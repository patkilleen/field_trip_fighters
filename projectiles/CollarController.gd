extends "ProjectileController.gd"


signal landed

const inputMangerResource = preload("res://input_manager.gd")
const frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")

const MIN_NUMBER_BONES=0
const ACTION_ISSUE_INPUT_BUFFER_SIZE=7
const IDLE_AIR_ANIMATIONS_LANDING_LAG_DURATION=5

const DTOOL_DIG_EXTRA_FRAMES_PER_BONE_DURATION=10#10 FRAMES PER BONE EXTRA DURATION
#const NUMBER_BUFFERABLE_COMMANDS=3

#number of frames delay before collar plays the issue comomand (if the sifflet tool animations are
# too fast, can add a couple frames of delay before Collar listens) Kinda like collar pre-startup frames
#anything <=0 means no delay
export (int) var frameDelayBeforePlayIssuedSingleAction=5

#this is the delay that will take place if whistle let's sifflet stance 
#run out without manuall cnaceling 
export (int) var frameDelayBeforePlayIssuedMultiAction=20


# collar will stay put as long as he at most X pixels on a-axis away from Whistle
#colalr stars walking to whistle if whistle gets out of this range
export (float) var outterIdleWhistleXDistanceThreshold = 75
#when heading to whistle in idle, will only sit still once get really close to whilse
#to avoid constantly sitting on edge of the radius and constantly shifting between 
#sitting and walking to whisle when whislt e does micro movement  
export (float) var innerIdleWhistleXDistanceThreshold = 25 

#up to 5 attack commands can be done
export (int) var maxNumberOfBones=5

export (int) var dToolDigAnimationBaseDuation=50#50 frames base

enum CollarState{
	IDLE,
	RECEIVING_SINGLE_COMMAND,
	EXECUTING_SINGLE_COMMAND,
	RECEIVING_MULTI_COMMAND,
	EXECUTING_MULTI_COMMAND
}
var acceptsIssuedCmdsFlag=true
var bufferableActionEnabled=false

var bufferedMultiActionIx=0
var multiActionBuffer = []

var wasCollarLeftOfWhistle = true

var firstTimeSpawning=true


var groundSiffletWhistleAnimationCollarActionMap={}
var collarActionToCmdMap={}

#var playIssuedActionFrameCountDown=0
var basicPendingActionId=-1

var state = CollarState.IDLE

var singleCommandDelayTimer = null
var multiCommandDelayTimer = null

var issuedActionInputBuffer=[]
var issuedActionInputBufferIx=0

var dToolDigSpriteAnimation = null

var currNumBones=0

var dirtParticles = null
var boneParticles = null
var mvmOnlyCollarSpriteAnimeIdMap={} #collar action ids of the actions whistle can issue that are tied to mvm only (back and down tool)

var spriteAnimeIdMapOnFinishConsumBone={} #sprite anime ids of animations that when finished consume a bone
var collarActionIdWhistleParentSpriteAnimeIdMap={}
func _ready():
	

	pass
	
	
func init():
	
	#call parent init
	.init()

	#the ball cap doesn't hit anything. A simple raycast is used for know if Hat is ontop of it
	collisionHandler.set_physics_process(false)
	collisionHandler.ignoreCollisions=true
	
	for i in ACTION_ISSUE_INPUT_BUFFER_SIZE:
		issuedActionInputBuffer.append(null)
	
	#playerDetectionArea = $bodyBox/playerDetectionArea
	
	#var masterHud = masterPlayerController.kinbody.get_node("HUD/HBoxContainer2/pnameLabel")
	var masterHud = masterPlayerController.kinbody.playerNameLabel
	var collarHud = $HUD/HBoxContainer2/pnameLabel
	collarHud.text = masterHud.text
	collarHud.set("custom_colors/font_color",masterHud.get("custom_colors/font_color"))
	
	dirtParticles = $"active-nodes/digging-particles/dirt-particles"
	dirtParticles.visible = true
	dirtParticles.emitting=false

	boneParticles = $"active-nodes/digging-particles/bone-particles"
	boneParticles.visible = true
	boneParticles.emitting=false
	
	singleCommandDelayTimer = frameTimerResource.new()
	add_child(singleCommandDelayTimer)
	singleCommandDelayTimer.connect("timeout",self,"_on_single_command_delay_timeout")

	multiCommandDelayTimer = frameTimerResource.new()
	add_child(multiCommandDelayTimer)
	multiCommandDelayTimer.connect("timeout",self,"_on_multi_command_delay_timeout")
	

	
func _on_first_time_collar_spawned():
	
	
	for i in masterPlayerController.NUMBER_BUFFERABLE_COLLAR_ACTIONS:
		multiActionBuffer.append(null)
	
		
	groundSiffletWhistleAnimationCollarActionMap[masterPlayerController.actionAnimeManager.FORWARD_TOOL_SPRITE_ANIME_ID]=actionAnimationManager.FORWARD_TOOL_WALK_STARTUP_ACTION_ID
	groundSiffletWhistleAnimationCollarActionMap[masterPlayerController.actionAnimeManager.DOWNWARD_TOOL_SPRITE_ANIME_ID]=actionAnimationManager.DOWNWARD_TOOL_EXCITED_ACTION_ID
	groundSiffletWhistleAnimationCollarActionMap[masterPlayerController.actionAnimeManager.UPWARD_TOOL_SPRITE_ANIME_ID]=actionAnimationManager.UPWARD_TOOL_WALK_FORWARD_ACTION_ID
	groundSiffletWhistleAnimationCollarActionMap[masterPlayerController.actionAnimeManager.BACKWARD_TOOL_SPRITE_ANIME_ID]=actionAnimationManager.BACKWARD_TOOL_WALK_STARTUP_ACTION_ID

	groundSiffletWhistleAnimationCollarActionMap[masterPlayerController.actionAnimeManager.SIFFLET_STANCE_FORWARD_TOOL_SPRITE_ANIME_ID]=actionAnimationManager.FORWARD_TOOL_WALK_STARTUP_ACTION_ID
	groundSiffletWhistleAnimationCollarActionMap[masterPlayerController.actionAnimeManager.SIFFLET_STANCE_DOWNWARD_TOOL_SPRITE_ANIME_ID]=actionAnimationManager.DOWNWARD_TOOL_EXCITED_ACTION_ID
	groundSiffletWhistleAnimationCollarActionMap[masterPlayerController.actionAnimeManager.SIFFLET_STANCE_UPWARD_TOOL_SPRITE_ANIME_ID]=actionAnimationManager.UPWARD_TOOL_WALK_FORWARD_ACTION_ID
	groundSiffletWhistleAnimationCollarActionMap[masterPlayerController.actionAnimeManager.SIFFLET_STANCE_BAKCWARD_TOOL_SPRITE_ANIME_ID]=actionAnimationManager.BACKWARD_TOOL_WALK_STARTUP_ACTION_ID
	
	
	
	
	collarActionToCmdMap[actionAnimationManager.FORWARD_TOOL_WALK_STARTUP_ACTION_ID]=inputMangerResource.Command.CMD_FORWARD_TOOL
	collarActionToCmdMap[actionAnimationManager.FORWARD_TOOL_WALK_ACTIVE_ACTION_ID]=inputMangerResource.Command.CMD_FORWARD_TOOL
	collarActionToCmdMap[actionAnimationManager.FORWARD_TOOL_WALL_ARRIVE_ACTION_ID]=inputMangerResource.Command.CMD_FORWARD_TOOL
	collarActionToCmdMap[actionAnimationManager.FORWARD_TOOL_ATTACK_DASH_ACTION_ID]=inputMangerResource.Command.CMD_FORWARD_TOOL
	collarActionToCmdMap[actionAnimationManager.DOWNWARD_TOOL_EXCITED_ACTION_ID]=inputMangerResource.Command.CMD_DOWNWARD_TOOL
	collarActionToCmdMap[actionAnimationManager.UPWARD_TOOL_WALK_FORWARD_ACTION_ID]=inputMangerResource.Command.CMD_UPWARD_TOOL
	collarActionToCmdMap[actionAnimationManager.BACKWARD_TOOL_WALK_STARTUP_ACTION_ID]=inputMangerResource.Command.CMD_BACKWARD_TOOL
	collarActionToCmdMap[actionAnimationManager.BACKWARD_TOOL_WALK_ACTIVE_ACTION_ID]=inputMangerResource.Command.CMD_BACKWARD_TOOL
	collarActionToCmdMap[actionAnimationManager.BACKWARD_TOOL_WALL_ARRIVE_ACTION_ID]=inputMangerResource.Command.CMD_BACKWARD_TOOL
	collarActionToCmdMap[actionAnimationManager.BACKWARD_TOOL_ATTACK_DASH_ACTION_ID]=inputMangerResource.Command.CMD_BACKWARD_TOOL
	collarActionToCmdMap[actionAnimationManager.UPWARD_TOOL_WALK_FORWARD_ACTION_ID]=inputMangerResource.Command.CMD_UPWARD_TOOL
	collarActionToCmdMap[actionAnimationManager.UPWARD_TOOL_JUMP_ATTACK_ACTION_ID]=inputMangerResource.Command.CMD_UPWARD_TOOL
	collarActionToCmdMap[actionAnimationManager.UPWARD_TOOL_RECOVERY_ACTION_ID]=inputMangerResource.Command.CMD_UPWARD_TOOL

	collarActionToCmdMap[actionAnimationManager.UP_TOOL_ON_HIT_ANY_AIR_TOOL_DRAG_ATTACK_ACTION_ID]=inputMangerResource.Command.CMD_NEUTRAL_TOOL #AIR attakc, any input will do this attack in air

	
	#pre-populated the hitboxes with the command of the attack
	#for actionId in collarActionToCmdMap.keys():
	#	var cmd = collarActionToCmdMap[actionId]		
	#	var sa = actionAnimationManager.spriteAnimationLookup(actionId)
	#	if sa != null:			
	#		sa.store_command(cmd)

	collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.FORWARD_TOOL_WALK_STARTUP_ACTION_ID]=masterPlayerController.actionAnimeManager.FORWARD_TOOL_SPRITE_ANIME_ID
	collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.FORWARD_TOOL_WALK_ACTIVE_ACTION_ID]=masterPlayerController.actionAnimeManager.FORWARD_TOOL_SPRITE_ANIME_ID
	collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.FORWARD_TOOL_WALL_ARRIVE_ACTION_ID]=masterPlayerController.actionAnimeManager.FORWARD_TOOL_SPRITE_ANIME_ID
	collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.FORWARD_TOOL_ATTACK_DASH_ACTION_ID]=masterPlayerController.actionAnimeManager.FORWARD_TOOL_SPRITE_ANIME_ID
	collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.BACKWARD_TOOL_WALK_STARTUP_ACTION_ID]=masterPlayerController.actionAnimeManager.BACKWARD_TOOL_SPRITE_ANIME_ID
	collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.BACKWARD_TOOL_WALK_ACTIVE_ACTION_ID]=masterPlayerController.actionAnimeManager.BACKWARD_TOOL_SPRITE_ANIME_ID
	collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.BACKWARD_TOOL_WALL_ARRIVE_ACTION_ID]=masterPlayerController.actionAnimeManager.BACKWARD_TOOL_SPRITE_ANIME_ID
	collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.BACKWARD_TOOL_ATTACK_DASH_ACTION_ID]=masterPlayerController.actionAnimeManager.BACKWARD_TOOL_SPRITE_ANIME_ID
	collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.UPWARD_TOOL_WALK_FORWARD_ACTION_ID]=masterPlayerController.actionAnimeManager.UPWARD_TOOL_SPRITE_ANIME_ID
	collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.UPWARD_TOOL_JUMP_ATTACK_ACTION_ID]=masterPlayerController.actionAnimeManager.UPWARD_TOOL_SPRITE_ANIME_ID
	collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.UPWARD_TOOL_RECOVERY_ACTION_ID]=masterPlayerController.actionAnimeManager.UPWARD_TOOL_SPRITE_ANIME_ID
	collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.UP_TOOL_ON_HIT_ANY_AIR_TOOL_DRAG_ATTACK_ACTION_ID]=masterPlayerController.actionAnimeManager.AIR_NEUTRAL_TOOL_SPRITE_ANIME_ID
	#collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.GROUND_IDLE_ACTION_ID]=null
	#collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.LANDING_LAG_ACTION_ID]=null
	#collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.AIR_IDLE_ACTION_ID]=null
	#collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.WALK_TOWARD_WHISTLE_ACTION_ID]=null
	#collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.AIR_MOVE_TOWARD_WHISTLE_ACTION_ID]=null
	collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.BACKWARD_TOOL_WALK_STARTUP_ACTION_ID]=masterPlayerController.actionAnimeManager.BACKWARD_TOOL_SPRITE_ANIME_ID
	#collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.DOWNWARD_TOOL_EXCITED_ACTION_ID]=masterPlayerController.actionAnimeManager.DOWNWARD_TOOL_SPRITE_ANIME_ID
	#collarActionIdWhistleParentSpriteAnimeIdMap[actionAnimationManager.DOWNWARD_TOOL_DIG_ACTION_ID]=masterPlayerController.actionAnimeManager.DOWNWARD_TOOL_SPRITE_ANIME_ID




	spriteAnimeIdMapOnFinishConsumBone[actionAnimationManager.BACKWARD_TOOL_ATTACK_DASH_SPRITE_ANIME_ID]=null
	spriteAnimeIdMapOnFinishConsumBone[actionAnimationManager.BACKWARD_TOOL_WALL_ARRIVE_SPRITE_ANIME_ID]=null
	spriteAnimeIdMapOnFinishConsumBone[actionAnimationManager.FORWARD_TOOL_ATTACK_DASH_SPRITE_ANIME_ID]=null
	spriteAnimeIdMapOnFinishConsumBone[actionAnimationManager.FORWARD_TOOL_WALL_ARRIVE_SPRITE_ANIME_ID]=null	
	spriteAnimeIdMapOnFinishConsumBone[actionAnimationManager.UP_TOOL_ON_HIT_ANY_AIR_TOOL_DRAG_ATTACK_SPRITE_ANIME_ID]=null	
	spriteAnimeIdMapOnFinishConsumBone[actionAnimationManager.UPWARD_TOOL_JUMP_ATTACK_SPRITE_ANIME_ID]=null	
	spriteAnimeIdMapOnFinishConsumBone[actionAnimationManager.UP_TOOL_RECOVERY_SPRITE_ANIME_ID]=null



	
	#iterate over every action id to get the sprite anime id of whislte, then get the animation and assign to appropriate 
	#sprite animation for hitbox
	#gotta reset these every time cause i think restarting match rests them
	for collarActionId in collarActionIdWhistleParentSpriteAnimeIdMap.keys():
		
		var whistleSpriteAnimeId = collarActionIdWhistleParentSpriteAnimeIdMap[collarActionId]
		
		var whistleSpriteAnimation = masterPlayerController.actionAnimeManager.spriteAnimationManager.spriteAnimations[whistleSpriteAnimeId]
		var collarSpriteAnimation = actionAnimationManager._spriteAnimationLookup(collarActionId)
		#self.projectileParentSpriteAnimation=whistleSpriteAnimation
		#iterate all sprite frames of collar for hitboxes
		for spriteFrame in collarSpriteAnimation.spriteFrames:
			#iterate hitboxes
			for hb in spriteFrame.hitboxes:
				hb.projectileParentSpriteAnimation=whistleSpriteAnimation

			
	masterPlayerController.actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_whistle_sprite_animation_played")
	

	masterPlayerController.connect("entered_sifflet_stance",self,"_on_whistle_entered_sifflet_stance")
	masterPlayerController.connect("left_sifflet_stance",self,"_on_whistle_left_sifflet_stance")
	
	masterPlayerController.opponentPlayerController.collisionHandler.connect("player_was_hit",self,"_on_opponent_was_hit")
	
	
	dToolDigSpriteAnimation = actionAnimationManager.spriteAnimationManager.spriteAnimations[actionAnimationManager.DOWNWARD_TOOL_DIG_SPRITE_ANIME_ID]
	
	#mvmOnlyCollarSpriteAnimeIdMap[actionAnimationManager.BACKWARD_TOOL_WALK_STARTUP_SPRITE_ANIME_ID]=null
	mvmOnlyCollarSpriteAnimeIdMap[actionAnimationManager.DOWNWARD_TOOL_EXCITED_SPRITE_ANIME_ID]=null
	mvmOnlyCollarSpriteAnimeIdMap[actionAnimationManager.DOWNWARD_TOOL_DIG_SPRITE_ANIME_ID]=null


#override the function
func fire():
	
	_on_respawn()
	
	if firstTimeSpawning:
		_on_first_time_collar_spawned()

	#masterPlayerController._on_request_play_special_sound(LOSE_HAT_SCREAM_SOUND_ID,masterPlayerController.HERO_SOUND_SFX)
	playActionKeepOldCommand(startingActionId)
	#playActionKeepOldCommand(actionAnimationManager.IN_AIR_ACTION_ID)
	
	self.visible = true
	
	#start the timeer for duration of retreive ballcap lockout
	#ballCapRetreiveLockTimer.start(RETREIVE_BALL_CAP_LOCK_DURATION)
	
	actionAnimationManager.movementAnimationManager.deactivateAllMovement()
	movementAnimationManager.haltMovement()

	
	firstTimeSpawning=false
	.fire()

func _on_respawn():
	setNumberCollarBones(maxNumberOfBones)	
	
	
				
				
	dirtParticles.emitting=false
	boneParticles.emitting=false
	changeState(CollarState.IDLE)
	#clearDelayedBasicPendingAction()
	#collar spawns in front of whistle when game starts (right of whistle when whistle is player 1, left of whistle when whistle player two)
	#wasCollarLeftOfWhistle=not masterPlayerController.kinbody.facingRight
	#facingRight= wasCollarLeftOfWhistle
	#faceDirection(facingRight)
	
	clearIssuedActionsInputBuffer()
	#acceptsIssuedCmdsFlag=true
	#bufferableActionEnabled=false
	startingActionId =actionAnimationManager.AIR_IDLE_ACTION_ID
	
	#resetMultiActionBuffer()
	



func changeState(newState):
#	if state == newState:
#		return

	#do some cleanup if necessary for current state ending
	match(state):
		CollarState.IDLE:
			pass
		CollarState.RECEIVING_SINGLE_COMMAND:
			
			singleCommandDelayTimer.stop()
			
		CollarState.EXECUTING_SINGLE_COMMAND:
			pass
		CollarState.RECEIVING_MULTI_COMMAND:
			multiCommandDelayTimer.stop()
			pass
		CollarState.EXECUTING_MULTI_COMMAND:
			pass
		_:
			pass
			
	
		
	state = newState
	
	match(state):
		CollarState.IDLE:
			
			#acceptsIssuedCmdsFlag=true
			playIdleAnimation()
		CollarState.RECEIVING_SINGLE_COMMAND:
			
			#can only start processing a single command if have enough bones
			#for attack command
			#or if its a movement command
			
			var isAttackAction=not isCollarMvmOnlyActionId(basicPendingActionId)
			if currNumBones == MIN_NUMBER_BONES and isAttackAction:
				masterPlayerController.signalInsufficientNumberOfBones()
				#can't accept attack command. not enough bones
				state = CollarState.IDLE
				playIdleAnimation()
				return
			
			
				
			#no frame delay between reciveing and executing single action input?
			if frameDelayBeforePlayIssuedSingleAction <=0:
				_on_single_command_delay_timeout() #immediate timout
			else:
				#wait a brief moment before playing dedicated singel action 
				singleCommandDelayTimer.start(frameDelayBeforePlayIssuedSingleAction)
			

		CollarState.EXECUTING_SINGLE_COMMAND:
			faceWhistleFacing()
				
			playActionNewCommand(basicPendingActionId)					
			
			
			
			
		CollarState.RECEIVING_MULTI_COMMAND:
					
			resetMultiActionBuffer()
		CollarState.EXECUTING_MULTI_COMMAND:
			pass
		_:
			print("unknown collar state")


func updateCollarParentSpriteAnimeId(actionId):
	#actionAnimationManager.playAction(actionId,masterPlayerController.kinbody.spriteCurrentlyFacingRight)
	projectileParentSpriteAnimation=null
	if	collarActionIdWhistleParentSpriteAnimeIdMap.has(actionId):
		var whistleSpriteAnimeId = collarActionIdWhistleParentSpriteAnimeIdMap[actionId]		
		var whistleSpriteAnimation = masterPlayerController.actionAnimeManager.spriteAnimationManager.spriteAnimations[whistleSpriteAnimeId]
		projectileParentSpriteAnimation=whistleSpriteAnimation
		
func playAction(actionId):
	
	#if collarActionIdWhistleParentSpriteAnimeIdMap.has(actionId):
	#	projectileParentSpriteAnimation=collarActionIdWhistleParentSpriteAnimeIdMap[actionId]
	#else:
	#	pass
	#actionAnimationManager.playAction(actionId,masterPlayerController.kinbody.spriteCurrentlyFacingRight)
	updateCollarParentSpriteAnimeId(actionId)
	
	actionAnimationManager.playAction(actionId,spriteCurrentlyFacingRight)
	
	

func playActionNewCommand(actionId):	
	#playAction(actionId)
	
#	var cmd = null
	#lookup the command given aciton
	
#	if actionAnimationManager.isInUpToolAirHitStance():
		#every possible action is air tool pull in after up tool hit in air
#		cmd =inputMangerResource.Command.CMD_NEUTRAL_TOOL
#	else:
#		if collarActionToCmdMap.has(actionId):
#			cmd=collarActionToCmdMap[actionId]		
	#lookup the command tied to the basic attack and tie it to the animatino so it can be riposted and has proper visual effects
#	setAnimationCommand(actionId,cmd)
	updateCollarParentSpriteAnimeId(actionId)
	var cmd = null
	#lookup the command given aciton
	
	if actionAnimationManager.isInUpToolAirHitStance():
		#every possible action is air tool pull in after up tool hit in air
		cmd =inputMangerResource.Command.CMD_NEUTRAL_TOOL
	else:
		if collarActionToCmdMap.has(actionId):
			cmd=collarActionToCmdMap[actionId]		

	actionAnimationManager._playAction(actionId,spriteCurrentlyFacingRight,cmd)
	
func playActionKeepOldCommand(actionId):
#	var tmp = actionAnimationManager.commandActioned
	#playAction(actionId)
	updateCollarParentSpriteAnimeId(actionId)
	actionAnimationManager._playAction(actionId,spriteCurrentlyFacingRight,actionAnimationManager.commandActioned)
	#actionAnimationManager.commandActioned = command

func playIdleAnimation():
		
	faceTowardsWhistle()
	
				
	#collar is near Whistle?
	if isInOutterIdleRangeOfWhistle():
		#	
		if my_is_on_floor():
			playAction(actionAnimationManager.GROUND_IDLE_ACTION_ID)
		else:
			playAction(actionAnimationManager.AIR_IDLE_ACTION_ID)	
	else: 
		if my_is_on_floor():
			playAction(actionAnimationManager.WALK_TOWARD_WHISTLE_ACTION_ID)
		else:
			playAction(actionAnimationManager.AIR_MOVE_TOWARD_WHISTLE_ACTION_ID)


func playNextSiffletStanceBufferedAction():
	
	#if state == CollarState.EXECUTING_MULTI_COMMAND:
	var nextAction= popNextBufferedMultiAction()
	
	#we didn't have enough bones to execute the sifflet buffered commands?
	if nextAction == null:
		masterPlayerController.signalInsufficientNumberOfBones()
		#go idle
		changeState(CollarState.IDLE)
	else:
		playActionNewCommand(nextAction)
	
	
func _on_hitting_invincible_player(selfHitboxArea, otherHurtboxArea):
	_on_opponent_was_hit(selfHitboxArea,otherHurtboxArea)
func _on_hitting_player(selfHitboxArea, otherHurtboxArea):
	playOnHitSound(otherHurtboxArea,selfHitboxArea)
	
	
	
	masterPlayerController.hittingPlayerInCornerPushAwayCheck(selfHitboxArea, otherHurtboxArea)
	
	#display the command type and direction particles to 
	#give a visual indication of move hit with
	if selfHitboxArea!= null:
		if selfHitboxArea.cmd != null:
			attackSFXContainer.displayCommandParticles( selfHitboxArea.cmd)
		#dislay a light to indicate hitting with attack type	
		#handleAttackTypeLightingSignaling(selfHitboxArea)
			
	#selfHitboxArea.spriteAnimation.disableAllHitboxes()
	masterPlayerController._check_on_block_autoparry_hit(selfHitboxArea, otherHurtboxArea)

func  _on_player_attacked_clashed(otherHitboxArea, selfHitboxArea):
	#POWER HITBOXES won't make the projectil disapear
	#if selfHitboxArea.clashType == selfHitboxArea.CLASH_TYPE_POWER:
	#		return
			
	_on_request_play_special_sound(masterPlayerController.ATTACK_CLASH_SOUND_ID,COMMON_SOUND_SFX)
	

func _on_opponent_was_hit(selfHitboxArea, otherHurtboxArea):
	#collar hit opponent?
	if selfHitboxArea.projectileController != null and   selfHitboxArea.projectileController == self:
		var saId=selfHitboxArea.spriteAnimation.id
		
		match(saId):
		#the hitsunless trigger to start jump attack connected? That is, opponent is vertically above/below collar?
			actionAnimationManager.UPWARD_TOOL_WALK_FORWARD_SPRITE_ANIME_ID:
				playActionNewCommand(actionAnimationManager.UPWARD_TOOL_JUMP_ATTACK_ACTION_ID)			
				#hitstullness hitbox. nothing to do
				return
			actionAnimationManager.UPWARD_TOOL_JUMP_ATTACK_SPRITE_ANIME_ID:
				
				#can only go into the stance to pull opponent in if have bones,
				#cause any input will be trated as the pull in
				if currNumBones>MIN_NUMBER_BONES:
					actionAnimationManager.enterUpToolAirHitStance()
				#force the end of animation to allow buffered attacks or to allow
				#whistle to manually command collar to pull into him
				_on_action_animation_finished(selfHitboxArea.spriteAnimation.id)
				return
			#collar arrive below the opponent during f-tool walk?
			actionAnimationManager.FORWARD_TOOL_WALK_ACTIVE_SPRITE_ANIME_ID,actionAnimationManager.FORWARD_TOOL_WALK_STARTUP_SPRITE_ANIME_ID:
				playActionNewCommand(actionAnimationManager.FORWARD_TOOL_ATTACK_DASH_ACTION_ID)
				
				#hitstullness hitbox. nothing to do
				return
			#collar arrive below the opponent during b-tool walk?
			actionAnimationManager.BACKWARD_TOOL_WALK_ACTIVE_SPRITE_ANIME_ID,actionAnimationManager.BACKWARD_TOOL_WALK_STARTUP_SPRITE_ANIME_ID:
				playActionNewCommand(actionAnimationManager.BACKWARD_TOOL_ATTACK_DASH_ACTION_ID)
				
				#hitstullness hitbox. nothing to do
				return
			actionAnimationManager.BACKWARD_TOOL_ATTACK_DASH_SPRITE_ANIME_ID,actionAnimationManager.FORWARD_TOOL_ATTACK_DASH_SPRITE_ANIME_ID:
			
				playActionKeepOldCommand(actionAnimationManager.MOMENTUM_STOP_ACTION_ID)
				pass
func _on_left_ground():
	pass

func _on_ceiling_collision(collider):
	pass	

func _on_wall_collision(collider):
	
	pass


func _on_left_wall():
	
	pass
	
	
func _on_land():
	actionAnimationManager.leaveUpToolAirHitStance()
	
	#determine if in null aniamtion (between frames)
	var nullAnimationFlag=false
	var spriteFrame = null
	var spriteAnimation = actionAnimationManager.getCurrentSpriteAnimation()
	if spriteAnimation != null:
		spriteFrame = spriteAnimation.getCurrentSpriteFrame()
		
		if spriteFrame == null:
			nullAnimationFlag = true						
	else:
		nullAnimationFlag =true
		
			
	#collar isn't performing a dedicated animation?
	if nullAnimationFlag or isCollarFreeFromDedicatedAction():

		#can go into landing lag since landing lag can be cancel by a dedicated action
		adjustSpriteAnimationSpeed(IDLE_AIR_ANIMATIONS_LANDING_LAG_DURATION,actionAnimationManager.LANDING_LAG_ACTION_ID)		
		playActionKeepOldCommand(actionAnimationManager.LANDING_LAG_ACTION_ID)
		
	else:				
					
					
							
			
		#collar doing a dedicated animation and landed. Decide what to do
		#handle what kind of landing
		if spriteFrame.landing_lag == spriteFrame.LandingType.LAGLESS:
						
			#the dedicated animation collar was doing was laglessly stopped via landing?
			if state == CollarState.EXECUTING_SINGLE_COMMAND:
				
				#canceled (finished) an air animation with landing lag?
				if isAnimationOnFinishConsumesBone(spriteAnimation.id):
					#consume one bone when attack action starts being processed		
					setNumberCollarBones(currNumBones-1)
		
				changeState(CollarState.IDLE)
				
			elif state == CollarState.EXECUTING_MULTI_COMMAND:
				#consider animation finished for sake of managing the  EXECUTING_MULTI_COMMAND state
				_on_action_animation_finished(spriteAnimation.id)
			else:
				changeState(CollarState.IDLE)
				print("unknown collar state, going idle by default")

		elif spriteFrame.landing_lag == spriteFrame.LandingType.CONTINUE_ANIMATION:
			#if spriteAnimation.isLooping:
			#	print("warning, infinite loop detected for air sprite aniamtion id: "+str(spriteAnimation.id)+",going idle to fix bug")
			#	changeState(CollarState.IDLE)
			#do nothing, wait for animation to end (avoid infite loop air animations with continue animation)
			pass
		else:# spriteFrame.landing_lag == spriteFrame.LandingType.LANDING_LAG:
		
				#canceled (finished) an air animation with landing lag?
			if isAnimationOnFinishConsumesBone(spriteAnimation.id):
				#consume one bone when attack action starts being processed		
				setNumberCollarBones(currNumBones-1)
					
			#change the landing lag duratin based off of animation
			adjustSpriteAnimationSpeed(spriteAnimation.landingLagDuration,actionAnimationManager.LANDING_LAG_ACTION_ID)
			playActionKeepOldCommand(actionAnimationManager.LANDING_LAG_ACTION_ID)
	
	
	emit_signal("landed")

func _on_collar_whistle_crossup():
	
	#we have collar turn around to face whistle at all times when
	#not doing dedicated animation
	if isCollarFreeFromDedicatedAction():
		
		#collar is walking idle to whistle?
		if isCollarIdleyWalkingToWhistle():
			
			#make sure stop/walk in appropriate direction
			playIdleAnimation()
		else:
			#sitting down, so simple turn around is fine
			faceTowardsWhistle()	
		
		
		#start walking in other dirction
		#if isCollarIdleyWalkingToWhistle():#walking to whistle?

#turns collar towards whistle
func faceTowardsWhistle():
	
	#collar by default faces towards whistle
	var leftOfWhistleFlag = isLeftOfWhistle()
	wasCollarLeftOfWhistle=leftOfWhistleFlag # since changing facing, force the flag update instead waiting for physics_process
	facingRight=leftOfWhistleFlag
	faceDirection(facingRight)
	
#make collar face same direction whistle facing
func faceWhistleFacing():
		
	facingRight=masterPlayerController.kinbody.facingRight
	faceDirection(facingRight)

func _on_action_animation_finished(animeId):

	if isAnimationOnFinishConsumesBone(animeId):
		#consume one bone when attack action starts being processed		
		setNumberCollarBones(currNumBones-1)
	#	_on_number_collar_bones_changed(currNumBones)
	
	
	#finished startup of f-tool where can only hit (hitstunless) on link?
	if animeId==actionAnimationManager.FORWARD_TOOL_WALK_STARTUP_SPRITE_ANIME_ID:
		#play next part of animation. inifite walk to wall or until arrive below opponent
		playActionNewCommand(actionAnimationManager.FORWARD_TOOL_WALK_ACTIVE_ACTION_ID)						
		return
	#finished startup of f-tool where can only hit (hitstunless) on link?
	elif animeId==actionAnimationManager.BACKWARD_TOOL_WALK_STARTUP_SPRITE_ANIME_ID:
		#play next part of animation. inifite walk to wall or until arrive below opponent
		playActionNewCommand(actionAnimationManager.BACKWARD_TOOL_WALK_ACTIVE_ACTION_ID)						
		return	
		
	elif animeId==actionAnimationManager.UPWARD_TOOL_WALK_FORWARD_SPRITE_ANIME_ID:
		playActionNewCommand(actionAnimationManager.UPWARD_TOOL_RECOVERY_ACTION_ID)
		return
	#collar finished startup/first part of down tool animation?
	elif animeId==actionAnimationManager.DOWNWARD_TOOL_EXCITED_SPRITE_ANIME_ID:
		#change animation duration here based on how many bones need recover
		#its BASE DURATION + X * 10 where x = number bones, so 50 to 100 frames 
		#50 for no bones, 100 for max lost bones
		#proceed t next part
		dToolDigSpriteAnimation.loopDuration=dToolDigAnimationBaseDuation + (maxNumberOfBones-currNumBones)*DTOOL_DIG_EXTRA_FRAMES_PER_BONE_DURATION
		
		#start the diggiging particles 
		dirtParticles.emitting=true
		boneParticles.emitting=true
		playActionNewCommand(actionAnimationManager.DOWNWARD_TOOL_DIG_ACTION_ID)
		return 
	#collar finished entire dtool dig up bones animation?
	elif animeId==actionAnimationManager.DOWNWARD_TOOL_DIG_SPRITE_ANIME_ID:
		#refresh all bones
		#hide the diggiging particles 
		dirtParticles.emitting=false
		boneParticles.emitting=false
		setNumberCollarBones(maxNumberOfBones)
		
		#stop playing digging sound effect
		heroSFXSoundPlayer.stopAll()
	#collar finished the pull in air tool?
	elif animeId==actionAnimationManager.UP_TOOL_ON_HIT_ANY_AIR_TOOL_DRAG_ATTACK_SPRITE_ANIME_ID	:	
		#make sure can't input the air pull twice in a row before landing. leave the stance
		actionAnimationManager.leaveUpToolAirHitStance()
	
	#not doing dedicated action?	
	if isCollarFreeFromDedicatedAction():
		#go idle
		playIdleAnimation() 
	elif state == CollarState.EXECUTING_SINGLE_COMMAND:
		
		#the single dedicated command is finished. go idle
		changeState(CollarState.IDLE)
			
		
		#can only execute next single command if have enough bones
		var bufferedIssuedAction =  getNextIssuedActionFromInputBuffer()
		#did whistle very briefly ago try to input a collar action?
		if bufferedIssuedAction != null:
			
			#immediatly process the buffered input 
			basicPendingActionId=bufferedIssuedAction
			changeState(CollarState.RECEIVING_SINGLE_COMMAND)
		
			
	elif state == CollarState.EXECUTING_MULTI_COMMAND:
				
		#FINISHEd playing multiple commands or no multi command to begin with?
		if isBufferedMultiActionsListEmpty():
				
			#finish an animation. collar can now be controlled again (nothing is buffered)
			changeState(CollarState.IDLE)
			var bufferedIssuedAction =  getNextIssuedActionFromInputBuffer()
			#did whistle very briefly ago try to input a collar action?
			if bufferedIssuedAction != null:
				#immediatly process the buffered input 
				basicPendingActionId=bufferedIssuedAction
				changeState(CollarState.RECEIVING_SINGLE_COMMAND)
			
				
				
		else:
			playNextSiffletStanceBufferedAction()
		
		
	else:
		print("warning, unknown state in collar animation finished")
	
		
	
func _on_whistle_entered_sifflet_stance():
	
	if isCollarIdle():
		changeState(CollarState.RECEIVING_MULTI_COMMAND)
		

#called when whistle leave sifflet stance
#siffletEndStatusRC =WhistleController.SIFFLET_STANCE_MANUALLY_CANCELED_RC=0 the actiosn were succesfully buffere by manually ending stance
#siffletEndStatusRC =WhistleController.SIFFLET_STANCE_DURATION_ELLAPSED_RC=1 the actiosn were succesfully buffere by letting stance end without manual cancel
#siffletEndStatusRC =WhistleController.SIFFLET_STANCE_INTERRUPTED_RC=2 stance was interrupted, ingored all bufferd sifflet acitosn
func _on_whistle_left_sifflet_stance(siffletEndStatusRC):
	#			
			#var multiCommandDelayTimer = null
#frameDelayBeforePlayIssuedMultiAction
	if state == CollarState.RECEIVING_MULTI_COMMAND:
		var grafuleCompletionFlag=siffletEndStatusRC == masterPlayerController.SIFFLET_STANCE_MANUALLY_CANCELED_RC
		grafuleCompletionFlag = grafuleCompletionFlag or siffletEndStatusRC == masterPlayerController.SIFFLET_STANCE_DURATION_ELLAPSED_RC
		#SUCCESFULLY completed the sifflet stance and issuing play multi actions?
		if grafuleCompletionFlag:
			#_on_whistle_issued_sifflet_stance_completion()
			
				#empty sifflet stance (no issued actions)
			if isBufferedMultiActionsListEmpty():
				#go back to diel
				changeState(CollarState.IDLE)
			else:
				
				#manual cnacel means immediate play collar actions
				if siffletEndStatusRC == masterPlayerController.SIFFLET_STANCE_MANUALLY_CANCELED_RC:
					
					beginExecutingMultiCommands()
				else:
					#whistle let the animation run out, so there will be a slight delay for collar
					#to start
					multiCommandDelayTimer.start(frameDelayBeforePlayIssuedMultiAction)

				
				
				
		else:
			#whistle failed to complete sifflet stance. go back to idle
			changeState(CollarState.IDLE)
	

func _on_whistle_sprite_animation_played(anime):
	
	#if state == CollarState.EXECUTING_MULTI_COMMAND or state == CollarState.EXECUTING_SINGLE_COMMAND:
	#	return 
		
	var animeId = null
	if anime != null:
		animeId=anime.id
		#a baisc ground tool sifflet animation that controls collar?
		#if animeId != null and  masterPlayerController.actionAnimeManager.basicSiffletToolAnimationSpriteIdsMap.has(animeId):
	if animeId != null and groundSiffletWhistleAnimationCollarActionMap.has(animeId):
		var collarActionId = groundSiffletWhistleAnimationCollarActionMap[animeId]
		_on_whistle_issued_action(collarActionId)
		
	#the animation played is not a basic ground tool sifflet aniamtion, nor is it any of the sifflet stance animations
	#so, if we were buffering collar actions via sifflet, stance then lose all buffered commands and collar does nothing
	#the stance weas interrupted before issuing final compleition
	#elif bufferableActionEnabled and animeId != null and  masterPlayerController.actionAnimeManager.siffletToolAnimationSpriteIdsMap.has(animeId):

		
	#		acceptsIssuedCmdsFlag=true
			#whistle messed up and never completed the collar action
			#buffered (was hit, got stunned, etc)
			
			#clear the buffer
		
	#		resetMultiActionBuffer()
			
	
	#if animeId == masterPlayerController.actionAnimeManager.NEUTRAL_TOOL_SPRITE_ANIME_ID:
		#_on_whistle_entered_sifflet_stance()


#the STATE MACHINE FOR COLLAR WHISTLE INTERACTION START HERE
func _on_whistle_issued_action(actionId):
	if actionId == null:
		print("internal design error. Whistle is trying to buffer a null action id for collar")
		return
		
	match(state):
			
		CollarState.IDLE:
			basicPendingActionId=actionId
			changeState(CollarState.RECEIVING_SINGLE_COMMAND)
			return 
		CollarState.RECEIVING_MULTI_COMMAND:
		
		
			#can buffer a attack siflet command even if out of bones
			#cause the one count is verified right before the attack is
			#played
			#var isAttackAction=not isCollarMvmOnlyActionId(actionId)
			#if currNumBones == MIN_NUMBER_BONES and isAttackAction:
			#	masterPlayerController.signalInsufficientNumberOfBones()
				#can't accept attack command. not enough bones				
			#	return


		
			if isBufferedMultiActionsListFull():
				#whistle in sifflet stance, and already buffered max num actions
				#can't buffer an extra action. Drop the action. Whisle will need
				#to confirm the buffered issued commands
				
				return
			else:
			
				#sotre the issued action in buffer
				multiActionBuffer[bufferedMultiActionIx]=actionId
				bufferedMultiActionIx = bufferedMultiActionIx +1
		#COLLAR is busy doing a dedicated animation?
		CollarState.EXECUTING_MULTI_COMMAND,CollarState.EXECUTING_SINGLE_COMMAND:
			#buffer the action temporarily
			storeIssuedActionInInputBuffer(actionId)
		_:
			pass

func _on_single_command_delay_timeout():
	if state == CollarState.RECEIVING_SINGLE_COMMAND:
		changeState(CollarState.EXECUTING_SINGLE_COMMAND)

func _on_multi_command_delay_timeout():
	
	if state == CollarState.RECEIVING_MULTI_COMMAND:
		beginExecutingMultiCommands()
	

func beginExecutingMultiCommands():
				
	changeState(CollarState.EXECUTING_MULTI_COMMAND)
	faceWhistleFacing()
	playNextSiffletStanceBufferedAction()
	
func popNextBufferedMultiAction():
	

	#gotta consider number of bones we have. Whistle can try and sifflet buffer
	#more actions than he has bones
	var actionId = null
	for i in  multiActionBuffer.size():
		#found action id?		
		if multiActionBuffer[i]!= null:
			
			#we don't have any bones
			if currNumBones == MIN_NUMBER_BONES:
				#only consider mvm actions
				if isCollarMvmOnlyActionId(multiActionBuffer[i]):
					#found a mvm action
					actionId=multiActionBuffer[i]
					multiActionBuffer[i]=null
					break
				else:
					#its an acttack acton. clear it. keep searcihn
					multiActionBuffer[i]=null
			else:#have enough bones for this action
				actionId=multiActionBuffer[i]
				multiActionBuffer[i]=null
				break
	return actionId
	
func resetMultiActionBuffer():
	for i in  multiActionBuffer.size():
		multiActionBuffer[i]=null
	bufferedMultiActionIx=0
	
#returns true when whistle can't buffer any more actions as part of sifflet stance
func isBufferedMultiActionsListFull():
	var actionCount=0
	#go through all slots in the buffer to check for non hnull actiosn
	for i in  multiActionBuffer.size():
	
		#count the actions that exists in buffer (can't buffer null action)
		if multiActionBuffer[i]!=null:
			actionCount = actionCount +1
		
	return actionCount == multiActionBuffer.size()
	
func isBufferedMultiActionsListEmpty():
	var nullActionCount=0
	#go through all slots in the buffer to check for null actiosn
	for i in  multiActionBuffer.size():
			
		if multiActionBuffer[i]==null:
			nullActionCount = nullActionCount +1
		
	return nullActionCount == multiActionBuffer.size()


func isCollarIdle():
	return state == CollarState.IDLE

func isCollarFreeFromDedicatedAction():
	return state == CollarState.IDLE or state == CollarState.RECEIVING_MULTI_COMMAND or state == CollarState.RECEIVING_SINGLE_COMMAND
	
func isCollarIdleyWalkingToWhistle():
	var sa = actionAnimationManager.getCurrentSpriteAnimation()

	if sa == null:
		return true
		
	return sa.id == actionAnimationManager.WALK_TOWARD_WHISTLE_SPRITE_ANIME_ID or sa.id == actionAnimationManager.AIR_MOVE_TOWARD_WHISTLE_MVM_ANIME_ID
		

func isCollarIdleWaitingByWhistle():
	var sa = actionAnimationManager.getCurrentSpriteAnimation()

	if sa == null:
		return true
		
	return sa.id == actionAnimationManager.GROUND_IDLE_SPRITE_ANIME_ID or sa.id == actionAnimationManager.AIR_IDLE_SPRITE_ANIME_ID


	
#returns true when collar is in sitting idle range of whistle
#and false when collar is farther from that threshold
func isInInnerIdleRangeOfWhistle():
	var collarPos = self.getCenter()
	var whistlePos = masterPlayerController.kinbody.getCenter()
	
	var puppetMasterDistance = abs(whistlePos.x-collarPos.x)
	return puppetMasterDistance <= innerIdleWhistleXDistanceThreshold


func isInOutterIdleRangeOfWhistle():
	var collarPos = self.getCenter()
	var whistlePos = masterPlayerController.kinbody.getCenter()
	
	var puppetMasterDistance = abs(whistlePos.x-collarPos.x)
	return puppetMasterDistance <= outterIdleWhistleXDistanceThreshold


func isLeftOfWhistle():
	var collarPos = self.getCenter()
	var whistlePos = masterPlayerController.kinbody.getCenter()
	return  collarPos.x < whistlePos.x
	
func isWhistleNextToRightWall():
	return rightWallDetector.is_colliding() or rightFalseWallDetector.is_colliding()
func isWhistleNextToLeftWall():
	return leftWallDetector.is_colliding() or leftFalseWallDetector.is_colliding()
func isWhistleNextToWall():
	return leftWallDetector.is_colliding() or rightWallDetector.is_colliding() or leftFalseWallDetector.is_colliding() or rightFalseWallDetector.is_colliding()

func isCollarMvmOnlyActionId(actionId):
	if actionId == null:
		return false
	
	#do a two step lookup cause stance might have changed in air after uptool hits
	#and mvm input will be remapped to the coolar air tool pull in
	var actualSpriteAnime = actionAnimationManager.spriteAnimationLookup(actionId)
	
	if actualSpriteAnime != null:
		return  mvmOnlyCollarSpriteAnimeIdMap.has(actualSpriteAnime.id)
	else:
		return false


func isAnimationOnFinishConsumesBone(animeId):
	if animeId == null:
		return false

	return spriteAnimeIdMapOnFinishConsumBone.has(animeId)



	
func adjustSpriteAnimationSpeed(totalDurationInFrames,actionId):
	
	if actionId == -1:
		return
		
	var animation = actionAnimationManager.spriteAnimationLookup(actionId)
	
	#so: target-speed = animation-speed * actual-num-frames / totalDurationInFrames
	
	#below show be independent of global speed mod, since when running animation, globa speed, mod will
	#come into effect
	
	var targetSpeed = (animation.getDefaultSpeed() * animation.getNumberOfFrames()) /totalDurationInFrames
	animation.speed = targetSpeed 
	
func clearIssuedActionsInputBuffer():
	for i in issuedActionInputBuffer.size():
		issuedActionInputBuffer[i]=null
	issuedActionInputBufferIx=0

func getNextIssuedActionFromInputBuffer():
	var result=null
	var counter = 0
	var i =(issuedActionInputBufferIx+1)%issuedActionInputBuffer.size() #+1 since that's the oldest buffered action id. current ix is most recent (and next frame will override oldest)
	#iterate from the current cell through all elements cyclicly
	#to search for non null action id
	while(counter <issuedActionInputBuffer.size()):
		i = (i + 1)%issuedActionInputBuffer.size()
		
		if issuedActionInputBuffer[i]!= null:
			result=issuedActionInputBuffer[i]
			issuedActionInputBuffer[i]=null#pop the actin id out
			break
		counter = counter +1
	
	return result

func storeIssuedActionInInputBuffer(actionId):
	issuedActionInputBuffer[issuedActionInputBufferIx]=actionId

	
#called when a follow movement is initiated (starts/activates) and
#the follow destination type is other (not caster, nor opponent)
func _on_following_special_object_type_hook(followMvm):

	followMvm.src = masterPlayerController.opponentPlayerController.kinbody #the source object being moved is the opponent himself
	followMvm.dst = self #follow collar
		
		
		
func setAnimationCommand(_actionId,_cmd):
	var sa = actionAnimationManager.spriteAnimationLookup(_actionId)
	if sa != null:
		actionAnimationManager.commandActioned=_cmd		
		actionAnimationManager.spriteAnimationManager.cmd=_cmd			
		sa.store_command(_cmd)

func setNumberCollarBones(newNum):
	
	if newNum < MIN_NUMBER_BONES:
		print("warning, design issue, an animation consummed a bone when no bone were left")
		
	newNum = clamp(newNum,MIN_NUMBER_BONES,maxNumberOfBones)

	var numChangedFlag= newNum != currNumBones
	currNumBones=newNum
	
	if numChangedFlag:
		masterPlayerController._on_number_collar_bones_changed(currNumBones)
		
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	
	
	if isWhistleNextToWall():
		var sa = actionAnimationManager.getCurrentSpriteAnimation()
		if sa != null:
			
			#collar arrived to wall from forward tool and didn't encounter opponent ?
			if sa.id == actionAnimationManager.FORWARD_TOOL_WALK_STARTUP_SPRITE_ANIME_ID or sa.id == actionAnimationManager.FORWARD_TOOL_WALK_ACTIVE_SPRITE_ANIME_ID:
				
				var playFToolWallRecoveryFlag=false
				#collar walking forward/right and bump into right wall?
				if facingRight and isWhistleNextToRightWall():
					playFToolWallRecoveryFlag=true
				#collar walking left/forward and bump into left wall?
				elif not facingRight and isWhistleNextToLeftWall():
					playFToolWallRecoveryFlag=true
				
				#avoid being in contact with acorner and trying to f-tool away
				#and getting stuck by ending animatin early
				if playFToolWallRecoveryFlag:
					#go into f-tool recovery from bumping into wall
					playActionNewCommand(actionAnimationManager.FORWARD_TOOL_WALL_ARRIVE_ACTION_ID)
			elif sa.id == actionAnimationManager.BACKWARD_TOOL_WALK_STARTUP_SPRITE_ANIME_ID or sa.id == actionAnimationManager.BACKWARD_TOOL_WALK_ACTIVE_SPRITE_ANIME_ID:
				
				var playbToolWallRecoveryFlag=false
				#collar walking left/back (facing right) and bump into right wall?
				if facingRight and isWhistleNextToLeftWall():
					playbToolWallRecoveryFlag=true
				#collar walking right/back and bump into right wall?
				elif not facingRight and isWhistleNextToRightWall():
					playbToolWallRecoveryFlag=true
				
				#avoid being in contact with acorner and trying to B-tool away
				#and getting stuck by ending animatin early
				if playbToolWallRecoveryFlag:
					#go into f-tool recovery from bumping into wall
					playActionNewCommand(actionAnimationManager.BACKWARD_TOOL_WALL_ARRIVE_ACTION_ID)
				
	#collar is 	
	var leftOfWhistleFlag = isLeftOfWhistle()
	
	#cross-up
	if wasCollarLeftOfWhistle !=leftOfWhistleFlag:
		wasCollarLeftOfWhistle=leftOfWhistleFlag
		_on_collar_whistle_crossup()
			
			
	if isCollarFreeFromDedicatedAction():
	
		if isCollarIdleyWalkingToWhistle():#walking to whistle?
			
			if isInInnerIdleRangeOfWhistle():
				#collar arrive to whistle. stop
				if my_is_on_floor():
					playAction(actionAnimationManager.GROUND_IDLE_ACTION_ID)
				else:
					playAction(actionAnimationManager.AIR_IDLE_ACTION_ID)	
			else:
				pass #already walking to whistle
		elif isCollarIdleWaitingByWhistle(): #waiting next to whistle side?
			if not isInOutterIdleRangeOfWhistle(): #whistle got out of range?
				if my_is_on_floor():
					playAction(actionAnimationManager.WALK_TOWARD_WHISTLE_ACTION_ID)
				else:
					playAction(actionAnimationManager.AIR_MOVE_TOWARD_WHISTLE_ACTION_ID)			
			else:
				pass #do nothing, already next to whistle
	
	#maintain the action issue input buffer via cyclic iindex
	#and making buffered actions drop after a couple frames
	issuedActionInputBufferIx = (issuedActionInputBufferIx+1)%issuedActionInputBuffer.size()
	issuedActionInputBuffer[issuedActionInputBufferIx]=null
	
