extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal proficiencies_selected
signal back

enum TrainingState{
	
	INITIAL,
	PLAYER_PROFICIENCIES_SELECTED,
	BOT_PROFICIENCIES_SELECTED	
}

var numPlayersReady = 0

var advProf =null
var disProf=null
var pid =null

var GLOBALS = preload("res://Globals.gd")
const ONE_SECOND = 1
var inputDevices = []
var holdingBTime = {}

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

func _ready():
	
	pass
#func init(_mode,_player1Name,_player2Name,_networkManager):
func init(_mode,_player1Name,_player2Name,_onlineModeMaineInputDeviceId=null):
	mode = _mode
	player1Name = _player1Name
	player2Name = _player2Name
	onlineModeMaineInputDeviceId = _onlineModeMaineInputDeviceId
	#networkManager = _networkManager
	
	
	p1 = $"player1-pane"
	p1.connect("ready",self,"_on_player_ready",[p1.inputDeviceId])
	p2 = $"player2-pane"
	p2.connect("ready",self,"_on_player_ready",[p2.inputDeviceId])
	
	#p1.init(mode, networkManager)
	#p2.init(mode, networkManager)
		
	p1.init(mode,onlineModeMaineInputDeviceId)
	p2.init(mode,onlineModeMaineInputDeviceId)
	
	
	#wehn in training mode, 1 controller controls both prof selections
	if mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		
		#both the proficiency panes will be filled by same controller
		$"player1-pane/inputManager".inputDeviceId =trainingPlayerDeviceId
		$"player2-pane/inputManager".inputDeviceId =trainingPlayerDeviceId

		p1.inputDeviceId =trainingPlayerDeviceId
		p2.inputDeviceId =trainingPlayerDeviceId
		
		p1.connect("advantage_proficiency_selected",self,"_on_advantage_proficiency_selected")
		p1.connect("advantage_proficiency_unselected",self,"_on_advantage_proficiency_unselected")
		p1.connect("disadvantage_proficiency_selected",self,"_on_disadvantage_proficiency_selected")
		p1.connect("disadvantage_proficiency_unselected",self,"_on_disadvantage_proficiency_unselected")
		
		
		p2.connect("advantage_proficiency_selected",self,"_on_advantage_proficiency_selected")
		p2.connect("advantage_proficiency_unselected",self,"_on_advantage_proficiency_unselected")
		p2.connect("disadvantage_proficiency_selected",self,"_on_disadvantage_proficiency_selected")
		p2.connect("disadvantage_proficiency_unselected",self,"_on_disadvantage_proficiency_unselected")
	
		trainingState = TrainingState.INITIAL
	else:
		p1.connect("disadvantage_proficiency_selected",self,"_on_disadvantage_proficiency_selected")
		p1.connect("disadvantage_proficiency_unselected",self,"_on_disadvantage_proficiency_unselected")
		p2.connect("disadvantage_proficiency_selected",self,"_on_disadvantage_proficiency_selected")
		p2.connect("disadvantage_proficiency_unselected",self,"_on_disadvantage_proficiency_unselected")
		
	
#	if mode == GLOBALS.GameModeType.ONLINE_HOSTING or mode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:

#		var otherInputDevice = GLOBALS.opposingInputDevice(onlineModeMaineInputDeviceId)
#		if mode == GLOBALS.GameModeType.ONLINE_HOSTING:
			
			
#			$"player1-pane/inputManager".inputDeviceId =onlineModeMaineInputDeviceId
#			$"player2-pane/inputManager".inputDeviceId =otherInputDevice
		
#			p1.inputDeviceId =onlineModeMaineInputDeviceId
#			p2.inputDeviceId =otherInputDevice
			
#		else:
#			$"player1-pane/inputManager".inputDeviceId =otherInputDevice
#			$"player2-pane/inputManager".inputDeviceId =onlineModeMaineInputDeviceId
			
#			p1.inputDeviceId =otherInputDevice
#			p2.inputDeviceId =onlineModeMaineInputDeviceId
			
	$"player1-pane/inputManager".init()
	$"player2-pane/inputManager".init()
	
	p1NameLabel = $"player1-pane/player-label"
	p2NameLabel = $"player2-pane/player-label"
	
	if player1Name != null:
		p1NameLabel.text = player1Name
		
	if player2Name != null:
		p2NameLabel.text = player2Name
	
	#wehn in training mode, 1 controller controls both prof selections
	if mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		
	
		#only the player 1 will have profs chosen first
		enableProfSelectionPane(p1)
		disableProfSelectionPane(p2)
	
		
	holdingBTime[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = 0
	holdingBTime[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = 0
	
	inputDevices.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDevices.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	
	numPlayersSelectProfs=0;
	
	
		
	pass
	


func setMode(value):
	mode = value
		
func getMode():
	return mode
	
func _on_player_ready(_advProf,_disProf,_id):
	
	#when in training mode, ignore ready player , proficiency selection, only 
	#handle bot ready
	if mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		if trainingState == TrainingState.INITIAL:
			pass
		elif trainingState == TrainingState.PLAYER_PROFICIENCIES_SELECTED:
			
			#unlock the player's prof selection
			p1.ready = false
			p1.readyIcon.visible = false
		if trainingState == TrainingState.BOT_PROFICIENCIES_SELECTED:
			disableProfSelectionPane(p1)
			disableProfSelectionPane(p2)
			set_physics_process(false)
			emit_signal("proficiencies_selected",playerAdvProf,playerDisProf,botAdvProf,botDisProf)
			return
		
	#numPlayersReady+=1
	
	#2nd player has made selection choice?
	#if numPlayersReady == 2 :
		
	#	if _id == "P1":
			
	#		#player 1 info goes as first parameters
	#		emit_signal("proficiencies_selected",_advProf,_disProf,advProf,disProf)
	#	else:
			#player 1 info goes as first parameters
	#		emit_signal("proficiencies_selected",advProf,disProf,_advProf,_disProf)
	#else:
	#	advProf=_advProf
	#	disProf=_disProf
	#	pid = _id
	if mode == GLOBALS.GameModeType.ONLINE_HOSTING or  mode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		
		#in online mode only 1 controller has to select proficiencies to continue
		disableProfSelectionPane(p1)
		disableProfSelectionPane(p2)
		set_physics_process(false)
		emit_signal("proficiencies_selected", p1.advProf,p1.disProf, p2.advProf, p2.disProf)
		
		#if mode == GLOBALS.GameModeType.ONLINE_HOSTING:
			#send null player 2 profs, as upon connection profs will be synched
		#	emit_signal("proficiencies_selected", p1.advProf,p1.disProf, null, null)
		#else:
			#send null player 1 profs, as upon connection profs will be synched
			#emit_signal("proficiencies_selected",null,null, p2.advProf, p2.disProf)
	#all players made their choice and a player pressed start
	elif numPlayersSelectProfs ==2:
		disableProfSelectionPane(p1)
		disableProfSelectionPane(p2)
		set_physics_process(false)
		emit_signal("proficiencies_selected", p1.advProf,p1.disProf, p2.advProf, p2.disProf)
		
		
func _physics_process(delta):

	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	#go thorugh the player input devices
	for player in inputDevices:
		
			#ONLINE mode?
		if mode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST or mode == GLOBALS.GameModeType.ONLINE_HOSTING:
				
			if player != onlineModeMaineInputDeviceId:
				#online mode, we pre-select our character before connecting to peer, so 
				#only accept input from the input device that was used to enter lobby
				continue
				
		#players may be holding b to go back
		if Input.is_action_pressed(player+"_B"):
			
			#count how long holding B
			holdingBTime[player] += delta
			
			if holdingBTime[player] > ONE_SECOND:
				
				emit_signal("back")
				
		elif Input.is_action_just_released(player+"_B"):
			#reset the holding b timer, were done trying to go back
			holdingBTime[player] =0
			
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _on_advantage_proficiency_selected():
	
	if mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		if trainingState == TrainingState.INITIAL:
			#player proficiency advantage selected, need to pick disadvantage prof
			enableProfSelectionPane(p1)
			disableProfSelectionPane(p2)
			playerAdvProf = p1.advProf
		elif trainingState == TrainingState.PLAYER_PROFICIENCIES_SELECTED:
			#bot proficiency advantage selected, need to pick disadvantage prof for bot, no longer
			#can remove plaery's proficiencies
			disableProfSelectionPane(p1)
			enableProfSelectionPane(p2)			
			p2.set_physics_process(true)
			botAdvProf = p2.advProf
		elif trainingState == TrainingState.BOT_PROFICIENCIES_SELECTED:
			pass
	else:
		pass
		
func _on_advantage_proficiency_unselected():
	
	if mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		if trainingState == TrainingState.INITIAL:
			#choosing bot profs disabled, choosing players prof enabled, unselect advantage prof
			enableProfSelectionPane(p1)
			disableProfSelectionPane(p2)
			playerAdvProf = null
			
		elif trainingState == TrainingState.PLAYER_PROFICIENCIES_SELECTED:
			# unselect advantage prof for bot, but can unselect advantage prof for palyer and can choose bots adv prof
			enableProfSelectionPane(p1)
			enableProfSelectionPane(p2)
			botAdvProf = null
		elif trainingState == TrainingState.BOT_PROFICIENCIES_SELECTED:
			pass
	else:
		pass	



func _on_disadvantage_proficiency_unselected():
	
	if mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		if trainingState == TrainingState.INITIAL:
			pass
		elif trainingState == TrainingState.PLAYER_PROFICIENCIES_SELECTED:
			enableProfSelectionPane(p1)
			disableProfSelectionPane(p2)
			playerDisProf = null
			trainingState = TrainingState.INITIAL
		elif trainingState == TrainingState.BOT_PROFICIENCIES_SELECTED:
			disableProfSelectionPane(p1)
			enableProfSelectionPane(p2)
			botDisProf = null
			trainingState = TrainingState.PLAYER_PROFICIENCIES_SELECTED
	else:
		
		numPlayersSelectProfs = numPlayersSelectProfs -1
		
func _on_disadvantage_proficiency_selected():
	
	if mode == GLOBALS.GameModeType.TRAINING or mode == GLOBALS.GameModeType.PLAY_V_AI:
		if trainingState == TrainingState.INITIAL:
			enableProfSelectionPane(p1)
			enableProfSelectionPane(p2)
			playerDisProf = p1.disProf
			trainingState = TrainingState.PLAYER_PROFICIENCIES_SELECTED
		elif trainingState == TrainingState.PLAYER_PROFICIENCIES_SELECTED:
			disableProfSelectionPane(p1)
			enableProfSelectionPane(p2)
			botDisProf = p2.disProf
			trainingState = TrainingState.BOT_PROFICIENCIES_SELECTED
		elif trainingState == TrainingState.BOT_PROFICIENCIES_SELECTED:
			pass
	else:
		numPlayersSelectProfs = numPlayersSelectProfs +1

		
		

func enableProfSelectionPane(pane):
	
	pane.set_physics_process(true)
	pane.get_node("inputManager").set_physics_process(true)
				
func disableProfSelectionPane(pane):
	
	pane.set_physics_process(false)
	pane.get_node("inputManager").set_physics_process(false)
	
	

	