extends Control

signal back

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const PLAYER1_IX = 0
const PLAYER2_IX = 1

const ONE_SECOND = 1


export (float) var holdBRotationSpeed = 150

var GLOBALS = preload("res://Globals.gd")

var inputDevices = []
var holdingBTime = {}
var disabledFlagInpudDeviceMap = {}

var redProgressBar = null

const CLOCKWISE_FILL= 0
const EMPTY_AMOUNT = 0
const DUMMY_VARIABLE = ONE_SECOND/10.0
func _ready():
	
	inputDevices.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDevices.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	
	disabledFlagInpudDeviceMap[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = false
	disabledFlagInpudDeviceMap[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = false
	
	holdingBTime[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = 0
	holdingBTime[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = 0
	
	redProgressBar = $"red-progress-bar"
	
	redProgressBar.init(ONE_SECOND,EMPTY_AMOUNT,0.01)
	visible = false
	set_physics_process(true)
	
	
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS

	var holdingBFlag = false
	#iterate both players
	#for player in 	inputManagers.keys():
	for player in inputDevices:
		
		#ignored disabled input devices. this allso parent nodes to handle when can return menus
		if disabledFlagInpudDeviceMap[player]:
			continue
		
		#players may be holding b to go back
		if Input.is_action_pressed(player+"_B"):
			
			#count how long holding B
			holdingBTime[player] += delta
			
			visible=true
			holdingBFlag = true
			
			
			if holdingBTime[player] > ONE_SECOND:
				holdingBTime[GLOBALS.PLAYER1_INPUT_DEVICE_ID]=0
				holdingBTime[GLOBALS.PLAYER2_INPUT_DEVICE_ID]=0
				emit_signal("back")
				
		elif Input.is_action_just_released(player+"_B"):
			
			
			
			#reset the holding b timer, were done trying to go back
			holdingBTime[player] =0
			self.rect_rotation = 0
			redProgressBar.setAmount(0)
		
	#both player's not pressing B?
	if not holdingBFlag:
		#back fill UI element not visible
		visible=false
		
	else:
		
		#someone is holding B
		visible=true
		
		var longestHoldTime =max(holdingBTime[inputDevices[PLAYER1_IX]],holdingBTime[inputDevices[PLAYER2_IX]])
		
		redProgressBar.setAmount(longestHoldTime)
	#if holdingBFlag:
	#	self.rect_rotation = self.rect_rotation + (holdBRotationSpeed*delta)	