extends KinematicBody2D


export (int) var hitBoxLayer = 0
export (int) var hitBoxMask = 0
export (int) var hurtBoxLayer = 0
export (int) var hurtBoxMask = 0
export (int) var selfHitBoxLayer = 0
export (int) var selfHitBoxMask = 0
export (int) var selfHurtBoxLayer = 0
export (int) var selfHurtBoxMask = 0


var floorDetector = null
var platformDetector = null
var wasInAir = true

var bodyBox = null

#flag used to indicate which direction gameobject facing
var facingRight = true

var GLOBALS = preload("res://Globals.gd")

var masterPlayerController = null
var spriteAnimationManager = null
var movementAnimationManager = null
var actionAnimationManager = null
var collisionHandler = null

var active_nodes = null
#the command input by player to create this projectil
var command =null

var destroyTimer = null

var framePauseFrequency = -1
var slowingDownGame = false
var pauseFrameCounter = 0

var hittingSFXPlayer = null




var startingActionId = 0 #0 is the startupt animation in action anime manager
func _ready():
	
	pass


func init():
	
	#this sets initial facing and sprite mirroring based on direction 
	#only need to check once
	var newScale = Vector2(1,1)
	if not self.facingRight:
		newScale.x = newScale.x*(-1)
	
	active_nodes.set_scale(newScale)
		
	
	
	if has_node("bodyBox/floorDetector"):
		floorDetector = $bodyBox/floorDetector
		
	if has_node("bodyBox/platformDetector"):
		platformDetector = $bodyBox/platformDetector
		
	actionAnimationManager = $ProjectileController/ActionAnimationManager
	
	
	var sprite = $"active-nodes/Sprite"
	var collisionAreas = $"active-nodes/collisionAreas"

	
	actionAnimationManager.spriteAnimationManager.init(sprite,collisionAreas,bodyBox,active_nodes,self)
	
	movementAnimationManager = $ProjectileController/ActionAnimationManager/MovementAnimationManager
	
	#search for any followMovements, and link this projectile to player who created it
	for ma in movementAnimationManager.movementAnimations:
		#iterate complex mvm
		for cm in ma.complexMovements:
			#iterate basic mvmv
			for bm in cm.basicMovements:
				#var script = bm.get_script()
				#if script != null:
					#var scriptName = script.get_path().get_file()
					#found movement node?
				#if scriptName == "FollowMovement.gd":
				if bm is preload("res://FollowMovement.gd"):
					if bm.type == bm.FollowType.PROJECTILE_FOLLOW_CASTER or bm.type == bm.FollowType.PROJECTILE_FOLLOW_X_CASTER or bm.type == bm.FollowType.PROJECTILE_FOLLOW_Y_CASTER:
						var player = masterPlayerController.kinbody
						bm.src = self #this projectil follows
						bm.dst = player #follow player
						
		
	#only have movement manager that pushes if required type, otherwise basic movement
	if behaviorType == BehaviorType.PUSHES:
		movementAnimationManager.set_script(pushableMovementManagerScript)
		movementAnimationManager._ready()
	else:
		movementAnimationManager.set_script(movementManagerScript)
		movementAnimationManager._ready()
		
	spriteAnimationManager = $ProjectileController/ActionAnimationManager/SpriteAnimationManager
	
	#now iterate all the hitboxes, and record the player's spriteanimation id 
	#that created this projectile (needed for riposting in RipostHandler)
	
	#iterate all animations
	for spriteAnimation in spriteAnimationManager.spriteAnimations:
		#iterate all sprite frames
		for spriteFrame in spriteAnimation.spriteFrames:
			#iterate hitboxes
			for hb in spriteFrame.hitboxes:
				hb.projectileParentSpriteAnimation=projectileParentSpriteAnimation
	
	if has_node("bodyBox"):
		bodyBox = get_node("bodyBox")
	collisionHandler = $ProjectileController/CollisionHandler

	#hitFreezeTimer = $hitFreezeTimer
	
	#hitFreezeTimer.connect("hit_freeze_finished",self,"_on_hit_freeze_finished")
	
	actionAnimationManager.movementAnimationManager.connect("wall_collision",self,"_on_wall_collision")
	
	actionAnimationManager.connect("action_animation_finished",self,"_on_action_animation_finished")
	actionAnimationManager.connect("multi_tap_action_animation_partially_finished",self,"_on_multi_tap_action_animation_partially_finished")
	
	collisionHandler.connect("player_attack_clashed",self,"_on_player_attacked_clashed")
	collisionHandler.connect("player_invincible_was_hit",self,"_on_player_invincibility_was_hit")
	collisionHandler.connect("player_was_hit",self,"_on_player_was_hit")

	collisionHandler.connect("hitting_invincible_player",self,"_on_hitting_invincible_player")
	collisionHandler.connect("hitting_player",self,"_on_hitting_player")
	
	
	movementAnimationManager.targetKinematicBody2D = self
	
	for c in self.get_children():
		if c is CollisionShape2D:
			bodyBox = c
			
			#only create a new shape if the body box doesn't have a default shape
			if bodyBox.get_shape() == null:
				bodyBox.set_shape(RectangleShape2D.new())
			break
	if bodyBox != null:		
		bodyBox.facingRight = facingRight
	movementAnimationManager.bodyBox = bodyBox
	movementAnimationManager.floorDetector = floorDetector
	
		
	
	
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
		hb.connect("area_entered",self.collisionHandler,"_on_area_entered_hitbox",[hb])
		hb.playerController = masterPlayerController
		#hb.connect("body_entered",actionAnimationManager,"_on_body_entered_hitbox",[hb])
	for hb in hurtboxes:
		if not hb.selfOnly:
			hb.collision_layer = hurtBoxLayer
			hb.collision_mask = hurtBoxMask
		else:
			hb.collision_layer = selfHurtBoxLayer
			hb.collision_mask = selfHurtBoxMask
		hb.connect("area_entered",self.collisionHandler,"_on_area_entered_hurtbox",[hb])
		hb.playerController = masterPlayerController
		#hb.connect("body_entered",actionAnimationManager,"_on_body_entered_hurtbox",[hb])
	
	#start the preojctile animation	
	fire()

func startHitFreezeNotification(duration):
	if GLOBALS.RIPOST_REACTION_WINDOW  > duration:
		print("warning, hit freeze window too short (shorter than reactive ripost hit freeze")
		duration =GLOBALS.RIPOST_REACTION_WINDOW
	emit_signal("start_hitfreeze",duration)
		

func _on_player_attacked_clashed(otherHitboxArea, selfHitboxArea):
	#POWER HITBOXES won't make the projectil disapear
	#if selfHitboxArea.clashType == selfHitboxArea.CLASH_TYPE_POWER:
	#		return
	#go into ending animation
	actionAnimationManager.playUserAction(actionAnimationManager.COMPLETION_ACTION_ID,facingRight,command)
	
	
	#print(str(self.get_parent()) + " player invincibility was hit")
	if otherHitboxArea == null:
		print("null hitbox hitting invicibiilty")
		return
	
#this is called when this player's invincibility frames were hit	
func _on_player_invincibility_was_hit(otherHitboxArea, selfInvincibilityboxArea):
	#do nothing, generally a projectile won't have invicibility frames
	#i leave it to subclasss to implement this
	pass
	
func _on_wall_collision():
	
#	if behaviorType == BehaviorType.BASIC:
	 #play the completion animation, the projetile lifetime is comming to an end, 
	#it hit a wall
	actionAnimationManager.playUserAction(actionAnimationManager.COMPLETION_ACTION_ID,facingRight,command)
	pass

func _on_player_was_hit(otherHitboxArea, selfHurtboxArea):
	#ignore this since projectiles shouldsn't be able to get hit
	pass
func _on_multi_tap_action_animation_partially_finished(currentSpriteAnimation,spriteFrame):
	pass
	
func _on_hitting_player(selfHitboxArea, otherHurtboxArea):
	#print(str(self.get_parent()) + " player landed a hit")
	#disable all remaining hitboxes, since we don't want to multi hit an oponent with same hitbox		
	#selfHitboxArea.get_parent().getSpriteAnimation().disableAllHitboxes()
	hittingSFXPlayer.playRandomSound()
	
	selfHitboxArea.spriteAnimation.disableAllHitboxes()
	masterPlayerController._check_on_block_autoparry_hit(selfHitboxArea, otherHurtboxArea)
	actionAnimationManager.playUserAction(actionAnimationManager.COMPLETION_ACTION_ID,facingRight,command)
	
func _on_action_animation_finished(spriteAnimationId):
	
	match(spriteAnimationId):
		#last animation of projectli?
		actionAnimationManager.COMPLETION_SPRITE_ANIME_ID:
			destroy()
	
		#startup ellapsed, onto active animation?
		actionAnimationManager.STARTUP_SPRITE_ANIME_ID:
			actionAnimationManager.playUserAction(actionAnimationManager.ACTIVE_ACTION_ID,facingRight,command)
		#the active animation litetime has ended without hitting player?
		actionAnimationManager.ACTIVE_SPRITE_ANIME_ID:
			actionAnimationManager.playUserAction(actionAnimationManager.COMPLETION_ACTION_ID,facingRight,command)
		#UNKOWN ACTION
		_:
			print("warning, unknown projectil sprite id ("+spriteAnimationId+") finished, destroying projectil... ") 
			destroy()
	pass

func _on_hitting_invincible_player(selfHitboxArea, otherHurtboxArea):
	
	#here, don't do hitfreeze or any disabling of hitboxes.
	#the player controller's _on_player_invincibility_was_hitfunction will deal with it
	actionAnimationManager.playUserAction(actionAnimationManager.COMPLETION_ACTION_ID,facingRight,command)
	
func fire():
	
	#play the startup animation to start the projectil animation
	#actionAnimationManager.playUserAction(actionAnimationManager.STARTUP_ACTION_ID,facingRight,command)
	actionAnimationManager.playUserAction(startingActionId,facingRight,command)
	
	
func destroy():

	if behaviorType == BehaviorType.PUSHES:
		#unlink the pushing syncrhonization between any object, about to delete this object
		movementAnimationManager.stopPushing()
	
	movementAnimationManager.stopAllMovement()
		
	emit_signal("destroyed")

	#make the whoel node disapear, it should appear vanished
	
	self.visible = false
	#delete this node in 2 seconds
	destroyTimer.wait_time = 2
	destroyTimer.start()
	pass

func _on_hit_freeze_finished():
	unpauseAnimation()
	
func _on_hit_freeze_started(duration):
#func startHitFreeze(duration):
		
	pauseAnimation()
	
func pauseAnimation():
	actionAnimationManager.pauseAnimation()
	
func unpauseAnimation():
	actionAnimationManager.unpauseAnimation()

func _on_delayed_queue_free():
	queue_free()
	
	
	
func my_is_on_floor():
	#origianl logic that didn't consider one-way platforms
#	return floorDetector.is_colliding()
	#new logic that considers platforms. Can't be on floor if u have vertical momentum
	#var velocity = actionAnimeManager.movementAnimationManager.computeRelativeVelocity()
	
	#return floorDetector.is_colliding() and velocity.y > 0 #negative y velocity is updward momentum
	
	#for platforms, you can only be "on the floor" ie  on plat form 
	#if you fall ontop of it. This way, even if floor detector triggers, it will be ignored
	#if we are currently inside the platform. That is, being inside the platform means
	
	#the simple case where were on ground and not merged in a platform
	if not platformDetector.is_colliding():
		return floorDetector.is_colliding()
	else:
		
		#were merged in platform (assumes can't be both on ground and merged in a platform
		#platform should be height enough to form a jump trhough it
		 return self.is_on_floor() and  floorDetector.is_colliding()
	
func standingOnOpponent():
	#colliding with a physics object and not on floor? ie. on opponent
	if self.is_on_floor():
		return not floorDetector.is_colliding()
	
	return false
								
func _physics_process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	var isOnOpponent = standingOnOpponent()
	var pushingOpponent = false
	if isOnOpponent:
		pushingOpponent = true
		pass
		
	#did we fall from air onto groudN
	if my_is_on_floor() and not isOnOpponent:
			
		#landing onto ground
		if wasInAir:
				
			#handle landing only when not in ripost reactive window hit freeze
			#(this function will get re signaled once window expires)
			if not actionAnimationManager.playerPaused:
				_on_land(isOnOpponent)
	
	#after all the hit handling, at end frame were no longer hitting
	#playerState.hittingWithJumpCancelHitBox = false
	
	checkOnGroundOrInAirState(isOnOpponent,pushingOpponent)
	
	
func checkOnGroundOrInAirState(isOnOpponent,pushingOpponent):

	#don't change state from air to ground, or ground to air
	#when paused (don't want to miss a signal)
	if not actionAnimationManager.playerPaused:
		var isInAir = false
		#update flag indicating if we just in air or not
		#on opponent
		if my_is_on_floor() and isOnOpponent and not pushingOpponent:
			isInAir = true
		elif not my_is_on_floor() and isOnOpponent and not pushingOpponent:
			isInAir = true
		elif not my_is_on_floor() and not isOnOpponent and not pushingOpponent:
			isInAir = true
		else:
			isInAir = false
		
		#was on ground last frame and no longer?
		if not wasInAir and isInAir:
			_on_left_ground()
			
		wasInAir = isInAir

func _on_land(isOnOpponent):
	pass
	
func _on_left_ground():
	pass