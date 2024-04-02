extends Control
signal back
signal save

const DEBUG=false
const inputManagerResource = preload("res://input_manager.gd")
const GLOBALS = preload("res://Globals.gd")


const REMAPPING_LAST_LEFT_COLUMN_SLOT_INDEX = 6
const REMAPPING_LEFT_COLUMN_SIZE = 7

export (Color) var unselectedColor = Color(0,0,0)
export (Color) var selectedColor = Color(0,0,0)
enum State{
	
	MAIN,
	ABOUT_TO_REMAP_BUTTON,
	REMAPPING_BUTTON,
	TOGGLING_OTHER_SETTINGS
}

enum ButtonId{
	L2,
	L1,
	R2,
	R1,
	X,
	Y,
	B,
	A,
	LEFT_R2_MACRO,
	RIGHT_R2_MACRO,
	DOWN_R2_MACRO,
	L2_R1_MACRO,
	L1_R1_MACRO
}

#given a button id as index, fetches the button's name
const buttonNames = ["Ability",
"Grab",
"Dash",
"Ripost",
"Melee",
"Special",
"Tool",
"Jump",
"Back Dash", 
"Forward Dash",
"Fast Fall",
"Auto Ripost", 
"Counter Ripost"]

#given a button id as index, fetches the button bitmap macro
const buttonBitMaps=[inputManagerResource.BTN_LEFT_TRIGGER, #ABILITY
inputManagerResource.BTN_LEFT_BUMPER, #GRAB
inputManagerResource.BTN_RIGHT_TRIGGER, #DASH
inputManagerResource.BTN_RIGHT_BUMPER, #RIPOST
inputManagerResource.BTN_X, #MELEE
inputManagerResource.BTN_Y,#SPECIAL
inputManagerResource.BTN_B,#TOOL
inputManagerResource.BTN_A,#JUMP
inputManagerResource.BTN_LEFT | inputManagerResource.BTN_RIGHT_TRIGGER, #BACK DASH
inputManagerResource.BTN_RIGHT | inputManagerResource.BTN_RIGHT_TRIGGER, #FORWARD DASH
inputManagerResource.BTN_DOWN | inputManagerResource.BTN_RIGHT_TRIGGER, #FAST FALL
inputManagerResource.BTN_LEFT_TRIGGER | inputManagerResource.BTN_RIGHT_BUMPER, #AUTO RIPOST
inputManagerResource.BTN_LEFT_BUMPER | inputManagerResource.BTN_RIGHT_BUMPER] #COUNTER RIPOST


#given a button bit map fetches the id of the button
const buttonBitInverseMap={buttonBitMaps[ButtonId.L2]:ButtonId.L2,
buttonBitMaps[ButtonId.L1]:ButtonId.L1,
buttonBitMaps[ButtonId.R2]:ButtonId.R2,
buttonBitMaps[ButtonId.R1]:ButtonId.R1,
buttonBitMaps[ButtonId.X]:ButtonId.X,
buttonBitMaps[ButtonId.Y]:ButtonId.Y,
buttonBitMaps[ButtonId.B]:ButtonId.B,
buttonBitMaps[ButtonId.A]:ButtonId.A,
buttonBitMaps[ButtonId.LEFT_R2_MACRO]:ButtonId.LEFT_R2_MACRO,
buttonBitMaps[ButtonId.RIGHT_R2_MACRO]:ButtonId.RIGHT_R2_MACRO,
buttonBitMaps[ButtonId.DOWN_R2_MACRO]:ButtonId.DOWN_R2_MACRO,
buttonBitMaps[ButtonId.L2_R1_MACRO]:ButtonId.L2_R1_MACRO,
buttonBitMaps[ButtonId.L1_R1_MACRO]:ButtonId.L1_R1_MACRO
}

const remappableBtnKeys=[
	inputManagerResource.BTN_A_KEY,
	inputManagerResource.BTN_B_KEY,
	inputManagerResource.BTN_X_KEY,
	inputManagerResource.BTN_Y_KEY,	
	inputManagerResource.BTN_RIGHT_BUMPER_KEY,	
	inputManagerResource.BTN_RIGHT_TRIGGER_KEY,
	inputManagerResource.BTN_LEFT_TRIGGER_KEY,
	inputManagerResource.BTN_LEFT_BUMPER_KEY,
	inputManagerResource.BTN_C_STICK_LEFT_KEY,
	inputManagerResource.BTN_C_STICK_RIGHT_KEY,
	inputManagerResource.BTN_C_STICK_UP_KEY,
	inputManagerResource.BTN_C_STICK_DOWN_KEY
	
]
var state = State.MAIN

#has nodes to toggle visibility in specific states
var nodeVisibilityMap = {}


var mainBtnSlotLabels = {}
var changingButtonBtnSlots=[]
var playerNameLabel=null

var inputRemapModel = null

var changesMadeFlag=false

var inputDeviceIds= []

var backArrow = null

var remappingBtnTitleBtnSlotLabel=null
var remappingBtnTitleBtnSlotTextureRec=null

const defaultButtonLayoutNamesMap = {
	inputManagerResource.BTN_A_KEY: "Jump",
	inputManagerResource.BTN_B_KEY: "Tool",
	inputManagerResource.BTN_X_KEY: "Melee",
	inputManagerResource.BTN_Y_KEY: "Special",
	inputManagerResource.BTN_RIGHT_BUMPER_KEY: "Ripost",
	inputManagerResource.BTN_RIGHT_TRIGGER_KEY: "Dash",
	inputManagerResource.BTN_LEFT_TRIGGER_KEY: "Ability",
	inputManagerResource.BTN_LEFT_BUMPER_KEY: "Grab",
	inputManagerResource.BTN_C_STICK_LEFT_KEY: "Back Dash",
	inputManagerResource.BTN_C_STICK_RIGHT_KEY: "Forward Dash",
	inputManagerResource.BTN_C_STICK_UP_KEY: "Auto Ripost",
	inputManagerResource.BTN_C_STICK_DOWN_KEY: "Fast Fall"
}

var saveTipNode = null
var restoreDefaultsTipNode=null


#Stores lists of flags that indicate for a button what are legal remaps

const remappingAvailabilityMap = {	
												#ability,grab,back-dash,forward-dash,fast-fall,auto ripost, counter ripsot, dash, ripost, melee, special,tool,jump
	inputManagerResource.BTN_A_KEY: 			[true,   true,false,    false,       false,    true,       true,           true,  true,   true,  true,   true ,true],
	inputManagerResource.BTN_B_KEY: 			[true,   true,false,    false,       false,    true,       true,           true,  true,   true,  true,   true ,true],
	inputManagerResource.BTN_X_KEY: 			[true,   true,false,    false,       false,    true,       true,           true,  true,   true,  true,   true ,true],
	inputManagerResource.BTN_Y_KEY: 			[true,   true,false,    false,       false,    true,       true,           true,  true,   true,  true,   true ,true],
	inputManagerResource.BTN_RIGHT_BUMPER_KEY: 	[true,   true,false,    false,       false,    true,       true,           true,  true,   true,  true,   true ,true],
	inputManagerResource.BTN_RIGHT_TRIGGER_KEY: [true,   true,false,    false,       false,    true,       true,           true,  true,   true,  true,   true ,true],
	inputManagerResource.BTN_LEFT_TRIGGER_KEY: 	[true,   true,false,    false,       false,    true,       true,           true,  true,   true,  true,   true ,true],
	inputManagerResource.BTN_LEFT_BUMPER_KEY:   [true,   true,false,    false,       false,    true,       true,           true,  true,   true,  true,   true ,true],
	inputManagerResource.BTN_C_STICK_LEFT_KEY: 	[true,   true,true,    false,       false,    true,       false,           true,  false,   true,  true,   true ,true],
	inputManagerResource.BTN_C_STICK_RIGHT_KEY: [true,   true,false,    true,       false,    true,       false,           true,  false,   true,  true,   true ,true],
	inputManagerResource.BTN_C_STICK_UP_KEY:  	[true,   true,false,    false,       false,    true,       false,           true,  false,   true,  true,   true ,true],
	inputManagerResource.BTN_C_STICK_DOWN_KEY: 	[true,   true,false,    false,       true,    true,       false,           true,  false,   true,  true,   true ,true]
}

const remappingMoveCursorMoveInputs = [inputManagerResource.BTN_UP_KEY,inputManagerResource.BTN_DOWN_KEY,inputManagerResource.BTN_LEFT_KEY,inputManagerResource.BTN_RIGHT_KEY]

var remappingBtnCursorIx = 0
var dblTapMvmCursorIx = 0
var btnBeingRemappedKey=null


const changingButtonBtnSlotBtnId = [

	ButtonId.L2,#ability")
	ButtonId.L1,#grab")
	ButtonId.LEFT_R2_MACRO,#back-dash")
	ButtonId.RIGHT_R2_MACRO,#forward-dash")
	ButtonId.DOWN_R2_MACRO,#fastfall")
	ButtonId.L2_R1_MACRO,#auto-ripost")
	ButtonId.L1_R1_MACRO,#counter-ripost")
	ButtonId.R2,#dash")
	ButtonId.R1,#ripost")
	ButtonId.X,#melee")
	ButtonId.Y,#special")
	ButtonId.B,#tool")
	ButtonId.A#jump")
]

var otherSettingsBtnSlots = []

const otherSettingsBtnSlotBtnKeys = [
	inputManagerResource.CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_UP_KEY,
	inputManagerResource.CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_RIGHT_KEY,
	inputManagerResource.CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_DOWN_KEY,
	inputManagerResource.CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_LEFT_KEY,
	inputManagerResource.CUSTOM_INPUT_SETTINGS_RIPOST_INPUT_MATCH_FACING_KEY
]

var playerName = null
# Called when the node enters the scene tree for the first time.
func _ready():
	nodeVisibilityMap[State.MAIN]=[$"Middle/MainState",$"Footers/MainState"]
	nodeVisibilityMap[State.REMAPPING_BUTTON]=[$"Middle/ChangingButtonState",$"Footers/ChangingButtonState"]
	nodeVisibilityMap[State.TOGGLING_OTHER_SETTINGS]=[$"Middle/ChangingOtherSettingsState",$"Footers/ChangingOtherSettingsState"]
	nodeVisibilityMap[State.ABOUT_TO_REMAP_BUTTON]=[$"Middle/remapTip",$"Middle/MainState"]
	
	
	#initialize button maps to fetch relevant nodes
	mainBtnSlotLabels[inputManagerResource.BTN_A_KEY] = $"Middle/MainState/slots/center-right-slots/ButtonSlot-A"
	mainBtnSlotLabels[inputManagerResource.BTN_B_KEY] = $"Middle/MainState/slots/center-right-slots/ButtonSlot-B"
	mainBtnSlotLabels[inputManagerResource.BTN_X_KEY] = $"Middle/MainState/slots/center-right-slots/ButtonSlot-X"
	mainBtnSlotLabels[inputManagerResource.BTN_Y_KEY] = $"Middle/MainState/slots/center-right-slots/ButtonSlot-Y"
	mainBtnSlotLabels[inputManagerResource.BTN_RIGHT_BUMPER_KEY] = $"Middle/MainState/slots/top-right-slots/ButtonSlot-R1"
	mainBtnSlotLabels[inputManagerResource.BTN_RIGHT_TRIGGER_KEY] = $"Middle/MainState/slots/top-right-slots/ButtonSlot-R2"
	mainBtnSlotLabels[inputManagerResource.BTN_LEFT_TRIGGER_KEY] = $"Middle/MainState/slots/top-left-slots/ButtonSlot-L2"
	mainBtnSlotLabels[inputManagerResource.BTN_LEFT_BUMPER_KEY]= $"Middle/MainState/slots/top-left-slots/ButtonSlot-L1"
	mainBtnSlotLabels[inputManagerResource.BTN_C_STICK_LEFT_KEY] = $"Middle/MainState/slots/center-left-slots/ButtonSlot-CSTICK-left"
	mainBtnSlotLabels[inputManagerResource.BTN_C_STICK_RIGHT_KEY] = $"Middle/MainState/slots/center-left-slots/ButtonSlot-CSTICK-right"
	mainBtnSlotLabels[inputManagerResource.BTN_C_STICK_UP_KEY] = $"Middle/MainState/slots/center-left-slots/ButtonSlot-CSTICK-up"
	mainBtnSlotLabels[inputManagerResource.BTN_C_STICK_DOWN_KEY] = $"Middle/MainState/slots/center-left-slots/ButtonSlot-CSTICK-DOWN"
	
	
	otherSettingsBtnSlots.append($"Middle/ChangingOtherSettingsState/VBoxContainer/ButtonSlot-up")
	otherSettingsBtnSlots.append($"Middle/ChangingOtherSettingsState/VBoxContainer/ButtonSlot-right")
	otherSettingsBtnSlots.append($"Middle/ChangingOtherSettingsState/VBoxContainer/ButtonSlot-down")
	otherSettingsBtnSlots.append($"Middle/ChangingOtherSettingsState/VBoxContainer/ButtonSlot-left")
	otherSettingsBtnSlots.append($"Middle/ChangingOtherSettingsState/VBoxContainer/ButtonSlot-RIPOSTfacing")
	
	#list of remap button slots  in order of cursor (first you traverse left column, then right column)
	changingButtonBtnSlots.append($"Middle/ChangingButtonState/VBoxContainer/ButtonSlot-ability")
	changingButtonBtnSlots.append($"Middle/ChangingButtonState/VBoxContainer/ButtonSlot-grab")
	changingButtonBtnSlots.append($"Middle/ChangingButtonState/VBoxContainer/ButtonSlot-back-dash")
	changingButtonBtnSlots.append($"Middle/ChangingButtonState/VBoxContainer/ButtonSlot-forward-dash")
	changingButtonBtnSlots.append($"Middle/ChangingButtonState/VBoxContainer/ButtonSlot-fastfall")
	changingButtonBtnSlots.append($"Middle/ChangingButtonState/VBoxContainer/ButtonSlot-auto-ripost")
	changingButtonBtnSlots.append($"Middle/ChangingButtonState/VBoxContainer/ButtonSlot-counter-ripost")
	changingButtonBtnSlots.append($"Middle/ChangingButtonState/VBoxContainer/ButtonSlot-dash")
	changingButtonBtnSlots.append($"Middle/ChangingButtonState/VBoxContainer/ButtonSlot-ripost")
	changingButtonBtnSlots.append($"Middle/ChangingButtonState/VBoxContainer/ButtonSlot-melee")
	changingButtonBtnSlots.append($"Middle/ChangingButtonState/VBoxContainer/ButtonSlot-special")
	changingButtonBtnSlots.append($"Middle/ChangingButtonState/VBoxContainer/ButtonSlot-tool")
	changingButtonBtnSlots.append($"Middle/ChangingButtonState/VBoxContainer/ButtonSlot-jump")
	
	
	remappingBtnTitleBtnSlotLabel=$"Middle/ChangingButtonState/TitleButtonSlot/btn-name"
	remappingBtnTitleBtnSlotTextureRec=$"Middle/ChangingButtonState/TitleButtonSlot/btnTexture"
	
	
	playerNameLabel = $"Header/pName"

	
	saveTipNode = $"Footers/MainState/save"

	saveTipNode.visible = false
	restoreDefaultsTipNode=$"Footers/MainState/default"
	restoreDefaultsTipNode.visible = false
	
			
	backArrow = $"Footers/back-arrow"
	backArrow.connect("back",self,"emit_signal",["back"])#emit back signal when back arrow node goes back
	
	

	inputDeviceIds.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDeviceIds.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	
	disable()
	#DEBUG
	if DEBUG:
		var playerControllerLayoutMap = {}
		playerControllerLayoutMap[inputManagerResource.BTN_C_STICK_UP_KEY]=inputManagerResource.BTN_LEFT_BUMPER | inputManagerResource.BTN_RIGHT_BUMPER
		playerControllerLayoutMap[inputManagerResource.BTN_LEFT_BUMPER_KEY]=inputManagerResource.BTN_A
		#playerControllerLayoutMap=null
		init("rc80",playerControllerLayoutMap)
		
	
	
func enable():
	set_physics_process(true)
	backArrow.disabledFlagInpudDeviceMap[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = false
	backArrow.disabledFlagInpudDeviceMap[GLOBALS.PLAYER2_INPUT_DEVICE_ID] =false

func disable():
	backArrow.disabledFlagInpudDeviceMap[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = true
	backArrow.disabledFlagInpudDeviceMap[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = true
	set_physics_process(false)
func init(_playerName,playerControllerLayoutMap):
	playerName =_playerName
	enable()
	btnBeingRemappedKey =null
	
	disableInputModelChanged()
	
	#remappingBtnCursorIx = 0
	moveRemappingBtnCursor(0)
	setOtherSettingsCursor(0)
	
	changeState(State.MAIN)
	
	playerNameLabel.text = playerName
	#playerControllerLayoutMap key: inputManagerResource.BTN_i_KEY
	#playerControllerLayoutMap value: btn bit map
	#default button layout
	if playerControllerLayoutMap == null:
		restoreDefaultButtonLayout()
	else:
		#show the tip to illustrate can restore defaults
		restoreDefaultsTipNode.visible = true
		#update the UI with the button layout of player
		
		#iterate over everey btn key
		for btnKey in playerControllerLayoutMap.keys():
			
			var btnBitMap = playerControllerLayoutMap[btnKey]
			
			if not buttonBitInverseMap.has(btnBitMap):
				print("button layout loaded is corrupted, coulcn't find the button bit map. doing default layout")
				break
			#lookup the button id  assosicate to this script
			var btnId = buttonBitInverseMap[btnBitMap]
			
			#lookup button name 
			var btnName =buttonNames[btnId]
			
			#lookup the label that we will update to relfect the remapping
			var label = mainBtnSlotLabels[btnKey].get_node("btn-name")
			
			label.text = btnName
		pass
		
		
	inputRemapModel=playerControllerLayoutMap
	
	
	

func restoreDefaultButtonLayout():
	
	var changesToInputModel = inputRemapModel!=null
	
	#to illustrate already defulat buttons, hide the tip
	restoreDefaultsTipNode.visible = false
	inputRemapModel=null
	#set the names to default layout
	for btnKey in defaultButtonLayoutNamesMap.keys():
		var btnName = defaultButtonLayoutNamesMap[btnKey]
		var btnLabel = mainBtnSlotLabels[btnKey].get_node("btn-name")
		btnLabel.text =btnName
		
	#a changes made to input remapping model?
	if changesToInputModel :		
		enableInputModelChanged()
		
func enableInputModelChanged():
	#we made changes
	changesMadeFlag=true
	saveTipNode.visible = true
	if DEBUG:
		debugPrintInputRemapModel()

func disableInputModelChanged():	
	#show we save by hidding the tip					
	changesMadeFlag=false
	saveTipNode.visible = false
	
func changeState(newState):
	
	
	for stateKey in nodeVisibilityMap.keys():
		var visibleNodes = nodeVisibilityMap[stateKey]
		for node in visibleNodes:
			#only nodes for new state are shown. others invisible			
			node.visible=stateKey ==newState
			
	#make sure nodes that are in 2 different states that should be visible are shown
	var visibleNodes = nodeVisibilityMap[newState]
	for node in visibleNodes:
		#only nodes for new state are shown. others invisible			
		node.visible=true
			
	state = newState

	if state == State.MAIN:
		#players can go back to main menu when in main staet
		backArrow.disabledFlagInpudDeviceMap[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = false
		backArrow.disabledFlagInpudDeviceMap[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = false
	else:
		#players can't back from menu since they are doing something and need to confirm or cancel what their doing
		backArrow.disabledFlagInpudDeviceMap[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = true
		backArrow.disabledFlagInpudDeviceMap[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = true


func beginRemappingButton(btnKey):
	btnBeingRemappedKey=btnKey
	
	var chosenBtnSlot = mainBtnSlotLabels[btnKey]
	var btnTextureRec = chosenBtnSlot.get_node("btnTexture")
	var btnNameLabel = chosenBtnSlot.get_node("btn-name")
	
	#for the button we just pressed to remap, take it's texture and the current remapping (if any) and 
	#display in title of remapping screen
	remappingBtnTitleBtnSlotLabel.text=btnNameLabel.text
	remappingBtnTitleBtnSlotTextureRec.texture=btnTextureRec.texture
	
	#gets flags indicating if the remapping for given button is okay
	var remapingAvailabilityList = remappingAvailabilityMap[btnKey]
	
	
	
	#update the little icon to indiacte if available or not for all possible rempas
	for slotIx in changingButtonBtnSlots.size():
		var slot = changingButtonBtnSlots[slotIx]
		
		var availableFlag = remapingAvailabilityList[slotIx]
		var availableIcon = slot.get_node("availableIcon")
		var unavailableIcon = slot.get_node("unavailableIcon")
		
		#gray when unavailalbe, highlitghed when availalbe
		availableIcon.visible = availableFlag
		unavailableIcon.visible = not availableFlag
		
		#we can't remap a button to the button already mapped (e.g., if R1 is mapped to jump, 
		#jump is unavailalbe since we already have jump mapped)
		var slotBtnId = changingButtonBtnSlotBtnId[slotIx]
		var slotBtnName = buttonNames[slotBtnId]
		
		if slotBtnName ==btnNameLabel.text:
			#unavailable
			availableIcon.visible = false
			unavailableIcon.visible = true
	
	moveRemappingBtnCursor(0)
	
		
	changeState(State.REMAPPING_BUTTON)
							
#for the remapping, I should add a script to each slot. Then athe butoon id will be attached
#up and down will iterate a cursor over the available slots (hightlight their background on select)
#will need to define a map that holds a list of all acceptable remaps given a button id.
#e.g., only right stick - richt allows forward dasah.
#on cofirm the selection, change state and update the main ui and the button input model
func moveRemappingBtnCursor(ix):
	
	var slot = changingButtonBtnSlots[remappingBtnCursorIx]
	
	# set unselect color background of old slot
	var bgdColorRec = slot.get_node("white")
	bgdColorRec.color = unselectedColor
	
	remappingBtnCursorIx = ix
	slot = changingButtonBtnSlots[remappingBtnCursorIx]
	#set bgd color of selected slot
	bgdColorRec = slot.get_node("white")
	bgdColorRec.color = selectedColor
	
	
func _moveRemappingBtnCursor(moveCursorBtnKey):
	
	var newCursor
	match(moveCursorBtnKey):
		inputManagerResource.BTN_UP_KEY:
			#first elements of right column
			if remappingBtnCursorIx == (REMAPPING_LAST_LEFT_COLUMN_SLOT_INDEX +1):
				#got to last element of right column
				newCursor=changingButtonBtnSlots.size()-1
				
			#first element of left column?
			elif remappingBtnCursorIx==0:
				#go to last of left column
				newCursor=REMAPPING_LAST_LEFT_COLUMN_SLOT_INDEX
				
			else:
				newCursor=(remappingBtnCursorIx -1) %changingButtonBtnSlots.size()
		inputManagerResource.BTN_DOWN_KEY:
			#last elements of right column
			if remappingBtnCursorIx == (changingButtonBtnSlots.size() -1):
				#got to first element of right column
				newCursor=REMAPPING_LAST_LEFT_COLUMN_SLOT_INDEX+1
				
			#last element of left column?
			elif remappingBtnCursorIx==REMAPPING_LAST_LEFT_COLUMN_SLOT_INDEX:
				#go to first of left column
				newCursor=0
				
			else:
				newCursor=(remappingBtnCursorIx +1) %changingButtonBtnSlots.size()
		inputManagerResource.BTN_LEFT_KEY:
			#can't move cursor left if in left column
			if remappingBtnCursorIx <= REMAPPING_LAST_LEFT_COLUMN_SLOT_INDEX:
				return
			
			#GO LEFT ONE ELEMENT IN 2 COLUMN LIST
			newCursor =(remappingBtnCursorIx -REMAPPING_LEFT_COLUMN_SIZE) %changingButtonBtnSlots.size()
		inputManagerResource.BTN_RIGHT_KEY:
			#can't move cursor right if in right column or is the last element of left column (nothing to right)
			if remappingBtnCursorIx >= REMAPPING_LAST_LEFT_COLUMN_SLOT_INDEX:
				return
			
			#the last element in left column is exception, since right nothing is there
			#and
			#GO RIGHT ONE ELEMENT IN 2 COLUMN LIST
			newCursor =(remappingBtnCursorIx +REMAPPING_LEFT_COLUMN_SIZE) %changingButtonBtnSlots.size()
		_:
			return
	
	#move the cursore and update the selection ui
	
	moveRemappingBtnCursor(newCursor)

#this confirms a remapping (determined by slotix) of current button selected 
func remapButton(slotIx):

		
		
	var chosenBtnSlot = mainBtnSlotLabels[btnBeingRemappedKey]
	#var btnTextureRec = chosenBtnSlot.get_node("btnTexture")
	var btnNameLabel = chosenBtnSlot.get_node("btn-name")
	
	#id of the new button remapping
	var selectedRemapSlotBtnId = changingButtonBtnSlotBtnId[remappingBtnCursorIx]
	
	#remapping to same button already mapped to?
	if btnNameLabel.text == buttonNames[selectedRemapSlotBtnId]:
		return
		
	
	#update main screen with new button mapping
	btnNameLabel.text = buttonNames[selectedRemapSlotBtnId]
	
	#same as default configuration?
	if defaultButtonLayoutNamesMap[btnBeingRemappedKey] == btnNameLabel.text:
		
		#we null the remap entry since it's back to default configuration
		if inputRemapModel != null and inputRemapModel.has(btnBeingRemappedKey):
			inputRemapModel.erase(btnBeingRemappedKey)
			
			#no more remaps?
			if inputRemapModel.keys().size() == 0:
				inputRemapModel=null
	
	else:
		if inputRemapModel == null:
			inputRemapModel={}
			
		inputRemapModel[btnBeingRemappedKey]=buttonBitMaps[selectedRemapSlotBtnId]
		
	
	enableInputModelChanged()
	
	changeState(State.MAIN)

#reutrns true if the current selected btn slot in remapping menu can be remapped given
#the button being re mapped
func isBtnRemappable(slotIx):
	if btnBeingRemappedKey == null:
		return false
		
	if slotIx < 0 or slotIx >=changingButtonBtnSlots.size():
		return false
		
	return remappingAvailabilityMap[btnBeingRemappedKey][slotIx]

func debugPrintInputRemapModel():
	print("input model: ")
	if inputRemapModel == null:
		print("null")
	else:
		for key in inputRemapModel.keys():
			print("[key, value]: " + str(key)+ ","+str(inputRemapModel[key]))
	
func moveOtherSettingCursor(upFlag):
	var newCursor=0
	#going up the list?
	if upFlag:
		newCursor = dblTapMvmCursorIx-1
	else:
		#going down
		newCursor = dblTapMvmCursorIx+1
	
	#bounds check to make it loop back to top or bot of list
	if newCursor < 0: 
		newCursor=otherSettingsBtnSlots.size()-1
	if newCursor >= otherSettingsBtnSlots.size():
		newCursor=0
	
	setOtherSettingsCursor(newCursor)	
	pass
	
func setOtherSettingsCursor(ix):

	
	var slot = otherSettingsBtnSlots[dblTapMvmCursorIx]

	# set unselect color background of old slot
	var bgdColorRec = slot.get_node("white")
	bgdColorRec.color = unselectedColor
	
	dblTapMvmCursorIx=ix
	slot = otherSettingsBtnSlots[dblTapMvmCursorIx]
	#set bgd color of selected slot
	bgdColorRec = slot.get_node("white")
	bgdColorRec.color = selectedColor

func updateOtherSettingEnabledIcons():
	#go over every slot and make sure the icon that displays
	#enable/disable is reflective of current input model
	for ix in otherSettingsBtnSlots.size():
		var slot = otherSettingsBtnSlots[ix]
		
		
		var enableTextureRec = slot.get_node("enabledIcon")
		var disableTextureRec = slot.get_node("disabledIcon")
		
		#default input config, so not double taps and other settings?
		if inputRemapModel == null:
			
			#disabled by default
			enableTextureRec.visible=false
			disableTextureRec.visible = true
		else:
			
			var btnKey =  otherSettingsBtnSlotBtnKeys[ix]
			
			#this double tap slot or other settings is enabled in the input remap model?
			if inputRemapModel.has(btnKey):
				#enable dthe icon
				enableTextureRec.visible=true
				disableTextureRec.visible = false
			else:
				enableTextureRec.visible=false
				disableTextureRec.visible = true
	
	
func confirmOtherSettingToggle(ix):
	var slot = otherSettingsBtnSlots[ix]
	
	
	var enableTextureRec = slot.get_node("enabledIcon")
	var disableTextureRec = slot.get_node("disabledIcon")

	#we enabling the double tap or other setting to default input remapping model, create empty model
	#that will be populated below with the remap double tap 
	if inputRemapModel == null:
		inputRemapModel={}
		
	
	var btnKey =  otherSettingsBtnSlotBtnKeys[ix]
	#already enabled this double tap or other setting?
	if inputRemapModel.has(btnKey):
		#disable it
		inputRemapModel.erase(btnKey)
		if inputRemapModel.size() == 0:
			inputRemapModel = null
		enableTextureRec.visible = false
		disableTextureRec.visible = true
	else:
		#already disabled, enable it
		inputRemapModel[btnKey] = null #value doesn't matter, existance of key indicates double tap or other setting remap
		enableTextureRec.visible = true
		disableTextureRec.visible = false
		
	enableInputModelChanged()
func _physics_process(delta):
	
	
	for deviceId in inputDeviceIds:
		
		#
		#****************MAIN STATE**************************
		#
		if state == State.MAIN:
			
			if Input.is_action_just_pressed(deviceId+"_X"):
				
				#player made changes to button layout?
				if changesMadeFlag:
					disableInputModelChanged()
					
					
					#only save when changes made
					emit_signal("save",playerName,inputRemapModel)
			if Input.is_action_just_pressed(deviceId+"_RIGHT_TRIGGER"):
				#only restore defaults if the remap isn't empty
				if inputRemapModel != null:
					restoreDefaultButtonLayout()
					
			if Input.is_action_just_pressed(deviceId+"_A"):
				changeState(State.ABOUT_TO_REMAP_BUTTON)
			if Input.is_action_just_pressed(deviceId+"_Y"):
				setOtherSettingsCursor(0)
				updateOtherSettingEnabledIcons()
				changeState(State.TOGGLING_OTHER_SETTINGS)
				
		#
		#****************REMAPPING_BUTTON**************************
		# player pressed A  and then chose a button to remap
		#
		elif state == State.REMAPPING_BUTTON:
			
			for moveCursorInput in remappingMoveCursorMoveInputs:
				if Input.is_action_just_pressed(deviceId+"_"+moveCursorInput):
					_moveRemappingBtnCursor(moveCursorInput)
					
			if Input.is_action_just_pressed(deviceId+"_B"):
				changeState(State.MAIN)
				
			if Input.is_action_just_pressed(deviceId+"_A"):
				if isBtnRemappable(remappingBtnCursorIx):
				
					remapButton(remappingBtnCursorIx)
				
				
					
		#
		#****************TOGGLING_OTHER_SETTINGS**************************
		# player pressed Y  and is now choosing the double tap movement or other settings options
		#	
		elif state == State.TOGGLING_OTHER_SETTINGS:
			if Input.is_action_just_pressed(deviceId+"_B"):
				changeState(State.MAIN)
			if Input.is_action_just_pressed(deviceId+"_A"):
				confirmOtherSettingToggle(dblTapMvmCursorIx)
			if Input.is_action_just_pressed(deviceId+"_UP"):
				moveOtherSettingCursor(true)#true means up
			elif Input.is_action_just_pressed(deviceId+"_DOWN"):
				moveOtherSettingCursor(false)#false means down:
				
		#	
		#****************ABOUT_TO_REMAP_BUTTON**************************
		# player pressed A and is now told to press a button to remap
		#	
		elif state == State.ABOUT_TO_REMAP_BUTTON:
			for btnKey in remappableBtnKeys:
				if Input.is_action_just_pressed(deviceId+"_"+btnKey):
					beginRemappingButton(btnKey)
					
		