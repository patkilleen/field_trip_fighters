extends Node

const inputManager = preload("res://input_manager.gd")
var frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")
var GLOBALS = preload("res://Globals.gd")
export (float) var  HUGE_AGGRESIVE_SCORE = 1.5
export (float) var  LARGE_AGGRESIVE_SCORE = 1.3
export (float) var  AGGRESIVE_SCORE = 1
export (float) var  NEUTRAL_SCORE = 0
export (float) var  DEFENSIVE_SCORE = -0.21 #abit more severe than aggresive more than aggressive since might try and camp without attatcking
export (float) var  LARGE_DEFENSIVE_SCORE = -0.41

export (float) var negativeLevelScoreMax = 5
export (float) var negativeLevelScoreMin = -5

var scoreBuffer = []
var scoreMovingSum =0

#export (int) var  NEGATIVE_LEVEL_NUM_CMDS_WINDOW = 20
#const WINDOW_SIZE_MODIFIER = 5
export (int) var scoreBufferMaxSize = 6
#holds the defensive scores for each command, where
#a hierer positive score more means aggresive, and a 
#lower negative score means more defensive
var defensiveCmdScoreMap = {}

export (int) var NEGATIVE_LEVEL_THRESHOLD= -3#

export (float) var canHoldBackBlockNegativeGainRatePerSecond = 0.8
export (float) var holdBackNegativeGainRatePerSecond = 0.1
export (float) var holdForwardNegativeLossRatePerSecond = 1
export (float) var hittingNegativeLoss = 0.6

export (float) var negativeStateDurationInSeconds = 7
export (float) var hittingCooldDownReduction = 1 #cooldown reduced 1 second each hit

export (float) var passiveNegativeGainRatePerSecond = 0.025 #doing nothing is still camping
var negativeLevelStateDurationTimer = null
var playerController = null

var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

var holdingBack = false
var holdingForward = false

var initialized = false

var subNegativeLevel = 0

var canHoldBackBlock = false


export (int) var subNegativeLevelThreshold = 4

func _ready():
	
	
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	
	negativeLevelStateDurationTimer = frameTimerResource.new()	
	self.add_child(negativeLevelStateDurationTimer)
	
	negativeLevelStateDurationTimer.connect("timeout",self,"_on_negative_level_cooldown_ellapsed")
	
	defensiveCmdScoreMap[inputManager.Command.CMD_JUMP]=NEUTRAL_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_NEUTRAL_MELEE]=LARGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_BACKWARD_MELEE]=HUGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_FORWARD_MELEE]=LARGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_DOWNWARD_MELEE]=LARGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_UPWARD_MELEE]=LARGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_NEUTRAL_SPECIAL]=LARGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_BACKWARD_SPECIAL]=HUGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_FORWARD_SPECIAL]=LARGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_DOWNWARD_SPECIAL]=LARGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_UPWARD_SPECIAL]=LARGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_NEUTRAL_TOOL]=LARGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_BACKWARD_TOOL]=HUGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_FORWARD_TOOL]=LARGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_DOWNWARD_TOOL]=LARGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_UPWARD_TOOL]=LARGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_MOVE_FORWARD]=NEUTRAL_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_MOVE_BACKWARD]=NEUTRAL_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_STOP_MOVE_FORWARD]=NEUTRAL_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_STOP_MOVE_BACKWARD]=NEUTRAL_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_DASH_FORWARD]=LARGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_DASH_BACKWARD]=DEFENSIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_CROUCH]=NEUTRAL_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_STOP_CROUCH]=NEUTRAL_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_JUMP_FORWARD]=AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_JUMP_BACKWARD]=DEFENSIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_AIR_DASH_DOWNWARD]=NEUTRAL_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_START]=NEUTRAL_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_AUTO_RIPOST]=LARGE_DEFENSIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_GRAB]=LARGE_AGGRESIVE_SCORE 
	defensiveCmdScoreMap[inputManager.Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE]=NEUTRAL_SCORE

	#counter and ripost all have same score
	defensiveCmdScoreMap[inputManager.Command.CMD_FORWARD_CROUCH]=NEUTRAL_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_BACKWARD_CROUCH]=NEUTRAL_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_DASH_FORWARD_NO_DIRECTIONAL_INPUT]=LARGE_AGGRESIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_FORWARD_UP]=NEUTRAL_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_BACKWARD_UP]=NEUTRAL_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_UP]=NEUTRAL_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_BACKWARD_CROUCH_PUSH_BLOCK]=LARGE_DEFENSIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_BACKWARD_UP_PUSH_BLOCK]=LARGE_DEFENSIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_BACKWARD_PUSH_BLOCK]=LARGE_DEFENSIVE_SCORE
	defensiveCmdScoreMap[inputManager.Command.CMD_FORWARD_CROUCH_PUSH_BLOCK]=NEUTRAL_SCORE #likely an ability cancel input
	defensiveCmdScoreMap[inputManager.Command.CMD_FORWARD_UP_PUSH_BLOCK]=NEUTRAL_SCORE#likely an ability cancel input
	defensiveCmdScoreMap[inputManager.Command.CMD_FORWARD_PUSH_BLOCK]=NEUTRAL_SCORE#likely an ability cancel input
	defensiveCmdScoreMap[inputManager.Command.CMD_BUFFERED_PUSH_BLOCK]=LARGE_DEFENSIVE_SCORE
	
func setGlobalSpeedMod(g):
	globalSpeedMod = g
	
func init(_playerController):
	playerController = _playerController
	#playerController.actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_sprite_animation_played")
	playerController.actionAnimeManager.spriteAnimationManager.connect("sprite_frame_activated",self,"_on_sprite_frame_activated")
	
	playerController.playerState.connect("changed_in_hitstun",self,"_on_hitstun_changed")
	playerController.collisionHandler.connect("player_was_hit",self,"_on_player_was_hit")
	playerController.collisionHandler.connect("hitting_player",self,"_on_hitting_player")
	set_physics_process(true)
	initialized=true
	
func reset():
	#undoNegativeLevelBuffer.clear()
	#undoNegativeLevelMovingSum = 0
	scoreBuffer.clear()
	scoreMovingSum=0
	#mostRecentScoreBuffer.clear()
	#mostRecentScoreMovingSum=  0
	negativeLevelStateDurationTimer.stop()
	subNegativeLevel =0

func getCommandScore(cmd):
	
	if cmd == null:
		return NEUTRAL_SCORE
	if playerController.inputManager.isRipostCommand(cmd):
		return AGGRESIVE_SCORE
	if playerController.inputManager.isCounterRipostCommand(cmd):
		return HUGE_AGGRESIVE_SCORE
		
	if not defensiveCmdScoreMap.has(cmd):
		return NEUTRAL_SCORE
		
	return defensiveCmdScoreMap[cmd]
	
#called when command used to play action
func _on_command_actioned(cmd):
	
	if not initialized:
		return
		
	#match hasn't started yet?
	if playerController.inputManager.movementOnlyCommands:
		return
		
	var score = getCommandScore(cmd)
	
	processScore(score)
	
#	if cmd ==inputManager.Command.CMD_MOVE_BACKWARD:
#		set_physics_process(true)
#	else:
#		set_physics_process(false)
	
func processScore(newScore):
	
	if not initialized:
		return
		
	scoreMovingSum = _updateMovingSum(newScore,scoreBuffer,scoreMovingSum,scoreBufferMaxSize)
	
	negavityLevelCheck()
	
	#chekc if we reached negative level
	#var average = scoreMovingSum/float(scoreBuffer.size())
	
	#iterate (from smallest to biggest) over thresholds used on moving average to decide what negative levl is
	#for thereshold in sortedThrsholds:
		
	#reached a negative level?
	#if scoreMovingSum < NEGATIVE_LEVEL_THRESHOLD:
		
	#	reset()
		#increase
	#	playerController.playerState.negativeLevel = playerController.playerState.negativeLevel +1
	#	return
	
	#do we have a negative level?
	#if playerController.playerState.negativeLevel > 0:
		
	#	undoNegativeLevelMovingSum = _updateMovingSum(newScore,undoNegativeLevelBuffer,undoNegativeLevelMovingSum,undoNegativeLeverBufferMaxSize)
		
		#stopped camping?		
	#	if undoNegativeLevelMovingSum > RECOVER_FROM_NEGATIVE_LEVEL_THRESHOLD:
			
			#decrease level
	#		playerController.playerState.negativeLevel = playerController.playerState.negativeLevel - 1

	#		reset()
	
	#else:
		
	#	mostRecentScoreMovingSum = _updateMovingSum(newScore,mostRecentScoreBuffer,mostRecentScoreMovingSum,mostRecentScoreBufferMaxSize)
	
		#player stopped camping before getting a negative level	
	#	if mostRecentScoreMovingSum > RESET_NEGATIVE_LEVEL_TRACKING_THRESHOLD:

			#reset any caping progress, player may had been about to get the camping level, but
			#they stopped camping
#			reset()

func _updateMovingSum(newScore,leakyList,movingSum,maxSize):
	if not initialized:
		return
	#add the score to buuffer and keep track of sum
	leakyList.push_front(newScore)
	movingSum = movingSum + newScore
	
	#tipical case where the buffer is filled?
	if leakyList.size() >= maxSize:
		
		#removed oldest element and update the moving sum
		var oldestScore = leakyList.pop_back()
		movingSum = movingSum -oldestScore
		
	return movingSum
	
#func _on_sprite_animation_played(animation):
	#NOTE THat this is called before command played signal, so below logic is safe 
	#if hold back is issued, then the cmd actioned signal will deal with it
#	canBlockFlag = 
#	set_physics_process(false)
#	pass
func _on_sprite_frame_activated(sf):
	
	canHoldBackBlock = sf.hasHoldBackToBlockHurtboxes()

func setNegativeLevelScore(score):
	scoreMovingSum = clamp(score,negativeLevelScoreMin,negativeLevelScoreMax)

func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS	
		
	if not initialized:
		return
		
	#match hasn't started yet?
	if playerController.inputManager.movementOnlyCommands:
		return
		
	delta = globalSpeedMod * delta
	
	
	#holding forward slwing removes negative level by adding to the negative score
	if holdingForward:
		var gain = delta * holdForwardNegativeLossRatePerSecond
		setNegativeLevelScore(scoreMovingSum +  gain)
	
	
	#holding back  gain negative level by removing from score
	if holdingBack:
		
		if canHoldBackBlock:
			var loss = delta * canHoldBackBlockNegativeGainRatePerSecond
			setNegativeLevelScore(scoreMovingSum - loss)
		else:
			
			var loss = delta * holdBackNegativeGainRatePerSecond
			setNegativeLevelScore(scoreMovingSum - loss)
	
	#passive negative level gain to stop idle camping (which removes from score)
	var loss = delta * passiveNegativeGainRatePerSecond
	setNegativeLevelScore(scoreMovingSum - loss)	
	
	negavityLevelCheck()
	
func negavityLevelCheck():
	if not initialized:
		return
	#reached a negative level?
	if scoreMovingSum < NEGATIVE_LEVEL_THRESHOLD:
		
		
		subNegativeLevel =subNegativeLevel+1
		#was camping 3 times in short amount of time?
		if subNegativeLevel >= subNegativeLevelThreshold:
		
			
			reset()
			#increase
			playerController.playerState.negativeLevel = playerController.playerState.negativeLevel +1
			negativeLevelStateDurationTimer.startInSeconds(negativeStateDurationInSeconds)
			return
		else:
			
			#we just reset the timer by continuing to camp
			if is_in_negative_level_state():
				negativeLevelStateDurationTimer.startInSeconds(negativeStateDurationInSeconds)
	
	#var loss = delta*walkBackNegativeGainRatePerSecond
	#gain negative level for some hold back aniamtions ( like walk back)
	#scoreMovingSum = scoreMovingSum -  loss
	#undoNegativeLevelMovingSum = undoNegativeLevelMovingSum - loss
	#mostRecentScoreMovingSum = mostRecentScoreMovingSum - loss
	
		
	#reached a negative level?
	#if scoreMovingSum < NEGATIVE_LEVEL_THRESHOLD:
		
	#	reset()
		#increase
	#	playerController.playerState.negativeLevel = playerController.playerState.negativeLevel +1
	#	return
		
	
		
	#do we have a negative level?
#	if playerController.playerState.negativeLevel > 0:

		#stopped camping?		
#		if undoNegativeLevelMovingSum > RECOVER_FROM_NEGATIVE_LEVEL_THRESHOLD:
			
			#decrease level
#			playerController.playerState.negativeLevel = playerController.playerState.negativeLevel - 1

#			reset()
	
#	else:
			#player stopped camping before getting a negative level	
#		if mostRecentScoreMovingSum > RESET_NEGATIVE_LEVEL_TRACKING_THRESHOLD:

			#reset any caping progress, player may had been about to get the camping level, but
			#they stopped camping
#			reset()
			
func _on_negative_level_cooldown_ellapsed():
	reset()
	playerController.playerState.negativeLevel = 0
	pass	
#func _on_released_back():
#	holdingBack=false
#	pass
#func _on_not_holding_back():
#	holdingBack=false
#	pass
#func _on_pressed_back():
#	holdingBack=true
#	pass
#func _on_holding_back():
#	holdingBack=true
#	pass

			
#func _on_released_forward():
#	holdingForward=false
#	pass
#func _on_not_holding_forward():
#	holdingForward = false
#	pass
#func _on_pressed_forward():
	#holdingForward=true
	#pass
#func _on_holding_forward():
	#holdingForward=true
#	pass
	
	
func _on_hitting_player(selfHitboxArea, otherHurtboxArea):
	
	if is_in_negative_level_state():
		#removes 1 second off the negative level state cooldown
		negativeLevelStateDurationTimer.ellapsedTimeInSeconds= negativeLevelStateDurationTimer.ellapsedTimeInSeconds + 1
		
	else:
		
		#add aggresseion to the ngegative level score
		setNegativeLevelScore(scoreMovingSum + HUGE_AGGRESIVE_SCORE)
		
		
	#remove a progress (a sub level) toward negative state, since hit opponent
	subNegativeLevel =  max(0,subNegativeLevel -1)
	
	pass
	
func _on_player_was_hit(otherHitboxArea, selfHurtboxArea):
	if is_in_negative_level_state():
		#removes 1 second off the negative level state cooldown
		negativeLevelStateDurationTimer.ellapsedTimeInSeconds= negativeLevelStateDurationTimer.ellapsedTimeInSeconds + 1
	else:
		#add aggresseion to the ngegative level score, as player being punished fro camping
		setNegativeLevelScore(scoreMovingSum + LARGE_AGGRESIVE_SCORE)
	
func _on_hitstun_changed(inHitStunFlag):
	if not initialized:
		return
	##don't process time-based negative levels when in hitstun
	if not inHitStunFlag:
		set_physics_process(true)
	else:
		set_physics_process(false)
		
		
func is_in_negative_level_state():
	return negativeLevelStateDurationTimer.is_physics_processing()
	


	
	
	
func _on_directional_input(diEnum):
	
	#track whether we are holding down
	match(diEnum):
		GLOBALS.DirectionalInput.FORWARD_UP:
			holdingForward=true
		GLOBALS.DirectionalInput.FORWARD:
			holdingForward=true
		GLOBALS.DirectionalInput.FORWARD_DOWN:
			holdingForward=true
		_:
			holdingForward=false
#	
	#track whether we are holding back
	match(diEnum):
		GLOBALS.DirectionalInput.BACKWARD_DOWN:
			holdingBack=true
		GLOBALS.DirectionalInput.BACKWARD:
			holdingBack=true
		GLOBALS.DirectionalInput.BACKWARD_UP:
			holdingBack=true
		_:
			holdingBack=false
	
