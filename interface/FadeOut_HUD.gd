extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (Color) var fadeOutColor = Color(1,1,1,1)

var defaultColor = null
var colorRect = null
var tween = null

const MyTweenResource = preload("res://MyTween.gd")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	colorRect = $ColorRect
	
	#tween = $Tween
	tween = MyTweenResource.new()
	
	add_child(tween)
	
	tween.removeFromGlobalSpeedGroup()
	tween.ignoreHitFreeze=true
	#tween.connect("tween_completed",self,"_fadeOut_complete")
	tween.connect("finished",self,"_fadeOut_complete")
	
	defaultColor=fadeOutColor
	pass

func init():
	colorRect.color = defaultColor
	self.visible=false
func _fadeOut_complete():
	#tween.stop(colorRect)
	#make the fadeout disapear once it finishes, sine the result screen will take over
	self.visible=false
	
func fadeOut(duration):
	self.visible=true
	
	#tween.interpolate_property(colorRect,"color",Color(0,0,0,0),fadeOutColor,duration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	tween.start_interpolate_property(colorRect,"color",Color(0,0,0,0),fadeOutColor,duration)
	#tween.start()