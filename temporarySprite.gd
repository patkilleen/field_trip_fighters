extends Sprite

signal disapeared

enum State{
	INACTIVE,
	LIVE,
	FADING	
}
var lifetimeInFrames = 60
var disapearDurationInFrames = 60
var preventMirroring = false
var visibilityCondition = 0 #0 means no conditional visiblity. always show
var disapearOnAnimationChange = false
var disapearOnHitstun = false
var disapearOnAnimationFinish = false
#var disapearOnOpponentAnimationChange = false
var disapearOnOpponentHitstun = false
#var disapearOnOpponentAnimationFinish = false

var animateScale = false #true means will animate the scale 
var scaleAnimationLifeTime=60  #duration of scale animation
var targetScale = Vector2(0,0) #the ending scale of sprite

const MyTweenResource = preload("res://MyTween.gd")

var GLOBALS = preload("res://Globals.gd")
var frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")

var lifeTimeTimer =null 
var defaultColor = null
var fadeOutColor = null
var disapearTween = null
var scaleTween=null

#have this just cause it's also used as a sfxSprite that check existance of spriteAnimationManager
var spriteAnimationManager = null
var activated=false

var state=State.INACTIVE

var opponentPlayerController = null
var opponentWentIntoHitstunCount=0
func _ready():
	disapearTween = MyTweenResource.new()
	self.add_child(disapearTween)
	disapearTween.connect("finished",self,"_fadeOut_complete")
	disapearTween.ignoreHitFreeze=false
	
	
	scaleTween = MyTweenResource.new()
	self.add_child(scaleTween)
	scaleTween.connect("finished",self,"_scale_animation_complete")
	scaleTween.ignoreHitFreeze=false
	
	
	self.visible = false
	lifeTimeTimer =frameTimerResource.new()
	lifeTimeTimer.connect("timeout",self,"_on_life_time_end")
	add_child(lifeTimeTimer)
	pass # Replace with function body.

func activate(sprite,referencePoint,facingRight,_lifetime,_disapearDurationInFrames,isInHitFreeze,_preventMirroring,_visibilityCondition,_spriteAnimationManager,_animateScale,_scaleAnimationLifeTime,_targetScale):
	
	#don't let sprites exist forever
	if _lifetime <= 0 :
		return
	
	


	opponentWentIntoHitstunCount=0
	spriteAnimationManager = _spriteAnimationManager
	self.texture = sprite.texture
	if not facingRight:
	#	spawnPoint.x = spawnPoint.x * (-1)
		
		self.position = sprite.position 
		self.position.x = -1*self.position.x
		self.position += referencePoint
	else:
		self.position = sprite.position + referencePoint
	
	self.scale = sprite.scale
	
	animateScale = _animateScale
	scaleAnimationLifeTime=_scaleAnimationLifeTime
	targetScale=_targetScale


	#don't mirror sprite's rotation based on facing if it prevents it	
	if not _preventMirroring:
		if not facingRight:
			self.rotation_degrees = -1*sprite.rotation_degrees
		else:
			self.rotation_degrees = sprite.rotation_degrees
	else:
		self.rotation_degrees = sprite.rotation_degrees
		
	self.z_index = sprite.z_index
	self.z_as_relative =sprite.z_as_relative
	self.modulate = sprite.modulate

	defaultColor = sprite.modulate
	fadeOutColor =defaultColor
	self.centered = sprite.centered
	fadeOutColor.a = 0
	
	#self.light_mask =sprite.light_mask
	
	
	disapearDurationInFrames=_disapearDurationInFrames
	preventMirroring = _preventMirroring
	visibilityCondition = _visibilityCondition
	if disapearDurationInFrames < 0:
		disapearDurationInFrames=0
		
	lifetimeInFrames= _lifetime
	visible = true
	activated = true
	state=State.LIVE
	lifeTimeTimer.start(lifetimeInFrames)
	disapearTween.stop()
	scaleTween.stop()
	
	
	if not facingRight:
		
		#don't mirror sprite based on facing if it prevents it
		if not _preventMirroring:
			self.scale.x 	= -1 * self.scale.x
			targetScale.x = -1 * targetScale.x
	if animateScale:
		startScaleAnimation()
		
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)

	#THIS sprite only appears when facing a specific direction?
	if visibilityCondition != GLOBALS.VisibilityCondition.NONE:
		
		if visibilityCondition == GLOBALS.VisibilityCondition.FACING_RIGHT_ONLY:
			if not facingRight:
				#the facing right requirement not met, so don't display
				deactivate()
				return
		elif visibilityCondition == GLOBALS.VisibilityCondition.FACING_LEFT_ONLY:
			if facingRight:
				#the facing left requirement not met, so don't display
				deactivate()
				return 
					
	if isInHitFreeze:
		_on_hit_freeze_started(null) 
		lifeTimeTimer.handleHitFreezeStarted()
	
	if sprite.material != null:
		self.material = sprite.material
		
func deactivate():
	
	if activated:
		disapearTween.stop()
		scaleTween.stop()
		state=State.INACTIVE
		remove_from_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
		activated=false
		lifeTimeTimer.stop()
		visible = false
		self.material=null		
		emit_signal("disapeared",self)
		
	
func startFadingOut():
	
	if disapearDurationInFrames == 0:
		deactivate()
	else:
		disapearTween.start_interpolate_property(self,"modulate",defaultColor,fadeOutColor,disapearDurationInFrames*GLOBALS.SECONDS_PER_FRAME)
		#disapearTween.start()

	
func startScaleAnimation():
	
	if scaleAnimationLifeTime > 0:
		scaleTween.start_interpolate_property(self,"scale",scale,targetScale,scaleAnimationLifeTime*GLOBALS.SECONDS_PER_FRAME)
		#disapearTween.start()

func _scale_animation_complete():
	pass
		
func _fadeOut_complete():
	
	deactivate()
	
func _on_hit_freeze_finished():
	pass	
	#if state ==State.FADING:
	#	disapearTween.resume_all()
	#elif state ==State.LIVE:
	#	lifeTimeTimer.set_physics_process(true)

	
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	pass
	#if state ==State.FADING:
	#	disapearTween.stop_all()
	#elif state ==State.LIVE:
		#lifeTimeTimer.set_physics_process(false)


func _on_life_time_end():
	state=State.FADING
	startFadingOut()
	
	
	
func _on_disapear_from_animation_played(anime,parentAnimation):
	
	#THIS AVoids the situation where tmp sprite create frame 1 of an animation, and the animation player ssignal called after its' created
	if parentAnimation!=anime:
		_on_disapear_from_animation_changed(anime)

func _on_disapear_from_animation_changed(animation):
	deactivate()
	#spriteAnimationManager.disconnect("sprite_animation_played",self,"_on_disapear_from_animation_played")
	disconnectTmpSpriteFromSignals()
	
	
	
func _on_disapear_from_opponent_hitstun_check(attackSpriteId,relativeDamage):
	#this is a hacky way of fixing a bug where hitboxs that apply sprite over opponent
	#on hit disappear immediatly cause hitstun applied after
	#sprite effects displayed
	
	if opponentWentIntoHitstunCount > 0:
		deactivate()
		disconnectTmpSpriteFromSignals() 
	opponentWentIntoHitstunCount = opponentWentIntoHitstunCount +1
func _on_disapear_from_hitstun_check(hitstunFlag):

	if hitstunFlag:
		deactivate()
		disconnectTmpSpriteFromSignals()
		#playerState.disconnect("changed_in_hitstun",self,"_on_disapear_from_hitstun_check")		

	
func disconnectTmpSpriteFromSignals():

	if spriteAnimationManager != null:			
		if spriteAnimationManager.is_connected("sprite_animation_played",self,"_on_disapear_from_animation_played"):
			spriteAnimationManager.disconnect("sprite_animation_played",self,"_on_disapear_from_animation_played")
				
		#projectiles don't have hitstun
		if spriteAnimationManager.playerController is preload("res://PlayerController.gd"):
			if spriteAnimationManager.playerController.playerState.is_connected("changed_in_hitstun",self,"_on_disapear_from_hitstun_check"):					
				spriteAnimationManager.playerController.playerState.disconnect("changed_in_hitstun",self,"_on_disapear_from_hitstun_check")	
	
		if spriteAnimationManager.is_connected("finished",self,"_on_disapear_from_animation_changed"):
			spriteAnimationManager.disconnect("finished",self,"_on_disapear_from_animation_changed")

		if opponentPlayerController != null:
			if opponentPlayerController.is_connected("about_to_be_applied_hitstun",self,"_on_disapear_from_opponent_hitstun_check"):
				opponentPlayerController.disconnect("about_to_be_applied_hitstun",self,"_on_disapear_from_opponent_hitstun_check")
			
			opponentPlayerController=null
		