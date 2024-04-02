extends CanvasLayer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal restart_game
signal back_to_online_lobby
signal back_to_main_menu
signal back_to_character_select
signal back_to_proficiency_select 
signal back_to_stage_select
signal save_replay
signal resumed
signal activated

const RESULT_SCREEN_PAUSE_CONTROL_TIMEOUT_DURATION=15#15 SECONDS before the pauser loses controll and game unpauses to allow for other player to take control

const INPUT_MANAGER_RESOURCE = preload("res://input_manager.gd")
#button names

const BTN_NAME_RESUME ="Resume"
const BTN_NAME_STUDENT_DETAILS="Student Details"
const BTN_NAME_RESTART = "Restart"
const BTN_NAME_CHARACTER_SELECT = "Back to Character Select" 
const BTN_NAME_PROFICIENCY_SELECT = "Back to Proficiency Select" 
const BTN_NAME_MAIN_MENU="Back to Main Menu"
const BTN_NAME_STAGE_SELECT="Back to Stage Select"
const BTN_NAME_SAVE_REPLAY="Save Replay"
const BTN_NAME_QUIT="Quit"

const UI_MOVE_CURSOR_SOUND_ID = 0
const UI_OVERRIDE_CONFIRM_SOUND_ID = 3
const PAUSE_SOUND_ID = 1
const UNPAUSE_SOUND_ID = 2
const CONTROLLER_DC_TEXT = "Controller Disconnected"
const NETCODE_DESYNC_TEXT = "Network Desynchronization"

const RESULT_SCREEN_PAUSE_SCREEN_STRING = "Continue..."
const MATCH_PAUSE_SCREEN_STRING = "Paused"

var UP  = null
var DOWN = null
var A = null
var wrapper = null

#var btns = []


#var btnFocusIx = 0

var listSelection = null
var ripostCheckbox = null
var inputManager = null
var inputDeviceId = null
var opponentInputDeviceId = null
var sfxPlayer = null
var trainingHUD = null
var botRipostNumHitsLine = null
var botRipostCmdnNode = null
var techButton = null
var guardSelectBtn = null
var guardBehaviorSelectBtn = null
var GLOBALS = preload("res://Globals.gd")

var comboListResource = preload("res://interface/comboList.tscn")
const newComboListResource = preload("res://interface/new-combo-list/NewComboList.tscn")
var frameTimerResource = preload("res://frameTimer.gd")

var pauseControlTimeoutTimer = null
var comboList = null

var commandSelectBtn = null

var botCommandsLine =null
var behaviorSelectBtn = null
var gameMode = GLOBALS.GameModeType.STANDARD setget setGameMode,getGameMode

var pausedLabel = null
var speedSelectBtn = null

var controllerDCLabel = null
var comboListTemplate = null
var resultScreenOpponentUI = null

var comboListMap = {}


var offlineUIOptionListMap = {}
var onlineUIOptionListMap = {}
var replayUIOptionListMap = {}
#points the the above two maps based on game mode
var gameModeBasedUIOptionListMap={}

var profHUD = null
var trainingHUDBgd=null
var abilityResourceCostList = null

#var trainingHUDToggleBtnContainer = null
var trainingHUDToggleBtn=null

var wasProfChoiceVisible = false

var playerController = null #the player controller that activated pause hud

var pauseMode = null

var wasUpPressedLastFrame = false #necessary for holding up in online mode to count as 1 tap

var cmdUserFriendlyNameMap= {}


func _ready():
	
	
	cmdUserFriendlyNameMap["None"]=null
	cmdUserFriendlyNameMap["Neutral Melee"]=INPUT_MANAGER_RESOURCE.Command.CMD_NEUTRAL_MELEE
	cmdUserFriendlyNameMap["Forward Melee"]=INPUT_MANAGER_RESOURCE.Command.CMD_FORWARD_MELEE
	cmdUserFriendlyNameMap["Down Melee"]=INPUT_MANAGER_RESOURCE.Command.CMD_DOWNWARD_MELEE
	cmdUserFriendlyNameMap["Back Melee"]=INPUT_MANAGER_RESOURCE.Command.CMD_BACKWARD_MELEE
	cmdUserFriendlyNameMap["Up Melee"]=INPUT_MANAGER_RESOURCE.Command.CMD_UPWARD_MELEE
	cmdUserFriendlyNameMap["Neutral Special"]=INPUT_MANAGER_RESOURCE.Command.CMD_NEUTRAL_SPECIAL
	cmdUserFriendlyNameMap["Forward Special"]=INPUT_MANAGER_RESOURCE.Command.CMD_FORWARD_SPECIAL
	cmdUserFriendlyNameMap["Down Special"]=INPUT_MANAGER_RESOURCE.Command.CMD_DOWNWARD_SPECIAL
	cmdUserFriendlyNameMap["Back Special"]=INPUT_MANAGER_RESOURCE.Command.CMD_BACKWARD_SPECIAL
	cmdUserFriendlyNameMap["Up Special"]=INPUT_MANAGER_RESOURCE.Command.CMD_UPWARD_SPECIAL
	cmdUserFriendlyNameMap["Neutral Tool"]=INPUT_MANAGER_RESOURCE.Command.CMD_NEUTRAL_TOOL
	cmdUserFriendlyNameMap["Forward Tool"]=INPUT_MANAGER_RESOURCE.Command.CMD_FORWARD_TOOL
	cmdUserFriendlyNameMap["Down Tool"]=INPUT_MANAGER_RESOURCE.Command.CMD_DOWNWARD_TOOL
	cmdUserFriendlyNameMap["Back Tool"]=INPUT_MANAGER_RESOURCE.Command.CMD_BACKWARD_TOOL
	cmdUserFriendlyNameMap["Up Tool"]=INPUT_MANAGER_RESOURCE.Command.CMD_UPWARD_TOOL
	cmdUserFriendlyNameMap["Grab"]=INPUT_MANAGER_RESOURCE.Command.CMD_GRAB
	cmdUserFriendlyNameMap["Auto Riposte"]=INPUT_MANAGER_RESOURCE.Command.CMD_AUTO_RIPOST
	cmdUserFriendlyNameMap["Jump"]=INPUT_MANAGER_RESOURCE.Command.CMD_JUMP
	cmdUserFriendlyNameMap["Jump Forward"]=INPUT_MANAGER_RESOURCE.Command.CMD_JUMP_FORWARD
	cmdUserFriendlyNameMap["Jump Back"]=INPUT_MANAGER_RESOURCE.Command.CMD_JUMP_BACKWARD
	cmdUserFriendlyNameMap["Dash Forward"]=INPUT_MANAGER_RESOURCE.Command.CMD_DASH_FORWARD
	cmdUserFriendlyNameMap["Dash Back"]=INPUT_MANAGER_RESOURCE.Command.CMD_DASH_BACKWARD
	cmdUserFriendlyNameMap["Fast Fall"]=INPUT_MANAGER_RESOURCE.Command.CMD_AIR_DASH_DOWNWARD
	cmdUserFriendlyNameMap["Walk Forward"]=INPUT_MANAGER_RESOURCE.Command.CMD_MOVE_FORWARD
	cmdUserFriendlyNameMap["Walk Back"]=INPUT_MANAGER_RESOURCE.Command.CMD_MOVE_BACKWARD
	cmdUserFriendlyNameMap["Crouch"]=INPUT_MANAGER_RESOURCE.Command.CMD_CROUCH
	cmdUserFriendlyNameMap["Crouch Back"]=INPUT_MANAGER_RESOURCE.Command.CMD_BACKWARD_CROUCH
	
	
	gameModeBasedUIOptionListMap[GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST]=onlineUIOptionListMap
	gameModeBasedUIOptionListMap[GLOBALS.GameModeType.ONLINE_HOSTING]=onlineUIOptionListMap
	gameModeBasedUIOptionListMap[GLOBALS.GameModeType.PLAY_V_AI]=offlineUIOptionListMap
	gameModeBasedUIOptionListMap[GLOBALS.GameModeType.STANDARD]=offlineUIOptionListMap
	gameModeBasedUIOptionListMap[GLOBALS.GameModeType.REPLAY]=replayUIOptionListMap
	gameModeBasedUIOptionListMap[GLOBALS.GameModeType.TRAINING]=offlineUIOptionListMap

	offlineUIOptionListMap[GLOBALS.PauseMode.IN_GAME]=BTN_NAME_RESUME+","+BTN_NAME_RESTART+","+BTN_NAME_STUDENT_DETAILS+","+BTN_NAME_STAGE_SELECT+","+BTN_NAME_PROFICIENCY_SELECT+","+BTN_NAME_CHARACTER_SELECT+","+BTN_NAME_MAIN_MENU
	offlineUIOptionListMap[GLOBALS.PauseMode.CONTROLLER_DC]=BTN_NAME_RESUME
	offlineUIOptionListMap[GLOBALS.PauseMode.RESULT_SCREEN]=BTN_NAME_RESTART+","+BTN_NAME_STAGE_SELECT+","+BTN_NAME_PROFICIENCY_SELECT+","+BTN_NAME_CHARACTER_SELECT+","+BTN_NAME_MAIN_MENU+","+BTN_NAME_SAVE_REPLAY
	offlineUIOptionListMap[GLOBALS.PauseMode.RESTART_OR_END]=BTN_NAME_RESTART+","+BTN_NAME_MAIN_MENU
	
	onlineUIOptionListMap[GLOBALS.PauseMode.IN_GAME]=BTN_NAME_RESUME+","+	BTN_NAME_RESTART+","+BTN_NAME_QUIT		
	onlineUIOptionListMap[GLOBALS.PauseMode.CONTROLLER_DC]=BTN_NAME_RESUME	
	onlineUIOptionListMap[GLOBALS.PauseMode.RESULT_SCREEN]=BTN_NAME_RESTART+","+BTN_NAME_QUIT
	onlineUIOptionListMap[GLOBALS.PauseMode.RESTART_OR_END]=BTN_NAME_RESTART+","+BTN_NAME_QUIT
	
	
	#replayUIOptionListMap[GLOBALS.PauseMode.IN_GAME]=BTN_NAME_RESUME+","+BTN_NAME_QUIT
	replayUIOptionListMap[GLOBALS.PauseMode.IN_GAME]=BTN_NAME_RESUME+","+BTN_NAME_QUIT+","+BTN_NAME_RESTART
	replayUIOptionListMap[GLOBALS.PauseMode.CONTROLLER_DC]=BTN_NAME_RESUME+","+BTN_NAME_QUIT
	replayUIOptionListMap[GLOBALS.PauseMode.RESULT_SCREEN]=BTN_NAME_RESUME+","+BTN_NAME_QUIT
	replayUIOptionListMap[GLOBALS.PauseMode.RESTART_OR_END]=BTN_NAME_RESUME+","+BTN_NAME_QUIT

	
	#comboList = comboListResource.new()
	#comboList = $wrapper/comboList
	#comboList.init()
	
	comboListTemplate = $wrapper/comboListTemplate
	
	wrapper = $wrapper
	wrapper.visible = false
	
	sfxPlayer = $sfxPlayer
	trainingHUD = $"wrapper/ScrollContainer"
	trainingHUDBgd = $wrapper/trainignHUDBgd
	profHUD = $wrapper/ProficiencySelectionHUD
	
	pauseControlTimeoutTimer =  frameTimerResource.new()
	self.add_child(pauseControlTimeoutTimer)
	pauseControlTimeoutTimer.connect("timeout",self,"_on_pauseControlTimeoutTimer_timeout")
	
	resultScreenOpponentUI = $"wrapper/resultScreenOpponentUI"
	resultScreenOpponentUI.connect("menu_override_requested",self,"_on_menu_override_requested")
	
	controllerDCLabel = $wrapper/HBoxContainer2/controllerDCLabel
	controllerDCLabel.visible = false
	abilityResourceCostList =$wrapper/ResourceCostList

	listSelection = $wrapper/ListSelection
	
	listSelection.connect("option_selected",self,"_on_button_pressed")
	
	pausedLabel = $wrapper/HBoxContainer/pauseLabel
	#trainingHUDToggleBtnContainer = $"wrapper/hboxcontainerToggle"
	
	
	botRipostNumHitsLine = $wrapper/ScrollContainer/TrainingHUD/HBoxContainer4
	botRipostNumHitsLine.visible = false #only display when ripost selected as bot command
	
	botRipostCmdnNode = $wrapper/ScrollContainer/TrainingHUD/HBoxContainer33
	botRipostCmdnNode.visible = false
	
	botCommandsLine = $wrapper/ScrollContainer/TrainingHUD/HBoxContainer
	
	ripostCheckbox = $wrapper/ScrollContainer/TrainingHUD/HBoxContainer19/ripostCheckBox
	
	ripostCheckbox.connect("pressed",self,"_on_ripost_check_box_pressed")
	
	commandSelectBtn = $wrapper/ScrollContainer/TrainingHUD/HBoxContainer/CommandSelectionButton
	commandSelectBtn.connect("item_selected",self,"_on_bot_command_selected")
	
	
	$wrapper/ScrollContainer/TrainingHUD/HBoxContainer16/BehaviorSelection.connect("item_selected",self,"_on_bot_behavior_selected")
	
	setGameMode(gameMode)
	
		
	populateTrainingHUD()
	
	#inputManager = $InputManager
	
	#inputManager.init()
	#inputManager.set_physics_process(false)
	
	#UP = inputManager.Command.CMD_UP
	#DOWN = inputManager.Command.CMD_DOWN
	#A = inputManager.Command.CMD_JUMP
	
	#iterate all buttons
	#for btn in $wrapper/Buttons.get_children():
	#	if btn is MenuButton:
	#		btns.append(btn)
			#btn.connect("pressed",self,"_on_button_pressed",[btn])
			
	set_physics_process(false)


func initializeTrainingHUDBtnToggle():
	pass
	return
	#trainingHUDToggleBtn = $"wrapper/hboxcontainerToggle/trainindHUDToggleBtn"
	#trainingHUDToggleBtn.pressed = true
	#if not trainingHUDToggleBtn.is_connected("button_up",self,"_on_training_hud_toggle"):
		#trainingHUDToggleBtn.connect("button_up",self,"_on_training_hud_toggle")
	
func init(settings,player1Controller,player2Controller):
	abilityResourceCostList.init(settings)
	resultScreenOpponentUI.init()
	
	preloadComboListInfo(player1Controller,player2Controller)
	
func populateTrainingHUD():
	
	#add behavior types to selection
	behaviorSelectBtn = $wrapper/ScrollContainer/TrainingHUD/HBoxContainer16/BehaviorSelection

	behaviorSelectBtn.add_item(GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_SPAM)
	behaviorSelectBtn.add_item(GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_2ND_CONTROLLER)
	behaviorSelectBtn.add_item(GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_MAIN_CONTROLLER)
	behaviorSelectBtn.add_item(GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_MIRROR_PLAYER_COMMAND)
	behaviorSelectBtn.add_item(GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_MIRROR_PLAYER_INPUT)
	behaviorSelectBtn.add_item(GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_CPU)
	
	#active frame auto ability cancel selections for player and cpu
	var afacSelections = []
	afacSelections.append($wrapper/ScrollContainer/TrainingHUD/HBoxContainer29/activeAutoAbilityCancelSelection)
	afacSelections.append($wrapper/ScrollContainer/TrainingHUD/HBoxContainer28/activeAutoAbilityCancelSelection2)

	for selection in afacSelections:
		selection.add_item(GLOBALS.TRAINING_MODE_AFAAC_DISABLED)	
		selection.add_item(GLOBALS.TRAINING_MODE_AFAAC_ENABLED)	
		selection.add_item(GLOBALS.TRAINING_MODE_AFAAC_ON_HIT_ONLY)	
	
	guardSelectBtn = $wrapper/ScrollContainer/TrainingHUD/HBoxContainer22/GuardTypeSelection
	guardSelectBtn.add_item(GLOBALS.TRAINING_MODE_GUARD_NO_BLOCK)
	guardSelectBtn.add_item(GLOBALS.TRAINING_MODE_GUARD_BLOCK_HIGH)
	guardSelectBtn.add_item(GLOBALS.TRAINING_MODE_GUARD_BLOCK_LOW)
	guardSelectBtn.add_item(GLOBALS.TRAINING_MODE_GUARD_BLOCK_EVERYTHING)
	
	guardBehaviorSelectBtn = $wrapper/ScrollContainer/TrainingHUD/HBoxContainer27/GuardBehaviorSelection
	
	guardBehaviorSelectBtn.add_item(GLOBALS.TRAINING_MODE_GUARD_BEHAVIOR_NOW)
	guardBehaviorSelectBtn.add_item(GLOBALS.TRAINING_MODE_GUARD_BEHAVIOR_RANDOM)
	guardBehaviorSelectBtn.add_item(GLOBALS.TRAINING_MODE_GUARD_BEHAVIOR_AFTER_FIRST_HIT)
	
	

	techButton = $wrapper/ScrollContainer/TrainingHUD/HBoxContainer18/techSlectionButton
	techButton.add_item("No Tech")
	techButton.add_item("Neutral Tech")
	techButton.add_item("Right Tech")
	techButton.add_item("Left Tech")
	techButton.add_item("Up Tech")
	techButton.add_item("Down Tech")
	
	#TODO: change techButton to a checkbox  so player can select what type of tech
	#which will select randomly from those selected. Remove 'no tech' option
	#TODO: add techType button as "No Tech, Always Tech, Random Tech". When 'no tech' select
	#all other tech options invisible
	#TODO: add collision filter check box to indicate what surface bot will tech form
	#so for example, checking wall and floor means bot will never ceiling tech. When a tech should occur, 
	#only on  floor and wall in this example
	
	speedSelectBtn = $wrapper/ScrollContainer/TrainingHUD/HBoxContainer17/speedSlectionButton
	
	speedSelectBtn.add_item("Normal")
	speedSelectBtn.add_item("Slow")
	speedSelectBtn.add_item("Very Slow")
	speedSelectBtn.add_item("Fast")
	speedSelectBtn.add_item("Very Fast")
	
	#add all the commands to selection
	var commandSelectBtn = $wrapper/ScrollContainer/TrainingHUD/HBoxContainer/CommandSelectionButton
	var reversalCommandSelectBtn = $wrapper/ScrollContainer/TrainingHUD/HBoxContainer13/CommandSelectionButton
	var inputMngr = preload("res://input_manager.gd").new()
	
	inputMngr.populateLookupMaps()
	
	#for cmdEnum in inputMngr.Command.keys():
		
		#ignore following coommands
	#	if inputMngr.Command[cmdEnum] == inputMngr.Command.CMD_STOP_MOVE_FORWARD:
	#		continue
	#	elif inputMngr.Command[cmdEnum] == inputMngr.Command.CMD_STOP_MOVE_BACKWARD:
	#		continue
	#	elif inputMngr.Command[cmdEnum] == inputMngr.Command.CMD_STOP_CROUCH:
	#		continue	
	#	elif inputMngr.Command[cmdEnum] == inputMngr.Command.CMD_START:
	#		continue	
		#don't add ripost or counter ripost commands
	#	if not inputMngr.isRipostCommand(inputMngr.Command[cmdEnum]) and not inputMngr.isCounterRipostCommand(inputMngr.Command[cmdEnum]):
	#		var cmdString = str(cmdEnum)
	#		commandSelectBtn.add_item(cmdString)
	#		reversalCommandSelectBtn.add_item(cmdString)
	for cmdString in cmdUserFriendlyNameMap.keys():
		
		commandSelectBtn.add_item(cmdString)
		reversalCommandSelectBtn.add_item(cmdString)
		
	
func _on_ripost_check_box_pressed():
	var enableFlag  = ripostCheckbox.pressed
	
	if enableFlag:
		botRipostNumHitsLine.visible=true
		botRipostCmdnNode.visible=true
	else:
		botRipostNumHitsLine.visible=false
		botRipostCmdnNode.visible=false

	
func _on_bot_command_selected(ix):
	
	var cmdString = commandSelectBtn.get_item_text(ix)
	
func _on_bot_behavior_selected(ix):
	
	var behaviortring = behaviorSelectBtn.get_item_text(ix)
	
	if behaviortring == "Spam":
		botCommandsLine.visible=true
	else:
		botCommandsLine.visible=false
				
func setGameMode(m):
	gameMode = m
	
	if gameMode == GLOBALS.GameModeType.TRAINING:
		#abilityResourceCostList.visible  =false
		trainingHUD.visible = true #DON'T MAKE it visible, the button will toggel visiblility
		trainingHUDBgd.visible = true
		#trainingHUDToggleBtnContainer.visible = true
		initializeTrainingHUDBtnToggle()
	else:
		#trainingHUDToggleBtnContainer.visible = false
		#abilityResourceCostList.visible = false
		trainingHUD.visible = false
		trainingHUDBgd.visible = false
func getGameMode():
	return gameMode

#does all bookeepikng to unpause game
func processUnpause():
	
	#make sure to reset cursor to start
	#btns[btnFocusIx].bgd.visible = false

	#btnFocusIx= 0
	pauseControlTimeoutTimer.stop()
	resultScreenOpponentUI.deactivate()
	
	hideStudentDetailsHUD()
		
	listSelection.resetCursor()
	listSelection.deactivate()
	
	#online mode?
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		pass
		#don't pause main thread when playing online
	else:
		get_tree().paused=false
	wrapper.visible = false
	set_physics_process(false)
	
	if comboList!= null:
		comboList.disable()
	
	
	#online mode?
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		pass
		#don't pause main thread when playing online
	else:
		#notify all interested that game unpaused
		get_tree().call_group(GLOBALS.GLOBAL_PAUSE_GROUP,GLOBALS.GLOBAL_PAUSE_GROUP_ON_UNPAUSE_FUNC)
		
	
#resume the game by unpausing and hiding pause menu
func resumeGame():
	
	#make sure to reset cursor to start
	#btns[btnFocusIx].bgd.visible = false

	#btnFocusIx= 0
	listSelection.resetCursor()
	listSelection.deactivate()
		
	#elif inputManager.readCommand() == DOWN:
	
	sfxPlayer.playSound(UNPAUSE_SOUND_ID)
	
	processUnpause()
	
	emit_signal("resumed")
	
func _on_button_pressed(btnName):
	
	#remapp the button press if the button overriding in result screen is activated
	if resultScreenOpponentUI.activated:
		btnName = mapOpponentRequestButtonText(btnName)
		
	if btnName== BTN_NAME_RESUME:
		resumeGame()
	
	elif btnName == BTN_NAME_STUDENT_DETAILS:
		
		
		#show the combo list and resource costs
		#hide the pause menu items and training hud
		trainingHUD.visible = false
		trainingHUDBgd.visible = false
		#$wrapper/Buttons.visible = false
		listSelection.visible = false
		listSelection.deactivate()
		pausedLabel.visible = false
		profHUD.visible = false
		
		if comboList != null:
			
			#bring combo list in focus
			comboList.activate()
			#btns[btnFocusIx].bgd.visible = false
			listSelection.visible = false
			comboList.visible = true
			comboListTemplate.visible = true
	
		if abilityResourceCostList != null:
			abilityResourceCostList.visible = false
		
	elif btnName == BTN_NAME_RESTART:
		
		processUnpause()
		emit_signal("restart_game")

	elif btnName == BTN_NAME_CHARACTER_SELECT:
		processUnpause()
		#back to character selection screen
		emit_signal("back_to_character_select") 
	elif btnName == BTN_NAME_PROFICIENCY_SELECT:
		processUnpause()
		#back to main meun
		emit_signal("back_to_proficiency_select") 
	
	elif btnName == BTN_NAME_MAIN_MENU:
		processUnpause()	
		#back to main meun
		emit_signal("back_to_main_menu")
	elif btnName == BTN_NAME_QUIT:
		processUnpause()
		
		if gameMode ==GLOBALS.GameModeType.REPLAY:
			emit_signal("back_to_main_menu")			
		else:
			#back to ONLINE lobby to display message and do any other cleanup
			emit_signal("back_to_online_lobby")
	elif btnName == BTN_NAME_STAGE_SELECT:
		processUnpause()	
		
		emit_signal("back_to_stage_select")
		
	elif btnName == BTN_NAME_SAVE_REPLAY:
		resultScreenOpponentUI.requestLabel.visible = true
		resultScreenOpponentUI.requestLabel.text = "Replayed Saved"
		emit_signal("save_replay")		
				
	else:
		
		print("unknown button pressed in pause menu")
	
func activate(_inputDeviceId,_opponentInputDeviceId,_playerController,_pauseMode):
	
	#it might be null if online peer in online mode pauses.
	#if _inputDeviceId == null:
	#	return
	#deferr the pause call to make sure the game doesn't pause
	#at this frame (want to make sure the pause command is consummed)
	call_deferred("_activate",_inputDeviceId,_opponentInputDeviceId,_playerController,_pauseMode)
	
func _activate(_inputDeviceId,_opponentInputDeviceId,_playerController,_pauseMode):
	
	
	#already paused?
	if is_physics_processing():
		return
		
	emit_signal("activated")
	
	comboListTemplate.visible = false
	pauseMode = _pauseMode
	playerController = _playerController
	
	listSelection.csvOptions = gameModeBasedUIOptionListMap[gameMode][_pauseMode]
	
	#online mode?
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		
		
		sfxPlayer.playSound(PAUSE_SOUND_ID)
		#btnFocusIx=0
		#btns[btnFocusIx].bgd.visible = true
		
		listSelection.init(gameMode,playerController) #duno why, but have to initalize it here, since it get's uninitiallized someohow
		listSelection.activate()
		listSelection.visible = true
		
		wrapper.visible = true
		
		#are we pausing the game during the match?
		if pauseMode != GLOBALS.PauseMode.RESULT_SCREEN:
			
			pausedLabel.text = MATCH_PAUSE_SCREEN_STRING			
			
		else:
			#pause wasn't done during match
			handlePauseDuringResultScreen()
			
			
		#we don't pause the main thread in online mode pause menu so games don't get outta sync
		set_physics_process(true)
	else:
			
		opponentInputDeviceId = _opponentInputDeviceId
		listSelection.inputDeviceId = _inputDeviceId
		
		sfxPlayer.playSound(PAUSE_SOUND_ID)
		#btnFocusIx=0
		#btns[btnFocusIx].bgd.visible = true
		
		listSelection.init(gameMode) #duno why, but have to initalize it here, since it get's uninitiallized someohow
		listSelection.activate()
		listSelection.visible = true
		
		wrapper.visible = true
		#inputManager.inputDeviceId = _inputDeviceId
		inputDeviceId = _inputDeviceId
		
		#are we pausing the game during the match?
		#if playerController != null:
		if pauseMode != GLOBALS.PauseMode.RESULT_SCREEN:
			
			pausedLabel.text = MATCH_PAUSE_SCREEN_STRING
			#remove previous player's combo list from being displayed
			for c in comboListTemplate.get_children():
				comboListTemplate.remove_child(c)
				
			#combo list of player not generated yet? #TODO: generate this when the game loads. it creates 
			#lag the first time you pause, and during an online match that lag can cause drift
			#if not comboListMap.has(_inputDeviceId):
			#	comboList = comboListResource.instance()
				
			#	comboListMap[_inputDeviceId] =comboList
			#	comboListTemplate.add_child(comboList)
				
				#comboList.populateGridWithCmdInfo(playerController)
				
#			else:#used cached combo list from 1st time player paused, to avoid loading the combos twice

			if comboListMap.has(_inputDeviceId):
				comboList=comboListMap[_inputDeviceId]
				comboListTemplate.add_child(comboList)
			
			#comboList.visible = true
			#comboListTemplate.visible = true
			comboList.visible = false
			comboListTemplate.visible = false
			
			profHUD.visible = true
			wasProfChoiceVisible = true
			#profHUD.displayProficiencies(playerController.kinbody.advProf,playerController.kinbody.disProf)
			profHUD.displayProficiencies(playerController.kinbody.majorProf1Ix,playerController.kinbody.minorProf1Ix,
										playerController.kinbody.majorProf2Ix,playerController.kinbody.minorProf2Ix)
			
			
			abilityResourceCostList.populateGridWithAbilityBasedCmdInfo(playerController)
			
			#only decide on the ability resoruce visiblity in trainingmod.
			#normal mode alway visible
	#		if trainingHUDToggleBtn!=null:
	#			if not trainingHUDToggleBtn.pressed:
	#				abilityResourceCostList.visible = true
	#			else:
	#				abilityResourceCostList.visible = false				
			abilityResourceCostList.visible = false				
		else:
			#pause wasn't done during match
			handlePauseDuringResultScreen()
		
		#inputManager.set_physics_process(true)
		set_physics_process(true)

		
		#make sure all the nodes interested in pause signal are notified
		get_tree().call_group(GLOBALS.GLOBAL_PAUSE_GROUP,GLOBALS.GLOBAL_PAUSE_GROUP_ON_PAUSE_FUNC)		
		get_tree().paused=true
	
func handlePauseDuringResultScreen():
	
	#TODO: add logic for online to avoid doing stuff that isn't necessary
	pausedLabel.text = RESULT_SCREEN_PAUSE_SCREEN_STRING
	abilityResourceCostList.visible = false
	profHUD.visible = false
	wasProfChoiceVisible = false
	comboListTemplate.visible = false
	
	#only offline 1v1 with 2 players to we activate timer to track the pause control
	#timeout
	if gameMode == GLOBALS.GameModeType.STANDARD:
		pauseControlTimeoutTimer.startInSeconds(RESULT_SCREEN_PAUSE_CONTROL_TIMEOUT_DURATION)
	
	#can't override the UI naviagtion in online mode as forced to restart or quit
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		pass
	else:
		#now that were in result screen, show the ui for the oppoent of player with
		#control over pause menu items
		resultScreenOpponentUI.activate(opponentInputDeviceId)
		
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	var btnBPressed=false
	var btnStartPressed=false
	var btnUpPressed=false
	var btnDownPressed=false
	#online mode?
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
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
			
			if _inputMngr.lastCommand == _inputMngr.Command.CMD_NEUTRAL_TOOL:
				btnBPressed=true
				
		
			elif _inputMngr.lastCommand == _inputMngr.Command.CMD_START:
				btnStartPressed=true
								
			elif _inputMngr.lastCommand == _inputMngr.Command.CMD_STOP_CROUCH: 
				btnDownPressed=true
			
		
	else:
		
		if Input.is_action_just_pressed(inputDeviceId+"_B"):
			btnBPressed=true
			
	
		elif Input.is_action_just_pressed(inputDeviceId+"_START"):
			btnStartPressed=true
			
			
			
		#ignore any cursor command when com list is in focus
		if not btnBPressed and not btnStartPressed and comboList != null and comboList.active:
			return
			
		
		if Input.is_action_just_pressed(inputDeviceId+"_UP"):
			btnUpPressed=true
			

		elif Input.is_action_just_pressed(inputDeviceId+"_DOWN"):
			btnDownPressed=true
	
	
	if btnBPressed:
		hideStudentDetailsHUD()
	
	elif btnStartPressed:
	
		#only unpause game with start button when pausing in game normally and controller disconnect
		#otherwise in result screen and in case that forces restart or quit you can't	
		if 	pauseMode == GLOBALS.PauseMode.IN_GAME or pauseMode == GLOBALS.PauseMode.CONTROLLER_DC:			
			resumeGame()

	
	elif btnUpPressed:
		#make sound of ui selection
		sfxPlayer.playSound(UI_MOVE_CURSOR_SOUND_ID)
	
	elif btnDownPressed:
		#make sound of ui selection
		sfxPlayer.playSound(UI_MOVE_CURSOR_SOUND_ID)
				

#called when a controller disconnects (unplug, for example)
#and was previously connected
func _on_controller_disconnected(deviceId):	

	#indicate what controller DC'ed
	var dcStringToDisplay = deviceId + " " +CONTROLLER_DC_TEXT
	controllerDCLabel.text = dcStringToDisplay
	controllerDCLabel.visible = true

#called when a controller connects and was previsouly disconnected
func _on_controller_connected(deviceId):
	controllerDCLabel.visible = false
	
	
func _on_training_hud_toggle():
	
	pass
	#if trainingHUDToggleBtn.pressed:
	#	abilityResourceCostList.visible  =false
	#	trainingHUD.visible = true
	#	trainingHUDBgd.visible = true
		
	#else:
	#	abilityResourceCostList.visible = true
	#	trainingHUD.visible = false
	#	trainingHUDBgd.visible = false
	#pass
	
func hideStudentDetailsHUD():
		#here we re display all hidden items that where hidden by hero details
		
		#only show proficiencies if there were visible 
		if wasProfChoiceVisible == true:
			profHUD.visible = true
		pausedLabel.visible = true
		if gameMode == GLOBALS.GameModeType.TRAINING:
			trainingHUD.visible = true
			trainingHUDBgd.visible = true
		#$wrapper/Buttons.visible = true
	
		#bring the mpause buttons back in focus
		#btns[btnFocusIx].bgd.visible = true
		listSelection.visible = true
		listSelection.activate()
		
		if comboList != null:
			
			
			
		
			comboList.visible = false
			comboListTemplate.visible = false
			
			comboList.disable()
		if abilityResourceCostList != null:
			abilityResourceCostList.visible = false


func _on_toggle_resource_cost_visibility():
	abilityResourceCostList.visible = not abilityResourceCostList.visible
	
#converts the text of button chosen to a new text depending on the request of opponent
#e.g: select "rematch" would map to "character select" (or w/e the exact text) if
#the opponent pressed the button to have request = Request.CHARACTER_SELECTION
func mapOpponentRequestButtonText(btnName):
	var remappedBtnName = btnName
	match(btnName):
		BTN_NAME_RESUME:
			pass #not remapped
		BTN_NAME_STUDENT_DETAILS:
			pass #not remapped			
		BTN_NAME_STAGE_SELECT:
			#can't go to stage select if the player requested proficiency selection or character select
			if resultScreenOpponentUI.request == resultScreenOpponentUI.Request.PROFICIENCY_SELECTION:
				remappedBtnName=BTN_NAME_PROFICIENCY_SELECT
			elif resultScreenOpponentUI.request == resultScreenOpponentUI.Request.CHARACTER_SELECTION:
				remappedBtnName=BTN_NAME_CHARACTER_SELECT			
			
		BTN_NAME_RESTART:
			#can't restart the match if the player requested proficiency selection, stage select, or character select
			if resultScreenOpponentUI.request == resultScreenOpponentUI.Request.PROFICIENCY_SELECTION:
				remappedBtnName=BTN_NAME_PROFICIENCY_SELECT
			elif resultScreenOpponentUI.request == resultScreenOpponentUI.Request.CHARACTER_SELECTION:
				remappedBtnName=BTN_NAME_CHARACTER_SELECT
			elif resultScreenOpponentUI.request == resultScreenOpponentUI.Request.STAGE_SELECTION:
				remappedBtnName=BTN_NAME_STAGE_SELECT
					
		BTN_NAME_CHARACTER_SELECT:
			 pass #not remapped
		BTN_NAME_PROFICIENCY_SELECT:
			#chracter select request will override  proficiency selection since 
			#both character choices stay the same if you go back to proficiency select
			if resultScreenOpponentUI.request == resultScreenOpponentUI.Request.CHARACTER_SELECTION:
				remappedBtnName=BTN_NAME_CHARACTER_SELECT
		BTN_NAME_MAIN_MENU:
			pass #not remapped
			
	return remappedBtnName
	


#loads the player's autocancel info and creates and cahches the student info combo list elements
func preloadComboListInfo(playerController1,playerController2):
	var comboList =null
	#can only preload once.
	if not comboListMap.has(GLOBALS.PLAYER1_INPUT_DEVICE_ID):
		comboList = newComboListResource.instance()
		
		comboListMap[GLOBALS.PLAYER1_INPUT_DEVICE_ID] =comboList
		comboListTemplate.add_child(comboList)
		#func init(_inputManager,_actionAnimeManager,movesetListScenePath):
		comboList.init(GLOBALS.PLAYER1_INPUT_DEVICE_ID,playerController1,playerController1.heroName)
		
		
		comboList.connect("toggle_resource_cost_visibility",self,"_on_toggle_resource_cost_visibility")
		
		
		playerController1.connect("inactive_projectile_instanced",comboList,"_on_inactive_projectile_instanced")
		#comboList.populateGridWithCmdInfo(playerController1)	
	#can only preload once.
	if not comboListMap.has(GLOBALS.PLAYER2_INPUT_DEVICE_ID):
		comboList = newComboListResource.instance()
		
		comboListMap[GLOBALS.PLAYER2_INPUT_DEVICE_ID] =comboList
		comboListTemplate.add_child(comboList)
		comboList.init(GLOBALS.PLAYER2_INPUT_DEVICE_ID,playerController2,playerController2.heroName)
		
		comboList.connect("toggle_resource_cost_visibility",self,"_on_toggle_resource_cost_visibility")
		#comboList.populateGridWithCmdInfo(playerController2)	
		playerController2.connect("inactive_projectile_instanced",comboList,"_on_inactive_projectile_instanced")

#loads the player's autocancel info and creates and cahches the student info combo list elements
func oldpreloadComboListInfo(playerController1,playerController2):
	var comboList =null
	#can only preload once.
	if not comboListMap.has(GLOBALS.PLAYER1_INPUT_DEVICE_ID):
		comboList = comboListResource.instance()
		
		comboListMap[GLOBALS.PLAYER1_INPUT_DEVICE_ID] =comboList
		comboListTemplate.add_child(comboList)
		comboList.populateGridWithCmdInfo(playerController1)	
	#can only preload once.
	if not comboListMap.has(GLOBALS.PLAYER2_INPUT_DEVICE_ID):
		comboList = comboListResource.instance()
		
		comboListMap[GLOBALS.PLAYER2_INPUT_DEVICE_ID] =comboList
		comboListTemplate.add_child(comboList)
		comboList.populateGridWithCmdInfo(playerController2)	

func _on_menu_override_requested():
	sfxPlayer.playSound(UI_OVERRIDE_CONFIRM_SOUND_ID)


func _on_pauseControlTimeoutTimer_timeout():
	#only unpause if we already are paused
	if self.is_physics_processing():
		processUnpause()