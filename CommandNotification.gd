extends Control

const frameTimerResource = preload("res://frameTimer.gd")

export (String) var text = "" setget setText,getText
export (int) var command = -1 setget setCommand,getCommand
export (float) var iconDuration = 4
export (float) var iconBlinkFreq = 0.4
var label=null
var cmdRect = null
var success = null
var fail = null
var timer = null
var blinkTimer = null

var blinkingIcon = null
func _ready():
	cmdRect = $CommandTextureRect
	cmdRect.animated = true
	label = $Label
	label.text = text
	success = $success
	fail = $fail
	
	timer = frameTimerResource.new()
	blinkTimer = frameTimerResource.new() 
	#timer.one_shot = true #set to true to indicate don't conitune ticking (only executed once called)
	#blinkTimer.one_shot = false
	timer.connect("timeout",self,"startIconDisapearing")
	blinkTimer.connect("timeout",self,"_on_blink")
	add_child(timer)
	add_child(blinkTimer)
	
	pass


func setText(t):
	text=t
	if label!=null:
		label.text=t
	
func getText():
	return text

func setCommand(cmd):
	
	command = cmd
	if cmdRect != null:
		cmdRect.setCommand(cmd)
		
func getCommand():
	return command

func commandAttempt(cmd,successFlag):
	setCommand(cmd)
	if successFlag:
		blinkingIcon = success
		success.visible=true
		fail.visible=false	
	else:
		success.visible=false
		blinkingIcon = fail
		fail.visible=true
	
	#start counting down before make icon disapear
	#timer.wait_time = iconDuration
	timer.startInSeconds(iconDuration)
	#blinkTimer.wait_time = self.iconBlinkFreq
	blinkTimer.startInSeconds(self.iconBlinkFreq)
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _on_blink():
	
	blinkingIcon.visible = not blinkingIcon.visible
	
func startIconDisapearing():
	success.visible=false
	fail.visible=false
	blinkingIcon = null
	blinkTimer.stop()