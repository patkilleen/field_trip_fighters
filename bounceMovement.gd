extends "res://basicMovement.gd"

signal stopped_bouncing
signal bounced #doesn't include first bounce
signal started_bouncing

var currNumBounces=0
#0 means infinity
#var maxBounces = 0
#var friction = 0 #0.1 could be a good value
#var bounceMod=0#0.7 could be a good value
var maxBounces = 0
var friction = 0.1 #0.1 could be a good value
var bounceMod=0.7#0.7 could be a good value
# Called when the node enters the scene tree for the first time.

var bounceCollision
var playerController = null

var initialized = false


func _ready():
	pass # Replace with function body.


#should be cllaed before the bounce signal handler called
#a movement animatio should implement these value, and if movement supports bounacign, should set it up
func setupBouncing(_maxBounces,_friction,_bounceMod):
	maxBounces=_maxBounces 
	friction=_friction
	bounceMod=_bounceMod
	currNumBounces=0
	initialized=true
	
func _on_bounce(newVelocityX,newVelocityY, is_on_floor):
	
	if not initialized:
		print("bounce bm not initialized. skip bounce")
		return
		
	var startedBouncing = false
		
			
	#limit on number of bounces?
	if maxBounces > 0:
		
		#bounced more than max number
		if currNumBounces >= maxBounces:
			
			#stop all bouncing movement
			stopBouncing()
			emit_signal("stopped_bouncing",GLOBALS.BOUNCE_RC_MAX_BOUNCES_EXCEEDED)
			return
	currNumBounces = currNumBounces + 1
	
	
	#first time bouncing?
	if not isActive():

		#start a new bounce movement
		init()
		#make sure to directly affect what x and y velocities are 
		#do this affect init, since xPseed and yspeed overriden with speed
		setXSpeed(newVelocityX*bounceMod)
		setYSpeed(newVelocityY*bounceMod)
		startedBouncing=true
		
	else:
		#bounce slows down the current velocity
		#update ball's current movement 
		setXSpeed(newVelocityX*bounceMod)
		setYSpeed(newVelocityY*bounceMod)
	
	#started bouncing signal called, and the bounced signal ignoresfirst bounce
	if startedBouncing:
		emit_signal("started_bouncing")
	else:
		emit_signal("bounced")
		
	
	applyFriction()
	
	
	if is_on_floor:
		#this logic from https://gist.github.com/memish/a72ebf71208d68e5fedd24fe3a57b496
		#prevent infinit mini bouncing 
		 #25 obtained from glove ball  d-trhow when it stops moving
		if ySpeed < 0 and ySpeed > -25:
			setYSpeed(0)
			
		if (abs(xSpeed) <= friction):
			if ySpeed <= 0:
				if ySpeed > -25:
					emit_signal("stopped_bouncing",GLOBALS.BOUNCE_RC_MOMENTUM_CAME_TO_HALT)
					stopBouncing()
					return
			
		
		
#override speed updates to avoid any computation of angles. using raw velocity vector
func updateCurrentSpeed(delta):
	
	#bouncing should have no acceleration

		
		

	setXSpeed(min(xSpeed,maxSpeed))
	setXSpeed(max(xSpeed,minSpeed))
	setYSpeed(min(ySpeed,maxSpeed))
	setYSpeed(max(ySpeed,minSpeed))
	
	var is_on_floor =playerController.my_is_on_floor()
	
	if is_on_floor:
		#this logic from https://gist.github.com/memish/a72ebf71208d68e5fedd24fe3a57b496
		#prevent infinit mini bouncing 
		if ySpeed < 0 and ySpeed > -2.1:
			setYSpeed(0)
		if abs(xSpeed) <= friction:
			stopBouncing()
			emit_signal("stopped_bouncing",GLOBALS.BOUNCE_RC_MOMENTUM_CAME_TO_HALT)
			return
			
		applyFriction()
	
	
	
		
func applyFriction():
	
	if xSpeed > 0:
		xSpeed = xSpeed -friction
	else:
		xSpeed = xSpeed +friction

func stopBouncing():
	.stop()
	#RESET bounce count in case bouncing restarts using same bouncing parameters
	currNumBounces = 0

#hook that stops ball but also emits singal that bounce forcefuly stopped before bounce naturally ends
func stop():
	
	initialized=false
	var wasActive = isActive()
	stopBouncing()
	
	if wasActive:
		emit_signal("stopped_bouncing",GLOBALS.BOUNCE_RC_EXTERNALLY_STOPPED)

	
#override get current speed
func getCurrentSpeed():
	
	var velocity = Vector2(0,0)
	
	velocity.x = getXSpeed()*rawSpeedMod.x
	velocity.y = getYSpeed()*rawSpeedMod.y
	
	
	
	#don't mirror x velocity, we want raw control on angles and directons
	#also ignore the angle, since working with raw velocity vector for bouncing
		
	#affect speed by speed mode (x2 faster mod means x2 faster movement)
	return (velocity *movementAnimationManager.globalSpeedMod)
	#return velocity
	
func setXSpeed(spd):
	xSpeed = spd
func getXSpeed():
	return xSpeed
	
func getYSpeed():
	return ySpeed
	
func setYSpeed(spd):
	ySpeed = spd



	