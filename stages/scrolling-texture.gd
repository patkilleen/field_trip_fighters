extends Sprite


var time = 0
const GLOBALS = preload("res://Globals.gd")
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD
func _ready():
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)

func setGlobalSpeedMod(g):
	globalSpeedMod = g
	
		
#CAREFUL, ONLY have one object if many duplicate exist have this script, when the shader resoruces is shared
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	delta = delta * globalSpeedMod
	get_material().set_shader_param("time", time)
	time+=delta
	
func _on_hit_freeze_finished():
	 
	set_physics_process(true)
	
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):	
	set_physics_process(false)