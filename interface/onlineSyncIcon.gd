extends Sprite

const GLOBALS = preload("res://Globals.gd")
export (float) var spinVelocity = 180
# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)
	visible = false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
 
	
func _physics_process(delta):	
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	#spinningIcon.rect_rotation += spinVelocity * delta
	rotation_degrees += spinVelocity * delta
	