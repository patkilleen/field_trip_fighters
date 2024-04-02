extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal ripost
signal create_projectile
signal player_ready
signal changed_sprite_facing



#var commandParticleResource = preload("res://particles/CommandParticle.tscn")
var frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")
var GLOBALS = preload("res://Globals.gd")

var movementAnimationManager = null
var actionAnimationManager = null
var playerController = null
var spriteAnimationManager = null
var gameObjects = null
var floorDetector = null
var leftPlatformDetector = null
var rightPlatformDetector = null
var insideOpponentDetector = null
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
var activeNodes = null
var sprite = null
var bodyBox = null
var attackSFXContainer = null
var turnAroundTimersNode = null
var landOnPlayerArea = null
var insidePlayerArea = null
#var proximityGuardArea = null

#attributes that will have their values overwritten by roote module before game start
var hp = null
var abilityBarMaximum = null
var abilityBar = null
var maxDamageGauge = null
var maxFocus = null
var profAbilityBarCostMod = null
var abilityNumberOfChunks = null
var baseAbilityCancelCost = null
var ripostDamage = null
var damageGaugeFailedRipostModIncrease = null
var focusFailedRipostModIncrease = null


var profGuardRegenAmountOnPerfectBlock = null
var damageGaugeComboLevelUpModIncrease = null
var damageGaugeRateMode = null
var focusComboLevelUpModIncrease = null
var focusRateMode = null
var ripostingPreWindow = null #number of frames to preemptively ripost
var ripostingReactWindow = null #number of frames to react to ripost
var facingRight = false setget setFacingRight,getFacingRight
var counterRipostingPreWindow = null
var ripostHitstunDuration=null
var ripostingAbilityBarRegenMod = null
var blockCooldownTime = null

var failedBlockDamageDecrease = null
var reboundingDamageThreshold = null
var minimumNumberReboundFrames = null
var reboundFramesMod = null
var maxNumReboundFramesSameDmg = null
var highDamageThreshold = null
var numJumps = null
var inputDeviceId = null
var hitBoxLayer = null
var hitBoxMask = null
var hurtBoxLayer = null
var hurtBoxMask = null
var selfHitBoxLayer = null
var selfHitBoxMask = null
var selfHurtBoxLayer = null
var selfHurtBoxMask = null
var proximityGuardMask = null
var defaultBlockEfficiency = null
var blockEfficiency = null
var maxBlockEff = null
var minBlockEff = null
var profAbilityBarComboProrationMod = null
var profAbilityBarComboLvlProrationMod=null
#the bodybox collision bit of opponent
var opponentPushableBodyBoxCollisionBit = null
#var pushableBodyBoxLayerBit = null
var bodyBoxCollisionBit= null
var opponentBodyBoxCollisionBit = null
var pushableBodyBoxCollisionBit = null
var falseWallCollisionBit = null
var stageCollisionBit= null
var stageFloorCollisionBit = null

var antiBlockHitstunDuration=null
var antiBlockDamage = null
var successfulAntiBlockDmg = null
var failedBlockDamageCapacityDecrease = null
var failedBlockFocusDecrease = null
var failedBlockFocusCapacityDecrease = null
var ripostHitFreeze = null
var failedTechAbilityBarCost = null
var maxNumberWallBounces = null
var playerName = null
var heroName = null
var focusCashInMod =null
var damageGaugeCashInMod =null		
var onRipostingDmgIncreaseRatio = null
var onRipostingBarReduceAmount = null

var guardHpLossRate = null

var halfHPAbilityIncreaseThreshold = null
var maxGuardHP=null
var guardHP=null

var loseGuardHPWhileWalkingBack = null
var gainBarOnGuardBreak=null
var numBarChunksGainedFromGuardBreak=null
var histunAbilityCancelProrationReductionRate =null
#var airDashSpeedMod =null
#var jumpSpeedMod = null
#var groundDashSpeedMod =null

#var cmdHitParticleBuffer=null
var additionalDamagePerStar = null

var standardLightingMaskBit=null
var abilityCancelLightingMaskBit=null

var acroABCancelExtraJumpBarCost=null

var defaultGuardDamageDealtModVsAirOpponent =null
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
var tripleDmgVulnInStun = false#ProficiencyPropertyID.BAD_TAKE_TRIPLE_DAMAGE_IN_STUN,
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
var additionalCooldownToAirGrab = 0
var preventGroundDashing = false
var preventBlockingGroundAttacksWhileAirborne = false
var preventIncorrectBlocking = false
var boostedBuffGuardRegenMod=null
var autoRipostGuardRegenBuffFillAmount=null
var abCancel_SpamProrationSetback = null
var enableJumpDashOutOfPushBlock = false
var regenGuardOnPerfectBlock =false
var loseTechInvincibility = false
var takeEnormousBlockChipDamage = false
var enormousBlockChipDamageMod = 0
var counterRipostStealsBar = false
var cantAutoRipost = false
var cantGainBarFromMagicSeries = false
var cantGrab = false
var incorrectBlockDamageReductionEnabled = false
var incorrectBlockDamageReductionMod = 1
var hasAdditionalGrabCharge = false
var abilityCancelOnHitOnly = false
var preventAutoTurnAroundInAir = false
var preventPushBlock = false		
#var advProf=null
#var disProf=null

var faildRipostBarGainLockTimeSecs = null
var faildRipostBarGainLockNumHits = null
var majorProf1Ix=null
var minorProf1Ix=null
var majorProf2Ix=null
var minorProf2Ix=null
	


#end

export (bool) var offScreenMagnifyingGlass = true
export (Color) var debug_body_box_color = null
export (float) var scaleModifier = 1
export (Vector2) var magnifyingGlassSpriteOffset = Vector2(0,0)
export (float) var abilityCancelLightEnergy = 3
export (bool) var supportsReverseBeat = false
export (int, FLAGS, "Jump","F-Jump", "B-Jump","Ground Idle","Ground F-Move","Ground B-Move" ,"Crouch","N-Melee","N-Special","N-Tool","B-Special","auto ripost","Air Idle","Air F-Move","Air B-Move", "Air F-Dash", "Air B-Dash","Air-Melee","Air-Special","Air-Tool","Fast Fall","Air Move Stop", "Air auto ripost","F-Special","D-Melee","U-Tool","D-Tool","F-Tool","B-Tool","U-Special","F-Melee","B-Special") var forwardDashABCancelWhiteList = 0
export (int, FLAGS, "D-Special","B-Melee","U-Melee","F-Ground-Dash","B-Ground-Dash", "Air-grab","grab","crouching-hold-back-block","Platform Drop", "Leave Platform Keep Animation","F-dash crouch cancel","non-cancelable f-ground-dash","non-cancelable b-ground-dash","apex-of-jump-only fast-fall","standing-hold-back-block","air-hold-back-block","standing-push-block","air-push-block","Air Jump","Air F-Jump", "Air B-Jump","b-dash-Crouch-cancel", "basic crouch cancel", "non-GDC jump","non-GDC F-jump", "non-GDC b-jump") var forwardDashABCancelWhiteList2 = 0
export (int, FLAGS, "Jump","F-Jump", "B-Jump","Ground Idle","Ground F-Move","Ground B-Move" ,"Crouch","N-Melee","N-Special","N-Tool","B-Special","auto ripost","Air Idle","Air F-Move","Air B-Move", "Air F-Dash", "Air B-Dash","Air-Melee","Air-Special","Air-Tool","Fast Fall","Air Move Stop", "Air auto ripost","F-Special","D-Melee","U-Tool","D-Tool","F-Tool","B-Tool","U-Special","F-Melee","B-Special") var backDashABCancelWhiteList = 0
export (int, FLAGS, "D-Special","B-Melee","U-Melee","F-Ground-Dash","B-Ground-Dash", "Air-grab","grab","crouching-hold-back-block","Platform Drop", "Leave Platform Keep Animation","F-dash crouch cancel","non-cancelable f-ground-dash","non-cancelable b-ground-dash","apex-of-jump-only fast-fall","standing-hold-back-block","air-hold-back-block","standing-push-block","air-push-block","Air Jump","Air F-Jump", "Air B-Jump","b-dash-Crouch-cancel", "basic crouch cancel", "non-GDC jump","non-GDC F-jump", "non-GDC b-jump") var backDashABCancelWhiteList2 = 0

export (int, FLAGS, "Jump","F-Jump", "B-Jump","Ground Idle","Ground F-Move","Ground B-Move" ,"Crouch","N-Melee","N-Special","N-Tool","B-Special","auto ripost","Air Idle","Air F-Move","Air B-Move", "Air F-Dash", "Air B-Dash","Air-Melee","Air-Special","Air-Tool","Fast Fall","Air Move Stop", "Air auto ripost","F-Special","D-Melee","U-Tool","D-Tool","F-Tool","B-Tool","U-Special","F-Melee","B-Special") var pushBlockAcrobaticsAutoCancels = 0
export (int, FLAGS, "D-Special","B-Melee","U-Melee","F-Ground-Dash","B-Ground-Dash", "Air-grab","grab","crouching-hold-back-block","Platform Drop", "Leave Platform Keep Animation","F-dash crouch cancel","non-cancelable f-ground-dash","non-cancelable b-ground-dash","apex-of-jump-only fast-fall","standing-hold-back-block","air-hold-back-block","standing-push-block","air-push-block","Air Jump","Air F-Jump", "Air B-Jump","b-dash-Crouch-cancel", "basic crouch cancel", "non-GDC jump","non-GDC F-jump", "non-GDC b-jump") var pushBlockAcrobaticsAutoCancels2 = 0
var framePauseFrequency = -1
var slowingDownGame = false
var pauseFrameCounter = 0
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD
var isInitialized = false

var spriteCurrentlyFacingRight = false
var landOnOpponentSignalEnabled = true

var dashStreakParticlesResource = preload("res://particles/dashStreakParticles.tscn")

var inHitFreeze = false
var defaultHittingCornerPushAwayRayCastLength=50
var activeNodeSprite = null
var lightingEffectsEnabled = true
var autoRipostLight = null
var blockLight = null
var techLight = null
var grabLight = null
var reboundLight = null
var abilityCancelLight = null
var starArray = null
var autoRipostAura = null
var meleeAttackLight = null
var specialAttackLight = null
var toolAttackLight = null
var dmgStarGlow = null
var missingAbilityBarIcon = null
var pushBlockSfx = null

var comboMagicSeriesCount=0

var guardRegenBuffParticles = null
var playerNameLabel = null
var playerNotification = null
var standingBlockstunSprite = null
var lowBlockstunSprite = null

var shatteredLowBlockstunSprite=null
var shatteredStandingBlockstunSprite=null
	
var abilityCancelParticleBuffer = null
var abilityCancelSwrilSFXBuffer = null
var abilityCancelExplosionSFXBuffer =null
var shieldBreakParticleBuffer = null


var autoAbilityCancelParticles = null
var emptyStarGlow = null
var stunParticles = null
var alphaSpriteFrameYOffset = Vector2(0,0)

var prefectBlockSFX = null
var badBlockSFX =null
var grabbedAutoRipostingSFX =null
var pushBlockingTmpSFX = null
var autoRipostAwaitingSFX=null
var autoRipostOnHitSFX=null
var spriteSFXNode = null

var perfectBlockSpriteSFXs = []
var badBlockSpriteSFXs=[]
var grabbedAutoRipostingSrptiesSFXs=[]
var pushBlockSpriteSFXs = []
var autoRipostAwaitingSpriteSFXs = []
var autoRipostOnHitSpriteSFXs = []


var spriteSFXBuffer = []
var opponentSpriteSFXBuffer = []
func _ready():
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	set_physics_process(false)
	emit_signal("player_ready")
	pass
	
func setGlobalSpeedMod(g):
	globalSpeedMod = g
	
	#find all tiemrs
#	for c in self.get_children():
#		if c is frameTimerResource:
#			c.setGlobalSpeedMod(g)
		
func reset():
	
	framePauseFrequency = -1
	slowingDownGame = false


	pauseFrameCounter = 0
	spriteCurrentlyFacingRight = false
	landOnOpponentSignalEnabled = true
	inHitFreeze = false
	#alphaSpriteFrameYOffset = bodyBox.position
	#bodyBox.position.x = 0
	#bodyBox.position.y = 0
	self.set_physics_process(false)
	
	shatteredLowBlockstunSprite.reset()
	shatteredStandingBlockstunSprite.reset()
	
	_on_face_correct_direction(true)
	
	
func init():
	
	
	
	# Called when the node is added to the scene for the first time.
	# Initialization here
	floorDetector = $bodyBox/floorDetector
	leftPlatformDetector = $bodyBox/leftPlatformDetector
	rightPlatformDetector = $bodyBox/rightPlatformDetector
	
	leftOpponentDetector = $bodyBox/leftOpponentDetector
	rightOpponentDetector = $bodyBox/rightOpponentDetector
	insideOpponentDetector = $bodyBox/insideOpponentDetector
	
	leftWallDetector = $bodyBox/leftWallDetector
	rightWallDetector = $bodyBox/rightWallDetector
	leftCornerDetector = $bodyBox/leftCornerDetector
	rightCornerDetector = $bodyBox/rightCornerDetector
	hittingLeftWallDetector = $bodyBox/hittingLeftWallDetector
	hittingRightWallDetector = $bodyBox/hittingRightWallDetector
	
	
	defaultHittingCornerPushAwayRayCastLength=abs(hittingRightWallDetector.cast_to.x)
	
	disableBodyBoxLeftWallDetector = $bodyBox/disableBodyBoxLeftWallDetector
	disableBodyBoxRightWallDetector = $bodyBox/disableBodyBoxRightWallDetector
	stunParticles = $"HUD/stunned-particles"
	stunParticles.visible = false
	
	spriteSFXNode = $"active-nodes/sfxSprites"

	guardRegenBuffParticles=$"guardRegenBuffParticles"
	
	
	activeNodeSprite = $"active-nodes/Sprite"
	
	activeNodeSprite.material= ShaderMaterial.new()
	
	#cmdHitParticleBuffer =$"cmdHitParticleBuffer"
	
	#make sure to initialize all the particles data models
	#for c in cmdHitParticleBuffer.get_children():
		
	#	c.init()
	
	playerNotification = $HUD/playerNotification
	missingAbilityBarIcon = $HUD/missingAbilityBar
	
	missingAbilityBarIcon.visible = false
	
	pushBlockSfx = $"active-nodes/pushBlockSfx"
	pushBlockSfx.visible = true
	autoRipostLight = $"active-nodes/autoripost-light"
	blockLight = $"active-nodes/blocking-light"
	grabLight = $"active-nodes/grab-light"
	techLight = $"active-nodes/tech-light"
	reboundLight=$"active-nodes/rebound-light"
	autoRipostAura = $autoRipostSFX
	#abilityCancelParticles = $abilityCancelParticles
	abilityCancelParticleBuffer = $"abilityCancelParticleBuffer"
	abilityCancelSwrilSFXBuffer = $"abilityCancelSwirlParticleBuffer"
	abilityCancelExplosionSFXBuffer =$"abilityCancelExplosionParticleBuffer"

	shieldBreakParticleBuffer = $"active-nodes/shieldBreakParticleBuffer"

	for c in abilityCancelSwrilSFXBuffer.get_children():
		c.pauseOnHitFreeze=false
	for c in abilityCancelExplosionSFXBuffer.get_children():
		c.pauseOnHitFreeze=false
	
	
	autoAbilityCancelParticles = $autoAbilityCancelParticles
	#MAKE SURE all the lights are on the p
	abilityCancelLight = $"active-nodes/ability-cancel-light"
	abilityCancelLight.energy = abilityCancelLightEnergy
	
	
	abilityCancelLight.range_item_cull_mask = 1 << standardLightingMaskBit
	abilityCancelLight.range_item_cull_mask = abilityCancelLight.range_item_cull_mask | (1 << abilityCancelLightingMaskBit)
	
	
	
	prefectBlockSFX  = $"active-nodes/perfectBlocksfx"
	badBlockSFX =$"active-nodes/badBlocksfx"
	grabbedAutoRipostingSFX =$"active-nodes/grabAutoRipostingBlocksfx"
	pushBlockingTmpSFX = $"active-nodes/pushBlockingTmpSfx"
	autoRipostAwaitingSFX=$"active-nodes/autoripost-awaiting"
	autoRipostOnHitSFX=$"active-nodes/autoripost-on-hit"
	
	for c in prefectBlockSFX.get_children():		
		perfectBlockSpriteSFXs.append(c)				
	
	for c in badBlockSFX.get_children():		
		badBlockSpriteSFXs.append(c)
	
	for c in grabbedAutoRipostingSFX.get_children():		
		grabbedAutoRipostingSrptiesSFXs.append(c)
	
	for c in pushBlockingTmpSFX.get_children():		
		pushBlockSpriteSFXs.append(c)				
		
	for c in autoRipostAwaitingSFX.get_children():		
		autoRipostAwaitingSpriteSFXs.append(c)				
	
	for c in autoRipostOnHitSFX.get_children():		
		autoRipostOnHitSpriteSFXs.append(c)				
		
	emptyStarGlow = $emptyStarGlow
	dmgStarGlow = $dmgStarGlow
	meleeAttackLight = $"active-nodes/melee-light"
	specialAttackLight = $"active-nodes/special-light"
	toolAttackLight = $"active-nodes/tool-light"

	bodyBox = $bodyBox
	
	alphaSpriteFrameYOffset = bodyBox.position
	bodyBox.position.x = 0
	bodyBox.position.y = 0
	
	activeNodes = $"active-nodes"
	activeNodes.enableAreas()
	sprite = $"active-nodes/Sprite"
	gameObjects = $gameObjects
	playerController = $PlayerController
	
	
	#sprite.light_mask = 1
	sprite.light_mask = sprite.light_mask | ( 1 << standardLightingMaskBit)
	sprite.light_mask = sprite.light_mask | ( 1 << abilityCancelLightingMaskBit)
	
	
	#proximityGuardArea = $"proximity-guard-area"
	landOnPlayerArea = $bodyBox/landOnPlayerArea
	insidePlayerArea = $bodyBox/insidePlayerArea2D
	
	landOnPlayerArea.connect("body_entered",self,"_on_land_on_opponent")
	landOnPlayerArea.connect("body_exited",self,"_on_stop_landing_on_opponent")
	
	attackSFXContainer = $"active-nodes/attackSFXs"
	
	#playerController.connect("cmd_action_changed",attackSFXContainer,"displayCommandParticles")
	$PlayerController/CollisionHandler.connect("hitting_player",self,"_on_attack_hit")
	
	#playerController.connect("cmd_attack_hit",self,"displayAttackCommandParticles")
	
	
	playerController.highDamageParticles = $"rage-smoke"
	playerController.damageIncParticles = $"damage-inc"
	playerController.damageDecParticles = $"damage-dec"
	playerController.comboLevelParticles = $"star-burst"
	playerController.antiBlockParticles = $"anti-block"
	
	
	var sprite = $"active-nodes/Sprite"
	var collisionAreas = $"active-nodes/collisionAreas"
	var attackSFXs = $"active-nodes/attackSFXs"
	playerController.kinbody = self
	
	
	#make sure the sprite is aware of eing applied hitstun for hit shaking effects
	playerController.connect("about_to_be_applied_hitstun",sprite,"_on_about_to_be_applied_hitstun")
	playerController.get_node("PlayerState").connect("changed_in_hitstun",sprite,"_on_changed_in_hitstun")
	
	
	#air dash speed required pre-init
	#playerController.airDashSpeedMod =airDashSpeedMod
	#playerController.jumpSpeedMod = jumpSpeedMod
	#playerController.groundDashSpeedMod =groundDashSpeedMod
	
	playerController.heroName = heroName
	
	playerController.init(sprite,collisionAreas,attackSFXs,bodyBox,activeNodes)
	
	
	starArray  = $"HUD/HBoxContainer/star-array"
	#playerController.playerState.connect("combo_level_changed",starArray,"setNumberOfStars")
	playerController.playerState.connect("combo_level_changed",self,"_on_magic_series_or_reverse_beat")
	playerController.playerState.connect("focus_combo_level_changed",self,"_on_magic_series_or_reverse_beat")
	playerController.connect("combo_ended",self,"_on_combo_ended")
	
	#when the guard regen boost changes, activate the particles
	playerController.playerState.connect("guard_regen_buff_flag_changed",guardRegenBuffParticles,"set_visible")
	playerController.playerState.connect("guard_regen_buff_flag_changed",guardRegenBuffParticles,"set_emitting")
	
	#playerController.connect("display_attack_lighting",self,"displayAttackTypeLighting")
	starArray.setNumberOfStars(0)
	
	actionAnimationManager = $PlayerController/ActionAnimationManager
	#actionAnimationManager.connect("create_projectile",self,"_on_create_projectile")
	playerController.connect("create_projectile",self,"_on_create_projectile")
	
	playerController.connect("ripost",self,"_on_ripost")

	
	standingBlockstunSprite = $"active-nodes/standing-blockstun-shield"
	standingBlockstunSprite.z_index = $"active-nodes/Sprite".z_index+1 #on top of player
	
	lowBlockstunSprite = $"active-nodes/low-blockstun-shield"
	lowBlockstunSprite.z_index = $"active-nodes/Sprite".z_index+1 # on top of player

	shatteredLowBlockstunSprite=$"shattered-standing-blockstun-shield"
	shatteredStandingBlockstunSprite=$"shattered-low-blockstun-shield"
	


	playerController.connect("landed",lowBlockstunSprite,"_on_land") 
	playerController.connect("landed",standingBlockstunSprite,"_on_land") 
	
	#connect guard break to shield sprites
	playerController.get_node("guardHandler").connect("guard_broken",shatteredLowBlockstunSprite,"_on_guard_break")
	playerController.get_node("guardHandler").connect("guard_broken",shatteredStandingBlockstunSprite,"_on_guard_break")
	
	
	standingBlockstunSprite.init(maxGuardHP,0)
	lowBlockstunSprite.init(maxGuardHP,0)
	
	shatteredLowBlockstunSprite.init()
	shatteredStandingBlockstunSprite.init()
	playerController.playerState.connect("guardHP_changed",standingBlockstunSprite,"_on_guard_hp_changed")
	playerController.playerState.connect("guardHP_changed",lowBlockstunSprite,"_on_guard_hp_changed")
	
	
	playerController.ripostHandler.ripostingPreWindow = ripostingPreWindow
	playerController.ripostHandler.ripostingReactWindow = ripostingReactWindow
	playerController.ripostDamage = ripostDamage
	playerController.damageGaugeComboLevelUpModIncrease = damageGaugeComboLevelUpModIncrease
	playerController.focusComboLevelUpModIncrease = focusComboLevelUpModIncrease
	playerController.ripostingAbilityBarCost = ripostingAbilityBarCost
	playerController.counterRipostingAbilityBarCost = counterRipostingAbilityBarCost
	#playerController.ripostCounterHandler.counterRipostingPreWindow = counterRipostingPreWindow
	playerController.damageGaugeFailedRipostModIncrease = damageGaugeFailedRipostModIncrease
	playerController.focusFailedRipostModIncrease = focusFailedRipostModIncrease
	playerController.damageGaugeRateMode = damageGaugeRateMode
	playerController.focusRateMode = focusRateMode
	playerController.blockCooldownTime = blockCooldownTime
	playerController.grabCooldownTime = grabCooldownTime
	#playerController.antiBlockDamage=antiBlockDamage
	playerController.floorDetector = floorDetector
	playerController.antiBlockHitstunDuration=antiBlockHitstunDuration
	playerController.leftPlatformDetector = leftPlatformDetector
	playerController.rightPlatformDetector = rightPlatformDetector
	playerController.leftOpponentDetector = leftOpponentDetector
	playerController.insideOpponentDetector = insideOpponentDetector
	playerController.rightOpponentDetector = rightOpponentDetector
	playerController.leftWallDetector = leftWallDetector
	playerController.rightWallDetector = rightWallDetector
	playerController.leftCornerDetector = leftCornerDetector
	playerController.rightCornerDetector = rightCornerDetector	
	playerController.hittingLeftWallDetector = hittingLeftWallDetector
	playerController.hittingRightWallDetector = hittingRightWallDetector
	playerController.disableBodyBoxLeftWallDetector=disableBodyBoxLeftWallDetector
	playerController.disableBodyBoxRightWallDetector=disableBodyBoxRightWallDetector
	playerController.successfulAntiBlockDmg = successfulAntiBlockDmg
	playerController.failedBlockDamageDecrease = failedBlockDamageDecrease
	playerController.failedBlockDamageCapacityDecrease = failedBlockDamageCapacityDecrease
	playerController.failedBlockFocusDecrease = failedBlockFocusDecrease
	playerController.failedBlockFocusCapacityDecrease = failedBlockFocusCapacityDecrease
	playerController.ripostingAbilityBarRegenMod = ripostingAbilityBarRegenMod
	playerController.ripostHitstunDuration =ripostHitstunDuration
	playerController.playerState.numJumps = numJumps
	playerController.playerState.currentNumJumps = numJumps
	playerController.playerState.hp = hp
	playerController.playerState.numJumps = numJumps
	playerController.playerState.currentNumJumps = numJumps
	playerController.playerState.maxDamageGauge = maxDamageGauge
	playerController.playerState.maxFocus = maxFocus
	playerController.playerState.currentNumJumps = numJumps
	playerController.playerState.abilityBar = abilityBar
	playerController.playerState.abilityBarMaximum = abilityBarMaximum
	playerController.halfHPAbilityIncreaseThreshold=halfHPAbilityIncreaseThreshold
	playerController.playerState.profAbilityBarCostMod = profAbilityBarCostMod
	playerController.playerState.abilityNumberOfChunks = abilityNumberOfChunks
	playerController.playerState.baseAbilityCancelCost=baseAbilityCancelCost
	playerController.playerState.defaultBlockEfficiency = defaultBlockEfficiency
	playerController.playerState.blockEfficiency = defaultBlockEfficiency
	playerController.playerState.maxBlockEff = maxBlockEff
	playerController.playerState.minBlockEff = minBlockEff
	playerController.reboundingDamageThreshold = reboundingDamageThreshold
	playerController.techAbilityBarCost = techAbilityBarCost
	playerController.minimumNumberReboundFrames = minimumNumberReboundFrames #atleast 6.6 frames of rebound
	playerController.reboundFramesMod = reboundFramesMod #addition "1.8* damage" of rebound frames
	playerController.maxNumReboundFramesSameDmg=maxNumReboundFramesSameDmg
	playerController.highDamageThreshold = highDamageThreshold #x2 damage will make rage smoke appear
	playerController.ripostHitFreeze = ripostHitFreeze
	playerController.failedTechAbilityBarCost = failedTechAbilityBarCost
	playerController.maxNumberWallBounces = maxNumberWallBounces
	
	playerController.onRipostingDmgIncreaseRatio=onRipostingDmgIncreaseRatio
	playerController.onRipostingBarReduceAmount=onRipostingBarReduceAmount
	
	playerController.numJumpsGainedFromAbCancel = numJumpsGainedFromAbCancel
	playerController.recoverAirDashOnHit=recoverAirDashOnHit
	playerController.recoverAirDashOnJump = recoverAirDashOnJump
	playerController.playerState.maxGuardHP=maxGuardHP
	playerController.playerState.guardHP=guardHP
	playerController.guardHpRegenRate=guardHpRegenRate
	playerController.guardHpLossRate =guardHpLossRate
	playerController.autoRipostAbilityBarCost =autoRipostAbilityBarCost
	playerController.pushBlockCost=pushBlockCost
	playerController.loseGuardHPWhileWalkingBack=loseGuardHPWhileWalkingBack
	playerController.gainBarOnGuardBreak=gainBarOnGuardBreak
	playerController.numBarChunksGainedFromGuardBreak=numBarChunksGainedFromGuardBreak
	playerController.additionalDamagePerStar=additionalDamagePerStar
	playerController.correctBlockGuardDamageDealtMod=correctBlockGuardDamageDealtMod
	playerController.autoAbilityCancelBaseCost=autoAbilityCancelBaseCost
	playerController.numAbChunksGainOnComboLvl = numAbChunksGainOnComboLvl
	playerController.faildRipostBarGainLockTimeSecs = faildRipostBarGainLockTimeSecs
	playerController.faildRipostBarGainLockNumHits = faildRipostBarGainLockNumHits
	playerController.regenGuardInAir = regenGuardInAir
	playerController.recoverJumpOnAirBlock = recoverJumpOnAirBlock
	playerController.defaultGuardDamageDealtModVsAirOpponent=defaultGuardDamageDealtModVsAirOpponent
	#playerController.comboHandler.init(playerController,playerController.playerState,damageGaugeRateMode,damageGaugeComboLevelUpModIncrease,focusRateMode,focusComboLevelUpModIncrease)
	
	playerController.canLowBlowInAir = canLowBlowInAir
	playerController.regenGuardInAir = regenGuardInAir
	playerController.numJumpsGainedFromAbCancel = numJumpsGainedFromAbCancel
	playerController.recoverAirDashOnAirBlock = recoverAirDashOnAirBlock
	playerController.loseJumpAndAirDashOnAirBlock = loseJumpAndAirDashOnAirBlock
	playerController.recoverAirDashOnHit = recoverAirDashOnHit
	playerController.recoverAirDashAndJumpOnAirTech = recoverAirDashAndJumpOnAirTech
	playerController.regenAbilityBarOnPerfectBlock = regenAbilityBarOnPerfectBlock
	playerController.regenAbilityBarOnPerfectBlock = regenAbilityBarOnPerfectBlock
	playerController.numAbChunksGainOnComboLvl = numAbChunksGainOnComboLvl
	playerController.faildRipostBarGainLockTimeSecs = faildRipostBarGainLockTimeSecs
	playerController.faildRipostBarGainLockNumHits = faildRipostBarGainLockNumHits
	
	playerController.recoverJumpOnAirBlock = recoverJumpOnAirBlock
	playerController.defaultGuardDamageDealtModVsAirOpponent	 = defaultGuardDamageDealtModVsAirOpponent
	
	
	playerController.barChunksGainedOnGrabbingAutoriposter=barChunksGainedOnGrabbingAutoriposter
	playerController.whiffedGrabProvokesCooldown =whiffedGrabProvokesCooldown
	playerController.airAbilityCancelCostInChunksTax=airAbilityCancelCostInChunksTax
	playerController.preventAirDashing=preventAirDashing
	
	playerController.acroABCancelExtraJumpBarCost = acroABCancelExtraJumpBarCost
	
	playerController.preventDITech =preventDITech
	#playerController.tripleDmgVulnInStun =tripleDmgVulnInStun
	
	#do we apply more damage to being in stun?
	if tripleDmgVulnInStun:
		#triple damage in stun
		playerController.applyStunDmgVulnerability(3)
		
	playerController.preventGrabInAir=preventGrabInAir
	playerController.preventAbilityCancelStaleMoveReset=preventAbilityCancelStaleMoveReset
	playerController.additionalBarGainFromBreakingGuard=additionalBarGainFromBreakingGuard
	playerController.additionalBarFeedFromGettingGuardBroken =additionalBarFeedFromGettingGuardBroken
	
	
	
	playerController.correctBlockGuardDamageTakenMod = correctBlockGuardDamageTakenMod
	playerController.incorrectBlockGuardDamageDealtMod  =incorrectBlockGuardDamageDealtMod
	playerController.incorrectBlockGuardDamageTakenMod = incorrectBlockGuardDamageTakenMod
	playerController.airBlockGuardDamageDealtMod=airBlockGuardDamageDealtMod
	playerController.airBlockGuardDamageTakenMod=airBlockGuardDamageTakenMod
	playerController.blockChipDamageDealtMod=blockChipDamageDealtMod
	playerController.blockChipDamageTakenMod=blockChipDamageTakenMod
	
	
	playerController.additionalNumChunksGainMagicSeriesInAir =additionalNumChunksGainMagicSeriesInAir
	playerController.numChunksLostOnMisssedAutoRiposte =numChunksLostOnMisssedAutoRiposte
	playerController.recoverGrabOnAutoAbilityCancel =recoverGrabOnAutoAbilityCancel
	playerController.recoverGrabOnAbilityCancel =recoverGrabOnAbilityCancel
	playerController.additionalCooldownToAirGrab= additionalCooldownToAirGrab
	playerController.preventGroundDashing= preventGroundDashing
	
	playerController.guardHandler.regenGuardOnPerfectBlock=regenGuardOnPerfectBlock
	playerController.guardHandler.profGuardRegenAmountOnPerfectBlock=profGuardRegenAmountOnPerfectBlock
	
	#make sure pushblock can jump/dash when flag enabled
	#by adjusting mask dynamically for all push block frames
	if enableJumpDashOutOfPushBlock:
		for pbSAId in playerController.actionAnimeManager.pushBlockSpriteAnimeIds:
			var sa = playerController.actionAnimeManager.spriteAnimationManager.spriteAnimations[pbSAId]
			for sf in sa.spriteFrames:
				#add jump and dash to auto cancel movs of pushblock
				sf.autoCancels= sf.autoCancels | pushBlockAcrobaticsAutoCancels
				sf.autoCancels2= sf.autoCancels2 | pushBlockAcrobaticsAutoCancels2
	
	#tech should be htitable?
	if loseTechInvincibility:
		for techSAId in playerController.actionAnimeManager.techSpriteAnimeIds:
			var sa = playerController.actionAnimeManager.spriteAnimationManager.spriteAnimations[techSAId]
			for sf in sa.spriteFrames:
				for hb in sf.hurtboxes:
					#make the hurtbox type basic to remove invincibility
					hb.subClass = hb.SUBCLASS_BASIC
	
	#give an extra grab charge
	if hasAdditionalGrabCharge:
		playerController.playerState.defaultGrabCharges = playerController.playerState.defaultGrabCharges+1  
		playerController.playerState.grabCharges=playerController.playerState.defaultGrabCharges
	
	playerController.abilityCancelOnHitOnly	=abilityCancelOnHitOnly
	playerController.preventAutoTurnAroundInAir=preventAutoTurnAroundInAir
	playerController.preventPushBlock = preventPushBlock
	playerController.takeEnormousBlockChipDamage=takeEnormousBlockChipDamage
	playerController.enormousBlockChipDamageMod=enormousBlockChipDamageMod
	playerController.counterRipostStealsBar=counterRipostStealsBar
	playerController.cantAutoRipost=cantAutoRipost
	playerController.cantGrab=cantGrab
	playerController.guardHandler.incorrectBlockDamageReductionEnabled = incorrectBlockDamageReductionEnabled
	playerController.guardHandler.incorrectBlockDamageReductionMod=incorrectBlockDamageReductionMod
	playerController.cantGainBarFromMagicSeries=cantGainBarFromMagicSeries
	playerController.preventBlockingGroundAttacksWhileAirborne = preventBlockingGroundAttacksWhileAirborne
	playerController.preventIncorrectBlocking = preventIncorrectBlocking
	playerController.boostedBuffGuardRegenMod=boostedBuffGuardRegenMod
	playerController.autoRipostGuardRegenBuffFillAmount=autoRipostGuardRegenBuffFillAmount

	movementAnimationManager = $PlayerController/ActionAnimationManager/MovementAnimationManager
	movementAnimationManager.targetKinematicBody2D = self
	
	
	
	
	#here is  example for maxugard hp of 125, a regen boost of x4, a typical regen rate of 1.1 guard hp /second
	#60*(62.5)/(4*1.1)] ~= 14 seconds to fill half the gaurd bar 
	var guardHPAmount = autoRipostGuardRegenBuffFillAmount*maxGuardHP
	playerController.autoRipostGuardRegenBuffDuration=GLOBALS.FRAMES_PER_SECOND*guardHPAmount/(boostedBuffGuardRegenMod*guardHpRegenRate)
	
	#for c in self.get_children():
	#	if c is CollisionShape2D:
	#		#var is_one_waycollision = c.one_way_collision
	#		bodyBox = c
	#		bodyBox.set_shape(RectangleShape2D.new())
			#bodyBox.one_way_collision = is_one_waycollision
	#		break
	
	#bodyBox.set_shape(RectangleShape2D.new())
	#facingRight = shouldFaceRight
	bodyBox.facingRight = facingRight
	bodyBox.modulate = debug_body_box_color
	movementAnimationManager.bodyBox = bodyBox
	movementAnimationManager.floorDetector = floorDetector
	
		
	spriteAnimationManager = $PlayerController/ActionAnimationManager/SpriteAnimationManager
	
	spriteAnimationManager.connect("sprite_animation_played",self,"_on_sprite_animation_played")
	
	#$PlayerController.kinbody = self
	$PlayerController/InputManager.inputDeviceId = inputDeviceId
	#$PlayerController/InputManager.inputDeviceId = GLOBALS.PLAYER1_INPUT_DEVICE_ID
	#$PlayerController/InputManager.manualPhysicsProcessHookCallFlag=true #players_controller will call physiscs_process of input manage
	
	playerNameLabel = $HUD/HBoxContainer2/pnameLabel
	playerNameLabel.text = inputDeviceId
	
	#did we assign a name to player?
	if playerName != null:
		playerNameLabel.text = playerName
		
	if( inputDeviceId == "P1"):
		playerNameLabel.set("custom_colors/font_color",Color(1,0,0))
	else:
		playerNameLabel.set("custom_colors/font_color",Color(0,0,1))
	
	
	#connect to the proximity guard area
	#proximityGuardArea.connect("area_entered",$PlayerController/guardHandler,"_on_proximity_guard_enabled")
	#proximityGuardArea.connect("area_exited",$PlayerController/guardHandler,"_on_proximity_guard_disabled")
	#make sure area can monitor but not detectable by other hitboxes (although prob not necessary since
	#hitbox just has scan mask, but just to be safe)
	#proximityGuardArea.monitoring = true
	#proximityGuardArea.monitorable = false
	#proximityGuardArea.get_node("hitbox").disabled = false
	
	
	#connect all hitboxes and hurtboxes given mask
	var proximityGuardAreas = actionAnimationManager.spriteAnimationManager.getAllProximityGuardAreas()
	var hitboxes = actionAnimationManager.spriteAnimationManager.getAllHitboxes()
	var hurtboxes = actionAnimationManager.spriteAnimationManager.getAllHurtboxes()
	var selfOnlyHitboxes = actionAnimationManager.spriteAnimationManager.getAllSelfOnlyHitboxes()
	var selfOnlyHurtboxes = actionAnimationManager.spriteAnimationManager.getAllSelfOnlyHurtboxes()
	
	for hb in proximityGuardAreas:
		hb.playerController = playerController
		
	for hb in hitboxes:
		hb.playerController = playerController
		
	for hb in hurtboxes:
		hb.playerController = playerController
		
	for hb in selfOnlyHitboxes:
		hb.playerController = playerController
		
	for hb in selfOnlyHurtboxes:
		hb.playerController = playerController

		
			
	proximityGuardAreas = activeNodes.getProximityGuardAreas()
	hitboxes = activeNodes.getHitboxAreas()
	hurtboxes = activeNodes.getHurtboxAreas()
	selfOnlyHurtboxes = activeNodes.getSelfOnlyHurtboxAreas()
	selfOnlyHitboxes = activeNodes.getSelfOnlyHitboxAreas()
	
	
	
	for hb in proximityGuardAreas:
		hb.collision_layer = 0
		hb.collision_mask = proximityGuardMask
		
		
	for hb in hitboxes:
		#if not hb.selfOnly:
		hb.collision_layer = hitBoxLayer
		hb.collision_mask = hitBoxMask
		#else:
		#	hb.collision_layer = selfHitBoxLayer
		#	hb.collision_mask = selfHitBoxMask
		#connect collision to action manager
		hb.connect("area_entered",playerController.collisionHandler,"_on_area_entered_hitbox",[hb])
		
	for hb in hurtboxes:
		#if not hb.selfOnly:
		hb.collision_layer = hurtBoxLayer
		hb.collision_mask = hurtBoxMask
	#	else:
	#		hb.collision_layer = selfHurtBoxLayer
	#		hb.collision_mask = selfHurtBoxMask
		hb.connect("area_entered",playerController.collisionHandler,"_on_area_entered_hurtbox",[hb])
		hb.connect("area_exited",playerController.collisionHandler,"_on_area_exited_hurtbox",[hb]) #required to detect when proximity guard diasbled
		
	for hb in selfOnlyHitboxes:
		#if not hb.selfOnly:
		#hb.collision_layer = hitBoxLayer
		#hb.collision_mask = hitBoxMask
		#else:
		hb.collision_layer = selfHitBoxLayer
		hb.collision_mask = selfHitBoxMask
		#connect collision to action manager
		hb.connect("area_entered",playerController.collisionHandler,"_on_area_entered_hitbox",[hb])
		
	for hb in selfOnlyHurtboxes:
		#if not hb.selfOnly:
		#hb.collision_layer = hurtBoxLayer
		#hb.collision_mask = hurtBoxMask
	#	else:
		hb.collision_layer = selfHurtBoxLayer
		hb.collision_mask = selfHurtBoxMask  
		
		hb.connect("area_entered",playerController.collisionHandler,"_on_area_entered_hurtbox",[hb])
		
	#connect to the areas for collisison signals
	#for area in activeNodes.collisionAreas:
	#	area.connect("body_entered",playerController.collisionHandler,"_on_body_entered_area2d",[area])
		
	#rescale(scaleModifier)
	actionAnimationManager.playAction(actionAnimationManager.AIR_IDLE_ACTION_ID,facingRight)#player spawns a few feet off ground
	
	self.set_physics_process(false)
	
	faceDirection(facingRight)
	
	turnAroundTimersNode = $turnAroundTimers
	
	
	isInitialized = true

func rescale(scaleMod):
	#1 means not scaling, so do nothing
	if scaleMod == 1:
		return
		
	var sprite = $"active-nodes/Sprite"
	sprite.scale = sprite.scale*scaleMod
	actionAnimationManager.spriteAnimationManager.rescale(scaleMod)
	
	#don't rescale body box for game consistency reasons . teh resacling is really jsut workaround 
	#that i didn't design glove correctly and was to lazy to fit all body boxes to re-scaled sprite
	
	#rescale body box
#	var transform =bodyBox.get_shape()
	
	#duplaite deep copy body box
#	transform=transform.duplicate(true)
#	var oldScale = transform.get_extents()
	#don't touch the x scale, cause a lot of signal/collisions depend on assumption 
	#that the body boxes are the same width
#	transform.set_extents(Vector2 (oldScale.x, oldScale.y *scaleMod))
#	bodyBox.set_shape(transform)
	
	#iterate raycasts to resize too (don't touch x axis, just y )
#	for c in bodyBox.get_children():
#		if c is RayCast2D:
			
#			var oldCastTo = c.cast_to
		
	#		c.cast_to.y = oldCastTo.y*scaleMod
			
		
	#	var oldPos = c.position
	
	#	c.position.y = oldPos.y*scaleMod
		
	#the landon on player area isn't moving, but what ever we don't use it anyway
	
func setFacingRight(f):
	var facingChanged = f != facingRight
	
	facingRight = f
	
	#changed facing?
	if isInitialized and facingChanged:
		
		
		var spriteAnimationManager = playerController.actionAnimeManager.spriteAnimationManager
		var currAnime = spriteAnimationManager.currentAnimation
		
		if currAnime == null:
			return
			
		#only turn around in number of frame
		#d3epending on current animation
		#todo: make this a hitfreeze aware timer, as hitfreeze pauses game and you should turn aroudn mid hitfreeze
		var frameTimer = frameTimerResource.new()
		frameTimer.connect("timeout",self,"_on_face_correct_direction",[],CONNECT_ONESHOT)
		
		turnAroundTimersNode.add_child(frameTimer)
		
		#make sure the timer is paused if in hitfreeze
		if inHitFreeze:
			frameTimer.handleHitFreezeStarted()
		
		
		var numFrameTurnAround = currAnime.numberOfFramesForTurnAround
		#ajdjust based on the global speed mod
		#numFrameTurnAround = ceil(numFrameTurnAround/globalSpeedMod)
	
	
		if numFrameTurnAround == 0:
			
			#automatically turn around
			_on_face_correct_direction()	
		#wait till the animation finishes bbefore turning
		elif numFrameTurnAround == -1:			

			#just wait till animation finishes
			pass
		else:
			#wait specific number of frames based on current animation
			frameTimer.start(numFrameTurnAround)
		

func getFacingRight():
	return facingRight

	
func getspriteCurrentlyFacingRight():
	return spriteCurrentlyFacingRight
	#here we will need to also consider the current sprite animation
		#cause sprite frame may explicitly be considered "facing opposite direction"
	#return facingRight
	
#this will be called when a sprite animatino is played (forcing the correct facing)
#, when a timer is up, or instantly upon facing change
func _on_face_correct_direction(forceCorrectDirection=false):
	
	if turnAroundTimersNode != null:
		#iterate through all tiemrs, stop them all, and remove them all
		for t in turnAroundTimersNode.get_children():
			
			t.stop()
			turnAroundTimersNode.remove_child(t)
	
	if forceCorrectDirection:
		faceDirection(facingRight)
	else:
	
		if playerController.canChangeSpriteFacingInAir():
			faceDirection(facingRight)
		else:
			#can't face correct direction
			pass
		
		
func faceDirection(_facingRight):
	
	var changeFacingFlag = _facingRight != spriteCurrentlyFacingRight
	
	if _facingRight:
		
		activeNodes.set_scale(Vector2(1,1))
		
		#facingRight = true
		spriteCurrentlyFacingRight = true
		bodyBox.facingRight = true
	else:
		
		activeNodes.set_scale(Vector2(-1,1))
		
		spriteCurrentlyFacingRight = false
		bodyBox.facingRight = false
	
	if changeFacingFlag:
		emit_signal("changed_sprite_facing",_facingRight)

#called when a sprite animation played	
func _on_sprite_animation_played(anime):

	
	
	#only turn around when animation is played if it suports that. otherwise
	#keep same fadcing (on hits and rekas, for example)
	if anime.facingCorrectDirectionOnPlay:
		_on_face_correct_direction()

func _physics_process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	pass
	

func _on_land_on_opponent(body):
	
	#ignore signal if were moving through opponent (tech, or other cross-up)
	#if bodyBox.disabled:************
	if not playerController.bodyBoxCollisionEnabledFlag or not playerController.opponentPlayerController.bodyBoxCollisionEnabledFlag or not landOnOpponentSignalEnabled:
		return
		
		
	#playerController._on_land_on_opponent()
	return

# warning-ignore:unused_argument
func _on_stop_landing_on_opponent(body):
	#ignore signal if were moving through opponent (tech, or other cross-up)
	#if bodyBox.disabled:***************
	#if not bodyBoxCollisionEnabledFlag:
	#if not playerController.bodyBoxCollisionEnabledFlag or not playerController.opponentPlayerController.bodyBoxCollisionEnabledFlag:
#		return
	#playerController._on_stop_landing_on_opponent()
	pass
	
func _on_ripost(ripostedInNeutralFlag):
	emit_signal("ripost",ripostedInNeutralFlag)


func distanceToOpponent():
	var usCenter = getCenter()
	var oppCenter = playerController.opponentPlayerController.kinbody.getCenter()
	
	return abs(usCenter.distance_to(oppCenter))
	
func getCenterX():
	var extent = bodyBox.get_shape().extents
	var centerX = bodyBox.global_position.x + extent.x/2
	return centerX
	

func getCenterY():
	var extent = bodyBox.get_shape().extents
	var centerY = bodyBox.global_position.y + extent.y/2
	return centerY
	
func getCenter():
	var extent = bodyBox.get_shape().extents
	extent.x = extent.x/2.0
	extent.y = extent.y/2.0
	return bodyBox.global_position + extent
	
func getRelativeCenter():
	var extent = bodyBox.get_shape().extents
	extent.x = extent.x/2.0
	extent.y = extent.y/2.0
	return bodyBox.position + extent


	
#func displayAttackCommandParticles(cmd):
	#make command particle float
	#var cmdParticle = commandParticleResource.instance()
	#self.add_child(cmdParticle)
	#cmdParticle.owner = self
	#cmdParticle.init()
#	var cmdParticle = cmdHitParticleBuffer.get_next_particle()
#	var success = cmdParticle.emitCommand(cmd)
#	if success:
#		cmdHitParticleBuffer.trigger()
	


		
func _on_create_projectile(projectile, spawnPoint):
	__on_create_projectile_helper(projectile, spawnPoint,self)
	
func __on_create_projectile_helper(projectile, spawnPoint,projectileOwner):
	#broadcast the signal up but also add facing to projectil
	#projectile.facingRight = self.facingRight
	#projectile.facingRight = getFacingRight()
	
	#projectile.facingRight = facingRight
	projectile.facingRight = spriteCurrentlyFacingRight
	projectile.ripostingReactWindow = playerController.ripostHandler.ripostingReactWindow
	
	#make sure projectiles' hitbox/hurtbox is same as player
	#projectile.hitBoxLayer = self.hitBoxLayer
	#projectile.hitBoxMask = self.hitBoxMask
	#projectile.hurtBoxLayer = self.hurtBoxLayer
	#projectile.hurtBoxMask = self.hurtBoxMask
	
	#projectile.selfHitBoxLayer = self.selfHitBoxLayer
	#projectile.selfHitBoxMask = self.selfHitBoxMask
	#projectile.selfHurtBoxLayer = self.selfHurtBoxLayer
	#projectile.selfHurtBoxMask = self.selfHurtBoxMask
		
	#projectile.masterPlayerController = self.playerController
	
	
	
	
	#mirror x if facing opposite way, make sure it's rrelative to the sprite direction, not the ideal facing direction
	#if not self.facingRight:
	#if not getFacingRight():
	if not spriteCurrentlyFacingRight:
		spawnPoint.x = spawnPoint.x * (-1)
		
	#position of projectile is relative to player	
		
	#adding to stage's game objects node?
	if projectile.mvmType == projectile.MovementType.RELATIVE_TO_STAGE:
		projectile.position = spawnPoint + projectileOwner.position
	#adding to be relative to player?
	elif projectile.mvmType == projectile.MovementType.RELATIVE_TO_PLAYER:
		projectile.position = spawnPoint


	#projectile.position  = self.position

	emit_signal("create_projectile",projectile,projectileOwner,self)
	
	

func _on_attack_hit(selfHitboxArea, otherHurtboxArea):
	
	#old particles, ignore
	pass
	#display the command type and direction particles to 
	#give a visual indication of move hit with
	#if selfHitboxArea!= null:
		#if selfHitboxArea.cmd != null:
			
			#ignore self hitboxes like glove's hitball hitboxes
			#if not selfHitboxArea.selfOnly:
				#attackSFXContainer.displayCommandParticles( selfHitboxArea.cmd)
			
		

#func displayAttackTypeLighting(attackTypeIx,shape,xScale,yScale,angle):
	
#	return 
	#var pos = shape.position
	#if not lightingEffectsEnabled:
	#	return 
		
	#var lightToTurnOn = null
	#if attackTypeIx == GLOBALS.MELEE_IX:
	#	meleeAttackLight.visible=true
	#	lightToTurnOn=meleeAttackLight
	#	specialAttackLight.visible=false
	#	toolAttackLight.visible=false
	#elif attackTypeIx == GLOBALS.SPECIAL_IX:
	#	lightToTurnOn=specialAttackLight
	#	meleeAttackLight.visible=false
	#	specialAttackLight.visible=true
	#	toolAttackLight.visible=false
	#elif attackTypeIx == GLOBALS.TOOL_IX:
	#	lightToTurnOn=toolAttackLight
	#	meleeAttackLight.visible=false
	#	specialAttackLight.visible=false
	#	toolAttackLight.visible=true
	#else:
		#no type to display
	#	pass 

	#if lightToTurnOn != null:
		#match the light to hitbox size
	#	lightToTurnOn.position = pos
	#	lightToTurnOn.scale.x=xScale
	#	lightToTurnOn.scale.y=yScale
	#	lightToTurnOn.rotation_degrees = angle
	
	
func _on_hit_freeze_started(duration):
	inHitFreeze = true
	
	pass
	
#stage connects this
func _on_hit_freeze_finished():
	
	 
	inHitFreeze = false
	meleeAttackLight.visible=false
	specialAttackLight.visible=false
	toolAttackLight.visible=false
	#had all 3 attack light types
	pass
	
	
	
func displayLocalTemporarySprites(tmpSprites):
	spriteSFXBuffer.clear()
	opponentSpriteSFXBuffer.clear()
	
	for tmpSprite in tmpSprites:
		#display on opponent?
		if tmpSprite.opponentIsParent:
			opponentSpriteSFXBuffer.append(tmpSprite)
		else:
			spriteSFXBuffer.append(tmpSprite)
		
	
	#display sprite on player
	if spriteSFXBuffer.size() >0:
		#spriteSFXNode.displayLocalTemporarySprites(spriteSFXBuffer,inHitFreeze)
		spriteSFXNode.displayLocalTemporarySprites(spriteSFXBuffer,inHitFreeze)
		
	
	#display sprite this player imposed onto opponent
	if opponentSpriteSFXBuffer.size() >0:
		#playerController.opponentPlayerController.kinbody.spriteSFXNode.displayLocalTemporarySprites(opponentSpriteSFXBuffer,inHitFreeze)
		playerController.opponentPlayerController.kinbody.spriteSFXNode.displayLocalTemporarySprites(opponentSpriteSFXBuffer,inHitFreeze)
	#if not spriteCurrentlyFacingRight:
	#	spawnPoint.x = spawnPoint.x * (-1)
	

func _on_combo_ended():
	comboMagicSeriesCount=0
	starArray.setNumberOfStars(comboMagicSeriesCount)
		
func _on_magic_series_or_reverse_beat(lvl):
	if lvl !=0:
		increaseMagicSeriesStarArray()
func increaseMagicSeriesStarArray():
	comboMagicSeriesCount=comboMagicSeriesCount+1
	starArray.setNumberOfStars(comboMagicSeriesCount)
	
	
func handleAbilityCancelParticles(barCost,autoAbilityCancelFlag):
	
	#only play following particles for greater version
	if barCost>playerController.BASIC_ABILITY_CANCEL_COST:
		
			
		var particles = null
		#var particlesToDuplicate = null
		
		
		if not autoAbilityCancelFlag:
			
			#particlesToDuplicate =kinbody.abilityCancelParticles
			particles=abilityCancelParticleBuffer.get_next_particle()
		else:
			#autoability cancel isn't a thing animatio
			pass
			#particlesToDuplicate = kinbody.autoAbilityCancelParticles
			
	
		#particles = particlesToDuplicate.duplicate()
		#particles.set_script(particlesToDuplicate.get_script())
		#kinbody.add_child(particles)
		#particles.emitting=true
		
		#set the number of particles based on cancel cost for manaual cancels
		if not autoAbilityCancelFlag:	
			var numParticles = barCost * 10
			
		
			if barCost> 12:
				numParticles = numParticles * 5
			elif barCost> 8:
				numParticles = numParticles * 4	
			elif barCost> 6:
				numParticles = numParticles * 2.5
			particles.amount=numParticles
		
		abilityCancelParticleBuffer.trigger()
		
	
	

	var swirls = abilityCancelSwrilSFXBuffer.get_next_particle()
	var explosion = abilityCancelExplosionSFXBuffer.get_next_particle()
	
	#var abilityCancelSwrilResource = preload("res://particles/abilityCancelSwirlParticles.tscn")
	#var abilityCancelExplosionResource = preload("res://particles/abilityCancelExplosionParticles.tscn")
	#var swirls = abilityCancelSwrilResource.instance()
	#var explosion = abilityCancelExplosionResource.instance()

	swirls.pauseOnHitFreeze=false
	explosion.pauseOnHitFreeze=false
	
	var playerCenter = getRelativeCenter()
	#player.add_child(swirls)
	#player.add_child(explosion)
	
	swirls.position = playerCenter
	#swirls.set_emitting(true)
	
	explosion.position = playerCenter
	#explosion.set_emitting(true)
	
	
		#no particles for lesser version of a cancel
	#lesser ability cancel (liek movement)?
	if barCost<=playerController.BASIC_ABILITY_CANCEL_COST:
		explosion.amount=8
		swirls.amount = 10
		
	abilityCancelSwrilSFXBuffer.trigger()
	abilityCancelExplosionSFXBuffer.trigger()
	
	#wait for partidles to finish before deleting (this is so we can create many and won't have to
	#wait for them to finish, since at time ability cancel won't emit if quickly ability cancling over an dover
	#if using one particle system
	#yield(particles,"finished_emitting")
	#print("deleting ability particles")
	#kinbody.remove_child(particles)
	#particles.queue_free()
	
		#kinbody.abilityCancelParticles.emitting=true