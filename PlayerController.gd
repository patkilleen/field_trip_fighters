extends Node

signal start_damage_gauge_generation_tracking
signal start_focus_generation_tracking
signal ripost
signal ripost_attempted
signal about_to_attempt_ripost
signal counter_ripost_attempted
signal cmd_action_changed
signal insufficient_ability_bar
signal pause
signal clear_red_hp
signal cmd_attack_hit
signal jumped
signal landed
signal start_hitfreeze
signal stop_hitfreeze
signal tech
signal failed_tech
signal ability_cancel
signal grabbed_in_block
signal display_red_hp
signal ability_bar_cancel_cost_display
signal ability_bar_cancel_cost_hide
signal feeding_ability_bar
signal starting_new_combo
signal attack_type_hit
signal base_damage_taken
signal cmd_inputed
signal cmd_inputed_post_buffer
signal userInputEnabledChange
signal landing_pushaway_changed
signal attack_hit
signal budget_blocked
#signal started_back_crouch
signal create_anchor_point
signal destroy_anchor_point
signal display_attack_lighting
signal create_projectile
signal entered_block_hitstun
signal exited_block_stun
signal counter_hit
signal punish
signal air_dashed
signal ground_dashed
signal ground_dash_cancel
signal pre_block_hitstun
signal reversal
signal clash
signal clash_break
signal block_stun_string
signal auto_ripost
signal combo_level_up
signal reverse_beat_combo_level_up
signal fill_combo
signal push_blocked
signal auto_ripost_attempted
signal damage_taken
signal combo_ended
signal start_tracking_frame_duration
signal hit_armored_opponent 
signal player_state_info_text_changed
signal pre_ability_bar_gain
signal ability_bar_gain_finished
signal hit_invincibility_opponent
signal being_attacked
signal debug_follow_mvm_started
signal display_block_sfx
signal about_to_be_applied_hitstun
signal false_ceiling_lock
signal false_wall_lock
signal false_ceiling_unlock
signal false_wall_unlock
signal entered_oki
signal entered_invincible_oki
signal inactive_projectile_instanced
signal hitstun_proration_mod_applied
signal incorrect_block_unblockable
signal grabbed_auto_riposter
signal reached_half_hp
signal guard_regen_buffed_enabled
signal parry

const BLOCK_DAMAGE_RESISTANCE_MOD = 0.2
const CANCEL_SUCCESS_RC = 0
const CANCEL_FAILED_NOT_ENOUGH_BAR_RC = 1
const CANCEL_FAILED_FRAME_UNCANCELABLE_RC = 2
const CANCEL_FAILED_PAUSED_RC = 3

const MAGIC_SERIES_COMBO_LEVEL_IX = 0
const REVERSE_BEAT_COMBO_LEVEL_IX = 1
const COMBO_TYPE_A = 0
const COMBO_TYPE_B = 1
const COMBO_TYPE_C = 2

const COMMON_SOUND_SFX = 0
const HERO_SOUND_SFX = 1
		
const NEUTRAL_RIPOST_PRORATION_SETBACK_NUMBER_HITS = 4 #first 4 hits don't affect proration when riposting in neutral

#getting hit shake
const DEFAULT_MIN_HIT_SHAKE_TRAUMA=0
#const DEFAULT_MAX_HIT_SHAKE_TRAUMA=0.8
const DEFAULT_MAX_HIT_SHAKE_TRAUMA=1
const DEFAULT_HIT_SHAKE_DECAY=1.5
const DEFAULT_MIN_HIT_SHAKE_OFFSET=2
#const DEFAULT_MAX_HIT_SHAKE_OFFSET=20
const DEFAULT_MAX_HIT_SHAKE_OFFSET=23
const DEFAULT_HIT_SHAKE_TRAUMA_POWER=2

#hitting hit shake
const DEFAULT_HITTING_MIN_HIT_SHAKE_TRAUMA=0
const DEFAULT_HITTING_MAX_HIT_SHAKE_TRAUMA=0.8
const DEFAULT_HITTING_HIT_SHAKE_DECAY=0.8
const DEFAULT_HITTING_MIN_HIT_SHAKE_OFFSET=2
const DEFAULT_HITTING_MAX_HIT_SHAKE_OFFSET=10
const DEFAULT_HITTING_HIT_SHAKE_TRAUMA_POWER=2


const BASIC_ABILITY_CANCEL_COST=1

const GET_HIT_SCREAM_FREQUENCY = 3

const END_MATCH_LOSER_STUN_DURATION = 60 * 100#100 seconds. this assumes the game end fadoute out lasts not that long (a fair asumption)
const AUTO_RIPOST_ON_HIT_SOUND_ID = 0
const DAMAGE_THRESHOLD_EXCEEDED_SOUND_ID = 2
const ATTACK_CLASH_SOUND_ID = 3
const RIPOST_SOUND_ID = 5
const COMBO_LEVEL_UP_SOUND_ID = 19
const GUARD_BROKEN_SOUND_ID= 7
const ABILITY_SOUND_ID = 8
const AIR_DASH_SOUND_ID = 11
const COUNTER_RIPOST_SOUND_ID = 12
const CORRECT_BLOCK_SOUND_ID = 13
const FAILED_RIPOST_SOUND_ID = 14
const MELEE_HIT_SOUND_ID = 15
const SPECIAL_HIT_SOUND_ID = 16
const TOOL_HIT_SOUND_ID = 17
const AUTO_ABILITY_CANCEL_SOUND_ID = 25
const LAND_SOUND_ID = 20
const NO_MORE_BAR_SOUND_ID = 21
const GROUND_DASH_CANCEL_SOUND_ID = 23
const PUSH_BLOCK_SOUND_ID = 24
const PERFECT_BLOCK_SOUND_ID = 26
const INCORRECT_BLOCK_SOUND_ID = 27
const BASIC_ABILITY_CANCEL_SOUND_ID = 28

#TO BE ASSIGNED BY SUBCLASS
var HERO_HITSTUN_STUN_SOUND_ID = null
var HERO_RIPOST_SOUND_ID = null
var HERO_COUNTER_RIPOST_SOUND_ID = null
var HERO_INCORRECT_BLOCK_SOUND_ID = null
#const FILL_DMG_STAR_COMBO_SOUND_ID = 32


const DASH_ABILITY_CANCEL_INPUT_RESTRICTION_DURATION = 15 #15 frames can't wal forward/back depending on dash cancel type

#TODO: move below 2 consts to settings
const FAIL_RIPOST_DMG_AMOUNT_INCREASE_FRACTION = 1.0/3.0
const FAIL_RIPOST_FOCUS_AMOUNT_INCREASE_FRACTION = 1.0/5.0

const BROKEN_GUARD_STUN_DURATION = 80
const FAILED_NEUTRAL_RIPOST_STUN_DURATION = 70
const FAILED_COUNTER_RIPOST_STUN_DURATION = 70 #make it super long to prevent option selecting covering ripost on all hitboxes with a multi hit projectile


const COUNTER_RIPOST_DAMAGE_MULTIPLIER = 3 #do triple damage that ripost would normally do

#HIT FREEZE TIMES
const PROJECTILE_CLASH_HIT_FREEZE_DURATION= 9
const CLASH_HIT_FREEZE_DURATION = 20
const CLASH_BREAK_HIT_FREEZE_DURATION = 15
const HTTING_AUTO_RIPOST_OPPONENT_HIT_FREEZE_DURATION = 15
const GUARD_BREAK_HIT_FREEZE_DURATION = 15
const PUSH_BLOCK_HIT_FREEZE_DURATION = 2
const TECH_HIT_FREEZE_DURATION = 15
const FAILED_RIPOST_HIT_FREEZE_DURATION =15


const CLASH_BREAK_RECOVERY_DURATION = 3
const CLASH_BREAK_VICTIM_RECOVERY_DURATION = 20 #puts attacker at + 17 against the clash break

const PROJECTILE_CLASH_RECOVERY_DURATION = 10

#PUSH_BLOCK_INPUT_INITIAL_LOCKOUT_DURATION ISN'T USED, old code
const PUSH_BLOCK_INPUT_INITIAL_LOCKOUT_DURATION=PUSH_BLOCK_HIT_FREEZE_DURATION+3 #10 frames of no action can be done by person getting pushblocke (after 10 frames, can autocancel like dash)
const PUSH_BLOCK_INPUT_RESTRICTION_DURATION=PUSH_BLOCK_HIT_FREEZE_DURATION+3# 20 - 10 means 10 frames where restricted on input (dashes/jumps only)


const COMBO_TYPE_ALL = 0
const COMBO_TYPE_NORMAL = 1
const COMBO_TYPE_ON_HIT_ONLY = 2
const COMBO_TYPE_ENTIRE_ANIMATION= 3


const COUNTER_HIT_DMG_MOD = 1.1 #10 % more damage for counter hits
const PLAYER_CENTER_INSIDE_PLAYER_DIST_THRESHOLD = 10 #10 should be fine, since body boxy hieght is liek 20-40

const GLOBAL_HIT_STUN_MOD = 1 #times more hitstun for all moves (1.65 was alpha temporary bandaid)
#const GLOBAL_HIT_STUN_MOD = 1

var frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")
var GLOBALS = preload("res://Globals.gd")
var hurtboxAreaResource = preload("res://HurtboxArea.gd")

#const colorOutlinerShader = preload("res://interface/shaders/color-outline.shader")

var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

var grabCooldownTimer = null 
var inputManager = null
var collisionHandler = null
var comboHandler = null
var playerState = null
var ripostHandler = null
#var ripostCounterHandler = null
var newCounterRipostHandler = null
var actionAnimeManager = null
var kinbody = null
var opponentPlayerController = null setget setOpponentPlayerController,getOpponentPlayerController
var floorDetector = null
var highDamageParticles = null
var damageIncParticles = null
var damageDecParticles = null
var comboLevelParticles = null
var antiBlockParticles = null
var techHandler = null
#sound players for special effects
var hittingSFXPlayer = null
var commonSFXSoundPlayer = null
var heroSFXSoundPlayer = null
var ripostHitstunMovementAnimation = null

var blockCooldownTimer = null

var antiBlockHitstunMovementAnimation = null
var guardHandler = null
var grabHandler = null
var inputLockHandler = null
var abilityBarGainLockHandler = null

#attributes that will have their values overwritten by kinematic body 2d (abstract player) module before game start
var ripostDamage = null
var damageGaugeFailedRipostModIncrease = null
var focusFailedRipostModIncrease = null

var acroABCancelExtraJumpBarCost = null

var damageGaugeComboLevelUpModIncrease = null
var damageGaugeRateMode = null
var focusRateMode = null
var focusComboLevelUpModIncrease = null
var ripostHitstunDuration = null
var ripostingAbilityBarRegenMod = null
var blockCooldownTime = null #seconds it will be down

var failedBlockDamageDecrease = null
var reboundingDamageThreshold = null
var minimumNumberReboundFrames = null
var reboundFramesMod = null
var maxNumReboundFramesSameDmg = null
var highDamageThreshold = null

var antiBlockHitstunDuration=null
#var antiBlockDamage = null
var successfulAntiBlockDmg = null
var failedBlockDamageCapacityDecrease = null
var failedBlockFocusDecrease = null
var failedBlockFocusCapacityDecrease = null
var ripostHitFreeze = null
var failedTechAbilityBarCost = null
var maxNumberWallBounces = null
var leftPlatformDetector = null
var rightPlatformDetector = null
var insideOpponentDetector=  null
var leftOpponentDetector = null
var rightOpponentDetector = null
var leftWallDetector = null
var rightWallDetector = null 
var leftCornerDetector = null
var rightCornerDetector = null
var hittingLeftWallDetector = null
var hittingRightWallDetector = null
var disableBodyBoxLeftWallDetector = null
var disableBodyBoxRightWallDetector = null
var heroName = null
var onRipostingDmgIncreaseRatio =null
var onRipostingBarReduceAmount = null

var guardHpLossRate = null
var halfHPAbilityIncreaseThreshold = null
var loseGuardHPWhileWalkingBack = null
var gainBarOnGuardBreak=null
var numBarChunksGainedFromGuardBreak=null
#var airDashSpeedMod =null
#var jumpSpeedMod = null
#var groundDashSpeedMod =null
var additionalDamagePerStar = null

var gameEndingStun = false

#the sprite animation id of the last attack was hit by durying a combo
var lastHitBySpriteAnimeId = null

var wasInInvincibleOki=false
			

var faildRipostBarGainLockTimeSecs = null
var faildRipostBarGainLockNumHits =null

var guardBrokeThisFrame = false

var defaultGuardDamageDealtModVsAirOpponent=null

#BEGIN PROFICIENCY properties
var canLowBlowInAir=false #ProficiencyPropertyID.GOOD_CAN_LOW_BLOCK_IN_AIR
var regenGuardInAir = false #ProficiencyPropertyID.GOOD_REGENERATE_GUARD_IN_AIR
var numJumpsGainedFromAbCancel = 0#ProficiencyPropertyID.GOOD_GAIN_JUMP_FROM_ABILITY_CANCEL
var recoverAirDashOnAirBlock=false#ProficiencyPropertyID.GOOD_RECOVER_AIR_DASH_ON_BLOCK
var loseJumpAndAirDashOnAirBlock=false#ProficiencyPropertyID.BAD_LOSE_AIR_DASH_AND_JUMP_ON_BLOCK
var recoverAirDashOnHit = false #ProficiencyPropertyID.GOOD_RECOVER_AIR_DASH_ON_HIT
var recoverAirDashAndJumpOnAirTech=false#ProficiencyPropertyID.GOOD_RECOVER_AIR_DASH_AND_JUMP_ON_TECH
var regenAbilityBarOnPerfectBlock = false#ProficiencyPropertyID.GOOD_PERFECT_BLOCK_ABILITY_BAR_REGEN
var barChunksGainedOnGrabbingAutoriposter = 0 #ProficiencyPropertyID.GOOD_SMALL_BAR_GAIN_BY_GRABBING_AUTORIPOSTER,GOOD_MEDIUM_BAR_GAIN_BY_GRABBING_AUTORIPOSTER,GOOD_LARGE_BAR_GAIN_BY_GRABBING_AUTORIPOSTER
var whiffedGrabProvokesCooldown= false#ProficiencyPropertyID.BAD_GRAB_WHIF_PROVOKES_COOLDOWN
var airAbilityCancelCostInChunksTax=0#ProficiencyPropertyID.BAD_SMALL_AIR_ANIMATION_AND_LANDING_LAG_CANCEL_COST_INCREASE,BAD_MEDIUM_AIR_ANIMATION_AND_LANDING_LAG_CANCEL_COST_INCREASE,BAD_LARGE_AIR_ANIMATION_AND_LANDING_LAG_CANCEL_COST_INCREASE,
var preventAirDashing=false#ProficiencyPropertyID.BAD_NO_AIR_DASHING
var recoverAirDashOnJump = true #ProficiencyPropertyID.BAD_DONT_RECOVER_AIR_DASH_FROM_JUMPING
var preventDITech = false #ProficiencyPropertyID.BAD_CANT_DI_TECH
#var tripleDmgVulnInStun = false#ProficiencyPropertyID.BAD_TAKE_TRIPLE_DAMAGE_IN_STUN,
var preventGrabInAir= false#ProficiencyPropertyID.BAD_CANT_GRAB_WHILE_IN_AIR
var preventAbilityCancelStaleMoveReset=false#ProficiencyPropertyID.BAD_ABILITY_CANCELING_NO_RESET_STALE_MOVES
var additionalBarGainFromBreakingGuard = 0#ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_BAR_GAIN_FROM_GUARD_BREAK,
var additionalBarFeedFromGettingGuardBroken = 0#ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_BAR_FEED_FROM_GUARD_BREAK,
var autoRipostAbilityBarCost = null # a default value will be set and then mod will be appliedProficiencyPropertyID.BAD_LARGE_INCREASE_TO_AUTO_RIPOSTE_COST
var autoAbilityCancelBaseCost = null  # a default value will be set and then mod will be appliedProficiencyPropertyID.BAD_SMALL_INCREASE_TO_AUTO_ABILITY_CANCEL_COST
var correctBlockGuardDamageDealtMod = 0#ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_GUARD_DAMAGE_DEALT,BAD_SMALL_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT
var correctBlockGuardDamageTakenMod = 0#ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_GUARD_DAMAGE_TAKEN,BAD_SMALL_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN,
var incorrectBlockGuardDamageDealtMod = 0#ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_GUARD_DAMAGE_DEALT,BAD_SMALL_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT
var incorrectBlockGuardDamageTakenMod = 0#ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_GUARD_DAMAGE_TAKEN,BAD_SMALL_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN
var airBlockGuardDamageDealtMod=0#ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT
var airBlockGuardDamageTakenMod=0#ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR
var blockChipDamageDealtMod=0#ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_BLOCK_CHIP_DAMAGE_DEALT
var blockChipDamageTakenMod=0#ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN
var guardHpRegenRate = null #a default value will be set and then mod will be applied  ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_GUARD_REGEN_RATE
var numAbChunksGainOnComboLvl = null #a default value will be set and then mod will be applied  ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES
var ripostingAbilityBarCost = null #a default value will be set and then mod will be applied  ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_RIPOST_COST
var counterRipostingAbilityBarCost =null#a default value will be set and then mod will be applied  ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_COUNTERRIPOST_COST
var techAbilityBarCost = null #a default value will be set and then mod will be applied  ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_TECH_COST
var pushBlockCost = null #a default value will be set and then mod will be applied  ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_PUSH_BLOCK_COST
#comboHandler.var profAbilityBarComboProrationMod a default value will be set and then mod will be applied  ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK
#playerState.profAbilityBarCostMod  a default value will be set and then mod will be applied ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_ABILITY_CANCEL_COST
var grabCooldownTime = null #a default value will be set and then mod will be applied ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_GRAB_COOLDOWN
var additionalNumChunksGainMagicSeriesInAir = 0 #ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR
var numChunksLostOnMisssedAutoRiposte = 0 #ProficiencyPropertyID.BAD_SMALL_BAR_COST_FROM_MISSING_AUTORIPOSTE
var recoverGrabOnAutoAbilityCancel = false#ProficiencyPropertyID.GOOD_GRAB_COOLDOWN_REFRESHED_ON_AUTO_ABILITY_CANCEL
var recoverGrabOnAbilityCancel = false#ProficiencyPropertyID.GOOD_GRAB_COOLDOWN_REFRESHED_ON_ABILITY_CANCEL
var recoverJumpOnAirBlock = true #BAD_LOSE_AIR_DASH_AND_JUMP_ON_BLOCK
var additionalCooldownToAirGrab = 0#BAD_SMALL_INCREASE_COOLDOWN_TO_AIR_GRAB
var preventGroundDashing = false
var preventBlockingGroundAttacksWhileAirborne = false
var preventIncorrectBlocking = false
var boostedBuffGuardRegenMod=null
var autoRipostGuardRegenBuffFillAmount=null
var takeEnormousBlockChipDamage = false
var enormousBlockChipDamageMod = null
var counterRipostStealsBar = false
var cantAutoRipost = false
var cantGrab = false
var cantGainBarFromMagicSeries = false
var abilityCancelOnHitOnly = false
var preventAutoTurnAroundInAir = false
var preventPushBlock = false
#END PROFICIENCY properties
#end set by parent kin body

var autoRipostGuardRegenBuffDuration = null #compute from guard max hp and autoRipostGuardRegenBuffFillAmount
			


#set by collision handler, used to determine where/when to push opponent upon landing on them
var inCornerStatus = GLOBALS.OnOpponentStatus.NOT_AGAINST_WALL

#var inHitstun = false
#var playerPaused = false
#var currentNumJumps = 2
#var numJumps = 2
#var wasInAir = true
#var blocked = false
#two attacks that have damage of at most a 'reboundingDamageThreshold'  difference
#can classh (both players go into rebound). outisdde this, the higher damage move wins
#and doesn't go into rebound

#export (float) var reboundingDamageThreshold = 15


var numFailedCounterRipostInCombo=0
var numFailedCounterRipostNumThershold=3 #on 3rd fail counter ripost, oppoent breaks from hitstun
	


var onLeftPlatformCallFlag = false
var onLeftGroundCallFlag = false

var restartDelayTimer = null

var commandBuffer = []

#flag used to indicate if riposting this frame (used to handle riposting same frame as opponent)
var riposting = false
var counterRiposting = false
var counterRipostingFinished = false


var tmpDisplayRedHPFlag = false

var blockStunAirRecoveryDuration = -1

var halfHpValue =-1
var wallBounces = 0
var wallBounceConssumedFlag = false

#higher will mean more lag. minimum 1
const MAX_LANDING_LAG_MOD = 1


const OKI_INVINCIBILITY_TRANSPARANCY = 0.6
#this flag is false when we havne' tcacneled, and is true when we are cancelign
var isBarCanceling = false

#2d array for looking up combo level up attack types: ix 0 (damage), ix 1 (focus)
var comboLevelUpString = []

var ignoreUserInputFlag = true


var muteSoundSFX=true
var canPauseFlag = false

#flagged used to indicate we are standing on opponent
var isOnOpponent = false

var enableParticles = true

#used for budget block in hit lag (true when player holding down backward crouch, or backward)
var holdingBackward = false
var holdingForward = false

#true means null commands stops walking, and false means you keep walking (used by ai agent)
#var nullCommandStopsWalkingFlag = true

var complexMvmInstance = null

var playerOnPlatformEdge = false

var bodyBoxCollisionEnabledFlag = true

var pushBlockMvmAnimation = null

var globalPushingOpponentFlag = false


var cachedResourcesNode = null
#var guardBrokenRipostLock = false

#var proximityGuardEnabled = false
var frame_analyzer = null

var abilityCancelLightTimer = null

var abilityCancelLightDuratinInFrames = 25 #10 frames of blue glow on ablility cancel

#flag to indicate if an animation that supports reversals has finished (oki, hitstun, rebound, stunned, block stun)
var reversableAnimationFinished = false

var skipHandleInputThisFrame=false #used to indicate to the physics process loop to not process user input this round

var pauseOnHitFreezeEndEnabled =false

var handleUserInputCallLock = false

var inHitFreezeFlag =false
var wasInHitFreezeThisFrame=false

var defaultSpriteModulate = null
var autoActiveFramesAbilityCancelFlag = false

var pushBlockActionWhiteListMask1 = 0
var pushBlockActionWhiteListMask2 = 0

var animationFramesRemaining = 0

var negativePenaltyTracker = null

var occupyingLeftCorner = false
var occupyingRightCorner = false

var hitstunTimer = null

var enableSlidingGroundIdle=false

var guardRegenBoostBuffTimer = null
var blockMvmStopTimer =null #timer to keep track of consistent knockback in block stun

var dashABCancelPreventingMvmInput = false

var commonSFXSoundDefaultVolume = null
var heroSFXSoundDefaultVolume=null

var ripostVoicelineVolumeOffset=0
var counterRipostVoicelineVolumeOffset=0
var badBlockVoicelineVolumeOffset=0
var gettingHitVoicelineVolumeOffset=0
#ProficiencyPropertyID.GOOD_REGENERATE_GUARD_IN_AIR
func _ready():
	set_physics_process(false)
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	
	
	pass
	
func reset():	
	inCornerStatus = GLOBALS.OnOpponentStatus.NOT_AGAINST_WALL
	#set_physics_process(false)
	
	if grabCooldownTimer != null:
		grabCooldownTimer.reset()
		#grabCooldownTimer.stop()
		
		#grabCooldownTimer.reset()
	
	if hitstunTimer!= null:
		#hitstunTimer.stop()
		#hitstunTimer.reset()
		hitstunTimer.reset()
		
	if guardRegenBoostBuffTimer != null:
		guardRegenBoostBuffTimer.reset()
		#guardRegenBoostBuffTimer.stop()
		#guardRegenBoostBuffTimer.reset()
	
	if blockMvmStopTimer != null:
		blockMvmStopTimer.reset()

	gameEndingStun = false

	#the sprite animation id of the last attack was hit by durying a combo
	lastHitBySpriteAnimeId = null

	
	numFailedCounterRipostInCombo=0
	numFailedCounterRipostNumThershold=3 #on 3rd fail counter ripost, oppoent breaks from hitstun
	
	if abilityBarGainLockHandler != null:
		abilityBarGainLockHandler.reset()
	
	if inputLockHandler != null:
		inputLockHandler.reset()
	if grabHandler != null:	
		grabHandler.reset()
	if techHandler!= null:
		techHandler.reset()
	if comboHandler!= null:
		comboHandler.reset()
	if ripostHandler != null:	
		ripostHandler.reset()
	if newCounterRipostHandler != null:
		newCounterRipostHandler.reset()
	
	if collisionHandler!=null:
		collisionHandler.init()
	if guardHandler != null:
		guardHandler.reset()		
	if actionAnimeManager != null:
		actionAnimeManager.reset()
		
	
	
	onLeftPlatformCallFlag = false
	onLeftGroundCallFlag = false
	commandBuffer = []
	riposting = false
	counterRiposting = false
	counterRipostingFinished = false


	tmpDisplayRedHPFlag = false

	blockStunAirRecoveryDuration = -1

	wallBounces = 0
	wallBounceConssumedFlag = false	
	isBarCanceling = false
	muteSoundSFX=true
	canPauseFlag = false
	isOnOpponent = false
	holdingBackward = false
	holdingForward = false

	playerOnPlatformEdge = false

	bodyBoxCollisionEnabledFlag = true

	globalPushingOpponentFlag = false

	reversableAnimationFinished = false

	skipHandleInputThisFrame=false

	pauseOnHitFreezeEndEnabled =false

	handleUserInputCallLock = false

	inHitFreezeFlag =false
	wasInHitFreezeThisFrame=false

	autoActiveFramesAbilityCancelFlag = false

	animationFramesRemaining = 0

	occupyingLeftCorner = false
	occupyingRightCorner = false

	enableSlidingGroundIdle=false

func init(sprite,collisionAreas,attackSFXs,bodyBox,activeNodes):
	
	abilityCancelLightTimer = frameTimerResource.new()
	self.add_child(abilityCancelLightTimer)
	
	
	hitstunTimer =  frameTimerResource.new()
	self.add_child(hitstunTimer)
	hitstunTimer.connect("timeout",self,"_on_hitstun_duration_expired")


	#blockMvmStopTimer = frameTimerResource.new()
	#self.add_child(blockMvmStopTimer)
	
#	blockMvmStopTimer.connect("timeout",self,"_on_block_momentum_expired")
	
	cachedResourcesNode = kinbody.get_node("cachedResources")
	
	guardRegenBoostBuffTimer =  frameTimerResource.new()
	self.add_child(guardRegenBoostBuffTimer)


	abilityCancelLightTimer.connect("timeout",self,"_on_ability_cancel_light_timer_timeout")

	var complexMvmResource =  preload("res://complexMovement.gd")
	complexMvmInstance = complexMvmResource.new()
	#proximityGuardEnabled = false
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	restartDelayTimer = preload("res://frameTimer.gd").new()
	add_child(restartDelayTimer)
	
	autoActiveFramesAbilityCancelFlag = false
	#initialize the attack combo level type looksups
	comboLevelUpString = []
	var magicSeriesComboLevelString = [GLOBALS.MELEE_IX,GLOBALS.SPECIAL_IX,GLOBALS.TOOL_IX]
	var reverseBeatSeriesComboLevelString = [GLOBALS.TOOL_IX,GLOBALS.SPECIAL_IX,GLOBALS.MELEE_IX]
	#var focusComboLevelString = [GLOBALS.TOOL_IX,GLOBALS.SPECIAL_IX,GLOBALS.MELEE_IX]
	comboLevelUpString.append(magicSeriesComboLevelString)
	comboLevelUpString.append(reverseBeatSeriesComboLevelString)
	#comboLevelUpString.append(focusComboLevelString)
	
	actionAnimeManager = $ActionAnimationManager
	actionAnimeManager.init(self)
	
	
	pushBlockActionWhiteListMask1=actionAnimeManager.computePushBlockActionIdWhiteListMask1()
	pushBlockActionWhiteListMask2=actionAnimeManager.computePushBlockActionIdWhiteListMask2()
	
	#actionAnimeManager.setDashingSpeed(airDashSpeedMod,groundDashSpeedMod)
	#actionAnimeManager.setJumpSpeed(jumpSpeedMod)
	
	actionAnimeManager.spriteAnimationManager.init(sprite,collisionAreas,bodyBox,activeNodes,self,self.kinbody)
	
	#actionAnimeManager.connect("start_tracking_frame_duration",self,"_on_start_tracking_frame_duration")
	
	
	
	#guardBrokenRipostLock = false
	
	inputManager = $InputManager
	inputManager.init(false) #don't process input by default
	
	inputManager.connect("controller_disconnected",self,"_on_controller_disconnected")
	
	defaultSpriteModulate = kinbody.activeNodeSprite.modulate
	
	
	collisionHandler = $CollisionHandler
	
	ripostHandler = $RipostHandler
	playerState = $PlayerState
	#ripostCounterHandler = $RipostCounterHandler
	newCounterRipostHandler= $NewCounterRipostHandler
	antiBlockHitstunMovementAnimation  = $"anti-block-hitstun"
	hittingSFXPlayer = $defaultHittingSFXPlayer
	commonSFXSoundPlayer = $commonSFXSounds
	
	ripostHandler.init()
	newCounterRipostHandler.init(self)
	
	heroSFXSoundPlayer = $heroSFXSounds	
	heroSFXSoundPlayer.init(heroName)
	
	commonSFXSoundDefaultVolume=commonSFXSoundPlayer.volume_db
	heroSFXSoundDefaultVolume =heroSFXSoundPlayer.volume_db
	
	techHandler= $TechHandler
	
	
	techHandler.init(actionAnimeManager)
	
	frame_analyzer = $frame_analyzer
	negativePenaltyTracker = $negativePenaltyTracker
	negativePenaltyTracker.init(self)
	
	
	comboHandler = $ComboHandler
	guardHandler = $guardHandler
	grabHandler = $grabHandler
	
	abilityBarGainLockHandler = $abilityBarLockHandler
	abilityBarGainLockHandler.connect("ability_gain_lock_changed",playerState,"setAbilityBarGainLocked")
	
	abilityBarGainLockHandler.init(self)
	
	
	#guardHandler.connect("perfect_block",self,"_on_perfect_block")
	
	inputLockHandler = $inputLockHandler
	inputLockHandler.init(actionAnimeManager)
	
	inputLockHandler.connect("input_restriction_timeout",self,"_on_input_restriction_timeout")
	guardHandler.connect("guard_broken",self,"_on_guard_broken")
	
	#guar handler will stop/start guard boost by changing player state
	playerState.connect("guard_regen_buff_flag_changed",guardHandler,"_on_guard_regen_boost_change")
	
	#when the timer timesout, the guard regen boost buff stops
	guardRegenBoostBuffTimer.connect("timeout",playerState,"setGuardRegenBuffEnabled",[false])
	
	self.connect("entered_invincible_oki",self,"_on_entered_invincible_oki")
	
	self.connect("reached_half_hp",self,"_on_half_hp_reached")
	
	#guardHandler.connect("proximity_guard_enabled",self,"_on_proximity_guard_enabled")
	#guardHandler.connect("proximity_guard_disabled",self,"_on_proximity_guard_disabled")
	#self.connect("budget_blocked",guardHandler,"_on_budget_block")
	collisionHandler.connect("hitting_player",guardHandler,"_on_hitting_player")
	collisionHandler.connect("exited_left_corner",self,"_on_exited_left_corner")
	collisionHandler.connect("exited_right_corner",self,"_on_exited_right_corner")
	collisionHandler.connect("entered_left_corner",self,"_on_entered_left_corner")
	collisionHandler.connect("entered_right_corner",self,"_on_entered_right_corner")

	collisionHandler.connect("entered_opponent_body_box",self,"_on_entered_opponent_body_box")
	collisionHandler.connect("exited_opponent_body_box",self,"_on_exited_opponent_body_box")

	
	#this signal connection makes it so can't buffer ripost input outstide hitstun 
	playerState.connect("changed_in_hitstun",inputManager,"setBufferingRipostInputFlag")
	playerState.connect("fill_combo_sub_level_changed",comboHandler,"_on_fill_combo_sub_level_changed")
	
	#hitFreezeTimer = $hitFreezeTimer
	
	#hitFreezeTimer.connect("hit_freeze_finished",self,"_on_hit_freeze_finished")
	
	self.connect("ability_cancel",self, "_on_ability_cancel")
	self.connect("ability_cancel",playerState, "_on_ability_cancel")
	self.connect("failed_tech",playerState,"_on_tech",[true])
	self.connect("tech",playerState,"_on_tech",[false])
	self.connect("entered_block_hitstun",playerState,"_on_entered_block_hitstun")
	
	
	self.connect("ground_dashed",self,"_on_ground_dashed")
	self.connect("insufficient_ability_bar",self,"_on_insufficient_ability_bar")
	guardHandler.connect("guard_broken",playerState,"_on_guard_broken")
	
	self.connect("cmd_action_changed",negativePenaltyTracker,"_on_command_actioned")
	
	techHandler.connect("failed_tech",self,"_on_failed_tech")
	techHandler.connect("successful_tech",self,"_on_successful_tech")
	techHandler.connect("tech_window_lock_expired",self,"_on_tech_window_lock_expired")
	actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",techHandler,"_on_sprite_animation_played")
	
	#collision handler will deal with this, don't worry
	#actionAnimeManager.movementAnimationManager.connect("wall_collision",techHandler,"_on_wall_collision")
	#actionAnimeManager.movementAnimationManager.connect("wall_collision",self,"_on_wall_collision")
	#pushed_against_wall
	
	#actionAnimeManager.movementAnimationManager.connect("ceiling_collision",techHandler,"_on_ceiling_collision")
	actionAnimeManager.movementAnimationManager.connect("moved_kinematic_body",self,"_on_moved_kinematic_body")
	
	self.connect("landing_pushaway_changed",actionAnimeManager.movementAnimationManager,"_on_landing_pushaway_changed")
	
	self.connect("entered_block_hitstun",self,"_on_entered_block_hitstun")
	
	actionAnimeManager.connect("action_animation_finished",self,"_on_action_animation_finished")
	
	actionAnimeManager.connect("action_animation_finished",grabHandler,"_on_action_animation_finished")
	
	
	actionAnimeManager.connect("multi_tap_action_animation_partially_finished",self,"_on_multi_tap_action_animation_partially_finished")
	actionAnimeManager.connect("request_play_sound",self,"_on_request_play_special_sound")
	#actionAnimeManager.connect("disabled_body_box",self,"_on_disabled_body_box")
	
	
	
	actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_sprite_animation_played")
	actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",grabHandler,"_on_sprite_animation_played")
	actionAnimeManager.connect("create_projectile",self,"_on_create_projectile")
	
	#old signal. instead fall fall input to go trhough platform
	#actionAnimeManager.spriteAnimationManager.connect("platform_drop",self,"_on_platform_drop")
	
	actionAnimeManager.spriteAnimationManager.connect("pushable_frame_flag",actionAnimeManager.movementAnimationManager,"setPushableFlag")
	actionAnimeManager.spriteAnimationManager.connect("canPush_frame_flag",actionAnimeManager.movementAnimationManager,"setCanPushFlag")
	
	actionAnimeManager.spriteAnimationManager.connect("disabled_body_box",self,"disablePlayerBodyCollision")
	actionAnimeManager.spriteAnimationManager.connect("enabled_body_box",self,"enablePlayerBodyCollision")
	
	actionAnimeManager.spriteAnimationManager.connect("sprite_frame_activated",guardHandler,"_on_sprite_frame_activated")
	actionAnimeManager.spriteAnimationManager.connect("sprite_frame_activated",self,"_on_sprite_frame_activated")
	
	actionAnimeManager.movementAnimationManager.connect("reached_vertical_momentum_apex",self,"_on_reached_vertical_momentum_apex")
	actionAnimeManager.movementAnimationManager.connect("bumped_into_something",self,"_on_bumped_into_something")
	
	#actionAnimeManager.movementAnimationManager.connect("reached_vertical_momentum_apex",self,"_on_reached_vertical_momentum_apex")
	
	collisionHandler.connect("hitting_player",actionAnimeManager.movementAnimationManager,"_on_hitting_player")
	
	#make sure the air histun is aware when reached apex of jump
	var airhitStun = actionAnimeManager.spriteAnimationLookup(actionAnimeManager.AIR_HITSTUN_ACTION_ID)
	actionAnimeManager.movementAnimationManager.connect("reached_vertical_momentum_apex",airhitStun,"_on_reached_vertical_momentum_apex")

		
	
	collisionHandler.connect("pushed_against_wall",actionAnimeManager.movementAnimationManager,"_on_hit_wall")
	collisionHandler.connect("pushed_against_ceiling",actionAnimeManager.movementAnimationManager,"_on_hit_ceiling")
	collisionHandler.connect("landing_on_ground",actionAnimeManager.movementAnimationManager,"_on_hit_floor")
	collisionHandler.connect("landing_on_platform",actionAnimeManager.movementAnimationManager,"_on_hit_platform")
	
	kinbody.insidePlayerArea.connect("body_entered",collisionHandler,"_on_entered_opponents_body_box")
	kinbody.insidePlayerArea.connect("body_exited",collisionHandler,"_on_exited_opponents_body_box")
	
	#collisionHandler.connect("entered_disabled_body_box_wall_area",self,"_on_entered_disabled_body_box_wall_area")
	#collisionHandler.connect("exited_disabled_body_box_wall_area",self,"_on_exited_disabled_body_box_wall_area")
	
	
	playerState.connect("num_filled_dmg_stars_changed",self,"_on_num_filled_dmg_stars_changed")
	
	self.connect("fill_combo",playerState,"count_num_star_completion_combos")
	self.connect("auto_ripost",playerState,"_on_auto_successful_ripost")
	self.connect("auto_ripost_attempted",playerState,"_on_auto_ripost_attempted")
	self.connect("combo_ended",playerState,"_on_combo_ended")
	
	
	
	playerState.connect("damage_gauge_changed",self,"_on_damage_bar_changed")
	playerState.connect("damage_gauge_capacity_changed",self,"_on_damage_gauge_capacity_changed")
	playerState.connect("hp_changed",self,"_on_hp_changed")
	
	playerState.connect("combo_level_changed",self,"_on_combo_level_changed")
	playerState.connect("num_empty_dmg_stars_changed",self,"_on_num_empty_dmg_stars_changed")
	
	playerState.connect("focus_combo_level_changed",self,"_on_focus_combo_level_changed")
	playerState.connect("combo_level_changed",comboHandler,"_on_combo_level_changed")
	#playerState.connect("focus_combo_level_changed",comboHandler,"_on_focus_combo_level_changed")
	#playerState.connect("focus_capacity_changed",comboHandler,"_on_focus_capacity_changed")
	playerState.connect("damage_gauge_capacity_changed",comboHandler,"_on_damage_gauge_capacity_changed")
	playerState.connect("damage_gauge_changed",comboHandler,"_on_damage_gauge_changed")
	#playerState.connect("focus_changed",comboHandler,"_on_focus_changed")
	
	comboHandler.connect("filled_combo_level_up",self,"_on_filled_combo_level_up")
	
	
	ripostHandler.connect("reactive_ripost_window_expired",self,"_on_reactive_ripost_window_expired")
	ripostHandler.connect("reactive_ripost_succeeded",self,"_on_reactive_ripost_succeeded")
	ripostHandler.connect("reactive_ripost_invalid_prediction",self,"_on_reactive_ripost_invalid_prediction")
	ripostHandler.connect("preemptive_ripost_window_expired",self,"_on_preemptive_ripost_window_expired")
	#ripostHandler.connect("preemptive_ripost_succeeded",self,"_on_preemptive_ripost_succeeded")
	#ripostHandler.connect("preemptive_ripost_invalid_prediction",self,"_on_preemptive_ripost_invalid_prediction")
	#ripostHandler.connect("ripost_was_countered",self,"_on_ripost_was_countered")
	
	#ripostCounterHandler.connect("counter_ripost_window_expired",self,"_on_counter_ripost_window_expired")
	#ripostCounterHandler.connect("counter_ripost_succeeded",self,"_on_counter_ripost_succeeded")
	#ripostCounterHandler.connect("counter_ripost_invalid_prediction",self,"_on_counter_ripost_invalid_prediction")
	newCounterRipostHandler.connect("counter_ripost_failed",self,"_on_counter_ripost_failed")
	
	collisionHandler.connect("player_attack_clashed",self,"_on_player_attacked_clashed")
	collisionHandler.connect("player_invincible_was_hit",self,"_on_player_invincibility_was_hit")
	collisionHandler.connect("player_was_hit",self,"_on_player_was_hit")
	collisionHandler.connect("hitting_invincible_player",self,"_on_hitting_invincible_player")
	collisionHandler.connect("hitting_player",self,"_on_hitting_player")
	collisionHandler.connect("proximity_guard_enabled_changed",self,"_on_proximity_guard_enabled_changed")
	
	
	collisionHandler.connect("pushed_against_wall",techHandler,"_on_wall_collision")
	collisionHandler.connect("pushed_against_ceiling",techHandler,"_on_ceiling_collision")
	#collisionHandler.connect("pushed_against_wall",self,"_on_wall_collision")
	collisionHandler.connect("left_wall",self,"_on_left_wall")
	
	
	collisionHandler.connect("left_ground",self,"_on_left_ground_delayed")
	collisionHandler.connect("landing_on_ground",self,"_on_land")
	collisionHandler.connect("left_platform",self,"_on_left_platform_delayed")
	collisionHandler.connect("landing_on_platform",self,"_on_landing_on_platform")

	collisionHandler.connect("landed_on_opponent",self,"_on_land_on_opponent")
	collisionHandler.connect("stopped_standing_on_opponent",self,"_on_stop_landing_on_opponent")
	
	#both ground and platform edge call same function for now (maybe want to change this in future)
	#but the design is that if you can't run off a platform, u shouldn't be able to run off
	#a ground isle, which is currently not implemented
	#collisionHandler.connect("entered_ground_ledge",self,"_on_arrived_on_platform_edge")
	#collisionHandler.connect("left_ground_ledge",self,"_on_walked_back_onto_platform_from_edge")
	
	collisionHandler.connect("left_platform_right_ledge",self,"_on_walked_back_onto_platform_from_edge")
	collisionHandler.connect("entered_platform_right_ledge",self,"_on_arrived_on_platform_edge")
	collisionHandler.connect("left_platform_left_ledge",self,"_on_walked_back_onto_platform_from_edge")
	collisionHandler.connect("entered_platform_left_ledge",self,"_on_arrived_on_platform_edge")
	
	collisionHandler.playerController = self

	ripostHitstunMovementAnimation = $"ripost-hitstun"
	
	grabHandler.init(self)
	

	playerState.connect("damage_gauge_reached_capacity",comboHandler,"_on_reached_damage_gauge_capacity")
	
	playerState.connect("guardHP_changed",guardHandler,"_on_guardHP_changed")
	
	#playerState.connect("focus_reached_capacity",comboHandler,"_on_reached_focus_capacity")
	#load the map that links commands and the attack type (melee, special, too)
	actionAnimeManager.populateCommandAttackMap(inputManager)
			
	
	self.set_physics_process(true)
	
	#actionAnimeManager.setGlobalSpeedMod(2)
	
	pass


#called by the node handling both palyers 
func initFollowMovements():
	
	#search for any followMovements, and link the follow oppoent 
	
	#searching in movement animations
	for ma in actionAnimeManager.movementAnimationManager.movementAnimations:
		#iterate complex mvm
		for cm in ma.complexMovements:
			#iterate basic mvmv
			for bm in cm.basicMovements:
				
				if bm is preload("res://FollowMovement.gd"):
					if bm.destinationType == bm.DestinationType.OPPONENT:
						bm.src = kinbody #this player will be moved by movement animation
						bm.dst = opponentPlayerController.kinbody #follow opponent
					elif bm.destinationType == bm.DestinationType.OTHER:
						#leave it up to sub class hook to setupt the src and dst
						bm.connect("following_special_object_type",self,"_on_following_special_object_type_hook")
					elif bm.destinationType == bm.DestinationType.CASTER:
						print("warning: invalid follow movement confiruation. Caster in this case is player, and player can't follow itself. ignoring.")
						
					if GLOBALS.DEBUGGING_FOLLOW_MVM:
						bm.connect("start_following",self,"_on_debug_restart_following_mvm")
	
	#searching in hitstun movements
	for sa in actionAnimeManager.spriteAnimationManager.spriteAnimations:
		
		#iterate sprite frames
		for sf in sa.spriteFrames:
			
			#iterate over hitboxes
			
			for hb in sf.hitboxes:
				
	
				var mvmAnimations = [hb.attackerOnBlockedMovementAnimation,hb.blockstunMovementAnimation,hb.hitstunLinkMovementAnimation,hb.cornerHitPushAwayMovementAnimation,hb.blockCornerHitPushAwayMovementAnimation,hb.hitstunMovementAnimation]
				
				for mvmAnimation  in mvmAnimations:
					
					if mvmAnimation != null:
						#iterate complex mvm
						for cm in mvmAnimation.complexMovements:
							#iterate basic mvmv
							for bm in cm.basicMovements:
								
								if bm is preload("res://FollowMovement.gd"):
									 #we are opponent, sicne this is hitstun movement to apply to victim
									if bm.destinationType == bm.DestinationType.OPPONENT:
										bm.dst = kinbody #in this case, we are the opponent since this movement is knockback from attack were hitting with
										bm.src = opponentPlayerController.kinbody  #victim flying towards us is opponent,
									elif bm.destinationType == bm.DestinationType.CASTER:
										#bm.src = kinbody 
										#bm.dst = opponentPlayerController.kinbody 
											print("warning: invalid follow movement confiruation. Caster in this case is victim being hit, and victim can't follow itself. ignoring.")
									elif bm.destinationType == bm.DestinationType.OTHER:
										#leave it up to sub class hook to setupt the src and dst
										bm.connect("following_special_object_type",opponentPlayerController,"_on_following_special_object_type_hook")
										
									if GLOBALS.DEBUGGING_FOLLOW_MVM:
										bm.connect("start_following",self,"_on_debug_restart_following_mvm")
func setGlobalSpeedMod(g):
	globalSpeedMod = g
	#techHandler.setGlobalSpeedMod(g)
	#actionAnimeManager.setGlobalSpeedMod(g)
	
#to be implemented by subclasses. Used to load a single type of projectile 
#to be spawned at multiple areas
func getStaticProjectileSpawn(customProjectileSpawnData):
	return null


func setOpponentPlayerController(o):
	opponentPlayerController = o
func getOpponentPlayerController():
	return opponentPlayerController

	
func _on_land_on_opponent(_inCornerStatus):
	
	
	#print("landed on opponent")
	
	if opponentPlayerController.my_is_on_floor():
		_disablePlayerBodyCollision()
	else:
	
		isOnOpponent = true
		inCornerStatus = _inCornerStatus
	pass
	
func _on_stop_landing_on_opponent():
	inCornerStatus = GLOBALS.OnOpponentStatus.NOT_AGAINST_WALL
	isOnOpponent = false
	
func standingOnOpponent():
	#colliding with a physics object and not on floor? ie. on opponent
	#if kinbody.is_on_floor():
	#	return not floorDetector.is_colliding()
	
	#return false
	var res = false
	#iterate the collisions
	for colliderIx in kinbody.get_slide_count():
		var collision = kinbody.get_slide_collision(colliderIx)
		
		if collision.collider  == opponentPlayerController.kinbody:
			print("collided with player")
			#we may be bumping into opponent, check if on floor 
			#if kinbody.is_on_floor():
			if actionAnimeManager.movementAnimationManager.on_floor:
				print("collided with player and is on something, and is on player = "+str(not floorDetector.is_colliding()))
				res = res or (not floorDetector.is_colliding()) #may be on the ground and bumping into opponent, so make sure
	
	if not res:
		#assuming we missed signal, try moving 1 pixel down into ground without actually
		#var collision = kinbody.move_and_collide(Vector2(0,1),true,true,true)
		var trans = Transform2D(kinbody.position,Vector2(1,0),Vector2(0,1)) #no transformation
		var collision = kinbody.test_move(trans,Vector2(0,1))
		
		if collision:
			
			#a critical assumption is made. You can't be overlapping with a platform whyile standing on ground
			#so on opponent while overlapping in platform?
		#	if platformDetector.is_colliding() and floorDetector.is_colliding():
				#we are on the player
		#		return true
		#	else:
			
			 	#may be on the ground and bumping into opponent, so make sure
			return not floorDetector.is_colliding()
				#not on floor but colliding with somthing, of course on player
				#return true
			
		
		#move back up. ideally we'd use the test_only flag, but it won't work (maybe godot older version unsupperted)
#		kinbody.move_and_collide(Vector2(0,-1))

		#if moving down 1, collide with player?
		#if collision != null and collision.collider  == opponentPlayerController.kinbody:
			
		#	res = true
	return res	
	

func _on_damage_bar_changed(newDamage,oldDamage):
	pass
func _on_num_filled_dmg_stars_changed(oldNumStars,newNumStars):
	pass
	
	
	#if newNumStars >= 4:

	#	if not highDamageParticles.emitting:
	#		_on_request_play_special_sound(DAMAGE_THRESHOLD_EXCEEDED_SOUND_ID)
	#	if enableParticles:
	#		highDamageParticles.visible=true
	#		highDamageParticles.emitting = true
	#	else:
	#		highDamageParticles.visible=false
	#		highDamageParticles.emitting = false
	#else:
	#	highDamageParticles.visible=false
	#	highDamageParticles.emitting = false
	

	#match(newNumStars):
	#	0:
	#		kinbody.dmgStarGlow.visible = false
	#	1:
	#		kinbody.dmgStarGlow.visible = true
	#		kinbody.dmgStarGlow.modulate.a = 0.2
	#	2:
	#		kinbody.dmgStarGlow.visible = true
	#		kinbody.dmgStarGlow.modulate.a = 0.4
	#	3:
	#		kinbody.dmgStarGlow.visible = true
	#		kinbody.dmgStarGlow.modulate.a = 0.6
	#	4:
	#		kinbody.dmgStarGlow.visible = true
	#		kinbody.dmgStarGlow.modulate.a = 0.8
	#	5:
	#		kinbody.dmgStarGlow.visible = true
	#		kinbody.dmgStarGlow.modulate.a = 1
func _on_damage_gauge_capacity_changed(newCapacity,oldCapacity):
	
	pass
#	if newCapacity > oldCapacity:
#		if enableParticles:
#			damageIncParticles.set_emitting(true)
#	else:
#		if enableParticles:
#			damageDecParticles.set_emitting(true)


#func _on_pushable_frame_flag(isPushableFlag):
#	if not isPushableFlag:
#		actionAnimeManager.movementAnimationManager.stopPushing()
		

func _on_platform_drop():
	
	#if is_on_floor():
		#when on a platform, fall trhough by entering the platform and ignoring physics
		#collisions
		#if platformDetector.is_colliding():
	if is_on_platform():
	
		if actionAnimeManager.isAutoCancelable(actionAnimeManager.PLATFORM_DROP_ACTION_ID):
			kinbody.position.y+=1
			playActionKeepOldCommand(actionAnimeManager.PLATFORM_DROP_ACTION_ID)

#called when ray-cast of platform exceeds platform, but where still on the platform
func _on_arrived_on_platform_edge():
	
	playerOnPlatformEdge = true
	var spriteFrame = actionAnimeManager.spriteAnimationManager.getCurrentSpriteFrame()
	
	if spriteFrame != null:
	
		if spriteFrame.disableRunOffPlatform:
		
			#landing on platform edge and tech rolling of (gravity is not reset)
			#if actionAnimeManager.isAutoCancelable(actionAnimeManager.LEAVE_PLATFROM_HALT_ACTION_ID):
			playActionKeepOldCommand(actionAnimeManager.LEAVE_PLATFROM_HALT_ACTION_ID)
			
	pass		
func _on_walked_back_onto_platform_from_edge():
	playerOnPlatformEdge = false
	pass
	
#called when leaving platform (jump, drop, walk off, hit off)
#TODO: call this function at appropriate time
func _on_left_platform():
	
	#if actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.LAND_ON_PLATFROM_ACTION_ID):
		#replay gravity if pushed off platform
	#	playActionKeepOldCommand(actionAnimeManager.LEAVE_PLATFROM_HALT_ACTION_ID)
		
		
	var spriteFrame = actionAnimeManager.spriteAnimationManager.getCurrentSpriteFrame()
		
		
	if spriteFrame != null:
		#stop momentum from ground animation as we leave platform?
		
		#THIS BELOW IS GOOD, JUST MAKE SURE TO ADJUST WHAT MOVE CAN KEEP MOMENTUM OFF PLATFORM
		if spriteFrame.keepMomentumWhenLeavePlatform:
			#do nothing to the momentum
			pass
		else:
			
			#reset gravity
			#replay gravity if not play
			#var gravType = complexMvmInstance.GravityEffect.REPLAY
			#actionAnimeManager.movementAnimationManager.applyComplexMovementGravity(gravType)
			#playActionKeepOldCommand(actionAnimeManager.LEAVE_PLATFROM_HALT_ACTION_ID)
			playActionKeepOldCommand(actionAnimeManager.STOP_PLATFORM_LEAVE_MOMENTUM_ACTION_ID)
			
	
	#do we break/cancel the animation upon leaving platform (grounders should
	#stop playing in air)
	
	#only break the animation if don't spcify in autocancel map to keep it
	#only cancel animation when on edge of platform (animations that ignore gravity need this chekc
	#ontherwise  they cancel on start up, from leaving ground)
	if not actionAnimeManager.isAutoCancelable(actionAnimeManager.PLATFORM_ANIMATION_CANCEL_ACTION_ID) and playerOnPlatformEdge:
		playActionKeepOldCommand(actionAnimeManager.PLATFORM_ANIMATION_CANCEL_ACTION_ID)
	
	playerOnPlatformEdge = false
	
	_on_left_ground()
	
	
	#the animation exceed the platfomr (like ground dash)
#export (bool) var disableRunOffPlatform = false

#when true, your movement is unaffected when you leave platform (like jump, for example)
#when false, your momentum is halted when you leave the platform (like walking off to stop speed boost)
#export (bool) var keepMomentumWhenLeavePlatform = true
	#print("left platform")
	
	
func _on_landing_on_platform():
	
	_on_land()
	
	
	#CONSIDER ADDING THIS AS AUTO CANCEL, CAUSE SOME MOVES MAY NOT WANT TO PLAY THIS (TECH FOR EXAMPLE)
	#playActionKeepOldCommand(actionAnimeManager.LAND_ON_PLATFROM_ACTION_ID)

func _on_left_platform_delayed():
	onLeftPlatformCallFlag = true
	
func _on_left_ground_delayed():
	onLeftGroundCallFlag = true
	


func _on_left_ground():
	#always have air dash from ground jump
	var recoverAirDash = true
	playerState.countJump(recoverAirDash)
	
	#this will happend when getting hit with movement only moves
	#or running off a platform
	if actionAnimeManager.isAutoCancelable(actionAnimeManager.AIR_IDLE_ACTION_ID):
		#try autocancel into air idle state (only moves that are almost idle should auto cancel into air idle)
		playActionKeepOldCommand(actionAnimeManager.AIR_IDLE_ACTION_ID)
		
		#reset the gravity when leave ground if autocancels into air idle
		var gravType = complexMvmInstance.GravityEffect.KEEP_AND_REPLAY_IF_STOPPED
		actionAnimeManager.movementAnimationManager.applyComplexMovementGravity(gravType)
		
	
	#leaving ground in hitstun?
	if playerState.inHitStun:
		
		#go into air hitstun
		actionAnimeManager.toggleHitstunSpriteAnimation(false,kinbody.facingRight)
	
func _on_land():
	
	
	emit_signal("landed")
	_on_request_play_special_sound(LAND_SOUND_ID,COMMON_SOUND_SFX)
	#get your jumps back and air dash back
	playerState.currentNumJumps = playerState.numJumps
	playerState.numAcroABCancelExtraJumps=0
	playerState.hasAirDashe = true
	
	#can now hit to get airdash back, if applicable
	playerState.recoveredAirDashFromHit= false
	
	#can now recover an air dash from ability cancel in air
	playerState.recoveredAbilityCancelAirDash= false
	
	#here we stop any excess air moementum we got from moving in air and getting hit half way trhough
	if playerState.inHitStun and ((actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.AIR_MOVE_FORWARD_ACTION_ID)) or (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.AIR_MOVE_BACKWARD_ACTION_ID))):
		stopWalkingMovement()		
	
	
	#stop pushing opponent, we landed
	actionAnimeManager.movementAnimationManager.stopPushing()	
	#note that we may want to consider moving below logic into above if statement (why
	#process all this landing info if we ignore land-on-oppenent events for reseting jumps?, same 
	#for the landed signal)
	
	
	var hasEnoughBarForTech = playerState.hasEnoughAbilityBar(techAbilityBarCost)
	##only apply the landing animation logc if we haven't teched
	#can only tech in hitstun, if player previously inputed tech (L2) ~25 frames before landing, has enough bar for tech,
	#and the hitbox that knocked back opponent supports ground teching
	if playerState.inHitStun and hasEnoughBarForTech and techHandler.readyForFloorTech():
		techHandler._on_land() #if can tech on an opponent, this is a illstration of bug
		#can ignore the landing logic, since about to tech
		return
		
	#cacel landing nimation if not in hitstun (this is where landing lag logic should be
	#done), that is go into landing lag animation if it doesn't autocancel on landing
	if not playerState.inHitStun:
		
		var spriteAnimation = actionAnimeManager.getCurrentSpriteAnimation()
		if spriteAnimation != null:
			var spriteFrame = spriteAnimation.getCurrentSpriteFrame()
			
			if  spriteFrame != null:
				
				var landingType =spriteFrame.landing_lag
				#handle what kind of landing
				if landingType == spriteFrame.LandingType.LAGLESS:
					#CANCEL air animation into ground idle
					playActionKeepOldCommand(actionAnimeManager.GROUND_IDLE_ACTION_ID)					
					return
				else:
					var cancelSuccessful = false
					
					if landingType == spriteFrame.LandingType.CONTINUE_ANIMATION: #failed to cancel bar, apply appropriate landing animation
						#continue playing the animation
						#this is where landing animaton logic would be sone if landing aniamtion would exist
						
						if not spriteFrame.keepMomentumOnLand:
							#stop movement upong landing (don't want sliding)
							playActionKeepOldCommand(actionAnimeManager.LANDING_STOP_MOMENTUM_ACTION_ID)
						return
					else:#LANDING_LAG
					
						
						
						#check for special case of landing in air block stun
						if guardHandler.isInBlockHitstun():
							
							#make sure the landing recovery duration is atleast a frame
							#the landing recovery is decided by hitbox that last hit
							if blockStunAirRecoveryDuration >= 1:
								
								#var blockStunFramesRemaining = actionAnimeManager.spriteAnimationManager.currentAnimation.computeNumberRemainingFrames()
								var blockStunFramesRemaining = animationFramesRemaining
								#still ahve internale lag in bock stun, so gotta ad 2 to compenate
								# +2, since for special case of "JUST frames", want make sure +5 means a startup moves of 5 will hit (takes 1
								#frame for the phsysics engine to process the activated frame and do collisions
				
								var newBlockStunDuration =blockStunAirRecoveryDuration+blockStunFramesRemaining
					
								#the blockstun's +/- frames depends on attack that hit blocker. so if the blockstun is typically +2,
								#Then on land it will be 2 + (blockStunAirRecoveryDuration)
								#you keep your original momentum from blockstun knockback (air idle doesn't affect momentum)
								var mvmAnimation = actionAnimeManager.mvmAnimationLookup(actionAnimeManager.AIR_IDLE_ACTION_ID)
								
								#attack facing doesn't matter, since movement is static, so just use dummy variable
								var attackFacingRight =true
								
											# -1, since for special case of "JUST frames", want make sure +5 means a startup moves of 5 will hit (takes 1
								#frame for the phsysics engine to process the activated frame and do collisions
								newBlockStunDuration = newBlockStunDuration -1
								displayFrameData(newBlockStunDuration)
								playBlockHistunAnimation(newBlockStunDuration,mvmAnimation,attackFacingRight)
								
								
						else:
							adjustSpriteAnimationSpeed(spriteAnimation.landingLagDuration,actionAnimeManager.LANDING_LAG_ACTION_ID)
						
						
							#make sure to migrate the autocancel maps to landing lag animation
							#before playing animation.
							#this will allow each move to define a unique set of moves that autocancel upon landing lag
							var sa = actionAnimeManager.spriteAnimationLookup(actionAnimeManager.LANDING_LAG_ACTION_ID)
							
							#the animation will determine if landing lag is cancelableb
							sa.barCancelableble=spriteAnimation.canAbilityCancelLandingLag
							sa.abilityCancelCostType = spriteAnimation.landingLagBarCost
							
							#see if we hit during this aniation
							#var wasAnimationHitting =sa.hasHitThisAnimation()
							
							var wasAnimationHitting = false
														
							if spriteFrame.spriteAnimation != null:
								var ignoreTimeEllapsed = true
								wasAnimationHitting = spriteFrame.spriteAnimation.isOnHitAutoCancelWindowActive(ignoreTimeEllapsed)
								
							#iterate over each frame to set autocancel map
							for sf in sa.spriteFrames:
								sf.autoCancels=spriteFrame.landingLagAutoCancels
								sf.autoCancels2=spriteFrame.landingLagAutoCancels2
								
								#are we hitting right before landing?
								if wasAnimationHitting:
								
								
									#the landing lag inherits on hit autocancels
									sf.autoCancelsOnHit=spriteFrame.landingLagAutoCancelsOnHit
									sf.autoCancelsOnHit2=spriteFrame.landingLagAutoCancelsOnHit2
								else:
									sf.autoCancelsOnHit=0
									sf.autoCancelsOnHit2=0
							playActionKeepOldCommand(actionAnimeManager.LANDING_LAG_ACTION_ID)
							
							if wasAnimationHitting:	
								#allow landing lag to do autocancel on hits
								actionAnimeManager.spriteFrameSetIsHitting(true)
								actionAnimeManager.spriteFrameSetHittingAnyHitbox(true)
						return
			else:#if there are any problems with frame handling, just cancel into ground idle
				playActionKeepOldCommand(actionAnimeManager.GROUND_IDLE_ACTION_ID)
				return
		else:	
			playActionKeepOldCommand(actionAnimeManager.GROUND_IDLE_ACTION_ID)			
			return
	else:
		#
		#we in hitstun
		#
		
		
		var stopHitMomentumOnLand = actionAnimeManager.isHitstunStopHitMomentumOnLand()
		
		#check if we should stop any movement animaton on land in hitstun
		#this i particularly important for fast moving players getting
		#hit by a grounder move, and then keeping their momentum
		#upon landing
		if stopHitMomentumOnLand != null and stopHitMomentumOnLand:
					
			if not hitstunTimer.hasTimeTickEllapsed():
				#wwe started hitstun this frame, so we were hit and landed on same frame
				#make sure to ignored okie if this is the case
				#print("posslbe source of oki bug")
				pass
				#print("hit same frame as landing. make sure the knockback isn't overrided. if a bug occured with knockback, tis my be reason (not implement yet)")
				#only apply below line in else
				
			actionAnimeManager.movementAnimationManager.haltMovement()
		else:
			#either the animation doesn't support the flag (invulerable histun), or flase is false, so don't stop movemetn
			pass
			
		#buggy state where landing but was already in landing hitstun?
		if actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.LANDING_HITSTUN_ACTION_ID):
			
			#do nothing, we want to make sure landing hitstun is always a static duration
			return
			
		#if actionAnimeManager.readyForLandingHitstun() or actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.INVULNERABLE_AIR_HITSTUN_ACTION_ID):
		if actionAnimeManager.readyForLandingHitstun():
		
			if not hitstunTimer.hasTimeTickEllapsed():
				#wwe started hitstun this frame, so we were hit and landed on same frame
				#make sure to ignored okie if this is the case
				#print("posslbe source of oki bug")
				pass
				#print("ignoring oki. Was hit same frame we landed in hitstun")
			#landing in hitstun (fall to the ground) (oki)
			else:
				playActionKeepOldCommand(actionAnimeManager.LANDING_HITSTUN_ACTION_ID)
				var _sa = actionAnimeManager.spriteAnimationLookup(actionAnimeManager.LANDING_HITSTUN_ACTION_ID)
				#hitstun is extended by duration of knockdown
				_on_start_tracking_frame_duration(_sa.getEffectiveNumberOfFrames())
				hitstunTimer.stop()
			
		else:
			
			#go into ground hitstun
			actionAnimeManager.toggleHitstunSpriteAnimation(true,kinbody.facingRight)
			
			
			#do we change the hitstun duration for landing?
			var newHitstunDurationOnLand = actionAnimeManager.getNewHitstunDurationOnLand()
			if newHitstunDurationOnLand>-1:
				
				#make sure we didn't land same frame being hit, cause then 
				#we would want to consider new hitstun duration only
				#if landed after being hit, not at same time
				
				if hitstunTimer.ellapsedTimeInSeconds>0:
					#apply proration to the  new duration upong landing
					#TODO: somehow integrate the move spam duration mod, cause you could have infinites with moves that create new hitstun on land
					var durationMod = opponentPlayerController.comboHandler.getHitstunProrationMod(lastHitBySpriteAnimeId,true)
					emit_signal("hitstun_proration_mod_applied",durationMod)
					#change the duration of hitstun for special hitboxes that have a static duration on land
					var _dur=durationMod*newHitstunDurationOnLand
					hitstunTimer.start(_dur)
					_on_start_tracking_frame_duration(_dur)
				else:
					print("hit wiht hitbox that changes hitstun duration when land same frame landed. Ignoring the land hitstun duration change")	
			
		#elif actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.INVULNERABLE_AIR_HITSTUN_ACTION_ID):
			#at this point, we in infinite hitstun, so must go into landing hitstun
		#	print("missed the landing hitstun queue cause not ready...")


#called when a follow movement is initiated (starts/activates) and
#the follow destination type is other (not caster, nor opponent)
func _on_following_special_object_type_hook(followMvm):
	#not implement yet
	pass
	
		
func my_is_on_floor():
	
	return not collisionHandler.wasInAir
	#return actionAnimeManager.movementAnimationManager.on_floor

func my_is_on_ceiling():
	return collisionHandler.wasAgainstCeiling
		
func my_is_against_wall():
	return kinbody.leftWallDetector.is_colliding() or kinbody.rightWallDetector.is_colliding()

#	return collisionHandler.wasAgainstWall

func is_on_platform():
	return 	collisionHandler.wasOnPlatform
	
func _on_moved_kinematic_body(mvmManager):
	var wasOnGroundCopy = collisionHandler.wasOnGround
	var wasOnPlatformCopy = collisionHandler.wasOnPlatform
	collisionHandler.environmentCollisionCheck(mvmManager)
	collisionHandler.stoppedEnvironmentCollisionCheck(wasOnGroundCopy,wasOnPlatformCopy,mvmManager)
	collisionHandler.onOpponentCheck(mvmManager)


func _physics_process(delta):

	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	#only update the frames remaining when an animation is active
	#otherwise were in between animations anf for sake of things
	#that requires frames remaiing, it's fine to treat remaining
	#frames since last frame (this is especially important for aiblity
	#canceling that stops the animation duration hit freeze)
	if actionAnimeManager.spriteAnimationManager.currentAnimation != null:
		animationFramesRemaining = getFramesRemainingInAnimation()
	
	checkForMissedFloorCollision()

	#handle managing guard resource renge/reduce rates
	#and the holding back guard hp dmg mod
	#guardHandler.process_guard_hp(globalSpeedMod*delta)
		
	
	#var isOnOpponent = standingOnOpponent()
	#var isOnOpponent = false
	var pushingOpponent = false

		
	updateRipostFlags()
	

	
	#make sure we push away opponent after checking for landing, otherwise may miss
	#landing
	#make sure we don't push when inside each other, since game engine will pop players
	#away from each other when the disabled body box ends
	if isOnOpponent: 
	
		if not insideOpponentDetector.is_colliding():
			actionAnimeManager.movementAnimationManager.pushPlayerAway(kinbody.facingRight, opponentPlayerController.isInCorner())
			pushingOpponent = true
			
	
	
	
	#landing-pushaway staate hasn't changed?
	if globalPushingOpponentFlag == pushingOpponent:
		pass
	else:
		globalPushingOpponentFlag=pushingOpponent
		emit_signal("landing_pushaway_changed",globalPushingOpponentFlag)
		
	#var selfPos = kinbody.getCenter()
	#var opponenentPos = opponentPlayerController.kinbody.getCenter()
	#there are rare cases where both players overlap perfectly when the bodyboxes were disabled
	#and re-enabled. In such cases, game will glitch out and both players will be locked inside each
	#other until one moves	
	#if abs(selfPos.x - opponenentPos.x) <= 0.01: #inside player almost exctly on top?
	#	if selfPos.distance_to(opponenentPos) <= PLAYER_CENTER_INSIDE_PLAYER_DIST_THRESHOLD: # 2 since body box y length may differ
		#TODO: make above dependednt on height of body box (else will buge if big heros come along)
	#		if self.leftWallDetector.is_colliding():
	#			kinbody.position.x = kinbody.position.x+1
		
	#		if self.rightWallDetector.is_colliding():
	#			kinbody.position.x = kinbody.position.x-1
		
		
	
	
	#pushAwayFromCornerCheck()
	
	#make sure were in hitstun while throwing opponent
	breakFreeFromThrowCheck()
	
		
	#skip the user input this frame?
	#necessary for when breaking free from hitstun, we handle user input there.
	#we want to avoid situation where we break free from hitstun the frame we were hit,
	#having the hitstun break logic be called first and then the hit logic 2nd, 
	#which doesn't give user a chance to play any action before hitstun restarts
	if not skipHandleInputThisFrame:
		
		#we make sure that commands that provoke hitstun break won't be able 
		# get a second command to input in same frame (ripost, for example)
		#A bug with ripost is that handling user input upon histun break will
		#make you ripost twice by accident in rective window
		#in normal case, breaking free from hitstun due to aniamtion end, the player didn't 
		#tirgerr the break so ts fine
		handleUserInputCallLock=true
		handleUserInput()
		handleUserInputCallLock=false
	else:
		skipHandleInputThisFrame=false #don't sip next round

	#after all the hit handling, at end frame were no longer hitting
	
	
	if onLeftPlatformCallFlag:
		onLeftPlatformCallFlag=false
		_on_left_platform()
	if onLeftGroundCallFlag:
		onLeftGroundCallFlag = false
		_on_left_ground()
	#	collisionHandler.environmentCollisionCheck()
	
	
	wasInHitFreezeThisFrame=false
	
	
	guardBrokeThisFrame = false
	
	#do a half hp check for when swap bars
	if not playerState.halfHPReached:
		if playerState.hp <halfHpValue:
			playerState.halfHPReached=true
			emit_signal("reached_half_hp")
	
		
func breakFreeFromThrowCheck():
	#when we are hit (in histun),  if we were mid grab/throw animation, release opponent?
	if playerState.inHitStun and opponentPlayerController.playerState.inHitStun and opponentPlayerController.actionAnimeManager.isBeingThrown():
		#release the opponent
		opponentPlayerController.breakFromHistun()
		#hard force go into idle and break free
		if opponentPlayerController.my_is_on_floor():
			opponentPlayerController.playActionKeepOldCommand(actionAnimeManager.GROUND_IDLE_ACTION_ID)			
		else:
			opponentPlayerController.playActionKeepOldCommand(actionAnimeManager.AIR_IDLE_ACTION_ID)
			
#func playOnHitSound(hurtBoxSoundId,hitBoxSoundId):
func playOnHitSound(hurtBox,hitBox): 

	
	if hurtBox == null or hitBox == null:
		#hittingSFXPlayer.playRandomSound() #play default random sound
		return 
		
	#hitbox doesn't trigger sound efefct?
	if not hitBox.playSoundSFX:
		return
		
	
	#check to see if the hitbox or hurtbox have a special sound to play		
	if hurtBox.heroSFXSoundId != -1:
		#play hero-specific sound specified by hurtbox
		_on_request_play_special_sound(hurtBox.heroSFXSoundId,HERO_SOUND_SFX,hurtBox.heroSFXSoundVolumeOffset)
	elif hurtBox.commonSFXSoundId != -1:
		#play universal sound specified by hurtbox
		_on_request_play_special_sound(hurtBox.commonSFXSoundId,COMMON_SOUND_SFX,hurtBox.commonSFXSoundVolumeOffset)
	
	#elif hitBox.commonSFXSoundId != -1:
		
	
	var attackerActionManager = hitBox.playerController.actionAnimeManager
	#var attackerSpriteAnime = attackerActionManager.getCurrentSpriteAnimation()
	#var attackerSpriteAnime = attackerActionManager.getCurrentSpriteAnimation()
	
	if hitBox.cmd == null:
		
		
			#check to see if the itBox have a special sound to play		
		if hitBox.heroSFXSoundId != -1:
			#play hero-specific sound specified by hitBox
			_on_request_play_special_sound(hitBox.heroSFXSoundId,HERO_SOUND_SFX,hitBox.heroSFXSoundVolumeOffset)
		elif hitBox.commonSFXSoundId != -1:
			#play universal sound specified by hitBox
			_on_request_play_special_sound(hitBox.commonSFXSoundId,COMMON_SOUND_SFX,hitBox.commonSFXSoundVolumeOffset)
		else:
			hittingSFXPlayer.playRandomSound() #play default random sound
			
		return
#	var attackType = -1
#	#*****************************#TODO: use the hitxboxe's command instead of current sprite id (which may change if hitbox belongs to projectile)
	
	var actionMngrToCheckAudioSFX = null
	#we choose action anime manager dynamically based on source of hitbox
	if hitBox.is_projectile:
		actionMngrToCheckAudioSFX = hitBox.projectileController.actionAnimationManager#projectile
	else:
		actionMngrToCheckAudioSFX=actionAnimeManager#player
	#resolve the attack type using sprite id
	#TODO: FIX THIS logic. Glove's bal doesn't do correct sound cause
	#glove's action manager is mbeing 
	#if attackerActionManager.isMeleeCommand(hitBox.cmd):
	if actionMngrToCheckAudioSFX.isAudioSFXMeleeSpriteAnimeId(hitBox.spriteAnimation.id):
		_on_request_play_special_sound(MELEE_HIT_SOUND_ID,COMMON_SOUND_SFX)
	#elif attackerActionManager.isSpecialCommand(hitBox.cmd):
	elif actionMngrToCheckAudioSFX.isAudioSFXSpecialSpriteAnimeId(hitBox.spriteAnimation.id):
		_on_request_play_special_sound(SPECIAL_HIT_SOUND_ID,COMMON_SOUND_SFX)
	#elif attackerActionManager.isToolCommand(hitBox.cmd):
	elif actionMngrToCheckAudioSFX.isAudioSFXToolSpriteAnimeId(hitBox.spriteAnimation.id):
		_on_request_play_special_sound(TOOL_HIT_SOUND_ID,COMMON_SOUND_SFX)
	#check to see if the itBox have a special sound to play		
	elif hitBox.heroSFXSoundId != -1:					
		#play hero-specific sound specified by hitBox
		_on_request_play_special_sound(hitBox.heroSFXSoundId,HERO_SOUND_SFX,hitBox.heroSFXSoundVolumeOffset)
	elif hitBox.commonSFXSoundId != -1:
		#play universal sound specified by hitBox
		_on_request_play_special_sound(hitBox.commonSFXSoundId,COMMON_SOUND_SFX,hitBox.commonSFXSoundVolumeOffset)
	
	else:
		hittingSFXPlayer.playRandomSound() #play default random sound
	#else:
	#	hittingSFXPlayer.playRandomSound() #play default random sound
	
		
func pauseAnimation():
	actionAnimeManager.pauseAnimation()
	
	
func unpauseAnimation():
	
	if pauseOnHitFreezeEndEnabled:
		pauseOnHitFreezeEndEnabled=false
		
		#don't let the cpu control the pause menu in result screen
		if opponentPlayerController.heroName != GLOBALS.CPU_NAME:			
			emit_signal("pause",inputManager.inputDeviceId,opponentPlayerController.inputManager.inputDeviceId,self,GLOBALS.PauseMode.IN_GAME)
		else:
			emit_signal("pause",inputManager.inputDeviceId,null,self,GLOBALS.PauseMode.IN_GAME)

	actionAnimeManager.unpauseAnimation()
	
	
func enablePlayerBodyCollision():
	
	#can't enable body box in corner to prevent wonky floor collision breaks
	#and landing /leaving ground due to someone entering a corner with a body
	#box and spawning inside someone else
	
	#var againstWall = false
	#use these ray casts since they are bigger so will guarantee body box won't be active in corner
	#againstWall = kinbody.leftCornerDetector.is_colliding()
	#againstWall = againstWall or kinbody.rightCornerDetector.is_colliding()
	#againstWall = kinbody.hittingLeftWallDetector.is_colliding()
	#againstWall = againstWall or kinbody.hittingRightWallDetector.is_colliding()
	
	#if againstWall:
	#if collisionHandler.wasInDisabledBodyBoxWallArea:
		#_disablePlayerBodyCollision()
		#don't enable the body box if in the disabled body boax area
	#	return 
	
	#can't enable the body box inside the opponent. psuh each other away
	if collisionHandler.wasInsideOpponent:
		#only consider pushing both opponents away if we had a disabled body box and are now 
		#trying to enable it inside oppoent (ingore case that it's already eneabled and were re-enabling it
		# since opponent may still have disagbled body box)
		if not bodyBoxCollisionEnabledFlag:
			
			#opponent in corner
			if opponentPlayerController.isInCorner():
			#trying to contest the corner. already occupied. get pushed out
				actionAnimeManager.movementAnimationManager.pushPlayerAwayFromInsideOpponent(kinbody.facingRight)
			else:
				#push both players away from each other
				actionAnimeManager.movementAnimationManager.pushPlayerAwayFromInsideOpponent(kinbody.facingRight)
				opponentPlayerController.actionAnimeManager.movementAnimationManager.pushPlayerAwayFromInsideOpponent(opponentPlayerController.kinbody.facingRight)
				
			return
	else:
		actionAnimeManager.movementAnimationManager.stopPushingPlayerAwayFromInsideOpponent()
	_enablePlayerBodyCollision()
		
func _enablePlayerBodyCollision():	
	#already enabled?
	if bodyBoxCollisionEnabledFlag:
		return
	
	if opponentPlayerController == null:
		return
	if opponentPlayerController.kinbody == null:
		return
	if kinbody ==null:
		return
		
	#make sure opponent can detect the playre collision and start pushing us
	var opponentBodyBoxMask = 1 << kinbody.opponentPushableBodyBoxCollisionBit
	
	kinbody.collision_mask= kinbody.collision_mask | opponentBodyBoxMask



	#var ourBodyBoxLayerMask = 1 << kinbody.pushableBodyBoxLayerBit
	var ourBodyBoxLayerMask = 1 << kinbody.pushableBodyBoxCollisionBit

	kinbody.collision_layer= kinbody.collision_layer | ourBodyBoxLayerMask
	
	
	#make sure the land on opponent area can be detected and is detecting
	#iterate all the collision areas of land on opponent detection, and enable
	#for c in kinbody.landOnPlayerArea.get_children():
	#	if c is CollisionShape2D:
	#		c.disabled = false
	kinbody.landOnOpponentSignalEnabled = true
	leftOpponentDetector.enabled = true
	rightOpponentDetector.enabled = true
	#opponentPlayerController.leftOpponentDetector.enabled = true
	#opponentPlayerController.rightOpponentDetector.enabled = true
	
	#var bodyBoxMask = 1 << kinbody.pushableBodyBoxCollisionBit
	
	
	#opponentPlayerController.kinbody.collision_mask=opponentPlayerController.kinbody.collision_mask | bodyBoxMask
	#opponentPlayerController.kinbody.landOnPlayerArea.monitoring = true
	
	#e.g.:
	#		10011	 MASK
	#		00100	OPPONENT'S BODY BOX BIT
	#OR		10111   NEW MASK
	
	bodyBoxCollisionEnabledFlag = true
	
	
	#wait 1 frame before re-enabling standing on opponent ray casts. This way,
	#it gives a chance for engine to pop the body box out of player
	#so you don't push player and pop away at same time
	#wait 2 frames, to be safe
	#yield(get_tree().create_timer(2*GLOBALS.SECONDS_PER_FRAME),"timeout")
	
	opponentPlayerController.leftOpponentDetector.enabled = true
	opponentPlayerController.rightOpponentDetector.enabled = true
	
#body box disable
func disablePlayerBodyCollision():
	
	_disablePlayerBodyCollision()
	
func _disablePlayerBodyCollision():
	
	
	
	#already disabled?
	if not bodyBoxCollisionEnabledFlag:
		return
	
	actionAnimeManager.movementAnimationManager.stopPushing()
	
	#got remove the bodybox bit of opponent to 1 in our mask (scanning)
	#by using bitwise xor
	
	var opponentBodyBoxMask = 1 << kinbody.opponentPushableBodyBoxCollisionBit
	#bit flip it, so only the body box bit is 0, then can and to map
	opponentBodyBoxMask = ~ opponentBodyBoxMask

	#stop any detection of body box collision
	kinbody.collision_mask= kinbody.collision_mask & opponentBodyBoxMask


	#var ourBodyBoxLayerMask = 1 << kinbody.pushableBodyBoxLayerBit
	var ourBodyBoxLayerMask = 1 << kinbody.pushableBodyBoxCollisionBit
	
	#bit flip it, so only the body box bit is 0, then can and to map
	ourBodyBoxLayerMask = ~ ourBodyBoxLayerMask

	#stop any detection of body box collision
	kinbody.collision_layer= kinbody.collision_layer & ourBodyBoxLayerMask

	
	
	
	#make sure the land on opponent area can't detected and isn't detecting
	
	
	kinbody.landOnOpponentSignalEnabled = false
	leftOpponentDetector.enabled = false
	rightOpponentDetector.enabled = false
	opponentPlayerController.leftOpponentDetector.enabled = false
	opponentPlayerController.rightOpponentDetector.enabled = false
	
	#var bodyBoxMask = 1 << kinbody.pushableBodyBoxCollisionBit
	#bodyBoxMask = ~ bodyBoxMask

	#opponentPlayerController.kinbody.collision_mask=opponentPlayerController.kinbody.collision_mask & bodyBoxMask
	
	bodyBoxCollisionEnabledFlag = false
	#opponentPlayerController.kinbody.landOnPlayerArea.monitoring = false
	
	

	#e.g.:
	#		10111	 MASK
	#		00100	OPPONENT'S BODY BOX BIT
	#OR		10011   NEW MASK

#not interacting with false walls implies gona do some form phasing through walls
#so since stage walls need to phase through to, disable the entire stage collision
#this is strong assumption but only hat does this with screen wrapping
#for projectiles when creating them there is more control so wson't need the falg for anything
#but hat
func disableFalseWallCollisions():
		
	#got remove the bodybox bit of opponent to 1 in our mask (scanning)
	#by using bitwise xor
	
	var mask = 1 << kinbody.falseWallCollisionBit
	#bit flip it, so only the body box bit is 0, then can and to map
	mask = ~ mask

	#stop any detection of body box collision
	kinbody.collision_mask= kinbody.collision_mask & mask


	mask = 1 << kinbody.stageCollisionBit
	#bit flip it, so only the body box bit is 0, then can and to map
	mask = ~ mask

	#stop any detection of body box collision
	kinbody.collision_mask= kinbody.collision_mask & mask

	
	
func enableFalseWallCollisions():
		#make sure opponent can detect the playre collision and start pushing us
	var mask = 1 << kinbody.falseWallCollisionBit
	
	kinbody.collision_mask= kinbody.collision_mask | mask

	mask = 1 << kinbody.stageCollisionBit
	
	kinbody.collision_mask= kinbody.collision_mask | mask

#this tries the tech, which requires bar and to be in hitstun
func attemptTech():
	
	#only when in hit stun u can tech
	if playerState.inHitStun:
		
		var hasEnoughBar = playerState.hasEnoughAbilityBar(techAbilityBarCost)
		if hasEnoughBar:
			
			var sa = actionAnimeManager.spriteAnimationManager.currentAnimation
			var techExceptions = 0
			if sa != null:
				#might have frame perfect land/tech hitstun situation, so make sure the property iexsits
				if "techExceptions" in sa:
					techExceptions = sa.techExceptions
			#ignore the case where we already against the gfournd/wall/ceiling, u gotta hit it 
			var rc = techHandler.startTechWindow(techExceptions)
			
			#IF ALREADY against the environment, trigger the logic
			if collisionHandler.wasAgainstWall:
				techHandler._on_techable_environment_collision(GLOBALS.TECH_WALL_IX)
			if collisionHandler.wasAgainstCeiling:
				techHandler._on_techable_environment_collision(GLOBALS.TECH_CEILING_IX)
			#don't allow tech on floor cause ppl are always on floor, so this would be
			#free every time. only for walls and ceiling so if you constatly pushed into wall by 
			#opponent, at any point u can tech 
			#if my_is_on_floor():
			#1	techHandler._on_techable_environment_collision(GLOBALS.TECH_FLOOR_IX)
		else:
			emit_signal("insufficient_ability_bar",techAbilityBarCost*playerState.abilityChunkSize)
			#print("tech rc:" + str(rc))

	
#func attemptCounterRipost(cmd):
			
#	if not actionAnimeManager.isCounterRipostableCommand(cmd):
#		return
	#can ripost in most cases, but special frames like blocking, you can't ripost
	
#	var currAnime= actionAnimeManager.getCurrentSpriteAnimation() 
	
#	if currAnime!=null:
#		var currFrame = currAnime.getCurrentSpriteFrame()
		#can't ripost in this frame
#		if currFrame != null and not currFrame.canCounterRipost:
			
			#can't ripost
#			return false

	
#	return ripostCounterHandler.attemptCounterRipost(cmd)	

	
#try to  a command
#para, cmd: the command trying to ripost
func attemptRipost(cmd):
	
	#can't ripost if guard just broke
	#if guardBrokenRipostLock:
	#	return
		
	#can ripost in most cases, but special frames like blocking, you can't ripost
	
	var currAnime= actionAnimeManager.getCurrentSpriteAnimation() 
	
	if currAnime!=null:
		var currFrame = currAnime.getCurrentSpriteFrame()
		#can't ripost in this frame
		if currFrame != null and not currFrame.canRipost:
			
			#can't ripost
			return
		
	
	#don't bother if you have not bar
	#if playerState.abilityBar < ripostingAbilityBarCost:
	if not playerState.hasEnoughAbilityBar(ripostingAbilityBarCost):
		emit_signal("insufficient_ability_bar",ripostingAbilityBarCost*playerState.abilityChunkSize)
		return
	
	emit_signal("about_to_attempt_ripost",cmd)
	
	#opponent hasn't predicted we were gona ripost (countered it?)
	#if not opponentPlayerController.ripostCounterHandler._on_ripost_input(cmd):#may want to debug this to make sure it work with facing
	#	ripostHandler.attemptRipost(cmd)
	ripostHandler.attemptRipost(cmd)

#a functionhook so subclasses can override the command for specials states
#otherwise doesn't change the command
func handleUserInputHook(_cmd):
	return _cmd
	
func handleUserInput():
	
	#don't read any commands if we are in the end game hitstun
	#if ignoreUserInputFlag:
	#	return
	#var cmd = inputManager.readCommand()
	var cmd = inputManager.readLastCommand()
	
	cmd = handleUserInputHook(cmd)
			
	
	if cmd == inputManager.Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE:
		pass
	#flag set by training mode so automatically ability cancel
	#upon entering active frames to get a frame perfect ability canel
	#while maintaining the active hitbox for 1 frame
	#i think below code is busted and suffers from port priority. so best
	#not ever use it (keeping it for now not to break things)
	if autoActiveFramesAbilityCancelFlag:
		if actionAnimeManager.spriteAnimationManager.isInActiveAnimation():
			
									
			#make sure we don't eat the command
			inputManager.storeBufferableCommandInBuffer(cmd)				
				
			cmd = inputManager.Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE
			
	
	var attemptCounterRipostOverridedRipost = false
	var _ignoreUserInputFlag =ignoreUserInputFlag
	
	#can't input anything when trying to preemptively ripost or we counter riposting
	#if ripostHandler.isInPreemptiveWindow() or newCounterRipostHandler.counterRiposting:
		
	#	_ignoreUserInputFlag=true
	
	if newCounterRipostHandler.counterRiposting:
		_ignoreUserInputFlag=true
	elif ripostHandler.isInPreemptiveWindow():
		
		#were gona check if we can interrupt the ripost with counter ripost (only possible at very start of window and in neutral)
		if not playerState.inHitStun:
			var ellapsedSecs = ripostHandler.getPreWindowNumberFramesEllapsed()
			var outsideCounterRipostableWindow = GLOBALS.has_frame_based_duration_ellapsed(ellapsedSecs,GLOBALS.COUNTER_RIPOST_OVERRIDES_RIPOST_WINDOW)
			
			#missed the oppurtunity to cancel the ripost with counter ripost?
			if outsideCounterRipostableWindow:
				_ignoreUserInputFlag=true
			elif inputManager.isCounterRipostCommand(cmd):
				_ignoreUserInputFlag=false #let the counter ripost slide				
				attemptCounterRipostOverridedRipost=true
			else:
				_ignoreUserInputFlag=true
		else:
			_ignoreUserInputFlag=true
	
	#checking if start was pressed to pause game, only when can process commands
	if not _ignoreUserInputFlag and cmd == inputManager.Command.CMD_START:
		
		#only pause when pause is enabled (not during end of game, for example)
		#can't pause during hitfreeze
		if canPauseFlag:
		
			if not actionAnimeManager.playerPaused:
				#don't let the cpu control the pause menu in result screen
				if opponentPlayerController.heroName != GLOBALS.CPU_NAME:			
					emit_signal("pause",inputManager.inputDeviceId,opponentPlayerController.inputManager.inputDeviceId,self,GLOBALS.PauseMode.IN_GAME)
				else:
					emit_signal("pause",inputManager.inputDeviceId,null,self,GLOBALS.PauseMode.IN_GAME)
			else:
				pauseOnHitFreezeEndEnabled=true
			
			return

			
	var bufferedInputFlag = false
	var commandConsummed = false

	var preventCounterRipost = false
	
	#convert the command to the appropriate command based on which direction facing
	var facingCmd = inputManager.getFacingDependantCommand(cmd,kinbody.facingRight)
	
	#keeps track of when holding back and when not
	handleHoldingBackInput(facingCmd)
	handleHoldingForwardInput(facingCmd)
	handleHoldingDownInput(facingCmd)
	#used by ghost ai demo data logger
	emit_signal("cmd_inputed",facingCmd,inputManager.isRipostCommand(facingCmd),inputManager.isCounterRipostCommand(facingCmd))
	#emit_signal("cmd_inputed",facingCmd,inputManager.isRipostCommand(facingCmd),isCounterRipostCmd)

	var currSpriteFrame = actionAnimeManager.spriteAnimationManager.getCurrentSpriteFrame()
	
	var useInputBufferFlag = false
	if currSpriteFrame != null and currSpriteFrame.canUseBufferedCommands:
		useInputBufferFlag=true			
	elif currSpriteFrame == null:
		useInputBufferFlag=true	
	elif isBarCanceling: #old content I beleive
		useInputBufferFlag=true
		isBarCanceling=false
	elif wasInHitFreezeThisFrame: 
		#so to avoid hitfreeze eating input in animations that don't support buffered commands(gground idle, for example), allow it
		useInputBufferFlag=true
		#don't have to reset the wasInHitFreezeThisFrame flag, physics_process deals with it
		
	var crouching = isCrouching()
	var crouchBufferableCmd=false
			
	#var currSpriteFrame = actionAnimeManager.spriteAnimationManager.getCurrentSpriteFrame()

	#read from buffer only if curernt sprite frame allows buffered input
	#otherwise, we just stick we raw input
	#but we ignore buffer if we try to ripoost			
	#if currSpriteFrame != null and currSpriteFrame.canUseBufferedCommands and not inputManager.isRipostCommand(facingCmd) and not inputManager.isCounterRipostCommand(facingCmd):
		#read and consum the command buffers
		#cmd = inputManager.readCommand()
		#facingCmd = inputManager.getFacingDependantCommand(cmd,kinbody.facingRight)
		
		
	if not _ignoreUserInputFlag :	
		handleDirectionalInput()
	else:
		#when input is ignored stick should be considered neutral (so blocking stops)
		guardHandler._on_directional_input(GLOBALS.DirectionalInput.NEUTRAL)
		negativePenaltyTracker._on_directional_input(GLOBALS.DirectionalInput.NEUTRAL)
	

	#in hit stun?
	#if not _ignoreUserInputFlag and playerState.inHitStun:
	if playerState.inHitStun:
		
		if not _ignoreUserInputFlag:
		#check for riposting
			
			if inputManager.isRipostCommand(facingCmd):
				commandConsummed = true
	
				attemptRipost(inputManager.getRipostedCommand(facingCmd))
			
			#you can't tech when stunned/lying prone on the ground
			elif not actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.LANDING_HITSTUN_ACTION_ID):
				#check for techs	
				if facingCmd == inputManager.Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE:			
					attemptTech()
					commandConsummed = false # don't want to eat the left trigger-based input. maybe player wants to buffer cancel
	
				elif inputManager.isAbilityCancelInput_basedCommand(facingCmd):	
					#inputing a ability cancel DI?
					attemptTech()
			
				elif inputManager.isHoldBackCommand(facingCmd):
					
					
					commandConsummed = false # don't want to eat the move, maybe player wants to move left/right
					#var forwardFlag = false
					#techHandler.attemptHorizontalTech(forwardFlag)
				#elif facingCmd == inputManager.Command.CMD_MOVE_FORWARD:
				elif inputManager.isHoldForwardCommand(facingCmd):
					commandConsummed = false # don't want to eat the move, maybe player wants to move left/right
					#var forwardFlag = true
					#techHandler.attemptHorizontalTech(forwardFlag)
					
			#no logic to buffer a tech... maybe should address? will se how teching feels first
			
	else:#not in hitstun
		
		
			
		#no immediate input (a null frame means we just finished an animation)?
		#if facingCmd == null:
		if not _ignoreUserInputFlag and useInputBufferFlag and not inputManager.isRipostCommand(facingCmd):
			#try to get buffered input
			var	tmpCmd = inputManager.readBufferedCommand()
		
			#trying to buffer ability cancel?
			if tmpCmd == inputManager.Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE:
				
				
				#for animations that don't support ability canceling, ignore the buffered ability
				#cancel and play the currently pressed cmd
				
				if not actionAnimeManager.spriteAnimationManager.canCurrentSpriteFrameAbilityCancel():
					tmpCmd=null #null the command to process the command pressed this frame to keep ability cancel buffered
				
			#convert the command to the appropriate command based on which direction facing
			var tmpFacingCmd = inputManager.getFacingDependantCommand(tmpCmd,kinbody.facingRight)
			
			#buffered input exists?
			if tmpFacingCmd != null:
				
				#here, the player may just inputed a command, but the input buffer
				#will take priority since the current spirte animation
				#allows commands from input buffer
				
				#make sure to store the raw command (the ignored one)
				#into buffer
								
				inputManager.storeBufferableCommandInBuffer(cmd)				
			
				
				bufferedInputFlag = true	
				cmd = tmpCmd
				facingCmd = tmpFacingCmd
				
				
				
				#print("obtained buffered command")
		emit_signal("cmd_inputed_post_buffer",facingCmd)
		#ripost input?
		if not _ignoreUserInputFlag and inputManager.isRipostCommand(facingCmd):
			commandConsummed = true			
					
			attemptRipost(inputManager.getRipostedCommand(facingCmd))
			
		else:
			
			
			
			
			#elif(not _ignoreUserInputFlag and facingCmd != null):
			#if(not _ignoreUserInputFlag and not counterRipostInputFlag):
			if(not _ignoreUserInputFlag):
				match(facingCmd):
					inputManager.Command.CMD_JUMP:
						
						commandConsummed = handleJumpCommand(facingCmd)
						
						if playerState.currentNumJumps > 0:
							crouchBufferableCmd=true
						#	elif commandConsummed:
						#		playerState.hasAirDashe = true
							
						
					inputManager.Command.CMD_JUMP_FORWARD:
						if playerState.currentNumJumps > 0:
														
							if my_is_on_floor():
								commandConsummed=playUserInputAction(actionAnimeManager.JUMP_FORWARD_ACTION_ID,facingCmd)						
								#jump didn't work? maybe only jump cancelable into a non-dash-cancelable jump
								if not commandConsummed:
									commandConsummed=playUserInputAction(actionAnimeManager.NON_GND_DASH_CANCELABLE_F_JUMP_ACTION_ID,facingCmd)
							else:
								
								var usedAcroABCancelExtraJumpFlag=false
								#are we left with only jumps gained from ability canceling in 
								#air from acrobatics advantage prof?
								if acroABCancelExtraJumpCheck():
									
									#enough bar to extra jump?
									if playerState.hasEnoughAbilityBar(acroABCancelExtraJumpBarCost):
										usedAcroABCancelExtraJumpFlag=true	
										
										#special condition where can't cahnge facing ?
										if mirrorAirActionDIRequired():
											commandConsummed=playUserInputAction(actionAnimeManager.AIR_JUMP_BACKWARD_ACTION_ID,facingCmd)
										else:
															
											commandConsummed=playUserInputAction(actionAnimeManager.AIR_JUMP_FORWARD_ACTION_ID,facingCmd)
									else:
										emit_signal("insufficient_ability_bar",acroABCancelExtraJumpBarCost*playerState.abilityChunkSize)
										commandConsummed=false
								else:
									#jump normally
									
									#special condition where can't cahnge facing ?
									if mirrorAirActionDIRequired():
										
										commandConsummed=playUserInputAction(actionAnimeManager.AIR_JUMP_BACKWARD_ACTION_ID,facingCmd)
									else:
										
										commandConsummed=playUserInputAction(actionAnimeManager.AIR_JUMP_FORWARD_ACTION_ID,facingCmd)
								
								#we jumped back using extra acro jump?
								if usedAcroABCancelExtraJumpFlag and commandConsummed:
									playerState.forceConsumeAbilityBarInChunks(acroABCancelExtraJumpBarCost)
							#double jumped? that is, was in the air and jumped?
							#the main process function handles consumming a jump when leaving the ground
							#if commandConsummed and playerState.wasInAir:
							if commandConsummed and not my_is_on_floor():
								
								playerState.countJump(recoverAirDashOnJump)
								emit_signal("jumped")
								
							crouchBufferableCmd=true
							#elif commandConsummed:
							#	playerState.hasAirDashe = true
								
					inputManager.Command.CMD_JUMP_BACKWARD:
						if playerState.currentNumJumps > 0:
							if my_is_on_floor():
								commandConsummed=playUserInputAction(actionAnimeManager.JUMP_BACKWARD_ACTION_ID,facingCmd)						
								#jump didn't work? maybe only jump cancelable into a non-dash-cancelable jump
								if not commandConsummed:
									commandConsummed=playUserInputAction(actionAnimeManager.NON_GND_DASH_CANCELABLE_B_JUMP_ACTION_ID,facingCmd)
							else:
								
								var usedAcroABCancelExtraJumpFlag=false
								#are we left with only jumps gained from ability canceling in 
								#air from acrobatics advantage prof?
								if acroABCancelExtraJumpCheck():
									
									#enough bar to extra jump?
									if playerState.hasEnoughAbilityBar(acroABCancelExtraJumpBarCost):
										usedAcroABCancelExtraJumpFlag=true	
										
										#special condition where can't cahnge facing ?
										if mirrorAirActionDIRequired():
											commandConsummed=playUserInputAction(actionAnimeManager.AIR_JUMP_FORWARD_ACTION_ID,facingCmd)
										else:
																	
											commandConsummed=playUserInputAction(actionAnimeManager.AIR_JUMP_BACKWARD_ACTION_ID,facingCmd)
									else:
										emit_signal("insufficient_ability_bar",acroABCancelExtraJumpBarCost*playerState.abilityChunkSize)
										commandConsummed=false
								else:
									#jump normally
									
									#special condition where can't cahnge facing ?
									if mirrorAirActionDIRequired():
										commandConsummed=playUserInputAction(actionAnimeManager.AIR_JUMP_FORWARD_ACTION_ID,facingCmd)
									else:	
										commandConsummed=playUserInputAction(actionAnimeManager.AIR_JUMP_BACKWARD_ACTION_ID,facingCmd)
								
								#we jumped back using extra acro jump?
								if usedAcroABCancelExtraJumpFlag and commandConsummed:
									playerState.forceConsumeAbilityBarInChunks(acroABCancelExtraJumpBarCost)
								
							
							#double jumped? that is, was in the air and jumped?
							#the main process function handles consumming a jump when leaving the ground
							#if commandConsummed and playerState.wasInAir:
							if commandConsummed and not my_is_on_floor():

								playerState.countJump(recoverAirDashOnJump)
								emit_signal("jumped")
							#elif commandConsummed:
							#	playerState.hasAirDashe = true #why is this here
								
							crouchBufferableCmd=true
								
					inputManager.Command.CMD_AUTO_RIPOST:
						
						if not cantAutoRipost:
							#only block if not on cooldown
							#if not playerState.isBlockOnCooldown:
							if playerState.hasEnoughAbilityBar(autoRipostAbilityBarCost):
								
								
								if not my_is_on_floor():				
									commandConsummed =playUserInputAction(actionAnimeManager.AIR_AUTO_RIPOST_ACTION_ID,facingCmd)
								else:
									commandConsummed =playUserInputAction(actionAnimeManager.AUTO_RIPOST_ACTION_ID,facingCmd)
								#only put block on cooldown if was able to cancel into block 
								if commandConsummed:
									emit_signal("auto_ripost_attempted")
									playerState.forceConsumeAbilityBarInChunks(autoRipostAbilityBarCost)
									#playerState.consumeAbilityBar(autoRipostAbilityBarCost)
									#startBlockCooldown()
	
							else:
								emit_signal("insufficient_ability_bar",autoRipostAbilityBarCost*playerState.abilityChunkSize)
								commandConsummed = false
						else:
							commandConsummed=false	
							
						crouchBufferableCmd=true
					inputManager.Command.CMD_MOVE_FORWARD,inputManager.Command.CMD_FORWARD_UP:
						commandConsummed = handleMoveForwardCmd(facingCmd)
						crouchBufferableCmd=true
					
					inputManager.Command.CMD_MOVE_BACKWARD,inputManager.Command.CMD_BACKWARD_UP:
						commandConsummed = handleMoveBackwardCmd(facingCmd)
						
						crouchBufferableCmd=true
											
					inputManager.Command.CMD_STOP_MOVE_BACKWARD: #below is legacy code to allow agents to work (player's just release (null command) to stop moving)
						if not playerState.inHitStun:
							if not my_is_on_floor():
								#are we proximity blocking?
								if actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_AIR_HOLD_BACK_BLOCK_ACTION_ID):
									#KEep momentum after releasing block and go idle in air, was blocking
									commandConsummed = playUserInputAction(actionAnimeManager.AIR_IDLE_ACTION_ID,facingCmd)
									
								elif (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.AIR_MOVE_FORWARD_ACTION_ID)) or (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.AIR_MOVE_BACKWARD_ACTION_ID)):
									commandConsummed = playUserInputAction(actionAnimeManager.AIR_MOVE_STOP_ACTION_ID,facingCmd)
							else:
									#are we proximity blocking?
								if actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_STANDING_HOLD_BACK_BLOCK_ACTION_ID):
									#KEep momentum after releasing block and go idle in air, was blocking
									commandConsummed = playUserInputAction(actionAnimeManager.GROUND_IDLE_ACTION_ID,facingCmd)
										
								#if (actionAnimeManager.currentActionAnimation == actionAnimeManager.GROUND_MOVE_FORWARD_ACTION_ID) or (actionAnimeManager.currentActionAnimation == actionAnimeManager.GROUND_MOVE_BACKWARD_ACTION_ID):
								elif (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.GROUND_MOVE_FORWARD_ACTION_ID)) or (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.GROUND_MOVE_BACKWARD_ACTION_ID)):
									commandConsummed = playUserInputAction(actionAnimeManager.GROUND_IDLE_ACTION_ID,facingCmd)
						
					inputManager.Command.CMD_STOP_MOVE_FORWARD: #below is legacy code to allow agents to work (player's just release (null command) to stop moving)
						if not playerState.inHitStun:
							if not my_is_on_floor():
								#if (actionAnimeManager.currentActionAnimation == actionAnimeManager.AIR_MOVE_FORWARD_ACTION_ID) or (actionAnimeManager.currentActionAnimation == actionAnimeManager.AIR_MOVE_BACKWARD_ACTION_ID):
								if (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.AIR_MOVE_FORWARD_ACTION_ID)) or (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.AIR_MOVE_BACKWARD_ACTION_ID)):
									commandConsummed = playUserInputAction(actionAnimeManager.AIR_MOVE_STOP_ACTION_ID,facingCmd)
							else:
								#if (actionAnimeManager.currentActionAnimation == actionAnimeManager.GROUND_MOVE_FORWARD_ACTION_ID) or (actionAnimeManager.currentActionAnimation == actionAnimeManager.GROUND_MOVE_BACKWARD_ACTION_ID):
								if (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.GROUND_MOVE_FORWARD_ACTION_ID)) or (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.GROUND_MOVE_BACKWARD_ACTION_ID)):
									commandConsummed = playUserInputAction(actionAnimeManager.GROUND_IDLE_ACTION_ID,facingCmd)									
					inputManager.Command.CMD_STOP_CROUCH:					
					
						#if my_is_on_floor():
							
						#crouching?
						if crouching:
							#commandConsummed = playUserInputAction(actionAnimeManager.UNCROUCH_ACTION_ID,facingCmd)
							#force the uncrouch. no need for autocancel check, cause by design, when crouching, u
							#must uncrouch when releasing down
							playActionKeepOldCommand(actionAnimeManager.UNCROUCH_ACTION_ID)
							commandConsummed = true
						
					
					inputManager.Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE,inputManager.Command.CMD_UP_PUSH_BLOCK,inputManager.Command.CMD_CROUCH_PUSH_BLOCK:
						
						#PLAYER may be tap-untaping back to save guard resoruce, so a raw L2/left-trigger tap in block stun
						#will count as push block
						if guardHandler.isInHoldBackBlockAnimation():
							
							#only process ABILITY CANCEL as pushblock while in animation that can block
							#although we can block in pushblock animation, don't process input as push block twice. instead
							#allow process input as ability cancel 
							if not isInPushBlockingAnimation():
								commandConsummed = attemptPushBlock(inputManager.Command.CMD_BUFFERED_PUSH_BLOCK)
							else:
								commandConsummed = handleAbilityCancelCmd()
						else:
							
							commandConsummed = handleAbilityCancelCmd()
									
					inputManager.Command.CMD_CROUCH:
						
						if my_is_on_floor():
							commandConsummed = handleCrouchCmdOnGround(facingCmd)

						
					inputManager.Command.CMD_FORWARD_CROUCH:
						if my_is_on_floor():
							commandConsummed = handleCrouchCmdOnGround(facingCmd)
						else:
							#move back in air
							#special condition where can't cahnge facing ?
							if mirrorAirActionDIRequired():
								commandConsummed = playUserInputAction(actionAnimeManager.AIR_MOVE_BACKWARD_ACTION_ID,facingCmd)
							else:										
								commandConsummed = playUserInputAction(actionAnimeManager.AIR_MOVE_FORWARD_ACTION_ID,facingCmd)
						#SAME AS CROUCH ABOVE
					
					inputManager.Command.CMD_BACKWARD_CROUCH:
						
						if my_is_on_floor():
							
							#inside proximity of incoming hitbox?
							if collisionHandler.isProximityGuardEnabled():
								
								
								commandConsummed = playUserInputAction(actionAnimeManager.PROXIMITY_GUARD_CROUCHING_HOLD_BACK_BLOCK_ACTION_ID,facingCmd)
											
								#failed to block (ie, not in blockable animation?)
								if not commandConsummed:
									#try to move backward instead
									commandConsummed = handleCrouchCmdOnGround(facingCmd)
									
							else:
								#there is no hitbox active and nearby?
								commandConsummed = handleCrouchCmdOnGround(facingCmd)
								
						
							
					inputManager.Command.CMD_DASH_FORWARD_NO_DIRECTIONAL_INPUT:
						
						if not my_is_on_floor() and mirrorAirActionDIRequired():
							commandConsummed = handleDashBackwardCmd(facingCmd)
						else:
							commandConsummed = handleDashForwardCmd(facingCmd)
						
						crouchBufferableCmd=true
						#COPY paste of below code
					inputManager.Command.CMD_DASH_FORWARD:
						commandConsummed = handleDashForwardCmd(facingCmd)
						crouchBufferableCmd=true
					inputManager.Command.CMD_DASH_BACKWARD:
						commandConsummed = handleDashBackwardCmd(facingCmd)
						crouchBufferableCmd=true
					inputManager.Command.CMD_AIR_DASH_DOWNWARD:
						if not my_is_on_floor():
							
							#can't fast fall if air dashing disabled
							if not preventAirDashing:
								commandConsummed = playUserInputAction(actionAnimeManager.AIR_DASH_DOWNWARD_ACTION_ID,facingCmd)
							
								if not commandConsummed:
									#failed to fast fall? maybe requires you to be at apex of jump
									
									#CAN only attempt to fast fall if passed apex (so relative y velocity toward ground)
									#so can't fast fall start of jump, for example
									#if actionAnimeManager.movementAnimationManager.cachedRelativeVelocity.y >=0:
									if actionAnimeManager.movementAnimationManager.hasReachedVerticalMomentumApex():
										commandConsummed = playUserInputAction(actionAnimeManager.APEX_ONLY_FAST_FALL_ACTION_ID,facingCmd)
							else:
								commandConsummed=false
								
							if commandConsummed:
								#consume the fast fall
								
								_on_request_play_special_sound(AIR_DASH_SOUND_ID,COMMON_SOUND_SFX)
								emit_signal("air_dashed",GLOBALS.AirDashType.DOWNWARD)
								
									
								
						elif is_on_platform() and actionAnimeManager.isAutoCancelable(actionAnimeManager.PLATFORM_DROP_ACTION_ID):
							_on_platform_drop()
							commandConsummed=true
						else:
								
								
							if not preventGroundDashing:
								#here we want to avoid having holding down eat the forward dash and immetiate crouch cancel
								#input, so play the dash forward commadn
								commandConsummed = playUserInputAction(actionAnimeManager.GROUND_FORWARD_DASH_ACTION_ID,facingCmd)
								
								#did we fail to dash back? maybe can only do a non-crouch cancelable dash back
								if not commandConsummed:
									commandConsummed = playUserInputAction(actionAnimeManager.NON_CROUCH_CANCELABLED_F_GROUND_DASH_ACTION_ID,facingCmd)
								
								if commandConsummed:
									emit_signal("ground_dashed",GLOBALS.AirDashType.FORWARD)
							else:
								commandConsummed=false
							
						crouchBufferableCmd=true
					inputManager.Command.CMD_NEUTRAL_MELEE,inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE:
						if not my_is_on_floor():
							#commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_MELEE_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(facingCmd))
							commandConsummed = handleAirMeleeAttackInput(facingCmd,inputManager.counterRipostCmdToBaseCmd(facingCmd))
						else:
							#commandConsummed= playUserInputAction(actionAnimeManager.NEUTRAL_MELEE_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(facingCmd))
							commandConsummed = handleGroundMeleeAttackInput(facingCmd,actionAnimeManager.NEUTRAL_MELEE_ACTION_ID)
						crouchBufferableCmd=true
					inputManager.Command.CMD_BACKWARD_MELEE,inputManager.Command.CMD_COUNTER_RIPOST_BACKWARD_MELEE:
						if not my_is_on_floor():
							#commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_MELEE_ACTION_ID,inputManager.Command.CMD_NEUTRAL_MELEE)
							commandConsummed = handleAirMeleeAttackInput(facingCmd,inputManager.Command.CMD_NEUTRAL_MELEE)
						else:
							###############################
							########ALPHA LOGIC###########
							###############################		
							#note this logic can be dropped once entire movesets are complete
							#var reMappedCmd = facingCmd
							#do we map non-existing move to neutral?
							#if actionAnimeManager.BACKWARD_MELEE_ACTION_ID == actionAnimeManager.NEUTRAL_MELEE_ACTION_ID:
							#	reMappedCmd = inputManager.Command.CMD_NEUTRAL_MELEE
							
								
							#commandConsummed= playUserInputAction(actionAnimeManager.BACKWARD_MELEE_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))
							commandConsummed = handleGroundMeleeAttackInput(facingCmd,actionAnimeManager.BACKWARD_MELEE_ACTION_ID)
						crouchBufferableCmd=true	
					inputManager.Command.CMD_FORWARD_MELEE,inputManager.Command.CMD_COUNTER_RIPOST_FORWARD_MELEE:
						if not my_is_on_floor():
							#commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_MELEE_ACTION_ID,inputManager.Command.CMD_NEUTRAL_MELEE)
							commandConsummed = handleAirMeleeAttackInput(facingCmd,inputManager.Command.CMD_NEUTRAL_MELEE)
						else:
							
							###############################
							########ALPHA LOGIC###########
							###############################		
							#note this logic can be dropped once entire movesets are complete
#							var reMappedCmd = facingCmd
							#do we map non-existing move to neutral?
#							if actionAnimeManager.FORWARD_MELEE_ACTION_ID == actionAnimeManager.NEUTRAL_MELEE_ACTION_ID:
#								reMappedCmd = inputManager.Command.CMD_NEUTRAL_MELEE
#							commandConsummed= playUserInputAction(actionAnimeManager.FORWARD_MELEE_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))
							commandConsummed = handleGroundMeleeAttackInput(facingCmd,actionAnimeManager.FORWARD_MELEE_ACTION_ID)
							#if not playerState.isGrabOnCooldown:
		
								#only allow grabbing on ground
								#if my_is_on_floor():
							#	commandConsummed= playUserInputAction(actionAnimeManager.GROUND_GRAB_ACTION_ID,inputManager.Command.CMD_GRAB)
								#else:
						
								#	commandConsummed= playUserInputAction(actionAnimeManager.AIR_GRAB_ACTION_ID,inputManager.Command.CMD_GRAB)
						
						
						crouchBufferableCmd=true
					inputManager.Command.CMD_DOWNWARD_MELEE,inputManager.Command.CMD_COUNTER_RIPOST_DOWNWARD_MELEE:
						if not my_is_on_floor():
							#commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_MELEE_ACTION_ID,inputManager.Command.CMD_NEUTRAL_MELEE)
							commandConsummed = handleAirMeleeAttackInput(facingCmd,inputManager.Command.CMD_NEUTRAL_MELEE)
						else:
							###############################
							########ALPHA LOGIC###########
							###############################		
							#note this logic can be dropped once entire movesets are complete
							#var reMappedCmd = facingCmd
							#do we map non-existing move to neutral?
							#if actionAnimeManager.DOWNWARD_MELEE_ACTION_ID == actionAnimeManager.NEUTRAL_MELEE_ACTION_ID:
							#	reMappedCmd = inputManager.Command.CMD_NEUTRAL_MELEE
							#commandConsummed = playUserInputAction(actionAnimeManager.DOWNWARD_MELEE_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))
							commandConsummed = handleGroundMeleeAttackInput(facingCmd,actionAnimeManager.DOWNWARD_MELEE_ACTION_ID)
						crouchBufferableCmd=true
					inputManager.Command.CMD_UPWARD_MELEE,inputManager.Command.CMD_COUNTER_RIPOST_UPWARD_MELEE:
						
						if not my_is_on_floor():
							#commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_MELEE_ACTION_ID,inputManager.Command.CMD_NEUTRAL_MELEE)
							commandConsummed = handleAirMeleeAttackInput(facingCmd,inputManager.Command.CMD_NEUTRAL_MELEE)
						
						else:
							###############################
							########ALPHA LOGIC###########
							###############################		
							#note this logic can be dropped once entire movesets are complete
							#var reMappedCmd = facingCmd
							#do we map non-existing move to neutral?
							#if actionAnimeManager.UPWARD_MELEE_ACTION_ID == actionAnimeManager.NEUTRAL_MELEE_ACTION_ID:
							#	reMappedCmd = inputManager.Command.CMD_NEUTRAL_MELEE
															
							#commandConsummed = playUserInputAction(actionAnimeManager.UPWARD_MELEE_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))
							commandConsummed = handleGroundMeleeAttackInput(facingCmd,actionAnimeManager.UPWARD_MELEE_ACTION_ID)
							
						crouchBufferableCmd=true
					inputManager.Command.CMD_NEUTRAL_SPECIAL,inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL:
						if not my_is_on_floor():
							#commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_SPECIAL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(facingCmd))
							commandConsummed = handleAirSpecialAttackInput(facingCmd,inputManager.counterRipostCmdToBaseCmd(facingCmd))
						else:						
							#commandConsummed = playUserInputAction(actionAnimeManager.NEUTRAL_SPECIAL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(facingCmd))
							commandConsummed = handleGroundSpecialAttackInput(facingCmd,actionAnimeManager.NEUTRAL_SPECIAL_ACTION_ID)
						crouchBufferableCmd=true
					inputManager.Command.CMD_BACKWARD_SPECIAL,inputManager.Command.CMD_COUNTER_RIPOST_BACKWARD_SPECIAL:
						if not my_is_on_floor():
							#commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_SPECIAL_ACTION_ID,inputManager.Command.CMD_NEUTRAL_SPECIAL)
							commandConsummed = handleAirSpecialAttackInput(facingCmd,inputManager.Command.CMD_NEUTRAL_SPECIAL)
						else:
							###############################
							########ALPHA LOGIC###########
							###############################		
							#note this logic can be dropped once entire movesets are complete
							#var reMappedCmd = facingCmd
							#do we map non-existing move to neutral?
							#if actionAnimeManager.BACKWARD_SPECIAL_ACTION_ID == actionAnimeManager.NEUTRAL_SPECIAL_ACTION_ID:
							#	reMappedCmd = inputManager.Command.CMD_NEUTRAL_SPECIAL
							#commandConsummed= playUserInputAction(actionAnimeManager.BACKWARD_SPECIAL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))
							commandConsummed = handleGroundSpecialAttackInput(facingCmd,actionAnimeManager.BACKWARD_SPECIAL_ACTION_ID)
							
							if commandConsummed:
								pass
						crouchBufferableCmd=true
					inputManager.Command.CMD_FORWARD_SPECIAL,inputManager.Command.CMD_COUNTER_RIPOST_FORWARD_SPECIAL:
						if not my_is_on_floor():
							#commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_SPECIAL_ACTION_ID,inputManager.Command.CMD_NEUTRAL_SPECIAL)
							commandConsummed = handleAirSpecialAttackInput(facingCmd,inputManager.Command.CMD_NEUTRAL_SPECIAL)
						else:
							###############################
							########ALPHA LOGIC###########
							###############################		
							#note this logic can be dropped once entire movesets are complete
							#var reMappedCmd = facingCmd
							#do we map non-existing move to neutral?
							#if actionAnimeManager.FORWARD_SPECIAL_ACTION_ID == actionAnimeManager.NEUTRAL_SPECIAL_ACTION_ID:
							#	reMappedCmd = inputManager.Command.CMD_NEUTRAL_SPECIAL
							#commandConsummed= playUserInputAction(actionAnimeManager.FORWARD_SPECIAL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))
							commandConsummed = handleGroundSpecialAttackInput(facingCmd,actionAnimeManager.FORWARD_SPECIAL_ACTION_ID)
						crouchBufferableCmd=true
					inputManager.Command.CMD_DOWNWARD_SPECIAL,inputManager.Command.CMD_COUNTER_RIPOST_DOWNWARD_SPECIAL:
						if not my_is_on_floor():
							#commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_SPECIAL_ACTION_ID,inputManager.Command.CMD_NEUTRAL_SPECIAL)
							commandConsummed = handleAirSpecialAttackInput(facingCmd,inputManager.Command.CMD_NEUTRAL_SPECIAL)
						else:
							###############################
							########ALPHA LOGIC###########
							###############################		
							#note this logic can be dropped once entire movesets are complete
							#var reMappedCmd = facingCmd
							#do we map non-existing move to neutral?
							#if actionAnimeManager.DOWNWARD_SPECIAL_ACTION_ID == actionAnimeManager.NEUTRAL_SPECIAL_ACTION_ID:
						#		reMappedCmd = inputManager.Command.CMD_NEUTRAL_SPECIAL
						#	commandConsummed= playUserInputAction(actionAnimeManager.DOWNWARD_SPECIAL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))
							commandConsummed = handleGroundSpecialAttackInput(facingCmd,actionAnimeManager.DOWNWARD_SPECIAL_ACTION_ID)
						crouchBufferableCmd=true
					inputManager.Command.CMD_UPWARD_SPECIAL,inputManager.Command.CMD_COUNTER_RIPOST_UPWARD_SPECIAL:
						if not my_is_on_floor():
							#commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_SPECIAL_ACTION_ID,inputManager.Command.CMD_NEUTRAL_SPECIAL)
							commandConsummed = handleAirSpecialAttackInput(facingCmd,inputManager.Command.CMD_NEUTRAL_SPECIAL)
						else:
							###############################
							########ALPHA LOGIC###########
							###############################		
							#note this logic can be dropped once entire movesets are complete
							#var reMappedCmd = facingCmd
							#do we map non-existing move to neutral?
							#if actionAnimeManager.UPWARD_SPECIAL_ACTION_ID == actionAnimeManager.NEUTRAL_SPECIAL_ACTION_ID:
							#	reMappedCmd = inputManager.Command.CMD_NEUTRAL_SPECIAL
							#commandConsummed= playUserInputAction(actionAnimeManager.UPWARD_SPECIAL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))
							commandConsummed = handleGroundSpecialAttackInput(facingCmd,actionAnimeManager.UPWARD_SPECIAL_ACTION_ID)
						crouchBufferableCmd=true
					inputManager.Command.CMD_NEUTRAL_TOOL,inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL:
						if not my_is_on_floor():
							#commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_TOOL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(facingCmd))
							commandConsummed = handleAirToolAttackInput(facingCmd,inputManager.counterRipostCmdToBaseCmd(facingCmd))
						else:
							#commandConsummed= playUserInputAction(actionAnimeManager.NEUTRAL_TOOL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(facingCmd))
							commandConsummed = handleGroundToolAttackInput(facingCmd,actionAnimeManager.NEUTRAL_TOOL_ACTION_ID)
						crouchBufferableCmd=true
					inputManager.Command.CMD_BACKWARD_TOOL,inputManager.Command.CMD_COUNTER_RIPOST_BACKWARD_TOOL:
						if not my_is_on_floor():
							#commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_TOOL_ACTION_ID,inputManager.Command.CMD_NEUTRAL_TOOL)
							commandConsummed = handleAirToolAttackInput(facingCmd,inputManager.Command.CMD_NEUTRAL_TOOL)
						else:
							###############################
							########ALPHA LOGIC###########
							###############################		
							#note this logic can be dropped once entire movesets are complete
							#var reMappedCmd = facingCmd
							#do we map non-existing move to neutral?
							#if actionAnimeManager.BACKWARD_TOOL_ACTION_ID == actionAnimeManager.NEUTRAL_TOOL_ACTION_ID:
							#	reMappedCmd = inputManager.Command.CMD_NEUTRAL_TOOL
							#commandConsummed= playUserInputAction(actionAnimeManager.BACKWARD_TOOL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))
							commandConsummed = handleGroundToolAttackInput(facingCmd,actionAnimeManager.BACKWARD_TOOL_ACTION_ID)
														
						crouchBufferableCmd=true
					inputManager.Command.CMD_FORWARD_TOOL,inputManager.Command.CMD_COUNTER_RIPOST_FORWARD_TOOL:
						if not my_is_on_floor():
							#commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_TOOL_ACTION_ID,inputManager.Command.CMD_NEUTRAL_TOOL)
							commandConsummed = handleAirToolAttackInput(facingCmd,inputManager.Command.CMD_NEUTRAL_TOOL)
						else:
							###############################
							########ALPHA LOGIC###########
							###############################		
							#note this logic can be dropped once entire movesets are complete
							#var reMappedCmd = facingCmd
							#do we map non-existing move to neutral?
							#if actionAnimeManager.FORWARD_TOOL_ACTION_ID == actionAnimeManager.NEUTRAL_TOOL_ACTION_ID:
							#	reMappedCmd = inputManager.Command.CMD_NEUTRAL_TOOL
							#commandConsummed= playUserInputAction(actionAnimeManager.FORWARD_TOOL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))
							commandConsummed = handleGroundToolAttackInput(facingCmd,actionAnimeManager.FORWARD_TOOL_ACTION_ID)
						crouchBufferableCmd=true
					inputManager.Command.CMD_DOWNWARD_TOOL,inputManager.Command.CMD_COUNTER_RIPOST_DOWNWARD_TOOL:
						if not my_is_on_floor():
							#commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_TOOL_ACTION_ID,inputManager.Command.CMD_NEUTRAL_TOOL)
							commandConsummed = handleAirToolAttackInput(facingCmd,inputManager.Command.CMD_NEUTRAL_TOOL)
						else:
							###############################
							########ALPHA LOGIC###########
							###############################		
							#note this logic can be dropped once entire movesets are complete
							#var reMappedCmd = facingCmd
							#do we map non-existing move to neutral?
							#if actionAnimeManager.DOWNWARD_TOOL_ACTION_ID == actionAnimeManager.NEUTRAL_TOOL_ACTION_ID:
							#	reMappedCmd = inputManager.Command.CMD_NEUTRAL_TOOL
							#commandConsummed= playUserInputAction(actionAnimeManager.DOWNWARD_TOOL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))
							commandConsummed = handleGroundToolAttackInput(facingCmd,actionAnimeManager.DOWNWARD_TOOL_ACTION_ID)
							
						crouchBufferableCmd=true
					inputManager.Command.CMD_GRAB:#raw input grab from right stick
						if not cantGrab:					
							#if not playerState.isGrabOnCooldown:
							if not playerState.isGrabOnCooldownCheck():
		
								#only allow grabbing on ground
								if my_is_on_floor():
									commandConsummed= playUserInputAction(actionAnimeManager.GROUND_GRAB_ACTION_ID,facingCmd)
								else:
									#can only grab if weren't not prevented frome air grabbing
									if not preventGrabInAir:
										commandConsummed= playUserInputAction(actionAnimeManager.AIR_GRAB_ACTION_ID,facingCmd)
									else:
										commandConsummed=false
						else:
							commandConsummed=false	
						crouchBufferableCmd=true														
					inputManager.Command.CMD_UPWARD_TOOL,inputManager.Command.CMD_COUNTER_RIPOST_UPWARD_TOOL:
						if not my_is_on_floor():
							#commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_TOOL_ACTION_ID,inputManager.Command.CMD_NEUTRAL_TOOL)
							commandConsummed = handleAirToolAttackInput(facingCmd,inputManager.Command.CMD_NEUTRAL_TOOL)
						else:
							###############################
							########ALPHA LOGIC###########
							###############################		
							#note this logic can be dropped once entire movesets are complete
							#var reMappedCmd = facingCmd
							#do we map non-existing move to neutral?
							#if actionAnimeManager.UPWARD_TOOL_ACTION_ID == actionAnimeManager.NEUTRAL_TOOL_ACTION_ID:
							#	reMappedCmd = inputManager.Command.CMD_NEUTRAL_TOOL
							#commandConsummed= playUserInputAction(actionAnimeManager.UPWARD_TOOL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))
							commandConsummed = handleGroundToolAttackInput(facingCmd,actionAnimeManager.UPWARD_TOOL_ACTION_ID)

						crouchBufferableCmd=true
					
					inputManager.Command.CMD_BUFFERED_PUSH_BLOCK: #special command that only results from being buffered (can't be raw input (ai might be able to)
						#try to autocancel into 
						commandConsummed = attemptPushBlock(facingCmd)
	
					#inputManager.Command.CMD_BACKWARD_CROUCH_PUSH_BLOCK:
					#	commandConsummed = handleBackPushBlockCmd(facingCmd)
					#	if not commandConsummed:
							
							#only buffer the push block if blocking, otherwise buffer the ability cancel
					#		if guardHandler.isInHoldBackBlockAnimation():
								
								#make sure to buffer the bush block and avoid buffering movement-tied pushblock command
					#			facingCmd = inputManager.Command.CMD_BUFFERED_PUSH_BLOCK
					#		else:
					#			facingCmd = inputManager.Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE
					#		cmd=facingCmd
					inputManager.Command.CMD_BACKWARD_CROUCH_PUSH_BLOCK,inputManager.Command.CMD_BACKWARD_PUSH_BLOCK,inputManager.Command.CMD_BACKWARD_UP_PUSH_BLOCK:
						commandConsummed = handleBackPushBlockCmd(facingCmd)
						if not commandConsummed:
							
							#only buffer the push block if blocking, otherwise buffer the ability cancel
							if guardHandler.isInHoldBackBlockAnimation():
								
								#make sure to buffer the bush block and avoid buffering movement-tied pushblock command
								facingCmd = inputManager.Command.CMD_BUFFERED_PUSH_BLOCK
							else:
								facingCmd = inputManager.Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE
							cmd=facingCmd					
					inputManager.Command.CMD_FORWARD_CROUCH_PUSH_BLOCK,inputManager.Command.CMD_FORWARD_PUSH_BLOCK,inputManager.Command.CMD_FORWARD_UP_PUSH_BLOCK:
						commandConsummed = handleForwardPushBlockCmd(facingCmd)
						if not commandConsummed:
							
							#only buffer the push block if blocking, otherwise buffer the ability cancel
							if guardHandler.isInHoldBackBlockAnimation():
								
								#make sure to buffer the bush block and avoid buffering movement-tied pushblock command
								facingCmd = inputManager.Command.CMD_BUFFERED_PUSH_BLOCK
							else:
								facingCmd = inputManager.Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE
							cmd=facingCmd	
						#if not commandConsummed:
							#make sure ability cancel will be buffered
						#	facingCmd = inputManager.Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE
						#	cmd=facingCmd
					
					
					inputManager.Command.CMD_UP:  #ignore command up, it doesn nothing
						commandConsummed = handleUserInputNullCommand(crouching,facingCmd)
						#does nothing other tahn notify grab handler of DI input					
						pass
						
					#inputManager.Command.CMD_RELEASED_GRAB:
					#	var diEnum = inputManager.getLastDirectinalInput(kinbody.facingRight)
					#	grabHandler._on_grab_input_released(diEnum)
						
					null: #uncrouch, stop holding right, stop holding left
						
						commandConsummed = handleUserInputNullCommand(crouching,facingCmd)
									
	
	
				
				#below should make it so u can buffer attack after uncrouch but it fails. I am also unsure if you
				# can buffer a command before going into grond idle (test with get up dp)
				#did our input get eating since were crouching and it doens't autocancel?
				if crouching and not commandConsummed and crouchBufferableCmd:
					#uncrouch
					playAction(actionAnimeManager.UNCROUCH_ACTION_ID)
					commandConsummed = true	
					preventCounterRipost=true
				#	#only buffer the rawinput (not the buffered input), may want to considered buffered, but we shall see how it feels
					if not bufferedInputFlag:
						
						#if not isCounterRipostCmd:
			
						inputManager.storeBufferableCommandInBuffer(cmd)				
						#else:
							#were counter riposting, so store the counter ripost command
						#	inputManager.storeBufferableCommandInBuffer(counterRipostCmd)
							
					
					#clear the flag, we handled the counter ripost input
					#isCounterRipostCmd=false
					
					#buffer the command manually so when uncrouch done, command is attempted
				#buffered a command, and it didn't play, and we don't have any animation at the moment?
				if not commandConsummed and  actionAnimeManager.spriteAnimationManager.currentAnimation == null:
					
					#only go idle when game isn't ending
					if not gameEndingStun:
						#no input, go to idle state if possible
						if my_is_on_floor():
							
							#is slide enabled when entering ground idle this frame?
							if enableSlidingGroundIdle:
								playUserInputAction(actionAnimeManager.SLIDING_GROUND_IDLE_ACTION_ID,facingCmd)	
							else:
								playUserInputAction(actionAnimeManager.GROUND_IDLE_ACTION_ID,facingCmd)
							
							
						else:
							
							
							#is slide enabled when entering air idle this frame?
							#if enableSlidingGroundIdle:
							#	playUserInputAction(actionAnimeManager.SLIDING_GROUND_IDLE_ACTION_ID,facingCmd)	
							
							playUserInputAction(actionAnimeManager.AIR_IDLE_ACTION_ID,facingCmd)
							
							
							
					else:
						#game ending, so victim goes stun instead of idle
						goIntoVulnerableStunState(END_MATCH_LOSER_STUN_DURATION) 
						
			else:
				
				if actionAnimeManager.spriteAnimationManager.currentAnimation == null:
					if gameEndingStun:
						#game ending, so victim goes stun instead of idle
						goIntoVulnerableStunState(END_MATCH_LOSER_STUN_DURATION) 
					
					
				#only go idle when game isn't ending
				if not gameEndingStun:
					
				
					
					#no input, go to idle state if possible
					if my_is_on_floor():
						#is slide enabled when entering ground idle this frame?
						if enableSlidingGroundIdle:
							playUserInputAction(actionAnimeManager.SLIDING_GROUND_IDLE_ACTION_ID,facingCmd)	
						else:
							playUserInputAction(actionAnimeManager.GROUND_IDLE_ACTION_ID,facingCmd)
						
					else:
						playUserInputAction(actionAnimeManager.AIR_IDLE_ACTION_ID,facingCmd)
				
					
					
					
			#end command is not null
		#end if not in hit stun and end not ripost command
	#comand consumed?
	if not commandConsummed:
		#only buffer the rawinput (not the buffered input)
		if not bufferedInputFlag:		
							
			inputManager.storeBufferableCommandInBuffer(cmd)


	else:
		
		#we used the buffered input?
		if bufferedInputFlag:
			#print("used buffered input")
			inputManager.eraseBufferedCommand()
			
		
		
		#Some states prevent counter ripost input from being processed
		#like when buffering in a non-courch attack when crouched (have to uncrouch first)
		if not preventCounterRipost:
			
			#are we trying to counter ripost?
			if inputManager.isCounterRipostCommand(facingCmd):	
			
				var sa = actionAnimeManager.getCurrentSpriteAnimation()
				var customCounterRipostWindowDuration = -1
				
				if sa != null:
					customCounterRipostWindowDuration =sa.customCounterRipostWindowDuration
					
				
				newCounterRipostHandler.attemptCounterRipost(preProcessCounterRipostCmd(facingCmd),customCounterRipostWindowDuration)
				
		
		#did we override ripost with counter ripost?
			
		if attemptCounterRipostOverridedRipost:
			#override the ripost
			ripostHandler.stopRipostWindow()

#hook for subclasses to change the counter ripost command
#for special stances where some DI + attack input just do neutral, for example
#(like hat sprinter stance attacsK0
func preProcessCounterRipostCmd(facingCounterRipostCmd):
	return facingCounterRipostCmd
#we implement this in a function to allow subclasses to have custom arial attacks
func handleAirMeleeAttackInput(actualCmd,treatAsCmd):
	var commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_MELEE_ACTION_ID,treatAsCmd)
	return commandConsummed
	
func handleAirSpecialAttackInput(actualCmd,treatAsCmd):
	var commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_SPECIAL_ACTION_ID,treatAsCmd)
	return commandConsummed	

func handleAirToolAttackInput(actualCmd,treatAsCmd):
	var commandConsummed = playUserInputAction(actionAnimeManager.AIR_NEUTRAL_TOOL_ACTION_ID,treatAsCmd)
	return commandConsummed
	

#we implement this in a function to allow subclasses to have custom ground attacks
func handleGroundMeleeAttackInput(actualCmd,expectedActionId):
	var commandConsummed=false
	var reMappedCmd = actualCmd
	#do we map non-existing move to neutral?
	if expectedActionId == actionAnimeManager.NEUTRAL_MELEE_ACTION_ID:
		reMappedCmd = inputManager.Command.CMD_NEUTRAL_MELEE
									
	commandConsummed = playUserInputAction(expectedActionId,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))

	return commandConsummed						

func handleGroundSpecialAttackInput(actualCmd,expectedActionId):
	var commandConsummed=false
	var reMappedCmd = actualCmd
	#do we map non-existing move to neutral?
	if expectedActionId == actionAnimeManager.NEUTRAL_SPECIAL_ACTION_ID:
		reMappedCmd = inputManager.Command.CMD_NEUTRAL_SPECIAL
									
	commandConsummed = playUserInputAction(expectedActionId,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))

	return commandConsummed						

func handleGroundToolAttackInput(actualCmd,expectedActionId):
	var commandConsummed=false
	var reMappedCmd = actualCmd
	#do we map non-existing move to neutral?
	if expectedActionId == actionAnimeManager.NEUTRAL_TOOL_ACTION_ID:
		reMappedCmd = inputManager.Command.CMD_NEUTRAL_TOOL
									
	commandConsummed = playUserInputAction(expectedActionId,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))

	return commandConsummed						
	
		
func handleDirectionalInput():
	
	var diEnum = inputManager.getLastDirectinalInput(kinbody.facingRight)
	#grabHandler._on_directional_input(diEnum)
	var grabDI =inputManager.getLastGrabDirectinalInput(kinbody.facingRight)
	grabHandler._on_grab_input_released(grabDI)
	
	#are we preventing tech's that have directional momentuM?
	if preventDITech:
		
		#force neutral tech 
		techHandler._on_directional_input(GLOBALS.DirectionalInput.NEUTRAL)
	else:
		techHandler._on_directional_input(diEnum)
		
	guardHandler._on_directional_input(diEnum)
	negativePenaltyTracker._on_directional_input(diEnum)
	
				
#processes the forward dash ommand logic, returnign true if command consummed and false othersie		
func handleDashForwardCmd(facingCmd):
	var commandConsummed = false
	if not my_is_on_floor():
		#if playerState.currentNumJumps > 0:
		if playerState.hasAirDashe == true and not preventAirDashing:
			
			#special condition where can't cahnge facing ?
			if mirrorAirActionDIRequired():
				commandConsummed = playUserInputAction(actionAnimeManager.AIR_DASH_BACKWARD_ACTION_ID,facingCmd)
			else:						
				commandConsummed = playUserInputAction(actionAnimeManager.AIR_DASH_FORWARD_ACTION_ID,facingCmd)
			if commandConsummed:
				#playerState.countJump()
				playerState.hasAirDashe =false
				if commandConsummed:
					emit_signal("air_dashed",GLOBALS.AirDashType.FORWARD)
	else:
		
		if not preventGroundDashing:
			commandConsummed = playUserInputAction(actionAnimeManager.GROUND_FORWARD_DASH_ACTION_ID,facingCmd)
			
			#did we fail to dash back? maybe can only do a non-crouch cancelable dash back
			if not commandConsummed:
				commandConsummed = playUserInputAction(actionAnimeManager.NON_CROUCH_CANCELABLED_F_GROUND_DASH_ACTION_ID,facingCmd)
			
			if commandConsummed:
				emit_signal("ground_dashed",GLOBALS.AirDashType.FORWARD)
				
		else:
			commandConsummed=false
	return commandConsummed

func handleDashBackwardCmd(facingCmd):
	var commandConsummed = false 
	if not my_is_on_floor():
		#if playerState.currentNumJumps > 0:
		if playerState.hasAirDashe == true and not preventAirDashing:
			
			#special condition where can't cahnge facing ?
			if mirrorAirActionDIRequired():
				commandConsummed = playUserInputAction(actionAnimeManager.AIR_DASH_FORWARD_ACTION_ID,facingCmd)
			else:
				commandConsummed = playUserInputAction(actionAnimeManager.AIR_DASH_BACKWARD_ACTION_ID,facingCmd)
			if commandConsummed:
				#playerState.countJump()
				playerState.hasAirDashe =false
				emit_signal("air_dashed",GLOBALS.AirDashType.BACKWARD)
	else:
		
		if not preventGroundDashing:
			commandConsummed = playUserInputAction(actionAnimeManager.GROUND_BACKWARD_DASH_ACTION_ID,facingCmd)
			
			#did we fail to dash back? maybe can only do a non-crouch cancelable dash back
			if not commandConsummed:
				commandConsummed = playUserInputAction(actionAnimeManager.NON_CROUCH_CANCELABLED_B_GROUND_DASH_ACTION_ID,facingCmd)

			if commandConsummed:
				emit_signal("ground_dashed",GLOBALS.AirDashType.BACKWARD)	
		else:
			commandConsummed=false
			
	return commandConsummed
func handleJumpCommand(facingCmd):
	var commandConsummed = false
	if playerState.currentNumJumps > 0:
		#try to jump
		
		if my_is_on_floor():
			commandConsummed=playUserInputAction(actionAnimeManager.JUMP_ACTION_ID,facingCmd)
			
			#jump didn't work? maybe only jump cancelable into a non-dash-cancelable jump
			if not commandConsummed:
				commandConsummed=playUserInputAction(actionAnimeManager.NON_GND_DASH_CANCELABLE_JUMP_ACTION_ID,facingCmd)
		else:
			
			var usedAcroABCancelExtraJumpFlag=false
			#are we left with only jumps gained from ability canceling in 
			#air from acrobatics advantage prof?
			if acroABCancelExtraJumpCheck():
				
				#enough bar to extra jump?
				if playerState.hasEnoughAbilityBar(acroABCancelExtraJumpBarCost):
					usedAcroABCancelExtraJumpFlag=true							
					commandConsummed=playUserInputAction(actionAnimeManager.AIR_JUMP_ACTION_ID,facingCmd)
				else:
					emit_signal("insufficient_ability_bar",acroABCancelExtraJumpBarCost*playerState.abilityChunkSize)
					commandConsummed=false
			else:
				#jump normally
				commandConsummed=playUserInputAction(actionAnimeManager.AIR_JUMP_ACTION_ID,facingCmd)
			
			#we jumped back using extra acro jump?
			if usedAcroABCancelExtraJumpFlag and commandConsummed:
				playerState.forceConsumeAbilityBarInChunks(acroABCancelExtraJumpBarCost)
									
			
		#double jumped? that is, was in the air and jumped?
		#the main process function handles consumming a jump when leaving the ground
		#if commandConsummed and playerState.wasInAir:
		if commandConsummed and not my_is_on_floor():

			playerState.countJump(recoverAirDashOnJump)
			emit_signal("jumped")
		
	return commandConsummed
						
	
	
func acroABCancelExtraJumpCheck():
	return playerState.numAcroABCancelExtraJumps>=1 and  playerState.currentNumJumps==playerState.numAcroABCancelExtraJumps


#processes the crouch when on ground command logic, returnign true if command consummed and false othersie		
func handleCrouchCmdOnGround(facingCmd):
	var commandConsummed = playUserInputAction(actionAnimeManager.CROUCH_ACTION_ID,facingCmd)

	#failed to crouch? 
	if not commandConsummed:
		
		commandConsummed = handleCrouchCancel(facingCmd)

						
	return commandConsummed
	
func handleCrouchCancel(facingCmd):
	var commandConsummed =false
	var groundDashingRight  =actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.GROUND_FORWARD_DASH_ACTION_ID)
	var groundDashingLeft  =actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.GROUND_BACKWARD_DASH_ACTION_ID)
	
	
	
	
	#maybe then this animation is crouch cancelable instead 
	if groundDashingRight:
		commandConsummed = playUserInputAction(actionAnimeManager.FORWARD_GROUND_DASH_CANCEL_RECOVERY_ACTION_ID,facingCmd)		
	elif groundDashingLeft:
		commandConsummed = playUserInputAction(actionAnimeManager.BACK_GROUND_DASH_CANCEL_RECOVERY_ACTION_ID,facingCmd)		
	else:
		commandConsummed = playUserInputAction(actionAnimeManager.BASIC_CROUCH_CANCEL_ACTION_ID,facingCmd)		
		
	if commandConsummed:
		_on_request_play_special_sound(GROUND_DASH_CANCEL_SOUND_ID,COMMON_SOUND_SFX)			
		if groundDashingRight:			
			emit_signal("ground_dash_cancel",GLOBALS.AirDashType.FORWARD)
		elif groundDashingLeft:
			emit_signal("ground_dash_cancel",GLOBALS.AirDashType.BACKWARD)
		else:
			#a spaecial case of croud cancel, ignore
			pass
			
	return commandConsummed
#processes the move forward command logic, returnign true if command consummed and false othersie		
func handleMoveForwardCmd(facingCmd):
	
	var commandConsummed = false
	if not my_is_on_floor():
			
		#special condition where can't cahnge facing ?
		if mirrorAirActionDIRequired():
			commandConsummed = playUserInputAction(actionAnimeManager.AIR_MOVE_BACKWARD_ACTION_ID,facingCmd)
		else:	
			commandConsummed = playUserInputAction(actionAnimeManager.AIR_MOVE_FORWARD_ACTION_ID,facingCmd)
	else:
		commandConsummed =playUserInputAction(actionAnimeManager.GROUND_MOVE_FORWARD_ACTION_ID,facingCmd)
		
	return commandConsummed
							
#processes the move cback command logic, returnign true if command consummed and false othersie		
func handleMoveBackwardCmd(facingCmd):
	var commandConsummed = false
	if not my_is_on_floor():
		
		#inside proximity of incoming hitbox?
		if collisionHandler.isProximityGuardEnabled():
			
			
			commandConsummed = playUserInputAction(actionAnimeManager.PROXIMITY_GUARD_AIR_HOLD_BACK_BLOCK_ACTION_ID,facingCmd)
						
			#failed to block (ie, not in blockable animation?)
			if not commandConsummed:
				#try to move backward instead
				
				#special condition where can't cahnge facing ?
				if mirrorAirActionDIRequired():
					commandConsummed = playUserInputAction(actionAnimeManager.AIR_MOVE_FORWARD_ACTION_ID,facingCmd)
				else:
					commandConsummed = playUserInputAction(actionAnimeManager.AIR_MOVE_BACKWARD_ACTION_ID,facingCmd)
		else:
			
			#handle the case where we were block ing the air, and the proximity area left, and were stil holding back
			#wan't to break free from the block animation in air
			if actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_AIR_HOLD_BACK_BLOCK_ACTION_ID):
				#make sure to go idle before walking back
				#$although command consumed flag override
				playUserInputAction(actionAnimeManager.AIR_IDLE_ACTION_ID,facingCmd)
				
			#there is no hitbox active and nearby?
			
			#special condition where can't cahnge facing ?
			if mirrorAirActionDIRequired():
				commandConsummed = playUserInputAction(actionAnimeManager.AIR_MOVE_FORWARD_ACTION_ID,facingCmd)
			else:
				
				commandConsummed = playUserInputAction(actionAnimeManager.AIR_MOVE_BACKWARD_ACTION_ID,facingCmd)
		
	else:
	
		
		#inside proximity of incoming hitbox?
		if collisionHandler.isProximityGuardEnabled():
			
			
			#try to standing block in aire
			commandConsummed = playUserInputAction(actionAnimeManager.PROXIMITY_GUARD_STANDING_HOLD_BACK_BLOCK_ACTION_ID,facingCmd)
			
			
			#failed to block (ie, not in blockable animation?)
			if not commandConsummed:
				#try to move backward instead
				commandConsummed = playUserInputAction(actionAnimeManager.GROUND_MOVE_BACKWARD_ACTION_ID,facingCmd)
		else:
			#there is no hitbox active and nearby?
				commandConsummed = playUserInputAction(actionAnimeManager.GROUND_MOVE_BACKWARD_ACTION_ID,facingCmd)
	return commandConsummed
	
func handleUserInputNullCommand(crouching,facingCmd):
	var commandConsummed =null
	if not playerState.inHitStun:
		
		#this is so that ghost ai agent doesn't  spazz out when not input
		#if nullCommandStopsWalkingFlag:
		if not my_is_on_floor():
			
			
			if (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.AIR_MOVE_FORWARD_ACTION_ID)) or (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.AIR_MOVE_BACKWARD_ACTION_ID)):
				commandConsummed = playUserInputAction(actionAnimeManager.AIR_MOVE_STOP_ACTION_ID,facingCmd)
			elif (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.AIR_MOVE_FORWARD_ACTION_ID)) or (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.AIR_MOVE_BACKWARD_ACTION_ID)):
				commandConsummed = playUserInputAction(actionAnimeManager.AIR_MOVE_STOP_ACTION_ID,facingCmd)
			elif actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_AIR_HOLD_BACK_BLOCK_ACTION_ID):
				commandConsummed = playUserInputAction(actionAnimeManager.AIR_IDLE_ACTION_ID,facingCmd)				
		else:		
		#this is special case where we didn't press anything. So, to avoid bugs and
			#to make sure the bots/ai don't act with impossible inputs, we will check
			#if we are walking forward, backwarwa, crouching, and backward crouching
			#because, to do those animations, you have to hold a button. Null input means
			# we missed the button release signal/command to stop it
			
			if (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.GROUND_MOVE_FORWARD_ACTION_ID)) or (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.GROUND_MOVE_BACKWARD_ACTION_ID)):
				commandConsummed = playUserInputAction(actionAnimeManager.GROUND_IDLE_ACTION_ID,facingCmd)					
			elif (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.GROUND_MOVE_FORWARD_ACTION_ID)) or (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.GROUND_MOVE_BACKWARD_ACTION_ID)):
				commandConsummed = playUserInputAction(actionAnimeManager.GROUND_IDLE_ACTION_ID,facingCmd)

			elif actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_STANDING_HOLD_BACK_BLOCK_ACTION_ID):
				commandConsummed = playUserInputAction(actionAnimeManager.GROUND_IDLE_ACTION_ID,facingCmd)
		#missed the uncrouch butotn release?
		if crouching:
				#commandConsummed = playUserInputAction(actionAnimeManager.UNCROUCH_ACTION_ID,facingCmd)
				#force the uncrouch. no need for autocancel check, cause by design, when crouching, u
				#must uncrouch when releasing down
				playActionKeepOldCommand(actionAnimeManager.UNCROUCH_ACTION_ID)
				commandConsummed = true						
		
	return commandConsummed


func  handleAbilityCancelCmd():
	
	var commandConsummed = false


	var rc = cancelAnimation(inputManager.Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE)
	
	#did we fali to cancel because of not cancelable
	#or are we in hitfreeze?
	# maybe can cancel next frame... when cancelable or not in hitfreeze?
	if rc == CANCEL_FAILED_FRAME_UNCANCELABLE_RC or rc == CANCEL_FAILED_PAUSED_RC:
		#buffer the cancle, 
		commandConsummed = false
	else:
		#and otheriwse we drop the cancel commdand
		#cause we either succeeded in cancel or didin't have enough
		#bar.
		commandConsummed = true
		isBarCanceling = true
			
	return commandConsummed
	

func handleForwardPushBlockCmd(facingCmd):
		
	#forward+ L2/left trigger isn't anything special.
	#to treat it as an ability cancel, and other wise aon fail treat it as walking forward
	
	#var commandConsummed = handleAbilityCancelCmd()
	
#	if not commandConsummed:
#		commandConsummed = handleMoveForwardCmd(facingCmd)
		
#	return commandConsummed

#try to autocancel into 
	var commandConsummed = attemptPushBlock(facingCmd)
	
	# failed pushed blocked?
	if not commandConsummed:

	
		#can't autocancel push block here, or don't have the resources
		
		#try an ability cancel instead (backward melee + ablity cancel woul be example where push block obviously doesn't work)
		commandConsummed = handleAbilityCancelCmd()
		
		#failed to ability cancel as well?
		if not commandConsummed:
		
				#try simply moving back
		
			#in any case, ingore the ability cancel input part of command 
			#and treat is as holding forward
		
			commandConsummed = handleMoveForwardCmd(facingCmd)
	
	
	return commandConsummed
	
	
func handleBackPushBlockCmd(facingCmd):
	
	#try to autocancel into 
	var commandConsummed = attemptPushBlock(facingCmd)
	
	# failed pushed blocked?
	if not commandConsummed:

	
		#can't autocancel push block here, or don't have the resources
		
		#try an ability cancel instead (backward melee + ablity cancel woul be example where push block obviously doesn't work)
		commandConsummed = handleAbilityCancelCmd()
		
		#failed to ability cancel as well?
		if not commandConsummed:
		
				#try simply moving back
		
			#in any case, ingore the ability cancel input part of command 
			#and treat is as holding back
		
			commandConsummed = handleMoveBackwardCmd(facingCmd)
	
	
	return commandConsummed
		
	
	
func enableUserInput(affectInptuMngrPhysicsProcFlag=true):
	inputManager.reset()
	

	if affectInptuMngrPhysicsProcFlag:
		inputManager.set_physics_process(true)
	
	var changedFlag = ignoreUserInputFlag
	ignoreUserInputFlag = false
	
	if changedFlag:
		emit_signal("userInputEnabledChange",not ignoreUserInputFlag)

func disableUserInput(affectInptuMngrPhysicsProcFlag=true):
	inputManager.reset()
	if affectInptuMngrPhysicsProcFlag:
		inputManager.set_physics_process(false)
	var changedFlag = not ignoreUserInputFlag
	ignoreUserInputFlag = true
	if changedFlag:
		emit_signal("userInputEnabledChange",not ignoreUserInputFlag)
#returns true when playig given action id will cause player
#to remain without a sprite animation
#func checkForNullSpriteAnimationState(actionId):
	
#	var actionIsSpriteAnimationless = actionAnimeManager.hasSpriteAnimation(actionId)
	
#	var noCurrentSpriteAnimation = actionAnimeManager.spriteAnimationManager.currentAnimation == null
	
#	return actionIsSpriteAnimationless and noCurrentSpriteAnimation
		
			
#uses up the block cooldown
#func startBlockCooldown():
	#playerState.isBlockOnCooldown = true
	
	#blockCooldownTimer.startInSeconds(blockCooldownTime) #convert to # of frames

#usues up the anti block cooldown
#func startAntiBlockCooldown():
	#playerState.isGrabOnCooldown = true
	
	#grabCooldownTimer.startInSeconds(grabCooldownTime)
	

#plays an action without worrying about check if cancels
func playAction(actionId):
	

	actionAnimeManager.playAction(actionId,kinbody.facingRight)
	
func playActionKeepOldCommand(actionId):
	var tmp = actionAnimeManager.commandActioned
	playAction(actionId)
	actionAnimeManager.commandActioned = tmp
	

#func checkAbilityBarCancelingReset(actionId):
	#don't reset it when aire movement action is used or any other action that doesn't change sprite
#	if actionAnimeManager.spriteAnimationLookup(actionId) == null:
#		return false
#	else:
#		return true
	
#param: actionId, id of action to execute if cancelable for current animation
#param: cmd: the command used to issue the action
#returns true when move canceled into something, and false when it didn't cancel
func playUserInputAction(actionId, cmd):
	
	
	var rc = null
	if actionId == actionAnimeManager.UNKNOWN_ACTION_ID:
		return false	
	
	
	#can't play user animations at the moement?
	#or the action trying to play isn't white listed when lock active?
	#if inputLockHandler.isActive():
	if not inputLockHandler.isValidActionId(actionId):
		return false
		
#	if inputLockHandler.isActive():
#		return false
	
	var animationPlayedFlag = false
	
	
	
	if	playerState.inHitStun or actionAnimeManager.playerPaused:
		animationPlayedFlag = false
	else:
		
		
		#we can proceed to play the movement action	
		if actionAnimeManager.isAutoCancelable(actionId):
			
			
			#didn't need to use ability bar to cancel into this move
			#playerState.abilityBarCanceling = false
			#if checkAbilityBarCancelingReset(actionId):
			#	playerState.abilityBarCanceling = false
			rc = actionAnimeManager.playUserAction(actionId,kinbody.facingRight,cmd)
			
			
			animationPlayedFlag = true
		 #were hitting at the momenment and it auto cancels on hit?
		#elif playerState.hittingWithJumpCancelHitBox and actionAnimeManager.isAutoCancelableOnHit(actionId):
		else:
			var ignoreOnHitWindow = true
			#see if we hit this animation (can't auto cancel on hit counter riposts?
			if actionAnimeManager.isSpriteFrameHittingOpponent(ignoreOnHitWindow) and not newCounterRipostHandler.counterRiposting:
				
				
				#we have, so now see if we can auto cancel with something
				#that can be canceled on hit for entire aniamtion
				if actionAnimeManager.isAutoCancelableOnHitAllAnimation(actionId):
					rc = actionAnimeManager.playUserAction(actionId,kinbody.facingRight,cmd)
					animationPlayedFlag = true
					
				else: 
					ignoreOnHitWindow = false
					#so now we check if still inside the hitting window for all other on hit cancel types
					if actionAnimeManager.isSpriteFrameHittingOpponent(ignoreOnHitWindow):
			
			
						#gatteling combo?
						if actionAnimeManager.isAutoCancelableOnHit(actionId):
						
						
							rc = actionAnimeManager.playUserAction(actionId,kinbody.facingRight,cmd)
							animationPlayedFlag = true
							
						#can't auto cancel but can ability auto cancel?
						elif actionAnimeManager.isAbilityAutoCancelableOnHit(actionId):
							
							var currentSpriteAnimation = actionAnimeManager.getCurrentSpriteAnimation()
							#auto ability cancel costs is based on how much it costs to manually
							#cancel the aniamtion
							
							#compute the cost that it would normally take to cancel thi move
#							var ignoreProfModCost = true
#							var avoidZeroCostForUncancelableAttacks = false# (grab required this)
#							var abilityCancelCost =_computeAbilityBarCancelCost(currentSpriteAnimation,ignoreProfModCost,avoidZeroCostForUncancelableAttacks)
							#do we apply the auto ability canceling tax fro being airborne?
#							if not my_is_on_floor():
								#abilityCancelCost = abilityCancelCost + airAbilityCancelCostInChunksTax#apply additional cost from being  in air
								
							#apply auto ability cancel cost mod
							var autoAbilityCancelCost =_computeAutoAbilityBarCancelCost(currentSpriteAnimation)
							autoAbilityCancelCost= max(1,autoAbilityCancelCost) #animation cancel is minimum 1 bar
							var enoughBarFlag = playerState.hasEnoughAbilityBar(autoAbilityCancelCost)
									
							if enoughBarFlag:
								
								rc = actionAnimeManager.playUserAction(actionId,kinbody.facingRight,cmd)
								animationPlayedFlag = true
								var spriteFrame = currentSpriteAnimation.getCurrentSpriteFrame()
								#playerState.consumeAbilityBar(abilityCancelCost)
								playerState.forceConsumeAbilityBarInChunks(autoAbilityCancelCost)
								var autoAbilityCancelFlag = true
								emit_signal("ability_cancel",autoAbilityCancelCost,spriteFrame,autoAbilityCancelFlag)
							else:
								emit_signal("insufficient_ability_bar",autoAbilityCancelCost*playerState.abilityChunkSize)
		#elif playerState.abilityBarCanceling:
			
		#	cancelAnimation=animationPlayedFlag(actionId)
	
	
	#did we attempt to play an animation that has no sprite animation while
	#the last sprite animation finished (is null)
	if rc == actionAnimeManager.RC_NULL_SPRITE_ANIMATION:
		
		#goto go into idle state, no choice
		if not my_is_on_floor():
				
			actionAnimeManager.playUserAction(actionAnimeManager.AIR_IDLE_ACTION_ID,kinbody.facingRight,cmd)
		else:
				
			#we don't want sliding, so make sure the movement doesn't last forever
			actionAnimeManager.playUserAction(actionAnimeManager.GROUND_IDLE_ACTION_ID,kinbody.facingRight,cmd)	
						
	if animationPlayedFlag:
		#emit_signal("cmd_action_changed",inputManager.getFacingDependantCommand(cmd,kinbody.facingRight))
		emit_signal("cmd_action_changed",cmd)
		
		#when a new animation begins, if we just canceled, we aren't anymore	
		isBarCanceling = false
	return animationPlayedFlag
	 
	
#attemtps to cancel current sprite frame using ability bar cancel
#return true when cancel was a success or there was not enought bar
# ie, true when command was consummed
#and false otherwise  if cannot cancel
func cancelAnimation(cmd):
	
	var rc = -1
	
	#ignore canceling if were paused
	if actionAnimeManager.playerPaused:
		return CANCEL_FAILED_PAUSED_RC
		
	#if inputLockHandler.isActive():
	#	return CANCEL_FAILED_FRAME_UNCANCELABLE_RC # can't cancel right now, input is locked (push block start, for example)
	#const CANCEL_SUCCESS_RC = 0
 	#const CANCEL_FAILED_NOT_ENOUGH_BAR_RC = 1
	#const CANCEL_FAILED_FRAME_UNCANCELABLE_RC = 2
	#lookup sprite animation that will be canceled into
	
	var currentSpriteAnimation = actionAnimeManager.getCurrentSpriteAnimation()
	
	if currentSpriteAnimation == null:
		#print("wanring: null sprite animatio in bar cancel function")
		return CANCEL_FAILED_FRAME_UNCANCELABLE_RC
	
	#do we have the proficiency that requires hitting to ability cancel (on-hit only)
	#to ability cancel, we must have hit opponent with the anaimtion we trying to cancel
	if abilityCancelOnHitOnly and not actionAnimeManager.isSpriteFrameHittingOpponentAnyHurtbox():
		
		return CANCEL_FAILED_FRAME_UNCANCELABLE_RC
	
	
	#don't let bar reduce mod reduce a 1 cost to 0 chunks
	
	var barCost = computeAbilityBarCancelCost(currentSpriteAnimation)
	
	
	#sprite frame before the ability cancel
	var spriteFrame = null
			
	#check to see if current animation allows bar canceling
	if currentSpriteAnimation.barCancelableble:
		
		spriteFrame = currentSpriteAnimation.getCurrentSpriteFrame()
		
		#now make sure current frame allows to be canceled
		if spriteFrame.barCancelable:
				
			
			
			
			var enoughBarFlag = playerState.hasEnoughAbilityBar(barCost)
				
			if enoughBarFlag:
				#playAction(actionId)
			#	actionAnimeManager.playUserAction(actionId,kinbody.facingRight,cmd)
				#ready to cancel next move
				
				rc =CANCEL_SUCCESS_RC
				
				
				dashCancelInputLockCheck(currentSpriteAnimation)
				
				
				if not my_is_on_floor():
					
					var sf = actionAnimeManager.spriteAnimationManager.getCurrentSpriteFrame()
					
					if sf != null:
						if sf.keepAirMomentumOnAbilityCancel:
							#freeze the time ellapse of movement to keep momentum 
							actionAnimeManager.movementAnimationManager.halthAnimationAndKeepArialMomentum()
					
				
				#we only trigger hitfreeze after hitting in a combo
				#to emphasize the cancel. canceling in neutral or whiff wont freeze game
				var ignoreOnHitWindow = true
				#see if we hit this animation (can't auto cancel on hit counter riposts?
				if actionAnimeManager.isSpriteFrameHittingOpponent(ignoreOnHitWindow):
					startHitFreezeNotification(currentSpriteAnimation.abilityCancelCostTypeToHitfreezeDuration())
		
				#make the animation finish so when ability cancel hit freeze stops, will use command in buffer
				#for next animation
				if currentSpriteAnimation!=null:
					
					#HERE, we should take the animation's sliding properties
					#and update the sliding ground idle movement SLIDING_GROUND_IDLE_ACTION_ID
					var groundSlideMvm = actionAnimeManager.mvmAnimationLookup(actionAnimeManager.SLIDING_GROUND_IDLE_ACTION_ID)
					
					var groundSlideBasicMvm=null
					var airOppGravBasicMvm=null
					if groundSlideMvm.complexMovements.size()>0:
						
						#ground sliding properties
						if groundSlideMvm.complexMovements[0].basicMovements.size()>0:	
							groundSlideBasicMvm=groundSlideMvm.complexMovements[0].basicMovements[0]
					
					var airSlideMvm = actionAnimeManager.mvmAnimationLookup(actionAnimeManager.SLIDING_AIR_IDLE_ACTION_ID)
					if airSlideMvm.complexMovements.size()>0:
						
						#ground sliding properties
						if airSlideMvm.complexMovements[0].basicMovements.size()>0:	
							airOppGravBasicMvm=airSlideMvm.complexMovements[0].basicMovements[0]
	
							
					if groundSlideBasicMvm!= null:						
						groundSlideBasicMvm.acceleration =currentSpriteAnimation.abCancelSlideDecceleration
						groundSlideBasicMvm.maxSpeed=currentSpriteAnimation.abCancelSlideMaxSpeed
					if airOppGravBasicMvm != null:
							
						airOppGravBasicMvm.acceleration=currentSpriteAnimation.abCancelAirOppGravity
					#else:
					#	print("hero "+heroName +" doesn't have the slide basic movement for ability cancel slide")
					
					if not my_is_on_floor():
						playActionKeepOldCommand(actionAnimeManager.SLIDING_AIR_IDLE_ACTION_ID)	
						
					currentSpriteAnimation.finishAnimation()
					
				
			else:
				
				rc = CANCEL_FAILED_NOT_ENOUGH_BAR_RC	
				
				emit_signal("insufficient_ability_bar",barCost*playerState.abilityChunkSize)
				
					#print("bar canceling into: "+str(actionId))
		else:
			
			#can't cancel this frame
			rc = CANCEL_FAILED_FRAME_UNCANCELABLE_RC		
	else:
		#can't cancel this frame
		rc = CANCEL_FAILED_FRAME_UNCANCELABLE_RC
		
	#did we end up canceling?
	if rc == CANCEL_SUCCESS_RC:
		#only consum bar if we canceled. otherwise don't
		#now attempte to consume bar, by applying cancel cost of current animation
		#playerState.consumeAbilityBar(barCost)
		playerState.forceConsumeAbilityBarInChunks(barCost)
		
		var autoAbilityCancelFlag = false
		
		#allow sliding in ground idle
		enableSlidingGroundIdle =true
		
		emit_signal("ability_cancel",barCost,spriteFrame,autoAbilityCancelFlag)
		
		#playerState.abilityBarCanceling = true
	return rc			

#will lock mvmv input de3pending on dash when cancled 
#to make sliding easier
func dashCancelInputLockCheck(currentSpriteAnimation):
	if currentSpriteAnimation == null:
		return
	#lock out certain mvm input temporarily if canceling a dash to 
	#make the dash sliding input easier to avoid interrupting it
	#,especially back dash
	
	#air dash forward
	var dashingForward = actionAnimeManager.isSpriteAnimationIdLinkedToAction(currentSpriteAnimation.id,actionAnimeManager.AIR_DASH_FORWARD_ACTION_ID)	
	dashingForward = dashingForward or actionAnimeManager.isSpriteAnimationIdLinkedToAction(currentSpriteAnimation.id,actionAnimeManager.GROUND_FORWARD_DASH_ACTION_ID)
	dashingForward = dashingForward or actionAnimeManager.isSpriteAnimationIdLinkedToAction(currentSpriteAnimation.id,actionAnimeManager.NON_CROUCH_CANCELABLED_F_GROUND_DASH_ACTION_ID)

	
	if dashingForward:					
		dashABCancelPreventingMvmInput=true
		#prevent forward or stoping movement
		inputLockHandler.reset()
		inputLockHandler.enable(DASH_ABILITY_CANCEL_INPUT_RESTRICTION_DURATION,null,inHitFreezeFlag,false,kinbody.forwardDashABCancelWhiteList,kinbody.forwardDashABCancelWhiteList2)#2 frames of no action after push block resolves
		#print("preventing walk forward")
		return 
		
		
	var dashingBack = actionAnimeManager.isSpriteAnimationIdLinkedToAction(currentSpriteAnimation.id,actionAnimeManager.AIR_DASH_BACKWARD_ACTION_ID)	
	dashingBack = dashingBack or actionAnimeManager.isSpriteAnimationIdLinkedToAction(currentSpriteAnimation.id,actionAnimeManager.GROUND_BACKWARD_DASH_ACTION_ID)
	dashingBack = dashingBack or actionAnimeManager.isSpriteAnimationIdLinkedToAction(currentSpriteAnimation.id,actionAnimeManager.NON_CROUCH_CANCELABLED_B_GROUND_DASH_ACTION_ID)
	
	if dashingBack:					
		dashABCancelPreventingMvmInput=true
		#prevent forward or stoping movement
		#print("preventing walk back")
		inputLockHandler.reset()
		inputLockHandler.enable(DASH_ABILITY_CANCEL_INPUT_RESTRICTION_DURATION,null,inHitFreezeFlag,false,kinbody.backDashABCancelWhiteList,kinbody.backDashABCancelWhiteList2)#2 frames of no action after push block resolves
		
		
func calculateComboLevelWithSpriteId(attackerPlayerController, spriteId,victimHurtboxSubClass,affectsDmgStarFill,dmgProrationMod,hitbox,abilityFeedProrationMod):
	var attackerActionManager = attackerPlayerController.actionAnimeManager
	var attackType = -1
	
	
	#resolve the attack type using sprite id
#	if attackerActionManager.isMeleeSpriteAnimation(spriteId):
#		attackType = attackerActionManager.MELEE_IX
#	elif attackerActionManager.isSpecialSpriteAnimation(spriteId):
#		attackType = attackerActionManager.SPECIAL_IX
#	elif attackerActionManager.isToolSpriteAnimation(spriteId):
#		attackType = attackerActionManager.TOOL_IX
#	else:
		#some other type of attack
#		return	


	#var isMelee
	if attackerActionManager.isMeleeSpriteAnimation(spriteId):
		attackType = attackerActionManager.MELEE_IX
	elif attackerActionManager.isSpecialSpriteAnimation(spriteId):
		attackType = attackerActionManager.SPECIAL_IX
	elif attackerActionManager.isToolSpriteAnimation(spriteId):
		attackType = attackerActionManager.TOOL_IX
	#elif attackerActionManager.isToolMeleeSpriteAnimation(spriteId):
	#	attackType = attackerActionManager.DUAL_TOOL_MELEE_IX
	#elif attackerActionManager.isMeleeToolSpriteAnimation(spriteId):
	#	attackType = attackerActionManager.DUAL_MELEE_TOOL_IX
	else:
		#some other type of attack
		return
	
	#calculateComboLevel(attackerPlayerController,MAGIC_SERIES_COMBO_LEVEL_IX,attackType,victimHurtboxSubClass,affectsDmgStarFill,dmgProrationMod,hitbox,abilityFeedProrationMod)
	#calculateComboLevel(attackerPlayerController,REVERSE_BEAT_COMBO_LEVEL_IX,attackType,victimHurtboxSubClass,affectsDmgStarFill,dmgProrationMod,hitbox,abilityFeedProrationMod)
	calculateComboLevel(attackerPlayerController,attackType,victimHurtboxSubClass,affectsDmgStarFill,dmgProrationMod,hitbox,abilityFeedProrationMod)
	
func calculateComboLevelWithCommand(attackerPlayerController, cmd, victimHurtboxSubClass,affectsDmgStarFill,dmgProrationMod,hitbox,abilityFeedProrationMod):
	var attackerActionManager = attackerPlayerController.actionAnimeManager
	var attackType = -1
	
	#resolve the attack type using sprite id
	#if attackerActionManager.isMeleeCommand(cmd):
		#attackType = attackerActionManager.MELEE_IX
	#elif attackerActionManager.isSpecialCommand(cmd):
		#attackType = attackerActionManager.SPECIAL_IX
	#elif attackerActionManager.isToolCommand(cmd):
		#attackType = attackerActionManager.TOOL_IX
	#else:
		
		#some other type of attack
	#	return
	
	
	
	if attackerActionManager.isMeleeCommand(cmd):
		attackType = attackerActionManager.MELEE_IX
	elif attackerActionManager.isSpecialCommand(cmd):
		attackType = attackerActionManager.SPECIAL_IX
	elif attackerActionManager.isToolCommand(cmd):
		attackType = attackerActionManager.TOOL_IX
	#elif attackerActionManager.isToolMeleeCommand(cmd):
	#	attackType = attackerActionManager.DUAL_TOOL_MELEE_IX
	#elif attackerActionManager.isMeleeToolCommand(cmd):
		#attackType = attackerActionManager.DUAL_MELEE_TOOL_IX
	else:
		#some other type of attack
		return
		

	#calculateComboLevel(attackerPlayerController,MAGIC_SERIES_COMBO_LEVEL_IX,attackType,victimHurtboxSubClass,affectsDmgStarFill,dmgProrationMod,hitbox,abilityFeedProrationMod)
	#calculateComboLevel(attackerPlayerController,REVERSE_BEAT_COMBO_LEVEL_IX,attackType,victimHurtboxSubClass,affectsDmgStarFill,dmgProrationMod,hitbox,abilityFeedProrationMod)
	calculateComboLevel(attackerPlayerController,attackType,victimHurtboxSubClass,affectsDmgStarFill,dmgProrationMod,hitbox,abilityFeedProrationMod)
	

#func calculateComboLevel(attackerPlayerController, comboLevelType,attackType,victimHurtboxSubClass,affectsDmgStarFill,dmgProrationMod,hitbox,abilityFeedProrationMod):
func calculateComboLevel(attackerPlayerController, attackType,victimHurtboxSubClass,affectsDmgStarFill,dmgProrationMod,hitbox,abilityFeedProrationMod):
	##case where reverse beat might take effect?
	#if attackType == GLOBALS.DUAL_MELEE_TOOL_IX or attackType == GLOBALS.DUAL_TOOL_MELEE_IX:
	
		#if the last attack we hit with wasn't a special, it's not important which attack we use
	#	if playerState.lastAttackWasHitBy  != GLOBALS.SPECIAL_IX:
	#		if attackType == GLOBALS.DUAL_MELEE_TOOL_IX:
	#			attackType = GLOBALS.MELEE_IX # TREAT as melee to start a magic series
	#		else:
	#			attackType = GLOBALS.TOOL_IX # TREAT as TOOL to start a reverse beat
	#	else:
			
			#not 1 hit away from doing a combo level?
	#		if playerState.focusSubComboLevel!=2 and playerState.subComboLevel != 2:	
				#treat as nomarl attack
	#			if attackType == GLOBALS.DUAL_MELEE_TOOL_IX:
	#				attackType = GLOBALS.MELEE_IX # TREAT as melee to start a magic series
	#			else:
	#				attackType = GLOBALS.TOOL_IX # TREAT as TOOL to start a reverse beat
	#		elif playerState.focusSubComboLevel==2: #started reverse beat and 1 hit way from completion?
	#			attackType =GLOBALS.MELEE_IX #complete the REVERSE BEAT
	#		else:
			#	attackType =GLOBALS.TOOL_IX #complete the MAGIC SERIES						
	
	#else:
		#BASIC case where no reverse beat is supported. do nothing to attack type		
	#	pass
	
	#attackerPlayerController.emit_signal("attack_type_hit",meleeFlag,specialFlag,toolFlag,victimHurtboxSubClass,affectsDmgStarFill)
	attackerPlayerController.emit_signal("attack_type_hit",attackType,victimHurtboxSubClass,affectsDmgStarFill)
	
	var attackerActionManager = attackerPlayerController.actionAnimeManager
	
	
#	const MAGIC_SERIES_COMBO_LEVEL_IX = 0
#const FOCUS_COMBO_LEVEL_IX = 1
#const COMBO_TYPE_A = 0
#const COMBO_TYPE_B = 1
#const COMBO_TYPE_C = 2

	#compute the combo levels and sublevels to apply to damage combo levels ups
	_calculateComboLevel(attackerPlayerController,attackerPlayerController.playerState.subComboLevel,attackerPlayerController.playerState.comboLevel,MAGIC_SERIES_COMBO_LEVEL_IX,attackType,affectsDmgStarFill,hitbox)	
	
	#we only compute the reverse beat combo level for hearos that support it
	if attackerPlayerController.kinbody.supportsReverseBeat:		
		_calculateComboLevel(attackerPlayerController,attackerPlayerController.playerState.focusSubComboLevel,attackerPlayerController.playerState.focusComboLevel,REVERSE_BEAT_COMBO_LEVEL_IX,attackType,affectsDmgStarFill,hitbox)		
		
	
	#dynamically compute the proration modifiers based on hitbox damage
	var newdmgProrationMod = comboHandler.computeDamageProrationMod(hitbox)
	var newabilityFeedProrationMod = comboHandler.computeAbilityFeedProrationMod(hitbox)

	#attackerPlayerController.comboHandler._on_combo_hit(attackerPlayerController.playerState.combo,dmgProrationMod,abilityFeedProrationMod)
	
	#only calculate proration for a hurtbox that's basic gets hit. armor hurtboxs shouldn't affect proration
	if victimHurtboxSubClass == GLOBALS.SUBCLASS_BASIC:
		attackerPlayerController.comboHandler._on_combo_hit(attackerPlayerController.playerState.combo,newdmgProrationMod,newabilityFeedProrationMod,hitbox)

	playerState.lastAttackWasHitBy = attackType
	
	

func _calculateComboLevel(attackerPlayerController,currSubLevel,currComboLevel,comboLevelType,attackType,affectsDmgStarFill,hitbox):

	var subComboLevel = null
	var comboLevel = null
	#var currSubLevel = attackerPlayerController.playerState.subComboLevel
	#var currComboLevel = attackerPlayerController.playerState.comboLevel
	#var comboLevelType = MAGIC_SERIES_COMBO_LEVEL_IX
	
	
	#combo: i.e. already in hitstun?
	if playerState.inHitStun == true:
		
		
		#doing a dmb fill combo?
		#if attackType == GLOBALS.SPECIAL_IX or attackType == GLOBALS.TOOL_IX:
			
			#can't perform a fill combo if already levelup the combo 
		#	if currComboLevel == 0:
				
				#some special/tool moves don't increase fill combo sub levels (usually multi hits)
		#		if affectsDmgStarFill:
					#working toward fill combo level (3 is level up)
		#			attackerPlayerController.playerState.fillComboSubLevel = attackerPlayerController.playerState.fillComboSubLevel + 1
					
					#hitbox my be null if we expliclty call caculate combo level outside collision system
					#e.g.: coutner ripost
		#			if hitbox != null:
						#make sure sprite animation of hitbox no longer can fill dmg stars
		#				var sa = hitbox.spriteAnimation
		#				sa.filledStar=true
				#else:
		#			#don't reduce fill sub combo lvl since might combo a tool/special out of the multihit where 
					#first hit did indeed increase it
		#			pass
		#	else:
				#can't level up fill combo during empty star combo levelup
				#attackerPlayerController.playerState.clearFillComboSubLevel()	
		#else:
			#messed it up, reset fill combo progress
		#	attackerPlayerController.playerState.clearFillComboSubLevel()
			
		# were we hit by a melee action and they hit us with tool previously?
		#if (attackerActionManager.MELEE_IX == attackType) and  (attackerActionManager.TOOL_IX == playerState.lastAttackWasHitBy):		
		if compareAttackType(comboLevelType,COMBO_TYPE_A,attackType) and  compareAttackType(comboLevelType,COMBO_TYPE_C,playerState.lastAttackWasHitBy):		
		
			#attackerPlayerController.playerState.subComboLevel = 1
			subComboLevel=1
			
		elif compareAttackType(comboLevelType,COMBO_TYPE_B,attackType) and  compareAttackType(comboLevelType,COMBO_TYPE_A,playerState.lastAttackWasHitBy):		
		
			#attackerPlayerController.playerState.subComboLevel += 1
			subComboLevel = currSubLevel + 1
		elif compareAttackType(comboLevelType,COMBO_TYPE_C,attackType) and  compareAttackType(comboLevelType,COMBO_TYPE_B,playerState.lastAttackWasHitBy):		
		
			#attackerPlayerController.playerState.subComboLevel += 1
			
			#now we check if we connected a combol level up (melee+special+tool)
			#if  attackerPlayerController.playerState.subComboLevel == 2:
			if  currSubLevel== 2:
				#attackerPlayerController.playerState.subComboLevel += 1		
				subComboLevel = currSubLevel + 1
			
				#level up combo
			
				#attackerPlayerController.playerState.comboLevel += 1
				comboLevel = currComboLevel + 1
				
			else:# this means we combined a different sequence than desired
				#reset string
				#attackerPlayerController.playerState.subComboLevel = 0
				subComboLevel = 0
		elif compareAttackType(comboLevelType,COMBO_TYPE_A,attackType) :# here, we didn't do M + S, S + T, nor M + S + T, but, we may have done M + M, which should be start of a string
			
			#attackerPlayerController.playerState.comboLevel = 0	
			#attackerPlayerController.playerState.subComboLevel = 1
			comboLevel = 0
			subComboLevel = 1
		else:
			#attackerPlayerController.playerState.subComboLevel = 0 #not a string
			subComboLevel = 0
	#first hit is melee?
	else:
		#attacker's combo stopped earlier, reset combo attributes

		#attackerPlayerController.playerState.comboLevel = 0
		comboLevel = 0
		if compareAttackType(comboLevelType,COMBO_TYPE_A,attackType) :
			#start tracking the combo leveling up if be
			#attackerPlayerController.playerState.subComboLevel = 1
			subComboLevel = 1
		else:
			#attackerPlayerController.playerState.subComboLevel = 0
			subComboLevel = 0
			
			
	
	#only change the damage combo level attributes if a change (not null) occured
	if comboLevel != null:
		
		if comboLevelType ==MAGIC_SERIES_COMBO_LEVEL_IX:
			attackerPlayerController.playerState.comboLevel = comboLevel
		elif comboLevelType ==REVERSE_BEAT_COMBO_LEVEL_IX:
			attackerPlayerController.playerState.focusComboLevel = comboLevel
		else: 
			print("error, invalid combo levevl indexses")
	if subComboLevel != null:
		
		if comboLevelType ==MAGIC_SERIES_COMBO_LEVEL_IX:
			attackerPlayerController.playerState.subComboLevel = subComboLevel
		
		elif comboLevelType ==REVERSE_BEAT_COMBO_LEVEL_IX:
			attackerPlayerController.playerState.focusSubComboLevel = subComboLevel
		else: 
			print("error, invalid combo levevl indexses")
		
	

func isCommandMeleeSpecialTool(cmd):
	#resolve the attack type using sprite id
	return actionAnimeManager.isMeleeCommand(cmd) or actionAnimeManager.isSpecialCommand(cmd) or actionAnimeManager.isToolCommand(cmd)
		
#returns true when target attack type is the desired type,
func compareAttackType(comboLevelTypeIx,comboStringSequenceIx,targetAttackType):
	
	return comboLevelUpString[comboLevelTypeIx][comboStringSequenceIx]==targetAttackType

func notifyCommandHitOpponent(cmd,emitsAttackSFXSignal,attackHitPosition):
	
	#var cmd = actionAnimeManager.commandActioned
	#get facing dependnt command
	cmd = inputManager.getFacingDependantCommand(cmd,kinbody.facingRight)
	
	if emitsAttackSFXSignal:
		#notify listeners that opponent connected a hit a command
		emit_signal("cmd_attack_hit",cmd,attackHitPosition)
	playerState.lastCommandHit = actionAnimeManager.commandActioned


#were duplicating code here, may want to consider redesigning this and "applyDamage" func
func computeRelativeDamage(baseDamage):
	
	#apply damage scaling (longer combos do less damage)
	var dmgProrationModifier = playerState.comboLevelDamageScale * playerState.damageScale
	
	#damage without proration
	#var relativeDamage = baseDamage*playerState.damageGauge
	var relativeDamage = baseDamage* (1 + playerState.numFilledDmgStars * (GLOBALS.DAMAGE_PER_STAR_MOD+additionalDamagePerStar))
	
	#apply proration
	relativeDamage = dmgProrationModifier * relativeDamage
	
	return relativeDamage
	
	
func applyDamage(attackerPlayerController, damage , abilityRegenMod, blocking):
	
	var counterHitMod = 1
	#beginning of  a combo?
	if not playerState.inHitStun:
		
		#are we in startup aniamtion, ie, it's a counter hit?
		if actionAnimeManager.spriteAnimationManager.isInStartupAnimation():
			counterHitMod = COUNTER_HIT_DMG_MOD
			#APPLY 15% MORE 
				
	#
	#DAMAGE CALCULATIONS
	#
	#apply damage scaling (longer combos do less damage)
	#var dmgProrationModifier = attackerPlayerController.playerState.comboLevelDamageScale * attackerPlayerController.playerState.damageScale
	var dmgProrationModifier = attackerPlayerController.playerState.damageScale
	
	#damage without proration
	#var baseDamage = damage*attackerPlayerController.playerState.damageGauge
	#100% + 20% FOR EACH damage star
#	var baseDamage = damage* (1 + attackerPlayerController.playerState.numFilledDmgStars * (GLOBALS.DAMAGE_PER_STAR_MOD+attackerPlayerController.additionalDamagePerStar))
	
	
	#apply proration
	#var relativeDamage = dmgProrationModifier * baseDamage
	var relativeDamage = dmgProrationModifier * damage * counterHitMod
	
	
	#were blocking and the chip damage will KP?
	if blocking and playerState.hp - relativeDamage <=0:
		
		#avoid KO a person via chip damage in block
		return 0
	else:
		
		var newHP=playerState.hp-relativeDamage
		
		#old if statemtent to preent winning from counter ripost protected attack
		#can't win game when doing a counter ripost
		#to prevent having a hitbox protected and unpunishable
		#if newHP<=0 and opponentPlayerController.newCounterRipostHandler.counterRiposting:
		#	newHP=0.01#barely surviving
			
		#apply
		playerState.hp =newHP
	
	
	#emit signal that we just cause damage to opponent, giving the base damage
	emit_signal("base_damage_taken",damage) #consider changin the name of "damage_takenh" signal to "damage taken'...
	emit_signal("damage_taken",relativeDamage,damage*dmgProrationModifier)
	
	#attempt to regenerate ability bar from being hit
	regenerateAbilityBarFromHit(attackerPlayerController,relativeDamage,abilityRegenMod)
	
	return relativeDamage

func regenerateAbilityBarFromHit(attackerPlayerController,relativeDamage,abilityRegenMod):
	
	#
	#OPONENT ABILITY REGENERATION CALCULATIONS
	#
	#var abilityRegenProrationModifier = attackerPlayerController.playerState.comboLevelabilityRegenScale*attackerPlayerController.playerState.abilityRegenScale
	var abilityRegenProrationModifier = attackerPlayerController.playerState.abilityRegenScale
	
	
	#apply the ability regen to base damage without proration
	#the base ability regenrate from move after damage modifiers
	var relativeAbilityRegen = relativeDamage*abilityRegenMod
	#var relativeAbilityRegen = baseDamage*abilityRegenMod
	
	
	#apply proration 
	relativeAbilityRegen = relativeAbilityRegen * abilityRegenProrationModifier
	
	#now, have the focus reduce the amount we feeding to opponent
	#relativeAbilityRegen = relativeAbilityRegen / attackerPlayerController.playerState.focus
	if not playerState.abilityBarGainLocked:
		
		#make sure to only increase bar and signal bar incrase if positive
		if relativeAbilityRegen > 0:
			playerState.increaseAbilityBar(relativeAbilityRegen)
	
			emit_signal("feeding_ability_bar",relativeAbilityRegen)

func _on_hitstun_duration_expired():

	if inHitFreezeFlag:
		print("warning, possibel frame perfpect bug, where hit, then break from hitstun during hit freeze, so initial hit ignored")
		#pssobiel solution: prevent hitstun timer from expiring during hitfreeze
		pass
	#print("hitstun duration expeired")
	hitstunTimer.stop()
	
	var sa  =actionAnimeManager.getCurrentSpriteAnimation()
	
	#were we in normal hitstun and broke free
	if sa != null:
		sa.finishAnimation()
	else:
		breakFromHistun()
func breakFromHistun():
	
	hitstunTimer.stop()
	
	actionAnimeManager.movementAnimationManager.specialBounceMvmAnimations =null
	
	playerState.inHitStun = false
	
	wasInInvincibleOki=false
	lastHitBySpriteAnimeId = null
	
	#make sure to make the sprite apear when histun ends in case hitbox made it disappear
	kinbody.sprite.visible = true
	
	#no more special bounces in hitstun
	#if actionAnimeManager.movementAnimationManager.specialBounceMvmAnimations != null:
	#	actionAnimeManager.movementAnimationManager.specialBounceMvmAnimations.resetBounceCounters()
	
		
	#make sure not stunned in air (get hit mid air dash, when gravity is stopped, by a grounder)
	#replay gravity if not play
	#var gravType = complexMvmInstance.GravityEffect.KEEP_AND_REPLAY_IF_STOPPED
	#actionAnimeManager.movementAnimationManager.applyComplexMovementGravity(gravType)
	
	#in the air?
	#if not my_is_on_floor():
		#keep relative gravity 
		#playActionKeepOldCommand(actionAnimeManager.AIR_HITSTUN_BREAK_FREE_ACTION_ID)
		
		#we explicitly stop movement, since the movement animation of AIR_HITSTUN_BREAK_FREE_ACTION_ID
		#won't get a chance to execute, since a frame won't ellapsed between air idle and movement stop
		#while air idle should stopp all movement
	
	#if not my_is_on_floor():
	#	var keepFloorCollision =false
	#	actionAnimeManager.movementAnimationManager.deactivateAllMovement(keepFloorCollision)
	#else:
	#	var keepFloorCollision =true
	#	actionAnimeManager.movementAnimationManager.deactivateAllMovement(keepFloorCollision)
	
		
	playActionKeepOldCommand(actionAnimeManager.BREAK_FROM_HITSTUN_HALT_ACTION_ID)
	
	
	#make sure we didn't get a command processed in same frame (ripost break you free of histun
	#so you would get 2 commands in a frame without this lock)
	if not handleUserInputCallLock:
		#handle user's input here this frame (ignoring the process in next physics process)
		#since want to make sure player can act, before any additional signal occur
		handleUserInput()
		skipHandleInputThisFrame=true
	
	
	#wallBounces = 0
	
	opponentPlayerController._on_opponent_broke_free_from_hitstun()
	


#called when requesting a special effects sound (as opposed to standard hitting sounds)
#to be played
func _on_request_play_special_sound(soundId,soundType,soundVolumeOffset=null):
	
	if muteSoundSFX:
		return
		
	if soundType == COMMON_SOUND_SFX:
		
		if soundVolumeOffset!= null:
			commonSFXSoundPlayer.changeVolume(commonSFXSoundDefaultVolume+soundVolumeOffset)#change voluem for this sound clip
		else:
			commonSFXSoundPlayer.changeVolume(commonSFXSoundDefaultVolume)#default volume for non-specified sound clkip
		
		commonSFXSoundPlayer.playSound(soundId)
	elif soundType == HERO_SOUND_SFX:
		if soundVolumeOffset!= null:
			heroSFXSoundPlayer.changeVolume(soundId,heroSFXSoundDefaultVolume+soundVolumeOffset)#change voluem for this sound clip
		else:
			heroSFXSoundPlayer.changeVolume(soundId,heroSFXSoundDefaultVolume)#default volume for non-specified sound clkip
		heroSFXSoundPlayer.playSound(soundId)
		
	
func _on_opponent_broke_free_from_hitstun():
	
	#combo is finish, therefore the combo level is reset
	playerState.comboLevel = 0
	#playerState.focusComboLevel = 0
	
	
func _on_starting_new_combo_pre_damage():
	emit_signal("starting_new_combo")
	
	if opponentPlayerController.actionAnimeManager.spriteAnimationManager.isInStartupAnimation():
		emit_signal("counter_hit")
	elif opponentPlayerController.actionAnimeManager.spriteAnimationManager.isInRecoveryAnimation():
		emit_signal("punish")
		
	opponentPlayerController.emit_signal("pre_ability_bar_gain")
	

func _on_starting_new_combo():
	
	
	numFailedCounterRipostInCombo = 0
	#since were comboing opponent, have opponent lose progress on resource increase proration
	#opponentPlayerController.playerState.damageGenerationComboCount = 0
	#opponentPlayerController.playerState.focusGenerationComboCount = 0
	playerState.subComboLevel=0
	playerState.focusSubComboLevel=0
	
	playerState.resetCombo()
	comboHandler._on_starting_new_combo()
	
	playerState._on_started_combo()
	
	
	
	
#this applyhitstun  function takes a hitbox area as a parameter, and will call the standard applyhistun function
func attemptApplyHitstun(attackSpriteId, attackerHitbox,victimHurtbox):
	
	#can't apply hitstun the same frame guard broke (prevents cases where two
	#sources of damage are applied same frame, one breaks guard, but the
	#otherone would otherwise overwride the gaurd break stun.
	#like when glove hits ball with bat and hits opponent at the same time
	if guardBrokeThisFrame:
		return
	
	var preventOnHitFlagEnabled = false
	var blocking = false
	var blockResult = null
	var perfectBlocking = false
	var attackerPlayerController=attackerHitbox.playerController
	
	var wasInHitstun = playerState.inHitStun
	
	var rawHitstunDuration=attackerHitbox.duration
	#link?
	if wasInHitstun:
		#has different hitstun duraiton for a link?
		if attackerHitbox.durationOnLink> -1:
			rawHitstunDuration = attackerHitbox.durationOnLink
			
	
	#this will be projectile or player' kinematic body
	var hitBoxParentKinBody =attackerHitbox.getParentKinbody()
	
		
	if attackerHitbox.hitstunType == GLOBALS.HitStunType.KNOCKBACK_ONLY: #no hitstun for this move, only knockback ( like doomfist upercut, but no damage)
		#only apply knockback, no hitstun
		#actionAnimeManager.movementAnimationManager.playMovementAnimation(attackerHitbox.hitstunMovementAnimation,not kinbody.facingRight)
		actionAnimeManager.movementAnimationManager.playMovementAnimation(attackerHitbox.hitstunMovementAnimation,not hitBoxParentKinBody.spriteCurrentlyFacingRight) #is the 'not' a bug?
		
		return
		
	var relativeDamageForHeavyArmorCheck = attackerPlayerController.computeRelativeDamage(attackerHitbox.damage)
	
	#potential show the red from damage taken for special types of hitboxes
	#only apply hitstun if not armor
	if victimHurtbox.subClass == victimHurtbox.SUBCLASS_HYPER_ARMOR:
		#show that damage was taken by putting red were HP used to be, for a brief moment
		displayRedHPTemporarily()
		emit_signal("hit_armored_opponent")
	elif victimHurtbox.subClass == victimHurtbox.SUBCLASS_SUPER_ARMOR:
				 
		#only count the hit limit of super armor for moves that apply hitstun
		if attackerHitbox.hitstunType != GLOBALS.HitStunType.NO_HITSTUN and attackerHitbox.hitstunType != GLOBALS.HitStunType.ON_LINK_ONLY_AND_HITSTUNLESS and attackerHitbox.hitstunType != GLOBALS.HitStunType.KNOCKBACK_ONLY: 
			#count the super armorhit
			#actionAnimeManager.spriteAnimationManager.currentAnimation.increaseSuperArmorWasHitCounter()
			victimHurtbox.spriteAnimation.increaseSuperArmorWasHitCounter()
			
			#is armor still active
			if not hasBrokenSuperArmor(victimHurtbox):
				#show that damage was taken by putting red were HP used to be, for a brief moment
				displayRedHPTemporarily()
				
				emit_signal("hit_armored_opponent")
		
		
	elif attackerHitbox.hitstunType == GLOBALS.HitStunType.NO_HITSTUN or attackerHitbox.hitstunType == GLOBALS.HitStunType.ON_LINK_ONLY_AND_HITSTUNLESS: #no hitstun for this move, like 
		#show that damage was taken by putting red were HP used to be, for a brief moment
		displayRedHPTemporarily()
		
	elif victimHurtbox.subClass == victimHurtbox.SUBCLASS_HEAVY_ARMOR:#heavy armor?
		#damage doesn't exceed its threshold?
		if relativeDamageForHeavyArmorCheck <= victimHurtbox.heavyArmorDamageLimit:
			#show that damage was taken by putting red were HP used to be, for a brief moment
			displayRedHPTemporarily()
			emit_signal("hit_armored_opponent")
	elif victimHurtbox.subClass == victimHurtbox.SUBCLASS_BASIC:#heavy armor?
	
		#begigin a combo?
		if not playerState.inHitStun:
			#attackerPlayerController._on_starting_new_combo_pre_damage()
			#do this signal before damage applied
			emit_signal("clear_red_hp")
		
	#check if possible to block move
	if victimHurtbox.canHoldBackBlock and playerState.guardHP>0 and not attackerHitbox.unblockable: #check to ssee if we can block the move
		
		blockResult = guardHandler.blockedAttackStatus(attackerHitbox)
		
		#most moves can generally be blocked  incorrectly. Hoever somemove can only be blocked correctly, otherwise incrorect block counts as no block
		if not attackerHitbox.incorrectBlockUnblockable or  blockResult != GLOBALS.BlockResult.INCORRECT:
				#can't block
			var guardRc = guardHandler.processGuardHP(attackerHitbox)
			
			
			#not blocking
			if guardRc == guardHandler.RC_NOT_BLOCKING:
				
			
				blocking= false
			elif guardRc == guardHandler.RC_BLOCKING  or guardRc == guardHandler.RC_PERFECT_BLOCKING or guardRc ==guardHandler.RC_GUARD_BROKEN: #opponent is block, or his guard was hsattered by attac?
				#in any case, we blockked attack, and on shatterd guard, will be in hitstun from signal, so consider it block
				
				blocking= true
				if  guardRc == guardHandler.RC_PERFECT_BLOCKING:
					perfectBlocking = true
			
			elif guardRc == guardHandler.RC_GRABBED_IN_BLOCK:
				emit_signal("grabbed_in_block")
				blocking= false
		
			

			#by default on hit animation inherit the "is hitting" to auto cancel on hit
			#so gotta disable that explicitly when should't be able to autocancel on hit
			if victimHurtbox.preventAutocancelOnHit or blocking:
				preventOnHitFlagEnabled=true
				
			if blocking:
				emit_signal("pre_block_hitstun",attackerHitbox,blockResult,not hitBoxParentKinBody.spriteCurrentlyFacingRight)
				
				#will three be an action played on hit?
				
				var actionIdOnHit = attackerPlayerController.resolveActionIdPlayedOnHit(attackerHitbox.on_hit_action_id,attackerHitbox.on_link_hit_action_id,attackerHitbox.cmd,attackerHitbox.on_hit_starting_sprite_frame_ix,wasInHitstun,attackerHitbox.preventOnHitActionWhenOnGround,attackerHitbox.preventOnHitActionWhenInAir,preventOnHitFlagEnabled)				
				if actionIdOnHit != -1:			
					#since we played an aniamtion on hit, the total duraiton remaing of
					#frames for animation is updated to the new animation's duration, for sake 
					#of applying hitstun/blockstun relative to animaton frames remaining (particularly
					#important to correctly display grab frame data)
					var currentAnimation = attackerPlayerController.actionAnimeManager.spriteAnimationLookup(actionIdOnHit)	
					if currentAnimation != null:
						attackerPlayerController.animationFramesRemaining=currentAnimation.getEffectiveNumberOfFrames()+1 #+1 to compensate for 1 frame early
						
			#only go into block stun if successfuly blocked without breaking guard
			if guardRc == guardHandler.RC_BLOCKING or  guardRc == guardHandler.RC_PERFECT_BLOCKING:	
				#did the gaurd resist from breaking from the attack?
				
				#block stun depends on angle attack traveling at?
				if attackerHitbox.blockstunAngleMatchesAttackerMomentum:
					attackerHitbox.adjustBlockStunKnockbackDynamicAngle()
					
				var blockstunMvm = null
				if guardRc == guardHandler.RC_PERFECT_BLOCKING:
					blockstunMvm= actionAnimeManager.mvmAnimationLookup(actionAnimeManager.PERFECT_MOMENTUM_STOP_BLOCK_ACTION_ID)
				else:				
	
					blockstunMvm=attackerHitbox.blockstunMovementAnimation
						
				
				var inBlockStun= guardHandler.isInBlockHitstun()
				#already in block histun?
				if inBlockStun:
					
					var ignoreBlockStunStringFlag = false
					#don't signal the blockk stun string if hitbox ignores it (multi hits, for exampel)
					if attackerHitbox.spriteAnimation != null:
						if attackerHitbox.spriteAnimation.hitABlockStunString:
							ignoreBlockStunStringFlag=true
					
					if not attackerHitbox.countsAsBlockString:
						ignoreBlockStunStringFlag = true
						
					if not ignoreBlockStunStringFlag:
						
						#make sure to flag the fact we hit in block stun (don't want multi hits to spam the notificaton)
						if attackerHitbox.spriteAnimation != null:
							attackerHitbox.spriteAnimation.hitABlockStunString=true
						opponentPlayerController.emit_signal("block_stun_string")
				var blockStunDuration = null
				
			
		
			
				var blockStunDur = 	null
				
				#correct block? default block stun duration
				if blockResult == GLOBALS.BlockResult.CORRECT or blockResult == GLOBALS.BlockResult.PERFECT:
					blockStunDur = attackerHitbox.blockStunDuration
				else: #blockResult == GLOBALS.BlockResult.INCORRECT, no need to check, we know were blocking incorrectly
			
					blockStunDur = attackerHitbox.incorrectBlockStunDuration
					
		
				
				#add -1 to address the "just frames". since starting an animation takes 1 tick i think
				#so if something is + 2, then the tick it's start should count as frame 1, and then the last frame
				#should be frame 2 (since game counts from 0 upwards)
				blockStunDur = blockStunDur -1 
				#there is still slight internal lag, so gotta increase bock stun by 
				# -1, since for special case of "JUST frames", want make sure +5 means a startup moves of 5 will hit (takes 1
						#frame for the phsysics engine to process the activated frame and do collisions
				#blockStunDur = blockStunDur +1
				
				if attackerHitbox.blockStunDurationType ==GLOBALS.HITSTUN_DURATION_TYPE_ADD:
					
					if inBlockStun:
					
						#blockStunDuration = calculateTargetAniamtionDuration(attackerHitbox.blockStunDurationType,blockStunDur,actionAnimeManager.spriteAnimationManager.currentAnimation.computeNumberRemainingFrames())
						blockStunDuration = calculateTargetAniamtionDuration(attackerHitbox.blockStunDurationType,blockStunDur,animationFramesRemaining) 
					else:
						#not in blockstun, so its just a meaty
						blockStunDuration =calculateTargetAniamtionDuration(GLOBALS.HITSTUN_DURATION_TYPE_MEATY,blockStunDur,null) #null since basic doesn't need curretn hitstun frames remaining
				
				else:
					
					blockStunDuration = calculateTargetAniamtionDuration(attackerHitbox.blockStunDurationType,blockStunDur,null)#null since basic and meaty doesn't need curretn hitstun frames remaining
					
					#go through block mvm animation and make the duration 
					#of knockback equal duration of shortest duration blockstun (incorrect vs correct)
					#ingore perfect blocks since you don't move
					if not attackerHitbox.preventBlockSetKnockBackDuration and blockResult != GLOBALS.BlockResult.PERFECT:
						if attackerHitbox.blockstunMovementAnimation != null:
							#duration if blocked correctly
							var correctBlockDur = calculateTargetAniamtionDuration(attackerHitbox.blockStunDurationType,attackerHitbox.blockStunDuration-1,null)# -1 since we applied that above
							for cm in attackerHitbox.blockstunMovementAnimation.complexMovements:
								for bm in cm.basicMovements:
									#indefinite duration or duration that exceeds correct block stun duration?
									if bm.duration == 0 or bm.duration >correctBlockDur:
										bm.duration= correctBlockDur
				
				# -2 since for special case of "JUST frames", want make sure +5 means a startup moves of 5 will hit (takes 1
						#frame for the phsysics engine to process the activated frame and do collisions
			
				#go into block stun
				#displayFrameData(blockStunDuration-2)
				displayFrameData(blockStunDuration)
				_on_start_tracking_frame_duration(blockStunDuration)
				#iterate
				playBlockHistunAnimation(blockStunDuration,blockstunMvm,not hitBoxParentKinBody.spriteCurrentlyFacingRight)
				emit_signal("entered_block_hitstun",attackerHitbox,blockResult,not hitBoxParentKinBody.spriteCurrentlyFacingRight)
				
				#attacker might have movement animation to apply when hitting on block
				if attackerHitbox.attackerOnBlockedMovementAnimation != null:
					#play mvm aniamtion for attacker
					opponentPlayerController.actionAnimeManager.movementAnimationManager.playMovementAnimation(attackerHitbox.attackerOnBlockedMovementAnimation, opponentPlayerController.kinbody.spriteCurrentlyFacingRight) 
				#
		else:
			emit_signal("incorrect_block_unblockable")		
		
	#need compute relative damage before applying it for red hp and heavy armor
	
	var damageResistance = 1
	
	#damage resisteance applied when blocking
	if blocking:
		#damageResistance = BLOCK_DAMAGE_RESISTANCE_MOD # 20% of damage is chip damage trhough block
		
		if perfectBlocking:
			damageResistance = 0 #0% chip damage
			
			#do we regen ability bar as if the attack hit when perfect blocking?
			#we calculate it here as perfect blocking has no chip damage, so were not gaining bar twice
			if regenAbilityBarOnPerfectBlock:
						
#				emit_signal("pre_ability_bar_gain")
				#attempt to regenerate ability bar from being hit
				regenerateAbilityBarFromHit(attackerPlayerController,attackerHitbox.damage,attackerHitbox.abilityRegenMod)
#				emit_signal("ability_bar_gain_finished")
		else:
		
			if takeEnormousBlockChipDamage:
				damageResistance=enormousBlockChipDamageMod#modifier to apply for blocking and taking buncha chip damage
			else:
				#take chip damage as normal
				var chipDmgMod = 1 +blockChipDamageTakenMod + opponentPlayerController.blockChipDamageDealtMod
				damageResistance = chipDmgMod* attackerHitbox.blockChipDamageMod
		
		_on_budget_block(blockResult)
	else:
		
		
		if victimHurtbox.subClass == victimHurtbox.SUBCLASS_BASIC:#heavy armor?
			#begigin a combo?
			if not playerState.inHitStun:
				attackerPlayerController._on_starting_new_combo_pre_damage()
			
		
		opponentPlayerController.attemptRecoverOnHitAirDash()
		#opponentPlayerController.handleAttackTypeLightingSignaling(attackerHitbox)
		#standard damagae resistance of hurtbox
		damageResistance = victimHurtbox.damageResistance

	#attackerHitbox.dispalyOnHitSFXSprites()
		
	#apply damage	(factor in damage resistance)
	var relativeDamage = applyDamage(attackerPlayerController,damageResistance*attackerHitbox.damage,attackerHitbox.abilityRegenMod,blocking)
	
	#gain ability bar if applicable
	#var abilityGain = attackerHitbox.abilityGainMod*relativeDamage
	#attackerPlayerController.playerState.increaseAbilityBar(abilityGain)
		
	#gain hp if appliccable
	var hpGain = attackerHitbox.hpGainMod*relativeDamage
	
	if hpGain < 0 :
		print("warning, gaining negative hp (losing hp) from an attack")
	elif hpGain >0:
		pass
	attackerPlayerController.playerState.hp += hpGain
	
	var nohitstunFlag = false
	#only apply hitstun if not heavy armor or hyper armor (youcan grab a super armor persone)
	if victimHurtbox.subClass == victimHurtbox.SUBCLASS_HYPER_ARMOR and not attackerHitbox.isThrow:
		nohitstunFlag=true
	elif victimHurtbox.subClass == victimHurtbox.SUBCLASS_HEAVY_ARMOR and not attackerHitbox.isThrow:#heavy armor?
		
		#damage doesn't exceed its threshold?
		if relativeDamageForHeavyArmorCheck <= victimHurtbox.heavyArmorDamageLimit:
			nohitstunFlag=true
			
	#super armor that's still standing (hasn't been hit past limit) and not a throw
	elif victimHurtbox.subClass == victimHurtbox.SUBCLASS_SUPER_ARMOR and not attackerHitbox.isThrow and not hasBrokenSuperArmor(victimHurtbox):
		nohitstunFlag=true
			
	
	elif attackerHitbox.hitstunType == GLOBALS.HitStunType.NO_HITSTUN or attackerHitbox.hitstunType == GLOBALS.HitStunType.ON_LINK_ONLY_AND_HITSTUNLESS: #no hitstun for this move, like 
		
		nohitstunFlag=true
	
	#did we block the attack?
	if blocking:
		nohitstunFlag=true
		
	#not applying hitstun?
	if nohitstunFlag:
		#only falg as hitting if hitbox allows it, the hurtbox allows it, and not blocking
		if attackerHitbox.onHitAutoCancelable and (not victimHurtbox.preventAutocancelOnHit) and not blocking:
			attackerPlayerController.actionAnimeManager.spriteFrameSetIsHitting(true)
			
		#flag the hit for any hitbox
		actionAnimeManager.spriteFrameSetHittingAnyHitbox(true)
		#no hitstun
		#return
	else:
		
		
		#check if gona do on hit animation, then manually changes frames remaining of animation base on how long next
		#animation will be
		var actionIdOnHit = attackerPlayerController.resolveActionIdPlayedOnHit(attackerHitbox.on_hit_action_id,attackerHitbox.on_link_hit_action_id,attackerHitbox.cmd,attackerHitbox.on_hit_starting_sprite_frame_ix,wasInHitstun,attackerHitbox.preventOnHitActionWhenOnGround,attackerHitbox.preventOnHitActionWhenInAir,preventOnHitFlagEnabled)				
		if actionIdOnHit != -1:			
			#since we played an aniamtion on hit, the total duraiton remaing of
			#frames for animation is updated to the new animation's duration, for sake 
			#of applying hitstun/blockstun relative to animaton frames remaining (particularly
			#important to correctly display grab frame data)
			var currentAnimation = attackerPlayerController.actionAnimeManager.spriteAnimationLookup(actionIdOnHit)	
			if currentAnimation != null:
				attackerPlayerController.animationFramesRemaining=currentAnimation.getEffectiveNumberOfFrames()+1#+1 to compensate for 1 frame early
				
				
		#only get grab back if not a grab hitbox
		#if attackSpriteId != attackerPlayerController.actionAnimeManager.ON_HIT_AIR_GRAB_SPRITE_ANIME_ID and attackSpriteId != attackerPlayerController.actionAnimeManager.ON_HIT_GROUND_GRAB_SPRITE_ANIME_ID and attackSpriteId != attackerPlayerController.actionAnimeManager.GROUND_GRAB_SPRITE_ANIME_ID and attackSpriteId != attackerPlayerController.actionAnimeManager.AIR_GRAB_SPRITE_ANIME_ID:
			#able to apply hitstun, so now the grab goes off cooldown
		#	opponentPlayerController.playerState.isGrabOnCooldown=false
			
		#make sure to update any dynamic angle basic movements if this hitbox supports hitting
		#int direction attacker is going
		if attackerHitbox.hitstunAngleMatchesAttackerMomentum:
			
			attackerHitbox.adjustHitStunKnockbackDynamicAngle()
				
			##TODO: GET N-SPECIAL BAT BALL HIT TO HIT IN PROPAER DIRECTION
		#get the modifier that prevents simple infinites with same move (opponent is hitting, so get his mod)		
		#var durationMod = opponentPlayerController.comboHandler.getHitstunProrationMod(attackerHitbox)
		var meatyFlag = attackerHitbox.hitstunDurationType == attackerHitbox.HITSTUN_DURATION_TYPE_MEATY
		
		
		var prorationSpriteAnimeId =attackSpriteId
		#add the proration id offset for projectlies so their proration can be stored in same map as normal animations
		if attackerHitbox.belongsToProjectile():
			if prorationSpriteAnimeId == null:
				prorationSpriteAnimeId=0
				print("warning: null sprite anime id for attacking projectile. Treating null as 0 base sprite id for proration calculaing")
			prorationSpriteAnimeId = prorationSpriteAnimeId+GLOBALS.PROJECTILE_SPRITE_ANIME_ID_PRORATION_TRACKING_OFFSET
			
		var durationMod = opponentPlayerController.comboHandler.getHitstunProrationMod(prorationSpriteAnimeId,meatyFlag)
		emit_signal("hitstun_proration_mod_applied",durationMod)
		#print(durationMod)
		#can't have histun of less thatn 1 frame from proration
		var hitstunDuration = null
		
		#the histun duration is static duration?
		if attackerHitbox.hitstunDurationType != attackerHitbox.HITSTUN_DURATION_TYPE_BASIC:
			
			#hitstunDuration = max(1,durationMod*rawHitstunDuration)
			hitstunDuration=max(1,rawHitstunDuration*durationMod) #in this case the mode is negative and remove from itstun
			#max 1 since non-basic mean 'hitstunDuration' is the raws duration of hitstun, its not realtive
		else:
			#histun duration relative, so can accpet - ,0, and +
			#hitstunDuration = durationMod*attackerHitbox.duration
			#hitstunDuration = durationMod*rawHitstunDuration
			hitstunDuration=rawHitstunDuration+durationMod #in this case the mode is negative and remove from itstun
			
			
		var autoCancelableFlag=attackerHitbox.onHitAutoCancelable and (not victimHurtbox.preventAutocancelOnHit)
		
		#must decide what knock back movement to use (some attacks will have different knockback properties if starting a combo)
		var knockBackMvmAnimation = attackerHitbox.hitstunMovementAnimation
		#following up with a combo?
		if playerState.inHitStun:
			
			#check if the attack  has special combo link knockback (linking a move into another, as opposed to starting a combo)
			if attackerHitbox.hitstunLinkMovementAnimation != null:
				knockBackMvmAnimation=attackerHitbox.hitstunLinkMovementAnimation
		
		
		#display sfx of the hitbox
		attackerHitbox.dispalyOnHitSFXSprites()
	
		applyHitstun(attackerPlayerController,attackSpriteId,relativeDamage,knockBackMvmAnimation, 
		autoCancelableFlag,hitstunDuration,attackerHitbox.hitstunDurationType,
		attackerHitbox.hitStunLandingType,attackerHitbox.minDurationBeforeFallProne,attackerHitbox.hitstunType,attackerHitbox.stopHitMomentumOnLand,attackerHitbox.isThrow,attackerHitbox.removesEmptyStar,hitBoxParentKinBody.spriteCurrentlyFacingRight,
		attackerHitbox.techExceptions,attackerHitbox.stopMomentumOnPushOpponent,attackerHitbox.stopMomentumOnOpponentAnimationPlay,attackerHitbox.ignoreComboTracking,
		attackerHitbox.falseCelingLockDuration,attackerHitbox.falseWallLockDuration,
		attackerHitbox.specialBounceMvmAnimations,attackerHitbox.newHitstunDurationOnLand,
		attackerHitbox.disableBodyBox,attackerHitbox.preventsAnimationStaleness,
		attackerHitbox.mvmStpOnOppAutoAbilityCancel,
		attackerHitbox.hideHitstunSprite)
	

		#to prevent counter riposting to guarantee a last hit to win the game, an counter ripost with no ripost
		#of with a bad ripost can't KO an oppponent
		#force the counter ripost fail for opponent that is counter riposting, since you gotta predict next
		#hitbox that hit
		if attackerHitbox.is_projectile and opponentPlayerController.newCounterRipostHandler.counterRiposting:		
			opponentPlayerController.newCounterRipostHandler._on_active_counter_ripost_and_projectile_hit_with_no_ripost()
			
		#shake sprite temporarily from hit
		var shakeIntensity = attackerHitbox.shakeIntensity
		if shakeIntensity > 0:
			
			handleHitShake(attackerHitbox)


		
	
	
	
	
	attackerPlayerController.attemptPlayOnHitActionId(attackerHitbox.on_hit_action_id,attackerHitbox.on_link_hit_action_id,attackerHitbox.cmd,attackerHitbox.on_hit_starting_sprite_frame_ix,wasInHitstun,attackerHitbox.preventOnHitActionWhenOnGround,attackerHitbox.preventOnHitActionWhenInAir,preventOnHitFlagEnabled)
	
	#make sure were not being hit during same attack
#	if not attackerPlayerController.playerState.inHitStun:
#		var onHitActionId = attackerHitbox.on_hit_action_id
		#current frame plays a new action on hit?
#		if onHitActionId != -1:
#			attackerPlayerController.playActionKeepOldCommand(onHitActionId)

func handleHitShake(attackerHitbox):
		

		var _shaketrauma = null				
		var _shakedecay=null
		var _shakemaxOffset=Vector2(0,0)
		var _shakepower =null
		var _shakeduration=null
		
		#default value ?
		if attackerHitbox.shakeTrauma == -1:
			
			#var middle = lerp(20, 30, 0.75)
		# `middle` is now 27.5.
				
			_shaketrauma=lerp(DEFAULT_MIN_HIT_SHAKE_TRAUMA,DEFAULT_MAX_HIT_SHAKE_TRAUMA,attackerHitbox.shakeIntensity)
		else:
			#hitbox defines its own shake paramters
			_shaketrauma=attackerHitbox.shakeTrauma 
		
			#default value ?
		if attackerHitbox.shakeDecay == -1:
			_shakedecay=DEFAULT_HIT_SHAKE_DECAY
		else:
			#hitbox defines its own shake paramters
			_shakedecay=attackerHitbox.shakeDecay 
		
		
		#default value ?
		if attackerHitbox.shakeMaxOffset.x == -1:
			if my_is_on_floor():
				#only shak3 left to right on ground
				_shakemaxOffset.x=lerp(DEFAULT_MIN_HIT_SHAKE_OFFSET,DEFAULT_MAX_HIT_SHAKE_OFFSET,attackerHitbox.shakeIntensity)
			else:
				_shakemaxOffset.x=0 #don't shake left to right in air
		else:
			#hitbox defines its own shake paramters
			_shakemaxOffset.x= attackerHitbox.shakeMaxOffset.x
		  
		#default value ?
		if attackerHitbox.shakeMaxOffset.y == -1:
			if not my_is_on_floor():
				#only shake up and down in air
				_shakemaxOffset.y=lerp(DEFAULT_MIN_HIT_SHAKE_OFFSET,DEFAULT_MAX_HIT_SHAKE_OFFSET,attackerHitbox.shakeIntensity)
			else:
				_shakemaxOffset.y=0 #don't shake up and down on the ground
		else:
			#hitbox defines its own shake paramters
			_shakemaxOffset.y= attackerHitbox.shakeMaxOffset.y
		
			#default value ?
		if attackerHitbox.shakePower == -1:
			_shakepower=DEFAULT_HIT_SHAKE_TRAUMA_POWER
		else:
			#hitbox defines its own shake paramters
			_shakepower=attackerHitbox.shakePower 
		
		#default value ?
		if attackerHitbox.shakeDuration == -1:
			_shakeduration=-1
		else:
			#hitbox defines its own shake paramters
			_shakeduration=attackerHitbox.shakeDuration 
		
		kinbody.sprite.startShaking(_shaketrauma,_shakedecay,_shakemaxOffset,_shakepower,_shakeduration)
		
		#add attacker slight shake too
		_shakemaxOffset.x = DEFAULT_HITTING_MAX_HIT_SHAKE_OFFSET
		_shakemaxOffset.y = 0
				
		_shaketrauma=lerp(DEFAULT_HITTING_MIN_HIT_SHAKE_TRAUMA,DEFAULT_HITTING_MAX_HIT_SHAKE_TRAUMA,attackerHitbox.shakeIntensity)
		opponentPlayerController.kinbody.sprite.startShaking(_shaketrauma,DEFAULT_HITTING_HIT_SHAKE_DECAY,_shakemaxOffset,DEFAULT_HITTING_HIT_SHAKE_TRAUMA_POWER,attackerHitbox.hitFreezeDuration)

				
func displayRedHPTemporarily():
	
	#already showing red?
	#if tmpDisplayRedHPFlag:
	#	return
		
	#tmpDisplayRedHPFlag = true
	
	#only send this out
	emit_signal("display_red_hp")
	
	#show red hp
	
	#wait 1 second
	#yield(get_tree().create_timer(3),"timeout")
	
	#not in hitstun?
	
	#i dont' think we need the hitstun check, since interfac3e checks for some reason (bad design)	
	#clear red hp
	#emit_signal("clear_red_hp")
	#check if in hitstun, if not, clear it
	
	#tmpDisplayRedHPFlag = false
func applyHitstun(attackerPlayerController, attackSpriteId, relativeDamage , mvmAnimation,autoCancelableFlag,duration,durationType,landingType, durationB4FallProne,hitstunType, stopHitMomentumOnLand,isThrow,attackRemovesEmptyStar,attackingSpriteFacingRight,techExceptions,stopMomentumOnPushOpponent,stopMomentumOnOpponentAnimationPlay,ignoreComboTracking,falseCelingLockDuration,falseWallLockDuration,_specialBounceMvmAnimations,_newHitstunDurationOnLand,_disableBodyBox,_attackPreventsAnimationStaleness,_mvmStpOnOppAutoAbilityCancel,hideHitstunSprite):
	
	
	if falseCelingLockDuration >=0:
		emit_signal("false_ceiling_lock",falseCelingLockDuration)
	else:
		emit_signal("false_ceiling_unlock")
	
	if falseWallLockDuration >=0:
		emit_signal("false_wall_lock",falseWallLockDuration)
	else:
		emit_signal("false_wall_unlock")

	emit_signal("about_to_be_applied_hitstun",attackSpriteId,relativeDamage)
	
	
	
	#only apply expering (if applicable to animation) if the attack/hitbox doesn't prevent becoming stale
	if not _attackPreventsAnimationStaleness:
		#some attacks expire after hitting a few times
		attackerPlayerController.actionAnimeManager.expireOneTimeHitAnimation(attackSpriteId)
		
	#for victim, they gain grab back as they were hit
	#playerState.isGrabOnCooldown=false
	playerState.grabCharges=playerState.defaultGrabCharges 
	
	if autoCancelableFlag:
		attackerPlayerController.actionAnimeManager.spriteFrameSetIsHitting(true)
	
	#flag the hit for any hitbox
	attackerPlayerController.actionAnimeManager.spriteFrameSetHittingAnyHitbox(true)
				
	if hitstunType == GLOBALS.HitStunType.NO_HITSTUN or hitstunType == GLOBALS.HitStunType.ON_LINK_ONLY_AND_HITSTUNLESS: #no hitstun for this move, like fox's laser
	#	emit_signal("clear_red_hp") #TODO: think of another way to show red upon taking damage, but not part of como
		
		displayRedHPTemporarily()
		
		#cause this will clear the red during a combo if hit with histulness move
		return
	elif hitstunType == GLOBALS.HitStunType.KNOCKBACK_ONLY: #no hitstun for this move, only knockback ( like doomfist upercut, but no damage)
				
		#only apply knockback, no hitstun
		#actionAnimeManager.movementAnimationManager.playMovementAnimation(mvmAnimation,not kinbody.facingRight)
		actionAnimeManager.movementAnimationManager.playMovementAnimation(mvmAnimation,not attackingSpriteFacingRight) #is the 'not' a bug?
		return
	#starting new combo?
	if not playerState.inHitStun:
		#here we assume that any attack that hits first won't be a hitbox that ignores combo tracking
		if ignoreComboTracking:
			#print("warning: starting a combo with a move that shouldn't count towards combo length")
			pass
		attackerPlayerController._on_starting_new_combo()
		
	else:
		
		#only increase combo  length for hitboxes that don't ignore (like grab on hit hitbox)
		if not ignoreComboTracking:
			#call this cause combo level check isn't being called here I don't think
			attackerPlayerController.playerState.increaseCombo()
	
	#SHOUT every few attacks (-1 sincE COMBO starts at 1 i beleive)
	if (attackerPlayerController.playerState.combo -1) % GET_HIT_SCREAM_FREQUENCY == 0:
		#play the get hit sound
		_on_request_play_special_sound(HERO_HITSTUN_STUN_SOUND_ID,HERO_SOUND_SFX)
		
	#calculateComboLevelWithSpriteId(attackerPlayerController, attackSpriteId)
		
	#enable potential of getting hit into a wall again, since last time hit
	wallBounceConssumedFlag = false
	
	
	
	#the hitboxe may have special bounce movement aniamtion when colliding with terrain
	actionAnimeManager.movementAnimationManager.specialBounceMvmAnimations =_specialBounceMvmAnimations
	
	
	if _specialBounceMvmAnimations != null:
		
		#when sure to keep track of where were facing when initially launhced, to avoid bouncing in mirror'ed dimesnios
		#if bounce occurs after a crossup
		#_specialBounceMvmAnimations.facingRightHitMovementPlayed = kinbody.facingRight
		#use the facing of sprite, not the direction that input is processed, since
		#a crossup should send you where sprite whould have hitu before crossup
		_specialBounceMvmAnimations.facingRightHitMovementPlayed = not attackerPlayerController.kinbody.getspriteCurrentlyFacingRight()
		
		#make sure reset number of time bounces occured as hitstun is replayed
		_specialBounceMvmAnimations.resetBounceCounters()
	
	
	attackerPlayerController.playerState.comboDamage += relativeDamage
	
	#if the player was moving forward or back, stop the momentum (usually releasing left or 
	#right ewould accomplish this, but maybe player was hit mid movement)
	

	stopWalkingMovement()	
	
			
	#var adding1ToCompensateFor1OffCalcs = false
	#dynamically determine how long hitstun is based on the hitstunduration type
	if durationType ==GLOBALS.HITSTUN_DURATION_TYPE_ADD:
		
	
		if playerState.inHitStun:
			
			#duration = calculateTargetAniamtionDuration(durationType,duration,actionAnimeManager.getHitstunFramesRemaining())
			
			#are we in special case where the hitastun has been overriden by oki and were hit during the first vulnerable frames
			if isInOkiHitstunSpriteAnimation():
				duration =calculateTargetAniamtionDuration(GLOBALS.HITSTUN_DURATION_TYPE_MEATY,duration,null) 
				#as oki resets hitstun, we treat this as a meaty duration
			else:
				
				#we add the duration to time left in hitstun
				duration = calculateTargetAniamtionDuration(durationType,duration,hitstunTimer.get_time_left_in_frames())
		else:
			duration =calculateTargetAniamtionDuration(GLOBALS.HITSTUN_DURATION_TYPE_MEATY,duration,null) #null since basic doesn't need curretn hitstun frames remaining
	
	else:
			
		duration = calculateTargetAniamtionDuration(durationType,duration,null)#null since basic and meaty doesn't need curretn hitstun frames remaining
		
	#duration = duration * GLOBAL_HIT_STUN_MOD
	if attackRemovesEmptyStar:	
		comboHandler.was_hit_remove_empty_star()
	
	
	#hitboxes may hide the player's sprite when hitting (like for attacks with temperoary sprite effects over, like cacoon)
	kinbody.sprite.visible=	not hideHitstunSprite
	
	#actionAnimeManager.playHitstun(duration,mvmAnimation,not attackingSpriteFacingRight,landingType, durationB4FallProne,my_is_on_floor(),stopHitMomentumOnLand,isThrow,techExceptions,stopMomentumOnPushOpponent)
	#0 duration for inifinite loop aniamtion (wait for timer to ellapse)
	actionAnimeManager.playHitstun(0,mvmAnimation,not attackingSpriteFacingRight,landingType, durationB4FallProne,my_is_on_floor(),stopHitMomentumOnLand,isThrow,techExceptions,stopMomentumOnPushOpponent,stopMomentumOnOpponentAnimationPlay,_newHitstunDurationOnLand,_disableBodyBox,_mvmStpOnOppAutoAbilityCancel)
	hitstunTimer.start(duration+1) #+1 as timer will be one frame early when finished signal occurs
	_on_start_tracking_frame_duration(duration+1)
	#expliclitly call this to make sure to reset the frame analyzer for new hit
	opponentPlayerController.frame_analyzer._on_opponent_hitstun_changed(true)
	

	displayFrameData(duration)
	
	
	
	

	#handle case where we combo somebody against a wall
	if collisionHandler.wasAgainstWall:
		_on_hit_against_wall()
	
	
	playerState.inHitStun = true
	
#	breakFreeFromThrowCheck()
#func stopHitFreeze():
#	self.hitFreezeTimer.stopHitFreeze()
#	_on_hit_freeze_finished()

func stopWalkingMovement():
	
	#this stops the air momntunm if landing and getting hit at same time
	if my_is_on_floor() and ((actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.AIR_MOVE_FORWARD_ACTION_ID)) or (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.AIR_MOVE_BACKWARD_ACTION_ID))):
		
		var keepRelativeGravComplexMvmRes = preload("res://complexMovement.gd")
		var keepRelativeGravComplexMvm = keepRelativeGravComplexMvmRes.new()
		keepRelativeGravComplexMvm.mvmType =keepRelativeGravComplexMvm.MovementType.POP_ALL_KEEP_RELATIVE_GRAVITY_SPEED
	
		#TODO: USE a movement animation to acheive to to follow the new design of mvm aniamtion manager	
		actionAnimeManager.movementAnimationManager.applyComplexMovementType(keepRelativeGravComplexMvm)
	
	#this stops the walking momentum	
	if (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.GROUND_MOVE_FORWARD_ACTION_ID)) or (actionAnimeManager.isCurrentMvmAnimation(actionAnimeManager.GROUND_MOVE_BACKWARD_ACTION_ID)):
		
		actionAnimeManager.movementAnimationManager.stopMovementAnimation()
			
func _on_hit_freeze_finished():
	unpauseAnimation()
	#inputManager.resetBufferSize()
	inputManager._on_hit_freeze_stopped()
	frame_analyzer._on_hit_freeze_stopped()
	inHitFreezeFlag=false
	wasInHitFreezeThisFrame=true

#duration: number of frames to pause game
#minimumRipostReactiveWindow: flag to indicate whether its an attack that's stopping game or seomtihng else that can be riposts are rquires at least 2 frame hitfreeze
#sometimes can do hitfreeze less than reactive window, like ability canceling for example
func startHitFreezeNotification(duration, minimumRipostReactiveWindow = false):
	
	if duration == null:
		return
	
	#if an attack is freezing game, the freeze duration is at minimum the ripost reactive window
	#since game freeze for that window of time to input godly reflects reaction time
	#otherwise, standard game freeze has minimum of 1
	if  minimumRipostReactiveWindow and ripostHandler.ripostingReactWindow  > duration:
		#print("warning, hit freeze window too short (shorter than reactive ripost hit freeze")
		duration = ripostHandler.ripostingReactWindow
	else:
		
		if duration < 1:
			return			
			

	emit_signal("start_hitfreeze",duration)

func stopHitFreezeNotification():
	emit_signal("stop_hitfreeze")
	
func _on_hit_freeze_started(duration):
	inHitFreezeFlag=true
	pauseAnimation()
	
	inputManager._on_hit_freeze_started()
	frame_analyzer._on_hit_freeze_started()

#used to handle the riposting/countering flags
func updateRipostFlags():
	
	#no longer riposting or counter riposting this frame
	riposting = false
	
	#wait 2 frames befores setting counter riposting flag to flase 
	#the processing of ripost all occurs in one frame
	if counterRipostingFinished:
		counterRiposting = false
		counterRipostingFinished = false
	if counterRiposting:
		counterRipostingFinished = true
	

#param: otherPlayerController, the target to ripost
func ripost(otherPlayerController):

	
	var ripostedInNeutral=false
	if not playerState.inHitStun:
		ripostedInNeutral=true
	
	#increase bars the amount by ratio depending on profiency
	#var amountToIncreaseBars = onRipostingDmgIncreaseRatio*playerState.focusCapacity
	playerState.damageGauge = min(playerState.damageGaugeCapacity,onRipostingDmgIncreaseRatio+playerState.damageGauge)
	#playerState.focus = min(playerState.focusCapacity,amountToIncreaseBars+playerState.focus)
	
	#TODO: DEOUBLE CHECK if action id is required or if its the sprite id
#	var ripostSpriteId = actionAnimeManager.RIPOST_SPRITE_ANIME_ID
	var ripostSpriteId  = null
	
	if my_is_on_floor():
		ripostSpriteId=actionAnimeManager.spriteAnimationIdLookup(actionAnimeManager.GROUND_RIPOST_ACTION_ID)
	else:
		ripostSpriteId=actionAnimeManager.spriteAnimationIdLookup(actionAnimeManager.AIR_RIPOST_ACTION_ID)
	
	_on_starting_new_combo_pre_damage()
	#do this signal before damage applied
	otherPlayerController.emit_signal("clear_red_hp")
	
	
	#are we riposting in neutral?
	if ripostedInNeutral:
		comboHandler.neutralRipostProrationSetback(NEUTRAL_RIPOST_PRORATION_SETBACK_NUMBER_HITS)
		
		
	var blocking = false
	
	var dmg = ripostDamage
	if counterRiposting:
		dmg = dmg * COUNTER_RIPOST_DAMAGE_MULTIPLIER
	#apply damage	to the opponent we riposted
	var relativeDamage = otherPlayerController.applyDamage(self,dmg,ripostingAbilityBarRegenMod,blocking)

	var durationBeforeFallProne = 0 #not applicable
	var stopHitMomentumOnLand = true #doesn't really matter, since ripost stops you in your tracks
	var isThrow=false
	var autoCancelableFlag=true
	var hitstunDurationType = GLOBALS.HITSTUN_DURATION_TYPE_MEATY
	var attackRemovesEmptyStar= false
	var techExcetions = GLOBALS.getTechNothingMask() #CAN'T tech a ripost
	var stopMomentumOnPushOpponent = false
	var stopMomentumOnOpponentAnimationPlay = false
	var ignoreComboTracking = false
	
	var _falseCelingLockDuration=-1 #don't lock false celing
	var _falseWallLockDuration = -1#dont' lock false walls
	var _specialBounceMvmAnimations = null #no special bounce
	var _newHitstunDurationOnLand = -1 #no new hitstun duration from landing
	var _disableBodyBox = false
	var _preventsAnimationStaleness =false 
	var _mvmStpOnOppAutoAbilityCancel =-1
	var hideHitstunSprite = false

	otherPlayerController.applyHitstun(self,ripostSpriteId,relativeDamage,ripostHitstunMovementAnimation,autoCancelableFlag,ripostHitstunDuration,hitstunDurationType,GLOBALS.LandingType.DONT_FALL_PRONE,durationBeforeFallProne,GLOBALS.HitStunType.BASIC,stopHitMomentumOnLand,isThrow,attackRemovesEmptyStar,self.kinbody.spriteCurrentlyFacingRight,techExcetions,stopMomentumOnPushOpponent,stopMomentumOnOpponentAnimationPlay,ignoreComboTracking,_falseCelingLockDuration,_falseWallLockDuration,_specialBounceMvmAnimations,_newHitstunDurationOnLand,_disableBodyBox,_preventsAnimationStaleness,_mvmStpOnOppAutoAbilityCancel,hideHitstunSprite)
	
	#make sure you can't win the game via ripost
	#this will et you style on your opponent for 3 seconds
	
	if  otherPlayerController.playerState.hp <=0:
		otherPlayerController.playerState.hp = 0.01#barely surviving
		
	#hitstun should no provoke fall prone
	#otherPlayerController.actionAnimeManager.setHitstunLandType_DONT_FALL_PRONE()
	
	#riposting doesn't count toward "hitting" for on hit canceling
	#playerState.hittingWithJumpCancelHitBox = false
	otherPlayerController.actionAnimeManager.spriteFrameSetIsHitting(false)
	otherPlayerController.actionAnimeManager.spriteFrameSetHittingAnyHitbox(false)
	emit_signal("ripost",ripostedInNeutral)
	
	#play sound of ripost
	#_on_request_play_special_sound(RIPOST_SOUND_ID)
	
	#handle case where simultanous ripst (don't go into ripost anymation if has just been riposted this frame)
	# both players should go into hitstun
	if not self.opponentPlayerController.riposting and not self.opponentPlayerController.counterRiposting:
		breakFromHistun()
		
		#make sure to save the ripost command, in case simultaneous ripost
		#then re-apply it
		if my_is_on_floor():
			
			playActionKeepOldCommand(actionAnimeManager.GROUND_RIPOST_ACTION_ID)
		else:
			playActionKeepOldCommand(actionAnimeManager.AIR_RIPOST_ACTION_ID)
	
	
#	self.startHitFreezeNotification(self.ripostHitFreeze)
	
	
	
#######################################################	
#				SIGNAL HANDLERS BELOW
#######################################################


#######################################################	
#				COUNTER RIPOST SIGNAL HANDLERS
#######################################################

func _on_ripost_was_countered(cmdRiposted):
	var cmdHitBy = null #since we were counter riposted, the command hitting us doesn't apply
	#emit_signal("ripost_attempted",inputManager.getFacingDependantCommand(cmdRiposted,kinbody.facingRight),inputManager.getFacingDependantCommand(cmdHitBy,kinbody.facingRight),false)
	var ripostedInNeutral=false #not applicaable to counter ripost
	emit_signal("ripost_attempted",cmdRiposted,cmdHitBy,false,ripostedInNeutral)
	#print("player " +self.get_parent().inputDeviceId+" _on_ripost_was_countered")
	#playerState.consumeAbilityBar(ripostingAbilityBarCost)
	playerState.forceConsumeAbilityBarInChunks(ripostingAbilityBarCost)
	
	playerState.numAttemptedRiposts+= 1
	#reset damage gauge, you were countered
	#playerState.damageGauge = 1
	
	#playerState.reduceDamageGaugeCapacity(playerState.damageGaugeCapacity-1) #-1 to reset the capacity to 1
	#playerState.reduceFocusCapacity(playerState.focusCapacity-1) #-1 to reset the capacity to 1

	 #reduce bar by amount depending on opponent dmg/focus ripost bar reduction mod	
	playerState.reduceDamageGauge(opponentPlayerController.onRipostingBarReduceAmount)
	playerState.reduceDamageGaugeCapacity(opponentPlayerController.onRipostingBarReduceAmount)
	#playerState.reduceFocus(opponentPlayerController.onRipostingBarReduceAmount)
	#playerState.reduceFocusCapacity(opponentPlayerController.onRipostingBarReduceAmount)
	
	self.opponentPlayerController.counterRiposting = true
	#unpauseAnimation()
	#stopHitFreeze()
	stopHitFreezeNotification()
	#the signal of counter ripost success will unause the other pcontroller's actionAnimeManager
	
#func _on_counter_ripost_invalid_prediction(cmdRiposted):
#	handleFailedCounterRipost(cmdRiposted)
	
func _on_counter_ripost_succeeded(cmdRiposted):
	
	newCounterRipostHandler.reset()
	
	#emit_signal("counter_ripost_attempted",inputManager.getFacingDependantCommand(cmdRiposted,kinbody.facingRight),true)
	emit_signal("counter_ripost_attempted",cmdRiposted,true)
	
	inputManager.resetRipostInputBuffer()
	
	#play the ripost hero specific sound sfx
	_on_request_play_special_sound(HERO_COUNTER_RIPOST_SOUND_ID,HERO_SOUND_SFX)
	
	#var counterRipostedSpriteId = actionAnimeManager.spriteAnimationIdLookup(cmdRiposted)
	
	var affectsDmgStarFill = true	
	#don't hurt dmg proration, counter ripost doesn't affect damage proration
	var dmgProrationMod=0
	var abilityFeedProrationMod=0
	var hitbox = null
	#have counter ripost count as type of move for leveling up combo, specify hitting a basic hurtbox subclass to make sure no
	#funny business when hitting and counting combos
	self.opponentPlayerController.calculateComboLevelWithCommand(self, cmdRiposted,hurtboxAreaResource.SUBCLASS_BASIC,affectsDmgStarFill,dmgProrationMod,hitbox,abilityFeedProrationMod)
	
	#print("player " +self.get_parent().inputDeviceId+" _on_counter_ripost_succeeded")
	#playerState.consumeAbilityBar(counterRipostingAbilityBarCost)
	playerState.forceConsumeAbilityBarInChunks(counterRipostingAbilityBarCost)
	playerState.numCounterRiposts+=1
	playerState.numAttemptedCounterRiposts+= 1
	
	
	#do we steal bar awa6y from opponenent?
	if counterRipostStealsBar:
		var opponentBarAmount = opponentPlayerController.playerState.abilityBar
		opponentPlayerController.playerState.abilityBar=0#steal the bar
		opponentPlayerController.emit_signal("pre_ability_bar_gain")
		playerState.abilityBar = playerState.abilityBar+opponentBarAmount
		opponentPlayerController.emit_signal("ability_bar_gain_finished")
	#unpauseAnimation()
	#stopHitFreeze()
	stopHitFreezeNotification()
	
	counterRiposting = true
	
	#ripost the opponent
	ripost(self.opponentPlayerController)
	
	#take away any proration (reset Proration)
	#comboHandler._on_ability_cancel(playerState.comboLevel,playerState.combo)
	comboHandler.setbackProrationCompletly(playerState.comboLevel,playerState.focusComboLevel,playerState.combo)
	
#func _on_counter_ripost_window_expired(cmdRiposted):	
#	handleFailedCounterRipost(cmdRiposted)

func _on_counter_ripost_failed(cmdRiposted):
	handleFailedCounterRipost(cmdRiposted)
	
#######################################################	
#				PREEMPTIVE RIPOST SIGNAL HANDLERS
#######################################################

#func _on_preemptive_ripost_invalid_prediction(attackerSpriteAnimationId,hitBoxArea,victimHurtboxArea,cmdRiposted):
#	preProcessFailedRipost(cmdRiposted,hitBoxArea.cmd)
#	var activelyFailedRipost=true
#	postProcessFailedRipost(activelyFailedRipost,attackerSpriteAnimationId,hitBoxArea,victimHurtboxArea)	

#func _on_preemptive_ripost_succeeded(hitBoxArea,cmdRiposted):	
#	handleSuccesfulRipost(hitBoxArea,cmdRiposted)
	

func _on_preemptive_ripost_window_expired(cmdRiposted):

	var cmdHitBy = null #wasn't hit when tryign to ripost preemptively
	preProcessFailedRipost(cmdRiposted,cmdHitBy)
	
	if actionAnimeManager.playerPaused:
		#mention this since below could be bug why people stay in ripost/block sprite animation
		print("note, premptive window of ripost exceeded while pause") 
		
	#since we wiffed the ripost entirely, if not in histun, get stunend for bad read
	if not playerState.inHitStun:
		goIntoVulnerableStunState(FAILED_NEUTRAL_RIPOST_STUN_DURATION)
	 
	#don't unpause on failing preemptive ripost since hitfreeze stil acitve
	#unpauseAnimation()
	#self.opponentPlayerController.unpauseAnimation()
#	

#######################################################	
#				REACTIVE RIPOST SIGNAL HANDLERS
#######################################################

func _on_reactive_ripost_invalid_prediction(attackerSpriteAnimationId,hitBoxArea,victimHurtbox,cmdRiposted):
	
	preProcessFailedRipost(cmdRiposted,hitBoxArea.cmd)
	var activelyFailedRipost=true
	postProcessFailedRipost(activelyFailedRipost,attackerSpriteAnimationId,hitBoxArea,victimHurtbox)
		
func _on_reactive_ripost_succeeded(hitBoxArea,cmdRiposted):	

	#did the opponent counter ripost us?
	if  opponentPlayerController.newCounterRipostHandler.succsfulCounterRipostCheck(cmdRiposted):
		_on_ripost_was_countered(cmdRiposted)
		opponentPlayerController._on_counter_ripost_succeeded(cmdRiposted)
	else:
		handleSuccesfulRipost(hitBoxArea,cmdRiposted)

	
func _on_reactive_ripost_window_expired(attackerSpriteAnimationId,hitBoxArea,victimHurtbox):	
	
	#this is the standard case wher eyour hit, and don't try to ripost
	var activelyFailedRipost=false
	postProcessFailedRipost(activelyFailedRipost,attackerSpriteAnimationId,hitBoxArea,victimHurtbox)	
		
	
	
func handleFailedCounterRipost(cmdRiposted):
	
	#emit_signal("counter_ripost_attempted",inputManager.getFacingDependantCommand(cmdRiposted,kinbody.facingRight),false)
	emit_signal("counter_ripost_attempted",cmdRiposted,false)
	
	inputManager.resetRipostInputBuffer()
	
	#print("player " +self.get_parent().inputDeviceId+" _on_counter_ripost_invalid_prediction")
	#playerState.consumeAbilityBar(counterRipostingAbilityBarCost)
	playerState.forceConsumeAbilityBarInChunks(counterRipostingAbilityBarCost)
	playerState.numAttemptedCounterRiposts+= 1
	
	#increase number of counter ripost during a combo, and don't bother if opponent isn't being combod
	#if opponentPlayerController.playerState.inHitStun:
		
	#	numFailedCounterRipostInCombo= numFailedCounterRipostInCombo+1
		
		#have we exceed n7umber of faile dcounter riposts for this combo?
	#	if numFailedCounterRipostInCombo >= numFailedCounterRipostNumThershold:
			
			#prevent a player from just simply expending bar and spamming
			#counter ripost to finish off low hp opponent
	#		opponentPlayerController.breakFromHistun()
		
	#play the failed ripost sound
	_on_request_play_special_sound(FAILED_RIPOST_SOUND_ID,COMMON_SOUND_SFX)
	
	#now increase damage guage of opponent (and capacity)
	failedRipostOpponentResourceIncrease()
	
	if not playerState.inHitStun:
		#50 frames of stun since you failed counter riposting
		goIntoVulnerableStunState(FAILED_COUNTER_RIPOST_STUN_DURATION)
	 
	
	
func handleSuccesfulRipost(hitBoxArea,cmdRiposted):
	
		
	var ripostedInNeutral = false
	if not playerState.inHitStun:
		ripostedInNeutral=true
	
		
	var cmdHitBy = cmdRiposted
	#emit_signal("ripost_attempted",inputManager.getFacingDependantCommand(cmdRiposted,kinbody.facingRight),inputManager.getFacingDependantCommand(cmdHitBy,kinbody.facingRight),true)
	emit_signal("ripost_attempted",cmdRiposted,cmdHitBy,true,ripostedInNeutral)	

	
	#playerState.consumeAbilityBar(ripostingAbilityBarCost)
	playerState.forceConsumeAbilityBarInChunks(ripostingAbilityBarCost)
	
	
	#play the ripost hero specific sound sfx
	_on_request_play_special_sound(HERO_RIPOST_SOUND_ID,HERO_SOUND_SFX)
	
	
	playerState.numRiposts+=1
	playerState.numAttemptedRiposts+= 1
	#now empty damage gauge of opponent
	#self.opponentPlayerController.playerState.reduceDamageGaugeCapacity(self.opponentPlayerController.playerState.damageGaugeCapacity-1)#-1 to reset the capacity to 1
	#self.opponentPlayerController.playerState.reduceFocusCapacity(self.opponentPlayerController.playerState.focusCapacity-1) #-1 to reset the capacity to 1
	
	#lose all damage buffs
	#opponentPlayerController.playerState.clearFillComboSubLevel()
	#opponentPlayerController.playerState.clearNumFilledDmgStars()
	#opponentPlayerController.playerState.clearNumEmptyDmgStars()
	opponentPlayerController.applyDmgStarRemoval()
	
	
	#reduce bar by amount depending on opponent dmg/focus ripost bar reduction mod	
	opponentPlayerController.playerState.reduceDamageGauge(onRipostingBarReduceAmount)
	opponentPlayerController.playerState.reduceDamageGaugeCapacity(onRipostingBarReduceAmount)
	#opponentPlayerController.playerState.reduceFocus(onRipostingBarReduceAmount)
	#opponentPlayerController.playerState.reduceFocusCapacity(onRipostingBarReduceAmount)
	
	#the opponent will now not gain bar for a bit
	opponentPlayerController.abilityBarGainLockHandler.activate(faildRipostBarGainLockTimeSecs,faildRipostBarGainLockNumHits)
		
	#reset the counter used to determine how much we increase ability bar
	#from magic series, since you were ripost, you lose all ability bar gain
	#you would have gottne since you got riposted
	opponentPlayerController.playerState.magicSeriesBarIncreaseCount = 0
	opponentPlayerController.playerState.airMagicSeriesBarIncreaseCount = 0
	
	
	#stopHitFreeze()
	stopHitFreezeNotification()
	#unpauseAnimation()
	
	#print("player " +self.get_parent().inputDeviceId+" _on_reactive_ripost_succeeded")
	if hitBoxArea != null:
		#hitBoxArea.playerController.unpauseAnimation()
		#self.opponentPlayerController.stopHitFreeze()
		riposting = true
		ripost(hitBoxArea.playerController)
			
	else:
		print("warning, riposted null hitbox")
	
func preProcessFailedRipost(cmdRiposted,cmdHitBy):
			
		
	var ripostedInNeutral = false
	if not playerState.inHitStun:
		ripostedInNeutral=true
	
		
	#emit_signal("ripost_attempted",inputManager.getFacingDependantCommand(cmdRiposted,kinbody.facingRight),inputManager.getFacingDependantCommand(cmdHitBy,kinbody.facingRight),false)
	emit_signal("ripost_attempted",cmdRiposted,cmdHitBy,false,ripostedInNeutral)	
	
	
	#playerState.consumeAbilityBar(ripostingAbilityBarCost)
	playerState.forceConsumeAbilityBarInChunks(ripostingAbilityBarCost)
	
	#startHitFreezeNotification(FAILED_RIPOST_HIT_FREEZE_DURATION)
	
	#now increase damage guage of opponent (and capacity)
	failedRipostOpponentResourceIncrease()
	
	#avoid locking out ability bar in stun as opposed to bad ripost mid histstun (the punish is free combo)
	#lock the ability bar gain fro a momentum to punish player
	if playerState.inHitStun:
		abilityBarGainLockHandler.activate(faildRipostBarGainLockTimeSecs,faildRipostBarGainLockNumHits)
	
	#play the failed ripost sound
	_on_request_play_special_sound(FAILED_RIPOST_SOUND_ID,COMMON_SOUND_SFX)
	
	playerState.numAttemptedRiposts+= 1

func postProcessFailedRipost(activelyFailedRipost,attackerSpriteAnimationId,hitBoxArea,victimHurtbox):

	var preventGuard = false
	var guardDisabledValue = null
	if hitBoxArea != null:
	
		#only apply hitstun if knockback exists
		if hitBoxArea.hitstunMovementAnimation != null:
			#a normal hitbox that doesn't trigger a counter?
			if victimHurtbox.onGettingHitCounterActionId == -1 or hitBoxArea.isThrow:
				
			
				#did we try to ripost and fail?
				if activelyFailedRipost:
					
						#so during a combo, failing a ripost has the concequence of losing ability bar regen and
						#reset opponent's damage scaling
				
					if not playerState.inHitStun:
						#otherwise, we might block, have invincibilty, or tank via super armor, so just become stunned
						#to make sure attack hits
						goIntoVulnerableStunState(FAILED_NEUTRAL_RIPOST_STUN_DURATION)
						
						#there is a frame perfect case where you input a backwards ripost
						#so technically your in an animation where you can block, and
						#then you go into vulnerability, but the block stun then overrides it
						if guardHandler.isBlocking():
							preventGuard=true #don't let the block happen. you tried to ripost and failed, so you should be hit
							
							guardDisabledValue=guardHandler.blockingDisabled
							#a hackish way to fix the problem. We make sure to disable the gaurd handler's blocking status briefly
							guardHandler.blockingDisabled=true
							
						
					
				
				# attack applied normally
				applyAttack(hitBoxArea,victimHurtbox,attackerSpriteAnimationId)
				
				if preventGuard:
					#if we prevent guard in a rare situation where blocking and same frame hit as when ripost
					#we disabled gaurd and now bring it back to it's orrignal value
					guardHandler.blockingDisabled=guardDisabledValue
			elif victimHurtbox.onGettingHitCounterActionId != -1 or hitBoxArea.isThrow:
				
				
				var preventOnHitFlagEnabled = false

	
				#by default on hit animation inherit the "is hitting" to auto cancel on hit
				#so gotta disable that explicitly when should't be able to autocancel on hit
				if not victimHurtbox.preventAutocancelOnHit:
					#opponentPlayerController.actionAnimeManager.spriteFrameSetIsHitting(true)	
					preventOnHitFlagEnabled=false
				else:
					#opponentPlayerController.actionAnimeManager.spriteFrameSetIsHitting(false)			
					preventOnHitFlagEnabled=true
			
				if hitBoxArea.belongsToProjectile():
					print("parry on hit action bbug found when projectile hits parry animation")
				#were hitting a countering opponent? 
				#elsewhere logic is in place to have the opponent do the parry animation from being hit
				#but the attacker still technically hit, so applying on hit and on hit action animations needs to be done here				
				#buuged (missing an arg)
				#hitBoxArea.playerController.attemptPlayOnHitActionId(hitBoxArea.on_hit_action_id,hitBoxArea.on_link_hit_action_id,hitBoxArea.cmd,playerState.inHitStun,hitBoxArea.preventOnHitActionWhenOnGround,hitBoxArea.preventOnHitActionWhenInAir,preventOnHitFlagEnabled)
				#not bugged
				var wasInHitstun = false
				if victimHurtbox.belongsToProjectile():
					wasInHitstun = false
				else:
					wasInHitstun = victimHurtbox.playerController.playerState.inHitStun
				hitBoxArea.playerController.attemptPlayOnHitActionId(hitBoxArea.on_hit_action_id,hitBoxArea.on_link_hit_action_id,hitBoxArea.cmd,hitBoxArea.on_hit_starting_sprite_frame_ix,wasInHitstun,hitBoxArea.preventOnHitActionWhenOnGround,hitBoxArea.preventOnHitActionWhenInAir,preventOnHitFlagEnabled)
			
				
				pass
				
				
	else:			
		print("null hit box in ripost singals")
		
		
		
func failedRipostOpponentResourceIncrease():
	
 
	
	#everything above is legacy code. deprecated
	
	#do we have dmg stars?, lose it
	if playerState.numFilledDmgStars > 0:
		playerState.decreaseNumFilledDmgStars()	
		
	#do we have an empty star? lost it
	elif playerState.numEmptyDmgStars > 0:
		playerState.decreaseNumEmptyDmgStars()
	else:
		
		#don't have a dmg star to sacrifice, so give one to opponeont
		
		#opponent has empty star? fill it
		#when we don't we feed dmg stars
		if self.opponentPlayerController.playerState.numEmptyDmgStars>0:
			
			self.opponentPlayerController.playerState.increaseNumFilledDmgStars()
		else:
			
			#opponent doesn't have an emtpyt start to fill, so give them one	
			self.opponentPlayerController.playerState.increaseNumEmptyDmgStars()
		#give a star and empty star for failed ripost
		#self.opponentPlayerController.playerState.increaseNumEmptyDmgStars()
		#self.opponentPlayerController.playerState.increaseNumEmptyDmgStars()
#		var hadEmptyStar = false
#		if self.opponentPlayerController.playerState.numEmptyDmgStars>0:
#			hadEmptyStar=true
#		self.opponentPlayerController.playerState.increaseNumFilledDmgStars()
		#since we gave a free star, make sure that if there existed an empty star, it's replaced
#		if hadEmptyStar:
		
#			self.opponentPlayerController.playerState.increaseNumEmptyDmgStars()

	opponentPlayerController.comboHandler.hardResetProration()
	
#func _on_wall_collision():
func _on_hit_against_wall():
	

	pass
	
	#although this fonction only called whe hit against wall,
	#it would be detremental to gameplay if a bug lead to making
	#somebody not in hitstun fall into histun from a wall 
	#collision, so make the check anyway
	#if playerState.inHitStun:/
		
		#only handle a wall bounce whe hit into a wall, not pushed
	#	if not wallBounceConssumedFlag:
	#		wallBounceConssumedFlag	 = true
			#make sure to limit the wall bounce combos
	#		if wallBounces < maxNumberWallBounces:
	#			wallBounces+=1
				#print("bounce off wall")
				#playActionKeepOldCommand(actionAnimeManager.WALL_BOUNCE_ACTION_ID)
	#		else:				
					
				#are we in the air (last frame tick)?
				#if playerState.wasInAir:
	#			if collisionHandler.wasInAir:
	#				if not actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.INVULNERABLE_AIR_HITSTUN_ACTION_ID):
						#go into invulnerable hitstun
	#					playActionKeepOldCommand(actionAnimeManager.INVULNERABLE_AIR_HITSTUN_ACTION_ID)
			#	else:
					#were on ground, so go into fall down hitstun
					#prevent infinite bouncings
			#		if not actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.LANDING_HITSTUN_ACTION_ID):
						#go into invulnerable hitstun
			#			playActionKeepOldCommand(actionAnimeManager.LANDING_HITSTUN_ACTION_ID)

func _on_left_wall():
	
	pass
	#wallBounces=0
	
func _on_player_attacked_clashed(otherHitboxArea, selfHitboxArea):
	
	
	
	#play the clashing sound when attacks collide (not necessarily go into rebound)
	_on_request_play_special_sound(ATTACK_CLASH_SOUND_ID,COMMON_SOUND_SFX)
	
	
	#we disable hitboxes from hitting hurtxboxes if they aren't of category TRADER
	#hitboxes can only trade hits betwen active hitboxes with Trader category
#	if selfHitboxArea.clashType != selfHitboxArea.CLASH_TYPE_TRADER and selfHitboxArea.clashType != selfHitboxArea.CLASH_TYPE_POWER_TRADER:
	selfHitboxArea.spriteAnimation.disableAllHitboxes()
#	if otherHitboxArea.clashType != otherHitboxArea.CLASH_TYPE_TRADER and otherHitboxArea.clashType != otherHitboxArea.CLASH_TYPE_POWER_TRADER:
#	otherHitboxArea.spriteAnimation.disableAllHitboxes()
		
		
	var reboundActionId = actionAnimeManager.REBOUND_ACTION_ID
	var hitFreezeDuration=CLASH_HIT_FREEZE_DURATION
	var numReboundFrames = max(otherHitboxArea.clashRecoveryDuration,1) #minimum 1 frame of rebound recovery
	startHitFreezeNotification(hitFreezeDuration)
	
	
	
	adjustSpriteAnimationSpeed(numReboundFrames,reboundActionId)
	#keep old command so if play is hit in rebound, then ripost can take place
	playActionKeepOldCommand(reboundActionId)
			
	emit_signal("clash",otherHitboxArea,selfHitboxArea)
	
	
#this is called when this player's invincibility frames were hit	
func _on_player_invincibility_was_hit(otherHitboxArea, selfInvincibilityboxArea):
	
	#print(str(self.get_parent()) + " player invincibility was hit")
	if otherHitboxArea == null:
		print("null hitbox hitting invicibiilty")
		return
	
	
	if not otherHitboxArea.ripostabled and (otherHitboxArea.hitstunType == GLOBALS.HitStunType.NO_HITSTUN or otherHitboxArea.hitstunType == GLOBALS.HitStunType.ON_LINK_ONLY_AND_HITSTUNLESS):
		#nothing tho check, the non ripostable histnless hitboxes are used for triggering on hit action ids
		#when in proximity to player
		
		#triggers the hitbox play action
		#for hitstulness hitboxes or thos that ignore the react ripost, we try play on hit
		
		var preventOnHitFlagEnabled = false
		var wasInHitstun = playerState.inHitStun
		opponentPlayerController.attemptPlayOnHitActionId(otherHitboxArea.on_hit_action_id,otherHitboxArea.on_link_hit_action_id,otherHitboxArea.cmd,otherHitboxArea.on_hit_starting_sprite_frame_ix,wasInHitstun,otherHitboxArea.preventOnHitActionWhenOnGround,otherHitboxArea.preventOnHitActionWhenInAir,preventOnHitFlagEnabled)
		
		return
		pass	
	#SOME invincibility frame animation notify they were hit (oki, for example shouldn't, since cleary
	#its incinsible, but DP it should be clear)
	if actionAnimeManager.isInvincibleSpriteAnimationId(selfInvincibilityboxArea.spriteAnimation.id):
		
		#only notify invincibility hit once per animation. So if a multi hit or projectile hit as
		#youhit, only one notification (this should be fine. If ever want multi display of the invincibilyt)
		#can just keep a list of hitboxes that hit the animation, and notify when new hitbox hits,
		#clearing list upon playing animation
		if not selfInvincibilityboxArea.spriteAnimation.invincibilityWasHitFlag:
			selfInvincibilityboxArea.spriteAnimation.invincibilityWasHitFlag=true
			opponentPlayerController.emit_signal("hit_invincibility_opponent")
			
	if actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.AUTO_RIPOST_ACTION_ID) or actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.AIR_AUTO_RIPOST_ACTION_ID):#AUTO RIPOST
		

		#have we been anti-blocked?#might want to check for throw flag instead of specific aniamtion (so belt can have many grabs...)
		if otherHitboxArea.isThrow:
			var autoriposting = true
			#display a over-head symbole for getting grabbed while auto riposting
			kinbody.displayLocalTemporarySprites(kinbody.grabbedAutoRipostingSrptiesSFXs)
			on_was_grabbed_in_block(otherHitboxArea, selfInvincibilityboxArea,autoriposting)
			opponentPlayerController.emit_signal("grabbed_auto_riposter")
			
		
				
		else:
			
			#play sound of on hit of the auto parry
			_on_request_play_special_sound(AUTO_RIPOST_ON_HIT_SOUND_ID,COMMON_SOUND_SFX)
			
			if my_is_on_floor():#AUTO RIPOST ON HIT
				playAction(actionAnimeManager.AUTO_RIPOST_ON_HIT_ACTION_ID)
			else:
				playAction(actionAnimeManager.AIR_AUTO_RIPOST_ON_HIT_ACTION_ID)
			
			emit_signal("auto_ripost")
			
			
			kinbody.displayLocalTemporarySprites(kinbody.autoRipostOnHitSpriteSFXs)		
			
			#make sure the hitbox that hit the autoripost is disabled
			#otherHitboxArea.spriteAnimation.disableAllHitboxes() #todo
			otherHitboxArea.spriteAnimation.disableAllHitboxesFromHit()
			
			#start the guard regen buff from autoripost
			playerState.setGuardRegenBuffEnabled(true)			
			guardRegenBoostBuffTimer.start(autoRipostGuardRegenBuffDuration)
			emit_signal("guard_regen_buffed_enabled",autoRipostGuardRegenBuffDuration,guardRegenBoostBuffTimer)
			#display hit particles to hype up the hit autoripost
			opponentPlayerController.handleAttackTypeLightingSignaling(otherHitboxArea)
			#give a moment to register you hit auto parry opponent by freezing game
			#but don't make it too long since ability cancel into block is way to easy
			#if long
			startHitFreezeNotification(HTTING_AUTO_RIPOST_OPPONENT_HIT_FREEZE_DURATION)
			
			playerState.numSuccesfulBlocks+=1
			
			
			
		
		return
		

#called when hitting non-blocking opponent with anti block
func _on_failed_anti_block_hit_opponent():
		
		var failureFlag = true
		playerState._on_grab(failureFlag)

#called when didn't hit an opponent at all with anti block
func _on_whiffed_grab():
		
	#do we go on cooldown from missing a grab?
	if whiffedGrabProvokesCooldown:
		#playerState.isGrabOnCooldown=true
		playerState.grabCharges= playerState.grabCharges -1 
	
	var failureFlag = true
	playerState._on_grab(failureFlag)	

#hook for subclasses to override
func on_grabbing_opponent():
	var failureFlag = false
	playerState._on_grab(failureFlag)
	
	#starting new combo
	#if not otherPlayerController.playerState.inHitStun:
	#	_on_starting_new_combo()
		#call this cause combo level check isn't being called here I don't think
	#	playerState.increaseCombo()

func on_was_grabbed_in_block(otherHitboxArea, selfHurtboxArea,autoriposting):
	
	
	#PLAY the anit block sucess sound effect
	#_on_request_play_special_sound(ANTI_BLOCK_SUCCESS_SOUND_ID)
	
		#check to see if the itBox have a special sound to play		
	if otherHitboxArea.heroSFXSoundId != -1:
		#play hero-specific sound specified by hitBox
		_on_request_play_special_sound(otherHitboxArea.heroSFXSoundId,HERO_SOUND_SFX,otherHitboxArea.heroSFXSoundVolumeOffset)
	elif otherHitboxArea.commonSFXSoundId != -1:
		#play universal sound specified by hitBox
		_on_request_play_special_sound(otherHitboxArea.commonSFXSoundId,COMMON_SOUND_SFX,otherHitboxArea.commonSFXSoundVolumeOffset)
	else:
		hittingSFXPlayer.playRandomSound() #play default random sound

		
		
	#legacy code?
	
	var blocking= false
	#apply damage
	var relativeDamage = applyDamage(opponentPlayerController,otherHitboxArea.damage,otherHitboxArea.abilityRegenMod,blocking)
	#var attackSpriteId = otherHitboxArea.playerController.actionAnimeManager.currentSpriteAnimation
	var attackSpriteId = otherHitboxArea.spriteAnimation.id
	var autoCancelableFlag=otherHitboxArea.onHitAutoCancelable and (not selfHurtboxArea.preventAutocancelOnHit)
	var hitstunDurationType = GLOBALS.HITSTUN_DURATION_TYPE_BASIC
	
	var hitBoxParentKinBody =otherHitboxArea.getParentKinbody()
		
	applyHitstun(opponentPlayerController,attackSpriteId,relativeDamage,otherHitboxArea.hitstunMovementAnimation,autoCancelableFlag,otherHitboxArea.duration,otherHitboxArea.hitstunDurationType,otherHitboxArea.hitStunLandingType,
				otherHitboxArea.minDurationBeforeFallProne,otherHitboxArea.hitstunType,otherHitboxArea.stopHitMomentumOnLand,otherHitboxArea.isThrow, otherHitboxArea.removesEmptyStar,hitBoxParentKinBody.spriteCurrentlyFacingRight,
				otherHitboxArea.techExceptions,otherHitboxArea.stopMomentumOnPushOpponent,otherHitboxArea.stopMomentumOnOpponentAnimationPlay,otherHitboxArea.ignoreComboTracking,
				otherHitboxArea.falseCelingLockDuration,otherHitboxArea.falseWallLockDuration,
				otherHitboxArea.specialBounceMvmAnimations, otherHitboxArea.newHitstunDurationOnLand,
				otherHitboxArea.disableBodyBox, otherHitboxArea.preventsAnimationStaleness,
				otherHitboxArea.mvmStpOnOppAutoAbilityCancel,
				otherHitboxArea.hideHitstunSprite)


	#can't win game when doing a counter ripost
	#to prevent having a hitbox protected and unpunishable
	#if opponentPlayerController.newCounterRipostHandler.counterRiposting:
	#	if  playerState.hp <=0:
	#		playerState.hp = 0.01#barely surviving
	#for projectiles (where can counter ripost riht before projectile hits as opposed to being commited into animation)
	#force the counter ripost fail for opponent that is counter riposting, since you gotta predict next
	#hitbox that hit
	if otherHitboxArea.is_projectile and opponentPlayerController.newCounterRipostHandler.counterRiposting:		
		opponentPlayerController.newCounterRipostHandler._on_active_counter_ripost_hit_with_no_ripost()
	
	opponentPlayerController.on_grabbing_opponent()
	
	var wasInHitstun = false #false since grabbed in block
	var preventOnHitActionWhenOnGround = false
	var preventOnHitActionWhenInAir=false
	var preventOnHitFlagEnabled = false
	opponentPlayerController.attemptPlayOnHitActionId(otherHitboxArea.on_hit_action_id,otherHitboxArea.on_link_hit_action_id,otherHitboxArea.cmd,otherHitboxArea.on_hit_starting_sprite_frame_ix,wasInHitstun,preventOnHitActionWhenOnGround,preventOnHitActionWhenInAir,preventOnHitFlagEnabled)
	
	#does the opponent get bar from grabbing an auto riposting opponent?
	#note that this doesn't include the recovery of autoripost. so it's a well timed grab only during
	#invincibility of auto riposte
	if autoriposting and opponentPlayerController.barChunksGainedOnGrabbingAutoriposter>0:
		
		#can't gain bar from the half way mark if locked ot of bar
		if not playerState.abilityBarGainLocked:
			opponentPlayerController.emit_signal("pre_ability_bar_gain")
			opponentPlayerController.playerState.increaseAbilityBarInChunks(barChunksGainedOnGrabbingAutoriposter)
			opponentPlayerController.emit_signal("ability_bar_gain_finished")
		
	emit_signal("grabbed_in_block")

#this is called when this player is hit
func _on_player_was_hit(otherHitboxArea, selfHurtboxArea):
	
	#print(str(self.get_parent().inputDeviceId) + " player was hit")
	if otherHitboxArea == null:
		print("null hitbox hitting this player")
		return
	if selfHurtboxArea == null:
		print("warning null hurtbox  was hit")

	
	#ignore hits on active frames for special hitboxes (if we active (has active hitbox) and hitbox can't
	# hit such a state, we ignored the collision)
	if not otherHitboxArea.canHitActiveFrame:
		var inActiveFrames = actionAnimeManager.spriteAnimationManager.isInActiveAnimation()
		
		if inActiveFrames:
			return
	if not otherHitboxArea.canHitStartupFrame:
		var inStartupFrames = actionAnimeManager.spriteAnimationManager.isInStartupAnimation()
		
		if inStartupFrames:
			return

	#	var sa = actionAnimeManager.getCurrentSpriteAnimation()
		
	#	if sa != null:
	#		var sf = sa.getCurrentSpriteFrame()
			
	#		if sf != null:
				
				#were in active attack?
	#			if sf.type == sf.FrameType.ACTIVE:
					#ignore collision
					#print("can't hit active frame with this hitbox")
	#				return

	
	#does this hitbox create a projectile on hit?
	if otherHitboxArea.projectileInstancer != null:
		otherHitboxArea.projectileInstancer.attemptSignalProjectileCreation()
		
	
	if not selfHurtboxArea.selfOnly and  otherHitboxArea.hitstunType != GLOBALS.HitStunType.KNOCKBACK_ONLY:
		#otherHitboxArea.spriteAnimation.disableAllHitboxes() #todo 
		otherHitboxArea.spriteAnimation.disableAllHitboxesFromHit()
		
	if selfHurtboxArea.selfOnly:
		#make sure we can't keep hitting ball with later hitboxes of same bat animation
		otherHitboxArea.spriteAnimation.disableAllSelfOnlyHitboxes()
		
	
	#todo: add logic to play sounds based on type melee, special, tool, ingoring the hit box 
	#sfx for now. if its not melee, special, tool, then play the sound specified by hitbox (left autoparry hit)
	#play the sound of getting hit	
	#playOnHitSound(selfHurtboxArea.commonSFXSoundId,otherHitboxArea.commonSFXSoundId)
	#soundeffect only for moves that aren't knockback only
	if otherHitboxArea.hitstunType != GLOBALS.HitStunType.KNOCKBACK_ONLY: #no hitstun for this move, only knockback ( like doomfist upercut, but no damage)			
	
		#only apply the on hit sound effect when u don't block
		if otherHitboxArea.isThrow or not guardHandler.isBlocking():
			opponentPlayerController.playOnHitSound(selfHurtboxArea,otherHitboxArea)
			
	#go into hit freeze
	#pauseAnimation()
	#otherHitboxArea.playerController.pauseAnimation()
	#hitFreezeTimer.startHitFreeze(otherHitboxArea.hitFreezeDuration)
	#self.opponentPlayerController.hitFreezeTimer.startHitFreeze(otherHitboxArea.hitFreezeDuration)
	#go into hit freeze (minimum duration is reactive ripost window)
	#don't apply hitfreeze when there is no hitstun 
	if otherHitboxArea.hitstunType != GLOBALS.HitStunType.NO_HITSTUN and otherHitboxArea.hitstunType != GLOBALS.HitStunType.ON_LINK_ONLY_AND_HITSTUNLESS and otherHitboxArea.hitstunType != GLOBALS.HitStunType.KNOCKBACK_ONLY:
		
		
		
		#does the hurtbox trigger a  counter and we aren't getting grabbed??
		if selfHurtboxArea.onGettingHitCounterActionId != -1 and not otherHitboxArea.isThrow:
			#make sure te counter animation is played before hitfreeze, to avoid having
			#any of it's hitboxes disabled upon unpausing animation as hitfreeze stops
			#player won't be attacked, instead they counter with an action
			emit_signal("parry")
			#make sure this hit against a parry hurtbox counts as a hit for sake of resetting proration
			#of attacker
			opponentPlayerController.comboHandler.hardResetProration()
			actionAnimeManager._playAction(selfHurtboxArea.onGettingHitCounterActionId,kinbody.facingRight,selfHurtboxArea.cmd)
		

		startHitFreezeNotification(otherHitboxArea.hitFreezeDuration,true)#true to always freeze minimum 2 frames for reactive window delay
		
		
	
	
	
	#here we comapre the current sprite animation to anti-block
	#if attacker is anti-blocjing and the victim is budget blocking, succesfful with anti block
	
	#var antiBlocked = selfHurtboxArea.canHoldBackBlock and holdingBackward
	#var hitSpriteAnimation = otherHitboxArea.spriteAnimation
	
	#antiBlocked = antiBlocked and (hitSpriteAnimation.id == opponentPlayerController.actionAnimeManager.AIR_GRAB_SPRITE_ANIME_ID or hitSpriteAnimation.id == opponentPlayerController.actionAnimeManager.GROUND_GRAB_SPRITE_ANIME_ID)
	
	#have we been anti-blocked? can't be anti blocked by a proejctile (avoid situation where we grabing and a projetile hits oopponent, which counts as grab)
	#
#	if antiBlocked and not otherHitboxArea.is_projectile: #might want to check for throw flag instead of specific aniamtion (so belt can have many grabs...)
	if otherHitboxArea.isThrow and guardHandler.isBlocking():
		var autoriposting = false
		on_was_grabbed_in_block(otherHitboxArea, selfHurtboxArea,autoriposting)
		return
			
	#it may be case that block recovery frames were hit, so effectively 
	#block (victim) missed the block,
	
	#var areWeBlocking = actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.AUTO_RIPOST_ACTION_ID)
	#areWeBlocking = areWeBlocking or actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.AIR_BLOCK_ACTION_ID)
		
	#var canRipost = otherHitboxArea.ripostabled and playerState.hasEnoughAbilityBar(ripostingAbilityBarCost)
	var ripostReactWindowStarted =ripostHandler.startBriefRipostCheckHitResolveDelay(otherHitboxArea,selfHurtboxArea,playerState.hasEnoughAbilityBar(ripostingAbilityBarCost))
	
	#for hitstulness hitboxes or thos that ignore the react ripost, we try play on hit
	if not ripostReactWindowStarted:
		var preventOnHitFlagEnabled = false
		var wasInHitstun = playerState.inHitStun
		opponentPlayerController.attemptPlayOnHitActionId(otherHitboxArea.on_hit_action_id,otherHitboxArea.on_link_hit_action_id,otherHitboxArea.cmd,otherHitboxArea.on_hit_starting_sprite_frame_ix,wasInHitstun,otherHitboxArea.preventOnHitActionWhenOnGround,otherHitboxArea.preventOnHitActionWhenInAir,preventOnHitFlagEnabled)
		
	#LOGIC ISSUE/ BUG below
	#When you don't have enough for bar or the attack is ripostable, on hit, you can auto cancel on hit sooner if opponent out
	#of bar or hitting with ripost-immune attack. I don't know what the side effcts are, but the pace of game feels off
	#will need to always enter 2 frame wait until apply attack and trigger the on hit, even if not ripostable. 
	#will need a new state in ripost ahdnerl to handle case where were tracking reactive window time 
	#for sake that game is handled at the same pace even if u can't ripost
		
	#only check for riposting if hitbox can be riposted and enough ability bar to ripost
	#also, even if input ripost before blocking, if hit and bluck stun will trigger, ignore this 
	#and dones't count that for ripost checking (even if they hit you with move you riposted, u gotta
	#tank it, you can't block)
#	if otherHitboxArea.ripostabled and playerState.hasEnoughAbilityBar(ripostingAbilityBarCost):

#		if not ripostHandler._on_player_was_hit(otherHitboxArea,selfHurtboxArea):

#			pass
#	else:
		
		
		#only apply the attack to non-counter hurtboxes or throws (can't counter a throw)
#		if selfHurtboxArea.onGettingHitCounterActionId == -1 or otherHitboxArea.isThrow:
			#a normal hurtbox
			
#			var attackSpriteId = otherHitboxArea.spriteAnimation.id

#			applyAttack(otherHitboxArea,selfHurtboxArea,attackSpriteId)
		
		#was the attack a projectile?
		#if so, allow the projectile's master to benifit from autocanceling on hit
		#only if projectile triggers on hit autocancels
#		if otherHitboxArea.is_projectile and otherHitboxArea.onHitAutoCancelable and (not selfHurtboxArea.preventAutocancelOnHit):
#			opponentPlayerController.actionAnimeManager.spriteFrameSetIsHitting(true)
		

func applyAttack(attackerHitboxArea, victimHurtboxArea,attackSpriteId):
	
	#TODO: make the logic addres fact that attackSpriteId 
	#isn't linked to a projectiles' sprite aniamtion hit. 
	#so if aniamtion that created the projectile ends before hitting
	#with projectile, attackSpriteId is out of date
	
	#FOR NOW IT'S FINE LIKE THIS
	lastHitBySpriteAnimeId=attackSpriteId
	
	var attackSFXPosition=null
		
	if guardHandler.isBlocking():
		var blockResult = guardHandler.blockedAttackStatus(attackerHitboxArea)
		
		if not attackerHitboxArea.emitsAttackSFXSignal:
			for c in attackerHitboxArea.get_children():
				
				if c is CollisionShape2D:
					
				
					attackSFXPosition = c.global_position
					break
					
				
		emit_signal("display_block_sfx",attackerHitboxArea,blockResult,not kinbody.spriteCurrentlyFacingRight)
		
	else:
		attackSFXPosition = opponentPlayerController.handleAttackTypeLightingSignaling(attackerHitboxArea)
		
	#this signal is useful to process hitting and opponent hitting AFTER ripost reactive rwindow processed
	emit_signal("being_attacked",attackerHitboxArea, victimHurtboxArea,attackSpriteId)
	
	
	if attackerHitboxArea.hitstunType != GLOBALS.HitStunType.KNOCKBACK_ONLY: #no hitstun for this move, only knockback ( like doomfist upercut, but no damage)
		opponentPlayerController.notifyCommandHitOpponent(attackerHitboxArea.cmd,attackerHitboxArea.emitsAttackSFXSignal,attackSFXPosition)
		
		#only emmit the signal if we didnt block it
		#this way hitstun proration doesn't trigger from hitting block
		if not guardHandler.isBlocking():
			
			#only consider the hit in combo tracking if hitbox specifees (on hit grab is example that won't count)
			if not attackerHitboxArea.ignoreComboTracking:
				opponentPlayerController.emit_signal("attack_hit",attackerHitboxArea,victimHurtboxArea)
	
	#define flag that's true when hitting invincibility frames
	var ignoreHitstunFlag = victimHurtboxArea.subClass == victimHurtboxArea.SUBCLASS_INVINCIBILITY
	#***
	#only apply histun when not invincibility
	if not ignoreHitstunFlag:
		attemptApplyHitstun(attackSpriteId,attackerHitboxArea,victimHurtboxArea)
	
	
	if attackerHitboxArea.hitstunType == GLOBALS.HitStunType.KNOCKBACK_ONLY: #no hitstun for this move, only knockback ( like doomfist upercut, but no damage)
		return
	if not attackerHitboxArea.is_projectile:
	
		#don't calculate combo levels if ingoring combo trackin giwth this move
		if not attackerHitboxArea.ignoreComboTracking:
			calculateComboLevelWithSpriteId(opponentPlayerController, attackSpriteId, victimHurtboxArea.subClass,attackerHitboxArea.canFillDamageStar(),attackerHitboxArea.dmgProratrion,attackerHitboxArea,attackerHitboxArea.abilityFeedProrationMod)
	else:
		
		#BUG! should be using the projectile's hitbox's command, not the sprite id, since with  glove's ball,
		#if he ball with bat inside opponent, game won't have time to process th sprite  id change, and it
		#may think ball's still doing tool
		#gotta use calculate combo levle with command here
		#TODO
		#TO REPROCUDE ERROR, DO WITH GLOVE FOLLWOING, WHEN HE HAS BALL:
		#WALK UP TO OPPONENT, D_TOOL + D_MELEE + D_SPECIAL, WILL AT TIMES COUNT LAST HIT COUNT AS D_SPECIAL ATTACK AND OTHER TIMES AS D_TOOL
		#calculateComboLevelWithSpriteId(opponentPlayerController, attackerHitboxArea.projectileParentSpriteAnimation.id,victimHurtboxArea.subClass,attackerHitboxArea.canFillDamageStar(),attackerHitboxArea.dmgProratrion,attackerHitboxArea,attackerHitboxArea.abilityFeedProrationMod)
		
		#don't calculate combo levels if ingoring combo trackin giwth this move
		if not attackerHitboxArea.ignoreComboTracking:
			calculateComboLevelWithCommand(opponentPlayerController, attackerHitboxArea.cmd, victimHurtboxArea.subClass,attackerHitboxArea.canFillDamageStar(),attackerHitboxArea.dmgProratrion,attackerHitboxArea,attackerHitboxArea.abilityFeedProrationMod)
	
	
	var decreaseResourceCombo = null
	
	#here we only apply the current combo as the modifier for
	#decreasing resource (focus or dmg capaicty) when not invincibility
	#that is, invincibility eaats up the combo strength of decrese
	#this avoid having someone be in invulnerable hitun after a long
	#combo, and then every basic hit coundts immensly toward resource decrease
	if ignoreHitstunFlag:
		decreaseResourceCombo = 1
	else:
		decreaseResourceCombo = opponentPlayerController.playerState.combo
		
	#reduce some focus
	#comboHandler._was_hit_decrease_focus(decreaseResourceCombo)
	comboHandler._was_hit_decrease_dmg_cap(decreaseResourceCombo)
	
	
func _on_hitting_invincible_player(selfHitboxArea, otherHurtboxArea):
	pass
			
#	if selfHitboxArea == null:
#		print("null hitbox hitting opponent invincibility")
#		return
	
	#ighnore throws, can't throw a invincible person
#	if selfHitboxArea.isThrow:
#		return
	#play sound of on hit
	#playOnHitSound(otherHurtboxArea.commonSFXSoundId,selfHitboxArea.commonSFXSoundId)
	
#	if selfHitboxArea.hitstunType != GLOBALS.HitStunType.KNOCKBACK_ONLY:
#		playOnHitSound(otherHurtboxArea,selfHitboxArea)
	
	#make sure were not being hit during same attack
	#if not playerState.inHitStun:
	#	var onHitActionId = selfHitboxArea.on_hit_action_id
		#current frame plays a new action on hit?
	#	if onHitActionId != -1:
	#		playActionKeepOldCommand(onHitActionId)
#	attemptPlayOnHitActionId(selfHitboxArea.on_hit_action_id)
	
func _on_hitting_player(selfHitboxArea, otherHurtboxArea):
	#print(str(self.get_parent()) + " player landed a hit")
	#disable all remaining hitboxes, since we don't want to multi hit an oponent with same hitbox		
	#selfHitboxArea.get_parent().getSpriteAnimation().disableAllHitboxes()
	
	
		
		
	hittingPlayerInCornerPushAwayCheck(selfHitboxArea, otherHurtboxArea)
	#handleAttackTypeLightingSignaling(selfHitboxArea)
	
	#see if hitting non-blocking frames means failed anti bloc
	var hasFailedAntiBlock = actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.GROUND_GRAB_ACTION_ID)
	hasFailedAntiBlock = hasFailedAntiBlock or actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.AIR_GRAB_ACTION_ID)
		
	if hasFailedAntiBlock:
		#todo: REMOVE THIS LOGIC. ANTIBLOCK ISN'T A THING. DON'T WANT TO TRACK FAILED BLOCKS
		_on_failed_anti_block_hit_opponent()
			
	
	#if not otherHurtboxArea.selfOnly and  selfHitboxArea.hitstunType != GLOBALS.HitStunType.KNOCKBACK_ONLY:
	#	selfHitboxArea.spriteAnimation.disableAllHitboxes()
		
	#hitting our own special hurtbox (like glove bat hitting ball?)
	#if otherHurtboxArea.selfOnly:
		#make sure we can't keep hitting ball with later hitboxes of same bat animation
	#	selfHitboxArea.spriteAnimation.disableAllSelfOnlyHitboxes()
		
	_check_on_block_autoparry_hit(selfHitboxArea, otherHurtboxArea)
	
	#attackHitExpireCheck(selfHitboxArea)
	
			
func _check_on_block_autoparry_hit(selfHitboxArea, otherHurtboxArea):
	#have we hit opponent with block?
	#if (actionAnimeManager.currentActionAnimation == actionAnimeManager.AIR_BLOCK_AUTO_PARRY_ACTION_ID) or (actionAnimeManager.currentActionAnimation == actionAnimeManager.BLOCK_AUTO_PARRY_ACTION_ID):
	if (actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.AIR_AUTO_RIPOST_ON_HIT_ACTION_ID)) or (actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.AUTO_RIPOST_ON_HIT_ACTION_ID)):
		
		#reduce opponent's damage gauge abit and the capacity, he was hit by block
		#player can regain some of damage lost this way
		self.opponentPlayerController.playerState.reduceDamageGaugeCapacity(failedBlockDamageCapacityDecrease)
		self.opponentPlayerController.playerState.damageGauge -= failedBlockDamageDecrease
		
		#self.opponentPlayerController.playerState.reduceFocusCapacity(failedBlockFocusCapacityDecrease)
		#self.opponentPlayerController.playerState.focus -= failedBlockFocusDecrease
		#also increase block efficency
		#var be = playerState.getBlockEfficiency()
		#increase block efficiency
		#be = be + 1
		#playerState.setBlockEfficiency(be)
		
		#inrease for positive block efficiency
		#var increaseBarChunks = max(playerState.getBlockEfficiency(),0)
		#increaseBarChunks = int(increaseBarChunks)
		
		#increase bar by block efficiency
		#playerState.increaseAbilityBarInChunks(increaseBarChunks)
	
		
func _on_multi_tap_action_animation_partially_finished(currentSpriteAnimation,spriteFrame):
	
	#make sure to save flag if we hit opponent during the multi tap animation
	var wasHitingDurignMultiTap = false
	if currentSpriteAnimation != null:
		#wasHitingDurignMultiTap = currentSpriteAnimation.hittingWithJumpCancelableHitbox
		var ignoreInputWindow = true
		wasHitingDurignMultiTap = currentSpriteAnimation.isOnHitAutoCancelWindowActive(ignoreInputWindow)
	
	#go into end animtion of the multi tap
	playActionKeepOldCommand(spriteFrame.on_multi_tap_incomplete_action_id)
	
	
	actionAnimeManager.spriteFrameSetHittingAnyHitbox(true)
	
	#make sure the autocancel on hit flag is enabled for the multi hit end animation
	#to allow autocanceling even if you didn't press buttons to continue aniamtion
	if wasHitingDurignMultiTap:
		actionAnimeManager.spriteFrameSetIsHitting(true)


func hittingPlayerInCornerPushAwayCheck(selfHitboxArea, otherHurtboxArea):
	
	if selfHitboxArea == null:
		return 
	
	#ignore the case where hitting your own special hitboxes (glove's ball for example)	
	if selfHitboxArea.selfOnly == true:
		return
		
	#hitbox doesn't support push back from hitting opponent in corner?
	if not selfHitboxArea.pushesBackOnHitInCorner:
		return
			
		
	#check if player is blocking
	var blockStatus =opponentPlayerController.guardHandler.blockedAttackStatus(selfHitboxArea)
	
	#hitting an opponent that can't (and isn't) blocking?
	if not opponentPlayerController.guardHandler.canHoldBackToBlock() or blockStatus == GLOBALS.BlockResult.NO_BLOCK:
		
				
		var hittingOpponenetAgainstWall = false
		
		#in this case we consider the hitting ray casts, as some moves should only 
		#get pushed back if right  up against opponent and wall. So we want control
		#on when to stop pushing back
		
		#the important take waay is when hitting a non blocking opponent, the push back 
		#shouldn't disrupt the combo
		
		#hitting opponent against left wall?
	#	if hittingLeftWallDetector.is_colliding() and opponentPlayerController.leftCornerDetector.is_colliding():
	#		hittingOpponenetAgainstWall=true		
		#hitting opponent against right wall?
	#	elif hittingRightWallDetector.is_colliding() and opponentPlayerController.rightCornerDetector.is_colliding():
	#		hittingOpponenetAgainstWall=true
			
	#hitting opponent against left wall?
		if opponentPlayerController.leftCornerDetector.is_colliding():
			hittingOpponenetAgainstWall=true		
		#hitting opponent against right wall?
		elif opponentPlayerController.rightCornerDetector.is_colliding():
			hittingOpponenetAgainstWall=true
	
		#		
		#here, hitting an opponent in the corner pushes you aways
		#a thing this addresses is wheen you bodybox is wedgign opponent in corner, which
		#flikers landing and leaving ground signals, prvent DP sinc eyour in the air half the time
		if hittingOpponenetAgainstWall:

			playCornerHitPushBackMvmAniamtion(selfHitboxArea)				
		
	else:
		
		#were blocking in this case
		
		var hittingOpponenetAgainstWall = false
		
		
		#here as long as opponent is in corner we get pushed back,
		#since it will eventually force the game back to neutral
		#after a few blocks. It also gives control to make normally unsafe
		#moves on block be safe in corner thanks to pushback distance		
		#hitting blocking opponent against left wall?
		if opponentPlayerController.leftCornerDetector.is_colliding():
			hittingOpponenetAgainstWall=true				
		#hitting blocking opponent against right wall?
		elif opponentPlayerController.rightCornerDetector.is_colliding():
			hittingOpponenetAgainstWall=true
			

		if hittingOpponenetAgainstWall:
			
		#	var actionIdOnHit=selfHitboxArea.on_hit_action_id
			#does the hitbox change animations upon hitting?
		#	if actionIdOnHit >=0:
				#we want to wait until that animation plays, as it will override our animation
				#If there is more than one argument, yield returns an array containing the arguments:
				#wait until the aniamtion is played
		#		var playedActionId = yield(actionAnimeManager,"action_animation_played")
		#		while  (actionIdOnHit != playedActionId):
		#			playedActionId = yield(actionAnimeManager,"action_animation_played")
					
			#now, we will instead use the attack's block knockback to
			#make sure the distance created is based on the distance you would get from smakcing
			#a blocking opponent not against a wall 
			
			#however, perfect block doesn't push back, so corner contester has control
			#over push back (perfect blocking a negative on block should be just
			#as devestating in a corner). so to counter an abuse of typically
			#unsafe on block moves in corner pressure, can perfect block
			
			if blockStatus !=GLOBALS.BlockResult.PERFECT:
				
				var pushBackMvmAniamtion = selfHitboxArea.blockCornerHitPushAwayMovementAnimation
				
				#no mvm for hitting blocking opponent in corner?
				if pushBackMvmAniamtion == null:
					#use default corner push back 
					playCornerHitPushBackMvmAniamtion(selfHitboxArea)
					
				else:
					
					actionAnimeManager.movementAnimationManager.playMovementAnimation(pushBackMvmAniamtion, kinbody.spriteCurrentlyFacingRight)
					#want to make sure the uninterruptible movement starts, so process the movement immediatly
					#actionAnimeManager.movementAnimationManager.handleCurrentAnimation(0)
				
			else:
				playActionKeepOldCommand(actionAnimeManager.PERFECT_MOMENTUM_STOP_BLOCK_ACTION_ID)

func playCornerHitPushBackMvmAniamtion(selfHitboxArea):		

	#hitbox doesn't have a movement animation to push away on hit in corner? use default
	#so we use the default or attack's push back from hitting opponent in corner
	if selfHitboxArea.cornerHitPushAwayMovementAnimation == null:
		playActionKeepOldCommand(actionAnimeManager.CORNER_HITTING_PUSH_AWAY_ACTION_ID)
	else:
		actionAnimeManager.movementAnimationManager.playMovementAnimation(selfHitboxArea.cornerHitPushAwayMovementAnimation,kinbody.spriteCurrentlyFacingRight)
		#want to make sure the uninterruptible movement starts, so process the movement immediatly
		#actionAnimeManager.movementAnimationManager.handleCurrentAnimation(0)				
func _on_action_animation_finished(spriteAnimationId):
	
		
	if actionAnimeManager.isReversableSpriteAnimationId(spriteAnimationId):
		reversableAnimationFinished = true
	#guardBrokenRipostLock = false
	
	
	#finished riposting?
	#if spriteAnimationId == actionAnimeManager.RIPOST_SPRITE_ANIME_ID:
	if actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimationId,actionAnimeManager.GROUND_RIPOST_ACTION_ID) or actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimationId,actionAnimeManager.AIR_RIPOST_ACTION_ID):
		#go into hitfreeze for the hype.
		self.startHitFreezeNotification(self.ripostHitFreeze)

	
	
	#did we recover from the initial invincible guard break?
	if actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimationId,actionAnimeManager.INVULNERABLE_GUARD_BREAK_ACTION_ID):
		goIntoVulnerableStunState(BROKEN_GUARD_STUN_DURATION)
		return
	
	var groundHitstunSpriteAnimeId = actionAnimeManager.spriteAnimationIdLookup(actionAnimeManager.HITSTUN_ACTION_ID)
	var airHitstunSpriteAnimeId = actionAnimeManager.spriteAnimationIdLookup(actionAnimeManager.AIR_HITSTUN_ACTION_ID)
	var okiHitstunSpriteAnimeId = actionAnimeManager.spriteAnimationIdLookup(actionAnimeManager.LANDING_HITSTUN_ACTION_ID)
	#if heroName == "ken":
	#	print("on_action_animation_finished:" + actionAnimeManager.spriteAnimationManager.spriteAnimations[spriteAnimationId].name)
	
	#no longer buffer cancel an animation, since animation to cancel has finished
	#playerState.abilityBarCanceling = false
	#breaking free from hitstun?
	#if actionId == actionAnimeManager.HITSTUN_ACTION_ID:
	#NOTE that we don't check for invulnerable hitstun, since its infite until land and go into landing hitstun 
	if actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimationId,actionAnimeManager.HITSTUN_ACTION_ID) or actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimationId,actionAnimeManager.LANDING_HITSTUN_ACTION_ID) or actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimationId,actionAnimeManager.AIR_HITSTUN_ACTION_ID):
		breakFromHistun()
	#pass # the hitstun timer breaks us from hitstun
	
	#finished oki wakup?
	elif actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimationId,actionAnimeManager.LANDING_HITSTUN_ACTION_ID):
		
		breakFromHistun()
	

	elif actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimationId,actionAnimeManager.GROUND_GRAB_ACTION_ID) or actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimationId,actionAnimeManager.AIR_GRAB_ACTION_ID):
		
	#elif spriteAnimationId == actionAnimeManager.GROUND_GRAB_SPRITE_ANIME_ID or spriteAnimationId == actionAnimeManager.AIR_GRAB_SPRITE_ANIME_ID:

		_on_whiffed_grab()
	#elif spriteAnimationId ==actionAnimeManager.CROUCHING_BUDGET_BLOCK_HIT_LAG_SPRITE_ANIME_ID or spriteAnimationId ==actionAnimeManager.BUDGET_BLOCK_HIT_LAG_SPRITE_ANIME_ID:
	elif actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimationId,actionAnimeManager.CROUCHING_BUDGET_BLOCK_HIT_LAG_ACTION_ID) or actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimationId,actionAnimeManager.AIR_BUDGET_BLOCK_HIT_LAG_ACTION_ID):
		_on_exited_block_stun()
		
	#elif spriteAnimationId ==actionAnimeManager.AUTO_RIPOST_SPRITE_ANIME_ID:
	elif actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimationId,actionAnimeManager.AUTO_RIPOST_ACTION_ID) or actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimationId,actionAnimeManager.AIR_AUTO_RIPOST_ACTION_ID):
	
		_on_whiffed_auto_riposte()
		
		
	#if player buffered or pressed something, it'll be consummed, otherwise idle state
	#****
	#***** THIS IS WERE MULTI INPUT PER FRAME BUGS MAY OCCUR. CONSIDER REMOVING THIS FROM HERE 
	#AND LEETING THE HANDLE USER INPUT FUNCTION DEAL WITH IT. ALHTOUGH THINGS
	#MIGHT BREAK WITH MULL ANIMATION SPREITES, SINCE ATM SPRITE ANIMATION IS NULL
	#*****
	#handleUserInput()
	
			
func _on_exited_block_stun():
	
	playerState.wasInBlockStun=false
	kinbody.lowBlockstunSprite.visible = false
	kinbody.standingBlockstunSprite.visible = false
		
	blockStunAirRecoveryDuration=-1
	
	emit_signal("ability_bar_gain_finished")
	
	emit_signal("exited_block_stun")

func _on_entered_block_hitstun(attackerHitbox,blockRes, spriteCurrentlyFacingRight):
	#emit_signal("pre_ability_bar_gain")
	playerState.wasInBlockStun=true
	
	#make sure flag is enabled to allow ability canceling on block for 
	#those whoe chose disadvantage mage that limits ability canceling to on hit
	opponentPlayerController.actionAnimeManager.spriteFrameSetHittingAnyHitbox(true)
	#perfect air block
	if blockRes == GLOBALS.BlockResult.PERFECT:
		
		#reduce landing recovery by 75% (minimum 1 frame)
		blockStunAirRecoveryDuration=int(round(0.25 * attackerHitbox.airBlockStunLandingRecoveryDuration))
		#minimum 1 frame, max 5)
		blockStunAirRecoveryDuration = min(5, blockStunAirRecoveryDuration)
		blockStunAirRecoveryDuration = max(1, blockStunAirRecoveryDuration)
		
	else:
		
		blockStunAirRecoveryDuration=attackerHitbox.airBlockStunLandingRecoveryDuration
	
	#here we toggle visibiblity of the shield, and make sure
	#the other shieled is invisible, as if you get hit in a blockstring
	#if you swap from low to high blocking, we make sure appropirate shiled
	#is displayed and not both
	if guardHandler.isInLowBlockStunAnimation():
		kinbody.lowBlockstunSprite.visible = true
		kinbody.standingBlockstunSprite.visible = false
	else:
		kinbody.lowBlockstunSprite.visible = false
		kinbody.standingBlockstunSprite.visible = true

	#we missed our block, give the opponent a combo level increase
	# this will give oppurtunity for opponent to gain huge damage next combo
	#self.opponentPlayerController.playerState.comboLevel += 1
		
	#var be = playerState.getBlockEfficiency()

	
	#number of chunks to lose is >= 0 (recall BE > 0 means no bar loss)
	#var numChunksLost = min(be,0) *(-1)
	
	
	#now consume bar from player that missed block
	#playerState.forceConsumeAbilityBarInChunks(numChunksLost)
	
	#decrease block efficiency
	#be = be - 1
	#playerState.setBlockEfficiency(be)

#func _on_opponent_entered_block_stun(attackerHitbox,blockResult,spriteFacingRight):
	#opponentPlayerController.emit_signal("pre_ability_bar_gain")

#magic  seires combo level changed
func _on_combo_level_changed(lvl):
	
	
	comboLevelupHandler("combo_level_up",lvl)		

	
#reverse beat combo level change (only for heros that uspport such combos)
func _on_focus_combo_level_changed(lvl):
	
	comboLevelupHandler("reverse_beat_combo_level_up",lvl)		

	
func comboLevelupHandler(signalStr,lvl):
	#since combo level only increases or is set to 0, 
	#if its not 0, it increased
	if lvl != 0:
		emit_signal(signalStr,lvl)
		if enableParticles:
			#show star particles
			self.comboLevelParticles.set_emitting(true)

	
		#to avoid enabling M + special + toll + special + m to be a magic series + reverse beat
		#need 3 hits per combo level, and combo levels can't share a hit
		playerState.subComboLevel = 0
		playerState.focusSubComboLevel = 0
		
		#start trackingt the damage guage (another combo level in same combo overrides the tracking)
		#either way, will only start gaingin damage once combo is finished, so should be fine
		#emit_signal("start_damage_gauge_generation_tracking",playerState.damageGauge,playerState.damageGaugeCapacity,playerState.damageGaugeNextHit)
		#emit_signal("pre_ability_bar_gain")
		#playerState.increaseAbilityBarInChunks(numAbChunksGainOnComboLvl)
		#emit_signal("ability_bar_gain_finished")
		
		playerState.magicSeriesBarIncreaseCount = playerState.magicSeriesBarIncreaseCount +1
		
		#in air?
		if not my_is_on_floor():
			#count the magic series bar increase coutns for air magic sereis
			playerState.airMagicSeriesBarIncreaseCount = playerState.airMagicSeriesBarIncreaseCount +1
			
		#play the level up sound
		_on_request_play_special_sound(COMBO_LEVEL_UP_SOUND_ID,COMMON_SOUND_SFX)
		

#func _block_cooldown_finished():
#	playerState.isBlockOnCooldown = false
	
#func _anti_block_cooldown_finished():
	#playerState.isGrabOnCooldown = false
	
func _on_hp_changed(newHP):
	if newHP <= 0:
		disableUserInput()
	


func _on_failed_tech():
	pass
	#print("failed tech")	
	#playerState.forceConsumeAbilityBarInChunks(failedTechAbilityBarCost)
	#emit_signal("failed_tech")
	pass
func _on_successful_tech(framesRemaining,type):
	
	
	#print("succesfful tech with " + str(framesRemaining) + "frames remaining and is of type " + str(type))
	var techAcitonId = -1
	
	#we use this flag to indicate if we gotta disable the body box collision temporarily
	#to renable cross-up via rolling
	#var disableBodyBoxCollisionsFlag = false
#	match(type):
#		GLOBALS.TYPE_GROUND_TECH_IN_PLACE:
#			techAcitonId=actionAnimeManager.GROUND_IN_PLACE_TECH_ACTION_ID
#		GLOBALS.TYPE_GROUND_TECH_ROLL_BACKWARD:
#			techAcitonId=actionAnimeManager.ROLLING_BACKWARD_TECH_ACTION_ID
			#disableBodyBoxCollisionsFlag=true
#		GLOBALS.TYPE_GROUND_TECH_ROLL_FORWARD:
#			techAcitonId=actionAnimeManager.ROLLING_FORWARD_TECH_ACTION_ID
			#disableBodyBoxCollisionsFlag=true
#		GLOBALS.TYPE_CEILING_TECH_IN_PLACE:
#			techAcitonId=actionAnimeManager.CEILING_TECH_ACTION_ID
#		GLOBALS.TYPE_WALL_TECH_IN_PLACE:
#			techAcitonId=actionAnimeManager.WALL_TECH_ACTION_ID

	if techHandler.techTypeActionMap.has(type):
		techAcitonId = techHandler.techTypeActionMap[type]
	
	if (techAcitonId != -1):
		
		
		#do we get jump/dash back on tech in air?
		if recoverAirDashAndJumpOnAirTech and not my_is_on_floor():
			playerState.hasAirDashe = true
			#gain a jump. Can't gain more than max # jumps, and can't have negative # jumps 
			playerState.currentNumJumps = clamp(playerState.currentNumJumps+1,0,playerState.numJumps)
			
					
			
		#playerState.consumeAbilityBar(techAbilityBarCost)
		playerState.forceConsumeAbilityBarInChunks(techAbilityBarCost)
		breakFromHistun()
		playActionKeepOldCommand(techAcitonId)
		emit_signal("tech",framesRemaining,type)
		#startHitFreezeNotification(TECH_HIT_FREEZE_DURATION)  tech no longer hitfreezes
	else:
		print("failed to process tech type, no tech animation played")

func _on_tech_window_lock_expired():
	#print("tech window lock expired")
	pass

#called when ability bar cancel occurs
func _on_ability_cancel(barCost,spriteFrame, autoAbilityCancelFlag):
	
	if autoAbilityCancelFlag:
	#play sound of auto ability bar canceling
		_on_request_play_special_sound(AUTO_ABILITY_CANCEL_SOUND_ID,COMMON_SOUND_SFX)
	else:
		
		#lesser ability cancel (liek movement)?
		if barCost<=BASIC_ABILITY_CANCEL_COST:		
			#play baisc sound of ability bar canceling a low cost move like mvm
			_on_request_play_special_sound(BASIC_ABILITY_CANCEL_SOUND_ID,COMMON_SOUND_SFX)
		else:
			#play sound of ability bar canceling
			_on_request_play_special_sound(ABILITY_SOUND_ID,COMMON_SOUND_SFX)
		
	
	#we reset the sprite animations that can only hit once before changing properties for
	#remainder of combo, as we use resources to reset the combo. only do so for manual ability
	#cancels
	if not autoAbilityCancelFlag:
		
		#only reset stale moves if possible
		if not preventAbilityCancelStaleMoveReset:
			var checkAbilityCancelRefreshBlackList=true#true to refresh only valid moves (some won't upon ability cancel)
			actionAnimeManager.refreshAllOneTimeHitAnimations(checkAbilityCancelRefreshBlackList)
	
		#get grab back from ability canceling?
		if recoverGrabOnAbilityCancel:
			#playerState.isGrabOnCooldown=false
			playerState.grabCharges= playerState.grabCharges +1 
			
		attemptRecoverAirDashFromAbilityCancel()
	else:
		
		#get grab back from auto ability canceling?
		if recoverGrabOnAutoAbilityCancel:
			#playerState.isGrabOnCooldown=false
			playerState.grabCharges= playerState.grabCharges +1 
			
			
			
		#opponent in hitstun when we played a new animation?
		if opponentPlayerController != null and opponentPlayerController.playerState.inHitStun:
			
			# momentum stop from auto ability cancel?
			var stopOppKnockBackFlag = opponentPlayerController.actionAnimeManager.getMvmStopOnOpponentAutoAbilityCancel()
			
			if stopOppKnockBackFlag:				
				#stop the knocback
				#opponentPlayerController.playActionKeepOldCommand(opponentPlayerController.actionAnimeManager.MOMENTUM_STOP_ACTION_ID)
				opponentPlayerController.playActionKeepOldCommand(opponentPlayerController.actionAnimeManager.GRAB_CANCEL_MOMENTUM_STOP_ACTION_ID)
				
	
	
			
	#air manual ability cancel?
	if not my_is_on_floor() and not autoAbilityCancelFlag:
		
		#do we get jumsp back on ability cancel?
		if numJumpsGainedFromAbCancel != 0:
		
			#we can go over the maximum by amount obtained, so if  were already maxed jumps in air, get an extra
			#gain (or lose) a jump. Can't gain more than max # jumps, and can't have negative # jumps 
			#note that leaving ground eats ur jump
			playerState.currentNumJumps = clamp(playerState.currentNumJumps+numJumpsGainedFromAbCancel,0,playerState.numJumps+numJumpsGainedFromAbCancel)
			playerState.numAcroABCancelExtraJumps=playerState.numAcroABCancelExtraJumps+1
	
	
	comboHandler._on_ability_cancel(playerState.comboLevel,playerState.focusComboLevel,playerState.combo,autoAbilityCancelFlag)
	opponentPlayerController.comboHandler._on_opponent_ability_cancel(playerState.comboLevel,playerState.focusComboLevel,playerState.combo,autoAbilityCancelFlag)

	kinbody.abilityCancelLight.visible = true
	abilityCancelLightTimer.start(abilityCancelLightDuratinInFrames)
	
	kinbody.handleAbilityCancelParticles(barCost,autoAbilityCancelFlag)
	

func _on_sprite_animation_played(spriteAnimation):
	
	
	#guardBrokenRipostLock = false
	#notifies any subscriber (the ability bar HUD) to display underlines or hide
	#to represent bar cost
	#logic here for displaying amount of bar to cancel
	#var spriteAnimation = actionAnimeManager.getCurrentSpriteAnimation()
	if spriteAnimation == null:
		emit_signal("ability_bar_cancel_cost_hide")
		return
							
	if actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimation.id,actionAnimeManager.AUTO_RIPOST_ACTION_ID):
		kinbody.displayLocalTemporarySprites(kinbody.autoRipostAwaitingSpriteSFXs)		
		
	
	#if spriteAnimation.id ==actionAnimeManager.LANDING_HITSTUN_SPRITE_ANIME_ID:
	if actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimation.id,actionAnimeManager.LANDING_HITSTUN_ACTION_ID):
		emit_signal("entered_oki")
		#stop shaking on land
		kinbody.sprite.reset_shake_trauma()
		
	
	#prevent movement input caseu of dash ability cancel? at any point, if do an animation, will 
	#no longer be locked out of mvm
	if dashABCancelPreventingMvmInput:	
		var idlePlayed =  actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimation.id,actionAnimeManager.SLIDING_GROUND_IDLE_ACTION_ID)
		idlePlayed = idlePlayed or actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimation.id,actionAnimeManager.AIR_IDLE_ACTION_ID)
		#first we go into idle before sliding, so only stop the lock if anything but idle is played
		if not idlePlayed:
		
			dashABCancelPreventingMvmInput=false
			inputLockHandler.reset()
		
	#after playing an animation we can't slide (ability cancel stops aniamtion and 
	#lets you slide if you don't buffer in an animation other than gorund idle)
	enableSlidingGroundIdle=false		
			
	#did we just break out of a reversable animation (oki, for example)
	if reversableAnimationFinished:
		
		if actionAnimeManager.isReversalSpriteAnimationId(spriteAnimation.id):
			emit_signal("reversal",spriteAnimation)
			
	
	reversableAnimationFinished = false
	
	
	
	#***I DO NOT KNOW IF BELOW CODE IS USED. LOOK ABOVE FOR stopOpponentMvmFlag LOGIC INSTEAD
	#check whether the knockback animation of histun will
	#stop the momentum upon playign a new animation
	if opponentPlayerController != null and opponentPlayerController.playerState.inHitStun:
		
		var _sa = opponentPlayerController.actionAnimeManager.spriteAnimationManager.currentAnimation
		
		if _sa != null:
			#might have frame perfect land/tech hitstun situation, so make sure the property iexsits
			if "stopMomentumOnPushOpponent" in _sa:
				
				if _sa.stopMomentumOnOpponentAnimationPlay:
					opponentPlayerController.playActionKeepOldCommand(opponentPlayerController.actionAnimeManager.MOMENTUM_STOP_ACTION_ID)
					



	if not spriteAnimation.barCancelableble:
		emit_signal("ability_bar_cancel_cost_hide")
		return
	
	#var abilityBarCost = spriteAnimation.abilityCancelCostTypeToNumberOfChunks() +playerState.profAbilityBarCostMod
	var abilityBarCost = computeAbilityBarCancelCost(spriteAnimation)
	#have enough bar to cancel current animation?
	#if playerState.hasEnoughAbilityBar(spriteAnimation.abilityBarDrain):
	if playerState.hasEnoughAbilityBar(abilityBarCost):
		
		emit_signal("ability_bar_cancel_cost_display",abilityBarCost,Color(0,1,0,1))#display green bar
	else:
		emit_signal("ability_bar_cancel_cost_display",abilityBarCost,Color(1,0,0,1))#display red bar

func _on_done_loading_game():
	pass

	#apply logic to removed proration	
#when match is restarted/started, this is called
func restart_hook():
	set_physics_process(true)
	wasInInvincibleOki=false
	pauseOnHitFreezeEndEnabled=false
	reversableAnimationFinished=false
	highDamageParticles.emitting=false
	highDamageParticles.visible=false
	kinbody.dmgStarGlow.visible = false
	kinbody.emptyStarGlow.visible = false
	kinbody.emptyStarGlow.emitting = false
	kinbody.autoRipostAura.visible = true
	kinbody.lowBlockstunSprite.visible = false
	kinbody.standingBlockstunSprite.visible = false
	
	#make sure to make the sprite apear when histun ends in case hitbox made it disappear
	kinbody.sprite.visible = true

	
	#remove preloaded shader/material resources
	for c in cachedResourcesNode.get_children():
		cachedResourcesNode.remove_child(c)
	
	dashABCancelPreventingMvmInput = false
	halfHpValue = playerState.hp/2.0
	
	#stop guard regen particles on game restart
	kinbody.guardRegenBuffParticles.visible=false
	kinbody.guardRegenBuffParticles.emitting=false
	
	gameEndingStun = false
	guardBrokeThisFrame = false
	
	lastHitBySpriteAnimeId = null
	
	enableSlidingGroundIdle=false
	occupyingLeftCorner = false
	occupyingRightCorner = false

	handleUserInputCallLock = false
	kinbody.autoRipostAura.self_modulate.a= 0
	kinbody.spriteSFXNode.deactivateAll()
	negativePenaltyTracker.reset()
	
	if not opponentPlayerController.is_connected("damage_taken",playerState,"_on_apply_damage_to_opponent"):
		opponentPlayerController.connect("damage_taken",playerState,"_on_apply_damage_to_opponent")
	if not opponentPlayerController.get_node("PlayerState").is_connected("changed_in_hitstun",self,"_on_opponent_hitstun_changed"):
		opponentPlayerController.get_node("PlayerState").connect("changed_in_hitstun",self,"_on_opponent_hitstun_changed")
	if not opponentPlayerController.get_node("guardHandler").is_connected("guard_damage_taken",playerState,"on_guard_damage_dealt"):
		opponentPlayerController.get_node("guardHandler").connect("guard_damage_taken",playerState,"on_guard_damage_dealt")
	if not opponentPlayerController.is_connected("being_attacked",self,"on_hitting_opponent_post_ripost"):
		opponentPlayerController.connect("being_attacked",self,"on_hitting_opponent_post_ripost")
	
	if not opponentPlayerController.is_connected("entered_block_hitstun",comboHandler,"_on_opponent_entered_block_stun"):
		opponentPlayerController.connect("entered_block_hitstun",comboHandler,"_on_opponent_entered_block_stun")
	if not opponentPlayerController.is_connected("entered_invincible_oki",self,"_on_opponent_entered_invincible_oki"):
		opponentPlayerController.connect("entered_invincible_oki",self,"_on_opponent_entered_invincible_oki")
	
	
	
	
		
	
	#guardBrokenRipostLock = false
	#when match starts, reset gravity after a split second to make sure no signals are still eexecuting to
	#over ride gravity reset
	#yield(get_tree().create_timer(0.1),"timeout")
	
	
	#do we need this?
	restartDelayTimer.startInSeconds(0.1)
	yield(restartDelayTimer,"timeout")
	
	
	#actionAnimeManager.movementAnimationManager.resetGravity()
	#reset gravity
			#replay gravity if not play
	var gravType = complexMvmInstance.GravityEffect.REPLAY
	actionAnimeManager.movementAnimationManager.applyComplexMovementGravity(gravType)
	
	actionAnimeManager.movementAnimationManager.stopUninterruptibleMovement()
	
	#make sure the next hit amounts in circular process bars are rendered by
	#updating the plyerstate next hit maount attributes
	comboHandler.updateDamageGaugeNextHit_nextCombo()
	#comboHandler.updateFocusNextHit_nextCombo()

	
func getReadyForStylePoints(timeToGetReadyWait):
	#disable any input
	pass
	
func computeAbilityBarCancelCost(spriteAnimation):
	var ignoreProfModCost = false
	return _computeAbilityBarCancelCost(spriteAnimation,ignoreProfModCost)
	
func _computeAbilityBarCancelCost(spriteAnimation,ignoreProfModCost,zeroCostForUncancelabledMove = true):
	
	if spriteAnimation == null:
		return 0
		
	if not spriteAnimation.barCancelableble and zeroCostForUncancelabledMove:
		return 0
	if spriteAnimation.abilityCancelCostType == spriteAnimation.AbilityCancelCostType.NA:
		return 0
		
	var numChunks = spriteAnimation.abilityCancelCostTypeToNumberOfChunks() # the cancel cost of animation
	numChunks =  numChunks + playerState.baseAbilityCancelCost #the base amount canceling costs
	
	#including the proficiency cost modifier in calculation?
	if not ignoreProfModCost:
		numChunks =  numChunks + playerState.profAbilityBarCostMod #apply the proficiency modifier for ability canceling
				
		#do we apply the ability canceling tax fro being airborne or landing lag?
		#TODO: WILL need to add some logic in aciton anime manager ot check if a sprite anime id is associated to aciton id,  since many have 2 different landing lag animations
		#if not my_is_on_floor() or spriteAnimation.id == actionAnimeManager.LANDING_LAG_SPRITE_ANIME_ID:
		if not my_is_on_floor() or actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimation.id,actionAnimeManager.LANDING_LAG_ACTION_ID):		
			numChunks = numChunks + airAbilityCancelCostInChunksTax#apply additional cost from being  in air
		
	
	
	return max(1,numChunks) #animation cancel is minimum 1 bar

	
func _computeAutoAbilityBarCancelCost(spriteAnimation):
	
	if spriteAnimation == null:
		return 0
		
	if spriteAnimation.autoAbilityCancelCostType == spriteAnimation.AbilityCancelCostType.NA:
		return 0
		
	var numChunks = spriteAnimation.autoAbilityCancelCostTypeToNumberOfChunks() # the cancel cost of animation
	numChunks =  numChunks + autoAbilityCancelBaseCost #the base amount canceling costs
	
	return max(1,numChunks) #animation cancel is minimum 1 bar


func playBlockHistunAnimation(blockHitLagDuration, movementAnimation,attackFacingRight):
	
	if blockHitLagDuration == 0:
		return
		
	#do we get jump back in air on block?
	if recoverJumpOnAirBlock:
		#in the air?
		if not my_is_on_floor():
			#gain (or lose) a jump. Can't gain more than max # jumps, and can't have negative # jumps 
			playerState.currentNumJumps = clamp(playerState.currentNumJumps+1,0,playerState.numJumps)
	#do we get air dash back in air on block?
	if recoverAirDashOnAirBlock	:
		#in the air?
		if not my_is_on_floor():
			playerState.hasAirDashe = true
	
	if loseJumpAndAirDashOnAirBlock:
		if not my_is_on_floor():
			playerState.hasAirDashe = false
			playerState.currentNumJumps=0
			playerState.numAcroABCancelExtraJumps=0
			
			
	#low block?
#	if guardHandler.isInLowBlockAnimation():
	if guardHandler.isBlockingLow():
		#the duration of hit stun varies by attack
		adjustSpriteAnimationSpeed(blockHitLagDuration,actionAnimeManager.CROUCHING_BUDGET_BLOCK_HIT_LAG_ACTION_ID)
		#playActionKeepOldCommand(actionAnimeManager.CROUCHING_BUDGET_BLOCK_HIT_LAG_ACTION_ID)
		actionAnimeManager.playBlockHitstun(actionAnimeManager.CROUCHING_BUDGET_BLOCK_HIT_LAG_ACTION_ID,movementAnimation,attackFacingRight)
		
	elif my_is_on_floor(): #high block on the ground
		
		#the duration of hit stun varies by attack
		adjustSpriteAnimationSpeed(blockHitLagDuration,actionAnimeManager.BUDGET_BLOCK_HIT_LAG_ACTION_ID)
		#playActionKeepOldCommand(actionAnimeManager.BUDGET_BLOCK_HIT_LAG_ACTION_ID) #restart the budget block hit lag animation
		actionAnimeManager.playBlockHitstun(actionAnimeManager.BUDGET_BLOCK_HIT_LAG_ACTION_ID,movementAnimation,attackFacingRight)
	
	else:#high block in air
			#the duration of hit stun varies by attack
		adjustSpriteAnimationSpeed(blockHitLagDuration,actionAnimeManager.AIR_BUDGET_BLOCK_HIT_LAG_ACTION_ID)
		#playActionKeepOldCommand(actionAnimeManager.AIR_BUDGET_BLOCK_HIT_LAG_ACTION_ID) #restart the budget block hit lag animation
		actionAnimeManager.playBlockHitstun(actionAnimeManager.AIR_BUDGET_BLOCK_HIT_LAG_ACTION_ID,movementAnimation,attackFacingRight)
	#emit_signal("entered")
		
				
#not that this is called before damage is applied
func _on_budget_block(blockType):
	
	
	#only apply block sound when not perfect (perfect sound sfx played by perfect block handler function)
	if blockType ==  GLOBALS.BlockResult.CORRECT:
#	if blockResult == GLOBALS.BlockResult.CORRECT or blockResult == GLOBALS.BlockResult.PERFECT:
		_on_request_play_special_sound(CORRECT_BLOCK_SOUND_ID,COMMON_SOUND_SFX)
	elif  blockType ==  GLOBALS.BlockResult.INCORRECT:
		_on_request_play_special_sound(INCORRECT_BLOCK_SOUND_ID,COMMON_SOUND_SFX)
		_on_request_play_special_sound(HERO_INCORRECT_BLOCK_SOUND_ID,HERO_SOUND_SFX)		
		#display a bad block over-head symbole
		kinbody.displayLocalTemporarySprites(kinbody.badBlockSpriteSFXs)
		
	elif blockType ==  GLOBALS.BlockResult.PERFECT:
		kinbody.displayLocalTemporarySprites(kinbody.perfectBlockSpriteSFXs)		
		#display the perfect block visuals
		_on_request_play_special_sound(PERFECT_BLOCK_SOUND_ID,COMMON_SOUND_SFX)
		
	#emit_signal("budget_blocked",blockHitLagDuration,guardHPDamage)
	
	
func getDistanceFromOpponent():
	var center = kinbody.getCenter()
	var oppCenter = opponentPlayerController.kinbody.getCenter()
	
	return oppCenter.distance_to(center)
	
#pause the game on controller disconnected
func _on_controller_disconnected(deviceId):
	#only pause game on controller DC in proper moments (node when game ending, starting, 
	#or at style points init phase)
	if canPauseFlag:
		#don't let the cpu control the pause menu in result screen
		if opponentPlayerController.heroName != GLOBALS.CPU_NAME:			
			emit_signal("pause",inputManager.inputDeviceId,opponentPlayerController.inputManager.inputDeviceId,self,GLOBALS.PauseMode.CONTROLLER_DC)
		else:
			emit_signal("pause",inputManager.inputDeviceId,null,self,GLOBALS.PauseMode.CONTROLLER_DC)
		
		
#retreives the list of commands that are autocancelable
#given the current sprite frame. An empty list is given if
#noothign is autocancelable
#will also consider autocancels on hit, when hitting
func getAutoCancelableCommandList():
	
	
	
	#only get all the possible autocancels (on-hit and normal) when hitting oppoentn
	var autoCancelActionIds  = null
	
	#const COMBO_TYPE_ALL = 0
	#const COMBO_TYPE_NORMAL = 1
	#const COMBO_TYPE_ON_HIT_ONLY = 2
	
	#normal get combo list is check for hitting, if hitting return all, 
	#other wise just get basic autocancelable action ids
	var ignoreOnHitWindow = true
	if actionAnimeManager.isSpriteFrameHittingOpponent(ignoreOnHitWindow):
		autoCancelActionIds = actionAnimeManager.getAllAutoCancelableActionIds()
	else:
		autoCancelActionIds = actionAnimeManager.getAutoCancelableActionIds()

	return _getAutoCancelableCommandList(autoCancelActionIds)
	
func _getAutoCancelableCommandList(autoCancelActionIds):	

	var res = []
	var duplicateLookup = {}
	#go through all the actions that are autocancelable, and get the  commands that are input to 
	#create/play those actions
	for actionId in autoCancelActionIds:
		var cmd = actionAnimeManager.getCommand(actionId)
		
		#don't include null commands or duplicates in results
		if cmd != null and not duplicateLookup.has(cmd):
			res.append(cmd)
			
			#sotre in lookup map to avoid duplicates
			duplicateLookup[cmd] = null
			
	return res
	
	
func isActionIdAirialAttack(actionId):
	return actionId == actionAnimeManager.AIR_NEUTRAL_MELEE_ACTION_ID or actionId == actionAnimeManager.AIR_NEUTRAL_SPECIAL_ACTION_ID  or actionId == actionAnimeManager.AIR_NEUTRAL_TOOL_ACTION_ID
	

#resolve what action id to play on hit
#-1 resturned if not such legal aciton id is found
func resolveActionIdPlayedOnHit(actionId,on_link_hit_action_id,cmd,on_hit_starting_sprite_frame_ix,opponentWasInHitstun,preventOnHitActionWhenOnGround,preventOnHitActionWhenInAir,preventOnHitFlagEnabled):
	
	#make sure were not being hit during same attack
	if not playerState.inHitStun:
		
		#some animations hitboxes only allow on hit to be done in air or on ground
		#(useful to avoid air on hits that trigger hitbox after landing and override landing
		#animation with an arial)
		if preventOnHitActionWhenOnGround and my_is_on_floor():
			return -1
		if preventOnHitActionWhenInAir and not my_is_on_floor():
			return	-1
			
			
		var actionIdPlayed=null
		#does this hitbox have a different on hit action when we link?
		if opponentWasInHitstun and on_link_hit_action_id!= -1:			
			return on_link_hit_action_id
		
		
		#current frame plays a new action on hit?
		elif actionId != -1:
			return actionId
		
			
		
		
	return -1
func attemptPlayOnHitActionId(actionId,on_link_hit_action_id,cmd,on_hit_starting_sprite_frame_ix,opponentWasInHitstun,preventOnHitActionWhenOnGround,preventOnHitActionWhenInAir,preventOnHitFlagEnabled):
	
	var actionIdToPlay=resolveActionIdPlayedOnHit(actionId,on_link_hit_action_id,cmd,on_hit_starting_sprite_frame_ix,opponentWasInHitstun,preventOnHitActionWhenOnGround,preventOnHitActionWhenInAir,preventOnHitFlagEnabled)
	if actionIdToPlay!= -1:
		actionAnimeManager._playAction(actionIdToPlay,kinbody.spriteCurrentlyFacingRight,cmd,on_hit_starting_sprite_frame_ix,preventOnHitFlagEnabled) #use spriteCurrentlyFacingRight, since one hit should look like part of same animation, so don't turn around on crossup			
	
	
		
			
func adjustSpriteAnimationSpeed(totalDurationInFrames,actionId):
	
	if actionId == -1:
		return
		
	var animation = actionAnimeManager.spriteAnimationLookup(actionId)
	
	#so: target-speed = animation-speed * actual-num-frames / totalDurationInFrames
	
	#below show be independent of global speed mod, since when running animation, globa speed, mod will
	#come into effect
	
	var targetSpeed = (animation.getDefaultSpeed() * animation.getNumberOfFrames()) /totalDurationInFrames
	animation.speed = targetSpeed 
	
func isCrouching():
	#courching budget block hitlag is a special case of crouching. So we special case will be considered in case by case basis
	return actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.CROUCH_ACTION_ID) or actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_CROUCHING_HOLD_BACK_BLOCK_ACTION_ID)
	


#called when block guard broke
func _on_guard_broken(highBlockFlag,amountGuardRegened):
	
	
	_on_request_play_special_sound(GUARD_BROKEN_SOUND_ID,COMMON_SOUND_SFX)

	var breakParticles = kinbody.shieldBreakParticleBuffer.get_next_particle()
		
	kinbody.shieldBreakParticleBuffer.trigger()
	
	#hop up and be invulnerable for a moment
	playActionKeepOldCommand(actionAnimeManager.INVULNERABLE_GUARD_BREAK_ACTION_ID)
	
	#goIntoVulnerableStunState(BROKEN_GUARD_STUN_DURATION)

	
	
	#break current hit's hitfreeze
	stopHitFreezeNotification()
	#hyype up the guard break by waiting 25 frames
	startHitFreezeNotification(GUARD_BREAK_HIT_FREEZE_DURATION)
	#below won't be necessary when all heros have a stun animation which locks ripost
	#guardBrokenRipostLock = true
	#applyHitstun(self,ripostActionId,relativeDamage,ripostHitstunMovementAnimation,autoCancelableFlag,ripostHitstunDuration,GLOBALS.LandingType.DONT_FALL_PRONE,durationBeforeFallProne,GLOBALS.HitStunType.BASIC,stopHitMomentumOnLand,isThrow)
	
	#do we gain bar from guard break?
	if gainBarOnGuardBreak:
		
		#can't gain bar from the half way mark if locked ot of bar
		if not playerState.abilityBarGainLocked:
			opponentPlayerController.emit_signal("pre_ability_bar_gain")
			
			
			var chunksToGain = computeBarFeedFromABrokenGuard()
			opponentPlayerController.playerState.increaseAbilityBarInChunks(chunksToGain)
			opponentPlayerController.emit_signal("ability_bar_gain_finished")
			
	
	#lose all damage buffs
	#playerState.clearFillComboSubLevel()
	#playerState.clearNumFilledDmgStars()
	#playerState.clearNumEmptyDmgStars()
	applyDmgStarRemoval()

	guardBrokeThisFrame=true
	
	
func computeBarFeedFromABrokenGuard():
	#apply the modifier to change how much bar is gained 
	var chunksToGain = opponentPlayerController.additionalBarGainFromBreakingGuard #amount of addition meter opponent will gain from breaking our gaurd
	chunksToGain= chunksToGain + additionalBarFeedFromGettingGuardBroken #amount of additional meter we feed from getting our guard broekn
	chunksToGain = chunksToGain+ numBarChunksGainedFromGuardBreak #the default amount of meter to gain from breaking guard
		
	return chunksToGain
#ripost or guardbreak will remove any empty star and convert filled stars to empty
func applyDmgStarRemoval():
	pass
	var oldNumFilledStars = playerState.numFilledDmgStars
	
	playerState.clearFillComboSubLevel()
	playerState.clearNumFilledDmgStars()
	playerState.clearNumEmptyDmgStars()
	
	#playerState.numEmptyDmgStars =oldNumFilledStars
	#var i = playerState.numEmptyDmgStars
	#while(i >=0):
	#	i= i -1
	#	playerState.decreaseNumEmptyDmgStars()
		
	#var i = oldNumFilledStars
	#while(i >=0):
	#	i= i -1
		#playerState.decreaseNumFilledDmgStars()
		#playerState.increaseNumEmptyDmgStars()
	#playerState.clearNumEmptyDmgStars()
	#playerState.clearNumFilledDmgStars()
	

	playerState.numEmptyDmgStars =oldNumFilledStars
	#playerState.increaseNumFilledDmgStars()
	#playerState.decreaseNumFilledDmgStars()

func handleHoldingDownInput(cmd):
	pass
	#var inputedDown = false
	
	##command required pressing/holding down?
	#if inputManager.isHoldDownCommand(cmd):
		#inputedDown = true
	#else:
	#	inputedDown = false
		
	#notify guard handler for low blocking
	#if inputedDown:
	#	guardHandler._on_holding_down()
	#else:
	#	guardHandler._on_not_holding_down()

func handleHoldingForwardInput(cmd):
	
	pass	
	#var inputedForward = false	
	#logic for determining if we are holding left or right (important for budget block)

	#if inputManager.isHoldForwardCommand(cmd):
	#	inputedForward = true
	#else:
	#	inputedForward = false
	#if inputedForward and holdingForward:
	#	negativePenaltyTracker._on_holding_forward()
	#	pass
	#elif inputedForward and not holdingForward:
	#	holdingForward = true
		
		
	#	negativePenaltyTracker._on_pressed_forward()
	
	#elif not inputedForward and not holdingForward:
		
	#	negativePenaltyTracker._on_not_holding_forward()
	#	pass
	#else: #we aren't holding back and we were, so we released back
		
		#negativePenaltyTracker._on_released_forward()
		#holdingForward = false
	


func handleHoldingBackInput(cmd):
	pass
	#var inputedBack = false	
	#logic for determining if we are holding left or right (important for budget block)

	#if inputManager.isHoldBackCommand(cmd):
	#	inputedBack = true
	#else:
	#	inputedBack = false
		
	#if inputedBack and holdingBackward:
		#already holding back, do nothing
		#guardHandler._on_holding_back()
	#	negativePenaltyTracker._on_holding_back()
	#	pass
	#elif inputedBack and not holdingBackward:
	#	holdingBackward = true
		
		
		#guardHandler._on_pressed_back()
	#	negativePenaltyTracker._on_pressed_back()
	#not holding back and wasn't last frame?
	#elif not inputedBack and not holdingBackward:
		#do nothing, not holding back
		#guardHandler._on_not_holding_back()
	#	negativePenaltyTracker._on_not_holding_back()
	#	pass
	#else: #we aren't holding back and we were, so we released back
		#guardHandler._on_released_back()
		#negativePenaltyTracker._on_released_back()
		#holdingBackward = false
	


func _on_inactive_projectile_instanced(proj,projectileScenePath):	
	proj.initFollowMovements()
	
	#migrate all the cached projectile resources to cached resoruces of player node
	# to avoid having to load the resource each time projectile fired
	var projCachedResources = proj.get_node("cachedResources")
	
	var playerCachedResources = kinbody.get_node("cachedResources")

	
	proj.heroSFXSoundPlayer.init(heroName)
	
	#re parent the resources
	proj.remove_child(projCachedResources)
	playerCachedResources.add_child(projCachedResources)
	projCachedResources.set_owner(playerCachedResources)

	emit_signal("inactive_projectile_instanced",proj,projectileScenePath)

#puts player into hitstun for a moment (failed pre emptive ripost or guard broke)
func goIntoVulnerableStunState(duration):
	
	if duration == 0:
		return
		
	adjustSpriteAnimationSpeed(duration,actionAnimeManager.STUNNED_ACTION_ID)
	playAction(actionAnimeManager.STUNNED_ACTION_ID)
	
	#var durationBeforeFallProne = 0 #not applicable
	#var stopHitMomentumOnLand = true #doesn't really matter, since ripost stops you in your tracks
	#var isThrow=false
#	var autoCancelableFlag=true
	
	
	
	
	
#	var mvmAnimation = null
#	if my_is_on_floor():
#		mvmAnimation = actionAnimeManager.mvmAnimationLookup(actionAnimeManager.GROUND_IDLE_ACTION_ID)
#	else:
#		mvmAnimation = actionAnimeManager.mvmAnimationLookup(actionAnimeManager.AIR_IDLE_ACTION_ID)
		
	
#	stopWalkingMovement()	
	
	#todo: create a 'stunned' state instead of hitstun
#	actionAnimeManager.playHitstun(duration,mvmAnimation,kinbody.facingRight,GLOBALS.LandingType.DONT_FALL_PRONE, durationBeforeFallProne,my_is_on_floor(),stopHitMomentumOnLand,isThrow)
	

#	playerState.inHitStun = true
	
	

#	breakFreeFromThrowCheck()
	

	
func attemptPushBlock(facingCmd):
	
	var commandConsummed = false
	
	#can't pushblock?
	if preventPushBlock:
		return false
	
	#so this check is required, since although the autocancel will limit what animation
	#can pushblock, since u can only pushblock strictly in blockstun, the null animation
	#autocancel into anything logic doesn't hold, so we need this check 
	#(otherwise in between animations, u can pushblock, which shouldn't be a thing
	if not guardHandler.isInBlockHitstun():
		commandConsummed=false
		return commandConsummed
		
	#enough bar to push block
	if playerState.hasEnoughAbilityBar(pushBlockCost):
		
		#try to play pushblock animation, requiring auto cancel (blockstun/proximity guard auto cancel)
		if my_is_on_floor():
		
			commandConsummed = playUserInputAction(actionAnimeManager.GROUND_PUSH_BLOCKING_ACTION_ID,facingCmd)
		else:
			commandConsummed = playUserInputAction(actionAnimeManager.AIR_PUSH_BLOCKING_ACTION_ID,facingCmd)
		
		#did we auto cancel succesfully?
		
		if commandConsummed:
			_on_request_play_special_sound(PUSH_BLOCK_SOUND_ID,COMMON_SOUND_SFX)		
			
			#playerState.consumeAbilityBar(pushBlockCost)
			playerState.forceConsumeAbilityBarInChunks(pushBlockCost)
			#opponentPlayerController.actionAnimeManager.spriteFrameSetIsHitting(true) #push block lets them  access on hit autocancel to punish push block
			#push opponent away from us
			
			if opponentPlayerController.actionAnimeManager.spriteAnimationManager.isInNeutralAnimation():
				
				#to avoid bugging out neutral mvm like walking, we keep current mvm animation
				#in neutral and get pushed back
				opponentPlayerController.playActionKeepOldCommand(opponentPlayerController.actionAnimeManager.GETTING_PUSH_BLOCKED_IN_NEUTRAL_ACTION_ID)
			else:
				#stop momentum and push back when in a non neutral animation
				opponentPlayerController.playActionKeepOldCommand(opponentPlayerController.actionAnimeManager.GETTING_PUSH_BLOCKED_ACTION_ID)
			#want to make sure the uninterruptible movement starts, so process the movement immediatly
			#note that this overrides hitfreeze and playes animation during hitfreeze (which is finze)
			#opponentPlayerController.actionAnimeManager.movementAnimationManager.handleCurrentAnimation(0)
			
			#don't let players access auto cancels on hit. Gotta raw ability cancel, cause belt
			#'s dashes are too fast
			#var flagIsHittingAfterUnlockFlag = false
			
			#TODO: fix bug where requires buffered ability cancel to cancel push block.
			#not sure why. i don't think its the input lockup
			#opponentPlayerController.inputLockHandler.reset()

			#PUSH_BLOCK_INPUT_INITIAL_LOCKOUT_DURATION and ushBlockActionWhiteListMask1,pushBlockActionWhiteListMask2 aren't used. old code
			#opponentPlayerController.inputLockHandler.enable(PUSH_BLOCK_INPUT_RESTRICTION_DURATION,PUSH_BLOCK_INPUT_INITIAL_LOCKOUT_DURATION,inHitFreezeFlag,flagIsHittingAfterUnlockFlag,pushBlockActionWhiteListMask1,pushBlockActionWhiteListMask2)#2 frames of no action after push block resolves
			#opponentPlayerController._on_start_tracking_frame_duration(PUSH_BLOCK_INPUT_RESTRICTION_DURATION)
			
			
			kinbody.pushBlockSfx.enable()
			kinbody.displayLocalTemporarySprites(kinbody.pushBlockSpriteSFXs)		
			
			
			
			emit_signal("push_blocked")
			
			#if not inHitFreezeFlag:
			#	startHitFreezeNotification(PUSH_BLOCK_HIT_FREEZE_DURATION)
			commandConsummed = true
		else:
			#failed to autocancel
			commandConsummed=false
	else:
		
		emit_signal("insufficient_ability_bar",pushBlockCost*playerState.abilityChunkSize)
		
		commandConsummed = false
		
	return commandConsummed
		
		
	
func _on_sprite_frame_activated(sf):
		
	if playerState.wasInBlockStun:
		#if sf.spriteAnimation.id != actionAnimeManager.CROUCHING_BUDGET_BLOCK_HIT_LAG_SPRITE_ANIME_ID and sf.spriteAnimation.id != actionAnimeManager.BUDGET_BLOCK_HIT_LAG_SPRITE_ANIME_ID:
		if not actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.CROUCHING_BUDGET_BLOCK_HIT_LAG_ACTION_ID) and not actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.BUDGET_BLOCK_HIT_LAG_ACTION_ID) and not actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.AIR_BUDGET_BLOCK_HIT_LAG_ACTION_ID):
		
			_on_exited_block_stun()		
	
	
	#change the length of ray cast hitting in corner length
	if sf.hittingCornerPushAwayRayCastLen <0:
		
		hittingRightWallDetector.cast_to.x	=kinbody.defaultHittingCornerPushAwayRayCastLength
		hittingLeftWallDetector.cast_to.x=-1*kinbody.defaultHittingCornerPushAwayRayCastLength
	else:
		hittingRightWallDetector.cast_to.x	=sf.hittingCornerPushAwayRayCastLen
		hittingLeftWallDetector.cast_to.x=-1*sf.hittingCornerPushAwayRayCastLen
		
	#make sure to let movement animtaion know if ignoring the push because iside opponent
	actionAnimeManager.movementAnimationManager.tmpIgnoringInsidePlayerPush = sf.ignoreInsideOpponentCornerPushAway	
	
	#if sf.spriteAnimation.id == actionAnimeManager.STUNNED_SPRITE_ANIME_ID:
	if actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.STUNNED_ACTION_ID):
	
		kinbody.stunParticles.visible = true
	else:
		kinbody.stunParticles.visible = false
	
	#we add lighting effects here to indicate what type aniamtion is being done
	#auto riposting?
	#if sf.spriteAnimation.id == actionAnimeManager.AUTO_RIPOST_SPRITE_ANIME_ID or sf.spriteAnimation.id == actionAnimeManager.AUTO_RIPOST_ON_HIT_SPRITE_ANIME_ID:
	#if sf.spriteAnimation.id == actionAnimeManager.AUTO_RIPOST_SPRITE_ANIME_ID or sf.spriteAnimation.id == actionAnimeManager.AUTO_RIPOST_ON_HIT_SPRITE_ANIME_ID:
		
	var autoRipostingFlag = actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.AUTO_RIPOST_ACTION_ID)
	autoRipostingFlag = autoRipostingFlag or actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.AIR_AUTO_RIPOST_ACTION_ID)
	
	var autoRipostingOnHitFlag = autoRipostingFlag or actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.AUTO_RIPOST_ON_HIT_ACTION_ID)
	autoRipostingOnHitFlag = autoRipostingFlag or actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.AIR_AUTO_RIPOST_ON_HIT_ACTION_ID)
	if  autoRipostingFlag or autoRipostingOnHitFlag:
		
		
		#last recovery frame of autparry where can be hit (to be changed, since this really coupled with sprite frame)?
		#if sf.spriteAnimation.id == actionAnimeManager.AUTO_RIPOST_SPRITE_ANIME_ID and sf.type == sf.FrameType.RECOVERY:
		if autoRipostingFlag and sf.type == sf.FrameType.RECOVERY:
			kinbody.autoRipostLight.visible = false
			#kinbody.autoRipostAura.visible = false
			kinbody.autoRipostAura.self_modulate.a= 0 #changing alpha and not visibility to mkae sure animation is cached for quick loading
			
			
		elif autoRipostingOnHitFlag and sf.type == sf.FrameType.RECOVERY:
			kinbody.autoRipostLight.visible = false
			#kinbody.autoRipostAura.visible = false
			kinbody.autoRipostAura.self_modulate.a= 0 #changing alpha and not visibility to mkae sure animation is cached for quick loading
		else:
			#not lighting effects to show?
			if kinbody.lightingEffectsEnabled:
				kinbody.autoRipostLight.visible = true
				#kinbody.autoRipostAura.visible = true
				kinbody.autoRipostAura.self_modulate.a= 1 #changing alpha and not visibility to mkae sure animation is cached for quick loading
				
				
			else:
				kinbody.autoRipostLight.visible = false
				#kinbody.autoRipostAura.visible = false
				kinbody.autoRipostAura.self_modulate.a= 0 #changing alpha and not visibility to mkae sure animation is cached for quick loading
				
				#kinbody.autoRipostAura.playing = false
				
		return
	else:
		#kinbody.autoRipostAura.visible = false
		kinbody.autoRipostAura.self_modulate.a= 0 #changing alpha and not visibility to mkae sure animation is cached for quick loading
		
		
		#kinbody.autoRipostAura.playing = false
		kinbody.autoRipostLight.visible = false
		
	#in block hitstun?
#	if sf.spriteAnimation.id == actionAnimeManager.BUDGET_BLOCK_HIT_LAG_SPRITE_ANIME_ID or  sf.spriteAnimation.id == actionAnimeManager.CROUCHING_BUDGET_BLOCK_HIT_LAG_SPRITE_ANIME_ID:
	if guardHandler.isInHoldBackBlockAnimation():
		
		#not lighting effects to show?
		if kinbody.lightingEffectsEnabled:
			#kinbody.blockLight.visible = true
			pass
			
		else:
			#kinbody.blockLight.visible = false
			pass
			
		return 
	else:
		#kinbody.blockLight.visible = false
		pass
		
		
		
	#grabbing?
	var grabbingFlag = actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.ON_HIT_GROUND_GRAB_ACTION_ID)
	grabbingFlag = grabbingFlag or actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.ON_HIT_AIR_GRAB_ACTION_ID)
	grabbingFlag = grabbingFlag or actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.GROUND_GRAB_ACTION_ID)
	grabbingFlag = grabbingFlag or actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.AIR_GRAB_ACTION_ID)
	#if sf.spriteAnimation.id == actionAnimeManager.ON_HIT_GROUND_GRAB_SPRITE_ANIME_ID or  sf.spriteAnimation.id == actionAnimeManager.GROUND_GRAB_SPRITE_ANIME_ID or sf.spriteAnimation.id == actionAnimeManager.ON_HIT_AIR_GRAB_SPRITE_ANIME_ID or  sf.spriteAnimation.id == actionAnimeManager.AIR_GRAB_SPRITE_ANIME_ID:
	if  grabbingFlag :
	
		
		#not lighting effects to show?
		if kinbody.lightingEffectsEnabled:
			#kinbody.grabLight.visible = true
			pass
			#below is how I would add a shader dynamically if required			
			#kinbody.activeNodeSprite.material.shader =colorOutlinerShader	
			#kinbody.activeNodeSprite.material.set_shader_param("intensity",50)
			#kinbody.activeNodeSprite.material.set_shader_param("precision",0.02)
			#kinbody.activeNodeSprite.material.set_shader_param("outline_color",Color(0.75,0,0.75,1))
		else:
			#kinbody.grabLight.visible = false
			pass
			
		return
	else:
		#kinbody.grabLight.visible = false
		pass
	
	#SEE if in oki, to make player more birght
	#if sf.spriteAnimation.id == actionAnimeManager.LANDING_HITSTUN_SPRITE_ANIME_ID:
	if actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.LANDING_HITSTUN_ACTION_ID):
		
		
		#check if its invincibility
		var invis = true
		
		#iteratve over each ddifre hurtbox
		for hb in sf.hurtboxes:
			invis = invis and (hb.subClass == hb.SUBCLASS_INVINCIBILITY)
		
		
		if invis:
			kinbody.activeNodeSprite.modulate.a	=OKI_INVINCIBILITY_TRANSPARANCY
			
			#first time changing to invincible oki frame?
			if not wasInInvincibleOki:
				wasInInvincibleOki=true
				emit_signal("entered_invincible_oki")
		else:
			kinbody.activeNodeSprite.modulate.a 	= defaultSpriteModulate.a
		
	else:
		kinbody.activeNodeSprite.modulate.a 	= defaultSpriteModulate.a
	#tech'ing?
	#var teching = sf.spriteAnimation.id == actionAnimeManager.GROUND_IN_PLACE_TECH_SPRITE_ANIME_ID
	#teching = teching or sf.spriteAnimation.id == actionAnimeManager.FORWARD_ROLLING_TECH_SPRITE_ANIME_ID
	#teching = teching or sf.spriteAnimation.id == actionAnimeManager.BACKWARD_ROLLING_TECH_SPRITE_ANIME_ID
	#teching = teching or sf.spriteAnimation.id == actionAnimeManager.CEILING_TECH_SPRITE_ANIME_ID
	#teching = teching or sf.spriteAnimation.id == actionAnimeManager.WALL_TECH_SPRITE_ANIME_ID
	#if teching:
	if actionAnimeManager.isTechSpriteAnimationId(sf.spriteAnimation.id):
		
		#not lighting effects to show?
		if kinbody.lightingEffectsEnabled:
			#kinbody.techLight.visible = true
			pass
		else:
			#kinbody.techLight.visible = false
			pass
			
		return
	else:
		#kinbody.techLight.visible = false
		pass
		
	#in clashing/rebound animation?
	#if sf.spriteAnimation.id == actionAnimeManager.REBOUND_SPRITE_ANIME_ID or  sf.spriteAnimation.id == actionAnimeManager.REBOUND_SPRITE_ANIME_ID:
	if actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.REBOUND_ACTION_ID) or  actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.REBOUND_CLASH_BREAK_VICTIM_ACTION_ID) or actionAnimeManager.isSpriteAnimationIdLinkedToAction(sf.spriteAnimation.id,actionAnimeManager.REBOUND_CLASH_BREAK_ACTION_ID):
		
		#not lighting effects to show?
		if kinbody.lightingEffectsEnabled:
			#kinbody.reboundLight.visible = true
			pass
		else:
			#kinbody.reboundLight.visible = false
			pass
			
		return
	else:
		#kinbody.reboundLight.visible = false
		pass
		
	#we check if the sprite frame supports false wall collisions or not
	if sf.interactWithFalseWalls:
		enableFalseWallCollisions()
	else:
		disableFalseWallCollisions()
	
func handleAttackTypeLightingSignaling(selfHitboxArea):
	
				#logic for lighting up hitbox with color of hitbox
	#for now just use 1st (should work for most moves) rectangle collisiosn shpae of a hitbox
	#don't emmit signal of sfx if hitbox doesn't suport it
	if selfHitboxArea != null and selfHitboxArea.emitsAttackSFXSignal:
		#if selfHitboxArea.cmd != null:
		#if isCommandMeleeSpecialTool(selfHitboxArea.cmd):
		#iterate all the collision shapes, and offset their position
		#to match our sprite offset 
		for c in selfHitboxArea.get_children():
			
			if c is CollisionShape2D:
				var shape = c.shape
				var xScale = 0
				var yScale = 0
				var angle = c.rotation_degrees
					
				if shape is RectangleShape2D:
					var extent = shape.get_extents()
					
					xScale = extent.x
					yScale = extent.y
					
					
				elif shape is CircleShape2D:
					xScale = shape.radius
					yScale = shape.radius
				var attackTypeIx = -1
				
				var cmd = selfHitboxArea.cmd 
				if selfHitboxArea.cmd == null:
					#attackTypeIx=null
					attackTypeIx=GLOBALS.OTHER_IX
				elif actionAnimeManager.isMeleeCommand(selfHitboxArea.cmd):
				#elif actionAnimeManager.isVisualSFXMeleeSpriteAnimeId(selfHitboxArea.spriteAnimation.id):
					attackTypeIx=GLOBALS.MELEE_IX
				elif actionAnimeManager.isSpecialCommand(selfHitboxArea.cmd):
				#elif actionAnimeManager.isVisualSFXSpecialSpriteAnimeId(selfHitboxArea.spriteAnimation.id):
					attackTypeIx=GLOBALS.SPECIAL_IX
				elif actionAnimeManager.isToolCommand(selfHitboxArea.cmd):
				#elif actionAnimeManager.isVisualSFXToolSpriteAnimeId(selfHitboxArea.spriteAnimation.id):
					attackTypeIx=GLOBALS.TOOL_IX
				else:
					attackTypeIx=GLOBALS.OTHER_IX
					
				emit_signal("display_attack_lighting",attackTypeIx,cmd,c,xScale,yScale,angle,kinbody.spriteCurrentlyFacingRight,selfHitboxArea.damage)
				return c.global_position
				
	return null		
		
func _on_started_bouncing():
	
	pass
func _on_stopped_bouncing(rc):
	
	pass
func _on_bounced():
	
	pass
	
func canCurrentSpriteFramePreventBounce():
	return actionAnimeManager.spriteAnimationManager.canCurrentSpriteFramePreventBounce()
	
func _on_reached_vertical_momentum_apex():
	#print("apex of vertical speed reached")
	pass
	
func getMovementAnimationManager():
	return actionAnimeManager.movementAnimationManager
	
	
func _on_proximity_guard_enabled_changed(proxGuardEnabled):
	
	#skip casae where eneabled, the inputhandler function will deal with this
	if proxGuardEnabled:
		return
	
	#here want to avoid sticking in prox block even when move wiffed u
	#blockign from proximity guard?
	if actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_AIR_HOLD_BACK_BLOCK_ACTION_ID):
		#KEep momentum after releasing block and go idle in air, was blocking
		playActionKeepOldCommand(actionAnimeManager.AIR_IDLE_ACTION_ID)
	elif actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_STANDING_HOLD_BACK_BLOCK_ACTION_ID):
		
		
		#KEep momentum after releasing block and go idle in air, was blocking
		#playActionKeepOldCommand(actionAnimeManager.GROUND_IDLE_ACTION_ID)
		playActionKeepOldCommand(actionAnimeManager.GROUND_MOVE_BACKWARD_ACTION_ID)
	#elif actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_CROUCHING_HOLD_BACK_BLOCK_ACTION_ID):	
		
	#	playActionKeepOldCommand(actionAnimeManager.CROUCH_ACTION_ID)
		
	#DON'T HAVE TO CONSIDER CROUCH HOLD BACK BLOCK, SINCE WILL JUST GO BACK INTO CROUCH IF HOLDING DOWN, AND IF RELEASED, WILL UNCROUCH
func _on_ability_cancel_light_timer_timeout():
	kinbody.abilityCancelLight.visible = false
	
	
func _on_create_projectile(projectile,spawnPoint):
	emit_signal("create_projectile",projectile,spawnPoint)
	
#to be overridden by subcalsses, returns true when can create projectile, and false
#to avoid create a projectile
func readyToCreateProjectileHook(projectileFrame):
	return true
	
	
func checkForMissedFloorCollision():
	#here, we solve the issue of going air idle as you are on ground 
	#this manifested as bug where could do anything (had to jump out since missed florr land signal)
	if actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.AIR_IDLE_ACTION_ID):
		if my_is_on_floor():
			playActionKeepOldCommand(actionAnimeManager.GROUND_IDLE_ACTION_ID)			
			
func _on_ground_dashed(type):
	pass

func _on_num_empty_dmg_stars_changed(old,new):
	pass
	#match(new):
	#	0:
		
	#		kinbody.emptyStarGlow.visible = false
	#		kinbody.emptyStarGlow.emitting = false
	#	1:
	#		kinbody.emptyStarGlow.visible = true
	#		kinbody.emptyStarGlow.emitting = true
	#		kinbody.emptyStarGlow.amount = 4
	#	2:
	#		kinbody.emptyStarGlow.visible = true
	#		kinbody.emptyStarGlow.emitting = true
	#		kinbody.emptyStarGlow.amount = 10
	#	3:
	#		kinbody.emptyStarGlow.visible = true
	#		kinbody.emptyStarGlow.emitting = true
	#		kinbody.emptyStarGlow.amount = 16
	#	4:
	#		kinbody.emptyStarGlow.visible = true
	#		kinbody.emptyStarGlow.emitting = true
	#		kinbody.emptyStarGlow.amount = 32
	#	5:
	#		kinbody.emptyStarGlow.visible = true
	#		kinbody.emptyStarGlow.emitting = true
	#		kinbody.emptyStarGlow.amount = 64
func _on_filled_combo_level_up():
	emit_signal("fill_combo")
	pass
	#_on_request_play_special_sound(FILL_DMG_STAR_COMBO_SOUND_ID)
	
func _on_insufficient_ability_bar(amount):
	
	_on_request_play_special_sound(NO_MORE_BAR_SOUND_ID,COMMON_SOUND_SFX)
	
	kinbody.missingAbilityBarIcon.display(GLOBALS.MISSING_BAR_ICON_DURATION)#1 second display missing chunk icon
	
	#kinbody.playerNotification.setTextOnTimeout("?",1)
	
	
func _on_opponent_hitstun_changed(inHitStunFlag):
	
	if not inHitStunFlag:
		emit_signal("combo_ended")
		opponentPlayerController.emit_signal("ability_bar_gain_finished")
		

		#reset the counter used to determine how much we increase ability bar
		#from magic series, since you were ripost, you lose all ability bar gain
		#you would have gottne since you got riposted
		#did with get magic series combos in our combo?
		if playerState.magicSeriesBarIncreaseCount > 0:
			
			
			#only gain bar from magic series if enabled
			if not cantGainBarFromMagicSeries:
				#increase bar baed on number of magic serires
				emit_signal("pre_ability_bar_gain")
				
				
				
				var barGainInChunks =numAbChunksGainOnComboLvl * playerState.magicSeriesBarIncreaseCount
				
				#add additional chunks gain (or lost) in air ()
				barGainInChunks = barGainInChunks + (float(playerState.airMagicSeriesBarIncreaseCount) * additionalNumChunksGainMagicSeriesInAir)
				
				playerState.increaseAbilityBarInChunks(barGainInChunks)
				emit_signal("ability_bar_gain_finished")
			
			
			
			#although reset when combo started, just to be safe reset it here too
			playerState.magicSeriesBarIncreaseCount=0
			playerState.airMagicSeriesBarIncreaseCount = 0
			
		#we reset the sprite animations that can only hit once before changing properties for
		#remainder of combo
		var checkAbilityCancelRefreshBlackList=false#false to refresh all moves no matter what. the combo ended
		actionAnimeManager.refreshAllOneTimeHitAnimations(checkAbilityCancelRefreshBlackList)
		
#called when pushblock finished initial lock of input
func _on_input_restriction_timeout(flagIsHittingAfterUnlockFlag):
	dashABCancelPreventingMvmInput=false
	
	#we can now play user animation again
	if flagIsHittingAfterUnlockFlag:
		#do we allow player to input on_hit comands?
		actionAnimeManager.spriteFrameSetIsHitting(true)
		actionAnimeManager.spriteFrameSetHittingAnyHitbox(true)
		
func _on_start_tracking_frame_duration(frameDuration):
	emit_signal("start_tracking_frame_duration",frameDuration,inHitFreezeFlag)


#emits a snignal via the frame analyzer to display if a stun of other animation is +/- depending on
#on opponent's animation frames remaining
func displayFrameData(stunDuration):

	#var framesRemainingForAttacker = opponentPlayerController.getFramesRemainingInAnimation()
	var framesRemainingForAttacker = opponentPlayerController.animationFramesRemaining
	_displayFrameData(framesRemainingForAttacker,stunDuration)
	
func _displayFrameData(framesRemainingForAttacker,stunDuration):
	
	opponentPlayerController.frame_analyzer.handleFrameDataLableUpdate(framesRemainingForAttacker,stunDuration)
	

#returns number of frames until current  animation ends (or 0 if no animatio playing)
func getFramesRemainingInAnimation():
	var currentAnimation = actionAnimeManager.spriteAnimationManager.currentAnimation
	var framesRemaining = 0
	if currentAnimation == null:
		pass
	else:
		
		#special case when in non oki hitstun?
		if isInNonOkiHitstunSpriteAnimation():
			framesRemaining = hitstunTimer.get_time_left_in_frames()
		else:
			framesRemaining=	currentAnimation.computeNumberRemainingFrames()
		
	return framesRemaining
	

#given a target animation type (hitstun or block stun), a duration, and remaining frames of current aniamtion
#calculate a target duration as meaty, basic, add, or meaty add
func calculateTargetAniamtionDuration(durationType,targetDuration,currAnimationFramesRemaining):
	var resDuration = 1
	
	
	match(durationType):
		GLOBALS.HITSTUN_DURATION_TYPE_ADD:
			#the target animation duration is dynamic, while the +/- of the target aniamtion is static
			#, it depends on time remaining for attacker's current animation
			#will also add this amount of time to current animation's duration
			#var framesRemainingForAttacker = opponentPlayerController.getFramesRemainingInAnimation()
			
			# a basic attack of +2, means that additional animation duration is framesRemainingForAttacker + 2
			#an attack of -5 means that additional aniation duration is framesRemainingForAttacker - 5, so victim will break free of 
			#target animation 5 frames before attacker finishes his animation
			#gotta be craful, since <= 0 animation duration is an infinite loop (minimum 1 frame)
	#		var relativeDuration = max(1,framesRemainingForAttacker + targetDuration) 
			
			
			resDuration = targetDuration + currAnimationFramesRemaining
			# +1, since for special case of "JUST frames", want make sure +5 means a startup moves of 5 will hit (takes 1
			#frame for the phsysics engine to process the activated frame and do collisions
	
		GLOBALS.HITSTUN_DURATION_TYPE_MEATY:
			#here target animation duration is a fixed amount, irrespective of
			#how much time attacker's animation has reminaing
			resDuration = targetDuration
			# +1, since for special case of "JUST frames", want make sure +5 means a startup moves of 5 will hit (takes 1
			#frame for the phsysics engine to process the activated frame and do collisions
		GLOBALS.HITSTUN_DURATION_TYPE_BASIC:
			#the duration of target aniamtion is dynamic, while the +/- of the target animation is static, the
			#target animation duration depends on time remaining for attacker's current animation
			
			#var framesRemainingForAttacker = opponentPlayerController.getFramesRemainingInAnimation()
			var framesRemainingForAttacker = opponentPlayerController.animationFramesRemaining
			
			
			# a basic attack of +2, means that additional hitstun is framesRemainingForAttacker + 2
			#an attack of -5 means that additional hitstun is framesRemainingForAttacker - 5, so attacker break free 5 frames before
			#gotta be craful, since 0 hitstun  or less isn't valid (minimum 1 frame)
			resDuration = max(1,framesRemainingForAttacker + targetDuration)
			# +1, since for special case of "JUST frames", want make sure +5 means a startup moves of 5 will hit (takes 1
			#frame for the phsysics engine to process the activated frame and do collisions
		_:
			print("warning, unknown animation duration type ("+durationType+")")
			pass
	return resDuration

func attemptRecoverOnHitAirDash():
	
	#recovering an air dash from hitting is a special feature for acrobatics proficiency
	#can't regain air dashes normally
	if recoverAirDashOnHit:
		
		if not my_is_on_floor():
			#hasn't recovered an air dash from hitting yet and expended the only air dash?
			if not playerState.hasAirDashe and not playerState.recoveredAirDashFromHit:
				playerState.recoveredAirDashFromHit= true
				playerState.hasAirDashe = true
				
			else:
				#will need to wait until landing before being able to recover an air dash from hitting again
				pass

func attemptRecoverAirDashFromAbilityCancel():
	#can only recover once until we land again
	if not playerState.recoveredAbilityCancelAirDash:
		
		if not my_is_on_floor():
			#only if we dont' havae the air dash do we get it back and lock out the regain dash 
			#from next cancel
			if not playerState.hasAirDashe:
				playerState.hasAirDashe = true
				playerState.recoveredAbilityCancelAirDash=true
			
				
func hasBrokenSuperArmor(hurtbox):
	if hurtbox == null:
		return false
		
	if actionAnimeManager.spriteAnimationManager.currentAnimation == null:
		return false
	return actionAnimeManager.spriteAnimationManager.currentAnimation.superArmorWasHitCount >hurtbox.superArmorHitLimit
	
func _on_bumped_into_something():
	
	#check whether the knockback animation of histun will
	#stop the momentum upon pushing oppnent
	if playerState.inHitStun:
		
		var sa = actionAnimeManager.spriteAnimationManager.currentAnimation
		var techExceptions = 0
		if sa != null:
			#might have frame perfect land/tech hitstun situation, so make sure the property iexsits
			if "stopMomentumOnPushOpponent" in sa:
				
				if sa.stopMomentumOnPushOpponent:
					playActionKeepOldCommand(actionAnimeManager.MOMENTUM_STOP_ACTION_ID)
					



func _on_exited_left_corner():
#	print(kinbody.heroName+" left the  left corner")
	
	occupyingLeftCorner = false
	
	
	#is the opponent in corner? 
	if opponentPlayerController.collisionHandler.wasInLeftCorner:
		
		#give the opponent the corner
		opponentPlayerController.occupyingLeftCorner = true
func _on_exited_right_corner():
	#print(kinbody.heroName+" left the right corner")
	occupyingRightCorner = false
	
	
	#is the opponent in corner? 
	if opponentPlayerController.collisionHandler.wasInRightCorner:
		
		#give the opponent the corner
		opponentPlayerController.occupyingRightCorner = true
	pass
func _on_entered_left_corner():
	#print(kinbody.heroName+" entered the left corner")
	
	#nobody is in corner?
	if not opponentPlayerController.occupyingLeftCorner:
		
		#take over the corner
		occupyingLeftCorner=true

func _on_entered_right_corner():
	
	
	#print(kinbody.heroName+" entered the right corner")
	
	#nobody is in corner?
	if not opponentPlayerController.occupyingRightCorner:
		
		#take over the corner
		occupyingRightCorner=true
		

func _on_entered_opponent_body_box():
	
	
		#opponent in corner
		if opponentPlayerController.isInCorner():
	
			#trying to contest the corner. already occupied. get pushed out
			actionAnimeManager.movementAnimationManager.pushPlayerAwayFromInsideOpponent(kinbody.facingRight)
			

	
func _on_exited_opponent_body_box():
	
	#nothing to do if we have disabled body box
	#already disabled?
	if not bodyBoxCollisionEnabledFlag:
		actionAnimeManager.movementAnimationManager.stopPushingPlayerAwayFromInsideOpponent()
		#disable opponent's as well just incase they miss signal
		opponentPlayerController.actionAnimeManager.movementAnimationManager.stopPushingPlayerAwayFromInsideOpponent()
		return
		
	#we want to enable body box only if the enabling was delayed since 
	#we were inside opponent and the current spriteframe has an enabled body box
	#other wise keep disabled
	var sf = actionAnimeManager.spriteAnimationManager.getCurrentSpriteFrame()
	
	if sf == null:
		#remain disabled, so that if buffer in command that has disable body box, won't pop player aside
		pass
	else:
		#only enabled if sprite frame says so
		if sf.disableBodyBox:
			_disablePlayerBodyCollision()
		else:
			_enablePlayerBodyCollision()
			
		
	actionAnimeManager.movementAnimationManager.stopPushingPlayerAwayFromInsideOpponent()
	#disable opponent's as well just incase they miss signal
	opponentPlayerController.actionAnimeManager.movementAnimationManager.stopPushingPlayerAwayFromInsideOpponent()
	
func isInCorner():
	return occupyingRightCorner or occupyingLeftCorner
	
	
	
func on_hitting_opponent_post_ripost(selfHitboxArea, opponentHurtboxArea,attackSpriteId):
	#hittingPlayerInCornerPushAwayCheck(selfHitboxArea, opponentHurtboxArea)
	pass
	
func _on_debug_restart_following_mvm(src,dst,followMvm):
	emit_signal("debug_follow_mvm_started",src,dst,followMvm)
					
			
func isInOkiHitstunSpriteAnimation():
	return  actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.LANDING_HITSTUN_ACTION_ID)
func isInNonOkiHitstunSpriteAnimation():
	return actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.HITSTUN_ACTION_ID) or actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.AIR_HITSTUN_ACTION_ID)
	
func applyStunDmgVulnerability(mod):
	var sa =actionAnimeManager.spriteAnimationLookup(actionAnimeManager.STUNNED_ACTION_ID)
	
	if sa == null:
		print("failed to make stun aniamtion vulnerable to damage. Null aniamtion")
		return
	
	#iterate over each sprite frame to apply vunlerability to each hurtbox
	for sf  in sa.spriteFrames:
		
		for hurtbox in sf.hurtboxes:
			#note that restance is calculated as 0.5 would be half, so 2 would be double damage
			hurtbox.damageResistance= hurtbox.damageResistance*mod
func _on_whiffed_auto_riposte():
	
	#do we lose bar from missing an auto riposte?
	if numChunksLostOnMisssedAutoRiposte > 0:
		playerState.forceConsumeAbilityBarInChunks(numChunksLostOnMisssedAutoRiposte)


func _on_entered_invincible_oki():
	pass
	
func _on_opponent_entered_invincible_oki():
	#our stale moves refresh since combo is effectivly done, and in theory
	#we can meaty the oki wakeup with the fresh move
	var checkAbilityCancelRefreshBlackList=false#false to refresh all moves no matter what. the combo ended
	actionAnimeManager.refreshAllOneTimeHitAnimations(checkAbilityCancelRefreshBlackList)
	
	

func trainingModeEnterCharDependentState(params):
	#to be override by sublcasses. should put player in a special state like a stance change or something 
	#when game upaunses in training mode and the setting is enabled
	pass
	

func isInPushBlockingAnimation():
	
	return actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.GROUND_PUSH_BLOCKING_ACTION_ID) or actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.AIR_PUSH_BLOCKING_ACTION_ID)
	
	
func _on_half_hp_reached():
	var numChunks=GLOBALS.getNumberOfChunks(playerState.abilityBar,playerState.abilityChunkSize)
	#comback mechanic, if you get to half hp, you get bar back if your low
	if numChunks < halfHPAbilityIncreaseThreshold:
		
		#can't gain bar from the half way mark if locked ot of bar
		if not playerState.abilityBarGainLocked:
			emit_signal("pre_ability_bar_gain")
			playerState.setAbilityBarAmountInChunks(halfHPAbilityIncreaseThreshold)
			emit_signal("ability_bar_gain_finished")
		
		
#hook function to support screen wrap handling	
func _on_player_left_screen(exitedScreenLeftSide,screenRect):
	pass
	

func mirrorAirActionDIRequired():
	#sprite is aligned with player relative screen position?
	if kinbody.facingRight ==kinbody.spriteCurrentlyFacingRight:
		
		#no need to mirror 
		return false
		
	else:
		
		#potentially air animation with movement have to be mirrored
		#depending on proficiency and whether in air and the current animation
		return not canChangeSpriteFacingInAir()
		
func canChangeSpriteFacingInAir():
	#always false unless proficiency disadvantage acrobatics chosen
	if preventAutoTurnAroundInAir:
		
		var animeId = null
		var anime = actionAnimeManager.spriteAnimationManager.currentAnimation
		if anime != null:
			animeId=anime.id
		#we in the air, automatically turning around is disabled whiel airborne, and doing an animation
		#that doesn't override the disabled auto turn around (liek hitestun)?
		if not my_is_on_floor() and actionAnimeManager.isSpriteAnimationInAirTurnAroundBlackList(animeId):
			return false
		else:
			return true
	else:
		return true