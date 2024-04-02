extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal hit_freeze_finished

var expireTime = -1
var ellapsedTime = -1
#const FPS = 1.0/60.0

var GLOBALS = preload("res://Globals.gd")


func _ready():
	stopHitFreeze()
	
	pass


func isInHitFreeze():
	return self.is_physics_processing()
	
#starts the hitfreeze timer and will signal "hit_freeze_finished"
#when the time is up
#param: number of frames to remain in hit freeze
func startHitFreeze(numFrames):
	
		#special cases
	if numFrames < 0:
		print("warning, setting negative hit freeze duration")
		stopHitFreeze()
		return
	elif numFrames == 0:	#no hit freeze?
		stopHitFreeze()
		emit_signal("hit_freeze_finished")
		return
	
	#reset time measured
	ellapsedTime = 0
	#set time when hit freeze is finished
	expireTime = GLOBALS.SECONDS_PER_FRAME*numFrames
	
	
	self.set_physics_process(true)
	
func stopHitFreeze():
	expireTime = -1
	ellapsedTime = -1
	self.set_physics_process(false)
	
func _physics_process(delta):
	
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	ellapsedTime += delta #todo: do we apply global speed mod here?
	#time is up?
	#if ellapsedTime >= expireTime:
	if GLOBALS.has_frame_based_duration_ellapsed(ellapsedTime,expireTime):
		stopHitFreeze()
		emit_signal("hit_freeze_finished")	


	