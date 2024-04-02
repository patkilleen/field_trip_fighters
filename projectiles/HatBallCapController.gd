extends "ProjectileController.gd"

signal retreived_ball_cap
signal landed

const frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")
var ballCapRetreiveLockTimer=null

#hat can't retreive ball cap for 30 frames after ball cap flung from head after headbutt 
#to prevent instint retreiving ball cap
const RETREIVE_BALL_CAP_LOCK_DURATION=30
#var opponentProximityDetector = null
var hatStandingDetector = null
var hatStandingDetector2 = null
var hatWasStandingOnBallCap =false
var onBatteleField=false
var canBeRetreived =false

const LOSE_HAT_SCREAM_SOUND_ID=40
func _ready():

	ballCapRetreiveLockTimer = frameTimerResource.new()
	self.add_child(ballCapRetreiveLockTimer)
	ballCapRetreiveLockTimer.connect("timeout",self,"_on_ball_cap_retreive_lock_timeout")
	
	
func init():
	
	#call parent init
	.init()

	#the ball cap doesn't hit anything. A simple raycast is used for know if Hat is ontop of it
	collisionHandler.set_physics_process(false)
	collisionHandler.ignoreCollisions=true
	
	#playerDetectionArea = $bodyBox/playerDetectionArea
	
	#var masterHud = masterPlayerController.kinbody.get_node("HUD/HBoxContainer2/pnameLabel")
	var masterHud = masterPlayerController.kinbody.playerNameLabel
	var ballHud = $HUD/HBoxContainer2/pnameLabel
	ballHud.text = masterHud.text
	ballHud.set("custom_colors/font_color",masterHud.get("custom_colors/font_color"))
	
	
	hatStandingDetector = $bodyBox/hatStandingDetector
	hatStandingDetector2 =$bodyBox/hatStandingDetector2
	#configure standing detection

	hatStandingDetector.collision_mask = 1 << masterPlayerController.kinbody.bodyBoxCollisionBit
	hatStandingDetector2.collision_mask = hatStandingDetector.collision_mask
	hatWasStandingOnBallCap = false
	

func _on_land():
	playActionKeepOldCommand(actionAnimationManager.ON_GROUND_ACTION_ID)
	emit_signal("landed")
	

func _on_left_ground():
	pass

func _on_ceiling_collision(collider):
	pass	

func _on_wall_collision(collider):
	
	pass

	
func _on_ball_cap_caught():

	ballCapRetreiveLockTimer.stop()
	#only enable magifying glass when on stage
	
	self.visible = false
	onBatteleField=false
	
	canBeRetreived=false
	
	playAction(actionAnimationManager.OFF_BATTLEFIELD_ACTION_ID)
		
	
	#ball cap isn't active anymore, stop collision detectio nand movement
	movementAnimationManager.set_physics_process(false)
	
	
	#this is to make sure the ball cap stops
	actionAnimationManager.movementAnimationManager.deactivateAllMovement()
	
	
	
	
	movementAnimationManager.haltMovement()
	
	
	emit_signal("retreived_ball_cap",self)

		
			
#override the function
func fire():
	
	
	masterPlayerController._on_request_play_special_sound(LOSE_HAT_SCREAM_SOUND_ID,masterPlayerController.HERO_SOUND_SFX)
	playActionKeepOldCommand(startingActionId)
	#playActionKeepOldCommand(actionAnimationManager.IN_AIR_ACTION_ID)
	
	self.visible = true
	
	#start the timeer for duration of retreive ballcap lockout
	ballCapRetreiveLockTimer.start(RETREIVE_BALL_CAP_LOCK_DURATION)
	
	actionAnimationManager.movementAnimationManager.deactivateAllMovement()
	movementAnimationManager.haltMovement()

	onBatteleField=true

	
	
	#prevent auto catching ball cap upon fleeing it from headbut.
	canBeRetreived = false
	
	
	hatWasStandingOnBallCap=false
	
	
	.fire()


	
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	if not onBatteleField:
		return
		
	#can only retreive ball cap if ball cap not just flung from headbut and ball cap inside body box of hat
	#also can't retreive  it if hat in hitstun
	if not hatWasStandingOnBallCap:#didn't catch ball cap last frame?
		if hatStandingDetector.is_colliding() or hatStandingDetector2.is_colliding():
			if masterPlayerController.isDashingToBallCap():
				hatWasStandingOnBallCap=true
				_on_ball_cap_caught()
		#if canBeRetreived: #ball cap can be retreived?	 
		#	if hatStandingDetector.is_colliding():#hat is on the hat?
		#		if not masterPlayerController.playerState.inHitStun: #hat is not in hitstun?
		#			if not masterPlayerController.guardHandler.isInBlockHitstun(): #hat not in blockkstun?
		#				if not masterPlayerController.actionAnimeManager.isCurrentSpriteAnimation(masterPlayerController.actionAnimeManager.STUNNED_ACTION_ID):	#hat not stunned?
				
						#	hatWasStandingOnBallCap=true
						#	_on_ball_cap_caught()
					
				
		

func _on_left_wall():
	
	pass
	
		
func playAction(actionId):
	actionAnimationManager.playAction(actionId,masterPlayerController.kinbody.spriteCurrentlyFacingRight)
	
func playActionKeepOldCommand(actionId):
#	var tmp = actionAnimationManager.commandActioned
	playAction(actionId)
	actionAnimationManager.commandActioned = command

func _on_ball_cap_retreive_lock_timeout():
	canBeRetreived = true
