extends "res://particles/one-shot-particles.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (bool) var cached = false
var cmdMap = null
func _ready():
	cmdMap = $CommandMap

func init():
	cmdMap = $CommandMap
	
#returns true if succesfully found texture for command, false otherwise
func emitCommand(cmd):
	var _texture = cmdMap.lookupTexture(cmd)
	self.texture = _texture
	return _texture != null
	
#func emitCommand(cmd):
#	var _texture = cmdMap.lookupTexture(cmd)
#	if _texture != null:
#		self.texture = _texture
#		self.emitting=false
#		.set_emitting(true)
#	else:
#		queue_free()
	
	
#func _finished_emitting():
#	._finished_emitting()
	
#	if not cached:
#		queue_free()
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
