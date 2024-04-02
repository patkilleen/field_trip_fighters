extends Node

const inputManagerResource = preload("res://input_manager.gd")
const GLOBALS = preload("res://Globals.gd")
const forgetfulCounterResource = preload("res://ai/forgetfulCounter.gd")

const FORGETFUL_HITSTUN_COUNTER_SIZE = 7

const HITSTUN_REVERSAL_IX_AUTO_RIPOST = 0
const HITSTUN_REVERSAL_IX_GRAB = 1
const HITSTUN_REVERSAL_IX_MEATY = 2
const HITSTUN_REVERSAL_IX_BLOCK = 3
const HITSTUN_REVERSAL_IX_RECOVERY = 4
const HITSTUN_REVERSAL_IX_DEFAULT = 5

var attackDistance = 75 # a rough estimate of when opponent in range to attack 
var autoRiposted = false
var ghostAiAgent = null
var okiOptionMap = {}
var okiOptionCounterMap = {}

var groundHitstunBreakOptionMap = {}
var groundHitstunBreakOptionCounterMap = {}
var airHitstunBreakOptionMap = {}
var airHitstunBreakOptionCounterMap = {}

var groundBlockstunBreakOptionMap = {}
var groundBlockstunBreakOptionCounterMap = {}
var airBlockstunBreakOptionMap = {}
var airBlockstunBreakOptionCounterMap = {}


var aggressiveCmds = []
var trackingReversal=false
var reversalActionPlayed = false
var activeReversalCmd=null
var activeReversalForgetfulCounter = null

var ripostSuccededFlag = false

var cmdDP = null
var blockPunishCmds = null
# Called when the node enters the scene tree for the first time.
func _ready():
	
	aggressiveCmds=[inputManagerResource.Command.CMD_NEUTRAL_MELEE,
	inputManagerResource.Command.CMD_BACKWARD_MELEE,
	inputManagerResource.Command.CMD_FORWARD_MELEE,
	inputManagerResource.Command.CMD_DOWNWARD_MELEE,
	inputManagerResource.Command.CMD_UPWARD_MELEE,
	inputManagerResource.Command.CMD_NEUTRAL_SPECIAL,
	inputManagerResource.Command.CMD_BACKWARD_SPECIAL,
	inputManagerResource.Command.CMD_FORWARD_SPECIAL,
	inputManagerResource.Command.CMD_DOWNWARD_SPECIAL,
	inputManagerResource.Command.CMD_UPWARD_SPECIAL,
	inputManagerResource.Command.CMD_NEUTRAL_TOOL,
	inputManagerResource.Command.CMD_BACKWARD_TOOL,
	inputManagerResource.Command.CMD_FORWARD_TOOL,
	inputManagerResource.Command.CMD_DOWNWARD_TOOL,
	inputManagerResource.Command.CMD_UPWARD_TOOL,
	inputManagerResource.Command.CMD_GRAB,
	inputManagerResource.Command.CMD_DASH_FORWARD,
	inputManagerResource.Command.CMD_JUMP_FORWARD]
	
	okiOptionMap = {}
	okiOptionMap[HITSTUN_REVERSAL_IX_AUTO_RIPOST]=createForgetfulCounter()
	okiOptionMap[HITSTUN_REVERSAL_IX_GRAB]=createForgetfulCounter()
	okiOptionMap[HITSTUN_REVERSAL_IX_MEATY]=createForgetfulCounter()
	okiOptionMap[HITSTUN_REVERSAL_IX_BLOCK]=createForgetfulCounter()
	okiOptionMap[HITSTUN_REVERSAL_IX_RECOVERY]=createForgetfulCounter()
	okiOptionMap[HITSTUN_REVERSAL_IX_DEFAULT]=createForgetfulCounter()
	#WILL always be the default by being 1 more than all others,
	okiOptionMap[HITSTUN_REVERSAL_IX_DEFAULT].increment()
	okiOptionMap[HITSTUN_REVERSAL_IX_DEFAULT].lock()
	
	groundHitstunBreakOptionMap={}
	groundHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_AUTO_RIPOST]=createForgetfulCounter()
	groundHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_GRAB]=createForgetfulCounter()
	groundHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_MEATY]=createForgetfulCounter()
	groundHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_BLOCK]=createForgetfulCounter()
	groundHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_RECOVERY]=createForgetfulCounter()
	groundHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_DEFAULT]=createForgetfulCounter()
	#WILL always be the default by being 1 more than all others
	groundHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_DEFAULT].increment()
	groundHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_DEFAULT].lock()
	
	airHitstunBreakOptionMap = {}
	airHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_AUTO_RIPOST]=createForgetfulCounter()
	airHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_GRAB]=createForgetfulCounter()
	airHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_MEATY]=createForgetfulCounter()
	airHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_BLOCK]=createForgetfulCounter()
	airHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_RECOVERY]=createForgetfulCounter()
	airHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_DEFAULT]=createForgetfulCounter()
	#WILL always be the default by being 1 more than all others
	airHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_DEFAULT].increment()
	airHitstunBreakOptionMap[HITSTUN_REVERSAL_IX_DEFAULT].lock()
	
	
	groundBlockstunBreakOptionMap={}
	groundBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_AUTO_RIPOST]=createForgetfulCounter()
	groundBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_GRAB]=createForgetfulCounter()
	groundBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_MEATY]=createForgetfulCounter()
	groundBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_BLOCK]=createForgetfulCounter()
	groundBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_RECOVERY]=createForgetfulCounter()
	groundBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_DEFAULT]=createForgetfulCounter()
	#WILL always be the default by being 1 more than all others
	groundBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_DEFAULT].increment()
	groundBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_DEFAULT].lock()
	
	
	airBlockstunBreakOptionMap = {}
	airBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_AUTO_RIPOST]=createForgetfulCounter()
	airBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_GRAB]=createForgetfulCounter()
	airBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_MEATY]=createForgetfulCounter()
	airBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_BLOCK]=createForgetfulCounter()
	airBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_RECOVERY]=createForgetfulCounter()
	airBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_DEFAULT]=createForgetfulCounter()
	#WILL always be the default by being 1 more than all others
	airBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_DEFAULT].increment()
	airBlockstunBreakOptionMap[HITSTUN_REVERSAL_IX_DEFAULT].lock()
	
	

	okiOptionCounterMap[HITSTUN_REVERSAL_IX_AUTO_RIPOST]=[inputManagerResource.Command.CMD_GRAB]#GRAB beats autoripost
	okiOptionCounterMap[HITSTUN_REVERSAL_IX_GRAB]=aggressiveCmds #any attack beats grab
	okiOptionCounterMap[HITSTUN_REVERSAL_IX_MEATY]=[GLOBALS.DP_FILLER_COMMAND,GLOBALS.DP_FILLER_COMMAND,inputManagerResource.Command.CMD_AUTO_RIPOST]#DP and autoripost beat meaty (MAKE DP abit more likely by including twice)
	okiOptionCounterMap[HITSTUN_REVERSAL_IX_BLOCK]=aggressiveCmds#should be anything but DP, but now implemented yet

	#HITSTUN_REVERSAL_IX_RECOVERY SAME AS BLOCK. GO OFFENSIVE
	okiOptionCounterMap[HITSTUN_REVERSAL_IX_RECOVERY] =okiOptionCounterMap[HITSTUN_REVERSAL_IX_BLOCK]
	okiOptionCounterMap[HITSTUN_REVERSAL_IX_DEFAULT]=[inputManagerResource.Command.CMD_MOVE_BACKWARD,inputManagerResource.Command.CMD_BACKWARD_CROUCH,inputManagerResource.Command.CMD_JUMP_BACKWARD]#in all other situations block
	
	#oki and ground hitstun should be same reversal
	groundHitstunBreakOptionCounterMap =okiOptionCounterMap
	groundBlockstunBreakOptionCounterMap=okiOptionCounterMap

	airHitstunBreakOptionCounterMap[HITSTUN_REVERSAL_IX_AUTO_RIPOST]=[inputManagerResource.Command.CMD_GRAB,inputManagerResource.Command.CMD_GRAB,inputManagerResource.Command.CMD_DASH_FORWARD,inputManagerResource.Command.CMD_DASH_BACKWARD,inputManagerResource.Command.CMD_DASH_BACKWARD,inputManagerResource.Command.CMD_AIR_DASH_DOWNWARD,inputManagerResource.Command.CMD_JUMP_FORWARD,inputManagerResource.Command.CMD_JUMP_BACKWARD,inputManagerResource.Command.CMD_JUMP]#GRAB beats autoripost (doing nothing does too)
	airHitstunBreakOptionCounterMap[HITSTUN_REVERSAL_IX_GRAB]=[inputManagerResource.Command.CMD_NEUTRAL_TOOL,inputManagerResource.Command.CMD_NEUTRAL_SPECIAL,inputManagerResource.Command.CMD_NEUTRAL_MELEE,inputManagerResource.Command.CMD_DASH_FORWARD,inputManagerResource.Command.CMD_DASH_BACKWARD,inputManagerResource.Command.CMD_DASH_BACKWARD,inputManagerResource.Command.CMD_AIR_DASH_DOWNWARD]#dash away from meaty grab, or attack
	airHitstunBreakOptionCounterMap[HITSTUN_REVERSAL_IX_MEATY]=[inputManagerResource.Command.CMD_AUTO_RIPOST,inputManagerResource.Command.CMD_BACKWARD_CROUCH,inputManagerResource.Command.CMD_MOVE_BACKWARD,inputManagerResource.Command.CMD_MOVE_BACKWARD]#blocking is best option, and autoripost can work at times
	airHitstunBreakOptionCounterMap[HITSTUN_REVERSAL_IX_BLOCK]=[#anything but DP and autoripost beat block
	inputManagerResource.Command.CMD_NEUTRAL_MELEE,
	inputManagerResource.Command.CMD_NEUTRAL_SPECIAL,
	inputManagerResource.Command.CMD_NEUTRAL_TOOL,
	inputManagerResource.Command.CMD_GRAB,
	inputManagerResource.Command.CMD_DASH_FORWARD,
	inputManagerResource.Command.CMD_DASH_FORWARD,
	inputManagerResource.Command.CMD_JUMP_FORWARD,
	inputManagerResource.Command.CMD_JUMP_FORWARD,
	inputManagerResource.Command.CMD_AIR_DASH_DOWNWARD,
	inputManagerResource.Command.CMD_AIR_DASH_DOWNWARD]
	#HITSTUN_REVERSAL_IX_RECOVERY SAME AS BLOCK. GO OFFENSIVE
	airHitstunBreakOptionCounterMap[HITSTUN_REVERSAL_IX_RECOVERY] =okiOptionCounterMap[HITSTUN_REVERSAL_IX_BLOCK]
	airHitstunBreakOptionCounterMap[HITSTUN_REVERSAL_IX_DEFAULT]=okiOptionCounterMap[HITSTUN_REVERSAL_IX_DEFAULT]
	
	airBlockstunBreakOptionCounterMap=airHitstunBreakOptionCounterMap

	pass # Replace with function body.


func _updateAllOptionTackings(_map):
	
	for option in  _map.keys():		
		_map[option].update()
		
func init(_ghostAiAgent,_cmdDP,_blockPunishCmds):
	ghostAiAgent = _ghostAiAgent
	cmdDP = _cmdDP
	blockPunishCmds = _blockPunishCmds
	ghostAiAgent.cpuPlayerController.collisionHandler.connect("player_was_hit",self,"_on_cpu_was_hit")
	ghostAiAgent.cpuPlayerController.collisionHandler.connect("player_invincible_was_hit",self,"_on_cpu_invincibility_was_hit")
	
	ghostAiAgent.cpuPlayerController.collisionHandler.connect("hitting_player",self,"_on_cpu_hitting_player")
	
	ghostAiAgent.cpuPlayerController.actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_sprite_animation_started")
	ghostAiAgent.cpuPlayerController.actionAnimeManager.spriteAnimationManager.connect("finished",self,"_on_sprite_animation_finished")
	
	ghostAiAgent.cpuPlayerController.opponentPlayerController.guardHandler.connect("guard_broken",self,"_on_opponent_guard_break")
	
	ghostAiAgent.cpuPlayerController.connect("exited_block_stun",self,"_on_cpu_exited_block_stun")
	ghostAiAgent.cpuPlayerController.opponentPlayerController.connect("exited_block_stun",self,"_on_player_exited_block_stun")

	ghostAiAgent.cpuPlayerController.connect("ripost_attempted",self,"_on_cpu_attempted_ripost")
	
	ghostAiAgent.cpuPlayerController.opponentPlayerController.playerState.connect("changed_in_hitstun",self,"_on_player_hit_stun_change")
	
	autoRiposted = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

	
func prepareOkiReversalCmd():
	_prepareHitstunBreakReversalCmd(okiOptionMap,okiOptionCounterMap)
	
func _prepareHitstunBreakReversalCmd(_map,_counerMap):
		

		var bestOptions=[]
		var bestOptionFreq=-1
		#find the player's most likely patterns when cpu wakesup from oki
		for option in _map.keys():
			var forgetfulCounter = _map[option]
			var freq =forgetfulCounter.computeSum()
			
			#found better option?
			if	freq > bestOptionFreq:			
				bestOptions.clear()
				bestOptionFreq=freq
				bestOptions.append(option)
			elif freq == bestOptionFreq:
				bestOptions.append(option)
		
		#the commands cpu has available to punish the predictable opponent
		var cmdOptions =[]
		#fill cmd list
		for bestOption in bestOptions:
			
			var counterCmdList = _counerMap[bestOption]
			
			var forgetfulCounter=_map[bestOption]
			for cmd in counterCmdList:
				
				#add command to list and tie it to the forgetful counter to track the reversal in abit
				cmdOptions.append([cmd,forgetfulCounter])
		
		var reversalCmdPair	= ghostAiAgent.chooseRandomElementFromList(cmdOptions)
		
		var reversalCmd =reversalCmdPair[0]
		var forgetfulCounter =reversalCmdPair[1]
		#cpu trying to autoripost?
		if reversalCmd == inputManagerResource.Command.CMD_AUTO_RIPOST:
			
			#number of ability bar chunks in full bar
			var fullBarChunks = ghostAiAgent.cpuPlayerController.playerState.abilityNumberOfChunks
			#make sure CPU has at least  half a full ability bar to avoid needless spending
			if not ghostAiAgent.cpuPlayerController.playerState.hasEnoughAbilityBar(fullBarChunks/2.0):
				#cpu doesn't have much bar, so DP instead
				reversalCmd =cmdDP
				
		
		
		#not block cmd?
		if reversalCmd != inputManagerResource.Command.CMD_MOVE_BACKWARD and  reversalCmd !=  inputManagerResource.Command.CMD_BACKWARD_CROUCH:
			
			#CPU wants to DP but in the air?
			if reversalCmd == GLOBALS.DP_FILLER_COMMAND and not ghostAiAgent.cpuPlayerController.my_is_on_floor():
				#high block instead
				reversalCmd =inputManagerResource.Command.CMD_MOVE_BACKWARD
			else:
				#we check distance to opponent
				var playerTooFarAway = ghostAiAgent.cpuPlayerController.kinbody.distanceToOpponent() > attackDistance
				if playerTooFarAway:
					
					if reversalCmd == inputManagerResource.Command.CMD_AUTO_RIPOST or reversalCmd == GLOBALS.DP_FILLER_COMMAND:
						
						#NO OTther option than to  block predicted meaty active
						
						if ghostAiAgent.cpuPlayerController.opponentPlayerController.my_is_on_floor():
							
								var blockingHigh = ghostAiAgent.getCorrectBlockAttempt()
								
								if blockingHigh:
									#low block
									reversalCmd =inputManagerResource.Command.CMD_MOVE_BACKWARD
								else:
									#high block
									reversalCmd =inputManagerResource.Command.CMD_BACKWARD_CROUCH

						else:
							#high block
							reversalCmd =inputManagerResource.Command.CMD_MOVE_BACKWARD
					else:
						#NO OTther option than to low block
						reversalCmd =inputManagerResource.Command.CMD_DASH_FORWARD
			
		#ghost ai wants to DP?		
		if reversalCmd == GLOBALS.DP_FILLER_COMMAND:
			reversalCmd= cmdDP
			
		ghostAiAgent.overrideLastCommand(reversalCmd)
		startTrackingReversalOption(reversalCmd,forgetfulCounter)
		

func logPlayerOkiPattern():
	_logPlayerHistunBreakPattern(okiOptionMap)

func logPlayerGroundHitstunBreakPattern():
	_logPlayerHistunBreakPattern(groundHitstunBreakOptionMap)

func logPlayerAirHitstunBreakPattern():
	_logPlayerHistunBreakPattern(airHitstunBreakOptionMap)


func logPlayerGroundBlockstunBreakPattern():
	_logPlayerHistunBreakPattern(groundBlockstunBreakOptionMap)

func logPlayerAirBlockstunBreakPattern():
	_logPlayerHistunBreakPattern(airBlockstunBreakOptionMap)
	
func _logPlayerHistunBreakPattern(_patternMap):
	
#called when CPU wakes up from oki

	
	var playerActionMngr=ghostAiAgent.cpuPlayerController.opponentPlayerController.actionAnimeManager
	var playerSAMngr = playerActionMngr.spriteAnimationManager
	
	
	var isAutoRiposting = playerActionMngr.isCurrentSpriteAnimation(playerActionMngr.AIR_AUTO_RIPOST_ACTION_ID)
	isAutoRiposting = isAutoRiposting or playerActionMngr.isCurrentSpriteAnimation(playerActionMngr.AUTO_RIPOST_ACTION_ID)
	
	if isAutoRiposting:
		#grab
		#_patternMap[HITSTUN_REVERSAL_IX_AUTO_RIPOST]=_patternMap[HITSTUN_REVERSAL_IX_AUTO_RIPOST]+1
		_patternMap[HITSTUN_REVERSAL_IX_AUTO_RIPOST].increment()

	else:
		var isPlayerBlocking = ghostAiAgent.cpuPlayerController.opponentPlayerController.guardHandler.canHoldBackToBlock()
		
		if isPlayerBlocking:
			#bot should attack (not DP). I suppose anything but dp is fine
			#_patternMap[HITSTUN_REVERSAL_IX_BLOCK]=_patternMap[HITSTUN_REVERSAL_IX_BLOCK]+1
			_patternMap[HITSTUN_REVERSAL_IX_BLOCK].increment()
			
		else:
			#
			var isGrabbing =playerActionMngr.isCurrentSpriteAnimation(playerActionMngr.GROUND_GRAB_ACTION_ID)
			isGrabbing = isGrabbing or playerActionMngr.isCurrentSpriteAnimation(playerActionMngr.AIR_GRAB_ACTION_ID)
			
			
			if isGrabbing:
				#DP
				#_patternMap[HITSTUN_REVERSAL_IX_GRAB]=_patternMap[HITSTUN_REVERSAL_IX_GRAB]+1
				_patternMap[HITSTUN_REVERSAL_IX_GRAB].increment()
				
			else:
				
				#meaty incoming or is active?
				var meatyActive = playerSAMngr.isInStartupAnimation()
				meatyActive = meatyActive or playerSAMngr.isInActiveAnimation()
				
				if meatyActive:
					#DP or autoripost
					#_patternMap[HITSTUN_REVERSAL_IX_MEATY]=_patternMap[HITSTUN_REVERSAL_IX_MEATY]+1
					_patternMap[HITSTUN_REVERSAL_IX_MEATY].increment()
					
				else:
					
					var inRecovery =playerSAMngr.isInRecoveryAnimation()
					
					if inRecovery:
						
						#_patternMap[HITSTUN_REVERSAL_IX_RECOVERY]=_patternMap[HITSTUN_REVERSAL_IX_RECOVERY]+1
						_patternMap[HITSTUN_REVERSAL_IX_RECOVERY].increment()
					else:
														
						pass
						#_patternMap[HITSTUN_REVERSAL_IX_DEFAULT]=_patternMap[HITSTUN_REVERSAL_IX_DEFAULT]+1
						#_patternMap[HITSTUN_REVERSAL_IX_DEFAULT].increment()
					#do ANYTHING
	
	
	_updateAllOptionTackings(_patternMap)

				
func prepareHistunBreakReversalCmd():
	
	var mapOfInterest =null
	var counterCmdMapOfInterest =null
	if ghostAiAgent.cpuPlayerController.my_is_on_floor():
		mapOfInterest=groundHitstunBreakOptionMap
		counterCmdMapOfInterest=groundHitstunBreakOptionCounterMap
	else:
		mapOfInterest=airHitstunBreakOptionMap
		counterCmdMapOfInterest=airHitstunBreakOptionCounterMap
	
	_prepareHitstunBreakReversalCmd(mapOfInterest,counterCmdMapOfInterest)					
	
func prepareBlockstunBreakReversalCmd():
	
	var mapOfInterest =null
	var counterCmdMapOfInterest =null
	if ghostAiAgent.cpuPlayerController.my_is_on_floor():
		mapOfInterest=groundBlockstunBreakOptionMap
		counterCmdMapOfInterest=groundBlockstunBreakOptionCounterMap
	else:
		mapOfInterest=airBlockstunBreakOptionMap
		counterCmdMapOfInterest=airBlockstunBreakOptionCounterMap
	
	_prepareHitstunBreakReversalCmd(mapOfInterest,counterCmdMapOfInterest)					


func createForgetfulCounter():
	var fcounter = forgetfulCounterResource.new()	
	add_child(fcounter)
	fcounter.init(FORGETFUL_HITSTUN_COUNTER_SIZE)
	return fcounter
	
func startTrackingReversalOption(_cmd,_forgetfulCounter):
	if not trackingReversal:
		trackingReversal=true
		reversalActionPlayed = false
		activeReversalCmd=_cmd
		activeReversalForgetfulCounter = _forgetfulCounter

func stopTrackingReversal():
	trackingReversal=false
	reversalActionPlayed = false
	activeReversalCmd=null
	activeReversalForgetfulCounter = null
func _on_sprite_animation_started(sa):
	
	if trackingReversal and reversalActionPlayed:
		
		
		#don't punish a block. getting hit will pusnish it (cause crouch, then proximity block triggers animation start twice)
		#auto ripost also starts before the hit triggers i think
		if  ghostAiAgent.isHighBlockRawCmd(activeReversalCmd) or ghostAiAgent.isLowBlockRawCmd(activeReversalCmd) or activeReversalCmd == inputManagerResource.Command.CMD_AUTO_RIPOST:
			pass
		else:
			#reversal ended without getting rewarded, therefore cpu failed, did a bad choice
			
			punishReversal()
			stopTrackingReversal()
			pass
			
	pass
	
#so this is always called after we start the reversal. Duno why. signaling ordering. but anyways, when trakcing and reversal isn't player
#finished means it started (oki ended)
func _on_sprite_animation_finished(sa):
		
	if trackingReversal:
	
	#we want to know when we started animation that isn't the reversal. aka, if the reversal animation didn't finishe and were starting
		#a new animation, the reversal is done
		if not reversalActionPlayed:
			
			reversalActionPlayed=true
		else:
	
			
			
			#if ghostAiAgent.isHighBlockRawCmd(activeReversalCmd) or ghostAiAgent.isLowBlockRawCmd(activeReversalCmd):
			
			#	stopTrackingReversal()
			if activeReversalCmd == inputManagerResource.Command.CMD_AUTO_RIPOST:
				#reversal ended without getting rewarded, therefore cpu failed, did a bad choice
				punishReversal()
			
			#don't punish anything for whiffing
			#it's only a bad read if auto ripost whiffs. otherwise the player didn't punish the poor read
			
			stopTrackingReversal()
			
			
	if autoRiposted:
		autoRiposted=false
		#force the cpu to dash forward to followup
		ghostAiAgent.overrideLastCommand(inputManagerResource.Command.CMD_DASH_FORWARD)
	elif ripostSuccededFlag:	
		ripostSuccededFlag=false
		#force the cpu to dash forward to followup
		ghostAiAgent.overrideLastCommand(inputManagerResource.Command.CMD_DASH_FORWARD)
	else:
		
		if ghostAiAgent.cpuPlayerController.opponentPlayerController.playerState.inHitStun:
			
			var playerTooFarAway = ghostAiAgent.cpuPlayerController.kinbody.distanceToOpponent() > attackDistance
			
			if playerTooFarAway:
				#force the cpu to dash forward to followup
				ghostAiAgent.overrideLastCommand(inputManagerResource.Command.CMD_DASH_FORWARD)
			else:
				#in range to attack
				performAttackCommand()
				
		else:
			
			#opponent attacking?
			if ghostAiAgent.cpuPlayerController.opponentPlayerController.actionAnimeManager.spriteAnimationManager.isInStartupAnimation() or ghostAiAgent.cpuPlayerController.opponentPlayerController.actionAnimeManager.spriteAnimationManager.isInActiveAnimation():
			
				#if ghostAiAgent.cpuPlayerController.opponentPlayerController.my_is_on_floor():
				#	ghostAiAgent.overrideLastCommand(inputManagerResource.Command.CMD_BACKWARD_CROUCH)
				#else:
				#	#high block
				#	ghostAiAgent.overrideLastCommand(inputManagerResource.Command.CMD_MOVE_FORWARD)
								
				var blockingHigh = ghostAiAgent.getCorrectBlockAttempt()
				
				if blockingHigh:
					ghostAiAgent.overrideLastCommand(inputManagerResource.Command.CMD_MOVE_BACKWARD)
				else:
					ghostAiAgent.overrideLastCommand(inputManagerResource.Command.CMD_BACKWARD_CROUCH)
				
			
			#in recovery	
			elif ghostAiAgent.cpuPlayerController.opponentPlayerController.actionAnimeManager.spriteAnimationManager.isInRecoveryAnimation():
				
				
				#opponent negative on block?
				if ghostAiAgent.cpuPlayerController.opponentPlayerController.guardHandler.isInBlockHitstun():
			
					#do a fast attack
						
					#pick randome  command from
										
					var fastAttackCmd = ghostAiAgent.chooseRandomElementFromList(blockPunishCmds)
					ghostAiAgent.overrideLastCommand(fastAttackCmd)
				else:
					#they in recovery
					var playerTooFarAway = ghostAiAgent.cpuPlayerController.kinbody.distanceToOpponent() > attackDistance
					
					#too far to attack?
					if playerTooFarAway:
						#they can be punish, engage
						ghostAiAgent.overrideLastCommand(inputManagerResource.Command.CMD_DASH_FORWARD)
					else:
						#attack
						performAttackCommand()
						
			else:	
				#when in doubt walk forward
				ghostAiAgent.overrideLastCommand(inputManagerResource.Command.CMD_MOVE_FORWARD)
				

func _on_cpu_invincibility_was_hit(hitbox,hurtbox):	
	
	if trackingReversal and reversalActionPlayed:
		
		#cpu auto riposted player?
		if activeReversalCmd == inputManagerResource.Command.CMD_AUTO_RIPOST:

			#cpu's auto ripost  reversal worked
			stopTrackingReversal()
			#print("cpu good reversal read!")

	
func _on_cpu_was_hit(hitbox,hurtbox):
	if trackingReversal and reversalActionPlayed:
		#reversal was punished, it was a bad choice
		
		
		#only punish if the reversal command wasn't block and we get hit
		#in case we blocked a hit, all is good
		if ghostAiAgent.cpuPlayerController.guardHandler.canHoldBackToBlock() and  (ghostAiAgent.isHighBlockRawCmd(activeReversalCmd) or ghostAiAgent.isLowBlockRawCmd(activeReversalCmd)):
			#print("cpu good reversal read!")
			#cpu correclty blocked as reversal, no punish
			pass
		else:
			#cpu got hit. that's not good. failed reversal
			punishReversal()
			
			
			
		stopTrackingReversal()
			
func _on_cpu_hitting_player(hitbox,hurtbox):
	if trackingReversal and reversalActionPlayed:
		
		
		var punishFlag = false
		
		#so hitting is a win, unless they blocked a DP, then it's a fail
		if activeReversalCmd == GLOBALS.DP_FILLER_COMMAND:
		
			var isPlayerBlocking = ghostAiAgent.cpuPlayerController.opponentPlayerController.guardHandler.canHoldBackToBlock()
			
			if isPlayerBlocking:
				punishFlag=true
			

		if punishFlag:
			#reversal was punished, it was a bad choice
			punishReversal()
		
		else:
			
			#cpu hit player, don't punish
			#print("cpu good reversal read!")
			pass
		stopTrackingReversal()


	var cpuActionAnimeManager = ghostAiAgent.cpuPlayerController.actionAnimeManager
	var isAutoRiposting = cpuActionAnimeManager.isCurrentSpriteAnimation(cpuActionAnimeManager.AIR_AUTO_RIPOST_ON_HIT_ACTION_ID)
	isAutoRiposting = isAutoRiposting or cpuActionAnimeManager.isCurrentSpriteAnimation(cpuActionAnimeManager.AUTO_RIPOST_ON_HIT_ACTION_ID)
	
	if isAutoRiposting:
		
		autoRiposted=true



func performAttackCommand():
	
	var attackCmd	= ghostAiAgent.chooseRandomElementFromList(aggressiveCmds)
	ghostAiAgent.overrideLastCommand(attackCmd)
	
func _on_opponent_guard_break(highBlockFlag,amountGuardOpponentRegened):
	performAttackCommand()
	
func _on_player_hit_stun_change(flag):
	#no longer in hitstun?
	if not flag:
		performAttackCommand()
		
func _on_player_exited_block_stun():
	performAttackCommand()
func _on_cpu_exited_block_stun():
	
	
	prepareBlockstunBreakReversalCmd()
		
	if ghostAiAgent.cpuPlayerController.my_is_on_floor():
		
		logPlayerGroundBlockstunBreakPattern()
	else:
		
		logPlayerAirBlockstunBreakPattern()

	
func punishReversal():
	if activeReversalForgetfulCounter != null:
		activeReversalForgetfulCounter.decrementX(2) #remove 2 
		activeReversalForgetfulCounter.update()
		#print("cpu bad reversal read!")
		
		 
func _on_cpu_attempted_ripost(cmdRiposted,cmdHitBy,successFlag,ripostedInNeutral):
	
	#succes?
	if  successFlag:
		ripostSuccededFlag = true