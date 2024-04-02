tool
extends Sprite

var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

var time = 0
const GLOBALS = preload("res://Globals.gd")

func _ready():
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	
func setGlobalSpeedMod(g):
	globalSpeedMod = g
	
func _process(delta):
	get_material().set_shader_param("zoom", get_viewport_transform().y.y)

func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	delta = delta * globalSpeedMod
	get_material().set_shader_param("time", time)
	time+=delta
#Connect the item_rect_changed() signal to this function
func _on_Waterfall_item_rect_changed():
	get_material().set_shader_param("scale", scale)
	
	
func _on_hit_freeze_finished():
	 
	set_physics_process(true)
	
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):	
	set_physics_process(false)