extends Node

signal focus_changed
signal focus_next_hit_changed
signal focus_capacity_changed
signal focus_reached_capacity
signal focus_generation_combo_count_changed
signal start_focus_generation_tracking
signal hp_changed
signal damage_gauge_next_hit_changed
signal damage_gauge_changed
signal damage_gauge_capacity_changed
signal damage_gauge_reached_capacity
signal damage_gauge_generation_combo_count_changed
signal start_damage_gauge_generation_tracking
signal ability_bar_changed
signal combo_level_changed
signal sub_combo_level_changed
signal focus_combo_level_changed
signal focus_sub_combo_level_changed
signal block_cooldown_changed
signal grab_cooldown_changed
signal combo_changed
signal max_combo_changed
signal changed_combo_damage
signal changed_in_hitstun
signal insufficient_ability_bar
signal block_efficiency_changed
signal comboLevelDamageScaleChanged
signal damageScaleChanged
signal abilityRegenScaleChanged
signal comboLevelAbilityRegenScaleChanged
signal guardHP_changed
signal guard_lock_changed
signal num_filled_dmg_stars_changed
signal num_empty_dmg_stars_changed
signal fill_combo_sub_level_changed
signal negative_level_changed
signal abilit_bar_gain_lock_changed
signal guard_regen_buff_flag_changed
signal max_combo_damage_changed 
export var inHitStun = false setget setInHitStun,getInHitStun


var GLOBALS =preload("res://Globals.gd")
#attributes that will have their values overwritten by kinematicbody2d (abstract player parent script) module before game start
var hp = 3000.0 setget setHP, getHP
var abilityBarMaximum = 500.0 setget setAbilityBarMaximum,getAbilityBarMaximum
var abilityBar = abilityBarMaximum setget setAbilityBar,getAbilityBar
var abilityNumberOfChunks = 5 setget setAbilityNumberOfChunks,getAbilityNumberOfChunks
var profAbilityBarCostMod = 0 # i think this is set by root
var baseAbilityCancelCost = 0
var numJumps = 2
var hasAirDashe = true
var recoveredAirDashFromHit=false
var recoveredAbilityCancelAirDash=false #inidcates if since last touched group, we got air dash back from ability cancel
var currentNumJumps = numJumps setget setCurrentNumberOfJumps, getCurrentNumberOfJumps
var numAcroABCancelExtraJumps=0
var maxDamageGauge = 5
var maxFocus = 5
#end

var matchSecondsEllapsed=0 setget setMatchSecondsEllapsed,getMatchSecondsEllapsed

var playerPaused = false
var wasInAir = true
var wasOnPlatform = false
var blocked = false

var numSuccesfulAutoRiposts = 0
var comboLevel = 0 setget setComboLevel,getComboLevel
var focusComboLevel = 0 setget setFocusComboLevel,getFocusComboLevel
var maxComboLevelAchieved = 0
var maxFocusComboLevelAchieved = 0
var subComboLevel  = 0 setget setSubComboLevel,getSubComboLevel
var focusSubComboLevel  = 0 setget setFocusSubComboLevel,getFocusSubComboLevel
var defaultDamageGauge = GLOBALS.DEFAULT_DAMAGE_GAUGE_AMOUNT
var damageGauge = defaultDamageGauge setget setDamageGauge,getDamageGauge
var damageGaugeNextHit = damageGauge setget setDamageGaugeNextHit,getDamageGaugeNextHit#for now, this default value is buggy (should be equal, but this will only result in odd behavior 1 st hit in combo, so no biggy for now)
var defaultDamageGaugeCapacity = 1.3
var damageGaugeCapacity = defaultDamageGaugeCapacity setget setDamageGaugeCapacity,getDamageGaugeCapacity
var damageGaugeMinimum = 1
var damageGenerationComboCount = 0 setget setDamageGenerationComboCount,getDamageGenerationComboCount
#var damageGauageUponCapacityChange = defaultDamageGauge
var focusGenerationComboCount = 0 setget setFocusGenerationComboCount,getFocusGenerationComboCount

var abilityBarChunksGained = 0
var abilityBarChunksExcessLost = 0

var magicSeriesBarIncreaseCount = 0
var airMagicSeriesBarIncreaseCount=0

var numberOfCombos = 0
var averageComboDamage= 0
var totalDamageDealt = 0
var bonusDamage = 0
var numEmptyDmgStars = 0 setget setNumEmptyDmgStars,getNumEmptyDmgStars
var numFilledDmgStars = 0 setget setNumFilledDmgStars,getNumFilledDmgStars

var numGuardBreaks = 0
var numberOfBlocks = 0
var numberOfCorrectBlocks=0
var numberOfPerfectBlocks=0
var numberOfIncorrectBlocks=0
var numStarCompletionCombos = 0
var totalDamageDealthToGuard = 0
var totalNumHits = 0
var bestAchievedDamageGauge = defaultDamageGauge
var bestAchieveddamageGaugeCapacity = defaultDamageGaugeCapacity

var fillComboSubLevel = 0 setget setFillComboSubLevel,getFillComboSubLevel

var negativeLevel = 0 setget setNegativeLevel,getNegativeLevel
var maxGuardHP = null #will be set by stage using settings
var guardHP =null  setget setGuardHP,getGuardHP #will be set by stage using default gaurd settings
var guardLock = false setget setGuardLock,getGuardLock 
var isBlockOnCooldown = false setget setBlockCooldown,getBlockCooldown
var isGrabOnCooldown = false setget setGrabCooldown,getGrabCooldown
var defaultGrabCharges = 1
var grabCharges = defaultGrabCharges setget setGrabCharges,getGrabCharges
var comboDamage = 0 setget setComboDamage,getComboDamage
var mostComboDamageDone = 0
var combo  = 0 setget setCombo,getCombo
var maxCombo = 0
var avgComboLength=0 setget setAvgComboLength,getAvgComboLength
var comboLengthArray= []
var damageScale = 1 setget setDamageScale,getDamageScale #this is affected by damage proration
var comboLevelDamageScale = 1 setget setComboLevelDamageScale,getComboLevelDamageScale#this is another form of proration that occurs upon leveling up a damage combo
var abilityRegenScale = GLOBALS.DEFAULT_ABILITY_REGEN_SCALE  setget setAbilityRegenScale,getAbilityRegenScale #this is affected by ability regeneration proration
var comboLevelabilityRegenScale = 1 setget setComboLevelAbilityRegenScale,getComboLevelAbilityRegenScale#this is another form of proration that occurs upon leveling up a focus combo
var defaultFocus = GLOBALS.DEFAULT_FOCUS_AMOUNT
var focus = defaultFocus setget setFocus,getFocus#the more focus you have, the less you feed ability bar to opponent upon hit
var focusNextHit = focus setget setFocusNextHit,getFocusNextHit #for now, this default value is buggy (should be equal, but this will only result in odd behavior 1 st hit in combo, so no biggy for now)
var focusMinimum = 1
var defaultFocusCapacity = 1.3
var focusCapacity = defaultFocusCapacity setget setFocusCapacity, getFocusCapacity
var focusUponCapacityChange = defaultFocus

var bestAchievedFocus = defaultFocus
var bestAchievedFocusCapacity = defaultFocusCapacity

var lastAttackWasHitBy = null
var hittingWithJumpCancelHitBox = false

var halfHPReached=false
var wasInBlockStun = false
var abilityChunkSize = 0

var abilityBarGainLocked = false setget setAbilityBarGainLocked,getAbilityBarGainLocked

var abilityBarCanceling = false

var antiBlockStealNumChunks = 2

var  abilityCancelCount = 0
var autoAbilityCancelCount = 0
var defaultBlockEfficiency = 0
var blockEfficiency = defaultBlockEfficiency setget setBlockEfficiency,getBlockEfficiency
var maxBlockEff = 1
var minBlockEff = -3

var bestBlockEfficiency = blockEfficiency
var worstBlockEfficiency = blockEfficiency

var totalNumDamageComboLevelUps=0
var totalNumFocusComboLevelUps=0
var numRiposts = 0
var numAttemptedRiposts = 0
var numCounterRiposts = 0
var numAttemptedCounterRiposts = 0
var numAutoRiposts = 0
var numSuccesfulBlocks = 0
var totalAbilityBarUsed = 0
var numberOfFailedTechs=0
var numberOfSuccessfulTechs=0

var guardRegenBuffEnabled = false setget setGuardRegenBuffEnabled,getGuardRegenBuffEnabled


var abilityCancelTotalChunksUsed = 0
var autoAbilityCancelTotalChunksUsed = 0
var numberOfWhiffedGrabs=0
var numberOfSuccessfulGrabs=0
		
var lastCommandHit=null





func _ready():
	currentNumJumps = numJumps
	#abilityChunkSize = floor(abilityBarMaximum / abilityNumberOfChunks)
	abilityChunkSize = abilityBarMaximum / abilityNumberOfChunks

func resetStatTracking():

	combo=0
	maxComboLevelAchieved = 0
	maxFocusComboLevelAchieved = 0
	totalNumHits = 0
	bestAchievedDamageGauge = defaultDamageGauge
	bestAchieveddamageGaugeCapacity = defaultDamageGaugeCapacity
	mostComboDamageDone = 0
	maxCombo = 0
	bestAchievedFocus = defaultFocus
	bestAchievedFocusCapacity = defaultFocusCapacity
	abilityCancelCount = 0
	autoAbilityCancelCount= 0
	
	blockEfficiency = defaultBlockEfficiency
	bestBlockEfficiency = blockEfficiency
	worstBlockEfficiency = blockEfficiency

	totalNumDamageComboLevelUps=0
	totalNumFocusComboLevelUps=0
	totalAbilityBarUsed = 0
	abilityCancelTotalChunksUsed = 0
	autoAbilityCancelTotalChunksUsed=0
	
	numStarCompletionCombos=0
	totalDamageDealthToGuard=0
	bonusDamage = 0
	magicSeriesBarIncreaseCount=0
	airMagicSeriesBarIncreaseCount=0
	numSuccesfulAutoRiposts=0
	numberOfCombos = 0
	#avgComboLength=0
	comboLengthArray.clear()
	averageComboDamage = 0
	totalDamageDealt = 0
	numGuardBreaks=0
	numberOfBlocks=0
	numberOfCorrectBlocks=0
	numberOfPerfectBlocks=0
	numberOfIncorrectBlocks=0
	abilityBarChunksGained=0
	abilityBarChunksExcessLost=0

func setGuardHP(v):
	var oldValue = guardHP
	
	guardHP = max(v,0)
	
	#don't exceed max guard
	guardHP = min(maxGuardHP,guardHP)
	
	emit_signal("guardHP_changed",oldValue,guardHP)
	
func getGuardHP():
	return guardHP

func setGuardLock(f):
	
	var oldValue = guardLock
	
	guardLock = f
	
	if guardLock!= oldValue:
		emit_signal("guard_lock_changed",guardLock)
func getGuardLock():
	return guardLock
	
func setMatchSecondsEllapsed(s):
	matchSecondsEllapsed=s
	
func getMatchSecondsEllapsed():
	return matchSecondsEllapsed
	
func setFillComboSubLevel(v):
	
	var old = fillComboSubLevel
	fillComboSubLevel = v
	
	if old != fillComboSubLevel:
		emit_signal("fill_combo_sub_level_changed",old,fillComboSubLevel)
	
func getFillComboSubLevel():
	return fillComboSubLevel
	
func clearFillComboSubLevel():
	setFillComboSubLevel(0)

func setCurrentNumberOfJumps(value):
	
	currentNumJumps = value
	
func getCurrentNumberOfJumps():
	return currentNumJumps

func setAbilityBarMaximum(value):
	abilityBarMaximum = value

func getAbilityBarMaximum():
	return abilityBarMaximum

func setAbilityBarAmountInChunks(chunks):
	setAbilityBar(chunks*abilityChunkSize)
	
func increaseAbilityBarToMax():
	#gotta double check this, its weird, i don't see a max ability bar anywhere
	#so 10 sould be good enough
	#increaseAbilityBarInChunks(50)
	increaseAbilityBarInChunks(abilityBarMaximum)
	
func setFocusGenerationComboCount(c):
	var from = focusGenerationComboCount
	var to = c
	focusGenerationComboCount = c
	
	emit_signal("focus_generation_combo_count_changed",from,to)
	
func getFocusGenerationComboCount():
	return focusGenerationComboCount


func setDamageGenerationComboCount(c):
	
	var from = damageGenerationComboCount
	var to = c
	
	damageGenerationComboCount = c
	
	emit_signal("damage_gauge_generation_combo_count_changed",from,to)
	
func getDamageGenerationComboCount():
	return damageGenerationComboCount


func setNegativeLevel(lvl):
	
	#minimum is 0
	if lvl < 0:
		lvl = 0
	#max is 5
	if lvl > 5:
		lvl = 5
		
	var old = negativeLevel
	
	negativeLevel=lvl
	
	if old != negativeLevel:
		emit_signal("negative_level_changed",negativeLevel,old)
	
	
func getNegativeLevel():
	return negativeLevel
	

func setBlockEfficiency(be):
	#boundary check
	if be < minBlockEff:
		be = minBlockEff
	elif be > maxBlockEff:
		be = maxBlockEff
		
	blockEfficiency = be
	
	bestBlockEfficiency = max(blockEfficiency,bestBlockEfficiency)
	worstBlockEfficiency = min(blockEfficiency,worstBlockEfficiency)
	
	emit_signal("block_efficiency_changed",blockEfficiency)

func getBlockEfficiency():
	return blockEfficiency

func setAbilityNumberOfChunks(n):
	abilityNumberOfChunks = n
	#abilityChunkSize = floor(abilityBarMaximum / abilityNumberOfChunks)
	abilityChunkSize = abilityBarMaximum / abilityNumberOfChunks
func getAbilityNumberOfChunks():
	return abilityNumberOfChunks
func setInHitStun(flag):
	
	var oldHitstun = inHitStun
	
	inHitStun=flag
	
	if oldHitstun != flag:
		emit_signal("changed_in_hitstun",flag)

func getInHitStun():
	return inHitStun

func setComboDamage(dmg):
	
	comboDamage = dmg
	
	#track max combo damage
	if mostComboDamageDone < comboDamage:
		mostComboDamageDone = comboDamage
		emit_signal("max_combo_damage_changed",mostComboDamageDone)
		
	emit_signal("changed_combo_damage",int(comboDamage))
	
func getComboDamage():
	return comboDamage
	
	#there is abug atm, where # hits != max combo when they both should be same
func setCombo(c):

	#reseting combo?
	if c < 0:
		c = 0

	#var oldCombo = combo
	combo = c



func setAvgComboLength(v):
	avgComboLength=v
	
func getAvgComboLength():
	if numberOfCombos == 0:
		return -1
	
	var comboLengthSum=0
	for l in comboLengthArray:
		comboLengthSum+=l
		
	return stepify(comboLengthSum/float(numberOfCombos),0.1) #1 decimal
	
func resetCombo():
	combo = 0
	increaseCombo()
	
func increaseCombo():
	combo = combo + 1
	
	#only count the combo if increasing
	totalNumHits = totalNumHits + 1

	
	#check for max combo changed
	if combo > maxCombo:
		maxCombo = combo
		emit_signal("max_combo_changed",combo)	
	emit_signal("combo_changed",combo)
	
func getCombo():
	return combo

func _on_auto_successful_ripost():
	numSuccesfulAutoRiposts+=1

func _on_auto_ripost_attempted():
	numAutoRiposts+=1
#old function, forget about it
func setBlockCooldown(b):
	pass
#	isBlockOnCooldown  =b
	
#	if isBlockOnCooldown:
		#numAutoRiposts+=1
	#send not on cool down to represent true when off cool down and false when on cooldown
#	emit_signal("block_cooldown_changed",not isBlockOnCooldown)

func getBlockCooldown():
	return isBlockOnCooldown

func setGrabCooldown(b):
	
	isGrabOnCooldown  =b
	
#	if isGrabOnCooldown:
#		numAutoRiposts+=1
	#send not on cool down to represent true when off cool down and false when on cooldown
	#emit_signal("grab_cooldown_changed",not isGrabOnCooldown)

func getGrabCooldown():
	return isGrabOnCooldown
	
func setGrabCharges(c):
	var oldValue=grabCharges
	
	
	grabCharges=clamp(c,0,defaultGrabCharges)

	if oldValue != grabCharges:
		#emit_signal("grab_cooldown_changed",not isGrabOnCooldownCheck())
		emit_signal("grab_cooldown_changed",grabCharges,oldValue)
	
func getGrabCharges():
	return grabCharges
		
func isGrabOnCooldownCheck():
	return grabCharges==0
	
func setSubComboLevel(lvl):
	subComboLevel = lvl
	var playerController = get_parent()
	if playerController == null:
		return
	var cmd = playerController.inputManager.getFacingDependantCommand(lastCommandHit,playerController.kinbody.facingRight)
	emit_signal("sub_combo_level_changed",subComboLevel,cmd)

func setFocusSubComboLevel(lvl):
	focusSubComboLevel = lvl
	var playerController = get_parent()
	if playerController== null:
		return
	var cmd = playerController.inputManager.getFacingDependantCommand(lastCommandHit,playerController.kinbody.facingRight)
	emit_signal("focus_sub_combo_level_changed",focusSubComboLevel,cmd)
		
func getSubComboLevel():
	return subComboLevel

func getFocusSubComboLevel():
	return focusSubComboLevel
		
func setComboLevel(lvl):
	
	var old = comboLevel
	comboLevel = lvl
	#track most combo levels obtained
	if maxComboLevelAchieved < comboLevel:
		maxComboLevelAchieved = comboLevel
		
	#a chagne occured?
	if old != lvl:
		emit_signal("combo_level_changed",comboLevel)
		
		if lvl > old:
			totalNumDamageComboLevelUps = totalNumDamageComboLevelUps + 1

func setFocusComboLevel(lvl):
	var old = focusComboLevel
	focusComboLevel = lvl
	#track most combo levels obtained
	if maxFocusComboLevelAchieved < focusComboLevel:
		maxFocusComboLevelAchieved = focusComboLevel
		
	#a chagne occured?
	if old != lvl:
		emit_signal("focus_combo_level_changed",focusComboLevel)
		
		if lvl > old:
			totalNumFocusComboLevelUps = totalNumFocusComboLevelUps + 1
	
func getComboLevel():
	return comboLevel

func getFocusComboLevel():
	return focusComboLevel
	
func setHP(_hp):
	
	hp = _hp
	emit_signal("hp_changed",hp)
func getHP():
	return hp
	
func setDamageGauge(d):

		
	var oldDamage = damageGauge
	#enforce minimum value of damage guagerespected and max is capacity
	damageGauge = min(d,damageGaugeCapacity)
	#if damageGauge < defaultDamageGauge:
	#	damageGauge = defaultDamageGauge
	if damageGauge < damageGaugeMinimum:
		damageGauge = damageGaugeMinimum
	

	#track the max damage gotten to date
	if bestAchievedDamageGauge < damageGauge:
		bestAchievedDamageGauge = damageGauge
	
	
	#only replace the ben
	#damageGauageUponCapacityChange=damageGauge	
	if d >= damageGaugeCapacity:
		emit_signal("damage_gauge_reached_capacity",damageGauge)
	#else:
		#damage reduced below capacity? start tracking
		#if damageGauge < oldDamage:
		#	emit_signal("start_damage_gauge_generation_tracking",damageGauge,damageGaugeCapacity)
	
	
	emit_signal("damage_gauge_changed",damageGauge,oldDamage)
	


func setGuardRegenBuffEnabled(f):
	#the falg chagned?
	var changed = f !=guardRegenBuffEnabled
	
	guardRegenBuffEnabled=f
	
	if changed:
		emit_signal("guard_regen_buff_flag_changed",guardRegenBuffEnabled)
		
func getGuardRegenBuffEnabled():
	return guardRegenBuffEnabled



func getDamageGauge():
	return damageGauge
	
	
func setDamageGaugeNextHit(value):
	
	var oldDamageNextHit = damageGaugeNextHit
	#enforce minimum value of damage guagerespected and max is capacity
	damageGaugeNextHit = min(value,damageGaugeCapacity)
	#if damageGauge < defaultDamageGauge:
	#	damageGauge = defaultDamageGauge
	if damageGaugeNextHit < damageGaugeMinimum:
		damageGaugeNextHit = damageGaugeMinimum

	
	emit_signal("damage_gauge_next_hit_changed",damageGaugeNextHit,oldDamageNextHit)
	

func getDamageGaugeNextHit():
	return damageGaugeNextHit
	
func setAbilityBar(b):
	b = clamp(b,0,abilityBarMaximum)
	
	var oldAmt =abilityBar
	abilityBar = b
	emit_signal("ability_bar_changed",abilityBar,oldAmt)

#no signal set ability bar
func _setAbilityBar(b):
	b = clamp(b,0,abilityBarMaximum)
	abilityBar = b
	


func getAbilityBar():
	return abilityBar
	
	
func countJump(recoverAirDashFlag):
	wasInAir = true
	setCurrentNumberOfJumps(currentNumJumps-1)
	
	if currentNumJumps < 0:
		pass
	if recoverAirDashFlag:
		hasAirDashe =true #get airdash back from jump
	#currentNumJumps -= 1 
	
# drains the ability bar
#returns true when ability bar was drained, and false otherwise 
#(didn't have enough to drain, or if drain amount is negative)
func consumeAbilityBar(numChunks):
	
	#convert from  number of chunks to recution amount
	var reductionAmount =  abilityChunkSize * numChunks
	
	#don't increase ability bar in this function
	if reductionAmount < 0:
		return false
		
	#less ability bar than amount to reduce by?
	if abilityBar < reductionAmount:
		emit_signal("insufficient_ability_bar",reductionAmount)
		return false
	
	#reduce bar
	setAbilityBar(abilityBar - reductionAmount)
	
	#totalAbilityBarUsed+=reductionAmount
	totalAbilityBarUsed+=numChunks
	return true

#this will drain ability bar and if the number of chunks
#is to much, then ability bar is drained completly anyway
func forceConsumeAbilityBarInChunks(numChunks):
	#to much requested bar to consum?
	#if not hasEnoughAbilityBar(numChunks):
		#just drain completly
	#	setAbilityBar( 0)
	#else:
		#drain normally
	#	consumeAbilityBar(numChunks)
	
		
	#convert from  number of chunks to recution amount
	var reductionAmount =  abilityChunkSize * numChunks
	
	#don't increase ability bar in this function
	if reductionAmount < 0:
		return false

	#reduce bar (minimum 0)
	setAbilityBar(max(abilityBar - reductionAmount,0))
	
	#totalAbilityBarUsed+=reductionAmount
	totalAbilityBarUsed+=numChunks
	return true

#returns true when has enough bar to consume given cost
func hasEnoughAbilityBar(numChunks):
	
	#var barCost =  abilityChunkSize * numChunks
	
	var numFilledChunks = int(GLOBALS.getNumberOfChunks(abilityBar,abilityChunkSize))
	
	return numFilledChunks>=numChunks
	#return abilityBar >= barCost
		
		
		
func increaseAbilityBarInChunks(numChunks):
	
	#don't decrease ability bar in this function
	if numChunks < 0:
		return false		
	
	var increaseAmount =  abilityChunkSize * numChunks

	
	return increaseAbilityBar(increaseAmount)
	
func increaseAbilityBar(additiveAmount):
	
	#don't decrease ability bar in this function
	if additiveAmount < 0:
		return false		
	
	
	var newAmount = abilityBar + additiveAmount
	var limitedNewAmount =min(newAmount,abilityBarMaximum)
	
	abilityBarChunksGained+=(limitedNewAmount-abilityBar)/abilityChunkSize
	abilityBarChunksExcessLost+=(newAmount-limitedNewAmount)/abilityChunkSize
	
	#reduce bar
	setAbilityBar(limitedNewAmount)
	
	return true
	
func setPlayerState(src):
	
	matchSecondsEllapsed = src.matchSecondsEllapsed
	setInHitStun(src.inHitStun)
	setHP(src.hp)
	setAbilityBarMaximum(src.getAbilityBarMaximum())
	setAbilityBar(src.getAbilityBar())
	setAbilityNumberOfChunks(src.getAbilityNumberOfChunks())
	profAbilityBarCostMod = src.profAbilityBarCostMod
	baseAbilityCancelCost = src.baseAbilityCancelCost
	numJumps = src.numJumps
	hasAirDashe = src.hasAirDashe
	recoveredAirDashFromHit = src.recoveredAirDashFromHit
	recoveredAbilityCancelAirDash = src.recoveredAbilityCancelAirDash
	currentNumJumps = src.currentNumJumps
	numAcroABCancelExtraJumps = src.numAcroABCancelExtraJumps
	maxDamageGauge = src.maxDamageGauge
	maxFocus = src.maxFocus
	playerPaused = src.playerPaused
	wasInAir = src.wasInAir
	blocked = src.blocked
	setComboLevel(src.getComboLevel())
	setFocusComboLevel(src.getFocusComboLevel())
	maxComboLevelAchieved = src.maxComboLevelAchieved
	maxFocusComboLevelAchieved = src.maxFocusComboLevelAchieved
	setSubComboLevel(src.getSubComboLevel())
	setFocusSubComboLevel(src.getFocusSubComboLevel())
	defaultDamageGauge = src.defaultDamageGauge
	setDamageGauge(src.getDamageGauge())
	defaultDamageGaugeCapacity = src.defaultDamageGaugeCapacity 
	abilityBarGainLocked = src.abilityBarGainLocked
	setDamageGaugeCapacity(src.getDamageGaugeCapacity())
	setDamageGenerationComboCount(src.getDamageGenerationComboCount())
	setFocusGenerationComboCount(src.getFocusGenerationComboCount())
	totalNumHits =src.totalNumHits
	bestAchievedDamageGauge =src.bestAchievedDamageGauge
	bestAchieveddamageGaugeCapacity =src.bestAchieveddamageGaugeCapacity
	setBlockCooldown(src.getBlockCooldown())
	setGrabCooldown(src.getGrabCooldown())
	setComboDamage(src.getComboDamage())
	mostComboDamageDone =src.mostComboDamageDone
	setCombo(src.getCombo())
	maxCombo =src.maxCombo
	setDamageScale(src.getDamageScale ())
	setComboLevelDamageScale(src.getComboLevelDamageScale())
	setAbilityRegenScale(src.getAbilityRegenScale())
	setComboLevelAbilityRegenScale(src.getComboLevelAbilityRegenScale())
	defaultFocus =src.defaultFocus
	defaultGrabCharges = src.defaultGrabCharges
	isGrabOnCooldown=src.isGrabOnCooldown
	grabCharges = src.grabCharges
	setFocus(src.getFocus())
	defaultFocusCapacity =src.defaultFocusCapacity
	setFocusCapacity(src.getFocusCapacity())
	focusUponCapacityChange =src.focusUponCapacityChange
	bestAchievedFocus =src.bestAchievedFocus
	bestAchievedFocusCapacity =src.bestAchievedFocusCapacity
	lastAttackWasHitBy =src.lastAttackWasHitBy
	hittingWithJumpCancelHitBox =src.hittingWithJumpCancelHitBox
	abilityChunkSize =src.abilityChunkSize
	abilityBarCanceling =src.abilityBarCanceling
	antiBlockStealNumChunks =src.antiBlockStealNumChunks
	abilityCancelCount =src. abilityCancelCount
	autoAbilityCancelCount = src.autoAbilityCancelCount
	setBlockEfficiency(src.getBlockEfficiency())
	maxBlockEff =src.maxBlockEff
	minBlockEff =src.minBlockEff
	bestBlockEfficiency =src.bestBlockEfficiency
	worstBlockEfficiency =src.worstBlockEfficiency
	totalNumDamageComboLevelUps=src.totalNumDamageComboLevelUps
	totalNumFocusComboLevelUps=src.totalNumFocusComboLevelUps
	numRiposts =src.numRiposts
	numAttemptedRiposts =src.numAttemptedRiposts
	numCounterRiposts =src.numCounterRiposts
	numAttemptedCounterRiposts =src.numAttemptedCounterRiposts
	numAutoRiposts =src.numAutoRiposts
	numSuccesfulBlocks =src.numSuccesfulBlocks
	totalAbilityBarUsed =src.totalAbilityBarUsed
	numberOfFailedTechs=src.numberOfFailedTechs
	numberOfSuccessfulTechs=src.numberOfSuccessfulTechs
	guardRegenBuffEnabled = src.guardRegenBuffEnabled
	abilityCancelTotalChunksUsed =src.abilityCancelTotalChunksUsed
	autoAbilityCancelTotalChunksUsed=src.autoAbilityCancelTotalChunksUsed
	numberOfWhiffedGrabs =src.numberOfWhiffedGrabs
	numberOfSuccessfulGrabs =src.numberOfSuccessfulGrabs	
	lastCommandHit =src.lastCommandHit
	defaultBlockEfficiency = src.defaultBlockEfficiency
	guardHP = src.guardHP
	negativeLevel = src.negativeLevel
	maxGuardHP  =src.maxGuardHP
	guardLock = src.guardLock
	numEmptyDmgStars = src.numEmptyDmgStars
	numFilledDmgStars = src.numFilledDmgStars
	wasInBlockStun = src.wasInBlockStun
	halfHPReached = src.halfHPReached
	numStarCompletionCombos = src.numStarCompletionCombos
	numSuccesfulAutoRiposts = src.numSuccesfulAutoRiposts
	totalDamageDealthToGuard = src.totalDamageDealthToGuard
	bonusDamage = src.bonusDamage
	magicSeriesBarIncreaseCount = src.magicSeriesBarIncreaseCount
	airMagicSeriesBarIncreaseCount = src.airMagicSeriesBarIncreaseCount
	numberOfCombos = src.numberOfCombos
	#avgComboLength = src.avgComboLength
	comboLengthArray.clear()
	
	for l in src.comboLengthArray:
		comboLengthArray.append(l)
		
	averageComboDamage = src.averageComboDamage
	totalDamageDealt = src.totalDamageDealt
	numGuardBreaks = src.numGuardBreaks
	numberOfBlocks = src.numberOfBlocks
	numberOfCorrectBlocks=src.numberOfCorrectBlocks
	numberOfPerfectBlocks=src.numberOfPerfectBlocks
	numberOfIncorrectBlocks=src.numberOfIncorrectBlocks
	abilityBarChunksGained=src.abilityBarChunksGained
	abilityBarChunksExcessLost=src.abilityBarChunksExcessLost
func deepCopy():
	
	#return self.duplicate(true)
	
	var cpy = Node.new()
	
	cpy.set_script(self.get_script())

	cpy.inHitStun = inHitStun
	cpy.hp=hp
	cpy.matchSecondsEllapsed =matchSecondsEllapsed
	cpy.abilityBarMaximum = abilityBarMaximum
	cpy.abilityBar =abilityBar
	cpy.abilityNumberOfChunks =abilityNumberOfChunks
	cpy.profAbilityBarCostMod =profAbilityBarCostMod
	cpy.baseAbilityCancelCost = baseAbilityCancelCost
	cpy.numJumps =numJumps
	cpy.hasAirDashe = hasAirDashe
	cpy.recoveredAirDashFromHit = recoveredAirDashFromHit
	cpy.recoveredAbilityCancelAirDash = recoveredAbilityCancelAirDash
	cpy.currentNumJumps =currentNumJumps
	cpy.numAcroABCancelExtraJumps = numAcroABCancelExtraJumps
	cpy.maxDamageGauge =maxDamageGauge
	cpy.maxFocus =maxFocus
	cpy.playerPaused =playerPaused
	cpy.wasInAir =wasInAir
	cpy.blocked =blocked
	cpy.comboLevel =comboLevel
	cpy.focusComboLevel =focusComboLevel
	cpy.maxComboLevelAchieved =maxComboLevelAchieved
	cpy.maxFocusComboLevelAchieved =maxFocusComboLevelAchieved
	cpy.focusNextHit = focusNextHit
	cpy.subComboLevel  =subComboLevel
	cpy.focusSubComboLevel  =focusSubComboLevel
	cpy.defaultDamageGauge =defaultDamageGauge
	cpy.defaultDamageGaugeCapacity =defaultDamageGaugeCapacity
	cpy.abilityBarGainLocked = abilityBarGainLocked
	cpy.damageGaugeCapacity =damageGaugeCapacity
	cpy.damageGauge =damageGauge
	cpy.damageGaugeNextHit =damageGaugeNextHit
	cpy.damageGenerationComboCount =damageGenerationComboCount
	cpy.focusGenerationComboCount =focusGenerationComboCount
	cpy.totalNumHits =totalNumHits
	cpy.bestAchievedDamageGauge =bestAchievedDamageGauge
	cpy.bestAchieveddamageGaugeCapacity =bestAchieveddamageGaugeCapacity
	cpy.isBlockOnCooldown =isBlockOnCooldown
	cpy.isGrabOnCooldown =isGrabOnCooldown
	cpy.grabCharges = grabCharges
	cpy.defaultGrabCharges=defaultGrabCharges
	cpy.comboDamage =comboDamage
	cpy.mostComboDamageDone =mostComboDamageDone
	cpy.combo  =combo
	cpy.maxGuardHP  =maxGuardHP
	cpy.guardHP  =guardHP
	cpy.negativeLevel = negativeLevel
	cpy.guardLock = guardLock
	cpy.maxCombo =maxCombo
	cpy.damageScale =damageScale
	cpy.comboLevelDamageScale =comboLevelDamageScale
	cpy.abilityRegenScale =abilityRegenScale
	cpy.comboLevelabilityRegenScale =comboLevelabilityRegenScale
	cpy.defaultFocus =defaultFocus
	cpy.defaultFocusCapacity =defaultFocusCapacity
	cpy.focusCapacity =focusCapacity
	cpy.focus =focus
	cpy.focusUponCapacityChange =focusUponCapacityChange
	cpy.bestAchievedFocus =bestAchievedFocus
	cpy.bestAchievedFocusCapacity =bestAchievedFocusCapacity
	cpy.lastAttackWasHitBy = lastAttackWasHitBy
	cpy.hittingWithJumpCancelHitBox =hittingWithJumpCancelHitBox
	cpy.abilityChunkSize =abilityChunkSize
	cpy.abilityBarCanceling =abilityBarCanceling
	cpy.antiBlockStealNumChunks =antiBlockStealNumChunks
	cpy.abilityCancelCount = abilityCancelCount
	cpy.autoAbilityCancelCount = autoAbilityCancelCount
	cpy.blockEfficiency =blockEfficiency
	cpy.maxBlockEff =maxBlockEff
	cpy.minBlockEff =minBlockEff
	cpy.bestBlockEfficiency = bestBlockEfficiency
	cpy.worstBlockEfficiency =worstBlockEfficiency
	cpy.totalNumDamageComboLevelUps=totalNumDamageComboLevelUps
	cpy.totalNumFocusComboLevelUps=totalNumFocusComboLevelUps
	cpy.numRiposts =numRiposts
	cpy.numAttemptedRiposts =numAttemptedRiposts
	cpy.numCounterRiposts =numCounterRiposts
	cpy.numAttemptedCounterRiposts =numAttemptedCounterRiposts
	cpy.numAutoRiposts =numAutoRiposts
	cpy.numSuccesfulBlocks =numSuccesfulBlocks
	cpy.totalAbilityBarUsed =totalAbilityBarUsed
	cpy.numberOfFailedTechs=numberOfFailedTechs
	cpy.numberOfSuccessfulTechs=numberOfSuccessfulTechs
	cpy.guardRegenBuffEnabled = guardRegenBuffEnabled
	cpy.abilityCancelTotalChunksUsed =abilityCancelTotalChunksUsed
	cpy.autoAbilityCancelTotalChunksUsed=autoAbilityCancelTotalChunksUsed
	cpy.lastCommandHit=lastCommandHit
	cpy.numberOfWhiffedGrabs=numberOfWhiffedGrabs
	cpy.numberOfSuccessfulGrabs=numberOfSuccessfulGrabs
	cpy.defaultBlockEfficiency = defaultBlockEfficiency
	cpy.numEmptyDmgStars = numEmptyDmgStars
	cpy.numFilledDmgStars = numFilledDmgStars
	cpy.wasInBlockStun = wasInBlockStun
	cpy.halfHPReached = halfHPReached
	cpy.numStarCompletionCombos=numStarCompletionCombos
	cpy.totalDamageDealthToGuard=totalDamageDealthToGuard
	cpy.bonusDamage = bonusDamage
	cpy.magicSeriesBarIncreaseCount = magicSeriesBarIncreaseCount
	cpy.airMagicSeriesBarIncreaseCount = airMagicSeriesBarIncreaseCount
	cpy.numSuccesfulAutoRiposts=numSuccesfulAutoRiposts
	cpy.numberOfCombos = numberOfCombos
	#cpy.avgComboLength = avgComboLength
	
	cpy.comboLengthArray.clear()
	
	for l in comboLengthArray:
		cpy.comboLengthArray.append(l)
		
	cpy.averageComboDamage = averageComboDamage
	cpy.totalDamageDealt = totalDamageDealt
	cpy.numGuardBreaks=numGuardBreaks
	cpy.abilityBarChunksGained=abilityBarChunksGained
	cpy.abilityBarChunksExcessLost=abilityBarChunksExcessLost
	cpy.numberOfBlocks=numberOfBlocks
	cpy.numberOfCorrectBlocks=numberOfCorrectBlocks
	cpy.numberOfPerfectBlocks=numberOfPerfectBlocks
	cpy.numberOfIncorrectBlocks=numberOfIncorrectBlocks
	return cpy
	
func increaseDamageGaugeCapacity(c):
	setDamageGaugeCapacity(damageGaugeCapacity + c)
	
func reduceDamageGaugeCapacity(c):
	
	setDamageGaugeCapacity(damageGaugeCapacity - c)
	#receuding the capactiy below current damage guage amount?
	
	if damageGaugeCapacity < damageGauge:
		#recude the damage amount, cause capacity decreasing 
		#below curent amoutn
		setDamageGauge(damageGaugeCapacity)
	
func reduceDamageGauge(c):
	
	setDamageGauge(damageGauge - c)
	
func setDamageGaugeCapacity(c):
	
	#don't let bar go too much
	if c > GLOBALS.MAXIMUM_DMG_FOCUS_BAR_AMOUNT:
		c =GLOBALS.MAXIMUM_DMG_FOCUS_BAR_AMOUNT
		
	var oldValue = damageGaugeCapacity
	
	#damageGauageUponCapacityChange=damageGauge
	#can't set capacity lower than minimum (default to minimum if smaller set)
	#damageGaugeCapacity = max(c,defaultDamageGaugeCapacity)
	damageGaugeCapacity = max(c,damageGaugeMinimum)
	
	#record highest
	bestAchieveddamageGaugeCapacity = max(bestAchieveddamageGaugeCapacity,damageGaugeCapacity)
	
	emit_signal("damage_gauge_capacity_changed",damageGaugeCapacity,oldValue)
func getDamageGaugeCapacity():
	return damageGaugeCapacity
	
func setFocus(f):

		
	var oldFocus = focus
	
	#can't set focus above capaicty
	focus =  min(f,focusCapacity)
	#minimum value of focus is enforced
	#if focus < defaultFocus:
	#	focus = defaultFocus
	if focus < focusMinimum:
		focus = focusMinimum

	#track the max focus gotten to date
	if bestAchievedFocus < focus:
		bestAchievedFocus = focus
		
	if f >= focusCapacity:
		emit_signal("focus_reached_capacity",focus)
	#else:
		#damage reduced below capacity? start tracking
		#if damageGauge < oldDamage:
		#	emit_signal("start_damage_gauge_generation_tracking",damageGauge,damageGaugeCapacity)
		
	emit_signal("focus_changed",focus,oldFocus)
	
		
func getFocus():
	return focus

func getFocusNextHit():
	return focusNextHit
	
	
func setFocusNextHit(value):
	
	var oldFocusNextHit = focusNextHit
	#enforce minimum value of damage guagerespected and max is capacity
	focusNextHit = min(value,focusCapacity)
	#if damageGauge < defaultDamageGauge:
	#	damageGauge = defaultDamageGauge
	if focusNextHit < focusMinimum:
		focusNextHit = focusMinimum

	
	emit_signal("focus_next_hit_changed",focusNextHit,oldFocusNextHit)
	
func increaseFocusCapacity(c):
	setFocusCapacity(focusCapacity + c)
	
func reduceFocusCapacity(c):
	
	setFocusCapacity(focusCapacity - c)
	#receuding the capactiy below current damage guage amount?
	
	if focusCapacity < focus:
		#recude the focus amount, cause capacity decreasing 
		#below curent amoutn
		setFocus(focusCapacity)
	
		
func reduceFocus(c):

	setFocus(focus - c)

	
	
func setFocusCapacity(c):
		
	#don't let bar go too much
	if c > GLOBALS.MAXIMUM_DMG_FOCUS_BAR_AMOUNT:
		c =GLOBALS.MAXIMUM_DMG_FOCUS_BAR_AMOUNT
		
	var oldValue = focusCapacity
	
	#focusUponCapacityChange = focus
	#can't set capacity lower than minimum (default to minimum if smaller set)
	#focusCapacity = max(c,defaultFocusCapacity)
	focusCapacity = max(c,focusMinimum)
	
	
	#record highest 
	bestAchievedFocusCapacity = max(focusCapacity,bestAchievedFocusCapacity)
	emit_signal("focus_capacity_changed",focusCapacity,oldValue)
	
func getFocusCapacity():
	return focusCapacity

func setAbilityRegenScale(value):
	var oldValue = abilityRegenScale

	abilityRegenScale = value
	
	if value != oldValue:
		emit_signal("abilityRegenScaleChanged",oldValue,value)
		
func getAbilityRegenScale():
	return abilityRegenScale

func setDamageScale(value):
	
	var oldValue = damageScale

	damageScale = value
	
	if value != oldValue:
		emit_signal("damageScaleChanged",oldValue,value)
	
func getDamageScale():
	return  damageScale
func setComboLevelDamageScale(value):
	
	var oldValue = comboLevelDamageScale
	
	comboLevelDamageScale = value
	
		
	if value != oldValue:
		emit_signal("comboLevelDamageScaleChanged",oldValue,value)
func getComboLevelDamageScale():
	return comboLevelDamageScale

func setComboLevelAbilityRegenScale(value):
	
	var oldValue = comboLevelabilityRegenScale
	
	comboLevelabilityRegenScale = value
	
		
	if value != oldValue:
		emit_signal("comboLevelAbilityRegenScaleChanged",oldValue,value)
func getComboLevelAbilityRegenScale():
	return comboLevelabilityRegenScale


func setNumEmptyDmgStars(num):
	
	if num >= GLOBALS.MAX_NUM_DMG_STARS:
		num =GLOBALS.MAX_NUM_DMG_STARS
	if num < 0:
		num = 0
			
	var old =numEmptyDmgStars
	
	numEmptyDmgStars=num
	
	if old != numEmptyDmgStars:
		
		emit_signal("num_empty_dmg_stars_changed",old,numEmptyDmgStars)

func getNumEmptyDmgStars():
	return numEmptyDmgStars
	
func clearNumEmptyDmgStars():
	setNumEmptyDmgStars(0)
	
func increaseNumEmptyDmgStars():
	
	#can never exceed more than max stars (5 empty, 0 filled) (4 empty, 1 filled) ... (2 emptye,3 filled),...
	if (numFilledDmgStars + numEmptyDmgStars ) < GLOBALS.MAX_NUM_DMG_STARS:
		setNumEmptyDmgStars(numEmptyDmgStars+1)

func decreaseNumEmptyDmgStars():
	
	setNumEmptyDmgStars(numEmptyDmgStars-1)
	
func setNumFilledDmgStars(num):
	if num >= GLOBALS.MAX_NUM_DMG_STARS:
		num =GLOBALS.MAX_NUM_DMG_STARS
	if num < 0:
		num = 0
		
	var old =numFilledDmgStars
	numFilledDmgStars = num
	if old != numFilledDmgStars:
		
		emit_signal("num_filled_dmg_stars_changed",old,numFilledDmgStars)
	
func clearNumFilledDmgStars():
	setNumFilledDmgStars(0)
	
func getNumFilledDmgStars():
	return numFilledDmgStars

func increaseNumFilledDmgStars():

	setNumFilledDmgStars(numFilledDmgStars+1)
	decreaseNumEmptyDmgStars()
	#this reduces empty stars by one, since empty star was filled

func decreaseNumFilledDmgStars():
	
	setNumFilledDmgStars(numFilledDmgStars-1)


func setAbilityBarGainLocked(f):
	abilityBarGainLocked = f 
	emit_signal("abilit_bar_gain_lock_changed",f)
	
func getAbilityBarGainLocked():
	return abilityBarGainLocked

func _on_combo_ended():
	if numberOfCombos ==0:
		averageComboDamage=-1
		#avgComboLength=-1
	else:
		comboLengthArray.append(combo)
		#avgComboLength=stepify(totalNumHits/numberOfCombos,0.1) #1 decimal
		averageComboDamage = stepify(totalDamageDealt/numberOfCombos,0.1) #1 decimal
func _on_started_combo():
	
	#reset the counter used to determine how much we increase ability bar
	#from magic series
	magicSeriesBarIncreaseCount = 0
	airMagicSeriesBarIncreaseCount = 0
	numberOfCombos+=1
	
	
func _on_apply_damage_to_opponent(totalDmg,baseDamage):
	totalDamageDealt+=totalDmg
	
	var _bonusDmg = totalDmg-baseDamage
	bonusDamage +=_bonusDmg

func _on_guard_broken(highBlocking,amountGuardRegened):
	numGuardBreaks+=1
	
	
	
#enum BlockResult{
#	CORRECT,
#	INCORRECT,
#	PERFECT,
#	NO_BLOCK
#}

func _on_entered_block_hitstun(attackerHitbox,blockResult,attackFacingRight):
	numberOfBlocks+=1
	
	if blockResult == GLOBALS.BlockResult.CORRECT or blockResult == GLOBALS.BlockResult.PERFECT:
		numberOfCorrectBlocks+=1
		
		if blockResult == GLOBALS.BlockResult.PERFECT:
			numberOfPerfectBlocks+=1
	elif blockResult == GLOBALS.BlockResult.INCORRECT:
		numberOfIncorrectBlocks+=1
	
	
	
func _on_ability_cancel(numberOfChunks,spriteFrame,autoAbilityCancelFlag):
	
	if not autoAbilityCancelFlag:
		abilityCancelCount= abilityCancelCount + 1#
		abilityCancelTotalChunksUsed =  abilityCancelTotalChunksUsed + numberOfChunks
	else:
		autoAbilityCancelCount= autoAbilityCancelCount + 1#
		autoAbilityCancelTotalChunksUsed =  autoAbilityCancelTotalChunksUsed + numberOfChunks
	
#func _on_tech(framesRemaining,type,failFlag):
func _on_tech(framesRemaining,type,failFlag):
	pass
	if failFlag:
		numberOfFailedTechs=numberOfFailedTechs+1
	else:
		numberOfSuccessfulTechs = numberOfSuccessfulTechs +1
		
func _on_grab(failFlag):
	if failFlag:
		numberOfWhiffedGrabs=numberOfWhiffedGrabs+1
	else:
		numberOfSuccessfulGrabs = numberOfSuccessfulGrabs +1

#computes the hash of all members and aggregates it into one final hash
func hashCode():
	
	var hashAgg = 0
	#convert self to dictionary for easy member lookup

	hashAgg=hashAgg^hash(int(hp))
	#hashAgg=hashAgg^hash(abilityBarMaximum)	
	hashAgg=hashAgg^hash(int(abilityBar))
	
#	hashAgg=hashAgg^hash(abilityNumberOfChunks)	
#	hashAgg=hashAgg^hash(profAbilityBarCostMod)	
	
#	hashAgg=hashAgg^hash(baseAbilityCancelCost)	
#	hashAgg=hashAgg^hash(numJumps)	
#	hashAgg=hashAgg^hash(hasAirDashe)	
#	hashAgg=hashAgg^hash(recoveredAirDashFromHit)		
#	hashAgg=hashAgg^hash(currentNumJumps)	
#	hashAgg=hashAgg^hash(playerPaused)		
#	hashAgg=hashAgg^hash(wasInAir)	
#	hashAgg=hashAgg^hash(wasOnPlatform)	
#	hashAgg=hashAgg^hash(blocked)	
	hashAgg=hashAgg^hash(numSuccesfulAutoRiposts)		
#	hashAgg=hashAgg^hash(comboLevel)	
#	hashAgg=hashAgg^hash(maxComboLevelAchieved)	
#	hashAgg=hashAgg^hash(subComboLevel)	
#	hashAgg=hashAgg^hash(int(abilityBarChunksGained))
#	hashAgg=hashAgg^hash(int(abilityBarChunksExcessLost))
#	hashAgg=hashAgg^hash(magicSeriesBarIncreaseCount)
#	hashAgg=hashAgg^hash(airMagicSeriesBarIncreaseCount)	
	hashAgg=hashAgg^hash(numberOfCombos)	
#	hashAgg=hashAgg^hash(int(averageComboDamage))
#	hashAgg=hashAgg^hash(int(totalDamageDealt))
	hashAgg=hashAgg^hash(numGuardBreaks)	
	hashAgg=hashAgg^hash(numberOfBlocks)	
#	hashAgg=hashAgg^hash(numberOfCorrectBlocks)	
#	hashAgg=hashAgg^hash(numberOfPerfectBlocks)	
	hashAgg=hashAgg^hash(int(totalDamageDealthToGuard))
	hashAgg=hashAgg^hash(totalNumHits)	
#	hashAgg=hashAgg^hash(fillComboSubLevel)	
	#hashAgg=hashAgg^hash(negativeLevel)	
#	hashAgg=hashAgg^hash(maxGuardHP)	
	#hashAgg=hashAgg^hash(int(guardHP))
#	hashAgg=hashAgg^hash(guardLock)	
#	hashAgg=hashAgg^hash(isGrabOnCooldown)	
#	hashAgg=hashAgg^hash(int(comboDamage))
#	hashAgg=hashAgg^hash(int(mostComboDamageDone))
	hashAgg=hashAgg^hash(combo)	
	hashAgg=hashAgg^hash(maxCombo)	
#	hashAgg=hashAgg^hash(int(avgComboLength))
#	hashAgg=hashAgg^hash(damageScale)	
#	hashAgg=hashAgg^hash(abilityRegenScale)	
	
#	hashAgg=hashAgg^hash(lastAttackWasHitBy)	
#	hashAgg=hashAgg^hash(hittingWithJumpCancelHitBox)	
#	hashAgg=hashAgg^hash(wasInBlockStun)	
#	hashAgg=hashAgg^hash(abilityChunkSize)	
#	hashAgg=hashAgg^hash(abilityBarGainLocked)	
#	hashAgg=hashAgg^hash(abilityBarCanceling)	
	
	hashAgg=hashAgg^hash(abilityCancelCount)	
	hashAgg=hashAgg^hash(autoAbilityCancelCount)	
#	hashAgg=hashAgg^hash(totalNumDamageComboLevelUps)	
	hashAgg=hashAgg^hash(numRiposts)	
	hashAgg=hashAgg^hash(numAttemptedRiposts)	
	hashAgg=hashAgg^hash(numCounterRiposts)	
	hashAgg=hashAgg^hash(numAttemptedCounterRiposts)	
	hashAgg=hashAgg^hash(numAutoRiposts)	
	hashAgg=hashAgg^hash(numSuccesfulBlocks)	
#	hashAgg=hashAgg^hash(int(totalAbilityBarUsed))
#	hashAgg=hashAgg^hash(int(totalAbilityBarUsed))
	
#	hashAgg=hashAgg^hash(numberOfFailedTechs)	
#	hashAgg=hashAgg^hash(numberOfSuccessfulTechs)	
	hashAgg=hashAgg^hash(numberOfSuccessfulTechs)	
	hashAgg=hashAgg^hash(abilityCancelTotalChunksUsed)	
	hashAgg=hashAgg^hash(autoAbilityCancelTotalChunksUsed)	
	hashAgg=hashAgg^hash(numberOfWhiffedGrabs)
	hashAgg=hashAgg^hash(numberOfSuccessfulGrabs)
#	hashAgg=hashAgg^hash(lastCommandHit)
	
	return hashAgg
#	var dict = inst2dict(self)
	
#	for keyMember in dict.keys():
		
#		var value = dict[keyMember]
#		var hashVal = hash(value)
		
		#use XOR as the aggregate (it's fast)
#		hashAgg = hashAgg ^ hashVal
		
#	return hashAgg


#print values of all members part of hash in hashCode funcition
func printHashCodeMembers():
	
	print("hp " + str(hp))	
	#print("abilityBarMaximum" +str(abilityBarMaximum))	
	print("abilityBar" +str(abilityBar))	
	
	#print("abilityNumberOfChunks" +str(abilityNumberOfChunks))	
	#print("profAbilityBarCostMod" +str(profAbilityBarCostMod))	
	
	#print("baseAbilityCancelCost" +str(baseAbilityCancelCost))	
	#print("numJumps" +str(numJumps))	
	#print("hasAirDashe" +str(hasAirDashe))	
	#print("recoveredAirDashFromHit)" +str(recoveredAirDashFromHit)	)	
	#print("currentNumJumps" +str(currentNumJumps))	
	#print("playerPaused)" +str(playerPaused)	)	
	#print("wasInAir" +str(wasInAir))	
	#print("wasOnPlatform" +str(wasOnPlatform))	
	#print("blocked" +str(blocked))	
	print("numSuccesfulAutoRiposts)" +str(numSuccesfulAutoRiposts)	)	
	#print("comboLevel" +str(comboLevel))	
	#print("maxComboLevelAchieved" +str(maxComboLevelAchieved))	
	#print("subComboLevel" +str(subComboLevel))	
	#print("abilityBarChunksGained" +str(abilityBarChunksGained))	
	#print("abilityBarChunksExcessLost" +str(abilityBarChunksExcessLost))	
	#print("magicSeriesBarIncreaseCoun" +str(magicSeriesBarIncreaseCount))
	#rint("airMagicSeriesBarIncreaseCount" +str(airMagicSeriesBarIncreaseCount))	
	print("numberOfCombos" +str(numberOfCombos))	
	#print("averageComboDamage" +str(averageComboDamage))	
	#print("totalDamageDealt" +str(totalDamageDealt))	
	print("numGuardBreaks" +str(numGuardBreaks))	
	print("numberOfBlocks" +str(numberOfBlocks))	
	#print("numberOfCorrectBlocks" +str(numberOfCorrectBlocks))	
	#print("numberOfPerfectBlocks" +str(numberOfPerfectBlocks))	
	print("totalDamageDealthToGuard" +str(totalDamageDealthToGuard))	
	print("totalNumHits" +str(totalNumHits))	
	#print("fillComboSubLevel" +str(fillComboSubLevel))	
#	print("negativeLevel" +str(negativeLevel))	
#	print("maxGuardHP" +str(maxGuardHP))	
#	print("guardHP" +str(guardHP))	
#	print("guardLock" +str(guardLock))	
#	print("isGrabOnCooldown" +str(isGrabOnCooldown))	
#	print("comboDamage" +str(comboDamage))	
#	print("mostComboDamageDone" +str(mostComboDamageDone))	
	print("combo" +str(combo))	
	print("maxCombo" +str(maxCombo))	
#	print("avgComboLength" +str(avgComboLength))	
#	print("damageScale" +str(damageScale))	
#	print("abilityRegenScale" +str(abilityRegenScale))	
	
	#print("lastAttackWasHitBy" +str(lastAttackWasHitBy))	
	#print("hittingWithJumpCancelHitBox" +str(hittingWithJumpCancelHitBox))	
	#print("wasInBlockStun" +str(wasInBlockStun))	
	#print("abilityChunkSize" +str(abilityChunkSize))	
	#print("abilityBarGainLocked" +str(abilityBarGainLocked))	
	#print("abilityBarCanceling" +str(abilityBarCanceling))	
	
	print("abilityCancelCount" +str(abilityCancelCount))	
	print("autoAbilityCancelCount" +str(autoAbilityCancelCount))	
	#print("totalNumDamageComboLevelUps" +str(totalNumDamageComboLevelUps))	
	print("numRiposts" +str(numRiposts))	
	print("numAttemptedRiposts" +str(numAttemptedRiposts))	
	print("numCounterRiposts" +str(numCounterRiposts))	
	print("numAttemptedCounterRiposts" +str(numAttemptedCounterRiposts))	
	print("numAutoRiposts" +str(numAutoRiposts))	
	print("numSuccesfulBlocks" +str(numSuccesfulBlocks))	
	#print("totalAbilityBarUsed" +str(totalAbilityBarUsed))	
	#print("totalAbilityBarUsed" +str(totalAbilityBarUsed))	
	
	#print("numberOfFailedTechs" +str(numberOfFailedTechs))	
	#print("numberOfSuccessfulTechs" +str(numberOfSuccessfulTechs))	
	print("numberOfSuccessfulTechs" +str(numberOfSuccessfulTechs))	
	print("abilityCancelTotalChunksUsed" +str(abilityCancelTotalChunksUsed))	
	print("autoAbilityCancelTotalChunksUsed" +str(autoAbilityCancelTotalChunksUsed))	
	print("numberOfWhiffedGrab" +str(numberOfWhiffedGrabs))
	print("numberOfSuccessfulGrab" +str(numberOfSuccessfulGrabs))
	#print("lastCommandHi" +str(lastCommandHit))
	
func count_num_star_completion_combos():
	numStarCompletionCombos = numStarCompletionCombos+1

func on_guard_damage_dealt(dmg):
	totalDamageDealthToGuard+=dmg	
func getMemberNamesToKeepTrackofMaximums():
	
	return ["matchSecondsEllapsed","hp","maxCombo","totalNumHits","maxComboLevelAchieved","totalNumDamageComboLevelUps",
	"mostComboDamageDone", "numRiposts","numCounterRiposts","numSuccesfulAutoRiposts","numAutoRiposts",
	"abilityCancelCount","numberOfSuccessfulTechs","numStarCompletionCombos","averageComboDamage","numberOfCombos","numGuardBreaks",
	"abilityBarChunksGained","abilityBarChunksExcessLost","autoAbilityCancelTotalChunksUsed","autoAbilityCancelCount","numberOfBlocks",
	"numberOfCorrectBlocks","numberOfPerfectBlocks","numberOfIncorrectBlocks","totalDamageDealthToGuard","bonusDamage","avgComboLength"]
	

func getMemberNamesToKeepTrackofTotals():
	
	return["matchSecondsEllapsed","totalNumHits", "totalNumDamageComboLevelUps", "numAttemptedRiposts"
	, "numRiposts", "numAttemptedCounterRiposts", "numCounterRiposts" , "numAutoRiposts", 
	"totalAbilityBarUsed", "abilityCancelTotalChunksUsed","numSuccesfulAutoRiposts",
	"abilityCancelCount", "numberOfSuccessfulTechs","numStarCompletionCombos","averageComboDamage","numberOfCombos","numGuardBreaks",
	"abilityBarChunksGained","abilityBarChunksExcessLost","autoAbilityCancelTotalChunksUsed","autoAbilityCancelCount","numberOfBlocks",
	"numberOfCorrectBlocks","numberOfPerfectBlocks","numberOfIncorrectBlocks","totalDamageDealthToGuard","bonusDamage","avgComboLength"]	
	

func getStylePointsMemberNamesToKeepTrackofMaximums():
	
	return ["maxCombo","maxComboLevelAchieved", "mostComboDamageDone","abilityCancelTotalChunksUsed","abilityCancelCount"]
	

func getStylePointsMemberNamesToKeepTrackofTotals():
	
	return["totalNumHits", "totalNumDamageComboLevelUps", 
	"totalAbilityBarUsed", "abilityCancelTotalChunksUsed"]
	

func getStatsMemberNames():
	
	return ["numCounterRiposts","numRiposts","maxCombo","mostComboDamageDone"]