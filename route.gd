extends Path2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
enum Route{
	UP,
	RIGHT,
	DOWN,
	LEFT
}

export (Route) var routeType = 0

var pathFollow2D = null
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pathFollow2D = $PathFollow2D
	pass

func activate():
	#place the bus at start of route
	pathFollow2D.set_offset(0)
	pathFollow2D.set_physics_process(true)

func deactivate():
	#note that  the path stops following upon arrival, so this is just for completness
	pathFollow2D.set_physics_process(false)
	pass
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
