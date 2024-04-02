extends TextureRect

signal restart_game
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const GLOBALS = preload("res://Globals.gd")
var inputManager = null
var inputManager2 = null
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	inputManager = $InputManager
	inputManager2 = $InputManager
	
	#only player 1 can restart it
	inputManager.inputDeviceId="P1"
	inputManager2.inputDeviceId="P2"
	pass

func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.

	if inputManager.readCommand() == inputManager.Command.CMD_START:
		emit_signal("restart_game")
	if inputManager2.readCommand() == inputManager2.Command.CMD_START:
		emit_signal("restart_game")
#	pass
