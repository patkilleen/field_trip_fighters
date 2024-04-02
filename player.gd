extends Node
const GLOBALS = preload("res://Globals.gd")
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var inputManager = null
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	inputManager = self.get_child(0)
	pass

func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.

	var cmd = inputManager.cmdBuffer.back()
	
	if(cmd != null):
		print(str(cmd))
	pass
#	pass
