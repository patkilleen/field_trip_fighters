extends Node

signal guard_broken
signal proximity_guard_enabled
signal proximity_guard_disabled
signal perfect_block
signal guard_damage_taken
signal guard_regen_lock_changed

const RC_BLOCKING = 0
const RC_NOT_BLOCKING = 1
const RC_GUARD_BROKEN = 2
const RC_PERFECT_BLOCKING = 3
const RC_GRABBED_IN_BLOCK = 4

var actionAnimeManager=null
var guardHpRegenRate=null
var guardHpLossRate = null
var playerController= null
#var proximityGuardEnabled= false

var initialized = false

var currentHitboxBlockStunDuration = 0

const PROXIMITY_GUARD_DURATION = 4

const DEFAULT_GUARD_REGEN_BOOST_MOD = 1
var frameTimerResource = preload("res://frameTimer.gd")
var GLOBALS = preload("res://Globals.gd")

#changing this will globaly alter speed of animations
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

const BASE_GUARD_HOLD_BACK_REDUCE_MOD = 0.7
const PERFECT_BLOCK_TIME_WINDOW= 2.5 # 2.5 to avoid tiny errors of 2nd frame block but 0.0001 secodn makes it not cound
#holding back for more than 3 seconds will cap out the drain (otherwise, with limit, holding back indefinatly will have
#shiled brack from 1 hit, which isn't visually represented
const MAX_HOLD_BACK_TIME_REDUCTION_PENALTY = 3 
var timeHeldBackInSeconds = 0
var perfectBlockTimeHeldBackInSeconds = 0

var blockingDisabled = false
var holdingBackward = false
var holdingDown = false

var incorrectBlockDamageReductionEnabled = false
var incorrectBlockDamageReductionMod = 1
var loseGuardHPWhileWalkingBack = null

#var guardLockTimer = null

var regenGuardOnPerfectBlock=false
var profGuardRegenAmountOnPerfectBlock = 0 #amount to regain of guard when perfect block

var boostedRegenMod=null #the regen modifier that is used for guard regen boost
var currentBoostedRegenMod=DEFAULT_GUARD_REGEN_BOOST_MOD #the active regen boost mod  (1 by default)

var guardHpRegenRateQuotient = null
var trackingHoldBack = false
var perfectBlockTrackingHoldBack = false
#used for decrasing resource on budget block
const gettingHitInBlockDmgCapDecrease=[0,0.015,0.05,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0]
const gettingHitInBlockDmgAmountDecrease=[0,0.02,0.06,0.15,0.25,0.35,0.45,0.55,0.65,0.75,0.85,0.95,1.1]

var regeneratingBlock = true



var holdBackInputLocked =false #can't change state of holding direction when true


#var consecutiveBlockCount = 0
func _ready():
	#make sure if speed was specified elsewhere other than globals, that speed is up to date
	#var globalSpeedNodes = get_tree().get_nodes_in_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	#setGlobalSpeedMod(globalSpeedNodes[1].globalSpeedMod)
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	set_physics_process(false)
	

func setGlobalSpeedMod(g):
	globalSpeedMod = g

func reset():
	
	
	
		
	
	initialized = true
	
	
#	proximityGuardEnabled = false
	
	timeHeldBackInSeconds=0
	#guardLockTimer = frameTimerResource.new()
	
	
	
	
	#the modifier for how much guard regens when in a boosted regen state (e.g. 1.5, for 50% more guard regen in boosted state)


	
	timeHeldBackInSeconds = 0
	perfectBlockTimeHeldBackInSeconds = 0

	blockingDisabled = false
	holdingBackward = false
	holdingDown = false

	currentBoostedRegenMod=DEFAULT_GUARD_REGEN_BOOST_MOD #the active regen boost mod  (1 by default)

	trackingHoldBack = false
	perfectBlockTrackingHoldBack = false

	regeneratingBlock = true


	holdBackInputLocked =false #can't change state of holding direction when true

	set_physics_process(true)
	
func init(_playerController,_actionAnimeManager,_guardHpRegenRate,_guardHpLossRate,_loseGuardHPWhileWalkingBack, _boostedRegenMod):
	guardHpRegenRate =_guardHpRegenRate
	
	guardHpRegenRateQuotient = guardHpRegenRate/100.0
		
	guardHpLossRate = _guardHpLossRate
	initialized = true
	actionAnimeManager =_actionAnimeManager
	playerController =_playerController
#	proximityGuardEnabled = false
	loseGuardHPWhileWalkingBack =_loseGuardHPWhileWalkingBack
	timeHeldBackInSeconds=0
	#guardLockTimer = frameTimerResource.new()
	trackingHoldBack = false
	perfectBlockTrackingHoldBack = false
	holdingBackward = false
	
	#the modifier for how much guard regens when in a boosted regen state (e.g. 1.5, for 50% more guard regen in boosted state)
	boostedRegenMod = _boostedRegenMod
	blockingDisabled=false
	
	set_physics_process(true)
#checks for blocking opponent and applies damages to guard hp on block, signaling on guard broken,
#and returns true when sblocked and false when didn't block (caller should put player into block animation)
func processGuardHP(attackerHitbox):
	
	if not initialized:
		return null
		
		
	if attackerHitbox.isThrow and isBlocking():
		return RC_GRABBED_IN_BLOCK
		
	var guardBroken = false
	var blocking = false
	var guardDamage = 0
	var perfectBlockingFlag = false
	var guardDmgTakenMod = 0
	var opponentGuardDmgDealtMod=0
	var blockStatus = GLOBALS.BlockResult.NO_BLOCK
	if canHoldBackToBlock():
		blockStatus = blockedAttackStatus(attackerHitbox)
	
	#player attmpeting to block?
	if blockStatus != GLOBALS.BlockResult.NO_BLOCK:	
	#if holdingBackward:
		blocking=true
		
		#if not isPerfectBlock(attackerHitbox.low):
		if blockStatus == GLOBALS.BlockResult.PERFECT:
			
			#regain guard on perfect block?
			if regenGuardOnPerfectBlock:
				playerController.playerState.guardHP = playerController.playerState.guardHP +profGuardRegenAmountOnPerfectBlock
			

			#print("perfect block")
			emit_signal("perfect_block")
			#perfect block takes no damage so return immediatly
			return RC_PERFECT_BLOCKING
		elif blockStatus == GLOBALS.BlockResult.CORRECT:
			guardDamage=attackerHitbox.guardHPDamage
			guardDmgTakenMod=playerController.correctBlockGuardDamageTakenMod
			opponentGuardDmgDealtMod=playerController.opponentPlayerController.correctBlockGuardDamageDealtMod
				
			
		elif blockStatus == GLOBALS.BlockResult.INCORRECT:
			guardDamage=attackerHitbox.incorrectBlockGuardHPDamage
			guardDmgTakenMod=playerController.incorrectBlockGuardDamageTakenMod
			opponentGuardDmgDealtMod=playerController.opponentPlayerController.incorrectBlockGuardDamageDealtMod
			#reduce the guard damage on incorrect block?
			if playerController.opponentPlayerController.guardHandler.incorrectBlockDamageReductionEnabled:
				opponentGuardDmgDealtMod = opponentGuardDmgDealtMod + playerController.opponentPlayerController.guardHandler.incorrectBlockDamageReductionMod
		else:
			print("unknown block status: "+str(blockStatus)+", can't process guard damage")
			return
			
		#modifier to guard hp based on attack and guard type
		var guardDmgMod = 1
		
		#in the air?
		if not playerController.my_is_on_floor():
			
	#		var airDmgMod = 1 + playerController.opponentPlayerController.airBlockGuardDamageDealtMod+playerController.airBlockGuardDamageTakenMod
			
			#guardDmgMod=playerController.defaultGuardDamageDealtModVsAirOpponent #x more damage against guard in air
			
			#only add the default air damage mod once, 
			guardDmgTakenMod=guardDmgTakenMod+playerController.airBlockGuardDamageTakenMod+playerController.defaultGuardDamageDealtModVsAirOpponent
			opponentGuardDmgDealtMod=opponentGuardDmgDealtMod+playerController.opponentPlayerController.airBlockGuardDamageDealtMod
			
			
			
		if attackerHitbox.guardDamageClass == GLOBALS.GUARD_DAMAGE_CLASS_AVERAGE:
			#BASE guard damage 80% for average attack
			guardDmgMod = guardDmgMod * 0.8
		elif attackerHitbox.guardDamageClass == GLOBALS.GUARD_DAMAGE_CLASS_LOW:
			#BASE guard damage 65% for low guard dmg attack
			guardDmgMod = guardDmgMod * 0.65
		elif attackerHitbox.guardDamageClass == GLOBALS.GUARD_DAMAGE_CLASS_HEAVY:
			#BASE guard damage 100% for shield buster attack
			guardDmgMod = guardDmgMod * 1.0
		
		
		var effectiveMod = 1 + guardDmgTakenMod  + opponentGuardDmgDealtMod
		
		#compute effeictve damage (if opponent deals 20% damage to guard, and we resiste it by 30%, then is -10% to dmage , e.e * 0.9)
		guardDmgMod =  guardDmgMod * effectiveMod


		guardDamage=guardDmgMod * guardDamage # modifier of dmage based on proficiency too
		
		#applying the damage break guard?
		if playerController.playerState.guardHP -guardDamage <=0:
			guardBroken = true	
		
		emit_signal("guard_damage_taken",guardDamage)
		#applpy damage to guard
		playerController.playerState.guardHP =  playerController.playerState.guardHP -guardDamage
		

	if guardBroken:
		
		return RC_GUARD_BROKEN
	elif blocking:
		
		return RC_BLOCKING
	else:
		return RC_NOT_BLOCKING
	
func _on_guardHP_changed(oldGuardHP, newGuardHP):
	
	if not initialized:
		return
		
	if newGuardHP == 0:
		
		
		var amountOfGuardRegened=playerController.playerState.maxGuardHP*0.75
		emit_signal("guard_broken",not isBlockingLow(),amountOfGuardRegened)#emit flag for true when high block, and false low block	
		
		handleGuardBreakDmgDecrease()
		
		#give back 75% of guard hp back to victim
		playerController.playerState.guardHP=amountOfGuardRegened
		
	
func isBlocking():
	if not initialized:
		return null
		
	if blockingDisabled:
		return false
		
	if holdingBackward:
		
		if canHoldBackToBlock():
			return true
				
	return false
	

#returns true if current animation supports holdback-block hurtboxes
#and fals otherwise
func canHoldBackToBlock():
	if not initialized:
		return null
		
		
	var spriAnime = actionAnimeManager.getCurrentSpriteAnimation()
	if spriAnime !=null:
		
		var sf = spriAnime.getCurrentSpriteFrame()
		
		#has a hurtbox that on hit can block by holding back?
		if sf != null and sf.hasHoldBackToBlockHurtboxes():
			
			return true
			
	return false
				

#delta is tiem passed since last frame
func _physics_process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	if not initialized:
		return

	delta = delta *globalSpeedMod
	
	if trackingHoldBack:
		#count the tiem holding back	
		timeHeldBackInSeconds= timeHeldBackInSeconds+delta

	
	if perfectBlockTrackingHoldBack:
		
		#only count the time held back if the input isn't locked
		if not holdBackInputLocked:
			perfectBlockTimeHeldBackInSeconds=perfectBlockTimeHeldBackInSeconds+delta

	
	var _regenBlock = false
	
	#we can only regen on the ground (unless proficient)
	if playerController.my_is_on_floor() or playerController.regenGuardInAir:
		#DEBUG flag that indicates only lose guard hp when walking back as opposed to only in blockstun/blocking from proximity guard (both same aniamtions ATM)
		if not loseGuardHPWhileWalkingBack:
			#only lose guard hp when in block animation (block hitlag or proximity block, not holding back walking/in air, or crouching)
			if isInHoldBackBlockAnimation():
				_regenBlock=false
			else:
				_regenBlock = true
		else:
			#only regenerate if not holding back (clearly dispaly that timing block is important)
			#, you
			#if not playerController.holdingBackward:
			if not holdingBackward:
				_regenBlock=true
				
			#may be case in animation that block isn't possible, so holding back doesn't affect regen
			elif not canHoldBackToBlock():
				_regenBlock=true
			#may be case we blocking
			elif isBlocking():
				_regenBlock=false		
	else:
		
		#regen shield when in hitstun and air (punishes attacker for being in air too long
		#since can't regen shield in air in neutral)
		if not playerController.playerState.inHitStun:
			_regenBlock=false		
		else:
			_regenBlock=true
			
	if _regenBlock:
		#var amountToRegen = max(0,playerController.playerState.maxGuardHP*(guardHpRegenRate/100.0)*delta) #can't loose guard hp if calculate buggy
		var amountToRegen = max(0,currentBoostedRegenMod*playerController.playerState.maxGuardHP*guardHpRegenRateQuotient*delta) #can't loose guard hp if calculate buggy
		playerController.playerState.guardHP = playerController.playerState.guardHP +amountToRegen
	
	
	#block regeneration changed?
	if regeneratingBlock != _regenBlock:
		regeneratingBlock=_regenBlock
		emit_signal("guard_regen_lock_changed",regeneratingBlock)
	
	
	#else:
		
		#we lose guard resource when holding back in block, in addition to the damage from being hit
	#	if timeHeldBackInSeconds>0:
			#reduction on block
			#loos guard hp
	#		var amountToLoss = playerController.playerState.maxGuardHP*(guardHpLossRate/100.0)*delta
			#amount loosing increase as yo hold back
	#		amountToLoss =  amountToLoss* (BASE_GUARD_HOLD_BACK_REDUCE_MOD +1.1*min(MAX_HOLD_BACK_TIME_REDUCTION_PENALTY,timeHeldBackInSeconds))
	#		playerController.playerState.guardHP = playerController.playerState.guardHP -amountToLoss
	
#func isInLowBlockAnimation():
#	if not initialized:
#		return null
		
	#can't block in guard lock after guard break
	#if playerController.playerState.guardLock:
	#	return false
		
	#uncrouch isn't considered low block, since wasn't holding down to keep crouch animation goind
#	var crouchingBackFlag = actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_CROUCHING_HOLD_BACK_BLOCK_ACTION_ID)
#	var inCrouchBudgetBlockHitLag = actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.CROUCHING_BUDGET_BLOCK_HIT_LAG_ACTION_ID)
	
	#low block?
#	return inCrouchBudgetBlockHitLag or crouchingBackFlag
	

	
func isInLowBlockStunAnimation():
#	if not initialized:
#		return null
		
	#can't block in guard lock after guard break
	#if playerController.playerState.guardLock:
	#	return false
		
	#uncrouch isn't considered low block, since wasn't holding down to keep crouch animation goind
#	var crouchingBackFlag = actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_CROUCHING_HOLD_BACK_BLOCK_ACTION_ID)
	return actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.CROUCHING_BUDGET_BLOCK_HIT_LAG_ACTION_ID)
	
	#low block?
#	return inCrouchBudgetBlockHitLag or crouchingBackFlag
func isBlockingLow():
	if not initialized:
		return null
	
	if playerController.canLowBlowInAir:
		#allow low blocking in air
		return holdingDown and holdingBackward and canHoldBackToBlock()
	else:
		#only low block by holding diagonal down back and is on floor
		return holdingDown and holdingBackward and playerController.my_is_on_floor() and canHoldBackToBlock()

func _on_sprite_frame_activated(sf):
	if not initialized:
		return

	#frame changed to a frame we can block, and we were holding back but not in a block aniamtion?
	
	if(holdingBackward and (not trackingHoldBack) and (sf != null) and (sf.hasHoldBackToBlockHurtboxes())):
		
		#were we not tracking hold back time, and now can block, so track it
		startTrackingHoldBackDuration()
		
	
	elif  holdingBackward and trackingHoldBack and sf != null and not sf.hasHoldBackToBlockHurtboxes():
		#we were in block aniamtion, but no longer, even if holding back, so stop
		stopTrackingHoldBackDuration()
		
	#as long as 

#func _on_holding_down():
#	holdingDown=true
	
#func _on_not_holding_down():
#	holdingDown=false
	
#func _on_not_holding_back():
#	holdingBackward=false
	
		
#func _on_holding_back():
#	holdingBackward=true
	
func _on_pressed_back():

	if not initialized:
		return
	
	holdingBackward = true

	startTrackingPerfectBlockHoldBackDuration()
	if not trackingHoldBack:
		#only start the timer if we in animation that can block
		if canHoldBackToBlock():
			startTrackingHoldBackDuration()
	pass

func _on_released_back():
	if not initialized:
		return
		
	holdingBackward = false

	stopTrackingPerfectBlockHoldBackDuration()
	timeHeldBackInSeconds=0
	if trackingHoldBack:
		stopTrackingHoldBackDuration()
	pass
	
	

func startTrackingHoldBackDuration():
	if not initialized:
		return
		
	
	trackingHoldBack = true
	timeHeldBackInSeconds=0
		

func startTrackingPerfectBlockHoldBackDuration():
	perfectBlockTrackingHoldBack = true
	perfectBlockTimeHeldBackInSeconds=0
	
func stopTrackingHoldBackDuration():
	if not initialized:
		return
	
	trackingHoldBack=false
	timeHeldBackInSeconds=0

func stopTrackingPerfectBlockHoldBackDuration():
	perfectBlockTrackingHoldBack = false
	


func isInBlockHitstun():
	
 return actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.CROUCHING_BUDGET_BLOCK_HIT_LAG_ACTION_ID) or actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.BUDGET_BLOCK_HIT_LAG_ACTION_ID)

#returns true if hold back proximity blocking or in block stun
func isInHoldBackBlockAnimation():
	if not initialized:
		return false
	if actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.CROUCHING_BUDGET_BLOCK_HIT_LAG_ACTION_ID):
		return true
		
	if actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.BUDGET_BLOCK_HIT_LAG_ACTION_ID):
		return true
	
	if actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_STANDING_HOLD_BACK_BLOCK_ACTION_ID):
		return true
	
	if actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_AIR_HOLD_BACK_BLOCK_ACTION_ID):
		return true
	
	if actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.PROXIMITY_GUARD_CROUCHING_HOLD_BACK_BLOCK_ACTION_ID):
		return true
	
	if playerController.isInPushBlockingAnimation():
		return true
	#if actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.GROUND_PUSH_BLOCKING_ACTION_ID):
	#	return true
	
	#if actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.AIR_PUSH_BLOCKING_ACTION_ID):
	#	return true
		
	return false
	



func fetchElement(arr,ix):
			
	if ix >= arr.size():
		ix = arr.size()-1
		
	if ix < 0:
		return null
		
	return arr[ix]


#called when go into block hit stun
func handleBudgetBlockDmgDecrease(blockHitStunDuration,guardHPDamage):
	
	pass

func handleGuardBreakDmgDecrease():
	#reduce damage bars by 60% (40% remaining)
	playerController.playerState.damageGauge = max (playerController.playerState.damageGauge*0.4,playerController.playerState.damageGaugeMinimum)
	playerController.playerState.damageGaugeCapacity = max (playerController.playerState.damageGaugeCapacity*0.4 ,playerController.playerState.damageGaugeMinimum)
	

func _on_hitting_player(selfHitboxArea, otherHurtboxArea):
	#we attacked player, so reset the consecutive blocks counter to reset the dmg decrease from block
	#consecutiveBlockCount = 0
	pass

#returns true if we have only held back very briefly to enable a perfect block
func canPerfectBlock():
	
	#if we held block the frame, or 1 frame before getting hit, then it's a perfect block ()
	#1.8 is to represent fact that may have variation in time between frames, so this should be general enoug
	#to catch a sligh lag
	return holdingBackward and perfectBlockTimeHeldBackInSeconds <=PERFECT_BLOCK_TIME_WINDOW*GLOBALS.SECONDS_PER_FRAME

#
func blockedAttackStatus(attackerHitbox):
	
	if blockingDisabled:
		return  GLOBALS.BlockResult.NO_BLOCK
		
	#player attmpeting to block?
	if holdingBackward:
	
		#can't block ground move while in air?
		if playerController.preventBlockingGroundAttacksWhileAirborne:
			#make sure it's not a projectile. you can block those in air
			if not attackerHitbox.is_projectile:
				#were in air and opponent on ground?
				 if playerController.opponentPlayerController.my_is_on_floor() and not playerController.my_is_on_floor():
						return  GLOBALS.BlockResult.NO_BLOCK
			
		var canPerfectBlockFlag = canPerfectBlock()
		#if not isPerfectBlock():
		
		#is opponent blocking low?
		#if isInLowBlockAnimation():
		if isBlockingLow():
			
			#are we atacking low?
			if attackerHitbox.low:
				
				#did we perfect low block?
				if canPerfectBlockFlag:
					return  GLOBALS.BlockResult.PERFECT
				else:
					return  GLOBALS.BlockResult.CORRECT
			else:
				
				#do we consider an incorrect block as a hit?
				if playerController.preventIncorrectBlocking:
					#display a bad block over-head symbole
					playerController.kinbody.displayLocalTemporarySprites(playerController.kinbody.badBlockSpriteSFXs)
					return  GLOBALS.BlockResult.NO_BLOCK
				else:
					return  GLOBALS.BlockResult.INCORRECT

		else:
			#blocking high
			
			
			#are we atacking low?
			if attackerHitbox.low:
				#fail to block a low with a standing block
				
				#do we consider an incorrect block as a hit?
				if playerController.preventIncorrectBlocking:
					#display a bad block over-head symbole
					playerController.kinbody.displayLocalTemporarySprites(playerController.kinbody.badBlockSpriteSFXs)
					return  GLOBALS.BlockResult.NO_BLOCK
				else:
					return  GLOBALS.BlockResult.INCORRECT
			else:
				
				#did we perfect standing block?
				if canPerfectBlockFlag:
					return  GLOBALS.BlockResult.PERFECT
				else:
					return  GLOBALS.BlockResult.CORRECT
	#	else:
				
	#		return  GLOBALS.BlockResult.PERFECT
	
	
	return  GLOBALS.BlockResult.NO_BLOCK




	
func _on_directional_input(diEnum):
	
	if holdBackInputLocked:
		return
		
	var wasHoldingDown = holdingDown
	
	#track whether we are holding down
	match(diEnum):
		GLOBALS.DirectionalInput.BACKWARD_DOWN:
			holdingDown=true
		GLOBALS.DirectionalInput.DOWN:
			holdingDown=true
		GLOBALS.DirectionalInput.FORWARD_DOWN:
			holdingDown=true
		_:
			holdingDown=false
#	
	var wasHoldingBack = holdingBackward
	#track whether we are holding back
	match(diEnum):
		GLOBALS.DirectionalInput.BACKWARD_DOWN:
			holdingBackward=true
		GLOBALS.DirectionalInput.BACKWARD:
			holdingBackward=true
		GLOBALS.DirectionalInput.BACKWARD_UP:
			holdingBackward=true
		_:
			holdingBackward=false
	
	
	#released holding back?
	if wasHoldingBack and not holdingBackward:
		_on_released_back()
		
	#started pressing back
	elif not wasHoldingBack and holdingBackward:
		_on_pressed_back()
		

		
func _on_hit_freeze_finished():

	holdBackInputLocked=false
	
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	holdBackInputLocked=true



func _on_guard_regen_boost_change(flag):
	
	#enabled guard renen boost?
	if flag:
		#set the active boost to guard regen to the increased amount
		currentBoostedRegenMod=boostedRegenMod
	else:
		#stop the boost
		currentBoostedRegenMod=DEFAULT_GUARD_REGEN_BOOST_MOD

		pass