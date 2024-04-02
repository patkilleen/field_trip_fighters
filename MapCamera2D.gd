extends Camera2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var bus = null
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	bus = get_parent()
	set_physics_process(true)


func _physics_process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	offset = bus.global_position
