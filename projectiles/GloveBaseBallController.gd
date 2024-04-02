extends "ProjectileController.gd"

signal caught_ball

var stringAttachedFlag = true

const TIME_IN_FRAMES_BEFORE_IDLE_IN_CORNER=10
var TIME_IN_SECONDS_BEFORE_IDLE_IN_CORNER=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS * TIME_IN_FRAMES_BEFORE_IDLE_IN_CORNER
var  MINIMUM_REEL_TIME_BEFORE_BOUNCE_IN_SECONDS=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS *5
const BAT_HIT_CATCH_LOCK_DURATION = 10


const UP_REEL_TYPE = 0
const BACK_REEL_TYPE = 1
const AIR_REEL_TYPE = 2
const DEFAULT_REEL_TYPE = 3

var trailParticles = null
var stringBreakParticles = null

var defaultHP = 100
var hp = defaultHP setget setHP,getHP

var hpBar = null
var transparencyTween = null
var defaultColor = null
var targetTransparentColor = null

var transparencyAnimatinDelayTimer =null
var frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")

var opponentStandingDetectorArea = null
#var opponentProximityDetector = null
var gloveStandingDetector = null

var gloveWasStandingOnBall = false
var opponentWasStandingOnBall = false

var onBatHitCatchLock = false
var batHitCatchLockTimer = null

var canBeCaught = false
const TOP_LEFT_IX =0
const TOP_IX =1
const TOP_RIGHT_IX =2
const RIGHT_IX =3
const BOTTOM_RIGHT_IX =4
const BOTTOM_IX =5
const BOTTOM_LEFT_IX =6
const LEFT_IX =7
const OTHER_IX =TOP_IX #other will just be top, since ball should bust when enter's oponen'ts body

const Y_UP= -1
const Y_DOWN= 1
const Y_NEUTRAL= 0
const X_NEUTRAL= 0
const X_LEFT= -1
const X_RIGHT = 1

var opponentInBlockStun = false
var keepAirMomentumBMRelativeNodePath = "cplx_mvm5/original-velocity"
#holds anngle related to hitting oppontent and bouncing
var hitBounceNormals = []
#given glove's bat attack animation sprite id, associate animtation to bat ball
#away
var gloveBatThrowAnimationLookup = {}

#var keepMomentumBM = null
#var keepAirMomentumAnimation = null

#var playerDetectionArea = null
var backReelFollowMvm = null

var activeGlowSprite = null
#var throwBounceOffPlayerMvmAnimation = null
#var reelBounceOffPlayerMvmAnimation = null

#var throwBounceCmplxMvm=null
#var reelInBounceCmplxMvm = null

var keepMomentumCplxMvm = null

const STRING_BREAK_SOUND_IX = 27
const BALL_THROW_SOUND_IX = 29
const BASEBALL_BAT_HIT_SOUND_IX = 25
const BASEBALL_BOUNCE_SOUND_IX = 34

const BASEBALL_BAT_HIT_VOLUME = 6
var lastBatAttackHitActionId = null
const BALL_HIT_SPRITE_ANIMATION_ID_IX=0
const BALL_HIT_COMPLX_MVM_IX=1
var ballHitBounceOffPlayerMap = [{},{}]

const MINIMUM_DURATION_FOR_REEL_BEFORE_END_IN_CORNER=30

var opponentOnBall = false
var onBatteleField=false

var collidingWithGlove= false
var collidingWithOpponent= false

const ON_HIT_STRING_BREAK_IMMUNITY_DURATION = 17 # num frames immune string break after hit
var stringBreakImmunityTimer = null
var stringBreakImunityTimerRunning = false

var batHitParticles=null
var throwParticles=null
var reelParticles=null

var ballBatHitLocked = false

var ballHasActiveHitbox = false

var stringSpawn = null
var defaultOffScreenMagnifyingGlass = null
func _ready():
	trailParticles = $"particle-trail"
	
	
	
	
	
	hpBar = $hpBar
	stringBreakParticles = $"string-break-particles"
	
	batHitParticles=$batHitParticles
	throwParticles=$throwParticles
	reelParticles=$reelParticles
	
	batHitCatchLockTimer = frameTimerResource.new()
	self.add_child(batHitCatchLockTimer)
	batHitCatchLockTimer.connect("timeout",self,"_on_bat_hit_catch_lock_timeout")
	defaultOffScreenMagnifyingGlass=true
	
	batHitParticles.visible=false
	throwParticles.visible = false
	reelParticles.visible = false
	
	batHitParticles.emitting=false
	throwParticles.emitting = false
	reelParticles.emitting = false
	
	#used for storing bounce information
	#throwBounceOffPlayerMvmAnimation = $"ProjectileController/ActionAnimationManager/MovementAnimationManager/throw-bounce-off-player"
	#reelBounceOffPlayerMvmAnimation = $"ProjectileController/ActionAnimationManager/MovementAnimationManager/reel-in-bounce-off-player"

	#throwBounceCmplxMvm=$"ProjectileController/ActionAnimationManager/MovementAnimationManager/throw-bounce-off-player/cplx_mvm6"
	#reelInBounceCmplxMvm = $"ProjectileController/ActionAnimationManager/MovementAnimationManager/reel-in-bounce-off-player/cplx_mvm7"
	
	#defaultColor = hpBar.get("custom_colors/font_color")
	defaultColor = hpBar.modulate
	hpBar.visible = false
	targetTransparentColor = defaultColor
	targetTransparentColor.a = 0#transparent
	#transparencyTween = Tween.new()
	#self.add_child(transparencyTween)
	
#	transparencyTween.connect("tween_completed",self,"_on_hp_bar_transparancy_tween_complete")
	
	transparencyAnimatinDelayTimer = frameTimerResource.new()
	self.add_child(transparencyAnimatinDelayTimer)
	transparencyAnimatinDelayTimer.connect("timeout",self,"_on_transparancy_hp_bar_delay_timeout")	

	
	hitBounceNormals.append(Vector2(X_LEFT,Y_UP).normalized())#top left
	hitBounceNormals.append(Vector2(X_NEUTRAL,Y_UP).normalized())#top
	hitBounceNormals.append(Vector2(X_RIGHT,Y_UP).normalized())#top RIGHT
	hitBounceNormals.append(Vector2(X_RIGHT,Y_NEUTRAL).normalized())#RIGHT
	hitBounceNormals.append(Vector2(X_RIGHT,Y_DOWN).normalized())#BOTTOM RIGHT
	hitBounceNormals.append(Vector2(X_NEUTRAL,Y_DOWN).normalized())#BOTTOM
	hitBounceNormals.append(Vector2(X_LEFT,Y_DOWN).normalized())#BOTTOM LEFT
	hitBounceNormals.append(Vector2(X_LEFT,Y_NEUTRAL).normalized())#LEFT
	
	activeGlowSprite = $activeGlowBgd
func init():
	

	#only enable magifying glass when on stage
	offScreenMagnifyingGlass = false		
	stringSpawn = $"ProjectileController/string-spawn"
	stringSpawn.init(1,self) #one string will ever exist
	
	#call parent init
	.init()

	
	bodyBox.disabled = true
	
	stringBreakImmunityTimer = frameTimerResource.new()
	stringBreakImmunityTimer.connect("timeout",self,"_on_string_break_immunity_timeout")
	
	self.add_child(stringBreakImmunityTimer)
	



	#keepMomentumBM = $"ProjectileController/ActionAnimationManager/MovementAnimationManager/keep-air-momentum-animation/cplx_mvm5/keep-air-momentum-bm"
	#keepAirMomentumAnimation = $"ProjectileController/ActionAnimationManager/MovementAnimationManager/keep-air-momentum-animation"
	#keepMomentumCplxMvm = $"ProjectileController/ActionAnimationManager/MovementAnimationManager/keep-air-momentum-animation/cplx_mvm5"
	gloveBatThrowAnimationLookup[masterPlayerController.actionAnimeManager.NEUTRAL_SPECIAL_SPRITE_ANIME_ID] =actionAnimationManager.N_SPECIAL_BAT_HIT_ACTION_ID  
	gloveBatThrowAnimationLookup[masterPlayerController.actionAnimeManager.FORWARD_SPECIAL_SPRITE_ANIME_ID] =actionAnimationManager.B_SPECIAL_BAT_HIT_ACTION_ID  
	gloveBatThrowAnimationLookup[masterPlayerController.actionAnimeManager.UPWARD_MELEE_SPRITE_ANIME_ID] =actionAnimationManager.U_MELEE_BAT_HIT_ACTION_ID  
	gloveBatThrowAnimationLookup[masterPlayerController.actionAnimeManager.NEW_B_MELEE_SPRITE_ANIME_ID] =actionAnimationManager.B_MELEE_BAT_HIT_ACTION_ID  
	gloveBatThrowAnimationLookup[masterPlayerController.actionAnimeManager.UPWARD_SPECIAL_SPRITE_ANIME_ID] =actionAnimationManager.U_SPECIAL_BAT_HIT_ACTION_ID
	#gloveBatThrowAnimationLookup[masterPlayerController.actionAnimeManager.AIR_NEUTRAL_SPECIAL_SPRITE_ANIME_ID] =actionAnimationManager.AIR_SPECIAL_BAT_HIT_ACTION_ID
	gloveBatThrowAnimationLookup[masterPlayerController.actionAnimeManager.NEW_AIR_SPECIAL_P1_SPRITE_ANIME_ID] =actionAnimationManager.AIR_SPECIAL_BAT_HIT_ACTION_ID
	gloveBatThrowAnimationLookup[masterPlayerController.actionAnimeManager.NEW_AIR_SPECIAL_P2_SPRITE_ANIME_ID] =actionAnimationManager.AIR_SPECIAL_BAT_HIT_ACTION_ID
	gloveBatThrowAnimationLookup[masterPlayerController.actionAnimeManager.NEW_AIR_SPECIAL_P3_SPRITE_ANIME_ID] =actionAnimationManager.AIR_SPECIAL_BAT_P3_HIT_ACTION_ID
	gloveBatThrowAnimationLookup[masterPlayerController.actionAnimeManager.DOWNWARD_SPECIAL_SPRITE_ANIME_ID] =actionAnimationManager.D_SPECIAL_BAT_HIT_ACTION_ID
	gloveBatThrowAnimationLookup[masterPlayerController.actionAnimeManager.NEW_BACK_SPECIAL_SPRITE_ANIME_ID] =actionAnimationManager.NEW_B_SPECIAL_BAT_HIT_ACTION_ID
	
	
	if not masterPlayerController.opponentPlayerController.is_connected("entered_block_hitstun",actionAnimationManager,"_on_opponent_entered_block_stun"):
		masterPlayerController.opponentPlayerController.connect("entered_block_hitstun",actionAnimationManager,"_on_opponent_entered_block_stun")
		
	if not masterPlayerController.opponentPlayerController.is_connected("entered_block_hitstun",self,"_on_opponent_entered_block_stun"):
		masterPlayerController.opponentPlayerController.connect("entered_block_hitstun",self,"_on_opponent_entered_block_stun")
	
	if not masterPlayerController.opponentPlayerController.is_connected("exited_block_stun",self,"_on_opponent_exited_block_hitstun"):
		masterPlayerController.opponentPlayerController.connect("exited_block_stun",self,"_on_opponent_exited_block_hitstun")		

	#playerDetectionArea = $bodyBox/playerDetectionArea
	
	#var masterHud = masterPlayerController.kinbody.get_node("HUD/HBoxContainer2/pnameLabel")
	var masterHud = masterPlayerController.kinbody.playerNameLabel
	var ballHud = $HUD/HBoxContainer2/pnameLabel
	ballHud.text = masterHud.text
	ballHud.set("custom_colors/font_color",masterHud.get("custom_colors/font_color"))
	
	
	actionAnimationManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_sprite_animation_played")
	actionAnimationManager.spriteAnimationManager.connect("sprite_frame_activated",self,"_on_sprite_frame_activated")
	
	masterPlayerController.actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_glove_sprite_animation_played")
	
	#if self.has_node("ProjectileController/ActionAnimationManager/MovementAnimationManager/MovementAnimations/b-tool-reel/cplx_mvm4/bm0"):
		#make sure to get reference to back reel follow movement (will break if change node name)
	#	backReelFollowMvm = $"ProjectileController/ActionAnimationManager/MovementAnimationManager/MovementAnimations/b-tool-reel/cplx_mvm4/bm0"
	#else:
		#print("warning, expected back reel at node path, but node path changed")
		
	opponentStandingDetectorArea = $bodyBox/opponentStandingDetectorArea
	
	opponentStandingDetectorArea.connect("area_entered",self,"_on_opponented_stepped_onto_ball")
	opponentStandingDetectorArea.connect("area_exited",self,"_on_opponented_stepped_away_from_ball")
	
	gloveStandingDetector = $bodyBox/gloveStandingDetector
	#opponentProximityDetector = $bodyBox/opponentProximityDetector
	
	#make sure ACTION animation manager aware to remap actions to string attached actions
	actionAnimationManager.setStringAttachedFlag(true)
	stringAttachedFlag = true
	 
	#keepMomentumBM.movementAnimationManager=actionAnimationManager.movementAnimationManager
	
	#iterate all basic movment, and connect to follow complete
	for mAnimes in movementAnimationManager.movementAnimations:
		for cm in mAnimes.complexMovements:
			for bm in cm.basicMovements:
				#the basic movement is a follow movement?
				if bm is preload("res://FollowMovement.gd"):
					
					#connect to singals that indicate ball arrived to glove
					bm.connect("restart_following",self,"_on_restart_following")
					bm.connect("arrived",self,"_on_arrived")

	#configure standing detection
#	gloveStandingDetector.collision_mask = 1 << masterPlayerController.kinbody.pushableBodyBoxCollisionBit
	gloveStandingDetector.collision_mask = 1 << masterPlayerController.kinbody.bodyBoxCollisionBit


	#opponentStandingDetector.collision_mask = masterPlayerController.opponentPlayerController.kinbody.hurtBoxLayer
	opponentStandingDetectorArea.collision_mask = masterPlayerController.opponentPlayerController.kinbody.hurtBoxLayer


	
	#detects hitboxes
	#playerDetectionArea.collision_mask = masterPlayerController.kinbody.hurtBoxLayer |masterPlayerController.opponentPlayerController.kinbody.hurtBoxLayer
	#playerDetectionArea.collision_mask = masterPlayerController.opponentPlayerController.kinbody.hurtBoxLayer
	#playerDetectionArea.collision_mask = 0
	#playerDetectionArea.connect("area_entered",self,"_player_entered_balls_space")
#	playerDetectionArea.connect("area_exited",self,"_player_exited_balls_space")
	
	gloveWasStandingOnBall = false
	opponentWasStandingOnBall = false

func setHP(value):
	hp = value
	
	#update and display hp bar
	var fracFilled = value/defaultHP
	hpBar.setValue(100*fracFilled)
	displayHPBar()
	
func getHP():
	return hp	
	
func _on_land():
	
	_on_request_play_special_sound(BASEBALL_BOUNCE_SOUND_IX,HERO_SOUND_SFX)
	
	if leftWallDetector.is_colliding() or rightWallDetector.is_colliding() or leftFalseWallDetector.is_colliding() or rightFalseWallDetector.is_colliding():
		
		
		

		#we only make ball stop if we didn't just start reeling it in
		#to prevent ball from getting caught in corner
		
		if actionAnimationManager.isCurrentSpriteAnimation(actionAnimationManager.B_TOOL_REEL_ACTION_ID) or actionAnimationManager.isCurrentSpriteAnimation(actionAnimationManager.AIR_TOOL_NO_BALL_REEL_ACTION_ID):
			var sa = actionAnimationManager.spriteAnimationManager.currentAnimation
			if sa != null and sa.timeEllaspedSinceAniamtionStart >= MINIMUM_DURATION_FOR_REEL_BEFORE_END_IN_CORNER:			
				
				goIntoIdleAnimation()	
		else:
			goIntoIdleAnimation()			
		
		return
	var sAnime=actionAnimationManager.getCurrentSpriteAnimation()
	if sAnime != null:
		
		var sf = sAnime.getCurrentSpriteFrame()
		
		if sf != null:
#			enum LandingType{
			#	LAGLESS,
			#	LANDING_LAG,
		#	CONTINUE_ANIMATION

			if sf.landing_lag == sf.LandingType.LAGLESS:
				goIntoIdleAnimation()			
			elif sf.landing_lag == sf.LandingType.CONTINUE_ANIMATION:
				#let it continue
				#print("let the ball keep going on ground")
				pass
			else:
				#not supported  yet (maybe a bounce)
				#TODO: Implement landing animation
				#for now go idle
				goIntoIdleAnimation()
		else:
			goIntoIdleAnimation()	
	else:
		goIntoIdleAnimation()
	#only got into  ground idle attached when ball on string and not getting reeled in
#	if stringAttachedFlag:
		
#		if actionAnimationManager.U_TOOL_REEL_SPRITE_ANIME_ID == actionAnimationManager.currentSpriteAnimation:
#			actionAnimationManager.playUserAction(actionAnimationManager.GROUND_IDLE_ATTACHED_ACTION_ID,facingRight,command)
#			return
			
#		var inAir = false
#		attemptGoIntoGroundIdle(inAir)
#		
	

func _on_left_ground():
	pass

func _on_ceiling_collision(collider):
	_on_request_play_special_sound(BASEBALL_BOUNCE_SOUND_IX,HERO_SOUND_SFX)
	pass	

func _on_wall_collision(collider):
	
	_on_request_play_special_sound(BASEBALL_BOUNCE_SOUND_IX,HERO_SOUND_SFX)
	
	#print("hit wall")

	#avoid having ball getting stuck active in corner
	if my_is_on_floor():
		
		#we only go into idel if its been more than 10 frames to give chance
		#for bat hits to fremove ball from corner
		var sa = actionAnimationManager.spriteAnimationManager.currentAnimation
		
		if sa == null:
			return
			
		if sa.timeEllaspedSinceAniamtionStart >= TIME_IN_SECONDS_BEFORE_IDLE_IN_CORNER:			
			goIntoIdleAnimation()
		return
	
	
	var sa = actionAnimationManager.spriteAnimationManager.currentAnimation

	#we only make the ball bounce if it's not immediatly against the wall
	#to prevent wall ball reels as wall bumps into ball
	#to cancel the pull
	if sa != null and sa.timeEllaspedSinceAniamtionStart >= MINIMUM_REEL_TIME_BEFORE_BOUNCE_IN_SECONDS:			
		#below might not even be necessary, since i think i fixe the get stuck on wall buck without it. but it works. so ill leave it
		if actionAnimationManager.isCurrentSpriteAnimation(actionAnimationManager.B_TOOL_REEL_ACTION_ID) or actionAnimationManager.isCurrentSpriteAnimation(actionAnimationManager.AIR_TOOL_NO_BALL_REEL_ACTION_ID):
			actionAnimationManager.playUserAction(actionAnimationManager.REELED_INTO_WALL_BOUNCE_ACTION_ID,masterPlayerController.kinbody.spriteCurrentlyFacingRight,command)
	pass
	#goIntoIdleAnimation()
	
func _on_restart_following(src,dst,followMovement):
	pass
	
func _on_arrived(src,dst,followMovement):
	#_on_ball_caught()
	#go idle, ball arrived where glove initially reeled
	
	
	if my_is_on_floor():
		goIntoIdleAnimation()
	else:	
		
		airReelMomentumCancel(followMovement)
	

	
func _on_ball_caught():


	#only enable magifying glass when on stage
	offScreenMagnifyingGlass = false
	self.visible = false
	onBatteleField=false
	
	emit_signal("remove_magnifying_glass",self)
	
	masterPlayerController.emit_signal("player_state_info_text_changed","")
	
	playAction(actionAnimationManager.OFF_BATTLEFIELD_ACTION_ID)
	
	opponentStandingDetectorArea.monitoring=false
	opponentOnBall=false
	
	
	#make sure ACTION animation manager aware to remap actions to no string actions
	actionAnimationManager.setStringAttachedFlag(true)
	stringAttachedFlag = true
	#reset collision values to avoid incorrectly signaling when destryog/respawing ball
	collisionHandler.init()
	
	
	#ball isn't active anymore, stop collision detectio nand movement
	movementAnimationManager.set_physics_process(false)
	collisionHandler.set_physics_process(false)
	
	#this is to make sure the ball stops bouncing mvm when caught
	actionAnimationManager.movementAnimationManager.deactivateAllMovement()
	
	if stringBreakImunityTimerRunning:
		#unpause timer
		stringBreakImmunityTimer.stop()
		stringBreakImunityTimerRunning=false
	
	
	bodyBox.disabled = true
	
	#clear any collision that happened same frame (so ball won't break or get hit by bat
	#if catching the same frame being hit)
	collisionHandler.collisionAreas.clear()
	
	movementAnimationManager.haltMovement()
	
	collisionHandler.ignoreCollisions=true
	
	#to avoid having ball exist on stage and frame perfect situation of throw ball and hitbox exists where ball 
	#wwas when caught (this should address long range  string break bug)
	self.position = Vector2(50000,50000)
	
	offScreenMagnifyingGlass=false #don't display the ball in magnifying glass when inactive
	
	emit_signal("caught_ball",self)
func _on_break_string():
	
	
	
	#prevents bug where at start of match bunch of collisiosn detection signals are poorly managed
	if not onBatteleField:
		return
	
	masterPlayerController.emit_signal("player_state_info_text_changed",GLOBALS.GLOVE_NOTIFICATION_TEXT_BROKEN_STRING)
	#avoid emitting the break particles every frame if opponent on ball or hitting hit frequently
	if stringAttachedFlag:
		_on_request_play_special_sound(STRING_BREAK_SOUND_IX,HERO_SOUND_SFX)
		stringBreakParticles.emitting = true
	
	
	#can reel again
	actionAnimationManager.unlockAllReels()
	
	#make sure ACTION animation manager aware to remap actions to no string actions
	actionAnimationManager.setStringAttachedFlag(false)
	canBeCaught=true
	stringAttachedFlag = false
	
	
#
	
	#break string, go into broken string animation
	
	if my_is_on_floor():
		actionAnimationManager.playUserAction(actionAnimationManager.GROUND_BROKEN_STRING_IDLE_ACTION_ID,masterPlayerController.kinbody.spriteCurrentlyFacingRight,command)
	else:
		actionAnimationManager.playUserAction(actionAnimationManager.AIR_BROKEN_STRING_IDLE_ACTION_ID,masterPlayerController.kinbody.spriteCurrentlyFacingRight,command)
	trailParticles.emitting = false
	
	



func goIntoIdleAnimation():
	
	if not my_is_on_floor():
		if stringAttachedFlag:
			playActionKeepOldCommand(actionAnimationManager.IDLE_ACTION_ID)
			
		else:
			playActionKeepOldCommand(actionAnimationManager.AIR_BROKEN_STRING_IDLE_ACTION_ID)
			
	else:
		if stringAttachedFlag:
			playActionKeepOldCommand(actionAnimationManager.GROUND_IDLE_ATTACHED_ACTION_ID)
			
		else:
			playActionKeepOldCommand(actionAnimationManager.GROUND_BROKEN_STRING_IDLE_ACTION_ID)
			
	

	
func _on_projectile_was_hit(otherHitboxArea, selfHurtboxArea):
	
	if not onBatteleField:
		return
		
	#it's glove picking up his ball?
	if otherHitboxArea.selfOnly:
		
		#can't hit ball twice with same animation
		if ballBatHitLocked:
			return
		#for now, hitting broken string ball catches it
	#	if actionAnimationManager.isCurrentSpriteAnimation(actionAnimationManager.BROKEN_STRING_IDLE_SPRITE_ANIME_ID):
	#		_on_ball_caught()
	#		return
	
		
		
		#TODO: add logic to disable self only hitboxes. cause atm you can spam hit the ball dring same animtion
		#glovehit ball with bal
		var sf = otherHitboxArea.spriteFrame
		var sa = sf.spriteAnimation
		
		
		#the self hitboxe is mapped?
		if gloveBatThrowAnimationLookup.has(sa.id):
			var batHitActionId = gloveBatThrowAnimationLookup[sa.id]
			
			
			#print("playing bat hit action: "+batHitActionId)
			#make sure the ball doesn't get picked up and stop
			opponentWasStandingOnBall =false
			gloveWasStandingOnBall=false
			command = otherHitboxArea.cmd
			lastBatAttackHitActionId=batHitActionId
			
						
			batHitParticles.visible=true
			#throwParticles.visible = false
			#reelParticles.visible = false
			
			batHitParticles.emitting=true
			batHitParticles.restart()
			#throwParticles.emitting = false
			#reelParticles.emitting = false
			
			
			#ball can't be hit with same bat animation until animations finishes
			ballBatHitLocked=true 
			onBatHitCatchLock=true
			batHitCatchLockTimer.start(BAT_HIT_CATCH_LOCK_DURATION)
			
			#super heavy bat swing? break the string
			if sa.id ==masterPlayerController.actionAnimeManager.NEW_BACK_SPECIAL_SPRITE_ANIME_ID:
				_on_break_string()
				
			actionAnimationManager.playUserAction(batHitActionId,masterPlayerController.kinbody.spriteCurrentlyFacingRight,otherHitboxArea.cmd)
			otherHitboxArea.dispalyOnHitSFXSprites()
			
			_on_request_play_special_sound(BASEBALL_BAT_HIT_SOUND_IX,HERO_SOUND_SFX,BASEBALL_BAT_HIT_VOLUME)
		else:
			#for now handle unmapped self hitboxes as catch hitboxes
			_on_ball_caught()
		
		
		
		#reset string hp only when pickup without a string pull
#		setHP(defaultHP)
	else:
		
		#playOnHitSound(selfHurtboxArea.commonSFXSoundId,otherHitboxArea.commonSFXSoundId)
		playOnHitSound(selfHurtboxArea,otherHitboxArea)
		#apply damage to string
		
		#applyStringDamage(otherHitboxArea)
		
		#broke the string?
		#if hp <= 0:
		
		#balnormally get on shot by attacks, but projectiles will jsut make it go idle
		if otherHitboxArea.is_projectile:
			goIntoIdleAnimation()
		else:
			#don't break on trhow. can't grab the ball
			if not otherHitboxArea.isThrow:
				_on_break_string()
				
		 #don't break on trhow. can't grab the ball
		if not otherHitboxArea.isThrow:
			#display sfx of the hitbox
			otherHitboxArea.dispalyOnHitSFXSprites()
		
func _on_hitting_player(selfHitboxArea, otherHurtboxArea):
	
	stringBreakImmunityTimer.start(ON_HIT_STRING_BREAK_IMMUNITY_DURATION)
	stringBreakImunityTimerRunning=true
	#print(str(self.get_parent()) + " player landed a hit")
	#disable all remaining hitboxes, since we don't want to multi hit an oponent with same hitbox		
	#selfHitboxArea.get_parent().getSpriteAnimation().disableAllHitboxes()
	#playOnHitSound(otherHurtboxArea.commonSFXSoundId,selfHitboxArea.commonSFXSoundId)
	playOnHitSound(otherHurtboxArea,selfHitboxArea)
	
	#stop glowing, since on hit ball losses hitbox
	activeGlowSprite.visible = false
	ballHasActiveHitbox = false
	
	batHitParticles.visible=false

	batHitParticles.emitting=false
		
	selfHitboxArea.spriteAnimation.disableAllHitboxes()
	masterPlayerController._check_on_block_autoparry_hit(selfHitboxArea, otherHurtboxArea)
	
	#bounc of whatever we hit
	
	var _controllerWeHit = otherHurtboxArea.playerController
	
	var otherPos =  _controllerWeHit.kinbody.getCenter()
	var selfPos =  getCenter()
	
	var vectorFromBallToHurtboxObject = otherPos-selfPos
	#var dirToObject = selfPos.angle_to(vectorFromBallToHurtboxObject)
	
	#rotate by 90 degrees to find perpendicular vector to compute the collision normal
	#var collisionNormal = vectorFromBallToHurtboxObject.rotated(PI/2.0)
	var collisionNormal= vectorFromBallToHurtboxObject.normalized()
	
	#var attackSpriteAnimeId = selfHitboxArea.spriteAnimation.id
	var sa = actionAnimationManager.getCurrentSpriteAnimation()
	
	var ignoreBounceMomentum = false
	if sa != null:
		var spriteAnimeId = sa.id
		
		#want to make sure ball isn't stuck under opponent on floor while being hit by bat and boucning
		#if my_is_on_floor() and opponentProximityDetector.is_colliding() and not isBeingReeledIn():
		#if my_is_on_floor() and opponentStandingDetector.is_colliding() and not isBeingReeledIn():
		if my_is_on_floor() and opponentOnBall and not isBeingReeledIn():
		
		
		#if my_is_on_floor() and collidingWithOpponent and not isBeingReeledIn():
			ignoreBounceMomentum = true
			
		#the general case when hitting player from relativly far
		if not ignoreBounceMomentum:
			
			var isOpponentBlocking = masterPlayerController.opponentPlayerController.guardHandler.isBlocking()
			
				
			#get the action id to play to bounce ball off player based on attack
			var hitBounceActionId = actionAnimationManager.getBallHitBounceOffPlayerActionId(spriteAnimeId,isOpponentBlocking)
			var hitBounceComplxMvm = actionAnimationManager.getBallHitBounceOffPlayerComplexMvm(spriteAnimeId,isOpponentBlocking)
			
			#the bounc animation is defined?
			if hitBounceActionId != null:
				
				if hitBounceComplxMvm != null:
					#dynamically adjust the bounce normal of the animation for those that invovled a bounce
					hitBounceComplxMvm.bounceNormal =collisionNormal
				
				#wait 1 frame to let the knockback angle get adjusted before changing speed of ball			
				#actionAnimationManager.playUserAction(hitBounceActionId,masterPlayerController.kinbody.spriteCurrentlyFacingRight,command)
				
				#TODO: may want to use a flag and manually call this next physics process,
				#so can control whether to not play it (like if hit the ball with bat next frame)
				actionAnimationManager.call_deferred("playUserAction",hitBounceActionId,masterPlayerController.kinbody.spriteCurrentlyFacingRight,command)
			else:
				#print("no bounce defined from hit, go idle")
				goIntoIdleAnimation()
			#_bounce_ball_using_current_velocity(collisionNormal)
		#else:
			#gotta deal with case where (usually) ball is stuck under player and won't budge
			#make ball fly as if hitting normally from bat hit since otherwise the angle ball would go would be 
			#down into the ground since player center is above ball when ball is being stood on,
			#and since ball is on floor, it won't bounce since it isn't re-colliding with floor
		#	actionAnimationManager.playUserAction(lastBatAttackHitActionId,masterPlayerController.kinbody.spriteCurrentlyFacingRight,command)
			
	handleBallHitting()
	
	#dislay a light to indicate hitting with attack type	
	#handleAttackTypeLightingSignaling(selfHitboxArea)


func _on_hitting_invincible_player(selfHitboxArea, otherHurtboxArea):
	
	pass
	
#override parent function
func handleBallHitting():
	
		
	canBeCaught=true
	#goIntoIdleAnimation()	
	pass
	
		
			
#override the function
func fire():
	
	masterPlayerController.emit_signal("player_state_info_text_changed",GLOBALS.GLOVE_NOTIFICATION_TEXT_ACTIVE_BALL)
	
	#only enable magifying glass when on stage
	offScreenMagnifyingGlass = true
	
	self.visible = true
	#typically will see bal in magnifying glass after fired
	offScreenMagnifyingGlass=defaultOffScreenMagnifyingGlass
	
	opponentStandingDetectorArea.monitoring=true
	opponentOnBall=false
	
	actionAnimationManager.movementAnimationManager.deactivateAllMovement()
	movementAnimationManager.haltMovement()
	#clear any collision that happened same frame (so ball won't break or get hit by bat
	#if catching the same frame being hit)
	collisionHandler.collisionAreas.clear()
	collisionHandler.ignoreCollisions=false
	onBatteleField=true
	
	#can reel again, we created projectile
	actionAnimationManager.unlockAllReels()
	
	bodyBox.disabled = false
	
	#prevent auto catching ball upon throwing it. gotta hit something first
	canBeCaught = false
	hpBar.visible = false
	if trailParticles != null:
		trailParticles.emitting = true
		trailParticles.restart()
	
	
	ballBatHitLocked=false
	
	batHitParticles.visible=false
	#throwParticles.visible = true
	#reelParticles.visible = false
	
	batHitParticles.emitting=false
	#throwParticles.emitting = true
	#reelParticles.emitting = false
	
	opponentWasStandingOnBall =false
	gloveWasStandingOnBall=false
	
	
	_on_request_play_special_sound(BALL_THROW_SOUND_IX,HERO_SOUND_SFX)
	.fire()
#override the function
func deactivate():
	.deactivate()
	#make sure to stop emitting the moving trail
	if trailParticles != null:
		trailParticles.emitting = false
	


func applyStringDamage(otherHitboxArea):
	var attackerPlayerController = otherHitboxArea.playerController
	var dmg = attackerPlayerController.computeRelativeDamage(otherHitboxArea.damage)
	
	setHP(hp - dmg)
	pass
	
func displayHPBar():
	
	transparencyAnimatinDelayTimer.stop()
	
	hpBar.visible = true
	hpBar.modulate = defaultColor
	#transparencyTween.stop(hpBar)
	#self.set("custom_colors/font_color",defaultColor)
	
	#wait a delay
	#yield(get_tree().create_timer(2),"timeout")
	transparencyAnimatinDelayTimer.startInSeconds(2)
	

	
func _on_transparancy_hp_bar_delay_timeout():
	return
	
#	var transparencyAnimationDuration = 3
	#"custom_colors/font_color"
#	transparencyTween.interpolate_property(hpBar,"modulate",defaultColor,targetTransparentColor,transparencyAnimationDuration,Tween.TRANS_QUAD,Tween.EASE_OUT)
#	transparencyTween.start()
	
func _on_hp_bar_transparancy_tween_complete(arg1,arg2):
	
	hpBar.visible = false
	
#override destory function.
#we never want ball to be deleted
#just make glove catch it when expliclty destoryed like upon match restart or style pointes
#BUGGGGGG: THIS function isn't actually overriding anything
#func destory():
	
#	_on_ball_caught()
	
	
#func _on_glove_standing_on_ball():
	#print("glove standed on ball")
	
#	if not isBeingThrown():
#		_on_ball_caught()
	
func _on_opponent_standing_on_ball():
	
	#print("opponent standed on ball")
	
	#only break string once
	if stringAttachedFlag:
		_on_break_string()
	
func isBeingThrown():
	var res = actionAnimationManager.isCurrentSpriteAnimation(actionAnimationManager.D_TOOL_THROW_ACTION_ID)
	res = res or actionAnimationManager.isCurrentSpriteAnimation(actionAnimationManager.U_TOOL_THROW_ACTION_ID)
	res = res or actionAnimationManager.isCurrentSpriteAnimation(actionAnimationManager.F_TOOL_THROW_ACTION_ID)
	
	return res
	
func isBeingReeledIn():
	var res = actionAnimationManager.isCurrentSpriteAnimation(actionAnimationManager.B_TOOL_REEL_ACTION_ID)
	res = res or actionAnimationManager.isCurrentSpriteAnimation(actionAnimationManager.F_TOOL_REEL_ACTION_ID)
	res = res or actionAnimationManager.isCurrentSpriteAnimation(actionAnimationManager.D_TOOL_REEL_ACTION_ID)
	
	return res
	
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	if not onBatteleField:
		return
		
	#can only catch ball if not throwing and ball inside body box
	#also can't catch it if in hitstun
	if not gloveWasStandingOnBall and  canBeCaught and gloveStandingDetector.is_colliding() and not masterPlayerController.playerState.inHitStun and not masterPlayerController.guardHandler.isInBlockHitstun() and not onBatHitCatchLock:
	#if not gloveWasStandingOnBall and  canBeCaught and collidingWithGlove and not masterPlayerController.playerState.inHitStun and not masterPlayerController.guardHandler.isInBlockHitstun():
	
			gloveWasStandingOnBall=true
			_on_ball_caught()
			
			
		
	#if not opponentWasStandingOnBall and my_is_on_floor():
	
	
	if not opponentWasStandingOnBall:
		#if opponentStandingDetector.is_colliding():
		if opponentOnBall:
			

		#if collidingWithOpponent:
			
			#only have opponent break string if not in hitstun or blockstun
			if not masterPlayerController.opponentPlayerController.playerState.inHitStun and not opponentInBlockStun:
				#can't break it and be stunned either
				if not masterPlayerController.opponentPlayerController.actionAnimeManager.isCurrentSpriteAnimation(masterPlayerController.opponentPlayerController.actionAnimeManager.STUNNED_ACTION_ID):
					#being in the pre-guard break stun can't break either
					if not masterPlayerController.opponentPlayerController.actionAnimeManager.isCurrentSpriteAnimation(masterPlayerController.opponentPlayerController.actionAnimeManager.INVULNERABLE_GUARD_BREAK_ACTION_ID):
						#other animation that can't break ball
						
						
						
						#can only break string when not invulnerable to string break
						if not isInvulnerableToStringBreak():
							
							#cant break ball when active
							if not ballHasActiveHitbox:
								opponentWasStandingOnBall =true
		
								_on_opponent_standing_on_ball()
			
		
			
#called when a follow movement is initiated (starts/activates) and
#the follow destination type is other (not caster, nor opponent)
func _on_following_special_object_type_hook(followMvm):
	

	#this make ball travel toward where glove was at cast time
	var currPos = masterPlayerController.kinbody.getCenter()

	#compute angle from ball to glove
	var srcPos = self.getCenter()
	var dstPos = currPos
	
	#distance between glove and the ball
	var distance = srcPos.distance_to(dstPos)
	
	#compute a vector that is follwoing the vector between glove and ball, and got beyond glove
	#20% of distance. #use that as target
	var vectorSepartingBallAndGlove = Vector2(dstPos.x - srcPos.x,dstPos.y - srcPos.y)
	
	vectorSepartingBallAndGlove = vectorSepartingBallAndGlove * 1.2
	var target = srcPos + vectorSepartingBallAndGlove
	

#point to be moved around map for ball destination
	var destinationAnchorPoint = Position2D.new()
	destinationAnchorPoint.visible = false
	#make sure stage adds it to the scene
	masterPlayerController.emit_signal("create_anchor_point",destinationAnchorPoint)
	
	
	destinationAnchorPoint.position.x = target.x
	destinationAnchorPoint.position.y = target.y
	#here, other means hat is following his head gear (will have to refine this logic for extensibility, but
	#should be fine for now)
	followMvm.src = self #source is this ball  
	followMvm.dst=destinationAnchorPoint# destination is the point glove was at during casting
	
	#automatically head towards glove, no turning
	var desiredAngle = followMvm.computeAngleFromSourceToDestination()
	followMvm.angle =desiredAngle
	
	pass
	
func _on_started_bouncing():
	canBeCaught=true
	#print("started bouncing")
	pass

func _on_stopped_bouncing(rc):
	#print("stopped bouncing:"+str(rc))
	
	#only go idle if the bounce naturally finished. Bounce is stopped upon new movement animations
	#so wouln't want to override new movment animation with idle
	if rc == GLOBALS.BOUNCE_RC_MAX_BOUNCES_EXCEEDED or rc == GLOBALS.BOUNCE_RC_MOMENTUM_CAME_TO_HALT:
		
		#avoid going idle if stopped bouncing right under opponent. otherwise ball will get lock under them
		#if hit with bat at same time
		#if not opponentStandingDetector.is_colliding():
		if not opponentOnBall:
		#if collidingWithOpponent:
			goIntoIdleAnimation()
	else:
		pass
	
	#we need to make sure the command that made the ball go isn't lost upon bounc stop (stopping bounce movement will 
	#null the command)
	actionAnimationManager.commandActioned = command

func _on_bounced():
	#print("bounced")
	pass
func _on_sprite_animation_played(sa):
	
	#when playign an animation other than throw, we can now catch the ball
	if sa.id != actionAnimationManager.D_TOOL_THROW_SPRITE_ANIME_ID or sa.id != actionAnimationManager.U_TOOL_THROW_SPRITE_ANIME_ID or sa.id != actionAnimationManager.F_TOOL_THROW_SPRITE_ANIME_ID:
		canBeCaught=true
		
		
func _on_sprite_frame_activated(sf):
		#hitboxes are active on tis frame?
	if sf.type == sf.FrameType.ACTIVE and not sf.spriteAnimation.disableHitboxes:
		activeGlowSprite.visible = true
		ballHasActiveHitbox = true

	else:
		ballHasActiveHitbox = false
		activeGlowSprite.visible = false
	
		batHitParticles.visible=false
		#throwParticles.visible = false
		#reelParticles.visible = false
		
		batHitParticles.emitting=false
		#throwParticles.emitting = false
		#reelParticles.emitting = false

	

func _on_left_wall():
	
	pass
	
func airReelMomentumCancel(followMovement):
		#TODO: FIGURE out why ball isn't keeping it's momentum and restart garvity. it stops for some reason
		#keep air momentum

	#	var keepAirMomentumMvmAnimation = actionAnimationManager.mvmAnimationLookup(actionAnimationManager.REEL_ARRIVE_KEEP_AIR_MOMENTUM_ACTION_ID)
	#	if not keepAirMomentumMvmAnimation.has_node(keepAirMomentumBMRelativeNodePath):
		
			
	#		print("warning: expected a basic movement '"+keepAirMomentumBMRelativeNodePath+"' in REEL_ARRIVE_KEEP_AIR_MOMENTUM_ACTION_ID movement animation. but wasn't there. can't keep momentum")	
	#		goIntoIdleAnimation()		
	#		return
			
	#	var bm = keepAirMomentumMvmAnimation.get_node(keepAirMomentumBMRelativeNodePath)
	#	bm.angle = followMovement.angle
		#gotta compute the speed from current x and y speeds 
		var spdVec = Vector2(followMovement.xSpeed,followMovement.ySpeed)
		#var spdVec = followMovement.getCurrentSpeed()
		var keepAirMomentumMvmAnimation = actionAnimationManager.mvmAnimationLookup(actionAnimationManager.REEL_ARRIVE_KEEP_AIR_MOMENTUM_ACTION_ID)
		if not keepAirMomentumMvmAnimation.has_node(keepAirMomentumBMRelativeNodePath):
	
		
			print("warning: expected a basic movement '"+keepAirMomentumBMRelativeNodePath+"' in REEL_ARRIVE_KEEP_AIR_MOMENTUM_ACTION_ID movement animation. but wasn't there. can't keep momentum")	
			goIntoIdleAnimation()		
			return
			
		var bm = keepAirMomentumMvmAnimation.get_node(keepAirMomentumBMRelativeNodePath)
	
		#gotta compute the speed from current x and y speeds 
		
		var spd = spdVec.length()
		#var angle = newVelocity.angle()
		bm.angle= followMovement.angle
		bm.speed = spd
		bm.maxSpeed = spd
		bm.acceleration = 0
		
		actionAnimationManager.playUserAction(actionAnimationManager.REEL_ARRIVE_KEEP_AIR_MOMENTUM_ACTION_ID,masterPlayerController.kinbody.facingRight,command)
	
		
		
func playAction(actionId):
	actionAnimationManager.playAction(actionId,masterPlayerController.kinbody.spriteCurrentlyFacingRight)
	
func playActionKeepOldCommand(actionId):
#	var tmp = actionAnimationManager.commandActioned
	playAction(actionId)
	actionAnimationManager.commandActioned = command

#func _player_entered_balls_space(playerHurtbox):
	
#	if playerHurtbox.playerController == self:
#		return
	
#	if playerHurtbox.playerController == masterPlayerController:	
#		if not collidingWithGlove:
#			print("collided with glove")
#		collidingWithGlove=true
#	elif playerHurtbox.playerController == masterPlayerController.opponentPlayerController:	
#		if not collidingWithOpponent:
#			print("collided with opponent")
#		collidingWithOpponent=true


#	pass
#func _player_exited_balls_space(playerHurtbox):
	
#	if playerHurtbox.playerController == self:
#		return
	
#	if playerHurtbox.playerController == masterPlayerController:	
#		if collidingWithGlove:
#			print("stopped colliding with glove")
#		collidingWithGlove=false
#	elif playerHurtbox.playerController == masterPlayerController.opponentPlayerController:	
#		if collidingWithOpponent:
#			print("stopped colliding with opponent")
#		collidingWithOpponent=false
		
	
#	pass

func _on_hit_freeze_finished():
	._on_hit_freeze_finished()
	
	
	if stringBreakImunityTimerRunning:
		#unpause timer
		stringBreakImmunityTimer.set_physics_process(true)
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	._on_hit_freeze_started(duration)
	
	if stringBreakImunityTimerRunning:
		
		#pause timer
		stringBreakImmunityTimer.set_physics_process(false)
		
func _on_string_break_immunity_timeout():
	stringBreakImunityTimerRunning=false
	pass
	
func isInvulnerableToStringBreak():
	return stringBreakImunityTimerRunning


func _on_glove_sprite_animation_played(spriteAnimation):
	
	#ball can't be hit more than once by same animation, so
	#now is able to get hit again
	ballBatHitLocked=false
	pass
	

func _on_bat_hit_catch_lock_timeout():
	#after a bat hit, temporary time where can't catch ball to
	#prevent hitting and immediatly catching ball
	#now that time ellapsed
	onBatHitCatchLock=false
	


func _on_opponented_stepped_onto_ball(hurtbox):
	
	#can only step on ball if ball on battlefield
	if onBatteleField:
		
		#since hurtboxes used for step detection,
		#must avoid hurtboxes from oterh sources (glove is
		#only one atm that has projectile with hurbox)
		if not hurtbox.belongsToProjectile():
			opponentOnBall=true
func _on_opponented_stepped_away_from_ball(hurtbox):
	
	opponentOnBall=false
 
func _on_opponent_entered_block_stun(attackerHitbox,blockResult,spriteFacingRight):
	opponentInBlockStun=true

func _on_opponent_exited_block_hitstun():
	opponentInBlockStun=false



func _on_create_projectile(projectile,spawnPoint):
	
	._on_create_projectile(projectile,spawnPoint)
	
	#we creating a string break object?
	if projectile is preload("res://projectiles/GloveBallStringController.gd"):
		var reelType = DEFAULT_REEL_TYPE 
		
		
		if actionAnimationManager.isCurrentSpriteAnimation(actionAnimationManager.B_TOOL_REEL_ACTION_ID):
			
			reelType = BACK_REEL_TYPE
		elif actionAnimationManager.isCurrentSpriteAnimation(actionAnimationManager.AIR_TOOL_NO_BALL_REEL_ACTION_ID):
	 		reelType = AIR_REEL_TYPE
		elif actionAnimationManager.isCurrentSpriteAnimation(actionAnimationManager.U_TOOL_REEL_ACTION_ID):
	 		reelType = UP_REEL_TYPE	
		
			
		#string projectile created, we will used last destination of follow recodred 
		#since line will illustrate exactly where ball going instead of center of glove
		
		#proj.setGloveBaseBallController(self)
		projectile.setupLinePoints(self.getCenter(),masterPlayerController.kinbody.getCenter(),reelType)
		
		
	
	
#to be implemented by subclasses. Used to load a single type of projectile 
#to be spawned at multiple areas
func getStaticProjectileSpawn(customProjectileSpawnData):
	
	return stringSpawn
	
