extends Control

var frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")
const myTweenResource = preload("res://MyTween.gd")
var timer = null
var fadeoutTimer=null
var leftCmdTextureRect = null
var rightCmdTextureRect = null

var leftEmptyCmdTextureRect = null
var rightEmptyCmdTextureRect = null

var leftLabel= null
var rightLabel= null

var checkMarkTextureRect = null
var crossTextureRect = null

var fadeOutTween= null
var defaultModulate=null
var targetFadeoutModulate=null

export (float) var fadeOutTime=1.5#1 second fadeout

# Called when the node enters the scene tree for the first time.
func _ready():
	
	init()
	
func init():
	
	self.visible = false
	leftCmdTextureRect = $HBoxContainer3/leftCmd
	rightCmdTextureRect = $HBoxContainer4/rightCmd
	
	leftCmdTextureRect.visible = true
	rightCmdTextureRect.visible = true
	
	leftEmptyCmdTextureRect = $emptyCmdLeft
	rightEmptyCmdTextureRect =$emptyCmdRight
	
	leftEmptyCmdTextureRect.visible = false
	rightEmptyCmdTextureRect.visible = false
	
	leftLabel=$HBoxContainer/leftLabel
	rightLabel= $HBoxContainer2/rightLabel
	
	leftLabel.visible = true
	rightLabel.visible = true
	
	checkMarkTextureRect = $checkMark
	crossTextureRect = $cross
	
	checkMarkTextureRect.visible = false
	crossTextureRect.visible = false
	timer = frameTimerResource.new()
	fadeoutTimer = frameTimerResource.new()
	self.add_child(timer)
	timer.connect("timeout",self,"_on_timer_timeout")
	self.add_child(fadeoutTimer)
	fadeoutTimer.connect("timeout",self,"_on_fade_away_timeout")
	
	
	fadeOutTween = myTweenResource.new()
	self.add_child(fadeOutTween)
	defaultModulate=self.modulate
	targetFadeoutModulate=defaultModulate
	targetFadeoutModulate.a=0
	
	
func initText(leftString,rightString):
	leftLabel.text = leftString
	rightLabel.text = rightString
	
func displayCommandPair(cmdLeft,cmdRight):
	
	_displayHelper(cmdLeft,leftCmdTextureRect,leftEmptyCmdTextureRect)
	_displayHelper(cmdRight,rightCmdTextureRect,rightEmptyCmdTextureRect)
		
		
	
func _displayHelper(cmd,cmdTextureRect,emptyCmdTextureRect):
	self.modulate = defaultModulate
	#no left command?
	if cmd == null:
		#show empty cmd icon
		emptyCmdTextureRect.visible = true
		cmdTextureRect.visible = false
	else:
		
		#show the command icon
		emptyCmdTextureRect.visible = false
		cmdTextureRect.visible = true
		
		cmdTextureRect.setCommand(cmd)
		
func setSuccessFlag(successFlag):
	#show the middle icon to dsiplay good or bad status
	if successFlag:
		checkMarkTextureRect.visible = true
		crossTextureRect.visible = false
	else:
		checkMarkTextureRect.visible = false
		crossTextureRect.visible = true

#hides the display affter a a user defiend delay
func delayedHide(delayInSeconds):
	timer.startInSeconds(delayInSeconds)
	self.modulate=defaultModulate
	fadeOutTween.stop()
	fadeoutTimer.stop()
	
func _on_timer_timeout():
	#visible=false
	
	fadeOutTween.start_interpolate_property(self,"modulate",defaultModulate,targetFadeoutModulate,fadeOutTime)
	#defaultModulate=self.modulate
	fadeoutTimer.startInSeconds(fadeOutTime)
	
func _on_fade_away_timeout():
	fadeOutTween.stop()
	fadeoutTimer.stop()
	visible=false