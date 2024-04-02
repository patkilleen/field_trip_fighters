extends "res://basicMovement.gd"

signal arrived
signal restart_following
signal start_following
signal following_special_object_type

enum FollowType{
	NA,
	PROJECTILE_FOLLOW_CASTER, #caster is player who creates projectile
	PROJECTILE_FOLLOW_X_CASTER, #only follows horizontally
	PROJECTILE_FOLLOW_Y_CASTER #only follows vertically
}

enum DestinationType{
	CASTER,
	OPPONENT,
	OTHER # API will have a hook to specify what happens
}


enum DestinationUpdate{
	DYNAMIC,  #keep following new position of destianation
	STATIC#only when follow starts does destination get defined, even if destination node moves, the initial position remains the destination
}
var src = null #node2d
var dst = null#node2d
export (float) var epsilon = 0 
export (Vector2) var offset = Vector2(0,0) setget setOffset,getOffset#offset from destinatio position to check if arrive
var defaultOffset = offset
# Allow floats from 0 to 180 and snap the value to multiples of 0.1
export (float) var angularSpeed = 90 #0-180
export (float) var  maxAngularSpeed = 180 #0-180
export (float) var  minAngularSpeed = 0 #0-180
export (float) var angularAcceleration = 0
export (float) var stopFollowingAngularDeacceleration = 25
export (float) var turnSpeedMod = 1 #0 mean no movement while turning, 1 means no change to movement
export (bool) var onArriveStop=true
export (bool) var initiallyAimAtDestination=false #true means angle will be change to face destination when played
#TODO: combind both types below
export (FollowType) var type = 0
export (DestinationType) var destinationType = 0
export (DestinationUpdate) var destinationUpdate=0
var defaultAngle = 0
var currentAngularSpeed=0 setget setCurrentAngularSpeed,getCurrentAngularSpeed
var isTurning=false#bool
var following =true#bool
var defaultAcceleration = 0
var defaultSpeed = 0

var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

var dstInitialPosition = Vector2(0,0)

func _ready():
	defaultAcceleration = acceleration
	defaultSpeed = speed
	defaultAngle = angle
	defaultOffset = offset
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	pass

func setOffset(o):
	offset = o
	defaultOffset = o
func getOffset():
	return offset
	
func setGlobalSpeedMod(mod):
	globalSpeedMod=mod


func init():
	.init()
	followInit()
	
	

func followInit():
	
	if destinationUpdate == DestinationUpdate.STATIC:
		dstInitialPosition = dst.global_position
		
	#let the high level scripts control what src and destination are
	if destinationType == DestinationType.OTHER:
		emit_signal("following_special_object_type",self)

	if dst == null or src == null:
		stop()
		return

	# do we adjust angle so it initially points to destination?
	if initiallyAimAtDestination:
		angle = computeAngleFromSourceToDestination()
	

	setCurrentAngularSpeed(angularSpeed)
	
	#depending on which way we face, the starting angle may be mirrored
	if mirrorXVelocity:
	
		#simple case of left swamp right
		if defaultAngle == 180:
			angle = 0
		elif defaultAngle == 0:
			angle = 180
		elif defaultAngle > 180:
			angle = 270 - (defaultAngle-270)
		else: #< 180
			angle = 90 - (defaultAngle-90)
			
	else:
		angle = defaultAngle
	
	
	isTurning=false
	following =true
	#make sure when we restart this node's movement, that the original speed values are
	#used and not the values affected from following
	acceleration=defaultAcceleration
	speed = defaultSpeed
	self.ySpeed = speed
	self.xSpeed = speed
	
	if mirrorXVelocity:
		offset.x = -1*defaultOffset.x
	else:
		offset =defaultOffset 
		
	if minAngularSpeed > maxAngularSpeed:
		print("warning, minimum angular speed faster than max in FollowMovement")

		
	emit_signal("start_following",src,dst,self)


func setCurrentAngularSpeed(newAngulerSpeed):
	currentAngularSpeed=min(newAngulerSpeed,maxAngularSpeed)
	currentAngularSpeed=max(newAngulerSpeed,minAngularSpeed)
	
func getCurrentAngularSpeed():
	return currentAngularSpeed
	
func _physics_process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	
	_physics_process_hook(delta)
	
func _physics_process_hook(delta):
	
	#don't update anything the momentum has been frozen
	if frozenMomentum:
		return 
	#need apply  logic
	delta = delta * globalSpeedMod
	#wasn't configured properly?
	if src == null or dst == null or type == FollowType.NA:
		return
	
	#determine the destination position (do we follow
	#destination dynamically or we going to a static point?)
	var dstPos
	
	if destinationUpdate == DestinationUpdate.STATIC:		
		dstPos = dstInitialPosition		
	else:
		dstPos=dst.global_position
		
	##
	##MANAGE SIGNALS OF ARRIVAL AND DEPARTURE
	##
	#var targetDistance = offset + dst.global_position
	var targetDistance = offset + dstPos
	
		
			#following only horizontally or vertically?
	if type == FollowType.PROJECTILE_FOLLOW_X_CASTER:
			
		#ignore the y speed
		targetDistance.y = src.global_position.y
	elif type == FollowType.PROJECTILE_FOLLOW_Y_CASTER:
				
		#ignore the x speed
		targetDistance.x = src.global_position.x
		
	#are we already within desired range of destination?
	var distFromTarget = src.global_position.distance_to(targetDistance)
	if  abs(distFromTarget) <= epsilon:
		
		#only process the new arrival once (we were following and arrived,
		#don't process the case where we have already arrive )
		if following:
			_on_arrived()
			following = false
			#isTurning=false
			
		#in any case, we arrived, so src won't travel away from
		#dst, it will remain fixed toward it
		var desiredAngle = computeAngleFromSourceToDestination()
		self.angle = desiredAngle
	else:
		
		#only process restart follow once 
		if not following:
			_on_redeparture()
			following = true
		
		
	
	#don't do any angle computations if we aren't following
	if not following:	
		return
	
	#convert our angle into a unit vector to calculate desired angle
	
	#var selfMvmDirection = Vector2(cos(self.angle), sin(self.angle))
	#var offsetVec = selfMvmDirection + src.position.normalized()
	#var desiredAngle = rad2deg(offsetVec.normalized().angle_to(dst.position.normalized()))
	#var desiredAngle = rad2deg(selfMvmDirection.angle_to(dst.position))
	var desiredAngle = computeAngleFromSourceToDestination()
	
	#start turning
	
	#have self.angle turn towards desired angle (cockwise desiredAngle <= 0 
	#rotate counterclockwise, desiredAngle > 0 rotate clockwise)
	
	var neededAngleChange = self.angle - desiredAngle
	
	neededAngleChange = bindAngleInDegrees(neededAngleChange)
	var clockwiseMod = 1
	if neededAngleChange >= 180:
		clockwiseMod = 1
		neededAngleChange = 360 - neededAngleChange
		#neededAngleChange = bindAngleInDegrees(neededAngleChange)
	else:
		clockwiseMod = -1
	
	#if desiredAngle <= 0:
	#	clockwiseMod = -1
		
	var angleIncrease = currentAngularSpeed*delta
	
	#can we make the turn in 1 frame?
	if abs(neededAngleChange) <= angleIncrease:
		self.angle = desiredAngle
	
		#return		
		if isTurning:
				_on_stop_turning()
				isTurning = false
	else:		
	
		if not isTurning:
			#now we can't turn in 1 frame, so start rotation
			_on_start_turning()
	
			isTurning = true
	
		
	
	
	#only accelerate roation if were turning
	if isTurning:
		#multiply clockwise mod to decide if incrementing clockwise or counterclockwise
		self.angle = self.angle + (clockwiseMod * angleIncrease) 
		var newAngulerSpeed = currentAngularSpeed + (angularAcceleration * delta)
		setCurrentAngularSpeed(newAngulerSpeed)
		

func computeAngleFromSourceToDestination():
	
		#determine the destination position (do we follow
	#destination dynamically or we going to a static point?)
	var dstPos
	
	if destinationUpdate == DestinationUpdate.STATIC:		
		dstPos = dstInitialPosition+offset
	else:
		dstPos = dst.global_position+offset
		
		
	var srcPos = src.global_position
	
	
	#update()
	
	
	
	#var desiredAngle = rad2deg(srcPos.angle_to(dstPos))
	var desiredAngle = rad2deg((dstPos-srcPos).angle())	
	
	return desiredAngle
		

#converts a multiple rotation angle to 0-360
func bindAngleInDegrees(_angle):
	#make sure convert from 0-306
	while _angle > 360:
		_angle = _angle -360
		
	while _angle < 0:
		_angle = _angle + 360

	return _angle
func _on_arrived():
	
	if onArriveStop:
		stop()
	else:	
		#make it so the movement of basic movement will head to 0
		acceleration=(-1)*stopFollowingAngularDeacceleration
	
		_on_stop_turning()
	emit_signal("arrived",src,dst,self)

func _on_redeparture():
	followInit()
	emit_signal("restart_following",src,dst,self)
	
func _on_start_turning():
	
	pass
	
func _on_stop_turning():
	#reset the angular speed upon a new turn (don't
	#want 1st turn to be slow and then next turn super fast
	#due to acceleration
	setCurrentAngularSpeed(angularSpeed)
	pass
	
	
#override get current speed. Speed change when turning
#and facing movement isn't a thing for following
	
	
func getCurrentSpeed():
	
	var velocity = Vector2(0,0)
	
	
	#if is_physics_processing():
	velocity.x = cos((angle) * PI / 180) * (xSpeed*rawSpeedMod.x);
	velocity.y = sin((angle) * PI / 180) * (ySpeed*rawSpeedMod.y);
	
	#affect speed by speed mode (x2 faster mod means x2 faster movement)
	velocity = velocity *movementAnimationManager.globalSpeedMod
	
	#apply turning mod if turnig
	if isTurning:
		velocity=velocity*turnSpeedMod
	
	#following only horizontally or vertically?
	if type == FollowType.PROJECTILE_FOLLOW_X_CASTER:
	
		#ignore the y speed
		velocity.y = 0
	elif type == FollowType.PROJECTILE_FOLLOW_Y_CASTER:
		#ignore the x speed
		velocity.x = 0
	
	return velocity