extends Control

signal proficiencies_selected
signal back


const GLOBALS = preload("res://Globals.gd")

	
############



enum TrainingState{
	
	INITIAL,
	PLAYER_PROFICIENCIES_SELECTED,
	BOT_PROFICIENCIES_SELECTED	
}

var numPlayersReady = 0

var advProf =null
var disProf=null
var pid =null



#set by roo.gd
var mode = GLOBALS.GameModeType.STANDARD setget setMode,getMode
var trainingPlayerDeviceId = null #P1_ or P2, the id of input device who picked training
var trainingState = null

var playerAdvProf = null
var playerDisProf = null
var botAdvProf = null
var botDisProf = null


var player1Name = null
var player2Name = null

var p1NameLabel = null
var p2NameLabel = null

var p1 = null
var p2 = null

#var networkManager = null

var numPlayersSelectProfs = 0
var onlineModeMaineInputDeviceId = null # the input device that will be used exlclusivly for local input



#new stuff

#offline pvp
var player1Prof1MajorClassIxSelect = null
var player1Prof1MinorClassIxSelect = null
var player1Prof2MajorClassIxSelect = null
var player1Prof2MinorClassIxSelect = null

var player2Prof1MajorClassIxSelect = null
var player2Prof1MinorClassIxSelect = null
var player2Prof2MajorClassIxSelect = null
var player2Prof2MinorClassIxSelect = null

#training
#new stuff
var playerProf1MajorClassIxSelect = null
var playerProf1MinorClassIxSelect = null
var playerProf2MajorClassIxSelect = null
var playerProf2MinorClassIxSelect = null

var botProf1MajorClassIxSelect = null
var botProf1MinorClassIxSelect = null
var botProf2MajorClassIxSelect = null
var botProf2MinorClassIxSelect = null

var player1SelectionHUD = null
var player2SelectionHUD = null


var backUINode = null
func _ready():
	
	#player1SelectionHUD.inputDevice = GLOBALS.PLAYER1_INPUT_DEVICE_ID
	#player2SelectionHUD.inputDevice = GLOBALS.PLAYER2_INPUT_DEVICE_ID


	pass

func init(_mode,_player1Name,_player2Name,_onlineModeMaineInputDeviceId=null):
	mode = _mode
	player1Name = _player1Name
	player2Name = _player2Name
	onlineModeMaineInputDeviceId = _onlineModeMaineInputDeviceId


	backUINode  = $"back-arrow"
	backUINode.connect("back",self,"_on_back")	

	player1SelectionHUD = $"P1-NewProficiencySelectWheelHUD"
	player2SelectionHUD = $"P2-NewProficiencySelectWheelHUD"

	p1NameLabel = $"player1-label"
	p2NameLabel = $"player2-label"
	
	player1SelectionHUD.connect("proficiencies_selection_confirmed",self,"_on_player_ready",[GLOBALS.PLAYER1_INPUT_DEVICE_ID])
	player2SelectionHUD.connect("proficiencies_selection_confirmed",self,"_on_player_ready",[GLOBALS.PLAYER2_INPUT_DEVICE_ID])
	

	
	
	#wehn in training mode, 1 controller controls both prof selections
	if mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		
		player1SelectionHUD.inputDeviceId = trainingPlayerDeviceId
		player2SelectionHUD.inputDeviceId = trainingPlayerDeviceId

#		signal proficiency_1_confirmed
#signal proficiency_2_confirmed
#signal proficiency_1_unconfirmed
#signal proficiency_2_unconfirmed
		player1SelectionHUD.connect("proficiency_1_confirmed",self,"_on_proficiency_1_confirmed")
		player1SelectionHUD.connect("proficiency_1_unconfirmed",self,"_on_proficiency_1_unconfirmed")
		player1SelectionHUD.connect("proficiency_2_confirmed",self,"_on_proficiency_2_confirmed")
		player1SelectionHUD.connect("proficiency_2_unconfirmed",self,"_on_proficiency_2_unconfirmed")
		
		
		player2SelectionHUD.connect("proficiency_1_confirmed",self,"_on_proficiency_1_confirmed")
		player2SelectionHUD.connect("proficiency_1_unconfirmed",self,"_on_proficiency_1_unconfirmed")
		player2SelectionHUD.connect("proficiency_2_confirmed",self,"_on_proficiency_2_confirmed")
		player2SelectionHUD.connect("proficiency_2_unconfirmed",self,"_on_proficiency_2_unconfirmed")
	
		trainingState = TrainingState.INITIAL
	else:
		
	
	
		player1SelectionHUD.connect("proficiency_2_confirmed",self,"_on_proficiency_2_confirmed")
		player1SelectionHUD.connect("proficiency_2_unconfirmed",self,"_on_proficiency_2_unconfirmed")
		player2SelectionHUD.connect("proficiency_2_confirmed",self,"_on_proficiency_2_confirmed")
		player2SelectionHUD.connect("proficiency_2_unconfirmed",self,"_on_proficiency_2_unconfirmed")
		
	
	if player1Name != null:
		#player1SelectionHUD.player1Label.text = player1Name
		#player1SelectionHUD.player2Label.text = player1Name
		p1NameLabel.text = player1Name
		
		
	if player2Name != null:
		#player2SelectionHUD.player1Label.text = player2Name
		#player2SelectionHUD.player2Label.text = player2Name
		p2NameLabel.text = player2Name
	
	#wehn in training mode, 1 controller controls both prof selections
	if mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		
	
		#only the player 1 will have profs chosen first
		enableProfSelectionPane(player1SelectionHUD)
		disableProfSelectionPane(player2SelectionHUD)
	
	numPlayersSelectProfs=0

func setMode(value):
	mode = value
		
func getMode():
	return mode
	
func _on_player_ready(prof1MajorClassIxSelect,prof1MinorClassIxSelect,prof2MajorClassIxSelect,prof2MinorClassIxSelect,_id):
	
	#when in training mode, ignore ready player , proficiency selection, only 
	#handle bot ready
	if mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		if trainingState == TrainingState.INITIAL:
			pass
		#elif trainingState == TrainingState.PLAYER_PROFICIENCIES_SELECTED:
			
			#unlock the player's prof selection
			#player1SelectionHUD.ready = false
			#p1.readyIcon.visible = false
		if trainingState == TrainingState.BOT_PROFICIENCIES_SELECTED:
			disableProfSelectionPane(player1SelectionHUD)
			disableProfSelectionPane(player2SelectionHUD)
			set_physics_process(false)
			emit_signal("proficiencies_selected", 
			playerProf1MajorClassIxSelect,	playerProf1MinorClassIxSelect,
			playerProf2MajorClassIxSelect,playerProf2MinorClassIxSelect,
			botProf1MajorClassIxSelect,botProf1MinorClassIxSelect,
			botProf2MajorClassIxSelect,botProf2MinorClassIxSelect)
			return
		

	if mode == GLOBALS.GameModeType.ONLINE_HOSTING or  mode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		
		#in online mode only 1 controller has to select proficiencies to continue
		disableProfSelectionPane(player1SelectionHUD)
		disableProfSelectionPane(player2SelectionHUD)
		set_physics_process(false)
		emit_signal("proficiencies_selected", 
		player1SelectionHUD.prof1MajorClassIxSelect,player1SelectionHUD.prof1MinorClassIxSelect,
		player1SelectionHUD.prof2MajorClassIxSelect,player1SelectionHUD.prof2MinorClassIxSelect,
		player2SelectionHUD.prof1MajorClassIxSelect,player2SelectionHUD.prof1MinorClassIxSelect,
		player2SelectionHUD.prof2MajorClassIxSelect,player2SelectionHUD.prof2MinorClassIxSelect)
		
		
	#all players made their choice and a player pressed start
	elif numPlayersSelectProfs ==2:
		disableProfSelectionPane(player1SelectionHUD)
		disableProfSelectionPane(player2SelectionHUD)
		set_physics_process(false)
		emit_signal("proficiencies_selected", 
		player1SelectionHUD.prof1MajorClassIxSelect,player1SelectionHUD.prof1MinorClassIxSelect,
		player1SelectionHUD.prof2MajorClassIxSelect,player1SelectionHUD.prof2MinorClassIxSelect,
		player2SelectionHUD.prof1MajorClassIxSelect,player2SelectionHUD.prof1MinorClassIxSelect,
		player2SelectionHUD.prof2MajorClassIxSelect,player2SelectionHUD.prof2MinorClassIxSelect)

func _on_proficiency_1_confirmed():
	
	if mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		if trainingState == TrainingState.INITIAL:
			#player proficiency advantage selected, need to pick disadvantage prof
			enableProfSelectionPane(player1SelectionHUD)
			disableProfSelectionPane(player2SelectionHUD)
			#playerAdvProf = p1.advProf
			playerProf1MajorClassIxSelect=	player1SelectionHUD.prof1MajorClassIxSelect
			playerProf1MinorClassIxSelect=	player1SelectionHUD.prof1MinorClassIxSelect
			
		elif trainingState == TrainingState.PLAYER_PROFICIENCIES_SELECTED:
			#bot proficiency advantage selected, need to pick disadvantage prof for bot, no longer
			#can remove plaery's proficiencies
			disableProfSelectionPane(player1SelectionHUD)
			enableProfSelectionPane(player2SelectionHUD)			
			
			#botAdvProf = p2.advProf
			botProf1MajorClassIxSelect=	player2SelectionHUD.prof1MajorClassIxSelect
			botProf1MinorClassIxSelect=	player2SelectionHUD.prof1MinorClassIxSelect
		elif trainingState == TrainingState.BOT_PROFICIENCIES_SELECTED:
			pass
	else:
		pass
		
func _on_proficiency_1_unconfirmed():
	
	if mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		if trainingState == TrainingState.INITIAL:
			#choosing bot profs disabled, choosing players prof enabled, unselect advantage prof
			enableProfSelectionPane(player1SelectionHUD)
			disableProfSelectionPane(player2SelectionHUD)
			#playerAdvProf = null
			playerProf1MajorClassIxSelect=	null
			playerProf1MinorClassIxSelect=	null
		elif trainingState == TrainingState.PLAYER_PROFICIENCIES_SELECTED:
			# unselect advantage prof for bot, but can unselect advantage prof for palyer and can choose bots adv prof
			enableProfSelectionPane(player1SelectionHUD)
			enableProfSelectionPane(player2SelectionHUD)
			#botAdvProf = null
			botProf1MajorClassIxSelect=	null
			botProf1MinorClassIxSelect=	null
		elif trainingState == TrainingState.BOT_PROFICIENCIES_SELECTED:
			pass
	else:
		pass	



func _on_proficiency_2_unconfirmed():
	
	if mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		if trainingState == TrainingState.INITIAL:
			pass
		elif trainingState == TrainingState.PLAYER_PROFICIENCIES_SELECTED:
			enableProfSelectionPane(player1SelectionHUD)
			disableProfSelectionPane(player2SelectionHUD)
			#playerDisProf = null
			playerProf2MajorClassIxSelect=	null
			playerProf2MinorClassIxSelect=	null
			trainingState = TrainingState.INITIAL
		elif trainingState == TrainingState.BOT_PROFICIENCIES_SELECTED:
			disableProfSelectionPane(player1SelectionHUD)
			enableProfSelectionPane(player2SelectionHUD)
			#botDisProf = null
			botProf2MajorClassIxSelect=	null
			botProf2MinorClassIxSelect=	null
			trainingState = TrainingState.PLAYER_PROFICIENCIES_SELECTED
	else:
		
		numPlayersSelectProfs = numPlayersSelectProfs -1
		
func _on_proficiency_2_confirmed():
	
	if mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		if trainingState == TrainingState.INITIAL:
			enableProfSelectionPane(player1SelectionHUD)
			enableProfSelectionPane(player2SelectionHUD)
			#playerDisProf = p1.disProf
			playerProf2MajorClassIxSelect=	player1SelectionHUD.prof2MajorClassIxSelect
			playerProf2MinorClassIxSelect=	player1SelectionHUD.prof2MinorClassIxSelect
			trainingState = TrainingState.PLAYER_PROFICIENCIES_SELECTED
		elif trainingState == TrainingState.PLAYER_PROFICIENCIES_SELECTED:
			disableProfSelectionPane(player1SelectionHUD)
			enableProfSelectionPane(player2SelectionHUD)
			#botDisProf = p2.disProf
			botProf2MajorClassIxSelect=	player2SelectionHUD.prof2MajorClassIxSelect
			botProf2MinorClassIxSelect=	player2SelectionHUD.prof2MinorClassIxSelect
			trainingState = TrainingState.BOT_PROFICIENCIES_SELECTED
		elif trainingState == TrainingState.BOT_PROFICIENCIES_SELECTED:
			pass
	else:
		numPlayersSelectProfs = numPlayersSelectProfs +1

		
		

func enableProfSelectionPane(pane):
	
	pane.set_physics_process(true)
	#pane.get_node("inputManager").set_physics_process(true)
				
func disableProfSelectionPane(pane):
	
	pane.set_physics_process(false)
	#pane.get_node("inputManager").set_physics_process(false)
	
func _on_back():
	emit_signal("back")	

	


