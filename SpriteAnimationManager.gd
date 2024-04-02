extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal finished
signal multi_tap_partially_finished
signal create_projectile
signal request_play_sound
signal sprite_animation_played
signal disabled_body_box
signal enabled_body_box
signal platform_drop
signal pushable_frame_flag
signal canPush_frame_flag
signal sprite_frame_activated
signal display_global_temporary_sprites
var spriteAnimations = []

var defaultAnimation = 0
var currentAnimation = null

#command that was last used to play an animation
var cmd = null
var shaking = false

export (NodePath) var targetSpritePath = NodePath("../../../active-nodes/Sprite")

var sprite = null

export (float) var maxShakeDistance = 0

var GLOBALS = preload("res://Globals.gd")
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

#flag indicating if facing right when played or left
var facingRightWhenPlayed = null

var playerController = null
var kinbody = null
func _ready():
	
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	
	self.set_physics_process(false)
	var id = 0
	for c in $SpriteAnimations.get_children():
		spriteAnimations.append(c)
		c.id = id
		
		c.set_sprite_animation_manager(self)
		id = id + 1
		c.connect("finished",self,"_on_finished")
		c.connect("create_projectile",self,"_on_create_projectile")
		c.connect("multi_tap_partially_finished",self,"_on_multi_tap_partially_finished")
		c.connect("request_play_sound",self,"_on_request_play_sound")
		c.connect("disabled_body_box",self,"_on_disabled_body_box")
		c.connect("enabled_body_box",self,"_on_enabled_body_box")
		c.connect("platform_drop",self,"_on_platform_drop")
		c.connect("pushable_frame_flag",self,"_on_pushable_frame_flag")
		c.connect("canPush_frame_flag",self,"_on_canPush_frame_flag")
		c.connect("sprite_frame_activated",self,"_on_sprite_frame_activated")
		
	#sprite = $Sprite
	sprite = get_node(targetSpritePath)
	

func init(sprite,collisionAreas,bodyBox,activeNodes,_playerController,_kinbody):
	
	#init all sprite animations
	for sa in spriteAnimations:
		sa.init(sprite,collisionAreas,bodyBox,activeNodes,_playerController)
	
	kinbody = _kinbody
	playerController=_playerController
	self.set_physics_process(true)

func reset():
	
	
	for sa in spriteAnimations:
		sa.reset()
		
	defaultAnimation = 0
	currentAnimation = null
	cmd = null
	shaking = false

	sprite.position = Vector2(0,0)

	facingRightWhenPlayed = null
	self.set_physics_process(true)

func setGlobalSpeedMod(mod):
	globalSpeedMod=mod

func _rescaleTemporarySprites(tmpSprite,sf,scaleMod):
	
	tmpSprite.scale =  tmpSprite.scale * scaleMod

#	#only ajust the position of the shape if the psirte frame is alpha
	if sf is preload("res://AlphaSpriteFrame.gd") and not sf is preload("res://SpriteFrame.gd"):
		#now scale the position to match size increase/decrease
		var oldPos = tmpSprite.position
		tmpSprite.position.x = oldPos.x*scaleMod
		tmpSprite.position.y = oldPos.y*scaleMod 



func initializeTmpSprites():
	
	#here wet give sprite animation manager reference to all tmp sprite sfx
	for sa in spriteAnimations:
	
		var spriteFrames = sa.spriteFrames
		
		for sf in spriteFrames:
			
			
			for s in sf.tmpLocalSFXSprites:				
				s.spriteAnimationManager = self
	
			for s in sf.tmpGlobalSFXSprites:
				s.spriteAnimationManager = self
			
			
			for hb in sf.hitboxes:
				for s in hb.tmpLocalSFXSprites:
					s.spriteAnimationManager = self
				for s in hb.tmpGlobalSFXSprites:
					s.spriteAnimationManager = self
			
			for hb in sf.selfonly_hitboxes:
				for s in hb.tmpLocalSFXSprites:
					s.spriteAnimationManager = self
				for s in hb.tmpGlobalSFXSprites:
					s.spriteAnimationManager = self
#resizes scale of collision shapes in sprite frames
func rescale(scaleMod):
	
	#don't bother will all math if not actually scaling
	if scaleMod == 1:
		return
		
	#this is temporar, but will sovle dittos issue
	#but gotta address issue that the collision shapes's position 
	#aren't updated (they should be x2 further away from (0,0) for scaling of x2,)
	#if not scaleCollisionShapesFlag:
	#	return 
	
	
	#var collisionShapes = Dictionary()	
	
	for sa in spriteAnimations:
		
		var spriteFrames = sa.spriteFrames
		
		for sf in spriteFrames:
			
			#rescale the  temporary sprites of sprite frames
			for s in sf.tmpLocalSFXSprites:				
				_rescaleTemporarySprites(s,sf,scaleMod)				

			for s in sf.tmpGlobalSFXSprites:
				_rescaleTemporarySprites(s,sf,scaleMod)			
			
			#rescale the  temporary sprites of htboxes
			for hb in sf.hitboxes:
				for s in hb.tmpLocalSFXSprites:
					_rescaleTemporarySprites(s,sf,scaleMod)
				for s in hb.tmpGlobalSFXSprites:
					_rescaleTemporarySprites(s,sf,scaleMod)
			#rescale the  temporary sprites of htboxes
			for hb in sf.selfonly_hitboxes:
				for s in hb.tmpLocalSFXSprites:
					_rescaleTemporarySprites(s,sf,scaleMod)
				for s in hb.tmpGlobalSFXSprites:
					_rescaleTemporarySprites(s,sf,scaleMod)
			#iterate the collision boxes and record all unique shapes
			for cshape in sf.collisionShapes:
				
				
				#get the shape
				var qShape =  cshape.get_shape()
				
				#make it unique
				qShape = qShape.duplicate(true) #pass true to make deep copy
				
				var oldScale = null
				
				#resize the shape's dimensions
				#circles don't have an extent, their size is defined by a radius
				if qShape is CircleShape2D:
					oldScale = qShape.radius
					qShape.set_radius(oldScale*scaleMod)
				elif qShape is RectangleShape2D:#this assumes we using
					oldScale = qShape.get_extents()
					qShape.set_extents(Vector2 (oldScale.x*scaleMod, oldScale.y *scaleMod))
				else:#this assumes we using
					print("in rescaling, unknown collision shape type: "+str(typeof(qShape)))
				
				#set the shape back int collision shape2d
				cshape.set_shape(qShape) 
				
				#only ajust the position of the shape if the psirte frame is alpha
				if sf is preload("res://AlphaSpriteFrame.gd") and not sf is preload("res://SpriteFrame.gd"):
					#now scale the position to match size increase/decrease
					var oldPos = cshape.position
					cshape.position.x = oldPos.x*scaleMod
					cshape.position.y = oldPos.y*scaleMod 


func _on_create_projectile(projectile,spawnPoint):
	emit_signal("create_projectile",projectile,spawnPoint)

func _on_request_play_sound(sfxId,soundType,volume):
	emit_signal("request_play_sound",sfxId,soundType,volume)

func getCurrentSpriteFrame():
	if currentAnimation != null:
		return currentAnimation.getCurrentSpriteFrame()
	else:
		return null
		
#plays the sprite animation, which was executed with a given command
func play(id,_cmd,_facingRight,on_hit_starting_sprite_frame_ix=0):
	
	
	if currentAnimation == null:
		currentAnimation =  spriteAnimations[id]
		currentAnimation.play(_cmd,_facingRight,on_hit_starting_sprite_frame_ix)
		cmd = _cmd
		facingRightWhenPlayed = _facingRight
		emit_signal("sprite_animation_played",currentAnimation)	
	else:
		
	
		#check case its a multi tap animation (gotta keep mashing command to keep animation going)
		var spriteFrame = getCurrentSpriteFrame()
		
		var sameAnimationFlag = (spriteAnimations[id] == currentAnimation)
		#now make sure the current frame its a single tap animation before stopping for new
		if sameAnimationFlag and (spriteFrame != null) and (spriteFrame.commandType == spriteFrame.CommandType.MULTI_TAP):
			#indicate that the player has multi tapped and animation should keep playing
			currentAnimation.multiTapFlag = true		
			#don't signal starting new animation, since continuing it via multi tap
		else:
			
			currentAnimation.stop()
			currentAnimation =  spriteAnimations[id]
			currentAnimation.play(_cmd,_facingRight,on_hit_starting_sprite_frame_ix)
			cmd = _cmd
			facingRightWhenPlayed = _facingRight
			emit_signal("sprite_animation_played",currentAnimation)	
			
	#emit_signal("sprite_animation_played",currentAnimation)	
	
	#print(str(get_parent().get_parent().get_parent().inputDeviceId) + ": playing: "+currentAnimation.name)
func pause():
	if currentAnimation == null:
		#print("warning, cannot pause null sprite animation")
		pass
	else:
		currentAnimation.pause()
func unpause():
	if currentAnimation == null:
		#print("warning, cannot unpause null sprite animation")
		pass
	else:
		currentAnimation.unpause()		

func _on_multi_tap_partially_finished(spriteAnimation,spriteFrame):
	currentAnimation = null
	emit_signal("multi_tap_partially_finished",spriteAnimation,spriteFrame)	
	
func _on_finished(spriteAnimation):
	
	if spriteAnimation !=currentAnimation:
		#print("overlaping sprites, frame perfect: started animation and one finished")
		#tipically this occurs when we buffer an ability cancel to start an animation and
		#immediatly cancel it
		return
	currentAnimation = null
	emit_signal("finished",spriteAnimation)	

func _on_disabled_body_box():
	emit_signal("disabled_body_box")	

func _on_enabled_body_box():
	emit_signal("enabled_body_box")


func _on_platform_drop():
	emit_signal("platform_drop")

func _on_pushable_frame_flag(flag):
	emit_signal("pushable_frame_flag",flag) 
	
func _on_canPush_frame_flag(flag):
	emit_signal("canPush_frame_flag",flag) 

func _on_sprite_frame_activated(spriteFrame):
	
	if spriteFrame.hasGlobalTempSFXSprites():
		emit_signal("display_global_temporary_sprites",spriteFrame.tmpGlobalSFXSprites)
		
	emit_signal("sprite_frame_activated",spriteFrame)

func getAllProximityGuardAreas():
	var res = []
	
	#iterate all sprite animations 
	for anime in spriteAnimations:
		#iterate all hitboxes in the animation
		var areas = anime.getProximityGuardAreas()
		for hb in areas:
			res.append(hb)
	
	return res	
		
func getAllHitboxes():
	var res = []
	
	#iterate all sprite animations 
	for anime in spriteAnimations:
		#iterate all hitboxes in the animation
		var hitboxes = anime.getHitboxes()
		for hb in hitboxes:
			res.append(hb)
	
	return res	

func getAllHurtboxes():
	var res = []
	
	#iterate all sprite animations 
	for anime in spriteAnimations:
		#iterate all hitboxes in the animation
		var hurtboxes = anime.getHurtboxes()
		for hb in hurtboxes:
			res.append(hb)
	
	return res	
	

func getAllSelfOnlyHitboxes():
	var res = []
	
	#iterate all sprite animations 
	for anime in spriteAnimations:
		#iterate all hitboxes in the animation
		var hitboxes = anime.getSelfOnlyHitboxes()
		for hb in hitboxes:
			res.append(hb)
	
	return res	

func getAllSelfOnlyHurtboxes():
	var res = []
	
	#iterate all sprite animations 
	for anime in spriteAnimations:
		#iterate all hitboxes in the animation
		var hurtboxes = anime.getSelfOnlyHurtboxes()
		for hb in hurtboxes:
			res.append(hb)
	
	return res	
#func startShakingSprite():
#	shaking = true
	
#func stopShakingSprite():
#	sprite.position.x = 0
#	sprite.position.y = 0
#	shaking = false
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.

#	if shaking:
		
		#apply shake logic (random int not implemented yet)
#		var randomFloatX = rand_range(-maxShakeDistance,maxShakeDistance)
#		var randomFloatY = rand_range(-maxShakeDistance,maxShakeDistance)
		
#		sprite.position.x = randomFloatX
#		sprite.position.y = randomFloatY
		
		
#	pass

func getAllInactiveProjectiles():
	
	var res = []
	
	#iterate sprite frames for projectile sprite frame
	for sa in spriteAnimations:
		
		#iterate all instances and add to result
		var instances = sa.getAllInactiveProjectiles()
		
		for i in instances:
			res.append(i)
			
	return res
	
func canCurrentSpriteFrameAbilityCancel():
	
	if currentAnimation == null:
		return false
	
	var sf = currentAnimation.getCurrentSpriteFrame()
	
	if sf == null:
		return false
	
	return 	currentAnimation.barCancelableble and sf.barCancelable


func canCurrentSpriteFramePreventBounce():
	var sf = getCurrentSpriteFrame()
	if sf == null:
		return false
	else:
		return sf.preventBouncing
	
func isInNeutralAnimation():
	return _isInFrameTypeAnimation(GLOBALS.FrameType.NEUTRAL)

func isInStartupAnimation():
	return _isInFrameTypeAnimation(GLOBALS.FrameType.STARTUP)

func isInRecoveryAnimation():
	return _isInFrameTypeAnimation(GLOBALS.FrameType.RECOVERY)


func isInActiveAnimation():
	return _isInFrameTypeAnimation(GLOBALS.FrameType.ACTIVE)
		
func _isInFrameTypeAnimation(type):
	
	var sf = getCurrentSpriteFrame()
	
	if sf != null:
		return sf.type == type
	else:
		return false