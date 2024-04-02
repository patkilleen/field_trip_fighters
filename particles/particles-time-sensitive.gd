extends Particles2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var GLOBALS = preload("res://Globals.gd")
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD


var defaultSpeedScale = 1
func _ready():
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	

	
	defaultSpeedScale = self.speed_scale
	self.speed_scale =defaultSpeedScale*globalSpeedMod


func set_speed_scale(value):
	.set_speed_scale(value)
	defaultSpeedScale = value
	
func setGlobalSpeedMod(g):
	globalSpeedMod = g
	self.speed_scale = defaultSpeedScale*globalSpeedMod
	