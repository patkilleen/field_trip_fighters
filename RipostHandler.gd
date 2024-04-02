extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal preemptive_ripost_succeeded
signal preemptive_ripost_window_expired
signal preemptive_ripost_invalid_prediction
signal reactive_ripost_succeeded
signal reactive_ripost_window_expired
signal reactive_ripost_invalid_prediction
signal ripost_was_countered


var inputManager_resource = preload("res://input_manager.gd")

var GLOBALS = preload("res://Globals.gd")
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

#note that the pre-react windows below will be set by other modules
var ripostingPreWindow = 5 setget setRipostingPreWindow,getRipostingPreWindow #number of frames to preemptively ripost
var ripostingPreWindowInSeconds = ripostingPreWindow* GLOBALS.SECONDS_PER_FRAME
#var ripostingPreTimeWindow = -1
var ripostingReactWindow = 2 setget setRipostingReactWindow,getRipostingReactWindow #number of frames to react to ripost
var ripostingReactWindowInSeconds = ripostingReactWindow*GLOBALS.SECONDS_PER_FRAME
#var ripostingReactTimeWindow = -1 #

#var predictedActionId = null
var predictedCommand = null

#-1 to be outstide reactive window
#var ripostingWindowFramesRemaining = -ripostingReactWindow-1
var ripostingWindowSecondsRemaining = -ripostingReactWindowInSeconds - GLOBALS.SECONDS_PER_FRAME

#var actualActionId = null
var actualSpriteAnimationId = null
var actualCommand = null

#hitbox hitting this player
var hitboxArea = null
#hurtbox being hit
var hurtboxArea = null

#used to access facing command map for cross-up command changing
var inputManager = null



func _ready():
	
	
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	
	inputManager = inputManager_resource.new()
	add_child(inputManager)
	inputManager.set_physics_process(false)
	
	set_physics_process(false)
	pass
	
func setGlobalSpeedMod(mod):
	globalSpeedMod=mod
	
func setRipostingPreWindow(w):
	ripostingPreWindow = w
	ripostingPreWindowInSeconds = ripostingPreWindow* GLOBALS.SECONDS_PER_FRAME
	
func getRipostingPreWindow():
	return ripostingPreWindow

func setRipostingReactWindow(w):
	ripostingReactWindow = w
	ripostingReactWindowInSeconds = ripostingReactWindow*GLOBALS.SECONDS_PER_FRAME
	
func getRipostingReactWindow():
	return ripostingReactWindow
	
func init():
#	predictedActionId = null
	actualSpriteAnimationId = null
	predictedCommand = null
	actualCommand = null
	hitboxArea = null
	hurtboxArea = null
	#-1 to be outstide reactive window
	#ripostingWindowFramesRemaining = -ripostingReactWindow -1	
	ripostingWindowSecondsRemaining = -ripostingReactWindowInSeconds - GLOBALS.SECONDS_PER_FRAME
	
	set_physics_process(false)
	
func signal_riposting_finished(signalStr,cmdRiposted):
	var _hitboxArea = hitboxArea
	var _hurtboxArea = hurtboxArea
	#var _predictedActionId = predictedActionId
	var _predictedCommand = predictedCommand
	#var _actualActionId = actualActionId
	var _actualSpriteAnimationId = actualSpriteAnimationId
	stopRipostWindow()

	match(signalStr):
		"preemptive_ripost_succeeded":
			emit_signal(signalStr,_hitboxArea,cmdRiposted)
		"preemptive_ripost_window_expired":
			emit_signal(signalStr,cmdRiposted)
		"preemptive_ripost_invalid_prediction":
			emit_signal(signalStr,_actualSpriteAnimationId,_hitboxArea,_hurtboxArea,cmdRiposted)
		"reactive_ripost_succeeded":
			emit_signal(signalStr,_hitboxArea,cmdRiposted)
		"reactive_ripost_window_expired":
			#emit_signal(signalStr,_actualActionId,_hitboxArea)
			emit_signal(signalStr,_actualSpriteAnimationId,_hitboxArea,_hurtboxArea)
		"reactive_ripost_invalid_prediction":
			#emit_signal(signalStr,_actualActionId,_hitboxArea)
			emit_signal(signalStr,_actualSpriteAnimationId,_hitboxArea,_hurtboxArea,cmdRiposted)
		"ripost_was_countered":
			emit_signal(signalStr,cmdRiposted)
func stopRipostWindow():
	set_physics_process(false)
	init()
	

#this stops the riposting window since it was countered
func ripostCountered(cmdCounterRiposted):
	signal_riposting_finished("ripost_was_countered",cmdCounterRiposted)
	
#this should be called only if enough ability bar available
#func attemptRipost(actionId):
func attemptRipost(cmd):
	
	
	#check if already in the riposting preemptive window
	if isRipostPreWindowActive():
		print("already riposting another move, ignore ripost")
		return
	#we in the time frame where can reactively rpost?
	elif isRipostReactiveWindowActive():
		
		#it was proper ripost?
		if actualCommand == cmd:
			signal_riposting_finished("reactive_ripost_succeeded",cmd)
			return
		else:
			signal_riposting_finished("reactive_ripost_invalid_prediction",cmd)
			return
			
	#at this point riposting hasn't been activated, so activate preemptive window
	
	#listening for this action to hit us
	#predictedActionId = actionId
	predictedCommand = cmd
	#start counting down window
	#ripostingWindowFramesRemaining = ripostingPreWindow
	ripostingWindowSecondsRemaining = ripostingPreWindowInSeconds
	set_physics_process(true)


func isRipostPreWindowActive():
	#return predictedActionId != null
	return predictedCommand != null

func isRipostReactiveWindowActive():
	
	return actualCommand != null

#func startRipostReactiveWindow(_actualAction):
func startRipostReactiveWindow(_actualCmd):
	
	if isInReactiveWindow():
		print("warning, starting reactive ripost window, but already started")
		
	set_physics_process(true)
	
	actualCommand = _actualCmd
	#aawait the ripost window
	#ripostingWindowFramesRemaining = 0
	ripostingWindowSecondsRemaining = 0.0
	

#entire window (preemptive + reactive )hasn't expired? 
func isInsideRipostWindow():
	#return (isRipostPreWindowActive() or isRipostReactiveWindowActive()) and ripostingWindowFramesRemaining >= -ripostingReactWindow 
	return (isRipostPreWindowActive() or isRipostReactiveWindowActive()) and ripostingWindowSecondsRemaining >= -ripostingReactWindowInSeconds 
	
	
#returns true when still in preemptive window  (not in reactive window)
#false if outstide window or not preemtively riposting
func isInPreemptiveWindow():
	#return isRipostPreWindowActive() and ripostingWindowFramesRemaining > 0
	return isRipostPreWindowActive() and ripostingWindowSecondsRemaining > 0

#returns true when still in reactive window (not in preemptive window)
#false if outstide window or not reactively riposting
func isInReactiveWindow():
	#return isRipostReactiveWindowActive() and (ripostingWindowFramesRemaining <= 0) and isInsideRipostWindow()
	return isRipostReactiveWindowActive() and (ripostingWindowSecondsRemaining <= 0) and isInsideRipostWindow()


func _physics_process(delta):

	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	delta = delta * globalSpeedMod
	#are we 
	if not isRipostPreWindowActive() and  not isRipostReactiveWindowActive():
		return
		#stopRipostWindow()
		
	
	
	
	#reactive window open?
	if isRipostReactiveWindowActive():
		#missed reactive window?
		if not isInReactiveWindow():
			signal_riposting_finished("reactive_ripost_window_expired",null)
			return
	#has attempted to ripost (predict being hit)?
	elif isRipostPreWindowActive():
		#wasn't hit during ripost preemptive window?
		if not isInPreemptiveWindow():
			signal_riposting_finished("preemptive_ripost_window_expired",predictedCommand)
			return
	
	#decrease the number of frames remaining to be able to ripost
	#ripostingWindowFramesRemaining = ripostingWindowFramesRemaining - 1 
	ripostingWindowSecondsRemaining = ripostingWindowSecondsRemaining - delta
	
	
#checks for a ripost input on being hit
#returns true when properly handled being hit, and false when an error occured
func _on_player_was_hit(_hitboxArea,_hurtboxArea):
	#print("ripost_on_player_hit")

	if _hitboxArea == null:
		print("warning, in ripost handler, and hitbox hitting is null when checking for ripost")
		return false
	
	if _hurtboxArea == null:
		print("warning, in ripost handler, and hurtbox hit is null when checking for ripost")
		return false
		
	hitboxArea = _hitboxArea
	hurtboxArea = _hurtboxArea
	
	var actionAnimationManager = hitboxArea.playerController.actionAnimeManager
	
	
	var _actualCommand = _hitboxArea.cmd
	
	if _actualCommand == null:
		print("warning, hit by attack with null command inputed when trying to check for ripost")
	#	return false
		
	
	if not _hitboxArea.is_projectile:
		actualSpriteAnimationId =actionAnimationManager.currentSpriteAnimation
	else:
		#actualSpriteAnimationId =hitboxArea.projectileParentSpriteAnimation
		actualSpriteAnimationId =hitboxArea.projectileParentSpriteAnimation.id

		
	#has attempted to ripost (predict being hit)?
	if isRipostPreWindowActive():
		
		#corretly predicted the move to ripost?
		#if predictedActionId == actualAnimationId:
		if predictedCommand == _actualCommand:
			#did they ripost on time?
			if isInPreemptiveWindow():
				signal_riposting_finished("preemptive_ripost_succeeded",predictedCommand)
				return true
			else:
				signal_riposting_finished("preemptive_ripost_window_expired",predictedCommand)
				return true
		else:
			signal_riposting_finished("preemptive_ripost_invalid_prediction",predictedCommand)
			return true
	else:
		#were not riposting, which means open reactive window to ripost
		
		_actualCommand = resolveRipostFacingDependentCommand(hitboxArea)
	
		startRipostReactiveWindow(_actualCommand)
		
	return true


func resolveRipostFacingDependentCommand(_hitboxArea):
	
		
	#here we should do logic to make sure command respects facing of original input  direction
	#(left-B animation will still be ripostable using right-B after/before a crossup)


	if hitboxArea == null:
		return null
	
	var playerController = get_parent()
	var isVictimFacingRight = playerController.kinbody.facingRight
	
#var _actualCommand = actionAnimationManager.commandActioned
	#if _actualCommand == null:
	var _actualCommand = null
	
	#Case a): attacker was left of victim and began animation that created hitbox
	if _hitboxArea.facingRightWhenPlayed:
		
		#cross-up occured, gotta reverse the command
		if isVictimFacingRight:
			#mirror the input command, cuase cross-up occured since attacker animation played
			_actualCommand = inputManager.getFacingDependantCommand(_hitboxArea.cmd,not isVictimFacingRight) 
		else:
			#no cross-up, command is stil same as direction inputed
			_actualCommand = _hitboxArea.cmd
	else: #attacker was right of victim and began animation that created hitbox
		
		#cross-up occured, gotta reverse the command
		if not isVictimFacingRight:
			#mirror the input command, cuase cross-up occured since attacker animation played
			_actualCommand = inputManager.getFacingDependantCommand(_hitboxArea.cmd,isVictimFacingRight) 
		else:
			#no cross-up, command is stil same as direction inputed
			_actualCommand = _hitboxArea.cmd
	
	return _actualCommand
	
	

	