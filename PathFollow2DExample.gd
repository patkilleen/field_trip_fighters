extends PathFollow2D
signal arrived 

export (float) var speed = 150
var route = null



const GLOBALS = preload("res://Globals.gd")
func _ready():
	
	#all the routes are disabled by default
	set_physics_process(false)
	
	self.loop = false
	
	pass

func _physics_process(delta):
	
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	#arrived at destination?
	if unit_offset >= 1.0:
		set_physics_process(false)
		var route = get_parent()
		emit_signal("arrived",route)
		return
		
	#move the child node along path at certain speed
	set_offset(get_offset() + speed * delta)



	