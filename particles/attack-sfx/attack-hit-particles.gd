extends Node2D

signal finished

var animatedSprite = null
var animatedPlayer = null
export (bool) var cached = false

var GLOBALS = preload("res://Globals.gd")
var attackType = null

#ignores hitfreeze when true, played immediatly. When false, wait till hitfreeze to start
#var playImmediatly = false
#const MELEE_IX = 0
#const SPECIAL_IX = 1
#const TOOL_IX = 2
#const OTHER_IX = 3
#const CLASH_IX = 4

var animationMap = {GLOBALS.MELEE_IX: "melee",GLOBALS.SPECIAL_IX: "special",GLOBALS.TOOL_IX:"tool",GLOBALS.OTHER_IX:"other",GLOBALS.CLASH_IX:"clash"}


func _ready():
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	animatedSprite=$AnimatedSprite
	animatedPlayer=$AnimationPlayer
	
	
	animatedPlayer.connect("animation_finished",self,"_on_animation_finished")

func play(_attackType,inHitFreeze):
	
	attackType = _attackType
	#animatedSprite.frames.frame = 0
	
	if not animationMap.has(attackType):
		#print("unkown attack type: "+str(attackType))
		emit_signal("finished")
		return	
		
	var animation = animationMap[attackType]
	
	
	#change sprite to correct animation, but stop it, waiting for hitfreeze to stop to start it
	animatedSprite.play(animation)
	
	animatedPlayer.play("fadeout")
	
	if inHitFreeze:
		_on_hit_freeze_started(null)

	
	
		
func _on_animation_finished(aniamtion):
	emit_signal("finished")

		
func _on_hit_freeze_finished():
	
	animatedSprite.playing = true
	animatedPlayer.play("fadeout")
	animatedPlayer.set_process(true)
	animatedSprite.set_process(true)

	
	
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	
	animatedSprite.playing = false
	var reset=false
	animatedPlayer.stop(reset)
	animatedPlayer.set_process(false)
	animatedSprite.set_process(false)
	
