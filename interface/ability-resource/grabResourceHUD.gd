extends "res://interface/ability-resource/abilityResourceHUD.gd"

const GLOBALS = preload("res://Globals.gd")
const frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")
var frameTimer = null
var duration = 0
#var ellapsedTime = 0



var redCrossOver = null
var countDownLabel = null
func _ready():
	redCrossOver=$"red-cross-over"
	countDownLabel = $countDownLabel
	countDownLabel.visible = false
	frameTimer =frameTimerResource.new()	
	add_child(frameTimer)
	frameTimer.connect("timeout",self,"_on_cooldown_timeout")
	deactivate()

func updateProgress(newValue):
	
	.updateProgress(newValue)
	
	#red cross appears only when the ability amount isn't the max value
	if newValue < circleProgress.max_value:
		redCrossOver.visible = true
	else:
		redCrossOver.visible = false
		
		
	

func activateGrabCooldownTimer(_duration):
	frameTimer.startInSeconds(_duration)
	duration = _duration
	#ellapsedTime = 0
	countDownLabel.text = str(int(ceil(duration)))
	countDownLabel.visible = true
	set_physics_process(true)
	
	#the circle progress goes in reverse here. start at 0 seconds, and as duration of cooldown ellapsed
	#we fill the circle
	.init(_duration,0)
	
func deactivate():
	frameTimer.stop()
	duration = 0
	countDownLabel.visible = false
	set_physics_process(false)
	
	#make sure to fill the bar to max when off cooldown, regardless of howmuch time ellapsed
	updateProgress(circleProgress.max_value)


func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS

	_my_update()

	pass

func _my_update():
	var ellapsedTime =frameTimer.ellapsedTimeInSeconds
	#update the countdown label
	var secondsRemaining = duration - int(ellapsedTime)
	
	countDownLabel.text = str(int(ceil(secondsRemaining)))
	
	#update the circular progress
	updateProgress(ellapsedTime)
	
func stopAndWait():
	countDownLabel.visible = false
	updateProgress(0)
	frameTimer.stop()
	set_physics_process(false)


func _on_cooldown_timeout():
	deactivate()
	
func inheritOtherGrabCooldown(other):
	frameTimer.ellapsedTimeInSeconds = other.frameTimer.ellapsedTimeInSeconds
	frameTimer.lengthInFrames = other.frameTimer.lengthInFrames
	frameTimer.lengthInSeconds = other.frameTimer.lengthInSeconds
	frameTimer.set_physics_process(true)
	
	circleProgress.min_value = other.circleProgress.min_value
	circleProgress.max_value = other.circleProgress.max_value 	
	circleProgress.step = other.circleProgress.step
	circleProgress.value=other.circleProgress.value
	
	duration=other.duration
	countDownLabel.text = other.countDownLabel.text
	countDownLabel.visible = other.countDownLabel.visible
	#_my_update()
	
	self.set_physics_process(other.is_physics_processing())