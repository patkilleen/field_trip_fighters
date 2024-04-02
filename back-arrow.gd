extends TextureRect

signal back

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const ONE_SECOND = 1


export (float) var holdBRotationSpeed = 150

var GLOBALS = preload("res://Globals.gd")

var inputDevices = []
var holdingBTime = {}


func _ready():
	
	inputDevices.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDevices.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	
	holdingBTime[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = 0
	holdingBTime[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = 0
	
	set_physics_process(true)
	
	
func _physics_process(delta):

	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.

	var holdingBFlag = false
	#iterate both players
	#for player in 	inputManagers.keys():
	for player in inputDevices:
		
		
		#players may be holding b to go back
		if Input.is_action_pressed(player+"_B"):
			
			#count how long holding B
			holdingBTime[player] += delta
			
			holdingBFlag = true
			
			if holdingBTime[player] > ONE_SECOND:
				
				emit_signal("back")
				
		elif Input.is_action_just_released(player+"_B"):
			#reset the holding b timer, were done trying to go back
			holdingBTime[player] =0
			self.rect_rotation = 0
		
	if holdingBFlag:
		self.rect_rotation = self.rect_rotation + (holdBRotationSpeed*delta)	
		

	