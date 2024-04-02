extends "res://jumpDust.gd"

var sparks = null
func _readyHook():
	._readyHook()
	sparks = $AnimatedSprite/sparks
	sparks.emitting = false
	visible = false

func activate():
	.activate()
	sparks.restart()
	visible = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
