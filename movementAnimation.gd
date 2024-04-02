extends Node
signal played
signal complex_mvm_activated #signaled when a new complex mvm's start time was met
signal finished_processing_all_complex_mvm #signaled when all the complex mvm's have started
signal finished #called when all the basic movement of the animation are inactive

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const GLOBALS = preload("res://Globals.gd")
var id = 0
var timeEllapsed = 0.0
export (float) var animationSpeed = 1.0 setget setAnimationSpeed,getAnimationSpeed
export (bool) var bouncable = false
export (bool) var overridable = true # true means this animation can be halted by an animtion that overrides others, false means it will continue processing until all complex mmv's basic mvm are done
export (bool) var overrides = true # true means this animation will halt the current animtion, false means it lets the  other animtions keep goign
export var priority = 0 #when animations override, they can only override aniamtion with priority equal to and less than itself. values from 0 to 10
export (bool) var enforcePriorityLocks = false #false means any animation can be played this frame. True means only those of same priority or higher can be played this frame
export (bool) var clearUnprocessedCmplxMvm = false #true means any comlex movement that haven't been processed yet are cleared
export (bool) var stopsAllMvmOnPlay = false #true means everything is stopped upon playing aniamtion, regardless of priority
export (bool) var alignWithFacing=false #true means the special case where sprite facing wrong way, movement will align with sprite facing  instead of player screen  position

#type of movement for knockback animations (not relevant for player movement)
enum KnockbackType{
	HITSTUN,
	BLOCKSTUN,
	HITSTUN_LINK, # only aapply if already in hitstun, else the HITSTUN movement is applied
	CORNER_HIT_PUSH_BACK, #the push back effect from hitting opponent in corer
	CORNER_BLOCK_HIT_PUSH_BACK,#push back from hitting blocking opponent in corner
	ATTACKER_ON_BLOCKED
}

#same constants as GLOBALS
export (int, FLAGS, "Wall", "Ceiling", "Floor", "Platform") var bouncableSurfaces = 0 #choose what can bounce off
export (int) var maxBounces = 0
export (float) var bounceFriction = 0.1 #1 x speed lost each frame
export (float) var bounceMod=0.7#0.7 could be a good value. speed lost each bunce
export (KnockbackType) var knockbackType = 0 #knockback default to on hit from attack


var bouncableSurfaceMasks = []


#changing this will globaly alter speed of animations
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

var complexMovements = []



var playing=false
var paused=false

var finishedStartingAllComplxMvm=false

var unActivatedComplexMovements = []

var mvmAnimationManager=null

var customCeilingBounceAnimation = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	
	#populate basicMovements by iterating children 
	for c in self.get_children():
		
		#found movement node?
		if c is preload("res://complexMovement.gd"):
	
			complexMovements.push_front(c)
			c.setMovementAnimation(self)
			
	updateBasicMvmSpeed(animationSpeed)
	
	#fill buffer that will be used to keep track of active complex movement and those who finished
	for cm in complexMovements:
		unActivatedComplexMovements.append(null)
		
	bouncableSurfaceMasks.append(1 <<GLOBALS.COLLISION_TYPE_WALL) #COLLISION_TYPE_WALL
	bouncableSurfaceMasks.append(1 <<GLOBALS.COLLISION_TYPE_CEILING) #COLLISION_TYPE_CEILING
	bouncableSurfaceMasks.append(1 <<GLOBALS.COLLISION_TYPE_FLOOR) #COLLISION_TYPE_FLOOR
	bouncableSurfaceMasks.append(1 <<GLOBALS.COLLISION_TYPE_PLATFORM) #COLLISION_TYPE_PLATFORM
	
	set_physics_process(false)
	pass

func reset():
	
	playing=false
	paused=false

	finishedStartingAllComplxMvm=false

	clearUnactiveMvm()
	
	customCeilingBounceAnimation = null
	
	for cm in complexMovements:
		cm.reset()
	#set_physics_process(false)

func setAnimationSpeed(spd):
	animationSpeed = spd
	updateBasicMvmSpeed(animationSpeed)
	
func getAnimationSpeed():
	return animationSpeed
	
func updateBasicMvmSpeed(_spd):
	
	#iterate over all complex movements of this animation
	for cm in complexMovements:
		#iterate all basic movements to apply animation speed
		for bm in cm.basicMovements:
			bm.animationSpeed=_spd
			
func canBounceOff(collisionType):
	
	if not bouncable:
		return false
		
	var mask =bouncableSurfaceMasks[collisionType]
	
	#zero after masking means bits don't align, meaning the collision type isn't bouncable
	return (mask & bouncableSurfaces) != 0

	
func applyDynamicAngle(angle):
	#iterate over complex movements
	for cm in complexMovements:
		
		#iterate over basic movement
		for bm in cm.basicMovements:
			
			#only change angle if dynamic angle supported
			if bm.dynamicAngle:
				bm.angle = angle


func _physics_process(delta):
	
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS

	if not playing:
		set_physics_process(false)
		return
	#we will consider iterating over all unactivated complex mmvms only if some remain
	if not finishedStartingAllComplxMvm:
		
		#only need to keep track of time to decide when a complex movement should start	
		timeEllapsed =  timeEllapsed + (delta*globalSpeedMod*animationSpeed)
		processAnimation()

	else:		
	
		#check for completion of animation (all basic movements are finished)
		
		var finishedAnimation=true
		
		#iterate over all our complex mvms
		for cm in complexMovements:
			
			#when atleast one complex mvm has active basic mvm, were not doen
			if(cm.isActive()):
				finishedAnimation= false
				break;
			
		if finishedAnimation:
			stop()
		


#checks what complex movement should be requested (via signal) to start
func processAnimation():
	#we will consider iterating over all unactivated complex mmvms only if some remain
	if not finishedStartingAllComplxMvm:		
		
		var i = 0
		
		#iterate all un activated complex movement
		for i in range(0,unActivatedComplexMovements.size()):
			var cm =unActivatedComplexMovements[i]
	
			#haven't activated comlex mvm already?
			if cm != null:
				
				#check if should start (enough time ellapsed)			
				#if GLOBALS.has_frame_based_duration_ellapsed(timeEllapsed,cm.startTime):
				if cm.readyToStart(timeEllapsed):
												
					unActivatedComplexMovements[i] = null
					emit_signal("complex_mvm_activated",cm,self)
					
		
		#want to check if aniamtion is done starting all complex movements available
		var processedAllCplxMvms = true
		
		#iterate over remainded of unactivate complx mvm array
		#to see if this animation has finished processing all complex movements
		for cm in unActivatedComplexMovements:
			if cm != null:
				processedAllCplxMvms =false
				break
				
		if processedAllCplxMvms:
			finishedStartingAllComplxMvm=true
			emit_signal("finished_processing_all_complex_mvm",self)
		
	
	
#plays the movement aniamtion, and the animation can start and be paused or start immediatly
#_paused: flag that is true when animation should start be begin paused, and false means start immediatly
#_spriteFacingRight: indicates which direction sprite is facing
func play(_paused,_facingRight,mvmAnimationManager,_spriteFacingRight=true):
	
	finishedStartingAllComplxMvm=false
	playing=true
	paused=_paused
	timeEllapsed=0
	
	#iterate complex mvms
	for i in range(0,complexMovements.size()):
		
		
		var cm = complexMovements[i]
		
		#mvm ignores player's facign? (static direction mvmv)
		if not cm.ignoredFacingDirection:
			
			#standard mvm where depends on position to opponent?
			if not cm.relativeSpriteFacingDirection:
				#make complex mvm have correct facing
				cm.mirrorXVelocity= not _facingRight	
			else:
				#mvm is dependent on position of player's facing sprite direction
				#make complex mvm have correct facing
				cm.mirrorXVelocity= not _spriteFacingRight	
		else:
			cm.mirrorXVelocity= false
		
		#give a reference to this movement aniotm manager
		cm.set_movement_animation_manager(mvmAnimationManager)
		
		#populate the active complex mvms
		unActivatedComplexMovements[i]=cm
	
	 
	#only start processing if not paused
	if paused:
		set_physics_process(false)
		
	else:
		set_physics_process(true)
		
	emit_signal("played",self)
	
func stop():
	
	if not playing:
		return
	
	clearUnactiveMvm()
		
	playing =false
	
	emit_signal("finished",self)

func clearUnactiveMvm():
		#clear all the active (not started) complex mvms
	for i in range(0,unActivatedComplexMovements.size()):
		unActivatedComplexMovements[i]=null
		
func pause():
	
	if not playing:
		return
		
	paused=true
	set_physics_process(false)	
	pass
	
func unpause():
	
	if not playing:
		return
		
	paused=false
	set_physics_process(true)	
	
	pass		



	
	
func setGlobalSpeedMod(mod):
	globalSpeedMod=mod
	
