extends Label

var frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")

var frameTimer = null
func _ready():
	
	frameTimer = frameTimerResource.new()
	frameTimer.connect("timeout",self,"_on_timeout")
	self.add_child(frameTimer)
	pass # Replace with function body.

func _on_timeout():
	self.visible = false
	self.text = ""
	pass
func setTextOnTimeout(textStr, durationSecs):
	frameTimer.startInSeconds(durationSecs)
	self.visible = true
	self.text = textStr