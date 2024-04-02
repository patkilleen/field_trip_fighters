extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal counter_ripost_succeeded
signal counter_ripost_window_expired
signal counter_ripost_invalid_prediction


var GLOBALS = preload("res://Globals.gd")
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

#note that the pre-react windows below will be set by other modules
var counterRipostingPreWindow = 60 setget setCounterRipostingPreWindow,getCounterRipostingPreWindow #number of frames to preemptively ripost
var counterRipostingPreWindowInSeconds = counterRipostingPreWindow*GLOBALS.SECONDS_PER_FRAME
var opponentRipostHandler = null


#var predictedActionId = null
var predictedCommand = null
#-1 to be outstide reactive window
#var counterRipostingWindowFramesRemaining = -1
var counterRipostingWindowSecondsRemaining = -1.0




#prevents counter riposting from being attempted
var counterRipostLocked=false
func _ready():
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	set_physics_process(false)
	pass
	
func reset():
	init()
	counterRipostLocked=false
func setGlobalSpeedMod(g):
	globalSpeedMod = g

func init():
	#predictedActionId = null
	predictedCommand = null
	#-1 to be outstide reactive window
	#counterRipostingWindowFramesRemaining = -1	
	counterRipostingWindowSecondsRemaining = -1.0
	set_physics_process(false)

func setCounterRipostingPreWindow(w):
	counterRipostingPreWindow = w
	counterRipostingPreWindowInSeconds = counterRipostingPreWindow*GLOBALS.SECONDS_PER_FRAME
func getCounterRipostingPreWindow():
	return counterRipostingPreWindow
	
func signal_counter_riposting_finished(signalStr):
	
	var _predictedCmd = predictedCommand
	stopRipostWindow()
	#emit_signal(signalStr,_predictedActionId,_actualActionId,_hitboxArea,_hurtboxArea)
	emit_signal(signalStr,_predictedCmd)
	
func stopRipostWindow():
	set_physics_process(false)
	init()

#this should be called only if enough ability bar available
#return true when counter ripost processed and false when already counter riposting
func attemptCounterRipost(cmd):
	
	if counterRipostLocked:
		return false
		
	#print(str(self.get_parent().get_parent().inputDeviceId)+": attempting counter ripost")		
	#check if already in the riposting preemptive window
	if isCounterRipostWindowActive():
		#print("already counter riposting another move, ignore counter ripost")
		return false
	
	
	#listening for this action to hit us
	predictedCommand = cmd
	
	#start counting down window
	#counterRipostingWindowFramesRemaining = counterRipostingPreWindow
	counterRipostingWindowSecondsRemaining = counterRipostingPreWindowInSeconds
	set_physics_process(true)
	
	#oppoent trying to ripost
	if opponentRipostHandler.isInPreemptiveWindow():
		#try to counter it
		_on_ripost_input(opponentRipostHandler.predictedCommand)
		
	return true	


func isCounterRipostWindowActive():
	return predictedCommand != null

func isInWindow():
	#return counterRipostingWindowFramesRemaining >= 0
	return counterRipostingWindowSecondsRemaining >= 0
	
	
func _physics_process(delta):

	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	delta = delta * globalSpeedMod
	#are we counter riposting
	if not isCounterRipostWindowActive():
		return
		
	#has attempted to counter ripost ?
	if isCounterRipostWindowActive():
		#no ripost during window and it expired?
		if not isInWindow():
			signal_counter_riposting_finished("counter_ripost_window_expired")
			return
	
	#decrease the number of frames remaining to be able to ripost
	#counterRipostingWindowFramesRemaining = counterRipostingWindowFramesRemaining - 1 
	counterRipostingWindowSecondsRemaining = counterRipostingWindowSecondsRemaining - delta

#note that this should be called by the opponen'ts player controller
#this player controller will be notified via signals
func _on_ripost_input(ripostedCmd):

	#print(str(self.get_parent().get_parent().inputDeviceId)+": counter ripost oppurtunity...")
	if ripostedCmd == null:
		print("warning, hit by null command attack action when trying to handle counter ripost input")
		return false
	
	#has attempted to counter ripost (pridiect getting riposted)?
	if isCounterRipostWindowActive():
		#corretly predicted the move to ripost?
		if	predictedCommand == ripostedCmd:
			#did they ripost on time?
			if isInWindow():
				opponentRipostHandler.ripostCountered(ripostedCmd)
				signal_counter_riposting_finished("counter_ripost_succeeded")
				counterRipostLocked=true
				return true
			else:
				signal_counter_riposting_finished("counter_ripost_window_expired")
				return false
		else:
			signal_counter_riposting_finished("counter_ripost_invalid_prediction")
			return false
	return false
	

	
	
	
		
func _on_hit_freeze_finished():
	counterRipostLocked=false
	pass
	
	
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	
	pass
