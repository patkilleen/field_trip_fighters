extends Node

signal loading_game
signal done_loading_game
signal loading_screen_finished
#hitbox and hurt box collision layers and masks for players
#const PLAYER_1_HITBOX_LAYER_BIT =  12
#const PLAYER_1_HURTBOX_LAYER_BIT = 13
#const PLAYER_2_HITBOX_LAYER_BIT = 14
#const PLAYER_2_HURTBOX_LAYER_BIT = 15

#body box collision masks and layers
#const PLAYER1_STAGE_COLLISION_LAYER_BIT = 0
#const PLAYER2_STAGE_COLLISION_LAYER_BIT = 1
#const PLAYER1_FALSE_WALL_STAGE_COLLISION_LAYER_BIT = 2
#const PLAYER2_FALSE_WALL_STAGE_COLLISION_LAYER_BIT = 3
#const PLAYER1_PUSHABLE_BODYBOX_LAYER_BIT = 4
#const PLAYER2_PUSHABLE_BODYBOX_LAYER_BIT = 5
#const PLAYER1_PLATFORM_LAYER_BIT = 6
#const PLAYER2_PLATFORM_LAYER_BIT = 7

const frameTimerResource = preload("res://frameTimer.gd")
const GLOBALS = preload("res://Globals.gd")

const MINIMUM_LOADING_SCREEN_TIME = 1


#var testGhostAIDBResource = preload("res://ai/test/TestGhostAIDB.gd")
#var testGhostAISituationHandlerResource = preload("res://ai/test/TestGhostAISituationHandler.gd")
var loadingThread=null


var player1Choice = null
var player2Choice = null

var player1Name = null
var player2Name = null

var player1Color = null
var player2Color  = null

var p1advProf=null
var p1disProf=null
var p2advProf = null
var p2disProf = null

var p1Prof1MajorClassIxSelect=null
var p1Prof1MinorClassIxSelect=null
var p1Prof2MajorClassIxSelect = null
var p1Prof2MinorClassIxSelect = null
var p2Prof1MajorClassIxSelect=null
var p2Prof1MinorClassIxSelect=null
var p2Prof2MajorClassIxSelect=null
var p2Prof2MinorClassIxSelect=null
	

var player1RemapButtonModel=null
var player2RemapButtonModel=null
	
var savedReplayId = null	
#var loadingScreenTimer = null
var loadingScreen = null
var gameObjects = null
var musicPlayer = null setget setMusicPlayer, getMusicPlayer
var fighter1Texture = null
var fighter2Texture = null
var settings = null
var stats = null
var stage = null


var onlineModeMaineInputDeviceId =null
var menuConfirmSFXSoundPlayer = null

var aiDemoDataFilePaths = {"ken":"res://ai/data/live/ken.ser", "marth":"res://ai/data/live/marth.ser","falcon":"res://ai/data/live/falcon.ser","glove":"res://ai/data/live/glove.ser","samus":"res://ai/data/live/samus.ser","belt":"res://ai/data/live/belt.ser","microphone":"res://ai/data/live/microphone.ser","hat":"res://ai/data/live/hat.ser","whistle":"res://ai/data/live/whistle.ser"}


var gameMode = null


#we save the ip address of host we connecting to 
var hostsIpAddr = null

var networkManager = null

#TODO consider chaning this variables name (its used for both play versus ai and training mode)
var trainingPlayerDeviceId = null 
		
const MENU_SELECT_SOUND_ID = 0
const MENU_BACK_SOUND_ID = 1


var stage_scene_path = null
var crewBattleFlag = true
var crewBattleWinner = null
var crewBattleWinnerPlayerState = null #deep copy of player state

var muteNextScreenMenuSoundFlag = false

var loadingScreenMinDurationEllapsed = false

var gameDoneLoadingFlag = false
var loadingScreeenFinishedFlag = false
var loadGameMutex = null

var proficiencyModel = null

var replayHandler = null

var loadingScreenFrameTimer = null
var loadingScreenFrameTimer2 = null

var lastStageSelected_scene_path = null

var nameIOHandler = null

func _ready():
	
	#var test = testGhostAIDBResource.new()
	#test.testAll()
	#test = testGhostAISituationHandlerResource.new()
	#test.testAll()
	loadGameMutex = Mutex.new()
	
	#Engine.set_target_fps(15)
	setMusicPlayer($menuMusicPlayer)
	menuConfirmSFXSoundPlayer = $menuConfirmSFXSounds
	gameObjects=$game_objects
	loadingScreen = $LoadingScreen
	settings = $settings
	stats = $stats
	replayHandler = $replayHandler
	
	replayHandler.connect("restart_replay",self,"_on_replay_launch_request")
	
	loadingScreenFrameTimer=frameTimerResource.new()
	loadingScreenFrameTimer2=frameTimerResource.new()
	add_child(loadingScreenFrameTimer)
	add_child(loadingScreenFrameTimer2)
	
	
	loadingScreenFrameTimer2.connect("timeout",self,"_on_min_loading_screen_duration_timeout")
	
	proficiencyModel = $ProficiencyDataModel
	
	networkManager = $networkManager
	
	networkManager.connect("disconnected",self,"_on_online_session_ended")
	
	connect("loading_game",networkManager,"_on_loading_game")
	connect("done_loading_game",networkManager,"_on_done_loading_game")
	
	#loadingScreenTimer = frameTimerResource.new()
	#loadingScreenTimer.one_shot = true #set to true to indicate don't conitune ticking (only executed once called)
	#self.add_child(loadingScreenTimer)
	
	
	#load the settings
	settings.loadSettings()
	stats.loadStats()
	
	
	nameIOHandler = $"namesIOHandler"
	nameIOHandler.init(GLOBALS.PLAYER_NAME_FILE,stats)
	
	
	self.connect("done_loading_game",self,"_on_done_loading_game")
	
	#uncomment below to merge ai's demo data fo ken (testing revealed it doesn't really inprome ai, so w/e)
	#var ghostAirDBMerger = load("res://ai/GhostAIDBMerger.gd").new()
	#ghostAirDBMerger.mergeMatchDataToGhostDB("ken", "res://ai/data/tmp/ken.ser","user://match-data", "user://merged-db/ken.ser")
	#ghostAirDBMerger.mergeMatchDataToGhostDB("ken", "res://ai/data/tmp/ken.ser","user://tmp-match-data", "user://merged-db/ken.ser")
	#_on_character_select()
	_on_main_menu()
	OS.set_window_maximized(true)
	
	pass

func playMenuSelectSound():
	menuConfirmSFXSoundPlayer.playSound(MENU_SELECT_SOUND_ID)
	
func _on_main_menu():
	
	freeGameObjects()
	
	muteNextScreenMenuSoundFlag = false
	
	replayHandler.set_physics_process(false)
	# Add the next level
	var mainMenu_resource = preload("res://interface/main-menu/MainMenu.tscn")
	var mainMenu = mainMenu_resource.instance()
	gameObjects.add_child(mainMenu)
	mainMenu.connectToMenuButtons(self,"_on_main_menu_button_confirmation")
	
	#forget the crew battle info
	crewBattleWinnerPlayerState = null
	crewBattleWinner=null
	
	stage_scene_path = null
	hostsIpAddr = null
	
	playMainMenuMusic()

	
func _on_online_menu():
	
	freeGameObjects()
	
	# Add the next level
	var onlineMenu_resource = preload("res://interface/main-menu/OnlineMenu.tscn")
	var onlineMenu = onlineMenu_resource.instance()
	gameObjects.add_child(onlineMenu)
	onlineMenu.connectToMenuButtons(self,"_on_online_menu_button_confirmation")
	onlineMenu.connect("back",self,"_on_main_menu")
	
	#forget the crew battle info
	crewBattleWinnerPlayerState = null
	crewBattleWinner=null
	
	
	
	playMainMenuMusic()
	
func playMainMenuMusic():
	if not self.musicPlayer.playing:
		#load music
		
		musicPlayer.playSound()
		
		pass
	

func _on_main_menu_button_confirmation(buttonText, arg,inputDeviceId):
	
	if buttonText == "Exit":
		
		#save any changes to the settings
		settings.saveSettings()
		
		get_tree().quit()
	elif buttonText == "Play":
		gameMode = GLOBALS.GameModeType.STANDARD
		#check if we are doing a crew battle
		crewBattleFlag = bool(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.CREW_BATTLE_FLAG_KEY))	
		self.call_deferred("_on_character_select",inputDeviceId)
	elif buttonText == "Play vs. AI":
		gameMode = GLOBALS.GameModeType.PLAY_V_AI
		trainingPlayerDeviceId =  arg[0] #P1_ or P2, the id of input device who picked AI
		self.call_deferred("_on_character_select",inputDeviceId)
		
	elif buttonText == "Play Online":
		self.call_deferred("_on_online_menu")
	elif buttonText == "Options":
		#self.call_deferred("_on_settings_menu")
		self.call_deferred("_on_options_menu")
	elif buttonText == "Training":
		gameMode = GLOBALS.GameModeType.TRAINING
		trainingPlayerDeviceId =  arg[0] #P1_ or P2, the id of input device who picked training
		self.call_deferred("_on_character_select",inputDeviceId)




func _on_options_menu_button_confirmation(buttonText, arg,inputDeviceId):
	
	if buttonText == "Back":
		self.call_deferred("_on_main_menu")
	elif buttonText == "Settings":
		
		self.call_deferred("_on_settings_menu")
		
	elif buttonText == "Names & Controls":

		self.call_deferred("_on_names_menu")
		
	elif buttonText == "Highscores":

		self.call_deferred("_on_highscores_menu")
	elif buttonText == "Replays":
		
		self.call_deferred("_on_replays_menu")
		
	
		#self.call_deferred("_on_online_lobby",inputDeviceId)
func _on_online_menu_button_confirmation(buttonText, arg,inputDeviceId):
	
	if buttonText == "Back":
		onlineModeMaineInputDeviceId=null
		self.call_deferred("_on_main_menu")
	elif buttonText == "Host":
		gameMode = GLOBALS.GameModeType.ONLINE_HOSTING
		#check if we are doing a crew battle
		crewBattleFlag = bool(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.CREW_BATTLE_FLAG_KEY))	
		
		onlineModeMaineInputDeviceId=inputDeviceId
		#handleNetworkSetup(inputDeviceId)
		self.call_deferred("_on_character_select",inputDeviceId)
		#self.call_deferred("_on_online_lobby",inputDeviceId)
		
	elif buttonText == "Connect to Host":
		
		gameMode = GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST
		#check if we are doing a crew battle
		crewBattleFlag = bool(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.CREW_BATTLE_FLAG_KEY))	
		onlineModeMaineInputDeviceId=inputDeviceId
		#handleNetworkSetup(inputDeviceId)
		self.call_deferred("_on_character_select",inputDeviceId)
		#self.call_deferred("_on_online_lobby",inputDeviceId)

#called to go back to previous screen
func _on_back(scene):
	
	muteNextScreenMenuSoundFlag = true
	menuConfirmSFXSoundPlayer.playSound(MENU_BACK_SOUND_ID)
	
	if scene == "CharacterSelect":
		#go back to main menu
		self.call_deferred("_on_main_menu")
	elif scene == "ProfSelect": #not implemented yet
		
		#go back to character select
		self.call_deferred("_on_character_select")
	elif scene == "SettingsMenu":
		#go back to options menu
		self.call_deferred("_on_options_menu")
	elif scene == "ReplayMenu":
		#go back to options menu
		self.call_deferred("_on_options_menu")
	elif scene == "OptionsMenu":
		#go back to options menu
		self.call_deferred("_on_options_menu")
	
	elif scene == "HighscoreMenu":
		#go back to options menu
		self.call_deferred("_on_options_menu")
			
	
#	elif scene == "StageSelect":
		
		#do we skip the prof selection and go to char select?
#		var skipProfSelectFlag = bool(settings.getValue(settings.PERSISTENT_USER_SETTINGS_SECTION,settings.SKIP_PROFICIENCY_SELECT_FLAG_KEY))	
	
#		if skipProfSelectFlag:
			#go back to character select, cause we never arrived at prof select
#		self.call_deferred("_on_character_select")
		#else:
		#	stage.call_deferred("_on_back_to_proficiency_select")
		
	#	else:
	#		self.call_deferred("_on_proficiency_selection",player1Choice, player2Choice,fighter1Texture,fighter2Texture,player1Name,player2Name, skipProfSelectFlag)
	
func _on_back_from_stage_select(player1Choice, player2Choice,fighter1Texture,fighter2Texture,player1Name,player2Name,player1Color,player2Color,skipProfSelectFlag):
	
	muteNextScreenMenuSoundFlag = true
	menuConfirmSFXSoundPlayer.playSound(MENU_BACK_SOUND_ID)
	call_deferred("_on_proficiency_selection",player1Choice, player2Choice,fighter1Texture,fighter2Texture,player1Name,player2Name,player1Color,player2Color,skipProfSelectFlag)
	#stageSelect.connect("back",self,"_on_proficiency_selection",[player1Choice, player2Choice,fighter1Texture,fighter2Texture,player1Name,player2Name,player1Color,player2Color,skipProfSelectFlag]) #go to proficiency selection
	
		
func setMusicPlayer(p):
	musicPlayer=p
func getMusicPlayer():
	return musicPlayer

func _on_game_ended(victoryType,winnerText,player1State,player2State, stylePointsPlayerState,p1Controller,p2Controller):
	
	#stop the music of the stage
	
	#stage.musicPlayer.stopAll()
	stage.stopStageMusic()
	
	
	
	var result_screen_resource = preload("res://ResultScreen.tscn")
	
	#create a result screen if it doesn't exist yet
#	if result_screen == null:
	var result_screen = result_screen_resource.instance()
	gameObjects.add_child(result_screen)	
	
	
	#populate the screen with ending stats
	result_screen.init(victoryType,winnerText,player1Choice,player2Choice,player1Name,player2Name,player1State,player2State,stylePointsPlayerState,stats,gameMode,p1Controller,p2Controller,lastStageSelected_scene_path)
	
	#result_screen.connect("restart_game",self,"_on_character_select")
	
	#do we event need this anymore?
	result_screen.pauseHUD.connect("restart_game",self,"_on_exit_result_screen_restart_game",[result_screen])
	result_screen.pauseHUD.connect("back_to_main_menu",self,"_on_exit_result_screen",[result_screen])
	result_screen.pauseHUD.connect("back_to_proficiency_select",self,"_on_exit_result_screen",[result_screen])
	result_screen.pauseHUD.connect("back_to_character_select",self,"_on_exit_result_screen",[result_screen])
	result_screen.pauseHUD.connect("back_to_stage_select",self,"_on_exit_result_screen",[result_screen])
	
	#connect the stage to signals, stage it will be used to navigate UI
	result_screen.pauseHUD.connect("restart_game",stage,"_on_start_match")
	result_screen.pauseHUD.connect("back_to_main_menu",stage,"_on_back_to_main_menu")
	result_screen.pauseHUD.connect("back_to_proficiency_select",stage,"_on_back_to_proficiency_select")
	result_screen.pauseHUD.connect("back_to_character_select",stage,"_on_back_to_character_select")
	result_screen.pauseHUD.connect("back_to_stage_select",stage,"_on_back_to_stage_select")
	result_screen.pauseHUD.connect("save_replay",stage,"_on_save_replay")

	#save stats of game after result screen, to give chance to display new records
	saveGameStats(player1Name,player2Name,player1Choice,player2Choice,player1State,player2State,stylePointsPlayerState,victoryType)
	
	
	#save the victor's info in case were doing crewbattles
	if crewBattleFlag:
		var winnerState = null	
		var winnerId = null
		#player 2 wins?
		if victoryType == GLOBALS.VictoryType.PLAYER2_WINS_VIA_KO or victoryType == GLOBALS.VictoryType.PLAYER2_WINS_VIA_TIMEOUT:	
			winnerState = player2State	
			winnerId=GLOBALS.PLAYER2_CREW_BATTLE_WINNER_ID
		#player 1 wins?
		elif victoryType == GLOBALS.VictoryType.PLAYER1_WINS_VIA_KO or victoryType == GLOBALS.VictoryType.PLAYER1_WINS_VIA_TIMEOUT:
			winnerState = player1State	
			winnerId=GLOBALS.PLAYER1_CREW_BATTLE_WINNER_ID
		#don't keep stats on draw, both players have 0 hp
		if winnerState !=null:
			
			crewBattleWinnerPlayerState = winnerState.deepCopy() #deep copy of player state
			crewBattleWinner=winnerId
	
	#don't play main menu sound upon result screen 
	#should be able to leave the game running with no sound between games
	#musicPlayer.playSound()

func saveGameStats(_player1Name,_player2Name,_player1Choice,_player2Choice,player1State,player2State,stylePointsPlayerState,victoryType):
	
	#also gotta save the style pooitns combo
	var p1VictoryStatType = null
	var p2VictoryStatType = null
	
	#RESOLVE the type of victory (don't want to count a draw as loss)
	#convert the GLOABL victory enum to stats enum
	if victoryType == GLOBALS.VictoryType.PLAYER1_WINS_VIA_KO or victoryType == GLOBALS.VictoryType.PLAYER1_WINS_VIA_TIMEOUT:
		p1VictoryStatType = stats.VictoryType.WIN
		p2VictoryStatType = stats.VictoryType.LOSS
	elif victoryType == GLOBALS.VictoryType.PLAYER2_WINS_VIA_KO or victoryType == GLOBALS.VictoryType.PLAYER2_WINS_VIA_TIMEOUT:
		p1VictoryStatType = stats.VictoryType.LOSS
		p2VictoryStatType = stats.VictoryType.WIN
	elif victoryType == GLOBALS.VictoryType.DRAW_VIA_KO or victoryType == GLOBALS.VictoryType.DRAW_VIA_TIMEOUT:
		p1VictoryStatType = stats.VictoryType.DRAW
		p2VictoryStatType = stats.VictoryType.DRAW
		
	
	#save the game stats for the match
	
	#player 1 save hero stats
	stats.updateHeroStats(_player1Choice,player1State,p1VictoryStatType)
	
	#player 1 has a different player name than default? (DON'T track cpu's stats)
	if player1Name != null and player1Name != GLOBALS.CPU_NAME:
		#player 1 save name stats
		stats.updatePlayerNameStats(_player1Name,_player1Choice,player1State,p1VictoryStatType)
	
	
	#player 2 save hero stats
	stats.updateHeroStats(_player2Choice,player2State,p2VictoryStatType)
	
	#player 2 has a different player name than default?(DON'T track cpu's stats)
	if player2Name != null and player2Name != GLOBALS.CPU_NAME:
		#player 2 save name stats
		stats.updatePlayerNameStats(_player2Name,_player2Choice,player2State,p2VictoryStatType)
		
	if p1VictoryStatType == stats.VictoryType.WIN:
		if stylePointsPlayerState!= null:
			stats.updateHeroStylePointsStats(_player1Choice,stylePointsPlayerState,p1VictoryStatType)
			
			#player 1 has a different player name than default?
			if player1Name != null and player1Name != GLOBALS.CPU_NAME:		
				stats.updatePlayerNameStylePointsStats(_player1Name,_player1Choice,stylePointsPlayerState,p1VictoryStatType)
	elif p2VictoryStatType == stats.VictoryType.WIN:
		
		if stylePointsPlayerState!= null:
			stats.updateHeroStylePointsStats(_player2Choice,stylePointsPlayerState,p2VictoryStatType)
		#player 2 has a different player name than default?
		if player2Name != null and player2Name != GLOBALS.CPU_NAME:		
			stats.updatePlayerNameStylePointsStats(_player2Name,_player2Choice,stylePointsPlayerState,p2VictoryStatType)
	
	stats.saveStats()
	
	
func _on_exit_result_screen_restart_game(resultScreen):
	stage.musicPlayer.playRandomSound()
	musicPlayer.stop()
	_on_exit_result_screen(resultScreen)
	
func _on_exit_result_screen(resultScreen):
	
	
	
	#make sure stage is loaded to start/restart
	#gameObjects.add_child(stage)
	
	#don't need result screen anymore
	resultScreen.disable()
	
	gameObjects.call_deferred("remove_child",resultScreen)
	resultScreen.call_deferred("free")

func _on_online_session_ended(netStatus,customMsg=""):
	var _inputDeviceId = null
	var _stageScenePath = null
	var _onlineLobby = null
	_on_online_lobby(_inputDeviceId,_stageScenePath,_onlineLobby,netStatus,customMsg)
	
func _on_online_lobby(_inputDeviceId,_stageScenePath, onlineLobby=null,netStatus = null,customMsg=""):
		
	replayHandler.set_physics_process(false)
	
	var reconnectingToPeer=true
	#first time instancing lobby?
	if onlineLobby == null:
		reconnectingToPeer=false
		if not muteNextScreenMenuSoundFlag:
			playMenuSelectSound()
	
		
		freeGameObjects()
	
	
		# Add the next level
		var onlineLobby_resource = preload("res://interface/main-menu/OnlineLobby.tscn")
		onlineLobby = onlineLobby_resource.instance()
	
		gameObjects.add_child( onlineLobby)
	
		onlineLobby.connect("host_ip_inputed",self,"_on_host_ip_inputed")
		onlineLobby.connect("reconnect_to_peer_request",self,"_on_lobby_reconnect_to_peer_request")
		
	var port  = int(settings.getValue(settings.TEMP_USER_SETTINGS_SECTION,settings.ONLINE_MODE_HOST_PORT_FLAG_KEY))	
	var debugNetcode  = bool(settings.getValue(settings.PERSISTENT_USER_SETTINGS_SECTION,settings.ONLINE_MODE_DEBUG_FLAG_KEY))	

	#starting the online match by entering lobby?
	if netStatus  == null:
		
		if not reconnectingToPeer:
				
			if _inputDeviceId == GLOBALS.PLAYER1_INPUT_DEVICE_ID:		
				
					onlineLobby.initOnlinePlay(player1Choice,player1Name,
					p1Prof1MajorClassIxSelect,	p1Prof1MinorClassIxSelect,
					p1Prof2MajorClassIxSelect,p1Prof2MinorClassIxSelect,
					player1Color,gameMode,networkManager,_stageScenePath,nameIOHandler.readInputRemapModel(player1Name),_inputDeviceId,port,debugNetcode,hostsIpAddr)
					
			else:
				
					#onlineLobby.initOnlinePlay(player2Choice,player2Name,p2advProf,p2disProf,player2Color,gameMode,networkManager,_stageScenePath,_inputDeviceId,port,debugNetcode)
					onlineLobby.initOnlinePlay(player2Choice,player2Name,
					p2Prof1MajorClassIxSelect,p2Prof1MinorClassIxSelect,
					p2Prof2MajorClassIxSelect,p2Prof2MinorClassIxSelect,
					player2Color,gameMode,networkManager,_stageScenePath,nameIOHandler.readInputRemapModel(player2Name),_inputDeviceId,port,debugNetcode,hostsIpAddr)
				
		else:
			#in the case we are reconnecting to the peer, the player selections eill
			#depend on who is host and client. So client is player 2 choice
			if gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
			
				onlineLobby.initOnlinePlay(player2Choice,player2Name,
				p2Prof1MajorClassIxSelect,	p2Prof1MinorClassIxSelect,
				p2Prof2MajorClassIxSelect,p2Prof2MinorClassIxSelect,
				player2Color,gameMode,networkManager,_stageScenePath,nameIOHandler.readInputRemapModel(player2Name),_inputDeviceId,port,debugNetcode,hostsIpAddr)
			else:#assume host
				onlineLobby.initOnlinePlay(player1Choice,player1Name,
				p1Prof1MajorClassIxSelect,	p1Prof1MinorClassIxSelect,
				p1Prof2MajorClassIxSelect,p1Prof2MinorClassIxSelect,
				player1Color,gameMode,networkManager,_stageScenePath,nameIOHandler.readInputRemapModel(player1Name),_inputDeviceId,port,debugNetcode,hostsIpAddr)
		
						
		if not  onlineLobby.is_connected("players_synchronized",self,"_on_online_match_synchronized"):
			onlineLobby.connect("players_synchronized",self,"_on_online_match_synchronized",[],CONNECT_ONESHOT)
		
	else:
		#were recoverying from online match and it ended	
		onlineLobby.initOnlineMatchEnd(netStatus,customMsg)
		
	if not onlineLobby.is_connected("back",self,"_on_main_menu"):
		onlineLobby.connect("back",self,"_on_main_menu",[],CONNECT_ONESHOT)
		
	muteNextScreenMenuSoundFlag = false

func _on_host_ip_inputed(_ipAddrStr):
	hostsIpAddr = _ipAddrStr
	
func _on_character_select(inputDeviceId = null):
	
	playMainMenuMusic()
	
	if not muteNextScreenMenuSoundFlag:
		playMenuSelectSound()
		
	muteNextScreenMenuSoundFlag = false
	
	freeGameObjects()
	# Add the next level
	var charSelect_resource = preload("res://CharacterSelect.tscn")
	var charSelect = charSelect_resource.instance()
	gameObjects.add_child(charSelect)
	
	#make sure to indicate the game mode were in
	charSelect.mode = gameMode
	
	#fix the frame rate if applicable
	#the delta for phsysics process will always be constant.
	
	
	
	#when in training, specify which input device selected training menu
	if gameMode == GLOBALS.GameModeType.TRAINING or GLOBALS.GameModeType.PLAY_V_AI:
		charSelect.trainingPlayerDeviceId = trainingPlayerDeviceId
		
	
	#charSelect.init(stats,player1Name,player2Name,inputDeviceId)
	charSelect.init(nameIOHandler,player1Name,player2Name,inputDeviceId)
	
	var skipProfSelectFlag = bool(settings.getValue(settings.PERSISTENT_USER_SETTINGS_SECTION,settings.SKIP_PROFICIENCY_SELECT_FLAG_KEY))	
	charSelect.connect("characters_selected",self,"_on_proficiency_selection",[skipProfSelectFlag])
	
	charSelect.connect("back",self,"_on_back", ["CharacterSelect"])
	
	
func _on_proficiency_selection(_player1Choice, _player2Choice,_fighter1Texture,_fighter2Texture,_player1Name,_player2Name, _player1Color,_player2Color,skipProfSelectFlag):
	
	
	
	player1Choice = _player1Choice
	player2Choice = _player2Choice
	fighter1Texture=_fighter1Texture
	fighter2Texture=_fighter2Texture
	player1Name=_player1Name
	player2Name=_player2Name
	player1Color = _player1Color
	player2Color = _player2Color
	
	freeGameObjects()
	
	if not muteNextScreenMenuSoundFlag:
		playMenuSelectSound()
		
	muteNextScreenMenuSoundFlag = false
	#only go to prof select if flag indicates to do so
	#if not bool(settings.getValue(settings.PERSISTENT_USER_SETTINGS_SECTION,settings.SKIP_PROFICIENCY_SELECT_FLAG_KEY)):
	if not skipProfSelectFlag:
		
		playMainMenuMusic()
		# Add the next level
		#var profSelect_resource = preload("res://ProficiencySelection.tscn")
		#var profSelect_resource = preload("res://interface/new-prof-select/NewProficiencySelectionScreen.tscn")
		var profSelect_resource = preload("res://interface/new-prof-select-wheel/NewProficiencySelectWheelScreen.tscn")
		
		var profSelect = profSelect_resource.instance()
		
		
		
			
		#profSelect.mode = gameMode
		#replace the input manager with training bot if in traniing mode
		if gameMode == GLOBALS.GameModeType.TRAINING or gameMode == GLOBALS.GameModeType.PLAY_V_AI:
			profSelect.trainingPlayerDeviceId = trainingPlayerDeviceId
		
		#profSelect.player1Name=_player1Name
		#profSelect.player2Name=_player2Name
		
		gameObjects.add_child(profSelect)
		
		#profSelect.init(gameMode,_player1Name,_player2Name,networkManager)
		profSelect.init(gameMode,_player1Name,_player2Name,onlineModeMaineInputDeviceId)
		
		profSelect.connect("proficiencies_selected",self,"_on_proficiencies_selected")
		profSelect.connect("back",self,"_on_back", ["ProfSelect"])
	else:
		
		
		#SKIp the proficiency selection and choose none as the prof
		#_on_proficiencies_selected(GLOBALS.Proficiency.NONE,GLOBALS.Proficiency.NONE,GLOBALS.Proficiency.NONE,GLOBALS.Proficiency.NONE)
		_on_proficiencies_selected(GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST,	GLOBALS.PROFICIENCY_NO_MINOR_CLASS,	
			GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST,	GLOBALS.PROFICIENCY_NO_MINOR_CLASS,
			GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST,	GLOBALS.PROFICIENCY_NO_MINOR_CLASS,
			GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST,	GLOBALS.PROFICIENCY_NO_MINOR_CLASS)

#func _on_proficiencies_selected(_p1advProf,_p1disProf,_p2advProf,_p2disProf):
func _on_proficiencies_selected(_p1Prof1MajorClassIxSelect,	_p1Prof1MinorClassIxSelect,	
			_p1Prof2MajorClassIxSelect,_p1Prof2MinorClassIxSelect,
			_p2Prof1MajorClassIxSelect,_p2Prof1MinorClassIxSelect,
			_p2Prof2MajorClassIxSelect,_p2Prof2MinorClassIxSelect):
	
	
	muteNextScreenMenuSoundFlag = false
	
	p1Prof1MajorClassIxSelect=	_p1Prof1MajorClassIxSelect	
	p1Prof1MinorClassIxSelect=_p1Prof1MinorClassIxSelect
	p1Prof2MajorClassIxSelect = _p1Prof2MajorClassIxSelect
	p1Prof2MinorClassIxSelect = _p1Prof2MinorClassIxSelect
	p2Prof1MajorClassIxSelect=_p2Prof1MajorClassIxSelect
	p2Prof1MinorClassIxSelect=_p2Prof1MinorClassIxSelect
	p2Prof2MajorClassIxSelect=_p2Prof2MajorClassIxSelect
	p2Prof2MinorClassIxSelect=_p2Prof2MinorClassIxSelect
	
	#p1advProf=_p1advProf
	#p1disProf=_p1disProf
	#p2advProf = _p2advProf
	#p2disProf = _p2disProf
	
	
	#peer that connects to host can't select stage. go to online lobby
	if gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		var _stageScenePath=null		
		self.call_deferred("_on_online_lobby",onlineModeMaineInputDeviceId,_stageScenePath)
		return
	#wait a 10 frames to give chance for animations of ready to show up on screen
	#yield(get_tree().create_timer(10* GLOBALS.SECONDS_PER_FRAME),"timeout")
		
	
	var skipStageSelectFlag = bool(settings.getValue(settings.PERSISTENT_USER_SETTINGS_SECTION,settings.SKIP_STAGE_SELECT_FLAG_KEY))	
	
	if not skipStageSelectFlag:
		playMainMenuMusic()
		#load the stage select scene
		load_stage_select()
		pass
	else:
		var _player1RemapButtonModel = nameIOHandler.readInputRemapModel(player1Name)
		var _player2RemapButtonModel = nameIOHandler.readInputRemapModel(player2Name)
		#begin_loading_game(_p1advProf,_p1disProf,_p2advProf,_p2disProf,preload("res://stages/snow-carnaval.tscn"))
		begin_loading_game(_p1Prof1MajorClassIxSelect,	_p1Prof1MinorClassIxSelect,
			_p1Prof2MajorClassIxSelect,_p1Prof2MinorClassIxSelect,
			_p2Prof1MajorClassIxSelect,_p2Prof1MinorClassIxSelect,
			_p2Prof2MajorClassIxSelect,_p2Prof2MinorClassIxSelect,preload("res://stages/snow-carnaval.tscn"),
			_player1RemapButtonModel,_player2RemapButtonModel)
		

func load_stage_select():
	playMainMenuMusic()
	freeGameObjects()
	
	
	if not muteNextScreenMenuSoundFlag:
		playMenuSelectSound()
		
	var stageSelect_resource = preload("res://map-selection.tscn")
	var stageSelect = stageSelect_resource.instance()
	
	stageSelect.setGameMode(gameMode)
	stageSelect.setLastStageSelected(lastStageSelected_scene_path)
	gameObjects.add_child(stageSelect)
	
	var skipProfSelectFlag = false
	
	
	stageSelect.connect("stage_selected",self,"_on_stage_selected")
	
	#instead of sending back to normal back function logic, we send back to proficiency selection
	#stageSelect.connect("back",self,"_on_proficiency_selection",[player1Choice, player2Choice,fighter1Texture,fighter2Texture,player1Name,player2Name,player1Color,player2Color,skipProfSelectFlag]) #go to proficiency selection
	stageSelect.connect("back",self,"_on_back_from_stage_select",[player1Choice, player2Choice,fighter1Texture,fighter2Texture,player1Name,player2Name,player1Color,player2Color,skipProfSelectFlag]) #go to proficiency selection
	
	#stageSelect.connect("back",self,"_on_back", ["StageSelect"]) 
	
#called whe player selects stage
#func _on_stage_selected(stageSelected):
func _on_stage_selected(stageNodePath):
	
	
	
	#host goes to online lobby after selecting stage that connects to host can't select stage. go to online lobby
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING:
		#stage_scene_path = stageSelected.stage_scene_path
		stage_scene_path = stageNodePath
		lastStageSelected_scene_path=stage_scene_path
		self.call_deferred("_on_online_lobby",onlineModeMaineInputDeviceId,stage_scene_path)
		return
	
	lastStageSelected_scene_path=stageNodePath
	
	#playMainMenuMusic()
	#playMenuSelectSound()
	
	var _player1RemapButtonModel = nameIOHandler.readInputRemapModel(player1Name)
	var _player2RemapButtonModel = nameIOHandler.readInputRemapModel(player2Name)
	
	#var stage_recourse = load(stageSelected.stage_scene_path)
	var stage_recourse = load(stageNodePath)
	
	#begin_loading_game(p1advProf,p1disProf,p2advProf,p2disProf,stage_recourse)
	begin_loading_game(p1Prof1MajorClassIxSelect,	p1Prof1MinorClassIxSelect,
			p1Prof2MajorClassIxSelect,p1Prof2MinorClassIxSelect,
			p2Prof1MajorClassIxSelect,p2Prof1MinorClassIxSelect,
			p2Prof2MajorClassIxSelect,p2Prof2MinorClassIxSelect,stage_recourse,
			_player1RemapButtonModel,_player2RemapButtonModel)
	
#func begin_loading_game(_p1advProf,_p1disProf,_p2advProf,_p2disProf,stage_resource):
	
func begin_loading_game(_p1Prof1MajorClassIxSelect,	_p1Prof1MinorClassIxSelect,
			_p1Prof2MajorClassIxSelect,_p1Prof2MinorClassIxSelect,
			_p2Prof1MajorClassIxSelect,_p2Prof1MinorClassIxSelect,
			_p2Prof2MajorClassIxSelect,_p2Prof2MinorClassIxSelect,stage_resource,
			_player1RemapButtonModel,_player2RemapButtonModel):
	
	player1RemapButtonModel=_player1RemapButtonModel
	player2RemapButtonModel=_player2RemapButtonModel
	
	var enableLoadingScreenFlag = bool(settings.getValue(settings.PERSISTENT_USER_SETTINGS_SECTION,settings.LOAD_GAME_IN_DIFFERENT_THREAD_KEY))	
	
	if enableLoadingScreenFlag:
		
		#maybe this should go in else below, when not loading screen enealbed?
		startLoadingScreen()
			
		loadingThread = Thread.new()
		#start game with loading screen but doesn't allow breakpoints
		#loadingThread.start(self,"_on_load_game",[player1Choice, player2Choice,p1advProf,p1disProf,p2advProf,p2disProf,player1Name,player2Name,player1Color,player2Color,stage_resource])
		loadingThread.start(self,"_on_load_game",[player1Choice, player2Choice,
			p1Prof1MajorClassIxSelect,	p1Prof1MinorClassIxSelect,
			p1Prof2MajorClassIxSelect,p1Prof2MinorClassIxSelect,
			p2Prof1MajorClassIxSelect,p2Prof1MinorClassIxSelect,
			p2Prof2MajorClassIxSelect,p2Prof2MinorClassIxSelect,
			player1Name,player2Name,player1Color,player2Color,stage_resource,
			_player1RemapButtonModel,_player2RemapButtonModel])
	else:
		
		var skipLoadDelayFlag = bool(settings.getValue(settings.PERSISTENT_USER_SETTINGS_SECTION,settings.SKIP_LOAD_SCREEN_DELAY_FLAG_KEY))	
		if not skipLoadDelayFlag:
		#*************************
		
			#put the loading sccreen, then use yield for it to be ready, then load game after like 1 second
			startLoadingScreen()
			#give engine a chance to display the loading screen
			yield(get_tree(),"physics_frame") #consider using physics_frame instead of idle_frame
		
		
		
			#wait a brief moement to display proficiencies
			#don't need to wait for prof display anymore as you choose it in selection
			#wait a brief moment to allow loading screen to load
			#yield(get_tree().create_timer(MINIMUM_LOADING_SCREEN_TIME),"timeout")
			loadingScreenFrameTimer.startInSeconds(MINIMUM_LOADING_SCREEN_TIME)
			yield(loadingScreenFrameTimer,"timeout")
			
		
		
		#uncomment below for debgging game without loading screen
		#_on_load_game([player1Choice, player2Choice,p1advProf,p1disProf,p2advProf,p2disProf,player1Name,player2Name,player1Color,player2Color,stage_resource])
		_on_load_game([player1Choice, player2Choice,
			p1Prof1MajorClassIxSelect,	p1Prof1MinorClassIxSelect,
			p1Prof2MajorClassIxSelect,p1Prof2MinorClassIxSelect,
			p2Prof1MajorClassIxSelect,p2Prof1MinorClassIxSelect,
			p2Prof2MajorClassIxSelect,p2Prof2MinorClassIxSelect
		,player1Name,player2Name,player1Color,player2Color,stage_resource,
		_player1RemapButtonModel,_player2RemapButtonModel])
	
		#	yield for done_loading_game
		#then hide loading screen


func _on_names_menu():
	
	
	playMainMenuMusic()
	
	if not muteNextScreenMenuSoundFlag:
		playMenuSelectSound()
		
	muteNextScreenMenuSoundFlag = false
	
	freeGameObjects()
	
	# Add the next level
	var namesMenu_resource = preload("res://interface/button-layout/NameMenu.tscn")
	var namesMenu = namesMenu_resource.instance()
	gameObjects.add_child(namesMenu)
	
	
	
	namesMenu.connect("back",self,"_on_back", ["OptionsMenu"])
	
	namesMenu.init(nameIOHandler)
	

func _on_replays_menu():
	playMainMenuMusic()
	
	if not muteNextScreenMenuSoundFlag:
		playMenuSelectSound()
		
	muteNextScreenMenuSoundFlag = false
	
	freeGameObjects()
	
	# Add the next level
	var replaysMenu_resource = preload("res://interface/replays-menu/ReplaysMenu.tscn")
	var replaysMenu = replaysMenu_resource.instance()
	gameObjects.add_child(replaysMenu)
	
	
	
	replaysMenu.connect("back",self,"_on_back", ["ReplayMenu"])
	replaysMenu.connect("replay_launch_request",self,"_on_replay_launch_request")
	
	replaysMenu.init(replayHandler)
	
func _on_settings_menu():
	
	playMainMenuMusic()
	
	if not muteNextScreenMenuSoundFlag:
		playMenuSelectSound()
		
	muteNextScreenMenuSoundFlag = false
	
	freeGameObjects()
	
	# Add the next level
	var settingsMenu_resource = preload("res://interface/settings-menu/Settings.tscn")
	var settingsMenu = settingsMenu_resource.instance()
	gameObjects.add_child(settingsMenu)
	
	
	
	settingsMenu.connect("back",self,"_on_back", ["SettingsMenu"])
	#settingsMenu.connect("replay_launch_request",self,"_on_replay_launch_request")
	
	settingsMenu.init(settings)#,stats,replayHandler)
	
	
func _on_highscores_menu():
	
	playMainMenuMusic()
	
	if not muteNextScreenMenuSoundFlag:
		playMenuSelectSound()
		
	muteNextScreenMenuSoundFlag = false
	
	freeGameObjects()
	
	# Add the next level
	var highScoremenu_resource = preload("res://interface/stats-menu/StatsMenu.tscn")
	var hiScoreMenu = highScoremenu_resource.instance()
	gameObjects.add_child(hiScoreMenu)
	
	
	
	hiScoreMenu.connect("back",self,"_on_back", ["HighscoreMenu"])
	
	
	hiScoreMenu.init(stats,nameIOHandler)
	
func _on_options_menu():
	
	playMainMenuMusic()
	
	if not muteNextScreenMenuSoundFlag:
		playMenuSelectSound()
		
	muteNextScreenMenuSoundFlag = false
	
	freeGameObjects()
	
	# Add the next level
	var optionsMenu_resource = preload("res://interface/main-menu/OptionsMenu.tscn")
	var optionsMenu = optionsMenu_resource.instance()
	gameObjects.add_child(optionsMenu)
	
	optionsMenu.connectToMenuButtons(self,"_on_options_menu_button_confirmation")
	optionsMenu.connect("back",self,"_on_main_menu")
	


func initPlayer1(player,
				majorProf1Ix,minorProf1Ix,
				majorProf2Ix,minorProf2Ix
				,playerName,heroName):
	player.inputDeviceId = GLOBALS.PLAYER1_INPUT_DEVICE_ID
	player.hitBoxLayer = 1 << GLOBALS.PLAYER_1_HITBOX_LAYER_BIT #player 1 hitbox is on this layer
	player.hitBoxMask =  1 << GLOBALS.PLAYER_2_HITBOX_LAYER_BIT # player 1 hitboxes scan for player 2 hitboxes
	
	
	
	#note that the below isn't done for hurtboxes, since no such thing as hurtbox hurtbox collision
	player.hitBoxMask = player.hitBoxMask | (1 << GLOBALS.PLAYER_2_HURTBOX_LAYER_BIT)#also have player 1 hitboxes scan for hurtboxes of player 2
	player.hurtBoxLayer = 1 << GLOBALS.PLAYER_1_HURTBOX_LAYER_BIT
	
	
	player.selfHitBoxLayer = 1 << GLOBALS.PLAYER_1_SELF_ONLY_HITBOX_LAYER_BIT #player 1 SELF-ONLY hitbox is on this layer
	player.selfHitBoxMask = 1 << GLOBALS.PLAYER_1_SELF_ONLY_HURTBOX_LAYER_BIT#PLAYER 1 CAN HIT HIIMSELF (TYPICALLY PROJECTILE - PLAYER INTEREACTION)
	player.selfHurtBoxLayer = 1 << GLOBALS.PLAYER_1_SELF_ONLY_HURTBOX_LAYER_BIT
	player.proximityGuardMask = 1 << GLOBALS.PLAYER_2_HURTBOX_LAYER_BIT


	player.standardLightingMaskBit = GLOBALS.PLAYER_1_STANDARD_LIGHTING_EFFECTS_MASK_BIT
	player.abilityCancelLightingMaskBit = GLOBALS.PLAYER_1_ABILITY_CANCEL_LIGHTING_EFFECTS_MASK_BIT
	
	
	#plyaer body box on this layer
	player.collision_layer = 1 << GLOBALS.PLAYER1_PUSHABLE_BODYBOX_LAYER_BIT
	player.collision_layer = player.collision_layer | (1 << GLOBALS.PLAYER1_BODYBOX_LAYER_BIT) #so ray casts can detect disable (non pushable) body boxes
	#player.pushableBodyBoxLayerBit = GLOBALS.PLAYER1_PUSHABLE_BODYBOX_LAYER_BIT
	player.bodyBoxCollisionBit = GLOBALS.PLAYER1_BODYBOX_LAYER_BIT
	player.opponentBodyBoxCollisionBit = GLOBALS.PLAYER2_BODYBOX_LAYER_BIT
	#the false wall collision bit
	player.falseWallCollisionBit=GLOBALS.PLAYER1_FALSE_WALL_STAGE_COLLISION_LAYER_BIT
	player.stageCollisionBit=GLOBALS.PLAYER1_STAGE_COLLISION_LAYER_BIT
	player.stageFloorCollisionBit=GLOBALS.PLAYER1_STAGE_FLOOR_COLLISION_LAYER_BIT
	
	
	
	#we are looking for body box collisions with stage, or player 2
	player.collision_mask = 1 << GLOBALS.PLAYER1_STAGE_COLLISION_LAYER_BIT
	player.collision_mask = player.collision_mask | (1 << GLOBALS.PLAYER1_STAGE_FLOOR_COLLISION_LAYER_BIT)
	player.collision_mask = player.collision_mask | (1 << GLOBALS.PLAYER1_FALSE_WALL_STAGE_COLLISION_LAYER_BIT)
	player.collision_mask = player.collision_mask | (1 << GLOBALS.PLAYER1_FALSE_CEILING_STAGE_COLLISION_LAYER_BIT)
	player.collision_mask = player.collision_mask | (1 << GLOBALS.PLAYER2_PUSHABLE_BODYBOX_LAYER_BIT)
	
	player.facingRight = true
	
	#give a reference to the bit layer for body box of player 2
	player.opponentPushableBodyBoxCollisionBit = GLOBALS.PLAYER2_PUSHABLE_BODYBOX_LAYER_BIT
	player.pushableBodyBoxCollisionBit = GLOBALS.PLAYER1_PUSHABLE_BODYBOX_LAYER_BIT
			
	
	#initPlayer(player,padvProf,pdisProf,playerName,heroName)
	initPlayer(player,
				majorProf1Ix,minorProf1Ix,
				majorProf2Ix,minorProf2Ix
				,playerName,heroName)
	

#func initPlayer2(player,padvProf,pdisProf,playerName,heroName):
func initPlayer2(player,
				majorProf1Ix,minorProf1Ix,
				majorProf2Ix,minorProf2Ix
				,playerName,heroName):
	player.inputDeviceId = GLOBALS.PLAYER2_INPUT_DEVICE_ID
	#player.hitBoxLayer = 1 << 14
	player.hitBoxLayer = 1 << GLOBALS.PLAYER_2_HITBOX_LAYER_BIT #player 2 hitboxes are on this layer
	player.hitBoxMask =  1 << GLOBALS.PLAYER_1_HITBOX_LAYER_BIT #scan for player 1 hitboxes
	
	
	player.standardLightingMaskBit = GLOBALS.PLAYER_2_STANDARD_LIGHTING_EFFECTS_MASK_BIT
	player.abilityCancelLightingMaskBit = GLOBALS.PLAYER_2_ABILITY_CANCEL_LIGHTING_EFFECTS_MASK_BIT
	
	#player.hitBoxMask = player.hitBoxMask | (1 << 13)
	#note that the below isn't done for hurtboxes, since no such thing as hurtbox hurtbox collision
	player.hitBoxMask = player.hitBoxMask | (1 << GLOBALS.PLAYER_1_HURTBOX_LAYER_BIT) #also have player 2 hitboxes scan for hurtboxes of player 1
	#player.hurtBoxLayer = 1 << 15
	player.hurtBoxLayer = 1 << GLOBALS.PLAYER_2_HURTBOX_LAYER_BIT
	

	player.selfHitBoxLayer = 1 << GLOBALS.PLAYER_2_SELF_ONLY_HITBOX_LAYER_BIT #player 2 SELF-ONLY hitbox is on this layer
	player.selfHitBoxMask = 1 << GLOBALS.PLAYER_2_SELF_ONLY_HURTBOX_LAYER_BIT#PLAYER 2 CAN HIT HIIMSELF (TYPICALLY PROJECTILE - PLAYER INTEREACTION)
	player.selfHurtBoxLayer = 1 << GLOBALS.PLAYER_2_SELF_ONLY_HURTBOX_LAYER_BIT
	player.proximityGuardMask = 1 << GLOBALS.PLAYER_1_HURTBOX_LAYER_BIT
	
	player.facingRight = false
	
	#plyaer body box on this layer
	player.collision_layer =  1 << GLOBALS.PLAYER2_PUSHABLE_BODYBOX_LAYER_BIT
	player.collision_layer = player.collision_layer | (1 << GLOBALS.PLAYER2_BODYBOX_LAYER_BIT) #so ray casts can detect disable (non pushable) body boxes
	#player.pushableBodyBoxLayerBit = GLOBALS.PLAYER2_PUSHABLE_BODYBOX_LAYER_BIT
	player.bodyBoxCollisionBit = GLOBALS.PLAYER2_BODYBOX_LAYER_BIT
	player.opponentBodyBoxCollisionBit = GLOBALS.PLAYER1_BODYBOX_LAYER_BIT
	#the false wall collision bit
	player.falseWallCollisionBit=GLOBALS.PLAYER2_FALSE_WALL_STAGE_COLLISION_LAYER_BIT
	player.stageCollisionBit=GLOBALS.PLAYER2_STAGE_COLLISION_LAYER_BIT
	player.stageFloorCollisionBit=GLOBALS.PLAYER2_STAGE_FLOOR_COLLISION_LAYER_BIT
	
	#we are looking for body box collisions with stage, or player 1
	player.collision_mask = 1 << GLOBALS.PLAYER2_STAGE_COLLISION_LAYER_BIT
	player.collision_mask = player.collision_mask | (1 << GLOBALS.PLAYER2_STAGE_FLOOR_COLLISION_LAYER_BIT)
	player.collision_mask = player.collision_mask | (1 << GLOBALS.PLAYER2_FALSE_WALL_STAGE_COLLISION_LAYER_BIT)
	player.collision_mask = player.collision_mask | (1 << GLOBALS.PLAYER2_FALSE_CEILING_STAGE_COLLISION_LAYER_BIT)
	player.collision_mask = player.collision_mask | (1 << GLOBALS.PLAYER1_PUSHABLE_BODYBOX_LAYER_BIT)
	
	#give a reference to the bit layer for body box of player 1
	player.opponentPushableBodyBoxCollisionBit = GLOBALS.PLAYER1_PUSHABLE_BODYBOX_LAYER_BIT
	player.pushableBodyBoxCollisionBit = GLOBALS.PLAYER2_PUSHABLE_BODYBOX_LAYER_BIT


	#initPlayer(player,padvProf,pdisProf,playerName,heroName)
	initPlayer(player,
				majorProf1Ix,minorProf1Ix,
				majorProf2Ix,minorProf2Ix
				,playerName,heroName)
	
	
#func initPlayer(player,padvProf,pdisProf,playerName,heroName):
func initPlayer(player,
				majorProf1Ix,minorProf1Ix,
				majorProf2Ix,minorProf2Ix,
				playerName,heroName):


	
#	if ((padvProf == GLOBALS.Proficiency.NONE) and (pdisProf != GLOBALS.Proficiency.NONE) ) or  ((padvProf != GLOBALS.Proficiency.NONE) and (pdisProf == GLOBALS.Proficiency.NONE) ):
#		print("warning: in proficiency selection, one of the proficienies is 'no proficiency' but the other isn't")
	
	#player.advProf=padvProf
	#player.disProf=pdisProf
	
	player.majorProf1Ix=majorProf1Ix
	player.minorProf1Ix=minorProf1Ix
	player.majorProf2Ix=majorProf2Ix
	player.minorProf2Ix=minorProf2Ix
	
	player.hp = int(settings.getValue(settings.TEMP_USER_SETTINGS_SECTION,settings.HP_KEY))
	
	player.profGuardRegenAmountOnPerfectBlock = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.GUARD_REGEN_FROM_PERFECT_BLOCK_PROF_KEY))	
	player.loseGuardHPWhileWalkingBack = bool(settings.getValue(settings.TEMP_USER_SETTINGS_SECTION,settings.LOSE_GUARD_HP_WHILE_MOVING_BACK_FLAG_KEY))
	player.gainBarOnGuardBreak = bool(settings.getValue(settings.TEMP_USER_SETTINGS_SECTION,settings.GAIN_BAR_ON_GUARD_BREAK_FLAG_KEY))
	player.numBarChunksGainedFromGuardBreak = int(settings.getValue(settings.TEMP_USER_SETTINGS_SECTION,settings.BAR_GAIN_FROM_GUARD_BREAK_KEY))
	
	
	player.defaultGuardDamageDealtModVsAirOpponent = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.DEFAULT_BONUS_GUARD_DAMAGE_VS_AIR_OPPONENT_KEY))
	player.autoRipostAbilityBarCost = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.AUTO_RIPOST_BAR_COST_NO_PROF_KEY))	
	player.autoAbilityCancelBaseCost = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.AUTO_ABILITY_CANCEL_COST_NOPROF_KEY))
	player.guardHpRegenRate = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.GUARD_HP_REGEN_RATE_PER_SECOND_NO_PROF_KEY))
	player.numAbChunksGainOnComboLvl = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.COMBO_LEVEL_ABILITY_INCREASE_NOPROF_KEY))
	player.ripostingAbilityBarCost =  int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.RIPOSTING_ABILITY_BAR_COST_NOPROF_KEY))#2 #chosts 2 chunks to ripost
	player.counterRipostingAbilityBarCost =  int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.COUNTER_RIPOSTING_ABILITY_BAR_COST_NOPROF_KEY))#2 #chosts 2 chunks to ripos		
	player.techAbilityBarCost = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.TECH_ABILITY_BAR_COST_NO_PROF_KEY))#3
	player.maxGuardHP=float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.MAX_GUARD_NO_PROF_HP_KEY))	
	player.guardHP=float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.DEFAULT_GUARD_NO_PROF_HP_KEY))	
	player.pushBlockCost = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.PUSH_BLOCK_BAR_COST_NO_PROF_KEY))
	player.profAbilityBarComboProrationMod = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.ABILITY_CANCEL_COMBO_PRORATION_MOD_NOPROF_KEY))
	player.profAbilityBarCostMod = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.ABILITY_BAR_CANCEL_COST_MOD_NOPROF_KEY))

	player.numJumps=int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.NUMBER_OF_JUMPS_KEY))#2
	
	player.acroABCancelExtraJumpBarCost=int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.ACROBATICS_ABILITY_CANCEL_EXTRA_JUMP_BAR_COST_KEY))


	#old no proficiency settings coopy pasted due to lazyness. TODO, figure out which one is NOT USED
	
	player.profAbilityBarComboLvlProrationMod = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.ABILITY_CANCEL_COMBO_LVL_PRORATION_MOD_NOPROF_KEY))
	player.histunAbilityCancelProrationReductionRate=float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.ABILITY_CANCEL_HITSTUN_PRORATION_MOD_NOPROF_KEY))
	
	player.abCancel_SpamProrationSetback= int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.ABILITY_CANCEL_SPAM_HITSTUN_PRORATION_SETBACK_KEY))
	
	#player.jumpSpeedMod=float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.JUMP_SPEED_MOD_NO_PROF_KEY))
	#player.airDashSpeedMod=float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.AIR_DASH_SPEED_MOD_NO_PROF_KEY))
	#player.groundDashSpeedMod=float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.GROUND_DASH_SPEED_MOD_NO_PROF_KEY))
	#player.numJumps = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.NUM_JUMPS_NO_PROF_KEY))
	player.numJumpsGainedFromAbCancel = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.NUM_JUMPS_RECOVERED_FROM_ABILITY_CANCEL_NO_PROF_KEY))
	player.recoverAirDashOnJump = bool(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.GET_BACK_DASH_ON_JUMP_NO_PROF_KEY))
	player.recoverAirDashOnHit = bool(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.RECOVER_AIR_DASH_ON_HIT_NO_PROF_KEY))		
	player.regenGuardInAir = bool(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.REGEN_GUARD_IN_AIR_NO_PROF_KEY))
	player.recoverJumpOnAirBlock = bool(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.RECOVER_DASH_JUMP_FROM_AIR_BLOCK_NO_PROF_KEY))	

	player.halfHPAbilityIncreaseThreshold = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.NUMBER_CHUNKS_GAIN_THRESHOLD_ON_HALF_HP_KEY))
	
	player.guardHpLossRate = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.GUARD_HP_HOLD_BACK_REDUCE_RATE_PER_SECOND_NO_PROF_KEY))
	
	#riposting
	player.ripostDamage = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.RIPOST_DAMAGE_NOPROF_KEY))#80
	player.damageGaugeFailedRipostModIncrease = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.DAMAGE_GUAGE_FAILED_RIPOST_MOD_INCREASE_NOPROF_KEY))#0.2
	player.focusFailedRipostModIncrease=float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.FOCUS_FAILED_RIPOST_MOD_INCREASE_NOPROF_KEY))#0.2
#		player.ripostingAbilityBarCost =  int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.RIPOSTING_ABILITY_BAR_COST_NOPROF_KEY))#2 #chosts 2 chunks to ripost
	
	player.onRipostingDmgIncreaseRatio = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.ON_RIPOST_DMG_AMOUNT_INCREASE_RATIO_NOPROF_KEY))
	player.onRipostingBarReduceAmount = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.ON_RIPOST_BAR_REDUCE_AMOUNT_NOPROF_KEY))
	player.faildRipostBarGainLockTimeSecs = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.FAILED_RIPOST_BAR_GAIN_LOCK_DURATION_NOPROF_KEY))
	player.faildRipostBarGainLockNumHits = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.FAILED_RIPOST_BAR_GAIN_LOCK_MIN_NUM_HIT_NOPROF_KEY))
	
	
	player.damageGaugeComboLevelUpModIncrease = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings. DAMAGE_GUAGE_COMBO_LEVELUP_MOD_INCREASE_NOPROF_KEY))#0.2
	player.damageGaugeRateMode = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.DAMAGE_GUAGE_RATE_MOD_NOPROF_KEY))#0.2 # each combo level increase damage by 20% of combo level
	player.focusComboLevelUpModIncrease = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.FOCUS_COMBO_LEVELUP_MOD_INCREASE_NOPROF_KEY))#0.3
	player.focusRateMode = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.FOCUS_RATE_MOD_NOPROF_KEY))#0.2
	player.focusCashInMod = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.FOCUS_CASH_IN_AMOUNT_INCREASE_MOD_NOPROF_KEY))
	player.damageGaugeCashInMod = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.DAMAGE_GUAGE_CASH_IN_AMOUNT_INCREASE_MOD_NOPROF_KEY))
	player.additionalDamagePerStar=float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.DAMAGE_GUAGE_ADDITIONAL_DAMAGE_PER_STAR_NOPROF_KEY))
	#player.correctBlockGuardDamageDealtMod=float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.DAMAGE_PROF_GUARD_BLOCK_AMAGE_MOD_NOPROF_KEY))
	
#		player.autoAbilityCancelBaseCost = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.AUTO_ABILITY_CANCEL_COST_NOPROF_KEY))
#		player.counterRipostingAbilityBarCost =  int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.COUNTER_RIPOSTING_ABILITY_BAR_COST_NOPROF_KEY))#2 #chosts 2 chunks to ripos		
	#player.numAbChunksGainOnComboLvl = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.COMBO_LEVEL_ABILITY_INCREASE_NOPROF_KEY))
	
	
	

	player.playerName = playerName
	player.heroName = heroName
	var abilityBarMaxFrac = float(settings.getValue(settings.TEMP_USER_SETTINGS_SECTION,settings.ABILITY_BAR_SIZE_MOD))
	var actualHP = int(settings.getValue(settings.TEMP_USER_SETTINGS_SECTION,settings.HP_KEY))
	var hpSizeRatio = float(settings.DEFAULT_HP)/float(actualHP) #if player has half as much hp as default, then we have to gain half as much bar by making bar twice as big
	player.abilityBarMaximum = (actualHP * GLOBALS.ABILITY_BAR_TO_MAX_HEALTH_RATIO *hpSizeRatio)/abilityBarMaxFrac
	player.abilityNumberOfChunks = int(settings.getValue(settings.TEMP_USER_SETTINGS_SECTION,settings.ABILITY_BAR_NUMBER_OF_CHUNKS_KEY))
	#player.abilityBar = float(settings.getValue(settings.TEMP_USER_SETTINGS_SECTION,settings.DEFAULT_ABILITY_BAR_KEY))# player.abilityBarMaximum/2
	var numChunksDefault = int(settings.getValue(settings.TEMP_USER_SETTINGS_SECTION,settings.DEFAULT_ABILITY_BAR_KEY))# player.abilityBarMaximum/2
	player.abilityBar = (player.abilityBarMaximum / player.abilityNumberOfChunks)*numChunksDefault
	
	
	#unsued masks
	player.hurtBoxMask = 0 
	player.selfHurtBoxMask = 0
	 
	
	player.incorrectBlockDamageReductionMod=float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.INCORRECT_BLOCK_DAMAGE_REDUCTION_MOD_PROF_KEY))
	player.ripostingPreWindow = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.RIPOSTING_PRE_WINDOW_LENGTH_KEY))#5 #number of frames to preemptively ripost
	#player.ripostingReactWindow = 2 #number of frames to react to ripost
	player.ripostingReactWindow = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.RIPOSTING_REACT_WINDOW_LENGTH_KEY))
	#player.ripostingPreWindow = 180 #number of frames to preemptively ripost
	#player.ripostingReactWindow = 180 #number of frames to react to ripost
	
	#counter ripost window is same size as window to ripost, only
	#you need to technically predict it, not have a smmal window to react
	#like ripost has
	player.counterRipostingPreWindow = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.COUNTER_RIPOSTING_PRE_WINDOW_LENGTH_KEY))#player.ripostingPreWindow + player.ripostingReactWindow
	player.ripostHitstunDuration = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.RIPOSTING_HIT_STUN_DURATION_NUM_FRAMES_KEY))#180 #180 frames  of histun (3 seconds): this should give chance to combo hard
	player.ripostHitFreeze = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.RIPOSTING_HIT_FREEZE_DURATION_NUM_FRAMES_KEY))#12
	
	player.ripostingAbilityBarRegenMod = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.RIPOSTING_ABILITY_BAR_REGEN_MOD_KEY))#0
	player.baseAbilityCancelCost = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.BASE_ABILITY_CANCEL_COST_KEY))#0
	
	#below is debug window
	#player.counterRipostingPreWindow = 180
	player.blockCooldownTime = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.BLOCK_COOLDOWN_DURATION_SECONDS_KEY))#9 #seconds
	player.grabCooldownTime = float(settings.getValue(settings.TEMP_USER_SETTINGS_SECTION,settings.GRAB_COOLDOWN_DURATION_SECONDS_KEY))#9 # seconds
	player.failedBlockDamageDecrease = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.FAILED_BLOCK_DAMAGE_DECREASE_KEY))#0.05
	
	
	player.antiBlockHitstunDuration=int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.ANTIBLOCK_HITSTUN_DURATION_NUM_FRAMES_KEY))#75
	#player.antiBlockDamage = 20 #i dunno what this is, but failed anti block damage is defined in the animation
	player.successfulAntiBlockDmg = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.ANTIBLOCK_SUCESS_DAMAGE_KEY))#65
	player.failedBlockDamageCapacityDecrease = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.FAILED_BLOCK_DAMAGE_CAP_DECREASE_KEY))#0.025
	player.failedBlockFocusDecrease = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.FAILED_BLOCK_FOCUS_DECREASE_KEY))#0.025
	player.failedBlockFocusCapacityDecrease = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.FAILED_BLOCK_FOCUS_CAP_DECREASE_KEY))#0.025


	player.failedTechAbilityBarCost = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.FAILED_TECH_ABILITY_BAR_COST_KEY))#1
	
	player.reboundingDamageThreshold = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.REBOUND_DAMAGE_THRESHOLD_KEY))# 15
	player.minimumNumberReboundFrames = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.MINIMUM_NUM_REBOUND_FRAMES_KEY))
	player.reboundFramesMod = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.REBOUND_FRAMES_MOD_KEY))
	player.maxNumReboundFramesSameDmg = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.MAXIMUM_NUM_REBOUND_FRAMES_SAME_DAMAGE_KEY))
	
	player.highDamageThreshold = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.HIGH_DAMAGE_THESHOLD_KEY))#2 #x2 damage will make rage smoke appear
	
	
	player.maxDamageGauge =float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.MAX_DAMAGE_GUAGE_KEY)) #5
	player.maxFocus =float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.MAX_FOCUS_KEY))# 5
	
	player.maxNumberWallBounces = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.MAX_NUM_WALL_BOUNCES_BEFORE_FALLING_HITSTUN_KEY))#3
	
	player.defaultBlockEfficiency = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.BLOCK_EFFICIENCY_DEFAULT_KEY))#3 
	player.blockEfficiency =  player.defaultBlockEfficiency
	player.maxBlockEff =  int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.BLOCK_EFFICIENCY_MAX_KEY))#3
	player.minBlockEff =  int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.BLOCK_EFFICIENCY_MIN_KEY))#3
	

	player.boostedBuffGuardRegenMod=float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.AUTO_RIPOST_GUARD_REGEN_BUFF_MOD_KEY))
#	player.autoRipostGuardRegenBuffFillAmount=int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.AUTO_RIPOST_GUARD_REGEN_BUFF_DURATION_KEY))
	player.autoRipostGuardRegenBuffFillAmount=float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.AUTO_RIPOST_GUARD_REGEN_BUFF_FILL_AMOUNT_KEY))
	
	player.enormousBlockChipDamageMod = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.ENORMOUS_BLOCK_CHIP_DAMAGE_MOD_PROF_KEY))
	
	#apply properites of proficiencies
	var props = proficiencyModel.getAllProficiencyBuildProperties(majorProf1Ix,minorProf1Ix,
																	majorProf2Ix,minorProf2Ix)															
	for prop in props:
		
		match(prop.id):
			GLOBALS.ProficiencyPropertyID.GOOD_CAN_LOW_BLOCK_IN_AIR:
				player.canLowBlowInAir=true
			GLOBALS.ProficiencyPropertyID.GOOD_REGENERATE_GUARD_IN_AIR:
				player.regenGuardInAir=true
			GLOBALS.ProficiencyPropertyID.GOOD_GAIN_JUMP_FROM_ABILITY_CANCEL:
				player.numJumpsGainedFromAbCancel=1
			GLOBALS.ProficiencyPropertyID.GOOD_RECOVER_AIR_DASH_ON_BLOCK:
				player.recoverAirDashOnAirBlock=true	
			GLOBALS.ProficiencyPropertyID.BAD_LOSE_AIR_DASH_AND_JUMP_ON_BLOCK:
				player.loseJumpAndAirDashOnAirBlock=true
				player.recoverJumpOnAirBlock = false
			GLOBALS.ProficiencyPropertyID.GOOD_RECOVER_AIR_DASH_ON_HIT:
				player.recoverAirDashOnHit=true
			GLOBALS.ProficiencyPropertyID.GOOD_RECOVER_AIR_DASH_AND_JUMP_ON_TECH:
				player.recoverAirDashAndJumpOnAirTech=true
			GLOBALS.ProficiencyPropertyID.GOOD_PERFECT_BLOCK_ABILITY_BAR_REGEN:
				player.regenAbilityBarOnPerfectBlock=true				
			GLOBALS.ProficiencyPropertyID.BAD_ONLY_1_JUMP:
				player.numJumps=1
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_BAR_GAIN_BY_GRABBING_AUTORIPOSTER:
				player.barChunksGainedOnGrabbingAutoriposter=1
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_BAR_GAIN_BY_GRABBING_AUTORIPOSTER:
				player.regenAbilityBarOnPerfectBlock=3
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_BAR_GAIN_BY_GRABBING_AUTORIPOSTER:
				player.regenAbilityBarOnPerfectBlock=5
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_GRAB_WHIF_PROVOKES_COOLDOWN:
				player.whiffedGrabProvokesCooldown=true
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_AIR_ANIMATION_AND_LANDING_LAG_CANCEL_COST_INCREASE:
				player.airAbilityCancelCostInChunksTax=1
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_AIR_ANIMATION_AND_LANDING_LAG_CANCEL_COST_INCREASE:
				player.airAbilityCancelCostInChunksTax=2
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_AIR_ANIMATION_AND_LANDING_LAG_CANCEL_COST_INCREASE:
				player.airAbilityCancelCostInChunksTax=3
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_NO_AIR_DASHING:
				player.preventAirDashing=true
			GLOBALS.ProficiencyPropertyID.BAD_DONT_RECOVER_AIR_DASH_FROM_JUMPING:
				player.recoverAirDashOnJump=false
			GLOBALS.ProficiencyPropertyID.BAD_CANT_DI_TECH:
				player.preventDITech=true
			GLOBALS.ProficiencyPropertyID.BAD_TAKE_TRIPLE_DAMAGE_IN_STUN:
				player.tripleDmgVulnInStun=true
			GLOBALS.ProficiencyPropertyID.BAD_CANT_GRAB_WHILE_IN_AIR:
				player.preventGrabInAir=true
			GLOBALS.ProficiencyPropertyID.BAD_ABILITY_CANCELING_NO_RESET_STALE_MOVES:
				player.preventAbilityCancelStaleMoveReset=true
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_BAR_GAIN_FROM_GUARD_BREAK:
				player.additionalBarGainFromBreakingGuard=  player.additionalBarGainFromBreakingGuard  - 1 #1 less chunk
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_BAR_GAIN_FROM_GUARD_BREAK:
				player.additionalBarGainFromBreakingGuard=  player.additionalBarGainFromBreakingGuard  - 2 #3 less chunk
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_BAR_GAIN_FROM_GUARD_BREAK:
				player.additionalBarGainFromBreakingGuard=  player.additionalBarGainFromBreakingGuard  - 3 #3 less chunk
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_BAR_GAIN_FROM_GUARD_BREAK:
				player.additionalBarGainFromBreakingGuard=  player.additionalBarGainFromBreakingGuard  + 1 #1 more chunk gained
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_BAR_GAIN_FROM_GUARD_BREAK:
				player.additionalBarGainFromBreakingGuard=  player.additionalBarGainFromBreakingGuard  + 2 #2 more chunk gained
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_BAR_GAIN_FROM_GUARD_BREAK:
				player.additionalBarGainFromBreakingGuard=  player.additionalBarGainFromBreakingGuard  + 3 #3 more chunk gained
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_BAR_FEED_FROM_GUARD_BREAK:
				player.additionalBarFeedFromGettingGuardBroken= player.additionalBarFeedFromGettingGuardBroken + 1 #feed 1 more chunk to opponent from guard break
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCCREASE_TO_BAR_FEED_FROM_GUARD_BREAK:
				player.additionalBarFeedFromGettingGuardBroken= player.additionalBarFeedFromGettingGuardBroken + 2 #feed 2 more chunk to opponent from guard break
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCCREASE_TO_BAR_FEED_FROM_GUARD_BREAK:
				player.additionalBarFeedFromGettingGuardBroken= player.additionalBarFeedFromGettingGuardBroken + 3 #feed 2 more chunk to opponent from guard break
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_BAR_FEED_FROM_GUARD_BREAK:
				player.additionalBarFeedFromGettingGuardBroken= player.additionalBarFeedFromGettingGuardBroken - 1 #feed 1 less chunk to opponent from guard break
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_BAR_FEED_FROM_GUARD_BREAK:
				player.additionalBarFeedFromGettingGuardBroken= player.additionalBarFeedFromGettingGuardBroken - 2 #feed 1 less chunk to opponent from guard break
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_BAR_FEED_FROM_GUARD_BREAK:
				player.additionalBarFeedFromGettingGuardBroken= player.additionalBarFeedFromGettingGuardBroken - 3 #feed 1 less chunk to opponent from guard break
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_AUTO_RIPOSTE_COST:
				player.autoRipostAbilityBarCost=player.autoRipostAbilityBarCost + 1 #auto ripost costs 1 more
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_AUTO_RIPOSTE_COST:
				player.autoRipostAbilityBarCost=player.autoRipostAbilityBarCost + 2
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_AUTO_RIPOSTE_COST:
				player.autoRipostAbilityBarCost=player.autoRipostAbilityBarCost + 4
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_AUTO_RIPOSTE_COST:
				player.autoRipostAbilityBarCost=max(player.autoRipostAbilityBarCost - 1,1) #auto ripost costs 1 less (minimum 1)
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_AUTO_RIPOSTE_COST:
				player.autoRipostAbilityBarCost=max(player.autoRipostAbilityBarCost - 2,1) 
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_AUTO_RIPOSTE_COST:
				player.autoRipostAbilityBarCost=max(player.autoRipostAbilityBarCost - 4,1) 
			#--------------------------------------------------------------------------------			
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_AUTO_ABILITY_CANCEL_COST:
				player.autoAbilityCancelBaseCost=player.autoAbilityCancelBaseCost + 1 #auto ability canceling costs 1 more
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_AUTO_ABILITY_CANCEL_COST:
				player.autoAbilityCancelBaseCost=player.autoAbilityCancelBaseCost + 2
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_AUTO_ABILITY_CANCEL_COST:
				player.autoAbilityCancelBaseCost=player.autoAbilityCancelBaseCost + 4
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_AUTO_ABILITY_CANCEL_COST:
				player.autoAbilityCancelBaseCost=player.autoAbilityCancelBaseCost -1#auto ability canceling costs 1 less
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_AUTO_ABILITY_CANCEL_COST:
				player.autoAbilityCancelBaseCost=player.autoAbilityCancelBaseCost -2
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_AUTO_ABILITY_CANCEL_COST:
				player.autoAbilityCancelBaseCost=player.autoAbilityCancelBaseCost -4
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_GUARD_DAMAGE_DEALT:
				 #5% less guard damag to any type of block (correct or incorrect)
				player.incorrectBlockGuardDamageDealtMod=player.incorrectBlockGuardDamageDealtMod-0.05
				player.correctBlockGuardDamageDealtMod=player.correctBlockGuardDamageDealtMod - 0.05
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_GUARD_DAMAGE_DEALT:
				#-10%
				player.incorrectBlockGuardDamageDealtMod=player.incorrectBlockGuardDamageDealtMod-0.10
				player.correctBlockGuardDamageDealtMod=player.correctBlockGuardDamageDealtMod - 0.10
				
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_GUARD_DAMAGE_DEALT:
				#-15%
				player.incorrectBlockGuardDamageDealtMod=player.incorrectBlockGuardDamageDealtMod-0.15
				player.correctBlockGuardDamageDealtMod=player.correctBlockGuardDamageDealtMod - 0.15
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_GUARD_DAMAGE_DEALT:
				#5 % more damage to any type of block
				player.incorrectBlockGuardDamageDealtMod=player.incorrectBlockGuardDamageDealtMod+0.05
				player.correctBlockGuardDamageDealtMod=player.correctBlockGuardDamageDealtMod + 0.05
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_GUARD_DAMAGE_DEALT:
				#+10%
				player.incorrectBlockGuardDamageDealtMod=player.incorrectBlockGuardDamageDealtMod+0.1
				player.correctBlockGuardDamageDealtMod=player.correctBlockGuardDamageDealtMod + 0.1
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_GUARD_DAMAGE_DEALT:
				#+15%
				player.incorrectBlockGuardDamageDealtMod=player.incorrectBlockGuardDamageDealtMod+0.15
				player.correctBlockGuardDamageDealtMod=player.correctBlockGuardDamageDealtMod + 0.15
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT:
				 #5% less guard damage to correct block				
				player.correctBlockGuardDamageDealtMod=player.correctBlockGuardDamageDealtMod - 0.05
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT:
				#-10%
				player.correctBlockGuardDamageDealtMod=player.correctBlockGuardDamageDealtMod - 0.10				
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT:
				#-15%
				player.correctBlockGuardDamageDealtMod=player.correctBlockGuardDamageDealtMod - 0.15
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT:
				#5 % more damage to correct blocks
				player.correctBlockGuardDamageDealtMod=player.correctBlockGuardDamageDealtMod + 0.05
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT:
				#+10%
				player.correctBlockGuardDamageDealtMod=player.correctBlockGuardDamageDealtMod + 0.1
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT:
				#+15%
				player.correctBlockGuardDamageDealtMod=player.correctBlockGuardDamageDealtMod + 0.15
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT:
				 #5% less guard damage to incorrect block				
				player.incorrectBlockGuardDamageDealtMod=player.incorrectBlockGuardDamageDealtMod - 0.05
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT:
				#-10%
				player.incorrectBlockGuardDamageDealtMod=player.incorrectBlockGuardDamageDealtMod - 0.10				
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT:
				#-15%
				player.incorrectBlockGuardDamageDealtMod=player.incorrectBlockGuardDamageDealtMod - 0.15
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT:
				#5 % more damage to incorrect blocks
				player.incorrectBlockGuardDamageDealtMod=player.incorrectBlockGuardDamageDealtMod + 0.05
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT:
				#+10%
				player.incorrectBlockGuardDamageDealtMod=player.incorrectBlockGuardDamageDealtMod + 0.15
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT:
				#+15%
				player.incorrectBlockGuardDamageDealtMod=player.incorrectBlockGuardDamageDealtMod + 0.18
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_GUARD_DAMAGE_TAKEN:
				 #5% more guard damag taken any type of block (correct or incorrect)
				player.incorrectBlockGuardDamageTakenMod=player.incorrectBlockGuardDamageTakenMod+0.05
				player.correctBlockGuardDamageTakenMod=player.correctBlockGuardDamageTakenMod + 0.05
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_GUARD_DAMAGE_TAKEN:
				#10%
				player.incorrectBlockGuardDamageTakenMod=player.incorrectBlockGuardDamageTakenMod+0.10
				player.correctBlockGuardDamageTakenMod=player.correctBlockGuardDamageTakenMod + 0.10
				
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_GUARD_DAMAGE_TAKEN:
				#15%
				player.incorrectBlockGuardDamageTakenMod=player.incorrectBlockGuardDamageTakenMod+0.15
				player.correctBlockGuardDamageTakenMod=player.correctBlockGuardDamageTakenMod + 0.15
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_GUARD_DAMAGE_TAKEN:
				#5 % less damage to any type of block taken
				player.incorrectBlockGuardDamageTakenMod=player.incorrectBlockGuardDamageTakenMod-0.05
				player.correctBlockGuardDamageTakenMod=player.correctBlockGuardDamageTakenMod - 0.05
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_GUARD_DAMAGE_TAKEN:
				#-10%
				player.incorrectBlockGuardDamageTakenMod=player.incorrectBlockGuardDamageTakenMod-0.1
				player.correctBlockGuardDamageTakenMod=player.correctBlockGuardDamageTakenMod - 0.1
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_GUARD_DAMAGE_TAKEN:
				#-15%
				player.incorrectBlockGuardDamageTakenMod=player.incorrectBlockGuardDamageTakenMod-0.15
				player.correctBlockGuardDamageTakenMod=player.correctBlockGuardDamageTakenMod - 0.15
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN:
				 #5% more guard damag taken any type of correct block 				
				player.correctBlockGuardDamageTakenMod=player.correctBlockGuardDamageTakenMod + 0.05
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN:				
				player.correctBlockGuardDamageTakenMod=player.correctBlockGuardDamageTakenMod + 0.10				
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN:			
				player.correctBlockGuardDamageTakenMod=player.correctBlockGuardDamageTakenMod + 0.15
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN:		
				player.correctBlockGuardDamageTakenMod=player.correctBlockGuardDamageTakenMod - 0.05
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN:				
				player.correctBlockGuardDamageTakenMod=player.correctBlockGuardDamageTakenMod - 0.15
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN:
				player.correctBlockGuardDamageTakenMod=player.correctBlockGuardDamageTakenMod - 0.18				
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN:
				player.incorrectBlockGuardDamageTakenMod=player.incorrectBlockGuardDamageTakenMod + 0.05
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN:				
				player.incorrectBlockGuardDamageTakenMod=player.incorrectBlockGuardDamageTakenMod + 0.10				
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN:				
				player.incorrectBlockGuardDamageTakenMod=player.incorrectBlockGuardDamageTakenMod + 0.15
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN:
				player.incorrectBlockGuardDamageTakenMod=player.incorrectBlockGuardDamageTakenMod - 0.05
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN:				
				player.incorrectBlockGuardDamageTakenMod=player.incorrectBlockGuardDamageTakenMod - 0.10
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN:				
				player.incorrectBlockGuardDamageTakenMod=player.incorrectBlockGuardDamageTakenMod - 0.15
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT:
				player.airBlockGuardDamageDealtMod=player.airBlockGuardDamageDealtMod - 0.05
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT:				
				player.airBlockGuardDamageDealtMod=player.airBlockGuardDamageDealtMod - 0.1
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT:				
				player.airBlockGuardDamageDealtMod=player.airBlockGuardDamageDealtMod - 0.15
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT:
				player.airBlockGuardDamageDealtMod=player.airBlockGuardDamageDealtMod + 0.05
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT:				
				player.airBlockGuardDamageDealtMod=player.airBlockGuardDamageDealtMod + 0.15
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT:				
				player.airBlockGuardDamageDealtMod=player.airBlockGuardDamageDealtMod + 0.18
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR:
				player.airBlockGuardDamageTakenMod=player.airBlockGuardDamageTakenMod + 0.05
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR:				
				player.airBlockGuardDamageTakenMod=player.airBlockGuardDamageTakenMod + 0.1
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR:				
				player.airBlockGuardDamageTakenMod=player.airBlockGuardDamageTakenMod + 0.15
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR:
				player.airBlockGuardDamageTakenMod=player.airBlockGuardDamageTakenMod - 0.05
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR:				
				player.airBlockGuardDamageTakenMod=player.airBlockGuardDamageTakenMod - 0.15
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR:				
				player.airBlockGuardDamageTakenMod=player.airBlockGuardDamageTakenMod - 0.18
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_BLOCK_CHIP_DAMAGE_DEALT:
				player.blockChipDamageDealtMod=player.blockChipDamageDealtMod - 0.15
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_BLOCK_CHIP_DAMAGE_DEALT:				
				player.blockChipDamageDealtMod=player.blockChipDamageDealtMod - 0.25
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_BLOCK_CHIP_DAMAGE_DEALT:				
				player.blockChipDamageDealtMod=player.blockChipDamageDealtMod - 0.5
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_BLOCK_CHIP_DAMAGE_DEALT:
				player.blockChipDamageDealtMod=player.blockChipDamageDealtMod + 0.15
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_BLOCK_CHIP_DAMAGE_DEALT:				
				player.blockChipDamageDealtMod=player.blockChipDamageDealtMod + 0.25
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_BLOCK_CHIP_DAMAGE_DEALT:				
				player.blockChipDamageDealtMod=player.blockChipDamageDealtMod + 0.5
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN:
				player.blockChipDamageTakenMod=player.blockChipDamageTakenMod - 0.15
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN:				
				player.blockChipDamageTakenMod=player.blockChipDamageTakenMod - 0.25
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN:				
				player.blockChipDamageTakenMod=player.blockChipDamageTakenMod - 0.5
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN:
				player.blockChipDamageTakenMod=player.blockChipDamageTakenMod + 0.15
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN:				
				player.blockChipDamageTakenMod=player.blockChipDamageTakenMod + 0.25
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN:				
				player.blockChipDamageTakenMod=player.blockChipDamageTakenMod + 0.5
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_GUARD_REGEN_RATE:
				player.guardHpRegenRate=player.guardHpRegenRate - 0.08
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_GUARD_REGEN_RATE:				
				player.guardHpRegenRate=player.guardHpRegenRate - 0.15
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_GUARD_REGEN_RATE:				
				player.guardHpRegenRate=player.guardHpRegenRate - 0.225
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_GUARD_REGEN_RATE:
				player.guardHpRegenRate=player.guardHpRegenRate + 0.08
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_GUARD_REGEN_RATE:				
				player.guardHpRegenRate=player.guardHpRegenRate + 0.15
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_GUARD_REGEN_RATE:				
				player.guardHpRegenRate=player.guardHpRegenRate + 0.225
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES:
				player.numAbChunksGainOnComboLvl=max(0.5,player.numAbChunksGainOnComboLvl-0.5)
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES:				
				player.numAbChunksGainOnComboLvl=max(0.5,player.numAbChunksGainOnComboLvl-1)
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES:				
				player.numAbChunksGainOnComboLvl=max(0.5,player.numAbChunksGainOnComboLvl-1.5)
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES:
				player.numAbChunksGainOnComboLvl=player.numAbChunksGainOnComboLvl+0.5
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES:				
				player.numAbChunksGainOnComboLvl=player.numAbChunksGainOnComboLvl+1
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES:				
				player.numAbChunksGainOnComboLvl=player.numAbChunksGainOnComboLvl+1.5
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_RIPOST_COST:
				player.ripostingAbilityBarCost= player.ripostingAbilityBarCost + 1
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_RIPOST_COST:				
				player.ripostingAbilityBarCost= player.ripostingAbilityBarCost + 2
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_RIPOST_COST:				
				player.ripostingAbilityBarCost= player.ripostingAbilityBarCost + 3
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_RIPOST_COST:
				player.ripostingAbilityBarCost= max(1,player.ripostingAbilityBarCost - 1)
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_RIPOST_COST:				
				player.ripostingAbilityBarCost= max(1,player.ripostingAbilityBarCost - 2)
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_RIPOST_COST:				
				player.ripostingAbilityBarCost= max(1,player.ripostingAbilityBarCost - 3)
		#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_COUNTERRIPOST_COST:
				player.counterRipostingAbilityBarCost= player.counterRipostingAbilityBarCost + 1
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_COUNTERRIPOST_COST:				
				player.counterRipostingAbilityBarCost= player.counterRipostingAbilityBarCost + 2
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_COUNTERRIPOST_COST:				
				player.counterRipostingAbilityBarCost= player.counterRipostingAbilityBarCost + 3
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_COUNTERRIPOST_COST:
				player.counterRipostingAbilityBarCost= max(1,player.counterRipostingAbilityBarCost - 1)
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_COUNTERRIPOST_COST:				
				player.counterRipostingAbilityBarCost= max(1,player.counterRipostingAbilityBarCost - 2)
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_COUNTERRIPOST_COST:				
				player.counterRipostingAbilityBarCost= max(1,player.counterRipostingAbilityBarCost - 3)
		#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_TECH_COST:
				player.techAbilityBarCost= player.techAbilityBarCost + 1
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_TECH_COST:				
				player.techAbilityBarCost= player.techAbilityBarCost + 2
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_TECH_COST:				
				player.techAbilityBarCost= player.techAbilityBarCost + 3
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_TECH_COST:
				player.techAbilityBarCost= max(1,player.techAbilityBarCost - 1)
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_TECH_COST:				
				player.techAbilityBarCost= max(1,player.techAbilityBarCost - 2)
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_TECH_COST:				
				player.techAbilityBarCost= max(1,player.techAbilityBarCost - 3)
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_PUSH_BLOCK_COST:
				player.pushBlockCost= player.pushBlockCost + 1
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_PUSH_BLOCK_COST:				
				player.pushBlockCost= player.pushBlockCost + 2
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_PUSH_BLOCK_COST:				
				player.pushBlockCost= player.pushBlockCost + 3
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_PUSH_BLOCK_COST:
				player.pushBlockCost= max(1,player.pushBlockCost - 1)
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_PUSH_BLOCK_COST:				
				player.pushBlockCost= max(1,player.pushBlockCost - 2)
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_PUSH_BLOCK_COST:				
				player.pushBlockCost= max(1,player.pushBlockCost - 3)	
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK:
				player.profAbilityBarComboProrationMod= player.profAbilityBarComboProrationMod -0.25
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK:				
				player.profAbilityBarComboProrationMod= player.profAbilityBarComboProrationMod -0.5
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK:				
				player.profAbilityBarComboProrationMod= player.profAbilityBarComboProrationMod -1.0
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK:
				player.profAbilityBarComboProrationMod= player.profAbilityBarComboProrationMod +0.25
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK:				
				player.profAbilityBarComboProrationMod= player.profAbilityBarComboProrationMod +0.5
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK:				
				player.profAbilityBarComboProrationMod= player.profAbilityBarComboProrationMod +1.0
			#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_ABILITY_CANCEL_COST:
				player.profAbilityBarCostMod= player.profAbilityBarCostMod +1
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_ABILITY_CANCEL_COST:				
				player.profAbilityBarCostMod= player.profAbilityBarCostMod +2
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_ABILITY_CANCEL_COST:				
				player.profAbilityBarCostMod= player.profAbilityBarCostMod +3
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_ABILITY_CANCEL_COST:
				player.profAbilityBarCostMod= player.profAbilityBarCostMod -1
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_ABILITY_CANCEL_COST:				
				player.profAbilityBarCostMod= player.profAbilityBarCostMod -2
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_ABILITY_CANCEL_COST:				
				player.profAbilityBarCostMod= player.profAbilityBarCostMod -3
		#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_GRAB_COOLDOWN:
				player.grabCooldownTime= player.grabCooldownTime +1
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_GRAB_COOLDOWN:				
				player.grabCooldownTime= player.grabCooldownTime +1.5
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_GRAB_COOLDOWN:				
				player.grabCooldownTime= player.grabCooldownTime +2
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_GRAB_COOLDOWN:
				player.grabCooldownTime= max(0.25,player.grabCooldownTime -1)
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_GRAB_COOLDOWN:				
				player.grabCooldownTime= max(0.25,player.grabCooldownTime -1.5)
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_GRAB_COOLDOWN:				
				player.grabCooldownTime= max(0.2,player.grabCooldownTime -2)
	#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_COOLDOWN_TO_AIR_GRAB:
				player.additionalCooldownToAirGrab= player.additionalCooldownToAirGrab +1
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_COOLDOWN_TO_AIR_GRAB:				
				player.additionalCooldownToAirGrab= player.additionalCooldownToAirGrab +1.5
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_COOLDOWN_TO_AIR_GRAB:				
				player.additionalCooldownToAirGrab= player.additionalCooldownToAirGrab +2
		#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR:
				player.additionalNumChunksGainMagicSeriesInAir= player.additionalNumChunksGainMagicSeriesInAir-0.5
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR:				
				player.additionalNumChunksGainMagicSeriesInAir= player.additionalNumChunksGainMagicSeriesInAir-1
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR:				
				player.additionalNumChunksGainMagicSeriesInAir= player.additionalNumChunksGainMagicSeriesInAir-1.5
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR:
				player.additionalNumChunksGainMagicSeriesInAir= player.additionalNumChunksGainMagicSeriesInAir+0.5
			GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR:				
				player.additionalNumChunksGainMagicSeriesInAir= player.additionalNumChunksGainMagicSeriesInAir+1
			GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR:				
				player.additionalNumChunksGainMagicSeriesInAir= player.additionalNumChunksGainMagicSeriesInAir+1.5
		#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_BAR_COST_FROM_MISSING_AUTORIPOSTE:
				player.numChunksLostOnMisssedAutoRiposte=player.numChunksLostOnMisssedAutoRiposte+1
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_BAR_COST_FROM_MISSING_AUTORIPOSTE:				
				player.numChunksLostOnMisssedAutoRiposte=player.numChunksLostOnMisssedAutoRiposte+2
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_BAR_COST_FROM_MISSING_AUTORIPOSTE:				
				player.numChunksLostOnMisssedAutoRiposte=player.numChunksLostOnMisssedAutoRiposte+3
		#--------------------------------------------------------------------------------
			GLOBALS.ProficiencyPropertyID.GOOD_GRAB_COOLDOWN_REFRESHED_ON_AUTO_ABILITY_CANCEL:	
				player.recoverGrabOnAutoAbilityCancel=true
			GLOBALS.ProficiencyPropertyID.GOOD_GRAB_COOLDOWN_REFRESHED_ON_ABILITY_CANCEL:	
				player.recoverGrabOnAbilityCancel=true
		#--------------------------------------------------------------------------------		
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_COOLDOWN_TO_AIR_GRAB:	
				player.additionalCooldownToAirGrab=1
			GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_COOLDOWN_TO_AIR_GRAB:	
				player.additionalCooldownToAirGrab=2
			GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_COOLDOWN_TO_AIR_GRAB:	
				player.additionalCooldownToAirGrab=3
			#--------------------------------------------------------------------------------		
			GLOBALS.ProficiencyPropertyID.BAD_PREVENT_GROUND_DASHING:
				player.preventGroundDashing = true
			#--------------------------------------------------------------------------------		
			GLOBALS.ProficiencyPropertyID.BAD_PREVENT_BLOCKING_GROUND_ATTACKS_IN_AIR:
				player.preventBlockingGroundAttacksWhileAirborne = true
			GLOBALS.ProficiencyPropertyID.BAD_PREVENT_INCORRECT_BLOCKING:
				player.preventIncorrectBlocking = true
			#--------------------------------------------------------------------------------			
			GLOBALS.ProficiencyPropertyID.GOOD_SMALL_SETBACK_INCREASE_TO_SPAM_HISTUN_ON_ABILITY_CANCEL:
				player.abCancel_SpamProrationSetback = player.abCancel_SpamProrationSetback+1
			GLOBALS.ProficiencyPropertyID.BAD_SMALL_SETBACK_DECREASE_TO_SPAM_HISTUN_ON_ABILITY_CANCEL:
				player.abCancel_SpamProrationSetback = player.abCancel_SpamProrationSetback-1
		
			#--------------------------------------------------------------------------------			
			GLOBALS.ProficiencyPropertyID.GOOD_YOU_CAN_DASH_OR_JUMP_OUT_OF_PUSHBLOCK:
				player.enableJumpDashOutOfPushBlock = true
			#--------------------------------------------------------------------------------			
			GLOBALS.ProficiencyPropertyID.GOOD_PERFECT_BLOCK_REGENS_GUARD:
				player.regenGuardOnPerfectBlock = true
			#--------------------------------------------------------------------------------				
			GLOBALS.ProficiencyPropertyID.BAD_LOSE_TECH_INVINCIBILITY:
				player.loseTechInvincibility = true
			#--------------------------------------------------------------------------------					
			GLOBALS.ProficiencyPropertyID.BAD_ENOURMOUS_BLOCK_CHIP_DAMAGE:
				player.takeEnormousBlockChipDamage = true
			#--------------------------------------------------------------------------------						
			GLOBALS.ProficiencyPropertyID.GOOD_COUNTER_RIPOST_STEAL_ABILITY_BAR:
				player.counterRipostStealsBar = true
			#--------------------------------------------------------------------------------						
			GLOBALS.ProficiencyPropertyID.BAD_CANT_AUTORIPOSTE:
				player.cantAutoRipost = true
			#--------------------------------------------------------------------------------						
			GLOBALS.ProficiencyPropertyID.BAD_GAIN_NO_BAR_FROM_MAGIC_SERIES:
				player.cantGainBarFromMagicSeries = true
			#--------------------------------------------------------------------------------						
			GLOBALS.ProficiencyPropertyID.BAD_CANT_GRAB:
				player.cantGrab = true
			#--------------------------------------------------------------------------------						
			GLOBALS.ProficiencyPropertyID.BAD_50_PRECENT_INCORRECT_BLOCK_GUARD_DMG_REDUCTION:
				player.incorrectBlockDamageReductionEnabled = true
			#--------------------------------------------------------------------------------						
			GLOBALS.ProficiencyPropertyID.GOOD_GAIN_ADDITIONAL_GRAB_CHARGE:
				player.hasAdditionalGrabCharge = true		
			#--------------------------------------------------------------------------------						
			GLOBALS.ProficiencyPropertyID.BAD_ABILITY_CANCEL_ON_HIT_ONLY:
				player.abilityCancelOnHitOnly = true		
			#--------------------------------------------------------------------------------						
			GLOBALS.ProficiencyPropertyID.BAD_DONT_TURN_AROUND_IN_AIR:
				player.preventAutoTurnAroundInAir = true		
			#--------------------------------------------------------------------------------						
			GLOBALS.ProficiencyPropertyID.BAD_CANT_PUSH_BLOCK:
				player.preventPushBlock = true		
			
			
func loadPlayer(choice):
		
	var playerResource = load("res://fighters/" + choice + ".tscn")
	return playerResource.instance()

func initializeTrainingBot(botKinBody, playerKinBody, stage,botHeroName):
	var inputManager = botKinBody.get_node("PlayerController/InputManager")
	var botPlayerController = botKinBody.get_node("PlayerController")
	var playerController = playerKinBody.get_node("PlayerController")
	#var botScript = preload("res://NPCInputManager.gd")
	var botController = preload("res://TrainingModeManager.gd").new()
	
	botController.npcInputManager = inputManager
	botController.botKinbody2d = botKinBody
	botController.botPlayerController = botPlayerController
	botController.playerController = playerController
	botController.stage = stage
	botController.gameMode = GLOBALS.GameModeType.TRAINING
	botController.botHeroName=botHeroName
	
	#in training mode can restart match with a button without pause HUD
	botController.connect("restart_game",stage,"_on_start_match")
	
	#save the knowledge ai learned during match (they get reqwarded for hitting
	stage.connect("save_ai_model",botController,"_on_game_end_save_ghost_ai_db")
	
	#inputManager.set_script(botScript)
	loadAnotherInputManagerScript(botKinBody,"res://NPCInputManager.gd")
	inputManager.reset()
	inputManager.connect("initiated",botController,"_on_npc_input_manager_initiated")
	inputManager.add_child(botController)
	
	return botController
	
func freeGameObjects():
	stage = null
	if gameObjects.get_child_count() > 0:
		var child = gameObjects.get_children()[0]
		
		if child != null:
			gameObjects.call_deferred("remove_child",child)
			child.call_deferred("free")
	

func _on_enabling_user_input(player1,player2):
	#when player are allowed to move start recording
	if gameMode == GLOBALS.GameModeType.STANDARD or gameMode == GLOBALS.GameModeType.PLAY_V_AI:		
		replayHandler.startRecording()
	elif gameMode == GLOBALS.GameModeType.REPLAY:
		
		loadPlayerReplayInputManager(player1,replayHandler.PLAYER1_IX)
		loadPlayerReplayInputManager(player2,replayHandler.PLAYER2_IX)
		
		#loadPlayerReplayInputManager(player1,replayHandler.PLAYER1_IX,true)
		#loadPlayerReplayInputManager(player2,replayHandler.PLAYER2_IX,false)
		
		
	
func _on_replay_launch_request(replayId):
	var rc =replayHandler.loadReplay(replayId)
	replayHandler.set_physics_process(false)
	#failed
	if not rc:
		return
	
	freeGameObjects()
	savedReplayId=replayId
	
	var usrData = replayHandler.toUsrDataArray()
	gameMode=GLOBALS.GameModeType.REPLAY
	
	#var _settings=replayHandler.getSettings()
#	if _settings != null:
#		settings =_settings
	
	var skipLoadDelayFlag = bool(settings.getValue(settings.PERSISTENT_USER_SETTINGS_SECTION,settings.SKIP_LOAD_SCREEN_DELAY_FLAG_KEY))	
	if not skipLoadDelayFlag:
	#*************************
	
		#put the loading sccreen, then use yield for it to be ready, then load game after like 1 second
		startLoadingScreen()
		#give engine a chance to display the loading screen
		yield(get_tree(),"physics_frame") #consider using physics_frame instead of idle_frame
	
	
	
		#wait a brief moement to display proficiencies
		#don't need to wait for prof display anymore as you choose it in selection
		#wait a brief moment to allow loading screen to load
		#yield(get_tree().create_timer(MINIMUM_LOADING_SCREEN_TIME),"timeout")
		loadingScreenFrameTimer.startInSeconds(MINIMUM_LOADING_SCREEN_TIME)
		yield(loadingScreenFrameTimer,"timeout")
		
	_on_load_game(usrData)
	

func _on_save_replay():
	replayHandler.saveReplay(player1Choice, player2Choice,
			p1Prof1MajorClassIxSelect,	p1Prof1MinorClassIxSelect,
			p1Prof2MajorClassIxSelect,p1Prof2MinorClassIxSelect,
			p2Prof1MajorClassIxSelect,p2Prof1MinorClassIxSelect,
			p2Prof2MajorClassIxSelect,p2Prof2MinorClassIxSelect,
		player1Name,player2Name,player1Color,player2Color,lastStageSelected_scene_path,
		nameIOHandler.readInputRemapModel(player1Name),nameIOHandler.readInputRemapModel(player2Name))
		
func _on_load_game(usrData):

	emit_signal("loading_game")
	var player1Choice=usrData[0]
	var player2Choice=usrData[1]
	#var p1advProf=usrData[2]
	#var p1disProf=usrData[3]
	#var p2advProf=usrData[4]
	#var p2disProf=usrData[5]
	var p1Prof1MajorClassIxSelect=usrData[2]
	var p1Prof1MinorClassIxSelect=usrData[3]
	var p1Prof2MajorClassIxSelect=usrData[4]
	var p1Prof2MinorClassIxSelect=usrData[5]
	var p2Prof1MajorClassIxSelect=usrData[6]
	var p2Prof1MinorClassIxSelect=usrData[7]
	var p2Prof2MajorClassIxSelect=usrData[8]
	var p2Prof2MinorClassIxSelect=usrData[9]
	var _p1Name=usrData[10]
	var _p2Name=usrData[11]
	var _player1Color=usrData[12]
	var _player2Color=usrData[13]
	var stage_resource=usrData[14]
	var _player1RemapButtonModel=usrData[15]
	var _player2RemapButtonModel=usrData[16]
	
	
	var enableLoadingScreenFlag = bool(settings.getValue(settings.PERSISTENT_USER_SETTINGS_SECTION,settings.LOAD_GAME_IN_DIFFERENT_THREAD_KEY))	
	
	self.musicPlayer.stop()
	
	freeGameObjects()
	
	
	# Add the next level
	#var stage_resource = preload("res://stage.tscn")
	#var stage_resource = preload("res://stages/ocean.tscn")
	#var stage_resource = preload("res://stages/japan.tscn")
	#var stage_resource = preload("res://stages/swamp.tscn")
	#var stage_resource = preload("res://stages/dojo.tscn")
	
	
	stage = stage_resource.instance()
	stage.stageName = stage_resource.resource_path
	stage.settings = settings
	stage.gameMode = gameMode	
	
	#load the winner's information if doing a crew battle
	if crewBattleFlag:
		stage.crewBattleFlag =true
		stage.crewBattleWinnerPlayerState =crewBattleWinnerPlayerState
		stage.crewBattleWinner = crewBattleWinner
	else:
		stage.crewBattleFlag =false
		stage.crewBattleWinnerPlayerState =null
		stage.crewBattleWinner = null

	stage.trainAIFlag = bool(settings.getValue(settings.PERSISTENT_USER_SETTINGS_SECTION,settings.TRAIN_AI_FLAG_KEY))
	stage.connect("back_to_main_menu",self,"_on_main_menu")
	
	#online mode?
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		networkManager.connect("ping",stage,"_on_ping")
		networkManager.connect("game_start_tick_arrived",stage,"_on_game_start_tick_arrived")		
		networkManager.connect("game_start_tick_arrived",self,"_on_game_start_tick_arrived")		
		networkManager.connect("input_delay_changed",stage,"_on_input_delay_changed")
		networkManager.connect("resolve_desynch",stage,"_on_resolve_desynch")
		
	#	func _on_match_count_down_started():
	
		#_on_match_restarting():
	
		stage.connect("game_starting",networkManager,"_on_game_starting")
		stage.connect("game_started",networkManager,"_on_game_started")
		stage.connect("back_to_online_lobby",networkManager,"disconnectCleanup",[GLOBALS.NetworkDisconnectionType.GRACEFUL_DISCONNECT])
		
		
		
	#stage.connect("back_to_character_select",self,"_on_character_select",[player1Choice, player2Choice,fighter1Texture,fighter2Texture])
	stage.connect("back_to_character_select",self,"_on_character_select") # go to chracters seclection
	stage.connect("back_to_stage_select",self,"load_stage_select")
	stage.connect("save_replay",self,"_on_save_replay") 
	stage.connect("enabling_user_input",self,"_on_enabling_user_input") 
	
	#stage.connect("back_to_proficiency_select",self,"_on_proficiencies_selected",[p1advProf,p1disProf,p2advProf,p2disProf])
	
	var skipProfSelectFlag = false
	stage.connect("back_to_proficiency_select",self,"_on_proficiency_selection",[player1Choice, player2Choice,fighter1Texture,fighter2Texture,player1Name,player2Name,player1Color,player2Color,skipProfSelectFlag]) #go to proficiency selection

	
	
	
	#depending on if loading screen enabled or not, connect stage start to end loading or loading screen vanishing
	if enableLoadingScreenFlag:
		
		gameDoneLoadingFlag = false
		loadingScreeenFinishedFlag = false
		#setup match when game loaded
		#connect("done_loading_game",stage,"preMatchStart")
		if not is_connected("done_loading_game",self,"_new_on_done_loading_game"):
			connect("done_loading_game",self,"_new_on_done_loading_game")
		
		#start match after loading screen disapears
		#connect("loading_screen_finished",stage,"postMatchStart")
		if not is_connected("loading_screen_finished",self,"_new_on_loading_screen_finished"):
			connect("loading_screen_finished",self,"_new_on_loading_screen_finished")
		
	else:
		#start match immediatly aafter game loaded
		connect("done_loading_game",stage,"_on_start_match")
	
	var player1 = loadPlayer(player1Choice)
	
	print("loaded player 1")
	var player2 = loadPlayer(player2Choice)
	
	print("loaded player 2")
	
	#online mode?
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		#give access to player states so network manager can check fo desynch issues
		var p1State = player1.get_node("PlayerController/PlayerState")
		var p2State = player2.get_node("PlayerController/PlayerState")
		networkManager.setPlayerStates(p1State,p2State)
	
	var p1Sprite = player1.get_node("active-nodes/Sprite")
	var p2Sprite = player2.get_node("active-nodes/Sprite")
	#same skin and hero selected?
	if player1Choice == player2Choice:
		if _player1Color ==_player2Color:
				
			#when two players pick same character, make one character lighter and one darker			
			p1Sprite.modulate = Color(0.5,0.5,0.5,1)
			p2Sprite.modulate = Color(1.3,1.3,1.3,1)
		
	
	#apply the skin
	p1Sprite.self_modulate = _player1Color
	p2Sprite.self_modulate = _player2Color
	
	#replace the input manager with training bot if in traniing mode
	if gameMode == GLOBALS.GameModeType.TRAINING:
		
		
		#we found the training bot? (PLAYER 2 IS PLAYER)
		if trainingPlayerDeviceId != GLOBALS.PLAYER1_INPUT_DEVICE_ID:
			
			initializeTrainingBot(player1,player2,stage,player1Choice)
	elif gameMode == GLOBALS.GameModeType.PLAY_V_AI:
		
		
		#we found the training bot? (PLAYER 2 IS PLAYER)
		if trainingPlayerDeviceId != GLOBALS.PLAYER1_INPUT_DEVICE_ID:
			
			var aiController = initializeTrainingBot(player1,player2,stage,player1Choice)
			
			#choose demo path on the cpu's hero selection (since player 2 is player, player1 is bot)
			aiController.demoDataFilePath = aiDemoDataFilePaths[player1Choice]
			aiController.enableGhostAIByDefault = true
			aiController.gameMode = GLOBALS.GameModeType.PLAY_V_AI
	
	
	#initPlayer1(player1,p1advProf,p1disProf,_p1Name,player1Choice)	
	initPlayer1(player1,
				p1Prof1MajorClassIxSelect,p1Prof1MinorClassIxSelect,
				p1Prof2MajorClassIxSelect,p1Prof2MinorClassIxSelect
				,_p1Name,player1Choice)	
	
	print("initialized player 1 attributes")
	
	
	
		#replace the input manager with training bot if in traniing mode
	if gameMode == GLOBALS.GameModeType.TRAINING:
		
		
		#we found the training bot? (PLAYER 1 IS PLAYER)
		if trainingPlayerDeviceId != GLOBALS.PLAYER2_INPUT_DEVICE_ID:
			
			initializeTrainingBot(player2,player1,stage,player2Choice)
	elif gameMode == GLOBALS.GameModeType.PLAY_V_AI:
			
		
		#we found the training bot? (PLAYER 1 IS PLAYER)
		if trainingPlayerDeviceId != GLOBALS.PLAYER2_INPUT_DEVICE_ID:
			
			var aiController = initializeTrainingBot(player2,player1,stage,player2Choice)
			#choose demo path on the cpu's hero selection (since player 1 is player, player2 is bot)
			aiController.demoDataFilePath = aiDemoDataFilePaths[player2Choice]
			aiController.enableGhostAIByDefault = true
			aiController.gameMode = GLOBALS.GameModeType.PLAY_V_AI
	
	#initPlayer2(player2,p2advProf,p2disProf,_p2Name,player2Choice)
	initPlayer2(player2,
				p2Prof1MajorClassIxSelect,p2Prof1MinorClassIxSelect,
				p2Prof2MajorClassIxSelect,p2Prof2MinorClassIxSelect
				,_p2Name,player2Choice)
	
	print("initialized player 2 attbibutes")
	

	
	gameObjects.call_deferred("add_child",stage)
	#gameObjects.add_child(stage)
	yield(stage,"stage_ready")
	print("added stage to scene")
	
	#shoudl wait 1 more frame, just tobe safe, since glove/hat dittos breaks stage collision box for player 2
	#this fixes the issue of player 2 as glove not standing correctly or falling trhough stage
	#only required if threading, so if loading screen disable, skip this step (otherwise it bugs stage)
	if enableLoadingScreenFlag:
		yield(get_tree(),"physics_frame") #consider using physics_frame instead idle_frame
	
	#stage.playersNode.add_child(player1)
	stage.playersNode.call_deferred("add_child",player1)
	yield(player1,"player_ready")
	#yield(get_tree(),"node_added")
	
	print("added playe 1 to stage")
	#stage.playersNode.add_child(player2)
	stage.playersNode.call_deferred("add_child",player2)
	yield(player2,"player_ready")
	
	
	print("added player 2 to stage")
		
	
	#PLAY STAGE SONG
	stage.musicPlayer.playRandomSound()
	
	
	player1.init()
	
	#get the name-specific control scheme
	#var inputRemapModel = nameIOHandler.readInputRemapModel(player1Name)
	player1.playerController.inputManager.addCustomButtonScheme(_player1RemapButtonModel)
	
	
	#make sure to replace the input manager in online mode
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
					
		if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING:
			player1.playerController.inputManager = networkManager.getLocalInputManager()					
		else:
			player1.playerController.inputManager = networkManager.getRemoteInputManager()			
	
	
	#enable the area to detect land on opponent
	player1.landOnPlayerArea.collision_mask = 1<< GLOBALS.PLAYER2_BODYBOX_LAYER_BIT
	player1.insidePlayerArea.collision_mask = 1<< GLOBALS.PLAYER2_BODYBOX_LAYER_BIT
	
	#	saveInitializedPlayer(player1,player1Choice)
	print("initialized player 1")
	
	
	#initializedPlayer = getInitializedPlayerScenePath(player2Choice)
	#if initializedPlayer == null:
	player2.init()
	
	#get the name-specific control scheme
	#inputRemapModel = nameIOHandler.readInputRemapModel(player2Name)
	player2.playerController.inputManager.addCustomButtonScheme(_player2RemapButtonModel)
	
	
	#make sure to replace the input manager in online mode
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
					
		if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING:
			player2.playerController.inputManager = networkManager.getRemoteInputManager()					
		else:
			player2.playerController.inputManager = networkManager.getLocalInputManager()			


	#enable the area to detect land on opponent
	#player2.landOnPlayerArea.collision_mask =1<< GLOBALS.PLAYER1_PUSHABLE_BODYBOX_LAYER_BIT
	player2.landOnPlayerArea.collision_mask =1<< GLOBALS.PLAYER1_BODYBOX_LAYER_BIT
	player2.insidePlayerArea.collision_mask = 1<< GLOBALS.PLAYER1_BODYBOX_LAYER_BIT
		#saveInitializedPlayer(player2,player1Choice)
	print("initialized player 2")
	
	
	if gameMode == GLOBALS.GameModeType.REPLAY:
		replayHandler.startReplayingTracking(savedReplayId,player1,player2)
		
		#at this point we must scale player heros' dynamically
	#so we don't want to scale the collision shapes twice, since they are
	#resource shared between scene isntances
	#rescaling playaer model logic
	#if player1Choice == player2Choice:
	#	var scaleCollisionShapesFlag = true
	#	player1.rescale(player1.scaleModifier,scaleCollisionShapesFlag)
	#	scaleCollisionShapesFlag = false
	#	player2.rescale(player2.scaleModifier,scaleCollisionShapesFlag)
	#else:
		#var scaleCollisionShapesFlag = true
		#player1.rescale(player1.scaleModifier,scaleCollisionShapesFlag)
		#scaleCollisionShapesFlag = true
		#player2.rescale(player2.scaleModifier,scaleCollisionShapesFlag)
	
	#player2.init()
	#print("initialized player 2")
	
		
	#normal mode?
	if gameMode == GLOBALS.GameModeType.STANDARD or gameMode == GLOBALS.GameModeType.PLAY_V_AI:
		#make sure the replay handler can record inputs
		player1.get_node("PlayerController/InputManager").connect("input_update",replayHandler,"_on_input_update",[player1.playerController.inputManager,replayHandler.PLAYER1_IX])
		player2.get_node("PlayerController/InputManager").connect("input_update",replayHandler,"_on_input_update",[player2.playerController.inputManager,replayHandler.PLAYER2_IX])
		#replayHandler.startRecording()
		
	#else:
		#no recording in any other mode (will leave future work for AI mode. gotta convert commands to button presses for it to work)
	#	replayHandler.stopRecording()
	replayHandler.stopRecording()	
		
		#if gameMode == GLOBALS.GameModeType.REPLAY:
		
		#	loadPlayerReplayInputManager(player1,replayHandler.PLAYER1_IX)
		#	loadPlayerReplayInputManager(player2,replayHandler.PLAYER2_IX)
	#saveInitializedPlayer(player2,player2Choice)
	
	player1.floorDetector.collision_mask=1 << GLOBALS.PLAYER1_STAGE_COLLISION_LAYER_BIT
	player2.floorDetector.collision_mask=1 << GLOBALS.PLAYER2_STAGE_COLLISION_LAYER_BIT
	player1.floorDetector.collision_mask=1 << GLOBALS.PLAYER1_STAGE_FLOOR_COLLISION_LAYER_BIT
	player2.floorDetector.collision_mask=1 << GLOBALS.PLAYER2_STAGE_FLOOR_COLLISION_LAYER_BIT	
	player1.leftPlatformDetector.collision_mask=1 << GLOBALS.PLAYER1_PLATFORM_LAYER_BIT
	player2.leftPlatformDetector.collision_mask=1 << GLOBALS.PLAYER2_PLATFORM_LAYER_BIT
	player1.rightPlatformDetector.collision_mask=1 << GLOBALS.PLAYER1_PLATFORM_LAYER_BIT
	player2.rightPlatformDetector.collision_mask=1 << GLOBALS.PLAYER2_PLATFORM_LAYER_BIT
	player1.leftOpponentDetector.collision_mask=1 << GLOBALS.PLAYER2_BODYBOX_LAYER_BIT
	player2.leftOpponentDetector.collision_mask=1 << GLOBALS.PLAYER1_BODYBOX_LAYER_BIT
	player1.rightOpponentDetector.collision_mask=1 << GLOBALS.PLAYER2_BODYBOX_LAYER_BIT
	player2.rightOpponentDetector.collision_mask=1 << GLOBALS.PLAYER1_BODYBOX_LAYER_BIT
	player1.rightWallDetector.collision_mask=1 << GLOBALS.PLAYER1_STAGE_COLLISION_LAYER_BIT
	player2.rightWallDetector.collision_mask=1 << GLOBALS.PLAYER2_STAGE_COLLISION_LAYER_BIT
	player1.leftWallDetector.collision_mask=1 << GLOBALS.PLAYER1_STAGE_COLLISION_LAYER_BIT
	player2.leftWallDetector.collision_mask=1 << GLOBALS.PLAYER2_STAGE_COLLISION_LAYER_BIT
	player1.hittingRightWallDetector.collision_mask=1 << GLOBALS.PLAYER1_STAGE_COLLISION_LAYER_BIT
	player2.hittingRightWallDetector.collision_mask=1 << GLOBALS.PLAYER2_STAGE_COLLISION_LAYER_BIT
	player1.hittingLeftWallDetector.collision_mask=1 << GLOBALS.PLAYER1_STAGE_COLLISION_LAYER_BIT
	player2.hittingLeftWallDetector.collision_mask=1 << GLOBALS.PLAYER2_STAGE_COLLISION_LAYER_BIT
	player1.disableBodyBoxRightWallDetector.collision_mask=1 << GLOBALS.PLAYER1_STAGE_COLLISION_LAYER_BIT
	player2.disableBodyBoxRightWallDetector.collision_mask=1 << GLOBALS.PLAYER2_STAGE_COLLISION_LAYER_BIT
	player1.disableBodyBoxLeftWallDetector.collision_mask=1 << GLOBALS.PLAYER1_STAGE_COLLISION_LAYER_BIT
	player2.disableBodyBoxLeftWallDetector.collision_mask=1 << GLOBALS.PLAYER2_STAGE_COLLISION_LAYER_BIT
	player1.insideOpponentDetector.collision_mask=1 << GLOBALS.PLAYER2_BODYBOX_LAYER_BIT
	player2.insideOpponentDetector.collision_mask=1 << GLOBALS.PLAYER1_BODYBOX_LAYER_BIT
	stage.init(player1,player2)
	
	
	print("initialized stage")
	
	stage.connect("game_ended",self,"_on_game_ended")
	
	connect("done_loading_game",stage,"_on_done_loading_game")
	
#	get_tree().paused = false
	#call_deferred("tmp")
	emit_signal("done_loading_game")
	
	print("done loading game")
	pass
	pass
#func step3():	
	pass
#func step4():
#	pass
#func tmp():
	#emit_signal("done_loading_game")

var debugCount=0
func loadPlayerReplayInputManager(player,playerIx,debugParam=false):
			
		if debugCount >=2:
			#debug
			var inputManagerNode = player.get_node("PlayerController/InputManager")	
			
			if inputManagerNode is preload("res://ReplayInputManager.gd"):
				inputManagerNode.tick=0
				return
		
		debugCount = debugCount+1	
		
		loadAnotherInputManagerScript(player,"res://ReplayInputManager.gd")
		var inputManagerNode = player.get_node("PlayerController/InputManager")
		
		inputManagerNode.connect("replay_missing_input",self,"_on_online_session_ended",[GLOBALS.MENU_NOTIFICATION_TEXT,"Replay Desyncrhonized"])		
	
		inputManagerNode.set_physics_process(true)
		
		if debugParam:
			inputManagerNode.mirrorDebugFlag = true
		var btnPressedBuffer = replayHandler.getButtonsPressedBuffer(playerIx)
		var btnHoldBuffer = replayHandler.getButtonsHoldBuffer(playerIx)
		var btnReleasedBuffer = replayHandler.getButtonsReleasedBuffer(playerIx)
		
		inputManagerNode.setupInputs(btnPressedBuffer,btnHoldBuffer,btnReleasedBuffer)
		
		
		
func loadAnotherInputManagerScript(playear,newScriptPath):
	
	var inputManagerNode = playear.get_node("PlayerController/InputManager")
	var _bufferSize=inputManagerNode.bufferSize
	var _doubleTapWindow=inputManagerNode.doubleTapWindow
	var _leakyDI=inputManagerNode.leakyDI
	var _leakyBtn=inputManagerNode.leakyBtn
	var _leakyRipostInput=inputManagerNode.leakyRipostInput
	var _leakyCounterRipostInput = inputManagerNode.leakyCounterRipostInput
	#var _defaultBufferSize=inputManagerNode.defaultBufferSize
	var _inputDeviceId=inputManagerNode.inputDeviceId
	var _resetBufferFlag=inputManagerNode.resetBufferFlag
	var _grabDIReleaseBlackList=inputManagerNode.grabDIReleaseBlackList
	var _controllerConnected=inputManagerNode.controllerConnected
	var _stopBufferLeakFlag=inputManagerNode.stopBufferLeakFlag
	var _movementOnlyCommands=inputManagerNode.movementOnlyCommands
	var _bufferingRipostInputFlag=inputManagerNode.bufferingRipostInputFlag
	var _globalSpeedMod=inputManagerNode.globalSpeedMod
	var _cmdStringToEnumMap=inputManagerNode.cmdStringToEnumMap
	var _mirrorDIMap=inputManagerNode.mirrorDIMap
	var _cmdDIMap=inputManagerNode.cmdDIMap
	
	var _btnMap =inputManagerNode.btnMap
	var _pInRemap = inputManagerNode.pInRemap
	var _inputHistory  = inputManagerNode.inputHistory
	var _cmdBuffer =inputManagerNode.cmdBuffer
	var _unbufferableCommands =inputManagerNode.unbufferableCommands
	var _lastCommand=inputManagerNode.lastCommand
	var _lastDI=inputManagerNode.lastDI
	var _lastGrabDI = inputManagerNode.lastGrabDI
	var _ignoreGrabDI = inputManagerNode.ignoreGrabDI
	var _mirroredCommandMap=inputManagerNode.mirroredCommandMap
	var _ripostCommandMap =inputManagerNode.ripostCommandMap
	var _counterRipostCommandMap = inputManagerNode.counterRipostCommandMap
	var _ripostCommandReverseMap=inputManagerNode.ripostCommandReverseMap
	var _counterRipostCommandReverseMap=inputManagerNode.counterRipostCommandReverseMap		
	var _counterRipostAirCommandMap =inputManagerNode.counterRipostAirCommandMap
	var _ripostToCounterRipostMap = inputManagerNode.ripostToCounterRipostMap
	var _commandMap = inputManagerNode.commandMap
	var _mvmOnlyCmdMap =inputManagerNode.mvmOnlyCmdMap
	var _holdingBackCmdMap = inputManagerNode.holdingBackCmdMap
	var _holdingDownCmdMap = inputManagerNode.holdingDownCmdMap
	var _abilityCancelInputCmdMap =inputManagerNode.abilityCancelInputCmdMap
	
	var newScript = load(newScriptPath)

	inputManagerNode.set_script(newScript)
	
	
	#inputManagerNode.init(false) #make sure no physics processing occurs until input is ready to be processed
	inputManagerNode.bufferSize=_bufferSize
	inputManagerNode.doubleTapWindow=_doubleTapWindow
	inputManagerNode.leakyDI=_leakyDI
	inputManagerNode.leakyBtn= _leakyBtn
	inputManagerNode.leakyRipostInput=_leakyRipostInput
	inputManagerNode.leakyCounterRipostInput =_leakyCounterRipostInput	
	#inputManagerNode.defaultBufferSize= _defaultBufferSize
	inputManagerNode.inputDeviceId=_inputDeviceId
	inputManagerNode.resetBufferFlag= _resetBufferFlag
	inputManagerNode.grabDIReleaseBlackList=_grabDIReleaseBlackList
	inputManagerNode.controllerConnected=_controllerConnected
	inputManagerNode.stopBufferLeakFlag=_stopBufferLeakFlag
	inputManagerNode.movementOnlyCommands=_movementOnlyCommands
	inputManagerNode.bufferingRipostInputFlag=_bufferingRipostInputFlag
	inputManagerNode.globalSpeedMod=_globalSpeedMod
	inputManagerNode.cmdStringToEnumMap=_cmdStringToEnumMap
	inputManagerNode.mirrorDIMap=_mirrorDIMap
	inputManagerNode.cmdDIMap=_cmdDIMap
	inputManagerNode.btnMap =_btnMap
	inputManagerNode.pInRemap = _pInRemap
	inputManagerNode.inputHistory  = _inputHistory
	inputManagerNode.cmdBuffer =_cmdBuffer
	inputManagerNode.unbufferableCommands =_unbufferableCommands
	inputManagerNode.lastCommand=_lastCommand
	inputManagerNode.lastDI=_lastDI
	inputManagerNode.lastGrabDI = _lastGrabDI
	inputManagerNode.ignoreGrabDI = _ignoreGrabDI
	inputManagerNode.mirroredCommandMap=_mirroredCommandMap
	inputManagerNode.ripostCommandMap =_ripostCommandMap
	inputManagerNode.counterRipostCommandMap = _counterRipostCommandMap
	inputManagerNode.ripostCommandReverseMap=_ripostCommandReverseMap
	inputManagerNode.counterRipostCommandReverseMap=_counterRipostCommandReverseMap
	inputManagerNode.ripostToCounterRipostMap=_ripostToCounterRipostMap
	inputManagerNode.counterRipostAirCommandMap = _counterRipostAirCommandMap
	inputManagerNode.commandMap = _commandMap
	inputManagerNode.mvmOnlyCmdMap =_mvmOnlyCmdMap
	inputManagerNode.holdingBackCmdMap = _holdingBackCmdMap
	inputManagerNode.holdingDownCmdMap = _holdingDownCmdMap
	inputManagerNode.abilityCancelInputCmdMap = _abilityCancelInputCmdMap


func startLoadingScreen():

	#loadingScreen.init(fighter1Texture, player1Choice, player1Name,p1advProf,p1disProf,fighter2Texture, player2Choice, player2Name,p2advProf,p2disProf)

	loadingScreen.init(fighter1Texture, player1Choice, player1Name,
	p1Prof1MajorClassIxSelect,p1Prof1MinorClassIxSelect,
	p1Prof2MajorClassIxSelect,p1Prof2MinorClassIxSelect,
	fighter2Texture, player2Choice, player2Name,
	p2Prof1MajorClassIxSelect,p2Prof1MinorClassIxSelect,
	p2Prof2MajorClassIxSelect,p2Prof2MinorClassIxSelect,lastStageSelected_scene_path)

	
	
	loadingScreen.call_deferred("fadeOut",0.5)#0.5 second to get dark and display loading
	
	if not is_connected("done_loading_game",self,"removeLoadingScreen"):
		
		#create a 3 second counter, to make minimum loading screen up toiem to read proficiencies
		#var minLoadscreenTimer = get_tree().create_timer(MINIMUM_LOADING_SCREEN_TIME)		
		loadingScreenMinDurationEllapsed = false		
		#minLoadscreenTimer.connect("timeout",self,"_on_min_loading_screen_duration_timeout",[],CONNECT_ONESHOT)
		loadingScreenFrameTimer2.startInSeconds(MINIMUM_LOADING_SCREEN_TIME)
		connect("done_loading_game",self,"removeLoadingScreen",[1,loadingScreen],CONNECT_ONESHOT)#3 is for 3 second delay before remove laodign screen

func _on_min_loading_screen_duration_timeout():
	#no longer need to be connected, it was one shot
	loadingScreenMinDurationEllapsed =true
func removeLoadingScreen(delay,loadingScreen):
	
	#took more than minimum amount of time to load game?
	if loadingScreenMinDurationEllapsed:
	#wait until laoding screen disapears
		loadingScreen.disapear(delay)#3 seconds to fade out
	#disconnect("done_loading_game",self,"removeLoadingScreen")
	else:
		
		if loadingScreenFrameTimer2.is_physics_processing():
			#wait for timer to ellapsed before continouing to make loading screen disape
			#to guarantee minimum laoding screen time respected
			#yield(get_tree().create_timer(minLoadscreenTimer.time_left),"timeout")
			#timer.startInSeconds(1)
			yield(loadingScreenFrameTimer2,"timeout")
			
		loadingScreen.disapear(delay)#3 seconds to fade out
		
	emit_signal("loading_screen_finished")
	

func _on_done_loading_game():
	
	
	
	#worker thread finished loading game?
	if loadingThread != null:
		
		#print("waiting to join thread")
		#join thread back to main loop
		loadingThread.wait_to_finish()
		
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass





#connect("done_loading_game",stage,"preMatchStart")
func _new_on_done_loading_game():
	
	loadGameMutex.lock()
	gameDoneLoadingFlag=true

	#only pre start match if haven't finishe dloading screen
	if not loadingScreeenFinishedFlag:
		stage.preMatchStart()
	else:
		#loading scree already finsihed, so laod game completly
		stage._on_start_match()
	
	loadGameMutex.unlock()
#start match after loading screen disapears
#connect("loading_screen_finished",stage,"postMatchStart")
func _new_on_loading_screen_finished():
	loadGameMutex.lock()
	loadingScreeenFinishedFlag=true
	
	#only start post match if the game loaded
	if gameDoneLoadingFlag:
		stage.postMatchStart()
	else:
		#the game hasn't finished loading yet, so do nothing, the signal handler for game load finished will hadnle
		pass
		
	loadGameMutex.unlock()
	
func _on_online_match_synchronized(_player1Choice, _player2Choice,
			_p1Prof1MajorClassIxSelect,	_p1Prof1MinorClassIxSelect,
			_p1Prof2MajorClassIxSelect,_p1Prof2MinorClassIxSelect,
			_p2Prof1MajorClassIxSelect,_p2Prof1MinorClassIxSelect,
			_p2Prof2MajorClassIxSelect,_p2Prof2MinorClassIxSelect
			,_player1Name,_player2Name,_player1Color,_player2Color,_stage_resource,
			_player1RemapButtonModel,_player2RemapButtonModel):

	var stage = load(_stage_resource)
	player1Choice=_player1Choice
	player2Choice=_player2Choice
	#p1advProf=_p1advProf
	#p1disProf=_p1disProf
	#p2advProf=_p2advProf
	#p2disProf=_p2disProf
	
		
	p1Prof1MajorClassIxSelect=	_p1Prof1MajorClassIxSelect	
	p1Prof1MinorClassIxSelect=_p1Prof1MinorClassIxSelect
	p1Prof2MajorClassIxSelect = _p1Prof2MajorClassIxSelect
	p1Prof2MinorClassIxSelect = _p1Prof2MinorClassIxSelect
	p2Prof1MajorClassIxSelect=_p2Prof1MajorClassIxSelect
	p2Prof1MinorClassIxSelect=_p2Prof1MinorClassIxSelect
	p2Prof2MajorClassIxSelect=_p2Prof2MajorClassIxSelect
	p2Prof2MinorClassIxSelect=_p2Prof2MinorClassIxSelect
	
	player1Name=_player1Name
	player2Name=_player2Name
	player1Color=_player1Color
	player2Color=_player2Color
	#TODO: dynamically create names that don't exist, but for peer name is null
	#begin_loading_game(_p1advProf,_p1disProf,_p2advProf,_p2disProf,stage)
	begin_loading_game(_p1Prof1MajorClassIxSelect,	_p1Prof1MinorClassIxSelect,
			_p1Prof2MajorClassIxSelect,_p1Prof2MinorClassIxSelect,
			_p2Prof1MajorClassIxSelect,_p2Prof1MinorClassIxSelect,
			_p2Prof2MajorClassIxSelect,_p2Prof2MinorClassIxSelect,stage,
			_player1RemapButtonModel,_player2RemapButtonModel)

func _on_lobby_reconnect_to_peer_request(onlineLobby):
	
	if gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		var _stageScenePath=null
		#PROVIDE lobby instance to remember the ip address to connect to
		self.call_deferred("_on_online_lobby",onlineModeMaineInputDeviceId,_stageScenePath,onlineLobby)
	else:
		#host simply needs to re-launch online lobby to wait for connection
		self.call_deferred("_on_online_lobby",onlineModeMaineInputDeviceId,stage_scene_path,onlineLobby)
		
func _on_game_start_tick_arrived():
	#we have to add the online mode's custom button remap here again because for some reason the
	#pInRemap map gets reset when game starts
	stage.player1.playerController.inputManager.addCustomButtonScheme(player1RemapButtonModel)
	stage.player2.playerController.inputManager.addCustomButtonScheme(player2RemapButtonModel)
	
	pass