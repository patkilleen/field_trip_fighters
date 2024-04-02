extends Sprite

export (float) var rotationSpeed = 3.14 #radians per second

export (bool) var initiallyPlayer = true
var GLOBALS = preload("res://Globals.gd")


func _ready():
	#this is so subclasses can do somethig tiwh hitfreeze
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	
	if initiallyPlayer:
		self.set_physics_process(true)
	else:
		self.set_physics_process(false)
func _physics_process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	self.rotate(delta*rotationSpeed)
	
#to be implemented as hook by subclass
func _on_hit_freeze_finished():
	self.set_physics_process(true)
	
#to be implemented as hook by subclass
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	
	self.set_physics_process(false)