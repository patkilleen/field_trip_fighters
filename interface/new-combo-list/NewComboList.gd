extends Control

signal toggle_resource_cost_visibility
const GLOBALS = preload("res://Globals.gd")
const InputManagerResource = preload("res://input_manager.gd")
const AnimationEntryResource = preload("res://interface/new-combo-list/animationEntry.gd")

# Called when the node enters the scene tree for the first time.


var inputDevices = []

const OKI_KNOCKDOWN_DURATION=58

const HIT_ADVANTAGE=0
const LINK_HIT_ADVANTAGE=1
const GOOD_BLOCK_ADVANTAGE=2
const BAD_BLOCK_ADVANTAGE=3
const SCROLL_EDGE_BOUNDARY_IX_OFFSET = 4
enum DetailsView{
	DESCRIPTION,
	COMBO_CANCELS
}

const UI_MOVE_CURSOR_SOUND_ID = 0
const DEBUG_ENTRY_NAMES = false

#const NUMBER_OF_GROUND_ATTACKS_PER_TYPE = 5 # neutral, up, down, right, forward
const SPECIAL_CASE_GRAB=0

const NIY_STR = "NIY"
const AIR_STR = "Air"
const KNOCKDOWN_STR = "Knockdown"
const LOW_STR = "Low"
const GRAB_STR = "Grab"
const STALE_STR ="Stale-moves"
const PARRY_STR = "Parry"
const INVINCIBILITY_STR = "Invincibility"
const ANTI_AIR_ONLY_STR = "Anti-air"
const ANTI_GROUND_ONLY_STR = "Anti-ground"
const OTG_STR ="OTG"
			
const ARMOR_STR ="Armor"
const  ON_HIT_MEATY_STR = "Hitstun-Meaty"
const ON_BLOCK_MEATY_STR ="Block-Meaty"
			
const SCROLL_FAST_ENTRIES_SKIPPED = 6 #skip 6 entries when using triggers
export (Color) var unselectedMoveColor = Color(0,0,0)
export (Color) var selectedMoveColor = Color(0,0,0)

var scrollContainerCursor = -1
var scrollContainer = null
var scrollContainerRows= null
var scrollV_max = 0

var currMoveSelected = null

var descriptionNodes = []
var comboCancelsNodes = []
var projectileMap = {}


var sfxPlayer = null


var detailsViewState = DetailsView.DESCRIPTION

const COMBO_CANCEL_BASIC_STATIC_STRING = "Basic"
const COMBO_CANCEL_ON_HIT_STATIC_STRING = "On-hit -  cancels"
const COMBO_CANCEL_AUTO_ABILITY_STATIC_STRING = "On-hit - auto ability cancels"
const COMBO_CANCEL_LANDING_LAG_STATIC_STRING = "Landing lag cancels"
const COMBO_CANCEL_ONHIT_LANDING_LAG_STATIC_STRING = "On-hit - landing lag cancels"

var airComboCancelEntryTemplate = null
var comboCancelEntryTemplate = null
var comboCancelStaticLabelTemplate = null

var comboCancelRows = null

var cmdTextureMap = null

var staticAirLabelTip = null

#var descriptionViewNameNode = null
#var descriptionViewTypeNode = null
var descriptionViewPropertiesNode = null
var descriptionViewAbilityCancelCostNode = null
var descriptionViewStartupFramesNode=null
var descriptionViewActiveFramesNode = null
var descriptionViewActiveFramesHeader = null
var descriptionViewRecoveryFramesNode= null
var descriptionViewRecoveryFramesHeader= null
var descriptionViewHitAdvFramesNode=null
var descriptionViewLinkHitAdvFramesNode=null

var descriptionViewGoodBlockAdvFramesNode=null
var descriptionViewBadBlockAdvFramesNode=null

var descriptionViewHitAdvFramesHeaderNode = null
var descriptionViewLinkHitAdvFramesHeaderNode=null
var descriptionViewGoodBlockAdvFramesHeader=null
var descriptionViewBadBlockAdvFramesHeader=null

var descriptionViewLinkFrameAvgContainer =null
var descriptionViewDescriptionNode = null

var actionAnimeManager = null
#var inputManager = null
var inputManagerDeviceId = null
var populatedComboCancels = false

var moveEntryElements = []

var comboCancelStaticStringCancelTypeMap = {}
var autoCancelBlackListMaskMap = {}
var comboCancelActionIdBlackListMap={}
var active = false

var playerController = null

var playerInfoLabel=null

const ABILITY_BASED_TYPE_STR = "Ability-based"
const COOLDOWN_TYPE_STR = "Cooldown-based"
const COMBO_TYPE_STR = "Combo"
const MOVEMENT_TYPE_STR = "Movement"
#name, type, description
const UNI_MOVE_NAME_IX = 0
const UNI_MOVE_TYPE_IX = 1
const UNI_MOVE_DESCRIPTION_IX = 2
var universalMoveMap=[{},{},{}]


var toggleDetailsViewCirclePair=null
		
#GLOBALS
#const MELEE_IX = 0
#const SPECIAL_IX = 1
#const TOOL_IX = 2
const JUMP_IX = 3
const AIR_JUMP_IX=4
const NON_DASHCANCEL_JUMP_IX=5
const GROUND_DASH_IX=6
const AIR_DASH_IX=7
const NON_CROUCHCANCEL_GROUND_DASH_IX = 8
var attackTypeActionIdSets = [[],[],[],[],[],[],[],[],[]]

const allAttackTypeAirFlag = [false,false,false,false,true,false,false,true,false]
const cmdTypeList = [InputManagerResource.Command.CMD_NEUTRAL_MELEE,InputManagerResource.Command.CMD_NEUTRAL_SPECIAL,InputManagerResource.Command.CMD_NEUTRAL_TOOL,InputManagerResource.Command.CMD_JUMP,InputManagerResource.Command.CMD_JUMP,InputManagerResource.Command.CMD_JUMP,InputManagerResource.Command.CMD_DASH_FORWARD,InputManagerResource.Command.CMD_DASH_FORWARD,InputManagerResource.Command.CMD_DASH_FORWARD]
const allAttackTypeNameList = ["All ground Melee attacks","All ground Special attacks","All ground Tool attacks", "All jump directions","All air jump directions","All jump directions", "Forward & back ground dash","Forward & back air dash","Forward & back ground dash"]
func _ready():
	
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.AUTO_RIPOST]="Auto-riposte"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.AUTO_RIPOST]=ABILITY_BASED_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.AUTO_RIPOST]="Invincible (vulnerable to grab) alpha counter reversal. When hit by an attack during this animation, a short-medium range parry is performed. \n\nThere is a brief moment of vulnerability at the end of the animation, if the opponent didn't hit you, where you can be hit."

	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.RIPOST]="Riposte"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.RIPOST]=ABILITY_BASED_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.RIPOST]="Ever know exactly what combo your opponent will do? A large window of time is created when you start riposting. If you are hit during that time and inputed R1 + the opponent's command, you steal the combo. Riposteing can be done in almost any situation (including during hitstun). Riposteing prevents input for the duration. \nFailing a riposte: when in neutral, you become stunned momentarily; in hitstun, you reset the opponent's damage proration and you are locked of ability bar gain temporarily. You can't win the game from a riposte."
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.COUNTER_RIPOST]="Counter-riposte"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.COUNTER_RIPOST]=ABILITY_BASED_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.COUNTER_RIPOST]="Can you read your opponent like a book? Counter riposte to perform a seemingly normal attack , but if your attack is riposted, you win the interaction and steal the game flow by gaining a free combo. \n\nIf the attack expires and you didn't get riposted, you get stunned for a brief moment."
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.ABILITY_CANCEL]="Ability Cancel"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.ABILITY_CANCEL]=ABILITY_BASED_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.ABILITY_CANCEL]="Empty cancel almost any animation by ability canceling. The ability bar cost for ability canceling varies by moves, which can seen in-game as the green (has enough bar) and red (insufficient bar) indicators in the Ability Bar UI. Ability canceling also maintains your momentum, so you can slide on the ground or glide in the air for a moment. Ability canceling also slightly resets hitstun and damage proration, making ability cancels later in combos have more value. Ability canceling also resets some character-specific stale moves (using the move more than once per combo). You can't win the game from a counter riposte nor win from a stray hitbox while counter-riposting"
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.PUSH_BLOCK]="Push Block"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.PUSH_BLOCK]=ABILITY_BASED_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.PUSH_BLOCK]="While blocking (in block stun), push blocking will push your opponent away, preventing them from input buttons for a very brief moment, allowing you to reduce your opponent's aggression and gain some breathing room. Block stun's full duration can be avoided by ability canceling the push block animation (although this may be ability costly)"
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.TECH]="Tech"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.TECH]=ABILITY_BASED_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.TECH]="You can break from from hitstun by tech'ing off a wall, floor, or ceiling. When you tech, the direction you are holding will be the direction you quickly move towards. During most of the tech animation you are invincible. \nFor a brief moment at the end of the animation you can be hit."
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.GRAB]="Grab"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.GRAB]=COOLDOWN_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.GRAB]="Non damaging grab that can grab a blocking or auto-riposting opponent, but cannot grab an opponent in startup or active frames. When the grab connects, any of the 8 directional inputs can be pressed to move the opponent in the desired direction. Grabbing an opponent in neutral grants plus frames, while grabbing an opponent already in hitstun reduces their hitstun by 1 frame (grabbing + long duration hitstun is recommended over grabbing an opponent in short hitstun)"
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.MAGIC_SERIES]="Magic Series"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.MAGIC_SERIES]=COMBO_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.MAGIC_SERIES]="Hitting an opponent consecutively with any Melee + Special + Tool is a Magic Series combo. When a combo ends, ability bar will be gained for every Magic Series combo performed during the full combo. \nA riposte can interrupt a combo and deny the Magic Series bar gain."
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.CROUCH]="Crouch"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.CROUCH]=MOVEMENT_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.CROUCH]="Crouching brings you lower to the ground, allowing the evasion of some high-reaching anti-airs, however only down-input attacks can be done out of crouch. Any other animation will force a brief moment of uncrouching."
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.JUMP]="Jump"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.JUMP]=MOVEMENT_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.JUMP]="Jump back, straight up, or forward. Jumping leaves you in place for a brief moment from a jump squat. During this jump squat a few movement options can be done to cancel the jump before the upward momentum begins."
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.GROUND_DASH_FORWARD]="Ground Dash Forward"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.GROUND_DASH_FORWARD]=MOVEMENT_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.GROUND_DASH_FORWARD]="Quickly dash forward to close distance between you and your opponent. Dashing right next to opponent supports cross-ups by dashing through them to end up behind them. \n\nWhen dashing in neutral (not a dash from an on-hit cancel), it can be canceled into crouch cancel to enable micro-spacing control by interrupting your dash with a quick slide."
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.GROUND_DASH_BACK]="Ground Dash Forward"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.GROUND_DASH_BACK]=MOVEMENT_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.GROUND_DASH_BACK]="Quickly dash backward to create distance between you and your opponent. \n\nWhen dashing in neutral (not a dash from an on-hit cancel), it can be canceled into crouch cancel to enable micro-spacing control by interrupting your dash with a quick slide."
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.CROUCH_CANCEL]="Crouch-cancel"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.CROUCH_CANCEL]=MOVEMENT_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.CROUCH_CANCEL]="A very brief animation to cancel ground dashes in neutral (not from on-hit cancels). You sacrifice dash distance and jump canceling to attack more quickly out of dash and have finer control over your momentum as your slide briefly. \n\n In rare cases some moves (character-specific) can be canceled into Crouch-cancel."
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.AIR_DASH_FORWARD]="Air Dash Forward"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.AIR_DASH_FORWARD]=MOVEMENT_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.AIR_DASH_FORWARD]="While airborne, quickly dash forward to close distance between you and your opponent. Dashing right next to opponent supports cross-ups by dashing through them to end up behind them. \n\n Some animations will keep the air dash momentum briefly when canceling into them from air dash."
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.AIR_DASH_BACK]="Air Dash Back"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.AIR_DASH_BACK]=MOVEMENT_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.AIR_DASH_BACK]="While airborne, quickly dash backward to create distance between you and your opponent. \n\n Some animations will keep the air dash momentum briefly when canceling into them from air dash."
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.FAST_FALL]="Fast Fall"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.FAST_FALL]=MOVEMENT_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.FAST_FALL]="A special type of downward dash. \n\nStop your current air momentum and quickly fall without interrupting your current animation. Fast falling enables air-to-ground combos by hitting in the air, fast falling, and then following up on the ground after landing lag ends."
	
	universalMoveMap[UNI_MOVE_NAME_IX][AnimationEntryResource.UniversalMove.LANDING_LAG]="Landing Lag"
	universalMoveMap[UNI_MOVE_TYPE_IX][AnimationEntryResource.UniversalMove.LANDING_LAG]=MOVEMENT_TYPE_STR
	universalMoveMap[UNI_MOVE_DESCRIPTION_IX][AnimationEntryResource.UniversalMove.LANDING_LAG]="Most air animations will be interrupted by landing lag when you land on the ground mid-animation.  Some air animations suport unique landing lag auto cancels. \n\nTrip guard is not supported, meaning you are vulnerable and cannot block during this animation. This means opponents that frequently jump and block can be punished by using a well-timed attack the moment they land. Landing while blocking doesn't trigger landing lag, but does extend the block stun duration (duration varies between attacks)"
	
	
	
	
	
	pass
func init(_inputManagerDeviceId,_playerController,heroName):
	
	playerController =_playerController
	actionAnimeManager = playerController.actionAnimeManager
	#inputManager = _inputManager
	inputManagerDeviceId = _inputManagerDeviceId
	
	sfxPlayer = $sfxPlayer
	
	#POPULATE THE LISTS OF ATTACK TYPE SETS WITH ACTION IDS OF THOSSE TYPES
	#attackTypeActionIdSets[GLOBALS.MELEE_IX].append(actionAnimeManager.AIR_NEUTRAL_MELEE_ACTION_ID)
	attackTypeActionIdSets[GLOBALS.MELEE_IX].append(actionAnimeManager.NEUTRAL_MELEE_ACTION_ID)
	attackTypeActionIdSets[GLOBALS.MELEE_IX].append(actionAnimeManager.FORWARD_MELEE_ACTION_ID)
	attackTypeActionIdSets[GLOBALS.MELEE_IX].append(actionAnimeManager.BACKWARD_MELEE_ACTION_ID)
	attackTypeActionIdSets[GLOBALS.MELEE_IX].append(actionAnimeManager.DOWNWARD_MELEE_ACTION_ID)
	attackTypeActionIdSets[GLOBALS.MELEE_IX].append(actionAnimeManager.UPWARD_MELEE_ACTION_ID)
	
	#attackTypeActionIdSets[GLOBALS.SPECIAL_IX].append(actionAnimeManager.AIR_NEUTRAL_SPECIAL_ACTION_ID)
	attackTypeActionIdSets[GLOBALS.SPECIAL_IX].append(actionAnimeManager.NEUTRAL_SPECIAL_ACTION_ID)
	attackTypeActionIdSets[GLOBALS.SPECIAL_IX].append(actionAnimeManager.FORWARD_SPECIAL_ACTION_ID)
	attackTypeActionIdSets[GLOBALS.SPECIAL_IX].append(actionAnimeManager.BACKWARD_SPECIAL_ACTION_ID)
	attackTypeActionIdSets[GLOBALS.SPECIAL_IX].append(actionAnimeManager.DOWNWARD_SPECIAL_ACTION_ID)
	attackTypeActionIdSets[GLOBALS.SPECIAL_IX].append(actionAnimeManager.UPWARD_SPECIAL_ACTION_ID)
	
	#attackTypeActionIdSets[GLOBALS.TOOL_IX].append(actionAnimeManager.AIR_NEUTRAL_TOOL_ACTION_ID)
	attackTypeActionIdSets[GLOBALS.TOOL_IX].append(actionAnimeManager.NEUTRAL_TOOL_ACTION_ID)
	attackTypeActionIdSets[GLOBALS.TOOL_IX].append(actionAnimeManager.FORWARD_TOOL_ACTION_ID)
	attackTypeActionIdSets[GLOBALS.TOOL_IX].append(actionAnimeManager.BACKWARD_TOOL_ACTION_ID)
	attackTypeActionIdSets[GLOBALS.TOOL_IX].append(actionAnimeManager.DOWNWARD_TOOL_ACTION_ID)
	attackTypeActionIdSets[GLOBALS.TOOL_IX].append(actionAnimeManager.UPWARD_TOOL_ACTION_ID)
	
	attackTypeActionIdSets[JUMP_IX].append(actionAnimeManager.JUMP_ACTION_ID)
	attackTypeActionIdSets[JUMP_IX].append(actionAnimeManager.JUMP_FORWARD_ACTION_ID)
	attackTypeActionIdSets[JUMP_IX].append(actionAnimeManager.JUMP_BACKWARD_ACTION_ID)
	
	attackTypeActionIdSets[AIR_JUMP_IX].append(actionAnimeManager.AIR_JUMP_ACTION_ID)
	attackTypeActionIdSets[AIR_JUMP_IX].append(actionAnimeManager.AIR_JUMP_FORWARD_ACTION_ID)
	attackTypeActionIdSets[AIR_JUMP_IX].append(actionAnimeManager.AIR_JUMP_BACKWARD_ACTION_ID)
	
	attackTypeActionIdSets[NON_DASHCANCEL_JUMP_IX].append(actionAnimeManager.NON_GND_DASH_CANCELABLE_JUMP_ACTION_ID)
	attackTypeActionIdSets[NON_DASHCANCEL_JUMP_IX].append(actionAnimeManager.NON_GND_DASH_CANCELABLE_F_JUMP_ACTION_ID)
	attackTypeActionIdSets[NON_DASHCANCEL_JUMP_IX].append(actionAnimeManager.NON_GND_DASH_CANCELABLE_B_JUMP_ACTION_ID)
	
	
	
	attackTypeActionIdSets[GROUND_DASH_IX].append(actionAnimeManager.GROUND_FORWARD_DASH_ACTION_ID)
	attackTypeActionIdSets[GROUND_DASH_IX].append(actionAnimeManager.GROUND_BACKWARD_DASH_ACTION_ID)
	
	
	attackTypeActionIdSets[AIR_DASH_IX].append(actionAnimeManager.AIR_DASH_FORWARD_ACTION_ID)
	attackTypeActionIdSets[AIR_DASH_IX].append(actionAnimeManager.AIR_DASH_BACKWARD_ACTION_ID)
	
	
	attackTypeActionIdSets[NON_CROUCHCANCEL_GROUND_DASH_IX].append(actionAnimeManager.NON_CROUCH_CANCELABLED_F_GROUND_DASH_ACTION_ID)
	attackTypeActionIdSets[NON_CROUCHCANCEL_GROUND_DASH_IX].append(actionAnimeManager.NON_CROUCH_CANCELABLED_B_GROUND_DASH_ACTION_ID)
	
	playerInfoLabel = $"Header/playerLabel"
	
	#PLAYER 1?
	if playerController.inputManager.inputDeviceId == GLOBALS.PLAYER1_INPUT_DEVICE_ID:
		playerInfoLabel.text = "Player 1 - "+playerController.heroName
	else:
		playerInfoLabel.text = "Player 2 - "+playerController.heroName
	
	var movesetListScenePath =null
	match(heroName):
		GLOBALS.WHISTLE_HERO_NAME:
			movesetListScenePath = "res://interface/new-combo-list/whistleComboList.tscn"
		GLOBALS.MICROPHONE_HERO_NAME:
			
			movesetListScenePath = "res://interface/new-combo-list/microphoneComboList.tscn"
		GLOBALS.BELT_HERO_NAME:
			
			movesetListScenePath = "res://interface/new-combo-list/beltComboList.tscn"
		GLOBALS.GLOVE_HERO_NAME:
			
			movesetListScenePath = "res://interface/new-combo-list/gloveComboList.tscn"
		GLOBALS.HAT_HERO_NAME:
			
			movesetListScenePath = "res://interface/new-combo-list/hatComboList.tscn"		
			
			
	toggleDetailsViewCirclePair = $"Header/details-icons"
	
	#dynamically loads the appropriate moveset list scene and adds to the scene tree
	var movesetListSceneResource = load(movesetListScenePath)
	var mosetListInstance  = movesetListSceneResource.instance()	
	scrollContainer =$"Middle/ScrollContainer"
	scrollContainer.add_child(mosetListInstance)
	scrollContainer.move_child(mosetListInstance,0)
	
	scrollContainerRows = $"Middle/ScrollContainer/rows"
	
	
	staticAirLabelTip =$"Middle/detailsContainer/combosContainer/airTip"
	
	

	#descriptionViewNameNode = $"Middle/detailsContainer/descriptionContainer/moveName/dynamicLabel"
	#descriptionViewTypeNode = $"Middle/detailsContainer/descriptionContainer/moveType/dynamicLabel"
	descriptionViewPropertiesNode=$"Middle/detailsContainer/descriptionContainer/properties/dynamicLabel"
	descriptionViewAbilityCancelCostNode =$"Middle/detailsContainer/descriptionContainer/cancelCostContainer/dynamicLabel"
	descriptionViewStartupFramesNode =$"Middle/detailsContainer/descriptionContainer/frameDataRowValues/startup"
	descriptionViewActiveFramesNode =$"Middle/detailsContainer/descriptionContainer/frameDataRowValues/active"	
	descriptionViewActiveFramesHeader =$"Middle/detailsContainer/descriptionContainer/frameDataRowHeader/active"
	descriptionViewRecoveryFramesNode =$"Middle/detailsContainer/descriptionContainer/frameDataRowValues/recovery"
	descriptionViewRecoveryFramesHeader = $"Middle/detailsContainer/descriptionContainer/frameDataRowHeader/recovery"
	
	
	descriptionViewHitAdvFramesHeaderNode=$"Middle/detailsContainer/descriptionContainer/hitFrameDataRowHeader/hitAdv"
	descriptionViewLinkHitAdvFramesHeaderNode=$"Middle/detailsContainer/descriptionContainer/hitFrameDataRowHeader/linkHitAdv"
	descriptionViewGoodBlockAdvFramesHeader=$"Middle/detailsContainer/descriptionContainer/blockFrameDataRowHeader/goodBlockHitAdv"
	descriptionViewBadBlockAdvFramesHeader=$"Middle/detailsContainer/descriptionContainer/blockFrameDataRowHeader/badBlockAdv"

	
	descriptionViewHitAdvFramesNode=$"Middle/detailsContainer/descriptionContainer/hitFrameDataRowValues/hitAdv"
	descriptionViewLinkHitAdvFramesNode=$"Middle/detailsContainer/descriptionContainer/hitFrameDataRowValues/linkHitAdv"
	
	descriptionViewGoodBlockAdvFramesNode=$"Middle/detailsContainer/descriptionContainer/blockFrameData2RowValues/goodBlockHitAdv"
	descriptionViewBadBlockAdvFramesNode=$"Middle/detailsContainer/descriptionContainer/blockFrameData2RowValues/badBlockAdv"
	
	
	
	descriptionViewDescriptionNode= $"Middle/detailsContainer/descriptionContainer/desciprtionContainer/descriptionScrollContainer/descriptionDynamicLabel"
	
	
	#load the hero info
	loadHeroInformation()	

	
	if DEBUG_ENTRY_NAMES:
		#make sure all the entries have name reflected by action manager,
		for c in scrollContainerRows.get_children():
			if c is  preload("res://interface/new-combo-list/animationEntry.gd"):
				
				var actionId = c.actionId
				var actionName = actionAnimeManager.getActionName(actionId)
				
				#non-empty?
				if actionName != "":
					c.setName(actionName)
		
		
		#iterate over all entries 
	for c in scrollContainerRows.get_children():
		if c is preload("res://interface/new-combo-list/animationEntry.gd"):
			moveEntryElements.append(c)
	
			#a universal move that every hero share the same name and description?
			if c.universalMove !=  AnimationEntryResource.UniversalMove.NA:
				var nameLable = c.get_node("container/moveName")
				nameLable.text = universalMoveMap[UNI_MOVE_NAME_IX][c.universalMove]
				c.type =  universalMoveMap[UNI_MOVE_TYPE_IX][c.universalMove]
				c.description =  universalMoveMap[UNI_MOVE_DESCRIPTION_IX][c.universalMove]
			
					

	comboCancelStaticStringCancelTypeMap[COMBO_CANCEL_BASIC_STATIC_STRING]=	actionAnimeManager.AUTO_CANCEL_COMMANDS_BASIC
	comboCancelStaticStringCancelTypeMap[COMBO_CANCEL_ON_HIT_STATIC_STRING]=	actionAnimeManager.AUTO_CANCEL_COMMANDS_ONHIT
	comboCancelStaticStringCancelTypeMap[COMBO_CANCEL_AUTO_ABILITY_STATIC_STRING]=	actionAnimeManager.AUTO_CANCEL_COMMANDS_ONHIT_AUTO_ABILITY_CANCEL	
	comboCancelStaticStringCancelTypeMap[COMBO_CANCEL_LANDING_LAG_STATIC_STRING]=	actionAnimeManager.AUTO_CANCEL_COMMANDS_LANDING_LAG_CANCEL	
	comboCancelStaticStringCancelTypeMap[COMBO_CANCEL_ONHIT_LANDING_LAG_STATIC_STRING]=	actionAnimeManager.AUTO_CANCEL_COMMANDS_ON_HIT_LANDING_LAG_CANCEL
	
	
	autoCancelBlackListMaskMap[actionAnimeManager.AUTO_CANCEL_COMMANDS_BASIC] = 1 
	autoCancelBlackListMaskMap[actionAnimeManager.AUTO_CANCEL_COMMANDS_ONHIT] = 1 <<2
	autoCancelBlackListMaskMap[actionAnimeManager.AUTO_CANCEL_COMMANDS_ONHIT_AUTO_ABILITY_CANCEL] = 1 <<3
	autoCancelBlackListMaskMap[actionAnimeManager.AUTO_CANCEL_COMMANDS_LANDING_LAG_CANCEL] = 1 <<4
	autoCancelBlackListMaskMap[actionAnimeManager.AUTO_CANCEL_COMMANDS_ON_HIT_LANDING_LAG_CANCEL] = 1<<5
			
			
	comboCancelActionIdBlackListMap[actionAnimeManager.PLATFORM_ANIMATION_CANCEL_ACTION_ID]=null
	comboCancelActionIdBlackListMap[actionAnimeManager.APEX_ONLY_FAST_FALL_ACTION_ID]=null
	comboCancelActionIdBlackListMap[actionAnimeManager.STOP_PLATFORM_LEAVE_MOMENTUM_ACTION_ID]=null
	comboCancelActionIdBlackListMap[actionAnimeManager.PLATFORM_DROP_ACTION_ID]=null
	comboCancelActionIdBlackListMap[actionAnimeManager.AIR_MOVE_STOP_ACTION_ID]=null
	comboCancelActionIdBlackListMap[actionAnimeManager.GROUND_IDLE_ACTION_ID]=null
	comboCancelActionIdBlackListMap[actionAnimeManager.PROXIMITY_GUARD_CROUCHING_HOLD_BACK_BLOCK_ACTION_ID]=null
	comboCancelActionIdBlackListMap[actionAnimeManager.SLIDING_GROUND_IDLE_ACTION_ID]=null
	
	
	
	
			
	
	inputDevices.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDevices.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	
	
	cmdTextureMap = $"CommandMap"
	
	
	
	
	descriptionNodes.append($"Middle/detailsContainer/descriptionContainer")
	descriptionNodes.append($"Header/details-icons/desc-icons")
	
	comboCancelsNodes.append($"Header/details-icons/combo-icons")
	comboCancelsNodes.append($"Middle/detailsContainer/combosContainer")
	
	airComboCancelEntryTemplate = $"templates/airComboCancelEntryTemplate"
	comboCancelEntryTemplate = $"templates/comboCancelEntryTemplate"
	comboCancelStaticLabelTemplate = $"templates/staticLabel2"

	comboCancelRows = $"Middle/detailsContainer/combosContainer/cmdScrollContainer/rows"
	
	#clearComboCancelEntries()
	
	
	
	
	#addComboCancelStaticEntry(COMBO_CANCEL_BASIC_STATIC_STRING)
	#_addComboCancelEntry(true,cmdTextureMap.lookupTexture(InputManagerResource.Command.CMD_BACKWARD_MELEE),"Jab")
	#_addComboCancelEntry(false,cmdTextureMap.lookupTexture(InputManagerResource.Command.CMD_FORWARD_TOOL),"kick")
	#addComboCancelStaticEntry(COMBO_CANCEL_ON_HIT_STATIC_STRING)
	#_addComboCancelEntry(false,cmdTextureMap.lookupTexture(InputManagerResource.Command.CMD_DASH_FORWARD),"slap")
	#addComboCancelEntry(true,InputManagerResource.Command.CMD_FORWARD_SPECIAL,"clap")
	
	#_updateDetailView()
	
	#make sure the first melee is selected by default (0th index is the melee section)
	#scrollContainerCursor=1
	#currMoveSelected = scrollContainerRows.get_child(scrollContainerCursor)
	#highlight selected move
	#updateSelectedElementColor(true)
	
	reset()
	#dynamically calculate max size of scroll verticale
	var rectSizeYSum = 0
	for c in scrollContainer.get_children():
		rectSizeYSum = rectSizeYSum + c.rect_size.y
	scrollV_max=max(0,rectSizeYSum-scrollContainer.rect_size.y)
	
	
	
	disable()
	
func disable():
	self.visible = false
	set_physics_process(false)
	active = false

func activate():
	self.visible = true
	set_physics_process(true)	
	active = true
	reset()
	
	#make sure when it first shows up you have desciription of
	#the student (even though n-melee is chosen)
	if currMoveSelected != null and currMoveSelected is preload("res://interface/new-combo-list/animationEntry.gd"):
		currMoveSelected.color = unselectedMoveColor
	
	#going down means select n melee
	scrollContainerCursor=0
	_updateDetailView()
	
func reset():
	clearComboCancelEntries()
	
	#make sure we start at beggingin for scroll
	scrollContainer.scroll_vertical= 0
	scrollContainer.update()# after changing the value of scroll_vertical
	
	#make sure all the selecitons and not selected by default
	for moveEntry in moveEntryElements:
			
		#not selected by default
		moveEntry.color = unselectedMoveColor
	
	
	detailsViewState = DetailsView.DESCRIPTION
	
	
	_updateDetailView()
	
			
			
	#make sure the first melee is selected by default (0th index is the melee section)
	scrollContainerCursor=1
	currMoveSelected = scrollContainerRows.get_child(scrollContainerCursor)
	#highlight selected move
	updateSelectedElementColor(true)
	

#populates the move description with hero description
func loadHeroInformation():
	_updateDescriptionViewValues(playerController.heroName,"Student information",scrollContainerRows.studentType,"NA","NA","NA","NA","NA","NA","NA","NA",scrollContainerRows.studentDescription)
	
func populateDescriptionDetailsView():
	descriptionViewRecoveryFramesHeader.text = "Recovery"
	descriptionViewActiveFramesHeader.text = "Active"
	descriptionViewHitAdvFramesHeaderNode.text = "Hit Advantage"
	descriptionViewLinkHitAdvFramesHeaderNode.text="Link Hit Advantage"
	descriptionViewGoodBlockAdvFramesHeader.text="Good Block Advan."
	descriptionViewBadBlockAdvFramesHeader.text="Bad Block Advan."

	if currMoveSelected == null or (not currMoveSelected is preload("res://interface/new-combo-list/animationEntry.gd")):
		return
	
	var projectileInstance = null
	var _actionAnimeManager=null
	if currMoveSelected.projectileOverrideNodePath != "":
		
		#read projectile from cache
		projectileInstance=projectileMap[currMoveSelected.projectileOverrideNodePath]
		
	
	if projectileInstance!=null:
		_actionAnimeManager	=projectileInstance.actionAnimationManager
	else:
		_actionAnimeManager=actionAnimeManager
		
		
	var moveName = currMoveSelected.getName()
	var moveType =currMoveSelected.type
	
	var moveDesc = ""
	#any entry that specifies the universal type will override action manager's description
	if currMoveSelected.universalMove ==  AnimationEntryResource.UniversalMove.NA:
		
		#prioritize the action anime manager description. if not present then use the UI's version
		moveDesc = _actionAnimeManager.getActionFullDetails(currMoveSelected.actionId)
		if moveDesc == "":
			moveDesc = currMoveSelected.description
	else:
		moveDesc = currMoveSelected.description
			
	var actionId = currMoveSelected.actionId
	
	
	var properties = ""
	var barCost = ""
	var startupFrames ="NA"
	var activeFrames ="NA"
	var recoveryFrames ="NA"
	var parryFrames ="NA"
	var preParryFrames ="NA"
	var hitAdvFrames="NA"
	var linkHitAdvFrames="NA"
	var goodBlockAdvFrames="NA"
	var badBlockAdvFrames="NA"
	var hasLandingLagFrame = false
	
	var addHitstunProperty=""
	
	
	if actionId!= -1:
		
		
		var sa = _actionAnimeManager._spriteAnimationLookup(actionId)
		
		#the sprite animation id is rempaped due to stale moves?
		#if sa.hasStaleHitbox:
		if currMoveSelected.staleAnimation:
			
			#stale maoves don't have an action id, so the UI entry will be one to define it
			moveDesc = currMoveSelected.description
			#remap sprite animation to the statel moves version
			var animeId = _actionAnimeManager.lookupOneTimeHitRemapSpriteAniamtionId(sa.id)
			sa = _actionAnimeManager.spriteAnimationManager.spriteAnimations[animeId]
		
		if projectileInstance == null:
			barCost = parseActionIdAbilityBarCost(sa)
		else:
			barCost="NA"
		
		#auto ability cancel isn't NA /free?
		#if sa.autoAbilityCancelCostType != sa.AbilityCancelCostType.NA:
		
		#see if some moves are auto ability cancelable
		#var autoAbilityCancels = _getAllAutocancelableActionIds(sa,_actionAnimeManager.AUTO_CANCEL_COMMANDS_ONHIT_AUTO_ABILITY_CANCEL)
		#don't show the cost (0) if non cancelalbe
		#if autoAbilityCancels.size() == 0:
		#	autoAbilityCancelCost="NA"
		#else:
		#	autoAbilityCancelCost = parseActionIdAutoAbilityBarCost(sa)
		
		var totalAnimationDuration = 0
		
		
		#var startupSpriteFrameNum =0
		var parrySpriteFrameNum =0
		var preParrySpriteFrameNum =0
		#var startupDuration=currMoveSelected.additionalStartupFrames
		var recoveryDuration=0
		var parryFrameDuration=0
		var preParryFrameDuration=0
		
		var wasLastFrameStartup=false
		var wasLastFrameParry=false
		var wasLastFramePreParry=false
		var countingStartup=true
		
	
		#an action id is specified to override startup frames?
		if currMoveSelected.startupFrameDataOverideActionId != -1 :				
			var tmpSA = _actionAnimeManager._spriteAnimationLookup(currMoveSelected.startupFrameDataOverideActionId)
			startupFrames = spriteAnimationToFrameDataString(tmpSA.spriteFrames,GLOBALS.FrameType.STARTUP,currMoveSelected.additionalStartupFrames)
		else:
			startupFrames = spriteAnimationToFrameDataString(sa.spriteFrames,GLOBALS.FrameType.STARTUP,currMoveSelected.additionalStartupFrames)
			
		
		#an action id is specified to override active frames?
		if currMoveSelected.activeFrameDataOverideActionId != -1 :				
			var tmpSA = _actionAnimeManager._spriteAnimationLookup(currMoveSelected.activeFrameDataOverideActionId)
			var tmpRes  = spriteAnimationHitboxFrameDatatoString(tmpSA.spriteFrames,_actionAnimeManager,projectileInstance,currMoveSelected.replaceHitAdvWithKnockdown)
			
			activeFrames=tmpRes[0]
			hitAdvFrames=tmpRes[1]
			linkHitAdvFrames=tmpRes[2]
			goodBlockAdvFrames=tmpRes[3]
			badBlockAdvFrames=tmpRes[4]
		else:	
			var tmpRes  = spriteAnimationHitboxFrameDatatoString(sa.spriteFrames,_actionAnimeManager,projectileInstance,currMoveSelected.replaceHitAdvWithKnockdown)
			
			activeFrames=tmpRes[0]
			hitAdvFrames=tmpRes[1]
			linkHitAdvFrames=tmpRes[2]
			goodBlockAdvFrames=tmpRes[3]
			badBlockAdvFrames=tmpRes[4]
		
		#an action id is specified to override recovery frames?
		if currMoveSelected.recoveryFrameDataOverideActionId != -1 :				
			var tmpSA = _actionAnimeManager._spriteAnimationLookup(currMoveSelected.recoveryFrameDataOverideActionId)
			recoveryFrames = spriteAnimationToFrameDataString(tmpSA.spriteFrames,GLOBALS.FrameType.RECOVERY,0)
		else:
			recoveryFrames = spriteAnimationToFrameDataString(sa.spriteFrames,GLOBALS.FrameType.RECOVERY,0)
			
		
		
		var spriteFrameIsParry=false
		#count animation duration
		for sf in sa.spriteFrames:
			totalAnimationDuration=totalAnimationDuration +sf.duration
			
			if projectileInstance == null:
				hasLandingLagFrame = hasLandingLagFrame or sf.landing_lag==sf.LandingType.LANDING_LAG
		
		
		addHitstunProperty= parseAddHitstunTypeProperty(sa.spriteFrames)
		
		var animationDurationSoFar=0
		var animeRemainingFrames=totalAnimationDuration
		var i = 0
		#count the duration of startup, recovery, and active 		
		for sf in sa.spriteFrames:
			
			if sa.hasParryHurtbox:
				
				spriteFrameIsParry=false
				#at a parry frame?
				for hb in sf.hurtboxes:
					if hb.onGettingHitCounterActionId!= -1:
						spriteFrameIsParry=true
						break								
			
			#check for parries and keep track of pre- (startup) and parry frames
			if sa.hasParryHurtbox:
				
				if spriteFrameIsParry and sf.type == sf.FrameType.NEUTRAL:
					parryFrameDuration = parryFrameDuration+sf.duration	
					wasLastFrameParry=true
				elif not spriteFrameIsParry and sf.type == sf.FrameType.NEUTRAL:
	
					preParryFrameDuration = preParryFrameDuration+sf.duration	
					wasLastFramePreParry=true
					
				#do we update the parry frame string (changed from parrying to not, or end of animation?)
				if not spriteFrameIsParry or sf.type != sf.FrameType.NEUTRAL or i == (sa.spriteFrames.size()-1):
						
					
					#no longer in parry frame so update the string?
					if wasLastFrameParry:
						if parrySpriteFrameNum == 0:
							parryFrames = str(parryFrameDuration) 
						else:
							parryFrames = parryFrames +","+str(parryFrameDuration)
							
						parrySpriteFrameNum = parrySpriteFrameNum+1
					parryFrameDuration=0
					wasLastFrameParry=false
				#do we update the parry frame string (changed from parrying to not, or end of animation?)
				if spriteFrameIsParry or  sf.type != sf.FrameType.NEUTRAL or i == (sa.spriteFrames.size()-1):
						
					
					#no longer in pre-parry frame so update the string?
					if wasLastFramePreParry :
						if preParrySpriteFrameNum == 0:
							preParryFrames = str(preParryFrameDuration) 
						else:
							preParryFrames = preParryFrames +","+str(preParryFrameDuration)
							
						preParrySpriteFrameNum = preParrySpriteFrameNum+1
					preParryFrameDuration=0
					wasLastFramePreParry=false
			
		
			
			#if sf.type == sf.FrameType.RECOVERY:
			#	recoveryDuration=recoveryDuration+sf.duration
			#	recoveryFrames=str(recoveryDuration)	
			
			animationDurationSoFar = animationDurationSoFar +sf.duration
			i = i +1
		
		
		#basic projectile that does "startup", "active", and "recovery"??
		#we override the statup/active/recovery strings
		if projectileInstance!= null:
			

			if currMoveSelected.projectileFrameDataType==currMoveSelected.ProjectileFrameDataType.BASIC:
				var projStartupSA = _actionAnimeManager._spriteAnimationLookup(_actionAnimeManager.STARTUP_ACTION_ID)
				var projActiveSA = _actionAnimeManager._spriteAnimationLookup(_actionAnimeManager.ACTIVE_ACTION_ID)			
				var projRecoverySA = _actionAnimeManager._spriteAnimationLookup(_actionAnimeManager.COMPLETION_ACTION_ID)
				
				addHitstunProperty= parseAddHitstunTypeProperty(projActiveSA.spriteFrames)
				
				if projStartupSA.isLoopingWithDuration:
					startupFrames=str(projStartupSA.loopDuration)
				else:
					startupFrames=str(projStartupSA.getEffectiveNumberOfFrames())
					
				if projActiveSA.isLoopingWithDuration:
					activeFrames=str(projActiveSA.loopDuration)
				else:
					activeFrames=str(projActiveSA.getEffectiveNumberOfFrames())				
					
				if projRecoverySA.isLoopingWithDuration:
					recoveryFrames=str(projRecoverySA.loopDuration)
				else:
					recoveryFrames=str(projRecoverySA.getEffectiveNumberOfFrames())
			elif currMoveSelected.projectileFrameDataType==currMoveSelected.ProjectileFrameDataType.FUSE_MANY_ANIMATIONS:
				
				var tmpSpriteFrames=[]
				
				#parse the acton id CSV field into tokens seperated by comma
				var fusedActionIDStrings = currMoveSelected.fusedCSVActionIDs.rsplit(",",false,0)
								
				#iterate the action ids desired to combine
				for actionIdStr in fusedActionIDStrings:
					var fusingSA =  _actionAnimeManager._spriteAnimationLookup(int(actionIdStr))
					for sf in fusingSA.spriteFrames:
						tmpSpriteFrames.append(sf)
				
				addHitstunProperty= parseAddHitstunTypeProperty(tmpSpriteFrames)
				
				startupFrames = spriteAnimationToFrameDataString(tmpSpriteFrames,GLOBALS.FrameType.STARTUP,currMoveSelected.additionalStartupFrames)
				
				var tmpRes  = spriteAnimationHitboxFrameDatatoString(tmpSpriteFrames,_actionAnimeManager,projectileInstance,currMoveSelected.addKnockdownOkiDurationToHitstun)
		
				activeFrames=tmpRes[0]
				hitAdvFrames=tmpRes[1]
				linkHitAdvFrames=tmpRes[2]
				goodBlockAdvFrames=tmpRes[3]
				badBlockAdvFrames=tmpRes[4]
				recoveryFrames = spriteAnimationToFrameDataString(tmpSpriteFrames,GLOBALS.FrameType.RECOVERY,0)
				
			
			else:
				#we just leaev as is, already did the work for SINGLE_ANIMATION
				pass
			
			
		
		if currMoveSelected.displayRawMeatyFrameData:
			descriptionViewHitAdvFramesHeaderNode.text = "Hit Duration"
			descriptionViewLinkHitAdvFramesHeaderNode.text="Link Hit Duration"
			descriptionViewGoodBlockAdvFramesHeader.text="Good Block Duration"
			descriptionViewBadBlockAdvFramesHeader.text="Bad Block Duration"
		
		if currMoveSelected.replaceHitAdvWithKnockdown:
			hitAdvFrames= KNOCKDOWN_STR
			if linkHitAdvFrames != "NA":
				linkHitAdvFrames = KNOCKDOWN_STR
		#no active frames? (GOTTA check type since simply doing == "NA" or == 0 will bug out due to typing issues)
		var noActiveFrameFlag=false
		if sa.hasParryHurtbox:
			if typeof(parryFrames) == TYPE_STRING and parryFrames == "NA":
				noActiveFrameFlag=true
			elif typeof(parryFrames) == TYPE_INT and parryFrames == 0:
				noActiveFrameFlag=true
		else:		
			if typeof(activeFrames) == TYPE_STRING and activeFrames == "NA":
				noActiveFrameFlag=true
			elif typeof(activeFrames) == TYPE_INT and activeFrames == 0:
				noActiveFrameFlag=true
		if  noActiveFrameFlag:
			startupFrames="NA" #startup and active frames not applicaable to aniamtion withotu hitbox
			activeFrames="NA"
			recoveryFrames =str(totalAnimationDuration)  #recovery indicates total duration			
			hitAdvFrames="NA"
			parryFrames = "NA"
			preParryFrames = "NA"
			linkHitAdvFrames="NA"
			goodBlockAdvFrames="NA"
			badBlockAdvFrames="NA"
	#else:
	#	autoAbilityCancelCost="NA"
		if hasLandingLagFrame:
			recoveryFrames = recoveryFrames + "("+str(sa.landingLagDuration)+")"
		
		if sa.hasParryHurtbox:
			descriptionViewActiveFramesHeader.text = "Parry"
			activeFrames = parryFrames
			startupFrames = preParryFrames
			
		if currMoveSelected.hitAdvantageOverride != "":
			hitAdvFrames=currMoveSelected.hitAdvantageOverride 
		if currMoveSelected.linkHitAdvantageOverride != "":
			linkHitAdvFrames=currMoveSelected.linkHitAdvantageOverride 
		if currMoveSelected.goodBlockAdvantageOverride != "":
			goodBlockAdvFrames=currMoveSelected.goodBlockAdvantageOverride 
		if currMoveSelected.badBlockAdvantageOverride != "":
			badBlockAdvFrames=currMoveSelected.badBlockAdvantageOverride 
		if currMoveSelected.recoveryAdvOverride != "":
			recoveryFrames=currMoveSelected.recoveryAdvOverride 
		if currMoveSelected.activeAdvOverride != "":
			activeFrames=currMoveSelected.activeAdvOverride 
		if currMoveSelected.startupAdvOverride != "":
			startupFrames=currMoveSelected.startupAdvOverride 
		
		
		var propertyStrings=[]
		
		#ARIAL?
		if  projectileInstance == null and _actionAnimeManager.isAirActionId(actionId):
			propertyStrings.append(AIR_STR)
			#properties = AIR_STR
		
		if currMoveSelected.addKnockdownOkiDurationToHitstun:
			propertyStrings.append(KNOCKDOWN_STR)
			
		#var sa = _actionAnimeManager.spriteAnimationLookup(actionId)
		
		#HAS LOW HITBOX?
		if sa.hasLowHitbox:
			#properties = properties + ","+LOW_STR
			propertyStrings.append(LOW_STR)
		 
		#BECOMES SATELE AFTER A CERTAIN NUMBER OF HITS
		#if sa.hasStaleHitbox:
			#properties = properties + ","+STALE_STR
		#	propertyStrings.append(STALE_STR)
		
		if addHitstunProperty != "":
			propertyStrings.append(addHitstunProperty)
		#A GRAB?
		if sa.hasGrabHitbox:	
			#properties = properties + ","+GRAB_STR
			propertyStrings.append(GRAB_STR)
		
		if sa.hasParryHurtbox:				
			propertyStrings.append(PARRY_STR)
		if sa.hasInvincibilityHurtbox:				
			propertyStrings.append(INVINCIBILITY_STR)
		if sa.hasArmorHurtbox:				
			propertyStrings.append(ARMOR_STR)
		
		if sa.hasDedicatedAntiAirHitbox:
			propertyStrings.append(ANTI_AIR_ONLY_STR)
		if sa.hasDedicatedAntiGroundHitbox:
			propertyStrings.append(ANTI_GROUND_ONLY_STR)	
		if sa.hasHitsWakeupOpponentHitbox:
			propertyStrings.append(OTG_STR)	
	
		if sa.hasBlockStunMeatyHitbox and not currMoveSelected.ignoreHitstunMeatyProperty:
			propertyStrings.append(ON_HIT_MEATY_STR)
		if sa.hasMeatyHitbox and not currMoveSelected.ignoreBlockMeatyProperty:
			propertyStrings.append(ON_BLOCK_MEATY_STR)
	
		#we seperate each property by commands
		for i in propertyStrings.size():
			var propertyStr = propertyStrings[i]
			if i == propertyStrings.size() -1:
				properties = properties +propertyStr
			else:
				properties = properties +propertyStr +", "
			
	else:
		properties =""
		barCost="NA"
		startupFrames ="NA"
		activeFrames ="NA"
		recoveryFrames ="NA"
		hitAdvFrames="NA"
		parryFrames = "NA"
		preParryFrames = "NA"
		linkHitAdvFrames="NA"
		goodBlockAdvFrames="NA"
		badBlockAdvFrames="NA"
	
	#manually add properties that aren't necessarily statically represented in an animation's frame data
	#but will apply (like how belt's angry animation don't have super aarmor, but the belt controller dycamically gives her 
	#super armor)
	if currMoveSelected.additionalProperties != "":
		if properties == "":
			properties = currMoveSelected.additionalProperties
		else:
			properties = properties + ", "+currMoveSelected.additionalProperties
			
		
	if currMoveSelected.disableComboCancelView:
		toggleDetailsViewCirclePair.visible=false
	else:
		toggleDetailsViewCirclePair.visible=true
		
	if linkHitAdvFrames == "NA" or linkHitAdvFrames == hitAdvFrames:
		descriptionViewLinkHitAdvFramesNode.visible = false
		descriptionViewLinkHitAdvFramesHeaderNode.visible = false
	else:
		descriptionViewLinkHitAdvFramesNode.visible = true
		descriptionViewLinkHitAdvFramesHeaderNode.visible = true
		
	if hasLandingLagFrame:
		
		descriptionViewRecoveryFramesHeader.text = "Recovery (Land Lag)"
		
	else:
		descriptionViewRecoveryFramesHeader.text = "Recovery"
	
	
	#moveName, moveType, propertiesStr,cancelCost,autoAbilityCancelCost,description):
	_updateDescriptionViewValues(moveName,moveType,properties,barCost,startupFrames,activeFrames,recoveryFrames,hitAdvFrames,linkHitAdvFrames,goodBlockAdvFrames,badBlockAdvFrames,moveDesc)
	
	
func spriteAnimationHitboxFrameDatatoString(spriteFrames,_actionAnimeManager,projectileInstance,addKnockdownOkiDurationToHitstun):
	var totalAnimationDuration = 0
	for sf in spriteFrames:
		totalAnimationDuration=totalAnimationDuration +sf.duration
	var i = 0
	var animationDurationSoFar=0
	var animeRemainingFrames=totalAnimationDuration
	var activeFrames = "NA"
	var hitAdvFrames="NA"
	var linkHitAdvFrames="NA"
	var goodBlockAdvFrames="NA"
	var badBlockAdvFrames="NA"
	var activeSpriteFrameNum =0
	var activeDuration=0
	var hitAdvDuration=0
	var blockAdvDuration=0

	var wasLastFrameActive=false
	var hitFrameAdvantages=[]
	var linkHitFrameAdvantages=[]
	var goodBlockFrameAdvantages=[]
	var badBlockFrameAdvantages=[]
	
	
	for	 sf in spriteFrames:
			
		if sf.type == sf.FrameType.ACTIVE:
			
			activeDuration = activeDuration + sf.duration				
			#countingStartup=false #stop counting startup frames, reached an active frame
			
			#only update the animation time remaing every new set of active farmes (once per hit)
			if not wasLastFrameActive:
				animeRemainingFrames =totalAnimationDuration-animationDurationSoFar#-1 #+1 since in the frame data displayer, +1 is added i think
			
			
			var onHitAnimeFramesRemain=-1
			
			
			#check if hitboxes does an animation on hit (duratino required for hit advantage calculation)
			var on_hit_action_id=-1
			
			if projectileInstance == null:
				#we assume here a single hitbox will determine on hit id. Otherwise it overrides if 2 exist
				#we also don't distinguish link and normal hit on hit actiosn here
				for hb in sf.hitboxes:
					if hb.on_hit_action_id != -1:
						on_hit_action_id=hb.on_hit_action_id
					if hb.on_link_hit_action_id != -1:
						on_hit_action_id=hb.on_link_hit_action_id 
							
					
			if on_hit_action_id != -1:			
			
				#since we played an aniamtion on hit, the total duraiton remaing of
				#frames for animation is updated to the new animation's duration, for sake 
				#of applying hitstun/blockstun relative to animaton frames remaining (particularly
				#important to correctly display grab frame data)
				var currentAnimation = _actionAnimeManager._spriteAnimationLookup(on_hit_action_id)	
				if currentAnimation != null:
					onHitAnimeFramesRemain=currentAnimation.getEffectiveNumberOfFrames()+1#+1 to compensate for 1 frame early
			
			if on_hit_action_id != -1:			
			
				#since we played an aniamtion on hit, the total duraiton remaing of
				#frames for animation is updated to the new animation's duration, for sake 
				#of applying hitstun/blockstun relative to animaton frames remaining (particularly
				#important to correctly display grab frame data)
				var currentAnimation = _actionAnimeManager._spriteAnimationLookup(on_hit_action_id)	
				if currentAnimation != null:
					onHitAnimeFramesRemain=currentAnimation.getEffectiveNumberOfFrames()+1#+1 to compensate for 1 frame early
					
			

			#we only consider meaties the first active sprite frame
			#if not wasLastFrameActive:
			var _hitAvgFrames 
			if onHitAnimeFramesRemain != -1 and not currMoveSelected.ignoreOnHitAnimationDuration:
				#this combo entry include oki knockdown duraiton in the frame data compuation?
				if addKnockdownOkiDurationToHitstun:
					_hitAvgFrames =  parseActiveFrameHitAdvantageString(sf,onHitAnimeFramesRemain-OKI_KNOCKDOWN_DURATION,true)
				else:
					_hitAvgFrames =  parseActiveFrameHitAdvantageString(sf,onHitAnimeFramesRemain,true)
			else:
				#this combo entry include oki knockdown duraiton in the frame data compuation?
				if addKnockdownOkiDurationToHitstun:
					_hitAvgFrames =  parseActiveFrameHitAdvantageString(sf,animeRemainingFrames-OKI_KNOCKDOWN_DURATION,true)
				else:
					_hitAvgFrames =  parseActiveFrameHitAdvantageString(sf,animeRemainingFrames,true)
			mergeArraysHelper(hitFrameAdvantages,_hitAvgFrames)
			#else:
			#var _hitAvgFrames =  parseActiveFrameHitAdvantageString(sf,animeRemainingFrames,false)
			#mergeArraysHelper(hitFrameAdvantages,_hitAvgFrames)
			
			
			#we only consider meaties the first active sprite frame
			#if not wasLastFrameActive:
			if onHitAnimeFramesRemain != -1 and not currMoveSelected.ignoreOnHitAnimationDuration:
				#this combo entry include oki knockdown duraiton in the frame data compuation?
				if addKnockdownOkiDurationToHitstun:
					_hitAvgFrames =  parseActiveFrameLinkHitAdvantageString(sf,onHitAnimeFramesRemain-OKI_KNOCKDOWN_DURATION,true)
				else:
					_hitAvgFrames =  parseActiveFrameLinkHitAdvantageString(sf,onHitAnimeFramesRemain,true)
			else:
				#this combo entry include oki knockdown duraiton in the frame data compuation?
				if addKnockdownOkiDurationToHitstun:
					_hitAvgFrames = parseActiveFrameLinkHitAdvantageString(sf,animeRemainingFrames-OKI_KNOCKDOWN_DURATION,true)
				else:
					_hitAvgFrames =  parseActiveFrameLinkHitAdvantageString(sf,animeRemainingFrames,true)
			mergeArraysHelper(linkHitFrameAdvantages,_hitAvgFrames)
			#else:
			#	var _hitAvgFrames =  parseActiveFrameLinkHitAdvantageString(sf,animeRemainingFrames,false)
			#	mergeArraysHelper(linkHitFrameAdvantages,_hitAvgFrames)
			
			#we only consider meaties the first active sprite frame
			#if not wasLastFrameActive:
			if onHitAnimeFramesRemain != -1 and not currMoveSelected.ignoreOnHitAnimationDuration:			
				_hitAvgFrames =  parseActiveFrameGoodBlockAdvantageString(sf,onHitAnimeFramesRemain,true)
			else:
				_hitAvgFrames =  parseActiveFrameGoodBlockAdvantageString(sf,animeRemainingFrames,true)
			
			mergeArraysHelper(goodBlockFrameAdvantages,_hitAvgFrames)
			#else:
			#	var _hitAvgFrames =  parseActiveFrameGoodBlockAdvantageString(sf,animeRemainingFrames,false)
			#	mergeArraysHelper(goodBlockFrameAdvantages,_hitAvgFrames)
			
			#we only consider meaties the first active sprite frame
			#if not wasLastFrameActive:
			if onHitAnimeFramesRemain != -1 and not currMoveSelected.ignoreOnHitAnimationDuration:					
				_hitAvgFrames =  parseActiveFrameBadBlockAdvantageString(sf,onHitAnimeFramesRemain,true)
			else:
				_hitAvgFrames =  parseActiveFrameBadBlockAdvantageString(sf,animeRemainingFrames,true)
			
			
			mergeArraysHelper(badBlockFrameAdvantages,_hitAvgFrames)
			#else:
			#	var _hitAvgFrames =  parseActiveFrameBadBlockAdvantageString(sf,animeRemainingFrames,false)
			#	mergeArraysHelper(badBlockFrameAdvantages,_hitAvgFrames)
				
			wasLastFrameActive=true
			
			#force the string update for last frame thats active
			if i == (spriteFrames.size()-1):
				 #a single set of active sprite frames
				if activeSpriteFrameNum == 0:
					activeFrames = str(activeDuration)
					hitAdvFrames=frameAdvArrayToString(hitFrameAdvantages)
					linkHitAdvFrames=frameAdvArrayToString(linkHitFrameAdvantages)
					goodBlockAdvFrames=frameAdvArrayToString(goodBlockFrameAdvantages)
					badBlockAdvFrames=frameAdvArrayToString(badBlockFrameAdvantages)
					
				#a more than one set of active sprite frames (multi hit)
				else:
					activeFrames = activeFrames +","+str(activeDuration)
					hitAdvFrames=hitAdvFrames + ","+frameAdvArrayToString(hitFrameAdvantages)
					linkHitAdvFrames=linkHitAdvFrames + ","+frameAdvArrayToString(linkHitFrameAdvantages)
					goodBlockAdvFrames=goodBlockAdvFrames + ","+frameAdvArrayToString(goodBlockFrameAdvantages)
					badBlockAdvFrames=badBlockAdvFrames + ","+frameAdvArrayToString(badBlockFrameAdvantages)
					
				activeSpriteFrameNum = activeSpriteFrameNum+1
				hitFrameAdvantages.clear()
				linkHitFrameAdvantages.clear()
				goodBlockFrameAdvantages.clear()
				badBlockFrameAdvantages.clear()
		elif  sf.type != sf.FrameType.ACTIVE : #no longer active or end animation?
			
			
			#no longer active?
			if wasLastFrameActive:
				#we parse the frame data to strings
				
				 #a single set of active sprite frames
				if activeSpriteFrameNum == 0:
					activeFrames = str(activeDuration)
					hitAdvFrames=frameAdvArrayToString(hitFrameAdvantages)
					linkHitAdvFrames=frameAdvArrayToString(linkHitFrameAdvantages)
					goodBlockAdvFrames=frameAdvArrayToString(goodBlockFrameAdvantages)
					badBlockAdvFrames=frameAdvArrayToString(badBlockFrameAdvantages)
					
				#a more than one set of active sprite frames (multi hit)
				else:
					activeFrames = activeFrames +","+str(activeDuration)
					hitAdvFrames=hitAdvFrames + ","+frameAdvArrayToString(hitFrameAdvantages)
					linkHitAdvFrames=linkHitAdvFrames + ","+frameAdvArrayToString(linkHitFrameAdvantages)
					goodBlockAdvFrames=goodBlockAdvFrames + ","+frameAdvArrayToString(goodBlockFrameAdvantages)
					badBlockAdvFrames=badBlockAdvFrames + ","+frameAdvArrayToString(badBlockFrameAdvantages)
					
				activeSpriteFrameNum = activeSpriteFrameNum+1
				hitFrameAdvantages.clear()
				linkHitFrameAdvantages.clear()
				goodBlockFrameAdvantages.clear()
				badBlockFrameAdvantages.clear()
	
			activeDuration=0
			wasLastFrameActive=false
			
		animationDurationSoFar = animationDurationSoFar +sf.duration
		i = i +1	
	
	#add a '~' to indicate knockdown hit dadvantage approximated
	if addKnockdownOkiDurationToHitstun:
		hitAdvFrames = "~"+hitAdvFrames
		linkHitAdvFrames = "~"+linkHitAdvFrames
		
	return [activeFrames,hitAdvFrames,linkHitAdvFrames,goodBlockAdvFrames,badBlockAdvFrames]
func spriteAnimationToFrameDataString(spriteFrames,frameType,additionalFrames):
	var desiredTypeDuration=additionalFrames
	var wasLastFrameDesiredType=false
	var desiredTypeSpriteFrameNum=0
	var resultStr="NA"
	var i =0
	for sf in spriteFrames:
		if sf.type == frameType:
			
			desiredTypeDuration = desiredTypeDuration + sf.duration				
			#countingStartup=false #stop counting startup frames, reached an active frame
			wasLastFrameDesiredType=true
			
		#BATCH of desired frame type changed or end of animation?
		if  sf.type != frameType or i == (spriteFrames.size()-1):
			
			#no longer active?
			if wasLastFrameDesiredType:
				if desiredTypeSpriteFrameNum == 0:
					resultStr = str(desiredTypeDuration) #a single active sprite frame
				else:
					resultStr = resultStr +","+str(desiredTypeDuration) #multiple active seperated by startup (e.g., multi hits)
					
				desiredTypeSpriteFrameNum = desiredTypeSpriteFrameNum+1
			desiredTypeDuration=0#DON'T ADD ADDITIONAL FRAMES AGAIN, SINCE ONLY APPLIES ONCE
			wasLastFrameDesiredType=false
		i = i +1
		
	return resultStr
#converts a list of frame data advantages to string in following format:
# 'x1' for a single element array
# 'x1/x2/x3' for multi element array (elems seperated by /)
#where xi is the element at index i
func frameAdvArrayToString(durList):
	
	if durList == null or durList.size() == 0:
		return "NA"
	elif durList.size() == 1:
		return str(durList[0])
	else:
		var res =str(durList[0])
		
		for i in range(durList.size()-1):
			res = res + "/"+str(durList[i+1])
		return res

	
#returns ""  when hitboxes don't have add hitstun (like adding X to current hitstun)
#and returns "Append ++X hitstun frames"
func parseAddHitstunTypeProperty(spriteFrames):
	for sf in spriteFrames:
		for hb in sf.hitboxes:
			if hb.hitstunDurationType == hb.HITSTUN_DURATION_TYPE_ADD:
				return "Append ++X hitstun frames to current hitstun"
	return ""
#merge two arrays (new appended to existing) without adding duplicates
func mergeArraysHelper(existingArray,newArray):
	
	#add teh frame advantages of this active frame to list of hit advanatges witotu adding duplicates
	for tmp1 in newArray:
		var tmp1InListAlready=false
		for tmp2 in existingArray:
			if tmp2 == tmp1:
				tmp1InListAlready=true
				break
		if not tmp1InListAlready:
			existingArray.append(tmp1)
				
				
#returns list of hitbox on hit + frame durations for each hitbox of spriteframe (.e.g, sour and sweet spot)
func parseActiveFrameHitAdvantageString(sf,animeRemainingFrames,includeMeatyFlag):
	return _parseActiveFrameAdvantageString(sf,animeRemainingFrames,includeMeatyFlag,HIT_ADVANTAGE)
func parseActiveFrameLinkHitAdvantageString(sf,animeRemainingFrames,includeMeatyFlag):
	return _parseActiveFrameAdvantageString(sf,animeRemainingFrames,includeMeatyFlag,LINK_HIT_ADVANTAGE)

#returns list of hitbox on block + frame durations for each hitbox of spriteframe (.e.g, sour and sweet spot)
func parseActiveFrameGoodBlockAdvantageString(sf,animeRemainingFrames,includeMeatyFlag):
	return _parseActiveFrameAdvantageString(sf,animeRemainingFrames,includeMeatyFlag,GOOD_BLOCK_ADVANTAGE)
func parseActiveFrameBadBlockAdvantageString(sf,animeRemainingFrames,includeMeatyFlag):
	return _parseActiveFrameAdvantageString(sf,animeRemainingFrames,includeMeatyFlag,BAD_BLOCK_ADVANTAGE)
		
#won't include meaties more than once for a single active hitbox, sicne duration would hcange each time
#and will just report thewost possible + frames if u hit frame one active (leave this up to caller)
func _parseActiveFrameAdvantageString(sf,animeRemainingFrames,includeMeatyFlag,type):
	#will be adding the plsu frames to frame list, and will dynamically calculatae pluts
	#frames of meaty hitbox durations based on animation time remaining. Type will be used to determine
	#what duration to read from
	
	var plusFrameList=[]
	#iterate hitboxes
	for hb in sf.hitboxes:
		var dur=null
		var meatyFlag =false
		match(type):
			HIT_ADVANTAGE:
				if hb.hitstunType == GLOBALS.HitStunType.BASIC:
					meatyFlag = hb.hitstunDurationType == hb.HITSTUN_DURATION_TYPE_MEATY
					dur = hb.duration
					
					#we denote added hitstun  (isntead of new histun) using ++
					if hb.hitstunDurationType == hb.HITSTUN_DURATION_TYPE_ADD:
						dur = "++"+str(dur)
				else:
					continue #skip this hitbox, its not of desired type
			LINK_HIT_ADVANTAGE:
				if hb.hitstunType == GLOBALS.HitStunType.BASIC or hb.hitstunType == GLOBALS.HitStunType.ON_LINK_ONLY:
					meatyFlag = hb.hitstunDurationType == hb.HITSTUN_DURATION_TYPE_MEATY
					dur = hb.durationOnLink
					if dur == -1:
						dur = hb.duration
					#we denote added hitstun  (isntead of new histun) using ++
					if hb.hitstunDurationType == hb.HITSTUN_DURATION_TYPE_ADD:
						dur = "++"+str(dur)
				else:
					continue
			GOOD_BLOCK_ADVANTAGE:
				if hb.unblockable or hb.isThrow or hb.hitstunType != GLOBALS.HitStunType.BASIC:
					continue
				meatyFlag = hb.blockStunDurationType == hb.HITSTUN_DURATION_TYPE_MEATY
				dur = hb.blockStunDuration
				#we denote added hitstun  (isntead of new histun) using ++
				if hb.hitstunDurationType == hb.HITSTUN_DURATION_TYPE_ADD:
					dur = "++"+str(dur)
			BAD_BLOCK_ADVANTAGE:
				if hb.incorrectBlockUnblockable or hb.isThrow or hb.hitstunType != GLOBALS.HitStunType.BASIC:
					continue
				meatyFlag = hb.blockStunDurationType == hb.HITSTUN_DURATION_TYPE_MEATY
				dur = hb.incorrectBlockStunDuration
				#we denote added hitstun  (isntead of new histun) using ++
				if hb.hitstunDurationType == hb.HITSTUN_DURATION_TYPE_ADD:
					dur = "++"+str(dur)
			_:
				#shouldn't happend
				pass
		if dur == null:
			continue
			
		if meatyFlag:
			#are we skipping meaty hitboxes
			if not includeMeatyFlag:
				continue
			else:
				
				#do we display relative frame advantag? otherwise just total duariotn
				if not currMoveSelected.displayRawMeatyFrameData:
					#gotta calculate relative frame advantage based on time remaining in animation
					dur = dur - animeRemainingFrames
				
		dur = str(dur)
		#don't add duplicate entries (if sour spot and sweet spot have same 
		#frame advantage, just report 1 value for clarity )
		var alreadyAdded=false
		for tmp in plusFrameList:
			if dur ==tmp:
				alreadyAdded=true
				break
		if not alreadyAdded:
			plusFrameList.append(dur)
	return plusFrameList
	
	
#const HIT_ADVANTAGE=0
#const LINK_HIT_ADVANTAGE=1
#const GOOD_BLOCK_ADVANTAGE=2
#const BAD_BLOCK_ADVANTAGE=3
func populateComboCancelsDetailsView():
	
	
	if currMoveSelected == null or (not currMoveSelected is preload("res://interface/new-combo-list/animationEntry.gd")):
		return
	
	if currMoveSelected.actionId == -1:
		staticAirLabelTip.visible=false
		return
		
	#special case for combo cancels?
	if currMoveSelected.specialCase > -1:
		#_handle_special_case_populateComboCancelsDetailsView( currMoveSelected.specialCase)
		return
		
	var displayAirTip = false
	var actionId = currMoveSelected.actionId
	
	
	#do we remap the action id to another move for determining combos that cancel?
	#useufl for on hit animations 
	if currMoveSelected.comboCancelActionId > -1:
		actionId=currMoveSelected.comboCancelActionId
		
	var sa = actionAnimeManager._spriteAnimationLookup(actionId)
	
	#the sprite animation id is rempaped due to stale moves?
	#if sa.hasStaleHitbox:
	if currMoveSelected.staleAnimation:
		#remap sprite animation to the statel moves version
		var animeId = actionAnimeManager.lookupOneTimeHitRemapSpriteAniamtionId(sa.id)
		sa = actionAnimeManager.spriteAnimationManager.spriteAnimations[animeId]
		
	
	
	var addedActionIdCancelsMap = {}
	for staticCombCancelString in comboCancelStaticStringCancelTypeMap.keys():
		var cancelType = comboCancelStaticStringCancelTypeMap[staticCombCancelString]
		
			#does the move prventing listing the auto cancels (e.g., grab, for counter ripost user friendlynes lets u free cancel into any attack
		#but it's inpercivable
		if isTypeBlacklisted(currMoveSelected.autoCancelsTypeBlackList,cancelType):
			continue
		var autoCancels = _getAllAutocancelableActionIds(sa,cancelType)
		
		#given the auto cancel priority, if something is a free autocancel, even if its
		#found in the on hit maps, it has no effect. it's always free. Remove poor-bitmapp managaemtn
		#auto cancels (like a move is both auto-ability cancelable and on hit (on hit takes prioirty))
		
		var filteredAutoCancels = []
		for autoCancel in autoCancels:
			if not addedActionIdCancelsMap.has(autoCancel):
				filteredAutoCancels.append(autoCancel)
				#keep track of auto cancels added		
				addedActionIdCancelsMap[autoCancel] = null				
		
		var airActionAdded = _add_combo_cancel_entry_helper(staticCombCancelString,filteredAutoCancels)
		
			
		displayAirTip = displayAirTip or airActionAdded
	
	
	
	#only show the air (*) tip when an air attack exists in list
	staticAirLabelTip.visible = displayAirTip
	pass

func _add_combo_cancel_entry_helper(staticCombCancelString,autoCancels):

	var displayAirTip = false
	#this move cancels into other moves?
	if autoCancels.size()>0:
		
		var moveName = currMoveSelected.getName()	
		addComboCancelStaticEntry(staticCombCancelString)
		
		#check if all GROUND attacks of a type (every melee, for example) is found in autocancel list
		for i in attackTypeActionIdSets.size():
			var attackTypeActionIdSet = attackTypeActionIdSets[i]		
			if _containsAttackTypeActionIdSet(autoCancels,attackTypeActionIdSet):
				
				#remove all actions ids of same type from autocancels list, and replace with one listing
				
				var newAutoCancelsList = []
				for autoCancel in autoCancels:
					var elementToRemove = false
					
					for blackListActionId in attackTypeActionIdSet:
						if autoCancel==blackListActionId:
							elementToRemove=true
							break
					if not elementToRemove:
						newAutoCancelsList.append(autoCancel)
				
				#replace the auto cancels list with list that didn't include any of the actions all sharing type
				autoCancels=	newAutoCancelsList
				addComboCancelEntry(allAttackTypeAirFlag[i],cmdTypeList[i],allAttackTypeNameList[i])
				
		
		#create an entrye for each auto cancel
		for autoCancelActionId in autoCancels:
			
			
			var isAirAction = actionAnimeManager.isAirActionId(autoCancelActionId)
			displayAirTip = displayAirTip or isAirAction
			var cmd = actionAnimeManager.getCommand(autoCancelActionId)
			
			#for the name, the command is same and in air same, but name changed based on stance
			#save the old stance
			#var oldStance = actionAnimeManager.currentActionIdGroup
			
			#for the stance to current entry
			#actionAnimeManager.currentActionIdGroup=currMoveSelected.stanceIx
			
			#use the same stance as the move used to get description and sprite aniamtion?
			if currMoveSelected.autoCancelNamingStanceIx <= -1:
				autoCancelActionId = actionAnimeManager._actionIdRemapHook(autoCancelActionId,currMoveSelected.stanceIx)
			else:
				autoCancelActionId = actionAnimeManager._actionIdRemapHook(autoCancelActionId,currMoveSelected.autoCancelNamingStanceIx)
				#stance change as result of canceling into a move, so lookup based on given stange
			#reset to old stance (likely default
			#actionAnimeManager.currentActionIdGroup=oldStance
			
			
			var cancelName  =actionAnimeManager.getActionName(autoCancelActionId)
		
			#is this move part of a reka? if so we change name of the auto cancel of
			#the same action
			if currMoveSelected.autoCancelNextRekaActionId>-1 and autoCancelActionId == currMoveSelected.autoCancelPreviousRekaActionId:
				cancelName  =actionAnimeManager.getActionName(currMoveSelected.autoCancelNextRekaActionId)
				
			
			addComboCancelEntry(isAirAction,cmd,cancelName)
			
	return displayAirTip
	
	

func containsAttackTypeActionIdSet(autoCancels,attackType):
	return _containsAttackTypeActionIdSet(autoCancels,attackTypeActionIdSets[attackType])
		
func _containsAttackTypeActionIdSet(autoCancels,attackTypeActionIdSet):
#must have at least 6 action ids to contain a full set of an attack type
	if autoCancels == null or autoCancels.size() < attackTypeActionIdSet.size():
		return false
		
		
	var foundActionId = false
	
	var actionsFounds = 0
	#iterate over each action id of same type taht should be found in autocancel list
	for desiredActionId in attackTypeActionIdSet:
		#iteratae over the autocancel action ids
		for actionId in autoCancels:
			if actionId == desiredActionId:
				actionsFounds = actionsFounds +1
				foundActionId=true
		
		#one of the types isn't iinside auto cancels, so no need to check rest of list?
		if foundActionId == false:
			return false
		
	#check wehter all action ids were found
	return actionsFounds == attackTypeActionIdSet.size()
	
func _handle_special_case_populateComboCancelsDetailsView(specialCase):
		

	#grabbing? it's special since the autocancel masks are dynamically created
	if specialCase == SPECIAL_CASE_GRAB:
		var allPossibleActions = actionAnimeManager.autoCancelMaskMap.keys()
		#feel possible actions with other acutcancelable map
		for actionId in actionAnimeManager.autoCancelMaskMap2.keys():
			allPossibleActions.append(actionId)
		
		var grabActionIdCancelList =[]
		#iterate all possible cancelable action ids
		for actionId in allPossibleActions:
			
			var mask1 = playerController.getGrabAutoAbilityCancelMask(currMoveSelected.stanceIx,true) #true for mask 1
			var mask2 = playerController.getGrabAutoAbilityCancelMask(currMoveSelected.stanceIx,false)#false for mask 2
			#only check the grab handler's auto ability cancel masks, since all masks will be zerod and the
			#auto ability cacnel of grab will be dynamically set
			if actionAnimeManager._isAutoCancelableHelper(actionId,mask1, mask2):
				grabActionIdCancelList.append(actionId)
	
		#HAVE TO THINK ABOUT THIS. MIC HAS TWO DIFFERENT AUTO ABILITY CANCEL MASKS BASED ON RAP OR OPERA FOR GRAB. 
		#MIGHT BE EASIRER TO SCRAP THE COMPLICATED AUTO CANCEL , AND JST EXPALIN "light moves tend to not
		#"prove auto ability cancels when grabing to link a combo.
		_add_combo_cancel_entry_helper(COMBO_CANCEL_AUTO_ABILITY_STATIC_STRING,grabActionIdCancelList)
	else:
		print("unknown special case for auto canceling combo detail handling")
	
func parseActionIdAbilityBarCost(sa):
		
	
	
	var barCost = null
	var barCostStr = null
	if sa == null:
		barCostStr = "NA"
	else:
		
		if 	not sa.barCancelableble:
			return "NA"
		else:
			barCost = playerController.computeAbilityBarCancelCost(sa)
			#barCost = sa.abilityCancelCostTypeToNumberOfChunks()
			
			
	
	
	
	if barCost== 0:
	#	barCostStr= FREE_BAR_COST_STR
		barCostStr = "0"
	elif barCost == null or barCost ==-1:
		barCostStr = "NA"
	else:
		barCostStr = str(barCost)
		
	return barCostStr
	

func parseActionIdAutoAbilityBarCost(sa):
		
	
	
	var barCost = null
	var barCostStr = null
	if sa == null:
		barCostStr = "NA"
	else:
	
		#barCost = playerController.computeAbilityBarCancelCost(sa)
		barCost = sa.autoAbilityCancelCostTypeToNumberOfChunks()
			
	
	
	
	if barCost== 0:
	#	barCostStr= FREE_BAR_COST_STR
		barCostStr = "0"
	elif barCost == null or barCost ==-1:
		barCostStr = "NA"
	else:
		barCostStr = str(barCost)
		
	return barCostStr
	
	


func scrollMovesetUp():
	
	#gray unselected move
	updateSelectedElementColor(false)
	
	
	scrollContainerCursor	 = scrollContainerCursor -1
	#loop back to top when we reach bottom
	if scrollContainerCursor <0:
			scrollContainerCursor= scrollContainerRows.get_child_count() -1
			
	#scrollContainerCursor = max(0,scrollContainerCursor - 1)
	
	#update the selected elemente
	currMoveSelected = scrollContainerRows.get_child(scrollContainerCursor)
	while scrollContainerCursor != 0 and not (currMoveSelected is preload("res://interface/new-combo-list/animationEntry.gd")):
		#keep scrolling until we get to a selectable move
		scrollContainerCursor	 = scrollContainerCursor -1
		
		
		#loop back to top when we reach bottom
		if scrollContainerCursor <0:
			scrollContainerCursor= scrollContainerRows.get_child_count() -1
			
		currMoveSelected = scrollContainerRows.get_child(scrollContainerCursor)
	
	#were back up top?
	if scrollContainerCursor == 0:
		loadHeroInformation()
	#highlight selected move
	updateSelectedElementColor(true)
	
	_updateMovesetScrollPosition()
	
	pass
func scrollMovesetDown():
	
	
	#gray unselected move
	updateSelectedElementColor(false)
	
	#scrollContainerCursor = min(scrollContainerCursor + 1,scrollContainerRows.get_child_count()-1)
	scrollContainerCursor = scrollContainerCursor +1
	#loop back to top when we reach bottom
	if scrollContainerCursor >= scrollContainerRows.get_child_count():
		scrollContainerCursor=0
		
			
	#update the selected elemente
	currMoveSelected = scrollContainerRows.get_child(scrollContainerCursor)
	while scrollContainerCursor != scrollContainerRows.get_child_count() and not (currMoveSelected is preload("res://interface/new-combo-list/animationEntry.gd")):
			#keep scrolling until we get to a selectable move
			
		scrollContainerCursor = scrollContainerCursor +1
		
		
		#loop back to top when we reach bottom
		if scrollContainerCursor >= scrollContainerRows.get_child_count():
			scrollContainerCursor=0
			
		currMoveSelected = scrollContainerRows.get_child(scrollContainerCursor)
	
	#highlight selected move
	updateSelectedElementColor(true)

	_updateMovesetScrollPosition()
	pass
	
func _updateMovesetScrollPosition():
	#indices used to indicate when we can scroll to them cause enough space
	#on screen to center the choice
	var centerScrollUpperIx=SCROLL_EDGE_BOUNDARY_IX_OFFSET
	var centerScrollLowerIx=scrollContainerRows.get_child_count()-SCROLL_EDGE_BOUNDARY_IX_OFFSET
	
	var relativeIx =-1
	
	if  scrollContainerCursor>= centerScrollUpperIx and scrollContainerCursor<=centerScrollLowerIx:
		relativeIx=scrollContainerCursor-SCROLL_EDGE_BOUNDARY_IX_OFFSET
	elif scrollContainerCursor < centerScrollUpperIx: #cursor is at top of screen?
		relativeIx=0 #we see all the top of screen and cursor can move without scrolling
	else: #cursor is at bottom  of screen?
		relativeIx=scrollContainerRows.get_child_count()-1 # at bottom
		
	if relativeIx <0:
		return
		
	var _currMoveSelected =scrollContainerRows.get_child(relativeIx)
	#relativeIx
	#if currMoveSelected!= null:
	#	currMoveSelected = scrollContainerRows.get_child(scrollContainerCursor)
	#var targetScrollRatio=0
	var targetScrollRatio = inverse_lerp(0,scrollV_max,_currMoveSelected.rect_position.y)
	#if  scrollContainerCursor>= centerScrollUpperIx and scrollContainerCursor<=centerScrollLowerIx:
		#targetScrollRatio = inverse_lerp(0,scrollV_max,currMoveSelected.rect_position.y)
	#elif scrollContainerCursor < centerScrollUpperIx: #cursor is at top of screen?
		#targetScrollRatio=0 #we see all the top of screen and cursor can move without scrolling
	#else: #cursor is at bottom  of screen?
		#targetScrollRatio=1 #at bootm
	scrollContainer.scroll_vertical= targetScrollRatio*scrollV_max
	scrollContainer.update()# after changing the value of scroll_vertical
	
func updateSelectedElementColor(selectedFlag):
	if not selectedFlag:
		if currMoveSelected != null and currMoveSelected is preload("res://interface/new-combo-list/animationEntry.gd"):
			currMoveSelected.color = unselectedMoveColor
	else:
		if currMoveSelected != null and currMoveSelected is preload("res://interface/new-combo-list/animationEntry.gd"):
			currMoveSelected.color = selectedMoveColor
			
func toggleDetailsView():
	
	
	if detailsViewState == DetailsView.DESCRIPTION:
		
		
		#can't check autocancels when not selected an entry
		if not currMoveSelected is preload("res://interface/new-combo-list/animationEntry.gd"):						
			return
		#can't check out autocancels?
		if  currMoveSelected.disableComboCancelView:
			return
		detailsViewState=DetailsView.COMBO_CANCELS
		
	else:
		detailsViewState=DetailsView.DESCRIPTION
	
	sfxPlayer.playSound(UI_MOVE_CURSOR_SOUND_ID)
	_updateDetailView()
			
func _updateDetailView():
	if detailsViewState == DetailsView.DESCRIPTION:
		
		
		for node in comboCancelsNodes:
			node.visible = false
			
		for node in descriptionNodes:
			node.visible = true
	else:
		
			
		for node in comboCancelsNodes:
			node.visible = true
			
		for node in descriptionNodes:
			node.visible = false
			
		#we didn't populate the combo cancels?
		if not populatedComboCancels:
	
			populateComboCancelsDetailsView()
			populatedComboCancels=true
	
func _addComboCancelEntry(airFlag,texture,moveName):
	airComboCancelEntryTemplate = $"templates/airComboCancelEntryTemplate"
	comboCancelEntryTemplate = $"templates/comboCancelEntryTemplate"
	comboCancelStaticLabelTemplate = $"templates/staticLabel2"
	var entry = null
	
	if airFlag:
		entry =airComboCancelEntryTemplate.duplicate()
	else:
		entry = comboCancelEntryTemplate.duplicate()
		
	
	comboCancelRows.add_child(entry)
	
	var icon = entry.get_node("cmdIcon")
	icon.texture =  texture
	
	var dynLabel= entry.get_node("dynamicLabel")
	dynLabel.text=moveName

func addComboCancelEntry(airFlag,cmd,moveName):
	var texture = cmdTextureMap.lookupTexture(cmd)
	_addComboCancelEntry(airFlag,texture,moveName)
func addComboCancelStaticEntry(name):
	var entry = comboCancelStaticLabelTemplate.duplicate()
	entry.text = name
	comboCancelRows.add_child(entry)
	
func clearComboCancelEntries():
	populatedComboCancels=false
	for c in comboCancelRows.get_children():
		comboCancelRows.remove_child(c)
	
func _updateDescriptionViewValues(moveName, moveType, propertiesStr,cancelCost,startupFrames,activeFrames,recoveryFrames,hitAdvFrames,linkHitAdvFrames,goodBlockAdvFrames,badBlockAdvFrames,description):
	
	#descriptionViewNameNode.text = moveName
	#descriptionViewTypeNode.text =moveType
	descriptionViewPropertiesNode.text = propertiesStr
	descriptionViewAbilityCancelCostNode.text = cancelCost
	descriptionViewStartupFramesNode.text = startupFrames
	descriptionViewActiveFramesNode.text = activeFrames	
	descriptionViewRecoveryFramesNode.text = recoveryFrames
	descriptionViewHitAdvFramesNode.text = hitAdvFrames
	descriptionViewLinkHitAdvFramesNode.text = linkHitAdvFrames
	descriptionViewGoodBlockAdvFramesNode.text = goodBlockAdvFrames
	descriptionViewBadBlockAdvFramesNode.text = badBlockAdvFrames
	descriptionViewDescriptionNode.text = description
	
	
	

func _physics_process(delta):

	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		

	if Input.is_action_just_pressed(inputManagerDeviceId+"_DOWN"):
		sfxPlayer.playSound(UI_MOVE_CURSOR_SOUND_ID)
		scrollMovesetDown()
		#we don't show autocancels immediatly when scrolling. description shown first
		#detailsViewState = DetailsView.DESCRIPTION
		clearComboCancelEntries()
		_updateDetailView()
		
		populateDescriptionDetailsView()
	elif Input.is_action_just_pressed(inputManagerDeviceId+"_UP"):	
		sfxPlayer.playSound(UI_MOVE_CURSOR_SOUND_ID)
		scrollMovesetUp()
		
		#we don't show autocancels immediatly when scrolling. description shown first
		#detailsViewState = DetailsView.DESCRIPTION
		clearComboCancelEntries()
		_updateDetailView()
		
		populateDescriptionDetailsView()
		
	elif Input.is_action_just_pressed(inputManagerDeviceId+"_RIGHT_TRIGGER"):	
		sfxPlayer.playSound(UI_MOVE_CURSOR_SOUND_ID)
		for i in SCROLL_FAST_ENTRIES_SKIPPED:
			scrollMovesetDown()
		#we don't show autocancels immediatly when scrolling. description shown first
		#detailsViewState = DetailsView.DESCRIPTION
		clearComboCancelEntries()
		_updateDetailView()
		
		populateDescriptionDetailsView()
	elif Input.is_action_just_pressed(inputManagerDeviceId+"_LEFT_TRIGGER"):	
		sfxPlayer.playSound(UI_MOVE_CURSOR_SOUND_ID)
		for i in SCROLL_FAST_ENTRIES_SKIPPED:
			scrollMovesetUp()
		#we don't show autocancels immediatly when scrolling. description shown first
		#detailsViewState = DetailsView.DESCRIPTION
		clearComboCancelEntries()
		_updateDetailView()
		
		populateDescriptionDetailsView()	
	elif Input.is_action_just_pressed(inputManagerDeviceId+"_RIGHT"):
		toggleDetailsView()
	elif Input.is_action_just_pressed(inputManagerDeviceId+"_LEFT"):	
		toggleDetailsView()
	elif Input.is_action_just_pressed(inputManagerDeviceId+"_X"):
		sfxPlayer.playSound(UI_MOVE_CURSOR_SOUND_ID)
		emit_signal("toggle_resource_cost_visibility")
		
	
#returns all possible autocancelable (on hit or basic, depends on type) commands
func _getAllAutocancelableActionIds(spriteAnimation,type):
	
	
	var res = []
	
	var duplicateLookup = {}
	#only get all the possible autocancels (on-hit and normal) when hitting oppoentn
	var autoCancelActionIds  = []

	#const COMBO_TYPE_ALL = 0
	#const COMBO_TYPE_NORMAL = 1
	#const COMBO_TYPE_ON_HIT_ONLY = 2
	
	#iterate all sprite frames of animation
	for sf in spriteAnimation.spriteFrames:
		
		#autocancelable action ids for sprite frame
		var tmpAutoCancelActionIds = actionAnimeManager.__getAutoCancelableActionIds(type,sf)
		
		#iterate all the on-hit autocancelable actionids and append to temperary array
		for aid in tmpAutoCancelActionIds:
			#ignore blacklisted action ids
			if comboCancelActionIdBlackListMap.has(aid):
				continue
			autoCancelActionIds.append(aid)
	
	#go through all the actions that are autocancelable, and get the  commands that are input to 
	#create/play those actions
	for actionId in autoCancelActionIds:
		#var cmd = actionAnimeManager.getCommand(actionId)
		
		#don't include null commands or duplicates in results
		if not duplicateLookup.has(actionId):
			
			#only add the action id if it isn't in the blacklist of the current entry
			if not actionAnimeManager._isAutoCancelableHelper(actionId,currMoveSelected.autoCancelBlackList,currMoveSelected.autoCancelBlackList2):
			
				res.append(actionId)
			
				#sotre in lookup map to avoid duplicates
				duplicateLookup[actionId] = null
			
	return res
	


func isTypeBlacklisted(blackListBitMap,autoCancelType):
	
		#export (int, FLAGS, "Basic","On-hit", "on-hit auto ability cancel", "landing lag", "on-hit landing lag") var autoCancelsTypeBlackList = 0
	if autoCancelType != null and autoCancelBlackListMaskMap.has(autoCancelType):
		var mask = autoCancelBlackListMaskMap[autoCancelType]
		return ((mask & blackListBitMap) == mask)
		
	
	return false
	
func _on_inactive_projectile_instanced(projectile,projectileScenePath):
	#connect("done_loading_game",projectile,"_on_done_loading_game")
	projectileMap[projectileScenePath]=projectile
	
	pass