extends TextureProgress
const GLOBALS = preload("res://Globals.gd")
var buffTimer=null
func _ready():
	set_physics_process(false)
	visible =false
	value=0
	pass # Replace with function body.

func _on_guard_regen_boost_change(flag):
	if flag:
		visible =true
	else:
		visible =false
		set_physics_process(false)
		buffTimer=null
func _on_guard_regen_buffed_enabled(buffDurationInFrames,timer):
	visible =true
	set_physics_process(true)
	buffTimer=timer
	max_value =buffDurationInFrames
	value=max_value
	pass
	
func _physics_process(delta):
	
	if buffTimer!=null:
		value = buffTimer.get_time_left_in_frames()
	pass