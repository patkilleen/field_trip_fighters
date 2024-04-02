extends Control
const GLOBALS = preload("res://Globals.gd")
signal option_selected
signal option_focused
export (String) var csvOptions = ""
export (String) var inputDeviceId = "P1"

var btns = []

var btnFocusIx = 0

var optionsNode = null
var template = null
var playerController = null
var gameMode = null

var wasUpPressedLastFrame = false
func _ready():
	optionsNode = $options
	template = $template
	set_physics_process(false)
	
func init(_gameMode,_playerController=null):
	gameMode=_gameMode
	playerController=_playerController
	wasUpPressedLastFrame = false
	var optionNames =  csvOptions.split(",")

	#remova all children 
	for c in optionsNode.get_children():
		optionsNode.remove_child(c)
	btnFocusIx=0
	btns.clear()
	var firstOption= true
	#iterate over options
	for names in optionNames:
		var newOptionBtn = template.duplicate()
		newOptionBtn.visible = true
		var lable = newOptionBtn.get_node("Label")
		lable.text = names
		
		
		var bgd = newOptionBtn.get_node("TextureRect")
		if firstOption:
			bgd.visible = true
		else:
			bgd.visible = false
		optionsNode.add_child(newOptionBtn)
		btns.append(newOptionBtn)
		
		firstOption=false
	set_physics_process(false)

func activate():
	btns[btnFocusIx].bgd.visible = true
	set_physics_process(true)
	
func deactivate():
	set_physics_process(false)
func resetCursor():
	
	#make sure to reset cursor to start
	btns[btnFocusIx].bgd.visible = false

	btnFocusIx= 0
	
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	
	var btnUpPressed = false
	var btnDownPressed = false
	var btnAPressed= false
	#online mode?
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		
		#this case occurs during pause of online match
		if  playerController != null :
			#during online match the game isnn't paused so input managers of player controler stil lprocessing
			#this way both peer and local can control pause hud
			var _inputMngr = playerController.inputManager
		
			
			
			if _inputMngr.lastCommand == _inputMngr.Command.CMD_UP: #THIS WIll spamm up when holding, but w/e
				#only count the up press once, can't hold to scroll menu
				if not wasUpPressedLastFrame:
					wasUpPressedLastFrame=true
					btnUpPressed=true	
					
			else:
				wasUpPressedLastFrame=false
				
	
				if _inputMngr.lastCommand == _inputMngr.Command.CMD_STOP_CROUCH: 
					btnDownPressed=true
				elif _inputMngr.lastCommand == _inputMngr.Command.CMD_JUMP: 
					btnAPressed=true
					
		else:
			
			#this case happends in character selection, when player controller not give
			if Input.is_action_just_pressed(inputDeviceId+"_UP"):
			
				btnUpPressed=true
			elif Input.is_action_just_pressed(inputDeviceId+"_DOWN"):
				btnDownPressed=true
			elif Input.is_action_just_pressed(inputDeviceId+"_A"):
				btnAPressed=true
	else:
		if Input.is_action_just_pressed(inputDeviceId+"_UP"):
			
			btnUpPressed=true
		elif Input.is_action_just_pressed(inputDeviceId+"_DOWN"):
			btnDownPressed=true
		elif Input.is_action_just_pressed(inputDeviceId+"_A"):
			btnAPressed=true
	#TODO: add a lock to make sure can't hold down up
	#so if up held last frame, doesn't count. Have to wait for
	#up to be pressed and it wasn't pressed last frame
	#if inputManager.readCommand() == UP:
	if btnUpPressed:
		
		
		btns[btnFocusIx].bgd.visible = false
		
		#wrap back to lowest button?
		if btnFocusIx ==0:
			btnFocusIx = btns.size()-1
		else:	
			btnFocusIx -= 1
			
		btns[btnFocusIx].bgd.visible = true
		emit_signal("option_focused",btns[btnFocusIx].btnName)
		
	#elif inputManager.readCommand() == DOWN:
	elif btnDownPressed:
		
		btns[btnFocusIx].bgd.visible = false
		
		#wrap back to HIGHEST button?
		if btnFocusIx ==(btns.size()-1):
			btnFocusIx = 0
		else:	
			btnFocusIx += 1
			
		btns[btnFocusIx].bgd.visible = true
		emit_signal("option_focused",btns[btnFocusIx].btnName)
	elif btnAPressed:
	
		btns[btnFocusIx].bgd.visible = false
		emit_signal("option_selected",btns[btnFocusIx].btnName)
	