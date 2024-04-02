extends "res://SpriteAnimation.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
#enum LandingType{
#	FALLS_PRONE,
#	FALLS_PRONE_AFTER_DURATION,
#	DONT_FALL_PRONE
#}

#const ANGLE_WHEN_LAUNCHED_UP_AND_CAN_FALL_PRONE = -25
#const ANGLE_WHEN_FALLING_DOWN_AND_CAN_FALL_PRONE = -125

export (int) var duration = 60 setget setDuration,getDuration
export (int) var minDurationBeforeFallProne = 5 setget setMinDurationBeforeFallProne,getMinDurationBeforeFallProne

export (bool) var isAirHitstun = false

export (float) var lauchUpAngleCanFallProne = -25
export (float) var fallDownAngleCanFallProne = -125
#const SECONDS_PER_FRAME = 1.0/60.0
var durationInSeconds = 0
var minDurationBeforeFallProneInSeconds = 0
var hitstunSecondsEllapsed = 0
var landingType = 0 #falls prone
var stopHitMomentumOnLand = true
var isThrow=false
var techExceptions = 0
var stopMomentumOnPushOpponent=false
var stopMomentumOnOpponentAnimationPlay = false
var mvmStpOnOppAutoAbilityCancel = false

var newHitstunDurationOnLand = -1
#var unhandledVerticalApexReached = false
#var unhandledVerticalApexReached = false
var upwardMomentumApexReached = false

var fallingAngleApplied=false


#var fallProneRotationMap = {}
func _ready():
	self.set_physics_process(false)

#	fallProneRotationMap[GLOBALS.LandingType.FALLS_PRONE] = 150 #updsite down falling head first
#	fallProneRotationMap[GLOBALS.LandingType.FALLS_PRONE_AFTER_DURATION] = 75 #falling on their back, until duration ellapsed
#	fallProneRotationMap[GLOBALS.LandingType.DONT_FALL_PRONE] = 0 #upright
	pass

func readyForLandingHitstun():
	if landingType == GLOBALS.LandingType.FALLS_PRONE:
		return true
	elif landingType == GLOBALS.LandingType.FALLS_PRONE_AFTER_DURATION:
		#return hitstunSecondsEllapsed > minDurationBeforeFallProneInSeconds
		return playerController.hitstunTimer.getEllapsedTimeInSeconds() >minDurationBeforeFallProneInSeconds
	elif landingType == GLOBALS.LandingType.DONT_FALL_PRONE:
		return false
	else:
		return false
func setDuration(d):
	duration = d
	durationInSeconds = duration*GLOBALS.SECONDS_PER_FRAME
	
	
#FIXED_FRAME_DURATION_IN_SECONDS
func getDuration():
	return duration	
	
func getMinDurationBeforeFallProne():
	return minDurationBeforeFallProne

func setMinDurationBeforeFallProne(d):
	minDurationBeforeFallProne = d
	minDurationBeforeFallProneInSeconds = minDurationBeforeFallProne*GLOBALS.SECONDS_PER_FRAME
	

func play(_cmd,_facingRight,on_hit_starting_sprite_frame_ix=0):
	
	
	if not playing:
		#unhandledVerticalApexReached = false
		upwardMomentumApexReached = false
		fallingAngleApplied=false
		hitstunSecondsEllapsed=0
		#landingType=GLOBALS.FALLS_PRONE landing type set by higher layer nodes, don't touch
		self.set_physics_process(true)
		
			
	if isAirHitstun:
		
		#if landingType == GLOBALS.LandingType.FALLS_PRONE_AFTER_DURATION or landingType == GLOBALS.LandingType.FALLS_PRONE:
		
		#go into oki on land?
	#	if landingType == GLOBALS.LandingType.FALLS_PRONE:
	
		if readyForLandingHitstun():
			fallingAngleApplied=true
			updateSpriteFrameRotation(lauchUpAngleCanFallProne) #45 degrees should make lying on their back
			
		#go into oki on land after duration and duration already met?
	#	elif  landingType == GLOBALS.LandingType.FALLS_PRONE_AFTER_DURATION  and hitstunSecondsEllapsed > minDurationBeforeFallProneInSeconds:			
	#		updateSpriteFrameRotation(lauchUpAngleCanFallProne) #45 degrees should make lying on their back
	
		else:
			updateSpriteFrameRotation(0) #45 degrees should make lying on their back
	.play(_cmd,_facingRight,on_hit_starting_sprite_frame_ix)

		
func stop():
	if playing:
		self.set_physics_process(false)
	.stop()
	
func pause():
	if playing:
		self.set_physics_process(false)
	.pause()
		

func unpause():
	if not playing:
		self.set_physics_process(true)
	.unpause()
	
func _physics_process(delta):
	
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	#is this timer ever used?
	hitstunSecondsEllapsed+=delta * speed * spriteAnimationManager.globalSpeedMod
	
	#only check for when haven't handle falling and oki angle and may need change rotation if hitstun
	#time duation ellapsed for oki to enable
	if isAirHitstun and landingType == GLOBALS.LandingType.FALLS_PRONE_AFTER_DURATION and not fallingAngleApplied:
		
		#time ellapsed and can go into oki?
		if playerController.hitstunTimer.getEllapsedTimeInSeconds() > minDurationBeforeFallProneInSeconds:
		
			fallingAngleApplied=true
			
			#we haven't fallen yet?
			if not upwardMomentumApexReached:
				
				#rotate to flying up angle
				handleSpriteFallingRotation(lauchUpAngleCanFallProne)
			
			else:
				#we already rach apex, so angle should be down
				handleSpriteFallingRotation(fallDownAngleCanFallProne)
			
				

func updateSpriteFrameRotation(rotation_degrees):
	for sf in spriteFrames:
		sf.rotation_degrees =rotation_degrees
		
		
func _on_reached_vertical_momentum_apex():
	
	
	if playing:
		upwardMomentumApexReached=true
		
		var rotateHeadFirstSprite = false	
		
		if readyForLandingHitstun():
			rotateHeadFirstSprite=true
		
	
		#elif landingType == GLOBALS.LandingType.FALLS_PRONE_AFTER_DURATION:
			
			#this means not ready for oki yet
			
			#if playerController.hitstunTimer.getEllapsedTimeInSeconds() <=minDurationBeforeFallProneInSeconds:
				
				#here we reached apex, but arean't ready for oki fall down
			#	unhandledVerticalApexReached=true		
				
			
		#for hitstuns that fall prone on land after a duration, have we exceeded the duration?
	#	if landingType == GLOBALS.LandingType.FALLS_PRONE_AFTER_DURATION:
			
			#ready to fall prone?
	#		if hitstunSecondsEllapsed > minDurationBeforeFallProneInSeconds:
				#rotateHeadFirstSprite=true
				#print("reached apex  and ready for oki,  rotate")
	#		else:
				#print("reached apex  but not ready for oki, so no rotate")
	#			unhandledVerticalApexReached=true		
		
	#	elif landingType == GLOBALS.LandingType.FALLS_PRONE:
	#			rotateHeadFirstSprite=true
		
		
		if rotateHeadFirstSprite:				
			fallingAngleApplied=true
			handleSpriteFallingRotation(fallDownAngleCanFallProne)
			


func handleSpriteFallingRotation(_angle):
	#if playerController.kinbody.facingRight:
		#rotate the sprite so head down, to indicate will fall prone
	updateSpriteFrameRotation(_angle) #150 degrees should make head downard
	#else:
	#	updateSpriteFrameRotation(-1*fallDownAngleCanFallProne) #150 degrees should make head downard
	#now forcfully apply chagne by rorating the active nodes
	var sf = getCurrentSpriteFrame()
		
	if sf!= null:
		sf.applyRotationToActiveNodes()
