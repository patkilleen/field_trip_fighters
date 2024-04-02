extends Node
signal hit_freeze_started
signal restart_game
var GLOBALS = preload("res://Globals.gd")
const RecordingHandlerResource = preload("res://interface/training/RecordingHandler.gd")

const NO_TECH_STR = "No Tech"
const NEUTRAL_TECH_STR = "Neutral Tech"
const RIGHT_TECH_STR = "Right Tech"
const DOWN_TECH_STR = "Down Tech"
const LEFT_TECH_STR = "Left Tech"
const UP_TECH_STR = "Up Tech"

const frameTimerResource = preload("res://frameTimer.gd")

const inputManagerResource = preload("res://input_manager.gd")


enum GuardMode{
	NOT_BLOCKING,
	BLOCKING_HIGH,
	BLOCKING_LOW,
	BLOCKING_ALL
}
		
#set these up initially by root script
var botKinbody2d = null
var botPlayerController = null
var playerController = null
var npcInputManager = null
var stage = null


var reversalNpcCommand = null
var ripostBotCommand = null
#var reversalEnabled = false

var guardMode = GuardMode.NOT_BLOCKING
var commandSelectBtn = null

var npcCommand = null

var counterRiposting = false
var riposting = false

var fixedDeltaFlag  = false

var trainingCPUFlag =false
var ripostTriggerFlag = false
var counterRipostTriggerFlag = false
var playerInfiniteBarFlag = true
var botInfiniteBarFlag = true
var playerRefillBarFlag =true
var botRefillBarFlag=true
var firstPhysicsProcessCallFlag = false

var ghostAIAgentActive = false
var enableGhostAIByDefault = false
var immediatlyBlocking = true #the default one 
var ripostHitDelay = 1
var currNumHitsRipostTracking = 0
var defaultBotHP = null
var defaultPlayerHP = null


var blockingEnabled = false
var defaultBotAbilityBar = null
var defaultPlayerAbilityBar = null

var numHitsRipostDelayLineEdit = null

var playerNumEmptyDmgStarsLineEdit = null
var playerNumFilledDmgStarsLineEdit = null
var playerFocusCapLineEdit = null
var playerFocusAmountLineEdit = null

var botNumEmptyDmgStarsLineEdit = null
var botNumFilledDmgStarsLineEdit = null
var botFocusCapLineEdit = null
var botFocusAmountLineEdit = null
var playerAbilityBarChunkLineEdit= null
var botAbilityBarChunkLineEdit= null

var playerInfiniteBarCheckbox = null
var botInfiniteBarCheckbox = null

var playerRefillBarCheckbox =null
var botRefillBarCheckbox = null
	
var playerAutoCancelActiveFrameSelection =  null
var cpuAutoCancelActiveFrameSelection =  null

	
var counterRipostCheckbox = null
#var randomBlockCheckbox = null
var ripostCheckbox = null
var ripostCommandSelectBtn = null
var trainCPUCheckBox = null


var perfectBlockCheckBox = null
#var blockCheckBox = null
var behaviorSelectBtn = null
var speedSelectBtn = null
#var proximityPushBlockCehckbox = null
var blockstunPushBlockCehckbox = null

var goIntoSpecialStateCheckbox = null

var perfectBlocking = false
var blockingAfterFirstHitTriggeredHelper = false
var techBehaviorString = NO_TECH_STR 
var techButton = null

var guardSelectBtn=null
var guardBehaviorSelectBtn = null

var reversalCommandSelectBtn = null
const PROBABILITY_OF_RANDOM_BLOCK_PER_SECOND = 0.3 # will guard after 3 seconds
const LENGTH_OF_RANDOM_BLOCK_DURATIN_IN_SEC = 2 # 2 seconds of blocking

var agentRiposting = false
#by default for training
const DEFAULT_DEMO_DATA_FILE_PATH="user://demodata-ken.ser"
var demoDataFilePath = DEFAULT_DEMO_DATA_FILE_PATH

var rng = null

#set by root node
var gameMode = null
var botHeroName  =null

var ghostAIAgentResource = preload("res://ai/GhostAIAgent.gd")

var blockingAfterFirstHit =false
var blockingAfterFirstHitTriggered=false
var proxGuardEnabled = false
var ghostAI = null
var isRandomBlocking = false


var goIntoSpecialStateFlag = false #flag to indicate go into special like, like belt angry, or glove auto catch ball

var playerAutoFramePerfectAbilityCancelOnHitOnly =false
var cpuAutoFramePerfectAbilityCancelOnHitOnly = false
	
var randomlyBlockingEnabled = false
var randomBlockTimer = null

#var pushBlockOnProximityGuardEnabled = false
var pushBlockOnBlockstunEnabled = false
#var inBlockstunFlag = false

var pushBlockThisFrameFlag = false

var guardUIElements = []
var recordingHandler = null
#var abilityBarChunkSize = null
func _ready():
	set_physics_process(false)
	
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	
#	ghostAI = ghostAIAgentResource.new()
#	self.add_child(ghostAI)

	pass

	#DON'T 
func _on_npc_input_manager_initiated():
	set_physics_process(true)
	
	
	randomBlockTimer = frameTimerResource.new()
	randomBlockTimer.connect("timeout",self,"_on_random_block_ended")
	self.add_child(randomBlockTimer)
	
	rng = RandomNumberGenerator.new()
	
	#abilityBarChunkSize = botPlayerController.playerState
	
	#genreate time-based seed
	rng.randomize()
	
	
	
	#don't do anything else if were not in training mode
	if gameMode != GLOBALS.GameModeType.TRAINING:
		npcCommand = null
		return
	
		
	#connect to pause hud training HUD
	var pauseHUD  = stage.pauseHUD
	
	if gameMode == GLOBALS.GameModeType.TRAINING:
		recordingHandler = RecordingHandlerResource.new()
		self.add_child(recordingHandler)
	
		recordingHandler.init(pauseHUD,self,npcInputManager,botPlayerController)
	
	pauseHUD.connect("resumed",self,"_on_game_resumed")
	commandSelectBtn = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer/CommandSelectionButton")
	commandSelectBtn.connect("item_selected",self,"_on_command_selected")
	
	behaviorSelectBtn = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer16/BehaviorSelection")
	behaviorSelectBtn.connect("item_selected",self,"_on_behavior_selected")
	
	speedSelectBtn = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer17/speedSlectionButton")
	speedSelectBtn.connect("item_selected",self,"_on_game_speed_selected")
	
	techButton = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer18/techSlectionButton")
	techButton.connect("item_selected",self,"_on_tech_type_selected")
	
	guardSelectBtn =  pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer22/GuardTypeSelection")
	guardSelectBtn.connect("item_selected",self,"_on_guard_type_selected")
	
	guardBehaviorSelectBtn =  pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer27/GuardBehaviorSelection")
	guardBehaviorSelectBtn.connect("item_selected",self,"_on_guard_behavior_selected")
	
	reversalCommandSelectBtn = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer13/CommandSelectionButton")
	reversalCommandSelectBtn.connect("item_selected",self,"_on_bot_reversal_command_selected")
	
	playerNumEmptyDmgStarsLineEdit = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer6/dmgCapLineEdit")
	playerNumFilledDmgStarsLineEdit = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer7/dmgAmountLineEdit")
	#playerFocusCapLineEdit = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer8/focusCapLineEdit")
	#playerFocusAmountLineEdit = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer9/focusAmountLineEdit")

	botNumEmptyDmgStarsLineEdit = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer11/dmgCapLineEdit")
	botNumFilledDmgStarsLineEdit = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer12/dmgAmountLineEdit")
	#botFocusCapLineEdit = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer13/focusCapLineEdit")
	#botFocusAmountLineEdit = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer14/focusAmountLineEdit")
	
	numHitsRipostDelayLineEdit = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer4/NumRipostHitDelayLineEdit")
	#numHitsRipostDelayLineEdit.connect("text_entered",self,"_on_num_hits_ripost_delay_entered")
	
	playerInfiniteBarCheckbox = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer2/playerInfBarCheckbox")
	botInfiniteBarCheckbox = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer3/cpuInfBarCheckbox")
	
	playerRefillBarCheckbox = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer31/playerRefilBarCheckbox")
	botRefillBarCheckbox = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer32/cpuRefillBarCheckbox")
	
	playerAutoCancelActiveFrameSelection =  pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer29/activeAutoAbilityCancelSelection")
	cpuAutoCancelActiveFrameSelection =  pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer28/activeAutoAbilityCancelSelection2")
	playerAutoCancelActiveFrameSelection.connect("item_selected",self,"_on_player_auto_cancel_selection_made")
	cpuAutoCancelActiveFrameSelection.connect("item_selected",self,"_on_cpu_auto_cancel_selection_made")
	
	#proximityPushBlockCehckbox = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer22-block3/proxPushBlockCheckBox")
	

	playerAbilityBarChunkLineEdit = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer8/playerAbilityBarChunksLineEdit")
	botAbilityBarChunkLineEdit = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer9/cpuAbilityBarChunksLineEdit")
	
	ripostCheckbox = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer19/ripostCheckBox")
	counterRipostCheckbox = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer5/counterRipostCheckBox")
	trainCPUCheckBox = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer20/trainBotCheckbox")
	
	ripostCommandSelectBtn= pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer33/RipostCommandSelectionButton")
	ripostCommandSelectBtn.connect("item_selected",self,"_on_bot_ripost_command_selected")
	
	
	ripostCommandSelectBtn.add_item("None")
	ripostCommandSelectBtn.add_item("Neutral Melee")
	ripostCommandSelectBtn.add_item("Forward Melee")
	ripostCommandSelectBtn.add_item("Down Melee")
	ripostCommandSelectBtn.add_item("Back Melee")
	ripostCommandSelectBtn.add_item("Up Melee")
	
	ripostCommandSelectBtn.add_item("Neutral Special")
	ripostCommandSelectBtn.add_item("Forward Special")
	ripostCommandSelectBtn.add_item("Down Special")
	ripostCommandSelectBtn.add_item("Back Special")
	ripostCommandSelectBtn.add_item("Up Special")
	
	ripostCommandSelectBtn.add_item("Neutral Tool")
	ripostCommandSelectBtn.add_item("Forward Tool")
	ripostCommandSelectBtn.add_item("Down Tool")
	ripostCommandSelectBtn.add_item("Back Tool")
	ripostCommandSelectBtn.add_item("Up Tool")
	
	perfectBlockCheckBox= pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer22-block5/perfBlockCheckBox")
	#randomBlockCheckbox = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer22-block2/randomBlockCheckBox")
	#blockCheckBox = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer22-block/blockCheckBox")
	blockstunPushBlockCehckbox = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer22-block4/blockstunPushBlockCheckBox")
		
	
	guardUIElements.append(pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer27"))#behavior button
	guardUIElements.append(pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer22-block5"))#perfect block
	guardUIElements.append(pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer22-block4"))#pushblock
	
	goIntoSpecialStateCheckbox= pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer30/specialCheckbox")
	
	#hide the block elements that are only available when picking block
	for node in guardUIElements:
		node.visible = false
	var saveDemoDataBtn = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer21/saveDemoDataMenuButton")
	#saveDemoDataBtn.connect("pressed",ghostAI.situationHandler,"saveGhostDBFile")
	saveDemoDataBtn.connect("pressed",self,"_on_save_demo_data_btn_pressed")
	
	var loadDemoDataBtn = pauseHUD.get_node("wrapper/ScrollContainer/TrainingHUD/HBoxContainer21/loadDemoDataMenuButton")
	#loadDemoDataBtn.connect("pressed",ghostAI.situationHandler,"loadAIDBIntoMemory")
	loadDemoDataBtn.connect("pressed",self,"_on_load_demo_data_btn_pressed")
	
	#playerInfiniteBarCheckbox.connect("pressed",self,"_on_player_infinite_bar_check_box_pressed",[playerInfiniteBarCheckbox])
	#botInfiniteBarCheckbox.connect("pressed",self,"_on_bot_infinite_bar_check_box_pressed",[botInfiniteBarCheckbox])
	#counterRipostCheckbox.connect("pressed",self,"_on_counter_ripost_check_box_pressed",[counterRipostCheckbox])
	
	#default for now
	npcCommand = npcInputManager.cmd

	var collisionHandler = botPlayerController.get_node("CollisionHandler")
	collisionHandler.connect("player_was_hit",self,"_on_bot_was_hit")
	collisionHandler.connect("hitting_player",self,"_on_bot_hitting")
	collisionHandler.connect("player_invincible_was_hit",self,"_on_bot_invincibility_was_hit")
	
	
	collisionHandler = playerController.get_node("CollisionHandler")
	collisionHandler.connect("player_was_hit",self,"_on_player_was_hit")
	collisionHandler.connect("hitting_player",self,"_on_player_hitting")
	
	
	botPlayerController.connect("entered_block_hitstun",self, "_on_entered_block_hitstun")
	botPlayerController.connect("exited_block_stun",self, "_on_exited_block_stun")
	

	var botPlayerState = botPlayerController.get_node("PlayerState")
	
	botPlayerState.connect("changed_in_hitstun",self,"_on_bot_hit_stun_change")
	botPlayerState.connect("hp_changed",self,"_on_bot_hp_changed")
	#botPlayerState.connect("ability_bar_changed",self,"_on_bot_ability_bar_changed")
	
	var playerState = playerController.get_node("PlayerState")
	playerState.connect("changed_in_hitstun",self,"_on_player_hit_stun_change")
	playerState.connect("hp_changed",self,"_on_player_hp_changed")
	
	
	#botPlayerController.get_node("CollisionHandler").connect("proximity_guard_enabled_changed",self,"_on_proximity_guard_enabled_changed")
	
	#playerState.connect("ability_bar_changed",self,"_on_player_ability_bar_changed")
	
	playerController.connect("about_to_attempt_ripost",self,"_on_player_attempting_ripost")

	#collisionHandler = botPlayerController.get_node("CollisionHandler")
	#collisionHandler.connect("landing_on_ground",self,"_on_land")
	#collisionHandler.connect("landing_on_platform",self,"_on_land")
	botPlayerController.connect("landed",self,"_on_landed")
	botPlayerController.actionAnimeManager.connect("action_animation_finished",self,"_on_bot_action_animation_finished")
	#var mvmAnimationMngr = botPlayerController.get_node("ActionAnimationManager/MovementAnimationManager")
	
	#mvmAnimationMngr.connect("wall_collision",self,"_on_wall_collision")
	#mvmAnimationMngr.connect("ceiling_collision",self,"_on_ceiling_collision")
	
	#collisionHandler.connect("pushed_against_wall",self,"_on_wall_collision")
	#collisionHandler.connect("pushed_against_ceiling",self,"_on_ceiling_collision")
	
	#collisionHandler.connect("pushed_against_wall",techHandler,"_on_wall_collision")
	#collisionHandler.connect("pushed_against_ceiling",techHandler,"_on_ceiling_collision")

func _on_first_physics_process_call():
		
	ghostAI = ghostAIAgentResource.new()
	
	ghostAI.connect("attempt_ripost",self,"_on_agent_attempt_ripost")
	self.add_child(ghostAI)
	
	#only disable the default right-stick behavior in training mode
	if gameMode == GLOBALS.GameModeType.TRAINING:
		
		#make sure C-stick macros are disabled, as they are used in training mode
		playerController.inputManager.remapButton(playerController.inputManager.BTN_C_STICK_LEFT_KEY, null)
		playerController.inputManager.remapButton(playerController.inputManager.BTN_C_STICK_RIGHT_KEY, null)
		playerController.inputManager.remapButton(playerController.inputManager.BTN_C_STICK_UP_KEY, null)
		playerController.inputManager.remapButton(playerController.inputManager.BTN_C_STICK_DOWN_KEY, null)
		
		
		
		npcInputManager.remapButton(playerController.inputManager.BTN_C_STICK_LEFT_KEY, null)
		npcInputManager.remapButton(playerController.inputManager.BTN_C_STICK_RIGHT_KEY, null)
		npcInputManager.remapButton(playerController.inputManager.BTN_C_STICK_UP_KEY, null)
		npcInputManager.remapButton(playerController.inputManager.BTN_C_STICK_DOWN_KEY, null)
		
	
	playerController.actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_sprite_animation_played")
	
	if gameMode == GLOBALS.GameModeType.TRAINING:
		#disconnect bot controller for action animation finished to enable frame perfect reversals
		botPlayerController.actionAnimeManager.disconnect("action_animation_finished",botPlayerController,"_on_action_animation_finished")
		
		#have to connect here. for some reason connecting earlier will not capture signal properly
		botPlayerController.collisionHandler.connect("pushed_against_wall",self,"_on_wall_collision")
		botPlayerController.collisionHandler.connect("pushed_against_ceiling",self,"_on_ceiling_collision")
	
	
	


	#unconnected playercontroll and reconect to wall/ceiling collision, so that our functions called first
	
	disableAbilityBarParticles(playerController)
	disableAbilityBarParticles(botPlayerController)
	
	npcInputManager.controller1InputDevice = playerController.inputManager.inputDeviceId
	
	if npcInputManager.controller1InputDevice == GLOBALS.PLAYER1_INPUT_DEVICE_ID:
		npcInputManager.controller2InputDevice=GLOBALS.PLAYER2_INPUT_DEVICE_ID
	else:
		npcInputManager.controller2InputDevice=GLOBALS.PLAYER1_INPUT_DEVICE_ID

	#aiDBFilePath,_npcInputManager,playerController
	#gona have to think about how to swap between reading demo data of player
	#and the playing the cpu
	ghostAI.init(demoDataFilePath,npcInputManager,botPlayerController,gameMode,botHeroName)#todo: fill out params
	
	#were not in traing mode (this is hacky and not ellegant, but it should be fine)
	if enableGhostAIByDefault:
		enableGhostAI()
		botPlayerController.connect("userInputEnabledChange",self,"_on_userInputEnabledChange")
	
	
#called when pause hud closed and game resumes, which updates all the training parameters
#change before closing traiing HUD
func _on_game_resumed():
	#
	
	#disable the particle animations from seeting bar values
	
	
	botPlayerController.enableParticles = false
	playerController.enableParticles = false
	
	
	stage.p1HUD.damageGaugeBar.enableParticles = false
	stage.p2HUD.damageGaugeBar.enableParticles = false
	
	#reset the guard hp
	botPlayerController.playerState.guardHP= botPlayerController.playerState.maxGuardHP
	playerController.playerState.guardHP= playerController.playerState.maxGuardHP
	
	disableBlocking()
	#stage.p1HUD.focusBar.enableParticles = false
	#stage.p2HUD.focusBar.enableParticles = false
	#_on_proximity_block_push_block_check_box_pressed()
	_on_blockstun_block_push_block_check_box_pressed()
	_on_player_infinite_bar_check_box_pressed()
	_on_bot_infinite_bar_check_box_pressed()
	_on_player_refill_bar_check_box_pressed()
	_on_bot_refill_bar_check_box_pressed()
	_on_ripost_check_box_pressed()
	_on_counter_ripost_check_box_pressed()
	#_on_random_Block_Checkbox()
	#_on_blockCheckBox_pressed()
	_on_update_num_damage_stars()
	_on_train_cpu_check_box_pressed()
	_on_perfect_block_check_box_pressed()
	_on_special_character_state_check_box_pressed()
	
	blockingAfterFirstHitTriggeredHelper = false
	var ripostHitDelayNumText =  numHitsRipostDelayLineEdit.text
	
	#no longer bocking first hit
	blockingAfterFirstHitTriggered = false
	
	_on_num_hits_ripost_delay_entered(ripostHitDelayNumText)
	
	
	
	if goIntoSpecialStateFlag:
		var params =null #TODO: add field to specify what state
		playerController.trainingModeEnterCharDependentState(params)
		
	#RESET ABILITY BAR specified by pause hud
	
	botPlayerController.playerState.setAbilityBarAmountInChunks(getLineEditIntHepler(botAbilityBarChunkLineEdit,0,24))
	playerController.playerState.setAbilityBarAmountInChunks(getLineEditIntHepler(playerAbilityBarChunkLineEdit,0,24))
	
	#re-enable the particles
	botPlayerController.enableParticles = true
	playerController.enableParticles = true
	
	
	stage.p1HUD.damageGaugeBar.enableParticles = true
	stage.p2HUD.damageGaugeBar.enableParticles = true
	
	#stage.p1HUD.focusBar.enableParticles = true
	#stage.p2HUD.focusBar.enableParticles = true

func _on_update_num_damage_stars():
	
	#disable the particles for damage/focus decrease/increase temporarily, when we reset bars
	playerController.enableParticles = false
	botPlayerController.enableParticles = false
	textFieldParseInt(playerNumEmptyDmgStarsLineEdit,playerController.playerState,"numEmptyDmgStars",0,GLOBALS.MAX_NUM_DMG_STARS)
	textFieldParseInt(playerNumFilledDmgStarsLineEdit,playerController.playerState,"numFilledDmgStars",0,GLOBALS.MAX_NUM_DMG_STARS)
	
	textFieldParseInt(botNumEmptyDmgStarsLineEdit,botPlayerController.playerState,"numEmptyDmgStars",0,GLOBALS.MAX_NUM_DMG_STARS)
	textFieldParseInt(botNumFilledDmgStarsLineEdit,botPlayerController.playerState,"numFilledDmgStars",0,GLOBALS.MAX_NUM_DMG_STARS)

#	line_text_max_value(playerNumFilledDmgStarsLineEdit,playerController.playerState,"numFilledDmgStars","numEmptyDmgStars")
	
#	line_text_max_value(botNumFilledDmgStarsLineEdit,botPlayerController.playerState,"numFilledDmgStars","numEmptyDmgStars")
	
		
	#var old =numFilledDmgStars
	#numFilledDmgStars = num
	playerController.enableParticles = true
	botPlayerController.enableParticles = true
	
#func line_text_max_value(lineEdit,playerState,playerStateMemberName,playerStateMaxMemberName):
	#var text = lineEdit.text
	#if text.is_valid_float():
		
	#	var maxValue = playerState.get(playerStateMaxMemberName)
		
	#	var value = float(text)
		
	#	if value > maxValue:
	#		value = maxValue
	#		lineEdit.text=str(value)
	#	playerState.set(playerStateMemberName,value)
	#else:
		#lineEdit.text = playerState.get(playerStateMemberName)
		
func textFieldParseInt(lineEdit,playerState,playerStateMemberName,minValue,maxValue):
	var text = lineEdit.text
	if text.is_valid_integer():
		
		
		var value = int(text)
		
		if value < minValue:
			value = minValue
			lineEdit.text=str(value)
			
		if value > maxValue:
			value = maxValue
			lineEdit.text=str(value)
		playerState.set(playerStateMemberName,value)
	else:
		lineEdit.text = str(minValue)


func getLineEditIntHepler(lineEdit,minValue,maxValue):
	var text = lineEdit.text
	if text.is_valid_integer():
		
		
		var value = int(text)
		
		if value < minValue:
			value = minValue
			lineEdit.text=str(minValue)
			
		if value > maxValue:
			value = maxValue
			lineEdit.text=str(value)
		return value
	else:
		lineEdit.text = str(maxValue)
		
		return maxValue
		

#func _on_proximity_block_push_block_check_box_pressed():
#	var enableFlag  = proximityPushBlockCehckbox.pressed
#	pushBlockOnProximityGuardEnabled = bool(enableFlag)

func _on_blockstun_block_push_block_check_box_pressed():
	var enableFlag  = blockstunPushBlockCehckbox.pressed
	pushBlockOnBlockstunEnabled = bool(enableFlag)
	

func _on_special_character_state_check_box_pressed():
	var enableFlag  = bool(goIntoSpecialStateCheckbox.pressed)
	goIntoSpecialStateFlag=enableFlag
	


func _on_player_infinite_bar_check_box_pressed():
	var enableFlag  = playerInfiniteBarCheckbox.pressed
	playerInfiniteBarFlag = bool(enableFlag)
	
	#inifite ability bar?
	if playerInfiniteBarFlag:
		
		#var hud = stage.lookupPlayerHUD(playerController.kinbody)
		#make sure particles of dropping chunks disabled, casue infinite bar
		#hud.abilityBar.enableParticles=false
		disableAbilityBarParticles(playerController)
		#playerController.playerState.abilityBar = playerController.playerState.abilityBarMaximum
		playerController.playerState.setAbilityBarAmountInChunks(getLineEditIntHepler(playerAbilityBarChunkLineEdit,0,24))
	else:
		#var hud = stage.lookupPlayerHUD(playerController.kinbody)
		#make sure particles of dropping chunks enabled, casue bar can be drained now
	#	hud.abilityBar.enableParticles=true
		enableAbilityBarParticles(playerController)

func _on_player_refill_bar_check_box_pressed():
	var enableFlag  = playerRefillBarCheckbox.pressed
	playerRefillBarFlag = bool(enableFlag)
	
	#refills ability bar when combo ends or unpause?
	if playerRefillBarFlag:
		
		#var hud = stage.lookupPlayerHUD(playerController.kinbody)
		#make sure particles of dropping chunks disabled, casue infinite bar
		#hud.abilityBar.enableParticles=false
		disableAbilityBarParticles(playerController)
		#playerController.playerState.abilityBar = playerController.playerState.abilityBarMaximum
		playerController.playerState.setAbilityBarAmountInChunks(getLineEditIntHepler(playerAbilityBarChunkLineEdit,0,24))
	else:
		#var hud = stage.lookupPlayerHUD(playerController.kinbody)
		#make sure particles of dropping chunks enabled, casue bar can be drained now
	#	hud.abilityBar.enableParticles=true
		enableAbilityBarParticles(playerController)


func _on_player_auto_cancel_selection_made(ix):
	
	
	var selString = playerAutoCancelActiveFrameSelection.get_item_text(ix)
	
	if selString == GLOBALS.TRAINING_MODE_AFAAC_DISABLED:
		playerAutoFramePerfectAbilityCancelOnHitOnly=false
		playerController.autoActiveFramesAbilityCancelFlag =false
	elif selString == GLOBALS.TRAINING_MODE_AFAAC_ENABLED:
		playerAutoFramePerfectAbilityCancelOnHitOnly=false
		playerController.autoActiveFramesAbilityCancelFlag =true
	elif selString == GLOBALS.TRAINING_MODE_AFAAC_ON_HIT_ONLY:#TODO: FIX THIS. THERE IS ISSUE WHERE PORT PRIOIRTY HAS IT SO PHYSPCS PROCEE OF PLAYER OCCURE BEFORE ON HITS CALLED AND AFTER ON THIS CALLED... (CDOESN'T WORK FOR PLAYER 1)
		playerAutoFramePerfectAbilityCancelOnHitOnly=true
		playerController.autoActiveFramesAbilityCancelFlag =false #will be set upon being hit
		

func _on_cpu_auto_cancel_selection_made(ix):
	var selString = cpuAutoCancelActiveFrameSelection.get_item_text(ix)
	
	if selString == GLOBALS.TRAINING_MODE_AFAAC_DISABLED:
		cpuAutoFramePerfectAbilityCancelOnHitOnly=false
		botPlayerController.autoActiveFramesAbilityCancelFlag =false
	elif selString == GLOBALS.TRAINING_MODE_AFAAC_ENABLED:
		cpuAutoFramePerfectAbilityCancelOnHitOnly=false
		botPlayerController.autoActiveFramesAbilityCancelFlag =true
	elif selString == GLOBALS.TRAINING_MODE_AFAAC_ON_HIT_ONLY:#TODO: FIX THIS. THERE IS ISSUE WHERE PORT PRIOIRTY HAS IT SO PHYSPCS PROCEE OF PLAYER OCCURE BEFORE ON HITS CALLED AND AFTER ON THIS CALLED... (DOESN'T WORK FOR PLAYER 1)
		cpuAutoFramePerfectAbilityCancelOnHitOnly=true
		botPlayerController.autoActiveFramesAbilityCancelFlag =false #will be set upon being hit
		
	
func _on_tech_type_selected(ix):
		
	techBehaviorString = techButton.get_item_text(ix)
	
		

func disableAbilityBarParticles(pcontroller):
	pass
	#var hud = stage.lookupPlayerHUD(pcontroller.kinbody)
	#make sure particles of dropping chunks disabled, casue infinite bar
#	hud.abilityBar.enableParticles=false

func enableAbilityBarParticles(pcontroller):
	pass
	#var hud = stage.lookupPlayerHUD(pcontroller.kinbody)
	#make sure particles of dropping chunks disabled, casue infinite bar
	#hud.abilityBar.enableParticles=true

	
func _on_bot_infinite_bar_check_box_pressed():
	var enableFlag  = botInfiniteBarCheckbox.pressed
	botInfiniteBarFlag = bool(enableFlag)
	
	#inifite ability bar?
	if botInfiniteBarFlag:
		
		#var hud = stage.lookupPlayerHUD(botPlayerController.kinbody)
		#make sure particles of dropping chunks disabled, casue infinite bar
		#hud.abilityBar.enableParticles=false
		disableAbilityBarParticles(botPlayerController)
		
		#botPlayerController.playerState.abilityBar = botPlayerController.playerState.abilityBarMaximum
		botPlayerController.playerState.setAbilityBarAmountInChunks(getLineEditIntHepler(botAbilityBarChunkLineEdit,0,24))
	else:
		#var hud = stage.lookupPlayerHUD(botPlayerController.kinbody)
		#make sure particles of dropping chunks enabled, casue bar can be drained now
		#hud.abilityBar.enableParticles=true
		enableAbilityBarParticles(botPlayerController)

func _on_bot_refill_bar_check_box_pressed():
	var enableFlag  = botRefillBarCheckbox.pressed
	botRefillBarFlag = bool(enableFlag)
	
	#reffill ability bar of bot when combo ends?
	if botRefillBarFlag:
		
		#var hud = stage.lookupPlayerHUD(botPlayerController.kinbody)
		#make sure particles of dropping chunks disabled, casue infinite bar
		#hud.abilityBar.enableParticles=false
		disableAbilityBarParticles(botPlayerController)
		
		#botPlayerController.playerState.abilityBar = botPlayerController.playerState.abilityBarMaximum
		botPlayerController.playerState.setAbilityBarAmountInChunks(getLineEditIntHepler(botAbilityBarChunkLineEdit,0,24))
	else:
		#var hud = stage.lookupPlayerHUD(botPlayerController.kinbody)
		#make sure particles of dropping chunks enabled, casue bar can be drained now
		#hud.abilityBar.enableParticles=true
		enableAbilityBarParticles(botPlayerController)
		
func _on_counter_ripost_check_box_pressed():
	var enableFlag  = counterRipostCheckbox.pressed
	counterRiposting = bool(enableFlag)

#func _on_random_Block_Checkbox():
#	var enableFlag  = randomBlockCheckbox.pressed
#	isRandomBlocking = bool(enableFlag)
#func _on_blockCheckBox_pressed():
#	var enabledFlag = blockCheckBox.pressed
#	blockingAfterFirstHit=bool(enabledFlag)
func _on_train_cpu_check_box_pressed():
	var enableFlag  = trainCPUCheckBox.pressed
	trainingCPUFlag = bool(enableFlag)
	
	if trainingCPUFlag:
		ghostAI.enableDemoDataCollection()
	else:
		
		ghostAI.disableDemoDataCollection()
		
func _on_perfect_block_check_box_pressed():
	var enableFlag  = perfectBlockCheckBox.pressed
	perfectBlocking = bool(enableFlag)
		

func _on_ripost_check_box_pressed():
	var enableFlag  = ripostCheckbox.pressed
	riposting = bool(enableFlag)

#called when bot uses bar
#func _on_bot_ability_bar_changed(newAmount):
	
	#the deafult is being set, first time writing to ability bar?
#	if defaultBotAbilityBar == null and newAmount != null:
#		defaultBotAbilityBar = newAmount
#		botPlayerController.playerState.disconnect("ability_bar_changed",self,"_on_bot_ability_bar_changed")
	
#called when player uses bar
#func _on_player_ability_bar_changed(newAmount):
	
	#the deafult is being set, first time writing to ability bar?
#	if defaultPlayerAbilityBar == null and newAmount != null:
		
		
#		defaultPlayerAbilityBar = newAmount
#		playerController.playerState.disconnect("ability_bar_changed",self,"_on_player_ability_bar_changed")

func _on_player_hp_changed(hp):
	
	#first time setting hp, ie., default value?
	if defaultPlayerHP == null:
		defaultPlayerHP = hp
		
#called when player changes hitstun
func _on_player_hit_stun_change(flag):
	
	#no longer in hitstun?
	if not flag:
		
		#make sure hp doesn't drain and rests after combo
		playerController.playerState.hp = defaultBotHP
		
		#refill bar when combo ends?
		if botRefillBarFlag:
			botPlayerController.playerState.setAbilityBarAmountInChunks(getLineEditIntHepler(botAbilityBarChunkLineEdit,0,24))
	
		


func _on_bot_hp_changed(hp):
	
	#first time setting hp, ie., default value?
	if defaultBotHP == null:
		defaultBotHP = hp
		
#called when bot changes hitstun
func _on_bot_hit_stun_change(flag):
	
	#no longer in hitstun?
	if not flag:
		#make sure hp doesn't drain and rests after combo
		botPlayerController.playerState.hp = defaultBotHP
		
		#refill bar when combo ends?
		if playerRefillBarFlag:
			playerController.playerState.setAbilityBarAmountInChunks(getLineEditIntHepler(playerAbilityBarChunkLineEdit,0,24))
	
func _on_player_attempting_ripost(cmd):
	
	counterRipostTriggerFlag = true
		
		
#called when hitting bot in invinsibility frames
func _on_bot_invincibility_was_hit(otherHitboxArea, selfHurtboxArea):
	_on_bot_was_hit(otherHitboxArea, selfHurtboxArea)
	

#called when bot hits players
func _on_player_was_hit(otherHitboxArea, selfHurtboxArea):
	
	if cpuAutoFramePerfectAbilityCancelOnHitOnly:
	#	yield(self,"hit_freeze_started")
	#	yield(get_tree(),"physics_frame")
		botPlayerController.autoActiveFramesAbilityCancelFlag=true
		#yield(get_tree(),"physics_frame")
	pass	
#	if cpuAutoFramePerfectAbilityCancelOnHitOnly:
	#	yield(self,"hit_freeze_started")
	#	yield(get_tree(),"physics_frame")
#		botPlayerController.autoActiveFramesAbilityCancelFlag=true
#		yield(get_tree(),"physics_frame")
	#	yield(get_tree(),"physics_frame")
#		botPlayerController.autoActiveFramesAbilityCancelFlag=false
	
func _on_player_hitting(otherHitboxArea, selfHurtboxArea):
	pass		
	#called when bot hits players
func _on_bot_hitting(otherHitboxArea, selfHurtboxArea):
	pass
	#if cpuAutoFramePerfectAbilityCancelOnHitOnly:
	##	yield(self,"hit_freeze_started")
	#	yield(get_tree(),"physics_frame")
		#botPlayerController.autoActiveFramesAbilityCancelFlag=true
		#yield(get_tree(),"physics_frame")
		#yield(get_tree(),"physics_frame")
		#botPlayerController.autoActiveFramesAbilityCancelFlag=false
		
		
func handlePlayerAutoFramePerfectAbilityCancelOnHit():
		
	if playerAutoFramePerfectAbilityCancelOnHitOnly:
	#	yield(self,"hit_freeze_started")
	#	yield(get_tree(),"physics_frame")
		playerController.autoActiveFramesAbilityCancelFlag=true
		#yield(get_tree(),"physics_frame")
		#yield(get_tree(),"physics_frame")
		#yield(get_tree(),"physics_frame")
		#yield(playerController.actionAnimeManager.spriteAnimationManager,"sprite_animation_played")
		#playerController.autoActiveFramesAbilityCancelFlag=false
	
func _on_sprite_animation_played(param):
	if playerAutoFramePerfectAbilityCancelOnHitOnly:
		playerController.autoActiveFramesAbilityCancelFlag=false

#called when bot is hit by player
func _on_bot_was_hit(otherHitboxArea, selfHurtboxArea):
	
	#on hit, do we enable the auto ability cancel frame perfect on active frames?
	#if playerAutoFramePerfectAbilityCancelOnHitOnly:
		#yield(self,"hit_freeze_started")
		#yield(get_tree(),"physics_frame")
	#	playerController.autoActiveFramesAbilityCancelFlag=true
	handlePlayerAutoFramePerfectAbilityCancelOnHit()
	
	#figure out if npc is blocking?
	var blocking = false
	if isRandomBlocking:	
		blocking = randomlyBlockingEnabled
	elif blockingAfterFirstHit:
		blocking = true 
	elif immediatlyBlocking:
		blocking = true 
		
	if blockingEnabled and blocking:
		
		#in the case it is blocking, in the mode where everythign is blocked correctly
		#we manually tell the gaurd manager to block high vs high attacks and low vs low attacks
		if guardMode ==GuardMode.BLOCKING_ALL:
			if otherHitboxArea.low:#low block
				botPlayerController.guardHandler.holdingBackward=true
				botPlayerController.guardHandler.holdingDown=true
				
			else:#high block
				botPlayerController.guardHandler.holdingBackward=true
				botPlayerController.guardHandler.holdingDown=false
		else:
				
	
			if guardMode ==GuardMode.BLOCKING_HIGH:
				botPlayerController.guardHandler.holdingBackward=true
				botPlayerController.guardHandler.holdingDown=false
				
			elif guardMode ==GuardMode.BLOCKING_LOW:
				botPlayerController.guardHandler.holdingBackward=true
				botPlayerController.guardHandler.holdingDown=true		
	
	#record the command we were hit with on hit when bot is riposting
	if riposting and otherHitboxArea.ripostabled:
		
		#if :
		currNumHitsRipostTracking = currNumHitsRipostTracking  + 1
		
		#ripostHitDelay <= 1 no delay? (1 would mean each hit, so has to be atleast 2 to make it so sometimes no ripost)
		#currNumHitsRipostTracking % ripostHitDelay == 0: #only ripost at a certain hit frequency (every 3 hits for example, ripostHitDelay = 3)
		
		
		if ripostBotCommand != null:
			#bot is told to ripost a specific command?
			var cmdHitBy = otherHitboxArea.cmd
			if cmdHitBy == ripostBotCommand:
				var ripostCmd = npcInputManager.ripostCommandReverseMap[cmdHitBy]
			
				npcCommand = ripostCmd
				
				npcInputManager.cmdBuffer.clear()
				var _cmd = npcInputManager.getFacingDependantCommand(npcCommand, botKinbody2d.facingRight)
				npcInputManager.cmd = _cmd
				npcInputManager.lastCommand = _cmd
				botPlayerController.skipHandleInputThisFrame=true #make sure this early reverasal input is only input processed this frame
				botPlayerController.handleUserInput()
		
				ripostTriggerFlag = true
		if ripostHitDelay > 0 and ((ripostHitDelay == 1) or (currNumHitsRipostTracking % ripostHitDelay == 0)):# 0 or smaller means doesn't ripost based on hit count
			
			
					
			var cmdHitBy = otherHitboxArea.cmd
			
			if npcInputManager.ripostCommandReverseMap.has(cmdHitBy):
				var ripostCmd = npcInputManager.ripostCommandReverseMap[cmdHitBy]
				
				npcCommand = ripostCmd
				
				if gameMode == GLOBALS.GameModeType.TRAINING:
					
		
					npcInputManager.cmdBuffer.clear()
					var _cmd = npcInputManager.getFacingDependantCommand(npcCommand, botKinbody2d.facingRight)
					npcInputManager.cmd = _cmd
					npcInputManager.lastCommand = _cmd
					botPlayerController.skipHandleInputThisFrame=true #make sure this early reverasal input is only input processed this frame
					botPlayerController.handleUserInput()
			
				ripostTriggerFlag = true
				
	#wait one tick before enabling the blokcing after the hit, otherwise bot will instanctly block
	blockingAfterFirstHitTriggeredHelper=true
	#blockingAfterFirstHitTriggered = true
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	
	if not firstPhysicsProcessCallFlag:
		_on_first_physics_process_call()
		firstPhysicsProcessCallFlag = true
	
	
	#if botPlayerController.ignoreUserInputFlag:	
	#botPlayerController.handleDirectionalInput()
	#playerController.ignoreUserInputFlag:	
	#playerController.handleDirectionalInput()
	
	
	var cmd = null	
	
	
	#if not ghostAIAgentActive:
	if gameMode != GLOBALS.GameModeType.PLAY_V_AI:
		
		
		
#skip casae where eneabled, the inputhandler function will deal with this
#	if proxGuardEnabled:
#		return
		
	#here want to avoid sticking in prox block even when move wiffed u
	#blockign from proximity guard?
#	if actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_AIR_HOLD_BACK_BLOCK_ACTION_ID):
		#KEep momentum after releasing block and go idle in air, was blocking
#		playActionKeepOldCommand(actionAnimeManager.AIR_IDLE_ACTION_ID)
#	elif actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_STANDING_HOLD_BACK_BLOCK_ACTION_ID):
		#KEep momentum after releasing block and go idle in air, was blocking
#		playActionKeepOldCommand(actionAnimeManager.GROUND_IDLE_ACTION_ID)
		if blockingEnabled and isRandomBlocking:	
			if not randomlyBlockingEnabled:
				disableBlocking()
				#check to randomly block
				if generateProbabilistichEvent(PROBABILITY_OF_RANDOM_BLOCK_PER_SECOND * GLOBALS.SECONDS_PER_FRAME):
				
				
					randomlyBlockingEnabled=true
					#randomBlockTimer.start(LENGTH_OF_RANDOM_BLOCK_DURATIN_IN_SEC)
					randomBlockTimer.startInSeconds(LENGTH_OF_RANDOM_BLOCK_DURATIN_IN_SEC)
					#block next frame
			else:
				enableBlocking()
				if guardMode ==GuardMode.BLOCKING_LOW:
					npcCommand=npcInputManager.Command.CMD_BACKWARD_CROUCH
					cmd =npcInputManager.Command.CMD_BACKWARD_CROUCH
		#does the bot block after first hit?
		elif blockingEnabled and blockingAfterFirstHit:
			
			var blocking = false
			
			#if proxGuardEnabled:
			#if botPlayerController.collisionHandler.isProximityGuardEnabled():
				#has bot been hit?
			if blockingAfterFirstHitTriggered:
				blocking=true
		
			if blocking:
				enableBlocking()
				if guardMode ==GuardMode.BLOCKING_LOW:
					npcCommand=npcInputManager.Command.CMD_BACKWARD_CROUCH
					cmd =npcInputManager.Command.CMD_BACKWARD_CROUCH
								
			else:
				disableBlocking()
				
				
				
			
			#TODO: don't use commands to determine blocking, instead many configure guard manager
			#to process hold back (and possible down) and idsable bot player controller input processing
			#that way block always (discovered this by holding back and swapping from player to CPU in training mode
			#the player blocked even crossups)
		#	if blocking:
				#in proximity of attack block
		#		cmd = npcInputManager.getFacingDependantCommand(npcInputManager.Command.CMD_MOVE_BACKWARD, botKinbody2d.facingRight)	
		#	else:
				#no attack in progress, don't block
		#		cmd = npcInputManager.getFacingDependantCommand(npcInputManager.Command.CMD_STOP_MOVE_BACKWARD, botKinbody2d.facingRight)								
		
		elif blockingEnabled and immediatlyBlocking:
			enableBlocking()
		else:
			
			#disableBlocking()

			#is the npc doing a reversal?			
			#if reversalEnabled and reversalNpcCommand != null:
			#	reversalEnabled=false #only do it once at end of animation
			#	cmd = npcInputManager.getFacingDependantCommand(reversalNpcCommand, botKinbody2d.facingRight)
			#else:
			cmd = npcInputManager.getFacingDependantCommand(npcCommand, botKinbody2d.facingRight)
		
			
		
		if pushBlockOnBlockstunEnabled  and pushBlockThisFrameFlag:
			pushBlockThisFrameFlag=false
			cmd =  npcInputManager.getFacingDependantCommand(npcInputManager.Command.CMD_BACKWARD_PUSH_BLOCK, botKinbody2d.facingRight)
			
		
	else:
		
		if not agentRiposting:
			
			cmd = ghostAI.pollNextCommand()
			#cmd =  ghostAI.estimateNextCommand()
			cmd = npcInputManager.getFacingDependantCommand(cmd, botKinbody2d.facingRight)
		else:	
			cmd = npcCommand #next command is a ripost command
			agentRiposting = false
			
	npcInputManager.cmd = cmd
	
	#TODO: we have to parsed the directional enum here from the command since the bot isn't pressing buttons,
	#it's just emulating commands
	#npcInputManager.lastDI = npcInputManager.cmdToDI(cmd)
	
	#don't do anything else if were not in training mode
	if gameMode != GLOBALS.GameModeType.TRAINING:
		return
		
	#riposting?
	if riposting and ripostTriggerFlag:
		
		#ripost immediatly
		ripostTriggerFlag=false
			
		npcCommand = null
		
		
	#counter riposting?
	elif counterRiposting and counterRipostTriggerFlag:
		
		#just set counter ripost for 1 frame, otherwise have bot keep spamming the derised button
		counterRipostTriggerFlag=false
		var counterRipostCmd = npcInputManager.counterRipostCommandReverseMap[cmd]
		npcInputManager.cmd =counterRipostCmd
		#not implemented
	
	
	#check for change in ability bar, and when infinite supply, restock upon use
	var playerNumAbilityChunks = int(GLOBALS.getNumberOfChunks(playerController.playerState.abilityBar,playerController.playerState.abilityChunkSize))	
	if playerInfiniteBarFlag and playerNumAbilityChunks !=  getLineEditIntHepler(playerAbilityBarChunkLineEdit,0,24):
	#if playerInfiniteBarFlag and (playerController.playerState.abilityBar*playerController.playerState.abilityBar)  != getLineEditIntHepler(playerAbilityBarChunkLineEdit,0,24):
		#playerController.playerState.abilityBar = defaultPlayerAbilityBar
		playerController.playerState.setAbilityBarAmountInChunks(getLineEditIntHepler(playerAbilityBarChunkLineEdit,0,24))
		

	var botNumAbilityChunks = int(GLOBALS.getNumberOfChunks(botPlayerController.playerState.abilityBar,botPlayerController.playerState.abilityChunkSize))	
	if botInfiniteBarFlag and botNumAbilityChunks !=  getLineEditIntHepler(botAbilityBarChunkLineEdit,0,24):
	#if botInfiniteBarFlag and botPlayerController.playerState.abilityBar !=  getLineEditIntHepler(botAbilityBarChunkLineEdit,0,24):
		#botPlayerController.playerState.abilityBar = defaultBotAbilityBar
		botPlayerController.playerState.setAbilityBarAmountInChunks(getLineEditIntHepler(botAbilityBarChunkLineEdit,0,24))

	handleSpecialTrainingModeInputs()
	
func handleSpecialTrainingModeInputs():
	var playerInputDeviceId = playerController.inputManager.inputDeviceId
	
	#player wants to restart match via quick button?
	if Input.is_action_just_pressed(playerInputDeviceId+"_SELECT"):
		emit_signal("restart_game")
	else:
		
		#TAPPING right stick changes control of player to NPC and NPC  to player
		var toggleNPCControlFlag = false
		
		var desiredBehavior =null
		
		#THE C STICK direction lets u control the input control over npc
		if Input.is_action_just_pressed(playerInputDeviceId+"_C_STICK_RIGHT"):
			desiredBehavior=GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_MIRROR_PLAYER_COMMAND
		elif Input.is_action_just_pressed(playerInputDeviceId+"_C_STICK_LEFT"):
			desiredBehavior=GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_MIRROR_PLAYER_INPUT			
		elif Input.is_action_just_pressed(playerInputDeviceId+"_C_STICK_DOWN") or Input.is_action_just_pressed(playerInputDeviceId+"_C_STICK_UP"):
			desiredBehavior=GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_SPAM
			
		toggleNPCControlFlag = desiredBehavior != null
		
		#change the chracter player controls?
		if toggleNPCControlFlag:
			#CURREntly player controls npc?
			if npcInputManager.behavior == npcInputManager.Behavior.CONTROL_MAIN_CONTROLLER:
				#go back to spam and controller player's character
				__on_behavior_selected(desiredBehavior)
			else:# 
				__on_behavior_selected(GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_MAIN_CONTROLLER)
	
	
func enableBlocking():
	
	if  guardMode ==GuardMode.NOT_BLOCKING:
		disableBlocking()
		return
		
	
	botPlayerController.guardHandler.holdBackInputLocked=true
	if guardMode == GuardMode.BLOCKING_HIGH:
		botPlayerController.guardHandler.holdingBackward=true
		botPlayerController.guardHandler.holdingDown=false
	elif guardMode == GuardMode.BLOCKING_LOW:
		botPlayerController.guardHandler.holdingBackward=true
		botPlayerController.guardHandler.holdingDown=true
	elif guardMode == GuardMode.BLOCKING_ALL:
		botPlayerController.guardHandler.holdingBackward=true
		#botPlayerController.guardHandler.holdingDown=false#HOLDING down will be dealt with on hit

	
#	blockingEnabled = true
	if perfectBlocking:
		#make sure time held down hold back is 0
		botPlayerController.guardHandler.perfectBlockTimeHeldBackInSeconds=0
	else:
		#make sure time held down hold back is greater than perfect block window
		botPlayerController.guardHandler.perfectBlockTimeHeldBackInSeconds=(1+botPlayerController.guardHandler.PERFECT_BLOCK_TIME_WINDOW)*GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	
	
	
	
func disableBlocking():
	#blockingEnabled = false
	botPlayerController.guardHandler.holdBackInputLocked=false
	botPlayerController.guardHandler.holdingBackward=false
	botPlayerController.guardHandler.holdingDown=false
	#checkForTech()
#called when player pressed enter to change number of hits for ripost delay
func _on_num_hits_ripost_delay_entered(text):
	
	if text.is_valid_integer():
		
		var value = int(text)
		
		if value < 1 :
			value = 0
			numHitsRipostDelayLineEdit.text = "0"
		ripostHitDelay = value
	else:
		#default value, not integer entered by user
		numHitsRipostDelayLineEdit.text = str(ripostHitDelay)
	
	currNumHitsRipostTracking = 0 #reset tracking of ripost hit delay
	
func _on_guard_type_selected(ix):
	var gaurdString = guardSelectBtn.get_item_text(ix)
	
	if gaurdString == GLOBALS.TRAINING_MODE_GUARD_NO_BLOCK:
		guardMode = GuardMode.NOT_BLOCKING
	elif gaurdString == GLOBALS.TRAINING_MODE_GUARD_BLOCK_HIGH:
		guardMode = GuardMode.BLOCKING_HIGH
	elif gaurdString == GLOBALS.TRAINING_MODE_GUARD_BLOCK_LOW:
		guardMode = GuardMode.BLOCKING_LOW
	elif gaurdString == GLOBALS.TRAINING_MODE_GUARD_BLOCK_EVERYTHING:
		guardMode = GuardMode.BLOCKING_ALL
	
	
	#not guarding?
	if guardMode == GuardMode.NOT_BLOCKING:
		blockingEnabled=false
		#hide the ui elements linked to block
		for node in guardUIElements:
			node.visible = false
	else:
		blockingEnabled=true
	
		#show the ui elements linked to block
		for node in guardUIElements:
			node.visible = true


func _on_guard_behavior_selected(ix):
	var gaurdString = guardBehaviorSelectBtn.get_item_text(ix)
	
	if gaurdString == GLOBALS.TRAINING_MODE_GUARD_BEHAVIOR_NOW:
		immediatlyBlocking =true
		isRandomBlocking=false
		blockingAfterFirstHit=false
	elif gaurdString == GLOBALS.TRAINING_MODE_GUARD_BEHAVIOR_RANDOM:
		immediatlyBlocking =false
		isRandomBlocking=true
		blockingAfterFirstHit =false
	elif gaurdString == GLOBALS.TRAINING_MODE_GUARD_BEHAVIOR_AFTER_FIRST_HIT:
		immediatlyBlocking =false
		blockingAfterFirstHit=true
		isRandomBlocking=false
		


	

	
func _on_behavior_selected(ix):
	var behaviorString = behaviorSelectBtn.get_item_text(ix)
	__on_behavior_selected(behaviorString)
	
func __on_behavior_selected(behaviorString):	


	if behaviorString == GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_SPAM:
		npcInputManager.behavior = npcInputManager.Behavior.SPAM
		playerController.enableUserInput()
	elif behaviorString == GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_2ND_CONTROLLER:
		npcInputManager.behavior = npcInputManager.Behavior.CONTROL_2ND_CONTROLLER
		playerController.enableUserInput()
	elif behaviorString == GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_MAIN_CONTROLLER:
		npcInputManager.behavior = npcInputManager.Behavior.CONTROL_MAIN_CONTROLLER
		playerController.disableUserInput()
	elif behaviorString == GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_MIRROR_PLAYER_COMMAND:
		npcInputManager.behavior = npcInputManager.Behavior.MIRROR_COMMAND
		playerController.enableUserInput()
	elif behaviorString == GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_MIRROR_PLAYER_INPUT:
		npcInputManager.behavior = npcInputManager.Behavior.MIRROR_INPUT
		playerController.enableUserInput()
	if behaviorString == GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_CPU:
		enableGhostAI()
		#playerController.enableUserInput()
	else:
		disableGhostAI()
		
func enableGhostAI():
	npcInputManager.behavior = npcInputManager.Behavior.SPAM
	ghostAIAgentActive = true
	ghostAI.enable()
	
func disableGhostAI():
	ghostAIAgentActive = false
	ghostAI.disable()
	
func _on_game_speed_selected(ix):
	var spdString = speedSelectBtn.get_item_text(ix)
	
	if spdString == "Normal":
		get_tree().call_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP,GLOBALS.GLOBAL_SPEED_MOD_SETTER_FUNC,1)
	elif spdString == "Slow":
		get_tree().call_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP,GLOBALS.GLOBAL_SPEED_MOD_SETTER_FUNC,0.5)
	elif spdString == "Very Slow":
		get_tree().call_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP,GLOBALS.GLOBAL_SPEED_MOD_SETTER_FUNC,0.25)
	elif spdString == "Fast":
		get_tree().call_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP,GLOBALS.GLOBAL_SPEED_MOD_SETTER_FUNC,1.25)
	elif spdString == "Very Fast":
		get_tree().call_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP,GLOBALS.GLOBAL_SPEED_MOD_SETTER_FUNC,1.75)
#called when in pause haude, player selects bot command
func _on_command_selected(ix):
	var cmdString = commandSelectBtn.get_item_text(ix)
	
	var cmdEnum = stage.pauseHUD.cmdUserFriendlyNameMap[cmdString]
	npcCommand=cmdEnum
	
	
	#var cmdString = commandSelectBtn.get_item_text(ix)
	#if cmdString == "Stand":
	#	npcCommand = null
	#	return
	
	#var cmd = npcInputManager.cmdStringToEnumMap[cmdString]
	
	#npcCommand=cmd
	
func _on_landed():
	
	
	if  techBehaviorString != NO_TECH_STR and botPlayerController.playerState.inHitStun:
		
		botPlayerController.attemptTech()
		setBotTechDI(techBehaviorString)

		
		
	
func _on_wall_collision(collider):
#	if techingFlag and botPlayerController.playerState.inHitStun:
	if  techBehaviorString != NO_TECH_STR and botPlayerController.playerState.inHitStun:
		
		setBotTechDI(techBehaviorString)		
		botPlayerController.attemptTech()
		
		#botPlayerController.techHandler._on_wall_collision(collider)
		#botPlayerController._on_successful_tech(0,GLOBALS.TYPE_WALL_TECH_IN_PLACE)
func _on_ceiling_collision(collider):
	#if techingFlag and botPlayerController.playerState.inHitStun:
	if  techBehaviorString != NO_TECH_STR and botPlayerController.playerState.inHitStun:
		setBotTechDI(techBehaviorString)
		botPlayerController.attemptTech()
		
		
		#botPlayerController.techHandler._on_ceiling_collision(collider)
		#botPlayerController._on_successful_tech(0,GLOBALS.TYPE_CEILING_TECH_IN_PLACE)


func setBotTechDI(techBehaviorString):
		if techBehaviorString == RIGHT_TECH_STR:
			#var rightFlag = true
			#botPlayerController.techHandler.attemptHorizontalTech(rightFlag)
			#var rightCmd = npcInputManager.Command.CMD_MOVE_FORWARD
			#botPlayerController.techHandler.setTechDI(rightCmd)	
			if botPlayerController.kinbody.facingRight:
				botPlayerController.techHandler.dirInput=GLOBALS.DirectionalInput.FORWARD
			else:
				botPlayerController.techHandler.dirInput=GLOBALS.DirectionalInput.BACKWARD
		elif techBehaviorString == LEFT_TECH_STR:
			#var rightFlag = false
			#botPlayerController.techHandler.attemptHorizontalTech(rightFlag)
			#var leftCmd = npcInputManager.Command.CMD_MOVE_BACKWARD
			#botPlayerController.techHandler.setTechDI(leftCmd)	
			if botPlayerController.kinbody.facingRight:
				botPlayerController.techHandler.dirInput=GLOBALS.DirectionalInput.BACKWARD
			else:
				botPlayerController.techHandler.dirInput=GLOBALS.DirectionalInput.FORWARD
		elif techBehaviorString == DOWN_TECH_STR:			
			botPlayerController.techHandler.dirInput=GLOBALS.DirectionalInput.DOWN
		elif techBehaviorString == UP_TECH_STR:			
			botPlayerController.techHandler.dirInput=GLOBALS.DirectionalInput.UP
		elif techBehaviorString == NEUTRAL_TECH_STR:
			botPlayerController.techHandler.dirInput=GLOBALS.DirectionalInput.NEUTRAL
		


#func checkForTech():
#	var techWindowLengthSec = null
#	var hitStunSecRemaining = null
#	if botPlayerController.playerState.inHitStun and techingFlag:
#		techWindowLengthSec = botPlayerController.techHandler.techWindowLockLengthInSeconds
		
		
#		var actionAnimeManager = botPlayerController.actionAnimeManager
		
#		hitStunSecRemaining = actionAnimeManager.getHitstunSecondsRemaining()
		#can now safely tech without expiring the window before hitstun end?
#		if techWindowLengthSec > hitStunSecRemaining - 1.0/60.0:
#			botPlayerController.attemptTech()
func _on_save_demo_data_btn_pressed():
	ghostAI.situationHandler.saveGhostDBFile()
	
func _on_load_demo_data_btn_pressed():
	ghostAI.situationHandler.loadAIDBIntoMemory()
	
	
func _on_agent_attempt_ripost(cmdToRipost):
	
	if cmdToRipost == null:
		return
	
	var cmd =npcInputManager.getFacingDependantCommand(cmdToRipost,botPlayerController.kinbody.facingRight)
	if npcInputManager.ripostCommandReverseMap.has(cmd):
		agentRiposting=true	
		var ripostCmd = npcInputManager.ripostCommandReverseMap[cmd]	
		npcCommand = ripostCmd
		
		
func _on_userInputEnabledChange(enabled):
	
	if not enabled:
		ghostAI.agentWorker._on_pause()
	else:
		ghostAI.agentWorker._on_unpause()
		
	
#func _on_proximity_guard_enabled_changed(_proxGuardEnabled):
	
	#proxGuardEnabled=_proxGuardEnabled
	
	
#generate an event (true or false ) with given probabliity
#pvalue: probablity of evnet [0,1]
#ture returns when event occurs
#false returned when it doesn't
func generateProbabilistichEvent(pvalue):

	var eventOccured = false


	#generate number between 0 -1 
	var r = rng.randf()
	
	#event occured? note that pobability 0 will never happen
	if r < pvalue:
		eventOccured = true
			
	return eventOccured
	
func _on_random_block_ended():
	randomlyBlockingEnabled = false
	
	
func _on_game_end_save_ghost_ai_db():
	ghostAI.situationHandler.saveGhostDBFile()
	
func _on_entered_block_hitstun(attackerHitbox,blockResult, spriteCurrentlyFacingRight):
	pushBlockThisFrameFlag=true
func _on_exited_block_stun():
	pass
	
	
func _on_bot_action_animation_finished(spriteAnimationId):
	
	
	var reversalEnabled = false
	if reversalNpcCommand != null:
		#animation finished that bot will reversal out of?
		if botPlayerController.actionAnimeManager.isReversableSpriteAnimationId(spriteAnimationId):
			#manually place command in input buffer and call the process user input of controller
			#inputs in buffer shifted by 1(oldest input lost if buffer full)
			
			#clear the buffer and make sure the reversal command gets processed
			#npcInputManager.cmdBuffer.clear()
			var _cmd = npcInputManager.getFacingDependantCommand(reversalNpcCommand, botKinbody2d.facingRight)
			npcInputManager.cmd = _cmd
			#npcInputManager.lastCommand = _cmd
			#npcInputManager.storeCommandInBuffer(_cmd)
			
			#npcInputManager.lastCommand=reversalNpcCommand			
			#npcInputManager.lastCommand = npcInputManager.getFacingDependantCommand(reversalNpcCommand, botKinbody2d.facingRight)
			reversalEnabled=true
			#botPlayerController.handleUserInput()
			#botPlayerController.skipHandleInputThisFrame=true #make sure this early reverasal input is only input processed this frame
			pass
			
	if gameMode == GLOBALS.GameModeType.TRAINING:
		botPlayerController._on_action_animation_finished(spriteAnimationId)
		#recordingHandler will handle this
		#if reversalEnabled :
		#	_force_training_bot_reversal_cmd()
			

func _force_training_bot_reversal_cmd():
	npcInputManager.cmdBuffer.clear()
	var _cmd = npcInputManager.getFacingDependantCommand(reversalNpcCommand, botKinbody2d.facingRight)
	npcInputManager.cmd = _cmd
	npcInputManager.lastCommand = _cmd
	botPlayerController.skipHandleInputThisFrame=true #make sure this early reverasal input is only input processed this frame
	botPlayerController.handleUserInput()
#to be implemented as hook by subclass
func _on_hit_freeze_finished():
	#delay the enabling of blocking for when the hit freeze stopped
	if blockingAfterFirstHitTriggeredHelper:
		blockingAfterFirstHitTriggeredHelper=false
		blockingAfterFirstHitTriggered=true
	
	
	#.connect("
	#wait a frame to cancel the auto ability cancel on active
	#yield(playerController.actionAnimeManager.spriteAnimationManager,"sprite_frame_activated")
	#yield(get_tree(),"physics_frame")
	#check for clear the flag to automatically frame perfect abilty after hit was processed
	#if playerAutoFramePerfectAbilityCancelOnHitOnly:
		#playerController.autoActiveFramesAbilityCancelFlag=false
		
	#check for clear the flag to automatically frame perfect abilty after hit was processed
	#if cpuAutoFramePerfectAbilityCancelOnHitOnly:
		#botPlayerController.autoActiveFramesAbilityCancelFlag=false

	
#to be implemented as hook by subclass
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	emit_signal("hit_freeze_started")
	pass

#called when player select command to perform as reversal
func _on_bot_reversal_command_selected(ix):
	
	var cmdString = reversalCommandSelectBtn.get_item_text(ix)
	
	var cmdEnum = stage.pauseHUD.cmdUserFriendlyNameMap[cmdString]
	reversalNpcCommand=cmdEnum
	
	#var cmdString = reversalCommandSelectBtn.get_item_text(ix)
	
	#if cmdString == "None":
	#	reversalNpcCommand = null
	#	return
	
	#var cmd = npcInputManager.cmdStringToEnumMap[cmdString]
	
	#reversalNpcCommand=cmd	
	
	

	
	
	
func _on_bot_ripost_command_selected(ix):
	
	
	var cmdString = ripostCommandSelectBtn.get_item_text(ix)
	var cmd = stage.pauseHUD.cmdUserFriendlyNameMap[cmdString]
	ripostBotCommand=cmd	
	#var cmdString = ripostCommandSelectBtn.get_item_text(ix)
	
	#if cmdString == "None":
	#	ripostBotCommand = null
	#	return
	
	#var cmd = npcInputManager.cmdStringToEnumMap[cmdString]
	
	#ripostBotCommand=cmd	
	
	#pass