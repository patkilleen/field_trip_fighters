extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal finished
signal create_projectile
signal request_play_sound #parameter is id of special sound sfx
signal disabled_body_box
signal enabled_body_box
signal platform_drop
signal pushable_frame_flag
signal canPush_frame_flag
signal activated

const FRAME_ACTIVATION_NOTIFIER_RESOURCE= preload("res://frameActivationNotifier.gd")
enum FrameType{##same as globals
	NEUTRAL,
	STARTUP,
	ACTIVE,
	RECOVERY	
}

enum LandingType{
	LAGLESS,
	LANDING_LAG,
	CONTINUE_ANIMATION
}

enum CommandType{
	SINGLE,
	MULTI_TAP
}


enum CameraBehavior{
	ATTACHED,
	DETTACHED,
	SMOOTH_FOLLOW
}

#number of frames until deactivated
export (int) var duration = 1 setget setDuration,getDuration
var durationInSeconds = -1

export (Texture) var texture = null
#export (NodePath) var targetActiveNodePath = NodePath("../../../../../../active-nodes")

var targetSprite = null
var targetBodyBox = null
var targetCollisionAreaNode = null
var targetActiveNodes= null

#export (NodePath) var targetCollisionAreaNodePathNew = NodePath("../../../../../../active-nodes/Sprite/collisionAreas")
export (int, FLAGS, "Jump","F-Jump", "B-Jump","Ground Idle","Ground F-Move","Ground B-Move" ,"Crouch","N-Melee","N-Special","N-Tool","B-Special","auto ripost","Air Idle","Air F-Move","Air B-Move", "Air F-Dash", "Air B-Dash","Air-Melee","Air-Special","Air-Tool","Fast Fall","Air Move Stop", "Air auto ripost","F-Special","D-Melee","U-Tool","D-Tool","F-Tool","B-Tool","U-Special","F-Melee","B-Special") var autoCancels = 0
export (int, FLAGS, "D-Special","B-Melee","U-Melee","F-Ground-Dash","B-Ground-Dash", "Air-grab","grab","crouching-hold-back-block","Platform Drop", "Leave Platform Keep Animation","F-dash crouch cancel","non-cancelable f-ground-dash","non-cancelable b-ground-dash","apex-of-jump-only fast-fall","standing-hold-back-block","air-hold-back-block","standing-push-block","air-push-block","Air Jump","Air F-Jump", "Air B-Jump","b-dash-Crouch-cancel", "basic crouch cancel", "non-GDC jump","non-GDC F-jump", "non-GDC b-jump") var autoCancels2 = 0
export (int, FLAGS, "Jump","F-Jump", "B-Jump","Ground Idle","Ground F-Move","Ground B-Move" ,"Crouch","N-Melee","N-Special","N-Tool","B-Special","auto ripost","Air Idle","Air F-Move","Air B-Move", "Air F-Dash", "Air B-Dash","Air-Melee","Air-Special","Air-Tool","Fast Fall","Air Move Stop", "Air auto ripost","F-Special","D-Melee","U-Tool","D-Tool","F-Tool","B-Tool","U-Special","F-Melee","B-Special") var autoCancelsOnHit = 0
export (int, FLAGS, "D-Special","B-Melee","U-Melee","F-Ground-Dash","B-Ground-Dash","Air-grab","grab","crouching-hold-back-block", "Platform Drop","Leave Platform Keep Animation", "F-dash crouch cancel","non-cancelable f-ground-dash","non-cancelable b-ground-dash","apex-of-jump-only fast-fall","standing-hold-back-block","air-hold-back-block","standing-push-block","air-push-block","Air Jump","Air F-Jump", "Air B-Jump","b-dash-Crouch-cancel","basic crouch cancel", "non-GDC jump","non-GDC F-jump", "non-GDC b-jump") var autoCancelsOnHit2 = 0
export (int, FLAGS, "Jump","F-Jump", "B-Jump","Ground Idle","Ground F-Move","Ground B-Move" ,"Crouch","N-Melee","N-Special","N-Tool","B-Special","auto ripost","Air Idle","Air F-Move","Air B-Move", "Air F-Dash", "Air B-Dash","Air-Melee","Air-Special","Air-Tool","Fast Fall","Air Move Stop", "Air auto ripost","F-Special","D-Melee","U-Tool","D-Tool","F-Tool","B-Tool","U-Special","F-Melee","B-Special") var abilityAutoCancelsOnHit = 0
export (int, FLAGS, "D-Special","B-Melee","U-Melee","F-Ground-Dash","B-Ground-Dash","Air-grab","grab","crouching-hold-back-block", "Platform Drop","Leave Platform Keep Animation", "F-dash crouch cancel","non-cancelable f-ground-dash","non-cancelable b-ground-dash","apex-of-jump-only fast-fall","standing-hold-back-block","air-hold-back-block","standing-push-block","air-push-block","Air Jump","Air F-Jump", "Air B-Jump","b-dash-Crouch-cancel","basic crouch cancel", "non-GDC jump","non-GDC F-jump", "non-GDC b-jump") var abilityAutoCancelsOnHit2 = 0
export (int, FLAGS, "Jump","F-Jump", "B-Jump","Ground Idle","Ground F-Move","Ground B-Move" ,"Crouch","N-Melee","N-Special","N-Tool","B-Special","auto ripost","Air Idle","Air F-Move","Air B-Move", "Air F-Dash", "Air B-Dash","Air-Melee","Air-Special","Air-Tool","Fast Fall","Air Move Stop", "Air auto ripost","F-Special","D-Melee","U-Tool","D-Tool","F-Tool","B-Tool","U-Special","F-Melee","B-Special") var landingLagAutoCancels = 0
export (int, FLAGS, "D-Special","B-Melee","U-Melee","F-Ground-Dash","B-Ground-Dash","Air-grab","grab","crouching-hold-back-block", "Platform Drop","Leave Platform Keep Animation", "F-dash crouch cancel","non-cancelable f-ground-dash","non-cancelable b-ground-dash","apex-of-jump-only fast-fall","standing-hold-back-block","air-hold-back-block","standing-push-block","air-push-block","Air Jump","Air F-Jump", "Air B-Jump", "b-dash-Crouch-cancel","basic crouch cancel", "non-GDC jump","non-GDC F-jump", "non-GDC b-jump") var landingLagAutoCancels2 = 0
export (int, FLAGS, "Jump","F-Jump", "B-Jump","Ground Idle","Ground F-Move","Ground B-Move" ,"Crouch","N-Melee","N-Special","N-Tool","B-Special","auto ripost","Air Idle","Air F-Move","Air B-Move", "Air F-Dash", "Air B-Dash","Air-Melee","Air-Special","Air-Tool","Fast Fall","Air Move Stop", "Air auto ripost","F-Special","D-Melee","U-Tool","D-Tool","F-Tool","B-Tool","U-Special","F-Melee","B-Special") var landingLagAutoCancelsOnHit = 0
export (int, FLAGS, "D-Special","B-Melee","U-Melee","F-Ground-Dash","B-Ground-Dash","Air-grab","grab","crouching-hold-back-block", "Platform Drop","Leave Platform Keep Animation", "F-dash crouch cancel","non-cancelable f-ground-dash","non-cancelable b-ground-dash","apex-of-jump-only fast-fall","standing-hold-back-block","air-hold-back-block","standing-push-block","air-push-block","Air Jump","Air F-Jump", "Air B-Jump", "b-dash-Crouch-cancel","basic crouch cancel", "non-GDC jump","non-GDC F-jump", "non-GDC b-jump") var landingLagAutoCancelsOnHit2 = 0
export (int, FLAGS, "Jump","F-Jump", "B-Jump","Ground Idle","Ground F-Move","Ground B-Move" ,"Crouch","N-Melee","N-Special","N-Tool","B-Special","auto ripost","Air Idle","Air F-Move","Air B-Move", "Air F-Dash", "Air B-Dash","Air-Melee","Air-Special","Air-Tool","Fast Fall","Air Move Stop", "Air auto ripost","F-Special","D-Melee","U-Tool","D-Tool","F-Tool","B-Tool","U-Special","F-Melee","B-Special") var autoCancelsOnHitAllAnimation = 0 #TODO: IMPLEMENT THIS. on hit, for entire animation, can autocancel on hit
export (int, FLAGS, "D-Special","B-Melee","U-Melee","F-Ground-Dash","B-Ground-Dash","Air-grab","grab","crouching-hold-back-block", "Platform Drop","Leave Platform Keep Animation", "F-dash crouch cancel","non-cancelable f-ground-dash","non-cancelable b-ground-dash","apex-of-jump-only fast-fall","standing-hold-back-block","air-hold-back-block","standing-push-block","air-push-block","Air Jump","Air F-Jump", "Air B-Jump","b-dash-Crouch-cancel","basic crouch cancel", "non-GDC jump","non-GDC F-jump", "non-GDC b-jump") var autoCancelsOnHitAllAnimation2 = 0 #TODO: IMPLEMENT THIS
export (Vector2) var sprite_Offset = Vector2(0,0)
#0 SINCE THERE IS A BUG WITH DEFAULT ENUM EXPORT VALUES (IT WILL BE NULL IF USE THE ACTUAL ENUM)
export (LandingType) var landing_lag = 0 
export (CommandType) var commandType = 0 #0 for single tap
export (int) var on_multi_tap_incomplete_action_id = -1 

#by default, if the parent is not barcancelable, it overrides children's 
#cancelable flag. If the parent is cancelable, then a child may choose
#to explicitly be cancelable or not
export (bool) var barCancelable = true

#true when opponent can push you in this sprite frame and 
#false when cannot be pushed
export (bool) var pushable=true

#true when you can push opponent, false
#otherwise
export (bool) var canPush=true

export (bool) var canUseBufferedCommands = true

#watch out. Enabling this and having gravity -> player falls into the abyss
#gotta really make sure player won't end up on the other side of false walls, under floor, or above ceiling
export (bool) var disableBodyBox = false 

#true means false walls can be collided with. false means you phase through the false wall
export (bool) var interactWithFalseWalls = true 

#when false, can run off the platform horizontally, like walking/jumpin; when true, don't let
#the animation exceed the platfomr (like ground dash)
export (bool) var disableRunOffPlatform = false

#when true, your movement is unaffected when you leave platform (like jump, for example)
#when false, your momentum is halted when you leave the platform (like walking off to stop speed boost)
export (bool) var keepMomentumWhenLeavePlatform = false
export (bool) var keepMomentumOnLand = false


#when false, don't drop from platform, when true, signal to drop
export (bool) var dropFromPlatform = false

#the id of the sound effect to play upon starting the frame
#-1 means no sound is played
export (int) var commonSoundSFXId = -1
export (int) var heroSoundSFXId = -1

export (int) var commonSFXSoundVolumeOffset = 0#0 means no change in volume
export (int) var heroSFXSoundVolumeOffset = 0 #0 means no change in volume

export (FrameType) var type = 0


export (CameraBehavior) var cameraBehavior = 0

export (bool) var canRipost = true
#export (bool) var canCounterRipost = true

export (bool) var preventBouncing = false

export (float) var rotation_degrees = 0 #the angle the sprite and collision boxes will be rotated

export (bool) var keepAirMomentumOnAbilityCancel = false #current momentum put onto poppable mvm stack on ability cancel when true
export (bool) var ignoreInsideOpponentCornerPushAway=false #false means merging into opponents space in corner will push you away, true means ignore the ellastic corner contest effect 
export (float) var hittingCornerPushAwayRayCastLen=50 # the length of the hitting in corner push away ray cast (less than 0 means default value)
 
#variables used to offset the false walls for false wall/ceiling manipulation
#positive  offset means false walls behave as if player is further forward
#negative  offset means false walls behave as if player is further back
#so to raise the ceiling for a nice high arc anti air, making falseCeilingOffset a smaller  value would do the trick
export (float) var falseWallOffset = 0
export (float) var falseCeilingOffset = 0	

#similar to false wall/ceiling offset but for camera manipulation
export (Vector2) var cameraPositionOffset = Vector2(0,0)

	
var GLOBALS = preload("res://Globals.gd")

var speed = null
var area2ds = []
#var numberOfFrames = 0
var ellapsedSeconds = 0.0
var frameSprite = null
var bodyBox = null
var playerController=null

var hitboxes = []
var hurtboxes = []
var selfonly_hitboxes = []
var selfonly_hurtboxes = []
var proximityGuardAreas = []
var collisionShapes = []

var tmpLocalSFXSprites = []
var tmpGlobalSFXSprites = []
#parent of this frame
var spriteAnimation setget setSpriteAnimation,getSpriteAnimation


var spriteAnimationManager = null

#true when already hit so hitboxes disabled, false otherwise
var hitboxesDisabled = false

var selfOnlyHitboxesDisabled = false

var projectileInstancer =null

var forceProximityGuardDisable = false

var activeFlag = false

var frameActivationNotifier = null


#var collisionShapeBoundingBox = null
func _ready():
	set_physics_process(false)
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	#for now bounding box is 0 sized
	#collisionShapeBoundingBox = Rect2(0,0,0,0)
	
	
	#TODO: REMOVE autoability canceling from game
	#for now just 0 the autoability cancel options
	abilityAutoCancelsOnHit=0
	abilityAutoCancelsOnHit2=0
	#autoCancelsOnHitAllAnimation=0
	#autoCancelsOnHitAllAnimation2=0
	activeFlag = false
	for c in self.get_children():
		if c is preload("res://SpriteCollisionArea.gd"):
			
			#c.monitoring = false
			#c.monitorable = false
			area2ds.append(c)
			
			#give reference of this frame to collision area
			c.spriteFrame = self
					
			#iterate all the collision shapes, and offset their position
			#to match our sprite offset 
			for shape in c.get_children():
				if shape is CollisionShape2D:
					
					#does the area support internal  offseting? ie, can offset in addition to spriteframe offset?
					#good for aligning collision boxes with another spriteframe with a different offset
					#only apply offseting if sprite frame doesn't support override of offset
					if not c.overrideSpriteFrameOffset:
						shape.position += sprite_Offset
						
					else:
						shape.position +=  c.offset
					shape.visible =true
					
					#only append shape if not already in array 
					#(since some sprite frames share shape objects)
					var isFound = false
					for cs in collisionShapes:
						if cs == shape:
							isFound = true
							break
					if not isFound:	
						collisionShapes.append(shape)
			if c is preload("res://HitboxArea.gd"):
				
				if c.selfOnly:
					selfonly_hitboxes.append(c)
				else:
					hitboxes.append(c)
					
				c.adjustOnHitSFXSpriteOffsets(sprite_Offset)
				
			elif c is preload("res://HurtboxArea.gd"):
				if c.selfOnly:
					selfonly_hurtboxes.append(c)
				else:
					hurtboxes.append(c)
			elif c is preload("res://ProximityGuardArea.gd"):
				proximityGuardAreas.append(c)
				
							
							
					
				
		if c is Sprite:
			frameSprite	 = c
		elif c is CollisionShape2D:
			bodyBox = c
		elif c is preload("res://spriteFrameTempSFXSprites.gd"):
			
			
			#sprite the will be local to player (child of player)
			if c.local_coords:
				#populate the sfx of the sprite
				for tmpSprite in c.get_children():
					
					if tmpSprite.overrideSpriteFrameOffset:
						tmpSprite.position += tmpSprite.myoffset
					else:
						tmpSprite.position += sprite_Offset
					tmpLocalSFXSprites.append(tmpSprite)
			else:# global coordinates that will be children of stage
				#populate the sfx of the sprite
				for tmpSprite in c.get_children():
					if tmpSprite.overrideSpriteFrameOffset:
						tmpSprite.position += tmpSprite.myoffset
					else:
						tmpSprite.position += sprite_Offset
					tmpGlobalSFXSprites.append(tmpSprite)
				
		elif c is preload("res://projectiles/projectileInstancer.gd"):
			projectileInstancer= c
			projectileInstancer.connect("create_projectile",self, "_on_create_projectile")	
		elif c is FRAME_ACTIVATION_NOTIFIER_RESOURCE:
			frameActivationNotifier = c

	deactivateCollisionShapes()
	
	

func setDuration(d):
	duration =d
	durationInSeconds =  GLOBALS.SECONDS_PER_FRAME * d
	
func getDuration():
	return duration

func reset():
	activeFlag = false
	for a in area2ds:
		a.reset()

	ellapsedSeconds = 0.0
	pass
func init(sprite,collisionAreas,bodyBox,activeNodes,_playerController):
	activeFlag = false
	#reset any sprite offeset used while developing
	#the position will be applied upon frame activation
	sprite.position = Vector2(0,0)
	
	#loads the nodes into memeroy once, to avoid repeated lookup	
	#targetSprite = get_node(targetSpritePath)
	targetSprite = sprite
	 
	forceProximityGuardDisable = false
	if projectileInstancer!=null:
		projectileInstancer.init(_playerController,self.get_parent())
	#don't load body box if it doesn't exist
	#if targetBodyBoxPath != null and bodyBox != null:
	#	targetBodyBox = get_node(targetBodyBoxPath)	
	targetBodyBox = bodyBox
	
	#targetCollisionAreaNode = get_node(targetCollisionAreaNodePath)
	targetCollisionAreaNode =collisionAreas
	
	targetActiveNodes = activeNodes
	
	playerController = _playerController
	
	#iterate over every non-self only hitbox, and connect 
	#any special bounce movement to hitstun change, as
	#it's necessary to reset number of bounces (neccesary
	#for limiting number of bounces)
	for hb in hitboxes:
		#special bounce animation exists?
		if hb.specialBounceMvmAnimations != null:
			
			playerController.get_node("PlayerState").connect("changed_in_hitstun",hb.specialBounceMvmAnimations,"_on_player_hitstun_changed")
		hb.init(_playerController,get_parent())
	
			
			
	var allTmpSprites = [tmpLocalSFXSprites,tmpGlobalSFXSprites]
	#include the hitbox sprite effects too
	for hb in hitboxes:
		if hb.tmpLocalSFXSprites.size()>0:			
			allTmpSprites.append(hb.tmpLocalSFXSprites)
		if hb.tmpGlobalSFXSprites.size()>0:			
			allTmpSprites.append(hb.tmpGlobalSFXSprites)
			
	for tmpSprites in allTmpSprites:
		#make sure the temporary sprite inherit the player's modulation unless specified otherwise
		for tmpSprite in tmpSprites:
			
			if not tmpSprite.disableSkinModuleOverride:
				
				tmpSprite.modulate.r = playerController.kinbody.activeNodeSprite.self_modulate.r
				tmpSprite.modulate.b = playerController.kinbody.activeNodeSprite.self_modulate.b
				tmpSprite.modulate.g = playerController.kinbody.activeNodeSprite.self_modulate.g
				
	
	
func set_sprite_animation_manager(spriteAnimManager):
	spriteAnimationManager = spriteAnimManager	
	
	var allTmpSprites = [tmpLocalSFXSprites,tmpGlobalSFXSprites]
	
	#include the hitbox sprite effects too
	for hb in hitboxes:
		if hb.tmpLocalSFXSprites.size()>0:			
			allTmpSprites.append(hb.tmpLocalSFXSprites)
		if hb.tmpGlobalSFXSprites.size()>0:			
			allTmpSprites.append(hb.tmpGlobalSFXSprites)
	
	
	for tmpSprites in allTmpSprites:
		#make sure the temporary sprite inherit the player's modulation unless specified otherwise
		for tmpSprite in tmpSprites:
	
			tmpSprite.spriteAnimationManager=spriteAnimationManager
			
	#do the same for all the hitboxes
	
		
#stores a command in all the hitbox and hurtbox areas
func store_command(_cmd):
	for area in hitboxes:
		area.cmd = _cmd
	for area in hurtboxes:
		area.cmd = _cmd
	for area in selfonly_hitboxes:
		area.cmd = _cmd
	for area in selfonly_hurtboxes:
		area.cmd = _cmd	
	for area in proximityGuardAreas:	
		area.cmd = _cmd
	
#stores facing right flag in all the hitbox and hurtbox areas
func storeFacingRightWhenPlayed(_facingRightWhenPlayed):
	
	for area in hitboxes:
		area.facingRightWhenPlayed = _facingRightWhenPlayed
	for area in hurtboxes:
		area.facingRightWhenPlayed = _facingRightWhenPlayed
		
func getSpriteAnimation():
	#return self.get_parent()
	return spriteAnimation
	
func setSpriteAnimation(sanime):
	spriteAnimation = sanime
	
	#propogate the sprite animation to children area collisions
	for c in area2ds:
		c.spriteAnimation = spriteAnimation
		
#param disableHitboxes: flag that's true when hitboxes are disabled, and false when not
#param cmd: command used to start this sprite animation
func activate(disableHitboxes,disableSelfOnlyHitboxes,_forceProximityGuardDisable,disableActiveFrameSet):
	#hittingWithJumpCancelableHitbox = false
	activeFlag = true
	durationInSeconds =  GLOBALS.SECONDS_PER_FRAME * duration
	hitboxesDisabled=disableHitboxes
	forceProximityGuardDisable = _forceProximityGuardDisable
	selfOnlyHitboxesDisabled=disableSelfOnlyHitboxes
	
	#numberOfFrames = 0
	ellapsedSeconds = 0.0
	#for a in area2ds:
	#	a.activate()
	
	
	_hitboxActivationHelper(disableHitboxes,hitboxes,disableActiveFrameSet)
			
	_hitboxActivationHelper(disableSelfOnlyHitboxes,selfonly_hitboxes,false)
	
	#only activate proximity guard areasboxes if not disabling hitboxes
	#if not disableHitboxes:
		#for hb in proximityGuardAreas:
		#	hb.activate()

	#promity guard always neabled, because it's precense implies a next hit is coming	
	#proximity guard is enabled only when there exists a hitbox or an upcoming hitbox that will be active
	if not disableHitboxes:
		
		if not forceProximityGuardDisable:
			for pg in proximityGuardAreas:
				pg.activate()					
	else:
				
		#otherwise, only activate the multihit hitboxes
		for pg in proximityGuardAreas:
			#only activate proximity guards that override the disable (should be set to true for multi hits)
			if pg.preventDisableOnHitboxHit and not forceProximityGuardDisable:				
				pg.activate()
				
	
	
			
	for hb in hurtboxes:
		hb.activate()
		
	
	for hb in selfonly_hurtboxes:
		hb.activate()
		
	
	if targetBodyBox != null:
		#here we may disable body box (dangerous, but careful with this. )
		if (disableBodyBox):
			#targetBodyBox.set_disabled(true)
			emit_signal("disabled_body_box")
		else:
			#targetBodyBox.set_disabled(false)
			emit_signal("enabled_body_box")
		
	#adjust the active nodes to be relative to sprite offset
	changeActiveNodesRelativePosition()	
	
	targetSprite.set_texture(texture)
	
	
	#emit_signal("new_sprite_texture",texture)
	
	#now move the collision ares over (remove children, thenn add to active colision nodes)
	#var collisionAreas = get_node(targetCollisionAreaNodePath)
	
	#offset the colission shpaes too
	#for c in area2ds:
	#	if self.is_a_parent_of(c):
	#		self.remove_child(c)
	#		targetCollisionAreaNode.add_child(c)
	#		c.set_owner(targetCollisionAreaNode)
	#targetActiveNodes.activate(area2ds)
	targetActiveNodes.activateHitboxes(hitboxes)
	targetActiveNodes.activateProximityGuardAreas(proximityGuardAreas)
	targetActiveNodes.activateHurtboxes(hurtboxes)
	targetActiveNodes.activateSelfOnlyHitboxes(selfonly_hitboxes)
	targetActiveNodes.activateSelfOnlyHurtboxes(selfonly_hurtboxes)
	
	#rorate the sprite (and collisiosn boxes and other special effects)
	applyRotationToActiveNodes()
	
	#spriteAnimationManager.kinbody.spriteSFXNode.displayLocalTemporarySprites(tmpLocalSFXSprites)
	spriteAnimationManager.kinbody.displayLocalTemporarySprites(tmpLocalSFXSprites)
	
	
	set_physics_process(true)
	
	if dropFromPlatform:
		emit_signal("platform_drop")
		
	emit_signal("pushable_frame_flag",pushable)
	emit_signal("canPush_frame_flag",canPush)

	#a special sound to play with this frame?

	if heroSoundSFXId != -1:
		emit_signal("request_play_sound",heroSoundSFXId,playerController.HERO_SOUND_SFX,heroSFXSoundVolumeOffset)
	elif commonSoundSFXId != -1:
		emit_signal("request_play_sound",commonSoundSFXId,playerController.COMMON_SOUND_SFX,commonSFXSoundVolumeOffset)


	if projectileInstancer!= null:
		projectileInstancer.signalProjectileCreation()
	
	emit_signal("activated",self)
	
	
	#now, hadnle special case that a frame was actiavated and is already finished (if there is lag or
	#game is slowed down, may activate multiple frames in 1 tick)
	#if (duration > 0) and (GLOBALS.frame_duration_almost_equal(ellapsedSeconds,durationInSeconds) or ellapsedSeconds>=durationInSeconds):
	if (duration > 0) and GLOBALS.has_frame_based_duration_ellapsed(ellapsedSeconds,durationInSeconds):
	
		deactivate()
		emit_signal("finished")
	
	
	
func _hitboxActivationHelper(_disabledFlag,hitboxArray,disableActiveFrameSet):
	
	
	#only activate hitboxes if not disabling them
	if not _disabledFlag:
		for hb in hitboxArray:
			hb.activate()
			#hb.visible = true #for debuggin purposes, make collision boxes visible when debugging
			
	else:
		#otherwise, only activate the multihit hitboxes
		for hb in hitboxArray:
			
			#multi hit hitboxes only activated if we didn't hit with them
			#for current active sprite frame set (two multihit frames in a counts as 
			#a single multi hit. need to seperate multi hits by non activate frame to have them hit again)
			if hb.behavior == hb.BEHAVIOR_MULTI_HIT and not disableActiveFrameSet:
				hb.activate()
			elif hb.behavior == hb.BEHAVIOR_TRUE_MULTI_HIT: #hits regardless of if already hit for this active frame set
				hb.activate()	
				

	
	
func deactivateCollisionShapes():
	for a in area2ds:
		a.deactivate()
		
	
func deactivate():
	activeFlag = false
	#for a in area2ds:
	#	if targetCollisionAreaNode.is_a_parent_of(a):
	#		targetCollisionAreaNode.remove_child(a)
	#		self.add_child(a)
	#		a.set_owner(self)
	#targetActiveNodes.deactivateAll()
	deactivateCollisionShapes()
	set_physics_process(false)

	
func deactivateHitboxes():
	for a in hitboxes:
		a.deactivate()
	for a in proximityGuardAreas:
		a.deactivate()	

func deactivateSelfOnlyHitboxes():
	for a in selfonly_hitboxes:
		a.deactivate()		

#places the target body box relative to sprite offset
func applyRelativeBodyBoxPosition():
	pass
#	if targetBodyBox != null and bodyBox != null:
#		var newExtents =bodyBox.get_shape().extents
#		targetBodyBox.get_shape().set_extents(Vector2 (newExtents.x, newExtents.y ))
		#set new position cause the facing will affect position of body box
		#and body box not child of active nodes 
#		targetBodyBox.setNewPosition(Vector2 (bodyBox.position.x, bodyBox.position.y ))

	
#adjusts the active nodes to be positioned relative to sprite offset and bodybox offset
func changeActiveNodesRelativePosition():
	
	applyRelativeBodyBoxPosition()
	targetSprite.position = sprite_Offset
	
	
func _physics_process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	if not activeFlag:
		return				
		
	delta = delta*speed*spriteAnimationManager.globalSpeedMod

	#this changes sprite duration
	#finished (and not infinite frame duration?
	ellapsedSeconds = ellapsedSeconds + delta
	#if (duration > 0) and ellapsedSeconds >= durationInSeconds:
	#if (duration > 0) and (GLOBALS.frame_duration_almost_equal(ellapsedSeconds,durationInSeconds) or ellapsedSeconds>=durationInSeconds):
	if (duration > 0) and GLOBALS.has_frame_based_duration_ellapsed(ellapsedSeconds,durationInSeconds):
	
		deactivate()
		emit_signal("finished")
	
	#numberOfFrames = numberOfFrames +(1*speed* spriteAnimationManager.globalSpeedMod)
	
	
func hasHoldBackToBlockHurtboxes():
	var res = false
	
	for hb in hurtboxes:
		res = res or hb.canHoldBackBlock
	
	return res
	
	
#rotates the active nodes
func applyRotationToActiveNodes():
	#targetSprite.rotation_degrees=rotation_degrees
	#make sure the rotation depends on facing
	#facing right?
	if playerController.kinbody.spriteCurrentlyFacingRight:
		
		targetActiveNodes.rotation_degrees = rotation_degrees
	else:
		targetActiveNodes.rotation_degrees = -1*rotation_degrees

func hasLocalTempSFXSprites():
	return not tmpLocalSFXSprites.empty()
			
func hasGlobalTempSFXSprites():
	return not tmpGlobalSFXSprites.empty()
	

func _on_create_projectile(projectileInstance,spawnPoint):
			
	emit_signal("create_projectile",projectileInstance,spawnPoint)
