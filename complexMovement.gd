extends Node

signal uninterruptible_bm_stopped

enum MovementType{
	ADD,
	NEW,
	POP,
	POP_ALL,
	POP_ALL_KEEP_RELATIVE_GRAVITY_SPEED,
	FREEZE_AIR_MOMENTUM,
	WALL_BOUNCE_KEEP_RELATIVE_SPEED,
	WALL_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING,
	WALL_BOUNCE_KEEP_RELATIVE_SPEED_WOG, #WITHOUT OPPOSING GRAVITY
	WALL_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING_WOG, #WITHOUT OPPOSING GRAVITY
	CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED,
	CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING,
	CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED_WOG, #WITHOUT OPPOSING GRAVITY
	CEILING_FLOOR_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING_WOG, #WITHOUT OPPOSING GRAVITY
	ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED,
	ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING,
	ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED_WOG, #WITHOUT OPPOSING GRAVITY
	ANY_ANGLE_BOUNCE_KEEP_RELATIVE_SPEED_IF_NOT_BOUNCING_WOG, #WITHOUT OPPOSING GRAVITY
	UNINTERRUPTIBLE #will only stopped when movement's duration ellapses, so be careful
}

enum GravityEffect{
	PAUSE,
	PLAY,
	STOP,
	KEEP,
	KEEP_AND_REPLAY_IF_STOPPED,
	REPLAY,
	REPLAY_IF_PLAYING,
	REPLAY_AND_KEEP_FLOOR_COLLISION
}

enum ConditionalMovement{##SAME as globals, make sure they in sync
	NO_CONDITION,
	AIR_ONLY,#don't combine this with AIR_AGAINST_WALL_ONLY, as they both trigger in corner in air so both complex movements will activate
	GROUND_ONLY, #don't combine this with GROUND_AGAINST_WALL_ONLY, as they both trigger in corner on ground so both complex movements will activate
	AIR_AGAINST_WALL_ONLY,
	GROUND_AGAINST_WALL_ONLY,
	AIR_AND_NOT_AGAINST_WALL_ONLY,
	GROUND_AND_NOT_AGAINST_WALL_ONLY,
	AGAINST_CEILING_ONLY, #DON'T COMBINE THIS WITH ANOTHER COMPLX MVM WITH AIR_ONLY, SINCE WILL BE IN AIR WHEN AGAINST CEILING. instead combine it with NOT_AGAINST_CEILING
	NOT_AGAINST_CEILING_ONLY #only combine this with AGAINST_CEILING_ONLY, since it's true all the time unless against ceiling
}

const GLOBALS = preload("res://Globals.gd")

const basicMvmResource = preload("res://basicMovement.gd")
#enum InheritRelativeVelocityType{
#	NO_INHERITANCE,
#INHERIT_RELATIVE_VELOCITY_EXCLUDING_GRAVITY,
	#INHERIT_RELATIVE_VELOCITY_INCLUDING_GRAVITY
#}

#const FRAME_PER_SECOND = 60

export (MovementType) var mvmType = MovementType.ADD

export (GravityEffect) var gravEffect = GravityEffect.PLAY
var startTime = 0
export (int) var startFrame = 0 setget setStartFrame,getStartFrame
export (Vector2) var bounceNormal = Vector2(0,0) #only required for any angle bounce
export (ConditionalMovement) var applyCondition = ConditionalMovement.NO_CONDITION
export (bool) var ignoredFacingDirection = false#false means speed chagnes with charater's facing. true means always same direction

#(overwrited by ignoredFacingDirection when ignoredFacingDirection = true) false speed is based on relative positioning of opponent. True means dependents on player's sprite facing (true will allow mvm animations not interrupted by crossup
export (bool) var relativeSpriteFacingDirection = false
var basicMovements = []


var active = false
var numStoppedBM = 0

var movementAnimationManager = null
var movementAnimation = null
#var started = false

#contains the most up-to-date version of current speeds of BM
var currentSpeedBuffer = []

#flag used to mirror x-movement when true, and leave x-velocity unchange when false
var mirrorXVelocity = false

func _ready():
		
		
	#index used to associate to each basim movement child
	#var basicMvmIx = 0
	
	#convert start frame to time
	#var frameDuration= 1.0/FRAME_PER_SECOND
	var frameDuration = GLOBALS.SECONDS_PER_FRAME
	startTime = startFrame * frameDuration
	
	#populate basicMovements by iterating children 
	for c in self.get_children():
		var script = c.get_script()
		if script != null:
			#var scriptName = script.get_path().get_file()
			#found movement node?
			if c is preload("basicMovement.gd"): #check if any script that is basicMovement.gd or extends it
			
					
					basicMovements.push_front(c)
					#call the _on_basic_movement_stopped function when a basic movement stops
					#the basic movement will signal it's index as well (numStoppedBM is index at this point)
					c.connect("stopped",self,"_on_basic_movement_stopped")
					
					
					#count the number of basic movement that are
					#initially stopped
					numStoppedBM=numStoppedBM+1
					
	#started = false
	
	
	pass


func reset():
	
	active = false
	numStoppedBM = 0

	currentSpeedBuffer = []

	mirrorXVelocity = false
	
	for bm in basicMovements:
		bm.reset()
#this setter and getter enables live tuning of start time vs godot editor
func setStartFrame(sf):
	startFrame = sf
	#var frameDuration= 1.0/FRAME_PER_SECOND
	var frameDuration = GLOBALS.SECONDS_PER_FRAME
	startTime = startFrame * frameDuration
func getStartFrame():
	return startFrame


func setMovementAnimation(anime):
	movementAnimation = anime
	
func set_movement_animation_manager(mvmAnimeMngr):
	
	movementAnimationManager=mvmAnimeMngr
	
	#now set it for all basic movement
	for bm in basicMovements:
		bm.set_movement_animation_manager(mvmAnimeMngr)


func readyToStart(timeEllapsed):
	return GLOBALS.has_frame_based_duration_ellapsed(timeEllapsed,startTime)
						
#this will make the movement indefinite
func pauseEllapsingTime():
	#iterate the basic movements and make
	#sure their timers stop counting
	for bm in basicMovements:
		bm.timerPauseFlag=true

#this will make the movement time ellapsing go back to normal 
#, (which may be indefinite)
func unpauseEllapsingTime():
	#iterate the basic movements and make
	#sure their timers stop counting
	for bm in basicMovements:
		bm.timerPauseFlag=false
		
func startBasicMovements():
	if basicMovements == null:
		return
		
	
	active=true
	numStoppedBM=0
	
	#iterate all basic movment	
	for bm in basicMovements:
		#make sure basic movment has proper x direction
		bm.mirrorXVelocity = mirrorXVelocity
		
		
		#the basic movement's speed and angle are dynamically determined by curret velocity?
		if bm.inheritSpeedType != basicMvmResource.InheritRelativeVelocityType.NO_INHERITANCE:
			
			var desiredAngle=null
			var curSpd = null
			var legalType = true
			#we include gravity in this?
			if bm.inheritSpeedType == basicMvmResource.InheritRelativeVelocityType.INHERIT_RELATIVE_VELOCITY_INCLUDING_GRAVITY:
				
				curSpd = movementAnimationManager.lastRelativeVelocity/movementAnimationManager.globalSpeedMod
				
			
			#we exclude gravity?
			elif bm.inheritSpeedType == basicMvmResource.InheritRelativeVelocityType.INHERIT_RELATIVE_VELOCITY_EXCLUDING_GRAVITY:
				curSpd = movementAnimationManager.lastRelativeVelocityExcGrav/movementAnimationManager.globalSpeedMod
				
			else:
				print("unkown InheritRelativeVelocityType basimc movement type, check definitions")
				legalType=false
				
			
			if legalType:
				var origin = Vector2(0,0)
				
				#length of speed vector
				var normSpeed  = origin.distance_to(curSpd)
				
				#var desiredAngle = rad2deg(srcPos.angle_to(dstPos))
				desiredAngle = rad2deg(curSpd.angle())
				
				#adjust the basic momvent's tradectory dynamically
				bm.speed = normSpeed
				bm.angle =desiredAngle
					
		bm.init()
		
#		started = true
	
#called when basic movement finshed
func _on_basic_movement_stopped(bm):
	numStoppedBM=numStoppedBM+1
	
	#all the basic movements stopped?
	if numStoppedBM >= basicMovements.size():
		active = false
	
	#although by desing in movement manager all the bm of a complex mvm that's uninterruptible, 
	#this dynamic check lets other external code make a basic movement uninterruptible if necessary
	if isUninturruptible():
		emit_signal("uninterruptible_bm_stopped",bm)

#summs the speed of all active basic movvements
func getRelativeVelocity():
	var velocity = Vector2(0,0)
	
	#iterate basic movements
	for n in basicMovements:
		#xSpeedResult = xSpeedResult + n.xSpeed 
		if n.is_physics_processing():
			velocity = velocity + n.getCurrentSpeed()
			
	return (velocity)

func isActive():
	#for n in basicMovements:
	
		#if n.is_physics_processing():
		#if not n.hasTimeExpired():
	#	if n.isActive():
	#		return true
			
			
	#return false
	return active
	
#		started = false

#sets mirror x velocity flag of all basic movements
func setXMirrorVelocity(flag):
	for bm in basicMovements:
		bm.mirrorXVelocity = flag
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func isUninturruptible():
	return mvmType == MovementType.UNINTERRUPTIBLE