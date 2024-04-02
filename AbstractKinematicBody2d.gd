extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var movementAnimationManager = null

var actionAnimationManager = null
var spriteAnimationManager = null

var floorDetector = null
var platformDetector = null
const GLOBALS = preload("res://Globals.gd")
export (int) var hitBoxLayer = 0
export (int) var hitBoxMask = 0
export (int) var hurtBoxLayer = 0
export (int) var hurtBoxMask = 0
export (int) var selfHitBoxLayer = 0
export (int) var selfHitBoxMask = 0
export (int) var selfHurtBoxLayer = 0
export (int) var selfHurtBoxMask = 0

var activeNodes = null
var bodyBox = null

#note finished yet
func init():
	
	self.set_physics_process(true)
	
	floorDetector = $bodyBox/floorDetector
	platformDetector = $bodyBox/platformDetector
	bodyBox = $bodyBox
	activeNodes = $"active-nodes"
	
	
	var sprite = $"active-nodes/Sprite"
	var collisionAreas = $"active-nodes/collisionAreas"
	
	actionAnimationManager = getActionManagerNode()
	actionAnimationManager.connect("create_projectile",self,"_on_create_projectile")
	
	movementAnimationManager = getMovementAnimationManagerNode()
	movementAnimationManager.targetKinematicBody2D = self
	
	#for c in self.get_children():
	#	if c is CollisionShape2D:
	#		#var is_one_waycollision = c.one_way_collision
	#		bodyBox = c
	#		bodyBox.set_shape(RectangleShape2D.new())
			#bodyBox.one_way_collision = is_one_waycollision
	#		break
	
	bodyBox.set_shape(RectangleShape2D.new())
			
	bodyBox.facingRight = facingRight
	movementAnimationManager.bodyBox = bodyBox
	movementAnimationManager.floorDetector = floorDetector
	
		
	spriteAnimationManager = $PlayerController/ActionAnimationManager/SpriteAnimationManager
	
	
	#connect all hitboxes and hurtboxes given mask
	var hitboxes = actionAnimationManager.spriteAnimationManager.getAllHitboxes()
	var hurtboxes = actionAnimationManager.spriteAnimationManager.getAllHurtboxes()
	
	for hb in hitboxes:
		if not hb.selfOnly:
			hb.collision_layer = hitBoxLayer
			hb.collision_mask = hitBoxMask
		else:
			hb.collision_layer = selfHitBoxLayer
			hb.collision_mask = selfHitBoxMask
		#connect collision to action manager
		hb.connect("area_entered",playerController.collisionHandler,"_on_area_entered_hitbox",[hb])
		hb.playerController = playerController
		#hb.connect("body_entered",actionAnimationManager,"_on_body_entered_hitbox",[hb])
	for hb in hurtboxes:
		if not hb.selfOnly:
			hb.collision_layer = hurtBoxLayer
			hb.collision_mask = hurtBoxMask
		else:
			hb.collision_layer = selfHurtBoxLayer
			hb.collision_mask = selfHurtBoxMask
		hb.connect("area_entered",playerController.collisionHandler,"_on_area_entered_hurtbox",[hb])
		hb.playerController = playerController
		#hb.connect("body_entered",actionAnimationManager,"_on_body_entered_hurtbox",[hb])
		
#should be implemented by subclasses to access action manager in tree
func getActionManagerNode():
	return null

#should be implemented by subclasses to access movement animation manager in tree	
func getMovementAnimationManagerNode():
	return null
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.

	if facingRight:
		#actionAnimationManager.set_scale(Vector2(1,1))
		activeNodes.set_scale(Vector2(1,1))
		
		
		bodyBox.facingRight = true
	else:
	#	print("facing left")
		#actionAnimationManager.set_scale(Vector2(-1,1))
		activeNodes.set_scale(Vector2(-1,1))
		bodyBox.facingRight = false
		#bodyBox.set_scale(Vector2(-1,1))

func getCenterX():
	var extent = bodyBox.get_shape().extents
	var centerX = self.global_position.x + extent.x/2
	return centerX
	pass
	

	
func _on_create_projectile(projectile, spawnPoint):
	#broadcast the signal up but also add facing to projectil
	projectile.facingRight = self.facingRight
	projectile.ripostingReactWindow = playerController.ripostHandler.ripostingReactWindow
	
	#make sure projectiles' hitbox/hurtbox is same as player
	projectile.hitBoxLayer = self.hitBoxLayer
	projectile.hitBoxMask = self.hitBoxMask
	projectile.hurtBoxLayer = self.hurtBoxLayer
	projectile.hurtBoxMask = self.hurtBoxMask
	projectie.proximityGuardLayer = self.proximityGuardLayer
	
	projectile.selfHitBoxLayer = self.selfHitBoxLayer
	projectile.selfHitBoxMask = self.selfHitBoxMask
	projectile.selfHurtBoxLayer = self.selfHurtBoxLayer
	projectile.selfHurtBoxMask = self.selfHurtBoxMask
		
	projectile.masterPlayerController = self.playerController
	
	
	
	
	#mirror x if facing opposite way
	if not self.facingRight:
		spawnPoint.x = spawnPoint.x * (-1)
		
	#position of projectile is relative to player	
		
	#adding to stage's game objects node?
	if projectile.mvmType == projectile.MovementType.RELATIVE_TO_STAGE:
		projectile.position = spawnPoint + self.position
	#adding to be relative to player?
	elif projectile.mvmType == projectile.MovementType.RELATIVE_TO_PLAYER:
		projectile.position = spawnPoint


	#projectile.position  = self.position

	emit_signal("create_projectile",projectile,self)
	
	