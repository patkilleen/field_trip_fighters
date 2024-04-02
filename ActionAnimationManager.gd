extends Node

signal start_tracking_frame_duration
signal action_animation_finished
signal action_animation_played
signal multi_tap_action_animation_partially_finished
signal create_projectile
signal request_play_sound
#sprite animation ids, which should match order of animations in scene tree
#(that is, 1st child shoujld be id 0)

var HITSTUN_SPRITE_ANIME_ID = 5
var HITSTUN_ACTION_ID = 20
var LANDING_HITSTUN_ACTION_ID = null
var AIR_HITSTUN_ACTION_ID = null
var INVULNERABLE_AIR_HITSTUN_ACTION_ID = null
const UNKNOWN_ACTION_ID = -1


const RC_UNKNOWN_ACTION = 0
const RC_NULL_SPRITE_ANIMATION = 1
const RC_SUCCESS = 2

const AUTO_CANCEL_COMMANDS_BASIC = 0 #masks: autoCancels +autoCancels2
const AUTO_CANCEL_COMMANDS_ONHIT=1 #autoCancelsOnHit + autoCancelsOnHit2 + autoCancelsOnHitAllAnimation +autoCancelsOnHitAllAnimation2
const AUTO_CANCEL_COMMANDS_ALL=2
const AUTO_CANCEL_COMMANDS_ONHIT_AUTO_ABILITY_CANCEL=3 #abilityAutoCancelsOnHit+abilityAutoCancelsOnHit2
const AUTO_CANCEL_COMMANDS_LANDING_LAG_CANCEL=4#landingLagAutoCancels+landingLagAutoCancels2
const AUTO_CANCEL_COMMANDS_ON_HIT_LANDING_LAG_CANCEL=5#landingLagAutoCancelsOnHit+landingLagAutoCancelsOnHit2


var inputManagerResource = preload("res://input_manager.gd")

var GLOBALS = preload("res://Globals.gd")
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

#used to map actionids to autocancel bitmaps, this way
#the sprite autocancel bits aren't coupled to action ids
var autoCancelMaskMap = {}
var autoCancelMaskMap2 = {}

var actionIdNameMap = {}
var actionIdDetailsMap = {}
var reversalSpriteAnimationIdMap = {}
var reversableSpriteAnimationIdMap = {}
var invincibilitySpriteAnimationIdMap = {}

var techSpriteAnimationIdsMap = {}


var airActionIdMap={}
#subclasses will populate this with sprite animation ids
#to indicate which stale aniamtion doesn't refresh from an ability cancel
var abCancelStaleAnimeRefreshBlackList={}

var movementAnimationManager = null
var spriteAnimationManager = null

#stores the sprite aniamtion ids that should be remapped to another sprite aniamtion
#id when tracking the hitstun spam proration. Typically empty. will be used by stance characters
#that share an animation but have diffrent sprites for the same attack
var spamHitstunProrationSpriteAnimeIdRemap = {}

var customSpamProrationAttackMap = {} #leave empty unless want specific moves to over ride proration mods for spamming

#flag indicating whether player is paused or not
var playerPaused = false

#the current animation
#var currentActionAnimation = null
var currentSpriteAnimation = null
#var currentMovementAnimation = null

#maps to contain sprite ids of melee, special, and tool attacks
var attackMaps = [{},{},{}]
#map for linking commands to attack types
var cmdAttackMaps = [{},{},{}]
#map to link sprite animation ids to visual sfx on hit
var visualSFXAttackMap = [{},{},{}]
#map to link sprite animation ids to audio sfx on hit
var audioSFXAttackMap = [{},{},{}]

const SPRITE_ANIME_IX = 0
const MVM_ANIME_IX = 1
var animationLookup = [{},{}] #will be updated by delayt tap actions
var animationLookupDefault = [{},{}] #the default after ready

var delayedTapActionIdReverseLookup={}
var delayedTapActionIdLookup ={}
var currentDelayedTapActionId = null

#holds the sprite animation ids (kye +  null values) that 
#don't turn around in air when disadvantage
#acrobatics chosen (like jump, dash, attack)
var airBornSupportPreventAutoFacingSpriteAnimeIds={}

#key: action, value: command
#used to see what command used to play an action id
var commandLookupMap = {}

#the command used to execute the action (null if non-user-activated action)
var commandActioned = null


#sprite animatino to play once unpause occurs
var nextSpriteAnimationId = null
#the command that was buffered in to play next sprite
var nextSpriteAnimationCmd = null

#flagc indicating direction of buffered animation
var nextSpriteAnimationFacingRight = null
var nextOnHitStartingSpriteFrameIx =0
var nextPreventOnHitFlagEnabled = false
var MELEE_IX = null
var SPECIAL_IX = null
var TOOL_IX = null
#SUPPORTS reverse beat
#var DUAL_MELEE_TOOL_IX = null 
#var DUAL_TOOL_MELEE_IX =  null
	
#to be set by sub class during init function
#var forwardAirDashBMNodePath = null
#var backwardAirDashBMNodePath = null
#var forwardGroundDashBMNodePath = null
#var backwardGroundDashBMNodePath = null

#var forwardJumpBM1NodePath = null
#var backwardJumpBM1NodePath = null
#var forwardJumpBM2NodePath = null
#var backwardJumpBM2NodePath = null
#var neutralJumpBMNodePath = null

#saves the default animation being played
var delayedTapSpriteAnimation=null
var delayedTapMovementAnimation=null

#commands that when ripost can't counter ripost in reesponse 
#var counterRipostCmdBlackListMap  = {}

var pushBlockActionIdWhiteList=[]


#stores the ids of sprite aniamtions that we will keep track of frame duration (block stun, hitstun, etc)
var frameTrackingSpriteAnimationIdMap = {}


#map that holds once-per combo hits: empty for most heros. 
#If  sprite animation with ID is played that has ID in the map, then we check whether this combo it was used (map will be key = sprite animation id, and value is bool indicating hit or not)
#if flag is false, we play it normally. if flag is true, then we have another map that holds the sprite animation we should play instead and play it.
#on hit, action animatio manager will manage the map and update bool. when combo end, resets
var oneTimeHitSpriteAnimationMap = [{},{}]

const HIT_THIS_COMBO_IX = 0
const REMAPPED_SPRITE_ANIMATION_ID_IX=1

var playerController = null

var pushBlockSpriteAnimeIds=[] #sub classes will fill this with push block sprite animation ids (1 animation for non-stance characters)
var techSpriteAnimeIds = []


func _ready():
	#set_physics_process(false)
	#BELOW logic is just cause too lazy to add the "GLOBALS." KEY
	#word in front of all uses of below variables in the subclasses
	MELEE_IX = GLOBALS.MELEE_IX
	SPECIAL_IX = GLOBALS.SPECIAL_IX
	TOOL_IX = GLOBALS.TOOL_IX
	#DUAL_MELEE_TOOL_IX =  GLOBALS.DUAL_MELEE_TOOL_IX
	#DUAL_TOOL_MELEE_IX =  GLOBALS.DUAL_TOOL_MELEE_IX
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	
	pass
	
func init(playerController):
	
	
	self.playerController = playerController
	spriteAnimationManager = $SpriteAnimationManager
	movementAnimationManager = $MovementAnimationManager
	movementAnimationManager.spriteAnimationManager=spriteAnimationManager
	movementAnimationManager.init(playerController)
	
	
	spriteAnimationManager.connect("sprite_animation_played",self,"_on_sprite_animation_played")
	spriteAnimationManager.connect("finished",self,"_on_sprite_animation_finished")
	spriteAnimationManager.connect("multi_tap_partially_finished",self,"_on_multi_tap_partially_finished")
	spriteAnimationManager.connect("create_projectile",self,"_on_create_projectile")
	spriteAnimationManager.connect("request_play_sound",self,"_on_request_play_sound")

func reset():
	spriteAnimationManager.reset()
	movementAnimationManager.reset()
	delayedTapSpriteAnimation=null
	delayedTapMovementAnimation=null

	playerPaused = false

	currentSpriteAnimation = null

	currentDelayedTapActionId = null

	commandActioned = null

	nextSpriteAnimationId = null
	nextSpriteAnimationCmd = null

	nextSpriteAnimationFacingRight = null
	nextOnHitStartingSpriteFrameIx =0
	nextPreventOnHitFlagEnabled = false
	#set_physics_process(true)
	

func setGlobalSpeedMod(mod):
	globalSpeedMod=mod
	#spriteAnimationManager.globalSpeedMod = mod
	#movementAnimationManager.globalSpeedMod = mod
#sets flag to true that frame is hitting opponent
func spriteFrameSetIsHitting(flag):
	#var frame = spriteAnimationManager.getCurrentSpriteFrame()
	
	#if frame!= null:
	#	frame.hittingWithJumpCancelableHitbox=flag
	var _currentSpriteAnimation = spriteAnimationManager.currentAnimation
	if _currentSpriteAnimation != null:
		_currentSpriteAnimation.hittingWithJumpCancelableHitbox=flag	

func spriteFrameSetHittingAnyHitbox(flag):
	var _currentSpriteAnimation = spriteAnimationManager.currentAnimation
	if _currentSpriteAnimation != null:
		_currentSpriteAnimation.httingAnyHurtboxFlag=flag	

#returns true when frame hit opponent and false otherwise
#ignoreOnHitWindow: true means that for the entire animation, if we hit opponent true will be returned, false, then only return true when hit opponent 
#withint time window
func isSpriteFrameHittingOpponent(ignoreOnHitWindow):
	#var frame = spriteAnimationManager.getCurrentSpriteFrame()
	
	#if frame!= null:
	#	return frame.hittingWithJumpCancelableHitbox
	
	var _currentSpriteAnimation = spriteAnimationManager.currentAnimation
	if _currentSpriteAnimation != null:

		return _currentSpriteAnimation.isOnHitAutoCancelWindowActive(ignoreOnHitWindow)
		#return _currentSpriteAnimation.hittingWithJumpCancelableHitbox
	return false
	
func isSpriteFrameHittingOpponentAnyHurtbox():
	var _currentSpriteAnimation = spriteAnimationManager.currentAnimation
	if _currentSpriteAnimation != null:

		return _currentSpriteAnimation.httingAnyHurtboxFlag
		
	return false
		
func getCurrentSpriteAnimation():
	return spriteAnimationManager.currentAnimation

func areAnimationsAssociated(spriteAnimeId,actionId):
	
	
	#remap to consider the stance (if any stances for this character)
	actionId = actionIdRemapHook(actionId)
	
	#action given exists in srpite lookup?
	if animationLookup[SPRITE_ANIME_IX].has(actionId):
		var id = animationLookup[SPRITE_ANIME_IX][actionId]

		return spriteAnimeId == spriteAnimeId
	else:
		return false
		
#returns true when current sprite animation is the sprite animation associated to the action id, false otherwise
#the parameter: actionId
func isCurrentSpriteAnimation(actionId):
	return _isSpriteAnimation(actionId,currentSpriteAnimation)


#returns true when given sprite animation is the sprite animation associated to the action id, false otherwise
#the parameter: actionId
func _isSpriteAnimation(actionId,_spriteAnimeId):
	
	#remap to consider the stance (if any stances for this character)
	actionId = actionIdRemapHook(actionId)
	
	#action given exists in srpite lookup?
	if animationLookup[SPRITE_ANIME_IX].has(actionId):
		var spriteAnimeId = animationLookup[SPRITE_ANIME_IX][actionId]

		return spriteAnimeId == _spriteAnimeId
	else:
		return false
		
			
#returns true when current moveemnt animation is the movement animation associated to the action id, false otherwise
#the parameter: actionId
func isCurrentMvmAnimation(actionId):
	
	#remap to consider the stance (if any stances for this character)
	actionId = actionIdRemapHook(actionId)
	
	#action given exists in srpite lookup?
	if animationLookup[MVM_ANIME_IX].has(actionId):
		var mvmAnimeId = animationLookup[MVM_ANIME_IX][actionId]
		#return mvmAnimeId == currentMovementAnimation
		return movementAnimationManager.isAnimationActive(mvmAnimeId)
	else:
		return false
		
#given a actionId as lookup key, fetches the sprite animation assosiated
func spriteAnimationLookup(actionId): 

	actionId = actionIdRemapHook(actionId)
	return _spriteAnimationLookup(actionId)
		
	
#ignores the aciton id remapping based on stance
func _spriteAnimationLookup(actionId): 

	if animationLookup[SPRITE_ANIME_IX].has(actionId):
		var spriteAnimeId = animationLookup[SPRITE_ANIME_IX][actionId]
		#case where action has not sprite id
		if spriteAnimeId == null:
			return null
		var spriteAnimation = spriteAnimationManager.spriteAnimations[spriteAnimeId]
		return spriteAnimation
	return null
	
#returns the id of sprite animation associated to action id
func spriteAnimationIdLookup(actionId):
	
	#remap to consider the stance (if any stances for this character)
	actionId = actionIdRemapHook(actionId)
	
	if animationLookup[SPRITE_ANIME_IX].has(actionId):
		return animationLookup[SPRITE_ANIME_IX][actionId]
		
	return null
	
#given a actionId as lookup key, fetches the sprite animation assosiated
#or null if no such movement	
func mvmAnimationLookup(actionId):
	
	#remap to consider the stance (if any stances for this character)
	actionId = actionIdRemapHook(actionId)
	
	if animationLookup[MVM_ANIME_IX].has(actionId):
		var mvmAnimationId = animationLookup[MVM_ANIME_IX][actionId]
		if mvmAnimationId == null:
			return null
		var mvmvAnimation = movementAnimationManager.movementAnimations[mvmAnimationId]
		return mvmvAnimation
	return null
	
func isMeleeSpriteAnimation(spriteAnimeId):
	return isXSpriteAnimation(GLOBALS.MELEE_IX,spriteAnimeId)
	
func isSpecialSpriteAnimation(spriteAnimeId):
	return isXSpriteAnimation(GLOBALS.SPECIAL_IX,spriteAnimeId)

func isToolSpriteAnimation(spriteAnimeId):
	return isXSpriteAnimation(GLOBALS.TOOL_IX,spriteAnimeId)

#func isToolMeleeSpriteAnimation(spriteAnimeId):
#	return isXSpriteAnimation(GLOBALS.DUAL_TOOL_MELEE_IX,spriteAnimeId)

#func isMeleeToolSpriteAnimation(spriteAnimeId):
#	return isXSpriteAnimation(GLOBALS.DUAL_MELEE_TOOL_IX,spriteAnimeId)
	
func isXSpriteAnimation(ix,spriteAnimeId):
	if spriteAnimeId == null:
		return false
		
	return attackMaps[ix].has(spriteAnimeId)
	 
	
	
func isMeleeCommand(cmd):
	return isXCommand(GLOBALS.MELEE_IX,cmd)
	
func isSpecialCommand(cmd):
	return isXCommand(GLOBALS.SPECIAL_IX,cmd)

func isToolCommand(cmd):
	return isXCommand(GLOBALS.TOOL_IX,cmd)

#func isToolMeleeCommand(cmd):
#	return isXCommand(GLOBALS.DUAL_TOOL_MELEE_IX,cmd)

#func isMeleeToolCommand(cmd):
#	return isXCommand(GLOBALS.DUAL_MELEE_TOOL_IX,cmd)
	
func isXCommand(ix,cmd):
	if cmd == null:
		return false
		
	return cmdAttackMaps[ix].has(cmd)

func isVisualSFXMeleeSpriteAnimeId(saId):
	return isVisualSFX_X_SpriteAnimeId(GLOBALS.MELEE_IX,saId)

func isVisualSFXSpecialSpriteAnimeId(saId):
	return isVisualSFX_X_SpriteAnimeId(GLOBALS.SPECIAL_IX,saId)

func isVisualSFXToolSpriteAnimeId(saId):
	return isVisualSFX_X_SpriteAnimeId(GLOBALS.TOOL_IX,saId)

func isVisualSFX_X_SpriteAnimeId(ix,saId):
	if saId == null:
		return false
		
	return visualSFXAttackMap[ix].has(saId)
	
func isAudioSFXMeleeSpriteAnimeId(saId):
	return isAudioSFX_X_SpriteAnimeId(GLOBALS.MELEE_IX,saId)

func isAudioSFXSpecialSpriteAnimeId(saId):
	return isAudioSFX_X_SpriteAnimeId(GLOBALS.SPECIAL_IX,saId)

func isAudioSFXToolSpriteAnimeId(saId):
	return isAudioSFX_X_SpriteAnimeId(GLOBALS.TOOL_IX,saId)

func isAudioSFX_X_SpriteAnimeId(ix,saId):
	if saId == null:
		return false
		
	return audioSFXAttackMap[ix].has(saId)

func isAutoCancelable(actionId):
	if actionId == null:
		return false	

	var _currentSpriteAnimation = spriteAnimationManager.currentAnimation
	if _currentSpriteAnimation == null:
		#print("warning, null sprite animation when checking: 'isAutoCancelable'")
		return true
		
	var frame = _currentSpriteAnimation.getCurrentSpriteFrame()
	
	if frame == null:
		print("warning, null sprite frame when checking: 'isAutoCancelable': animation: "+str(_currentSpriteAnimation.name))
		return true

	return _isAutoCancelable(actionId,frame)

func _isAutoCancelable(actionId,frame):
	
	if frame ==null:
		return true

	return _isAutoCancelableHelper(actionId,frame.autoCancels, frame.autoCancels2)
	#var mask = 0
	#choose the map the action is in
	#if not autoCancelMaskMap.has(actionId):
	#	if not autoCancelMaskMap2.has(actionId):
	#		print("warning, trying to autocancel non-maped user action")
	#		return false
	#	else:
	#		mask = autoCancelMaskMap2[actionId]
	#		return ((mask & frame.autoCancels2) == mask)
	#else:
	#	mask = autoCancelMaskMap[actionId]
		#var mask = 1 << (bitmap) #bitshift a 1 'actionId' bits left'
	#	return ((mask & frame.autoCancels) == mask)
		
		
func isAutoCancelableOnHit(actionId):
	if actionId == null:
		return false
	var _currentSpriteAnimation = spriteAnimationManager.currentAnimation
	if _currentSpriteAnimation == null:
		#print("warning, null sprite animation when checking: 'isAutoCancelableOnHit'")
		return true
		
	var frame = _currentSpriteAnimation.getCurrentSpriteFrame()
	
	if frame == null:
		print("warning, null sprite frame when checking: 'isAutoCancelableOnHit': animation: "+str(_currentSpriteAnimation.name))
		return true
	return  _isAutoCancelableOnHit(actionId,frame)

func isAutoCancelableOnHitAllAnimation(actionId):
	if actionId == null:
		return false
	var _currentSpriteAnimation = spriteAnimationManager.currentAnimation
	if _currentSpriteAnimation == null:
		#print("warning, null sprite animation when checking: 'isAutoCancelableOnHit'")
		return true
		
	var frame = _currentSpriteAnimation.getCurrentSpriteFrame()
	
	if frame == null:
		print("warning, null sprite frame when checking: 'isAutoCancelableOnHit': animation: "+str(_currentSpriteAnimation.name))
		return true
	return  _isAutoCancelableOnHitAllAnimation(actionId,frame)
	
func isAbilityAutoCancelableOnHit(actionId):
	if actionId == null:
		return false
	var _currentSpriteAnimation = spriteAnimationManager.currentAnimation
	if _currentSpriteAnimation == null:
		#print("warning, null sprite animation when checking: 'isAutoCancelableOnHit'")
		return true
	
	var ignoreOnHitWindow = false		
	#if not _currentSpriteAnimation.hittingWithJumpCancelableHitbox:	
	if not _currentSpriteAnimation.isOnHitAutoCancelWindowActive(ignoreOnHitWindow):
		print("on hit ability autocancel bug")
	var frame = _currentSpriteAnimation.getCurrentSpriteFrame()
	
	if frame == null:
		print("warning, null sprite frame when checking: 'isAutoCancelableOnHit': animation: "+str(_currentSpriteAnimation.name))
		return true
	return  _isAbilityAutoCancelableOnHit(actionId,frame)
		

func _isAutoCancelableOnHit(actionId,frame):
	
	if frame ==null:
		return true
	
	#try see if autocancel on hit that required input withting on hit window
	return _isAutoCancelableHelper(actionId,frame.autoCancelsOnHit, frame.autoCancelsOnHit2)
	
	
		
		
	#check the auto cancel on hit bit maps
#	var mask = 0
	
	#choose the map the action is in
	#if not autoCancelMaskMap.has(actionId):
	#	if not autoCancelMaskMap2.has(actionId):
	#		print("warning, trying to autocancel non-maped user action")
	#		res =  false
	#	else:
	#		mask = autoCancelMaskMap2[actionId]
	#		res = ((mask & frame.autoCancelsOnHit2) == mask)
	#else:
	#	mask = autoCancelMaskMap[actionId]
		
	#	res = ((mask & frame.autoCancelsOnHit) == mask)
	
func _isAutoAbilityCancelableOnHit(actionId,frame):
	
	if frame ==null:
		return true
	
	#try see if auto ability cancel on hit that required input withting on hit window 
	return _isAutoCancelableHelper(actionId,frame.abilityAutoCancelsOnHit, frame.abilityAutoCancelsOnHit2)
	
func _isLandingLagAutoCancelable(actionId,frame):
	
	if frame ==null:
		return true
	
	#try see if can cancel landing lag from this animation
	return _isAutoCancelableHelper(actionId,frame.landingLagAutoCancels, frame.landingLagAutoCancels2)

	
func _isLandingLagOnHitAutoCancelable(actionId,frame):
	
	if frame ==null:
		return true
	#try see if can cancel landing lag from this animation after hitting
	return _isAutoCancelableHelper(actionId,frame.landingLagAutoCancelsOnHit, frame.landingLagAutoCancelsOnHit2)
		
func _isAutoCancelableOnHitAllAnimation(actionId,frame):
	
	if frame ==null:
		return true
	
	#check on hit autocancelable for entire animation
	return _isAutoCancelableHelper(actionId,frame.autoCancelsOnHitAllAnimation, frame.autoCancelsOnHitAllAnimation2)
	
	


func _isAbilityAutoCancelableOnHit(actionId,frame):
	if frame ==null:
		return true
		
	return _isAutoCancelableHelper(actionId,frame.abilityAutoCancelsOnHit, frame.abilityAutoCancelsOnHit2)
	#var mask = 0
	##choose the map the action is in
	#if not autoCancelMaskMap.has(actionId):
	#	if not autoCancelMaskMap2.has(actionId):
	#		print("warning, trying to autocancel non-maped user action")
	#		return false
	#	else:
	#		mask = autoCancelMaskMap2[actionId]
	#		return ((mask & frame.abilityAutoCancelsOnHit2) == mask)
	#else:
	#	mask = autoCancelMaskMap[actionId]
		
	#	return ((mask & frame.abilityAutoCancelsOnHit) == mask)

func _isAutoCancelableHelper(actionId,autoCancelMap1,autoCancelMap2):
	
	var mask = 0
	#choose the map the action is in
	if not autoCancelMaskMap.has(actionId):
		if not autoCancelMaskMap2.has(actionId):
			print("warning, trying to autocancel non-maped user action")
			return false
		else:
			mask = autoCancelMaskMap2[actionId]
			return ((mask & autoCancelMap2) == mask)
	else:
		mask = autoCancelMaskMap[actionId]
		
		return ((mask & autoCancelMap1) == mask)
	
#returns list of action ids that can be auto-canceled into this sprite frame
func getAutoCancelableActionIds():
	return _getAutoCancelableActionIds(AUTO_CANCEL_COMMANDS_BASIC)

#returns list of action ids that can be on-hit auto-canceled into this sprite frame
func getOnHitAutoCancelableActionIds():
	return _getAutoCancelableActionIds(AUTO_CANCEL_COMMANDS_ONHIT)

#returns list of action ids that can be on-hit or basic auto-canceled into this sprite frame 
#no duplicates
func getAllAutoCancelableActionIds():
	return _getAutoCancelableActionIds(AUTO_CANCEL_COMMANDS_ALL)

#returns list of action ids that can be auto-canceled into this sprite frame
func _getAutoCancelableActionIds(type):
	
	var _currentSpriteAnimation = spriteAnimationManager.currentAnimation
	
	if _currentSpriteAnimation == null:
		return []
		
	var frame = _currentSpriteAnimation.getCurrentSpriteFrame()
	
	if frame == null:
		return []

	return __getAutoCancelableActionIds(type,frame)
	
#autoCancels2
#autoCancelsOnHit
#autoCancelsOnHit2
#returns list of action ids that can be auto-canceled into this sprite frame
func __getAutoCancelableActionIds(type,frame):
	#unkown type
	#if type != AUTO_CANCEL_COMMANDS_BASIC and type !=AUTO_CANCEL_COMMANDS_ONHIT and type !=AUTO_CANCEL_COMMANDS_ALL:
	#	print("warning: unknown type "+str(type)+" when trying to get auto cancel command list")
	#	return []
	 
	
	

	var mask = 0
	var mask2 = 0
	var actionList = []
	
	var allPossibleActions = autoCancelMaskMap.keys()
	#feel possible actions with other acutcancelable map
	for actionId in autoCancelMaskMap2.keys():
		allPossibleActions.append(actionId)
	
	#iterate all possible cancelable action ids
	for actionId in allPossibleActions:	
	
		match(type):
			AUTO_CANCEL_COMMANDS_BASIC:
				#sprite frame autocancels?
				if _isAutoCancelable(actionId,frame):
					actionList.append(actionId)
			AUTO_CANCEL_COMMANDS_ONHIT:	
			
				if _isAutoCancelableOnHit(actionId,frame) or _isAutoCancelableOnHitAllAnimation(actionId,frame):
					actionList.append(actionId)
			AUTO_CANCEL_COMMANDS_ALL:
			
				if _isAutoCancelable(actionId,frame):
					actionList.append(actionId)
				elif _isAutoCancelableOnHit(actionId,frame) or _isAutoCancelableOnHitAllAnimation(actionId,frame):
					actionList.append(actionId)
				elif _isAutoAbilityCancelableOnHit(actionId,frame):
					actionList.append(actionId)
				elif _isLandingLagAutoCancelable(actionId,frame):
					actionList.append(actionId)
				elif _isLandingLagOnHitAutoCancelable(actionId,frame):
					actionList.append(actionId)
			AUTO_CANCEL_COMMANDS_ONHIT_AUTO_ABILITY_CANCEL: #abilityAutoCancelsOnHit+abilityAutoCancelsOnHit2	
				if _isAutoAbilityCancelableOnHit(actionId,frame):
					actionList.append(actionId)
			AUTO_CANCEL_COMMANDS_LANDING_LAG_CANCEL:#landingLagAutoCancels+landingLagAutoCancels2
				if _isLandingLagAutoCancelable(actionId,frame):
					actionList.append(actionId)
			AUTO_CANCEL_COMMANDS_ON_HIT_LANDING_LAG_CANCEL:#landingLagAutoCancelsOnHit+landingLagAutoCancelsOnHit2
				if _isLandingLagOnHitAutoCancelable(actionId,frame):
					actionList.append(actionId)
	return actionList



#actionId: the id of action animation to play
#facingRight: boolean flag indicating this player is facing right, flase if facing left
#command issued by user to actiate this action
#retruns a status/result code
func playUserAction(actionId,facingRight, cmd):
	
	var rc = null		
	rc = _playAction(actionId,facingRight,cmd)
	#only save command actioned if it creates a new sprite aniation
	#if its only a movement based, then don't replace the command that
	#started the sprite aniamtion that is still running
	#if animationLookup[SPRITE_ANIME_IX][actionId] != null:
	if animationLookup[SPRITE_ANIME_IX].has(actionId):
		var spriteAnimationId =  animationLookup[SPRITE_ANIME_IX][actionId]
		if spriteAnimationId != null:
			commandActioned = cmd
			#spriteAnimationManager.store_command(cmd)
			
	return rc
	#else:
	#	print("ignoring saving command "+ str(cmd) +" since only movement involved")

#engine plays a commandless-action
func playAction(actionId,facingRight):
	
	var cmd = null
	return _playAction(actionId,facingRight,cmd)
	
#actionId: the id of action animation to play
#facingRight: boolean flag indicating this player is facing right, flase if facing left
#cmd: command that executed this action, or null if it's the engine that created it
#on_hit_starting_sprite_frame_ix: the sprite frame index that starts when animation starts (can skipp frames) default0 means no skip
func _playAction(actionId,facingRight,cmd,on_hit_starting_sprite_frame_ix=0,preventOnHitFlagEnabled=false):
	
	
	actionId = delayedTapAnimationCheck(actionId)
	
		
	#	animationLookup[SPRITE_ANIME_IX][actionId] =delayedTapSpriteAnimation
		#animationLookup[MVM_ANIME_IX][actionId] = delayedTapMovementAnimation
		
	var rc = RC_SUCCESS
	#already in hitstun?
	if isCurrentSpriteAnimation(HITSTUN_ACTION_ID) or isCurrentSpriteAnimation(AIR_HITSTUN_ACTION_ID)  or  isCurrentSpriteAnimation(LANDING_HITSTUN_ACTION_ID) or isCurrentSpriteAnimation(INVULNERABLE_AIR_HITSTUN_ACTION_ID):
		#palying another move other than hitstun?
		if ( HITSTUN_ACTION_ID != actionId) and  (AIR_HITSTUN_ACTION_ID != actionId) and   (LANDING_HITSTUN_ACTION_ID != actionId) and (INVULNERABLE_AIR_HITSTUN_ACTION_ID != actionId):
			
			#####this is the source of falcon freeze in place bug. Gotta make sure that frame perfect hitting each other
			#is handled properly
			# we also have tech'ing do this, so its not a bug most of time
			#print("warning: playing a new animation and overriding hitstun animation, action: "+str(actionId))
			pass
			
	#currentActionAnimation =  actionId
	#assume by default actioned played isn't user-activated
	actionId = actionIdRemapHook(actionId)
	if animationLookup[SPRITE_ANIME_IX].has(actionId):
		var spriteAnimationId =  animationLookup[SPRITE_ANIME_IX][actionId]
		if spriteAnimationId != null:
			commandActioned = null
			
			#here we potentially remap the sprite aniamtaion id
			#as some sprite animation can only hit once per combo and then 
			#become sour to prevent infinites (e.g., belt air special)
			spriteAnimationId = oneTimeHitRemapSpriteAnimationId(spriteAnimationId)
			
			#spriteAnimationManager.store_command(null)
			currentSpriteAnimation = spriteAnimationId
			
			var _sa = spriteAnimationManager.spriteAnimations[currentSpriteAnimation]
			
			#if not playerPaused or _sa.supportPlayWhilePaused:				
				
			#	spriteAnimationManager.play(spriteAnimationId,cmd,facingRight)
				
			#	if playerPaused:
			#		spriteAnimationManager.pause()
			if not playerPaused:				
				
				spriteAnimationManager.play(spriteAnimationId,cmd,facingRight,on_hit_starting_sprite_frame_ix)
				if preventOnHitFlagEnabled:
					spriteFrameSetIsHitting(false)
			else:
				
				if _sa.supportPlayWhilePaused:
					#some animations during hitfreeze should display animation
					#hastly so hit shake looks good. so visually manually update the sprite
					#to first sprite of the animation if it supports it
					var sf = _sa.spriteFrames[0]
					sf.targetSprite.texture = sf.texture
										
					#adding bellow line makes the visual bug on hit where certain animation jitter (belt f-tool)
					sf.targetSprite.position = sf.sprite_Offset
				
				var allowSpritePlayOverride = true	
				
				#sprite animation already queued to be played on unpause?
				#and the animation to override the queued is not a hitstun aniamtion?
				if nextSpriteAnimationId != null and  _isAniamtionHitstunAnimation(nextSpriteAnimationId) and  not _isAniamtionHitstunAnimation(spriteAnimationId):
					#print("warning, replacing a buffered sprite action while paused,action: : "+ str(actionId))
				
					
				
					#can only override a buffered  sprite aniamtion played  if it's hitstun
					
					
					allowSpritePlayOverride=false
					print("can't override a hitstun queued (during hit freeze) animation with a non hitstun queue aniamtion")
					pass
				
				
				
				if allowSpritePlayOverride:
					#prepare to play this sprite when unpause occurs
					#TODO: consider adding sprite animation priorities of which 
					#one will win if two animations played dring hitfreeze (atm it's first come first serve
					#and last animation played wins)
					nextSpriteAnimationId = spriteAnimationId
					nextSpriteAnimationFacingRight = facingRight
					nextSpriteAnimationCmd=cmd
					nextOnHitStartingSpriteFrameIx =on_hit_starting_sprite_frame_ix
					nextPreventOnHitFlagEnabled=preventOnHitFlagEnabled	
		else:
			#were changing the sprite, overwrite last command
			#note that we cdon't overwrite command when there is no sprite animation, since
			#command used to playe the sprite animation hasn't been replaced 
			
			
			if spriteAnimationManager.currentAnimation == null:
				#print("Warning: buffered movement animtion but no sprite animation is playing")
				rc = RC_NULL_SPRITE_ANIMATION
			pass
		
		#avoid replaying movement when doing a multi tap animation
		var multiTapingFlag = false
		if spriteAnimationManager.currentAnimation != null:
			multiTapingFlag = spriteAnimationManager.currentAnimation.multiTapFlag
			
		if not multiTapingFlag and animationLookup[MVM_ANIME_IX].has(actionId) :
			var mvmAnimationId = animationLookup[MVM_ANIME_IX][actionId]
			if mvmAnimationId != null:
				
				#TODO make below an argument to the fucntion
				var _spriteCurrentlyFacingRight= playerController.kinbody.spriteCurrentlyFacingRight 
				#we add the  '_spriteCurrentlyFacingRight' here, since some movement aniamtions
				#may be crossed-up, and they should be able to specify if the movement follows 
				#position relative to opponent or is relative to player's facing
				#currentMovementAnimation = mvmAnimationId
				movementAnimationManager.play(mvmAnimationId,facingRight,_spriteCurrentlyFacingRight)
	else: #unknown action
		#print("unknown action, cannot play")	
		#currentActionAnimation = null
		currentSpriteAnimation = null
		#currentMovementAnimation = null
		rc = RC_UNKNOWN_ACTION
		

	#if we were paused and action played, paused newly played action too
	if playerPaused:
			
		movementAnimationManager.pause()
		#spriteAnimationManager.pause()
		#don't need to pause sprite animation, since once unpaused it will play
	
	if rc == RC_SUCCESS:
		emit_signal("action_animation_played",actionId)
	return rc
#knockBackMovementAnimation: the movement animation to apply as knockback
#facingRight: boolean flag indicating this player is facing right, flase if facing left
#landingType: type that indicates if go prone upon landing or not
#isOnFloor: flag indicating true on floor, false in the air
func playHitstun(duration,knockBackMovementAnimation,facingRight,landingType, minDurationBeforeFallProne, isOnFloor, stopHitMomentumOnLand,isThrow,techExceptions,stopMomentumOnPushOpponent,stopMomentumOnOpponentAnimationPlay,_newHitstunDurationOnLand,_disableBodyBox,_mvmStpOnOppAutoAbilityCancel):
	
	var hitstunAnime = null
	var hitstunActionId = null
	if isOnFloor:
		hitstunActionId =HITSTUN_ACTION_ID
	else:
		hitstunActionId =AIR_HITSTUN_ACTION_ID
		
	
	#preload the air-hitstun and ground hitstun with proper attributes, so when they
	#swap, from going in/out of air, the landing type and type during is consistent
	hitstunAnime = spriteAnimationLookup(HITSTUN_ACTION_ID)
	hitstunAnime.landingType = landingType
	hitstunAnime.minDurationBeforeFallProne=minDurationBeforeFallProne
	hitstunAnime.duration = duration
	hitstunAnime.stopHitMomentumOnLand = stopHitMomentumOnLand
	hitstunAnime.isThrow=isThrow
	hitstunAnime.techExceptions=techExceptions
	hitstunAnime.stopMomentumOnPushOpponent=stopMomentumOnPushOpponent
	hitstunAnime.stopMomentumOnOpponentAnimationPlay=stopMomentumOnOpponentAnimationPlay
	hitstunAnime.newHitstunDurationOnLand=_newHitstunDurationOnLand	
	hitstunAnime.setDisableBodyBoxFlag(_disableBodyBox)
	hitstunAnime.mvmStpOnOppAutoAbilityCancel = _mvmStpOnOppAutoAbilityCancel
	
	hitstunAnime = spriteAnimationLookup(AIR_HITSTUN_ACTION_ID)
	hitstunAnime.landingType = landingType
	hitstunAnime.minDurationBeforeFallProne=minDurationBeforeFallProne
	hitstunAnime.duration = duration
	hitstunAnime.stopHitMomentumOnLand = stopHitMomentumOnLand
	hitstunAnime.isThrow=isThrow
	hitstunAnime.techExceptions=techExceptions
	hitstunAnime.stopMomentumOnPushOpponent=stopMomentumOnPushOpponent
	hitstunAnime.stopMomentumOnOpponentAnimationPlay=stopMomentumOnOpponentAnimationPlay
	hitstunAnime.newHitstunDurationOnLand=_newHitstunDurationOnLand
	hitstunAnime.setDisableBodyBoxFlag(_disableBodyBox)
	hitstunAnime.mvmStpOnOppAutoAbilityCancel = _mvmStpOnOppAutoAbilityCancel
	#hitstunAnime = spriteAnimationLookup(hitstunActionId)
	#hitstunAnime.landingType = landingType
	#hitstunAnime.minDurationBeforeFallProne=minDurationBeforeFallProne
	#hitstunAnime.duration = duration
	
	movementAnimationManager.playMovementAnimation(knockBackMovementAnimation,not facingRight)
	#playAction(HITSTUN_ACTION_ID,facingRight)
	playAction(hitstunActionId,facingRight)
	
	#emit_signal("start_tracking_frame_duration",duration*globalSpeedMod)
	#emit_signal("start_tracking_frame_duration",duration)


func playBlockHitstun(actionId,knockBackMovementAnimation,facingRight):
	movementAnimationManager.playMovementAnimation(knockBackMovementAnimation,not facingRight)
	#playAction(HITSTUN_ACTION_ID,facingRight)
	playAction(actionId,facingRight)


func isCurrentAniamtionHitstunAnimation():
	return isCurrentSpriteAnimation(HITSTUN_ACTION_ID) or isCurrentSpriteAnimation(AIR_HITSTUN_ACTION_ID) or isCurrentSpriteAnimation(LANDING_HITSTUN_ACTION_ID)

func _isAniamtionHitstunAnimation(_spriteAnimeId):
	return _isSpriteAnimation(HITSTUN_ACTION_ID,_spriteAnimeId) or _isSpriteAnimation(AIR_HITSTUN_ACTION_ID,_spriteAnimeId) or _isSpriteAnimation(LANDING_HITSTUN_ACTION_ID,_spriteAnimeId)


#returns true when were in the air or ground hitstun and
#the stopHitMomentumOnLand flag is true. (returne false when falg false)
#if not in ground/air hitstun, it retunrns null
func isHitstunStopHitMomentumOnLand():
	if isCurrentSpriteAnimation(HITSTUN_ACTION_ID) or isCurrentSpriteAnimation(AIR_HITSTUN_ACTION_ID):
		var anime = spriteAnimationManager.currentAnimation
		
		#i think frame perfect bug between landing is here, and at times animation isn't hitstun
		#so check if property exists first
		if "stopHitMomentumOnLand" in anime:
			
			return anime.stopHitMomentumOnLand
		else:
			return null
	else:
		return null
#will change the hitstun sprite animation to be either air or gground hitstun
func toggleHitstunSpriteAnimation(isOnFloor,facingRight):
	
	#was in the air, now on the ground, but wasn't in air hitstun
	if isOnFloor and isCurrentSpriteAnimation(HITSTUN_ACTION_ID):
		#print("warning: trying to toggle hitstun to ground, but already in ground hitstun")
		return
	if not isOnFloor and isCurrentSpriteAnimation(AIR_HITSTUN_ACTION_ID):
		#print("warning: trying to toggle hitstun to air, but already in air hitstun")
		return 
	
	#not in normal air/ground hitstun? (maybe in falling hitstun or on ground hitstun)
	if not isCurrentSpriteAnimation(AIR_HITSTUN_ACTION_ID) and not isCurrentSpriteAnimation(HITSTUN_ACTION_ID):
		#print("warning: trying to toggle hitstun, but not in air or ground hitstun")
		return
	
	var currHitStunActionID = null
	var targetHitStunActionID = null
	var currHitStunSpriteAnime = null
	var targetHitStunSpriteAnime = null
	
	#resolve action ids of hitstun based on if desired is ground/air
	if isOnFloor:
		targetHitStunActionID=HITSTUN_ACTION_ID	
		currHitStunActionID=AIR_HITSTUN_ACTION_ID	
	else:
		targetHitStunActionID=AIR_HITSTUN_ACTION_ID
		currHitStunActionID=HITSTUN_ACTION_ID
	
	currHitStunSpriteAnime = spriteAnimationLookup(currHitStunActionID)
	targetHitStunSpriteAnime = spriteAnimationLookup(targetHitStunActionID)
		
	#copy necessary attributes
	#targetHitStunSpriteAnime.landingType = currHitStunSpriteAnime.landingType
	#targetHitStunSpriteAnime.minDurationBeforeFallProne=currHitStunSpriteAnime.minDurationBeforeFallProne
	#targetHitStunSpriteAnime.duration = currHitStunSpriteAnime.duration
	
	playAction(targetHitStunActionID,facingRight)
	

	targetHitStunSpriteAnime.hitstunSecondsEllapsed=currHitStunSpriteAnime.hitstunSecondsEllapsed
	
	
#returns true when landing in hitstun should provoke falling prone
#and false otherswise (like if riposted or just started getting combod and touch ground instantly)
func readyForLandingHitstun():
	#var hitstunAnime = spriteAnimationLookup(HITSTUN_ACTION_ID)
	#return hitstunAnime.readyForLandingHitstun()
	if isCurrentSpriteAnimation(HITSTUN_ACTION_ID) or isCurrentSpriteAnimation(AIR_HITSTUN_ACTION_ID):
		var anime = spriteAnimationManager.currentAnimation
		return anime.readyForLandingHitstun()
	else:
		#not in normal hitstun, so don't fall prone into hitstun
		return  false

func getNewHitstunDurationOnLand():
	if isCurrentSpriteAnimation(HITSTUN_ACTION_ID) or isCurrentSpriteAnimation(AIR_HITSTUN_ACTION_ID):
		var anime = spriteAnimationManager.currentAnimation
		return anime.newHitstunDurationOnLand
	else:
		return -1
	
func pauseAnimation():
	
	if not playerPaused:
	
		playerPaused = true
		if nextSpriteAnimationId != null:
			print("warning, buffered a sprite animation to play, but pausing actionanimationmanager is clearing it")
			
		#trying to pause, so clear the next sprite animatin that should be played
		nextSpriteAnimationId = null
		nextSpriteAnimationCmd = null		
		movementAnimationManager.pause()
		spriteAnimationManager.pause()

func unpauseAnimation():
	if playerPaused:
		playerPaused = false
			
		movementAnimationManager.unpause()
		
		
		#buffered in a sprite animation to play when paused?
		if nextSpriteAnimationId != null:
			#spriteAnimationManager.cmd is last command played before pause
			#spriteAnimationManager.play(nextSpriteAnimationId,spriteAnimationManager.cmd,nextSpriteAnimationFacingRight)
			spriteAnimationManager.play(nextSpriteAnimationId,nextSpriteAnimationCmd,nextSpriteAnimationFacingRight,nextOnHitStartingSpriteFrameIx)
			
			if nextPreventOnHitFlagEnabled:
				spriteFrameSetIsHitting(false)			
			nextSpriteAnimationId = null
			nextSpriteAnimationCmd =null
			nextOnHitStartingSpriteFrameIx =0
			nextPreventOnHitFlagEnabled=false
		else:
			spriteAnimationManager.unpause()	
			
func _on_multi_tap_partially_finished(spriteAnimation,spriteFrame):
	
	if spriteFrame != null:
		#multi tap sprite frame has a action id to execute when player failed 
		#to tap to continue animation?
		if spriteFrame.on_multi_tap_incomplete_action_id != -1:
			
			#emit_signal("multi_tap_action_animation_partially_finished",currentSpriteAnimation,spriteFrame)
			emit_signal("multi_tap_action_animation_partially_finished",spriteAnimation,spriteFrame)
			#playActionKeepOldCommand(spriteFrame.on_multi_tap_incomplete_action_id)
			
			return
	
	#something went wrong, so just finish normally (no special finish animation)
	_on_sprite_animation_finished(spriteAnimation)

func _on_sprite_animation_played(spriteAnimation):	

	#for specific animation, keep track of the numer ber of frames
	if spriteAnimation != null:
		if frameTrackingSpriteAnimationIdMap.has(spriteAnimation.id):
			var durationInFrames = spriteAnimation.getEffectiveNumberOfFrames()
			#emit_signal("start_tracking_frame_duration",durationInFrames*globalSpeedMod)
			emit_signal("start_tracking_frame_duration",durationInFrames)
				
func _on_sprite_animation_finished(spriteAnimation):
	#var _currentActionAnimation = currentActionAnimation
	#currentActionAnimation = null
	var _currentSpriteAnimation = currentSpriteAnimation
	
	#if currentSpriteAnimation != spriteAnimationManager.currentAnimation
	currentSpriteAnimation=null
	commandActioned = null
	currentDelayedTapActionId = null # this makes sure you can't buffer in the 2nd (or 3rd, 4th , 5th, etc) reka animations to play at end of reka animation
	#spriteAnimationManager.store_command(null)
	emit_signal("action_animation_finished",_currentSpriteAnimation)
	
	
#func _physics_process(delta):
	
	#TODO: CLEAN THIS UP AND USE SIGNALS INSTEAD OF UNECESSARY POLLING
	#movement animation finished?
#	if movementAnimationManager.currentAnimation == null:
#		currentMovementAnimation=null
		
	#pass
	#in hit stun?
	#if currentActionAnimation ==HITSTUN_ACTION_ID:
#	if currentSpriteAnimation == HITSTUN_SPRITE_ANIME_ID:
#		#hit stun over?
#		if movementAnimationManager.currentAnimation == null:			
#			spriteAnimationManager.currentAnimation.stop()
#			spriteAnimationManager.currentAnimation=null
#			_on_sprite_animation_finished(spriteAnimationManager.spriteAnimations[HITSTUN_SPRITE_ANIME_ID])
		
func _on_create_projectile(projectile,spawnPoint):
	#make sure to capture signal and continue broadcasting signal while
	#and add the command last actioned that create projectile
	projectile.command = self.commandActioned
	emit_signal("create_projectile",projectile,spawnPoint)
	
func _on_request_play_sound(sfxId,soundtype,volume):
	emit_signal("request_play_sound",sfxId,soundtype,volume)
	
#sub classes can override this to change the aciton id dynamically
#depending on some special state. This function will be called when resolving the
#sprite id and movement id
func actionIdRemapHook(actionId):
	return actionId
	
func _actionIdRemapHook(actionId,stanceIx):
	return actionId
	
	
	
#func hasSpriteAnimation(actionId):
#	if animationLookup[SPRITE_ANIME_IX].has(actionId):
#		var spriteAnimationId =  animationLookup[SPRITE_ANIME_IX][actionId]
		
		#actio
#		return spriteAnimationId != null
		
	#otherwise couldn't find the action, so null sprite indieeed
#	return false
	
#RETURNS seconds remaing for basic ground hitstun and air (not invulnerable or landing, not implemented yet)
#not that this isn't used.
func getHitstunSecondsRemaining(): 
	
	var secs = 0
	var hitstunAnime = null
	if isCurrentSpriteAnimation(HITSTUN_ACTION_ID):
		hitstunAnime = spriteAnimationLookup(HITSTUN_ACTION_ID)
		
	if isCurrentSpriteAnimation(AIR_HITSTUN_ACTION_ID):
		hitstunAnime = spriteAnimationLookup(AIR_HITSTUN_ACTION_ID)
		
	
	if hitstunAnime != null:	
		#secs = (hitstunAnime.durationInSeconds - hitstunAnime.hitstunSecondsEllapsed)/globalSpeedMod
		secs = (hitstunAnime.durationInSeconds - hitstunAnime.hitstunSecondsEllapsed)
	
	return secs

#returns true when should konckback movment stop on opponent autoability cancel
func getMvmStopOnOpponentAutoAbilityCancel():
	
	var res = false
	var hitstunAnime = null
	if isCurrentSpriteAnimation(HITSTUN_ACTION_ID):
		hitstunAnime = spriteAnimationLookup(HITSTUN_ACTION_ID)
		
	if isCurrentSpriteAnimation(AIR_HITSTUN_ACTION_ID):
		hitstunAnime = spriteAnimationLookup(AIR_HITSTUN_ACTION_ID)
		
	
	if hitstunAnime != null:
		res =hitstunAnime.mvmStpOnOppAutoAbilityCancel
	
	return res	
	
#func getHitstunFramesRemaining(): 

#	var hitstunSecondsRemaining = getHitstunSecondsRemaining()
#	return hitstunSecondsRemaining /GLOBALS.SECONDS_PER_FRAME  # SEC / (SEC/FRAME) = SEC * FRAME /  SEC = FRAME
#fetches the command that is used to play given action id
#null is returned when no such command exists (for example, for rebound animation)
func getCommand(actionId):
	
	if actionId == null:
		return null
		
	#no associated command?
	if not commandLookupMap.has(actionId):
		return null
	
	return commandLookupMap[actionId]
	
#returns true when in hitstun from a throw/grab
func isBeingThrown():
	var thrownFlag = false
	
	var hitstunAnime = null
	if isCurrentSpriteAnimation(HITSTUN_ACTION_ID):
		hitstunAnime = spriteAnimationLookup(HITSTUN_ACTION_ID)
		
	if isCurrentSpriteAnimation(AIR_HITSTUN_ACTION_ID):
		hitstunAnime = spriteAnimationLookup(AIR_HITSTUN_ACTION_ID)
		
	#the histun animation is playing?
	if hitstunAnime != null:
		thrownFlag =hitstunAnime.isThrow
	
	return thrownFlag 

#adjusts the speed of dashes
#func setDashingSpeed(airDashSpeedMod,groundDashSpeedMod):
	
#	var playerController = self.get_parent()
#	var kinbody = playerController.kinbody
	#get basic movement of dash with speed
#	var forwardAirDashBM = kinbody.get_node(forwardAirDashBMNodePath)
#	var backwardAirDashBM = kinbody.get_node(backwardAirDashBMNodePath)
#	var forwardGroundDashBM = kinbody.get_node(forwardGroundDashBMNodePath)
#	var backwardGroundDashBM = kinbody.get_node(backwardGroundDashBMNodePath)
	
	#adjjust the base speeds of each dash
#	forwardAirDashBM.speed=forwardAirDashBM.speed*airDashSpeedMod
#	backwardAirDashBM.speed = backwardAirDashBM.speed*airDashSpeedMod
#	forwardGroundDashBM.speed=forwardGroundDashBM.speed*groundDashSpeedMod
#	backwardGroundDashBM.speed = backwardGroundDashBM.speed*groundDashSpeedMod

	
#func setJumpSpeed(jumpSpeedMod):
	
#	var playerController = self.get_parent()
#	var kinbody = playerController.kinbody
	#get basic movement of dash with speed
#	var forwardJBM1 = kinbody.get_node(forwardJumpBM1NodePath)
#	var backwardJBM1 = kinbody.get_node(backwardJumpBM1NodePath)
#	var forwardJBM2 = kinbody.get_node(forwardJumpBM2NodePath)
#	var backwardJBM2 = kinbody.get_node(backwardJumpBM2NodePath)
#	var neutralJBM = kinbody.get_node(neutralJumpBMNodePath)
	
	#forwardJBM1.speed = forwardJBM1.speed*jumpSpeedMod
	#backwardJBM1.speed = backwardJBM1.speed*jumpSpeedMod
	#forwardJBM2.speed = forwardJBM2.speed*jumpSpeedMod
	#backwardJBM2.speed = backwardJBM2.speed*jumpSpeedMod
	#neutralJBM.speed = neutralJBM.speed*jumpSpeedMod
	
func isDelayedTapActionId(actionId):
	if actionId == null:
		return false
		
	return delayedTapActionIdLookup.has(actionId)
	
func processDelayedTapActionId(actionId):
	
	if not isDelayedTapActionId(actionId):
		currentDelayedTapActionId = null
		return
	
	#first part of the delayed tap animation series?
	if currentDelayedTapActionId == null: #(so action id is the basic, like N_SPECIAL_ACTION_ID)
		
		#first animation
		currentDelayedTapActionId = delayedTapActionIdLookup[actionId]
		
	else:
		
		#end of the delayed tap aniation series?
		if  not delayedTapActionIdLookup.has(currentDelayedTapActionId):
			currentDelayedTapActionId=null
		else:
			
			#get next animation in delayed tap series
			currentDelayedTapActionId = delayedTapActionIdLookup[currentDelayedTapActionId]


func delayedTapAnimationCheck(actionId):
	
	#do we have to do some bookeeping to map action ids to delayed tap action id
	#aniamtion series
	if isDelayedTapActionId(actionId):
		
		processDelayedTapActionId(actionId)
		
		#this aciton remaps to another in a multi tap delayed series?
		if currentDelayedTapActionId !=null:
		
			#remap the animation map based on current delayed tap aniamtion
		#	delayedTapSpriteAnimation=animationLookup[SPRITE_ANIME_IX][actionId]
		#	delayedTapMovementAnimation=animationLookup[MVM_ANIME_IX][actionId]
			
			animationLookup[SPRITE_ANIME_IX][actionId] = animationLookup[SPRITE_ANIME_IX][currentDelayedTapActionId]
			animationLookup[MVM_ANIME_IX][actionId] = animationLookup[MVM_ANIME_IX][currentDelayedTapActionId]
			actionId = currentDelayedTapActionId
			
			#we must make sure that the last delayed tap animtio in series is end,
			#end of the delayed tap aniation series?
			if  not delayedTapActionIdLookup.has(currentDelayedTapActionId):
				currentDelayedTapActionId=null
		else:
			#bring the map BACK TO NORMAL			
			animationLookup[SPRITE_ANIME_IX][actionId] =animationLookupDefault[SPRITE_ANIME_IX][actionId]
			animationLookup[MVM_ANIME_IX][actionId] = animationLookupDefault[MVM_ANIME_IX][actionId]
	else:
		
		var spriteAnimationId =  animationLookup[SPRITE_ANIME_IX][actionId]
		if spriteAnimationId != null:
			#we only reset the current delayed tap action id if a sprite animation will be played
			#reset delayed tap animation
			currentDelayedTapActionId=null	
		#bring the map BACK TO NORMAL, IN case a previous delayed tap was played		
		animationLookup[SPRITE_ANIME_IX][actionId] =animationLookupDefault[SPRITE_ANIME_IX][actionId]
		animationLookup[MVM_ANIME_IX][actionId] = animationLookupDefault[MVM_ANIME_IX][actionId]
	return actionId	
	
#return true when sprite id is an attack
func isReversalSpriteAnimationId(spriteAnimeId):
	
	if spriteAnimeId == null:
		return false
		
	return reversalSpriteAnimationIdMap.has(spriteAnimeId)


#returns true when the aniation is a reversable animation (after being hit, you can attack out of hit
#and it's consicered reverse: block stun, oki, histun, stunned, rebound)
func isReversableSpriteAnimationId(spriteAnimeId):
		
	if spriteAnimeId == null:
		return false
		
	return reversableSpriteAnimationIdMap.has(spriteAnimeId)
	

#returns true when the subclass of actionmanager speficied that the sprite animation
#id given is tied to a invincibility notification animation on hit
func isInvincibleSpriteAnimationId(spriteAnimeId):
	if spriteAnimeId == null:
		return false
	return invincibilitySpriteAnimationIdMap.has(spriteAnimeId)	
	
func getActionName(actionId):
	if actionId == null or not actionIdNameMap.has(actionId):
		return ""
		
	return actionIdNameMap[actionId]

func getActionFullDetails(actionId):
	if actionId == null or not actionIdDetailsMap.has(actionId):
		return ""
		
	return actionIdDetailsMap[actionId]
#reeturns true if there is a delayed tap animation that will start from an
#initial action id and eventually lead to a target action id as part of
#delayed tap action series
func isActionIdPartOfDelayedTapString(initialtActionId,targetActionId):
	
	if initialtActionId == null or targetActionId == null or initialtActionId < 0 or targetActionId < 0 or not isDelayedTapActionId(initialtActionId):
		return false
		
	var  tmpActionId = delayedTapActionIdLookup[initialtActionId]
	var foundActionFlag = false
	while(tmpActionId != null):
		
		if tmpActionId ==targetActionId:
			foundActionFlag=true
			break
			
		if delayedTapActionIdLookup.has(tmpActionId):
			tmpActionId=delayedTapActionIdLookup[tmpActionId]
		else:
			tmpActionId = null
			
	return foundActionFlag
	
func isInitialActionIdOfDelayedTapAniamtion(actionId):
	if isDelayedTapActionId(actionId):
		#only the initial action id has no reverse lookup, since first one in chain
		if not delayedTapActionIdReverseLookup.has(actionId):
			return true
			
			
	return false
		
		
#func isCounterRipostableCommand(cmd):
#	if cmd == null:
#		return false
		
	#any cmd in black list doesn't suport counter ripost (DP, for example should be in here)
#	return not counterRipostCmdBlackListMap.has(cmd)
	

func computePushBlockActionIdWhiteListMask1():
	return _computePushBlockActionIdWhiteListMask(autoCancelMaskMap)

func computePushBlockActionIdWhiteListMask2():
	return _computePushBlockActionIdWhiteListMask(autoCancelMaskMap2)
	
#returns an autocancel mask of all the pushblock action ids you can perform when locked out of input
func _computePushBlockActionIdWhiteListMask(_autoCancelMaskMap):
	
	var mask= 0
	
	#itreate over all ids that can be used a few moments after being pushblocked 
	for actionId in pushBlockActionIdWhiteList:
	
		if not _autoCancelMaskMap.has(actionId):
			pass
		else:
			mask = mask | _autoCancelMaskMap[actionId]
		
	return mask
	
func addOnTimeHitSpriteAnimationMap(srcSpriteAnimeId,remappedSpriteAnimeId):
	var map1 = oneTimeHitSpriteAnimationMap[HIT_THIS_COMBO_IX]
	var map2 = oneTimeHitSpriteAnimationMap[REMAPPED_SPRITE_ANIMATION_ID_IX]
	map1[srcSpriteAnimeId]=false
	map2[srcSpriteAnimeId]=remappedSpriteAnimeId
	
#returns true for aniamtions that will change prorpeties after hhtting for remainder of a combo
#false for any normal attack that doesn't have this special property
func hasOneTimeHitExpired(srcSpriteAnimeId):
	var map = oneTimeHitSpriteAnimationMap[HIT_THIS_COMBO_IX]
	
	return map.has(srcSpriteAnimeId)
	
#sets the expiry of a one-time hit per combo attack.
#so false resets it (combo ended or started)
#and true means expried, so can't be used again this combo
func _updateOneTimeHitExpired(srcSpriteAnimeId,flag):
	
	#do nothing for attacks that don't expire after one hit during a combo
	if not hasOneTimeHitExpired(srcSpriteAnimeId):
		return
		
	var map = oneTimeHitSpriteAnimationMap[HIT_THIS_COMBO_IX]
	
	map[srcSpriteAnimeId] = flag
	
func expireOneTimeHitAnimation(spriteAnimeId):
	_updateOneTimeHitExpired(spriteAnimeId,true)
	
func refreshOneTimeHitAnimation(spriteAnimeId):
	_updateOneTimeHitExpired(spriteAnimeId,false)

func refreshAllOneTimeHitAnimations(checkAbilityCancelRefreshBlackList):
	var map = oneTimeHitSpriteAnimationMap[HIT_THIS_COMBO_IX]
	var keys = map.keys()
	
	for spriteAnimeId  in keys:
		
		#do we conditionaly refresh if animation  not in refresh blacklist?
		if checkAbilityCancelRefreshBlackList:
			
			#only refresh animations not in blacklist
			if not isSpriteAnimationRefreshBlockedOnAbilityCancel(spriteAnimeId):
				map[spriteAnimeId] =false
		else:
			map[spriteAnimeId] =false
		
	
		
func oneTimeHitRemapSpriteAnimationId(spriteAnimeId):
	if not hasOneTimeHitExpired(spriteAnimeId):
		return spriteAnimeId
		
	var map = oneTimeHitSpriteAnimationMap[HIT_THIS_COMBO_IX]
	
	#sprite animatio nexpired?
	if map[spriteAnimeId] == true:
		var remapperMap = oneTimeHitSpriteAnimationMap[REMAPPED_SPRITE_ANIMATION_ID_IX]
		#expired, so return remapped aniamtion id
		return remapperMap[spriteAnimeId]
	else:
		#not expired yet, return the same sprite animation id
		return spriteAnimeId
		

#returns the sprite anime id that's remapped when expired
func lookupOneTimeHitRemapSpriteAniamtionId(spriteAnimeId):
	var remapperMap = oneTimeHitSpriteAnimationMap[REMAPPED_SPRITE_ANIMATION_ID_IX]
	if spriteAnimeId == null or not remapperMap.has(spriteAnimeId):
		return null
	return remapperMap[spriteAnimeId]
	
	
	
#returns true if the sprite animation associated to given action id
#prevents counter riposting 
func preventsCounterRipost(actionId):
	var sa = spriteAnimationLookup(actionId)
	
	if sa == null:
		return false
	
	return sa.preventCounterRipost
	

#returns true for stale animations that cann't be refreshed from ability cancel 
#False is returned if they aren't part of the blacklist (either can't go stale or can go stale and can be
#refreshed on ability cancel)
func isSpriteAnimationRefreshBlockedOnAbilityCancel(spriteAnimeId):
	if spriteAnimeId == null:
		return false
	
	return abCancelStaleAnimeRefreshBlackList.has(spriteAnimeId)
	
	
func isSpriteAnimationIdLinkedToAction(spriteAnimeId,actionId):
	if spriteAnimeId == null or actionId == null:
		return false
		
	var id = spriteAnimationIdLookup(actionId)
	return spriteAnimeId == id
	
	
func isTechSpriteAnimationId(spriteAnimeId):
	
	if spriteAnimeId == null:
		return false
		
	return techSpriteAnimationIdsMap.has(spriteAnimeId)
	
func isAirActionId(actionId):
	if actionId == null:
		return false
		
	return airActionIdMap.has(actionId)

func isSpriteAnimationInAirTurnAroundBlackList(spriteAnimeId):
	if spriteAnimeId == null:
		return true
	return airBornSupportPreventAutoFacingSpriteAnimeIds.has(spriteAnimeId)
	
