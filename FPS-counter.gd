extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const GLOBALS = preload("res://Globals.gd")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _physics_process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	self.text = str(int(Engine.get_frames_per_second()))
#	pass
