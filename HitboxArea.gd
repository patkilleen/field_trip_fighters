extends "SpriteCollisionArea.gd"

var GLOBALS = preload("res://Globals.gd")
const BEHAVIOR_BASIC = 0
const BEHAVIOR_MULTI_HIT = 1 #will hit multiple time even where already hit, but need to be seperated by non-activate frames to hit again
const BEHAVIOR_PROXIMITY_GUARD = 2
const BEHAVIOR_TRUE_MULTI_HIT = 3 #concesutive active true multi hit frames will hit regardless of its they already hit

const CLASH_TYPE_HIT_PRIORITY = 0 #only clashes when hitbox-hitbox collision occur without hurtobxes invovled
const CLASH_TYPE_CLASH_PRIORITY = 1 #clashes (hitbox-hitbox collision) override hurtbox collision
const CLASH_TYPE_TRANS = 2#doesn't clash
#const CLASH_TYPE_POWER = 3#doesn't provoke stun from clash break
#const CLASH_TYPE_TRADER = 4 #doesn't disable the hurtbox/hitbox collisions involving hitbox that clashed
#const CLASH_TYPE_POWER_TRADER = 5 #doesn't disable the hurtbox/hitbox collisions involving hitbox that clashed and don't stun on clash break

#same definitionas as in globals
const HITSTUN_DURATION_TYPE_BASIC = 0
const HITSTUN_DURATION_TYPE_ADD = 1
const HITSTUN_DURATION_TYPE_MEATY = 2
#const HITSTUN_DURATION_TYPE_MEATY_ADD = 3


export (int, "Basic","Multi-hit","Proximity-guard","True Multi-hit") var behavior = 0 #im not sure if proximity gurd is needed
export (int, "Hit-priority","Clash-priority","Transendant") var clashType = 0
export (int, "Basic","No-hitsun","Knock-back Only","Protection","On-link Only","On-link Only and No-hitstun") var hitstunType = 0
export (int, "Basic","Add","Meaty") var hitstunDurationType = 0
export (int, "Basic","Add","Meaty") var blockStunDurationType = 0 #same indices as HITSTUN_DURATION_TYPE_x
export (float) var damage = 0
#1 is for 100% of damage is regenerated as ability bar
export (float) var abilityRegenMod = 1
export (bool) var ripostabled = true
export (bool) var onHitAutoCancelable = true
export (int) var duration = 60  #NOTE THAT THERE IS APPARANTLY A 4 FRAME INUT LAG OR lag betwene animation transitions, so need to add 4 more frames. So if duration is 12, and animation is +5, the +5 is actually +1, so need add $( need make it 17 )
export (int) var durationOnLink = -1  #-1 means no difference in hitstun duration for a link combo. > -1 means this duratin is used instead of 'duration' when hiting opponent already in htistun
export (float) var abilityGainMod = 0
export (float) var hpGainMod = 0
export (int) var on_hit_action_id = -1
export (int) var on_link_hit_action_id = -1 #action id to play when linking a combo. Overrides on_hit_action_id if comboing. Ingored if starting a combo with this move
export (int) var on_hit_starting_sprite_frame_ix = 0 #for hitboxes that play an animation on hit, this is the sprite frame that starts (can skip frames if ix more than 0)
export (bool) var preventOnHitActionWhenOnGround=false#true means on hit action id played only when on floor 
export (bool) var preventOnHitActionWhenInAir=false#true means on hit action id played only when in air 
#export (int) var debug_on_hit_action_id = -1
export (int) var hitFreezeDuration = 8
export (bool) var is_projectile = false

export (int) var hitStunLandingType = 0 #this is of type GLOBALS.LANDINGTYPE
export (int) var minDurationBeforeFallProne = 0
export (bool) var stopHitMomentumOnLand = true
export (bool) var isThrow = false
export (bool) var affectsHitstunProration = true
export (bool) var affectsDmgStarFill = true#TODO: rename this to affects bar increase, since the dmg proratio not implemented and this flag used to indicate if dmg/foucs increase on hit 
export (bool) var affectsMoveSpamHistunProratrion = true #false means won't affect the spamming of move proration (useful for multi hits)
export (float) var histunProratrion = 1.0 #counts as 1 hit to hitstun duration by default (0 will be same as affecthitstunproration flag false)
export (int,0,100) var spamHistunProration = 0 #additional spam proration when spamming a move (useful to break single button infitinites without chanign hitstun)
export (float) var dmgProratrion = 1.0 #0 MEANS no damage proration. otheriwse  proration applied normally based on damage
export (int, "Light","Medium","Heavy") var dmgProrationClass = 0 #same indices as GLOBALS.GUARD_DAMAGE_CLASS_DMG_MOD_x
export (float) var abilityFeedProrationMod = 1.0 #counts as 1 hit to ability feed proration duration by default (high # means increase proration from hit faster)
export (int) var blockStunDuration = 15 # number of frames budget block goes into hit lag
export (int) var incorrectBlockStunDuration = 0 # number of frames block goes into hit lag when incorrectly blocked (e.g., low attack hits standing block)
export (int) var airBlockStunLandingRecoveryDuration = 10 # number of frames the block stun will continue for if landing in block stun
export (float) var guardHPDamage = 35 # amount of damage t apply to guard on hit
export (float) var incorrectBlockGuardHPDamage = 35
export (float) var blockChipDamageMod = 0.1 # modifier (0,1) indicating hw much chip damage is done (% of total damage)
export (bool) var low = false # true means percies trhough standing blow, false means its a high/overhead which eats away at low blocking oppoent's guard hp
export (bool) var canHitActiveFrame = true # true means can hit an opponent in an active frame, false means the collision ignored
export (bool) var canHitStartupFrame = true # true means can hit an opponent in an startup frame, false means the collision ignored
export (bool) var canHitGroundedTarget = true #false means can't hit target on ground, true means can hit if target on ground
export (bool) var canHitAirborneTarget = true #false means can't hit target on ground, true means can hit if target on ground
export (bool) var hitstunAngleMatchesAttackerMomentum = false #true means angle of dynamicAngle = trrue basic moemvent of hitstun momentum will be the attacker's direction momentum
export (bool) var blockstunAngleMatchesAttackerMomentum = false #true means angle of dynamicAngle = trrue basic moemvent of blockstun momentum will be the attacker's direction momentum
export (bool) var removesEmptyStar = true #true when will decrease empty star count, and false when leaves empty stars untouched
export (int, FLAGS, "Walls","Floor","Ceiling") var techExceptions = 0 #indicates what can't be teched after getting hit by this hitbox. nothing selected means can tech at anytime
export (bool) var emitsAttackSFXSignal = true #true means the attack has visual effect, false means no sfx
export (bool) var playSoundSFX = true #true means the attack will have audio  on hit, false means silent
export (bool) var stopMomentumOnPushOpponent = false #true means if push an opponent while in hitstun, momentum is stopped (geneally will apply to wall bounce attacks)
export (bool) var stopMomentumOnOpponentAnimationPlay=false #true means canceling the animation that hit opponent stops them (good fro grabs)
export (bool) var ignoreComboTracking = false #false means hitting with this counts as a hit for combo length, proration, etc,. true means ignored (animations that require on hit to animate, with 0 damage dummy hitbox)
export (bool) var countsAsBlockString = true #true means triggers a block string signal, false ignores signal 
export (int, "Average","Low","Heavy") var guardDamageClass = 0 #same indices as GLOBALS.GUARD_DAMAGE_CLASS_DMG_MOD_x
export (bool) var pushesBackOnHitInCorner = true # when true, hitting an opponent in the corner will push attacker away, false means no push away
export (int) var clashRecoveryDuration = 5 #in frames. amount of time you go into rebound from a clash
export (int) var falseCelingLockDuration = -1 # <0 means no locking false celiling. 0 means lock until hitstun end or hit by other attack. > 0 means false ceiling will be locked for next X frames
export (int) var falseWallLockDuration = -1 # <0 means no locking false celiling. 0 means lock until hitstun end or hit by other attack. > 0 means false ceiling will be locked for next X frames
export (int) var newHitstunDurationOnLand=-1 #-1 means no change to hitstun on land. any thing else means on land, new hitstun occurs (good for bounces)
export (bool) var disableBodyBox = false #the opponent's body box will be disabled for duration of histgun when true
export (bool) var preventsAnimationStaleness = false #true when a hitbox overrides the default behavior of a special type of animation from going stale (typically sour vs sweet spot)
export (bool) var mvmStpOnOppAutoAbilityCancel = false #movment stop on opponent auto ability cancel when true . 
export (bool) var unblockable = false #true means can't block this hitbox
export (bool) var incorrectBlockUnblockable = false #true means can't block this hitbox if block incorrectly
export (bool) var preventBlockSetKnockBackDuration = false #false is default, where knockback on block will always be duration of shorten block stun duration (incorrect vs correct). True means the incroorect block can have different duration that correct
export (float,0,1) var shakeIntensity = 0 #how much opponent shakes when you hit them using default shake values
export (float) var shakeTrauma=-1 #-1 means use default, >= 0 means override default
export (float) var shakeDecay=-1 #-1 means use default, >= 0 means override default
export (Vector2) var shakeMaxOffset=Vector2(-1,-1) #-1 means use default, >= 0 means override default
export (float) var shakePower=-1 #-1 means use default, >= 0 means override default
export (float) var shakeDuration=-1 #-1 means use default, which is when hitfreeze ends, >= 0 means custom duration
export (bool) var ignoreProjectileCollisions = false #true means projectile hurtbox collision ignored for this hitbox
export (bool) var hitsWakeupOpponent=false #false means can't hit opponent in oki, true means can (OTG)
export (bool) var hideHitstunSprite=false #true means the sprite of victim while in hitstun fro mthis hitbox disapears

var hitstunMovementAnimation = null
var blockstunMovementAnimation = null
var hitstunLinkMovementAnimation=null
var cornerHitPushAwayMovementAnimation = null
var blockCornerHitPushAwayMovementAnimation = null
var attackerOnBlockedMovementAnimation = null
var specialBounceMvmAnimations = null

var projectileInstancer = null
#this is used to store the sprite animation that was used to create this projectil
var projectileParentSpriteAnimation = null setget setProjectileParentSpriteAnimation,getProjectileParentSpriteAnimation

var tmpLocalSFXSprites = []
var tmpGlobalSFXSprites = []

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	#go find hitstun knock back if exists
	for c in self.get_children():

		#var script = c.get_script()
		#if script != null:
		#	var scriptName = script.get_path().get_file()
		#	#found movement node?
		#	if scriptName == "movementAnimation.gd":
		#			hitstunMovementAnimation = c
		#movement aniamtion?
		if c is preload("res://movementAnimation.gd"):
			
			#movement to apply on hit?
			if c.knockbackType == c.KnockbackType.HITSTUN:
				if hitstunMovementAnimation !=null:
					print("warning, hitbox "+str(self.get_path())+" has duplicate hitstun knockback mvm animations, ignroing duplicates")
				else:
					hitstunMovementAnimation=c

			#movement to apply on hit?
			elif c.knockbackType == c.KnockbackType.BLOCKSTUN:
				if blockstunMovementAnimation !=null:
					print("warning, hitbox "+str(self.get_path())+" has duplicate blockstun knockback mvm animations, ignroing duplicates")
				else:
					blockstunMovementAnimation=c
			#movement to apply to attacker  on block?
			elif c.knockbackType == c.KnockbackType.ATTACKER_ON_BLOCKED:
				if attackerOnBlockedMovementAnimation !=null:
					print("warning, hitbox "+str(self.get_path())+" has duplicate attacker on block mvm animations, ignroing duplicates")
				else:
					attackerOnBlockedMovementAnimation=c		
			
			#movement to apply if already in hitstun, iei, a combo/link, where the histun knockbak is overridden
			elif c.knockbackType == c.KnockbackType.HITSTUN_LINK:
				if hitstunLinkMovementAnimation !=null:
					print("warning, hitbox "+str(self.get_path())+" has duplicate hitstun-link knockback mvm animations, ignroing duplicates")
				else:
					hitstunLinkMovementAnimation=c
			#MOVEMENT to apply to attacker if were pressuring and hitting someone in corner
			elif c.knockbackType == c.KnockbackType.CORNER_HIT_PUSH_BACK:
				if cornerHitPushAwayMovementAnimation !=null:
					print("warning, hitbox "+str(self.get_path())+" has duplicate cornerHitPushAway mvm animations, ignroing duplicates")
				else:
					cornerHitPushAwayMovementAnimation=c		
			#MOVEMENT to apply to attacker if were pressuring and hitting someone in corner and they are blocking
			elif c.knockbackType == c.KnockbackType.CORNER_BLOCK_HIT_PUSH_BACK:
				if blockCornerHitPushAwayMovementAnimation !=null:
					print("warning, hitbox "+str(self.get_path())+" has duplicate blockcornerHitPushAway mvm animations, ignroing duplicates")
				else:
					blockCornerHitPushAwayMovementAnimation=c		
			
		elif c is preload("res://spriteFrameTempSFXSprites.gd"):
			
			#sprite the will be local to player (child of player)
			if c.local_coords:
				#populate the sfx of the sprite
				for tmpSprite in c.get_children():
					tmpLocalSFXSprites.append(tmpSprite)
			else:# global coordinates that will be children of stage
				#populate the sfx of the sprite
				for tmpSprite in c.get_children():
					tmpGlobalSFXSprites.append(tmpSprite)
		elif c is preload("res://specialBounceMvmAnimations.gd"):
			specialBounceMvmAnimations=c		
		elif c is preload("res://projectiles/projectileInstancer.gd"):
			projectileInstancer= c
			projectileInstancer.connect("create_projectile",self, "_on_hit_create_projectile")
			

func init(playerController,spriteAnimation):
	if projectileInstancer!= null:
		projectileInstancer.init(playerController,spriteAnimation)	
func adjustOnHitSFXSpriteOffsets(sprite_offset):
	
	for s in tmpLocalSFXSprites:
		s.position = s.position +sprite_offset
		
	for s in tmpGlobalSFXSprites:
		s.position = s.position +sprite_offset
		
func setProjectileParentSpriteAnimation(_a):
	projectileParentSpriteAnimation = _a
	
func getProjectileParentSpriteAnimation():
	return projectileParentSpriteAnimation
	
func canFillDamageStar():
	
	#already filled a dmg star this animation?
	if spriteAnimation.filledStar:
		return false
	
	return affectsDmgStarFill
	
func getParentKinbody():
		
	if is_projectile:
		return projectileController.kinbody
	else:
		return playerController.kinbody
		
		
func adjustBlockStunKnockbackDynamicAngle():
	if blockstunMovementAnimation != null:
		_adjustKnockbackDynamicAngle(blockstunMovementAnimation)
	
func adjustHitStunKnockbackDynamicAngle():
	if hitstunMovementAnimation != null:
		_adjustKnockbackDynamicAngle(hitstunMovementAnimation)
	if hitstunLinkMovementAnimation != null:
		_adjustKnockbackDynamicAngle(hitstunLinkMovementAnimation)
	
func _adjustKnockbackDynamicAngle(mvmAnimation):
	
	var hittingMovementAnimationManager = null
	#chose the controller depending on if projectile or not
	
	if is_projectile:
		hittingMovementAnimationManager = projectileController.getMovementAnimationManager()
	else:
		hittingMovementAnimationManager = playerController.getMovementAnimationManager()
		
	var lastFrameAttackerVelocity = hittingMovementAnimationManager.lastRelativeVelocity	
	var angle = rad2deg(lastFrameAttackerVelocity.angle())
	mvmAnimation.applyDynamicAngle(angle)
	
	
func dispalyOnHitSFXSprites():
	var kinbody = getParentKinbody()
	#kinbody.spriteSFXNode.displayLocalTemporarySprites(tmpLocalSFXSprites)
	kinbody.displayLocalTemporarySprites(tmpLocalSFXSprites)
	if spriteAnimation != null and spriteAnimation.spriteAnimationManager != null:
		spriteAnimation.spriteAnimationManager.emit_signal("display_global_temporary_sprites",tmpGlobalSFXSprites)
	
	
func _on_hit_create_projectile(projectileInstance,spawnPoint):
			
	spriteFrame.emit_signal("create_projectile",projectileInstance,spawnPoint)