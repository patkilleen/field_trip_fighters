extends "res://basicMovement.gd"

export (float) var angularVelocity = 0
export (float) var angularAcceleration = 0
var currAngularVelocity=0

func init():
	.init()
	currAngularVelocity = angularVelocity
func updateCurrentSpeed(delta):
	.updateCurrentSpeed(delta)
	
	currAngularVelocity = currAngularVelocity + (angularAcceleration*movementAnimationManager.globalSpeedMod) * delta
	
	activeAngle = activeAngle + currAngularVelocity*delta
	
	