extends Node2D
signal animation_finished
var GLOBALS = preload("res://Globals.gd")

var animePlayer = null

var active = false

var spriteDefaultModulate = null
var spriteDefaultScale = null
var sprite = null
func _ready():
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	animePlayer = $AnimationPlayer
	animePlayer.connect("animation_finished",self,"_on_animation_finished")
	sprite = $Sprite
	spriteDefaultModulate =sprite.self_modulate
	spriteDefaultScale = sprite.scale
	self.visible = false
	pass # Replace with function body.


func emit():
	active=true
	self.visible = true
	animePlayer.play("expand")
	
	
func _on_animation_finished(animation):
	emit_signal("animation_finished")
	active=false
	visible = false
	sprite.self_modulate = spriteDefaultModulate
	sprite.scale = spriteDefaultScale

func _on_hit_freeze_finished():
	
	if active:
		animePlayer.play()

	
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	if active:
		animePlayer.stop(false)# stop to indicate paused

