extends Node

#var input_manager = preload("res://input_manager.gd")
const GLOBALS = preload("res://Globals.gd")
const DEFAULT_PRORATION_MOD = 1.0
const DEFAULT_ATTACK_HIT_FREQUENCY = 0

const SPAM_PRORATION_WINDOW_SIZE = 6
const NO_PRORATION_BASIC_HITSTUN_MOD = 0
const NO_PRORATION_MEATY_HITSTUN_MOD=1.0
#const MINIMUM_HITSTUN_MOD= 0.05 # 5% of orignal histun
const MINIMUM_HITSTUN_MOD= -10000 # no limit on how bad the hitstun can get when spamming a move

#map that stores the modifiers of the histun propration for each attack animation
var spamHSProrationMap = {}

#stores number of times a attack animation was consecutive hit while considering
#other hits
#e.g.:  n-melee, n-melee, n-melee : n-melee  -> 3
#e.g.:  n-melee, n-melee, u-melee : n-melee  -> 2, u-melee -> 1
#e.g.:  n-melee, n-melee, u-melee, u-melee : n-melee  -> 1, u-melee -> 2
#e.g.:  n-melee, n-melee, u-melee, u-melee n-melee: n-melee  -> 2, u-melee -> 1
#e.g.:  n-melee, n-melee, u-melee, u-melee n-melee, b-melee: n-melee  -> 1, u-melee -> 0, b-melee ->1
var concecutiveHitMap = {} 

#inidcates how much modifier is lost (proration increases means les hitstun) after consecutive hits
#start counting at 0, since first hit of comb0 is 1, so index resolves to 1, not 0
#note that both below have to be same length
#var hsProrationModIncreases = [0,0.1,0.3,0.25,0.35,0.45,0.65,0.75] #1,0.9,0.6,.0.35,0,-0.05,-0.1,-0.25,-0.5,-0.75,-1,-1.5,-2,-3,-5
var hsProrationModIncreases = [0,0.1,0.3,0.25,0.35,0.4,
0.45,0.5,0.55,0.6,
0.65,0.7,0.75,0.8,0.85,0.9,0.95,1,1.05,
1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2,2.2,2.4,2.6,2.8,3,4,5,6,8,10,15,25,35] 

var hsProrationModDecreases = [0,0.02,0.01,0.0005,0.00025,0.000125,0.000125,0.000125]

#this was the poration mods used when we had hitstun proration for any combo
#var basicHSProrationMod = [1.0,1.0,1.0,0.97,0.95,0.92,0.88,0.83,0.78,0.7,0.65,0.6,0.55,0.5,0.45,0.4,0.35,0.3,0.25,0.2,0.15,0.1,0.05]
#this was proration mods used when no hitstun proration used
#var basicHSProrationMod = [1.0,1.0,1.0]#all 1 since no more proration the longer the combo is

#this is hitstun proration mods AFTER we reach max damage proration (will be dynamically filled with 1s to avoid any hitstun
#proration before reach end of combo)
#the first few hits don't have hitstun proratio nto give players a momentum to
#decide how to finish their combo once they see damage proration maxed out 
var meatyHSProrationMod= [1,1,1,1,0.9,0.85,0.8,0.7,0.6,0.45,0.3,0.15,0.05,0.01]  
var basicHSProrationMod= [0,0,0,0,-5,-10,-15,-25,-45,-60,-80,-100,-150,-300,-500,-1000]  

const PRORATION_INC_IX = 0
const PRORATION_DEC_IX = 1
var hsProrationModIncDec = [hsProrationModIncreases,hsProrationModDecreases]

#counts effective hits (supports fraction of hits) to be used to generate index for how much proratio modifier is up to
var prorationTracker = 0.0

var abCancel_SpamProrationSetback= null
var abilityCancelProrationReductionRate = 0

var spamHitstunProrationSpriteAnimeIdRemap = null

#new proration system
const SPAM_MEATY_HITSTUN_MOD_LIST_IX=0
const SPAM_BASIC_HITSTUN_MOD_LIST_IX=1
const SPAM_DMG_MOD_LIST_IX=2
var attackHitMovingWindow = []
var defaultMeatyHSSpamProrationMods = [1,0.9,0.75,0.55,0.35,0.15,0.05,0.005,0.0005,0.00005,0.000005,0.00000005]
var defaultBasicHSSpamProrationMods = [0,-1,-5,-35,-70,-150,-300]#how many frames to remove from the hitstun
var defaultDmgSpamProrationMods = [0.95,0.9,0.85,0.8,0.75,0.7,0.65,0.6] # for damage don't start at one since dcamage calcuated such that i think attack sisn't in window when first hits
var defaultModLists=[defaultMeatyHSSpamProrationMods,defaultBasicHSSpamProrationMods,defaultDmgSpamProrationMods]
#keys is sprite aniamtion id, values is a 2 element array containing 1 list in each cell, one list for
#the hitstun proration mods for the moves, other list is for damage mods
var customSpamProrationAttackMap = {}

var ripostProrationSetbackEnabled=false
var neutralRipostNumHitsSetBack =0


func _ready():
	
	
	pass # Replace with function body.
	
#dmgProrationHitCountLimit: the number of hits before damage proration maxes out to make damage virtually null
func init(_abilityCancelProrationReductionRate,dmgProrationHitCountLimit,_spamHitstunProrationSpriteAnimeIdRemap,_abCancel_SpamProrationSetback,_customSpamProrationAttackMap):
	abilityCancelProrationReductionRate= _abilityCancelProrationReductionRate	
	spamHitstunProrationSpriteAnimeIdRemap = _spamHitstunProrationSpriteAnimeIdRemap
	abCancel_SpamProrationSetback =_abCancel_SpamProrationSetback
	customSpamProrationAttackMap = _customSpamProrationAttackMap
	#fill the proration mods to make sure first prorations before max combo length
	#don't affect combos
	for i in range(0,dmgProrationHitCountLimit):
		meatyHSProrationMod.push_front(NO_PRORATION_MEATY_HITSTUN_MOD)
		basicHSProrationMod.push_front(NO_PRORATION_BASIC_HITSTUN_MOD)
		
		
	
	#e.g.: meatyHSProrationMod = [0.9,0.85,0.7,...]
	#would become [1,1,1,1,1,0.9,0.85,0.7,...] when limit on combo when dmg proration caps is 5 hits
	
	
#func getHitstunProrationMod(attackerHitbox):
#	var attackId = null
	
#	if attackerHitbox != null:
#		attackId = attackerHitbox.spriteAnimation.id
func reset():
	
	
	spamHSProrationMap.clear()
	spamHSProrationMap ={}
	concecutiveHitMap.clear()
	concecutiveHitMap={}	
	prorationTracker = 0.0

	#the ripost propartion set back must be handle at end of
	#combo to prevent it from being reste when combo starts
	#ripostProrationSetbackEnabled=false
	#neutralRipostNumHitsSetBack =0 
	abilityCancelProrationReductionRate = 0


func getHitstunProrationMod(attackSpriteAnimeId,meatyHitboxFlag):

		
	var mod = _getComboLengthProrationMod(prorationTracker,meatyHitboxFlag)
	
	
	#doesn't have the command?
	#if  (attackSpriteAnimeId == null) or (not spamHSProrationMap.has(attackSpriteAnimeId)):
	#	return mod*DEFAULT_PRORATION_MOD
		
	#var res = mod*spamHSProrationMap[attackSpriteAnimeId]
	var res = 0
	if meatyHitboxFlag:
		res = mod * _getSpamProrationMod(attackSpriteAnimeId,SPAM_MEATY_HITSTUN_MOD_LIST_IX) #typeIx =SPAM_MEATY_HITSTUN_MOD_LIST_IX or SPAM_DMG_MOD_LIST_IX
	else:
		#we add the mod here since its the number of frames to remove fomr the hitstun
		res =  _getSpamProrationMod(attackSpriteAnimeId,SPAM_BASIC_HITSTUN_MOD_LIST_IX) + mod
	return res
#
#func getHitstunProrationMod(attackerHitbox):
	
#	if attackerHitbox == null:
#		return 1.0
		
		
#	var attackId = attackerHitbox.spriteAnimation.id
#	var mod = _getComboLengthProrationMod(prorationTracker)
	
#	if mod == null:
#		pass	
	#doesn't have the command?
#	if  (attackId == null) or (not spamHSProrationMap.has(attackId)):
#		return mod*DEFAULT_PRORATION_MOD
		
#	mod = mod*spamHSProrationMap[attackId]
	
#	if mod == null:
#		pass	
	#for meaty and additional hitstun, the duration is static, so standard proartion modifiers treated
#	if attackerHitbox.hitstunDurationType == attackerHitbox.HITSTUN_DURATION_TYPE_ADD or  attackerHitbox.hitstunDurationType == attackerHitbox.HITSTUN_DURATION_TYPE_MEATY:
		
		
#		return mod
		#print("hitstun proration:" +str(res))
#	elif attackerHitbox.hitstunDurationType == attackerHitbox.HITSTUN_DURATION_TYPE_BASIC:
	
		#this is special case where hitstun duration is speicfied realtively (+/-)
		#special case of 0 duration
#		if attackerHitbox.duration == 0:
#			return 1.0
			
		#case when duration is -
#		if attackerHitbox.duration <  0:
			#here, we make it proportionally more -
			# e.g.: duration of -2, if  proration is 0.5, means x2 more hitstun,
			#so -2 should be -4 (1/0.5 = x2)
#			mod = -1.0/mod
#		else:
#			var durationModProduct = mod* attackerHitbox.duration
#			if  durationModProduct<1  : #it's positive, but really small (this is indication that we gotta wrape to negtiave mod)
#				if durationModProduct != 0:
#					mod = -1.0/(1-durationModProduct)
#					return mod
#				else:
#					print("division by 0, 0 duration hitstun...")
#					return 1.0 #this should never happend, but just in case, return non buggy result
#			else: #positive simple case
#				return mod
			
#	else:
#		print("in hitstun proratio, unknown histun type : "+str(attackerHitbox.hitstunDurationType))
#		return 1.0
		

func _getSpamProrationMod(attackSpriteAnimeId,typeIx): #typeIx =SPAM_MEATY_HITSTUN_MOD_LIST_IX or SPAM_DMG_MOD_LIST_IX
	 
	#potential remap the attack id
	if attackSpriteAnimeId != null and spamHitstunProrationSpriteAnimeIdRemap.has(attackSpriteAnimeId):
		
		#remap the coomand (some attacks have same frame data but different animation. like Microphons' opera vs rap melees
		attackSpriteAnimeId=spamHitstunProrationSpriteAnimeIdRemap[attackSpriteAnimeId]
	
	
		#compute number of time hit with attack withint last 7 attacks
	var attackSpamCount=0
	for attackId in attackHitMovingWindow:
		if attackSpriteAnimeId==attackId:
			attackSpamCount = attackSpamCount +1
		
	
	if  (attackSpriteAnimeId == null) or (attackSpamCount==0):
		return DEFAULT_PRORATION_MOD
	
	var modList = null
	
	
	#does the attack have custom proratin mods?
	if customSpamProrationAttackMap.has(attackSpriteAnimeId):
		#USE custom proration mods for spamming this moves
		var modListPair = customSpamProrationAttackMap[attackSpriteAnimeId]
		modList=modListPair[typeIx]
		
		#null, meaning use default proration mods?
		if modList==null:
			modList=defaultModLists[typeIx]
		
	else:
		#use default proration mods for spamm
		modList=defaultModLists[typeIx]
		
	#does the attack hit number of times exceed proration list size? (use last mod if so)
	if attackSpamCount>=modList.size():
		return modList[modList.size()-1]
	else:
		##-1 since the attack count will always be 1 
		# because the attack hits, is put into the window, and then the check is made. 
	#anything hitting once has default proration
		return modList[attackSpamCount-1] 

func getSpamDamageProrationMod(attackSpriteAnimeId):
	return 	_getSpamProrationMod(attackSpriteAnimeId,SPAM_DMG_MOD_LIST_IX)
func getHitCount(attackId):
	if attackId == null:
		return 0
	if not concecutiveHitMap.has(attackId):
		concecutiveHitMap[attackId]=DEFAULT_ATTACK_HIT_FREQUENCY
		
	return concecutiveHitMap[attackId]
	
func increaseSpamHitCount(attackId,_spamHistunProration):
	if attackId == null:
		return
	if not concecutiveHitMap.has(attackId):
		concecutiveHitMap[attackId]=DEFAULT_ATTACK_HIT_FREQUENCY
		
	concecutiveHitMap[attackId] = min(concecutiveHitMap[attackId] + 1+_spamHistunProration,hsProrationModIncreases.size()-1)

func decreaseSpamHitCount(attackId):
	if attackId == null:
		return
	if not concecutiveHitMap.has(attackId):
		concecutiveHitMap[attackId]=DEFAULT_ATTACK_HIT_FREQUENCY
		
	concecutiveHitMap[attackId] = max(DEFAULT_ATTACK_HIT_FREQUENCY,concecutiveHitMap[attackId] - 1)
	
#retrune increase or decraease mod given an index (ix) 
#and incIx which is the index of array
func _getSpamProrationIncDec(ix,incIx):
	
	#invalid index?
	if ix == null or ix < 0:
		return 0
	
	var incDecArray = hsProrationModIncDec[incIx]
	
	#cap the ix at last element
	ix = min(ix, incDecArray.size()-1)
	
	return incDecArray[ix]

func _getComboLengthProrationMod(_prorationTracker,isMeatyFlag):
	
	var prorationList=null
	if isMeatyFlag:
		prorationList =meatyHSProrationMod
	else:
		prorationList =basicHSProrationMod
	#invalid index?
	if _prorationTracker == null or _prorationTracker < 0:
		return 0
	#convert to nearest integer (minimum 0, in case negative value for some reason)
	var ix =int(round(_prorationTracker))
	
	#cap the ix at last element
	ix = min(ix, prorationList.size()-1)
	
	return prorationList[ix]
	

func getSpamProrationInc(ix):
	return _getSpamProrationIncDec(ix,PRORATION_INC_IX)

func getSpamProrationDec(ix):
	return _getSpamProrationIncDec(ix,PRORATION_DEC_IX)
		
#removes any proration, setting back to default values
func resetHitstunProration():
	#no more proration
	
	resetConsecutiveHitProration()
	
	prorationTracker = 0.0
	
	
	
func resetConsecutiveHitProration():
	
	attackHitMovingWindow.clear()
	
	for attackId in spamHSProrationMap.keys():
		spamHSProrationMap[attackId] = DEFAULT_PRORATION_MOD
	
	#numbers hits back to 0
	for attackId in concecutiveHitMap.keys():
		concecutiveHitMap[attackId] = DEFAULT_ATTACK_HIT_FREQUENCY
func _on_combo_hit(hitbox,hurtbox):
	
	#we ignore armored hurtboxes for proration hitstun
	if hurtbox.subClass !=hurtbox.SUBCLASS_BASIC:
		return
		
	#did a ripost in neutral setback the first few hits of combo to
	#ignore proration?
	if ripostProrationSetbackEnabled:
		neutralRipostNumHitsSetBack = neutralRipostNumHitsSetBack -1
		
		#ignore tracking the spam proration for first few hits of ripsot in neutral
		if neutralRipostNumHitsSetBack > 0:
			return
	#minimum proration is 0
	#var addedProration = max(0,hitbox.histunProratrion)
	#the proration is based on damage proration, and hitstun proration kicks in when 
	#dmg proration is maxed out, so only use dmg proration
	var addedProration = max(0,hitbox.dmgProratrion)
	
	#do not include hitstun proration for all multihit attacks (only first hit)
	#although this will be weak to case where only last hit multi attack is hit first, but 
	#such cases in infinites should be rare
	#if hitbox.behavior == hitbox.BEHAVIOR_MULTI_HIT and not hitbox.isFirstMultiAttackFrame:
	
	#we don't need to check this as 0 dmg proration will act as not affecting hitstun
#	if not hitbox.affectsHitstunProration:
#		return
	
	#prorationTracker = prorationTracker +1
	prorationTracker = prorationTracker +addedProration
	
	var attackId= hitbox.spriteAnimation.id 
	
	
	
	#add the proration id offset for projectlies so their proration can be stored in same map as normal animations
	if hitbox.belongsToProjectile():
		#here if the hitbox has the override of using player parent sprite animation
		#for proration, we use it to identify the sprite animation to apply proration to
		if hitbox.projectileParentSpriteAnimation != null:
			attackId= hitbox.projectileParentSpriteAnimation.id
		attackId = attackId+GLOBALS.PROJECTILE_SPRITE_ANIME_ID_PRORATION_TRACKING_OFFSET
			
	#TODO: add an extra falg 'addToAttackSpamWindow". So for things like grab, it will 
	#add to window so other moves will lose proraiton, but the 2nd grab hitbox add to window
	#since it's an invisible hitbox simply for on hit action triggers
	
	if not hitbox.affectsMoveSpamHistunProratrion:
		return 
	
	
	#remove oldest hit move from moving window
	if attackHitMovingWindow.size() > SPAM_PRORATION_WINDOW_SIZE:
		attackHitMovingWindow.pop_back()
		
		#potential remap the attack id
	if spamHitstunProrationSpriteAnimeIdRemap.has(attackId):
		
		#remap the coomand (some attacks have same frame data but different animation. like Microphons' opera vs rap melees
		#store the remapped command	
		attackHitMovingWindow.push_front(spamHitstunProrationSpriteAnimeIdRemap[attackId])
	else:
		attackHitMovingWindow.push_front(attackId)
	
	if spamHitstunProrationSpriteAnimeIdRemap.has(attackId):
		
		#remap the coomand (some attacks have same frame data but different animation. like Microphons' opera vs rap melees
		attackId=spamHitstunProrationSpriteAnimeIdRemap[attackId]
		
		
	if not spamHSProrationMap.has(attackId):
		spamHSProrationMap[attackId]=DEFAULT_PRORATION_MOD
	
	#now, we will increment proration mod for move that hit and decrease poration for
	#all other moves
	for attackIdK in spamHSProrationMap.keys():
		
		#combo ix
		var hitIx = getHitCount(attackIdK)
			
			
		var newMod = null
		
		#the command we just hit with?
		if attackIdK == attackId:
			
			var modInc = getSpamProrationInc(hitIx)
			#decrease hitstun mod
			newMod = spamHSProrationMap[attackIdK]-modInc
			newMod = max(MINIMUM_HITSTUN_MOD,newMod)
			
			
			#count the hit
			increaseSpamHitCount(attackIdK,hitbox.spamHistunProration)
		else:

			
			var modDec = getSpamProrationDec(hitIx)
			
			#another move, should remove proration since adding variety to combo
			#(not hitting alway with same move)
			#increase hitstun mod
			newMod = spamHSProrationMap[attackIdK] + modDec
			newMod = min(DEFAULT_PRORATION_MOD,newMod)
			
			#decrease the hit  count
			decreaseSpamHitCount(attackIdK)
			
		spamHSProrationMap[attackIdK] = newMod
	

	
func _on_combo_ended():
	#reset the hitstun proration modifiers
	resetHitstunProration()
	#the ripost propartion set back must be handle at end of
	#combo to prevent it from being reste when combo starts
	ripostProrationSetbackEnabled=false
	neutralRipostNumHitsSetBack =0 
	pass
	
func _on_ability_cancel():
	#reset the hitstun proration modifiers
	#resetHitstunProration()
	 
	#resetConsecutiveHitProration()
	
	#set back the spam proration slightly by reducing each attack's hit count by abCancel_SpamProrationSetback
	 #numbers hits back to 0
	for attackId in concecutiveHitMap.keys():
		
		var oldHitFreq=concecutiveHitMap[attackId]
		#we reduce the hitfrequence (can't be lower than default)	
		var newHitFreq=max(DEFAULT_ATTACK_HIT_FREQUENCY,oldHitFreq -abCancel_SpamProrationSetback)
		concecutiveHitMap[attackId] = newHitFreq
	
		#validity check, just in case
		if not spamHSProrationMap.has(attackId):		
			spamHSProrationMap[attackId]=DEFAULT_PRORATION_MOD
		else:
			#undo some of the hitstun duration decreasese
			var i = oldHitFreq
			var newMod = spamHSProrationMap[attackId]
			while i >newHitFreq:
				
				#the amounnt increased from a previous hit
				var modInc = getSpamProrationInc(i)
				
				#undo the increase
				newMod =newMod+modInc
				
				i = i - 1
				
			newMod = min(DEFAULT_PRORATION_MOD,newMod)
	
			spamHSProrationMap[attackId] = newMod
	
	
	#end of undo spam proration slightly
	
	#reduce combo length proration (to minimum of 0)
	prorationTracker = max(0,prorationTracker - abilityCancelProrationReductionRate)
	
	var i = 0
	#move the attack window by a number of hits depending on proficiency:
	while i <abCancel_SpamProrationSetback:
		i = i+1
		attackHitMovingWindow.push_front(null)
		#remove oldest hit move from moving window
		if attackHitMovingWindow.size() > SPAM_PRORATION_WINDOW_SIZE:
			attackHitMovingWindow.pop_back()
			
func neutralRipostProrationSetback(_neutralRipostNumHitsSetBack):
	ripostProrationSetbackEnabled=true
	neutralRipostNumHitsSetBack =_neutralRipostNumHitsSetBack
	