extends "ProjectileController.gd"


var stringLine = null
var defaultColor = null
var targetFadeoutColor = null

var fadeoutTween = null

export (Vector2) var upReelMidPoitnOffset= Vector2(0,-50)
export (Vector2) var backReelMidPoitnOffset= Vector2(-15,30)
export (Vector2) var airReelMidPoitnOffset= Vector2(-15,-30)

export (float) var fadeOutDuration= 0.25 #seconds

func _ready():
	pass
func init():
	#call parent init
	.init()
	bodyBox.disabled = true
	stringLine = $"stringLine2D"
	defaultColor= stringLine.modulate
	
	targetFadeoutColor =defaultColor
	targetFadeoutColor.a = 0
	
	fadeoutTween = $fadeoutTween
	
	#destroy the line once animation fadeout ends
	fadeoutTween.connect("finished",self,"destroy")
	
	#stringBreakImmunityTimer = frameTimerResource.new()
	#stringBreakImmunityTimer.connect("timeout",self,"_on_string_break_immunity_timeout")
	
	#self.add_child(stringBreakImmunityTimer)
	

#override the function
func fire():
	.fire()
	
	#start fading out the line
	fadeoutTween.start_interpolate_property(stringLine,"modulate",defaultColor,targetFadeoutColor,fadeOutDuration)
	
#override the function
func deactivate():
	.deactivate()


	
func setupLinePoints(gloveBallControllerPos,glovePos,reelType):
	
	var gloveBallController = self.masterPlayerController
	var gloveController = gloveBallController.masterPlayerController
	
	var midPointOffset = Vector2(0,0)
	#todo: implement logic to add a addition point in middle to illustrate the reel type
	if(reelType==masterPlayerController.UP_REEL_TYPE):
		midPointOffset = upReelMidPoitnOffset

	elif(reelType==masterPlayerController.BACK_REEL_TYPE):
		midPointOffset = backReelMidPoitnOffset
		pass
	elif(reelType==masterPlayerController.AIR_REEL_TYPE):	
		midPointOffset = airReelMidPoitnOffset
		pass
	else:#unknown reeel type. no middle point offeset
		pass	
		
	#mirror the x middle ofsset depending on where glove facing
	if not gloveController.kinbody.facingRight:
		midPointOffset.x = midPointOffset.x * -1
		
	var offset = self.getCenter()


	#distance between glove and the ball
	var distance = gloveBallControllerPos.distance_to(glovePos)
	
	#compute a vector that is follwoing the vector between glove and ball, and get point in middle	
	var vectorSepartingBallAndGlove = Vector2(glovePos.x - gloveBallControllerPos.x,glovePos.y - gloveBallControllerPos.y)
	
	vectorSepartingBallAndGlove = vectorSepartingBallAndGlove * 0.5
	var midPt = gloveBallControllerPos + vectorSepartingBallAndGlove
	
	
	#make the line reach from ball to glove
	stringLine.points[0].x=gloveBallControllerPos.x-offset.x
	stringLine.points[0].y=gloveBallControllerPos.y-offset.y
	
	stringLine.points[1].x=midPt.x-offset.x+midPointOffset.x
	stringLine.points[1].y=midPt.y-offset.y+midPointOffset.y
	
	stringLine.points[2].x=glovePos.x-offset.x
	stringLine.points[2].y=glovePos.y-offset.y