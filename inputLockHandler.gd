extends Node
signal input_restriction_timeout
signal initial_input_lock_timeout

var GLOBALS = preload("res://Globals.gd")
var frameTimerResource = preload("res://frameTimer.gd")

var totalDurationFrameTimer = null
var initialDurationFrameTimer = null

var lockActive = false
#var actionMaskLockActive = false
var totalDurationInFrames = null #duration of entire length of window, after initatial duration, then this duration where limited comanda can be inputed
var initialDurationInFrames = null #duration initially where can't apply anny input
var enabled = false
var flagIsHittingAfterUnlockFlag = null
var actionWhiteListMask1 = 0
var actionWhiteListMask2 = 0

var actionAnimeManager = null
func _ready():
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	totalDurationFrameTimer = frameTimerResource.new()
	#initialDurationFrameTimer= frameTimerResource.new()
	totalDurationFrameTimer.connect("timeout",self,"_on_total_duration_timeout")
	#initialDurationFrameTimer.connect("timeout",self,"_on_initial_duration_timeout")
		
	add_child(totalDurationFrameTimer)
	reset()
	#add_child(initialDurationFrameTimer)


#enable lock so next time hitfreeze stops, itll take effect to lock input away
#to make it so player can't take actions for a brief moment
func enable(_totalDurationInFrames,_initialDurationInFrames,inHitFreezeFlag,_flagIsHittingAfterUnlockFlag,_actionWhiteListMask1,_actionWhiteListMask2):
	
	reset()
	totalDurationInFrames=_totalDurationInFrames
	initialDurationInFrames=_initialDurationInFrames
	enabled=true
	actionWhiteListMask1 = _actionWhiteListMask1
	actionWhiteListMask2 = _actionWhiteListMask2
	flagIsHittingAfterUnlockFlag=_flagIsHittingAfterUnlockFlag
	#not in hitfreeze? start right away
	if not inHitFreezeFlag:
		start()

func reset():
	lockActive = false
	totalDurationFrameTimer.stop()
	#actionMaskLockActive = false
	totalDurationInFrames = null 
	initialDurationInFrames=null
	lockActive = false
	#actionMaskLockActive = false
	enabled = false
	flagIsHittingAfterUnlockFlag = null
	actionWhiteListMask1 = 0
	actionWhiteListMask2 = 0
	
func init(_actionAnimeManager):
	actionAnimeManager=_actionAnimeManager
	reset()	

func start():
	if enabled:
		lockActive = true
		#actionMaskLockActive = true
		enabled=false
		
		#only start the initial timer if there is actually a window of time where total duration isn't done whiel initi is
		#if initialDurationInFrames <totalDurationInFrames:
		#	initialDurationFrameTimer.start(initialDurationInFrames)
		totalDurationFrameTimer.start(totalDurationInFrames)
		
		
#func _on_initial_duration_timeout():
#	actionMaskLockActive = false
#	emit_signal("initial_input_lock_timeout",flagIsHittingAfterUnlockFlag)
func _on_total_duration_timeout():
	
	lockActive = false
	emit_signal("input_restriction_timeout",flagIsHittingAfterUnlockFlag)
	
func isActive():
	return lockActive
	
#func isActionMaskLockActive():
#	return actionMaskLockActive
	
	
func _on_hit_freeze_finished():
	
	#lock out 
	start()

	
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	pass


#returns true when the action id is part of wite list while input lock is active and inital
#part of lock is complete, when lock isn't active and false if action is not part of whilte list
func isValidActionId(actionId):
	
	#if the input lock isn't active, any action is fine
	if not isActive():
		return true
		
	#the initial lock on input is still active, so the masking process can't be done
	#nothign is autocancelable at the moement
	#if isActionMaskLockActive():
	#	return false
		
	
	var mask = 0
	if not actionAnimeManager.autoCancelMaskMap.has(actionId):
		if not actionAnimeManager.autoCancelMaskMap2.has(actionId):
			return false
		else:
			mask = actionAnimeManager.autoCancelMaskMap2[actionId]
			return ((mask & actionWhiteListMask2) == mask)
	else:
		mask = actionAnimeManager.autoCancelMaskMap[actionId]
		#var mask = 1 << (bitmap) #bitshift a 1 'actionId' bits left'
		return ((mask & actionWhiteListMask1) == mask)