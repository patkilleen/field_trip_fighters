extends Node2D

const GLOBALS  = preload("res://Globals.gd")

const frameTimerResource = preload("res://frameTimer.gd")

export (float) var redBlinkToggleDelay=0.25 #0.25 seconds to change from red/green to green/red
export (float) var redBlinkDuration=2.5 #2.5 second blnk for feedback of ignored sifflet aciton
var boneIcon = null
var redBoneIcon=null
var boneCountLabel=null

var boneCount = null

var blinkIntervalTimer =null
var blinkDurationTimer =null

var blinkingRedIconFlag=false
func _ready():
	boneIcon = $"bone-icon"
	redBoneIcon = $"red-bone-icon"
	boneCountLabel = $"boneCountLabel"
	
	blinkIntervalTimer =frameTimerResource.new()
	blinkDurationTimer =frameTimerResource.new()
	add_child(blinkIntervalTimer)
	add_child(blinkDurationTimer)
	
	blinkIntervalTimer.connect("timeout",self,"_on_toggle_red_blink")
	blinkDurationTimer.connect("timeout",self,"_on_red_blink_end")

func startRedIconBlinking():
	blinkingRedIconFlag=true
	redBoneIcon.visible=false
	blinkDurationTimer.startInSeconds(redBlinkDuration)
	blinkIntervalTimer.startInSeconds(redBlinkToggleDelay)

func _on_toggle_red_blink():
	redBoneIcon.visible=not redBoneIcon.visible
	blinkIntervalTimer.startInSeconds(redBlinkToggleDelay)
	
func _on_red_blink_end():
	blinkingRedIconFlag=false
	blinkIntervalTimer.stop()
	displayCorrectBoneIcon()
	
func displayCorrectBoneIcon():
	#show red
	if boneCount ==0:
		redBoneIcon.visible=true
	else:
		redBoneIcon.visible=false
func updateBoneCount(count):
	
	#indication of tried to execute command with no bones?
	if count == GLOBALS.WHISTLE_NOT_ENOUGH_BONES_IX:
		startRedIconBlinking()
	else:
		
		#stop blinking when collar fetched all the bones
		if blinkingRedIconFlag:
			blinkingRedIconFlag=false
			blinkIntervalTimer.stop()
			blinkDurationTimer.stop()
		boneCount =count
		
		displayCorrectBoneIcon()
			
		boneCountLabel.text = str(count)
