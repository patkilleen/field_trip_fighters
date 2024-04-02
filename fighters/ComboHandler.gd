extends Node

signal filled_combo_level_up

var playerState = null

const GLOBALS = preload("res://Globals.gd")
var hitstunProrationResource = preload("res://hitstunProration.gd")
var hitstunProration = null

var generatingFocusFlag = false
var generatingDamageGaugeFlag = false
var damageGaugeRateMode = null
var damageGaugeComboLevelUpModIncrease = null
var focusComboLevelUpModIncrease = null
var focusRateMode = null

var initialDamageGaugeTrackingValue =null
var initialFocusTrackingValue= null

var dmgIncreaseHandler = null
var focusIncreaseHandler = null

var focusCashInMod =null
var damageGaugeCashInMod =null

var profAbilityBarComboProrationMod= null
var profAbilityBarComboLvlProrationMod = null

const DEFAULT_DAMAGE_SCALE = 1
const DAMAGE_IX = 0
const FOCUS_IX = 1


const DAMAGE_NORMALIZATION_LOWER_BOUND = 10
const DAMAGE_NORMALIZATION_UPPER_BOUND = 60

const PRORATION_NORMALIZATION_LOWER_BOUND = 0.5
const PRORATION_NORMALIZATION_UPPER_BOUND = 1.5

const MAXIMUM_ABILITY_FEED_PRORATION_MOD = 2.5
const MINIMUM_ABILITY_FEED_PRORATION_MOD = 1

const MAX_PRORATION_COMBO_LENGTH = 14
#used ot offset proration when ablity canceling occurs
var dmgComboLevelForLastAbilityCancel = 0
var focusComboLevelForLastAbilityCancel = 0
#var comboLengthForLastAbilityCancel = 0
var setbackCounter = 0

#var blockHitStunStringLength = 1

#first element is filler, since combos are always >=1, and used as index to loojup in arrays
const gettingHitFocusDecrease = [0,0.02,0.02,0.1,0.03,0.03,0.2,0.06,0.06,0.3,0.08,0.08,0.4,0.1,0.1,0.5,0.12,0.12,0.6]
#const hittingFocusIncrease = [0,0.05,0.05,0.1,0.06,0.06,0.15,0.07,0.07,0.25,0.1,0.1,0.35,0.12,0.12,0.5,0.15,0.15,0.8,0.2]#note that 1st element unused
const hittingFocusIncrease = [0,0.015,0.015,0.15,0.03,0.03,0.35,0.05,0.05,0.5,0.08,0.08,0.75,0.1,0.1,1,0.12,0.12,1.3,0.15]#note that 1st element unused
#const gettingHitDmgCapDecrease=[0,0.01,0.01,0.04,0.02,0.02,0.06,0.04,0.04,0.09,0.06,0.06,0.15,0.07,0.07,0.3,0.1,0.1,0.8,0.2,0.2]
const gettingHitDmgCapDecrease=[0,0.015,0.015,0.1,0.025,0.025,0.325,0.04,0.04,0.375,0.05,0.05,0.5,0.06,0.06,0.65,0.075,0.075,0.9,0.1,0.1]
const hittingDmgIncrease = [0,0.03,0.03,0.2,0.05,0.05,0.65,0.08,0.08,0.75,0.1,0.1,1.0,0.12,0.12,1.3,0.15,0.15,1.8,0.2]#note that 1st element unused
#const gettingHitDmgCapDecrease=[0.01,0.01,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1,0.11,0.15,0.2,0.3,0.45,0.6,0.8,1]


const comboLengthDmgProrationMods= [
		DEFAULT_DAMAGE_SCALE,#1
		DEFAULT_DAMAGE_SCALE,#2
		DEFAULT_DAMAGE_SCALE,#3
		DEFAULT_DAMAGE_SCALE,#4
		0.95,#5
		0.9,#6
		0.85,#7
		0.8,#8
		0.75,#9
		0.7,#10
		0.65,#11
		0.6,#12
		0.55,#13
		0.45,#14
		0.35,#15
		0.2,#16
		0.12,#17
		0.05]#18 +


const comboLengthAbilityFeedProrationMods= [
		GLOBALS.DEFAULT_ABILITY_REGEN_SCALE,#1
		1,#2	
		1,#3	
		1,#4	
		1,#5	
		1,#6
		1,#7	
		1,#8	
		1,#9
		1.15]#10+


		
#var blockStunStringLocked = false
#const DAMAGE_AMOUNT_INCREASE_MOD= 3 #3 TIMES faster to increase damage than it is to reduce it, helping the agro player

#const FOCUS_INCREASE_MOD= 2 #2 TIMES faster to increase focus than it is to reduce it, helping the agro player

const PARTIAL_SETBACK_TYPE = 0
const TOTAL_SETBACK_TYPE = 1

var dmgProrationTracker = 0.0

#TODO: make abilityFeedProrationTracker THE same as dmgProrationTracker, and just change the  comboLengthAbilityFeedProrationMods table's entries
#cause right now it's confusing. The trackers are based on damage delath but scale differelty
var abilityFeedProrationTracker = 0.0

var attackClassProrationMap={}

var ripostProrationSetbackEnabled=false
var neutralRipostNumHitsSetBack =0
	
func _ready():	
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func reset():
	
	generatingFocusFlag = false
	generatingDamageGaugeFlag = false
	#used ot offset proration when ablity canceling occurs
	dmgComboLevelForLastAbilityCancel = 0
	focusComboLevelForLastAbilityCancel = 0
	
	ripostProrationSetbackEnabled=false
	neutralRipostNumHitsSetBack =0

	setbackCounter = 0
	
	dmgProrationTracker = 0.0
	
	
	abilityFeedProrationTracker = 0.0

	
	hitstunProration.reset()
	
func init(_playerController,_playerState,_damageGaugeRateMode,_damageGaugeComboLevelUpModIncrease,_focusRateMode,_focusComboLevelUpModIncrease,_focusCashInMod,_damageGaugeCashInMod,_profAbilityBarComboProrationMod,_profAbilityBarComboLvlProrationMod,_histunAbilityCancelProrationReductionRate,_abCancel_SpamProrationSetback):
	playerState = _playerState
	damageGaugeRateMode = _damageGaugeRateMode
	damageGaugeComboLevelUpModIncrease=_damageGaugeComboLevelUpModIncrease
	#focusRateMode=_focusRateMode
	#focusComboLevelUpModIncrease=_focusComboLevelUpModIncrease
	initialDamageGaugeTrackingValue =playerState.damageGauge
	#initialFocusTrackingValue= playerState.focus
	dmgIncreaseHandler =$DamageAmountIncreaseHandler
#	focusIncreaseHandler = $FocusAmountIncreaseHandler
	profAbilityBarComboProrationMod=_profAbilityBarComboProrationMod
	profAbilityBarComboLvlProrationMod=_profAbilityBarComboLvlProrationMod
#	focusCashInMod =_focusCashInMod
	damageGaugeCashInMod =_damageGaugeCashInMod

	hitstunProration = hitstunProrationResource.new()	
	self.add_child(hitstunProration)
	
	attackClassProrationMap[GLOBALS.PRORATION_DAMAGE_CLASS_LIGHT]= 1.25 # 25% more proration for lights attacks
	attackClassProrationMap[GLOBALS.PRORATION_DAMAGE_CLASS_MEDIUM]= 1.1 # 10% more proration for medium attacks
	attackClassProrationMap[GLOBALS.PRORATION_DAMAGE_CLASS_HEAVY]= 1 # 0% more proration for heavy attacks
	
	
	hitstunProration.init(_histunAbilityCancelProrationReductionRate,MAX_PRORATION_COMBO_LENGTH,_playerController.actionAnimeManager.spamHitstunProrationSpriteAnimeIdRemap,_abCancel_SpamProrationSetback,_playerController.actionAnimeManager.customSpamProrationAttackMap)
	_playerController.connect("attack_hit",hitstunProration,"_on_combo_hit")
	

	
	
	_playerController.opponentPlayerController.playerState.connect("changed_in_hitstun",self,"_on_opponent_hitstun_changed")
	

	#_playerController.connect("starting_new_combo",dmgIncreaseHandler,"_on_combo_started")
	#_playerController.connect("starting_new_combo",focusIncreaseHandler,"_on_combo_started")
	
	_playerController.connect("attack_type_hit",dmgIncreaseHandler,"_on_hit")
	_playerController.connect("attack_type_hit",self,"_on_hit")
	
	_playerController.opponentPlayerController.playerState.connect("changed_in_hitstun",dmgIncreaseHandler,"_on_opponent_hitstun_changed")
	
	_playerController.connect("combo_ended",self,"_on_combo_ended")
	
	#_playerController.connect("attack_type_hit",focusIncreaseHandler,"_on_hit")
	#_playerController.opponentPlayerController.playerState.connect("changed_in_hitstun",focusIncreaseHandler,"_on_opponent_hitstun_changed")
	
	dmgIncreaseHandler.connect("reset_bar_amount_increase_process",self,"_on_reset_bar_increase_process",[DAMAGE_IX])
	#focusIncreaseHandler.connect("reset_bar_amount_increase_process",self,"_on_reset_bar_increase_process",[FOCUS_IX])
	
	dmgIncreaseHandler.connect("bar_amount_increased",self,"increaseDamageGauge")
	#focusIncreaseHandler.connect("bar_amount_increased",self,"increaseFocus")
	

func applyComboLevelProration(dmgLvl,focusLvl):
	
	#the largest combo level
	#var maxComboLvl=max(focusLvl,dmgLvl)
	
	if dmgLvl!=0:
		#biggest combo level is used as proration mod
		applyDmgComboLevelProration(dmgLvl)
		#applyFocusComboLevelProration(maxComboLvl)


func neutralRipostProrationSetback(_neutralRipostNumHitsSetBack):
	ripostProrationSetbackEnabled=true
	neutralRipostNumHitsSetBack =_neutralRipostNumHitsSetBack
	hitstunProration.neutralRipostProrationSetback(_neutralRipostNumHitsSetBack)
	
func _on_combo_level_changed(lvl):
	#since combo level only increases or is set to 0, 
	#if its not 0, it increased
	if lvl != 0:
	
		#at higher combo levels, damage increase rate is higher
		#we do lvl -1 since want to calculate the damage pre-level up
		#basically, start at combo level 0 ,then 1
		var additionalDamageMod = (damageGaugeRateMode  * (lvl-1))
			
		#increase the damage gauge which also increased by a factor as combo level increases
		playerState.increaseDamageGaugeCapacity(damageGaugeComboLevelUpModIncrease + additionalDamageMod)
		
		dmgIncreaseHandler._on_combo_level_up()
		
		
		#update the combo level proration
		applyComboLevelProration(lvl,playerState.focusComboLevel)
		
		#increase number of empty damage stars
		playerState.increaseNumEmptyDmgStars()
		
		#can't be performing a fill combo when levelup up combo
		playerState.clearFillComboSubLevel()
	

	

#gotta change this function to dmagae combo, or add a type parameters
func _on_focus_combo_level_changed(lvl):
	pass
	#since combo level only increases or is set to 0, 
	#if its not 0, it increased
	#if lvl != 0:
		
		#at higher combo levels, damage increase rate is higher
	#	var additionalFocus = (focusRateMode  * (lvl-1))
			
		#increase the damage gauge which also increased by a factor as combo level increases
	#	playerState.increaseFocusCapacity(focusComboLevelUpModIncrease + additionalFocus)
		
	#	focusIncreaseHandler._on_combo_level_up()
		
		#update the combo level proration
	#	applyComboLevelProration(playerState.comboLevel,lvl)
	#	applyFocusComboLevelProration(lvl)
				

func resetProration():
	#reset proration (back to 100% (1) of damage is applied on hit)
	playerState.damageScale = 1
	playerState.comboLevelDamageScale = 1
	playerState.abilityRegenScale = 1 
	playerState.comboLevelabilityRegenScale = 1
	hitstunProration.reset()
	#hitstunProration.resetConsecutiveHitProration()
	
	
func applyDmgComboLevelProration(lvl):

	#offset the proration (ability canceling resets proration to 0)
	var effectiveLvl = max(lvl - dmgComboLevelForLastAbilityCancel,0)
	#no more damage proration on combo lvl
	match(effectiveLvl):
		0:
			playerState.comboLevelDamageScale=1
		1:
			#playerState.comboLevelDamageScale=0.95
			playerState.comboLevelDamageScale=1
		2:
			#playerState.comboLevelDamageScale=0.9 # 
			playerState.comboLevelDamageScale=1
		3:
			#playerState.comboLevelDamageScale=0.85 # 
			playerState.comboLevelDamageScale=1
		4:
			#playerState.comboLevelDamageScale=0.8 
			playerState.comboLevelDamageScale=1
		_:#more than 4 is 3% of damage
			#playerState.comboLevelDamageScale=0.75
			playerState.comboLevelDamageScale=1
	
func applyFocusComboLevelProration(lvl):
	pass

	


#called when player ability cancels
func _on_ability_cancel(currDmgComboLevel,currFocusComboLevel,currComboLength,autoAbilityCancelFlag):
	
	#ignore autoability cancels in terms of proration
	if autoAbilityCancelFlag:
		return
	
	setbackProration(currDmgComboLevel,currFocusComboLevel,currComboLength,PARTIAL_SETBACK_TYPE)
	hitstunProration._on_ability_cancel()

#called when opponent player ability cancels
func _on_opponent_ability_cancel(currDmgComboLevel,currFocusComboLevel,currComboLength,autoAbilityCancelFlag):
	pass
	#blockHitStunStringLength = blockHitStunStringLength + 1


	
func setbackProrationCompletly(currDmgComboLevel,currFocusComboLevel,currComboLength):
	setbackProration(currDmgComboLevel,currFocusComboLevel,currComboLength,TOTAL_SETBACK_TYPE)
	
#this will offset the proration during a combo, either partially (when setbacktype = PARTIAL_SETBACK_TYPE)
#or completly (when setbacktype = TOTAL_SETBACK_TYPE)
func setbackProration(currDmgComboLevel,currFocusComboLevel,currComboLength, setbacktype):
	
	if setbacktype ==PARTIAL_SETBACK_TYPE:
		
		#is the issue that combo level = 0 most of the time even after level up mid combo?
		setbackCounter = setbackCounter + 1
		#here, do logic to apply proration modifier based on ability modifier
		#keep track of current combo numbers to offset he proration
		#we tak minimum, since we want to limit how much poration is reset
		#from an ability cancel (if currComboLevel == profAbilityBarComboLvlProrationMod, reset 100%
		#and if profAbilityBarComboLvlProrationMod = 0, reset 0%)
		#hmm, now the proration resets completly.....
		dmgComboLevelForLastAbilityCancel = min(currDmgComboLevel,profAbilityBarComboLvlProrationMod*setbackCounter)
	
		#comboLengthForLastAbilityCancel = min(currComboLength,profAbilityBarComboProrationMod*setbackCounter)
		
		#remove proration, minimum 0
		dmgProrationTracker = max(0, dmgProrationTracker-profAbilityBarComboProrationMod)
		abilityFeedProrationTracker =max(0, abilityFeedProrationTracker-profAbilityBarComboProrationMod)
		
	elif setbacktype ==TOTAL_SETBACK_TYPE:
		dmgComboLevelForLastAbilityCancel = currDmgComboLevel
	
		#comboLengthForLastAbilityCancel = currComboLength
		#reset proration tracker
		dmgProrationTracker = 0.0
		abilityFeedProrationTracker=0.0
	else:
		print("warning, unkwonw setback type in setbackProration : "+str(setbacktype))
		return
	
	#apply the proration scaling so the ui updates the proration bars
	applyDmgComboLevelProration(currDmgComboLevel)
	#applyFocusComboLevelProration(currFocusComboLevel)
	
	
	
	
	#var dmgProrationIx = int(round(dmgProrationTracker))
	#applyComboLengthDamageProration(dmgProrationIx)
	applyComboLengthDamageProration(dmgProrationTracker,null)
	#var abilityFeedProrationIx = int(round(abilityFeedProrationTracker))
	#applyComboLengthAbilityFeedProration(abilityFeedProrationIx)
	applyComboLengthAbilityFeedProration(abilityFeedProrationTracker)


#called when a combo lands. Here some proration and
#other book keeping based on combo length will be done
func _on_combo_hit(combo,dmgProration,abilityFeedProration,hitbox):
	
	#negative proration isn't supported, minimum is 0 (not affecting proration)
	
	#neutral riposting gives your combo extended hits before proration kicks in
	if ripostProrationSetbackEnabled:
		combo = max(0,combo-neutralRipostNumHitsSetBack)#minimum 0 combo
	
	
	if dmgProration < 0:
		dmgProration = 0
	if abilityFeedProration < 0:
		abilityFeedProration = 0
			
	#starting new combo?
	if combo == 1:
		#reset proration tracker
		dmgProrationTracker = 0.0
		abilityFeedProrationTracker=0.0
		
	#keep track of proration amount, and avoid exceeding max number hit before saturated proration
	#to make it possible to ability cancel and get value at max proration
	dmgProrationTracker = min(MAX_PRORATION_COMBO_LENGTH,dmgProrationTracker + dmgProration)
	abilityFeedProrationTracker=min(MAX_PRORATION_COMBO_LENGTH,abilityFeedProrationTracker + abilityFeedProration)
	
	
	#convert proration an index to lookup proration rates (minimum 0 ix)
	#var dmgProrationIx = int(round(dmgProrationTracker))
	#applyComboLengthDamageProration(dmgProrationIx)
	#hitbox might be null when we counter ripost
	if hitbox != null:
		
		if hitbox.belongsToProjectile(): 
			#add the proration id offset for projectlies so their proration can be stored in same map as normal animations
			applyComboLengthDamageProration(dmgProrationTracker,hitbox.spriteAnimation.id+GLOBALS.PROJECTILE_SPRITE_ANIME_ID_PRORATION_TRACKING_OFFSET)
		else:
			applyComboLengthDamageProration(dmgProrationTracker,hitbox.spriteAnimation.id)
	

	
	
	#var abilityFeedProrationIx = int(round(abilityFeedProrationTracker))
	#applyComboLengthAbilityFeedProration(abilityFeedProrationIx)
	applyComboLengthAbilityFeedProration(abilityFeedProrationTracker)
	
	




	
	
const DMG_PRORATION_TRACKER_EPSILON =  0.01
func applyComboLengthDamageProration(_dmgProrationTracker,attackSpriteAnimeId):	
	var _dmgScale = GLOBALS.interpolateFromNumbericalArray(_dmgProrationTracker,comboLengthDmgProrationMods,DMG_PRORATION_TRACKER_EPSILON)	
	
	if attackSpriteAnimeId!= null:
		#apply spamming attack damage proration
		var mod = hitstunProration.getSpamDamageProrationMod(attackSpriteAnimeId)
		playerState.damageScale=mod*_dmgScale
	else:
		playerState.damageScale =_dmgScale
	

		
func old_applyComboLengthDamageProration(dmgProrationIx):	
	
	#offset the proration (ability canceling resets proration to 0)
	#var effectiveCombo = max(combo - comboLengthForLastAbilityCancel,1)
	
	
	#ability reneration of opponent increases as combo gets long
	#damage will go down as combo goes down
	match(dmgProrationIx):
		0:
			playerState.damageScale=DEFAULT_DAMAGE_SCALE
		1:
			playerState.damageScale=DEFAULT_DAMAGE_SCALE
		2:
			playerState.damageScale=DEFAULT_DAMAGE_SCALE
		3:
			playerState.damageScale=DEFAULT_DAMAGE_SCALE
		4:
			playerState.damageScale=0.95
		5:
			playerState.damageScale=0.9
		6:
			playerState.damageScale=0.85
		7:
			playerState.damageScale=0.8
		8:
			playerState.damageScale=0.75
		9:
			playerState.damageScale=0.7
		10:
			playerState.damageScale=0.65
		11:
			playerState.damageScale=0.5
		12:
			playerState.damageScale=0.3
		13: 
			playerState.damageScale=0.15
		_: # more than 13 hit combo
			playerState.damageScale=0.05

	
func applyComboLengthAbilityFeedProration(_prorationTracker):				
	var _abilityRegenScale = GLOBALS.interpolateFromNumbericalArray(_prorationTracker,comboLengthAbilityFeedProrationMods,DMG_PRORATION_TRACKER_EPSILON)	
	playerState.abilityRegenScale =_abilityRegenScale	


func oldapplyComboLengthAbilityFeedProration(prorationIx):	
	
	match(prorationIx):
		0:
			playerState.abilityRegenScale=GLOBALS.DEFAULT_ABILITY_REGEN_SCALE
		1:
			playerState.abilityRegenScale=1
		2:
			playerState.abilityRegenScale=1
		3:
			playerState.abilityRegenScale=1
		4:
			playerState.abilityRegenScale=1
		5:
			playerState.abilityRegenScale=1
		6:
			playerState.abilityRegenScale=1
		7:
			playerState.abilityRegenScale=1
		8:
			playerState.abilityRegenScale=1
		_: # more than 8 hit combo
			playerState.abilityRegenScale=1.15



func increaseDamageGauge(combo):

	var damageDiff = playerState.damageGaugeCapacity - initialDamageGaugeTrackingValue

	#don't increase damage passed capaicty
	if damageDiff <= 0:
		return
		
	
	var increaseAmount = 0
	var nextHitIncreaseAmount=0
	
	#determine how much to increase damage gauge given combo
	if combo >= hittingDmgIncrease.size():
		increaseAmount=hittingDmgIncrease[hittingDmgIncrease.size()-1]#last element is max increase
	else:
		increaseAmount=hittingDmgIncrease[combo]
	
	#determine how much to increase damage gauge next hit given combo
	var comboNextHit = combo+1
	if comboNextHit >= hittingDmgIncrease.size():
		nextHitIncreaseAmount=hittingDmgIncrease[hittingDmgIncrease.size()-1]#last element is max increase
	else:
		nextHitIncreaseAmount=hittingDmgIncrease[comboNextHit]
		
	#damage increase at a rate depending on damage decrease
	#increaseAmount = DAMAGE_AMOUNT_INCREASE_MOD*increaseAmount*damageGaugeCashInMod
	increaseAmount = increaseAmount*damageGaugeCashInMod
	nextHitIncreaseAmount = nextHitIncreaseAmount*damageGaugeCashInMod
	
	playerState.damageGaugeNextHit =min (playerState.damageGaugeCapacity , playerState.damageGauge+increaseAmount+nextHitIncreaseAmount)
	playerState.damageGauge = min (playerState.damageGaugeCapacity , playerState.damageGauge+increaseAmount)
	
	
	#var amountToIncrease = damageDiff*increaseAmountFraction
	
	#playerState.damageGauge += amountToIncrease


func increaseFocus(combo):
	return
	pass
#	var focusDiff = playerState.focusCapacity -initialFocusTrackingValue

	#don't increase damage passed capaicty
#	if focusDiff <= 0:
	#	return
		
	
#	var increaseAmountFraction = 0
	# numberr of combos deterines focus gained
	#longer the combo, more focus gained
	#the fraction is fraction of focus t gain
	#with respect to the difference between
	#capacity and amoutn of gauage
	#this way, higher capacity damae gauage (obtained from high combo level ups)
	#means more damage gain per hit
#	match(combo):
#		0:
#			increaseAmountFraction=0
#		1:
#			increaseAmountFraction= 0.025
#		2:
#			increaseAmountFraction = 0.05
#		3:
#			increaseAmountFraction  = 0.08
#		4:
#			increaseAmountFraction  = 0.1
#		5:
#			increaseAmountFraction  =  0.15
#		6:
#			increaseAmountFraction  =  0.17	
#		7:
#			increaseAmountFraction  = 0.2
#		8:
#			increaseAmountFraction  = 0.23
#		9:
#			increaseAmountFraction  = 0.25
#		10:
#			increaseAmountFraction  = 0.3
#		11:
#			increaseAmountFraction  = 0.32
#		12:
#			increaseAmountFraction  = 0.35
#		_: # everything eslse maxes out guagae
#			increaseAmountFraction  = 0.37
			
	
	
	#var amountToIncrease =focusCashInMod*focusDiff*increaseAmountFraction
	
	#var focusDiff = playerState.focusCapacity -initialFocusTrackingValue

	#don't increase focus passed capaicty
	#if focusDiff <= 0:
	#	return


	#var amountToIncrease = 0
	#var amountToIncreaseNextHit = 0
	
	#if combo >= hittingFocusIncrease.size():
		
	#	amountToIncrease = hittingFocusIncrease[hittingFocusIncrease.size()-1]#last element is most incrase
	#else:
	#	amountToIncrease = hittingFocusIncrease[combo]
	
	
	#var nextHitCombo= combo+1
	#if nextHitCombo >= hittingFocusIncrease.size():
		
	#	amountToIncreaseNextHit = hittingFocusIncrease[hittingFocusIncrease.size()-1]#last element is most increase
	#else:
	#	amountToIncreaseNextHit = hittingFocusIncrease[nextHitCombo]
	
	
	#amountToIncrease = amountToIncrease*focusCashInMod
	#amountToIncreaseNextHit = amountToIncreaseNextHit*focusCashInMod
	
	#amountToIncrease = FOCUS_INCREASE_MOD  * amountToIncrease
	#playerState.focusNextHit = min(playerState.focusCapacity,playerState.focus + amountToIncrease+amountToIncreaseNextHit)
	#playerState.focus = min(playerState.focusCapacity, playerState.focus+amountToIncrease)
		

#called when hitting player
func _on_hit(attackType,victimHurtboxSubClass,affectBarIncreaseProrationFlag):
#func _on_hit(meleeFlag,specialFlag,toolFlag,victimHurtboxSubClass,affectBarIncreaseProrationFlag):

	
	
	#so this is required, since if a combo hasn't started
	#but the bar capacities have increase, the starting combo
	#functon, which starts the focus/dmg increase, won't happend. especially for budgetg block
	manageAmountBarIncreaseFlags()
	
func _on_starting_new_combo():
	#playerState.combo = 1
	playerState.comboDamage = 0
	
	dmgComboLevelForLastAbilityCancel = 0

#	comboLengthForLastAbilityCancel = 0

	setbackCounter = 0
	#here, we decide if we will start generating damage gauage
	#only build damage from combos if the damage gauage capacity
	#exceeds current damage gauge amount
	#we don't want to build damage gauage mid combo upon leveling up
	#start generating damage increase from combos
	#if playerState.damageGaugeCapacity > playerState.damageGauge:
	#	generatingDamageGaugeFlag = true
	#	dmgIncreaseHandler.increasingBarFlag=true
	#else:
	#	generatingDamageGaugeFlag = false
	#	dmgIncreaseHandler.increasingBarFlag=false
	
	#same for focus generation
	#if playerState.focusCapacity > playerState.focus:
	#	generatingFocusFlag = true
	#	focusIncreaseHandler.increasingBarFlag=true
	#else:
	#	generatingFocusFlag = false
	#	focusIncreaseHandler.increasingBarFlag=false
	manageAmountBarIncreaseFlags()
	
	
	dmgIncreaseHandler._on_combo_started()
	#focusIncreaseHandler._on_combo_started()
	
	resetProration()

func manageAmountBarIncreaseFlags():
	
	if playerState.damageGaugeCapacity > playerState.damageGauge:
		generatingDamageGaugeFlag = true
		dmgIncreaseHandler.increasingBarFlag=true
	else:
		generatingDamageGaugeFlag = false
		dmgIncreaseHandler.increasingBarFlag=false
	
	#same for focus generation
#	if playerState.focusCapacity > playerState.focus:
#		generatingFocusFlag = true
#		focusIncreaseHandler.increasingBarFlag=true
#	else:
#		generatingFocusFlag = false
#		focusIncreaseHandler.increasingBarFlag=false
		
func _on_reset_bar_increase_process(ix):
	if ix == DAMAGE_IX:
		playerState.damageGenerationComboCount = 0
	#elif ix == FOCUS_IX:
	#	playerState.focusGenerationComboCount = 0
func _on_reached_damage_gauge_capacity(dmgCapacity):
	playerState.damageGenerationComboCount = 0

func _on_reached_focus_capacity(focusCapacity):
	pass
	#playerState.focusGenerationComboCount = 0
	
		
#called when opponent hits this player. 
#reduces focus in a precentage based approach (may change)
func _was_hit_decrease_focus(combo):
	pass
	#var focusDiff = playerState.focus - playerState.defaultFocus

	#don't decrease passed default
	#if focusDiff <= 0:
	#	return
		
#	var amountToDecrease = 0
	
#	if combo >= gettingHitFocusDecrease.size():
		
#		amountToDecrease = gettingHitFocusDecrease[gettingHitFocusDecrease.size()-1]#last element is most dama cap decreate
#	else:
#		amountToDecrease = gettingHitFocusDecrease[combo]

	
	#var amountToDecrease = focusDiff*decreaseAmountFraction
	
	#for now temporary fix of inaccurate default value for next hit
	
	
	#remove from focus, but not more than default
#	var newFocus = max (playerState.focus - amountToDecrease, playerState.defaultFocus)
	#playerState.focusNextHit = newFocus
	#playerState.focus = newFocus
		

#called when opponent hits this player. 
#reduces damage capaicity to a max of damage amount
func _was_hit_decrease_dmg_cap(combo):
	
	var dmgCapDiff = playerState.damageGaugeCapacity - playerState.damageGauge

	#don't decrease passed the damage guage amount
	if dmgCapDiff <= 0:
		return
		
	
	#var amountToDecrease = focusDiff*decreaseAmountFraction
	
	var amountToDecrease = 0

	if combo >= gettingHitDmgCapDecrease.size():
		amountToDecrease = gettingHitDmgCapDecrease[gettingHitDmgCapDecrease.size()-1]#last element most damage decreased
	else:
		amountToDecrease = gettingHitDmgCapDecrease[combo]
	
	#remove from damage capacity, but not more than damage amount
	playerState.damageGaugeCapacity = max (playerState.damageGaugeCapacity - amountToDecrease, playerState.damageGauge)
		

func _on_damage_gauge_changed(oldValue,newValue):
	
	#damage gauaged reduced below the initial tracking value?
	if newValue < initialDamageGaugeTrackingValue:
		#start tracking again
		initialDamageGaugeTrackingValue = newValue
	
func _on_focus_changed(oldValue,newValue):
	pass
	#if newValue < initialFocusTrackingValue:
	#	initialFocusTrackingValue = newValue
	
	
func _on_damage_gauge_capacity_changed(oldValue,newValue):

	#decreaseing the capacity?
	if oldValue < newValue:
		
		if initialDamageGaugeTrackingValue > newValue:
			initialDamageGaugeTrackingValue= newValue
		
	
func _on_focus_capacity_changed(oldValue,newValue):
	#decreaseing the capacity?
	#if oldValue < newValue:
		
	#	if initialFocusTrackingValue > newValue:
	#			initialFocusTrackingValue= newValue
		
	pass
	

	
# called when the circular progress bar appears for first time after a combo
func updateDamageGaugeNextHit_nextCombo():
	#update the damage gauge on next hit for fresh combo
	var combo = 0 #first hit of a combo
	#var damageDiff = playerState.damageGaugeCapacity - initialDamageGaugeTrackingValue
		
	var nextHitIncreaseAmount=0
	
	nextHitIncreaseAmount=hittingDmgIncrease[combo]

	nextHitIncreaseAmount = nextHitIncreaseAmount*damageGaugeCashInMod
	
	playerState.damageGaugeNextHit = min (playerState.damageGaugeCapacity , playerState.damageGauge+nextHitIncreaseAmount)

# called when the circular progress bar appears for first time after a combo	
func updateFocusNextHit_nextCombo():
	pass
	#update the focus on next hit for fresh combo
	#var combo = 0 #first hit of a combo
	#var damageDiff = playerState.focusCapacity - initialFocusTrackingValue
		
	#var nextHitIncreaseAmount=0
	
	#nextHitIncreaseAmount=hittingFocusIncrease[combo]

	#nextHitIncreaseAmount = nextHitIncreaseAmount*focusCashInMod
	
	#playerState.focusNextHit =  min (playerState.focusCapacity , playerState.focus+nextHitIncreaseAmount)
	
	
	
func _on_opponent_hitstun_changed(inHitStunFlag):
	
	#opponent longer in hitstun (our combo ended)?
	if not inHitStunFlag:
		hitstunProration._on_combo_ended()
		playerState.clearFillComboSubLevel() 
		#reset proration tracker
		dmgProrationTracker = 0.0
		abilityFeedProrationTracker=0.0
		
func hardResetProration():
	#reset proration tracker
	dmgProrationTracker = 0.0
	abilityFeedProrationTracker=0.0
	resetProration()
	hitstunProration.resetHitstunProration()


#func getHitstunProrationMod(hitbox):
#	return hitstunProration.getHitstunProrationMod(hitbox)

func getHitstunProrationMod(attackSpriteAnimeId,isMeatyHitbox):
	return hitstunProration.getHitstunProrationMod(attackSpriteAnimeId,isMeatyHitbox)

func getSpamDamageProrationMod():
	return hitstunProration.getSpamDamageProrationMod()
	
#func resetBlockHistunComboString():
	
	#reset block tun combo length (first hit making you go into block hitstun)
#	blockHitStunStringLength=1
#	blockStunStringLocked=false
	
	
func fetchElement(arr,ix):
			
	if ix >= arr.size():
		ix = arr.size()-1
		
	if ix < 0:
		return null
		
	return arr[ix]

func was_hit_remove_empty_star():
	#decrease number of empty damage stars
	#can't decreased passed number of filled stars
	
	
	playerState.decreaseNumEmptyDmgStars()
	
	
func _on_fill_combo_sub_level_changed(old,new):
	
	#fill combo level?
	if new == 3:
		
		#fill an empty dmg star (if it exists)
		if playerState.numEmptyDmgStars>0:
			emit_signal("filled_combo_level_up")
			playerState.increaseNumFilledDmgStars()
			#playerState.decreaseNumEmptyDmgStars()
			#reset fill combo progress
			playerState.clearFillComboSubLevel()
			
			
			
func _on_combo_ended():
	#reset the damage and ability feed modifiers to avoid having 1st hit of
	#combo affected by last combo's proration
	playerState.damageScale=DEFAULT_DAMAGE_SCALE
	playerState.abilityRegenScale=GLOBALS.DEFAULT_ABILITY_REGEN_SCALE
	
	
	
func computeDamageProrationMod(hitbox):
	
	if hitbox == null:
		return 0
	
	#no proration for this hitbox?
	if hitbox.dmgProratrion == 0:
		return 0
		
#	const PRORATION_NORMALIZATION_LOWER_BOUND = 0.5
#const PRORATION_NORMALIZATION_UPPER_BOUND = 1.5
#const MAXIMUM_ABILITY_FEED_PRORATION_MOD = 2.5
#const MINIMUM_ABILITY_FEED_PRORATION_MOD = 1
	# Now, we pretend to have forgotten the original ratio and want to get it back.
	#var ratio = inverse_lerp(20, 30, 27.5)
	# `ratio` is now 0.75.
#	const  = 10
#const MAXIMUM_DAMAGERORATION_LERP = 60

	#convert damage into bounds by minimum and  maxm damage moves tend to do
	var dmg = clamp(hitbox.damage,DAMAGE_NORMALIZATION_LOWER_BOUND,DAMAGE_NORMALIZATION_UPPER_BOUND)
	var dmgRatio = inverse_lerp(DAMAGE_NORMALIZATION_LOWER_BOUND,DAMAGE_NORMALIZATION_UPPER_BOUND,dmg)
	
	#damage ration from 0 to 1 to how much proration it does
	
	
	
	#var middle = lerp(20, 30, 0.75)
# `middle` is now 27.5.

	
	var baseProration =lerp(PRORATION_NORMALIZATION_LOWER_BOUND,PRORATION_NORMALIZATION_UPPER_BOUND,dmgRatio)
	
	#we also want lights to have more proration
	#for example, heavies after doing like 20% of HP proration kill syou damage, 
	#while for like 13-15 % of damage before proration kicks in
	#since it's harder to land heavies than it is for lights
	
	#so the lightest move do 25% more proration than heavies, while proration is still linear with
	#the amount of damage
	#var prorationMod = lerp(1.25,1, dmgRatio)
	var attackClassProrationMod = attackClassProrationMap[hitbox.dmgProrationClass]
	
	#return baseProration * prorationMod
	var res =  baseProration * attackClassProrationMod
	return res

func computeAbilityFeedProrationMod(hitbox):
	
	if hitbox == null:
		return 0
	
	#no proration for this hitbox?
	if hitbox.abilityFeedProrationMod == 0:
		return 0
		
#	const PRORATION_NORMALIZATION_LOWER_BOUND = 0.5
#const PRORATION_NORMALIZATION_UPPER_BOUND = 1.5
#const MAXIMUM_ABILITY_FEED_PRORATION_MOD = 2.5
#const MINIMUM_ABILITY_FEED_PRORATION_MOD = 1
	# Now, we pretend to have forgotten the original ratio and want to get it back.
	#var ratio = inverse_lerp(20, 30, 27.5)
	# `ratio` is now 0.75.
#	const  = 10
#const MAXIMUM_DAMAGERORATION_LERP = 60

	#convert damage into bounds by minimum and  maxm damage moves tend to do
	var dmg = clamp(hitbox.damage,DAMAGE_NORMALIZATION_LOWER_BOUND,DAMAGE_NORMALIZATION_UPPER_BOUND)
	var dmgRatio = inverse_lerp(DAMAGE_NORMALIZATION_LOWER_BOUND,DAMAGE_NORMALIZATION_UPPER_BOUND,dmg)
	
	#damage ration from 0 to 1 to how much proration it does
	
	
	
	#var middle = lerp(20, 30, 0.75)
# `middle` is now 27.5.

	return lerp(MINIMUM_ABILITY_FEED_PRORATION_MOD,MAXIMUM_ABILITY_FEED_PRORATION_MOD,dmgRatio)
	
	
func _on_opponent_entered_block_stun(attackerHitbox,blockResult,spriteFacingRight):
	resetProration()