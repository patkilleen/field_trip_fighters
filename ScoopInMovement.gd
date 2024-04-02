extends "res://FollowMovement.gd"

#signal arrived
#signal restart_following
#signal start_travelin
#signal taveling_to_special_object_type



#var src = null #node2d
#var dst = null#node2d
#export (float) var epsilon = 0 
#export (Vector2) var offset = Vector2(0,0) setget setOffset,getOffset#offset from destinatio position to check if arrive
#ar defaultOffset = offset


#variable to keep track of how much progress was in straight vector towards desitnation
#in both axis
var distanceTraveled=Vector2(0,0)

#the amount of distance required  (in both axis0) to travel before arriving
var maxDistanceTraveled=Vector2(0,0)

export (bool) var dynamicSpeed=true # true means speed will be dynamic to make sure the duration and distance will make object arrive always at same time (fast far away, slow nearby)
##TODO: combind both types below
#export (FollowType) var type = 0
#export (DestinationType) var destinationType = 0


#var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

#var dstInitialPosition = Vector2(0,0)

func _ready():
	
	#prevent inifinite travel from negative epsions
	if epsilon <0:
		epsilon=0
		
		
	defaultOffset = offset
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	pass

#func setOffset(o):
#	offset = o
#	defaultOffset = o
#func getOffset():
	return offset
	
#func setGlobalSpeedMod(mod):
#	globalSpeedMod=mod


#func init():
#	.init()
#	travelInit()
	
	
#override
func followInit():

	#cfor compatibility	
	if destinationUpdate == DestinationUpdate.STATIC:
		dstInitialPosition = dst.global_position


	#reasting a new travel, reset distance tradcking
	distanceTraveled=Vector2(0,0)
	maxDistanceTraveled=Vector2(0,0)

	following=true
	
	if mirrorXVelocity:
		offset.x = -1*defaultOffset.x
	else:
		offset =defaultOffset 
			
	if destinationType == DestinationType.OTHER:
		#allow some nodes to manually decide what destination is
		emit_signal("following_special_object_type",self)
	
	
	#point towards destination 
	angle = computeAngleFromSourceToDestination()
	
	#var targetDistance = offset + dst.global_position
	var targetDestinationPoint = offset + dst.global_position
	
		
	#travleing only horizontally or vertically?
	if type == FollowType.PROJECTILE_FOLLOW_X_CASTER:
			
		#ignore the y direction
		targetDestinationPoint.y = src.global_position.y
	elif type == FollowType.PROJECTILE_FOLLOW_Y_CASTER:
				
		#ignore the x direction
		targetDestinationPoint.x = src.global_position.x
	
	
	
	#compute amount of absolute distance needed to travel before arriving at destination
	maxDistanceTraveled.x = abs(targetDestinationPoint.x - src.global_position.x)
	maxDistanceTraveled.y = abs(targetDestinationPoint.y - src.global_position.y	)


	if dynamicSpeed:
		#speed should make it that you arrive in "duration" frames to destination
		# pixels / second =   distance (pixels) / duration (secs)
		speed = abs(src.global_position.distance_to(targetDestinationPoint))/ (duration)
		
		
	self.ySpeed = speed
	self.xSpeed = speed
	
	
	emit_signal("start_following",src,dst,self)
	
	#so if we already arrived by being in radius, emmit the signal
	if reachedDestination():
		_on_arrived();
		
	#emit_signal("start_following",src,dst,self)
#override to alway sstop
func _on_arrived():
	
	stop()
	
	emit_signal("arrived",src,dst,self)
	
#override the physisc process
func _physics_process_hook(delta):
	#we don't track the ellapsed distance travelled when momentum has been frozen
	if frozenMomentum:
		return
	#delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	#need apply  logic
	delta = delta * globalSpeedMod
	#wasn't configured properly?
	if src == null or dst == null or type == FollowType.NA:
		return
	
	
		
	#have we traveled enough in x distance to potentially have arrived?
	if reachedDestination():
			
		if following:
			#print("scooped-in")	
			_on_arrived()
			following = false
		return 
			
			
	#compute distance traveled
	var velocity = getCurrentSpeed()
	distanceTraveled.x = distanceTraveled.x+ abs(velocity.x * delta)
	distanceTraveled.y = distanceTraveled.y+ abs(velocity.y * delta)

func reachedDestination():
	#have we traveled enough in x distance to potentially have arrived?
	if distanceTraveled.x >= (maxDistanceTraveled.x-epsilon):
		#have we traveled enough in x distance to potentially have arrived?
		if distanceTraveled.y >= (maxDistanceTraveled.y-epsilon):
			return true
			
	return false	
func getCurrentSpeed():
	
	var velocity = Vector2(0,0)
	
	
	#if is_physics_processing():
	velocity.x = cos((angle) * PI / 180) * (xSpeed*rawSpeedMod.x);
	velocity.y = sin((angle) * PI / 180) * (ySpeed*rawSpeedMod.y);
	
	#affect speed by speed mode (x2 faster mod means x2 faster movement)
	velocity = velocity *movementAnimationManager.globalSpeedMod

	#following only horizontally or vertically?
	if type == FollowType.PROJECTILE_FOLLOW_X_CASTER:
	
		#ignore the y speed
		velocity.y = 0
	elif type == FollowType.PROJECTILE_FOLLOW_Y_CASTER:
		#ignore the x speed
		velocity.x = 0
	
	return velocity