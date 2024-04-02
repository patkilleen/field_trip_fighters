extends Node

signal timeout

var GLOBALS = preload("res://Globals.gd")

#changing this will globaly alter speed of animations
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

var lengthInFrames = 0
var lengthInSeconds = 0

var ellapsedTimeInSeconds = 0
var active=false

func _ready():
	
	#make sure if speed was specified elsewhere other than globals, that speed is up to date
	#var globalSpeedNodes = get_tree().get_nodes_in_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	#setGlobalSpeedMod(globalSpeedNodes[1].globalSpeedMod)
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	
	#this is so subclasses can do somethig tiwh hitfreeze
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	
	add_to_group(GLOBALS.GLOBAL_TIMER_FORCE_TIMEOUT_GROUP)
	active=false
	
	set_physics_process(false)
	pass

func reset():
	
	lengthInFrames = 0
	lengthInSeconds = 0
	set_physics_process(false)
	active=false
	ellapsedTimeInSeconds = 0
	
	
func startInSeconds(_lengthInSeconds):
	lengthInSeconds=_lengthInSeconds
	lengthInFrames=_lengthInSeconds/GLOBALS.SECONDS_PER_FRAME #frames = seconds / (seconds / frames)
	ellapsedTimeInSeconds = 0
	active=true
	set_physics_process(true)
	
func start(_lengthInFrames):
	lengthInFrames=_lengthInFrames
	lengthInSeconds = lengthInFrames*GLOBALS.SECONDS_PER_FRAME #seconds = frames * (seconds / frames)
	ellapsedTimeInSeconds = 0
	active=true
	set_physics_process(true)
	
func stop():
	active=false
	set_physics_process(false)
	
func setGlobalSpeedMod(g):
	globalSpeedMod = g
	
func get_time_left_in_seconds():
	#return (lengthInSeconds - ellapsedTimeInSeconds)/globalSpeedMod
	return (lengthInSeconds - ellapsedTimeInSeconds)

func getEllapsedTimeInSeconds():
	return ellapsedTimeInSeconds
	
func get_time_left_in_frames():
	
	#convert the time remaining of tech window into # of frames (sec/(sec/frames) = frames)
	return  ceil(get_time_left_in_seconds()/GLOBALS.SECONDS_PER_FRAME)
	
func _physics_process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS

	delta = delta *globalSpeedMod
	
	ellapsedTimeInSeconds= ellapsedTimeInSeconds+delta
	
	#if ellapsedTimeInSeconds>=lengthInSeconds:
	if GLOBALS.has_frame_based_duration_ellapsed(ellapsedTimeInSeconds,lengthInSeconds):
		stop()
		emit_signal("timeout")
		
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass



#to be implemented as hook by subclass
func _on_hit_freeze_finished():
	pass
	
#to be implemented as hook by subclass
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	
	pass
	

func removeFromGlobalSpeedGroup():
	remove_from_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD
	
func hasTimeTickEllapsed():
	return ellapsedTimeInSeconds >0

func forceTimeout():
	var timeoutFlag = false
	#if is_physics_processing():
	if active:
		timeoutFlag=true
	reset()
	if timeoutFlag:
		emit_signal("timeout")