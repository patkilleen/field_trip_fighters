extends "MovementAnimationManager.gd"

signal bumped_into_something


#export (Vector2) var inCornerHitPushAwaySpeed = Vector2(250,0)
#export (float) var inCornerHitPushAwayDurationInSeconds = 0.25
export (Vector2) var landingPushAwaySpeed = Vector2(250,60)
export (float) var horizontalAlignmentOffset = -40

export (Vector2) var cornerContextPushAwaySpeed = Vector2(200,60)

const LANDING_ON_OPPONENT_PUSH_AWAY_X_AMOUNT = 9
const LANDING_ON_OPPONENT_PUSH_AWAY_Y_AMOUNT = 2

var frameTimerResource = preload("res://frameTimer.gd")

var canPushFlag = true setget setCanPushFlag,getCanPushFlag
var pushableFlag = true setget setPushableFlag,getPushableFlag

var pushing = null


var pushed_body = null
var pushing_body = null
var pushed_vel = Vector2(0,0)
var speed_when_pushing_started = Vector2(0,0)
var pushed_speedMod = 1

var facingRightWhenPushingStarted = false

var selfScript = null

var landingPushingAway = false

#var pushingAwayInCorner = false

var hittingInCornerPushAwayTimer = null

var insidePlayerBodyPushingAway = false
var insidePlayerBodyPushingLeft = null
var tmpIgnoringInsidePlayerPush=false

var pushingPlayerAwayRecursionLock = false
func _ready():

	#our scripts name
	selfScript = self.get_script().get_path().get_file()
	hittingInCornerPushAwayTimer = frameTimerResource.new()
	self.add_child(hittingInCornerPushAwayTimer)
	
	hittingInCornerPushAwayTimer.connect("timeout",self, "_on_hitting_in_corner_push_away_timeout")
	

	
	

func reset():
	.reset()
	canPushFlag = true
	pushableFlag = true
	pushingPlayerAwayRecursionLock=false
	pushing = null

	if hittingInCornerPushAwayTimer != null:
		hittingInCornerPushAwayTimer.stop()
	pushed_body = null
	pushing_body = null
	pushed_vel = Vector2(0,0)
	speed_when_pushing_started = Vector2(0,0)
	pushed_speedMod = 1

	facingRightWhenPushingStarted = false

	landingPushingAway = false

	insidePlayerBodyPushingAway = false
	insidePlayerBodyPushingLeft = null
	tmpIgnoringInsidePlayerPush=false


func setCanPushFlag(flag):
	canPushFlag = flag
	
	#when we aren't pusahble, stop pushing/being pushed
	if not canPushFlag:
		stopPushing()

	
func getCanPushFlag():
	return canPushFlag
	
func setPushableFlag(flag):
	pushableFlag = flag
	
	#when we aren't pusahble, stop pushing/being pushed
	if not pushableFlag:
		stopPushing()
	
func getPushableFlag():
	return pushableFlag

		
#make sure origanal logic of parent clsas is empty now
#that we implement our own pushing logic
#we implement like this since we can't actually override 
#_physics_process. It will be called in parent and child class
func on_physics_process_hook(delta):	
	#release lock on frame so any animation can change animation for next frame
	priorityOfAnimeHoldingLock=null
	
	#each frame can push player away again
	pushingPlayerAwayRecursionLock=false
	#do not move anything until landing push away is done
	if landingPushingAway:
		clearMvmCollisions()	
		return

	
	#var xDirection = Vector2(1,1)
	#if not facingRight:
	#	xDirection = Vector2(-1,1)
		
	handleCurrentAnimation(delta)
	
	
		
	#$var velocity = computeRelativeVelocity() * xDirection
	var velocity = computeRelativeVelocity()
	#add the gravity
	#if gravity.is_physics_processing():
	#	velocity = velocity + gravity.getCurrentSpeed()
	
	velocity = addGravityToVelocity(velocity)
	
	checkForStopBodyCollisions(velocity)		
	
	clearMvmCollisions()
	
	var velocityToApply = velocity
				
	#var pushedVelocity = Vector2(pushed_vel.x,velocity.y + pushed_vel.y)
	
	if isPushing():
		applyPushRelativeSpeed(pushed_body,velocity.x,pushed_body.computeRelativeVelocity().x)
		velocityToApply.x = velocity.x * pushed_speedMod
		velocityToApply.y = velocity.y
	#set the x velocity match pusher's speed	
	elif isBeingPushed():
		
		velocityToApply.x = pushed_vel.x * pushed_speedMod
		velocityToApply.y = velocity.y
		velocityToApply = velocityToApply 
	
	#if pushingAwayInCorner:
	#	velocityToApply = velocityToApply + inCornerHitPushAwaySpeed
	var otherMovementAnimationManager = playerController.opponentPlayerController.actionAnimeManager.movementAnimationManager
	
	#were contesting corner and getting pushed out of it? and not ignoreing the push (if either player ignores push, then don't push)?
	if 	insidePlayerBodyPushingAway and not tmpIgnoringInsidePlayerPush and not otherMovementAnimationManager.tmpIgnoringInsidePlayerPush:
			
		if insidePlayerBodyPushingLeft:
			
			var vel =landingPushAwaySpeed
			vel.x = vel.x * -1
			velocityToApply = velocityToApply +vel
#			targetKinematicBody2D.move_and_slide(vel,floor_normal)
#			emit_signal("moved_kinematic_body")
			
			
		else:
				
			var vel =landingPushAwaySpeed
			velocityToApply = velocityToApply +vel
			#targetKinematicBody2D.move_and_slide(vel,floor_normal)
			#emit_signal("moved_kinematic_body")
		 
	moveKinematicBody(velocityToApply,delta)		
	#var stop_on_slope=false
	#var max_slides=4
	#var floor_max_angle=0
	#var infinite_inertia=true
	#targetKinematicBody2D.move_and_slide(velocityToApply,floor_normal,stop_on_slope,max_slides,floor_max_angle,infinite_inertia)
	
	emit_signal("moved_kinematic_body",self)	
	

	
	#cachedRelativeVelocity =velocityToApply
func _on_moved_kinematic_body(mvmAnimationMngr):
	checkForNewBodyCollisions(lastRelativeVelocity.x)
	
func stopPushing():
	if(pushed_body != null):
		pushed_body.pushed_vel.x = 0
		#pushed_body.pushed_vel.y = 0
		pushed_body.pushed_body = null
		pushed_body.pushing_body = null
		pushed_body = null
	if(pushing_body != null):
		pushing_body.pushed_vel.x = 0
		#pushing_body.pushed_vel.y = 0
		pushing_body.pushed_body = null
		pushing_body.pushing_body = null
		pushing_body = null
		
	pushed_vel.x = 0
	#pushed_vel.y = 0
	speed_when_pushing_started.x=0
	
func startPushing(target, speed,otherXSpeed, pushSpeedMod):
	
	#print("start pushing")
	if(target != null):
		facingRightWhenPushingStarted = targetKinematicBody2D.facingRight
		pushed_vel.x = 0
		#pushed_vel.y = 10 #  keep the gravity
		pushed_body = target
		pushing_body = null
		target.pushing_body = self
		pushed_speedMod = pushSpeedMod
		pushed_body.pushed_speedMod = pushSpeedMod
		applyPushRelativeSpeed(target,speed,otherXSpeed)
		

func applyPushRelativeSpeed(targetBeingPushed, speed, otherXSpeed):
	#pushing target left?
	if(speed < 0):
		#going with target (its going left)
		if( otherXSpeed < 0):
			targetBeingPushed.pushed_vel.x = speed 
		else: #going against (its going right))
			targetBeingPushed.pushed_vel.x = (speed + otherXSpeed) 
	elif (speed > 0):#pushing right
		#going against target (its going left)
		if( otherXSpeed < 0):
			targetBeingPushed.pushed_vel.x = (speed + otherXSpeed) 
		else: #going with (its going right)
			targetBeingPushed.pushed_vel.x = speed 
	else:
		print("warning, pushing with 0 speed")	
		
	speed_when_pushing_started.x = speed
	targetBeingPushed.speed_when_pushing_started.x = 0
func isPushing():
	return ( pushed_body != null)
	
func isBeingPushed():
	return ( pushing_body != null)
	
func horizontallyAligned(otherBodyBox):
	#make sure both bodys still on same y axis (if not, clearly not pushing)
	var bodyBoxPosition = bodyBox.global_position
	var bodyBoxDim = bodyBox.get_shape().get_extents()
	var otherBodyBoxPosition = otherBodyBox.global_position
	var otherBodyBoxDim = otherBodyBox.get_shape().get_extents()
	
	#above? 
	if (bodyBoxPosition.y + bodyBoxDim.y - horizontalAlignmentOffset) < otherBodyBoxPosition.y:
		return false
	elif bodyBoxPosition.y  > (otherBodyBoxPosition.y + otherBodyBoxDim.y - horizontalAlignmentOffset):#below
		return false
		
	return true
#############################bug with stop getting pushed. if pushing, even with more speed, u can tbreak bree. 2nd there is more speed, it should break away
##############################
func checkStopPushing(xVelocity):
	
	if not isPushing():
		return;
	
	
	
	#if were not about to collide with object being pushed, then stop, its gone (got away)
	#need to take into account may collide with ceiling or walls or floor
	#if not self.test_move(self.transform,Vector2(xVelocity,0)):
	#	stopPushing()
	#	return

	if not horizontallyAligned(pushed_body.bodyBox):
		stopPushing()
		return
			
		#speed changed for body pushing?
	var velocityChangedSincedInitialPush = speed_when_pushing_started.x != xVelocity
	
	#our speed has changed?
	#if velocityChangedSincedInitialPush :
		
	#speed of object we are pushing
	var pushed_body_speed = pushed_body.computeRelativeVelocity().x
	
	#if( speed_when_pushing_started.x == 0):
	if xVelocity == 0 :
		stopPushing()
		return
		
	#stop pushing if we are going away from facing direction we started pushing
	if facingRightWhenPushingStarted and xVelocity < 0:
		stopPushing()
		return
	if not facingRightWhenPushingStarted and xVelocity > 0:
		stopPushing()
		return
		
	#has pushing speed increased? keep pushing if so
	#pushing left...?
	#if speed_when_pushing_started.x < 0:
	if  xVelocity < 0:
	#slowed down?
		if xVelocity > speed_when_pushing_started.x:
			#only stop pushing if the object being pushed is going faster than our current pushing speed
			if xVelocity > pushed_body_speed:
				
				stopPushing()
				return
		#check if moved away via y-axis,
	#	elif not self.test_move(self.transform,Vector2(xVelocity,0)):
	#		stopPushing()
	#		return
	#elif speed_when_pushing_started.x > 0:#pushing right
	elif  xVelocity > 0:
		#slowed down?
		if xVelocity < speed_when_pushing_started.x:
			#only stop pushing if the object being pushed is going faster than our current pushing speed
			if xVelocity < pushed_body_speed:
				stopPushing()
				return
	#	elif not self.test_move(self.transform,Vector2(xVelocity,0)):
	#		stopPushing()
	#		return
			
	
	#make sure to update the speed at which were pushing opponent
	#pushed_body.pushed_vel.x = xVelocity
	#speed_when_pushing_started.x = xVelocity


func checkStopGettingPushed(xVelocity):
	
	if pushing_body == null:
		stopPushing()
		
	if not isBeingPushed():
		return;
	
	#current animation can't get pushed?
	if not isSpriteFramePushable():
		stopPushing()
		return
	
	
	var pushing_body_speed = pushing_body.computeRelativeVelocity().x
		#speed changed?
	#var velocityChangedSincedInitialPush = speed_when_pushing_started.x != xVelocity
	
	#our speed has changed?
	#if velocityChangedSincedInitialPush :
		
	#speed of object pushing us
	if pushing_body_speed == 0:
		stopPushing()
		return
	# getting pushed left...?
	#if pushing_body.speed_when_pushing_started.x < 0:
	if pushing_body_speed < 0:
	
		if xVelocity < pushing_body_speed:
	
				stopPushing()
				return
		elif xVelocity > abs(pushing_body_speed):
			stopPushing()
			return
				
	#elif pushing_body.speed_when_pushing_started.x > 0:
	elif pushing_body_speed > 0:
		#sped up down?
		if xVelocity > pushing_body_speed:
				stopPushing()
				return
		elif pushing_body_speed < abs(xVelocity):
			stopPushing()
			return

func isSpriteFramePushable():
	#unpushable sprite frame?
	var currFrame = spriteAnimationManager.getCurrentSpriteFrame()
	
	if currFrame != null:
		return currFrame.pushable
	
	return true
		
	
func checkForStopBodyCollisions(velocity):
	
	if(isBeingPushed()):
		checkStopGettingPushed(velocity.x)
	if(isPushing()):
		checkStopPushing(velocity.x)
		


func standingOnOpponent():
	#colliding with a physics object and not on floor? ie. on opponent
	#if targetKinematicBody2D.is_on_floor():
	if on_floor:
		return not floorDetector.is_colliding()
	
	return false
	
#this function is called when this player lands on opponent
func pushPlayerAway(facingRight,opponentInCorner):
	if pushingPlayerAwayRecursionLock:
		return
	pushingPlayerAwayRecursionLock=true
	#avoid recursion inifites (caused the infamous game freeze crash typically with hat up tool)
	
	var otherMovementAnimationManager = self.get_parent().get_parent().opponentPlayerController.actionAnimeManager.movementAnimationManager
	
	var p1Center = targetKinematicBody2D.getCenter()
	var p2Center = otherMovementAnimationManager.targetKinematicBody2D.getCenter()
	
	var p1CenterX = p1Center.x
	var p2CenterX = p2Center.x
	var p1Position = p1Center
	var p2Position = p2Center
	
	
	var  thisPlayerYSpeedMod = null
	var  opponentYSpeedMod = null

	#TODO: I think the logic is reversed. negative y is up... no game breaking atm,
	#but odd land signals from pushing opponent probably due to this logic
	#now, determine who is in air (may be jumping into someone standing on a platform)
	if playerController.my_is_on_floor():
		#don't break the floor collision, so keep positive y speed
		thisPlayerYSpeedMod =abs(landingPushAwaySpeed.y)
	else:
		#were in the air, so now make y speed go away from opponent
		#above opponent?
		if  p1Position.y < p2Position.y:
			#go  up
			thisPlayerYSpeedMod =-abs(landingPushAwaySpeed.y)
		else:
			#below opponent, so go down
			thisPlayerYSpeedMod =abs(landingPushAwaySpeed.y)
	
	if playerController.opponentPlayerController.my_is_on_floor():
		#don't break the floor collision, so keep positive y speed
		opponentYSpeedMod =abs(landingPushAwaySpeed.y)
	else:
		#were in the air, so now make y speed go away from opponent
		#above opponent?
		if  p2Position.y < p1Position.y:
			#go  up
			opponentYSpeedMod =-abs(landingPushAwaySpeed.y)
		else:
			#below opponent, so go down
			opponentYSpeedMod =abs(landingPushAwaySpeed.y)
	

	var xAmountToMove =0
	#we will be pushing both players away from each other?
	#ie, the opponent isn't contesting the corner?
	if not opponentInCorner:
		
		if facingRight:	

			
			#otherMovementAnimationManager.targetKinematicBody2D.move_and_slide(Vector2(landingPushAwaySpeed.x,opponentYSpeedMod),floor_normal)
			otherMovementAnimationManager.my_move_and_slide(otherMovementAnimationManager.targetKinematicBody2D,Vector2(landingPushAwaySpeed.x,opponentYSpeedMod),floor_normal)
						
			otherMovementAnimationManager.emit_signal("moved_kinematic_body",otherMovementAnimationManager)
			
			#targetKinematicBody2D.move_and_slide(Vector2(-1*landingPushAwaySpeed.x,thisPlayerYSpeedMod),floor_normal)
			my_move_and_slide(targetKinematicBody2D,Vector2(-1*landingPushAwaySpeed.x,thisPlayerYSpeedMod),floor_normal)
		
			emit_signal("moved_kinematic_body",self)
		else:
			

		
		
			#otherMovementAnimationManager.targetKinematicBody2D.move_and_slide(Vector2(-1*landingPushAwaySpeed.x,opponentYSpeedMod),floor_normal)
			otherMovementAnimationManager.my_move_and_slide(otherMovementAnimationManager.targetKinematicBody2D,Vector2(-1*landingPushAwaySpeed.x,opponentYSpeedMod),floor_normal)			
			otherMovementAnimationManager.emit_signal("moved_kinematic_body",otherMovementAnimationManager)

			#targetKinematicBody2D.move_and_slide(Vector2(landingPushAwaySpeed.x,thisPlayerYSpeedMod),floor_normal)
			my_move_and_slide(targetKinematicBody2D,Vector2(landingPushAwaySpeed.x,thisPlayerYSpeedMod),floor_normal)
			emit_signal("moved_kinematic_body",self)
			
	else:
		if facingRight:
			#we will be pushing only the landing player away from right way (to the left)
			
			#targetKinematicBody2D.move_and_slide(Vector2(-1*landingPushAwaySpeed.x,thisPlayerYSpeedMod),floor_normal)
			my_move_and_slide(targetKinematicBody2D,Vector2(-1*landingPushAwaySpeed.x,thisPlayerYSpeedMod),floor_normal)
			emit_signal("moved_kinematic_body",self)
			
		else:
			#we will be pushing only the landing player away from right way (to the left)
	
			#targetKinematicBody2D.move_and_slide(Vector2(landingPushAwaySpeed.x,thisPlayerYSpeedMod),floor_normal)
			my_move_and_slide(targetKinematicBody2D,Vector2(landingPushAwaySpeed.x,thisPlayerYSpeedMod),floor_normal)
			emit_signal("moved_kinematic_body",self)
	




func pushPlayerAwayFromInsideOpponent(facingRight):
	
	
	insidePlayerBodyPushingLeft =  facingRight
	
	insidePlayerBodyPushingAway = true
	
func stopPushingPlayerAwayFromInsideOpponent():
	insidePlayerBodyPushingAway = false
	insidePlayerBodyPushingLeft = null
		
#this function is called corner contesting occurs
#func _pushPlayerAwayFromInsideOpponent(inCornerStatus):
	
#	if inCornerStatus == GLOBALS.OnOpponentStatus.AGAINST_RIGHT_WALL:
		
#		var vel =landingPushAwaySpeed
#		vel.x = vel.x * -1
#		targetKinematicBody2D.move_and_slide(vel,floor_normal)
#		emit_signal("moved_kinematic_body")
		
		
#	elif inCornerStatus == GLOBALS.OnOpponentStatus.AGAINST_LEFT_WALL:
			
#		var vel =landingPushAwaySpeed
#		targetKinematicBody2D.move_and_slide(vel,floor_normal)
#		emit_signal("moved_kinematic_body")
		
			
func checkForNewBodyCollisions(xPushSpeed):
	var pushFlag = false

	
	#only check for pushing if current frame can push
#	if not canPushFlag:
#		return
		
	#if standingOnOpponent():
	#	pushPlayerAway()
	#	return
	var otherPlayer = getKinematicBodyCollision()
	
	#no collision?
	if otherPlayer == null:
		return
	
	var otherMovementAnimationManager = otherPlayer.movementAnimationManager
	
	if otherMovementAnimationManager == null:
		return
		
	
	#only check for pushing of opponent's frame can be pushed
	if not otherMovementAnimationManager.pushableFlag:
		return
		
	#now make sure the thing we collided with has a movement manager that also 
	#handles pushing
	var script = otherMovementAnimationManager.get_script()	
	
	if script == null:
		return
	var scriptName = script.get_path().get_file()
	
	#make sure both self and this opposing object have pushing movement mngr script
	if scriptName != selfScript:
		return 
		
	#only collide when on same horizontal axis (cannot push from below or above)
	if (not horizontallyAligned(otherMovementAnimationManager.bodyBox)) and canPushFlag:
		
		
		#push away both players (as opposed to just one against a wall)
		pushPlayerAway(playerController.kinbody.facingRight,false)
		return
		
	
		
	#others speed
	var otherXSpeed = otherMovementAnimationManager.computeRelativeVelocity().x
	
	#right horizontal movement?
	if (xPushSpeed > 0) and (otherXSpeed >= 0):
		if xPushSpeed > otherXSpeed:
			pushFlag = true	
	elif (xPushSpeed < 0) and (otherXSpeed <= 0):
		if xPushSpeed < otherXSpeed:
			pushFlag = true	
	elif (xPushSpeed > 0) and (otherXSpeed <= 0):
		if xPushSpeed > abs(otherXSpeed):
			pushFlag = true	
	elif (xPushSpeed < 0) and (otherXSpeed >= 0):
		if abs(xPushSpeed) > otherXSpeed:
			pushFlag = true	
	#we can only push if opponent is slower than us
		
		
	#only start pushing once
	if not isPushing():
		if pushFlag and canPushFlag:
			#in the air? full speed
			#if targetKinematicBody2D.is_on_floor():
			if on_floor:
				startPushing(otherMovementAnimationManager,xPushSpeed,otherXSpeed,0.5) #TODO REMOVE HARDCODED VALUE
			else:
				startPushing(otherMovementAnimationManager,xPushSpeed,otherXSpeed,1)
		
	if pushFlag:
		emit_signal("bumped_into_something")
		#on ground, half speed
		
		
#called when stopped or started opponent landing pushing
func _on_landing_pushaway_changed(pushingAwayFlag):
	landingPushingAway = pushingAwayFlag
	

func _on_hitting_player(selfHitboxArea, otherHurtboxArea):
	
	#ignore the case where hitting your own special hitboxes (glove's ball for example)
#	if selfHitboxArea.selfOnly:
#		return
#	pass
	
	#ignore grabs (might have to revisit this in future for comand grabs, but this is fine for now)
#	if selfHitboxArea.isThrow:
#		return
	
	#hitting opponent against left wall?
#	if playerController.hittingLeftWallDetector.is_colliding() and playerController.opponentPlayerController.leftWallDetector.is_colliding():
		
		#pus away from wall means go right
#		inCornerHitPushAwaySpeed.x= abs(inCornerHitPushAwaySpeed.x)
#		pushingAwayInCorner = true
#	elif playerController.hittingRightWallDetector.is_colliding() and playerController.opponentPlayerController.rightWallDetector.is_colliding():
		
#		pushingAwayInCorner = true
		#push away from wall means go left
#		inCornerHitPushAwaySpeed.x= -1*abs(inCornerHitPushAwaySpeed.x)
		
#	if pushingAwayInCorner:
#		hittingInCornerPushAwayTimer.startInSeconds(inCornerHitPushAwayDurationInSeconds)
	pass
func _on_hitting_in_corner_push_away_timeout():
	#pushingAwayInCorner = false
	pass
	