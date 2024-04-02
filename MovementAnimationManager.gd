extends Node
signal wall_collision
signal ceiling_collision
signal moved_kinematic_body 
signal reached_vertical_momentum_apex
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const GRAVITY_ACCELERATION = 1100
const GRAVITY_MAX_SPEED = 50000 # no coun
const GRAVITY_REPLAY_Y_SPEED = 6
#const GRAVITY_REPLAY_Y_SPEED = 25
const MINIMUM_Y_VELOCITY_TO_KEEP_FLOOR_COLLISION = 6

export var player_name = "p1"

const complxMvmResource = preload("res://complexMovement.gd")

var gravity = null

var activeMvms = []

var additionalMvmStack = []

#var timeEllapsed = 0

#var currentAnimation = null

var targetKinematicBody2D = null
var playerController = null

var bodyBox = null

var floor_normal = Vector2(0, -1)

#unused i think, but the sub class does, so this is tmp fix
var spriteAnimationManager = null setget setSpriteAnimationManager,getSpriteAnimationManager
var floorDetector = null

var movementAnimations = []

#var currentCmplxMovements = []

var colliders = [] #collisionhandler will need access to these for collision
var on_floor = false
var on_ceiling = false
var on_wall = false
var floor_velocity = Vector2(0,0)




var facingRight = true

var lastGravityEffect = null
#this is just used to access the enumeration types
#var complexMvmRef = null

var globals = null

var GLOBALS = preload("res://Globals.gd")
#changing this will globaly alter speed of animations
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

#used to lock the use of keep relative gravity
var hasAlreadyComputedRelGravFlag = false

var bounceBasicMvm = null
var bounceOpposingGravBasicMvm = null
#var bouncingEnabled = false
#for bouncing
var lastBouncableMvmPlayed = null

var bounceLock = false

var wallCollisionNormal = Vector2(1,0).normalized()
var ceilingCollisionNormal = Vector2(0,-1).normalized()
var floorCollisionNormal = Vector2(0,-1).normalized()

var lastRelativeVelocity = Vector2(0,0)
var lastRelativeVelocityExcGrav = Vector2(0,0)

var activeUninterruptableBMs ={}




var activeAnimationMap = {}

var isPaused = false

var gravTypePriorityMap = {}

var mvmTypePriorityIXMap = {} #sotres the indices of movementtypes which will act as priroty as first elements in a list will be processed first
var mvmTypePriorityIXTmpArray = []
#complex movements that start this frame that have yet to affect the basic moovement arrays
var unprocessedComplexMvmMap= {}
var mvmTypesAvailableThisFrame = {}

var priorityOfAnimeHoldingLock = null

var specialBounceMvmAnimations = null

func _ready():
	
	
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	
	globals = get_node("/root/Globals")
	
	gravity = $Gravity
	gravity.acceleration = GRAVITY_ACCELERATION
	gravity.maxSpeed = GRAVITY_MAX_SPEED
	gravity.init()
	gravity.set_movement_animation_manager(self)
	
	loadBounceMvmsIntoScene()
	
	if not is_connected("moved_kinematic_body",self,"_on_moved_kinematic_body"):
		connect("moved_kinematic_body",self,"_on_moved_kinematic_body")
#	bounceOpposingGravBasicMvm = $"Bouncing-mvms/opposing-gravity-bm"

	
	#set_process(false)
	#set_physics_process(false)
	
	var id = 0
	for c in $MovementAnimations.get_children():
		
		if c is preload("res://movementAnimation.gd"):
			movementAnimations.append(c)
			c.id = id
			id = id + 1
		
	
	#filled the map with empty lists, partitioned by MovementType
	unprocessedComplexMvmMap[complxMvmResource.MovementType.ADD]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.NEW]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.POP]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.POP_ALL]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.POP_ALL_KEEP_RELATIVE_GRAVITY_SPEED]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.FREEZE_AIR_MOMENTUM]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.WALL_BOUNCE_KEEP_RELATIVE_SPEED]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.WALL_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.WALL_BOUNCE_KEEP_RELATIVE_SPEED_WOG]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.WALL_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING_WOG]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED_WOG]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING_WOG]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED_WOG]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING_WOG]=[]
	unprocessedComplexMvmMap[complxMvmResource.MovementType.UNINTERRUPTIBLE]=[]

	
	mvmTypePriorityIXMap[complxMvmResource.MovementType.FREEZE_AIR_MOMENTUM]=0
	mvmTypePriorityIXMap[complxMvmResource.MovementType.POP_ALL_KEEP_RELATIVE_GRAVITY_SPEED]=1
	mvmTypePriorityIXMap[complxMvmResource.MovementType.POP_ALL]=2	
	mvmTypePriorityIXMap[complxMvmResource.MovementType.POP]=3
	mvmTypePriorityIXMap[complxMvmResource.MovementType.NEW]=4
	mvmTypePriorityIXMap[complxMvmResource.MovementType.ADD]=5
	mvmTypePriorityIXMap[complxMvmResource.MovementType.WALL_BOUNCE_KEEP_RELATIVE_SPEED]=6
	mvmTypePriorityIXMap[complxMvmResource.MovementType.WALL_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING]=7
	mvmTypePriorityIXMap[complxMvmResource.MovementType.WALL_BOUNCE_KEEP_RELATIVE_SPEED_WOG]=8
	mvmTypePriorityIXMap[complxMvmResource.MovementType.WALL_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING_WOG]=9
	mvmTypePriorityIXMap[complxMvmResource.MovementType.CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED]=10
	mvmTypePriorityIXMap[complxMvmResource.MovementType.CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING]=11
	mvmTypePriorityIXMap[complxMvmResource.MovementType.CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED_WOG]=12
	mvmTypePriorityIXMap[complxMvmResource.MovementType.CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING_WOG]=13
	mvmTypePriorityIXMap[complxMvmResource.MovementType.ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED]=14
	mvmTypePriorityIXMap[complxMvmResource.MovementType.ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING]=15
	mvmTypePriorityIXMap[complxMvmResource.MovementType.ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED_WOG]=16
	mvmTypePriorityIXMap[complxMvmResource.MovementType.ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING_WOG]=17
	mvmTypePriorityIXMap[complxMvmResource.MovementType.UNINTERRUPTIBLE]=18
	
	#fill a buffer tha will be used at each movement process
	for i in mvmTypePriorityIXMap.keys().size():
		mvmTypePriorityIXTmpArray.append(null)
	#map that given a gravity type (key) a list of gravity types with higher priority given
	#if the value inside inner map isn't null, it means we replace that inner key with the inner value
	#NOTHING higher priority than replay
	
	var tmpGravPriorityMap = {}
	gravTypePriorityMap[complxMvmResource.GravityEffect.REPLAY]=tmpGravPriorityMap
	
	#replay is only type that has higher priority than REPLAY_AND_KEEP_FLOOR_COLLISION
	tmpGravPriorityMap = {}
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY]=null
	gravTypePriorityMap[complxMvmResource.GravityEffect.REPLAY_AND_KEEP_FLOOR_COLLISION]=tmpGravPriorityMap
	
	
	tmpGravPriorityMap = {}
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY_AND_KEEP_FLOOR_COLLISION]=null
	gravTypePriorityMap[complxMvmResource.GravityEffect.REPLAY_IF_PLAYING]=tmpGravPriorityMap
	
	tmpGravPriorityMap = {}
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY_AND_KEEP_FLOOR_COLLISION]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.PLAY]=null
	gravTypePriorityMap[complxMvmResource.GravityEffect.KEEP_AND_REPLAY_IF_STOPPED]=tmpGravPriorityMap
	
	tmpGravPriorityMap = {}
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY_AND_KEEP_FLOOR_COLLISION]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY_IF_PLAYING]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.KEEP_AND_REPLAY_IF_STOPPED]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.STOP]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.PLAY]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.PAUSE]=null
	gravTypePriorityMap[complxMvmResource.GravityEffect.KEEP]=tmpGravPriorityMap
	
	tmpGravPriorityMap = {}
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY_AND_KEEP_FLOOR_COLLISION]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.KEEP_AND_REPLAY_IF_STOPPED]=complxMvmResource.GravityEffect.REPLAY
	tmpGravPriorityMap[complxMvmResource.GravityEffect.PLAY]=null
	gravTypePriorityMap[complxMvmResource.GravityEffect.STOP]=tmpGravPriorityMap
	
	tmpGravPriorityMap = {}
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY_AND_KEEP_FLOOR_COLLISION]=null	
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY_IF_PLAYING]=complxMvmResource.GravityEffect.REPLAY
	gravTypePriorityMap[complxMvmResource.GravityEffect.PLAY]=tmpGravPriorityMap
	
	tmpGravPriorityMap = {}
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY_AND_KEEP_FLOOR_COLLISION]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.REPLAY_IF_PLAYING]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.KEEP_AND_REPLAY_IF_STOPPED]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.STOP]=null
	tmpGravPriorityMap[complxMvmResource.GravityEffect.PLAY]=null
	gravTypePriorityMap[complxMvmResource.GravityEffect.PAUSE]=tmpGravPriorityMap

func loadBounceMvmsIntoScene():
	
	var boucningMvmNode = Node.new()
	
	bounceBasicMvm = Node.new()
	bounceBasicMvm.set_script(preload("res://bounceMovement.gd"))
	
	bounceOpposingGravBasicMvm = Node.new()
	bounceOpposingGravBasicMvm.set_script(preload("res://basicMovement.gd"))
	
	
	boucningMvmNode.add_child(bounceBasicMvm)
	boucningMvmNode.add_child(bounceOpposingGravBasicMvm)
	
	self.add_child(boucningMvmNode)
	#bounceBasicMvm = $"Bouncing-mvms/bounce-bm"
	
	bounceBasicMvm.speed=0
	bounceBasicMvm.acceleration=0
	bounceBasicMvm.maxSpeed=10000
	bounceBasicMvm.minSpeed=-10000
	bounceBasicMvm.angle=0
	bounceBasicMvm.durationInFrames=0
	bounceBasicMvm.opposingGravity=false
	bounceBasicMvm.movementAnimationManager = self
	
	bounceOpposingGravBasicMvm.speed=0
	bounceOpposingGravBasicMvm.acceleration=0
	bounceOpposingGravBasicMvm.maxSpeed=gravity.maxSpeed
	bounceOpposingGravBasicMvm.minSpeed=0
	bounceOpposingGravBasicMvm.angle=0
	bounceOpposingGravBasicMvm.durationInFrames=0
	bounceOpposingGravBasicMvm.opposingGravity=true
	bounceOpposingGravBasicMvm.movementAnimationManager = self

func reset():
	
	for a in movementAnimations:
		a.reset()
	var keepFloorCollision = false
	deactivateAllMovement(keepFloorCollision)
	activeMvms = []

	colliders = []
	on_floor = false
	on_ceiling = false
	on_wall = false
	floor_velocity=Vector2(0,0)
	isPaused=false
	additionalMvmStack = []

	facingRight = true

	lastGravityEffect = null
	hasAlreadyComputedRelGravFlag = false

	if bounceBasicMvm != null:
		bounceBasicMvm.stop()
		
	if bounceOpposingGravBasicMvm != null:
		bounceOpposingGravBasicMvm.stop()
		
	if gravity != null:
		#gravity.stop()
		stopGravity()
		gravity.acceleration = GRAVITY_ACCELERATION
		gravity.maxSpeed = GRAVITY_MAX_SPEED
		gravity.reset()
		

	for bm in activeUninterruptableBMs.keys():
		bm.stop()
		
	activeUninterruptableBMs={}
		
	lastBouncableMvmPlayed = null

	bounceLock = false


	lastRelativeVelocity = Vector2(0,0)
	lastRelativeVelocityExcGrav = Vector2(0,0)


	activeAnimationMap.clear()
	activeAnimationMap = {}


	mvmTypePriorityIXTmpArray.clear()
	mvmTypePriorityIXTmpArray=[]
	#fill a buffer tha will be used at each movement process
	for i in mvmTypePriorityIXMap.keys().size():
		mvmTypePriorityIXTmpArray.append(null)
	
	#complex movements that start this frame that have yet to affect the basic moovement arrays
	
	for k in unprocessedComplexMvmMap.keys():
		var list = unprocessedComplexMvmMap[k]
		list.clear()
		
	mvmTypesAvailableThisFrame.clear()
	#mvmTypesAvailableThisFrame = {}

	priorityOfAnimeHoldingLock = null

	specialBounceMvmAnimations = null
	
	for ma  in movementAnimations:
		ma.reset()
	pass
func init(_playerController):
	
	
	
	#connect in init to avoid having ready called twice 
	bounceBasicMvm.connect("stopped_bouncing",self,"_on_stopped_bouncing")
	bounceBasicMvm.connect("stopped_bouncing",_playerController,"_on_stopped_bouncing")
	bounceBasicMvm.connect("started_bouncing",_playerController,"_on_started_bouncing")
	bounceBasicMvm.connect("started_bouncing",self,"_on_started_bouncing")
	bounceBasicMvm.connect("bounced",self,"_on_bounced")
	bounceBasicMvm.connect("bounced",_playerController,"_on_bounced")
	bounceBasicMvm.playerController = _playerController
	
	playerController=_playerController
	
	isPaused=false
	
	
	#only start the movement processing for players. projectiles start when fired
	#this is important, since even though projectiles deactive when ready, multithreading 
	#issues will occur to trigger the physics process between time set true and deactivated
	if playerController is preload("res://PlayerController.gd"):
		set_physics_process(true)
	else:#for projectiles they don't spawn
		set_physics_process(false)
		#although physics process not running for engine unspwaned projectil pruposes
		#the projectil movement mngr isn't paused, as when play animation it should be considered
		#active
		
	pass

	
func setGlobalSpeedMod(mod):
	globalSpeedMod=mod


func setSpriteAnimationManager(sam):
	spriteAnimationManager  = sam
	
func getSpriteAnimationManager():
	return spriteAnimationManager
#animation id, and bool isFacingRight (true  means forward is right), isFacingRight (flase means forward left)
func play(mvmAnimationId, isFacingRight,_spriteFacingRight=true):
	playMovementAnimation(movementAnimations[mvmAnimationId], isFacingRight,_spriteFacingRight)
	#		break
func playMovementAnimation(anime,isFacingRight,_spriteFacingRight=true):
	

	if anime == null:
		#print("warning playing null movement")
		return
	

	#another animation locked this frame from changing mvm aniation?
	if priorityOfAnimeHoldingLock != null:

		#lower priority animation than the mvm animation that locked the frame?
		if anime.priority <priorityOfAnimeHoldingLock:
			return
		
	
	#does this animation lock the frame and take priority?
	if anime.enforcePriorityLocks:

	
		#when an animation already holds a lock, we have to out prioritize it 
		#to override it
		if priorityOfAnimeHoldingLock != null:
			
			#higher prirotiy? NOTE that for locking frame, only lesser prioirties locked out
			#this way same prioirty animation aren't affected (2 hitstun animations played at same time
			#, for example)
			if anime.priority >= priorityOfAnimeHoldingLock:
	
				#this animation locks the frame such that only equal or higher priroty animation can by played this frame
				priorityOfAnimeHoldingLock = anime.priority
	
		else:
			#this animation locks the frame such that only equal or higher priroty animation can by played this frame
			priorityOfAnimeHoldingLock = anime.priority
		
	#connect to the movement animation signals if not already connected	
	if not anime.is_connected("finished",self,"_on_movement_animation_finished"):
		anime.connect("finished",self,"_on_movement_animation_finished")

	if not anime.is_connected("finished_processing_all_complex_mvm",self,"_on_finished_processing_all_complex_mvm")	:
		anime.connect("finished_processing_all_complex_mvm",self,"_on_finished_processing_all_complex_mvm")
		
	if not anime.is_connected("complex_mvm_activated",self,"_on_complex_mvm_activated"):
		anime.connect("complex_mvm_activated",self,"_on_complex_mvm_activated")
		
	if anime.bouncable:
		bounceLock = false

	
	#some special states prevent facing based on player orientation on screen 
	#and instead uses uccrent sprite facing	
	if not playerController.canChangeSpriteFacingInAir() and anime.alignWithFacing:
		#treat the animation as facing where sprite currelty facing
		facingRight=playerController.kinbody.spriteCurrentlyFacingRight
	else:

		facingRight = isFacingRight
	#timeEllapsed = 0 
	
	
	
	#stops everything?
	if anime.stopsAllMvmOnPlay:
		
		if not playerController.my_is_on_floor():
			var keepFloorCollision =false
			deactivateAllMovement(keepFloorCollision)
		else:
			var keepFloorCollision =true
			deactivateAllMovement(keepFloorCollision)
			
	#does this animation override curretly playing ones?
	if anime.overrides:
		
		stopOverridableAnimations(anime.priority)
	
	#does this animation halt any complex mvms that were going to be processed next physics process?
	if anime.clearUnprocessedCmplxMvm:
		clearUnprocessedCmplxMvms(anime.priority)
	
	storeActiveAnimation(anime)
	
	anime.play(isPaused,facingRight,self,_spriteFacingRight)
	
	if not isPaused:
		set_physics_process(true)
	
	
	
				
	#currentCmplxMovements.clear()
	#currentAnimation = anime
	
	
	
	#fill the complex mvms array
	#for  cm in currentAnimation.complexMovements:
		#if cm != null and cm.isUninturruptible():
			#if not cm.is_connected("uninterruptible_bm_stopped",self,"_on_uninterruptible_bm_stopped"):
		#		cm.connect("uninterruptible_bm_stopped",self,"_on_uninterruptible_bm_stopped",[cm])
			
		#give a reference to this movement aniotm manager
		#cm.set_movement_animation_manager(self)
		#currentCmplxMovements.push_front(cm)
		#make sure to reflect the direction of movement (facing)
		#in basic movements. when facing right, that's the default orientation with tmath
		# so mirror when looking left
		#cm.mirrorXVelocity= not isFacingRight 
		
	#print("current animation: " + currentAnimation.name)
	#set_physics_process(true)

func stopMovementAnimation():
	
	
	for bm in activeMvms:		
			bm.stop()
		
	for bmArr in additionalMvmStack:
		for bm in bmArr:
			bm.stop()
	#currentCmplxMovements = []
	#currentCmplxMovements.clear()
	
	activeMvms.clear()
	
	stopAllAnimations()
	
	
	
	#make sure to re-
	#currentAnimation = null
func pause():
	#if currentAnimation == null:
#		pass
#	else:
	isPaused=true
	set_physics_process(false)	
	
	for bm in activeMvms:
		bm.pause()
	for bmArr in additionalMvmStack:
		for bm in bmArr:
			bm.pause()
	gravity.pause()
	
	
	for anime in activeAnimationMap.keys():
		anime.pause()
		
	for bm in activeUninterruptableBMs.keys():
		bm.pause()
func unpause():
#	if currentAnimation == null:
#		pass
#	else:
	isPaused=false
	set_physics_process(true)	
	
	for anime in activeAnimationMap.keys():
		anime.unpause()
		
	for bm in activeMvms:
		bm.unpause()
	for bmArr in additionalMvmStack:
		for bm in bmArr:
			bm.unpause()
			
	#only unpause gravity if it was running
	#that is, if movement made it such that it's stopped or paused, dont unpause gravity,
	#let the active movement do that
	if lastGravityEffect != null and lastGravityEffect != complxMvmResource.GravityEffect.PAUSE and lastGravityEffect != complxMvmResource.GravityEffect.STOP:
		gravity.unpause()		
	elif lastGravityEffect== null:
		gravity.unpause()		

	for bm in activeUninterruptableBMs.keys():
		bm.unpause()
func addGravityToVelocity(velocity):
	#add the gravity
	if gravity.is_physics_processing():
		
		#so there is a special caase for gravity: when the game speed is low,
		#the gravity y velocity may not be enough to keep person grounded,
		#so expplicitly make sure the collision is kept
		if self.playerController.my_is_on_floor() and lastGravityEffect == complxMvmResource.GravityEffect.REPLAY_AND_KEEP_FLOOR_COLLISION:
			#make sure minimum 1 y velcotiy	
			var gravVelicity =  gravity.getCurrentSpeed()
			gravVelicity.y = max(MINIMUM_Y_VELOCITY_TO_KEEP_FLOOR_COLLISION,gravVelicity.y)
			velocity = velocity + gravVelicity
		else:
			#compute it normlly
			velocity = velocity + gravity.getCurrentSpeed()
			
	return velocity

#removes velocity of gravity from a given velocity
func removeGravityFromVelocity(vel):
	if gravity.isActive():
		
		#so there is a special caase for gravity: when the game speed is low,
		#the gravity y velocity may not be enough to keep person grounded,
		#so expplicitly make sure the collision is kept
		if self.playerController.my_is_on_floor() and lastGravityEffect == complxMvmResource.GravityEffect.REPLAY_AND_KEEP_FLOOR_COLLISION:
			#make sure minimum 1 y velcotiy	
			var gravVelicity =  gravity.getCurrentSpeed()
			gravVelicity.y = max(MINIMUM_Y_VELOCITY_TO_KEEP_FLOOR_COLLISION,gravVelicity.y)
			vel = vel - gravVelicity
		else:
			#compute it normlly
			vel = vel - gravity.getCurrentSpeed()
			
	return vel
	
func addGravityToVelocityIgnoringHitFreeze(velocity):
		#add the gravity
	if gravity.isActive():
		
		#so there is a special caase for gravity: when the game speed is low,
		#the gravity y velocity may not be enough to keep person grounded,
		#so expplicitly make sure the collision is kept
		if self.playerController.my_is_on_floor() and lastGravityEffect == complxMvmResource.GravityEffect.REPLAY_AND_KEEP_FLOOR_COLLISION:
			#make sure minimum 1 y velcotiy	
			var gravVelicity =  gravity.getCurrentSpeed()
			gravVelicity.y = max(MINIMUM_Y_VELOCITY_TO_KEEP_FLOOR_COLLISION,gravVelicity.y)
			velocity = velocity + gravVelicity
		else:
			#compute it normlly
			velocity = velocity + gravity.getCurrentSpeed()
			
	return velocity
	
func _physics_process(delta):
	
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	
	on_physics_process_hook(delta)
	pass

#to be overriden by subclasses
func on_physics_process_hook(delta):
	
	clearMvmCollisions()
	
	handleCurrentAnimation(delta)
	
	
	#$var velocity = computeRelativeVelocity() * xDirection
	var velocity = computeRelativeVelocity()
	
	
	velocity = addGravityToVelocity(velocity)
	
	if targetKinematicBody2D is KinematicBody2D:
		
		moveKinematicBody(velocity,delta)
			
	elif targetKinematicBody2D is StaticBody2D:
		targetKinematicBody2D.position = targetKinematicBody2D.position + delta*velocity 
	
	
	
	#emitt signals if we collide with walls
	#var emitWallCollisionFlag =true
	#checkForWallCollision(emitWallCollisionFlag)
	
	#same the realtive velocity so we don't have to recompute the relative velocity 
	#each frame if polling the relative velocity
	#cachedRelativeVelocity = velocity
	
func computeRelativeVelocity():
	
	var velocity = Vector2(0,0)
		
	velocity = velocity + computeActiveMovementRelativeVelocity()
	velocity = velocity + computeAdditionalStackRelativeVelocity()
		
	return velocity
	
func computeRelativeVelocityIgnoringHitfreeze():
	
	var velocity = Vector2(0,0)
		
	velocity = velocity + computeActiveMovementRelativeVelocityIgnoringHitFreeze()
	velocity = velocity + computeAdditionalStackRelativeVelocityIgnoringHitFreeze()
		
	return velocity
	

func computeActiveMovementRelativeVelocity():
	var velocity = Vector2(0,0)
	
	#iterate active movement
	for n in activeMvms:
		if n.is_physics_processing():
			velocity = velocity + n.getCurrentSpeed()
	
	#iterate over uninterruptible movement
	for bm in activeUninterruptableBMs.keys():
		if bm.is_physics_processing():
			velocity = velocity + bm.getCurrentSpeed()
	return velocity

func computeActiveMovementRelativeVelocityIgnoringHitFreeze():
	var velocity = Vector2(0,0)
	
	#iterate active movement
	for n in activeMvms:
		if n.isActive():
			velocity = velocity + n.getCurrentSpeed()
	
	#iterate over uninterruptible movement
	for bm in activeUninterruptableBMs.keys():
		if bm.isActive():
			velocity = velocity + bm.getCurrentSpeed()
				
	return velocity
	
func computeAdditionalStackRelativeVelocity():
	
	var velocity = Vector2(0,0)
	
	#iterate additional movement
	for arr in additionalMvmStack:
		for bm in arr:
			if bm.is_physics_processing():
				velocity = velocity + bm.getCurrentSpeed()
	return velocity

func computeAdditionalStackRelativeVelocityIgnoringHitFreeze():
	
	var velocity = Vector2(0,0)
	
	#iterate additional movement
	for arr in additionalMvmStack:
		for bm in arr:
			if bm.isActive():
				velocity = velocity + bm.getCurrentSpeed()
	return velocity
		
func getMovementNodes():
	return (get_tree().get_nodes_in_group(player_name+"_mvm_nodes"))
	
	
	
func handleCurrentAnimation(delta):
	
	
	#if((currentAnimation == null) or (currentCmplxMovements.size() == 0)):
	#if((getNumberOfActiveAnimations() == 0) or (currentCmplxMovements.size() == 0)):
	
	#if not hasActiveAnimations():
	#	return
	
	var gravEffect = null
	
	var sortedIndices = []
	
	#iterate over all the bins of complex movements to apply this frame
	#and determine which gravity effect to play
	#for mvmType in unprocessedComplexMvmMap.keys():
	for mvmType in mvmTypesAvailableThisFrame.keys():
		
		if not unprocessedComplexMvmMap.has(mvmType):
			print("internal design error in unprocessedComplexMvmMap in movement animation manager")
			continue
		var bin = unprocessedComplexMvmMap[mvmType]
		
		
		var complxMvmToApply = []
		#iterate over all complex movements of a type
		for cm in bin:
			
			var applyMovement = checkComplexMovementCondition(cm)
			
			#only consider complex movements that can be applied this frame
			if applyMovement:
				gravEffect = resolveGravEffectBasedOnPriority(gravEffect,cm.gravEffect)
				complxMvmToApply.append(cm)
		
		#now that we created list of complex movements to apply	, we store them in a list by priority
		if complxMvmToApply.size() > 0:
			
			var ix = mvmTypePriorityIXMap[mvmType]
			mvmTypePriorityIXTmpArray[ix]=complxMvmToApply
			sortedIndices.append(ix)
		
		#no longer need to hold onto complex mvms of this frame
		bin.clear()
	sortedIndices.sort()
	#now that we bunched all complex mvms together we will apply them in order of priority
	#for mvmType in mvmTypesAvailableThisFrame.keys():
	for ix in sortedIndices:
		
		var complxMvmToApply =mvmTypePriorityIXTmpArray[ix]
		var mvmType = complxMvmToApply[0].mvmType #all elemtns same type
		_applyComplexMovementType(mvmType,complxMvmToApply)
	mvmTypesAvailableThisFrame.clear()	

		
	if gravEffect!= null:	
		#apply the single final aggregated highest priority gravity effect
		applyComplexMovementGravity(gravEffect)
			


func resolveGravEffectBasedOnPriority(currGravType, candidateGravType):
	
	#	REPLAY,
#	REPLAY_AND_KEEP_FLOOR_COLLISION
#	REPLAY_IF_PLAYING,
#	KEEP_AND_REPLAY_IF_STOPPED,
#	KEEP,
#	STOP,
#	PLAY,
#	PAUSE,

	
#for gravity, replay out prioritizes everything, KEEP IS lowest priority
	#so e.g., if one complex mvm says KEEPP and one says REPLAY, we replay gravity
	#if one says STOP and other says REPLAY, we REPLAY
	#if one says STOP and one KEEP, we STOP
	#the types like Y_and_X_IF_STOPPED, has higher pIROTIY than STOP, and is treated as X if STOP played same frame
	
	if currGravType == null:
		return candidateGravType
	
	if not gravTypePriorityMap.has(currGravType):
		print("design error for gravity type priority resoultion")
		return currGravType
		
	var map = gravTypePriorityMap[currGravType]
	
	#is the candidate higher priority than currect type?
	if map.has(candidateGravType):
		
		var remappedElem = map[candidateGravType]
		
		#it is, now we check for special case that we remap the gravity type
		if remappedElem != null:
			return remappedElem# non-null value means value is the new grav effect to play
			
		else:
			return candidateGravType # null value means candidate has higher priority
	
	else:
		return currGravType
#returns true if our current movement conditions (air, ground, etc) meet the complex movement condition
func checkComplexMovementCondition(cm):
	
	#can't apply null complex movement
	if cm == null:
		return false

	var applyMovement=false	
	match(cm.applyCondition):
	
		#no condition?
		complxMvmResource.ConditionalMovement.NO_CONDITION:
			applyMovement=true
		complxMvmResource.ConditionalMovement.AIR_ONLY:
		
			#only apply movemnt if in air
			if playerController.my_is_on_floor():
				applyMovement=false
			else:
				applyMovement=true
							
		complxMvmResource.ConditionalMovement.GROUND_ONLY:
			#only apply movemnt if  on ground
			if playerController.my_is_on_floor():
				applyMovement=true
			else:
				applyMovement=false
				
		complxMvmResource.ConditionalMovement.AIR_AGAINST_WALL_ONLY:
			
			#only apply movemnt if in air and against wall
			if playerController.my_is_on_floor():
				applyMovement=false
			elif playerController.my_is_against_wall():		
				applyMovement=true
			else:
				applyMovement=false
							
		complxMvmResource.ConditionalMovement.GROUND_AGAINST_WALL_ONLY:
			#only apply movemnt if  on ground
			if not playerController.my_is_on_floor():
				applyMovement=false
			elif playerController.my_is_against_wall():
				applyMovement=true
			else:
				applyMovement=false
			
		complxMvmResource.ConditionalMovement.AIR_AND_NOT_AGAINST_WALL_ONLY:
			
			#only apply movemnt if in air and not against wall
			if not playerController.my_is_on_floor() and not playerController.my_is_against_wall():
				applyMovement=true
			else:
				applyMovement=false
							
		complxMvmResource.ConditionalMovement.GROUND_AND_NOT_AGAINST_WALL_ONLY:
			#only apply movemnt if on ground and not against wall
			if playerController.my_is_on_floor() and not playerController.my_is_against_wall():
				applyMovement=true
			else:
				applyMovement=false
	
		complxMvmResource.ConditionalMovement.AGAINST_CEILING_ONLY:
		
			#only apply movemnt if against ceiling
			if playerController.my_is_on_ceiling():
				applyMovement=true
			else:
				applyMovement=false
		complxMvmResource.ConditionalMovement.NOT_AGAINST_CEILING_ONLY:
		
			#only apply movemnt if not against ceiling
			if playerController.my_is_on_ceiling():
				applyMovement=false
			else:
				applyMovement=true		
		
		_:
			#this cased shouldn't happen with proper design
			print("forgot to update movement animation manager with new complex movement ConditionalMovement enmu")
			#this implies a bug, so by default the condition is not met for unknown conditions
			applyMovement=false		
		
	return applyMovement		
	
	
#apply a single complex movement
func applyComplexMovementType(cm):
	_applyComplexMovementType(cm.mvmType,[cm])
	
	
#applies a list of complex movement of same type in a batch
func _applyComplexMovementType(mvmType,cmList):
		
	var _basicMovements = []
	
	#clunk together basic movement lists of each complex movement all in one array
	#where elements are basic movements from among the compelx mvms
	for cm in cmList:
		for bm in cm.basicMovements:
			_basicMovements.append(bm)
			
	match(mvmType):
		#handle all types of movement
		complxMvmResource.MovementType.ADD:
			for cm in cmList:
				cm.startBasicMovements()
			
			if _basicMovements.size() > 0:
				additionalMvmStack.push_front(_basicMovements)
		
		complxMvmResource.MovementType.NEW:
			stopBasicMovements(activeMvms)
			activeMvms.clear()
			addActiveBasicMovements(_basicMovements)
			
			stopAllAdditionalMovement()
			for cm in cmList:
				cm.startBasicMovements()
			additionalMvmStack.clear()
		complxMvmResource.MovementType.UNINTERRUPTIBLE:
			addUninterruptibleBasicMovements(_basicMovements)
			for cm in cmList:
				cm.startBasicMovements()
		complxMvmResource.MovementType.POP:
			var lastAddedMovements = additionalMvmStack.pop_front()
			stopBasicMovements(lastAddedMovements)
		complxMvmResource.MovementType.POP_ALL:

			stopAllAdditionalMovement()
		
		complxMvmResource.MovementType.POP_ALL_KEEP_RELATIVE_GRAVITY_SPEED:
		
			keepRelativeGravity()
			stopAllAdditionalMovement()
		complxMvmResource.MovementType.FREEZE_AIR_MOMENTUM:
			
			#computes the instantaneous relative momentum to keep it
			#only doing so in the air. otherwise on ground, then it just removes the momentum complelty
			if not playerController.my_is_on_floor():
				
				#flag used to track when the relative gravity has 
				#been computed. Doing it twice in same movement aniamtion
				#will give burst of y speed via gravity not
				#well reflecting actual y momentum
				if not hasAlreadyComputedRelGravFlag:
					keepRelativeGravity()
				
				halthAnimationAndKeepArialMomentum()
				
			else:
				#otherwise, were on ground, so stop everything, and adde movement if 
				#the complaex movement defines it
				stopBasicMovements(activeMvms)
				activeMvms.clear()
				addActiveBasicMovements(_basicMovements)
				for cm in cmList:
					cm.startBasicMovements()
				stopAllAdditionalMovement()
				additionalMvmStack.clear()
				
				
		_:#BOUNCE MVM types
			
			#in this case we assume it's bounce movement.
			#and we will make strict assumption that only one bounce animation is processed per frame
			#so if more occur, it's first come first serve (this is how it was before, so it's not so bad)
			#this assumption is made as the bounce paramters are specified by a movement animation, 
			#not by a mvm type
			
			for cm in cmList:
				
				
				var parentMvmAnimation = cm.movementAnimation
				
				if parentMvmAnimation == null:
					print("interanl design erorr in mvm manager, cna't find parent aniamtion that created a comlex mvm")
					continue
				
				match(cm.mvmType):
					
					complxMvmResource.MovementType.WALL_BOUNCE_KEEP_RELATIVE_SPEED:
						#bounceBasicMvm.stop()
						#bounceOpposingGravBasicMvm.stop()
						#add the movement to active momvement so whe boucning calculations occur, the new mavomvent is added to relative velocity
						#so the bounce includes this  added velocity 
						
						
						cm.startBasicMovements()
						
						additionalMvmStack.push_front(cm.basicMovements)
						
						#new bounce, override olde bounce params	
						bounceBasicMvm.setupBouncing(parentMvmAnimation.maxBounces,parentMvmAnimation.bounceFriction,parentMvmAnimation.bounceMod)
						bounce_using_current_velocity(wallCollisionNormal,null,parentMvmAnimation)
					
						
			
					#_try_bounce(wallCollisionNormal,GLOBALS.COLLISION_TYPE_WALL)
					complxMvmResource.MovementType.WALL_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING:#TODO: THIS ISN'T WORKING ON SOMETHING LIKE TECH, 	
						#don't bounce if already bouncing (good for wall tech out of bouncable wall hitstun)
						if not bounceBasicMvm.isActive():
				
							
							cm.startBasicMovements()
							additionalMvmStack.push_front(cm.basicMovements)
							
							#new bounce, override olde bounce params	
							bounceBasicMvm.setupBouncing(parentMvmAnimation.maxBounces,parentMvmAnimation.bounceFriction,parentMvmAnimation.bounceMod)
							bounce_using_current_velocity(wallCollisionNormal,null,parentMvmAnimation)
							
						
					
					complxMvmResource.MovementType.WALL_BOUNCE_KEEP_RELATIVE_SPEED_WOG:
							
						#stop the current opposing grav and bouce
						resetBounceOpposingGravity()
						
						
						stopAllOpposingGravityBasicMovement()
						
						#TODO: manually disable all the current oposing gravs in addition stack and active mvmv
						
						cm.startBasicMovements()
						additionalMvmStack.push_front(cm.basicMovements)
						
						
						#new bounce, override olde bounce params	
						bounceBasicMvm.setupBouncing(parentMvmAnimation.maxBounces,parentMvmAnimation.bounceFriction,parentMvmAnimation.bounceMod)
						bounce_using_current_velocity(wallCollisionNormal,null,parentMvmAnimation)
						
				
						
					complxMvmResource.MovementType.WALL_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING_WOG:
						#don't bounce if already bouncing (good for wall tech out of bouncable wall hitstun)
						if not bounceBasicMvm.isActive():
							#stop the current opposing grav and bouce
							resetBounceOpposingGravity()
							
							stopAllOpposingGravityBasicMovement()
							
							#TODO: manually disable all the current oposing gravs in addition stack and active mvmv
							
							cm.startBasicMovements()
							additionalMvmStack.push_front(cm.basicMovements)
							
							#new bounce, override olde bounce params	
							bounceBasicMvm.setupBouncing(parentMvmAnimation.maxBounces,parentMvmAnimation.bounceFriction,parentMvmAnimation.bounceMod)
							bounce_using_current_velocity(wallCollisionNormal,null,parentMvmAnimation)
							
					
						
						
				
					complxMvmResource.MovementType.CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED:#TODO: THIS ISN'T WORKING ON SOMETHING LIKE TECH, 
						#bounceBasicMvm.stop()
						#bounceOpposingGravBasicMvm.stop()
						#add the movement to active momvement so whe boucning calculations occur, the new mavomvent is added to relative velocity
						#so the bounce includes this  added velocity 
						
						cm.startBasicMovements()
						additionalMvmStack.push_front(cm.basicMovements)
						#new bounce, override olde bounce params	
						bounceBasicMvm.setupBouncing(parentMvmAnimation.maxBounces,parentMvmAnimation.bounceFriction,parentMvmAnimation.bounceMod)
						bounce_using_current_velocity(floorCollisionNormal,null,parentMvmAnimation)
						
				
					
			
					#_try_bounce(wallCollisionNormal,GLOBALS.COLLISION_TYPE_WALL)
					complxMvmResource.MovementType.CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING:#TODO: THIS ISN'T WORKING ON SOMETHING LIKE TECH, 	
						#don't bounce if already bouncing (good for wall tech out of bouncable wall hitstun)
						if not bounceBasicMvm.isActive():
							
							cm.startBasicMovements()
							additionalMvmStack.push_front(cm.basicMovements)
							
							#new bounce, override olde bounce params	
							bounceBasicMvm.setupBouncing(parentMvmAnimation.maxBounces,parentMvmAnimation.bounceFriction,parentMvmAnimation.bounceMod)
							bounce_using_current_velocity(floorCollisionNormal,null,parentMvmAnimation)
							
							
							
					
					complxMvmResource.MovementType.CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED_WOG:
							
						#stop the current opposing grav and bouce
						resetBounceOpposingGravity()
						
						stopAllOpposingGravityBasicMovement()
						
						
						cm.startBasicMovements()
						additionalMvmStack.push_front(cm.basicMovements)
						
						#new bounce, override olde bounce params	
						bounceBasicMvm.setupBouncing(parentMvmAnimation.maxBounces,parentMvmAnimation.bounceFriction,parentMvmAnimation.bounceMod)
						
						
						bounce_using_current_velocity(floorCollisionNormal,null,parentMvmAnimation)
					
			
					
					
						
					complxMvmResource.MovementType.CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING_WOG:
						#don't bounce if already bouncing (good for wall tech out of bouncable wall hitstun)
						if not bounceBasicMvm.isActive():
							#stop the current opposing grav and bouce
							resetBounceOpposingGravity()
							
							stopAllOpposingGravityBasicMovement()
							
							#TODO: manually disable all the current oposing gravs in addition stack and active mvmv
							
							cm.startBasicMovements()
							additionalMvmStack.push_front(cm.basicMovements)
							
							
							#new bounce, override olde bounce params	
							bounceBasicMvm.setupBouncing(parentMvmAnimation.maxBounces,parentMvmAnimation.bounceFriction,parentMvmAnimation.bounceMod)
							bounce_using_current_velocity(floorCollisionNormal,null,parentMvmAnimation)
							
							
					complxMvmResource.MovementType.ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED:#TODO: THIS ISN'T WORKING ON SOMETHING LIKE TECH, 
						#bounceBasicMvm.stop()
						#bounceOpposingGravBasicMvm.stop()
						#add the movement to active momvement so whe boucning calculations occur, the new mavomvent is added to relative velocity
						#so the bounce includes this  added velocity 
						
						#TODO: manually disable all the current oposing gravs in addition stack and active mvmv
				
						
						cm.startBasicMovements()
						additionalMvmStack.push_front(cm.basicMovements)
				
				
							
						#new bounce, override olde bounce params	
						bounceBasicMvm.setupBouncing(parentMvmAnimation.maxBounces,parentMvmAnimation.bounceFriction,parentMvmAnimation.bounceMod)
						bounce_using_current_velocity(cm.bounceNormal.normalized(),null,parentMvmAnimation)
						
								
			
					#_try_bounce(wallCollisionNormal,GLOBALS.COLLISION_TYPE_WALL)
					complxMvmResource.MovementType.ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING:#TODO: THIS ISN'T WORKING ON SOMETHING LIKE TECH, 	
						#don't bounce if already bouncing (good for wall tech out of bouncable wall hitstun)
						if not bounceBasicMvm.isActive():
							
							
							cm.startBasicMovements()
							additionalMvmStack.push_front(cm.basicMovements)
							
							#new bounce, override olde bounce params	
							bounceBasicMvm.setupBouncing(parentMvmAnimation.maxBounces,parentMvmAnimation.bounceFriction,parentMvmAnimation.bounceMod)
							bounce_using_current_velocity(cm.bounceNormal,null,parentMvmAnimation)
						
							
					
					complxMvmResource.MovementType.ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED_WOG:
							
						#stop the current opposing grav and bouce
						resetBounceOpposingGravity()
						
						#TODO: manually disable all the current oposing gravs in addition stack and active mvmv
						stopAllOpposingGravityBasicMovement()
						
						
						cm.startBasicMovements()
						additionalMvmStack.push_front(cm.basicMovements)
						
						#new bounce, override olde bounce params	
						bounceBasicMvm.setupBouncing(parentMvmAnimation.maxBounces,parentMvmAnimation.bounceFriction,parentMvmAnimation.bounceMod)
						bounce_using_current_velocity(cm.bounceNormal.normalized(),null,parentMvmAnimation)
						
						
					
					complxMvmResource.MovementType.ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING_WOG:
						#don't bounce if already bouncing (good for wall tech out of bouncable wall hitstun)
						if not bounceBasicMvm.isActive():
							#stop the current opposing grav and bouce
							resetBounceOpposingGravity()
							
							stopAllOpposingGravityBasicMovement()
							
							
							#TODO: manually disable all the current oposing gravs in addition stack and active mvmv
							
							cm.startBasicMovements()
							additionalMvmStack.push_front(cm.basicMovements)
							
							#new bounce, override olde bounce params	
							bounceBasicMvm.setupBouncing(parentMvmAnimation.maxBounces,parentMvmAnimation.bounceFriction,parentMvmAnimation.bounceMod)
							bounce_using_current_velocity(cm.bounceNormal.normalized(),null,parentMvmAnimation)
						
					_:
						print("unknown mvement type: "+str(mvmType))
						pass	
					
				
func keepRelativeGravity():
	

	#any previous y speed that's about to be popped is migrrated to gravity
	#so seemingless pop-all, only x affected
	var additionalVelocity = computeAdditionalStackRelativeVelocity()
	var gravitySpeed = gravity.getCurrentSpeed()
	
	var relativeYSpeed = gravitySpeed.y + additionalVelocity.y #gravity postive negative y while speed vertically up is negative
	
	gravity.ySpeed = relativeYSpeed/self.globalSpeedMod
	#gravity.ySpeed = relativeYSpeed
	
	hasAlreadyComputedRelGravFlag = true


func stopAllAdditionalMovement():
	var lastAddedMovements = null
	while(additionalMvmStack.size() > 0):
		lastAddedMovements = additionalMvmStack.pop_front()
		stopBasicMovements(lastAddedMovements)

func haltMovement():
	stopBasicMovements(activeMvms)
	activeMvms.clear()
	stopAllAdditionalMovement()
	additionalMvmStack.clear()
	
func applyComplexMovementGravity(gravEffectType):
	
	#keep a note of last effect we applied to gravity
	lastGravityEffect = gravEffectType
	#complexMvmRef = cm #just save complex movement to access enumerations
	
	
	match(gravEffectType):
	#handle all types of movement gravityes
		complxMvmResource.GravityEffect.PAUSE:
		
			gravity.set_physics_process(false)
			return
		complxMvmResource.GravityEffect.PLAY:
			#reset the keeping relative gravity flag. This allows relative gravity to be
			#computed once again
			hasAlreadyComputedRelGravFlag = false
			
			gravity.set_physics_process(true)
			gravity.acceleration = GRAVITY_ACCELERATION #reset acceleration
			return
	
		complxMvmResource.GravityEffect.STOP:
			stopGravity()
			
			return
		complxMvmResource.GravityEffect.KEEP:
				#DO nothing
				return
		complxMvmResource.GravityEffect.REPLAY:
			replayGravity()
			return
		complxMvmResource.GravityEffect.REPLAY_AND_KEEP_FLOOR_COLLISION:
		
			#reset the keeping relative gravity flag. This allows relative gravity to be
			#computed once again
			hasAlreadyComputedRelGravFlag = false
			
			gravity.set_physics_process(true)	
			#6 WAS FOUND via trial erro, 1 and 2, make constant break in collisions when on floor
			#gravity.ySpeed = 20
			gravity.ySpeed = GRAVITY_REPLAY_Y_SPEED
			gravity.acceleration = 0 #want the acceleration to stay 0, so when drop of ground/platform, there is no odd gravity effect
			# gravity shouldn't affect people horizontally, but just to be safe
			gravity.xSpeed = 0
			return
		complxMvmResource.GravityEffect.KEEP_AND_REPLAY_IF_STOPPED:
			
			#consider "stopped" as acceleration is not maxed
			if gravity.acceleration  != GRAVITY_ACCELERATION:
				gravity.acceleration = GRAVITY_ACCELERATION #reset acceleration 
				
			#keepAndReplayGravityIfStopped()
			if(gravity.is_physics_processing()):
				return
			else:
				
				#reset the keeping relative gravity flag. This allows relative gravity to be
				#computed once again
				hasAlreadyComputedRelGravFlag = false
				gravity.set_physics_process(true)
				
				#gravity.ySpeed = 0
				gravity.ySpeed = GRAVITY_REPLAY_Y_SPEED
				# gravity shouldn't affect people horizontally, but just to be safe
				gravity.xSpeed = 0
			return
		complxMvmResource.GravityEffect.REPLAY_IF_PLAYING:
			#keepAndReplayGravityIfStopped()
			if(gravity.is_physics_processing()):
				replayGravity()
				#reset the keeping relative gravity flag. This allows relative gravity to be
				#computed once again
				#hasAlreadyComputedRelGravFlag = false
			
				#replay since gravity playing
				#gravity.ySpeed = 0
				#gravity.ySpeed = GRAVITY_REPLAY_Y_SPEED
				#gravity.acceleration = GRAVITY_ACCELERATION #reset acceleration
				# gravity shouldn't affect people horizontally, but just to be safe
				#gravity.xSpeed = 0
				
			else:
				#gravity is stopped, don't restart it
				return
				
		_:
			print("unknown gravity type: "+str(gravEffectType))
			return
				
func stopGravity():
	#reset the keeping relative gravity flag. This allows relative gravity to be
	#computed once again
	hasAlreadyComputedRelGravFlag = false
	
	gravity.acceleration = GRAVITY_ACCELERATION #reset acceleration
	gravity.set_physics_process(false)	
	gravity.ySpeed = 0
	# gravity shouldn't affect people horizontally, but just to be safe
	gravity.xSpeed = 0 
func replayGravity():
	#reset the keeping relative gravity flag. This allows relative gravity to be
		#computed once again
		hasAlreadyComputedRelGravFlag = false
		
		gravity.set_physics_process(true)	
		#gravity.ySpeed = 0
		gravity.ySpeed = GRAVITY_REPLAY_Y_SPEED
		gravity.acceleration = GRAVITY_ACCELERATION #reset acceleration
		# gravity shouldn't affect people horizontally, but just to be safe
		gravity.xSpeed = 0
func checkForWallCollision(emitWallCollisionFlag):
	
	var potentialWallCollisionFlag = false
	var playerCollidedWith = null
	#for colliderIx in targetKinematicBody2D.get_slide_count():
		#var collision = targetKinematicBody2D.get_slide_collision(colliderIx)
	for collider in colliders:
		if collider is KinematicBody2D :
			#playerCollidedWith = collision.collider
			playerCollidedWith = collider
		else:
			potentialWallCollisionFlag = true
	#we hit something 
	if potentialWallCollisionFlag:
		#we didn't bump into opponent?
		if playerCollidedWith == null:
			#if self.targetKinematicBody2D.is_on_wall():
			if on_wall:
				
				if emitWallCollisionFlag:
					emit_signal("wall_collision")
			
			#if self.targetKinematicBody2D.is_on_ceiling():		
			if on_ceiling:
				#may want to consider using another flag/parameter, but for now should be
				#fine to emit ceiling and wall collision equally
				if emitWallCollisionFlag:
					emit_signal("ceiling_collision")
				
	return playerCollidedWith	

#returns null when no collision exist, otherwise KinematicCollision2D of player
func getKinematicBodyCollision():
	var emitWallCollisionFlag =true
	return checkForWallCollision(emitWallCollisionFlag)
		


func keepAndReplayGravityIfStopped():
	lastGravityEffect=complxMvmResource.GravityEffect.KEEP_AND_REPLAY_IF_STOPPED
	applyComplexMovementGravity(complxMvmResource.GravityEffect.KEEP_AND_REPLAY_IF_STOPPED)

func addActiveBasicMovements(basicMovements):
	if basicMovements == null:
		return
	
	for b in basicMovements:
		activeMvms.push_front(b)
	
#func startBasicMovements(basicMovements):
#	if basicMovements == null:
#		return
		#iterate all basic movment
#	for bm in basicMovements:
#		bm.init()
#		started = true
		
func stopBasicMovements(basicMovements):
	if basicMovements == null:
		return
	#iterate all basic movment
	for bm in basicMovements:
		bm.stop()
		

func halthAnimationAndKeepArialMomentum():
	pauseMovementEllapsingTimer()
	
	#make sure no new complex movements will come and affet
	#indefinite movement
	#currentCmplxMovements.clear()
	stopAllAnimations()
	
	
	keepAndReplayGravityIfStopped()
	
	for bmSets in  additionalMvmStack:
		for bm in bmSets:
			bm.freezeMomentum()

	#dump all the base-active movement into additive, since don't want to be able
	#to spring back and forth in air at high speeds using air movement (air movement with stop it)
	#deep copy of activeMVvm array
	var tmpMomentum = []
	for bm in activeMvms:
		tmpMomentum.push_front(bm)
		bm.freezeMomentum()
	
	additionalMvmStack.push_front(tmpMomentum)
	
	activeMvms.clear()
	

	#make sure we keep the relative 

	#iterate all additional movement
#	for bmSets in  additionalMvmStack:
#		for bm in bmSets:
#			activeMvms.push_front(bm)
	
	
#	additionalMvmStack.clear()
	
#will make all the movement currently playing remain indefinetly	
func pauseMovementEllapsingTimer():
	
	#iterate all sets of additional basic movement
	for basicMvmSet in additionalMvmStack:
		#now iterate all basic mvm and pause their timers
		for bm in basicMvmSet:
			bm.timerPauseFlag=true
			
	#do the same for active movements
	for bm in activeMvms:
		bm.timerPauseFlag=true
	
	for bm in activeUninterruptableBMs.keys():
		bm.timerPauseFlag=true
		
#will resume timer of all movement so they can now ellapse again
func unpauseMovementEllapsingTimer():
	
	#iterate all sets of additional basic movement
	for basicMvmSet in additionalMvmStack:
		#now iterate all basic mvm and pause their timers
		for bm in basicMvmSet:
			bm.timerPauseFlag=false
			
	#do the same for active movements
	for bm in activeMvms:
		bm.timerPauseFlag=false
	
	for bm in activeUninterruptableBMs.keys():
		bm.timerPauseFlag=false	
func stopAllMovement():
	for bm in activeMvms:
		bm.set_physics_process(false)
	for bmArr in additionalMvmStack:
		for bm in bmArr:
			bm.set_physics_process(false)
			
	gravity.set_physics_process(false)	
	
	stopAllAnimations()
	
func resetGravity():
	lastGravityEffect=complxMvmResource.GravityEffect.REPLAY
	applyComplexMovementGravity(complxMvmResource.GravityEffect.REPLAY)
	
	
func moveKinematicBody(velocity,delta):
	
	
		var stop_on_slope=false
		var max_slides=4
		var floor_max_angle=0
		var infinite_inertia=true
		#only slide against stuff if current srpite animation can't bounce
		#this is the default behavior of most things. Players will "walk" accross ground by
		#sliding as gravity pushes them into ground
		#targetKinematicBody2D.move_and_slide(velocity,floor_normal,stop_on_slope,max_slides,floor_max_angle,infinite_inertia)
		
		my_move_and_slide(targetKinematicBody2D,velocity,floor_normal,stop_on_slope,max_slides,floor_max_angle,infinite_inertia)
		emit_signal("moved_kinematic_body",self)
		
		#check if we were moving upward or horizontally, and now are falling
		if lastRelativeVelocity.y<=0 and velocity.y >0:
			emit_signal("reached_vertical_momentum_apex")
		lastRelativeVelocity=velocity
		lastRelativeVelocityExcGrav= removeGravityFromVelocity(lastRelativeVelocity)


func bounce_using_current_velocity(collisionNormal,colliderType, bounceableMvmAnime):			

	#GET objets's relative velocity
	var velocity = computeActiveMovementRelativeVelocityIgnoringHitFreeze()
	
	
	velocity = addGravityToVelocityIgnoringHitFreeze(velocity)
		

	#bounce off the angle given by where hit opponnet
	velocity = velocity.bounce(collisionNormal)
	
	#_bounce_ball_specifying_velocity(velocity)
	_bounce(velocity,colliderType,bounceableMvmAnime)

#tries to bounce, if the last animation played wasbouncable. returns true if bounced and false otherwise
#func attemptBounce(velocity,colliderType):
#	if lastBouncableMvmPlayed != null:
#		_bounce(velocity,colliderType,lastBouncableMvmPlayed)
#		return true
#	else:
#		return false	
	
#forces movement into a bounce
#bounceMvmAnimation used for bounce information
func _bounce(velocity,colliderType,bounceableMvmAnime):
	
	#var maxBounces = bounceMvmAnimation.maxBounces
	#var bounceFriction = bounceMvmAnimation.bounceFriction
	#var bounceMod = bounceMvmAnimation.bounceMod
#	var maxBounces = currentAnimation.maxBounces
#	var bounceFriction = currentAnimation.bounceFriction
#	var bounceMod = currentAnimation.bounceMod
	
	#lastBouncableMvmPlayed = bounceMvmAnimation
	#starting the bounce?
	if not bounceBasicMvm.isActive():
		
		#search for all basic movement opposing gravity to make mvoemtn more floaty
		#and aggreagte the speeds to make total relative gravity opposition movement
		
		var hasOpposingGravityBM = false
		#var totalYSpeed = 0
		var totalYAcceleration=0
		#var maxOfMaximumsYSpeed=-1
		for bm in activeMvms:
			
			if bm.opposingGravity and bm.isActive():
				hasOpposingGravityBM=true
				#totalYSpeed = bm.ySpeed + totalYSpeed
				totalYAcceleration = bm.acceleration + totalYAcceleration#assumes opposing gravity has angle 270, so acceleration is y acceleration
				#maxOfMaximumsYSpeed = max(bm.maxSpeed,maxOfMaximumsYSpeed)
		for bm in activeUninterruptableBMs.keys():
			if bm.opposingGravity and bm.isActive():
				hasOpposingGravityBM=true
				#totalYSpeed = bm.ySpeed + totalYSpeed
				totalYAcceleration = bm.acceleration + totalYAcceleration#assumes opposing gravity has angle 270, so acceleration is y acceleration
				#maxOfMaximumsYSpeed = max(bm.maxSpeed,maxOfMaximumsYSpeed)
		for bmArr in additionalMvmStack:
			for bm in bmArr:
				if bm.opposingGravity and bm.isActive():
					hasOpposingGravityBM=true
				#	totalYSpeed = bm.ySpeed + totalYSpeed
					totalYAcceleration = bm.acceleration + totalYAcceleration#assumes opposing gravity has angle 270, so acceleration is y acceleration
				#	maxOfMaximumsYSpeed = max(bm.maxSpeed,maxOfMaximumsYSpeed)
			
		#stop all movement
		stopBasicMovements(activeMvms)
		activeMvms.clear()
		
		stopAllAdditionalMovement()
		additionalMvmStack.clear()
		
		
		#make sure we setupt the bouncing AFTER we stopped all movement, since
		#the bounce make have been part of active mvmv, just inactive
		#bounce params only setup at start of bounce. So can only change them by having
		#the bounce stop and restarted
		bounceBasicMvm.setupBouncing(bounceableMvmAnime.maxBounces,bounceableMvmAnime.bounceFriction,bounceableMvmAnime.bounceMod)
	
		
		#is there opposing gravity for floaty ness?
		#also only initialize the gravity oppoosition
		if hasOpposingGravityBM:
			#copy the relative gravity opposition to bouncing grav opposition basic movement
			bounceOpposingGravBasicMvm.speed =0 #always start at 0 speed
			bounceOpposingGravBasicMvm.acceleration =totalYAcceleration
			#bounceOpposingGravBasicMvm.maxSpeed =maxOfMaximumsYSpeed
			bounceOpposingGravBasicMvm.angle = 270 #always 270 cause opposing gravity (upward acceleration nulifies some of grav's accel)
			activeMvms.push_front(bounceOpposingGravBasicMvm)
			
		else:
			resetBounceOpposingGravity()
			
			
			
		
		
		#starting the bounce for first time
		activeMvms.push_front(bounceBasicMvm)
		
		
	#end start bouncing
	
	#restart opposing gravity
	bounceOpposingGravBasicMvm.init()
	
	#restart gravity
	replayGravity()
	
	var isOnFloor = false
	if colliderType == GLOBALS.COLLISION_TYPE_FLOOR:
		isOnFloor=true
	#start the bouncing basic movemen
	bounceBasicMvm._on_bounce(velocity.x,velocity.y,isOnFloor)
	
	
func _on_bounced():
	
	pass
func _on_stopped_bouncing(rc):
	
	#can't bounce twice in same aniamtion
	if rc == GLOBALS.BOUNCE_RC_MAX_BOUNCES_EXCEEDED or rc == GLOBALS.BOUNCE_RC_MOMENTUM_CAME_TO_HALT:
		bounceLock = true
	else:
		#some other animation STOPPED it, which means there isn't any chance of restarting to the bounce
		#sequence in same animation, don't lock
		pass
	resetBounceOpposingGravity()

func _on_started_bouncing():
	
	pass
	
#stop all movement just looks like it pauses it, so making new function just incase
func deactivateAllMovement(keepFloorCollision=false):
	#stop all movement
	stopBasicMovements(activeMvms)
	activeMvms.clear()
	stopAllAdditionalMovement()
	additionalMvmStack.clear()

	bounceBasicMvm.stop()
	bounceOpposingGravBasicMvm.stop()
	lastGravityEffect = null
	
	lastRelativeVelocity = Vector2(0,0)
	lastRelativeVelocityExcGrav = Vector2(0,0)
	
	priorityOfAnimeHoldingLock = null
	
	stopBasicMovements(activeUninterruptableBMs)
	
	stopAllAnimations()
	
	#stop gravity
	#computed once again
	
	gravity.acceleration = GRAVITY_ACCELERATION #reset acceleration
	
	
	if keepFloorCollision:
		gravity.ySpeed = MINIMUM_Y_VELOCITY_TO_KEEP_FLOOR_COLLISION
		gravity.set_physics_process(true)	
	else:
		gravity.ySpeed = 0
		gravity.set_physics_process(false)
	# gravity shouldn't affect people horizontally, but just to be safe
	gravity.xSpeed = 0 
		
		
func _on_hit_wall(collider):
	
	_try_bounce(wallCollisionNormal,GLOBALS.COLLISION_TYPE_WALL)
	

func _on_hit_floor():
	
	_try_bounce(floorCollisionNormal,GLOBALS.COLLISION_TYPE_FLOOR)
	
	pass	

func _on_hit_ceiling(collider):
	
	
	_try_bounce(ceilingCollisionNormal,GLOBALS.COLLISION_TYPE_CEILING)

func _on_hit_platform():
	
	_try_bounce(floorCollisionNormal,GLOBALS.COLLISION_TYPE_PLATFORM)
		

#will bounce the player at current relative velocity only if the last bouncable animation
#played supports the type of bounce
func _try_bounce(collisionNormal,collisionType):
	
	
	#typical case where basic bounce aniamton will occur, nothing that overrides bounce
	if specialBounceMvmAnimations == null:
		
		
		var attemptProcessBounceFlag = false
		#animation exists and can bounce off environment?
		#if currentAnimation != null and currentAnimation.bouncable:
		
		#we stritcly assume here that no too bouncing animations will be running at same time
		var bouncableAnime = findFirstBouncableActiveAnimation()
		if bouncableAnime != null:
			attemptProcessBounceFlag = true
		
		
		#maybe a new animation played, but if it didn't override bouncing, then keep bouncing
		elif bounceBasicMvm.isActive():
			attemptProcessBounceFlag=true
		else:
			attemptProcessBounceFlag=false
		
			
		#can attempt to bounce, were not locked out of bounce, and current sprite frame suports bouncing?
		if attemptProcessBounceFlag and not bounceLock and not playerController.canCurrentSpriteFramePreventBounce():
			#can the bouncing movementanimation bounce off this?
			#double check the null instance, since I think double wall signaling and animation changes can do race condition?
			#at leeast I got a null pointer on currentAnimtion, so that wy i check
			#if currentAnimation != null and currentAnimation.canBounceOff(collisionType):
			if bouncableAnime != null and bouncableAnime.canBounceOff(collisionType):

				bounce_using_current_velocity(collisionNormal,collisionType,bouncableAnime)


	else:
		
		if specialBounceMvmAnimations.isSpecialBounceAnimationAvailable(collisionType):
			
			specialBounceMvmAnimations.incrementBounceCount(collisionType)
			#here we make the assumption that if a special bounce is defined (which is only during histun)
			#then bouncing WILL occur
			var specialMvmAnimation = specialBounceMvmAnimations.getSpecialBounceAnimation(collisionType)
			#playMovementAnimation(specialMvmAnimation,playerController.kinbody.facingRight)					
			
			
			#play movement with direction based on where facing initially that created the knockback
			#that triggered the bounce
			playMovementAnimation(specialMvmAnimation,specialBounceMvmAnimations.facingRightHitMovementPlayed)
			
func resetBounceOpposingGravity():
	bounceOpposingGravBasicMvm.speed =0 #always start at 0 speed
	bounceOpposingGravBasicMvm.acceleration =0
	bounceOpposingGravBasicMvm.angle = 270 #always 270 cause opposing gravity (upward acceleration nulifies some of grav's accel)
	bounceOpposingGravBasicMvm.stop()
	
func stopAllOpposingGravityBasicMovement():
	
	for bm in activeMvms:
		if bm.opposingGravity and bm.isActive():
			bm.stop()
	for bmArr in additionalMvmStack:
		for bm in bmArr:
			if bm.opposingGravity and bm.isActive():
				bm.stop()
				
#returns true if falling, and false if rising,
#note that hit freeze is ingored in this check
func hasReachedVerticalMomentumApex():
	
	
	var velocity = computeRelativeVelocityIgnoringHitfreeze()
	
	
	velocity = addGravityToVelocity(velocity)
	
	return velocity.y >0
	
func addUninterruptibleBasicMovements(basicMvms):
	
	for bm in basicMvms:
		#add the basic movement to uninterruptible list (if add basimc movement twice, it doesn't duplicate mvm effect, movement just restarts)
		activeUninterruptableBMs[bm] = null #null since just use keys for lookup and iterations
		
func _on_uninterruptible_bm_stopped(bm,cm):
	
	if bm != null:
		if not activeUninterruptableBMs.erase(bm):
			print("problem remvoing uninterruptible basic movement")
	
	
	#copmlex movement finished?
	if not cm.isActive():
		
		#disconnect from it
		cm.disconnect("uninterruptible_bm_stopped",self,"_on_uninterruptible_bm_stopped")
	else:
		pass#stil some uninterruptible basimc movements to play
func stopUninterruptibleMovement():
	for bm in activeUninterruptableBMs.keys():
		bm.stop()
	
	activeUninterruptableBMs.clear()
	

	
	

#returns true when the given movement animation is active
#and false when inactive	
func isAnimationActive(animeId):
	if animeId == null:
		return false
	
	#look trhough all activ emovement animations and search 
	#see if given id is among the ids of those active
	for anime in 	activeAnimationMap.keys():
		if anime.id == animeId:
			return true
			
			
	return false
		


#returns true when the given movement animation is active
#and false when inactive	
func _isAnimationActive(anime):
	if anime == null:
		return false
	return activeAnimationMap.has(anime)
	
#store the animation to indicate it's active
func storeActiveAnimation(anime):
	if anime == null:
		return
	activeAnimationMap[anime]=null

#erase the animation to indicate it's inactive
func eraseActiveAnimation(anime):
	if not _isAnimationActive(anime):
		return
	activeAnimationMap.erase(anime)
	
func getNumberOfActiveAnimations():
	return activeAnimationMap.keys().size()
	
func hasActiveAnimations():
	var numActiveAnimations=getNumberOfActiveAnimations()
	
	return numActiveAnimations> 0

func findFirstBouncableActiveAnimation():
	
	var bouncableAnimation = null
	
	for anime in activeAnimationMap.keys():
		if anime.bouncable:
			bouncableAnimation=anime
			break
	return bouncableAnimation

#stops all overridable animations of lower  or equal priority
func stopOverridableAnimations(priority):
	var onlyStopOverridable = true
	_stopAnimations(onlyStopOverridable,priority)
func stopAllAnimations():
	var onlyStopOverridable = false
	#use highest priorioty. it illustrates point we stop all mvms as nothing can have higher priority than that
	_stopAnimations(onlyStopOverridable,GLOBALS.MVM_ANIMATION_HIGHEST_PRIORITY+1)	
	clearUnprocessedCmplxMvms(GLOBALS.MVM_ANIMATION_HIGHEST_PRIORITY+1)
	
func _stopAnimations(onlyStopOverridable,priority):
	
	var animationsToStop = []
	#stop all overridable aniamtions
	for mvmAnime in activeAnimationMap.keys():
			
			
		#only stopping overridable animation?
		if onlyStopOverridable:
			#can be stopped by a new animation?
			if mvmAnime.overridable:
				
				#only stop aniamtions of <= priroity
				if mvmAnime.priority <=priority:
					#add to list of animations to remove (can't alter the dictionary while iterating over it)
					animationsToStop.append(mvmAnime)
		else:#stopping everything	
			#add to list of animations to remove (can't alter the dictionary while iterating over it)
			animationsToStop.append(mvmAnime)
			
	for anime in animationsToStop:
		anime.stop()
		eraseActiveAnimation(anime)	
	
#clear all unprocessed complex mvms from animations of lower priority
func clearUnprocessedCmplxMvms(priority):
	
	
	
	for mvmType in unprocessedComplexMvmMap.keys():
	
		var bin = unprocessedComplexMvmMap[mvmType]
		#clear everything when higest proiroty given
		if priority >= GLOBALS.MVM_ANIMATION_HIGHEST_PRIORITY:
			
			bin.clear()
			
		else:
			
			#only processed bins with compex movements in them
			if bin.size() > 0:
				#must choose only complx mvm of animations of lower priroity to remove
				var complxMvmsToRemove = []
				for cm in bin:
					
					#lower priority?
					if cm.movementAnimation.priority <= priority:
						complxMvmsToRemove.append(cm)
				#now that were done iterating the bin, remove complx that are of lower prirority
				for cm in complxMvmsToRemove:
					bin.erase(cm)
					
				#we removed everything in bin?
				if bin.size() ==0:
					#indicate no more complex mvms of this type
					mvmTypesAvailableThisFrame.erase(mvmType)
				
	if priority >= GLOBALS.MVM_ANIMATION_HIGHEST_PRIORITY:	
		
		mvmTypesAvailableThisFrame.clear()
	else:
		#we already dynamically checked and removed types with no more complex movements, do nothing
		pass
	
	
func _on_movement_animation_finished(mvmAnime):
	eraseActiveAnimation(mvmAnime)
func _on_finished_processing_all_complex_mvm(mvmAnime):
	pass
	
func _on_complex_mvm_activated(complexMvm,mvmAnime):
	
	#uniterruptible complex movement?
	if complexMvm != null and complexMvm.isUninturruptible():
		if not complexMvm.is_connected("uninterruptible_bm_stopped",self,"_on_uninterruptible_bm_stopped"):
			complexMvm.connect("uninterruptible_bm_stopped",self,"_on_uninterruptible_bm_stopped",[complexMvm])
	
	#entries stored in here to know what mvm type is to be applied this frame (avoid iterating over all the mvm types for keys)
	mvmTypesAvailableThisFrame[complexMvm.mvmType]=null
	
	#put compelx mvm in appropriate bin
	var bin = unprocessedComplexMvmMap[complexMvm.mvmType]
	bin.append(complexMvm)


func my_move_and_slide(kinematicBody2d,p_linear_velocity, p_floor_direction=Vector2( 0, 0 ), stop_on_slope=false, p_max_slides=4, p_floor_max_angle=0.785398, infinite_inertia=true):
	
#Vector2 KinematicBody2D::move_and_slide(const Vector2 &p_linear_velocity, const Vector2 &p_floor_direction, float p_slope_stop_min_velocity, int p_max_slides, float p_floor_max_angle) {
	#var floor_velocity = kinematicBody2d.get_floor_velocity()
	var p_slope_stop_min_velocity =1
	var motion = (floor_velocity+p_linear_velocity) * GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	var lv = p_linear_velocity

	var old_on_floor=on_floor
	var old_on_ceiling=on_ceiling
	var old_on_wall=on_wall
	

	floor_velocity = Vector2(0,0)

	while p_max_slides:

		var collision=false

		var collided = kinematicBody2d.move_and_collide(motion, collision)
		
		if collided:
			
			motion = collided.remainder

			if p_floor_direction == Vector2(0,0):
				#all is a wall
				#on_wall = true
				on_wall = true
			else:
				if collided.normal.dot(p_floor_direction) >= cos(p_floor_max_angle): #floor

					on_floor = true
					floor_velocity = collided.collider_velocity

					var rel_v = lv - floor_velocity
					var hv = rel_v - p_floor_direction * p_floor_direction.dot(rel_v)

					#if collided.travel.length() < 1 and (hv.length() < p_slope_stop_min_velocity):
						#var gt = kinematicBody2d.get_global_transform();
						#gt.elements[2] -= collided.travel; # this break
						#gt.y -= collided.travel; # this break
						#kinematicBody2d.set_global_transform(gt);
						#kinematicBody2d.set_global_transform(gt);
					#	return Vector2(0,0)
						
					
				elif collided.normal.dot(-p_floor_direction) >= cos(p_floor_max_angle): #ceiling
					on_ceiling = true
				else:
					on_wall = true
				
			#end p_floor_direction == Vector2(0,0))

			var n = collided.normal
			motion = motion.slide(n)
			lv = lv.slide(n)

			colliders.push_back(collided.collider)

		else:#else didn't collide
			break
		

		p_max_slides=  p_max_slides -1
		if motion == Vector2(0,0):
			break
	#end while max slide

	if old_on_floor != on_floor:
		pass
	if old_on_wall != on_wall:
		pass
	if old_on_ceiling != on_ceiling:
		pass
	return lv
	
func clearMvmCollisions():
	on_floor = false
	on_ceiling = false
	on_wall = false #consider signaling when these change from olde values (if on floor was false and then below is true, means floor collision)
	colliders.clear()
	
func _on_moved_kinematic_body(_mvmAnimationManager):
	pass