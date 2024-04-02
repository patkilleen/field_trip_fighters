extends PathFollow2D
const GLOBALS = preload("res://Globals.gd")

export (float) var speed = 150
var route = null


func _ready():
	
	#this is so subclasses can do somethig tiwh hitfreeze
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	#all the routes are disabled by default
	set_physics_process(true)
	
	self.loop = true
	


func _physics_process(delta):
	
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS

		
	#move the child node along path at certain speed
	set_offset(get_offset() + speed * delta)



	
func _on_hit_freeze_finished():
	self.set_physics_process(true)
		
	
	
#to be implemented as hook by subclass
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	
	self.set_physics_process(false)

