extends CanvasLayer

signal restart_game

const NEW_RECORD_SOUND_IX=0

const NEW_RECORD_FOOTER_TEXT="* New Record Acheived"
export (Color) var newRecordFontColor = null

var winnerTextNode = null
var player1StatsNode = null
var player2StatsNode = null
var victoryType = null
var GLOBALS = preload("res://Globals.gd")
var inputDevices = []
var stats = null

var statTemplate = null
var pauseHUD = null

var gameMode = null
var statsP1Container = null
var statsP2Container = null

export (int) var scrollSpeed = 300

var vicotoryInfoPane = null
const TAB_WHITESPACE = "          "

var soundSFXPlayer= null

var p1Controller=null
var p2Controller= null
var playerControllers = []

var footerNewRecordP1Lable = null
var footerNewRecordP2Lable = null

var newRecordAcheived =  false
	
		
func _ready():
	set_physics_process(true)
	
	pass
func init(_victoryType,winnerText,player1Choice,player2Choice,player1Name,player2Name,player1State,player2State, victorStylePointsPlayerState,_stats,_gameMode,_p1Controller,_p2Controller,_stageScenePath):
	# Called when the node is added to the scene for the first time.
	# Initialization here
	gameMode=_gameMode	
	stats = _stats
	
	
	p1Controller = _p1Controller
	p2Controller = _p2Controller
	playerControllers.append(p1Controller)
	playerControllers.append(p2Controller)
	
	#inputManager = $InputManager
	#inputManager2 = $InputManager2
	pauseHUD = $"wrapper/PauseLayer"
	
	pauseHUD.gameMode = gameMode
	
	
	soundSFXPlayer = $sfxPlayer
	
	$wrapper.visible = true
	winnerTextNode = $"wrapper/result-text"
	victoryType = _victoryType
	player1StatsNode = $"wrapper/player1-stats"
	player2StatsNode = $"wrapper/player2-stats"

	footerNewRecordP1Lable = $"wrapper/VBoxContainer/footer/newRecordP1"
	footerNewRecordP2Lable = $"wrapper/VBoxContainer/footer/newRecordP2"
	footerNewRecordP1Lable.text =""
	footerNewRecordP2Lable.text =""

	statTemplate = $"wrapper/stat-template"
	
	statsP1Container = $"wrapper/VBoxContainer/center/leftPane/player1ScrollContainer/"
	statsP2Container = $"wrapper/VBoxContainer/center/rightPane/player2ScrollContainer"
	
	vicotoryInfoPane=$"wrapper/StudentVictoryInfo"
	vicotoryInfoPane.visible = true
	
	processVictoryInfo(_victoryType,player1Choice,player2Choice,player1Name,player2Name,_stageScenePath)
	#only player 1 can restart it
#	inputManager.inputDeviceId="P1"
#	inputManager2.inputDeviceId="P2"
	
	
	#winnerTextNode.text = "The winner is...:" + winnerText
	
	$wrapper/VBoxContainer/header/VBoxContainer/Label2.text = $wrapper/VBoxContainer/header/VBoxContainer/Label2.text + " " + winnerText
	var statsP1Pane = $wrapper/VBoxContainer/center/leftPane/player1ScrollContainer/player1Stats
	var statsP2Pane = $wrapper/VBoxContainer/center/rightPane/player2ScrollContainer/player2Stats
	
	
	var p1NewRecord =renderStats(statsP1Pane,player1State,player1Name,player1Choice,footerNewRecordP1Lable)		
	var p2NewRecord =renderStats(statsP2Pane,player2State,player2Name,player2Choice,footerNewRecordP2Lable)
	
	newRecordAcheived =  p1NewRecord or p2NewRecord
	
	var stylePointsPane = null
	var victorName = null
	var victorHero = null
	#render style points
	if victoryType == GLOBALS.VictoryType.PLAYER1_WINS_VIA_KO or victoryType == GLOBALS.VictoryType.PLAYER1_WINS_VIA_TIMEOUT:
		stylePointsPane=statsP1Pane
		victorName = player1Name
		victorHero = player1Choice
	elif victoryType == GLOBALS.VictoryType.PLAYER2_WINS_VIA_KO or victoryType == GLOBALS.VictoryType.PLAYER2_WINS_VIA_TIMEOUT:
		stylePointsPane=statsP2Pane
		victorName = player2Name
		victorHero = player2Choice
	elif victoryType == GLOBALS.VictoryType.DRAW_VIA_KO or victoryType == GLOBALS.VictoryType.DRAW_VIA_TIMEOUT:
		#no style points
		pass
		
	#only display style point if not a draw
	if stylePointsPane != null and victorStylePointsPlayerState != null:
		_addStat(stylePointsPane,"---style combo stats follow---")
		renderStyleStats(stylePointsPane,victorStylePointsPlayerState,victorName,victorHero)
		
	inputDevices.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDevices.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	set_physics_process(true)

func processVictoryInfo(_victoryType,_player1Choice,_player2Choice,_player1Name,_player2Name,_stageScenePath):
	
	var victoryHeroName =null
	var victoryPlayerName =null
	var loserHeroName=null
	#determine names of victors and losers
	if _victoryType == GLOBALS.VictoryType.PLAYER1_WINS_VIA_KO or _victoryType == GLOBALS.VictoryType.PLAYER1_WINS_VIA_TIMEOUT:
		victoryHeroName =_player1Choice
		victoryPlayerName =_player1Name
		loserHeroName=_player2Choice
	elif _victoryType == GLOBALS.VictoryType.PLAYER2_WINS_VIA_KO or _victoryType == GLOBALS.VictoryType.PLAYER2_WINS_VIA_TIMEOUT:
		victoryHeroName =_player2Choice
		victoryPlayerName =_player2Name
		loserHeroName=_player1Choice
	
	#ignore draws, don't display victor info
	elif _victoryType == GLOBALS.VictoryType.DRAW_VIA_KO or _victoryType == GLOBALS.VictoryType.DRAW_VIA_TIMEOUT:
		vicotoryInfoPane.visible = false
		return
	else:	
		print("can't display vicotry info, unkwon victory type: "+str(_victoryType))
		vicotoryInfoPane.visible = false
		return

	
	vicotoryInfoPane.visible = true
	vicotoryInfoPane.init(victoryHeroName,victoryPlayerName,loserHeroName,_stageScenePath)
func disable():
	set_physics_process(false)
	$wrapper.visible = false
	
func _addStat(scrollContainer,text,fontcolor = null):
	var statLabel = statTemplate.duplicate()
	
	
	statLabel.visible = true
	statLabel.text = text
	
	if fontcolor != null:
		statLabel.set("custom_colors/font_color",fontcolor)
	scrollContainer.add_child(statLabel)
#adds a stat entry to scroll contain
#param: scrollContainer, container to add item to
#param: text, the flavor text descrbing stats
#param: value, the stat numeric value to display
func addStat(scrollContainer,text,member,playerState,playerName,playerHero,decimalsDisplayMask,footerNewRecordLabel):
	
	
	
	var newHeroRecordFlag=false
	#fetch value of player state member
	var value = playerState.get(member)
	
	value = stepify(value,decimalsDisplayMask)
	#check for new record
	if stats.isNewHeroStatRecord(playerHero,member,value):
		
		text = text + " (new hero record): "+str(value)
		newHeroRecordFlag=true
	elif playerName != null and stats.isNewPlayerNameHeroStatRecord(playerName,playerHero,member,value):
		text = text + " (new personal record): "+str(value)
		newHeroRecordFlag=true
	else:
		text = text + str(value)
	
	if newHeroRecordFlag:
		
		footerNewRecordLabel.text =NEW_RECORD_FOOTER_TEXT
		
		_addStat(scrollContainer,text,newRecordFontColor)
	else:
		_addStat(scrollContainer,text)
		
	return newHeroRecordFlag

func addStylePointsStat(scrollContainer,text,member,playerState,playerName,playerHero):
	
	var newHeroRecordFlag=false
	
	#fetch value of player state member
	var value = playerState.get(member)
	
	#check for new record
	if stats.isNewHeroStatStylePointsRecord(playerHero,member,value):
		
		text = text + " (new hero record): "+str(value)
		newHeroRecordFlag=true
	elif playerName != null and stats.isNewPlayerNameHeroStatStylePointsRecord(playerName,playerHero,member,value):
		newHeroRecordFlag=true
		text = text + " (new personal record): "+str(value)
	else:
		text = text + str(value)
	
	if newHeroRecordFlag:
		_addStat(scrollContainer,text,newRecordFontColor)
	else:
		_addStat(scrollContainer,text)



func renderStats(scrollContainer,playerState,playerName,playerHero,footerNewRecordLabel):
	
	var newRecordFlag=false
	var tmpNewRecord = false
	tmpNewRecord= addStat(scrollContainer,"Time ellapsed (seconds): ","matchSecondsEllapsed",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"Remaining HP: ","hp",playerState,playerName,playerHero,0.1,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	
	tmpNewRecord= addStat(scrollContainer,"# of Hits: ","totalNumHits",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"Best Combo: ","maxCombo",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"Avg. combo length: ","avgComboLength",playerState,playerName,playerHero,0.1,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"# of combos: ","numberOfCombos",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	
	
	tmpNewRecord= addStat(scrollContainer,"Best Combo Damage: ", "mostComboDamageDone",playerState,playerName,playerHero,0.1,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"Average Combo Damage: ","averageComboDamage",playerState,playerName,playerHero,0.2,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	#addStat(scrollContainer,"Total Star-based Bonus Damage: ","bonusDamage",playerState,playerName,playerHero,0.2)
	
	
	#addStat(scrollContainer,"Largest Combo Level: ","maxComboLevelAchieved",playerState,playerName,playerHero)	
	tmpNewRecord= addStat(scrollContainer,"# Magic Series Combos: ","numStarCompletionCombos",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	#addStat(scrollContainer,"# Star Creation Combos (empty stars): ","totalNumDamageComboLevelUps",playerState,playerName,playerHero,0)
	
	
	tmpNewRecord= addStat(scrollContainer,"# Ability Bar Chunks Gained: ","abilityBarChunksGained",playerState,playerName,playerHero,0.1,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"# Ability Bar Chunks Lost (from full bar): ","abilityBarChunksExcessLost",playerState,playerName,playerHero,0.1,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"Total # Ability Bar Chunks Used: ","totalAbilityBarUsed",playerState,playerName,playerHero,0.1,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	
	
	
	tmpNewRecord= addStat(scrollContainer,"# Guard Breaks: ","numGuardBreaks",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"# Blocks: ","numberOfBlocks",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"# Correct (low/high) Blocks: ","numberOfCorrectBlocks",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"# Incorrect (low/high) Blocks: ","numberOfIncorrectBlocks",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"# Perfect blocks: ","numberOfPerfectBlocks",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"Total Guard Damage Dealt: ","totalDamageDealthToGuard",playerState,playerName,playerHero,0.1,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	
	
	tmpNewRecord= addStat(scrollContainer,"# of Ability Cancels: ","abilityCancelCount",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"# Auto Ability Cancels: ","autoAbilityCancelCount",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"# Cancel-based Ability Bar Chunks Used: ","abilityCancelTotalChunksUsed",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"# Auto Ability Cancel-based Chunks Used: ","autoAbilityCancelTotalChunksUsed",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	

	
	tmpNewRecord= addStat(scrollContainer,"# Auto Riposts Attempted: ","numAutoRiposts",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"# Succesful Auto Riposts: ","numSuccesfulAutoRiposts",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	
		
	tmpNewRecord= addStat(scrollContainer,"# Attempted Riposts: ","numAttemptedRiposts",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"# Successful Riposts: ","numRiposts",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"# Attempted Counter Riposts: ","numAttemptedCounterRiposts",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	tmpNewRecord= addStat(scrollContainer,"# Successful Counter Riposts: ","numCounterRiposts",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	


	#addStat(scrollContainer,"Most Focus Stars: ","maxFocusComboLevelAchieved",playerState,playerName,playerHero)
#	addStat(scrollContainer,"# Focus Stars Earned: ","totalNumFocusComboLevelUps",playerState,playerName,playerHero)
	#addStat(scrollContainer,"Best Damage Gauge Amount: ","bestAchievedDamageGauge",playerState,playerName,playerHero)
	#addStat(scrollContainer,"Best Damage Gauge Capacity: ","bestAchieveddamageGaugeCapacity",playerState,playerName,playerHero)
	#addStat(scrollContainer,"Best Focus Amount: ","bestAchievedFocus",playerState,playerName,playerHero)
	#addStat(scrollContainer,"Best Focus Capacity: ","bestAchievedFocusCapacity",playerState,playerName,playerHero)

	#addStat(scrollContainer,"# of attempted auto ripost: ","numBlocks",playerState,playerName,playerHero)
	#addStat(scrollContainer,"# of Successful auto ripost: ","numSuccesfulBlocks",playerState,playerName,playerHero)
	#addStat(scrollContainer,"# of Failed Anti-Blocks: ","numberOfWhiffedGrabs",playerState,playerName,playerHero)
	#addStat(scrollContainer,"# of Successful Anti-Blocks: ","numberOfSuccessfulGrabs",playerState,playerName,playerHero)
	#addStat(scrollContainer,"Best Block Efficiency: ","bestBlockEfficiency",playerState,playerName,playerHero)
	#addStat(scrollContainer,"Worst Block Efficiency: ","worstBlockEfficiency",playerState,playerName,playerHero)

	#addStat(scrollContainer,"# of Failed Techs: ","numberOfFailedTechs",playerState,playerName,playerHero)
	
	tmpNewRecord= addStat(scrollContainer,"# of Techs: ","numberOfSuccessfulTechs",playerState,playerName,playerHero,0,footerNewRecordLabel)
	newRecordFlag=tmpNewRecord or newRecordFlag
	
	return newRecordFlag
	
func renderStyleStats(scrollContainer,playerState,playerName,playerHero):
	
	#old content below
	pass
#	addStylePointsStat(scrollContainer,"Remaining HP: ","hp",playerState,playerName,playerHero)
#	addStylePointsStat(scrollContainer,"Best Combo: ","maxCombo",playerState,playerName,playerHero)
#	addStylePointsStat(scrollContainer,"Most Damage Stars: ","maxComboLevelAchieved",playerState,playerName,playerHero)
#	addStylePointsStat(scrollContainer,"# Damage Stars Earned: ","totalNumDamageComboLevelUps",playerState,playerName,playerHero)
	
#	addStylePointsStat(scrollContainer,"# Focus Stars Earned: ","totalNumFocusComboLevelUps",playerState,playerName,playerHero)
#	addStylePointsStat(scrollContainer,"Best Damage Gauge Amount: ","bestAchievedDamageGauge",playerState,playerName,playerHero)
#	addStylePointsStat(scrollContainer,"Best Damage Gauge Capacity: ","bestAchieveddamageGaugeCapacity",playerState,playerName,playerHero)
	
#	addStylePointsStat(scrollContainer,"Best Combo Damage: ","mostComboDamageDone",playerState,playerName,playerHero)
#	addStylePointsStat(scrollContainer,"Total ability bar chunks used: ","totalAbilityBarUsed",playerState,playerName,playerHero)
#	addStylePointsStat(scrollContainer,"Canceling ability bar chunks used: ","abilityCancelTotalChunksUsed",playerState,playerName,playerHero)
#	addStylePointsStat(scrollContainer,"# of Ability Cancels: ","abilityCancelCount",playerState,playerName,playerHero)
	
func _physics_process(delta):
	
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	var hideVictoryInfoPaneFlag = false
	var displayPauseHUDFlag = false
	var playerPausing = null
	var opponentInputDeviceId = null
	var playerControllerPausing = null
	

	#online mode?
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		
		for pController in playerControllers:
			#during online match the game isnn't paused so input managers of player controler stil lprocessing
			#this way both peer and local can control pause hud
			var _inputMngr = pController.inputManager
			
	
		
			if _inputMngr.lastCommand == _inputMngr.Command.CMD_START or _inputMngr.lastCommand == _inputMngr.Command.CMD_JUMP:
				
				#at victory info screen?
				if vicotoryInfoPane.visible:
					hideVictoryInfoPaneFlag=true
				else:
					displayPauseHUDFlag=true
					playerControllerPausing= pController
					playerPausing=_inputMngr.inputDeviceId
			
	else:
		

	
		#process logic to skip student victory info screen or pause
		for player in inputDevices:
			
			if  Input.is_action_just_pressed(player+"_START") or Input.is_action_just_pressed(player+"_A"):
				#at victory info screen?
				if vicotoryInfoPane.visible:
					hideVictoryInfoPaneFlag=true
				else:
					displayPauseHUDFlag=true
					playerPausing=player
	
				
	if displayPauseHUDFlag:
		
		#determine what the input id of the opponent is
		if playerPausing == inputDevices[0]:
			opponentInputDeviceId=inputDevices[1]
			
			#onlnie mode this will be already set
			if playerControllerPausing ==null:
				playerControllerPausing=p1Controller
		else:
			opponentInputDeviceId=inputDevices[0]
			
			#onlnie mode this will be already set
			if playerControllerPausing ==null:
				playerControllerPausing=p2Controller
			
		pauseHUD.activate(playerPausing,opponentInputDeviceId,playerControllerPausing,GLOBALS.PauseMode.RESULT_SCREEN)
	
	if hideVictoryInfoPaneFlag:
		#hide victory scene
		vicotoryInfoPane.visible=false
		
		#play new record sfx when arrive at stats screen with new record
		if newRecordAcheived:
			newRecordAcheived=false
			soundSFXPlayer.playSound(NEW_RECORD_SOUND_IX)
	
	
	#online mode?
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		
					#let players scroll through stats	
		if p1Controller.inputManager.lastCommand == p1Controller.inputManager.Command.CMD_CROUCH:

			statsP1Container.scroll_vertical= statsP1Container.scroll_vertical + delta*scrollSpeed
			statsP1Container.update()# after changing the value of scroll_vertical
		elif p1Controller.inputManager.lastCommand == p1Controller.inputManager.Command.CMD_UP:
			statsP1Container.scroll_vertical= statsP1Container.scroll_vertical - delta*scrollSpeed
			statsP1Container.update()# after changing the value of scroll_vertical
			
		if p2Controller.inputManager.lastCommand == p2Controller.inputManager.Command.CMD_CROUCH:
			
			statsP2Container.scroll_vertical= statsP2Container.scroll_vertical + delta*scrollSpeed
			statsP2Container.update()# after changing the value of scroll_vertical
		elif p2Controller.inputManager.lastCommand == p2Controller.inputManager.Command.CMD_UP:
			statsP2Container.scroll_vertical= statsP2Container.scroll_vertical - delta*scrollSpeed
			statsP2Container.update()# after changing the value of scroll_vertical
			
	else:	
		var player1Input = inputDevices[0]
		var player2Input = inputDevices[1]
		
		#let players scroll through stats
		if Input.is_action_pressed(player1Input+"_DOWN"):
			
			statsP1Container.scroll_vertical= statsP1Container.scroll_vertical + delta*scrollSpeed
			statsP1Container.update()# after changing the value of scroll_vertical
		elif Input.is_action_pressed(player1Input+"_UP"):
			statsP1Container.scroll_vertical= statsP1Container.scroll_vertical - delta*scrollSpeed
			statsP1Container.update()# after changing the value of scroll_vertical
		elif Input.is_action_pressed(player1Input+"_RIGHT"):
			
			statsP1Container.scroll_horizontal= statsP1Container.scroll_horizontal + delta*scrollSpeed
			statsP1Container.update()# after changing the value of scroll_horizontal
		elif Input.is_action_pressed(player1Input+"_LEFT"):
			statsP1Container.scroll_horizontal= statsP1Container.scroll_horizontal - delta*scrollSpeed
			statsP1Container.update()# after changing the value of scroll_horizontal
			
				
		if Input.is_action_pressed(player2Input+"_DOWN"):
			
			statsP2Container.scroll_vertical= statsP2Container.scroll_vertical + delta*scrollSpeed
			statsP2Container.update()# after changing the value of scroll_vertical
		elif Input.is_action_pressed(player2Input+"_UP"):
			statsP2Container.scroll_vertical= statsP2Container.scroll_vertical - delta*scrollSpeed
			statsP2Container.update()# after changing the value of scroll_vertical
		elif Input.is_action_pressed(player2Input+"_RIGHT"):
			
			statsP2Container.scroll_horizontal= statsP2Container.scroll_horizontal + delta*scrollSpeed
			statsP2Container.update()# after changing the value of scroll_horizontal
		elif Input.is_action_pressed(player1Input+"_LEFT"):
			statsP2Container.scroll_horizontal= statsP2Container.scroll_horizontal - delta*scrollSpeed
			statsP2Container.update()# after changing the value of scroll_horizontal
				
			

	