extends Node

#stores a variable for certain number of frames

var frameTimerResource = preload("res://frameTimer.gd")
var timer = null

#the value of variable that will be nulled after X frames
var value = null setget setValue,getValue

#5 frames by default
var leakLenthInFrames = 5
# Called when the node enters the scene tree for the first time.
func _ready():
	
	#create new timer
	timer = frameTimerResource.new()
	self.add_child(timer)
	timer.connect("timeout",self,"_on_timeout")
	
	pass # Replace with function body.

#sets the number of frames before variable is nulled
func init(_leakLenthInFrames):
	
	leakLenthInFrames=_leakLenthInFrames
	
#sets the value of variable,  and restart nullifer timer
func setValue(v):
	value = v
	timer.start(leakLenthInFrames)
	
func getValue():
	return value
	
func resetValue():
	value = null
	timer.stop()
#called leakLenthInFrames (5 frames by default) frames have ellapsed
#after setting the value
func _on_timeout():
	value = null
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
