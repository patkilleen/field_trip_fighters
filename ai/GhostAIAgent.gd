extends Node

#this is class that will generate random numbers to create commands
signal attempt_ripost

var situationHandler = null
var characterStateCollector = null
var enemyStateCollector = null
var aiDB = null
var npcInputManager = null

const PROBABILITY_OF_CORRECT_BLOCK = 0.75

const hitstunReversalTrackerResource = preload("res://ai/hitstunReversalTracker.gd")
var situationHandlerResource = preload("res://ai/GhostAISituationHandler.gd")
var stateCollectorResource = preload("res://ai/GhostAIStateCollector.gd")
var inputManagerResource = preload("res://input_manager.gd")
const GLOBALS = preload("res://Globals.gd")
var agentWorkerResource = null
var cpuPlayerController = null
var rng = null

var hitstunReversalTracker = null
var ablityBarCancelingNextFrame = false
var pushBlockNextFrame = false
var enabled = false

var gameMode = null
var agentWorker = null



var P_VALUE_TECH= 0.03
var PUSH_BLOCK_P_VALUE=0.2
var P_VALUE_CHOOSE_MOST_NON_SIMILARE_SITUATION = 0.5 #(0.05 is good )use this to have AI explore vs do what it learned. higher values mean expore. lower means more on history

var P_VALUE_RANDOM_FAST_FALL = 0.1 #0.01% fast fall, cause every frame is a lot of chances to fast fall
var P_VALUE_IGNORE_JUMP_CANCEL_ON_GROUND=0.4

var dpCmdMap = {}

var blockPunishCmdMap = {}
func _ready():
	pass

func init(aiDBFilePath,_npcInputManager,_cpuPlayerController,_gameMode,_botHeroName):
	
	gameMode = _gameMode
	situationHandler = situationHandlerResource.new()
	situationHandler.init(aiDBFilePath)
	
	
	dpCmdMap[GLOBALS.BELT_HERO_NAME]=inputManagerResource.Command.CMD_UPWARD_SPECIAL
	dpCmdMap[GLOBALS.MICROPHONE_HERO_NAME]=inputManagerResource.Command.CMD_UPWARD_MELEE
	dpCmdMap[GLOBALS.GLOVE_HERO_NAME]=inputManagerResource.Command.CMD_UPWARD_SPECIAL
	dpCmdMap[GLOBALS.HAT_HERO_NAME]=inputManagerResource.Command.CMD_AUTO_RIPOST #HAT doesn't have a DP
	dpCmdMap[GLOBALS.WHISTLE_HERO_NAME]=inputManagerResource.Command.CMD_AUTO_RIPOST #HAT doesn't have a DP
	
	blockPunishCmdMap[GLOBALS.BELT_HERO_NAME] = [inputManagerResource.Command.CMD_NEUTRAL_MELEE,inputManagerResource.Command.CMD_BACKWARD_MELEE,inputManagerResource.Command.CMD_FORWARD_MELEE,inputManagerResource.Command.CMD_DOWNWARD_MELEE,inputManagerResource.Command.CMD_DOWNWARD_SPECIAL]
	blockPunishCmdMap[GLOBALS.MICROPHONE_HERO_NAME] = [inputManagerResource.Command.CMD_NEUTRAL_MELEE,inputManagerResource.Command.CMD_BACKWARD_SPECIAL,inputManagerResource.Command.CMD_FORWARD_TOOL,inputManagerResource.Command.CMD_DOWNWARD_TOOL,inputManagerResource.Command.CMD_BACKWARD_TOOL]
	blockPunishCmdMap[GLOBALS.GLOVE_HERO_NAME] = [inputManagerResource.Command.CMD_NEUTRAL_MELEE,inputManagerResource.Command.CMD_BACKWARD_MELEE,inputManagerResource.Command.CMD_FORWARD_MELEE,inputManagerResource.Command.CMD_DOWNWARD_MELEE,inputManagerResource.Command.CMD_DOWNWARD_SPECIAL,inputManagerResource.Command.CMD_BACKWARD_SPECIAL]
	blockPunishCmdMap[GLOBALS.HAT_HERO_NAME] = [inputManagerResource.Command.CMD_NEUTRAL_MELEE,inputManagerResource.Command.CMD_BACKWARD_MELEE,inputManagerResource.Command.CMD_FORWARD_MELEE]
	blockPunishCmdMap[GLOBALS.WHISTLE_HERO_NAME] = [inputManagerResource.Command.CMD_NEUTRAL_MELEE,inputManagerResource.Command.CMD_DOWNWARD_MELEE,inputManagerResource.Command.CMD_DOWNWARD_SPECIAL]
	#should have 2 state collecotrs, one for character and one for enemy. the one connected mainly to characetr
	#will be used for logging demo data, and the enemey mainly connected one will be used to replay the command 
	#by ghost ai agent
	characterStateCollector = stateCollectorResource.new()
	enemyStateCollector = stateCollectorResource.new()
	characterStateCollector.init(_cpuPlayerController.opponentPlayerController,situationHandler,self)
	enemyStateCollector.init(_cpuPlayerController,situationHandler,self)
	
	characterStateCollector.collectingDemoData=false
	enemyStateCollector.collectingDemoData=false
	
	#add child (defeered to be mul-tithread safe) to enable physice_process calls to characterStateCollector
	self.call_deferred("add_child",characterStateCollector)
	self.call_deferred("add_child",enemyStateCollector)
	
	cpuPlayerController = _cpuPlayerController
	
	#make it so agent doesn't spazz when walking , has to explicitly say "stop walking"
	#cpuPlayerController.nullCommandStopsWalkingFlag = false
	
	aiDB = situationHandler.aiDB
	
	npcInputManager = _npcInputManager


	if gameMode == GLOBALS.GameModeType.PLAY_V_AI:
		hitstunReversalTracker = hitstunReversalTrackerResource.new()
		self.add_child(hitstunReversalTracker)
		
		var dpCmd = dpCmdMap[_botHeroName]
		var blockPunishCmds = blockPunishCmdMap[_botHeroName]
		hitstunReversalTracker.init(self,dpCmd,blockPunishCmds)
		
	rng = RandomNumberGenerator.new()
	
	#genreate time-based seed
	rng.randomize()
	
	agentWorkerResource = load("res://ai/GhostAIAgentWorker.gd")
	agentWorker = agentWorkerResource.new()
	#add the child so that group calls are enabled for pause/unpause
	self.call_deferred("add_child",agentWorker)
	agentWorker.init(self)
	agentWorker.connect("attempt_ripost",self,"_on_attempt_ripost")
	
	#enable()
	disable()
	
	cpuPlayerController.connect("entered_block_hitstun",self,"_on_entered_block_hitstun")
	cpuPlayerController.collisionHandler.connect("pushed_against_wall",self,"_on_wall_collide")
	cpuPlayerController.connect("landed",self,"_on_land")
	cpuPlayerController.collisionHandler.connect("pushed_against_ceiling",self,"_on_ceiling_collide")
	cpuPlayerController.actionAnimeManager.spriteAnimationManager.connect("sprite_frame_activated",self,"_on_sprite_frame_activated")
	

#func _physics_process(delta):
	
#	if not enabled:
#		print("warning, ai agent not enabled but physics process is true. turning physics process of (hint: call enable() instead of using set_physics_process(true))")
#		set_physics_process(false)
#		return 
	
#starts the command prediction and actioning
func enable():
	if enabled:
		return
	set_physics_process(true)
	enabled = true
	
	if not agentWorker.start():
		print("ghostaiAgent: failed to start worker")
		
	#set_physics_process(true)
#stops predicting commands and controlling the bot
func disable():
	
	if not enabled:
		return
		
	set_physics_process(false)
	enabled = false
	
	if npcInputManager != null:
		npcInputManager.cmd = null
	
	if agentWorker != null:
		agentWorker.stop()

	#set_physics_process(false)
func enableDemoDataCollection():
	
	#we don't enable the cpu's demo data collection, since its the player opponent 
	#that populates demo data
	characterStateCollector.collectingDemoData=true

func disableDemoDataCollection():
	
	characterStateCollector.collectingDemoData=false
	
	
func pollNextCommand():
	
	return agentWorker.pollCommand()
	
#this is api to allow to poll command even when agent not enabled
func estimateNextCommand():
	
	#get the situation the cpu is in
	var situationId = enemyStateCollector.parseCurentSituationId()
	
	return _estimateNextCommand(situationId)
	
#this function fetches the next command the agent will execute, given
#the current situation id
func _estimateNextCommand(situationId):
	
	var cmd = null
	
	if ablityBarCancelingNextFrame:
		#no longer bufeering the abilty cancel for next frame
		ablityBarCancelingNextFrame =false
		return	inputManagerResource.Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE
		
	if pushBlockNextFrame:
		pushBlockNextFrame=false
		return	inputManagerResource.Command.CMD_BUFFERED_PUSH_BLOCK
	#encountered situation before?
	if aiDB.hasSituationId(situationId):
	
		
		
		#get number of times situation occured
		var situationFrequency = situationHandler.aiDB.getSituationFrequency(situationId)
		
		
		
		#fetch the command map with key as command and value as command frequency
		var commandMap = situationHandler.aiDB.getSituationCommandMap(situationId)
		
		#avoid picking a null command if opponente in hitstun
	#	if cpuPlayerController.opponentPlayerController.playerState.inHitStun:
			#has null command and more than one command as option?
			
		#avoid null as a command
		if commandMap.has(null) and commandMap.keys().size() > 1:
			commandMap.erase(null) #remove the null command as option
		
			
		cmd = chooseCommandRandomly(commandMap,situationFrequency)
		
		
		#in case no event of command occurs, agent chooses to do nothing
	else:
		
		#note, this logic doesn't consider case where a siatuion could have 2 possible
		#comamnds, and one is more likely than the other base on freq, but should be fine
		
		
		#situation never occured, so gotta estimate which action to take
		var possibleCommands = cpuPlayerController.getAutoCancelableCommandList()
		
		#just usedc for command lookup when randomly choosing commands (only to select from autocancel list)
		var whiteListCommandMap = {}
		var bestSimilarity = -1 #1 is worst, so two is fine, since first sim we find will be better
		var candidateSituationIds = [] #list of situation ids with all equal best similarity
		
		#iterate the commands that are autocancelable and find their best similairy-situationid pair
		for _cmd in possibleCommands:
			
			#ignore null commands when opponenet in hitstun
			#if cpuPlayerController.opponentPlayerController.playerState.inHitStun and _cmd == null:
			#	continue
			#ignore null commands
			if _cmd == null:
				continue		
			#ignore jump commands on ground while hitting?
			var chooseNonOptimalSimilarSituation = generateProbabilistichEvent(P_VALUE_CHOOSE_MOST_NON_SIMILARE_SITUATION)
			#populate the lookup white list
			whiteListCommandMap[_cmd] = 0
			#find the most similare situation to ours that the command was played from before
			#, and get its similarity
			var bestSimSituationPair = situationHandler.findMostSimilarSituation(_cmd,situationId)
			
			#todo: consider case where we didn't train bot well enough, and a command doesn't return a similar situation
			#found a more similare situation?
			if bestSimSituationPair == null or bestSimSituationPair[situationHandler.MOST_SIMILAR_SITUATION_ID_IX] == null:
				continue
				pass
			
			#do we choose a situation that isn't necesarily optimial?
			#this is to remove local issues where the prediction that is most similar is bad
			var cpuOnGround = cpuPlayerController.my_is_on_floor()
			var playerOnGround = cpuPlayerController.opponentPlayerController.my_is_on_floor()
			var ignoreOnHitWindow =false
			var cpuHitting = cpuPlayerController.actionAnimeManager.isSpriteFrameHittingOpponent(ignoreOnHitWindow)
			if inputManagerResource.isJumpCommand(_cmd) and cpuOnGround and playerOnGround and cpuHitting and generateProbabilistichEvent(P_VALUE_IGNORE_JUMP_CANCEL_ON_GROUND):
				#ignore jump on hit when both cpu and player on ground most of the time to encourage grounder combos
				continue
			
			if bestSimSituationPair[situationHandler.MOST_SIMILAR_SITUATION_SIM_IX] > bestSimilarity:
				
				candidateSituationIds.clear()
				candidateSituationIds.append(bestSimSituationPair[situationHandler.MOST_SIMILAR_SITUATION_ID_IX])
				bestSimilarity= bestSimSituationPair[situationHandler.MOST_SIMILAR_SITUATION_SIM_IX]
				
			elif bestSimSituationPair[situationHandler.MOST_SIMILAR_SITUATION_SIM_IX] == bestSimilarity or chooseNonOptimalSimilarSituation:
				candidateSituationIds.append(bestSimSituationPair[situationHandler.MOST_SIMILAR_SITUATION_ID_IX])
			else:
				#not better, ignore nthis situation id
				pass
		
		#here goan have to pick a situation to use to see what command to use
		#easy case is one similar situation, but if more than 1, pick randomly,
		#and respect the command frequency-based probabbilty
		var estimatedSituationId=-1
		
		
		#onlye 1 best situation?	
		if candidateSituationIds.size() == 1:
			estimatedSituationId =candidateSituationIds[0]
			
		elif candidateSituationIds.size() > 1:
		
			
			#pick randomly an index to choose situation id
			var randomIx = rng.randi_range(0,candidateSituationIds.size()-1)
				
			estimatedSituationId = candidateSituationIds[randomIx]
		
		#if candidateSituationIds.size()>=0:
		#only choose the commands based on estimated situation if it exists
		if estimatedSituationId != -1:
			
			#pick commands from this situation 
			var commandMap = situationHandler.aiDB.getSituationCommandMap(estimatedSituationId)
			
			
			
			#get number of times situation occured
			var situationFrequency = situationHandler.aiDB.getSituationFrequency(estimatedSituationId)
			
			#some times situation never occured
			
			if situationFrequency == 0:
				cmd = chooseRandomElementFromList(possibleCommands)
				
			else:
				#execute chooseCommandRandomly until a candidate command was chosen 
				#from among a randomly chosen candidate situation ids
				cmd = _chooseCommandRandomly(commandMap,situationFrequency,whiteListCommandMap)
				
		else:
			
			cmd = chooseRandomElementFromList(possibleCommands)
				
	
	#for now, do a hacky way to avoid fast falling
	var canSelectFastFall = generateProbabilistichEvent(P_VALUE_RANDOM_FAST_FALL)		
	
	#selected fast fall but not allowd to input it?
	if not canSelectFastFall and cmd == inputManagerResource.Command.CMD_AIR_DASH_DOWNWARD:
		return null
			
	return cmd	

func chooseRandomElementFromList(list):
	
	if list == null or list.size() == 0:
		return null
	
	#only one choice?
	if list.size() == 1:
		return list[0]
		
	#only choose this fast fall with p P_VALUE_RANDOM_FAST_FALL
	var canSelectFastFall = generateProbabilistichEvent(P_VALUE_RANDOM_FAST_FALL)
	
		
	#choose a element randomly from available elements
	var ix = rng.randi_range(0,list.size()-1)
	var cmd = list[ix]
	
	#continue choosing a random command in case where we can't pick fast fall
	#while not canSelectFastFall and cmd == inputManagerResource.Command.CMD_AIR_DASH_DOWNWARD:
	#	ix = rng.randi_range(0,list.size()-1)
	#	cmd = list[ix]
					
	return cmd
	
#chooses a command at random based on rng and the probability of 
#command to occur and total frequency of sitautaions
#command map has command as key and frequency as value
func chooseCommandRandomly(commandMap,totalFreq):
	var cmdWhiteListMap = commandMap #no white list (the white list is the list of availalbe commands), consider all commands
	return _chooseCommandRandomly(commandMap,totalFreq,cmdWhiteListMap)
	
#chooses a command at random based on rng and the probability of 
#command to occur and total frequency of sitautaions, but only selects from among white list commands
#command map has command as key and frequency as value
func _chooseCommandRandomly(commandMap,totalFreq,cmdWhiteListMap):
	var cmd = null
	
	if totalFreq == 0:
		pass
		
	var candidateCommands = []
	
 	#iterate the commands, and see if event occurs of picking it
	for _cmd in commandMap.keys():
		#frequency of command
		var freq = commandMap[_cmd]
		
		#probablity of cmd
		var pvalue = float(freq)/totalFreq
		
		#command event occured?
		if generateProbabilistichEvent(pvalue) and cmdWhiteListMap.has(_cmd):	
			candidateCommands.append(_cmd)
		
	cmd = chooseRandomElementFromList(candidateCommands)	
	#choose uniforly at random among all commands who triggerd event
	return cmd
	

#generate an event (true or false ) with given probabliity
#pvalue: probablity of evnet [0,1]
#ture returns when event occurs
#false returned when it doesn't
func generateProbabilistichEvent(pvalue):

	var eventOccured = false


	#generate number between 0 -1 
	var r = rng.randf()
	
	#event occured? note that pobability 0 will never happen
	if r < pvalue:
		eventOccured = true
			
	return eventOccured
	
func _on_wall_collide(collider):
	
	if not enabled:
		return 
		
		
	#only see if tech occured when in hitstun
	if cpuPlayerController.playerState.inHitStun:
			
		attemptRandomTech()

func _on_ceiling_collide(collider):

	if not enabled:
		return 
		
	#only see if tech occured when in hitstun
	if cpuPlayerController.playerState.inHitStun:
				
		attemptRandomTech()

func _on_land():
	
	
	if not enabled:
		return 
		
	#only see if tech occured when in hitstun
	if cpuPlayerController.playerState.inHitStun:
			
		attemptRandomTech()

func attemptRandomTech():			
	#were gona be checking event that ground tech in place, tech left, or tech right occured
	
	#see if we do an in place tech
	var collisionTechRatio = situationHandler.aiDB.getFloorCollision_TechInPlaceRatio()
	
	#did tech event occur while respecting tech-collision ratio?
	#if generateProbabilistichEvent(collisionTechRatio):
	if generateProbabilistichEvent(P_VALUE_TECH/3.0):
		
		#don't input tech, just explicitly execute it
		#cpuPlayerController.attemptTech()
		#cpuPlayerController.techHandler._on_ceiling_collision(null)
		overrideLastCommand(inputManagerResource.Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE)
		return
	
	#see if we do forward tech
	collisionTechRatio = situationHandler.aiDB.getFloorCollision_TechForwardRatio()
	
	#did tech event occur while respecting tech-collision ratio?
	#if generateProbabilistichEvent(collisionTechRatio):
	if generateProbabilistichEvent(P_VALUE_TECH/3.0):
		
		#don't input tech, just explicitly execute it
		#cpuPlayerController.attemptTech()
		overrideLastCommand(inputManagerResource.Command.CMD_FORWARD_PUSH_BLOCK)
		#var rightFlag = true
		#cpuPlayerController.techHandler.attemptHorizontalTech(rightFlag)
		#var rightCmd = inputManagerResource.Command.CMD_MOVE_FORWARD
		#cpuPlayerController.techHandler.setTechDI(rightCmd)
		#if cpuPlayerController.kinbody.facingRight:
		#	cpuPlayerController.techHandler.dirInput=GLOBALS.DirectionalInput.FORWARD
		#else:
			#cpuPlayerController.techHandler.dirInput=GLOBALS.DirectionalInput.BACKWARD
		return
	#see if we do backward tech
	collisionTechRatio = situationHandler.aiDB.getFloorCollision_TechBackwardRatio()
	
	#did tech event occur while respecting tech-collision ratio?
	#if generateProbabilistichEvent(collisionTechRatio):
	if generateProbabilistichEvent(P_VALUE_TECH/3.0):
		
		#don't input tech, just explicitly execute it
	#	cpuPlayerController.attemptTech()
		overrideLastCommand(inputManagerResource.Command.CMD_BACKWARD_PUSH_BLOCK)
		#var rightFlag = false
		#cpuPlayerController.techHandler.attemptHorizontalTech(rightFlag)
		#var leftCmd = inputManagerResource.Command.CMD_MOVE_BACKWARD
		#cpuPlayerController.techHandler.setTechDI(leftCmd)
		#if cpuPlayerController.kinbody.facingRight:
	#		cpuPlayerController.techHandler.dirInput=GLOBALS.DirectionalInput.BACKWARD
	#	else:
	#		cpuPlayerController.techHandler.dirInput=GLOBALS.DirectionalInput.FORWARD
		return
	
	


				
func _on_sprite_frame_activated(spriteFrame):
	
	if not enabled:
		return 
		
	#probability of ability canceling in thie sprite frame
	var cancelProb = situationHandler.aiDB.getSpriteFrameActivation_AbilityCancelRatio(spriteFrame)
	
	#ablity cancel event? for now ignore amount of bar left
	#future work could be to condiser only to cancel if has enough bar
	if generateProbabilistichEvent(cancelProb):
		ablityBarCancelingNextFrame=true
		
		
func _on_attempt_ripost(cmdToRipost):
	emit_signal("attempt_ripost",cmdToRipost)
	
	
func _on_entered_block_hitstun(attackerHitbox,blockResult, spriteCurrentlyFacingRight):
	
	if generateProbabilistichEvent(PUSH_BLOCK_P_VALUE):
		pushBlockNextFrame = true
	#ghostAiAgent.cpuPlayerController.attemptPushBlock(ghostAiAgent.cpuPlayerController.inputManager.Command.CMD_BUFFERED_PUSH_BLOCK)
	
	
		
func overrideLastCommand(newCmd):
	#clear the buffer and make sure the reversal command gets processed
	#npcInputManager.cmdBuffer.clear()
	var _cmd = npcInputManager.getFacingDependantCommand(newCmd, cpuPlayerController.kinbody.facingRight)
	#npcInputManager.lastCommand = _cmd
	#npcInputManager.storeCommandInBuffer(_cmd)
	npcInputManager.cmd = _cmd
	#npcInputManager.lastDI = npcInputManager.cmdToDI(_cmd)
	
	
	#a block means ai will block for a brief moment (more than 1 frame)
	if isHighBlockRawCmd(newCmd):
		var isBlockingHigh = true
		agentWorker.startBlocking(isBlockingHigh)
	elif  isLowBlockRawCmd(newCmd):
		var isBlockingHigh = false
		agentWorker.startBlocking(isBlockingHigh)
	
	
func isHighBlockRawCmd(_cmd):
	
	return _cmd == inputManagerResource.Command.CMD_MOVE_BACKWARD or  _cmd== inputManagerResource.Command.CMD_BACKWARD_UP
	
func isLowBlockRawCmd(_cmd):
		
	return _cmd == inputManagerResource.Command.CMD_BACKWARD_CROUCH
	
	
func getCorrectBlockAttempt():
	
	var blockingHigh = false
	var blockCorrectly = generateProbabilistichEvent(PROBABILITY_OF_CORRECT_BLOCK)
	
	var opponentSA =  cpuPlayerController.opponentPlayerController.actionAnimeManager.getCurrentSpriteAnimation()
	if opponentSA != null:
		
		var isLowAttacking =opponentSA.hasLowHitbox
			
		if blockCorrectly:
			if isLowAttacking:
				#low block
				blockingHigh=false
			else:
				#high block
				blockingHigh=true
		else:
			if isLowAttacking:
				#high block
				blockingHigh=true
			else:
				#low block
				blockingHigh=false
	elif cpuPlayerController.opponentPlayerController.my_is_on_floor():

		#low block
		blockingHigh=false
	else:
		#high block
		blockingHigh=true
		
		
	return blockingHigh
