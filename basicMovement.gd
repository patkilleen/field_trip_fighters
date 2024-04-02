extends Node

signal stopped
signal complx_mvm_signal_stopped
#const FRAME_PER_SECOND = 60

const GLOBALS = preload("res://Globals.gd")

enum InheritRelativeVelocityType{
	NO_INHERITANCE,
	INHERIT_RELATIVE_VELOCITY_EXCLUDING_GRAVITY,
	INHERIT_RELATIVE_VELOCITY_INCLUDING_GRAVITY
}

export (float) var speed=0 setget setSpeed,getSpeed
export (InheritRelativeVelocityType) var inheritSpeedType=InheritRelativeVelocityType.NO_INHERITANCE #true means the speed given is ignored and is replaced with current velocity
export (float) var acceleration=0
export (float) var maxSpeed=0
export (float) var minSpeed=0
export (float) var angle=0 setget setAngle,getAngle
var activeAngle = 0
var duration=0
export (int) var durationInFrames=0 setget setDurationInFrames,getDurationInFrames
export (bool) var opposingGravity = false # when true, indicates this bm ussed to make gravity feel floatier (assumes angle 270)
export (bool) var speedFacingDependant = true #when true, facing opposite direction will mirror x velocity, false the facing is ignored
export (bool) var dynamicAngle = false #true means external source will set angle. usually used for hitting opponent in direction of current momentum
export (Vector2) var rawSpeedMod = Vector2(1,1)
export (bool) var preventAccelerationOnFrozenMomentum=false
var animationSpeed =1.0


var totalTime = 0
var xSpeed = 0 setget setXSpeed,getXSpeed
var ySpeed = 0 setget setYSpeed,getYSpeed

#this flag indicates if time ellapses or not (for indefinite movenent, turn flag to true)
var timerPauseFlag = false

#var stopped = true setget setStopped, getStopped
var stopped = true

var movementAnimationManager = null
#flag used to mirror x-movement when true, and leave x-velocity unchange when false
var mirrorXVelocity = false


var frozenMomentum=false

func _ready():
	set_physics_process(false)
	
	
	ySpeed = speed
	xSpeed = speed
	totalTime = 0
	activeAngle = angle
	#convert the number of frames to time
	#to have movement be independent of FPS
	#var frameDuration = 1.0/FRAME_PER_SECOND
	#duration = durationInFrames*frameDuration
	duration = durationInFrames* GLOBALS.SECONDS_PER_FRAME
	
	if opposingGravity and angle != 270:
		print("warning: illconfired opposing gravity basic movement of non 270 angle: "+str(get_path()))
	pass

#these getters just for easily changing the attribute in editor during match
func setSpeed(s):
	speed = s
	ySpeed = speed
	xSpeed = speed
func getSpeed():
	return speed

#these getters just for easily changing the attribute in editor during match
func setAngle(a):
	angle = a
	activeAngle = angle
	
func getAngle():
	return angle
	
#these getters just for easily changing the attribute in editor during match
func setDurationInFrames(d):
	durationInFrames = d
	duration = durationInFrames* GLOBALS.SECONDS_PER_FRAME
func getDurationInFrames():
	return durationInFrames

func set_movement_animation_manager(mvmAnimeMngr):
	
	movementAnimationManager=mvmAnimeMngr
	
#func setStopped(flag):
#	stopped = flag
#	if stopped == false:
#		emit_signal("stopped",self)
		
#func getStopped():
#	return stopped
	
	
func isActive():
	return not stopped
	

func init():
	ySpeed = speed
	xSpeed = speed
	totalTime = 0
	activeAngle = angle
	timerPauseFlag = false
	stopped = false
	#mirrorXVelocity=false
	set_physics_process(true)
	frozenMomentum=false

func reset():	
	ySpeed = speed
	xSpeed = speed
	totalTime = 0
	activeAngle = angle
	timerPauseFlag = false
	stopped = false
	#mirrorXVelocity=false
	set_physics_process(false)


	
func stop():
	
	stopped = true
	set_physics_process(false)
	emit_signal("stopped",self)

func pause():
	set_physics_process(false)
	
func unpause():
	if not stopped:
		set_physics_process(true)	
	#if duration <= 0:
	#	set_physics_process(true)	
	#	return
	#only unpause if duration not exceeded	
	#if totalTime < duration:
	#	set_physics_process(true)	
	

func hasTimeExpired():
	#duration <= 0 means indefinite duration
	#by design
	#if duration <= 0:
	if duration <= 0:
		return false
	#return totalTime >= (duration/movementAnimationManager.globalSpeedMod)
	return GLOBALS.has_frame_based_duration_ellapsed(totalTime,duration)
	
func _physics_process(delta):
	
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	#don't count time ellapsed if momentum has been frozen
	if not frozenMomentum:
	#delta = delta * animationSpeed * movementAnimationManager.globalSpeedMod
		totalTime = totalTime + (delta* animationSpeed * movementAnimationManager.globalSpeedMod)
	#the time ellapsed is affected by global speed mod
	#delta = delta *movementAnimationManager.globalSpeedMod 
	
	
	#make sure to stop the movement once the duration expires
	if((not timerPauseFlag) and (duration > 0)):
		if GLOBALS.has_frame_based_duration_ellapsed(totalTime,duration):
		#if((totalTime+delta) >= (duration/movementAnimationManager.globalSpeedMod))):
			#delta = duration - totalTime
			stop()
			return

	
	#totalTime = totalTime +delta
	#divide cause don't want to change accerlearation rate
	updateCurrentSpeed(delta)
	

func updateCurrentSpeed(delta):
	#did we ability cancel and freeze the basic movement to keep momentum?
	if frozenMomentum:
		
		#do we prevent acceleratin when abilty cancel froze this momemntum?
		if preventAccelerationOnFrozenMomentum:
			pass #don't add to the speed
		else:
			xSpeed = xSpeed + (acceleration*movementAnimationManager.globalSpeedMod) * delta
			ySpeed = ySpeed + (acceleration*movementAnimationManager.globalSpeedMod) * delta
	else:
		xSpeed = xSpeed + (acceleration*movementAnimationManager.globalSpeedMod) * delta
		ySpeed = ySpeed + (acceleration*movementAnimationManager.globalSpeedMod) * delta
	#xSpeed = xSpeed + (acceleration) * delta
	#ySpeed = ySpeed + (acceleration) * delta

	xSpeed = min(xSpeed,maxSpeed)
	xSpeed = max(xSpeed,minSpeed)
	ySpeed = min(ySpeed,maxSpeed)
	ySpeed = max(ySpeed,minSpeed)

func getCurrentSpeed():
	
	var velocity = Vector2(0,0)
	
	var relativeXSpeed = xSpeed * rawSpeedMod.x

	#do we potentiall mirror x depending on facing?
	if speedFacingDependant:
		#we do, so now check if x velocity should be mirrored
		if mirrorXVelocity:
			relativeXSpeed= (-1)*relativeXSpeed
	#if is_physics_processing():
	velocity.x = cos((activeAngle) * PI / 180) * (relativeXSpeed);
	velocity.y = sin((activeAngle) * PI / 180) * (ySpeed*rawSpeedMod.y);
	
	#affect speed by speed mode (x2 faster mod means x2 faster movement)
	return (velocity *movementAnimationManager.globalSpeedMod)
	#return velocity
	

func setXSpeed(spd):
	xSpeed = spd
func getXSpeed():
	return xSpeed
	
func getYSpeed():
	return ySpeed
	
func setYSpeed(spd):
	ySpeed = spd

func freezeMomentum():
	frozenMomentum=true
	totalTime=0
	
	
	
