extends Node2D


var sprite = null
var animePlayer= null

var GLOBALS = preload("res://Globals.gd")

var active=false

var defaultModulation = null
var defaultScale = null

export (Texture) var clashTexture = null
export (Texture) var clashBreakTexture = null

enum ClashType{
	BASIC,
	CLASH_BREAK

}
func _ready():
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	
	sprite = $Sprite
	
	sprite.visible = false
	
	defaultModulation=sprite.self_modulate
	defaultScale=sprite.scale
	sprite.texture = clashTexture #by default is normal clash texture
	animePlayer = $AnimationPlayer
	
	animePlayer.connect("animation_finished",self,"_on_animation_finished")
	
func setClashBreakTexture():
	sprite.texture = clashBreakTexture
	
		
func enable():
	
	#avoid activating special effect twice, since player clash signals air in pairs
	#usually
	if active:
		return
	
	active=true
	
	sprite.self_modulate=defaultModulation
	sprite.scale=defaultScale
	animePlayer.play("fadeout")
	sprite.visible = true
	

func _on_animation_finished(animation):
	active=false
	sprite.visible = false
	sprite.texture = clashTexture #by default is normal clash texture
	
	animePlayer.stop()
	sprite.self_modulate=defaultModulation
	sprite.scale=defaultScale

func _on_hit_freeze_finished():
	
	if active:
		animePlayer.play()

	
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	if active:
		animePlayer.stop(false)# stop to indicate paused

