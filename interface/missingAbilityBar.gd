extends Sprite

export (float) var blinkIntervalDuration=0.15
var frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")

var frameTimer = null
var flashTimer = null
func _ready():
	
	frameTimer = frameTimerResource.new()
	frameTimer.connect("timeout",self,"_on_timeout")
	self.add_child(frameTimer)
	
	flashTimer = frameTimerResource.new()
	flashTimer.connect("timeout",self,"_on_flash_timeout")
	self.add_child(flashTimer)
	
	self.visible =false
	pass # Replace with function body.

func _on_timeout():
	self.visible = false
	flashTimer.stop()
	frameTimer.stop()
	pass
	
func display(durationSecs):
	frameTimer.startInSeconds(durationSecs)
	flashTimer.startInSeconds(blinkIntervalDuration)
	self.visible = true
	
func _on_flash_timeout():
	flashTimer.startInSeconds(blinkIntervalDuration)
	self.visible=not self.visible