extends Node

var collisionShapes = []

var playerController = null
var projectileController = null #will be null if not a projectile
var spriteAnimation = null
var spriteFrame = null

var position = Vector2(0,0)
#false means this collision box interacts with opponent. true means interactiosn 
#only occur with this player's selfonly oppisite collision boxes (self only hurt collide with self only hitboxes)
export (bool) var selfOnly = false 

#the id of the sound effect to play upon collisioin (hit or hitting)
#-1 means default sound is played
export (int) var commonSFXSoundId = -1
export (int) var heroSFXSoundId = -1 #sound id specific to hero

export (int) var commonSFXSoundVolumeOffset = 0#0 means no change in volume
export (int) var heroSFXSoundVolumeOffset = 0 #0 means no change in volume

#priority is used to resolve multi-ple collision on
#same frame. sour-spots should have high priority (0)
#and sweet spots should be low priority (>0)
#super armor should be (>0) while normal would be (0)
#e.g.: noarmal hurtbox 0, super armor 1, invincibility 2 (all in same sprite frame)
export (int) var collisionPriority = 0

#only supported by alpha sprite frames (glove is :(    cause his logic is outlier)
export (bool) var overrideSpriteFrameOffset=false #true means can specify a different offset than the sprite frame's
export (Vector2) var offset = Vector2(0,0)


var cmd = null setget setCommand,getCommand
var facingRightWhenPlayed = null
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	#go find hitstun knock back if exists
	for c in self.get_children():
		
		if c is CollisionShape2D:
			collisionShapes.append(c)
	
	deactivate()
	#monitorable = true
	#monitoring = true	
	pass

func reset():
	deactivate()
	facingRightWhenPlayed = null
	cmd = null 
#param: _cmd - the command used to start this collision box's sprite aniamtion
func activate():
	for c in collisionShapes:
		c.disabled = false
func deactivate():
	for c in collisionShapes:
		c.disabled = true
		
func setCommand(_cmd):
	cmd = _cmd
	
func getCommand():
	return cmd
	
func belongsToProjectile():
	return projectileController != null