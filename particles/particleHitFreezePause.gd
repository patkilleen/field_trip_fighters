extends Particles2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var inHitFreezeFlag = false
var speedBeforeHitFreeze = null
var GLOBALS = preload("res://Globals.gd")
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_hit_freeze_finished():
	 
	if inHitFreezeFlag:
		if speedBeforeHitFreeze != null:
			self.speed_scale = speedBeforeHitFreeze
			speedBeforeHitFreeze=null
			inHitFreezeFlag = false
	
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	
	if not inHitFreezeFlag:
		if duration > 0:
			inHitFreezeFlag=true
			speedBeforeHitFreeze = speed_scale
			self.speed_scale = 0