extends Node

signal attempt_ripost

const CMD_IX = 0
const SITUATION_ID_IX = 1

const TMP_CMD_SITUATION_PAIR_WINDOW_SIZE = 30
const GETTING_HIT_PUNISHEMENT = 4
const COMBO_REWARD = 10
const HITTING_REWARD = 3
#const GRAB_BLOCKING_OPPONENT_REWARD = 2
const GRAB_BLOCKING_OPPONENT_REWARD = 2
const BLOCK_STRING_REWARD = 1
const BROKE_OPPONENT_GUARD_REWARD = 3
const BLOCKED_A_HIT_CORRECTLY_REWARD = 3
const BLOCKED_A_HIT_INCORRECTLY_REWARD = 1
const HITTING_BLOCKING_OPPONENT_REWARD = 2
const PERFECT_BLOCK_REWARD = 2



const BLOCK_HOLD_BACK_MIN_DURATION_IN_FRAMES=5
var holdingBackBlock = false
var framesUntilHoldBackBlockEllasped = -1

const GLOBALS = preload("res://Globals.gd")
var inputManagerResource = preload("res://input_manager.gd")

var input_manager = null
var thread = null

#quere that will hold request command-situatioId pairs to log
var logQueue = []

var running = false

var ghostAiAgent = null

var nGramStrBeforeRipost = null
var initialized = false

var mutex = null
var semaphore = null
#var nextCommand = null

#var nextCommandBuffer  = []

var nextCommandMutex = null

var exit_thread = false

var paused = false

var nextCommand = null
const NEXT_CMD_QUEUE_CAPACITY = 8

const SPRITE_FRAME_IX=2


var cpuInOki= false
#for n-grams and riposting

#the biggest n-grams we using
const TO_N_GRAM_SIZE = 4
#the smallest n-grams we suing
const FROM_N_GRAM_SIZE = 2
var cmdFreqMap = {}
var playerCmdArray = []
var nGramMap = {}
var counterRipostFreqMap = {}
var ripostFreqMap = {}




#used to keept track of commands ai used in certain situations
var tmpCmdSituationPairBuffer = []

var riposting = false
var lockRiposts = false
var cmdToRipost = null
const BEST_CMD_IX = 0
const BEST_CMD_PVALUE_IX = 1
const NGRAM_STR_IX = 2

const MINIMUM_HITS_BEFORE_RIPOST_STARTS = 5
const NEXT_CMD_PROBABILITY_RIPOST_THRESHOLD = 0.9
#number times player hit cpu
var playerHitCount = 0
var totalPlayerHitCount = 0

var cmdStrMap = {
	inputManagerResource.Command.CMD_NEUTRAL_MELEE:"a",
	inputManagerResource.Command.CMD_BACKWARD_MELEE:"b",
	inputManagerResource.Command.CMD_FORWARD_MELEE:"c",
	inputManagerResource.Command.CMD_DOWNWARD_MELEE:"d",
	inputManagerResource.Command.CMD_UPWARD_MELEE:"e",
	inputManagerResource.Command.CMD_NEUTRAL_SPECIAL:"f",
	inputManagerResource.Command.CMD_BACKWARD_SPECIAL:"g",
	inputManagerResource.Command.CMD_FORWARD_SPECIAL:"h",
	inputManagerResource.Command.CMD_DOWNWARD_SPECIAL:"i",
	inputManagerResource.Command.CMD_UPWARD_SPECIAL:"j",
	inputManagerResource.Command.CMD_NEUTRAL_TOOL:"k",
	inputManagerResource.Command.CMD_BACKWARD_TOOL:"l",
	inputManagerResource.Command.CMD_FORWARD_TOOL:"m",
	inputManagerResource.Command.CMD_DOWNWARD_TOOL:"n",
	inputManagerResource.Command.CMD_UPWARD_TOOL:"o"
}

var airOnlyCommand = {
	inputManagerResource.Command.CMD_NEUTRAL_MELEE:inputManagerResource.Command.CMD_NEUTRAL_MELEE,
	inputManagerResource.Command.CMD_NEUTRAL_SPECIAL:inputManagerResource.Command.CMD_NEUTRAL_SPECIAL,
	inputManagerResource.Command.CMD_NEUTRAL_TOOL:inputManagerResource.Command.CMD_NEUTRAL_TOOL
}
func _ready():
	pass # Replace with function body.

func init(_ghostAiAgent):
	if _ghostAiAgent == null:
		print("AIWorker: error: could not initialize ghoost ai agent workern, null agent")
		return
	
	if initialized:
		print("AIWorker: warning: could not initialize ghoost ai agent workern, already initialized")
		return
		
	#MAKE sure this worker in group that indicates paused occured
	add_to_group(GLOBALS.GLOBAL_PAUSE_GROUP)
	
	input_manager = inputManagerResource.new()
	cpuInOki=false
	cmdFreqMap = {}
	playerCmdArray = []
	nGramMap = {}
	playerHitCount = 0
	riposting = false
	cmdToRipost = null
	set_physics_process(false)
	running = false
	initialized = true
	ghostAiAgent = _ghostAiAgent
	thread = Thread.new()
	mutex = Mutex.new()
	nextCommandMutex = Mutex.new()
	semaphore = Semaphore.new()
	


	ghostAiAgent.cpuPlayerController.collisionHandler.connect("player_was_hit",self,"_on_cpu_was_hit")
	
	#reward for hitting
	ghostAiAgent.cpuPlayerController.collisionHandler.connect("hitting_player",self,"_on_cpu_hitting_player")
	ghostAiAgent.cpuPlayerController.connect("pre_block_hitstun",self,"_on_pre_block_hitstun")
	ghostAiAgent.cpuPlayerController.opponentPlayerController.connect("grabbed_in_block",self,"_on_grabbing_blocking_opponent")
	ghostAiAgent.cpuPlayerController.opponentPlayerController.guardHandler.connect("guard_broken",self,"_on_opponent_guard_break")
	ghostAiAgent.cpuPlayerController.connect("block_stun_string",self,"_on_hit_block_stun_string")
	
	ghostAiAgent.cpuPlayerController.actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_sprite_animation_started")
		
	ghostAiAgent.cpuPlayerController.playerState.connect("changed_in_hitstun",self,"_on_cpu_hit_stun_change")
	ghostAiAgent.cpuPlayerController.opponentPlayerController.connect("counter_ripost_attempted",self,"_on_player_counter_ripost_attempted")
	ghostAiAgent.cpuPlayerController.connect("ripost_attempted",self,"_on_cpu_attempted_ripost")
	
	
#attempts to start the thread
#returns true when started, and false if something went wrong
#and we falied to start the worker
func start():
	
	if running:
		print("AIWorker: can't start thread, already running")
		return false
		
		
	#already running?
	#if running and thread.is_active():
	#	print("AIWorker: can't start thread, already active")
	#	return false
	
	#this shouldn't happen, but requested to stop but still active (waiting to finish in stop function)?
	#if not running and not thread.is_active():
	#	print("AIWorker: can't start thread, waiting for thread to finish in stop function")
	#	return false
	
	exit_thread=false
	running=true
	set_physics_process(true)
	var rc = thread.start(self,"_run",[]) 
	#var rc = OK
	if rc == OK:
		print("GHOST ai agent worker thread started")
		return true
	else:
		return false


func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	
	if holdingBackBlock:
		
		framesUntilHoldBackBlockEllasped=framesUntilHoldBackBlockEllasped-1
		
		#the minimum block time ellapsed?
		if framesUntilHoldBackBlockEllasped <=0:
			
			var inProximityGuard = ghostAiAgent.cpuPlayerController.collisionHandler.isProximityGuardEnabled()
			
			#are we still about to be hit (proximity guard enabled?)	
			if inProximityGuard:
				#keep blocking
				framesUntilHoldBackBlockEllasped=BLOCK_HOLD_BACK_MIN_DURATION_IN_FRAMES
			else:
				#break from block
				holdingBackBlock=false
	
	if not ghostAiAgent.cpuPlayerController.playerState.inHitStun:
		#if ghostAiAgent.cpuPlayerController.opponentPlayerController.actionAnimeManager.spriteAnimationManager.isInStartupAnimation() or ghostAiAgent.cpuPlayerController.opponentPlayerController.actionAnimeManager.spriteAnimationManager.isInActiveAnimation():		
		#about to be hit?
		if ghostAiAgent.cpuPlayerController.collisionHandler.isProximityGuardEnabled():
			
			#can the ai block?
			if  ghostAiAgent.cpuPlayerController.guardHandler.canHoldBackToBlock():
				
				var blockingHigh = ghostAiAgent.getCorrectBlockAttempt()
				#_nextCommand=nextCommand #we doe this cause  nextCommand is overrided by _nextCommand at end of thie func
				startBlocking(blockingHigh)

		
	
#this is the thread function
func _run(params):
	
	print("GhostAI agent wroker: starting in main worker function")
	running = true
	
	var timeEllasped=OS.get_system_time_msecs()
	var sleepDur= GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS/4.0 #sleep for 1/4th of a frame
	#loop infenitely until other thread stops this thread (running set to false)
	while(true):
		#limit the commands to 1/frame
		
		
			
		mutex.lock ()
		var is_paused = paused
		mutex.unlock()
		
		#stop the thread when game is paused
		if is_paused:
		#	print("worker agent run thread wating...")
			semaphore.wait() #this will unblock when game unpaused
		#	print("worker agent run thread stooped waiting.")
		
		mutex.lock ()
		var shouldexit = exit_thread
		mutex.unlock()
		#doe we exit out of thread?
		if shouldexit:
			break



	#tmp = tmp +1
	#first, check whether there are new cmd-situationId pairs to log
		if logQueue.size() > 0:
			
			#lets log them, lock the queue temporarily to make local copy
			#which won't starve out main thread for too long
			#lock access to the log queue
			mutex.lock()
			
			var queueCopy = []
			
			#coyp over elements (note, order doesn't matter, since just counting frequencies)
			for pair in logQueue:
				queueCopy.append(pair)
			
			logQueue.clear()
			
			#now that we don't need to touch the queue, can safely release lock 
			mutex.unlock()
			
			#log our local copy of pairs
			for pair in queueCopy:
				#store the situation id and command
				ghostAiAgent.situationHandler.aiDB.logCommandSituationPair(pair[CMD_IX],pair[SITUATION_ID_IX])
			
			
			
		#finishe logging queue
		
	#	print("finished emptyig queu")
		#estiamte next best command to be done by agent
		var _nextCommand = null
		
		#forcing block?
		if holdingBackBlock:
			_nextCommand=nextCommand
		else:
			_nextCommand= ghostAiAgent.estimateNextCommand()
			
			#blocking command? force ai to block for a brief moment
			if ghostAiAgent.isLowBlockRawCmd(_nextCommand):
				var blockingHigh = false
				startBlocking(blockingHigh)
			elif ghostAiAgent.isHighBlockRawCmd(_nextCommand):
				var blockingHigh = true
				startBlocking(blockingHigh)			
			
		#get the situation, and store cmd and situation temporarily
		var situationId = ghostAiAgent.enemyStateCollector.parseCurentSituationId()
		
		
	
		mutex.lock ()
		_nextCommand= handleHeroSpecificCmdOverride(_nextCommand)
		
		#cpu TRYING TO autoripost?
		if _nextCommand ==ghostAiAgent.inputManagerResource.Command.CMD_AUTO_RIPOST:
			#opponent in hitstun?
			if ghostAiAgent.cpuPlayerController.opponentPlayerController.playerState.inHitStun:
				#ignore autoripost commands when comboing
				_nextCommand=ghostAiAgent.inputManagerResource.Command.CMD_MOVE_FORWARD
		
		if _nextCommand == null: #no command?  let's replace it with something useful
			#opponent attacking?
			if ghostAiAgent.cpuPlayerController.opponentPlayerController.actionAnimeManager.spriteAnimationManager.isInStartupAnimation() or ghostAiAgent.cpuPlayerController.opponentPlayerController.actionAnimeManager.spriteAnimationManager.isInActiveAnimation():		
			
				var blockingHigh = ghostAiAgent.getCorrectBlockAttempt()
				_nextCommand=nextCommand #we doe this cause  nextCommand is overrided by _nextCommand at end of thie func
				startBlocking(blockingHigh)
			
			elif ghostAiAgent.cpuPlayerController.opponentPlayerController.actionAnimeManager.spriteAnimationManager.isInActiveAnimation():
			#they can be punish, engage
				_nextCommand=ghostAiAgent.inputManagerResource.Command.CMD_DASH_FORWARD
			else:	
				#when in doubt walk forward
				_nextCommand=ghostAiAgent.inputManagerResource.Command.CMD_MOVE_FORWARD
				
		#reading in thread should be fine
		var currAnimation = ghostAiAgent.cpuPlayerController.actionAnimeManager.spriteAnimationManager.currentAnimation
		if currAnimation != null:		
			var currSpriteFrame = currAnimation.getCurrentSpriteFrame()
			mutex.unlock ()
			storeCmdSituationPair(_nextCommand,situationId,currSpriteFrame)
		else:
			mutex.unlock ()
		
		semaphore.wait() #we wait until physics frame occurs (don't want to input commands faster than can process
		
		nextCommand=_nextCommand
		
		var timeEllaspedSinceLastLoop= OS.get_system_time_msecs()
		#has 1 frame went by since last run
		if (timeEllaspedSinceLastLoop-timeEllasped) >=GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS:
			timeEllasped=timeEllaspedSinceLastLoop
		else:
			
			OS.delay_msec(sleepDur)
			continue
			
	#	nextCommandMutex.lock()
		
	#	while(nextCommandBuffer.size() > NEXT_CMD_QUEUE_CAPACITY):
	#		nextCommandBuffer.pop_back()
	#	nextCommandBuffer.push_front(_nextCommand)
		
		
	#	nextCommandMutex.unlock()
		
	#	print("done estimating command")
		
	#	if tmp > 10:
	#		running = false
		pass

	print("GhostAI agent wroker: stopping in worker fucntion")
#stops the thread and waits for it to merge into this thread	
func stop():
	
	if not running:
		print("AIWorker: can't stop thread, not running")
		return
	
	
	set_physics_process(false)

    # Set exit condition to true.
	mutex.lock()

	exit_thread=true
	mutex.unlock()
	running = false
	
	
	# Unblock if paused for some reason
	semaphore.post()


	#wait for thread to finis
	thread.wait_to_finish()
	print("GHOST ai agent worker stopped")
	

#returns next command estimated by agent
func pollCommand():
	
	
	#nextCommandMutex.lock()
	
#	var _nextCmd = null
	
#	_nextCmd = nextCommandBuffer.pop_back()
	
#	nextCommandMutex.unlock()
	
	var resCmd = nextCommand

	#print("finsihed polling")
#	return _nextCmd

	#unblock the next command processing
	semaphore.post()
	
	return resCmd
	
#thread safe: requests the worker to log a command-situationid pair
func requestLogCommandSituationPair(cmd,situationId):
	
	#lock access to the log queue
	mutex.lock()
	
	#queue the pair to be logged by worker when it gets the chance
	logQueue.append([cmd,situationId])
	
	mutex.unlock()
	
# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	stop()
	
	
func _on_pause():
#	print("worker agent paused")
#	mutex .lock()
	paused = true
#	mutex .unlock()

func _on_unpause():
#	print("worker agent unpaused")
#	mutex .lock()
	paused = false
#	mutex .unlock()
	semaphore.post()


func _on_cpu_hit_stun_change(flag):
	if not running:
		return
		
	#no longer in hitstun?
	if not flag:
		#reset the combo tracking
		playerHitCount = 0
		

		#at this point, predicted a ripost but not hit, signal the prediction
		#to make the cpu illustrate it failed to guess the attack
		#if riposting:
		#	signalRipostAttempt()
			#ripostAttempt()
			#riposting=true
		
		#playerCmdArray.clear() #don't want to make ngrams of last hit in combo and starting hit of next
		riposting = false
		cmdToRipost = null
		
		#lockRiposts=false
	
		
		if ghostAiAgent.gameMode == GLOBALS.GameModeType.PLAY_V_AI:
			if cpuInOki:			
				ghostAiAgent.hitstunReversalTracker.prepareOkiReversalCmd()
				ghostAiAgent.hitstunReversalTracker.logPlayerOkiPattern()
			else:
				
				
				ghostAiAgent.hitstunReversalTracker.prepareHistunBreakReversalCmd()
				
				if ghostAiAgent.cpuPlayerController.my_is_on_floor():
					
					ghostAiAgent.hitstunReversalTracker.logPlayerGroundHitstunBreakPattern()
				else:
					
					ghostAiAgent.hitstunReversalTracker.logPlayerAirHitstunBreakPattern()
			
				
		

#this is never called.... i don't think
#maybe its useless?
#func _on_ripost_attempted(cmdRiposted,cmdHit,successFlag):
#	if not running:
#		return
	
	#riposting=false
	
	#lockRiposts=true
	
	#if successFlag: 
#	if not ripostFreqMap.has(cmdRiposted):
#		ripostFreqMap[cmdRiposted] = 0
		
	#increase number of times this command was succesffully riposted
#	ripostFreqMap[cmdRiposted] = ripostFreqMap[cmdRiposted] + 1
	
func _on_cpu_was_hit(otherHitboxArea, selfHurtboxArea):
	
	if not running:
		return	
	
	#ignore hits that are just for purpose of playing an action when near opponent
	if (otherHitboxArea.hitstunType == GLOBALS.HitStunType.NO_HITSTUN or otherHitboxArea.hitstunType == GLOBALS.HitStunType.ON_LINK_ONLY_AND_HITSTUNLESS) and not otherHitboxArea.ripostabled:
		return
	
	#can't be in oki if we are hit	
	cpuInOki=false
	
	#punish the cpu for being hit
	#punishRecentBehavior(GETTING_HIT_PUNISHEMENT)
	
	#the command we were hit by
	var cmd =otherHitboxArea.cmd

		
	#we ignore non ripostable commands, since only tracking in hitstun (don't ripost hitstunless moves, for now), and it matters
	#not if player crouched or move forward, it's important what he hits with consecutively
	#TODO: enable riposting hitstunless attacks
	#if (not ghostAiAgent.npcInputManager.ripostCommandReverseMap.has(cmd)) or (not ghostAiAgent.cpuPlayerController.playerState.inHitStun):
	if not ghostAiAgent.npcInputManager.ripostCommandReverseMap.has(cmd):
		return 

	#its assumed that F_melee in air = melee for cmd

	#count num times cpu was hit
	playerHitCount = playerHitCount + 1
	totalPlayerHitCount = totalPlayerHitCount + 1

	if not GLOBALS.DEMO_MODE_FLAG:
		#we only consider riposting after 1st hit
		if playerHitCount > 1:
			checkForRipost()
	
	if riposting:
		
		riposting=false
		
		#if otherHitboxArea.ripostabled and ghostAiAgent.cpuPlayerController.playerState.hasEnoughAbilityBar(ghostAiAgent.cpuPlayerController.ripostingAbilityBarCost):
		#	ghostAiAgent.cpuPlayerController.attemptRipost(ghostAiAgent.npcInputManager.getFacingDependantCommand(cmdToRipost,ghostAiAgent.cpuPlayerController.kinbody.facingRight))
				
		#	if not ghostAiAgent.cpuPlayerController.ripostHandler._on_player_was_hit(otherHitboxArea,selfHurtboxArea):
		#		pass
		signalRipostAttempt()	
	
			
		#lockRiposts =true 

	
		
	#increaseCommandFrequency of cmd
	if not cmdFreqMap.has(cmd):
		#first time command used to hit cpu
		cmdFreqMap[cmd] = 0
		
	cmdFreqMap[cmd] = cmdFreqMap[cmd] + 1
	
	#add to front (most recent commd)
	playerCmdArray.push_front(cmd)
	
	
	for nGramSize in range(FROM_N_GRAM_SIZE,TO_N_GRAM_SIZE+1,1): #iterate from 2 to 3 (+1 to include 3), by seps of 1
		#store 2-grams and 3-grams to help predict commands
		var nGramStr = parseNGram(nGramSize,playerCmdArray)
		increaseNGramFrequency(nGramStr)
func increaseNGramFrequency(nGramStr):
	
	if nGramStr == null:
		return
		
	#increase the ngram frequency
	if not nGramMap.has(nGramStr):
		#first time this combo sequence occured
		nGramMap[nGramStr] = 0
	nGramMap[nGramStr] = nGramMap[nGramStr] + 1


func parseNGram(nGramSize,cmdList):

	#ignore the first few cases during match when not enough
	#commands were input to create a ngram (e.g., only hit by two moves, by ngram size = 3. needs 1 more hit to start
	#storing ngram frequency)
	if cmdList.size() < nGramSize:
		return ""
	#fetch the latest 'nGramSize' commands and stringify them and append them to a string
	#that represents the commands
	
	var cmdNGramString = ""
	#the most recent are pushed to front of array, so start at index 0 for latest cmd
	for i in range(nGramSize):
		var cmd = cmdList[i]
		var cmdStr = cmdStrMap[cmd]
		cmdNGramString = cmdNGramString + cmdStr
		
	return cmdNGramString
	
func predictMostLikelyCommand():

	var bestPValue = 0
	var bestCmd = null
	var nGramStr =null
	
	#goal here, is given the command list, fetch most recent nGramSize -1 commands,
	#now, plug in 'cmd' here to form the ngram , and we want to see what is probability
	#of cmd given the ngram 'cmd' and most recent commands form
	
	for nGramSize in range(FROM_N_GRAM_SIZE,TO_N_GRAM_SIZE+1,1): #iterate from 2 to 3 (+1 to include 3), by seps of 1
		#target n-gram list used to parse n gram
		var targetCmdList = []
		
		if playerCmdArray.size () < nGramSize:
			continue
			
		for i in range(nGramSize -1 ):
			targetCmdList.append(playerCmdArray[i])
		
		#create the n-1_gram to then have a string to easily just append
		#the target command
		var nMinus1GramStr = parseNGram(nGramSize-1,targetCmdList)

		var playerInAir = not ghostAiAgent.cpuPlayerController.opponentPlayerController.my_is_on_floor()
		
		#iterate all observed commands so far (don't bother checking non-used commands, probability will be 0)
		for cmd in cmdFreqMap.keys():
			
			#don't condiser DI command (f-melee, e.g.) when player in air, since
			#they can't input such a command
			if playerInAir and not airOnlyCommand.has(cmd):
				continue
			
			#crate n gram string 
			nGramStr = cmdStrMap[cmd] + nMinus1GramStr
			
			#now get frequencies
			var nGramFreq = 0
			
			#only get frequency of n-gram if it exists, otherwise it's 0
			if nGramMap.has(nGramStr):
				nGramFreq = nGramMap[nGramStr]
				
			var cmdFreq = cmdFreqMap[cmd]
			
			#avoid divisions by 0 with 0 occurence frequency
			if nGramFreq == 0 or cmdFreq == 0:
				#don't bother checking, 0 probability
				continue
				
			var pvalue = float(nGramFreq)/cmdFreq #cast to float to avoid integer division
			
			#found more likely command?
			if pvalue > bestPValue:
				bestPValue=pvalue
				bestCmd = cmd
		
	
	return [bestCmd,bestPValue,nGramStr]
		
		

func checkForRipost():
	
	#already riposting, and haven't been hit yet
	#or already riposted this combo
	if riposting or lockRiposts or totalPlayerHitCount < MINIMUM_HITS_BEFORE_RIPOST_STARTS:
		return
		
	#mutex.lock()
	#only predict riposts when we have been hit atleast once and were in hitstun
	#if playerHitCount > 0 and ghostAiAgent.cpuPlayerController.playerState.inHitStun:
	#if ghostAiAgent.cpuPlayerController.playerState.inHitStun:
	
	var predictionRes = predictMostLikelyCommand()
	
	#execeeding ripost threshold?
	if predictionRes[BEST_CMD_PVALUE_IX] >= NEXT_CMD_PROBABILITY_RIPOST_THRESHOLD:
		
		riposting = true
		cmdToRipost = predictionRes[BEST_CMD_IX]
		nGramStrBeforeRipost=predictionRes[NGRAM_STR_IX]
		#ripost with probability to counter player's counter ripost habits
	#	if counterRipostFreqMap.has(predictionRes[BEST_CMD_IX]):
	#		if ripostFreqMap.has(predictionRes[BEST_CMD_IX]):
				
	#			var ripostFreq = ripostFreqMap[predictionRes[BEST_CMD_IX]]
	#			var counterRipostFreq = counterRipostFreqMap[predictionRes[BEST_CMD_IX]]
				
	#			if ripostFreq > 0:
					
					#0 means won't get ripost
					#1 means 1 for 1 (counter riposted each ripost)
					#0.5 means counter riposted half
					#var counterRipostPValue = float(counterRipostFreq)/ripostFreq
					
					#1- to generate even of should we ripost (don't want to get locked out of riposting, so apply 0.75 weight to
					#souncter riposting pvalue. so if player counter ripost each time, we have 25% chance riposting)
					#if ghostAiAgent.generateProbabilistichEvent(1-(counterRipostPValue*0.75)):
	#				if ghostAiAgent.generateProbabilistichEvent(1-(counterRipostPValue*0.75)):
	#					riposting = true
	#					cmdToRipost = predictionRes[BEST_CMD_IX]
						
	#	else:
			#ripost, haven't been countered beffore
		#	riposting = true
		#	cmdToRipost = predictionRes[BEST_CMD_IX]
		
			
			
	#mutex.unlock()

func signalRipostAttempt():
	emit_signal("attempt_ripost",cmdToRipost)	
	
	
func _on_player_counter_ripost_attempted(cmd,successFlag):
	
	if not running:
		return
	
	pass
	#if successFlag:
	#	if not counterRipostFreqMap.has(cmd):
	#		counterRipostFreqMap[cmd] = 0
	#		
	#	#increase number of times this command was counter riposted
	#	counterRipostFreqMap[cmd] = counterRipostFreqMap[cmd] + 1
		
	pass
	

func storeCmdSituationPair(cmd,situationId,currSpriteFrame):
	
	if situationId == null:
		return
	
	mutex.lock()	
	
	#leaky queue
	tmpCmdSituationPairBuffer.push_front([cmd,situationId,currSpriteFrame])
	
	if tmpCmdSituationPairBuffer.size() > TMP_CMD_SITUATION_PAIR_WINDOW_SIZE:
		tmpCmdSituationPairBuffer.pop_back()
	
	
	mutex.unlock()
		
func rewardRecentBehavior(rewardAmount):
	
	
	mutex.lock()	
	
	#store all the most recent situation-command pair for future lookup
	
	for pair in tmpCmdSituationPairBuffer:
		
		if pair.size() != 3:
				continue
				
		if pair != null:
			
			#reward a certain number
			for i in range(0,rewardAmount):
				
				
				#store the situation id and command (ignore null commands. doing nothing is never a good thing)
				if pair[CMD_IX] != null:
					ghostAiAgent.situationHandler.aiDB.logCommandSituationPair(pair[CMD_IX],pair[SITUATION_ID_IX])

	#now clear the recent behavior buffer
	tmpCmdSituationPairBuffer.clear()
	
	mutex.unlock()
	
	pass
	
func punishRecentBehavior(severity):
	
	#ignore punishing, wan tto avoid having bot do nothing in response to getting wrecked
	return
	#increment frequencies of commands all but those found in buffer (for a siturion
	#make is so everyt other possible command in the scenerio ir more likely)
# warning-ignore:unreachable_code
	mutex.lock()	
	
	#store all the most recent situation-command pair for future lookup
	
	for pair in tmpCmdSituationPairBuffer:
		if pair != null:
			
			if pair.size() != 3:
				continue
				
			var situationId = pair[SITUATION_ID_IX]
			var spriteFrame = pair[SPRITE_FRAME_IX]
			
			var autoCancelActionIds = ghostAiAgent.cpuPlayerController.actionAnimeManager.__getAutoCancelableActionIds(ghostAiAgent.cpuPlayerController.actionAnimeManager.AUTO_CANCEL_COMMANDS_ALL,spriteFrame)
			
			if autoCancelActionIds == null or autoCancelActionIds.size() ==0:
				continue
			#var situationPossibleCmds = ghostAiAgent.situationHandler.aiDB.getListOfCommands(situationId)
			var situationPossibleCmds =ghostAiAgent.cpuPlayerController._getAutoCancelableCommandList(autoCancelActionIds)
			
			#store the punished command once just for chance it occurs again
			ghostAiAgent.situationHandler.aiDB.logCommandSituationPair(pair[CMD_IX],situationId)
			
			if situationPossibleCmds != null:
				#ietare all commands possible in situation
				for cmd in situationPossibleCmds:
					
					#increment freq of all but the recent command
					if cmd != pair[CMD_IX]:
						
						#increment based on punishement severity
						for i in range (0,severity):
							#store the situation id and command
							ghostAiAgent.situationHandler.aiDB.logCommandSituationPair(cmd,situationId)

	#now clear the recent behavior buffer
	tmpCmdSituationPairBuffer.clear()
	
	mutex.unlock()
	
func _on_cpu_hitting_player(selfHitboxArea, otherHurtboxArea):

	#don't reward hitting blocking opponent
	if not ghostAiAgent.cpuPlayerController.opponentPlayerController.guardHandler.isBlocking():
		
		#ai landed a combo?
		if ghostAiAgent.cpuPlayerController.playerState.combo >=1:
			rewardRecentBehavior(COMBO_REWARD)
		else:
			rewardRecentBehavior(HITTING_REWARD)			
		
	#throwing oponent u get rewarded
	else:
		
		rewardRecentBehavior(HITTING_BLOCKING_OPPONENT_REWARD)	

	
func _on_pre_block_hitstun(hitbox,blockResult,facingRight):

	if blockResult == GLOBALS.BlockResult.INCORRECT:
		rewardRecentBehavior(BLOCKED_A_HIT_INCORRECTLY_REWARD)
	elif blockResult == GLOBALS.BlockResult.CORRECT:
		rewardRecentBehavior(BLOCKED_A_HIT_CORRECTLY_REWARD)
func _on_grabbing_blocking_opponent():
	rewardRecentBehavior(GRAB_BLOCKING_OPPONENT_REWARD)
	
func _on_opponent_guard_break(highBlockFlag,amountGuardOpponentRegened):
	rewardRecentBehavior(BROKE_OPPONENT_GUARD_REWARD)
	
func _on_hit_block_stun_string():
	rewardRecentBehavior(BLOCK_STRING_REWARD)
	
	
func _on_sprite_animation_started(sa):
	if not running:
		return
	
	var _isOki = sa.id == ghostAiAgent.cpuPlayerController.opponentPlayerController.actionAnimeManager.LANDING_HITSTUN_SPRITE_ANIME_ID
	
	if _isOki:
		cpuInOki=true
		playerHitCount =0
	pass

#this forces AI to block for a brief moment
func startBlocking(blockHighFlag):
	if not running:
		return
		
	holdingBackBlock = true
	framesUntilHoldBackBlockEllasped=BLOCK_HOLD_BACK_MIN_DURATION_IN_FRAMES
	
	if blockHighFlag:
		nextCommand = ghostAiAgent.inputManagerResource.Command.CMD_MOVE_BACKWARD
	else:
		nextCommand = ghostAiAgent.inputManagerResource.Command.CMD_BACKWARD_CROUCH
	


func _on_cpu_attempted_ripost(cmdRiposted,cmdHitBy,successFlag,ripostedInNeutral):
	if not running:
		return
	
	
	#fail?
	if not successFlag:
		#clear the history of playe rinput. they learned to punish cpus
		cmdFreqMap = {}
		playerCmdArray = []
#		nGramMap = {}
		totalPlayerHitCount=0	
		if nGramStrBeforeRipost != null:
			nGramMap[nGramStrBeforeRipost] = 0 #clear any memory of combo that lead to fail
	

func handleHeroSpecificCmdOverride(_nextCommand):

	#whistle hero being player
	if ghostAiAgent.cpuPlayerController.heroName == ghostAiAgent.GLOBALS.WHISTLE_HERO_NAME:
		#on the floor?
		if ghostAiAgent.cpuPlayerController.my_is_on_floor():
			#out of bones?
			if  ghostAiAgent.cpuPlayerController.collar.currNumBones == ghostAiAgent.cpuPlayerController.collar.MIN_NUMBER_BONES:
				#any bone required command converted to d tool when in neutral (not the sifflet stance)
				if  ghostAiAgent.cpuPlayerController.actionAnimeManager.isInSiffletStance():
					
					#TOOL command?
					match(_nextCommand):
						
						#MAKE SURE BONE required command converted to down tool to obtain more bones
						inputManagerResource.Command.CMD_BACKWARD_TOOL,inputManagerResource.Command.CMD_FORWARD_TOOL,inputManagerResource.Command.CMD_UPWARD_TOOL:
							_nextCommand = inputManagerResource.Command.CMD_DOWNWARD_TOOL
						_:
							pass#keep comand
	return _nextCommand	