extends Node

signal finished

const GLOBALS = preload("res://Globals.gd")

export (float) var speed=1 setget setSpeed,getSpeed#speed in form of 100%, meaning it takes 100% of duration to complete (speed 0.5 means x2 duration in seconds)
export (float) var acceleration=0 setget setAcceleration,getAcceleration
export (float) var maxSpeed=1 setget setMaxSpeed,getMaxSpeed
export (float) var minSpeed=0 setget setMinSpeed,getMinSpeed
export (bool) var ignoreHitFreeze = true
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

var currSpeed = 0
var defaultSpeed

#this flag indicates if time ellapses or not (for indefinite movenent, turn flag to true)
var timerPauseFlag = false


var inHitFreeze = false

var running = false

var obj=null
var member=null
var method=null
var initValue=null
var finalValue=null
var duration = null

var ellapsedTime=0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	
	self.set_physics_process(false)
	running=false
	
	if speed > maxSpeed or speed < minSpeed:
		print("my tween: wanring, speed is incorrectly bounded by max/mins speeds")
		

func setSpeed(s):
	speed=s
	
	if speed > maxSpeed or speed < minSpeed:
		print("my tween: wanring, speed is incorrectly bounded by max/mins speeds")
func getSpeed():
	return speed
	
func setAcceleration(a):
	acceleration = a
func getAcceleration():
	return acceleration
	
func setMaxSpeed(ms):
	maxSpeed = ms
	
func getMaxSpeed():
	return maxSpeed
	
func setMinSpeed(ms):
	minSpeed = ms
	
func getMinSpeed():
	return minSpeed
	
func init():
	self.set_physics_process(false)
	running=false
	ellapsedTime=0
	currSpeed =speed

func start_interpolate_property(_obj,_member,_initValue,_finalValue,_duration):
	
	#illegal arg
	if _obj == null or _member == null or _initValue == null or _finalValue == null or _duration == null or _duration <0:
		print("my tween illegal arg")
		return
	running = true
	obj=_obj
	member=_member
	initValue=_initValue
	finalValue=_finalValue 
	duration=_duration
	reset()

func start_interpolate_method(_obj,_method,_initValue,_finalValue,_duration):
	
	#illegal arg
	if _obj == null or _method == null or _initValue == null or _finalValue == null or _duration == null or _duration <0:
		print("my tween illegal arg")
		return
	running = true
	obj=_obj
	method=_method
	initValue=_initValue
	finalValue=_finalValue 
	duration=_duration
	reset()	

func stop():
	running = false
	self.set_physics_process(false)
	
func reset():
	ellapsedTime=0
	currSpeed =clamp(speed,minSpeed,maxSpeed)	
	self.set_physics_process(true)
	#reset the initial value of given object's property
	if obj != null:
		
		#interpolating property?
		if member != null:
			obj.set(member,initValue)
		else:
			#interpolating method
			obj.call(method,initValue)
	

	
	
func setGlobalSpeedMod(mod):
	globalSpeedMod=mod
	
	
	
func _on_hit_freeze_finished():
	if not ignoreHitFreeze:
		inHitFreeze=false
		if running:
			self.set_physics_process(true)
			
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	if not ignoreHitFreeze:
		inHitFreeze=true
		if running:
			self.set_physics_process(false)
	
func _physics_process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	
	if not running:
		return
		
	
	
	delta = delta * globalSpeedMod
	
	#update the speed assuming there is accerleration
	currSpeed = currSpeed + (acceleration*globalSpeedMod) * delta
	currSpeed = clamp(currSpeed,minSpeed,maxSpeed)
	
	#speed of tween affects how fast the ellapsed time will take to reach duration
	ellapsedTime = ellapsedTime + (delta*currSpeed)
	
	if ellapsedTime >= duration:
		
		#interpolating property?
		if member != null:
			obj.set(member,finalValue)
		else:
			#interpolating method
			obj.call(method,finalValue)			
		
		stop()
		emit_signal("finished")
		
	else:
		_interpolate_step()
		
func _interpolate_step():
		# Now, we pretend to have forgotten the original ratio and want to get it back.
	#var ratio = inverse_lerp(20, 30, 27.5)
	# `ratio` is now 0.75.
#	const  = 10

	#compute the ratio of completion 

	var completionRatio = inverse_lerp(0,duration,ellapsedTime)	
	#completionRatio is now  from 0 to 1 to indicate progress how much we finished
	
	#	var completionRatio = inverse_lerp(initialValue,finalValue,currValue)
	
	
	#var middle = lerp(20, 30, 0.75)
# `middle` is now 27.5.
	var newValue = lerp(initValue,finalValue,completionRatio)
	
	#update the property
	
	#interpolating property?
	if member != null:
		obj.set(member,newValue)
	else:
		#interpolating method
		obj.call(method,newValue)	


func removeFromGlobalSpeedGroup():
	remove_from_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD