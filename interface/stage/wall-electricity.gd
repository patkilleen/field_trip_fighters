extends ColorRect

const MyTweenResource = preload("res://MyTween.gd")
const frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")

export (float) var visibilityDuration= 0.1 #in seconds
export (float) var fadoutDuration= 0.3 #in frames
var myTween = null
var visibilityTimer = null

var defaultModulate = null
var targetFadeoutModulate=null
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	
	myTween = MyTweenResource.new()
	visibilityTimer = frameTimerResource.new()
	
	self.add_child(visibilityTimer)
	
	self.add_child(myTween)
	
	myTween.connect("finished",self,"_on_fadeout_finished")
	
	visibilityTimer.connect("timeout",self,"_on_fully_visible_finished")
	
	myTween.ignoreHitFreeze=false
	
	defaultModulate = self.modulate
	targetFadeoutModulate=defaultModulate
	targetFadeoutModulate.a =0
	pass # Replace with function body.

func startAnimation(_modulate):
	
	myTween.stop()
	defaultModulate = _modulate
	modulate=defaultModulate
	visible = true
	visibilityTimer.startInSeconds(visibilityDuration)
	
func _on_fully_visible_finished():
	myTween.start_interpolate_property(self,"modulate",defaultModulate,targetFadeoutModulate,fadoutDuration)
	

func _on_fadeout_finished():
	visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
