extends "res://particles/one-shot-particles.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (bool) var cached = false
func _finished_emitting():
	._finished_emitting()
	visible = false
	#if not cached:
	#	queue_free()
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
