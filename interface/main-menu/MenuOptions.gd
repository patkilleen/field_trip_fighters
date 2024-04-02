extends Control

#signal ui_scene_transition #param: scene path

const UI_MOVE_CURSOR_SOUND_ID = 0

var menuOptions = []

var cursorIx = -1 #start with nothing selected first
var itemSelectedFlag = false
var GLOBALS = preload("res://Globals.gd")

var inputDevices = []
var sfxPlayer = null
func _ready():
	
	sfxPlayer = $sfxPlayer
	#populate button map
	for c in self.get_children():
		if c is preload("res://interface/main-menu/MenuButton.gd"):
			menuOptions.append(c)
			c.unselect() #this not working for some reason
			
	#first button active by default
	#menuOptions[cursorIx].select()
	itemSelectedFlag=false
	inputDevices.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDevices.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	set_process(true)
	

func _process(delta):

	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	for inputDevice in inputDevices:
		#pressed A for confirm selection?
		var confirmationInput = inputDevice+"_A"

		#player  just pressed A?
		if Input.is_action_just_pressed(confirmationInput) and itemSelectedFlag:
			
			#make the arument contain the input device that selected the item (an array, since
			#in future, may want to add arguments to array)
			var args = []		
			args.append(inputDevice)	
			menuOptions[cursorIx].argument = args
			
			set_process(false)
			menuOptions[cursorIx].confirm(inputDevice)
			return
		
		#pressed down for next button?
		var nextInput = inputDevice+"_DOWN"

		#player  just pressed down?
		if Input.is_action_just_pressed(nextInput):
		
			#make sound of ui selection
			sfxPlayer.playSound(UI_MOVE_CURSOR_SOUND_ID)
			#not first time selecting something?
			if itemSelectedFlag:
				menuOptions[cursorIx].unselect()
			else:
				itemSelectedFlag=true
				cursorIx=-1
			#increment menu cursor (loop it back to start on last item)
			cursorIx = (cursorIx + 1 ) % menuOptions.size()
			menuOptions[cursorIx].select()
			return		
		#pressed down for next button?
		var previousInput = inputDevice+"_UP"

		#player  just pressed down?
		if Input.is_action_just_pressed(previousInput):
			#make sound of ui selection
			sfxPlayer.playSound(UI_MOVE_CURSOR_SOUND_ID)
			
			#not first time selecting something?
			if itemSelectedFlag:
				menuOptions[cursorIx].unselect()
			else:
				itemSelectedFlag=true
				cursorIx =menuOptions.size()
				
			#increment menu cursor (loop it back to start on last item)
			cursorIx = (cursorIx - 1 )
			if cursorIx < 0:
				cursorIx = menuOptions.size() -1
				
			menuOptions[cursorIx].select()
			return 

