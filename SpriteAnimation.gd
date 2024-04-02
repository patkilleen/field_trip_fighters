extends Node

signal finished
signal stopped
signal multi_tap_partially_finished
signal create_projectile
signal request_play_sound
signal disabled_body_box
signal enabled_body_box
signal platform_drop
signal unpushable_frame
signal pushable_frame_flag
signal canPush_frame_flag
signal sprite_frame_activated

enum AbilityCancelCostType{
	NA,
	VERY_LIGHT,
	LIGHT,
	MEDIUM,
	HEAVY,
	VERY_HEAVY,
	CUSTOM #abilityBarDrain specifies how much it coests, in chunks
}
var id = 0

#note that ideally id have one looping memeber, using an enum : NO_LOOP, LOOP, LOOP_WITH_DURATION
#but I don't want to have to manually change all frame nodes. So isLooping true has higher priority than
#isLoopingWithDuration. so if isLoopingWithDuration = true, isLooping = true, we loop with the duration.
#if isLoopingWithDuration = true, isLooping = false, we don't loop. 
#if isLoopingWithDuration = false, isLooping = false, we don't loop. 
export (bool) var isLooping = false 
export (bool) var isLoopingWithDuration = false
export (int) var loopDuration = -1 setget setLoopDuration,getLoopDuration #in frames 
var loopDurationInSeconds = -1
#var loopEllapsedSeconds = 0

export (int) var nextActionId = -1

#the amount it cost to cancel out of this move
export (float) var abilityBarDrain = 0

export (AbilityCancelCostType) var abilityCancelCostType = 0


#the amount it cost to aubot ability cancel out of this move
export (float) var autoAbilityBarDrain = 0

export (AbilityCancelCostType) var autoAbilityCancelCostType = 0

export (int) var customAbilityCancelHitFreeze = -1
#flag indicating if its possible to cancel out of this move
#if false, no child can be canceled and their cancelable flag is ingored
#if true, childs can explicitly specify they don't want to be canceled
export (bool) var barCancelableble = true
export (bool) var canBeBarCanceledInto = true
export (float) var landingLagDuration= 7 #number of frames landing aniamtion takes 
export (float) var speed = 1.0 setget setSpeed, getSpeed

#-1 means must finish animation, 0 means auto snap when able to turn around
#, otherwise, will take an addition X number of frames before facing other way
#this enable crossups
export (int) var numberOfFramesForTurnAround = 0

#truemeans you keep the "hitting" status trhough the entire animation
#this way, can autocancel at any time (useful for timing moves like marth having to
#wait for a tipper)
#false means the hitting flag is only true during the hitting frame, so player is
#gona have to input the autocancel during hitfreeze or during the short during
#remaining with acti vehitbox
export (bool) var keepHittingFlagUponFrameChange = true


export (int) var onHitAutoCancelWindow= -1 #-1 means can autocancel on hit for rest of duration,0 means the frame u hit u gotta press button (after hitfreeze), 1 means 1 frame after hitfreeze, etc

export (bool) var facingCorrectDirectionOnPlay=true #will be case for 99 % of animations. Rekas and on hits generally wont' turn around, for example. 
export (bool) var preventCounterRipost=false #false means for aniamtions that can counter ripost, they may do so. true means for an animation that would usally be okay, it can't trigger counter ripost
export (bool) var preventCounterRipostFailOnPlay=false #false means playing this aniamtion while counter riposting will make you fail the counter ripost. true means your counter ripost aniamtion extends to this animation (e.g., landing lag)
export (bool) var preventCounterRipostFailOnEnd=false #false means ending this aniamtion while counter riposting will make you fail the counter ripost. true means your counter ripost aniamtion extends to the next animation (e.g., uncrouch)
export (bool) var hittingFlagAlwaysEnabled=false # true means for on hitt cancels, can do at any point even when animations starts (goes well with on hit animations)
export (int) var customCounterRipostWindowDuration= -1 #> -1 means animation will specify it's own counter ripost window duraiont. by desing shoud be longer than animation. -1 means no custom, so fail on animation end
export (bool) var supportPlayWhilePaused=false #true means in hitfreeze/pause, the sprite will be changed to animation's first frame's sprite, but mechanically the aniamtion will follow same paly logic as other animation and wait till end of hitfreeze
export (float) var abCancelSlideDecceleration=-900
export (float) var abCancelSlideMaxSpeed=300
export (float) var abCancelAirOppGravity=0
export (bool) var onPlayHitFlagEnabled=false #false means not hitting when animation played. true means hitting flag set when played

#TODO: implement below 2 properties
export (AbilityCancelCostType) var landingLagBarCost=0 #-1 means can't ability cancel the landing lag. any
export (bool) var canAbilityCancelLandingLag=false #false emans landing lag unabbility cancelabled, true means can cancel it for landingLagBarCost chunks


#the id of the sound effect to play upon starting the animation
#-1 means no sound is played
export (int) var commonSoundSFXId = -1
export (int) var heroSoundSFXId = -1

export (int) var commonSFXSoundVolumeOffset = 0#0 means no change in volume
export (int) var heroSFXSoundVolumeOffset = 0 #0 means no change in volume


var onHitAutoCancelWindowInSeconds = 0
var hittingWithJumpCancelableHitbox = false  setget setHittingWithJumpCancelableHitbox,getHittingWithJumpCancelableHitbox
var httingAnyHurtboxFlag=false
#set to true when we hit at some point during this animation
#var hasHitThisAnimationFlag = false

var GLOBALS = preload("res://Globals.gd")

var defaultSpeed = 1.0

var currentFrame = 0

var spriteFrames = []

var playing = false

var disableHitboxes =false setget setDisableHitboxes,getDisableHitboxes
var disableActiveFrameSet=false #true when at some point in the current set of concurrent active sprite frame, hitboxes hit someone, so disable (only relevant to multi hits)

var forceProximityGuardDisable= false
var disableSelfOnlyHitboxes =false

var numberOfFrames = 0

#used to indicated to continue animation when true when otherwise would ahve stopped cause
#playe didnt multi tap to keep it going
var multiTapFlag = false

#flag true indicating facing right when played and false when facing left when played
var facingRightWhenPlayed = null

#flag to store case when this animation was used to do a block stun string
var hitABlockStunString = false
#command that activate this sprite animation
var cmd = null

#the node that handles all the collisions
var activeNodes = null
var spriteAnimationManager = null
var paused = false

var superArmorWasHitCount=0 #number of times animation hit since start (necessary for super armor break check)

#flag to store case when this animation was used to partially fill a dmg star (increase fill sub combo)
var filledStar= false

var playerController = null


var trackingTimeEllapsedSinceHit = false
var timeEllapsedSinceHit = 0

var timeEllaspedSinceAniamtionStart=0

#flag to track if the invincibility hit notification already happened for this animation
#used to avoid signaling multiple times as the sprite frames change
#since invincibility doesnt deactivate hitboxes
var invincibilityWasHitFlag =false

var hasLowHitbox = false
#var hasStaleHitbox = false
var hasGrabHitbox = false
var hasParryHurtbox=false
var hasInvincibilityHurtbox=false
var hasArmorHurtbox= false
var hasMeatyHitbox=false
var hasBlockStunMeatyHitbox=false
var hasDedicatedAntiAirHitbox=false
var hasDedicatedAntiGroundHitbox=false
var hasHitsWakeupOpponentHitbox=false

func _ready():
	
	onHitAutoCancelWindowInSeconds = GLOBALS.SECONDS_PER_FRAME*onHitAutoCancelWindow
	
	
	
	self.set_physics_process(false)
	# Called when the node is added to the scene for the first time.
	# Initialization here
	defaultSpeed = speed
	for c in self.get_children():
		if c is preload("res://AlphaSpriteFrame.gd"):
			spriteFrames.append(c)
			c.spriteAnimation = self
			c.speed = speed
			c.connect("finished",self,"_on_sprite_frame_finished",[c])
			c.connect("create_projectile",self,"_on_create_projectile")
			c.connect("request_play_sound",self,"_on_request_play_sound")
			c.connect("disabled_body_box",self,"_on_disabled_body_box")
			c.connect("enabled_body_box",self,"_on_enabled_body_box")
			c.connect("platform_drop",self,"_on_platform_drop")
			c.connect("pushable_frame_flag",self,"_on_pushable_frame_flag")
			c.connect("canPush_frame_flag",self,"_on_canPush_frame_flag")
			c.connect("activated",self,"_on_sprite_frame_activated")
			numberOfFrames+=c.duration
			
			#search for hitbox properties to flag sprite animation and prevent
			#searching through hitboxes more than once per game-load
			if not hasLowHitbox:
				for hb in c.hitboxes:
					
					#low?
					if hb.low:
						hasLowHitbox = true
						break
			
			#if not hasStaleHitbox:
			#	for hb in c.hitboxes:
				
					#aniamtion becomes stale after hits?
			#		if hb.preventsAnimationStaleness:
			#			hasStaleHitbox=true
			#			break
						
			if not hasGrabHitbox:
				for hb in c.hitboxes:
				
					#aniamtion has a grab/trhow hitbox?
					if hb.isThrow:
						hasGrabHitbox=true
						break
			if not hasDedicatedAntiAirHitbox:				
				for hb in c.hitboxes:
				
					#aniamtion has a grab/trhow hitbox?
					if hb.canHitAirborneTarget and not hb.canHitGroundedTarget:
						hasDedicatedAntiAirHitbox=true
						break
			if not hasDedicatedAntiGroundHitbox:				
				for hb in c.hitboxes:
				
					#aniamtion has a grab/trhow hitbox?
					if not hb.canHitAirborneTarget and hb.canHitGroundedTarget:
						hasDedicatedAntiGroundHitbox=true
						break		
			if not hasHitsWakeupOpponentHitbox:
				for hb in c.hitboxes:
				
					#OTG / off-the-ground hitbox for htting while oki?
					if hb.hitsWakeupOpponent:
						hasHitsWakeupOpponentHitbox=true
						break		
			

					
			if not 	hasMeatyHitbox:
				for hb in c.hitboxes:
				
					#meaty hitbox on hit?
					if hb.hitstunDurationType == hb.HITSTUN_DURATION_TYPE_MEATY:
						hasMeatyHitbox=true
						break
						
			if not 	hasBlockStunMeatyHitbox:
				for hb in c.hitboxes:
				
					#meaty hitbox on block?
					if hb.blockStunDurationType == hb.HITSTUN_DURATION_TYPE_MEATY:
						hasBlockStunMeatyHitbox=true
						break	
		
		
			if not hasParryHurtbox:
				for hb in c.hurtboxes:
				
					#has a counter hurtbox?:
					if hb.onGettingHitCounterActionId != -1:
						hasParryHurtbox=true
						break
			if not hasInvincibilityHurtbox:
				for hb in c.hurtboxes:
				
					#has a counter hurtbox?:
					if hb.subClass == hb.SUBCLASS_INVINCIBILITY:
						hasInvincibilityHurtbox=true
						break								
			if not hasArmorHurtbox:
				for hb in c.hurtboxes:
				
					#has a counter hurtbox?:
					if hb.subClass != hb.SUBCLASS_BASIC and (hb.subClass == hb.SUBCLASS_HYPER_ARMOR or hb.subClass == hb.SUBCLASS_HEAVY_ARMOR or hb.subClass == hb.SUBCLASS_SUPER_ARMOR):
						hasArmorHurtbox=true
						break			

		#var script = c.get_script()
		#if script != null:
			#var scriptName = script.get_path().get_file()
			#found movement node?
			#if scriptName == "SpriteFrame.gd" or scriptName == "AlphaSpriteFrame.gd" or scriptName == "SpriteProjectileFrame.gd":
			#		spriteFrames.append(c)
			#		c.spriteAnimation = self
			#		c.speed = speed
			#		c.connect("finished",self,"_on_sprite_frame_finished",[c])
			#		c.connect("create_projectile",self,"_on_create_projectile")
			#		numberOfFrames+=c.duration
					
					
	
	playing = false
	
	pass

func setLoopDuration(d):
	loopDuration = d
	loopDurationInSeconds = loopDuration* GLOBALS.SECONDS_PER_FRAME #seconds = frames * (seconds / frames)
func getLoopDuration():
	return loopDuration

	
func init(sprite,collisionAreas,bodyBox,_activeNodes,_playerController):
	#init all the sprite frames
	for sf in spriteFrames:
		sf.init(sprite,collisionAreas,bodyBox,_activeNodes,_playerController)
	
	playerController = _playerController
	activeNodes = _activeNodes
	paused=false
	
func reset():
	
	#self.set_physics_process(false)
	
	for sf in spriteFrames:
		sf.reset()
		
	currentFrame = 0

	playing = false

	disableHitboxes =false
	disableActiveFrameSet=false 

	forceProximityGuardDisable=false
	disableSelfOnlyHitboxes =false
	multiTapFlag = false

	facingRightWhenPlayed = null

	hitABlockStunString = false
	cmd = null

	paused = false

	superArmorWasHitCount=0 #number of times animation hit since start (necessary for super armor break check)

	filledStar= false


	trackingTimeEllapsedSinceHit = false
	timeEllapsedSinceHit = 0

	timeEllaspedSinceAniamtionStart=0

	invincibilityWasHitFlag =false

func set_sprite_animation_manager(spriteAnimManager):
	spriteAnimationManager = spriteAnimManager
	
	#iterate all sprite frame and set reference
	for sf in spriteFrames:
		sf.set_sprite_animation_manager(spriteAnimManager)

		
func store_command(_cmd):
	#store a command in all sprite frames
	for sf in spriteFrames:
		sf.store_command(_cmd)
		
	cmd = _cmd

func storeFacingRightWhenPlayed(_facingRightWhenPlayed):
	
	#store a facing right flag in all sprite frames
	for sf in spriteFrames:
		sf.storeFacingRightWhenPlayed(_facingRightWhenPlayed)
		
	cmd = _facingRightWhenPlayed
	
	
func _on_create_projectile(projectile,spawnPoint):
	emit_signal("create_projectile",projectile,spawnPoint)
	
#any function that calls this or accesses thenumber of frames will need to consider
#the animation speed and global speed mod
func getNumberOfFrames():
	var numFrames = 0
	for sf in spriteFrames:
		numFrames += sf.duration
		
	return numFrames

#considering the speed and length of sprite animation
#return number of effective frames
func getEffectiveNumberOfFrames():
	#0.5 speed means twice as many frames frames / (1/2) = frames *2
	#return numberOfFrames/ (defaultSpeed * spriteAnimationManager.globalSpeedMod)
	#return getNumberOfFrames()/ (speed * spriteAnimationManager.globalSpeedMod)
	return getNumberOfFrames()/ speed

func getEffectiveDurationInSeconds():
	var numFrames = getNumberOfFrames()
	#var totalDuration = (numFrames*GLOBALS.SECONDS_PER_FRAME)/(speed * spriteAnimationManager.globalSpeedMod)
	var totalDuration = (numFrames*GLOBALS.SECONDS_PER_FRAME)/(speed)
	return totalDuration
func getDefaultSpeed():
	return defaultSpeed
	
func setSpeed(spd):
	speed = spd
	
	#update speed in each sprite frame
	for f in spriteFrames:
		f.speed = spd

func getSpeed():
	return speed
	
#returns current sprite frame, and null if its no current frame
func getCurrentSpriteFrame():
	#if not playing:
	#	return null
		
	if currentFrame < spriteFrames.size():
		return spriteFrames[currentFrame]
	else:
		return null

#returns 1 when completed, 0 when not started,  0.5 when half done, etc...
#func computeCompletionFraction():
	
#	var additionalFrames = 0
#	if currentFrame < spriteFrames.size():
#		var spriteFrame = spriteFrames[currentFrame]
#		if spriteFrame != null:
			#get the number of frames currently prossesed by sprite frame
#			additionalFrames=spriteFrame.numberOfFrames
	
#	var frac = (numFramesEllapsed+additionalFrames)/self.getNumberOfFrames()
	
#	return frac
	
	
#returns ratio of how many frames cycles have ellapsed
#1 for 100% complete animation
#0.5 for half complet
#0 for just started
#note that this is old content and hasn't been test in while (isn't used since
#the landing lag duration in frames specified)
#
func computeCompletionFraction():

	var _durationEllapsedInSeconds = timeEllaspedSinceAniamtionStart
	if isLoopingWithDuration:
		
		return _durationEllapsedInSeconds/loopDurationInSeconds
	else:	
		
		var totalAnimationDurationInSeconds = self.getEffectiveNumberOfFrames()*GLOBALS.SECONDS_PER_FRAME
		
		#return  durationEllapsed / self.getNumberOfFrames()
		
		return  _durationEllapsedInSeconds / totalAnimationDurationInSeconds
		
	
#returns number of seconds ellapsed in this animation
func getEllapsedTimeInSeconds():

	return timeEllaspedSinceAniamtionStart
#	var currFrame = getCurrentSpriteFrame()
	
	#animation done?
#	if currFrame == null:
#		return 1
		
#	var durationEllapsedInSeconds = 0
#	var frameIx=0
	#iterate all completed frames and count duration
#	while frameIx < currentFrame:
#		var frame = spriteFrames[frameIx]
		
		#var duration = frame.duration/ (frame.speed * spriteAnimationManager.globalSpeedMod)
#		var frameDurationInSeconds = frame.durationInSeconds/ (frame.speed * spriteAnimationManager.globalSpeedMod)
		
#		durationEllapsedInSeconds = durationEllapsedInSeconds + frameDurationInSeconds
#		frameIx = frameIx + 1
		#if frameIx == currentFrame:
		#	break
			
	#durationEllapsed = durationEllapsed + currFrame.numberOfFrames
#	durationEllapsedInSeconds = durationEllapsedInSeconds + currFrame.ellapsedSeconds
	
#	return durationEllapsedInSeconds

func computeNumberRemainingFrames():
	if isLoopingWithDuration:
		
		#var secsRemaining = max(0,(loopDuration- timeEllaspedSinceAniamtionStart)/spriteAnimationManager.globalSpeedMod)
		var secsRemaining = max(0,(loopDuration- timeEllaspedSinceAniamtionStart))
		return secsRemaining/GLOBALS.SECONDS_PER_FRAME
	else:

		#var numFramesEllapsed = timeEllaspedSinceAniamtionStart/GLOBALS.SECONDS_PER_FRAME
		
		#var totalAnimationDurationInFrames = self.getEffectiveNumberOfFrames()
		
		var totalAniamtionDuration = getEffectiveDurationInSeconds()
		var framesRemaining =  (totalAniamtionDuration-timeEllaspedSinceAniamtionStart)/GLOBALS.SECONDS_PER_FRAME
		
		return  max(framesRemaining,0)
		
	#total duration in seconds
func disableAllHitboxes():
	setDisableHitboxes(true)
	if currentFrame < spriteFrames.size():
		var spriteFrame = spriteFrames[currentFrame]
		if spriteFrame != null:
			spriteFrame.deactivateHitboxes()
			
	activeNodes.deactivateHitboxes()

func disableAllHitboxesFromHit():
	disableAllHitboxes()
	disableActiveFrameSet=true

func disableAllSelfOnlyHitboxes():
	disableSelfOnlyHitboxes=true
	if currentFrame < spriteFrames.size():
		var spriteFrame = spriteFrames[currentFrame]
		if spriteFrame != null:
			spriteFrame.deactivateSelfOnlyHitboxes()
			
	activeNodes.deactivateSelfOnlyHitboxes()
	
	
func _on_sprite_frame_finished(_spriteFrame):

	if playing:
		#calculate the fraction of seconds in excess , to carry over (since
		#typically a frame won't finish exactly 1/60th of a second, there will be some fluctuation
		#) we gotta carry it over to next frame to not get dysyncrhonized
		#var spriteFrameExcessTime = _spriteFrame.durationInSeconds - _spriteFrame.ellapsedSeconds 
		
		#next frame index
		currentFrame =  currentFrame  +1 
		#numFramesEllapsed += _spriteFrame.duration
		
		#is it a multi tap animation and player hasn't multi-tapped?
		if ((_spriteFrame.commandType == _spriteFrame.CommandType.MULTI_TAP) and (multiTapFlag == false)):
			#play next animation
				playing = false
				
				emit_signal("multi_tap_partially_finished",self,_spriteFrame)
				return
				
		#reached end animation?		
		if(currentFrame >= spriteFrames.size()):
			#finished animation, since were not looping at all?
			if (not isLooping):	
				#set_physics_process(false)
				
				#play next animation
				#playing = false
				
				#emit_signal("finished",self)
				finishAnimation()
				return
			else: #looping infinitly or until loop duration expire via signal
			
				currentFrame = 0	
				
			#don't re-enabled disabled hitboxes on looping animation
			#if their disabled, it means they should restart hitting when animation
			#is over. Will need to play new animation (this prevents glove's ball
			#to re-enable it's hitboxes every tiem it loops  and get many hits 
			#from signel bat swing)
			#	disableHitboxes = false
			#	disableSelfOnlyHitboxes=false
		
		
		#resset flag to make sure player needs to tap to continue multi tap animations
		multiTapFlag = false
		var spriteFrame = spriteFrames[currentFrame]
		
		#are we no longer in a sequential active spriteframe set?
		#(to be in active sprite frame stet, the last frame and this frame must be active)
		if spriteFrame.type == GLOBALS.FrameType.ACTIVE and  _spriteFrame.type == GLOBALS.FrameType.ACTIVE:
			pass
		else:
			disableActiveFrameSet=false #no longer hitting for this active sprite frame set
		spriteFrame.activate(disableHitboxes,disableSelfOnlyHitboxes,forceProximityGuardDisable,disableActiveFrameSet)
		#spriteFrame.ellapsedSeconds = spriteFrameExcessTime #carry over the time from last frame
		#make sure to transfer over

func finishAnimation():
	
	#only process physics frames if we measuring
	#the time to stop a limited-time animation loop
	#if isLoopingWithDuration:
	set_physics_process(false)
	
	for i in spriteFrames.size():
		var sf = spriteFrames[i]
		sf.deactivate()
	#play next animation
	playing = false
	
	emit_signal("finished",self)
	
func _on_request_play_sound(sfxId,soundType,volume):
	emit_signal("request_play_sound",sfxId,soundType,volume)
	
func _on_disabled_body_box():
	emit_signal("disabled_body_box")

func _on_enabled_body_box():
	emit_signal("enabled_body_box")
	
func _on_platform_drop():
	emit_signal("platform_drop") 
	
func _on_pushable_frame_flag(flag):
	emit_signal("pushable_frame_flag",flag) 
	
func _on_canPush_frame_flag(flag):
	emit_signal("canPush_frame_flag",flag) 

func _on_sprite_frame_activated(spriteFrame):
	
	#legacy code. shouldn't be using 'keepHittingFlagUponFrameChange'
	#since want the autocancel onhit window to be consistent accross
	#roster, not defined the sprite fframe duration
	#we will be clearing the "hitting flag" depending on 
	#type of sprite animatino 
	if not keepHittingFlagUponFrameChange:
		#hittingWithJumpCancelableHitbox = false
		setHittingWithJumpCancelableHitbox(false)
		httingAnyHurtboxFlag =false
		
		
	emit_signal("sprite_frame_activated",spriteFrame)
	
func play(_cmd, _facingRightWhenPlayed,on_hit_starting_sprite_frame_ix=0):
	
	#eeror checking, invalid sprite frame start?
	if on_hit_starting_sprite_frame_ix<0:
		on_hit_starting_sprite_frame_ix=0
		
	if not playing:
		#print("played: "+self.name)
		
		#only print if hero is ken
		#if get_parent().get_parent().get_parent().get_parent().heroName == "ken":
			
		#	print("played: "+self.name)
			
		#only process physics frames if we measuring
		#the time to stop a limited-time animation loop
		#if isLoopingWithDuration:
			#set_physics_process(true)
		#	print("wanring: lots of new timeing issn't actually considering the case of isLoopingWithDuration enable.")
			#will have to investigate effects and confirm looping animation the time remaining properly calculated
			#loopEllapsedSeconds = 0
		
		
		set_physics_process(true)
		#print(str(get_parent().get_parent().get_parent().get_parent().get_parent().inputDeviceId) +": playing..."+ str(self.name))
		multiTapFlag = false
		setHittingWithJumpCancelableHitbox(false)
		httingAnyHurtboxFlag=false
		
	
		timeEllaspedSinceAniamtionStart=0
	
		currentFrame=on_hit_starting_sprite_frame_ix
			
		disableActiveFrameSet=false 
		#reset hitting tracking
		#hasHitThisAnimationFlag=false
		#no longer trackin the onhit window, and disable hitting flag
		trackingTimeEllapsedSinceHit = false
		timeEllapsedSinceHit = 0
		
		#hittingWithJumpCancelableHitbox = false
		playing = true

		superArmorWasHitCount = 0
		setDisableHitboxes(false)
		
		forceProximityGuardDisable = false 
		
		disableSelfOnlyHitboxes=false
		store_command(_cmd)
		storeFacingRightWhenPlayed(_facingRightWhenPlayed)
		
		
		invincibilityWasHitFlag = false
		filledStar = false
		hitABlockStunString=false
		
		if onPlayHitFlagEnabled:
			setHittingWithJumpCancelableHitbox(true)
			httingAnyHurtboxFlag = true
			disableActiveFrameSet=true 
		if currentFrame < spriteFrames.size():
			var spriteFrame = spriteFrames[currentFrame]
			#are we no longer in a sequential active spriteframe set?
			#(to be in active sprite frame stet, the last frame and this frame must be active)
			if spriteFrame.type != GLOBALS.FrameType.ACTIVE:
				disableActiveFrameSet=false #no longer hitting for this active sprite frame set
			spriteFrame.activate(disableHitboxes,disableSelfOnlyHitboxes,forceProximityGuardDisable,disableActiveFrameSet)
		
		#play sound on animation play
		if heroSoundSFXId != -1:
			_on_request_play_sound(heroSoundSFXId,playerController.HERO_SOUND_SFX,heroSFXSoundVolumeOffset)
		if commonSoundSFXId != -1:
			_on_request_play_sound(commonSoundSFXId,playerController.COMMON_SOUND_SFX,commonSFXSoundVolumeOffset)
		
			
func stop():
	#set_physics_process(false)
	#if currentFrame < spriteFrames.size():
	#	var spriteFrame = spriteFrames[currentFrame]
	#	spriteFrame.deactivate()	
	#if playing:
		#print(str(get_parent().get_parent().get_parent().get_parent().get_parent().inputDeviceId) +":stopping..."+ str(self.name))
	var wasPlaying = playing
	
	playing = false

	#only process physics frames if we measuring
	#the time to stop a limited-time animation loop
	
	set_physics_process(false)
	
	for i in spriteFrames.size():
		var sf = spriteFrames[i]
		sf.deactivate()
		
	#if currentFrame < spriteFrames.size():
	#	var spriteFrame = spriteFrames[currentFrame]
	#	spriteFrame.deactivate()
	if(wasPlaying):
		emit_signal("stopped",self)
#else:
	#	print("warning: stopping sprite animation that is already stopped")
	

func pause():
	#set_physics_process(false)
	if playing:
		paused = true
		#only process physics frames if we measuring
		#the time to stop a limited-time animation loop
		#if isLoopingWithDuration:
			#set_physics_process(false)
		set_physics_process(false)
		#print(str(get_parent().get_parent().get_parent().get_parent().get_parent().inputDeviceId) +":pausing..."+ str(self.name))
		playing = false

		#if currentFrame < spriteFrames.size():
		#	var spriteFrame = spriteFrames[currentFrame]
		#	spriteFrame.set_physics_process(false)
		
		for i in spriteFrames.size():
			var sf = spriteFrames[i]
			sf.set_physics_process(false)

func unpause():
	#set_physics_process(true)
	
	if not playing:
		paused=false
		#only process physics frames if we measuring
		#the time to stop a limited-time animation loop
		#if isLoopingWithDuration:
			#set_physics_process(true)
		set_physics_process(true)
		#print(str(get_parent().get_parent().get_parent().get_parent().get_parent().inputDeviceId) +":unpausing..."+ str(self.name))
		playing = true

		if currentFrame < spriteFrames.size():
			var spriteFrame = spriteFrames[currentFrame]
			spriteFrame.set_physics_process(true)
	
func _physics_process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	var animationDelta = delta * speed * spriteAnimationManager.globalSpeedMod
	
	timeEllaspedSinceAniamtionStart = timeEllaspedSinceAniamtionStart + animationDelta
	
	#did we hit opponent and are now tracking the time
	#before closing autocancel on hit window?
	if trackingTimeEllapsedSinceHit:
		var onhitWindowDelta = delta * spriteAnimationManager.globalSpeedMod
		
		timeEllapsedSinceHit = timeEllapsedSinceHit+onhitWindowDelta
		
		#don't need to clear flag as the isOnHitAutoCancelWindowActive function
		#will be used instead to support autocanceling on hit
		#withitn window and for entire animation
		
		#the autocancel on hit window ellapsed?		
		#if GLOBALS.has_frame_based_duration_ellapsed(timeEllapsedSinceHit,onHitAutoCancelWindowInSeconds):
			
		#	setHittingWithJumpCancelableHitbox(false)
	
	if isLoopingWithDuration:
		
		#loopEllapsedSeconds = loopEllapsedSeconds + animationDelta
		
		#if timeEllaspedSinceAniamtionStart >= loopDurationInSeconds:
		if GLOBALS.has_frame_based_duration_ellapsed(timeEllaspedSinceAniamtionStart,loopDurationInSeconds):
			
			finishAnimation()
			
func getProximityGuardAreas():
	var res = []
	#iterate all frames in animation
	for f in spriteFrames:
		#iterate al hitbox areas
		for area in f.proximityGuardAreas:
			res.append(area)
	
	return res

func getHitboxes():
	var res = []
	#iterate all frames in animation
	for f in spriteFrames:
		#iterate al hitbox areas
		for hitbox in f.hitboxes:
			res.append(hitbox)
	
	return res

func getHurtboxes():
	var res = []
	#iterate all frames in animation
	for f in spriteFrames:
		#iterate al hitbox areas
		for hurtbox in f.hurtboxes:
			res.append(hurtbox)
	
	return res	
	
func getSelfOnlyHitboxes():
	var res = []
	#iterate all frames in animation
	for f in spriteFrames:
		#iterate al hitbox areas
		for hitbox in f.selfonly_hitboxes:
			res.append(hitbox)
	
	return res

func getSelfOnlyHurtboxes():
	var res = []
	#iterate all frames in animation
	for f in spriteFrames:
		#iterate al hitbox areas
		for hurtbox in f.selfonly_hurtboxes:
			res.append(hurtbox)
	
	return res	

func setHittingWithJumpCancelableHitbox(value):
	
	#we may be setting the hitflag to true
	if value:
		#check if the autocancel on hit window isn't for entire aniamtion
	#	#the autocancel on hit window ellapsed?
		if onHitAutoCancelWindow >= 0:
			#start tracking on hit autocancel window
			trackingTimeEllapsedSinceHit = true
			timeEllapsedSinceHit = 0
		#hasHitThisAnimationFlag=true
	else:
		#no longer trackin the onhit window, and disable hitting flag
		trackingTimeEllapsedSinceHit = false
		timeEllapsedSinceHit = 0
	hittingWithJumpCancelableHitbox = value
	
func getHittingWithJumpCancelableHitbox():
	return hittingWithJumpCancelableHitbox
	
func abilityCancelCostTypeToNumberOfChunks():
	match(abilityCancelCostType):
		AbilityCancelCostType.NA: 
			return 0
		AbilityCancelCostType.VERY_LIGHT: 
			return 0
		AbilityCancelCostType.LIGHT: 
			return 1
		AbilityCancelCostType.MEDIUM: 
			return 2
		AbilityCancelCostType.HEAVY: 
			return 3
		AbilityCancelCostType.VERY_HEAVY: 
			return 4
		_:
			return abilityBarDrain
	
func autoAbilityCancelCostTypeToNumberOfChunks():
	match(autoAbilityCancelCostType):
		AbilityCancelCostType.NA: 
			return 0
		AbilityCancelCostType.VERY_LIGHT: 
			return 0
		AbilityCancelCostType.LIGHT: 
			return 1
		AbilityCancelCostType.MEDIUM: 
			return 2
		AbilityCancelCostType.HEAVY: 
			return 3
		AbilityCancelCostType.VERY_HEAVY: 
			return 4
		_:
			return autoAbilityBarDrain
			
#hitfreeze duration of an ability cancel is determined by it's cost
func abilityCancelCostTypeToHitfreezeDuration():
	
	if customAbilityCancelHitFreeze > -1:
		return customAbilityCancelHitFreeze
	match(abilityCancelCostType):
		AbilityCancelCostType.NA: 
			return null
		AbilityCancelCostType.VERY_LIGHT: 
			return 1
		AbilityCancelCostType.LIGHT: 
			return 2
		AbilityCancelCostType.MEDIUM: 
			return 3
		AbilityCancelCostType.HEAVY: 
			return 4
		AbilityCancelCostType.VERY_HEAVY: 
			return 5
		_:
			return 5
		
func getAllInactiveProjectiles():
	
	var res = []
	
	#iterate sprite frames for projectile sprite frame
	for sf in spriteFrames:
		if sf is preload("res://projectiles/SpriteProjectileFrame.gd"):
			
			#iterate all instances and add to result
			var instances = sf.getAllInactiveProjectiles()
			
			for i in instances:
				res.append(i)
				
	return res
	
func setDisableHitboxes(f):
	disableHitboxes = f
func getDisableHitboxes():
	return disableHitboxes
	
	
func increaseSuperArmorWasHitCounter():
	superArmorWasHitCount = superArmorWasHitCount +1
	

	
	
#returns true when inside on hit autocancelable windows after hitting
#ignoreTimeEllapsed: true means we return true for entire animation if we hit, and false
#means only return true if hit and inside window
func isOnHitAutoCancelWindowActive(ignoreTimeEllapsed):

	#some aniamtions are always considered hitting
	if hittingFlagAlwaysEnabled:
		return true
	#case wehre ingore the window for on hit cancel ?
	if ignoreTimeEllapsed:
		return hittingWithJumpCancelableHitbox


	#didn't hit?
	if not hittingWithJumpCancelableHitbox:
		return false
		
	#special case where the window is infinitly large?
	if onHitAutoCancelWindow < 0:
		return hittingWithJumpCancelableHitbox
	else:
		#the autocancel on hit window ellapsed?
		if GLOBALS.has_frame_based_duration_ellapsed(timeEllapsedSinceHit,onHitAutoCancelWindowInSeconds):
			
			return false #missed on hit auto cancel window
			
		else:
			return true #still in on hit autocancel window
			
			
func setDisableBodyBoxFlag(flag):
	for sf in spriteFrames:
		sf.disableBodyBox=flag
		
		
#func hasHitThisAnimation():
	#return hasHitThisAnimationFlag	