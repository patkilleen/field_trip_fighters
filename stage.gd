extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal back_to_main_menu
signal back_to_online_lobby
signal back_to_proficiency_select
signal back_to_character_select
signal back_to_stage_select
signal game_ended
signal game_started
signal stage_ready
signal object_entered_screen
signal object_left_screen
signal save_ai_model
signal online_mode_match_started
signal game_count_down_finished 
signal game_starting
signal done_loading_game
signal save_replay
signal enabling_user_input
const KO_HIT_FREEZE_DURATION_IN_FRAMES = 45

const KO_GAME_SLOW_MOD = 0.05
const KO_GAME_SLOW_DURATION = 0.75

const KO_DURATION_WHERE_CAN_COMBO_BETWEEN_GAME_END=2
const GAME_ENDING_SOUND_ID = 0
const MATCH_START_SOUND_ID = 1
const TIMER_TICK_SOUND_ID = 2
const HALF_WAY_MARK_FIRST_PLAYER_SOUND_ID = 3
const HALF_WAY_MARK_SECOND_PLAYER_SOUND_ID = 4

const HYPNESS_VOLUMNE_RELATION_MOD = 4
const RIPOST_HYPE_GAINED_PER_SECOND = 1.0/25.0 # takes 25 seconds to recover from hype loss of ripsot
const MAXIMUM_RIPOST_HYPNESS_COUNT=3


const PATH_TO_HERO_THEME_SONGS = "res://assets/sounds/music/hero-themes/"
const SECONDS_PER_MINUTE = 60
const NUMBER_PRELOADED_MAGNIFYING_GLASSES = 16


const RIPOST_FLASH_DURATION_IN_SECONDS= 0.075
const RIPOST_FLASH_STRENGTH=0.5

const GRAB_FLASH_DURATION_IN_SECONDS = 0.05
const GRAB_FLASH_STRENGTH= 0.03
var GLOBALS = preload("res://Globals.gd")

const MyTweenResource = preload("res://MyTween.gd")

var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

var blockSFXResource = preload("res://particles/blockSfX.tscn")
var matchDataCollectorResource = preload("res://ai/MatchDataCollector.gd")

var leakyVariableResource = preload("res://leakyVariable.gd")

var player1DefaultState = null
var player2DefaultState = null

var playersNode = null

var p1SpawnPosition = null
var p2SpawnPosition = null

var p1CollisionInfo = null
var p2CollisionInfo = null

var specialSFXSoundPlayer = null


var ripostSFXSoundPlayer = null
var counterRipostSFXSoundPlayer = null

var onlineSyncIcon = null

var spriteSFXBuffer = []
var opponentSpriteSFXBuffer=[]
	
var koSlowMotionTween = null
var playersPaused = false
var player1 = null
var player2 = null
var pauseHUD = null
var hitFreezeTimer = null
var gameObjects = null
var anchorPoints = null
#var landingDustResource = preload("res://particles/LandingDust.tscn")
#var airDashingSfxResource = preload("res://particles/air-dash-sfx.tscn")
#var groundDashingSfxResource = preload("res://particles/ground-dash-sfx.tscn")
#var groundDashingSfxResource = preload("res://particles/attack-sfx/GroundDashDust.tscn")
#var groundDashCancelSfxResource = preload("res://particles/attack-sfx/GroundDashCancelDust.tscn")
#var jumpDustSfxResource = preload("res://particles/attack-sfx/jumpDust.tscn")
#var techSfxResource = preload("res://particles/attack-sfx/techSFX.tscn")
#var leaveGroundDustSfxResource=preload("res://particles/attack-sfx/leaveGroundDust.tscn")
#var airJumpDustSfxResource=preload("res://particles/attack-sfx/airJumpDust.tscn")

#var abilityCancelSwrilResource = preload("res://particles/abilityCancelSwirlParticles.tscn")
#var abilityCancelExplosionResource = preload("res://particles/abilityCancelExplosionParticles.tscn")
#var nmeleeSfxResource = preload("res://particles/attack-sfx/n-melee-hit-particles.tscn")
#var dimeleeSfxResource = preload("res://particles/attack-sfx/di-melee-hit-particles.tscn")
#var newAttackSFXResource = preload("res://particles/attack-sfx/newAttackSFX.tscn")
#var jumpDustSfxResource = preload("res://particles/attack-sfx/jumpDust.tscn")

var magifyingGlassResource = preload("res://interface/stage/magnifyingGlass.tscn")


const frameTimerResource = preload("res://frameTimer.gd")


var magnifyingGlassesDisabled = true
var matchTimer = null
#var replayHandler = null
var matchDataCollector = null


export (float) var floorCameraLimitOffset = 10
var gameEndDelay = 0.5
export (int) var gameEndFramePauseFrequency = 5
export (int) var notificationPanelDuration = 2 # 2 seconds of ui
export (int) var notificationKODuration = 0 # 0 seconds means indefinate of ui dislpaye
var endGameSlowMotionDuration = 3
var endGameSlowDownModifier = 0.5
var ripostSlowDownModifier = 0.25
var ripostSlowDownDurationInSeconds = 0.15
var ripostSlowDownRecoverDurationInSeconds = 0.15
var ripostInBetweenDurationInSeconds = 0.15 #duation game stays slow, before speedup

var KOSlowDownModifier = 0.5
var KOSlowDownDurationInSeconds = 1.5
var KOSlowDownRecoverDurationInSeconds = 1.5
var KOInBetweenDurationInSeconds = 1


var numPlayersReachedHalfHP =0
var jumpSfxTracker = null

export (float) var leftOffScreenOffset = 0
export (float) var rightOffScreenOffset = 0
export (float) var topOffScreenOffset = 15
#make sure magnifying glass doesn't happen for bottom, cause with gravity you won't be out of side for long
export (float) var botOffScreenOffset = -100 

export (bool) var falseCeilingEnabled = true

export (Color) var techableLandingDustModulate = Color(0,1.5,1.5,1)
export (Color) var untechableLandingDustModulate = Color(0.83,0,0.83,0.75)

export (float) var endMatchAmbienceVolumeIncrease=0




var gameMode = null #set by root node
var settings = null
var gameEnding = false

var pingLabel =null
var inputDelayLabel = null
var camera = null
var activeMagnifyingGlasses = {}

var offscreenObjects = {}

var cachedResourcesNode = null 

var matchCountDownLabel = null
var gameEndTimer=null
var counterRipostSFX = null
var ripostSFX = null

var musicPlayer = null
var player1ThemeMusicPlayer = null
var player2ThemeMusicPlayer = null
var ambienceMusic = null


var hitFreezeContainer = null

var flashRect = null
var stageSongIx = -1

var fadeOutRect = null

var p1HUD = null
var p2HUD = null

var p1DmgStarArray = null
var p2DmgStarArray = null

var slowingDownTimeFlag = false

var stageName = null
var largeHitTempSpriteTemplate = null

var enableStylePointsRoundFlag = false

var otherTypeHitSfx = null
var clashHitSfx = null

var tweenFlash = null

var boundingBox = null

var falseWallBgd = null
var falseWallBgd2 = null


var newAttackSFXBuffer = null
var blockSFXBuffer =null
var airDashSFXBuffer = null
var leaveGroundSFXBuffer = null
var jumpDustSFXBuffer = null
var airJumpDustSFXBuffer=null
var techSFXBuffer=null
var groundDashDustSFXBuffer=null
var groundDashCancelDustSFXBuffer=null
#var abilityCancelSwrilSFXBuffer = null
#var abilityCancelExplosionSFXBuffer =null


var timerState = null
const NORMAL_MATCH_TIMEOUT=0
const STYLE_POINT_ROUND_TIMEOUT=1

var fadeOutHUD = null


var debugSrc = null
var debugDst =null
var debugAngleLabel = null

var clashBubbleSfx = null
#var saveReplayFlag = false

var inHitFreeze = false

var ripostWaitTimer = null
var counterRipostWaitTimer = null
var matchEndTimer = null
var ripostAttemptedTimer = null
var countDownSequenceTimer = null

var player1BarGainLockSprite = null
var player2BarGainLockSprite =null

var fpsNode = null
var magnifyingGlassesNode = null

#var p1ComboUIAttackTypeController = null

var onlineSessionFirstMatch = true
var defaultMatchTime = 60*8 # 8 minutes
#var defaultMatchTime = 3#20 seconds
var stylePointRoundDefaultTimeLength = 15 #15 seconds

var crewBattleFlag = false
var crewBattleWinner = null
var crewBattleWinnerPlayerState = null #deep copy of player state

var ripostHypnessP1 = 0
var ripostHypnessP2 = 0
var defaultRipostCheerVolume = null

var trainAIFlag=null #will be set by root.gd

var hitSfxSpriteMap = {}

var spriteSFXNode = null
var uiLayerSpriteSFXNode = null


var p1MissingAbilityBarIcon=null
var p2MissingAbilityBarIcon=null

var amibenceMusicDefaultVolume=null

var cmdHitParticleBuffer=null 
func _ready():
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)

	camera = $Camera2D
	playersNode = $players
	p1SpawnPosition = $player1Spawn.position
	p2SpawnPosition = $player2Spawn.position
	p1CollisionInfo = $player1CollisionInfo
	p2CollisionInfo = $player2CollisionInfo
	counterRipostSFX = $counterRipostSFX
	magnifyingGlassesNode = $magnifyingGlasses
	specialSFXSoundPlayer = $speciaSFXSounds
	ripostSFXSoundPlayer = $ripostSoundPlayer
	counterRipostSFXSoundPlayer = $counterRipostSoundPlayer
	
	ripostWaitTimer = frameTimerResource.new()
	counterRipostWaitTimer = frameTimerResource.new()
	matchEndTimer= frameTimerResource.new()
	ripostAttemptedTimer=frameTimerResource.new()
	countDownSequenceTimer = frameTimerResource.new()
	add_child(ripostWaitTimer)
	add_child(counterRipostWaitTimer)
	add_child(matchEndTimer)
	add_child(ripostAttemptedTimer)
	add_child(countDownSequenceTimer)
	p1DmgStarArray = $"CanvasLayer/P1_HUD/NewDamageStarBar"
	p2DmgStarArray = $"CanvasLayer/P2_HUD/NewDamageStarBar"
	
	
	if has_node("AmbienceMusic"):
		ambienceMusic=get_node("AmbienceMusic")
		amibenceMusicDefaultVolume = ambienceMusic.volume_db
	koSlowMotionTween =MyTweenResource.new()	
	self.add_child(koSlowMotionTween)
	koSlowMotionTween.removeFromGlobalSpeedGroup()
	
	
	onlineSyncIcon = $"CanvasLayer/onlineSyncIcon"
	
	
	clashBubbleSfx = $clashBubbleSfx
	
	spriteSFXNode =$"sfxSprites"
	uiLayerSpriteSFXNode =$"falseWallBackground/uiLayerSfxSprites"
	
	flashRect = $CanvasLayer/flashRect
	
	defaultRipostCheerVolume = ripostSFXSoundPlayer.volume_db

	fpsNode = $"CanvasLayer/FPS"
	#replayHandler = $ReplayHandler
	
	cmdHitParticleBuffer =$"cmdHitParticleBuffer"
	newAttackSFXBuffer = $"attackSFXSpriteBuffer"
	blockSFXBuffer = $"blockSFXSpriteBuffer"
	airDashSFXBuffer=$"airDashSFXSpriteBuffer"
	leaveGroundSFXBuffer=$"leaveGroundSFXSpriteBuffer"
	jumpDustSFXBuffer=$"jumpDustSFXSpriteBuffer"
	airJumpDustSFXBuffer = $"airJumpDustSFXSpriteBuffer"	
	techSFXBuffer = $"techSFXSpriteBuffer"
	
	groundDashDustSFXBuffer=$"groundDashDustSFXSpriteBuffer"
	groundDashCancelDustSFXBuffer=$"groundDashCancelDustSFXSpriteBuffer"


	
		
	cachedResourcesNode = $"CanvasLayer/cachedResources"
	
	
	largeHitTempSpriteTemplate = $"largeHitTempSpriteTemplate"
	
	jumpSfxTracker = $jumpSfxTracker
	
	fadeOutHUD = $CanvasLayer/FadeOut_HUD
	#set up block and anti block timers
	#gameEndTimer = Timer.new()
	#gameEndTimer.one_shot = true #set to true to indicate don't conitune ticking (only executed once called)
	#self.add_child(gameEndTimer)
	
	hitSfxSpriteMap[GLOBALS.MELEE_IX]=$meleeHitSFX
	hitSfxSpriteMap[GLOBALS.SPECIAL_IX]=$specialHitSFX
	hitSfxSpriteMap[GLOBALS.TOOL_IX]=$toolHitSFX
	otherTypeHitSfx = $otherHitSFX
	clashHitSfx = $clashHitSfx
	ripostSFX = $ripostSFX
	matchTimer  = $"CanvasLayer/match-timer"
	matchTimer.connect("timeout",self,"_on_match_timer_timeout")
	matchTimer.connect("ten_second_remaining",self,"_on_ten_seconds_remaining")
	matchTimer.init(self)
	
	
	tweenFlash = MyTweenResource.new()
	self.add_child(tweenFlash)
	
	
	pauseHUD = $PauseLayer
	pauseHUD.connect("restart_game",self,"_on_start_match")
	pauseHUD.connect("back_to_online_lobby",self,"_on_back_to_online_lobby")
	pauseHUD.connect("back_to_main_menu",self,"_on_back_to_main_menu")
	pauseHUD.connect("back_to_proficiency_select",self,"_on_back_to_proficiency_select")
	pauseHUD.connect("back_to_character_select",self,"_on_back_to_character_select")
	pauseHUD.connect("back_to_stage_select",self,"_on_back_to_stage_select")
	pauseHUD.connect("save_replay",self,"_on_save_replay")
	pauseHUD.connect("resumed",self,"_on_game_resumed")
	
	
	musicPlayer = $musicPlayer
	
	player1ThemeMusicPlayer = $player1ThemeMusicPlayer
	player2ThemeMusicPlayer = $player2ThemeMusicPlayer
	
	gameObjects = $gameObjects
	anchorPoints = $anchorPoints
	
	player1BarGainLockSprite = $"CanvasLayer/P1_HUD/abilityGainLockSprite"
	player2BarGainLockSprite = $"CanvasLayer/P2_HUD/abilityGainLockSprite"

	hitFreezeContainer = $"CanvasLayer/hitFreezeControl"
	
	
	

	fadeOutRect = $CanvasLayer/FadeOut_HUD/ColorRect
	
	gameEndTimer = frameTimerResource.new()
	#gameEndTimer.one_shot = true #set to true to indicate don't conitune ticking (only executed once called)
	#self.call_deferred("add_child",gameEndTimer)
	add_child(gameEndTimer)
	gameEndTimer.removeFromGlobalSpeedGroup()
	
	
	emit_signal("stage_ready")
	pass

	
func setGlobalSpeedMod(g):
	globalSpeedMod = g
	
func initCamera():
	
			
	#https://github.com/godotengine/godot/issues/1912
	#~5 played around with camera boundaries. it's a bug finnaly. so gave up on the nice camera... (even godot 3.3.3 dooesn't fix bug)
	#https://www.reddit.com/r/godot/comments/4fkjrk/camera_zoom_affecting_limit/
	
	var boundariesRect = $cameraBoundaries
	var limit_bottom = boundariesRect.rect_position.y + boundariesRect.rect_size.y
	var limit_top = boundariesRect.rect_position.y
	var limit_right = boundariesRect.rect_position.x + boundariesRect.rect_size.x
	var limit_left = boundariesRect.rect_position.x

	var initialPosition =Vector2(boundariesRect.rect_position.x + (boundariesRect.rect_size.x/2),boundariesRect.rect_position.y + (boundariesRect.rect_size.y/2)) # center camera
	$Camera2D.init(limit_bottom,limit_top,limit_right,limit_left,playersNode,$boundingBox,initialPosition,gameMode)
	
	boundingBox = $Camera2D.boundingBox
	boundingBox.init($Camera2D,player1,player2)
	#disable false ceiling?
	if not falseCeilingEnabled:
		
		$Camera2D.boundingBox.ceiling.disable()
		$Camera2D.boundingBox.ceiling.disablePermanently = true
	

func init(_player1,_player2):	
	
	player1=_player1
	player2=_player2
	
	
	loadHeroThemeSong(player1,player2)
	
	playersNode.init(player1,player2)
	
	p1HUD = $CanvasLayer/P1_HUD
	p2HUD = $CanvasLayer/P2_HUD
	
	
	pauseHUD.init(settings,player1.playerController,player2.playerController)
	
	#set the player id in top left and top right
	p1HUD.playerId = _player1.heroName
	p2HUD.playerId = _player2.heroName
	
	
	#setupt the hero-specific HUD elements
	if _player1.heroName == GLOBALS.BELT_HERO_NAME:
		 p1HUD.beltAngryHUD = $"CanvasLayer/P1_HUD/heroStateInfo/belt-angry"
	
	elif _player1.heroName == GLOBALS.WHISTLE_HERO_NAME:
		p1HUD.whistleHUD = $"CanvasLayer/P1_HUD/heroStateInfo/whistle"
		
	#	p1HUD.micOperaHUD = $"CanvasLayer/P1_HUD/heroStateInfo/mic/pink-note"
	elif _player1.heroName == GLOBALS.GLOVE_HERO_NAME:	
		p1HUD.gloveActiveBallHUD = $"CanvasLayer/P1_HUD/heroStateInfo/glove/active-ball"
		p1HUD.gloveBrokenStringHUD = $"CanvasLayer/P1_HUD/heroStateInfo/glove/broken-string"
	
	elif _player1.heroName == GLOBALS.HAT_HERO_NAME:	
		p1HUD.hatHUD = $"CanvasLayer/P1_HUD/heroStateInfo/hat"
		


	if _player2.heroName == GLOBALS.BELT_HERO_NAME:
		 p2HUD.beltAngryHUD = $"CanvasLayer/P2_HUD/heroStateInfo/belt-angry"
	elif _player2.heroName == GLOBALS.WHISTLE_HERO_NAME:
		p2HUD.whistleHUD = $"CanvasLayer/P2_HUD/heroStateInfo/whistle"
		
	elif _player2.heroName == GLOBALS.GLOVE_HERO_NAME:	
		p2HUD.gloveActiveBallHUD = $"CanvasLayer/P2_HUD/heroStateInfo/glove/active-ball"
		p2HUD.gloveBrokenStringHUD = $"CanvasLayer/P2_HUD/heroStateInfo/glove/broken-string"
	
	elif _player2.heroName == GLOBALS.HAT_HERO_NAME:	
		p2HUD.hatHUD = $"CanvasLayer/P2_HUD/heroStateInfo/hat"
	
		
	p1HUD.init()
	p2HUD.init()
	
	
	p1HUD.connectPlayerStateToTrainingModeElements(player1,player2)
	p2HUD.connectPlayerStateToTrainingModeElements(player2,player1)

	p1HUD.notifyciationPanel.applyFacing(true)
	p2HUD.notifyciationPanel.applyFacing(false)
	
	
	#p1HUD.setProficiencies(player1.advProf,player1.disProf)
	#p2HUD.setProficiencies(player2.advProf,player2.disProf)
	p1HUD.setProficiencies(player1.majorProf1Ix,player1.minorProf1Ix,player1.majorProf2Ix,player1.minorProf2Ix)
	p2HUD.setProficiencies(player2.majorProf1Ix,player2.minorProf1Ix,player2.majorProf2Ix,player2.minorProf2Ix)

	
	
	
	#make sure to initialize all the particles data models
	for c in cmdHitParticleBuffer.get_children():
		
		c.init()
	
		
	#make sure the ability cancel particles don't pause in hitfreeze
#	for c in abilityCancelSwrilSFXBuffer.get_children():
#		c.pauseOnHitFreeze=false
#	for c in abilityCancelExplosionSFXBuffer.get_children():
#		c.pauseOnHitFreeze=false
		
	
	jumpSfxTracker.init(player1,player2)
	
	falseWallBgd = $falseWallBackground/background
	falseWallBgd2 = $falseWallBackground/background2

	#
	p1HUD.hpBar.setFillRightToLeft()
	#p1HUD.guardHPBar.fill_mode= p1HUD.guardHPBar.FILL_RIGHT_TO_LEFT

	pauseHUD.gameMode = gameMode
	
	hitFreezeContainer.init(gameMode)
	
	matchCountDownLabel = $CanvasLayer/HBoxContainer/matchCountdown
	matchCountDownLabel.visible = false
	
	
	
	
	#preload a buffer of magnifying glasses
	for i in NUMBER_PRELOADED_MAGNIFYING_GLASSES:
	
		var mg = magifyingGlassResource.instance()
		magnifyingGlassesNode.add_child(mg)
		mg.disable()
	
	
	initCamera()
	
	largeHitTempSpriteTemplate.init(self,$Camera2D,boundingBox)
	
	self.connect("object_entered_screen",self,"_on_object_entered_screen")
	self.connect("object_left_screen",self,"_on_object_left_screen")
	
	#$Camera2D/players.connect("game_ended",self,"_on_game_ended")
	#$Camera2D/players.connect("game_ending",self,"_on_game_ending")
	
	$players.connect("game_ended",self,"_on_game_ended")
	$players.connect("game_ending",self,"_on_game_ending")
	
	#save the match data only for pvp matches
	if gameMode == GLOBALS.GameModeType.STANDARD or gameMode == GLOBALS.GameModeType.PLAY_V_AI:
		matchDataCollector = matchDataCollectorResource.new()
		matchDataCollector.init(GLOBALS.MATCH_DATA_COLLECTION_OUTPUT_DIR,player1.playerController,player2.playerController,stageName)
		pass
	elif gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		
		#have spinning icon when match first syncs
		onlineSyncIcon.visible=true
		onlineSyncIcon.set_physics_process(true)
		
		var pingNode = $CanvasLayer/ping
		pingNode.visible = true
		pingLabel = $CanvasLayer/ping/counter
		
		var inputdelayNode = $CanvasLayer/inputdelay
		inputdelayNode.visible = true
		inputDelayLabel = $CanvasLayer/inputdelay/counter
		
	call_deferred("add_child",matchDataCollector)
	
	#connect the pause hud to controller cnx signals to allow displaying error messages
	var player1InputManager = player1.get_node("PlayerController/InputManager")
	var player2InputManager = player2.get_node("PlayerController/InputManager")
	
	player1InputManager.connect("controller_disconnected",pauseHUD,"_on_controller_disconnected")
	player1InputManager.connect("controller_connected",pauseHUD,"_on_controller_connected")
	player2InputManager.connect("controller_disconnected",pauseHUD,"_on_controller_disconnected")
	player2InputManager.connect("controller_connected",pauseHUD,"_on_controller_connected")
	
	
	
		
	#player1.playerController.connect("pause",self,"_on_pause")
	#player2.playerController.connect("pause",self,"_on_pause")
	
	player1.playerController.connect("inactive_projectile_instanced",self,"_on_inactive_projectile_instanced",[player1])
	player2.playerController.connect("inactive_projectile_instanced",self,"_on_inactive_projectile_instanced",[player2])
	
	
	
	connect("done_loading_game",player1.playerController,"_on_done_loading_game")
	connect("done_loading_game",player2.playerController,"_on_done_loading_game")
	
	
	var p1ComboUIAttackTypeController = p1HUD.comboPanel.get_node("VBoxContainer/MagicSeriesComboLevelHUD/controller")
	var p2ComboUIAttackTypeController = p2HUD.comboPanel.get_node("VBoxContainer/MagicSeriesComboLevelHUD/controller")
	var p1FocusComboUIAttackTypeController = p1HUD.comboPanel.get_node("VBoxContainer/ReverseBeatComboLevelHUD/controller")
	var p2FocusComboUIAttackTypeController = p2HUD.comboPanel.get_node("VBoxContainer/ReverseBeatComboLevelHUD/controller")
	
	p1MissingAbilityBarIcon=p1HUD.get_node("missingAbilityBar")
	p2MissingAbilityBarIcon=p2HUD.get_node("missingAbilityBar")
	player1.playerController.connect("insufficient_ability_bar",self,"_on_insufficient_ability_bar",[p1MissingAbilityBarIcon])
	player2.playerController.connect("insufficient_ability_bar",self,"_on_insufficient_ability_bar",[p2MissingAbilityBarIcon])
	
	#connect player states to time ellapsed
	matchTimer.connect("second_ellapsed",player1.playerController.playerState,"setMatchSecondsEllapsed")
	matchTimer.connect("second_ellapsed",player2.playerController.playerState,"setMatchSecondsEllapsed")
	
	player1.playerController.connect("create_anchor_point",self,"_on_create_anchor_point")
	player1.playerController.connect("destroy_anchor_point",self,"_on_destroy_anchor_point")
	
		
	player2.playerController.connect("create_anchor_point",self,"_on_create_anchor_point")
	player2.playerController.connect("destroy_anchor_point",self,"_on_destroy_anchor_point")
	
	
	player1.playerController.connect("cmd_attack_hit",self,"displayAttackCommandParticles",[player1])
	player2.playerController.connect("cmd_attack_hit",self,"displayAttackCommandParticles",[player2])
	
	#uncomment this to view follow movemenet source, destination, and radius
	#var debugFollowMvmDrawNode = $followDebugDraw
	#debugFollowMvmDrawNode.init(player1,player2)
	
	player1.playerController.connect("player_state_info_text_changed",p1HUD,"updateHeroStateInfoText")	
	player1.playerController.actionAnimeManager.spriteAnimationManager.connect("display_global_temporary_sprites",self,"_on_display_global_temporary_sprites",[player1])
	player2.playerController.actionAnimeManager.spriteAnimationManager.connect("display_global_temporary_sprites",self,"_on_display_global_temporary_sprites",[player2])
	
	player1.playerController.frame_analyzer.connect("animation_frame_data",p1HUD,"_on_animation_frame_data")
	
	player1.connect("create_projectile",self,"_on_create_projectile")
	player1.playerController.playerState.connect("hp_changed",p1HUD,"setHP")
	player1.playerController.connect("start_hitfreeze",self,"startHitFreeze")
	p1HUD.connect("dmg_circular_progress_newly_activated",player1.playerController.comboHandler,"updateDamageGaugeNextHit_nextCombo")
	#p1HUD.connect("focus_circular_progress_newly_activated",player1.playerController.comboHandler,"updateFocusNextHit_nextCombo")
	#player1.playerController.playerState.connect("damage_gauge_changed",p1HUD,"setDamageGauge")
	player1.playerController.playerState.connect("damage_gauge_changed",self,"_on_damage_gauge_changed",[p1HUD])
	player1.playerController.playerState.connect("damage_gauge_next_hit_changed",self,"_on_damage_gauge_next_hit_changed",[p1HUD])
	player1.playerController.playerState.connect("damage_gauge_capacity_changed",self,"_on_damage_gauge_capacity_changed",[p1HUD])
	player1.playerController.playerState.connect("damage_gauge_reached_capacity",self,"_on_damage_gauge_reached_capacity",[p1HUD])
	player1.playerController.connect("counter_hit",self,"_on_counter_hit",[player1])
	player1.playerController.connect("punish",self,"_on_punish",[player1])
	
	
	player1.playerController.playerState.connect("num_filled_dmg_stars_changed",p1DmgStarArray,"_on_num_filled_dmg_stars_changed")
	player1.playerController.playerState.connect("num_empty_dmg_stars_changed",p1DmgStarArray,"_on_num_empty_dmg_stars_changed")
	player1.playerController.playerState.connect("combo_level_changed",p1DmgStarArray,"_on_combo_level_changed")
	player2.playerController.connect("ripost",p1DmgStarArray,"_on_riposted") #on player 2 ripost, remove stars
	player1.playerController.guardHandler.connect("guard_broken",p1DmgStarArray,"_on_guard_broken")
	player1.playerController.playerState.connect("fill_combo_sub_level_changed",p1DmgStarArray,"_on_fill_combo_sub_level_changed")
	
	player1.playerController.collisionHandler.connect("player_attack_clashed",self,"_on_player_attack_clashed")
	player1.playerController.collisionHandler.connect("pushed_against_wall",self,"_on_pushed_against_wall",[player1])
	player1.playerController.collisionHandler.connect("pushed_against_ceiling",self,"_on_pushed_against_ceiling",[player1])
	#player1.playerController.playerState.connect("guard_lock_changed",p1HUD.guardHPBar,"setTransparent")


	#player1.playerController.connect("start_damage_gauge_generation_tracking",p1HUD.damageGaugeBar,"_on_start_tracking_damage_gain")
	#player1.playerController.playerState.connect("start_damage_gauge_generation_tracking",p1HUD.damageGaugeBar,"_on_start_tracking_damage_gain")
	player1.playerController.connect("start_damage_gauge_generation_tracking",p1HUD.comboPanel.dmgProgress,"activate")
	player1.playerController.playerState.connect("start_damage_gauge_generation_tracking",p1HUD.comboPanel.dmgProgress,"activate")
	player1.playerController.playerState.connect("damage_gauge_generation_combo_count_changed",p1HUD.comboPanel.dmgProgress,"_on_increase_resource_combo_change")	
	#player1.playerController.playerState.connect("focus_changed",self,"_on_focus_changed",[p1HUD])
	#player1.playerController.playerState.connect("focus_next_hit_changed",self,"_on_focus_next_hit_changed",[p1HUD])
	#player1.playerController.playerState.connect("focus_capacity_changed",self,"_on_focus_capacity_changed",[p1HUD])
	#player1.playerController.playerState.connect("focus_reached_capacity",self,"_on_focus_reached_capacity",[p1HUD])
	#player1.playerController.connect("start_focus_generation_tracking",p1HUD.focusBar,"_on_start_tracking_damage_gain")
	#player1.playerController.connect("start_focus_generation_tracking",p1HUD.comboPanel.focusProgress,"activate")
	#player1.playerController.playerState.connect("start_focus_generation_tracking",p1HUD.comboPanel.focusProgress,"activate")
	#player1.playerController.playerState.connect("focus_generation_combo_count_changed",p1HUD.comboPanel.focusProgress,"_on_increase_resource_combo_change")	
	player1.playerController.playerState.connect("ability_bar_changed",self,"_on_ability_bar_changed",[p1HUD])
	
	player1.playerController.connect("display_block_sfx",self,"_on_display_block_sfx")
	
	#p1HUD.guardHPBar.max_value =player1.maxGuardHP
	p1HUD.guardHPBar.setMax(player1.maxGuardHP)
	
	#p1HUD.guardHPBar.value =player1.guardHP
	p1HUD.guardHPBar.guardSetAmount(player1.guardHP,player1.guardHP)
	#p1HUD.guardHPBar.setAmount(player1.guardHP)
	
	player1.playerController.playerState.connect("guard_regen_buff_flag_changed",p1HUD.guardHPBar.guardRegenBuffBar,"_on_guard_regen_boost_change")
	player1.playerController.connect("guard_regen_buffed_enabled",p1HUD.guardHPBar.guardRegenBuffBar,"_on_guard_regen_buffed_enabled")
	
	player1.playerController.playerState.connect("guardHP_changed",p1HUD,"_on_guard_hp_changed")
	
	
	player1.playerController.connect("display_attack_lighting",self,"_on_display_attack_lighting")
	
	player1.playerController.playerState.connect("abilit_bar_gain_lock_changed",player1BarGainLockSprite,"set_visible")
	
	#player1.playerController.comboHandler.dmgIncreaseHandler.connect("unlock_circular_progress",p1HUD.circularDamageProgress,"setTransparancy",[false])
	#player1.playerController.comboHandler.dmgIncreaseHandler.connect("lock_circular_progress",p1HUD.circularDamageProgress,"setTransparancy",[true])
	#player1.playerController.comboHandler.dmgIncreaseHandler.connect("lock_circular_progress",p1HUD.comboPanel,"setDmgIncreaseLockVisibility",[true])
	#player1.playerController.comboHandler.dmgIncreaseHandler.connect("unlock_circular_progress",p1HUD.comboPanel,"setDmgIncreaseLockVisibility",[false])
	player1.playerController.comboHandler.dmgIncreaseHandler.connect("unlock_circular_progress",p1HUD.comboPanel.dmgProgress,"setTransparancy",[false])
	player1.playerController.comboHandler.dmgIncreaseHandler.connect("lock_circular_progress",p1HUD.comboPanel.dmgProgress,"setTransparancy",[true])
	player1.playerController.comboHandler.dmgIncreaseHandler.connect("lock_circular_progress",p1HUD.comboPanel,"setDmgIncreaseLockVisibility",[true])
	player1.playerController.comboHandler.dmgIncreaseHandler.connect("unlock_circular_progress",p1HUD.comboPanel,"setDmgIncreaseLockVisibility",[false])
	player1.playerController.playerState.connect("negative_level_changed",p1HUD.anitCampingIcon,"_on_negative_level_changed")
	
	player1.playerController.connect("pre_ability_bar_gain",p1HUD.abilityBar,"_on_start_tracking_ability_gain")
	player1.playerController.connect("ability_bar_gain_finished",p1HUD.abilityBar,"_on_stop_tracking_ability_gain")

	player1.playerController.collisionHandler.connect("player_was_hit_collision_info",self,"_on_player_was_hit_collision_info",[player1])
	player1.playerController.playerState.connect("combo_level_changed",p1HUD.comboPanel.dmgProgress,"_on_combo_level_changed")
	
	#player1.playerController.comboHandler.focusIncreaseHandler.connect("reset_bar_amount_increase_process",p1HUD.circularFocusProgress,"reset")
	if not player1.playerController.comboHandler.dmgIncreaseHandler.is_connected("lock_circular_progress",p1HUD.comboPanel,"setDmgIncreaseLockVisibility"):
		player1.playerController.comboHandler.dmgIncreaseHandler.connect("lock_circular_progress",p1HUD.comboPanel,"setDmgIncreaseLockVisibility",[true])
	if not player1.playerController.comboHandler.dmgIncreaseHandler.is_connected("lock_circular_progress",p1HUD.comboPanel,"setDmgIncreaseUnlockVisibility"):
		player1.playerController.comboHandler.dmgIncreaseHandler.connect("lock_circular_progress",p1HUD.comboPanel,"setDmgIncreaseUnlockVisibility",[false])
	if not player1.playerController.comboHandler.dmgIncreaseHandler.is_connected("unlock_circular_progress",p1HUD.comboPanel,"setDmgIncreaseLockVisibility"):
		player1.playerController.comboHandler.dmgIncreaseHandler.connect("unlock_circular_progress",p1HUD.comboPanel,"setDmgIncreaseLockVisibility",[false])
	player1.playerController.comboHandler.dmgIncreaseHandler.connect("unlock_circular_progress",p1HUD.comboPanel,"setDmgIncreaseUnlockVisibility",[true])
	#player1.playerController.comboHandler.focusIncreaseHandler.connect("lock_circular_progress",p1HUD.comboPanel,"setFocusIncreaseLockVisibility",[true])
	#player1.playerController.comboHandler.focusIncreaseHandler.connect("lock_circular_progress",p1HUD.comboPanel,"setFocusIncreaseUnlockVisibility",[false])
	#player1.playerController.comboHandler.focusIncreaseHandler.connect("unlock_circular_progress",p1HUD.comboPanel,"setFocusIncreaseLockVisibility",[false])
	#player1.playerController.comboHandler.focusIncreaseHandler.connect("unlock_circular_progress",p1HUD.comboPanel,"setFocusIncreaseUnlockVisibility",[true])
	
	#player1.playerController.playerState.connect("combo_level_changed",p1HUD.stars,"addDamageStar")
	#player1.playerController.playerState.connect("focus_combo_level_changed",p1HUD.stars,"addFocusStar")
	player1.playerController.playerState.connect("sub_combo_level_changed",p1HUD.subCombos,"_on_sub_combo_level_changed")
	
	player1.playerController.playerState.connect("sub_combo_level_changed",p1HUD.comboPanel,"_on_magic_series_sub_combo_level_changed",[player1.playerController.playerState])	
	player1.playerController.playerState.connect("focus_sub_combo_level_changed",p1HUD.comboPanel,"_on_reverse_beat_sub_combo_level_changed",[player1.playerController.playerState])	

	player1.playerController.playerState.connect("focus_combo_level_changed",p1ComboUIAttackTypeController,"_on_opposite_combo_level_changed")
	player1.playerController.playerState.connect("combo_level_changed",p1FocusComboUIAttackTypeController,"_on_opposite_combo_level_changed")
		
	#player1.playerController.playerState.connect("focus_sub_combo_level_changed",p1HUD.subCombos,"_on_focus_sub_combo_level_changed")
	player1.playerController.playerState.connect("block_cooldown_changed",p1HUD.blockIcon,"startCooldownAnimation",[player1.blockCooldownTime])
	#player1.playerController.playerState.connect("grab_cooldown_changed",p1HUD.antiBlockIcon,"startCooldownAnimation",[player1.grabCooldownTime])
	#player1.playerController.playerState.connect("grab_cooldown_changed",p1HUD,"_on_grab_cooldown_changed")
	player1.playerController.playerState.connect("grab_cooldown_changed",self,"_on_grab_cooldown_changed",[player1,p1HUD])
	player1.playerController.playerState.connect("combo_changed",p1HUD,"setCombo")
	player1.playerController.playerState.connect("max_combo_changed",p1HUD,"setMaxCombo")
	player1.playerController.playerState.connect("changed_combo_damage",p1HUD,"setComboDamage")
	player1.playerController.playerState.connect("block_efficiency_changed",p1HUD,"setBlockEfficiency")
	player1.playerController.connect("cmd_action_changed",p1HUD.cmdList,"displayCommand")
	#player1.playerController.connect("ripost_attempted",p1HUD.ripostNotification,"commandAttempt")
	player1.playerController.connect("ripost_attempted",self,"_on_riposted_attempted",[player1])
	#player1.playerController.connect("ripost_attempted",self,"startRipostParticles",[player1])
	player1.playerController.connect("counter_ripost_attempted",p1HUD.counterRipostNotification,"commandAttempt")
	#player1.playerController.connect("counter_ripost_attempted",self,"startCounterRipostParticles",[player1])
	player1.playerController.connect("counter_ripost_attempted",self,"_on_counter_ripost_attempted",[player1])
	player1.playerController.connect("start_tracking_frame_duration",self,"_on_start_tracking_frame_duration",[player1])	
	player1.playerController.connect("tech",self,"_on_tech",[player1])
	player1.playerController.connect("failed_tech",self,"_on_failed_tech",[player1])
	player1.playerController.connect("ability_cancel",self,"_on_ability_cancel",[player1])
	player1.playerController.connect("grabbed_in_block",self,"_on_grabbed_in_block",[player2])
	player1.playerController.connect("grabbed_auto_riposter",self,"_on_grabbed_auto_riposter",[player1])
	player1.playerController.connect("hit_armored_opponent",self,"_on_hit_armored_opponent",[player2]) #player 2 since hitting opponent means player 2 armored
	player1.playerController.connect("clash",self,"_on_clash",[player1])
	player1.playerController.connect("push_blocked",self,"_on_push_blocked",[player1])
	player1.playerController.connect("fill_combo",self,"_on_fill_combo",[player1])
	player1.playerController.connect("combo_level_up",self,"_on_combo_level_up",[player1])	
	player1.playerController.connect("reverse_beat_combo_level_up",self,"_on_reverse_beat_combo_level_up",[player1])		
	player1.playerController.connect("auto_ripost",self,"_on_auto_ripost",[player1])
	player1.playerController.connect("parry",self,"_on_parry",[player1])
	player1.playerController.connect("block_stun_string",self,"_on_block_stun_string",[player1])
	player1.playerController.connect("clash_break",self,"_on_clash_break",[player1])
	player1.playerController.connect("reversal",self,"_on_reversal",[player1])
	player1.playerController.connect("hit_invincibility_opponent",self,"_on_was_hit_in_invincibility",[player2])
	player1.playerController.connect("incorrect_block_unblockable",self,"_on_incorrect_block_unblockable",[player2])
	
	player1.playerController.guardHandler.connect("perfect_block",self,"_on_perfect_block",[player1])
	player1.playerController.guardHandler.connect("guard_broken",self,"_on_guard_broken",[player1])
	
	
	player1.playerController.connect("attack_type_hit",p1ComboUIAttackTypeController,"_on_hit")
	player1.playerController.playerState.connect("changed_in_hitstun",p2ComboUIAttackTypeController,"_on_hitstun_changed")
	player1.playerController.connect("attack_type_hit",p1FocusComboUIAttackTypeController,"_on_hit")
	player1.playerController.playerState.connect("changed_in_hitstun",p2FocusComboUIAttackTypeController,"_on_hitstun_changed")
	
	player1.playerController.guardHandler.connect("guard_regen_lock_changed",p1HUD.guardHPBar,"_on_guard_regen_lock_changed")
	
	player1.playerController.playerState.connect("insufficient_ability_bar",p1HUD,"setUnderAbilityBarWithTimeout")
	player1.playerController.connect("insufficient_ability_bar",p1HUD,"setUnderAbilityBarWithTimeout")
	player1.playerController.connect("ability_bar_cancel_cost_display",p1HUD.abilityBar,"displayUnderlines")
	player1.playerController.connect("ability_bar_cancel_cost_hide",p1HUD.abilityBar,"hideUnderlines")
	
	player1.playerController.connect("starting_new_combo",p1HUD.comboPanel.abilityBarFeedingHUD,"reset")
	#P2HUD, since the PLAYEcontroller signaling bar feeding is the one being fed
	player1.playerController.connect("feeding_ability_bar",p2HUD.comboPanel.abilityBarFeedingHUD,"inreaseBarFed")
	
	player1.playerController.connect("reached_half_hp",self,"_on_player_reached_half_hp",[player1])
	
	
	player1.playerController.connect("pause",self,"_on_pause")
	#p2 hud since when player 1 in hitstun, show combo of other player
	player1.playerController.playerState.connect("changed_in_hitstun",p2HUD.comboPanel,"setVisibility")
	player1.playerController.playerState.connect("changed_in_hitstun",p2HUD.comboPanel.dmgProgress,"_on_hitstun_changed")
	#player1.playerController.playerState.connect("changed_in_hitstun",p2HUD.comboPanel.focusProgress,"_on_hitstun_changed")
	#player1.playerController.playerState.connect("changed_in_hitstun",self,"_clearStars", [p2HUD])
	player1.playerController.playerState.connect("changed_in_hitstun",p1HUD,"clearRed",[player1.playerController.playerState])
	#player1.playerController.playerState.connect("changed_in_hitstun",self,"_onHitStunChanged",[player1.playerController.playerState,p1HUD])
	
	#player1.playerController.connect("enable_red_hp",p1HUD,"clearRed",[player1.playerController.playerState])
	#player1.playerController.connect("display_red_hp",p1HUD,"setUnderHPBar")
	player1.playerController.connect("display_red_hp",self,"enableTempRedHP",[player1.playerController.playerState,p1HUD])
	#player1.playerController.connect("clear_red_hp",p1HUD,"clearRed",[false,player1.playerController.playerState])
	player1.playerController.connect("clear_red_hp",self,"clearRedNow",[player1.playerController.playerState,p1HUD])
	player1.playerController.connect("jumped",self,"_on_player_jumped",[player1])
	player1.playerController.connect("air_dashed",self,"_on_player_air_dahsed",[player1])
	player1.playerController.connect("ground_dash_cancel",self,"_on_ground_dash_cancel",[player1])
	player1.playerController.connect("ground_dashed",self,"_on_player_ground_dahsed",[player1])
	player1.playerController.connect("landed",self,"_on_player_landed",[player1])
	player1.playerController.collisionHandler.connect("left_ground",self,"_on_player_left_ground",[player1])
	
	player1.playerController.actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_sprite_animation_played",[p1HUD])
	player1.playerController.actionAnimeManager.spriteAnimationManager.connect("sprite_frame_activated",self,"_on_sprite_frame_activated",[p1HUD])
	
	
	player2.playerController.frame_analyzer.connect("animation_frame_data",p2HUD,"_on_animation_frame_data")
	
	player2.connect("create_projectile",self,"_on_create_projectile")
	player2.playerController.connect("start_hitfreeze",self,"startHitFreeze")
	player2.playerController.playerState.connect("hp_changed",p2HUD,"setHP")
	p2HUD.connect("dmg_circular_progress_newly_activated",player2.playerController.comboHandler,"updateDamageGaugeNextHit_nextCombo")
	#p2HUD.connect("focus_circular_progress_newly_activated",player2.playerController.comboHandler,"updateFocusNextHit_nextCombo")

	player2.playerController.connect("player_state_info_text_changed",p2HUD,"updateHeroStateInfoText")
	
	player2.playerController.connect("counter_hit",self,"_on_counter_hit",[player2])
	player2.playerController.connect("punish",self,"_on_punish",[player2])
	player2.playerController.playerState.connect("num_empty_dmg_stars_changed",p2DmgStarArray,"_on_num_empty_dmg_stars_changed")
	player2.playerController.playerState.connect("num_filled_dmg_stars_changed",p2DmgStarArray,"_on_num_filled_dmg_stars_changed")
	player2.playerController.playerState.connect("combo_level_changed",p2DmgStarArray,"_on_combo_level_changed")
	player2.playerController.playerState.connect("focus_combo_level_changed",p2ComboUIAttackTypeController,"_on_opposite_combo_level_changed")
	player2.playerController.playerState.connect("combo_level_changed",p2FocusComboUIAttackTypeController,"_on_opposite_combo_level_changed")
	
	player1.playerController.connect("ripost",p2DmgStarArray,"_on_riposted")#on player 1 riposted, remove stars
	player2.playerController.guardHandler.connect("guard_broken",p2DmgStarArray,"_on_guard_broken")
	player2.playerController.playerState.connect("fill_combo_sub_level_changed",p2DmgStarArray,"_on_fill_combo_sub_level_changed")
	#player2.playerController.playerState.connect("guard_lock_changed",p2HUD.guardHPBar,"setTransparent")
	
	player2.playerController.collisionHandler.connect("player_was_hit_collision_info",self,"_on_player_was_hit_collision_info",[player2])
	player2.playerController.guardHandler.connect("guard_regen_lock_changed",p2HUD.guardHPBar,"_on_guard_regen_lock_changed")
	
	player2.playerController.playerState.connect("negative_level_changed",p2HUD.anitCampingIcon,"_on_negative_level_changed")
	
	player2.playerController.playerState.connect("abilit_bar_gain_lock_changed",player2BarGainLockSprite,"set_visible")
	player2.playerController.connect("incorrect_block_unblockable",self,"_on_incorrect_block_unblockable",[player1])
	
	player2.playerController.connect("pre_ability_bar_gain",p2HUD.abilityBar,"_on_start_tracking_ability_gain")
	player2.playerController.connect("ability_bar_gain_finished",p2HUD.abilityBar,"_on_stop_tracking_ability_gain")
	#player2.playerController.playerState.connect("damage_gauge_changed",p2HUD,"setDamageGauge")
	player2.playerController.playerState.connect("damage_gauge_changed",self,"_on_damage_gauge_changed",[p2HUD])
	player2.playerController.playerState.connect("damage_gauge_next_hit_changed",self,"_on_damage_gauge_next_hit_changed",[p2HUD])
	player2.playerController.playerState.connect("damage_gauge_capacity_changed",self,"_on_damage_gauge_capacity_changed",[p2HUD])
	player2.playerController.playerState.connect("damage_gauge_reached_capacity",self,"_on_damage_gauge_reached_capacity",[p2HUD])
	player2.playerController.playerState.connect("damage_gauge_generation_combo_count_changed",p2HUD.comboPanel.dmgProgress,"_on_increase_resource_combo_change")	
	#player2.playerController.connect("start_damage_gauge_generation_tracking",p2HUD.damageGaugeBar,"_on_start_tracking_damage_gain")
	#player2.playerController.playerState.connect("start_damage_gauge_generation_tracking",p2HUD.damageGaugeBar,"_on_start_tracking_damage_gain")
	player2.playerController.connect("start_damage_gauge_generation_tracking",p2HUD.comboPanel.dmgProgress,"activate")
	player2.playerController.playerState.connect("start_damage_gauge_generation_tracking",p2HUD.comboPanel.dmgProgress,"activate")
	#player2.playerController.playerState.connect("start_focus_generation_tracking",p2HUD.focusBar,"_on_start_tracking_damage_gain")
	#player2.playerController.connect("start_focus_generation_tracking",p2HUD.focusBar,"_on_start_tracking_damage_gain")
	#player2.playerController.playerState.connect("focus_changed",self,"_on_focus_changed",[p2HUD])
	#player2.playerController.playerState.connect("focus_next_hit_changed",self,"_on_focus_next_hit_changed",[p2HUD])
	#player2.playerController.playerState.connect("focus_capacity_changed",self,"_on_focus_capacity_changed",[p2HUD])
	#player2.playerController.playerState.connect("focus_reached_capacity",self,"_on_focus_reached_capacity",[p2HUD])
	#player2.playerController.connect("start_focus_generation_tracking",p2HUD.comboPanel.focusProgress,"activate")
	#player2.playerController.playerState.connect("start_focus_generation_tracking",p2HUD.comboPanel.focusProgress,"activate")
	#player2.playerController.playerState.connect("focus_generation_combo_count_changed",p2HUD.comboPanel.focusProgress,"_on_increase_resource_combo_change")	
	player2.playerController.connect("display_block_sfx",self,"_on_display_block_sfx")
	player2.playerController.collisionHandler.connect("pushed_against_wall",self,"_on_pushed_against_wall",[player2])
	player2.playerController.collisionHandler.connect("pushed_against_ceiling",self,"_on_pushed_against_ceiling",[player2])
	#player2.playerController.comboHandler.dmgIncreaseHandler.connect("reset_bar_amount_increase_process",p2HUD.circularDamageProgress,"reset")
	#player2.playerController.comboHandler.dmgIncreaseHandler.connect("unlock_circular_progress",p2HUD.circularDamageProgress,"setTransparancy",[false])
	#player2.playerController.comboHandler.dmgIncreaseHandler.connect("lock_circular_progress",p2HUD.circularDamageProgress,"setTransparancy",[true])
	#player2.playerController.comboHandler.focusIncreaseHandler.connect("reset_bar_amount_increase_process",p2HUD.circularFocusProgress,"reset")
	#player2.playerController.comboHandler.focusIncreaseHandler.connect("unlock_circular_progress",p2HUD.circularFocusProgress,"setTransparancy",[false])
	#player2.playerController.comboHandler.focusIncreaseHandler.connect("lock_circular_progress",p2HUD.circularFocusProgress,"setTransparancy",[true])
	
	#player2.playerController.comboHandler.dmgIncreaseHandler.connect("lock_circular_progress",p2HUD.comboPanel,"setDmgIncreaseLockVisibility",[true])
	#player2.playerController.comboHandler.dmgIncreaseHandler.connect("lock_circular_progress",p2HUD.comboPanel,"setDmgIncreaseUnlockVisibility",[false])
	#player2.playerController.comboHandler.dmgIncreaseHandler.connect("unlock_circular_progress",p2HUD.comboPanel,"setDmgIncreaseLockVisibility",[false])
	#player2.playerController.comboHandler.dmgIncreaseHandler.connect("unlock_circular_progress",p2HUD.comboPanel,"setDmgIncreaseUnlockVisibility",[true])
	
	player2.playerController.connect("reached_half_hp",self,"_on_player_reached_half_hp",[player2])
	
	player2.playerController.connect("display_attack_lighting",self,"_on_display_attack_lighting")
	player2.playerController.collisionHandler.connect("player_attack_clashed",self,"_on_player_attack_clashed")
	
	player2.playerController.comboHandler.dmgIncreaseHandler.connect("unlock_circular_progress",p2HUD.comboPanel.dmgProgress,"setTransparancy",[false])
	player2.playerController.comboHandler.dmgIncreaseHandler.connect("lock_circular_progress",p2HUD.comboPanel.dmgProgress,"setTransparancy",[true])
	player2.playerController.comboHandler.dmgIncreaseHandler.connect("lock_circular_progress",p2HUD.comboPanel,"setDmgIncreaseLockVisibility",[true])
	player2.playerController.comboHandler.dmgIncreaseHandler.connect("unlock_circular_progress",p2HUD.comboPanel,"setDmgIncreaseLockVisibility",[false])
	
	
	player2.playerController.connect("start_tracking_frame_duration",self,"_on_start_tracking_frame_duration",[player2])
	player2.playerController.playerState.connect("combo_level_changed",p2HUD.comboPanel.dmgProgress,"_on_combo_level_changed")
	#player2.playerController.comboHandler.focusIncreaseHandler.connect("lock_circular_progress",p2HUD.comboPanel,"setFocusIncreaseLockVisibility",[true])
	#player2.playerController.comboHandler.focusIncreaseHandler.connect("lock_circular_progress",p2HUD.comboPanel,"setFocusIncreaseUnlockVisibility",[false])
	#player2.playerController.comboHandler.focusIncreaseHandler.connect("unlock_circular_progress",p2HUD.comboPanel,"setFocusIncreaseLockVisibility",[false])
	#player2.playerController.comboHandler.focusIncreaseHandler.connect("unlock_circular_progress",p2HUD.comboPanel,"setFocusIncreaseUnlockVisibility",[true])
	
	
	
	player2.playerController.connect("attack_type_hit",p2ComboUIAttackTypeController,"_on_hit")
	player2.playerController.playerState.connect("changed_in_hitstun",p1ComboUIAttackTypeController,"_on_hitstun_changed")
	player2.playerController.connect("attack_type_hit",p2FocusComboUIAttackTypeController,"_on_hit")
	player2.playerController.playerState.connect("changed_in_hitstun",p1FocusComboUIAttackTypeController,"_on_hitstun_changed")
	
	
	player2.playerController.playerState.connect("ability_bar_changed",self,"_on_ability_bar_changed",[p2HUD])
	
	#player2.playerController.playerState.connect("combo_level_changed",p2HUD.stars,"addDamageStar")
	#player2.playerController.playerState.connect("focus_combo_level_changed",p2HUD.stars,"addFocusStar")
	player2.playerController.playerState.connect("sub_combo_level_changed",p2HUD.subCombos,"_on_sub_combo_level_changed")	
	#player2.playerController.playerState.connect("focus_sub_combo_level_changed",p2HUD.subCombos,"_on_focus_sub_combo_level_changed")	
	
	player2.playerController.playerState.connect("sub_combo_level_changed",p2HUD.comboPanel,"_on_magic_series_sub_combo_level_changed",[player2.playerController.playerState])	
	player2.playerController.playerState.connect("focus_sub_combo_level_changed",p2HUD.comboPanel,"_on_reverse_beat_sub_combo_level_changed",[player2.playerController.playerState])	
	
	
	player2.playerController.playerState.connect("block_cooldown_changed",p2HUD.blockIcon,"startCooldownAnimation",[player2.blockCooldownTime])
#	player2.playerController.playerState.connect("grab_cooldown_changed",p2HUD.antiBlockIcon,"startCooldownAnimation",[player2.grabCooldownTime])
#	player2.playerController.playerState.connect("grab_cooldown_changed",p2HUD,"_on_grab_cooldown_changed")
	player2.playerController.playerState.connect("grab_cooldown_changed",self,"_on_grab_cooldown_changed",[player2,p2HUD])
	player2.playerController.playerState.connect("combo_changed",p2HUD,"setCombo")
	player2.playerController.playerState.connect("max_combo_changed",p2HUD,"setMaxCombo")
	player2.playerController.playerState.connect("changed_combo_damage",p2HUD,"setComboDamage")
	player2.playerController.playerState.connect("block_efficiency_changed",p2HUD,"setBlockEfficiency")
	player2.playerController.connect("cmd_action_changed",p2HUD.cmdList,"displayCommand")
	#player2.playerController.connect("display_red_hp",p2HUD,"setUnderHPBar")
	player2.playerController.connect("display_red_hp",self,"enableTempRedHP",[player2.playerController.playerState,p2HUD])
	
	player2.playerController.connect("jumped",self,"_on_player_jumped",[player2])
	player2.playerController.connect("air_dashed",self,"_on_player_air_dahsed",[player2])
	player2.playerController.connect("ground_dash_cancel",self,"_on_ground_dash_cancel",[player2])
	player2.playerController.connect("ground_dashed",self,"_on_player_ground_dahsed",[player2])
	player2.playerController.connect("landed",self,"_on_player_landed",[player2])
	player2.playerController.collisionHandler.connect("left_ground",self,"_on_player_left_ground",[player2])
	
	#player2.playerController.connect("ripost_attempted",p2HUD.ripostNotification,"commandAttempt")
	#player2.playerController.connect("ripost_attempted",self,"startRipostParticles",[player2])
	player2.playerController.connect("ripost_attempted",self,"_on_riposted_attempted",[player2])
	player2.playerController.connect("counter_ripost_attempted",p2HUD.counterRipostNotification,"commandAttempt")
	#player2.playerController.connect("counter_ripost_attempted",self,"startCounterRipostParticles",[player2])
	player2.playerController.connect("counter_ripost_attempted",self,"_on_counter_ripost_attempted",[player2])
	player2.playerController.connect("tech",self,"_on_tech",[player2])
	player2.playerController.connect("failed_tech",self,"_on_failed_tech",[player2])
	player2.playerController.connect("ability_cancel",self,"_on_ability_cancel",[player2])
	player2.playerController.connect("grabbed_in_block",self,"_on_grabbed_in_block",[player1])
	player2.playerController.connect("grabbed_auto_riposter",self,"_on_grabbed_auto_riposter",[player2])
	player2.playerController.connect("hit_armored_opponent",self,"_on_hit_armored_opponent",[player1])#player 1 since hitting opponent means player 1 armored
	player2.playerController.connect("clash",self,"_on_clash",[player2])
	player2.playerController.connect("push_blocked",self,"_on_push_blocked",[player2])
	player2.playerController.connect("fill_combo",self,"_on_fill_combo",[player2])
	player2.playerController.connect("combo_level_up",self,"_on_combo_level_up",[player2])
	player2.playerController.connect("reverse_beat_combo_level_up",self,"_on_reverse_beat_combo_level_up",[player2])	
	player2.playerController.connect("block_stun_string",self,"_on_block_stun_string",[player2])
	player2.playerController.connect("auto_ripost",self,"_on_auto_ripost",[player2])
	player2.playerController.connect("parry",self,"_on_parry",[player2])
	player2.playerController.connect("clash_break",self,"_on_clash_break",[player2])
	player2.playerController.connect("reversal",self,"_on_reversal",[player2])
	player2.playerController.connect("hit_invincibility_opponent",self,"_on_was_hit_in_invincibility",[player1])
	
	player2.playerController.guardHandler.connect("perfect_block",self,"_on_perfect_block",[player2])
	player2.playerController.guardHandler.connect("guard_broken",self,"_on_guard_broken",[player2])
	
	#p2HUD.guardHPBar.max_value =player2.maxGuardHP
	#p2HUD.guardHPBar.value =player2.guardHP
	p2HUD.guardHPBar.setMax(player2.maxGuardHP)
	
	
	#p1HUD.guardHPBar.value =player1.guardHP
	p2HUD.guardHPBar.guardSetAmount(player2.guardHP,player2.guardHP)
	
	player2.playerController.playerState.connect("guard_regen_buff_flag_changed",p2HUD.guardHPBar.guardRegenBuffBar,"_on_guard_regen_boost_change")
	player2.playerController.connect("guard_regen_buffed_enabled",p2HUD.guardHPBar.guardRegenBuffBar,"_on_guard_regen_buffed_enabled")
	
	player2.playerController.playerState.connect("guardHP_changed",p2HUD,"_on_guard_hp_changed")
	
	player2.playerController.playerState.connect("insufficient_ability_bar",p2HUD,"setUnderAbilityBarWithTimeout")
	player2.playerController.connect("insufficient_ability_bar",p2HUD,"setUnderAbilityBarWithTimeout")
	player2.playerController.connect("ability_bar_cancel_cost_display",p2HUD.abilityBar,"displayUnderlines")
	player2.playerController.connect("ability_bar_cancel_cost_hide",p2HUD.abilityBar,"hideUnderlines")
	
	player2.playerController.actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_sprite_animation_played",[p2HUD]) 
	player2.playerController.actionAnimeManager.spriteAnimationManager.connect("sprite_frame_activated",self,"_on_sprite_frame_activated",[p2HUD])
	
	player2.playerController.connect("starting_new_combo",p2HUD.comboPanel.abilityBarFeedingHUD,"reset")
	#P1HUD, since the PLAYEcontroller signaling bar feeding is the one being fed
	player2.playerController.connect("feeding_ability_bar",p1HUD.comboPanel.abilityBarFeedingHUD,"inreaseBarFed")
	
	#p1 hud since when player 2 in hitstun, show combo of other player
	player2.playerController.playerState.connect("changed_in_hitstun",p1HUD.comboPanel,"setVisibility")
	player2.playerController.playerState.connect("changed_in_hitstun",p1HUD.comboPanel.dmgProgress,"_on_hitstun_changed")
	#player2.playerController.playerState.connect("changed_in_hitstun",p1HUD.comboPanel.focusProgress,"_on_hitstun_changed")
	#player2.playerController.playerState.connect("changed_in_hitstun",self,"_clearStars", [p1HUD])
	player2.playerController.playerState.connect("changed_in_hitstun",p2HUD,"clearRed",[player2.playerController.playerState])
	#player2.playerController.connect("clear_red_hp",p2HUD,"clearRed",[false,player2.playerController.playerState])
	player2.playerController.connect("clear_red_hp",self,"clearRedNow",[player2.playerController.playerState,p2HUD])
	player2.playerController.connect("pause",self,"_on_pause")
	
	
	p1HUD.blockEfficiencyElem.init(player1.playerController.playerState.blockEfficiency,player1.playerController.playerState.maxBlockEff,player1.playerController.playerState.minBlockEff)
	p2HUD.blockEfficiencyElem.init(player2.playerController.playerState.blockEfficiency,player2.playerController.playerState.maxBlockEff,player2.playerController.playerState.minBlockEff)
	
	p1HUD.hpBar.setMaximum(player1.playerController.playerState.hp)
	p1HUD.setHP(player1.playerController.playerState.hp)
	p2HUD.hpBar.setMaximum(player2.playerController.playerState.hp)
	p2HUD.setHP(player2.playerController.playerState.hp)
	
	p1HUD.hpBar.setUnderBarAmount(player1.playerController.playerState.hp)
	p2HUD.hpBar.setUnderBarAmount(player2.playerController.playerState.hp)
	
	#func init(playerIx,_capacity,_amount,_chunkSize):
	p1HUD.abilityBar.init(p1HUD.abilityBar.PLAYER1_IX,
	player1.playerController.playerState.abilityBarMaximum,
	player1.playerController.playerState.abilityBar,
	player1.playerController.playerState.abilityChunkSize)
	
	
	
	#p1HUD.abilityBar.numberOfChunks = player1.playerController.playerState.abilityNumberOfChunks
	#p1HUD.abilityBar.setMaximum(player1.playerController.playerState.abilityBarMaximum)
	#p1HUD.setAbility(player1.playerController.playerState.abilityBar)
	#p1HUD.comboPanel.abilityBarFeedingHUD.chunkSize = p1HUD.abilityBar.chunkSize
	p1HUD.comboPanel.abilityBarFeedingHUD.chunkSize = player1.playerController.playerState.abilityChunkSize
	p1HUD.abilityBar.enableParticles=true
	
	p1HUD.ripostAbilityStatusHUD.init(player1.playerController.ripostingAbilityBarCost*player1.playerController.playerState.abilityChunkSize,player1.playerController.playerState.abilityBar)
	p1HUD.autoRipostAbilityStatusHUD.init(player1.playerController.autoRipostAbilityBarCost*player1.playerController.playerState.abilityChunkSize,player1.playerController.playerState.abilityBar)
	p1HUD.counterRipostAbilityStatusHUD.init(player1.playerController.counterRipostingAbilityBarCost*player1.playerController.playerState.abilityChunkSize,player1.playerController.playerState.abilityBar)
	
	p2HUD.abilityBar.init(p1HUD.abilityBar.PLAYER2_IX,
	player2.playerController.playerState.abilityBarMaximum,
	player2.playerController.playerState.abilityBar,
	player2.playerController.playerState.abilityChunkSize)
	p2HUD.abilityBar.enableParticles=true
	
	p2HUD.ripostAbilityStatusHUD.init(player2.playerController.ripostingAbilityBarCost*player2.playerController.playerState.abilityChunkSize,player2.playerController.playerState.abilityBar)
	p2HUD.autoRipostAbilityStatusHUD.init(player2.playerController.autoRipostAbilityBarCost*player2.playerController.playerState.abilityChunkSize,player2.playerController.playerState.abilityBar)
	p2HUD.counterRipostAbilityStatusHUD.init(player2.playerController.counterRipostingAbilityBarCost*player2.playerController.playerState.abilityChunkSize,player2.playerController.playerState.abilityBar)
	
	p1HUD.setDamageGauge(player1.playerController.playerState.damageGauge)
#	p1HUD.damageGaugeBar.setMaximum(player1.playerController.playerState.damageGauge)
	p2HUD.setDamageGauge(player2.playerController.playerState.damageGauge)
	
	p1HUD.damageGaugeBar.maxDamageGauge = player1.maxDamageGauge
	p2HUD.damageGaugeBar.maxDamageGauge = player2.maxDamageGauge
	
	
	#hitFreezeTimer = $hitFreezeTimer
	hitFreezeTimer = frameTimerResource.new()
	self.add_child(hitFreezeTimer)
	#hitFreezeTimer.connect("hit_freeze_finished",self,"_on_hit_freeze_finished")
	hitFreezeTimer.connect("timeout",self,"_on_hit_freeze_finished")
	
	
	p1HUD.dmgProrationBar.connectToPlayerStateDamageSignals(player1.playerController.playerState)
	p2HUD.dmgProrationBar.connectToPlayerStateDamageSignals(player2.playerController.playerState)
	#p1HUD.focusProrationBar.connectToPlayerStateFocusSignals(player1.playerController.playerState)
	#p2HUD.focusProrationBar.connectToPlayerStateFocusSignals(player2.playerController.playerState)
	
	matchCountDownLabel.init()
	
	
#	if _player1.heroName == GLOBALS.MICROPHONE_HERO_NAME:
	
		#by default in rap stance when game starts
#		p1HUD.updateHeroStateInfoText(GLOBALS.MIC_NOTIFICATION_TEXT_RAP)
		
		
#	if _player2.heroName == GLOBALS.MICROPHONE_HERO_NAME:
	
		#by default in rap stance when game starts
#		p2HUD.updateHeroStateInfoText(GLOBALS.MIC_NOTIFICATION_TEXT_RAP)
		
	set_physics_process(true)

func _on_done_loading_game():
	
	emit_signal("done_loading_game")
	
func loadHeroThemeSong(player1,player2):
	
	var p1HeroName = player1.heroName
	var p2HeroName = player2.heroName
	
	#resolve path to theme song (its <heroname>.wav)
	player1ThemeMusicPlayer.soundFilePath = PATH_TO_HERO_THEME_SONGS+p1HeroName+".wav"
	player2ThemeMusicPlayer.soundFilePath = PATH_TO_HERO_THEME_SONGS+p2HeroName+".wav"
	
	#load the theme song of the players
	player1ThemeMusicPlayer.loadSound()
	player2ThemeMusicPlayer.loadSound()




func stopStageMusic(keepAmbienceFlag=false):
	musicPlayer.stopAll()
	player1ThemeMusicPlayer.stop()
	player2ThemeMusicPlayer.stop()
	
	#only stop ambience sounds if it exists for this stage and the ambience flag isn't set
	if ambienceMusic!=null and not keepAmbienceFlag:
		ambienceMusic.stop()
		
	
	
func clearRedNow(playerState,hud):
	hud.setRedHP(playerState.hp)
	
func enableTempRedHP(playerState,hud):
	hud.delayedSetRedHP(playerState)
#func displayRedHPWithTimeout(playerState,hud):
#	hud.delayedSetRedHP(playerState.hp,RED_HP_CLEAR_TIMEOUT_IN_SECONDS)

func lookupPlayerHUD(player):
	
	if player == player1:
		return p1HUD
	elif player == player2:
		return p2HUD
	else:
		return null
		
#func clearRedHP(playerState,hud):
#	hud.setRedHP(playerState.hp)
	
#iterate through all active game objects (exlucding those attached to playr)
#and see if any are off screen to add magnifying glass
func offScreenObjectsCheck():
	

	#add all the game object for checking magnifying glass into an array, so 
	#don't have to repeat code, just itreate the objects
	for o in gameObjects.get_children():
		var isProjectileFlag = true
		var player =o.masterPlayerController.kinbody
		_offScreenObjectsCheck(isProjectileFlag,player, o)
	for o in player1.gameObjects.get_children():
		var isProjectileFlag = true
		_offScreenObjectsCheck(isProjectileFlag,player1, o)
	for o in player2.gameObjects.get_children():
		var isProjectileFlag = true
		_offScreenObjectsCheck(isProjectileFlag,player2, o)
	
	var isProjectileFlag = false
	#the players now
	_offScreenObjectsCheck(false,player1, player1)
	_offScreenObjectsCheck(false,player2, player2)
	
	
func _offScreenObjectsCheck(isProjectileFlag,player, gameObj):
	
	#game object outside screen
	if camera.isOutsideCamera(gameObj.global_position,rightOffScreenOffset,leftOffScreenOffset,topOffScreenOffset,botOffScreenOffset):
		
		#first time leaving or leaving once again?	
		if (not offscreenObjects.has(gameObj)) or offscreenObjects[gameObj] == false: 
			
			offscreenObjects[gameObj] =true
			var objectOwner = player #for now, unused
			emit_signal("object_left_screen",isProjectileFlag,player,gameObj)
			
	else:
		#first time entering screen (spawned outside camera) or entering once again?	
		if (not offscreenObjects.has(gameObj)) or offscreenObjects[gameObj] == true: 
			
			offscreenObjects[gameObj] =false
			var objectOwner = player #for now, unused
			emit_signal("object_entered_screen",isProjectileFlag,player,gameObj)

func _on_object_left_screen(isProjectileFlag,player,obj):
	
	if magnifyingGlassesDisabled:
		return
	
	#player left screen?
	if not isProjectileFlag:
		var screenCenter = camera.computeScreenCenter()
		
		var exitedScreenLeftSide=player.position.x < screenCenter.x #determine side left screen suing camera center and player position
		var screenRect = camera.computeScreenRect2D()
		player.playerController._on_player_left_screen(exitedScreenLeftSide,screenRect)
		
	#ignore first param for now, can be used to style 
	#magnifying glasses based on what player (or other thign)
	#left screen
	if obj.offScreenMagnifyingGlass:
		
		var mg = null
		
		#this shouldn't happen, but just to be save
		if activeMagnifyingGlasses.has(obj) and activeMagnifyingGlasses[obj] != null:
			
			#remove the referecen, we will just create new ones as we go along
			#to avoid holding states
			activeMagnifyingGlasses[obj].disable()
			activeMagnifyingGlasses[obj] = null
			
			
		
		#find an inactive magnifying glass from pool
		for _mg in magnifyingGlassesNode.get_children():
			
			#found one?
			if not _mg.enabled:
				mg = _mg
		
		if mg == null:
			print("error: magnifying glass buffer overflow. Too many object leaving screen")
			return
		
		#record it for future lookup using the object that left screen
		activeMagnifyingGlasses[obj] =mg
		
		
		#obj.connect("changed_sprite_facing",mg,"_on_changed_sprite_facing")
		#obj.connect("new_sprite_position",mg,"_on_new_sprite_position")
		
		
		#make a shallow copy (reference to texture that is update by spritemanager) of sprite
		var targetSprite = obj.sprite
		var targetNode2D = obj
		
		if player1 == player:
			#initialize it
			mg.enable(targetSprite, targetNode2D, camera,obj,isProjectileFlag,mg.PLAYER1,obj.spriteCurrentlyFacingRight)
		elif player2 == player:
			#initialize it
			mg.enable(targetSprite, targetNode2D, camera,obj,isProjectileFlag,mg.PLAYER2,obj.spriteCurrentlyFacingRight)
		else:
			print("warning, trying create magnifying glass without owner")

#func _on_object_left_screen(isProjectileFlag,player,obj):
	
	#ignore first param for now, can be used to style 
	#magnifying glasses based on what player (or other thign)
	#left screen
#	if obj.offScreenMagnifyingGlass:
		
#		var mg = null
		
		#this shouldn't happen, but just to be save
#		if magnifyingGlasses.has(obj) and magnifyingGlasses[obj] != null:
			
			#remove the referecen, we will just create new ones as we go along
			#to avoid holding states
#			magnifyingGlasses[obj].disable()
#			self.remove_child(magnifyingGlasses[obj])
			
		 #have to create a new magnifying glass
		#create new magnifying glass
#		mg = magifyingGlassResource.instance()
		
		
		#record it for future lookup using the object that left screen
#		magnifyingGlasses[obj] =mg
		
#		self.add_child(mg)
		
#		obj.connect("changed_sprite_facing",mg,"_on_changed_sprite_facing")
		#obj.connect("new_sprite_position",mg,"_on_new_sprite_position")
		
		
		#make a shallow copy (reference to texture that is update by spritemanager) of sprite
#		var targetSprite = obj.sprite
#		var targetNode2D = obj
#		
#		if player1 == player:
#			#initialize it
#			mg.enable(targetSprite, targetNode2D, camera,obj,isProjectileFlag,mg.PLAYER1,obj.spriteCurrentlyFacingRight)
#		elif player2 == player:
#			#initialize it
#			mg.enable(targetSprite, targetNode2D, camera,obj,isProjectileFlag,mg.PLAYER2,obj.spriteCurrentlyFacingRight)
#		else:
#			print("warning, trying create magnifying glass without owner")


func _on_object_entered_screen(isProjectileFlag,player,obj):
	
	destroyMagnifyingGlass(obj)
	
func _on_create_projectile(projectile,projectileOwner,player):
	
	#ignore null projetiles
	if projectile ==null:
		return
#	var facingRight = player.facingRight
#	var cmd = playerController.actionAnimeManager.commandActioned
#	var ripostingWindow = playerController.ripostHandler.ripostingReactWindow
	
	#debugSrc = projectile
	#debugDst=player
	#debugAngleLabel = Label.new()
	#projectile.add_child(debugAngleLabel)
	projectile.collision_mask = 0
	projectile.collision_layer = 0
		
	#resolve what collision layer is opponent's and which is the player creating projectile
	var opponentPushableBodyBoxCollisionLayerBit = GLOBALS.PLAYER2_PUSHABLE_BODYBOX_LAYER_BIT
	var playerPushableBodyBoxCollisionLayerBit = GLOBALS.PLAYER1_PUSHABLE_BODYBOX_LAYER_BIT
	var opponenteBodyBoxCollisionBit= GLOBALS.PLAYER2_BODYBOX_LAYER_BIT
	var playerBodyBoxCollisionBit= GLOBALS.PLAYER1_BODYBOX_LAYER_BIT
	var playerStageCollisionLayerBit = GLOBALS.PLAYER1_STAGE_COLLISION_LAYER_BIT
	var opponentStageCollisionLayerBit = GLOBALS.PLAYER2_STAGE_COLLISION_LAYER_BIT
	var playerStageFloorCollisionLayerBit = GLOBALS.PLAYER1_STAGE_FLOOR_COLLISION_LAYER_BIT
	var opponentStageFloorCollisionLayerBit = GLOBALS.PLAYER2_STAGE_FLOOR_COLLISION_LAYER_BIT
	var playerFalseWallStageCollisionLayerBit = GLOBALS.PLAYER1_FALSE_WALL_STAGE_COLLISION_LAYER_BIT
	var opponentFalseWallStageCollisionLayerBit = GLOBALS.PLAYER2_FALSE_WALL_STAGE_COLLISION_LAYER_BIT
	var playerFalseCeilingStageCollisionLayerBit = GLOBALS.PLAYER1_FALSE_CEILING_STAGE_COLLISION_LAYER_BIT
	var opponentFalseCeilingStageCollisionLayerBit = GLOBALS.PLAYER2_FALSE_CEILING_STAGE_COLLISION_LAYER_BIT
	var playerPlatformCollisionLayerBit = GLOBALS.PLAYER1_PLATFORM_LAYER_BIT
	var opponentPlatformCollisionLayerBit = GLOBALS.PLAYER2_PLATFORM_LAYER_BIT
	


	if player == player2:
		opponentPushableBodyBoxCollisionLayerBit = GLOBALS.PLAYER1_PUSHABLE_BODYBOX_LAYER_BIT
		playerPushableBodyBoxCollisionLayerBit = GLOBALS.PLAYER2_PUSHABLE_BODYBOX_LAYER_BIT
		opponenteBodyBoxCollisionBit= GLOBALS.PLAYER1_BODYBOX_LAYER_BIT
		playerBodyBoxCollisionBit= GLOBALS.PLAYER2_BODYBOX_LAYER_BIT
		playerStageCollisionLayerBit = GLOBALS.PLAYER2_STAGE_COLLISION_LAYER_BIT
		playerStageFloorCollisionLayerBit = GLOBALS.PLAYER2_STAGE_FLOOR_COLLISION_LAYER_BIT
		opponentStageCollisionLayerBit = GLOBALS.PLAYER1_STAGE_COLLISION_LAYER_BIT
		opponentStageFloorCollisionLayerBit = GLOBALS.PLAYER1_STAGE_FLOOR_COLLISION_LAYER_BIT
		playerPlatformCollisionLayerBit = GLOBALS.PLAYER2_PLATFORM_LAYER_BIT
		opponentPlatformCollisionLayerBit = GLOBALS.PLAYER1_PLATFORM_LAYER_BIT
		playerFalseWallStageCollisionLayerBit = GLOBALS.PLAYER2_FALSE_WALL_STAGE_COLLISION_LAYER_BIT
		opponentFalseWallStageCollisionLayerBit = GLOBALS.PLAYER1_FALSE_WALL_STAGE_COLLISION_LAYER_BIT
		

	#depending on projectile type, change it's body box masks and layer
	if projectile.behaviorType == projectile.BehaviorType.BASIC:
		#no pushing or physical interaction, it's just an immaterial projectile
		projectile.collision_mask = 0
		projectile.collision_layer = 0
	elif projectile.behaviorType == projectile.BehaviorType.MATERIAL: #COLLIDEDS with walls, false walls, and players
		#can interact and be blocked by stage
		#only scan for stage collision (both types, since players may create envrionment) 
		projectile.collision_mask = 1 << playerStageCollisionLayerBit
		projectile.collision_mask = projectile.collision_mask | (1 << opponentStageCollisionLayerBit)
		projectile.collision_mask = projectile.collision_mask | (1 << opponentFalseWallStageCollisionLayerBit)
		projectile.collision_mask = projectile.collision_mask | (1 << opponentFalseCeilingStageCollisionLayerBit)
		#nobody can interact with the projectile
		projectile.collision_layer = 0
	elif projectile.behaviorType == projectile.BehaviorType.MATERIAL_NO_FALSE_WALLS: #collides with players and external stage, and false ceiling
		#can interact and be blocked by stage
		#only scan for stage collision (both types, since players may create envrionment) 
		projectile.collision_mask = 1 << playerStageCollisionLayerBit
		projectile.collision_mask = projectile.collision_mask | (1 << opponentStageCollisionLayerBit)
		projectile.collision_mask = projectile.collision_mask | (1 << opponentFalseCeilingStageCollisionLayerBit)
		#nobody can interact with the projectile
		projectile.collision_layer = 0
	elif projectile.behaviorType == projectile.BehaviorType.MATERIAL_NO_FALSE_CEILING: #collides with players and external stage walls, false walls, but not false ceiling
		#can interact and be blocked by stage
		#only scan for stage collision (both types, since players may create envrionment) 
		projectile.collision_mask = 1 << playerStageCollisionLayerBit
		projectile.collision_mask = projectile.collision_mask | (1 << opponentStageCollisionLayerBit)
		projectile.collision_mask = projectile.collision_mask | (1 << opponentFalseWallStageCollisionLayerBit)
		#nobody can interact with the projectile
		projectile.collision_layer = 0
		pass
	
	elif projectile.behaviorType == projectile.BehaviorType.PUBLIC_ENVIRONMENT:
		# and it doesn't cared about its' envrioment around it
		projectile.collision_mask = 0
		
		#the projectile acts as a new part of the stage (both players can bump into it)
		
		projectile.collision_layer = 1 << playerStageCollisionLayerBit
		projectile.collision_layer = projectile.collision_layer | (1 << opponentStageCollisionLayerBit)	
		projectile.collision_layer = projectile.collision_layer | (1 << playerPlatformCollisionLayerBit)
		projectile.collision_layer = projectile.collision_layer | (1 << opponentPlatformCollisionLayerBit)
		
	elif projectile.behaviorType == projectile.BehaviorType.SELF_ENVIRONMENT:
		#don't care about envrionement around it
		projectile.collision_mask = 0
		
		#the projectile acts as a new part of the stage but only for the player
		projectile.collision_layer = 1 << playerStageCollisionLayerBit
		projectile.collision_layer = projectile.collision_layer | (1 << playerPlatformCollisionLayerBit)
	elif projectile.behaviorType == projectile.BehaviorType.OPPONENT_ENVIRONMENT:
		#don't care about envrionement around it
		projectile.collision_mask = 0
		
		#the projectile acts as a new part of the stage but only for the player
		projectile.collision_layer = 1 << opponentStageCollisionLayerBit
		projectile.collision_layer = projectile.collision_layer | (1 << opponentPlatformCollisionLayerBit)
	elif projectile.behaviorType == projectile.BehaviorType.PUSHES:
		
		
		#can push opponent only (and bump into stage) (scan for opponent, and opponent scans for it)
		projectile.collision_mask = 1 << opponentPushableBodyBoxCollisionLayerBit
		projectile.collision_mask = projectile.collision_mask  | (1 << playerStageCollisionLayerBit	)
		projectile.collision_mask = projectile.collision_mask  | (1 << playerFalseWallStageCollisionLayerBit	)
		projectile.collision_layer = 1 << playerPushableBodyBoxCollisionLayerBit
		
	#make sure projectiles' hitbox/hurtbox is same as player
#	projectile.hitBoxLayer = player.hitBoxLayer
#	projectile.hitBoxMask = player.hitBoxMask
#	projectile.hurtBoxLayer = player.hurtBoxLayer
#	projectile.hurtBoxMask = player.hurtBoxMask
	
	var gameObjectAdded = null
	#adding to stage's game objects node?
	if projectile.mvmType == projectile.MovementType.RELATIVE_TO_STAGE:
		gameObjectAdded=gameObjects
		
	#adding to be relative to player?
	elif projectile.mvmType == projectile.MovementType.RELATIVE_TO_PLAYER:
		#gameObjectAdded=player.gameObjects
		gameObjectAdded=projectileOwner.gameObjects
		
	
	#projectile.floorDetector.collision_mask = 1 << playerStageCollisionLayerBit 
	#projectile.platformDetector.collision_mask = 1 << playerPlatformCollisionLayerBit
	
	projectile.floorDetector.collision_mask=player.floorDetector.collision_mask
	
	projectile.leftPlatformDetector.collision_mask=player.leftPlatformDetector.collision_mask
	
	projectile.rightPlatformDetector.collision_mask=player.rightPlatformDetector.collision_mask
	
	projectile.leftOpponentDetector.collision_mask=player.leftOpponentDetector.collision_mask
	
	projectile.rightOpponentDetector.collision_mask=player.rightOpponentDetector.collision_mask
	
	projectile.rightWallDetector.collision_mask=player.rightWallDetector.collision_mask

	projectile.leftWallDetector.collision_mask=player.leftWallDetector.collision_mask
	
	projectile.leftFalseWallDetector.collision_mask=1 << playerFalseWallStageCollisionLayerBit
	projectile.rightFalseWallDetector.collision_mask=1 << playerFalseWallStageCollisionLayerBit

	
		
	#add to appropriate game object (avoid adding instance twice that avoids reparenting
	if not gameObjectAdded.is_a_parent_of(projectile):
		gameObjectAdded.add_child(projectile)
	
	#projectile.set_owner(gameObjectAdded)
	
	#gameObjectAdded.call_deferred("add_child",projectile)
	
	#projectile.connect("destroyed",self,"_on_projectile_destroyed",[gameObjectAdded])
	#projectile.init()
		
	if not projectile.spriteAnimationManager.is_connected("display_global_temporary_sprites",self,"_on_display_global_temporary_sprites"):
		projectile.spriteAnimationManager.connect("display_global_temporary_sprites",self,"_on_display_global_temporary_sprites",[projectile])
	
	if not projectile.is_connected("remove_magnifying_glass",self,"_on_remove_magnifying_glass"):
		projectile.connect("remove_magnifying_glass",self,"_on_remove_magnifying_glass",[],CONNECT_ONESHOT)
	
	projectile.fire()

#called whne projectile is destroyed
func _on_remove_magnifying_glass(proj):
	destroyMagnifyingGlass(proj)
	

#given an object, will destroy a magnifying glass
func destroyMagnifyingGlass(obj):
	
	#has magniyfying glass?
	if activeMagnifyingGlasses.has(obj):
		
		var mg = activeMagnifyingGlasses[obj]
		#null the entry
		activeMagnifyingGlasses[obj] = null
		
		if mg != null:
			mg.disable()
			
		

#given an object, will destroy a magnifying glass
#func destroyMagnifyingGlass(obj):
	
	#has magniyfying glass?
#	if magnifyingGlasses.has(obj):
		
#		var mg = magnifyingGlasses[obj]
		#null the entry
#		magnifyingGlasses[obj] = null
		
#		if mg != null:
#			mg.disable()
#			self.remove_child(mg)
		
				
#func _on_projectile_destroyed(projectile,gameObjectAdded):
#	gameObjectAdded.remove_child(projectile)
	
func _on_hit_freeze_finished():
	
	inHitFreeze = false
	#broad cast to game objects and players to stop hitfreeze
	
	#notify stage game objects
	#for gameObj in gameObjects.get_children():
	#	gameObj._on_hit_freeze_finished()
	
	
	#notify player-relative game objects
	#for gameObj in player1.gameObjects.get_children():
	#	gameObj._on_hit_freeze_finished()

	#for gameObj in player2.gameObjects.get_children():
	#	gameObj._on_hit_freeze_finished()
				
	#notify players
	#player1.playerController._on_hit_freeze_finished()
	#player2.playerController._on_hit_freeze_finished()
	
	#player1._on_hit_freeze_finished()
	#player2._on_hit_freeze_finished()
	get_tree().call_group(GLOBALS.GLOBAL_HITFREEZE_GROUP,"_on_hit_freeze_finished")
	pass

func stopHitFreeze():
	
	#self.hitFreezeTimer.stopHitFreeze()
	self.hitFreezeTimer.stop()
	_on_hit_freeze_finished()


func startHitFreeze(duration):
	
	var wasInHitFreeze = inHitFreeze
	inHitFreeze = true
	
	
	#hitfreeze starting?
	if not wasInHitFreeze:
		
		hitFreezeTimer.start(duration)
		#we only want to call this once per pause, not many times if many things do hitfreeze
		#get_tree().call_group(GLOBALS.GLOBAL_HITFREEZE_GROUP,"_on_hit_freeze_started",duration)
		GLOBALS.my_call_group_function(get_tree(),GLOBALS.GLOBAL_HITFREEZE_GROUP,"_on_hit_freeze_started",[duration])
		
	else:
		
		
		#alreayd have an instance of histfreeze?
		#the larger hitfreeze wins (most times hitfreeze will override each other is multiple times
		#per frame, otherwise there shouldn't be infitinite hitfreeze calls that ever increase
		#the duration)
		
		#only restart hitfreeze if new duration longer than time left
		if hitFreezeTimer.get_time_left_in_frames() < duration:
			hitFreezeTimer.start(duration)
			#we only want to call this once per pause, not many times if many things do hitfreeze
			#get_tree().call_group(GLOBALS.GLOBAL_HITFREEZE_GROUP,"_on_hit_freeze_started",duration)
			GLOBALS.my_call_group_function(get_tree(),GLOBALS.GLOBAL_HITFREEZE_GROUP,"_on_hit_freeze_started",[duration])
	
	#if not wasInHitFreeze:
		#we only want to call this once per pause, not many times if many things do hitfreeze
	#	get_tree().call_group(GLOBALS.GLOBAL_HITFREEZE_GROUP,"_on_hit_freeze_started",duration)
	
#destorys all the projectiles
func removeAllProjectiles():
	
		
	#iterate trhough all active on stage projectiles to destroy them
	for gameObj in gameObjects.get_children():
	
		gameObj.destroy()
	
	#iterate trhough all active player1-relative projectiles to destroy them
	for gameObj in player1.gameObjects.get_children():
	
		gameObj.destroy()

	#iterate trhough all active player2-relative projectiles to destroy them
	for gameObj in player2.gameObjects.get_children():
	
		gameObj.destroy()
		
		
func changeGlobalSpeedMod(mod):
	#return
	#get_tree().call_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP,GLOBALS.GLOBAL_SPEED_MOD_SETTER_FUNC,mod)
	GLOBALS.my_call_group_function(get_tree(),GLOBALS.GLOBAL_SPEED_MOD_GROUP,GLOBALS.GLOBAL_SPEED_MOD_SETTER_FUNC,[mod])
func slowDownTimeGraduallyAndTemporarily(targetGlobalSpeedMod,slowDownDuration,speedupDuration, timeBeforeSpeedUp):
	

		
	#don't slow down time concurrently
	if not slowingDownTimeFlag:
		slowingDownTimeFlag = true
		#now gradually speed game back up
		var startingGlobalSpeed=self.globalSpeedMod
		var endingGlobalSpeed=targetGlobalSpeedMod
		
	#	GLOBALS.GLOBAL_SPEED_MOD_GROUP,GLOBALS.GLOBAL_SPEED_MOD_SETTER_FUNC
		#var ripostSlowMotionTween = Tween.new()
		var ripostSlowMotionTween =MyTweenResource.new()
		#ripostSlowMotionTween.playback_process_mode = ripostSlowMotionTween.TWEEN_PROCESS_PHYSICS
		self.add_child(ripostSlowMotionTween)
		
		if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
			#make tween deterministic in online mode
			#ripostSlowMotionTween.fixedDeltaFlag = true
			pass

		
		
		#ripostSlowMotionTween.connect("tween_completed",self,"_on_slow_down_game_complete",[ripostSlowMotionTween,startingGlobalSpeed,speedupDuration,timeBeforeSpeedUp],CONNECT_ONESHOT)
		#ripostSlowMotionTween.interpolate_method(self,"changeGlobalSpeedMod",startingGlobalSpeed,endingGlobalSpeed,slowDownDuration,Tween.TRANS_QUAD,Tween.EASE_OUT)
		#ripostSlowMotionTween.start()
		
		ripostSlowMotionTween.connect("finished",self,"_on_slow_down_game_complete",[ripostSlowMotionTween,startingGlobalSpeed,speedupDuration,timeBeforeSpeedUp],CONNECT_ONESHOT)
		ripostSlowMotionTween.start_interpolate_method(self,"changeGlobalSpeedMod",startingGlobalSpeed,endingGlobalSpeed,slowDownDuration)
		
#func _on_slow_down_game_complete(object,key,ripostSlowMotionTween,oldGlobalSpeed,speedupDuration,timeBeforeSpeedUp):
func _on_slow_down_game_complete(ripostSlowMotionTween,oldGlobalSpeed,speedupDuration,timeBeforeSpeedUp):
	
	var tmpFrameTimer = frameTimerResource.new()
	add_child(tmpFrameTimer)
	
	
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		#make tween deterministic in online mode
		#tmpFrameTimer.fixedDeltaFlag = true
		pass
	
	tmpFrameTimer.startInSeconds(timeBeforeSpeedUp)
	
	#make sure this timer isn't affected by speed slow down
	tmpFrameTimer.remove_from_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	tmpFrameTimer.globalSpeedMod=GLOBALS.DEFAULT_GLOBAL_SPEED_MOD
	#wait for a duration before speeding backup again
	yield(tmpFrameTimer,"timeout")
	
	remove_child(tmpFrameTimer)
	
	self.remove_child(ripostSlowMotionTween)
	#now gradually speed game back up
	var startingGlobalSpeed=self.globalSpeedMod
	var endingGlobalSpeed=oldGlobalSpeed
	
#	GLOBALS.GLOBAL_SPEED_MOD_GROUP,GLOBALS.GLOBAL_SPEED_MOD_SETTER_FUNC
	#var ripostSpeedUpRecoverTween = Tween.new()
	var ripostSpeedUpRecoverTween  =MyTweenResource.new()
	#ripostSpeedUpRecoverTween.playback_process_mode = ripostSpeedUpRecoverTween.TWEEN_PROCESS_PHYSICS
	self.add_child(ripostSpeedUpRecoverTween)

		
	
	ripostSpeedUpRecoverTween.connect("finished",self,"_on_speedup_game_complete",[ripostSpeedUpRecoverTween],CONNECT_ONESHOT)
	ripostSpeedUpRecoverTween.start_interpolate_method(self,"changeGlobalSpeedMod",startingGlobalSpeed,endingGlobalSpeed,speedupDuration)
	
				
	#ripostSpeedUpRecoverTween.connect("tween_completed",self,"_on_speedup_game_complete",[ripostSpeedUpRecoverTween],CONNECT_ONESHOT)
	#ripostSpeedUpRecoverTween.interpolate_method(self,"changeGlobalSpeedMod",startingGlobalSpeed,endingGlobalSpeed,speedupDuration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	#ripostSpeedUpRecoverTween.start()
	
	

#func _on_speedup_game_complete(object,key,tween):
func _on_speedup_game_complete(tween):
	self.remove_child(tween)
	slowingDownTimeFlag = false
	
func displayNotificationText(player,text):
	if player == null:
		print("null player, cant display: "+str(text))
		return
	if player == player1:
		p1HUD.notifyciationPanel.display(text,notificationPanelDuration)
	elif  player == player2:
		p2HUD.notifyciationPanel.display(text,notificationPanelDuration)


func _on_insufficient_ability_bar(amountMissing,missingBarIcon):
	missingBarIcon.display(GLOBALS.MISSING_BAR_ICON_DURATION)
	
func _on_player_jumped(player):
	#_on_emit_dust_particles(player)
	
	#only emite dust upon jump when in air, since 
	#upon leaving ground signal will handle when player's ground
	#jump sends them in the air
	if player.playerController.my_is_on_floor():
		return
		
		
	var pos = player.getCenter()
	#var pos =player.position 
	#move to bottom center of body box
	pos.y += (player.bodyBox.get_shape().extents.y)/2

	#var dust = airJumpDustSfxResource.instance()
	var dust = airJumpDustSFXBuffer.get_next_scene_instance()
	
	#the jump dust color changes if u get extra jumps
	var modulateColor = jumpSfxTracker.lookupJumpDustColor(player)
	dust.modulate = modulateColor
	dust.defaultModulate=modulateColor
	#does the color change cause we got an extra jump? #TODO: MOve the logic of extra jump trackin to player controller
	#cause here were mixing UI/model with controller logic
	#make the just DUST huge if we get extra jump
	if modulateColor != jumpSfxTracker.baseJumpModulate:
		dust.scale.x  = dust.scale.x*1.5
		dust.scale.y  = dust.scale.y*1.5

	
	
	#self.add_child(dust)
	dust.position = pos
	dust.activate()

func _on_player_left_ground(player):
	#_on_emit_dust_particles(player)
	
	#only emit dust if player willingly leaving ground
	if player.playerController.playerState.inHitStun:
		return
		
		
	var pos = player.getCenter()
	#var pos =player.position 
	#move to bottom center of body box
	pos.y += (player.bodyBox.get_shape().extents.y)/2 + 10 # + 10 to make sure dust appears from ground, since player in air

	#var dust = leaveGroundDustSfxResource.instance()
	#self.add_child(dust)
	var dust = leaveGroundSFXBuffer.get_next_scene_instance()
	dust.position = pos
	dust.activate()
#	var pos =player.position 
#	pos.y += player.bodyBox.get_shape().extents.y
#	playDustParticles(pos)

func _on_player_air_dahsed(airDashType,player):
	var pos = player.getCenter()

	#var particles = airDashingSfxResource.instance()
	var particles = airDashSFXBuffer.get_next_scene_instance()
	particles.modulate = particles.defaultModulate
	particles.rotation_degrees = particles.defaultRotation
	particles.scale = particles.defaultScale
	
	#the air dash dust color changes if u get extra dashes
	var modulateColor = jumpSfxTracker.lookupAirDashDustColor(airDashType,player)
	particles.modulate = modulateColor

	#does the color change cause we got an extra dash? #TODO: MOve the logic of extra dash trackin to player controller
	#cause here were mixing UI/model with controller logic
	#make the just DUST abit bigger if we get extra dash
	if modulateColor != jumpSfxTracker.baseAirDashModulate:
		particles.scale.x  = particles.scale.x*1.25
		particles.scale.y  = particles.scale.y*1.25
		
	particles.play()
	#self.add_child(particles)
	particles.position = pos
	
	if airDashType == GLOBALS.AirDashType.FORWARD and not player.facingRight:
		particles.scale.x = particles.scale.x*(-1)
	elif airDashType == GLOBALS.AirDashType.BACKWARD and player.facingRight:
		particles.scale.x = particles.scale.x*(-1)
	elif airDashType == GLOBALS.AirDashType.DOWNWARD:
		#make it face downard
		particles.rotation_degrees=90
	
	
	
	#if not player.facingRight:
	#	particles.scale.x = particles.scale.x*(-1)
		

	#particles.set_emitting(true)
	
func _on_player_ground_dahsed(dashType,player):
	var pos = player.getCenter()
	#var particles = groundDashingSfxResource.instance()
	var particles = groundDashDustSFXBuffer.get_next_scene_instance()
	particles.defaultModulate = particles.unmutableDefaultModulate
	particles.modulate = particles.unmutableDefaultModulate	
	particles.rotation_degrees = particles.defaultRotation
	particles.scale =particles.defaultScale 
	#groundDashDustSFXBuffer=$"groundDashDustSFXSpriteBuffer"
	#groundDashCancelDustSFXBuffer=$"groundDashCancelDustSFXSpriteBuffer"
	#self.add_child(particles)
	particles.position = pos
	
	if dashType == GLOBALS.AirDashType.FORWARD and not player.facingRight:
		particles.scale.x = particles.scale.x*(-1)
	elif dashType == GLOBALS.AirDashType.BACKWARD and player.facingRight:
		particles.scale.x = particles.scale.x*(-1)
	
	particles.activate()

func _on_ground_dash_cancel(dashType,player):
	var pos = player.getCenter()
	#var particles = groundDashCancelSfxResource.instance()
	var particles = groundDashCancelDustSFXBuffer.get_next_scene_instance()
	particles.defaultModulate = particles.unmutableDefaultModulate
	particles.modulate = particles.unmutableDefaultModulate	
	particles.rotation_degrees = particles.defaultRotation
	particles.scale =particles.defaultScale 
	
	
	particles.position = pos
	
	if dashType == GLOBALS.AirDashType.FORWARD and not player.facingRight:
		particles.scale.x = particles.scale.x*(-1)
	elif dashType == GLOBALS.AirDashType.BACKWARD and player.facingRight:
		particles.scale.x = particles.scale.x*(-1)
		

func _on_player_landed(player):
	
	var pos = player.getCenter()
	#var pos =player.position 
	#move to bottom center of body box
	pos.y += (player.bodyBox.get_shape().extents.y)/2
	var dust = playDustParticles(pos)
	
	applyWallHitDustTechModulate(player,dust,GLOBALS.TECH_FLOOR_IX)
	dust.activate()

func playDustParticles(position):
#	var dust = landingDustResource.instance()
#	self.add_child(dust)
#	dust.position = position
#	dust.set_emitting(true)
	
	#var newdust = jumpDustSfxResource.instance()
	var newdust = jumpDustSFXBuffer.get_next_scene_instance()
	newdust.scale = newdust.defaultScale
	newdust.rotation_degrees = newdust.defaultRotation
	newdust.modulate = newdust.unmutableDefaultModulate
	newdust.defaultModulate = newdust.unmutableDefaultModulate
	#self.add_child(newdust)
	newdust.position = position
	
		
	return newdust
	
	
func _on_damage_gauge_changed(newDamage,oldDamage, playerHUD):
	playerHUD.setDamageGauge(newDamage)

func _on_damage_gauge_next_hit_changed(newValue,oldValue, playerHUD):
	playerHUD.setDamageGaugeNextHit(newValue)
	
func _on_damage_gauge_capacity_changed(newCapacity,oldCapacity, playerHUD):
	playerHUD.setDamageGaugeCapacity(newCapacity)

func _on_damage_gauge_reached_capacity(newDamage, playerHUD):
	playerHUD._on_damageGaugeCapacityReached(newDamage)

func _on_focus_changed(newFocus,oldFocus, playerHUD):
	#playerHUD.setFocus(newFocus)
	pass

func _on_focus_next_hit_changed(new,old, playerHUD):
	#playerHUD.setFocusNextHit(new)
	pass
	
func _on_focus_capacity_changed(newCapacity,oldCapacity, playerHUD):
	#playerHUD.setFocusCapacity(newCapacity)
	pass

func _on_focus_reached_capacity(newFocus, playerHUD):
	#playerHUD._on_focusCapacityReached(newFocus)
	pass


func _on_pause(inputDeviceId,opponentInputDeviceId,playerController,pauseMode):

	pauseHUD.activate(inputDeviceId,opponentInputDeviceId,playerController,pauseMode)



func _on_tech(timeLeftInFrames,techType,player):
	displayNotificationText(player,"Tech'ed!")
	

	var pos = player.getCenter()
	#var pos =player.position 
	#move to bottom center of body box
	pos.y += (player.bodyBox.get_shape().extents.y)/2

	#var dust = techSfxResource.instance()
	var dust = techSFXBuffer.get_next_scene_instance()
	#self.add_child(dust)
	dust.position = pos
	
	match(techType):
		GLOBALS.TYPE_GROUND_TECH_BOUNCE_UP,GLOBALS.TYPE_GROUND_TECH_IN_PLACE,GLOBALS.TYPE_GROUND_TECH_ROLL_FORWARD,GLOBALS.TYPE_GROUND_TECH_ROLL_BACKWARD:

			pass #do nothing, it's a ground tech
			
		GLOBALS.TYPE_WALL_TECH_IN_PLACE,GLOBALS.TYPE_WALL_TECH_BOUNCE_UP,GLOBALS.TYPE_WALL_TECH_BOUNCE_DOWN,GLOBALS.TYPE_WALL_TECH_BOUNCE_AWAY:		
		
			if player.facingRight:
				dust.rotation_degrees = 90 # left wall, 
			else:
				dust.rotation_degrees = 270 # right wall, 
				
		
		GLOBALS.TYPE_CEILING_TECH_IN_PLACE,GLOBALS.TYPE_CEILING_TECH_BOUNCE_DOWN,GLOBALS.TYPE_CEILING_TECH_BOUNCE_FORWARD,GLOBALS.TYPE_CEILING_TECH_BOUNCE_BACK:

	
			dust.rotation_degrees = 180 # turn it upsidedown
			dust.position.y = dust.position.y - 50
		_:
			#bug, no such type 
			print("unknwoen tech type")
		
		
	dust.activate()
	

func _on_failed_tech(player):
	pass
	#displayNotificationText(player,"Failed Tech'ed!")
	
func _on_ability_cancel(barCost,spriteFrame,autoAbilityCancelFlag,player):
	if autoAbilityCancelFlag:
		displayNotificationText(player,"Auto Ability Cancel!")
	else:
		displayNotificationText(player,"Ability Cancel!")
		
		
	
	
#		var swirls = abilityCancelSwrilSFXBuffer.get_next_particle()
#		var explosion = abilityCancelExplosionSFXBuffer.get_next_particle()
		
		#var abilityCancelSwrilResource = preload("res://particles/abilityCancelSwirlParticles.tscn")
		#var abilityCancelExplosionResource = preload("res://particles/abilityCancelExplosionParticles.tscn")
		#var swirls = abilityCancelSwrilResource.instance()
		#var explosion = abilityCancelExplosionResource.instance()

#		swirls.pauseOnHitFreeze=false
#		explosion.pauseOnHitFreeze=false
		
#		var playerCenter = player.getRelativeCenter()
		#player.add_child(swirls)
		#player.add_child(explosion)
		
#		swirls.position = playerCenter
		#swirls.set_emitting(true)
		
#		explosion.position = playerCenter
		#explosion.set_emitting(true)
		
		
			#no particles for lesser version of a cancel
		#lesser ability cancel (liek movement)?
		#if barCost<=player.playerController.BASIC_ABILITY_CANCEL_COST:
		#	explosion.amount=8
		#	swirls.amount = 10
			
		#abilityCancelSwrilSFXBuffer.trigger()
		#abilityCancelExplosionSFXBuffer.trigger()
	
func _on_perfect_block(player):
	displayNotificationText(player,"Perfect block!")
func _on_incorrect_block_unblockable(player):
	displayNotificationText(player,"Incorrect Unblockable!")
	
func _on_counter_hit(player):
	displayNotificationText(player,"Counter Hit!")

func _on_punish(player):
	displayNotificationText(player,"Punish!")
	
func _on_guard_broken(highBlockFlag,guardBreakGuardRecovered,player):
	displayNotificationText(player,"Guard break!")
	
	if player == player1:
		p1HUD.guardHPBar.startGuardBreakRefillAnimation(guardBreakGuardRecovered)
	else:
		p2HUD.guardHPBar.startGuardBreakRefillAnimation(guardBreakGuardRecovered)
func _on_riposted_attempted(cmdRiposted,cmdHitBy,successFlag,ripostedInNeutralFlag,player):
	
	if player == player1:
		
		#dislay the command pair of hit vs. ripost command
		
		p1HUD.commandPairDisplay.initText("Hit","Riposted")
		p1HUD.commandPairDisplay.setSuccessFlag(successFlag)
		p1HUD.commandPairDisplay.displayCommandPair(cmdHitBy,cmdRiposted)
		p1HUD.commandPairDisplay.visible = true
		p1HUD.commandPairDisplay.delayedHide(2) #1.5 seconds before disappear
		
		
		p1HUD.ripostNotification.commandAttempt(cmdRiposted,successFlag)
		
		
	else:
		#dislay the command pair of hit vs. ripost command
		p2HUD.commandPairDisplay.initText("Hit","Riposted")
		p2HUD.commandPairDisplay.setSuccessFlag(successFlag)
		p2HUD.commandPairDisplay.displayCommandPair(cmdHitBy,cmdRiposted)
		p2HUD.commandPairDisplay.visible = true
		p2HUD.commandPairDisplay.delayedHide(2) #1.5 seconds before disappear
		
		p2HUD.ripostNotification.commandAttempt(cmdRiposted,successFlag)
		
	var areWeSlowingTimeATM = self.slowingDownTimeFlag
	
	#wait for the hitfreeze to die down
	var timeToWait = hitFreezeTimer.get_time_left_in_seconds()
	
	
	if timeToWait > 0:
		#var oldGlobalSpeed = self.globalSpeedMod
		#slow game down during hitfreeze for suspense
		#get_tree().call_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP,GLOBALS.GLOBAL_SPEED_MOD_SETTER_FUNC,ripostSlowDownModifier)
		#yield(get_tree().create_timer(timeToWait),"timeout")
		
		
		ripostAttemptedTimer.startInSeconds(timeToWait)
		yield(ripostAttemptedTimer,"timeout")
		
		#get_tree().call_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP,GLOBALS.GLOBAL_SPEED_MOD_SETTER_FUNC,oldGlobalSpeed)
	
	startRipostParticles(cmdRiposted,successFlag,player) #remove the flag, it's useless
	if successFlag:
		
		#flash screen for 0.075 seconds
		start_flash(RIPOST_FLASH_DURATION_IN_SECONDS,RIPOST_FLASH_STRENGTH)
		
		var hypeMod = getRipostHypnessMod(player)
		ripostSFXSoundPlayer.volume_db = defaultRipostCheerVolume - HYPNESS_VOLUMNE_RELATION_MOD*hypeMod
		
		ripostSFXSoundPlayer.playSound()
		#make sure volume of ripost is 
		#proportional to number of ripost player performed
		#count the number of riposts
		increaseRipostHypnessMod(player)
		
		#check to have ripost stop theme song music to return the flow to normal
		#player1 riposted?
		if player==player1:
			#did player 2 have a hero theme song from counter ripost?
			if player2ThemeMusicPlayer.playing:
				
				
				#stop it and restart the normal stage theme
				player2ThemeMusicPlayer.stop()
				player2ThemeMusicPlayer.stream_paused = true
				#player2ThemeMusicPlayer.stream_paused = true
				
				#stage song index was recorded when music changed?
				if stageSongIx != -1:
					
					#play stage music from where left off
					musicPlayer.playSoundFromCurrentPosition(stageSongIx)
					
				else:
					musicPlayer.playRandomSound()
					
				var soundPlayer = musicPlayer.getCurrentSoundPlayer()
				soundPlayer.stream_paused = false
		else:
			
			#did player 1 have a hero theme song from counter ripost?
			if player1ThemeMusicPlayer.playing:
				
				#stop it and restart the normal stage theme
				#player1ThemeMusicPlayer.stream_paused = true	
				player1ThemeMusicPlayer.stop()
				player1ThemeMusicPlayer.stream_paused = true
				#stage song index was recorded when music changed?
				if stageSongIx != -1:
					#play stage music from where left off
					musicPlayer.playSoundFromCurrentPosition(stageSongIx)
										
				else:
					musicPlayer.playRandomSound()
					
				var soundPlayer = musicPlayer.getCurrentSoundPlayer()
				soundPlayer.stream_paused = false

		if ripostedInNeutralFlag:
			displayNotificationText(player,"Neutral Riposte!")
		else:
			displayNotificationText(player,"Riposte!")
		#player.playerController._on_request_play_special_sound(player.playerController.RIPOST_SOUND_ID)
		
		#zoom in the camera
		camera._on_ripost(true)
		
		
		#weren't already messing with the time?
	#	if not areWeSlowingTimeATM:
			#slow game down gradually for a breif moment and speed it back up againt
	#		slowDownTimeGraduallyAndTemporarily(ripostSlowDownModifier,ripostSlowDownDurationInSeconds,ripostSlowDownRecoverDurationInSeconds,ripostInBetweenDurationInSeconds)
		
	else:
		displayNotificationText(player,"Failed Riposte!")
				

func _on_counter_ripost_attempted(cmd,successFlag,player):
	
	
	var areWeSlowingTimeATM = self.slowingDownTimeFlag
	#wait for the hitfreeze to die down
	var timeToWait = hitFreezeTimer.get_time_left_in_seconds()
	
	if timeToWait > 0:
		#yield(get_tree().create_timer(timeToWait),"timeout")
		counterRipostWaitTimer.startInSeconds(timeToWait)
		yield(counterRipostWaitTimer,"timeout")
	
	startCounterRipostParticles(cmd,successFlag,player) # remove flag, its useless	
	if successFlag:
		
		
		
		if player == player1:
			#inverse the hud since victim who failed ripost is opponent
			p2HUD.commandPairDisplay.visible = false #clearly ripost failed since it was countered, hide the ui display

		else:
		#inverse the hud since victim who failed ripost is opponent
			p1HUD.commandPairDisplay.visible = false #clearly ripost failed since it was countered, hide the ui display

		
		displayNotificationText(player,"Counter Riposted!")
		
		#flash screen for 0.075 seconds
		start_flash(RIPOST_FLASH_DURATION_IN_SECONDS,RIPOST_FLASH_STRENGTH)
		
		counterRipostSFXSoundPlayer.playSound()
		
		#start the clapping sound of counter ripost
	#	player.playerController._on_request_play_special_sound(player.playerController.COUNTER_RIPOST_SOUND_ID)
		
		#stop stage's music to start the counter-riposter's theme song for the rest of the match
		stageSongIx = musicPlayer.currSoundPlayerIx
		musicPlayer.stopAll()
		
	
		#play hero's theme from where left off, to simulate stealing flow
		#away from opponent
		#stop opponents theme song
		if player == player1:
			
			if player2ThemeMusicPlayer.playing:
				player2ThemeMusicPlayer.stream_paused = true
				player2ThemeMusicPlayer.stop()
			
			
			#if not player1ThemeMusicPlayer.playing:
			var pos = player1ThemeMusicPlayer.get_playback_position()
			player1ThemeMusicPlayer.playSound(pos)
			player1ThemeMusicPlayer.stream_paused = false
		
			
			
			#player1ThemeMusicPlayer.stream_paused = false
		else:
			if player1ThemeMusicPlayer.playing:
				player1ThemeMusicPlayer.stream_paused = true
				player1ThemeMusicPlayer.stop()
			#var pos = player2ThemeMusicPlayer.get_playback_position()
			#player2ThemeMusicPlayer.playSound(pos)
		
			
		#	if not player2ThemeMusicPlayer.playing:
			var pos = player2ThemeMusicPlayer.get_playback_position()
			player2ThemeMusicPlayer.playSound(pos)
			player2ThemeMusicPlayer.stream_paused = false
			
			#player2ThemeMusicPlayer.stream_paused = false
			
		#zoom in the camera
		camera._on_ripost(false)
		
		#weren't already messing with the time?
		if not areWeSlowingTimeATM:
			#slow game down gradually for a breif moment and speed it back up againt
			slowDownTimeGraduallyAndTemporarily(ripostSlowDownModifier,ripostSlowDownDurationInSeconds,ripostSlowDownRecoverDurationInSeconds,ripostInBetweenDurationInSeconds)
		
		
	else:
		displayNotificationText(player,"Failed Counter Riposted!")
	
func _on_clash(opponentHitboxArea,selfHitboxArea,player):
	
	displayNotificationText(player,"Clash!")
	
	
func _on_grabbed_in_block(player):
	displayNotificationText(player,"Grab Counter!")
	start_flash(GRAB_FLASH_DURATION_IN_SECONDS,GRAB_FLASH_STRENGTH)

func _on_hit_armored_opponent(player):
	displayNotificationText(player,"Armor!")

func _on_grabbed_auto_riposter(player):
	camera._on_grab_auto_riposter()
	
#func _on_grab_cooldown_changed(grabAvailable,player,hud):
func _on_grab_cooldown_changed(grabCharges,oldNumGrabCharges,player,hud):
	#hud._on_grab_cooldown_changed(grabAvailable)
	
	
	var grabCooldownDur = player.playerController.grabHandler.computeGrabCooldownTime()
	#hud.antiBlockIcon.startCooldownAnimation(grabAvailable,grabCooldownDur)

	var grabAvailable = grabCharges>0
	
	#basic case where only 1 grab cooldown icon?
	if not player.hasAdditionalGrabCharge:
		#went onto cooldown?
		if not grabAvailable:
			hud.grabResourceHUD.activateGrabCooldownTimer(grabCooldownDur)
			
		else:#back off cooldown before time ellapsed?
			hud.grabResourceHUD.deactivate()
	else:
		#here we spent a grab charge, so dynamically determine which grab 
		#cooldown icon to setup
		#grabResourceHUD is for manaing charge 0 to 1
		#grabResourceHUD2ndCharge is for manaing charge 1 to 2
		if grabCharges == 1:
			#we have a full grab available, so make sure grabResourceHUD is full
			hud.grabResourceHUD.deactivate()
			hud.grabResourceHUD2ndCharge.activateGrabCooldownTimer(grabCooldownDur)
		elif grabCharges == 0:
			#we just used the 2nd grab. so migrate the progress of grabResourceHUD2ndCharge to
			# grabResourceHUD and drain grabResourceHUD2ndCharge of any progress
			hud.grabResourceHUD.inheritOtherGrabCooldown(hud.grabResourceHUD2ndCharge)
			
			#other cooldown wasn'ta ctive?
			if not hud.grabResourceHUD.is_physics_processing():
				hud.grabResourceHUD.activateGrabCooldownTimer(grabCooldownDur)
			hud.grabResourceHUD2ndCharge.stopAndWait()
		elif grabCharges == 2:
			hud.grabResourceHUD.deactivate()
			hud.grabResourceHUD2ndCharge.deactivate()
	
func _on_push_blocked(player):
	displayNotificationText(player,"Push Block!")

func _on_fill_combo(player):
	pass #not a thing anymore
	#displayNotificationText(player,"Star Completion Combo")
	
func _on_combo_level_up(lvl, player):
	displayNotificationText(player,"Magic Series Combo!")

func _on_reverse_beat_combo_level_up(lvl, player):
	displayNotificationText(player,"Reverse Beat Combo!")
	
		
func _on_reversal(spriteAnimation,player):
	displayNotificationText(player,"Reversal!")

func _on_player_reached_half_hp(player):
	displayNotificationText(player,"Half-Way Mark")
	if numPlayersReachedHalfHP==0:
		specialSFXSoundPlayer.playSound(HALF_WAY_MARK_FIRST_PLAYER_SOUND_ID)
	else:
		specialSFXSoundPlayer.playSound(HALF_WAY_MARK_SECOND_PLAYER_SOUND_ID)
	
	numPlayersReachedHalfHP = numPlayersReachedHalfHP +1
	
	
func _on_was_hit_in_invincibility(player):
	displayNotificationText(player,"Invincibility!")

func _on_clash_break(player):
	clashBubbleSfx.setClashBreakTexture()
	displayNotificationText(player,"Clash Break!")
	
func _on_block_stun_string(player):
	
	displayNotificationText(player,"Blockstun String!")

func _on_auto_ripost(player):
	
	displayNotificationText(player,"Auto Riposte!")	
	
func _on_parry(player):
	
	displayNotificationText(player,"Parry!")	
	

func _on_start_tracking_frame_duration(numFrames,inHitFreezeFlag,player):
	if gameMode == GLOBALS.GameModeType.TRAINING:
		if player == player1:			
			p2HUD.frameCounterBar.activate(numFrames,inHitFreezeFlag)
		elif player == player2:
			p1HUD.frameCounterBar.activate(numFrames,inHitFreezeFlag)

func startCounterRipostParticles(cmd,successFlag,player):
	if successFlag:
		var pos = player.getCenter()
		#start counter ripost particles
		counterRipostSFX.position =pos
		counterRipostSFX.start()
		#start ripost particles
		#ripostSFX.position = pos
		#ripostSFX.start()
	
func startRipostParticles(cmd,successFlag,player):
	if successFlag:
		ripostSFX.position = player.getCenter()
		ripostSFX.start()
	
#the player's hp has reached 0
func _on_game_ending(victoryType,player1State,player2State):
	
	
	if gameMode == GLOBALS.GameModeType.TRAINING:
		#RESTART
		_on_start_match()
		return
			
	specialSFXSoundPlayer.playSound(GAME_ENDING_SOUND_ID)
	
	#stop music but keep ambience
	var keepAmbienceFlag=true
	
	if ambienceMusic != null:
		ambienceMusic.volume_db=amibenceMusicDefaultVolume+endMatchAmbienceVolumeIncrease
	stopStageMusic(keepAmbienceFlag) 
	
	
	var winnerState = null
	var winnerPlayerController = null
	var loserPlayerController = null

	
	#plyaer 1 lost
	#if player1State.hp <= 0:
	if victoryType == GLOBALS.VictoryType.PLAYER2_WINS_VIA_KO or victoryType == GLOBALS.VictoryType.PLAYER2_WINS_VIA_TIMEOUT:
		
		
		
		#p1HUD.notifyciationPanel.display("KO!",notificationKODuration)
		if victoryType == GLOBALS.VictoryType.PLAYER2_WINS_VIA_TIMEOUT:
			matchCountDownLabel.activateWithoutAnimation("Timeout!")
		else:
			matchCountDownLabel.activateWithoutAnimation("KO!")
	
		#brief moment of freeze for ko hype
		startHitFreeze(KO_HIT_FREEZE_DURATION_IN_FRAMES)
		matchEndTimer.start(KO_HIT_FREEZE_DURATION_IN_FRAMES)
		yield(matchEndTimer,"timeout")
		
		#slow down game after hitfreeze and quickly speed up to give a big feel to last hit
		koSlowMotionTween.start_interpolate_method(self,"changeGlobalSpeedMod",KO_GAME_SLOW_MOD,GLOBALS.DEFAULT_GLOBAL_SPEED_MOD,KO_GAME_SLOW_DURATION)
		yield(koSlowMotionTween,"finished")
		
		
		#matchCountDownLabel.visible = false
		matchCountDownLabel.hide()
		
		#disable the light flashes of attacks
		#hide the HUD
		p1HUD.visible = false
		p2HUD.visible = false
		
			#quickly get speed of game back to normal
	
		#not style poitns round?	
		if (not enableStylePointsRoundFlag):
	
			#this is where the lolgic for KO
			#matchCountDownLabel.visible = false
			#yield(get_tree().create_timer(2.5),"timeout")
						
			matchEndTimer.startInSeconds(KO_DURATION_WHERE_CAN_COMBO_BETWEEN_GAME_END)
			fadeOutHUD.fadeOut(KO_DURATION_WHERE_CAN_COMBO_BETWEEN_GAME_END+endGameSlowMotionDuration)
			yield(matchEndTimer,"timeout")
			
			matchCountDownLabel.hide()
			var winnerStylePointsState = null #no winner
			_on_game_ended(victoryType,"Player2",player1State,player2State,winnerStylePointsState) 
			return
					
		p1HUD.hpBar.setUnderBarToMaximumAmount()
		
		
		#p2HUD.notifyciationPanel.display("Finish Him!",notificationKODuration)
		winnerState = player2State
		winnerPlayerController =player2.playerController
		loserPlayerController =player1.playerController
	#player 2 lost
	#if player2State.hp <= 0:
	elif victoryType == GLOBALS.VictoryType.PLAYER1_WINS_VIA_KO or victoryType == GLOBALS.VictoryType.PLAYER1_WINS_VIA_TIMEOUT:
		
	
			
		if victoryType == GLOBALS.VictoryType.PLAYER1_WINS_VIA_TIMEOUT:
			matchCountDownLabel.activateWithoutAnimation("Timeout!")
		else:
			matchCountDownLabel.activateWithoutAnimation("KO!")
			
		#brief moment of freeze for ko hype
		startHitFreeze(KO_HIT_FREEZE_DURATION_IN_FRAMES)
		matchEndTimer.start(KO_HIT_FREEZE_DURATION_IN_FRAMES)
		yield(matchEndTimer,"timeout")	
		
		#slow down game after hitfreeze and quickly speed up to give a big feel to last hit
		koSlowMotionTween.start_interpolate_method(self,"changeGlobalSpeedMod",KO_GAME_SLOW_MOD,GLOBALS.DEFAULT_GLOBAL_SPEED_MOD,KO_GAME_SLOW_DURATION)
		yield(koSlowMotionTween,"finished")
		
		#matchCountDownLabel.visible = false
		matchCountDownLabel.hide()
		
		#disable the light flashes of attacks
		#hide the HUD
		p1HUD.visible = false
		p2HUD.visible = false
		
		
			#not style poitns round?	
		if (not enableStylePointsRoundFlag):
			
			#yield(get_tree().create_timer(2.5),"timeout")
			matchEndTimer.startInSeconds(KO_DURATION_WHERE_CAN_COMBO_BETWEEN_GAME_END)
			#fadeOutHUD.fadeOut(endGameSlowMotionDuration+KO_DURATION_WHERE_CAN_COMBO_BETWEEN_GAME_END)
			fadeOutHUD.fadeOut(KO_DURATION_WHERE_CAN_COMBO_BETWEEN_GAME_END+endGameSlowMotionDuration)
			yield(matchEndTimer,"timeout")
			
			#matchCountDownLabel.visible = false
			matchCountDownLabel.hide()
			
			#disable the light flashes of attacks
			#hide the HUD
			p1HUD.visible = false
			p2HUD.visible = false
			
			var winnerStylePointsState = null #no winner
			_on_game_ended(victoryType,"Player1",player1State,player2State,winnerStylePointsState) 
			return
			
		p2HUD.hpBar.setUnderBarToMaximumAmount()
		winnerState = player1State
		#p1HUD.notifyciationPanel.display("Finish Him!",notificationKODuration)
		loserPlayerController =player2.playerController
		winnerPlayerController =player1.playerController
		
	
	#TODO: need to deal with draw situation
	#if player1State.hp <= 0 and player2State.hp <= 0:
	elif victoryType == GLOBALS.VictoryType.DRAW_VIA_KO or victoryType == GLOBALS.VictoryType.DRAW_VIA_TIMEOUT:
		#print("WARNING:draw not implement yet")
		if victoryType == GLOBALS.VictoryType.DRAW_VIA_TIMEOUT:
			matchCountDownLabel.activateWithoutAnimation("Timeout - Draw!")
		else:
			matchCountDownLabel.activateWithoutAnimation("KO - Draw!")
			
		#brief moment of freeze for ko hype
		startHitFreeze(KO_HIT_FREEZE_DURATION_IN_FRAMES)
		matchEndTimer.start(KO_HIT_FREEZE_DURATION_IN_FRAMES)
		yield(matchEndTimer,"timeout")
		
		#slow down game after hitfreeze and quickly speed up to give a big feel to last hit
		koSlowMotionTween.start_interpolate_method(self,"changeGlobalSpeedMod",KO_GAME_SLOW_MOD,GLOBALS.DEFAULT_GLOBAL_SPEED_MOD,KO_GAME_SLOW_DURATION)
		yield(koSlowMotionTween,"finished")
		
		#matchCountDownLabel.visible = false
		matchCountDownLabel.hide()
		
		#disable the light flashes of attacks
		#hide the HUD
		p1HUD.visible = false
		p2HUD.visible = false
			
			
		#slowDownTimeGraduallyAndTemporarily(KOSlowDownModifier,KOSlowDownDurationInSeconds,KOSlowDownRecoverDurationInSeconds,KOInBetweenDurationInSeconds)
		var timeToGetReadyWait = KOSlowDownDurationInSeconds +  KOSlowDownRecoverDurationInSeconds + KOInBetweenDurationInSeconds#seconds
		gameEnding = false
		#yield(get_tree().create_timer(timeToGetReadyWait),"timeout")
		matchEndTimer.startInSeconds(timeToGetReadyWait)
		yield(matchEndTimer,"timeout")
		
		
		#matchCountDownLabel.visible = false
		#matchCountDownLabel.hide()
		var winnerStylePointsState = null #no winner
		_on_game_ended(victoryType,"Draw",player1State,player2State,winnerStylePointsState) #make sure that player_controller.winnerText doesn't or does need to be changed
		return
		
	else:
		print("unknown victory type")
	
	#give winner max ability bar, reset the bars, adn see how well can do
	# to place style points that will eventually be shown on result screen
	winnerState.damageGauge = winnerState.defaultDamageGauge 
	winnerState.damageGaugeCapacity = winnerState.defaultDamageGaugeCapacity
	winnerState.focus = winnerState.defaultFocus
	winnerState.focusCapacity = winnerState.defaultFocusCapacity
	winnerState.focusCapacity = winnerState.defaultFocusCapacity
	winnerState.increaseAbilityBarToMax()
	
	#don't ttouch input manager physics process in online match
	var affectPHysicsPorcInputMngr = gameMode != GLOBALS.GameModeType.ONLINE_HOSTING and gameMode != GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST
	#disable input for abit
	loserPlayerController.disableUserInput(affectPHysicsPorcInputMngr)
	winnerPlayerController.disableUserInput(affectPHysicsPorcInputMngr)
	
	
	#remove all the projectiles
	removeAllProjectiles()
	
	#slowDownTimeGraduallyAndTemporarily(KOSlowDownModifier,KOSlowDownDurationInSeconds,KOSlowDownRecoverDurationInSeconds,KOInBetweenDurationInSeconds)
	#, +1 to give chance for the animations to finish to setup the style points round
	var timeToGetReadyWait = KOSlowDownDurationInSeconds +  KOSlowDownRecoverDurationInSeconds + KOInBetweenDurationInSeconds#seconds
	
	#yield(get_tree().create_timer(timeToGetReadyWait),"timeout")
	matchEndTimer.startInSeconds(timeToGetReadyWait)
	yield(matchEndTimer,"timeout")
	
	
	matchCountDownLabel.activateWithoutAnimation("Style points round in...")
	#matchCountDownLabel.visible = true
	#matchCountDownLabel.text = "Style points combo in..."
	#center the text
	#matchCountDownLabel.rect_position.x  = matchCountDownLabel.rect_position.x - 400
	matchCountDownLabel.visible = true
	#wait a second
	
	#yield(get_tree().create_timer(1.5),"timeout")
	countDownSequenceTimer.startInSeconds(1.5)
	yield(countDownSequenceTimer,"timeout")
		
		
	#matchCountDownLabel.rect_position.x  = matchCountDownLabel.rect_position.x + 400
	#matchCountDownLabel.text = "3"
	specialSFXSoundPlayer.playSound(TIMER_TICK_SOUND_ID)
	matchCountDownLabel.activateAnimation("3")
	#wait a second
	#yield(get_tree().create_timer(1),"timeout")
	countDownSequenceTimer.startInSeconds(1)
	yield(countDownSequenceTimer,"timeout")
	#matchCountDownLabel.text = "2"
	specialSFXSoundPlayer.playSound(TIMER_TICK_SOUND_ID)
	matchCountDownLabel.activateAnimation("2")
	
	#wait a second
	#yield(get_tree().create_timer(1),"timeout")
	countDownSequenceTimer.startInSeconds(1)
	yield(countDownSequenceTimer,"timeout")
	#matchCountDownLabel.text = "1"
	specialSFXSoundPlayer.playSound(TIMER_TICK_SOUND_ID)
	matchCountDownLabel.activateAnimation("1")
	#wait a second
	#yield(get_tree().create_timer(1),"timeout")
	countDownSequenceTimer.startInSeconds(1)
	yield(countDownSequenceTimer,"timeout")
	#matchCountDownLabel.text = "Go!"
	matchCountDownLabel.activateAnimation("Go!")
	
	specialSFXSoundPlayer.playSound(MATCH_START_SOUND_ID)
	#let winner style on oponent
	winnerPlayerController.enableUserInput()
	#loserPlayerController.enableUserInput()
	
	#this makes sure now when hitstun finsiesh, game ends
	playersNode.gameEnding = true
	
	#start style points round timer
	matchTimer.activate(stylePointRoundDefaultTimeLength)
	
	#make sure to change the timer state to style points timer, so game ends when timer ellapsed
	timerState = STYLE_POINT_ROUND_TIMEOUT
	
	#yield(get_tree().create_timer(1),"timeout")
	countDownSequenceTimer.startInSeconds(1)
	yield(countDownSequenceTimer,"timeout")
	matchCountDownLabel.text = ""
	#matchCountDownLabel.visible = false
	matchCountDownLabel.hide()
	
	
	
#func setGlobalSpeedMod(mod):
	
	
	#notify stage game objects
	#for gameObj in gameObjects.get_children():
	
	#	gameObj.setGlobalSpeedMod(mod)
	
	
	#notify player-relative game objects
	#for gameObj in player1.gameObjects.get_children():
	
	#	gameObj.setGlobalSpeedMod(mod)

	#for gameObj in player2.gameObjects.get_children():
	
	#	gameObj.setGlobalSpeedMod(mod)
				
	#notify players
	#player2.playerController.setGlobalSpeedMod(mod)
	#player1.playerController.setGlobalSpeedMod(mod)
	#playersNode.setGlobalSpeedMod(mod)
	
		
func _on_game_ended(victoryType,winnerText,player1State,player2State,winnerStylePointsState):
	
	if not gameEnding:
		
		fpsNode.visible = false
		
		matchTimer.deactivate()
		
		gameEnding = true
		
		#make sure players can't pause during ending
		player1.playerController.canPauseFlag = false
		player2.playerController.canPauseFlag = false
		
					
	
		player1.lightingEffectsEnabled=false
		player2.lightingEffectsEnabled=false
		#setGlobalSpeedMod(endGameSlowDownModifier)
		
		#if gameEndTimer.is_connected("timeout",self,"_end_game"):
			#temporarliy don't end game. give player a moment to style before game sloyw down
		#	gameEndTimer.disconnect("timeout",self,"_end_game")
			
		

		

	
		#disable the light flashes of attacks
		#hide the HUD
		p1HUD.visible = false
		p2HUD.visible = false
		#gameEndTimer.startInSeconds(gameEndDelay)
		
		#yield(gameEndTimer,"timeout")
		#make sure all those in group of global speed mod are notified
		#to slow down their time tick
		#even in online mode it's fine, since game will restart anyway
		#get_tree().call_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP,GLOBALS.GLOBAL_SPEED_MOD_SETTER_FUNC,endGameSlowDownModifier)
		
		if not gameEndTimer.is_connected("timeout",self,"_end_game"):
			#start a timer so that game ends after a few seconds of slow motion
			gameEndTimer.connect("timeout",self,"_end_game",[victoryType,winnerText,player1State,player2State,winnerStylePointsState])
		#gameEndTimer.wait_time = endGameSlowMotionDuration
		gameEndTimer.startInSeconds(endGameSlowMotionDuration)
		
		#fadeds screen to black
		#fadeOutHUD.fadeOut(endGameSlowMotionDuration)
		
		#disable the light flashes of attacks
		#hide the HUD
		#p1HUD.visible = false
		#p2HUD.visible = false
		
		#if saveReplayFlag:
		#	replayHandler.save_replay(player1.playerController.inputManager.recordedCmds,player2.playerController.inputManager.recordedCmds)
			
		#save the match data only for non-training pvp matches
		#if gameMode == GLOBALS.GameModeType.STANDARD or gameMode == GLOBALS.GameModeType.PLAY_V_AI:
		if gameMode != GLOBALS.GameModeType.TRAINING and gameMode != GLOBALS.GameModeType.REPLAY:
			
			if matchDataCollector!= null:
				matchDataCollector._on_match_end(victoryType)
			
		elif gameMode == GLOBALS.GameModeType.PLAY_V_AI:
			if trainAIFlag:
				emit_signal("save_ai_model")
	
func _end_game(victoryType,winnerText,player1State,player2State,winnerStylePointsState):
	
	#disconnect from the end game timer, to make sure parameters refreshed each connection to signal
	#(sytle points wehrn't updated)
	if gameEndTimer.is_connected("timeout",self,"_end_game"):
		gameEndTimer.disconnect("timeout",self,"_end_game")
	
	
				
	player1.global_position = p1SpawnPosition
	player2.global_position = p2SpawnPosition

	#make sure players float where they should spawn
	player1.playerController.actionAnimeManager.movementAnimationManager.stopGravity()
	player2.playerController.actionAnimeManager.movementAnimationManager.stopGravity()
	
	#don't ttouch input manager physics process in online match
	var affectPHysicsPorcInputMngr = gameMode != GLOBALS.GameModeType.ONLINE_HOSTING and gameMode != GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST
	#make sure players can't input anything until count down
	player1.playerController.disableUserInput(affectPHysicsPorcInputMngr)
	player2.playerController.disableUserInput(affectPHysicsPorcInputMngr)
	
	player1.playerController.muteSoundSFX=true
	player2.playerController.muteSoundSFX=true
		
	
	#make sure all child timers timeout and stop
	for c in self.get_children():
		
		if c is frameTimerResource:
			if c.is_physics_processing():
				c.emit_signal("timeout")
				c.stop()
	

	#player1.playerController.ignoreUserInputFlag = true
	#player2.playerController.ignoreUserInputFlag = true
		
	#save the victor's info in case were doing crewbattles SO THAT restarting the match saves the 
	#wiiner's stats
	if crewBattleFlag and gameMode == GLOBALS.GameModeType.STANDARD:
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

	
	#for replayed matches we don't show result screen
	if gameMode == GLOBALS.GameModeType.REPLAY:
		#emit_signal("back_to_main_menu") this is usual
		#this is debug
		_on_start_match()
	else:	
		#wait a couple moments before ending game
		emit_signal("game_ended",victoryType,winnerText,player1State,player2State,winnerStylePointsState,player1.playerController,player2.playerController)
	
	#
	
	
#func _on_game_end_timer_ellapsed(winnerText,player1State,player2State):
	#emit_signal("game_ended",winnerText,player1State,player2State)
func _physics_process(delta):

	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	
	
	#check to see what object left the screen
	
	offScreenObjectsCheck()
	
	
	delta = delta * globalSpeedMod
	
	#make the hype of ripost slowly recover over time
	#minimum 1, which is fresh hype oover ripost
	ripostHypnessP1=max(0,ripostHypnessP1 - (delta*RIPOST_HYPE_GAINED_PER_SECOND))
	ripostHypnessP2 = max(0,ripostHypnessP2 - (delta*RIPOST_HYPE_GAINED_PER_SECOND))
		
func _on_start_match():
	preMatchStart()
	postMatchStart()

func preMatchStart():
	
	emit_signal("game_starting")
	#make sure the counter ripost hero theme music resets to start of song
	#upon new match (only during match does the song get remebmered)
	player1ThemeMusicPlayer.seek(0)
	player2ThemeMusicPlayer.seek(0)
	player1ThemeMusicPlayer.stop()
	player2ThemeMusicPlayer.stop()
	player1ThemeMusicPlayer.stream_paused = true
	player2ThemeMusicPlayer.stream_paused = true
	#print(player2ThemeMusicPlayer.stream_paused)
	#print(player1ThemeMusicPlayer.stream_paused)
	if ambienceMusic != null:
		ambienceMusic.volume_db=amibenceMusicDefaultVolume 
	
	#dont display hp label unless under 100 HP
	p1HUD.hpBar.forceDisplayHPLabel=false
	p2HUD.hpBar.forceDisplayHPLabel=false
	
	
	
	tweenFlash.init()
	koSlowMotionTween.init()
	
	gameEndTimer.reset()
	ripostWaitTimer.reset()
	counterRipostWaitTimer.reset()
	matchEndTimer.reset()
	#matchTimer.reset()
	ripostAttemptedTimer.reset()
	countDownSequenceTimer.reset()
	hitFreezeTimer.reset()
	
		
	#make sure no hitfreeze occured
	if inHitFreeze:
	 	stopHitFreeze()
		
	#this is just incase we load the stage and change game modes.
	pauseHUD.gameMode = gameMode


	#allow players input moves now  but only movement abilities
	player1.playerController.inputManager.enabledMovementOnlyCommands()
	player2.playerController.inputManager.enabledMovementOnlyCommands()

	magnifyingGlassesDisabled=true
	if not GLOBALS.DEMO_MODE_FLAG:
		#disable the light flashes of attacks
		#hide the HUD
		p1HUD.visible = true
		p2HUD.visible = true
	else:
		#disable the light flashes of attacks
		#hide the HUD
		p1HUD.visible = false
		p2HUD.visible = false
	
	#when game starts remove 1 jump to force players to land as game st
	player1.playerController.playerState.setCurrentNumberOfJumps(player1.playerController.playerState.currentNumJumps-1)
	player2.playerController.playerState.setCurrentNumberOfJumps(player2.playerController.playerState.currentNumJumps-1)
	
	#make sure the red bar visible over autoripost icon indicates can't autoripost
	if player1.cantAutoRipost:
		p1HUD.autoRipostAbilityStatusHUD.setDisableOverrideFlag(true)
	if player2.cantAutoRipost:
		p2HUD.autoRipostAbilityStatusHUD.setDisableOverrideFlag(true)
	
	#make sure the red bar visible over grab icon indicates can't grag
	if player1.cantGrab:
		p1HUD.grabResourceHUD.setDisableOverrideFlag(true)
	if player2.cantGrab:
		p2HUD.grabResourceHUD.setDisableOverrideFlag(true)
		
	#hide the extra grab cooldown indicator is hidden if player doesn't have an extra grab
	if not player1.hasAdditionalGrabCharge:
		p1HUD.grabResourceHUD2ndCharge.visible=false
	else:
		p1HUD.grabResourceHUD2ndCharge.visible=true
	if not player2.hasAdditionalGrabCharge:
		p2HUD.grabResourceHUD2ndCharge.visible=false
	else:
		p2HUD.grabResourceHUD2ndCharge.visible=true	
		
	
	#stop counting jumps. game restarted
	jumpSfxTracker.reset()
	
	#we displaye the training UI elements in training mod		
	if gameMode == GLOBALS.GameModeType.TRAINING:
		#PLAYER 2 IS THE PLAYER?
		if player1.playerName == GLOBALS.CPU_NAME:
			p1HUD.trainingModeElements.visible = false
			p2HUD.trainingModeElements.visible = true
						
			
		else:#player 1 is player
			p1HUD.trainingModeElements.visible = true
			p2HUD.trainingModeElements.visible = false
						
	else:
		
		#no training mode ui elements in other modes
		p1HUD.trainingModeElements.visible = false
		p2HUD.trainingModeElements.visible = false

	
	#not playing?
	if not musicPlayer.playing:
		musicPlayer.playRandomSound()
	#else:
	#	var currSoundPlayer = musicPlayer.getCurrentSoundPlayer()
	#	if currSoundPlayer != null:
			#restart sound
	#		currSoundPlayer.seek(0)
	
	
	numPlayersReachedHalfHP = 0
	
	if ambienceMusic != null and not ambienceMusic.playing:
		ambienceMusic.playing=true	
		ambienceMusic.seek(0)
		
	fpsNode.visible = true
	#make particles disabled while restarting match
	p1HUD.abilityBar.enableParticles = false
	p2HUD.abilityBar.enableParticles = false
	
	player1.playerController.enableParticles = false
	player2.playerController.enableParticles = false
	
	p1HUD.anitCampingIcon.visible = false
	p2HUD.anitCampingIcon.visible = false
	
	p1HUD.guardHPBar.stopGuardBreakRefillAnimation()
	p2HUD.guardHPBar.stopGuardBreakRefillAnimation()
	
	
	player1.lightingEffectsEnabled=true
	player2.lightingEffectsEnabled=true
	
	p1HUD.damageGaugeBar.enableParticles = false
	p2HUD.damageGaugeBar.enableParticles = false
	
	spriteSFXNode.deactivateAll()
	uiLayerSpriteSFXNode.deactivateAll()
	#clear the stars of damage
	p1DmgStarArray._on_num_filled_dmg_stars_changed(0,0)
	p1DmgStarArray._on_num_empty_dmg_stars_changed(0,0)
	p2DmgStarArray._on_num_filled_dmg_stars_changed(0,0)
	p2DmgStarArray._on_num_empty_dmg_stars_changed(0,0)
	
	
	#p1HUD.focusBar.enableParticles = false
	#p2HUD.focusBar.enableParticles = false
	
	var defaultGlobalSpeedMod = float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.GLOBAL_SPEED_MOD_KEY))	
	changeGlobalSpeedMod(defaultGlobalSpeedMod)
	
	defaultMatchTime = SECONDS_PER_MINUTE* float(settings.getValue(settings.TEMP_USER_SETTINGS_SECTION,settings.MATCH_TIME_IN_MINUTES_KEY))	
	#var defaultMatchTime = 3#20 seconds
	stylePointRoundDefaultTimeLength = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.STYLE_POINTS_ROUND_TIME_IN_SECONDS_KEY))	

	

	enableStylePointsRoundFlag =bool(settings.getValue(settings.TEMP_USER_SETTINGS_SECTION,settings.ENABLE_STYLE_POINTS_ROUND_KEY))	

	#let players pause once their input is enabled, so disable for now
	player1.playerController.canPauseFlag = false
	player2.playerController.canPauseFlag = false

	fadeOutHUD.init()
	
	#remove any text from last match
	p1HUD.notifyciationPanel.clear()
	p2HUD.notifyciationPanel.clear()
	
	
	gameEnding = false
	
	playersNode.resetDefaultValues()
	playersNode.enableStylePointsRoundFlag = enableStylePointsRoundFlag
	
	matchTimer.deactivate()
	
	#saveReplayFlag = false
	p1HUD.comboPanel.setVisibility(false)
	p2HUD.comboPanel.setVisibility(false)
	
	loadParticleAnimationsIntoCache()
	
	#p1HUD.circularFocusProgress.resetInitialValues()
	p1HUD.circularDamageProgress.resetInitialValues()
	#p2HUD.circularFocusProgress.resetInitialValues()
	p2HUD.circularDamageProgress.resetInitialValues()
	
	
	#stop the ripost/counter ripost timers
	#player1.playerController.ripostHandler.reset()
	#player2.playerController.ripostHandler.reset()
	
	#player1.playerController.ripostCounterHandler.init()
	#player2.playerController.ripostCounterHandler.init()
	#player1.playerController.newCounterRipostHandler.init(player1.playerController)
	#player2.playerController.newCounterRipostHandler.init(player2.playerController)
	#player1.playerController.newCounterRipostHandler.reset()
	#player2.playerController.newCounterRipostHandler.reset()
	
	#stop the tech handler from detecting a ripost
	#player1.playerController.techHandler.init(player1.playerController.actionAnimeManager)
	#player2.playerController.techHandler.init(player2.playerController.actionAnimeManager)
	

	
	#replay exists, put null argument for now. Eventually players will choose a replay file?
	#if not replayHandler.replayExists(null):
	#	player1.playerController.inputManager.startRecording()
	#	player2.playerController.inputManager.startRecording()
	#else:
		#load replay
	#	replayHandler.load_replay(player1.playerController.inputManager,player2.playerController.inputManager)
	
	
	player1.global_position = p1SpawnPosition
	player2.global_position = p2SpawnPosition
	 
		
	player1.reset()
	player2.reset()
	
	
	player1.facingRight = true
	player1.faceDirection(true)
	player2.facingRight = false
	player2.faceDirection(false)
	
	
	#first time starting match?
	if player1DefaultState ==null:
		
		
		player1DefaultState = player1.playerController.playerState.deepCopy()
		
		if player1DefaultState.hashCode() != player1.playerController.playerState.hashCode():
			print("error creating player1 state deep copy")
		#make sure the focus and dmg bar's UI reflect default values (force signals to emmit)
		#player1.playerController.playerState.setFocusCapacity(player1.playerController.playerState.defaultFocusCapacity)
		player1.playerController.playerState.setDamageGaugeCapacity(player1.playerController.playerState.defaultDamageGaugeCapacity)
		#player1.playerController.playerState.setFocus(player1.playerController.playerState.defaultFocus)
		player1.playerController.playerState.setDamageGauge(player1.playerController.playerState.defaultDamageGauge)
		
	else:
		#save repalyer here
		#player1.playerController.inputManager.startReplaying(player1.playerController.inputManager.recordedCmds)
		#replayHandler.save_replay(player1.playerController.inputManager.recordedCmds,player2.playerController.inputManager.recordedCmds)
		#replayHandler.load_replay(player1.playerController.inputManager,player2.playerController.inputManager)
		
		#set player state back to default
		player1.playerController.playerState.setPlayerState(player1DefaultState)
		if player1DefaultState.hashCode() != player1.playerController.playerState.hashCode():
			print("error reseting player2 state to original state")
		#here match restarted
	#this resets everything
	player1.playerController.actionAnimeManager.movementAnimationManager.stopAllMovement()
	player1.playerController.actionAnimeManager.movementAnimationManager.lastGravityEffect = null
	player1.playerController.actionAnimeManager.movementAnimationManager.gravity.init()
	player1.playerController.playAction(player1.playerController.actionAnimeManager.AIR_IDLE_ACTION_ID)
	#player1.playerController.restart_hook()
		
	if player2DefaultState ==null:

		player2DefaultState = player2.playerController.playerState.deepCopy()
		if player2DefaultState.hashCode() != player2.playerController.playerState.hashCode():
			print("error creating player2 state deep copy")
		#make sure the focus and dmg bar's UI reflect default values (force signals to emmit)
		#player2.playerController.playerState.setFocusCapacity(player2.playerController.playerState.defaultFocusCapacity)
		player2.playerController.playerState.setDamageGaugeCapacity(player2.playerController.playerState.defaultDamageGaugeCapacity)
		#player2.playerController.playerState.setFocus(player2.playerController.playerState.defaultFocus)
		player2.playerController.playerState.setDamageGauge(player2.playerController.playerState.defaultDamageGauge)
	else:
		#player2.playerController.inputManager.startReplaying(player2.playerController.inputManager.recordedCmds)
		#replayHandler.load_replay(player2.playerController.inputManager)
		#set player state back to default
		player2.playerController.playerState.setPlayerState(player2DefaultState)
		
		if player2DefaultState.hashCode() != player2.playerController.playerState.hashCode():
			print("error reseting player2 state to original state")
			
	player2.playerController.actionAnimeManager.movementAnimationManager.stopAllMovement()
	player2.playerController.actionAnimeManager.movementAnimationManager.lastGravityEffect = null
	player2.playerController.actionAnimeManager.movementAnimationManager.gravity.init()
	
	
	player2.playerController.playAction(player2.playerController.actionAnimeManager.AIR_IDLE_ACTION_ID)
	#player2.playerController.restart_hook()
	

	#when doing crewbattle, keep the hp, damage gaugae, damage capacity, focus, focus capacity and
	#ability bar of crew-battle match's winner, if it exists
	if crewBattleFlag and gameMode == GLOBALS.GameModeType.STANDARD and  crewBattleWinner != null:
		
		#find the plaeyr state of winner
		var winnerPlayerState = null
		if crewBattleWinner == GLOBALS.PLAYER1_CREW_BATTLE_WINNER_ID: #player 1 won last match?
			winnerPlayerState = player1.playerController.playerState
		elif crewBattleWinner == GLOBALS.PLAYER2_CREW_BATTLE_WINNER_ID: #player 2 won last match?
			winnerPlayerState = player2.playerController.playerState
		else:
			print("crew battle player sate interanl error: unknwoen kinbody winner")
		
		#shouldn't happen, but better safe than sorry
		#only copy over the last match's player state if winnder existed
		if winnerPlayerState != null:
			winnerPlayerState.hp = crewBattleWinnerPlayerState.hp
			winnerPlayerState.damageGaugeCapacity = crewBattleWinnerPlayerState.damageGaugeCapacity
			winnerPlayerState.damageGauge=crewBattleWinnerPlayerState.damageGauge
			winnerPlayerState.focusCapacity=crewBattleWinnerPlayerState.focusCapacity
			winnerPlayerState.focus=crewBattleWinnerPlayerState.focus
			winnerPlayerState.abilityBar=crewBattleWinnerPlayerState.abilityBar

	#$Camera2D.boundingBox.disableFalseWalls()
	#$Camera2D.boundingBox.resetDefaultPosition()
	$Camera2D.boundingBox.reset()
	$Camera2D.reset()
	removeAllProjectiles()
	
	removeAllAnchorPoints()
	

	#don't ttouch input manager physics process in online match
	var affectPHysicsPorcInputMngr = gameMode != GLOBALS.GameModeType.ONLINE_HOSTING and gameMode != GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST
	#make sure players can't input anything until count down
	player1.playerController.disableUserInput(affectPHysicsPorcInputMngr)
	player2.playerController.disableUserInput(affectPHysicsPorcInputMngr)
	
	player1.playerController.reset()
	player2.playerController.reset()
	
	player1.playerController.restart_hook()
	player2.playerController.restart_hook()
	
	#player1.playerController.playAction(player1.playerController.actionAnimeManager.AIR_IDLE_ACTION_ID)
	#player2.playerController.playAction(player2.playerController.actionAnimeManager.AIR_IDLE_ACTION_ID)
func postMatchStart():
	
	#for online matches, we wait for the game to synch before matchs starts.
	#any later match won't have to wait
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		
		if onlineSessionFirstMatch:
			#we wait for the game to arrive at tick where both players can act for online mode
			yield(self,"online_mode_match_started")
		
		
	#only wait for players to land in offline mode. online mode the game sync will let them land and when 
	#matched is sync, players will already be on ground
	if gameMode != GLOBALS.GameModeType.ONLINE_HOSTING and gameMode != GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		#wait a few frames after players land before can input 
		yield(player2.playerController,"landed")
		var tmpFrameTimer = frameTimerResource.new()
		add_child(tmpFrameTimer)
			
		tmpFrameTimer.start(10)#10 frames, to make sure player 2 lands too (should be safe assumption as all will have standardized bodybox)		
		#wait for a duration before speeding backup again
		yield(tmpFrameTimer,"timeout")

		remove_child(tmpFrameTimer)
	
	#snap the false walls in place
	var forceSnap =true
	boundingBox.updateBoundingBox($Camera2D.bb_rect,forceSnap)
	
	#STOP and timeout all frame timers
	#get_tree().call_group(GLOBALS.GLOBAL_TIMER_FORCE_TIMEOUT_GROUP,GLOBALS.GLOBAL_TIMER_FORCE_TIMEOUT_FUNC)
	
	#need this so the next yield to wait 1 second doesn't bug out
	#tmpFrameTimer.start(3)#10 frames, to make sure player 2 lands too (should be safe assumption as all will have standardized bodybox)		
	#wait for a duration before speeding backup again
	#yield(tmpFrameTimer,"timeout")
	#remove_child(tmpFrameTimer)

	#allow players input moves now  but only movement abilities
	#player1.playerController.inputManager.enabledMovementOnlyCommands()
	#player2.playerController.inputManager.enabledMovementOnlyCommands()
	
	emit_signal("enabling_user_input",player1,player2)
	
	
	#don't ttouch input manager physics process in online match
	var affectPHysicsPorcInputMngr = gameMode != GLOBALS.GameModeType.ONLINE_HOSTING and gameMode != GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST
	
	player1.playerController.enableUserInput(affectPHysicsPorcInputMngr)
	player2.playerController.enableUserInput(affectPHysicsPorcInputMngr)
	
	player1.playerController.muteSoundSFX=false
	player2.playerController.muteSoundSFX=false
	

	#skip the count down in training mode
	if gameMode == GLOBALS.GameModeType.REPLAY or gameMode == GLOBALS.GameModeType.STANDARD or gameMode == GLOBALS.GameModeType.PLAY_V_AI or gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		specialSFXSoundPlayer.playSound(TIMER_TICK_SOUND_ID)
		matchCountDownLabel.activateAnimation("3")
		#matchCountDownLabel.text = "3"
		#matchCountDownLabel.visible = true
		#wait a second
		#yield(get_tree().create_timer(1),"timeout")
		countDownSequenceTimer.startInSeconds(1)
		yield(countDownSequenceTimer,"timeout")
		#matchCountDownLabel.text = "2"
		specialSFXSoundPlayer.playSound(TIMER_TICK_SOUND_ID)
		matchCountDownLabel.activateAnimation("2")
		#wait a second
		#yield(get_tree().create_timer(1),"timeout")
		countDownSequenceTimer.startInSeconds(1)
		yield(countDownSequenceTimer,"timeout")
		#matchCountDownLabel.text = "1"
		specialSFXSoundPlayer.playSound(TIMER_TICK_SOUND_ID)
		matchCountDownLabel.activateAnimation("1")
		#wait a second
		#yield(get_tree().create_timer(1),"timeout")
		countDownSequenceTimer.startInSeconds(1)
		yield(countDownSequenceTimer,"timeout")
		#matchCountDownLabel.text = "Go!"
		matchCountDownLabel.activateAnimation("Go!")
		
		specialSFXSoundPlayer.playSound(MATCH_START_SOUND_ID)
		
		#start match timer
		timerState=NORMAL_MATCH_TIMEOUT
		matchTimer.activate(defaultMatchTime)
	elif gameMode == GLOBALS.GameModeType.TRAINING:
		#yield(get_tree().create_timer(2),"timeout") #give time for disabled false walls to get to destination
		pass
		
	
	#starte tracking match data only for pvp matches
	if gameMode == GLOBALS.GameModeType.STANDARD or gameMode == GLOBALS.GameModeType.PLAY_V_AI:
		matchDataCollector.startCollectingMatchData()
		pass
	
	
	#make particles enabled again
	p1HUD.abilityBar.enableParticles = true
	p2HUD.abilityBar.enableParticles = true
	
	player1.playerController.enableParticles = true
	player2.playerController.enableParticles = true
	
	p1HUD.damageGaugeBar.enableParticles = true
	p2HUD.damageGaugeBar.enableParticles = true
	
	
	#remove the cahced resources that preload shaders and materials to
	#avoid eating away at resources
	if cachedResourcesNode != null:
		$CanvasLayer.remove_child(cachedResourcesNode)
		cachedResourcesNode=null
	
	#p1HUD.focusBar.enableParticles = true
	#p2HUD.focusBar.enableParticles = true
	
	
	
	delayedMagnifyingGlassEnable()
	
	
	$Camera2D.boundingBox.enableFalseWalls()
	
	
	#allow players input moves now
	#player1.playerController.enableUserInput()
	#player2.playerController.enableUserInput()
	
	#allow players input moves now  but only movement abilities
	player1.playerController.inputManager.disableMovementOnlyCommands()
	player2.playerController.inputManager.disableMovementOnlyCommands()
	
	player1.playerController.canPauseFlag = true
	player2.playerController.canPauseFlag = true
	#wait a second
	#yield(get_tree().create_timer(0.5),"timeout")
	countDownSequenceTimer.startInSeconds(0.5)
	yield(countDownSequenceTimer,"timeout")
	
	matchCountDownLabel.text = ""
	matchCountDownLabel.visible = false
	
	
	#clear any remaining red hp on player in case crew battle
	player1.playerController.emit_signal("clear_red_hp")
	player2.playerController.emit_signal("clear_red_hp")
	
	emit_signal("game_started")

		
		

func delayedMagnifyingGlassEnable():
	var tmpFrameTimer = frameTimerResource.new()
	add_child(tmpFrameTimer)

	
	#enable the magnifying galses in 1 second
	tmpFrameTimer.startInSeconds(1)
	
	#make sure this timer isn't affected by speed slow down
	
	#wait for a duration before speeding backup again
	yield(tmpFrameTimer,"timeout")
	
	remove_child(tmpFrameTimer)
	
	magnifyingGlassesDisabled=false
	
#will play particle animations to load them into memeory. assumes
#the animations are hidden, otherwise will blink when game starts
func loadParticleAnimationsIntoCache():
	
	#want to make sure star animation load into cache, so play animation and undo changes
	p1HUD.comboPanel.stars.addDamageStar(1)
	#p1HUD.comboPanel.stars.addFocusStar(1)
	p1HUD.comboPanel.stars.clearStars()
	p2HUD.comboPanel.stars.addDamageStar(1)
	#p2HUD.comboPanel.stars.addFocusStar(1)
	p2HUD.comboPanel.stars.clearStars()
		
func _on_back_to_main_menu():
	emit_signal("back_to_main_menu")
	
func _on_back_to_online_lobby():
	emit_signal("back_to_online_lobby")
	
func _on_back_to_proficiency_select():
	emit_signal("back_to_proficiency_select")

func _on_back_to_character_select():
	emit_signal("back_to_character_select")
	
func _on_back_to_stage_select():
	emit_signal("back_to_stage_select")

func _on_save_replay():
	emit_signal("save_replay")
	
func _on_inactive_projectile_instanced(projectile,projectileScenePath,player):
	#connect("done_loading_game",projectile,"_on_done_loading_game")
	pass
#func _on_request_save_replay():
	#saveReplayFlag=true
	

#CALLED when match timer ends (either during style points round or normally when game timer expires)
func _on_match_timer_timeout():
	
	if timerState == NORMAL_MATCH_TIMEOUT:
		matchTimer.deactivate()
		timerState=STYLE_POINT_ROUND_TIMEOUT
		playersNode._on_game_match_timeout()
	elif timerState == STYLE_POINT_ROUND_TIMEOUT:
		playersNode.style_point_round_end()


func _on_ten_seconds_remaining():
	
	#show hp amount when 10 seconds left
	p1HUD.hpBar.forceHPLabelDisplay(str(int(round(player1.playerController.playerState.hp))))
	p2HUD.hpBar.forceHPLabelDisplay(str(int(round(player2.playerController.playerState.hp))))
	pass	
func _on_game_resumed():
	#the pause hud paused the main trhead, and audistream players seem
	#to implemtn a hook that toggles the "stream_paused" flag when 
	#that happens, so make sure keep music paused if it was paused before 
	#pause menu pressed
	if not player1ThemeMusicPlayer.playing:
		player1ThemeMusicPlayer.stream_paused = true
	if not player2ThemeMusicPlayer.playing:
		player2ThemeMusicPlayer.stream_paused = true
	
	
	#unpause the music on player
	#if musicPlayer.playing:	
	#	musicPlayer.stream_paused = false
	#if currSoundPlayer !=null:
	#		currSoundPlayer.stream_paused = true
#	if not musicPlayer.playing:
#		var soundPlayer
#		musicPlayer.stream_paused = true

func _on_create_anchor_point(pt):
	
	anchorPoints.add_child(pt)
	
func _on_destroy_anchor_point(pt):
	
	anchorPoints.remove_child(pt)
	pt.call_deferred("queue_free")
	
func removeAllAnchorPoints():
	for n in anchorPoints.get_children():
		anchorPoints.remove_child(n)
		n.call_deferred("queue_free")
	
	
func getRipostHypnessMod(player):
	
	if player == player1:
		return ripostHypnessP1
	else:
		return ripostHypnessP2
		
func increaseRipostHypnessMod(player):
	if player == player1:
		ripostHypnessP1 = min(ripostHypnessP1+1,MAXIMUM_RIPOST_HYPNESS_COUNT)
	else:
		ripostHypnessP2 = min(ripostHypnessP2+1,MAXIMUM_RIPOST_HYPNESS_COUNT)
		
			
func _on_display_attack_lighting(attackTypeIx,cmd,shape,xScale,yScale,angle,spriteCurrentlyFacingRight,dmg):
	
	#THIS FUNCTION adds a little sprite to show a hit happend, of color of attack  type
	var pos = shape.global_position
	
	#var sfx = newAttackSFXResource.instance()
	var sfx = newAttackSFXBuffer.get_next_scene_instance()
	
	#self.add_child(sfx)
	
	sfx.playAttackHitSfx(cmd,attackTypeIx,spriteCurrentlyFacingRight,pos,inHitFreeze)
	
	largeHitTempSpriteTemplate.displayAttackHitSfx(cmd,attackTypeIx,spriteCurrentlyFacingRight,pos,inHitFreeze)
	#the scale of special effect based on damage
	#https://docs.godotengine.org/en/stable/classes/class_@gdscript.html#class-gdscript-method-lerp
	var maxDmg = 60
	var minDmg = 0
	dmg=clamp(dmg,minDmg,maxDmg)
	
	#var minScale = 0.4
	var sfxScale = lerp(0.75,1,dmg/maxDmg)
	#sfxScale = max(sfxScale,minScale)
	sfx.scale = sfx.scale*sfxScale
	#var targetSpriteSfx = null
	#if hitSfxSpriteMap.has(attackTypeIx):
	#	targetSpriteSfx=hitSfxSpriteMap[attackTypeIx]
		
		#var newAttackSfx = dimeleeSfxResource.instance()
	#	var newAttackSfx = nmeleeSfxResource.instance()
	
	#	self.add_child(newAttackSfx)
	#	
	#	newAttackSfx.position = pos
		
	#	if not spriteCurrentlyFacingRight:
	#		newAttackSfx.scale.x = newAttackSfx.scale.x *(-1)
	#	return
	
	#else:
	#	targetSpriteSfx=otherTypeHitSfx
	
	
	#var newSprite = Sprite.new()
	#newSprite.texture = targetSpriteSfx.texture
	#newSprite.scale = targetSpriteSfx.scale
	#newSprite.position = pos
	#newSprite.visible = true
	#newSprite.z_index = targetSpriteSfx.z_index
	#self.add_child(newSprite)
	
	#wait a ssecond before removing child
	#yield(get_tree().create_timer(0.25),"timeout") #TODO, MAKE this dependent on global speed mod
	
	#self.remove_child(newSprite)
	#newSprite.call_deferred("queue_free")
	
func _on_sprite_frame_activated(sf,hud):
	
	if sf==null:
		return
	
	#make sure to disable the ripost icon when riposting isn't allowed (like during stun)
	hud.ripostAbilityStatusHUD.setDisableOverrideFlag(not sf.canRipost) #true means disable ovride activated, so negation of can ripost
	#hud.autoRipostAbilityStatusHUD.updateProgress(newAbilityBarAmt)
	#hud.counterRipostAbilityStatusHUD.updateProgress(newAbilityBarAmt)

	
func _on_sprite_animation_played(sa, hud):
	
	if sa==null:
		return
		
	#some animation can't counter ripost, update the ui to reflect this
	hud.counterRipostAbilityStatusHUD.setDisableOverrideFlag(sa.preventCounterRipost)


func _on_player_attack_clashed(hitbox1,hitbox2):
	if hitbox1 != null:
	
	
		#check for player vs player clash
		if hitbox2 != null and not hitbox1.is_projectile and not hitbox2.is_projectile:
			
			#get middle point between players and display the clash bubble sfx
			var p1Center = player1.getCenter()
			var p2Center = player2.getCenter()
			
			var midPoint = (p1Center+p2Center)/2.0
			clashBubbleSfx.position=midPoint
			clashBubbleSfx.enable()
			
		#if isCommandMeleeSpecialTool(selfHitboxArea.cmd):
		#iterate all the collision shapes, and offset their position
		#to match our sprite offset 
		for c in hitbox1.get_children():
			
			if c is CollisionShape2D:
				var pos = c.global_position
		
				
				#var sfx = newAttackSFXResource.instance()
				var sfx = newAttackSFXBuffer.get_next_scene_instance()
				
				#self.add_child(sfx)
				
				sfx.playClashSfx(pos,inHitFreeze)
				
				#scale the sfx based on damage of hitbox1
				var maxDmg = 60
				var minDmg = 0
				var dmg=clamp(hitbox1.damage,minDmg,maxDmg)
				
				#var minScale = 0.4
				var sfxScale = lerp(0.4,1,dmg/maxDmg)
				#sfxScale = max(sfxScale,minScale)
				sfx.scale = sfx.scale*sfxScale
				
			#	var newSprite = Sprite.new()
			#	newSprite.texture = clashHitSfx.texture
			#	newSprite.scale = clashHitSfx.scale
			#	newSprite.position = pos
			#	newSprite.visible = true
			#	newSprite.z_index = clashHitSfx.z_index
			#	self.add_child(newSprite)
				
				#wait a ssecond before removing child
			#	yield(get_tree().create_timer(0.25),"timeout") #TODO, MAKE this dependent on global speed mod
				
			#	self.remove_child(newSprite)
			#	newSprite.call_deferred("queue_free")
				return
				

				

func _on_display_block_sfx(hitbox,blockResult,facingRight):
		
	
	if hitbox != null:
	
		#ignore hitboxes that don't show SFX
		if not hitbox.emitsAttackSFXSignal:
			return
		#if isCommandMeleeSpecialTool(selfHitboxArea.cmd):
		#iterate all the collision shapes, and offset their position
		#to match our sprite offset 
		for c in hitbox.get_children():
			
			if c is CollisionShape2D:
				
				#var blockSfx = blockSFXResource.instance()
				var blockSfx = blockSFXBuffer.get_next_scene_instance()
				blockSfx.position = c.global_position
				
				#self.add_child(blockSfx)
				
				blockSfx.playAnimation(blockResult,facingRight)
				
				#only scale the block hit particles if not perfet block.
				#perfect blocks are max size
				if blockResult != GLOBALS.BlockResult.PERFECT:
					
					#the scale of special effect based on guard damage
					#https://docs.godotengine.org/en/stable/classes/class_@gdscript.html#class-gdscript-method-lerp
					var maxDmg = 45
					var minDmg = 5
					var dmg=clamp(hitbox.guardHPDamage,minDmg,maxDmg)
					
					#var minScale = 0.4
					var sfxScale = lerp(0.5,1.0,dmg/maxDmg)
					blockSfx.scale = blockSfx.scale*sfxScale
				else:
					pass
					
				return c.global_position
	return null

func start_flash(speed,strength):
	tweenFlash.start_interpolate_property(flashRect,"modulate:a",0,strength,speed)
	#tweenFlash.start()
	
	yield(tweenFlash,"finished")
	
	tweenFlash.start_interpolate_property(flashRect,"modulate:a",strength,0,speed)
	#tweenFlash.start()
	

func _on_pushed_against_ceiling(collider, player):
	
	#only emitt the dust against wall if in hitstun
	if not player.playerController.playerState.inHitStun:
		return
		
	var pos = player.getCenter()
	#var pos =player.position 
	#move to top center of body box
	pos.y -= (player.bodyBox.get_shape().extents.y)/2
	
	var dust = playDustParticles(pos)
	
	#flip uppside down
	dust.scale.y = dust.scale.y*(-1)
	
	applyWallHitDustTechModulate(player,dust,GLOBALS.TECH_CEILING_IX)
	dust.activate()
		
func _on_pushed_against_wall(collider,player):
	
	#only emitt the dust against wall if in hitstun
	if not player.playerController.playerState.inHitStun:
		return
	
	var xScale = null
	var pos = player.getCenter()
	if collider	== $leftwall or collider == boundingBox.leftWall:
	
		#move to left center of body box
		pos.x -= (player.bodyBox.get_shape().extents.x)/2
		
		
		xScale=1
	elif collider== $rightwall or collider == boundingBox.rightWall:
			
		#move to right center of body box
		pos.x += (player.bodyBox.get_shape().extents.x)/2
		xScale=-1
	else:
		#something went wrong with parameterrs and signals
		return
		
	
	
	var dust = playDustParticles(pos)
	
	#flip uppside down
	dust.scale.x = dust.scale.x * xScale
	
	dust.rotation_degrees=90
	
	applyWallHitDustTechModulate(player,dust,GLOBALS.TECH_WALL_IX)
	dust.activate()

func applyWallHitDustTechModulate(player,newdust,techIx):
	#d we have landing dust in hitstun  change color to indicate techable vs not techanble?
	if player.playerController.playerState.inHitStun:
	
		#we decide what color wall highlight is based on if techable
		if player.playerController.techHandler.canBeTeched(techIx):
			
			newdust.modulate = techableLandingDustModulate
			newdust.defaultModulate=techableLandingDustModulate
		else:
			newdust.modulate = untechableLandingDustModulate
			newdust.defaultModulate=untechableLandingDustModulate
	else:
		#leave the default color for dust
		#newdust.defaultModulate=newdust.unmutableDefaultModulate
		#newdust.modulate=newdust.unmutableDefaultModulate
		pass
		
func _on_display_global_temporary_sprites(tmpSprites, kinbody):
	
	spriteSFXBuffer.clear()
	opponentSpriteSFXBuffer.clear()
	
	for tmpSprite in tmpSprites:
		#display using  opponent's coordinates?
		if tmpSprite.opponentIsParent:
			opponentSpriteSFXBuffer.append(tmpSprite)
		else:
			spriteSFXBuffer.append(tmpSprite)
		
	
	#display sprite on player
	if spriteSFXBuffer.size() >0:
		spriteSFXNode.displayGlobalTemporarySprites(spriteSFXBuffer,inHitFreeze,kinbody.position,kinbody.getspriteCurrentlyFacingRight())
	#display sprite this player imposed onto opponent
	if opponentSpriteSFXBuffer.size() >0:
		
		if kinbody.playerController.opponentPlayerController != null:
			var opponentKinBody = kinbody.playerController.opponentPlayerController.kinbody			
			spriteSFXNode.displayGlobalTemporarySprites(opponentSpriteSFXBuffer,inHitFreeze,opponentKinBody.position,opponentKinBody.getspriteCurrentlyFacingRight())
	


func _on_ability_bar_changed(newAbilityBarAmt,oldAbilityBarAmt,hud):
	#make sure to update the blue to show where we are curerntly at
	hud.setAbility(newAbilityBarAmt)
	#show red to indicate how much we lost
	hud.abilityBar.displayRedBarConsummed(newAbilityBarAmt,oldAbilityBarAmt)
	
	#update the resource status hud
	hud.ripostAbilityStatusHUD.updateProgress(newAbilityBarAmt)
	hud.autoRipostAbilityStatusHUD.updateProgress(newAbilityBarAmt)
	hud.counterRipostAbilityStatusHUD.updateProgress(newAbilityBarAmt)


func displayAttackCommandParticles(cmd,attackHitPos,player):
	#make command particle float
	#var cmdParticle = commandParticleResource.instance()
	#self.add_child(cmdParticle)
	#cmdParticle.owner = self
	#cmdParticle.init()
	var cmdParticle = cmdHitParticleBuffer.get_next_particle()
	
	var success = cmdParticle.emitCommand(cmd)
	if success:
		
		#if something went wrong to compute approx. location of collision
		#just display command particle over player
		#other wise we display particle ontop of hit
		if attackHitPos == null:
			cmdParticle.position = player.getCenter()	
		else:
			cmdParticle.position = attackHitPos
		
		cmdHitParticleBuffer.trigger()


	#update()
#NETCODE signals
func _on_ping(latency):
	if pingLabel!=null:
		pingLabel.text = str(int(round(latency)))
		
func _on_input_delay_changed(new,old):
	if inputDelayLabel != null:
		inputDelayLabel.text = str(int(round(new)))
		
		
func _on_resolve_desynch():
	
	#we pause the game and give controll to host to decide if we restart match or end
	#host is player 1
	var inputDeviceId = player1.playerController.inputManager.inputDeviceId
	var opponentInputDeviceId = player2.playerController.inputManager.inputDeviceId
	var playerController=player1.playerController
	var pauseMode = GLOBALS.PauseMode.RESTART_OR_END
	
	#indicate that there was a desync (use controller disconnect lable
	pauseHUD.controllerDCLabel.text = pauseHUD.NETCODE_DESYNC_TEXT
	pauseHUD.controllerDCLabel.visible = true
	
	#make sure we override pause menu if already opened
	if pauseHUD.is_physics_processing():
		pauseHUD.resumeGame()		
	pauseHUD.activate(inputDeviceId,opponentInputDeviceId,playerController,pauseMode)
	
	#now wait for game to restart to make the text disapear, as 
	#restarting the match resyncrhonizes games
	yield(self,"game_started")
	
	pauseHUD.controllerDCLabel.visible = false

func _on_game_start_tick_arrived():
	
	#have spinning icon disapear, game is synched
	onlineSyncIcon.visible=false
	onlineSyncIcon.set_physics_process(false)
		
	if onlineSessionFirstMatch:
		emit_signal("online_mode_match_started")
	onlineSessionFirstMatch=false
	

#NETCODE signals END


