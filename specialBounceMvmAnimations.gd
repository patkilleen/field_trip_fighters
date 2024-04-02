extends Node

const GLOBALS = preload("res://Globals.gd")

export (int) var maxNumberCeilingBounces = 1 setget setMaxNumberCeilingBounces,getMaxNumberCeilingBounces
export (int) var maxNumberWallBounces = 1 setget setMaxNumberWallBounces,getMaxNumberWallBounces
export (int) var maxNumberFloorBounces = 1 setget setMaxNumberFloorBounces,getMaxNumberFloorBounces
export (int) var maxNumberPlatformBounces = 1 setget setMaxNumberPlatformBounces,getMaxNumberPlatformBounces


#SAME DEFINITION AS RES://eNVIRONEMTNsATETDOBY2D.GD, BUT DIF NAMES
#const COLLISION_TYPE_WALL = 0
#const COLLISION_TYPE_CEILING = 1
#const COLLISION_TYPE_FLOOR = 2
#const COLLISION_TYPE_PLATFORM = 3

var mvmAnimationList = {}

var bounceCounters = {}
var maxBounceCounters = {}

#bool flag indicating true when facing right when the hitbox initially applied 
#to keep track of facing when animation started
var facingRightHitMovementPlayed=false
func _ready():
	
	if has_node("wall"):
		var wallMvmAniamtion = get_node("wall")
		if 	wallMvmAniamtion is preload("res://movementAnimation.gd"):
			mvmAnimationList[GLOBALS.COLLISION_TYPE_WALL] = wallMvmAniamtion
		
	if has_node("ceiling"):
		var ceilingMvmAniamtion = get_node("ceiling")		
		if 	ceilingMvmAniamtion is preload("res://movementAnimation.gd"):
			mvmAnimationList[GLOBALS.COLLISION_TYPE_CEILING] = ceilingMvmAniamtion
	
			
	if has_node("floor"):
		var floorMvmAniamtion = get_node("floor")		
		if 	floorMvmAniamtion is preload("res://movementAnimation.gd"):
			mvmAnimationList[GLOBALS.COLLISION_TYPE_FLOOR] = floorMvmAniamtion	
	
	if has_node("platform"):
		var platformMvmAniamtion = get_node("platform")		
		if 	platformMvmAniamtion is preload("res://movementAnimation.gd"):
			mvmAnimationList[GLOBALS.COLLISION_TYPE_PLATFORM] = platformMvmAniamtion
	resetBounceCounters()
	
	maxBounceCounters[GLOBALS.COLLISION_TYPE_WALL]=maxNumberWallBounces
	maxBounceCounters[GLOBALS.COLLISION_TYPE_CEILING]=maxNumberCeilingBounces
	maxBounceCounters[GLOBALS.COLLISION_TYPE_FLOOR]=maxNumberFloorBounces
	maxBounceCounters[GLOBALS.COLLISION_TYPE_PLATFORM]=maxNumberPlatformBounces


func setMaxNumberCeilingBounces(n):
	maxNumberCeilingBounces=n
	maxBounceCounters[GLOBALS.COLLISION_TYPE_CEILING]=n
func getMaxNumberCeilingBounces():
	return maxNumberCeilingBounces
	
func setMaxNumberWallBounces(n):
	maxNumberWallBounces=n
	maxBounceCounters[GLOBALS.COLLISION_TYPE_WALL]=n
func getMaxNumberWallBounces():
	return maxNumberWallBounces
	

func setMaxNumberFloorBounces(n):
	maxNumberFloorBounces=n
	maxBounceCounters[GLOBALS.COLLISION_TYPE_FLOOR]=n
func getMaxNumberFloorBounces():
	return maxNumberFloorBounces


func setMaxNumberPlatformBounces(n):
	maxNumberPlatformBounces=n
	maxBounceCounters[GLOBALS.COLLISION_TYPE_PLATFORM]=n
func getMaxNumberPlatformBounces():
	return maxNumberPlatformBounces	




func resetBounceCounters():
	bounceCounters[GLOBALS.COLLISION_TYPE_WALL]=0
	bounceCounters[GLOBALS.COLLISION_TYPE_CEILING]=0
	bounceCounters[GLOBALS.COLLISION_TYPE_FLOOR]=0
	bounceCounters[GLOBALS.COLLISION_TYPE_PLATFORM]=0

func incrementBounceCount(collisionType):
	
	#keep track of how many times bounced of certain type of terrain
	if bounceCounters.has(collisionType):
		bounceCounters[collisionType] = bounceCounters[collisionType] +1

##bounce aniamtion only avaialable if it exsits and hasn't played over it's maximum frequency
func isSpecialBounceAnimationAvailable(collisionType):
	if not bounceCounters.has(collisionType):
		return false
	
	#bounces exceeded number of max times can be done?
	var bounceCountExceeded = bounceCounters[collisionType] >= maxBounceCounters[collisionType]
	
	return hasSpecialBounceAnimation(collisionType) and not bounceCountExceeded
	
func hasSpecialBounceAnimation(collisionType):
	return	mvmAnimationList.has(collisionType)
	
func getSpecialBounceAnimation(collisionType):
	
	if hasSpecialBounceAnimation(collisionType):
		return	mvmAnimationList[collisionType]
	else:
		return null
func _on_player_hitstun_changed(inHitStunFlag):
	
	#combo ended
	if not inHitStunFlag:
		
		#we reset the number of bounces
		resetBounceCounters()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
