extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const GLOBALS = preload("res://Globals.gd")

const frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")
var animatedSprite = null
var animatedPlayer = null
export (float) var tweenFadeoutDuration = 0.5 #1/2 of a second

export (float) var delayBeforeApplyTweenFadeout = 0
var myTween = null

var fadeoutDelayTimer = null
export (bool) var cached = false

var defaultModulate=null
var unmutableDefaultModulate=null
var defaultScale =null
var defaultRotation=null

func _ready():
	_readyHook()
func _readyHook():
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	animatedSprite=$AnimatedSprite
	#animatedPlayer=$AnimationPlayer
	defaultModulate = self.modulate
	unmutableDefaultModulate=defaultModulate
	defaultRotation=rotation_degrees
	defaultScale = scale 
	visible=false
	if has_node("MyTween"):
		myTween = $MyTween
	
	if myTween != null:
		
		
		
		myTween.connect("finished",self,"_on_animation_finished")
		
		#no delay?
		if delayBeforeApplyTweenFadeout <= 0:
			pass
		else:
			fadeoutDelayTimer=frameTimerResource.new()
			self.add_child(fadeoutDelayTimer)
			fadeoutDelayTimer.connect("timeout",self,"_on_fadeout_delay_timeout")
			
			
	else:
		
		animatedPlayer=$AnimationPlayer
		
		
		
		animatedPlayer.connect("animation_finished",self,"_on_animation_finished2")

func activate():
	
	visible=true
	
	animatedSprite.playing = true
	#animatedSprite.frames.frame = 0
	animatedSprite.frame = 0
	

	if myTween != null:
		
					
		
		#no delay?
		if delayBeforeApplyTweenFadeout <= 0:
			var targetFadeOutColor = defaultModulate
			targetFadeOutColor.a = 0 #transparent
			myTween.start_interpolate_property(self,"modulate",defaultModulate,targetFadeOutColor,tweenFadeoutDuration)
		else:
			
			fadeoutDelayTimer.startInSeconds(delayBeforeApplyTweenFadeout)
			
	else:
		
		
		
		animatedPlayer.play("fadeout")
		
		

	pass
func _on_fadeout_delay_timeout():
	var targetFadeOutColor = defaultModulate
	targetFadeOutColor.a = 0 #transparent
	myTween.start_interpolate_property(self,"modulate",defaultModulate,targetFadeOutColor,tweenFadeoutDuration)
	
func _on_animation_finished2(aniamtion):
	_on_animation_finished()
	
func _on_animation_finished():
	visible=false
	pass
	#if not cached:
	#	var parent = get_parent()
	#	if parent!=null:
	#		parent.remove_child(self)
	#	queue_free()

func _on_hit_freeze_finished():
	if visible:
		animatedSprite.playing = true
	#animatedPlayer.play()
	pass
		
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	if visible:
	
		animatedSprite.playing = false
#	animatedPlayer.stop(false)# stop to indicate paused

