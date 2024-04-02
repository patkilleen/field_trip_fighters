extends "res://basicMovement.gd"



func getCurrentSpeed():
	
	var velocity = Vector2(0,0)
	
	velocity.x = cos((activeAngle) * PI / 180) * (xSpeed*rawSpeedMod.x);
	velocity.y = sin((activeAngle) * PI / 180) * (ySpeed*rawSpeedMod.y);
	
	#affect speed by speed mode (x2 faster mod means x2 faster movement)
	return (velocity *movementAnimationManager.globalSpeedMod)
	
	