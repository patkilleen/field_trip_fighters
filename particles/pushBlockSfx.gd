extends Node2D

var particles = null
var animatedSprite = null
var glow = null
var animePlayer= null

var GLOBALS = preload("res://Globals.gd")

var active=false

var defaultGlowModulation = null
func _ready():
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	particles = $"pushBlock-particles"
	animatedSprite = $pushBlockExpandingGlow
	glow = $Sprite
	
	glow.visible = false
	
	defaultGlowModulation=glow.self_modulate
	animatedSprite.visible = false
	animePlayer = $AnimationPlayer
	animatedSprite.connect("animation_finished",self,"_on_animation_finished")
func enable():
	active=true
	
	animatedSprite.visible = true
	animatedSprite.emit()
	animePlayer.play("fadeout")
	glow.visible = true
	

func _on_animation_finished():
	active=false
	glow.visible = false
	animatedSprite.visible = false
	animePlayer.stop()
	glow.self_modulate=defaultGlowModulation

func _on_hit_freeze_finished():
	
	if active:
		particles.emit()# EMIT THE PARTICLES ONLY after hitfreeze ends, to hype up the moment 
		animePlayer.play()

	
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	if active:
		animePlayer.stop(false)# stop to indicate paused

