extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal destroyed
signal remove_magnifying_glass
signal projectile_ready
signal changed_sprite_facing

enum MovementType{
	RELATIVE_TO_STAGE,
	RELATIVE_TO_PLAYER
}

enum BehaviorType{
	BASIC,
	MATERIAL,
	MATERIAL_NO_FALSE_WALLS,
	PUSHES,
	PUBLIC_ENVIRONMENT,
	SELF_ENVIRONMENT,
	OPPONENT_ENVIRONMENT,
	MATERIAL_NO_FALSE_CEILING
}


const GLOBALS = preload("res://Globals.gd")

const movementManagerScript = preload("res://MovementAnimationManager.gd")
const pushableMovementManagerScript = preload("res://PushableMovementAnimationManager.gd")

const COMMON_SOUND_SFX = 0
const HERO_SOUND_SFX = 1
		
		
# warning-ignore:unused_class_variable
export (Vector2) var magnifyingGlassSpriteOffset = Vector2(0,0)
# warning-ignore:unused_class_variable
export (bool) var offScreenMagnifyingGlass = false
export (bool) var supportsReparentingOnDestroy = true

export (bool) var completeAnimationOnHit=true
export (bool) var completeAnimationOnWallCollision = false
export (bool) var disableSkinModuleOverride=false

export (bool) var allowHitboxParentSpriteAnimationUpdate = true #true means spawning the proejctile will determine parent sprite animation. false means projectiles managers parent sprite animatin itself
export (int) var actionId2ndStartupAnimation = -1 #-1 means when start action id done, active will be palyed. when > -1, when startu anime ends, custom startup 2 action anime palyed, and active played when 2nd aim done
var kinbody = null
var hitBoxLayer = 0
var hitBoxMask = 0
var hurtBoxLayer = 0
var hurtBoxMask = 0
var selfHitBoxLayer = 0
var selfHitBoxMask = 0
var selfHurtBoxLayer = 0
var selfHurtBoxMask = 0
var proximityGuardMask = 0

var commonSFXSoundDefaultVolume = null
var heroSFXSoundDefaultVolume=null

#var soundInitiated  = false
# warning-ignore:unused_class_variable
export (Vector2) var spawnPoint = Vector2(0,0)
# warning-ignore:unused_class_variable
export (MovementType) var mvmType = 0
export (BehaviorType) var behaviorType = 0

const MELEE_HIT_SOUND_ID = 15
const SPECIAL_HIT_SOUND_ID = 16
const TOOL_HIT_SOUND_ID = 17

var floorDetector = null
var leftPlatformDetector = null
var rightPlatformDetector = null
var leftOpponentDetector = null
var rightOpponentDetector = null
var leftWallDetector = null
var rightWallDetector = null
var leftFalseWallDetector = null
var rightFalseWallDetector = null
var leftCornerDetector = null#not used, but colilsion handler needs it to exist (null) to not bug with corner detection
var rightCornerDetector = null#not used, but colilsion handler needs it to exist (null) to not bug with corner detection
var hittingLeftWallDetector = null#not used, but colilsion handler needs it to exist (null) to not bug with corner detection
var hittingRightWallDetector = null#not used, but colilsion handler needs it to exist (null) to not bug with corner detection
var disableBodyBoxLeftWallDetector = null#not used, but colilsion handler needs it to exist (null) to not bug with corner detection
var disableBodyBoxRightWallDetector = null#not used, but colilsion handler needs it to exist (null) to not bug with corner detection
var attackSFXContainer = null

var meleeAttackLight = null
var specialAttackLight = null
var toolAttackLight = null

var wasInAir = true

var alphaSpriteFrameYOffset = Vector2(0,0)

var bodyBox = null
var projectileParentSpriteAnimation = null setget setProjectileParentSpriteAnimation,getProjectileParentSpriteAnimation
#command used to create the projectil

#flag used to indicate which direction player was facing
#when they create projectil
var facingRight = true setget setFacingRight,getFacingRight

var spriteCurrentlyFacingRight = true
#this is used for hitfreeze purposes. The player controller that created the 
#projectil should be in charge of setting this
var ripostingReactWindow = 0

var masterPlayerController = null
var spriteAnimationManager = null
var movementAnimationManager = null
var actionAnimationManager = null
var collisionHandler = null


var inAir = true

var active_nodes = null
#the command input by player to create this projectil
var command =null setget setCommand,getCommand

# warning-ignore:unused_class_variable
var destroyTimer = null

# warning-ignore:unused_class_variable
var framePauseFrequency = -1
# warning-ignore:unused_class_variable
var slowingDownGame = false
# warning-ignore:unused_class_variable
var pauseFrameCounter = 0

var hittingSFXPlayer = null
var commonSFXSoundPlayer = null
var heroSFXSoundPlayer = null

var lightingEffectsEnabled = true
var activeNodeSprite = null
var sprite = null
var startingActionId = 0 #0 is the startupt animation in action anime manager

var spriteSFXNode =null

var inHitFreeze = false

var startup2AnimationId = -1

var spriteSFXBuffer=[]
var opponentSpriteSFXBuffer=[]
func _ready():
	
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	emit_signal("projectile_ready")
	pass

func setProjectileParentSpriteAnimation(_a):
	projectileParentSpriteAnimation = _a
	if allowHitboxParentSpriteAnimationUpdate:
		updateHitboxParentSpriteAnimation()
	
func getProjectileParentSpriteAnimation():
	return projectileParentSpriteAnimation
	
func init():
	
	#required to support code that is applied onplayer controllers
	kinbody = self
	
	#make sure projectiles' hitbox/hurtbox is same as player
	self.hitBoxLayer = masterPlayerController.kinbody.hitBoxLayer
	self.hitBoxMask = masterPlayerController.kinbody.hitBoxMask
	self.hurtBoxLayer = masterPlayerController.kinbody.hurtBoxLayer
	self.hurtBoxMask = masterPlayerController.kinbody.hurtBoxMask
	
	self.selfHitBoxLayer = masterPlayerController.kinbody.selfHitBoxLayer
	self.selfHitBoxMask = masterPlayerController.kinbody.selfHitBoxMask
	self.selfHurtBoxLayer = masterPlayerController.kinbody.selfHurtBoxLayer
	self.selfHurtBoxMask = masterPlayerController.kinbody.selfHurtBoxMask
	self.proximityGuardMask =masterPlayerController.kinbody.proximityGuardMask 
	active_nodes = $"active-nodes"
	active_nodes.enableAreas()
	
	
	spriteSFXNode = $"active-nodes/sfxSprites"
	
	activeNodeSprite = $"active-nodes/Sprite"
	sprite=activeNodeSprite#so not bugs . for somereason 2 references in player controler, to the sprite
	hittingSFXPlayer = $ProjectileController/hittingSFX
	commonSFXSoundPlayer = $ProjectileController/commonSFXSounds
	heroSFXSoundPlayer = $ProjectileController/heroSFXSounds
	
	commonSFXSoundDefaultVolume=commonSFXSoundPlayer.volume_db
	heroSFXSoundDefaultVolume =heroSFXSoundPlayer.volume_db
	
	attackSFXContainer = $"active-nodes/attackSFXs"
	
	#this sets initial facing and sprite mirroring based on direction 
	#only need to check once
		
	#timer to delay deleting
	#destroyTimer = Timer.new()
	#destroyTimer.one_shot = true #set to true to indicate don't conitune ticking (only executed once called)
	#destroyTimer.connect("timeout",self,"_on_delayed_queue_free")
	#self.add_child(destroyTimer)
	
	
	#if has_node("bodyBox/floorDetector"):
	#	floorDetector = $bodyBox/floorDetector
		
	#if has_node("bodyBox/platformDetector"):
	#	platformDetector = $bodyBox/platformDetector
	
	floorDetector = $bodyBox/floorDetector
	leftPlatformDetector = $bodyBox/leftPlatformDetector
	rightPlatformDetector = $bodyBox/rightPlatformDetector
	
	leftOpponentDetector = $bodyBox/leftOpponentDetector
	rightOpponentDetector = $bodyBox/rightOpponentDetector
	
	leftWallDetector = $bodyBox/leftWallDetector
	rightWallDetector = $bodyBox/rightWallDetector
	leftFalseWallDetector = $bodyBox/leftFalseWallDetector	
	rightFalseWallDetector = $bodyBox/rightFalseWallDetector
	
	actionAnimationManager = $ProjectileController/ActionAnimationManager
	
	meleeAttackLight = $"active-nodes/melee-light"
	specialAttackLight = $"active-nodes/special-light"
	toolAttackLight = $"active-nodes/tool-light"
	
	
# warning-ignore:shadowed_variable
	var activeNodeSprite = $"active-nodes/Sprite"
	var collisionAreas = $"active-nodes/collisionAreas"

	

	
	movementAnimationManager = $ProjectileController/ActionAnimationManager/MovementAnimationManager
	
	#movementAnimationManager.connect("stopped_bouncing",self,"_on_stopped_bouncing")
	#movementAnimationManager.connect("started_bouncing",self,"_on_started_bouncing")
	
	#only have movement manager that pushes if required type, otherwise basic movement
	if behaviorType == BehaviorType.PUSHES:
		movementAnimationManager.set_script(pushableMovementManagerScript)
		movementAnimationManager._ready()
	else:
		movementAnimationManager.set_script(movementManagerScript)
		movementAnimationManager._ready()
		
	actionAnimationManager.init(self)
	
	#actionAnimationManager.spriteAnimationManager.init(activeNodeSprite,collisionAreas,bodyBox,active_nodes,masterPlayerController,self)
	actionAnimationManager.spriteAnimationManager.init(activeNodeSprite,collisionAreas,bodyBox,active_nodes,self,self)
	
	
	
	spriteAnimationManager = actionAnimationManager.spriteAnimationManager
	
	updateHitboxParentSpriteAnimation()
	
	if has_node("bodyBox"):
		bodyBox = get_node("bodyBox")
	collisionHandler = $ProjectileController/CollisionHandler


	if actionId2ndStartupAnimation != -1:
		var startup2SA=actionAnimationManager._spriteAnimationLookup(actionId2ndStartupAnimation)
		if startup2SA !=null:
			startup2AnimationId = startup2SA.id
		else:
			actionId2ndStartupAnimation=-1
			startup2AnimationId=null
			print("projectile "+str(self.name)+" specified startup 2 action id but couldn't find the sprite animation")
	#hitFreezeTimer = $hitFreezeTimer
	
	#hitFreezeTimer.connect("hit_freeze_finished",self,"_on_hit_freeze_finished")
	
	#actionAnimationManager.movementAnimationManager.connect("wall_collision",self,"_on_wall_collision")
	
	actionAnimationManager.movementAnimationManager.connect("moved_kinematic_body",self,"_on_moved_kinematic_body")
	
	actionAnimationManager.connect("action_animation_finished",self,"_on_action_animation_finished")
	actionAnimationManager.connect("multi_tap_action_animation_partially_finished",self,"_on_multi_tap_action_animation_partially_finished")
	actionAnimationManager.connect("request_play_sound",self,"_on_request_play_special_sound")
	
	actionAnimationManager.connect("create_projectile",self,"_on_create_projectile")
	
	collisionHandler.connect("player_attack_clashed",self,"_on_player_attacked_clashed")
	collisionHandler.connect("player_invincible_was_hit",self,"_on_projectile_invincibility_was_hit")
	collisionHandler.connect("player_was_hit",self,"_on_projectile_was_hit")

	collisionHandler.connect("hitting_invincible_player",self,"_on_hitting_invincible_player")
	collisionHandler.connect("hitting_player",self,"_on_hitting_player")
	
	collisionHandler.connect("left_wall",self,"_on_left_wall")
	
	collisionHandler.connect("pushed_against_wall",self,"_on_wall_collision")
	collisionHandler.connect("pushed_against_ceiling",self,"_on_ceiling_collision")
	
	
	collisionHandler.connect("left_ground",self,"_on_left_ground")
	collisionHandler.connect("landing_on_ground",self,"_on_land")
	collisionHandler.connect("left_platform",self,"_on_left_ground")
	collisionHandler.connect("landing_on_platform",self,"_on_land")
	
	collisionHandler.playerController = self
	
	movementAnimationManager.targetKinematicBody2D = self
	
	collisionHandler.connect("pushed_against_wall",movementAnimationManager,"_on_hit_wall")
	collisionHandler.connect("pushed_against_ceiling",movementAnimationManager,"_on_hit_ceiling")
	collisionHandler.connect("landing_on_ground",movementAnimationManager,"_on_hit_floor")
	collisionHandler.connect("landing_on_platform",movementAnimationManager,"_on_hit_platform")
	
	#for c in self.get_children():
	#	if c is CollisionShape2D:
	#		bodyBox = c
			
	#		#only create a new shape if the body box doesn't have a default shape
	#		if bodyBox.get_shape() == null:
	#			bodyBox.set_shape(RectangleShape2D.new())
	#		break
	if bodyBox != null:		
		bodyBox.facingRight = facingRight
		spriteCurrentlyFacingRight =facingRight
	movementAnimationManager.bodyBox = bodyBox
	movementAnimationManager.floorDetector = floorDetector
	

	
	#connect all hitboxes and hurtboxes given mask
	var proximityGuardAreas = actionAnimationManager.spriteAnimationManager.getAllProximityGuardAreas()
	var hitboxes = actionAnimationManager.spriteAnimationManager.getAllHitboxes()
	var hurtboxes = actionAnimationManager.spriteAnimationManager.getAllHurtboxes()
	var selfOnlyHitboxes = actionAnimationManager.spriteAnimationManager.getAllSelfOnlyHitboxes()
	var selfOnlyHurtboxes = actionAnimationManager.spriteAnimationManager.getAllSelfOnlyHurtboxes()
	
	for hb in proximityGuardAreas:
		hb.playerController = masterPlayerController
		hb.projectileController = self
		
	for hb in hitboxes:
		hb.playerController = masterPlayerController
		hb.projectileController = self
		
	for hb in hurtboxes:
		hb.playerController = masterPlayerController
		hb.projectileController = self
	for hb in selfOnlyHitboxes:
		hb.playerController = masterPlayerController
		hb.projectileController = self
		
	for hb in selfOnlyHurtboxes:
		hb.playerController = masterPlayerController
		hb.projectileController = self
		
	
	proximityGuardAreas = active_nodes.getProximityGuardAreas()
	hitboxes = active_nodes.getHitboxAreas()
	hurtboxes = active_nodes.getHurtboxAreas()
	selfOnlyHurtboxes = active_nodes.getSelfOnlyHurtboxAreas()
	selfOnlyHitboxes = active_nodes.getSelfOnlyHitboxAreas()
	
	for hb in proximityGuardAreas:
		
		hb.collision_layer = 0
		hb.collision_mask = proximityGuardMask
		
		
	for hb in hitboxes:
		
		hb.collision_layer = hitBoxLayer
		hb.collision_mask = hitBoxMask
		
		#connect collision to action manager
		hb.connect("area_entered",self.collisionHandler,"_on_area_entered_hitbox",[hb])
		
	for hb in hurtboxes:
		#if not hb.selfOnly:
		hb.collision_layer = hurtBoxLayer
		hb.collision_mask = hurtBoxMask
	
		hb.connect("area_entered",self.collisionHandler,"_on_area_entered_hurtbox",[hb])
		hb.connect("area_exited",self.collisionHandler,"_on_area_exited_hurtbox",[hb]) #required to detect when proximity guard diasbled
		
	for hb in selfOnlyHitboxes:
		
		hb.collision_layer = selfHitBoxLayer
		hb.collision_mask = selfHitBoxMask
		#connect collision to action manager
		hb.connect("area_entered",self.collisionHandler,"_on_area_entered_hitbox",[hb])
		
	for hb in selfOnlyHurtboxes:
	
		hb.collision_layer = selfHurtBoxLayer
		hb.collision_mask = selfHurtBoxMask 
		hb.connect("area_entered",self.collisionHandler,"_on_area_entered_hurtbox",[hb])	
	
	deactivate()
	#start the preojctile animation	
	#fire()


#called by master player controller
func initFollowMovements():
		
	#search for any followMovements, and link the follow oppoent 
	
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
					if bm.destinationType == bm.DestinationType.OPPONENT:
						bm.src = self #this projectil follows
						bm.dst = masterPlayerController.opponentPlayerController.kinbody #follow opponent
						
					elif bm.destinationType == bm.DestinationType.OTHER:
						#leave it up to sub class hook to setupt the src and dst
						bm.connect("following_special_object_type",self,"_on_following_special_object_type_hook")
		
	
	#searching in hitstun movements
	for sa in actionAnimationManager.spriteAnimationManager.spriteAnimations:
		
		#iterate sprite frames
		for sf in sa.spriteFrames:
			
			#iterate over hitboxes
			
			for hb in sf.hitboxes:
				
				if hb.hitstunMovementAnimation != null:
					#iterate complex mvm
					for cm in hb.hitstunMovementAnimation.complexMovements:
						#iterate basic mvmv
						for bm in cm.basicMovements:
							
							if bm is preload("res://FollowMovement.gd"):
								 #we are opponent, sicne this is hitstun movement to apply to victim
								if bm.destinationType == bm.DestinationType.OPPONENT:
									bm.dst = masterPlayerController.kinbody #in this case, player creating projectil is the opponent since this movement is knockback from attack were hitting with
									bm.src = masterPlayerController.opponentPlayerController.kinbody  #victim flying towards us is opponent,
								elif bm.destinationType == bm.DestinationType.CASTER:
									#bm.src = kinbody 
									#bm.dst = opponentPlayerController.kinbody 
										print("warning: invalid follow movement confiruation. Caster in this case is victim being hit, and victim can't follow itself. ignoring.")
								elif bm.destinationType == bm.DestinationType.OTHER:
									#leave it up to sub class hook to setupt the src and dst
									bm.connect("following_special_object_type",masterPlayerController.opponentPlayerController,"_on_following_special_object_type_hook")
									bm.connect("following_special_object_type",self,"_on_following_special_object_type_hook")
func _on_moved_kinematic_body(_mvmAnimationManager):
	var wasOnGroundCopy = collisionHandler.wasOnGround
	var wasOnPlatformCopy = collisionHandler.wasOnPlatform
	collisionHandler.environmentCollisionCheck(_mvmAnimationManager)
	collisionHandler.stoppedEnvironmentCollisionCheck(wasOnGroundCopy,wasOnPlatformCopy,_mvmAnimationManager)
	
func updateHitboxParentSpriteAnimation():

	#now iterate all the hitboxes, and record the player's spriteanimation id 
	#that created this projectile (needed for riposting in RipostHandler and combo levels)
	
	if spriteAnimationManager == null:
		return
		
	#iterate all animations
	for spriteAnimation in spriteAnimationManager.spriteAnimations:
		#iterate all sprite frames
		for spriteFrame in spriteAnimation.spriteFrames:
			#iterate hitboxes
			for hb in spriteFrame.hitboxes:
				hb.projectileParentSpriteAnimation=projectileParentSpriteAnimation
				
func setFacingRight(f):
	facingRight = f
	spriteCurrentlyFacingRight = f
	#emit_signal("changed_facing",facingRight)
	emit_signal("changed_sprite_facing",facingRight)
	
func getFacingRight():
	return facingRight
	
func setCommand(cmd):
	command = cmd
	
func getCommand():
	return command


func startHitFreezeNotification(duration):
	if ripostingReactWindow  > duration:
		print("warning, hit freeze window too short (shorter than reactive ripost hit freeze")
		duration = ripostingReactWindow
	emit_signal("start_hitfreeze",duration)
		

#func playOnHitSound(hurtBoxSoundId,hitBoxSoundId):

#check to see if the hitbox or hurtbox have a special sound to play
#	if hurtBoxSoundId != -1:
		#play specific sound specified by hurtbox
#		_on_request_play_special_sound(hurtBoxSoundId)
#	elif hitBoxSoundId != -1:
		#play specific sound specified by hitbox
#		_on_request_play_special_sound(hitBoxSoundId)
#	else:
#		hittingSFXPlayer.playRandomSound() #play default random sound

#func playOnHitSound(hurtBoxSoundId,hitBoxSoundId):
	
func playOnHitSound(hurtBox,hitBox): 

	
	if hurtBox == null or hitBox == null:
		hittingSFXPlayer.playRandomSound() #play default random sound
		return 
	
	#check to see if the hitbox or hurtbox have a special sound to play		
	if hurtBox.heroSFXSoundId != -1:
		#play hero-specific sound specified by hurtbox
		_on_request_play_special_sound(hurtBox.commonSFXSoundId,HERO_SOUND_SFX)
	elif hurtBox.commonSFXSoundId != -1:
		#play universal sound specified by hurtbox
		_on_request_play_special_sound(hurtBox.commonSFXSoundId,COMMON_SOUND_SFX)
		
	#elif hitBox.commonSFXSoundId != -1:
		
	
	var attackerActionManager = hitBox.playerController.actionAnimeManager
	#var attackerSpriteAnime = attackerActionManager.getCurrentSpriteAnimation()
	#var attackerSpriteAnime = attackerActionManager.getCurrentSpriteAnimation()
	
	if hitBox.cmd == null:
		hittingSFXPlayer.playRandomSound() #play default random sound
		return
		
#	var attackType = -1
#	#*****************************#TODO: use the hitxboxe's command instead of current sprite id (which may change if hitbox belongs to projectile)
	#resolve the attack type using sprite id
	if attackerActionManager.isMeleeCommand(hitBox.cmd):
		_on_request_play_special_sound(MELEE_HIT_SOUND_ID,COMMON_SOUND_SFX)
	elif attackerActionManager.isSpecialCommand(hitBox.cmd):
		_on_request_play_special_sound(SPECIAL_HIT_SOUND_ID,COMMON_SOUND_SFX)
	elif attackerActionManager.isToolCommand(hitBox.cmd):
		_on_request_play_special_sound(TOOL_HIT_SOUND_ID,COMMON_SOUND_SFX)
		
	#check to see if the hitbox  have a special sound to play		
	elif hitBox.heroSFXSoundId != -1:
		#play hero-specific sound specified by hitBox
		_on_request_play_special_sound(hitBox.heroSFXSoundId,HERO_SOUND_SFX)
	elif hitBox.commonSFXSoundId != -1:
		#play universal sound specified by hitBox
		_on_request_play_special_sound(hitBox.commonSFXSoundId,COMMON_SOUND_SFX)

		
	else:
		hittingSFXPlayer.playRandomSound() #play default random sound
	#else:
	#	hittingSFXPlayer.playRandomSound() #play default random sound


func _on_player_attacked_clashed(otherHitboxArea, selfHitboxArea):
	#POWER HITBOXES won't make the projectil disapear
	#if selfHitboxArea.clashType == selfHitboxArea.CLASH_TYPE_POWER:
	#		return
			
	_on_request_play_special_sound(masterPlayerController.ATTACK_CLASH_SOUND_ID,COMMON_SOUND_SFX)
	#go into ending animation
	actionAnimationManager.playUserAction(actionAnimationManager.COMPLETION_ACTION_ID,facingRight,command)
	
	
	#print(str(self.get_parent()) + " player invincibility was hit")
	if otherHitboxArea == null:
		print("null hitbox hitting invicibiilty")
		return
	
#this is called when this player's invincibility frames were hit	
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_projectile_invincibility_was_hit(otherHitboxArea, selfInvincibilityboxArea):
	#do nothing, generally a projectile won't have invicibility frames
	#i leave it to subclasss to implement this
	pass
	
func _on_wall_collision(collider):
	
#	if behaviorType == BehaviorType.BASIC:
	 #play the completion animation, the projetile lifetime is comming to an end, 
	#it hit a wall
	if completeAnimationOnWallCollision:
		actionAnimationManager.playUserAction(actionAnimationManager.COMPLETION_ACTION_ID,facingRight,command)
	pass

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_projectile_was_hit(otherHitboxArea, selfHurtboxArea):
	#ignore this since projectiles shouldsn't be able to get hit
	pass
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_multi_tap_action_animation_partially_finished(currentSpriteAnimation,spriteFrame):
	pass
	
func _on_hitting_player(selfHitboxArea, otherHurtboxArea):
	#print(str(self.get_parent()) + " player landed a hit")
	#disable all remaining hitboxes, since we don't want to multi hit an oponent with same hitbox		
	#selfHitboxArea.get_parent().getSpriteAnimation().disableAllHitboxes()
	#hittingSFXPlayer.playRandomSound()
	#play sound of on hit
	#playOnHitSound(otherHurtboxArea.commonSFXSoundId,selfHitboxArea.commonSFXSoundId)
	if selfHitboxArea.playSoundSFX:
		playOnHitSound(otherHurtboxArea,selfHitboxArea)
	
	
	masterPlayerController.hittingPlayerInCornerPushAwayCheck(selfHitboxArea, otherHurtboxArea)
	
	#display the command type and direction particles to 
	#give a visual indication of move hit with
	if selfHitboxArea!= null:
		if selfHitboxArea.cmd != null:
			attackSFXContainer.displayCommandParticles( selfHitboxArea.cmd)
		#dislay a light to indicate hitting with attack type	
		#handleAttackTypeLightingSignaling(selfHitboxArea)
			
	#selfHitboxArea.spriteAnimation.disableAllHitboxes()
	masterPlayerController._check_on_block_autoparry_hit(selfHitboxArea, otherHurtboxArea)
	
	if completeAnimationOnHit:
		actionAnimationManager.playUserAction(actionAnimationManager.COMPLETION_ACTION_ID,facingRight,command)
	
func _on_action_animation_finished(spriteAnimationId):
	
	
	# projectile only has 1 startup aniamtion?
	if actionId2ndStartupAnimation == -1:		
	
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
	else: # projectile has a custom 2nd startup animation
		if spriteAnimationId == actionAnimationManager.COMPLETION_SPRITE_ANIME_ID:
		
			#last animation of projectli?
			
			destroy()
		elif spriteAnimationId == actionAnimationManager.STARTUP_SPRITE_ANIME_ID:
			actionAnimationManager.playUserAction(actionId2ndStartupAnimation,facingRight,command)
		elif spriteAnimationId == startup2AnimationId:
			
			actionAnimationManager.playUserAction(actionAnimationManager.ACTIVE_ACTION_ID,facingRight,command)
		elif spriteAnimationId == actionAnimationManager.ACTIVE_SPRITE_ANIME_ID:		
			#the active animation litetime has ended without hitting player?
			
			actionAnimationManager.playUserAction(actionAnimationManager.COMPLETION_ACTION_ID,facingRight,command)
		else:
			print("warning, unknown projectil sprite id ("+spriteAnimationId+") finished, destroying projectil... ") 
			destroy()
func _on_hitting_invincible_player(selfHitboxArea, otherHurtboxArea):
	
	
	var sa = otherHurtboxArea.spriteAnimation
	#HITTIN auto riposting opponent?
	if sa.id == masterPlayerController.opponentPlayerController.actionAnimeManager.AUTO_RIPOST_SPRITE_ANIME_ID:
	#playOnHitSound(otherHurtboxArea,selfHitboxArea)
	
	#here, don't do hitfreeze or any disabling of hitboxes.
	#the player controller's _on_player_invincibility_was_hitfunction will deal with it
		actionAnimationManager.playUserAction(actionAnimationManager.COMPLETION_ACTION_ID,facingRight,command)

#starts the projectile
func fire():
	
	if not disableSkinModuleOverride:
		if masterPlayerController is preload("res://PlayerController.gd"):
			activeNodeSprite.self_modulate.r = masterPlayerController.kinbody.activeNodeSprite.self_modulate.r
			activeNodeSprite.self_modulate.b = masterPlayerController.kinbody.activeNodeSprite.self_modulate.b
			activeNodeSprite.self_modulate.g = masterPlayerController.kinbody.activeNodeSprite.self_modulate.g
			
	
	unpauseAnimation() #consider putting this in fire(), since it'll unpause collision management and movement
	movementAnimationManager.set_physics_process(true)
	collisionHandler.set_physics_process(true)
	#make sure to face appropriate direction
	var newScale = Vector2(1,1)
	if not self.facingRight:
		newScale.x = newScale.x*(-1)
	
	active_nodes.set_scale(newScale)
	
	self.visible = true
	
	#play the startup animation to start the projectil animation
	#actionAnimationManager.playUserAction(actionAnimationManager.STARTUP_ACTION_ID,facingRight,command)
	actionAnimationManager.playUserAction(startingActionId,facingRight,command)
	
	
func destroy():
	deactivate()
	spriteSFXNode.deactivateAll()
	#make sure to unpause projectile fi destroyed in hitfreeze
	#this way projectile won't be frozen when fired again
	#unpauseAnimation() #consider putting this in fire(), since it'll unpause collision management and movement
	hideLighting()
	emit_signal("remove_magnifying_glass",self)
	emit_signal("destroyed",self)

	#make the whoel node disapear, it should appear vanished
	
	
	#delete this node in 2 seconds
	#destroyTimer.wait_time = 2
	#destroyTimer.start()
	pass

func deactivate():
	self.visible = false
	active_nodes.deactivateAll()
	if behaviorType == BehaviorType.PUSHES:
		#unlink the pushing syncrhonization between any object, about to delete this object
		movementAnimationManager.stopPushing()
	
	movementAnimationManager.stopAllMovement()
	movementAnimationManager.set_physics_process(false)
	collisionHandler.set_physics_process(false)
	
	if spriteAnimationManager.currentAnimation != null:
		spriteAnimationManager.currentAnimation.stop()	
		
func _on_hit_freeze_finished():
	unpauseAnimation()
	
	inHitFreeze = false
	hideLighting()
	
	
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
#func startHitFreeze(duration):
	hideLighting()
	inHitFreeze = true
	pauseAnimation()
	
	
func hideLighting():
	meleeAttackLight.visible=false
	specialAttackLight.visible=false
	toolAttackLight.visible=false
func pauseAnimation():
	actionAnimationManager.pauseAnimation()
	
func unpauseAnimation():
	actionAnimationManager.unpauseAnimation()

			
# warning-ignore:unused_argument
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS

	pass

func my_is_on_floor():
	return not collisionHandler.wasInAir

# warning-ignore:unused_argument
func _on_land():
	#inAir = false
	pass
	
func _on_left_ground():
	#inAir = true
	pass
	

#called when requesting a special effects sound (as opposed to standard hitting sounds)
#to be played
#func _on_request_play_special_sound(specialSFXId):
	#specialSFXSoundPlayer.playSound(specialSFXId)
	

#called when requesting a special effects sound (as opposed to standard hitting sounds)
#to be played
#func _on_request_play_special_sound(soundId,soundType):
	
#	if soundType == COMMON_SOUND_SFX:
#		commonSFXSoundPlayer.playSound(soundId)
#	elif soundType == HERO_SOUND_SFX:
#		heroSFXSoundPlayer.playSound(soundId)

#called when requesting a special effects sound (as opposed to standard hitting sounds)
#to be played
func _on_request_play_special_sound(soundId,soundType,soundVolumeOffset=null):
	
	#if muteSoundSFX:
	#	return
		
	if soundType == COMMON_SOUND_SFX:
		
		if soundVolumeOffset!= null:
			commonSFXSoundPlayer.changeVolume(commonSFXSoundDefaultVolume+soundVolumeOffset)#change voluem for this sound clip
		else:
			commonSFXSoundPlayer.changeVolume(commonSFXSoundDefaultVolume)#default volume for non-specified sound clkip
		
		commonSFXSoundPlayer.playSound(soundId)
	elif soundType == HERO_SOUND_SFX:
		if soundVolumeOffset!= null:
			heroSFXSoundPlayer.changeVolume(soundId,heroSFXSoundDefaultVolume+soundVolumeOffset)#change voluem for this sound clip
		else:
			heroSFXSoundPlayer.changeVolume(soundId,heroSFXSoundDefaultVolume)#default volume for non-specified sound clkip
		heroSFXSoundPlayer.playSound(soundId)
		
	
func _on_following_special_object_type_hook(followMvm):
	pass
	

#duplicate logic as kinmematicbody 2d
func displayAttackTypeLighting(attackTypeIx,pos,xScale,yScale,angle):
	
	return 
	#if not lightingEffectsEnabled:
	#	return 
		
	#var lightToTurnOn = null
	#if attackTypeIx == GLOBALS.MELEE_IX:
#		meleeAttackLight.visible=true
#		lightToTurnOn=meleeAttackLight
#		specialAttackLight.visible=false
#		toolAttackLight.visible=false
#	elif attackTypeIx == GLOBALS.SPECIAL_IX:
#		lightToTurnOn=specialAttackLight
#		meleeAttackLight.visible=false
#		specialAttackLight.visible=true
#		toolAttackLight.visible=false
#	elif attackTypeIx == GLOBALS.TOOL_IX:
#		lightToTurnOn=toolAttackLight
#		meleeAttackLight.visible=false
#		specialAttackLight.visible=false
#		toolAttackLight.visible=true
#	else:
		#no type to display
#		pass 

#	if lightToTurnOn != null:
		#match the light to hitbox size
#		lightToTurnOn.position = pos
#		lightToTurnOn.scale.x=xScale
#		lightToTurnOn.scale.y=yScale
#		lightToTurnOn.rotation_degrees = angle

#similar logic as kinematoc2d
func handleAttackTypeLightingSignaling(selfHitboxArea):
				#logic for lighting up hitbox with color of hitbox
	#for now just use 1st (should work for most moves) rectangle collisiosn shpae of a hitbox
	if selfHitboxArea != null and selfHitboxArea.emitsAttackSFXSignal:
		#if selfHitboxArea.cmd != null:
	#if masterPlayerController.isCommandMeleeSpecialTool(selfHitboxArea.cmd):
		#iterate all the collision shapes, and offset their position
		#to match our sprite offset 
		for c in selfHitboxArea.get_children():
			
			if c is CollisionShape2D:
				var shape = c.shape
				var xScale = 0
				var yScale = 0
				var angle = c.rotation_degrees
					
				if shape is RectangleShape2D:
					var extent = shape.get_extents()
					
					xScale = extent.x
					yScale = extent.y
					
					
				elif shape is CircleShape2D:
					xScale = shape.radius
					yScale = shape.radius
				var attackTypeIx = -1
				var cmd = selfHitboxArea.cmd
				if selfHitboxArea.cmd == null:
					#attackTypeIx=null
					attackTypeIx=GLOBALS.OTHER_IX
				elif masterPlayerController.actionAnimeManager.isMeleeCommand(selfHitboxArea.cmd):
					attackTypeIx=GLOBALS.MELEE_IX
				elif masterPlayerController.actionAnimeManager.isSpecialCommand(selfHitboxArea.cmd):
					attackTypeIx=GLOBALS.SPECIAL_IX
				elif masterPlayerController.actionAnimeManager.isToolCommand(selfHitboxArea.cmd):
					attackTypeIx=GLOBALS.TOOL_IX
				else:
					attackTypeIx=GLOBALS.OTHER_IX
				
				#displayAttackTypeLighting(attackTypeIx,c,xScale,yScale,angle)
				masterPlayerController.emit_signal("display_attack_lighting",attackTypeIx,cmd,c,xScale,yScale,angle,spriteCurrentlyFacingRight,selfHitboxArea.damage)
				return
					

func _on_ceiling_collision(collider):
	pass
func _on_left_wall():
	pass
func _on_started_bouncing():
	pass

func _on_stopped_bouncing(rc):
	pass

func _on_bounced():
	pass
					

func getCenter():
	var extent = bodyBox.get_shape().extents
	extent.x = extent.x/2.0
	extent.y = extent.y/2.0
	return bodyBox.global_position + extent

func canCurrentSpriteFramePreventBounce():
	return actionAnimationManager.spriteAnimationManager.canCurrentSpriteFramePreventBounce()
	
#when match is restarted/started, this is called
#func restart_hook():
#func _on_done_loading_game():
	
#	if not soundInitiated:
#		soundInitiated=true
#		heroSFXSoundPlayer.init(masterPlayerController.heroName)
	
#	#proectile inactive by default
#	deactivate()
	
func getMovementAnimationManager():
	return actionAnimationManager.movementAnimationManager
	
	
func getspriteCurrentlyFacingRight():
	return spriteCurrentlyFacingRight
	
#func displayLocalTemporarySprites(tmpSprite):
	
#	spriteSFXNode.displayLocalTemporarySprites(tmpSprite,inHitFreeze)
	
	#if not spriteCurrentlyFacingRight:
	#	spawnPoint.x = spawnPoint.x * (-1)


	
func displayLocalTemporarySprites(tmpSprites):
	spriteSFXBuffer.clear()
	opponentSpriteSFXBuffer.clear()
	
	for tmpSprite in tmpSprites:
		#display on opponent?
		if tmpSprite.opponentIsParent:
			opponentSpriteSFXBuffer.append(tmpSprite)
		else:
			spriteSFXBuffer.append(tmpSprite)
		
	
	#display sprite on player
	if spriteSFXBuffer.size() >0:
		#spriteSFXNode.displayLocalTemporarySprites(spriteSFXBuffer,inHitFreeze)
		spriteSFXNode.displayLocalTemporarySprites(spriteSFXBuffer,inHitFreeze)
		
	
	#display sprite this player imposed onto opponent
	if opponentSpriteSFXBuffer.size() >0:
		#playerController.opponentPlayerController.kinbody.spriteSFXNode.displayLocalTemporarySprites(opponentSpriteSFXBuffer,inHitFreeze)
		masterPlayerController.opponentPlayerController.kinbody.spriteSFXNode.displayLocalTemporarySprites(opponentSpriteSFXBuffer,inHitFreeze)
	#if not spriteCurrentlyFacingRight:
	#	spawnPoint.x = spawnPoint.x * (-1)
	


	

func _on_inactive_projectile_instanced(proj,projectileScenePath):
	#INITIALIZE the projectiles' follow movement
	
	proj.initFollowMovements()
	
	if not proj.has_node("cachedResources"):
		return

	
	if not kinbody.has_node("cachedResources"):
		return
		
			
	#migrate all the cached projectile resources to cached resoruces of player node
	# to avoid having to load the resource each time projectile fired
	var projCachedResources = proj.get_node("cachedResources")
	
	var playerCachedResources = kinbody.get_node("cachedResources")
	
	
	#re parent the resources
	proj.remove_child(projCachedResources)
	playerCachedResources.add_child(projCachedResources)
	projCachedResources.set_owner(playerCachedResources)

#to be overridden by subcalsses, returns true when can create projectile, and false
#to avoid create a projectile
func readyToCreateProjectileHook(projectileFrame):
	return true
	
func _on_create_projectile(projectile,spawnPoint):
	
	#have the player's kinbody signal projectile creation, but we give our selves as reference
	masterPlayerController.kinbody.__on_create_projectile_helper(projectile,spawnPoint,self)
	
	#emit_signal("create_projectile",projectile,spawnPoint)	

func canChangeSpriteFacingInAir():
	return true
	
	

func faceDirection(_facingRight):
	
	var changeFacingFlag = _facingRight != spriteCurrentlyFacingRight
	
	if _facingRight:
		
		active_nodes.set_scale(Vector2(1,1))
		
		#facingRight = true
		spriteCurrentlyFacingRight = true
		bodyBox.facingRight = true
	else:
		
		active_nodes.set_scale(Vector2(-1,1))
		
		spriteCurrentlyFacingRight = false
		bodyBox.facingRight = false
	
	if changeFacingFlag:
		emit_signal("changed_sprite_facing",_facingRight)