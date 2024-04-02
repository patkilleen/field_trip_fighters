extends HBoxContainer
signal second_ellapsed
signal timeout
signal ten_second_remaining

var duration = 0
var stage = null

var countDownLabel = null
const GLOBALS = preload("res://Globals.gd")
var frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")

var timer = null

const SECONDS_PER_MINUTE = 60

const TEN_SECONDS = 10


var lastCheckSecondsRemaining = 0

var signaled10SecLeft=false

func _ready():
	
	self.visible = false
	
	countDownLabel = $countDownLabel
	
	timer = frameTimerResource.new()
	self.call_deferred("add_child",timer)
	
	timer.connect("timeout",self,"_on_timeout")

	pass

func init(_stage):
	stage = _stage
func activate(_duration):
	duration = int(round(_duration))
	lastCheckSecondsRemaining =duration
	countDownLabel.text = str(duration)
	self.visible = true
	timer.startInSeconds(duration)
	signaled10SecLeft=false

	set_physics_process(true)
	
func deactivate():
	duration = 0
	lastCheckSecondsRemaining=0
	timer.stop()
	self.visible = false
	set_physics_process(false)
	

func _physics_process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS	
		
	var ellapsedTime = timer.ellapsedTimeInSeconds
	
	#update the countdown label
	var secondsRemaining = duration - int(ellapsedTime)
	
	#did a second ellapse
	if secondsRemaining != lastCheckSecondsRemaining:
		lastCheckSecondsRemaining=secondsRemaining
		
		
		#signal the second ellapsed
		emit_signal("second_ellapsed",int(ellapsedTime))
		
	
	
	var secondsOverAMinute = secondsRemaining % SECONDS_PER_MINUTE
	var minutes = secondsRemaining/SECONDS_PER_MINUTE
	
	var string = ""
	
	if minutes > 0:
		
		if secondsOverAMinute >= TEN_SECONDS: 
			#mm:ss format
			string = str(minutes) +":"+str(secondsOverAMinute) 
		else:
			#mm:0s format
			string = str(minutes) +":0"+str(secondsOverAMinute) 
	else:
		#s format
		string=str(secondsOverAMinute) 
		
		#lower than 10 seconds and the time ticked down by 1 second?
		if secondsOverAMinute <= 10 and  str(secondsOverAMinute)!=countDownLabel.text:
			stage.specialSFXSoundPlayer.playSound(stage.TIMER_TICK_SOUND_ID)
			
			#haven't signal the 10 seconds remaining?
			if not signaled10SecLeft:
				signaled10SecLeft=true
				emit_signal("ten_second_remaining")
	countDownLabel.text = str(string)



func _on_timeout():
	emit_signal("timeout")
	
