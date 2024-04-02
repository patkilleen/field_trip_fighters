extends Node

var GLOBALS = preload("res://Globals.gd")

const PLUS_FRAMES_FROM_THROW = 3
var DEFAULT_THROW_DIRECTION_WITHOUT_INPUT = GLOBALS.DirectionalInput.NEUTRAL


const GROUND_BACKWARD_UP_TRHOW_HITSTUN_MVM_ANIMATION_ID = 0
const GROUND_FORWARD_UP_TRHOW_HITSTUN_MVM_ANIMATION_ID = 1
const GROUND_FORWARD_TRHOW_HITSTUN_MVM_ANIMATION_ID = 2
const GROUND_FORWARD_DOWN_TRHOW_HITSTUN_MVM_ANIMATION_ID = 3
const GROUND_DOWN_TRHOW_HITSTUN_MVM_ANIMATION_ID = 4
const GROUND_BACKWARD_DOWN_TRHOW_HITSTUN_MVM_ANIMATION_ID = 5
const GROUND_BACKWARD_TRHOW_HITSTUN_MVM_ANIMATION_ID = 6
const GROUND_UP_TRHOW_HITSTUN_MVM_ANIMATION_ID = 7
const GROUND_NEUTRAL_TRHOW_HITSTUN_MVM_ANIMATION_ID = 8

export (int, FLAGS, "Jump","F-Jump", "B-Jump","Ground Idle","Ground F-Move","Ground B-Move" ,"Crouch","N-Melee","N-Special","N-Tool","B-Special","auto ripost","Air Idle","Air F-Move","Air B-Move", "Air F-Dash", "Air B-Dash","Air-Melee","Air-Special","Air-Tool","Fast Fall","Air Move Stop", "Air auto ripost","F-Special","D-Melee","U-Tool","D-Tool","F-Tool","B-Tool","U-Special","F-Melee","B-Special") var abilityAutoCancelsOnHit = 0
export (int, FLAGS, "D-Special","B-Melee","U-Melee","F-Ground-Dash","B-Ground-Dash","Air-grab","grab","crouching-hold-back-block", "Platform Drop","Leave Platform Keep Animation", "F-dash crouch cancel","non-cancelable f-ground-dash","non-cancelable b-ground-dash","apex-of-jump-only fast-fall","standing-hold-back-block","air-hold-back-block","standing-push-block","air-push-block","Air Jump","Air F-Jump", "Air B-Jump","b-dash-Crouch-cancel","basic crouch cancel", "non-GDC jump","non-GDC F-jump", "non-GDC b-jump") var abilityAutoCancelsOnHit2 = 0

var input_manager_resource = preload("res://input_manager.gd")

const frameTimeResource = preload("res://hitFreezeAwareFrameTimer.gd")

#command representing last direction input done before grab started
#DEFAULT is forward
var lastDI = DEFAULT_THROW_DIRECTION_WITHOUT_INPUT

var playerController =null


var diCmdMap = {}

const GROUND_GRAB_IX = 0
const AIR_GRAB_IX = 1

var diThrowActionIdMap = [{},{}]
var throwingDIWindowActive = false

#var grabInitialThrowStartupAnimation = []
#var grabInitialThrowStartupAnimationId = []
var grabInitialThrowStartupActionId = []
#var grabAnimationId = []
var grabActionId = []

#var startupThrowHitboxes = [[],[]]


var activelyThrowing = false

var grabHitstunMvmAnimations = [[],[]]

var grabHitstunMvmAnimationIdMap = [{},{}]

var throwActionIdSelected = -1


var grabThrowSpriteAnimationIMap=[{},{}]
var grabCooldownTimer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#TODO: remove autoability canceling from game
	#for now just zero the cancel options
	abilityAutoCancelsOnHit=0
	abilityAutoCancelsOnHit2=0
	grabCooldownTimer = frameTimeResource.new()
	grabCooldownTimer.connect("timeout",self,"_on_grab_cooldown_timeout")
	add_child(grabCooldownTimer)
	
	#maps all the command  to direction enum
	#diCmdMap[input_manager_resource.Command.CMD_UP] = GLOBALS.DirectionalInput.UP
	#diCmdMap[input_manager_resource.Command.CMD_UPWARD_MELEE] = GLOBALS.DirectionalInput.UP
	#diCmdMap[input_manager_resource.Command.CMD_UPWARD_SPECIAL] = GLOBALS.DirectionalInput.UP
	#diCmdMap[input_manager_resource.Command.CMD_UPWARD_TOOL] = GLOBALS.DirectionalInput.UP
	
	
	#diCmdMap[input_manager_resource.Command.CMD_FORWARD_UP] = GLOBALS.DirectionalInput.FORWARD_UP
	#diCmdMap[input_manager_resource.Command.CMD_FORWARD_UP_PUSH_BLOCK] = GLOBALS.DirectionalInput.FORWARD_UP
	
	#diCmdMap[input_manager_resource.Command.CMD_GRAB] = GLOBALS.DirectionalInput.FORWARD #HOLDING/PRESESD forward, released up
	#diCmdMap[input_manager_resource.Command.CMD_MOVE_FORWARD] = GLOBALS.DirectionalInput.FORWARD
	#diCmdMap[input_manager_resource.Command.CMD_JUMP_FORWARD] = GLOBALS.DirectionalInput.FORWARD
	#diCmdMap[input_manager_resource.Command.CMD_FORWARD_MELEE] = GLOBALS.DirectionalInput.FORWARD
	#diCmdMap[input_manager_resource.Command.CMD_FORWARD_SPECIAL] = GLOBALS.DirectionalInput.FORWARD
	#diCmdMap[input_manager_resource.Command.CMD_FORWARD_TOOL] = GLOBALS.DirectionalInput.FORWARD
	#diCmdMap[input_manager_resource.Command.CMD_FORWARD_PUSH_BLOCK] = GLOBALS.DirectionalInput.FORWARD
	

	#diCmdMap[input_manager_resource.Command.CMD_BACKWARD_UP] = GLOBALS.DirectionalInput.BACKWARD_UP
	#diCmdMap[input_manager_resource.Command.CMD_BACKWARD_UP_PUSH_BLOCK] = GLOBALS.DirectionalInput.BACKWARD_UP
	
	
	#diCmdMap[input_manager_resource.Command.CMD_CROUCH] = GLOBALS.DirectionalInput.DOWN
	#diCmdMap[input_manager_resource.Command.CMD_AIR_DASH_DOWNWARD] = GLOBALS.DirectionalInput.DOWN
	#diCmdMap[input_manager_resource.Command.CMD_DOWNWARD_MELEE] = GLOBALS.DirectionalInput.DOWN
	#diCmdMap[input_manager_resource.Command.CMD_DOWNWARD_SPECIAL] = GLOBALS.DirectionalInput.DOWN
	#diCmdMap[input_manager_resource.Command.CMD_DOWNWARD_TOOL] = GLOBALS.DirectionalInput.DOWN
	
	
	#diCmdMap[input_manager_resource.Command.CMD_FORWARD_CROUCH] = GLOBALS.DirectionalInput.FORWARD_DOWN
	#diCmdMap[input_manager_resource.Command.CMD_FORWARD_CROUCH_PUSH_BLOCK] = GLOBALS.DirectionalInput.FORWARD_DOWN
	
	
	#diCmdMap[input_manager_resource.Command.CMD_BACKWARD_CROUCH] = GLOBALS.DirectionalInput.BACKWARD_DOWN
	#diCmdMap[input_manager_resource.Command.CMD_BACKWARD_CROUCH_PUSH_BLOCK] = GLOBALS.DirectionalInput.BACKWARD_DOWN
	
	
	#diCmdMap[input_manager_resource.Command.CMD_MOVE_BACKWARD] = GLOBALS.DirectionalInput.BACKWARD
	##diCmdMap[input_manager_resource.Command.CMD_BACKWARD_UP_RELEASE] = GLOBALS.DirectionalInput.BACKWARD#HOLDING/PRESESD backward, released up
	#diCmdMap[input_manager_resource.Command.CMD_JUMP_BACKWARD] = GLOBALS.DirectionalInput.BACKWARD
	#diCmdMap[input_manager_resource.Command.CMD_BACKWARD_MELEE] = GLOBALS.DirectionalInput.BACKWARD
	#diCmdMap[input_manager_resource.Command.CMD_BACKWARD_SPECIAL] = GLOBALS.DirectionalInput.BACKWARD
	#diCmdMap[input_manager_resource.Command.CMD_BACKWARD_TOOL] = GLOBALS.DirectionalInput.BACKWARD
	#diCmdMap[input_manager_resource.Command.CMD_DASH_BACKWARD] = GLOBALS.DirectionalInput.BACKWARD #DON'T INlucnde dash forward, seince forward dash is default dash from just R2/trigger press
	#diCmdMap[input_manager_resource.Command.CMD_BACKWARD_PUSH_BLOCK] = GLOBALS.DirectionalInput.BACKWARD
	
	
	#maps the direction enum to throw histun mvm grab throw animations
	grabHitstunMvmAnimationIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.UP] = GROUND_UP_TRHOW_HITSTUN_MVM_ANIMATION_ID
	grabHitstunMvmAnimationIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.FORWARD_UP] = GROUND_FORWARD_UP_TRHOW_HITSTUN_MVM_ANIMATION_ID
	grabHitstunMvmAnimationIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.BACKWARD_UP] = GROUND_BACKWARD_UP_TRHOW_HITSTUN_MVM_ANIMATION_ID
	
	grabHitstunMvmAnimationIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.DOWN] = GROUND_DOWN_TRHOW_HITSTUN_MVM_ANIMATION_ID
	grabHitstunMvmAnimationIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.FORWARD_DOWN] = GROUND_FORWARD_DOWN_TRHOW_HITSTUN_MVM_ANIMATION_ID
	grabHitstunMvmAnimationIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.BACKWARD_DOWN] = GROUND_BACKWARD_DOWN_TRHOW_HITSTUN_MVM_ANIMATION_ID
	
	grabHitstunMvmAnimationIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.FORWARD] = GROUND_FORWARD_TRHOW_HITSTUN_MVM_ANIMATION_ID
	grabHitstunMvmAnimationIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.BACKWARD] = GROUND_BACKWARD_TRHOW_HITSTUN_MVM_ANIMATION_ID
	#grabHitstunMvmAnimationIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.NEUTRAL] = GROUND_FORWARD_TRHOW_HITSTUN_MVM_ANIMATION_ID
	grabHitstunMvmAnimationIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.NEUTRAL] = GROUND_NEUTRAL_TRHOW_HITSTUN_MVM_ANIMATION_ID
	
	#TODO,implement new air mvovment (like stop gravity the movements )
	grabHitstunMvmAnimationIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.UP] = GROUND_UP_TRHOW_HITSTUN_MVM_ANIMATION_ID
	grabHitstunMvmAnimationIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.FORWARD_UP] = GROUND_FORWARD_UP_TRHOW_HITSTUN_MVM_ANIMATION_ID
	grabHitstunMvmAnimationIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.BACKWARD_UP] = GROUND_BACKWARD_UP_TRHOW_HITSTUN_MVM_ANIMATION_ID
	
	grabHitstunMvmAnimationIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.DOWN] = GROUND_DOWN_TRHOW_HITSTUN_MVM_ANIMATION_ID
	grabHitstunMvmAnimationIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.FORWARD_DOWN] = GROUND_FORWARD_DOWN_TRHOW_HITSTUN_MVM_ANIMATION_ID
	grabHitstunMvmAnimationIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.BACKWARD_DOWN] = GROUND_BACKWARD_DOWN_TRHOW_HITSTUN_MVM_ANIMATION_ID
	
	grabHitstunMvmAnimationIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.FORWARD] = GROUND_FORWARD_TRHOW_HITSTUN_MVM_ANIMATION_ID
	grabHitstunMvmAnimationIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.BACKWARD] = GROUND_BACKWARD_TRHOW_HITSTUN_MVM_ANIMATION_ID
	
	#grabHitstunMvmAnimationIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.NEUTRAL] = GROUND_FORWARD_TRHOW_HITSTUN_MVM_ANIMATION_ID
	grabHitstunMvmAnimationIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.NEUTRAL] = GROUND_NEUTRAL_TRHOW_HITSTUN_MVM_ANIMATION_ID
	
	
	
	#add hitstun movement animations to list
	for c in $"ground-throw-hitstun-mvm".get_children():
		
		if c is preload("res://movementAnimation.gd"):
			grabHitstunMvmAnimations[GROUND_GRAB_IX].append(c)
	for c in $"air-throw-hitstun-mvm".get_children():
		
		if c is preload("res://movementAnimation.gd"):
			grabHitstunMvmAnimations[AIR_GRAB_IX].append(c)
	
	
	#diCmdMap
	pass # Replace with function body.

func reset():
	throwingDIWindowActive = false
	throwActionIdSelected = -1
	activelyThrowing = false
	grabCooldownTimer.stop()
func init(_playerController):
	playerController = _playerController
	reset()
	#grabCooldownDurationInSecs = _grabCooldownDurationInSecs
	#make sure to connect to signals that represent grab cooldown changes
	playerController.playerState.connect("grab_cooldown_changed",self,"_on_grab_cooldown_changed")
	
	#id of pre-launch on grab starupt throw sprite aniamtion id
	#grabInitialThrowStartupAnimationId.append(playerController.actionAnimeManager.ON_HIT_GROUND_GRAB_SPRITE_ANIME_ID)
	#grabInitialThrowStartupAnimationId.append(playerController.actionAnimeManager.ON_HIT_AIR_GRAB_SPRITE_ANIME_ID)

	grabInitialThrowStartupActionId.append(playerController.actionAnimeManager.ON_HIT_GROUND_GRAB_ACTION_ID)
	grabInitialThrowStartupActionId.append(playerController.actionAnimeManager.ON_HIT_AIR_GRAB_ACTION_ID)

	
	#id of the first part of grab that hasn't first hitbox to hit and then throw	
	#grabAnimationId.append(playerController.actionAnimeManager.GROUND_GRAB_SPRITE_ANIME_ID)
	#grabAnimationId.append(playerController.actionAnimeManager.AIR_GRAB_SPRITE_ANIME_ID)
	
	grabActionId.append(playerController.actionAnimeManager.GROUND_GRAB_ACTION_ID)
	grabActionId.append(playerController.actionAnimeManager.AIR_GRAB_ACTION_ID)
	
	#the sprite animation the is executed if grab lands on player but before DI determine 
	#trhow direction
	#grabInitialThrowStartupAnimation.append(playerController.actionAnimeManager.spriteAnimationLookup(playerController.actionAnimeManager.ON_HIT_GROUND_GRAB_ACTION_ID))
	#grabInitialThrowStartupAnimation.append(playerController.actionAnimeManager.spriteAnimationLookup(playerController.actionAnimeManager.ON_HIT_AIR_GRAB_ACTION_ID))
	
	
	
	
	#map all DI to action ids of player's movment when throwing opponent
	diThrowActionIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.UP]=playerController.actionAnimeManager.GROUND_GRAB_UP_THROW_ACTION_ID
	diThrowActionIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.FORWARD_UP]=playerController.actionAnimeManager.GROUND_GRAB_FORWARD_UP_THROW_ACTION_ID
	diThrowActionIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.BACKWARD_UP] =playerController.actionAnimeManager.GROUND_GRAB_BACKWARD_UP_THROW_ACTION_ID
	
	diThrowActionIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.DOWN] =playerController.actionAnimeManager.GROUND_GRAB_DOWN_THROW_ACTION_ID
	diThrowActionIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.FORWARD_DOWN] =playerController.actionAnimeManager.GROUND_GRAB_FORWARD_DOWN_THROW_ACTION_ID
	diThrowActionIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.BACKWARD_DOWN]=playerController.actionAnimeManager.GROUND_GRAB_BACKWARD_DOWN_THROW_ACTION_ID
	
	diThrowActionIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.FORWARD]=playerController.actionAnimeManager.GROUND_GRAB_FORWARD_THROW_ACTION_ID
	diThrowActionIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.BACKWARD]=playerController.actionAnimeManager.GROUND_GRAB_BACKWARD_THROW_ACTION_ID
	#diThrowActionIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.NEUTRAL]=playerController.actionAnimeManager.GROUND_GRAB_FORWARD_THROW_ACTION_ID
	diThrowActionIdMap[GROUND_GRAB_IX][GLOBALS.DirectionalInput.NEUTRAL]=playerController.actionAnimeManager.GROUND_GRAB_NEUTRAL_THROW_ACTION_ID
	
	#map all DI to action ids of player's movment when throwing opponent
	diThrowActionIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.UP]=playerController.actionAnimeManager.AIR_GRAB_UP_THROW_ACTION_ID
	diThrowActionIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.FORWARD_UP]=playerController.actionAnimeManager.AIR_GRAB_FORWARD_UP_THROW_ACTION_ID
	diThrowActionIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.BACKWARD_UP] =playerController.actionAnimeManager.AIR_GRAB_BACKWARD_UP_THROW_ACTION_ID
	
	diThrowActionIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.DOWN] =playerController.actionAnimeManager.AIR_GRAB_DOWN_THROW_ACTION_ID
	diThrowActionIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.FORWARD_DOWN] =playerController.actionAnimeManager.AIR_GRAB_FORWARD_DOWN_THROW_ACTION_ID
	diThrowActionIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.BACKWARD_DOWN]=playerController.actionAnimeManager.AIR_GRAB_BACKWARD_DOWN_THROW_ACTION_ID
	
	diThrowActionIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.FORWARD]=playerController.actionAnimeManager.AIR_GRAB_FORWARD_THROW_ACTION_ID
	diThrowActionIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.BACKWARD]=playerController.actionAnimeManager.AIR_GRAB_BACKWARD_THROW_ACTION_ID
	
	#diThrowActionIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.NEUTRAL]=playerController.actionAnimeManager.AIR_GRAB_FORWARD_THROW_ACTION_ID
	diThrowActionIdMap[AIR_GRAB_IX][GLOBALS.DirectionalInput.NEUTRAL]=playerController.actionAnimeManager.AIR_GRAB_NEUTRAL_THROW_ACTION_ID
	
		
	populateThrowSpriateAnimationIdMap()
	
	#startupThrowHitboxes.append(grabInitialThrowStartupAnimation[GROUND_GRAB_IX].getHitboxes())
	#startupThrowHitboxes.append(grabInitialThrowStartupAnimation[AIR_GRAB_IX].getHitboxes())
	
	
func populateThrowSpriateAnimationIdMap():
	#populate the map that holds sprite animation ids of throws
	for di in diThrowActionIdMap[GROUND_GRAB_IX].keys():
		var throwActionId = diThrowActionIdMap[GROUND_GRAB_IX][di]
		var sa = playerController.actionAnimeManager.spriteAnimationLookup(throwActionId)
		var saId = sa.id
		grabThrowSpriteAnimationIMap[GROUND_GRAB_IX][saId]=null#null since we only use for lookup
	
	for di in diThrowActionIdMap[AIR_GRAB_IX].keys():
		var throwActionId = diThrowActionIdMap[AIR_GRAB_IX][di]
		var sa = playerController.actionAnimeManager.spriteAnimationLookup(throwActionId)
		var saId = sa.id
		grabThrowSpriteAnimationIMap[AIR_GRAB_IX][saId]=null#null since we only use for lookup
		

func _on_sprite_animation_played(sa):
	
	#we interrupted our throw(cancel or was hit)?
	#the aniamtion should have otherwise finished
	#if activelyThrowing and playerController.opponentPlayerController.playerState.inHitStun:
	if activelyThrowing:
	
		#stop the opponent
		#so below code works but it messes up up throw
		#	playerController.opponentPlayerController.playActionKeepOldCommand(playerController.opponentPlayerController.actionAnimeManager.MOMENTUM_STOP_ACTION_ID)
		pass
		
		
	#started the thorw aniamtion (in grab recovery and moving opponent)?
	if sa != null  and  (grabThrowSpriteAnimationIMap[AIR_GRAB_IX].has(sa.id) or grabThrowSpriteAnimationIMap[GROUND_GRAB_IX].has(sa.id) ):
		activelyThrowing = true
		
		
		#dynamically adjust all the auto ability cancel masks so the grab can cancel, but only if opponent wasn't originally in hitstun when we grabbed
		var sFrames = sa.spriteFrames
		#iterate over each frame
		for i in sFrames.size():
			var sf = sFrames[i]
			#skip first frames to make auto ability cancel window +10 (last two frames combined are 10 frames)
			 
		
			#only allow autoability canceling when the grabbing in neutral
			if i>0 and playerController.playerState.combo<=1 :
				sf.abilityAutoCancelsOnHit=abilityAutoCancelsOnHit
				sf.abilityAutoCancelsOnHit2=abilityAutoCancelsOnHit2
			else:
				#otherwise can't autoability cancel
				sf.abilityAutoCancelsOnHit=0
				sf.abilityAutoCancelsOnHit2=0
		
			i = i +1
				
	else:
		activelyThrowing = false	
		
	
	#geta the ground grab animation id  for ground	grab and check whether played animation matches the grab's id
	#ground grab's initial throw animation (successfully grabed opponent) started (next throw animation decided by DI during this animation)?
	#if sa != null and sa.id == grabInitialThrowStartupAnimationId[GROUND_GRAB_IX]:		
	if sa != null and sa.id ==playerController.actionAnimeManager.spriteAnimationIdLookup(grabInitialThrowStartupActionId[GROUND_GRAB_IX]):
	
		#playerController.playerState.isGrabOnCooldown=true
		playerController.playerState.grabCharges= playerController.playerState.grabCharges -1 
		#can now input directional input to decide throw type (all 8 directiosn)
		throwingDIWindowActive = true
		
		#sa.hittingWithJumpCancelableHitbox=true
		#clear the next action id of startupt throw aniamtion
		#setStartupThrowOnHitActionId(diThrowActionIdMap[GROUND_GRAB_IX][DEFAULT_THROW_DIRECTION_WITHOUT_INPUT],null)
	
	#air grab's initial throw animation (successfully grabed opponent)
	#elif sa != null and sa.id == grabInitialThrowStartupAnimationId[AIR_GRAB_IX]:
	elif sa != null and sa.id == playerController.actionAnimeManager.spriteAnimationIdLookup(grabInitialThrowStartupActionId[AIR_GRAB_IX]):
	
		#playerController.playerState.isGrabOnCooldown=true
		playerController.playerState.grabCharges= playerController.playerState.grabCharges -1 
		#can now input directional input to decide throw type (all 8 directiosn)
		throwingDIWindowActive = true
		#sa.hittingWithJumpCancelableHitbox=true
		#setStartupThrowOnHitActionId(diThrowActionIdMap[AIR_GRAB_IX][lastDI],null)
		#clear the next action id of startupt throw aniamtion
		#setStartupThrowOnHitActionId(diThrowActionIdMap[AIR_GRAB_IX][DEFAULT_THROW_DIRECTION_WITHOUT_INPUT],null)
		
	#ground grab (haven't grabbed oppoent yet)
	#elif sa != null and sa.id == grabAnimationId[GROUND_GRAB_IX]:
	elif sa != null and sa.id == playerController.actionAnimeManager.spriteAnimationIdLookup(grabActionId[GROUND_GRAB_IX]):
	
		throwingDIWindowActive = true
		#clear the DI input from last grab BY USING defulat trhow direction
		lastDI = DEFAULT_THROW_DIRECTION_WITHOUT_INPUT
		prepareThrowDirection(lastDI)
		
		
		#clear the next action id of startupt throw aniamtion
		#setStartupThrowOnHitActionId(diThrowActionIdMap[GROUND_GRAB_IX][DEFAULT_THROW_DIRECTION_WITHOUT_INPUT],null)
	#air grab (haven't grabbed oppoent yet)
	#elif sa != null and sa.id == grabAnimationId[AIR_GRAB_IX]:
	elif sa != null and sa.id == playerController.actionAnimeManager.spriteAnimationIdLookup(grabActionId[AIR_GRAB_IX]):
		throwingDIWindowActive = true
		#clear the DI input from last grab  BY USING defulat trhow direction
		lastDI = DEFAULT_THROW_DIRECTION_WITHOUT_INPUT
		prepareThrowDirection(lastDI)
		
		
		
		#clear the next action id of startupt throw aniamtion
	#	setStartupThrowOnHitActionId(diThrowActionIdMap[AIR_GRAB_IX][DEFAULT_THROW_DIRECTION_WITHOUT_INPUT],null)
	else:
		throwingDIWindowActive = false
		
		
			
		

	
	
func _on_hitting_player(hitbox,hurtbox):
	
	var sa = hitbox.spriteAnimation
	
	#ground grab's initial throw animation (successfully grabed opponent) started (next throw animation decided by DI during this animation)?
	#if sa != null and sa.id == grabInitialThrowStartupAnimationId[GROUND_GRAB_IX] or sa.id == grabInitialThrowStartupAnimationId[AIR_GRAB_IX]:
	if sa != null and sa.id == playerController.actionAnimeManager.spriteAnimationIdLookup(grabInitialThrowStartupActionId[GROUND_GRAB_IX]) or playerController.actionAnimeManager.spriteAnimationIdLookup(grabInitialThrowStartupActionId[AIR_GRAB_IX]):
		
		#can now input directional input to decide throw type (all 8 directiosn)
		throwingDIWindowActive = true
	pass

func _on_action_animation_finished(saId):
	#can't be throwing if an animation ended
	activelyThrowing = false
	
	#grab's initial throw animation finished (next frame will be throw animation decided by DI during this animation)?
#	if saId != null and saId ==grabInitialThrowStartupAnimationId:	
	
#		print("di'ed: "+str(lastDI))
	pass
		
func _on_grab_input_released(diEnum):
			
	#can only input throw DI when the throw window active
	if throwingDIWindowActive:
		prepareThrowDirection(diEnum)

func prepareThrowDirection(diEnum):
		
		#we will be setting up the next animation to link up on grab based on DI
		
		#the id of throw action to play when starutp throw aniamtion end
		var throwActionId = -1
		var hitstunMvmAnimation =-1

		#only map kown di commands
		lastDI=diEnum
		
		var mvmAnimationIx = null
		#get the hitstun throw mvmv animation depending if on floor or air grabing
		if playerController.my_is_on_floor():
			throwActionId=diThrowActionIdMap[GROUND_GRAB_IX][lastDI]
			mvmAnimationIx=grabHitstunMvmAnimationIdMap[GROUND_GRAB_IX][lastDI]
			hitstunMvmAnimation= grabHitstunMvmAnimations[GROUND_GRAB_IX][mvmAnimationIx]
		else:
			throwActionId=diThrowActionIdMap[AIR_GRAB_IX][lastDI]
			mvmAnimationIx=grabHitstunMvmAnimationIdMap[AIR_GRAB_IX][lastDI]
			hitstunMvmAnimation= grabHitstunMvmAnimations[AIR_GRAB_IX][mvmAnimationIx]
		
	
		#lookupt action id to play and assign to next actoin id
		#grabInitialThrowStartupAnimation.nextActionId = throwActionId
		setStartupThrowOnHitActionId(throwActionId,hitstunMvmAnimation)
		
	#else:
		
	#	grabInitialThrowStartupAnimation.nextActionId = diThrowActionIdMap[DEFAULT_THROW_DIRECTION_WITHOUT_INPUT]

	
func setStartupThrowOnHitActionId(nextActionId,movementAnimation):
	
	throwActionIdSelected = nextActionId
	
	#iterate over ground and air throw to affect next hit action id to deice the throw movement
	#go over the action ids of the on hit grab actions	
	for grabActionId in  grabInitialThrowStartupActionId:
		
		#geta the grab animation
		var grabSA = playerController.actionAnimeManager.spriteAnimationLookup(grabActionId)
		
		#get the hitboxes
		var startupHitboxes = grabSA.getHitboxes()
		
		
		for hb in startupHitboxes:
			hb.on_hit_action_id = nextActionId
			hb.hitstunMovementAnimation=movementAnimation
			
	
#func isHitboxAGrabHitbox(hb):
#	if attackSpriteId != attackerPlayerController.actionAnimeManager.ON_HIT_AIR_GRAB_SPRITE_ANIME_ID and attackSpriteId != attackerPlayerController.actionAnimeManager.ON_HIT_GROUND_GRAB_SPRITE_ANIME_ID and attackSpriteId != attackerPlayerController.actionAnimeManager.GROUND_GRAB_SPRITE_ANIME_ID and attackSpriteId != attackerPlayerController.actionAnimeManager.AIR_GRAB_SPRITE_ANIME_ID:
#		#able to apply hitstun, so now the grab goes off cooldown
#		opponentPlayerController.playerState.isGrabOnCooldown=false

#func _on_grab_cooldown_changed(grabAvailable):
func _on_grab_cooldown_changed(grabCharges,oldGrabCharges):
	#we have all the grab charges back?
	var allGrabChargesAvailable = grabCharges == playerController.playerState.defaultGrabCharges

	if allGrabChargesAvailable:
		if grabCooldownTimer != null:
			grabCooldownTimer.stop()
		
	else:
		
		#atleast 1 of the grabs should come back, so start cooldown timer
		if grabCooldownTimer != null:
			
			#already running from last cooldown charge? let it run
			#it'll then restart when it rungs out
			if not grabCooldownTimer.active:
				var time = computeGrabCooldownTime()
				grabCooldownTimer.startInSeconds(time)
			

#called when cooldown timer timed out. the bookkeeping will be done in _on_grab_cooldown_changed
#as that is attached to signals of cooldown changes in grab
func _on_grab_cooldown_timeout():
	
	#playerController.playerState.isGrabOnCooldown=false
	#playerController
	playerController.playerState.grabCharges= playerController.playerState.grabCharges +1 
	
func computeGrabCooldownTime():
	var time = playerController.grabCooldownTime
	#in air?
	if not playerController.my_is_on_floor():
		#add the additional cooldown duration from air grab
		time = time +playerController.additionalCooldownToAirGrab
	return time	
		