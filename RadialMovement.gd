extends "res://basicMovement.gd"

#TODO: BUGGED. WILL HAVE TO ANCHOR THE CENTER LIKE FOLLOW MOVEMENT

export (float) var radius = 1.0 
export (Vector2) var center = Vector2(0,0)#center of the circular movement to apply
export (bool) var clockwise = true



#PARENT attribbutes
#export (float) var speed=0 ANGULAR SPEED
#export (float) var acceleration=0 ANGULAR ACCELERATION
#export (float) var maxSpeed=0 MAXIMUM ANGULAR SPEED
#export (float) var minSpeed=0 MINIMUM ANGULAR SPEED
#export (float) var angle=0 THE DEFAULT ANGLE THE SPINING STARTS

var currentAngularSpeed=0 setget setCurrentAngularSpeed,getCurrentAngularSpeed
var defaultAngle = angle
var currentAngle = angle
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD


func _ready():
	
	defaultAngle=angle
	currentAngle=angle
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	
	pass

func setGlobalSpeedMod(mod):
	globalSpeedMod=mod
	
func init():
	.init()
	#the angle of movement changes as opposed to being static like basic movement
	angle=defaultAngle
	currentAngle=defaultAngle

		
func setCurrentAngularSpeed(newAngulerSpeed):
	currentAngularSpeed=min(newAngulerSpeed,maxSpeed)
	currentAngularSpeed=max(newAngulerSpeed,minSpeed)
	
func getCurrentAngularSpeed():
	return currentAngularSpeed
	
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	delta = delta * globalSpeedMod

	#compute point where fictional point was
	var currPos = Vector2(center.x + cos(currentAngle)*radius,center.y + sin(currentAngle)*radius)
	
	var clockwiseMod = null
	#ccompute what direction spinning
	if clockwise:
		clockwiseMod=1
	else:
		clockwiseMod=-1
		
	#move the fictional reference point around circle
	var angleIncrease = currentAngularSpeed*delta
	currentAngle = currentAngle + (clockwiseMod * angleIncrease) 
	
	var newAngulerSpeed = currentAngularSpeed + (acceleration * delta)
	setCurrentAngularSpeed(newAngulerSpeed)
	
	
	#compute the new locaiton of reference poitn
	var newPos = Vector2(center.x + cos(currentAngle)*radius,center.y + sin(currentAngle)*radius)
	
	#now, we need to compute the xspeed, yspeed, and angle that this basic movement
	#will guide the target object it's moving
	#note that the delta was applied to find the new point, so we must multiply/extend the 
	#new point's distance by factor of delta, so make sure when relative speed computed (including delta)
	#delta isn't appied twice
	
	newPos.x =  newPos.x/delta
	newPos.y =  newPos.y/delta
	
	
	xSpeed = newPos.x
	ySpeed = newPos.y
	
	
	angle = rad2deg((newPos-currPos).angle())
	
