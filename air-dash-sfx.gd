extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var animePlayer = null

const FADE_OUT_DURATION = 0.2 #1/4 of a second
var myTween = null
var targetFadeOutColor=null
var defaultModulate=null
var defaultRotation=null
var defaultScale =null
#var startingModulate=null
func _ready():
	#animePlayer=$AnimationPlayer
	#animePlayer.play("fadeout")	
	#animePlayer.connect("animation_finished",self,"_on_finished_animation")
	#startingModulate = modulate
	
	myTween = $MyTween
	myTween.connect("finished",self,"_on_finished_animation")
	visible = false
	defaultModulate = modulate
	defaultRotation = rotation_degrees
	defaultScale = scale
func play():
	
	visible = true
	var targetFadeOutColor=modulate
	targetFadeOutColor.a = 0 #transparent
	myTween.start_interpolate_property(self,"modulate",modulate,targetFadeOutColor,FADE_OUT_DURATION)
	


func _on_finished_animation():
#func _on_finished_animation(animation):
	visible = false
	#queue_free()


