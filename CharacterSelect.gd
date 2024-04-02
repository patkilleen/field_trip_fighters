extends Control
signal characters_selected
signal back

enum TrainingCharacterSelectionState{
	INITIAL,#no player chose a character
	PLAYER_HERO_SELECTED, # one of players picked a hero, giving a chance to now pick CPU hero
	BOTH_HEROS_SELECTED#CPU and player's hero picked
}

var GLOBALS = preload("res://Globals.gd")

const UI_MOVE_CURSOR_SOUND_ID = 0
const CONFIRM_HERO_SOUND_ID = 3
const ONE_SECOND = 1

const PLAYER1_NAME_ID = "Player 1"
const PLAYER2_NAME_ID = "Player 2"


const BELT_SELECTED_SOUND_IX=0
const GLOVE_SELECTED_SOUND_IX=1
const HAT_SELECTED_SOUND_IX=2
const MIC_SELECTED_SOUND_IX=3
const WHISTLE_SELECTED_SOUND_IX=4

var inputManagerResource = preload("res://input_manager.gd")


#set by root.gd
var mode = GLOBALS.GameModeType.STANDARD setget setMode,getMode
var trainingPlayerDeviceId = null #P1_ or P2, the id of input device who picked training



var LEFT = null
var RIGHT = null
var DOWN = null
var START = null
var A = null

var numCharSelected = 0
var characterChoices = []

var inputManagerP1 = null
var inputManagerP2 = null
var inputManagers = {}

var p1SamusLabel = null
var p1KenLabel = null
var p1MarthLabel = null
var p1FalconLabel = null

var p2KenLabel = null
var p2SamusLabel = null
var p2MarthLabel = null
var p2FalconLabel = null

var p1CharSelected = null
var p2CharSelected = null
var playerCharSelected = {}

var p1LockedIn=false
var p2LockedIn=false
var playerLockedIn = {}


#holds each hero's rows containing the star attribute
var fighterAttributeContainers = {}
#holds the visible container with attributes when hero selecteed
var visibleAttributeContainer = {}

var soundSFXPlayer = null
var characterSelections = []

var ignoringPlayerInput = {}

var toggleSkinUIs = {}
var playerCursors = {}

var playerSkinIx = {}

var holdingBTime = {}
var sfxPlayer = null

const RIGHT_CURSOR = 1
const LEFT_CURSOR = -1




var heroSoundSelectMap={GLOBALS.BELT_HERO_NAME:BELT_SELECTED_SOUND_IX,
						GLOBALS.GLOVE_HERO_NAME:GLOVE_SELECTED_SOUND_IX,
						GLOBALS.HAT_HERO_NAME:HAT_SELECTED_SOUND_IX,
						GLOBALS.MICROPHONE_HERO_NAME:MIC_SELECTED_SOUND_IX,
						GLOBALS.WHISTLE_HERO_NAME:WHISTLE_SELECTED_SOUND_IX}
var heroSoundSelectSoundVolumeMap={GLOBALS.BELT_HERO_NAME:10,
						GLOBALS.GLOVE_HERO_NAME:11,
						GLOBALS.HAT_HERO_NAME:-6,
						GLOBALS.MICROPHONE_HERO_NAME:10,
						GLOBALS.WHISTLE_HERO_NAME:10}
						
var p1HeroSelectSoundSFXPlayer = null
var p2HeroSelectSoundSFXPlayer=null
						

var inputDevices = []

var selectedHeroIcons = {}

var playerNameContainers = {}
var p1NameContainer = null
var p2NameContainer = null

var backArrow = null
var player1Name = null
var player2Name = null

var skinMap = {}

var trainingCharSelectState = 0 #start off in 1st state
var heroConfirmLock = false

const DEFAULT_SKIN_COLOR = Color(1,1,1)
#const MIC_DEFAULT_SKIN_COLOR = Color(1.75,1.75,1.75)#2 TO make the colors pop out, otherwise it's hard to see cause transparent outline
const DEFAULT_SKIN_IX= 0

#var networkManager = null
#the input device that selected character select (important for online play)
var selectionInputDeviceId = null



func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	
	skinMap[GLOBALS.KEN_HERO_NAME]= [DEFAULT_SKIN_COLOR,Color(0.2,0.73,0.2),Color(0.12,1,1),Color(1,1,0.2)]
	skinMap[GLOBALS.BELT_HERO_NAME]= [DEFAULT_SKIN_COLOR,Color(0.1,0,1),Color(0,1,1),Color(0.8,0.1,1)]
	skinMap[GLOBALS.GLOVE_HERO_NAME]= [DEFAULT_SKIN_COLOR,Color(0.74,0.38,1),Color(0.18,0.60,0.76),Color(0.13,0.87,0.16),Color(0.94,0.93,0),Color(0.96,0.36,0.24)]	
	#skinMap[GLOBALS.MICROPHONE_HERO_NAME]= [MIC_DEFAULT_SKIN_COLOR,Color(1.75,1.75,0),Color(0,1.75,1.75),Color(0.25,1.75,1.25),Color(0,0,1.75),Color(0,1.75,0),Color(0.75,0.3,1.3)]
	skinMap[GLOBALS.MICROPHONE_HERO_NAME]= [DEFAULT_SKIN_COLOR,Color(1.75,1.75,0),Color(0.3,1.5,1.75),Color(0.75,0.3,1.3),Color(1.75,0.5,0)]
	skinMap[GLOBALS.WHISTLE_HERO_NAME]=  [DEFAULT_SKIN_COLOR,Color(0.93,0.52,0.05),Color(0.07,0.67,0.93),Color(1,0.31,0.99),Color(0.73,0.78,0.99),Color(0.37,0.2,0.78)]
	skinMap[GLOBALS.HAT_HERO_NAME]= [DEFAULT_SKIN_COLOR,Color(1,0.87,0),Color(0,1,0.95),Color(1,0,0.12),Color(0.03,0.55,0)]
	#default skin
	playerSkinIx[GLOBALS.PLAYER1_INPUT_DEVICE_ID]=DEFAULT_SKIN_IX
	playerSkinIx[GLOBALS.PLAYER2_INPUT_DEVICE_ID]=DEFAULT_SKIN_IX
	
	sfxPlayer = $sfxPlayer
	backArrow = $"back-arrow"
	
	p1HeroSelectSoundSFXPlayer = $p1HeroConfirmSounds
	p2HeroSelectSoundSFXPlayer = $p2HeroConfirmSounds
	p1NameContainer = $p1namecontainer
	p2NameContainer = $p2namecontainer
	
	fighterAttributeContainers[GLOBALS.PLAYER1_INPUT_DEVICE_ID]=get_node("p1HeroAttributes")
	fighterAttributeContainers[GLOBALS.PLAYER2_INPUT_DEVICE_ID]=get_node("p2HeroAttributes")
	
	#make sure attributes not visible by default
	for inputDevice in fighterAttributeContainers.keys():
		var container = fighterAttributeContainers[inputDevice]
		
		for c in container.get_children():
			c.visible = false
			
	visibleAttributeContainer[GLOBALS.PLAYER1_INPUT_DEVICE_ID]=null
	visibleAttributeContainer[GLOBALS.PLAYER2_INPUT_DEVICE_ID]=null
	
	
	p1NameContainer.connect("player_name_selected",self,"_on_player_name_selected",[GLOBALS.PLAYER1_INPUT_DEVICE_ID])
	p2NameContainer.connect("player_name_selected",self,"_on_player_name_selected",[GLOBALS.PLAYER2_INPUT_DEVICE_ID])
	
	#RIGHT = inputManagerP1.Command.CMD_STOP_MOVE_FORWARD
	#RIGHT = inputManagerP1.Command.CMD_MOVE_FORWARD
	#LEFT = inputManagerP1.Command.CMD_STOP_MOVE_BACKWARD
	#DOWN = inputManagerP1.Command.CMD_CROUCH
	#START = inputManagerP1.Command.CMD_START
#	A  = inputManagerP1.Command.CMD_JUMP
	
	selectedHeroIcons[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = $"p1-selection-bdg/CenterContainer/selected-hero-icon"
	selectedHeroIcons[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = $"p2-selection-bdg/CenterContainer/selected-hero-icon"
	
	toggleSkinUIs[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = $"skin-toggle-p1"	
	toggleSkinUIs[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = $"skin-toggle-p2"
	
	
	
	playerNameContainers[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = $"p1namecontainer"
	playerNameContainers[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = $"p2namecontainer"
	
	ignoringPlayerInput[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = false
	ignoringPlayerInput[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = false
	
	
	holdingBTime[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = 0
	holdingBTime[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = 0
	
	playerCursors[GLOBALS.PLAYER1_INPUT_DEVICE_ID]=0
	playerCursors[GLOBALS.PLAYER2_INPUT_DEVICE_ID]=0
	
	
	
	playerLockedIn[GLOBALS.PLAYER1_INPUT_DEVICE_ID]=false
	playerLockedIn[GLOBALS.PLAYER2_INPUT_DEVICE_ID]=false
	playerCharSelected[GLOBALS.PLAYER1_INPUT_DEVICE_ID]=null
	playerCharSelected[GLOBALS.PLAYER2_INPUT_DEVICE_ID]=null
	#add all character icons to list
	for cicon in $characters.get_children():
		characterSelections.append(cicon)

	#movePlayerCursor((
	#var samusClickArea = $"click-samus"
	#samusClickArea.connect("input_event",self,"_on_samus_clicked")

	#var kenClickArea = $"click-ken"
	#kenClickArea.connect("input_event",self,"_on_ken_clicked")
	
	#make sure a default selection is present to fix buggy null selection
	#cursor over left most hero
	movePlayerCursor(GLOBALS.PLAYER1_INPUT_DEVICE_ID,RIGHT_CURSOR)
	movePlayerCursor(GLOBALS.PLAYER1_INPUT_DEVICE_ID,LEFT_CURSOR)
	movePlayerCursor(GLOBALS.PLAYER2_INPUT_DEVICE_ID,RIGHT_CURSOR)
	movePlayerCursor(GLOBALS.PLAYER2_INPUT_DEVICE_ID,LEFT_CURSOR)

#func init(stats,_player1Name,_player2Name,_inputDeviceId,_networkManager):
func init(nameIOHandler,_player1Name,_player2Name,_inputDeviceId):
	p1NameContainer.init(nameIOHandler,"Player 1",mode)
	p2NameContainer.init(nameIOHandler,"Player 2",mode)
	
	selectionInputDeviceId=_inputDeviceId
	#networkManager = _networkManager
	#if mode == GLOBALS.GameModeType.STANDARD:
	inputManagerP1 = inputManagerResource.new()
	add_child(inputManagerP1)
	inputManagerP1.init()
	inputManagerP2 =inputManagerResource.new()
	add_child(inputManagerP2)
	inputManagerP2.init()
	
	if mode == GLOBALS.GameModeType.STANDARD  or mode == GLOBALS.GameModeType.ONLINE_HOSTING or mode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:	
		inputManagerP1.inputDeviceId=GLOBALS.PLAYER1_INPUT_DEVICE_ID
		inputManagerP2.inputDeviceId=GLOBALS.PLAYER2_INPUT_DEVICE_ID
	
	inputManagers[GLOBALS.PLAYER1_INPUT_DEVICE_ID] =inputManagerP1
	inputManagers[GLOBALS.PLAYER2_INPUT_DEVICE_ID] =inputManagerP2

#	elif mode == GLOBALS.GameModeType.ONLINE_HOSTING or mode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		
		
		
#		if mode == GLOBALS.GameModeType.ONLINE_HOSTING:
#			inputManagerP1 = networkManager.getLocalInputManager()
#			inputManagerP2 = networkManager.getRemoteInputManager()
			
#		else:
#			inputManagerP1 = networkManager.getRemoteInputManager()
#			inputManagerP2 = networkManager.getLocalInputManager()	
	
	#we need to make sure the host is player 1 and peer is player 2
	#if mode == GLOBALS.GameModeType.ONLINE_HOSTING or mode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		#figure out what input devices id is the other one compared to device that started character select
	#	var otherInputDeviceId = GLOBALS.opposingInputDevice(selectionInputDeviceId)

			
	#	if mode == GLOBALS.GameModeType.ONLINE_HOSTING:
				
			#host controls player1
	#		inputManagerP1.inputDeviceId=selectionInputDeviceId
	#		inputManagerP2.inputDeviceId=otherInputDeviceId
						
	#		inputManagers[selectionInputDeviceId] =inputManagerP1
	#		inputManagers[otherInputDeviceId] =inputManagerP2
	#	else:
			#peer controls player2
	#		inputManagerP1.inputDeviceId=otherInputDeviceId
	#		inputManagerP2.inputDeviceId=selectionInputDeviceId
			
	#		inputManagers[selectionInputDeviceId] =inputManagerP2
	#		inputManagers[otherInputDeviceId] =inputManagerP1
		
		
		
	
	inputDevices.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDevices.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	
	
	
		
	toggleSkinUIs[GLOBALS.PLAYER1_INPUT_DEVICE_ID].visible  = false
	toggleSkinUIs[GLOBALS.PLAYER2_INPUT_DEVICE_ID].visible  = false
	
	#make sure cpu cursor is invisible at start, and the text is 'cpu'
	#WHEN in training mode ans selecting cpu hero, change cursor of other player text to 'cpu'
	if mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		
		
		
		
		var cpuInputDevice = GLOBALS.opposingInputDevice(trainingPlayerDeviceId)
		
		#hide the player name button for cpu
		playerNameContainers[cpuInputDevice].visible = false
		
		#name the cpu "CPU"
		if cpuInputDevice == GLOBALS.PLAYER1_INPUT_DEVICE_ID:
			_on_player_name_selected(GLOBALS.CPU_NAME,PLAYER1_NAME_ID,cpuInputDevice)
		elif cpuInputDevice == GLOBALS.PLAYER2_INPUT_DEVICE_ID:
			_on_player_name_selected(GLOBALS.CPU_NAME,PLAYER2_NAME_ID,cpuInputDevice)
		
		#disable the other player's controller for spinning the back arrow
		backArrow.disabledFlagInpudDeviceMap[cpuInputDevice] = true
		
		var i = 0
		#iterate all the cursor texts
		for cicon in characterSelections:		
			
			var cpuLabel = cicon.labelMap[cpuInputDevice]
			cpuLabel.text = "CPU"
			cpuLabel.visible = false
	
			i+=1
	
	
	#make sure to save the names over for multiple matches of changed characters
	#make sure the cpu name isn't save between ai/training and playing a match pvp
	if _player1Name != null and _player1Name != GLOBALS.CPU_NAME:
		_on_player_name_selected(_player1Name,PLAYER1_NAME_ID,GLOBALS.PLAYER1_INPUT_DEVICE_ID)
		
	if _player2Name != null and _player2Name != GLOBALS.CPU_NAME:
		_on_player_name_selected(_player2Name,PLAYER2_NAME_ID,GLOBALS.PLAYER2_INPUT_DEVICE_ID)
			

func setMode(value):
	mode = value
		
func getMode():
	return mode

#returns the opposing input device: eg. player 1's input device opposing would be player 2, and vice versa

func _on_player_name_selected(pname,playerId,_playerDeviceId):
	
	ignoringPlayerInput[_playerDeviceId] = false
	
	
	if pname != GLOBALS.CPU_NAME:
		#make cursor visible
		var characterIconIx=playerCursors[_playerDeviceId]
		var charSelect = characterSelections[characterIconIx]
		charSelect.select(_playerDeviceId)
	
	
	
	#Are we selecting the default filler text?
	if pname == playerId:
		
		#not choosing a name		
		if playerId == PLAYER1_NAME_ID:
			player1Name=null
			#display default name
			p1NameContainer.displayPlayerName(playerId)	
		elif playerId==PLAYER2_NAME_ID:
			player2Name=null
			#display default name
			p2NameContainer.displayPlayerName(playerId)	
		return
		
	
	
	
	if playerId == PLAYER1_NAME_ID:
		
		p1NameContainer.displayPlayerName(pname)
		#make sure players haven't picked same name
		if player2Name != pname:
			player1Name = pname
		else:
			#override the label name change to palyer 2.
			if player1Name == null:
				
				p1NameContainer.pNameLabel.text=PLAYER1_NAME_ID
			else:
				p1NameContainer.pNameLabel.text=player1Name
	elif playerId==PLAYER2_NAME_ID:
		p2NameContainer.displayPlayerName(pname)
		#make sure players haven't picked same name
		if player1Name != pname:
			player2Name = pname
		else:
			
			#override the label name change to palyer 2.
			if player2Name == null:
				
				p2NameContainer.pNameLabel.text=PLAYER2_NAME_ID
			else:
				p2NameContainer.pNameLabel.text=player2Name
func displaySelectedHero(player):
	selectedHeroIcons[player].texture = playerCharSelected[player].texture
	
	selectedHeroIcons[player].rect_scale = playerCharSelected[player].rect_scale
	
	#display the default skin of heor
	var skinIx = playerSkinIx[player]
	
	var heroName = playerCharSelected[player].fighterSceneName
	
	var skinList = skinMap[heroName]
	
	
	var heroIcon = selectedHeroIcons[player]
	
	heroIcon.self_modulate = skinList[0]


func hideSelectedHero(player):
	selectedHeroIcons[player].texture = null
	
func movePlayerCursor(player,direction):
	
	#make sound of ui selection
	sfxPlayer.playSound(UI_MOVE_CURSOR_SOUND_ID)
		
	#move cursor left or right (index)
	playerCursors[player] += direction
	
	#make sure move using modulo # of characters
	if playerCursors[player] < 0:
		playerCursors[player] = characterSelections.size() -1
	elif playerCursors[player] >= characterSelections.size():
		playerCursors[player] = 0

	renderCursor(player)
	
	#choose character
	var characterIconIx=playerCursors[player]
	playerCharSelected[player]=characterSelections[characterIconIx]
	playerLockedIn[player]=false
	
func renderCursor(player):
	
	var i = 0
	for cicon in characterSelections:
		#found selected character?
		if i ==playerCursors[player]:	
			cicon.select(player)
		else:
			cicon.unselect(player)
		i+=1

func selectHero(playerInputDevice):
	
	#make sound of ui selection to allow spamming to get opponent to hury
	sfxPlayer.playSound(CONFIRM_HERO_SOUND_ID)
	if playerLockedIn[playerInputDevice] == false and playerCharSelected[playerInputDevice].fighterSceneName != null:
		
		#sfxPlayer.playSound(CONFIRM_HERO_SOUND_ID)
		
		displaySelectedHero(playerInputDevice)
		#hide the icon
		characterSelections[playerCursors[playerInputDevice]].unselect(playerInputDevice)
		playerLockedIn[playerInputDevice] = true
		
		backArrow.disabledFlagInpudDeviceMap[playerInputDevice] = true
		
		toggleSkinUIs[playerInputDevice].visible = true
		
		#assign the fighter attribute node and make it visible
		var charSelected =playerCharSelected[playerInputDevice].fighterSceneName
		var attContainer = fighterAttributeContainers[playerInputDevice]		
		visibleAttributeContainer[playerInputDevice] = attContainer.get_node(charSelected)
		
		if visibleAttributeContainer[playerInputDevice] == null:
			print("warning, can't display student attribute stars. Can't find child node for hero: "+charSelected)
		else:
			visibleAttributeContainer[playerInputDevice].visible =true
		
		#PLAYER 1?
		if playerInputDevice == GLOBALS.PLAYER1_INPUT_DEVICE_ID:
			
			p1HeroSelectSoundSFXPlayer.changeVolume(heroSoundSelectSoundVolumeMap[playerCharSelected[playerInputDevice].fighterSceneName])
			#play the hero voiceline
			p1HeroSelectSoundSFXPlayer.playSound(heroSoundSelectMap[playerCharSelected[playerInputDevice].fighterSceneName])
		else:
			p2HeroSelectSoundSFXPlayer.changeVolume(heroSoundSelectSoundVolumeMap[playerCharSelected[playerInputDevice].fighterSceneName])
			p2HeroSelectSoundSFXPlayer.playSound(heroSoundSelectMap[playerCharSelected[playerInputDevice].fighterSceneName])

		

func unselectHero(playerInputDevice):
	
	if playerLockedIn[playerInputDevice]:
		hideSelectedHero(playerInputDevice)
		#hide the icon
		characterSelections[playerCursors[playerInputDevice]].select(playerInputDevice)
		playerLockedIn[playerInputDevice] = false
		backArrow.disabledFlagInpudDeviceMap[playerInputDevice] = false
		toggleSkinUIs[playerInputDevice].visible = false
		
		visibleAttributeContainer[playerInputDevice].visible =false
		visibleAttributeContainer[playerInputDevice]=null
		

func attempConfirmHeroSelection():
	
	if not heroConfirmLock:
		
		
		#online mode?
		if mode == GLOBALS.GameModeType.ONLINE_HOSTING or  mode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
			
			if playerLockedIn[selectionInputDeviceId]:
				#only need 1 characcter selection to confirm in online mode, as it's upon connection that characeter seleciton info shared
				if selectionInputDeviceId == GLOBALS.PLAYER1_INPUT_DEVICE_ID:
		
					
					set_physics_process(false)
					heroConfirmLock = true
					
					#only send player 1 info
					emit_signal("characters_selected",
					playerCharSelected[GLOBALS.PLAYER1_INPUT_DEVICE_ID].fighterSceneName,null,
					playerCharSelected[GLOBALS.PLAYER1_INPUT_DEVICE_ID].fighterIcon,null,
					player1Name,null,
					getHeroSkinColor(GLOBALS.PLAYER1_INPUT_DEVICE_ID),null)
				else:
	
					set_physics_process(false)
					heroConfirmLock = true
					#only send player 2 info				
					emit_signal("characters_selected",
					null,playerCharSelected[GLOBALS.PLAYER2_INPUT_DEVICE_ID].fighterSceneName,
					null,playerCharSelected[GLOBALS.PLAYER2_INPUT_DEVICE_ID].fighterIcon,
					null,player2Name,
					null,getHeroSkinColor(GLOBALS.PLAYER2_INPUT_DEVICE_ID)) 
		elif playerLockedIn[GLOBALS.PLAYER1_INPUT_DEVICE_ID] and playerLockedIn[GLOBALS.PLAYER2_INPUT_DEVICE_ID]:
			#emit_signal("characters_selected",playerCharSelected[GLOBALS.PLAYER1_INPUT_DEVICE_ID].fighterSceneName,playerCharSelected[GLOBALS.PLAYER2_INPUT_DEVICE_ID].fighterSceneName,playerCharSelected[GLOBALS.PLAYER1_INPUT_DEVICE_ID].texture,playerCharSelected[GLOBALS.PLAYER2_INPUT_DEVICE_ID].texture,player1Name,player2Name)
			set_physics_process(false)
			heroConfirmLock = true
			emit_signal("characters_selected",playerCharSelected[GLOBALS.PLAYER1_INPUT_DEVICE_ID].fighterSceneName,playerCharSelected[GLOBALS.PLAYER2_INPUT_DEVICE_ID].fighterSceneName,playerCharSelected[GLOBALS.PLAYER1_INPUT_DEVICE_ID].fighterIcon,playerCharSelected[GLOBALS.PLAYER2_INPUT_DEVICE_ID].fighterIcon,player1Name,player2Name,getHeroSkinColor(GLOBALS.PLAYER1_INPUT_DEVICE_ID),getHeroSkinColor(GLOBALS.PLAYER2_INPUT_DEVICE_ID))

func checkForMenuReturnInput(playerInputDevice,delta):

	#only let the controlling player go back (no other controller should be able to)
	if mode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST or mode == GLOBALS.GameModeType.ONLINE_HOSTING:
		if playerInputDevice != selectionInputDeviceId:
			return
			
	#can't return to main menu if hero selected
	if playerLockedIn[playerInputDevice]:
		return
		
	#players may be holding b to go back
	if Input.is_action_pressed(playerInputDevice+"_B"):
		
		#count how long holding B
		holdingBTime[playerInputDevice] += delta
		
		if holdingBTime[playerInputDevice] > ONE_SECOND:
			
			emit_signal("back")
			
	elif Input.is_action_just_released(playerInputDevice+"_B"):
		#reset the holding b timer, were done trying to go back
		holdingBTime[playerInputDevice] =0
		
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	
	if mode == GLOBALS.GameModeType.STANDARD or mode == GLOBALS.GameModeType.ONLINE_HOSTING or mode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		handleTwoPlayerCharacterSelectionInput(delta)
	elif mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		handleTrainingCharacterSelectionInput(delta)
		
func handleTwoPlayerCharacterSelectionInput(delta):


	#iterate both players
	for player in inputDevices:
		
		
		#ONLINE mode?
		if mode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST or mode == GLOBALS.GameModeType.ONLINE_HOSTING:
				
			if player != selectionInputDeviceId:
				#online mode, we pre-select our character before connecting to peer, so 
				#only accept input from the input device that was used to enter lobby
				continue
				
		if ignoringPlayerInput[player]:
			continue
			
		var inputManager = inputManagers[player]
		checkForMenuReturnInput(player,delta)
		
		var cmd =inputManager.readCommand()
		#if Input.is_action_just_pressed(player+"_LEFT"):
		if cmd == inputManager.Command.CMD_STOP_MOVE_BACKWARD:
			
			
			if playerLockedIn[player] == false:
				movePlayerCursor(player,LEFT_CURSOR)
			
		#elif Input.is_action_just_pressed(player+"_RIGHT"):
		if cmd == inputManager.Command.CMD_STOP_MOVE_FORWARD:
			 
			if playerLockedIn[player] == false:
				movePlayerCursor(player,RIGHT_CURSOR)
		
		#elif Input.is_action_just_pressed(player+"_B"):
		#elif Input.is_action_just_released(player+"_B"):
		if cmd == inputManager.Command.CMD_NEUTRAL_TOOL:
			unselectHero(player)
		
#		elif Input.is_action_just_pressed(player+"_A"):	
		if cmd == inputManager.Command.CMD_JUMP:
			if playerLockedIn[GLOBALS.PLAYER1_INPUT_DEVICE_ID] and playerLockedIn[GLOBALS.PLAYER2_INPUT_DEVICE_ID]:
							
			
				attempConfirmHeroSelection()
				return
			else:
				selectHero(player)
			
		#elif Input.is_action_just_pressed(player+"_X"):		
		if cmd == inputManager.Command.CMD_NEUTRAL_MELEE:
			_on_toggle_skin_index(player)
		#elif Input.is_action_just_pressed(player+"_Y"):	
		if inputManager.lastCommand == inputManager.Command.CMD_NEUTRAL_SPECIAL:
			
			applyFocusToNameSelect(player)
			
		#elif Input.is_action_just_pressed(player+"_START"):
		if cmd == inputManager.Command.CMD_START:
			attempConfirmHeroSelection()
			
			if playerLockedIn[GLOBALS.PLAYER1_INPUT_DEVICE_ID] and playerLockedIn[GLOBALS.PLAYER2_INPUT_DEVICE_ID]:
				#ignore any other attempt at pressing start, don't want to load game twice
				return
func applyFocusToNameSelect(playerDeviceId):
	ignoringPlayerInput[playerDeviceId] = true
	playerNameContainers[playerDeviceId].enable()
	
	#make the hero cursor hidden
	var characterIconIx=playerCursors[playerDeviceId]
	var charSelect = characterSelections[characterIconIx]
	charSelect.unselect(playerDeviceId)
			

func _on_toggle_skin_index(playerId):

		
	#can only change skin if hero selected
	if not playerLockedIn[playerId]:
		return 
		
	var heroName = playerCharSelected[playerId].fighterSceneName
			
	
	var skinIx = playerSkinIx[playerId]
	
	var skinList = skinMap[heroName]
	
	#increment the skin index cyclicly and save it as the chosen skin index
	skinIx = (skinIx + 1 ) % skinList.size()
	playerSkinIx[playerId]=skinIx
	
	#display the skin sample by changing color of hero portrain
	var heroIcon = selectedHeroIcons[playerId]
	
	heroIcon.self_modulate = skinList[skinIx]

func getHeroSkinColor(playerId):
	var heroName = playerCharSelected[playerId].fighterSceneName
	var skinList = skinMap[heroName]
	return skinList[playerSkinIx[playerId]]
	
func handleTrainingCharacterSelectionInput(delta):
	
	if trainingPlayerDeviceId == null:
		print("warning, forgot to specify what player input device selected training mode")
		return
			
	var player = trainingPlayerDeviceId
	var cpuInputDevice = GLOBALS.opposingInputDevice(player)
	#check what state of training hero select were in
	match(trainingCharSelectState):
		TrainingCharacterSelectionState.INITIAL:
			
			if ignoringPlayerInput[player]:
				return
			
			checkForMenuReturnInput(player,delta)
			
			if Input.is_action_just_pressed(player+"_LEFT"):
				
				if playerLockedIn[player] == false:
					movePlayerCursor(player,LEFT_CURSOR)
				
			elif Input.is_action_just_pressed(player+"_RIGHT"):
				 
				if playerLockedIn[player] == false:
					movePlayerCursor(player,RIGHT_CURSOR)
			
			elif Input.is_action_just_released(player+"_B"):
				pass
			
			elif Input.is_action_just_pressed(player+"_Y"):	
			
				applyFocusToNameSelect(player)

			
			elif Input.is_action_just_pressed(player+"_A"):	
				
				selectHero(player)
				#make the CPU cursor appear over ken
				movePlayerCursor(cpuInputDevice,RIGHT_CURSOR)
				movePlayerCursor(cpuInputDevice,LEFT_CURSOR)
				trainingCharSelectState = TrainingCharacterSelectionState.PLAYER_HERO_SELECTED
				
			elif Input.is_action_just_pressed(player+"_START"):
				pass
		TrainingCharacterSelectionState.PLAYER_HERO_SELECTED:
			
			#same input device chooses CPU, but opposing input device 
			#used for lookup and internal selections
			
			if Input.is_action_just_pressed(player+"_LEFT"):
				
				if playerLockedIn[cpuInputDevice] == false:
					movePlayerCursor(cpuInputDevice,LEFT_CURSOR)
				
			elif Input.is_action_just_pressed(player+"_RIGHT"):
				 
				if playerLockedIn[cpuInputDevice] == false:
					movePlayerCursor(cpuInputDevice,RIGHT_CURSOR)
			
						
			elif Input.is_action_just_pressed(player+"_X"):	
			
				
				_on_toggle_skin_index(player)
			
			
			elif Input.is_action_just_released(player+"_B"):
				unselectHero(player)
				trainingCharSelectState = TrainingCharacterSelectionState.INITIAL
			elif Input.is_action_just_pressed(player+"_A"):	
				
				selectHero(cpuInputDevice)
				trainingCharSelectState = TrainingCharacterSelectionState.BOTH_HEROS_SELECTED
			elif Input.is_action_just_pressed(player+"_START"):
				pass
		TrainingCharacterSelectionState.BOTH_HEROS_SELECTED:	
			
			#same input device chooses CPU, but opposing input device 
			#used for lookup and internal selections
			
			if Input.is_action_just_pressed(player+"_LEFT"):
				
				pass
			elif Input.is_action_just_pressed(player+"_RIGHT"):
				 pass
			elif Input.is_action_just_released(player+"_B"):
				unselectHero(cpuInputDevice)
				trainingCharSelectState = TrainingCharacterSelectionState.PLAYER_HERO_SELECTED
			elif Input.is_action_just_pressed(player+"_A"):	
				attempConfirmHeroSelection()
			elif Input.is_action_just_pressed(player+"_X"):	
			
				
				_on_toggle_skin_index(cpuInputDevice)
			
			
			elif Input.is_action_just_pressed(player+"_START"):
				attempConfirmHeroSelection()
				
	
	
	

	