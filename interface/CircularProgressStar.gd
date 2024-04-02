extends TextureProgress


const ONE_THIRD_FILL = 100.0/3.0 #33%

export (Texture) var firstButtonTexture = null
export (Texture) var secondButtonTexture = null
export (Texture) var thirdButtonTexture = null

#the filling aniamtion duratin in secondds
var animationDuration = 0.25
var particles = null
var textRectX= null
var textRectY= null
var textRectB= null
var textRectXTransparent= null
var textRectYTransparent= null
var textRectBTransparent= null

#tween for animating the star filling
var fillTween = null
const MyTweenResource = preload("res://MyTween.gd")

func _ready():
	
	textRectX = $TextureRect_X
	textRectY = $TextureRect_Y
	textRectB = $TextureRect_B
	textRectXTransparent = $TextureRect_X_transparent
	textRectYTransparent = $TextureRect_Y_transparent
	textRectBTransparent = $TextureRect_B_transparent
	
	setButtonTextures(firstButtonTexture,secondButtonTexture,thirdButtonTexture)
	
	textRectXTransparent.modulate = Color(1,1,1,0.4)
	textRectYTransparent.modulate = Color(1,1,1,0.4)
	textRectBTransparent.modulate = Color(1,1,1,0.4)
	
	fillTween = MyTweenResource.new()
	self.add_child(fillTween)
	
	particles = $Particles2D
	
func setButtonTextures(_firstButtonTexture,_secondButtonTexture,_thirdButtonTexture):
	firstButtonTexture = _firstButtonTexture
	secondButtonTexture = _secondButtonTexture
	thirdButtonTexture = _thirdButtonTexture
	
	textRectX.texture = firstButtonTexture
	textRectY.texture = secondButtonTexture
	textRectB.texture = thirdButtonTexture
	
	textRectXTransparent.texture = firstButtonTexture
	textRectYTransparent.texture = secondButtonTexture
	textRectBTransparent.texture = thirdButtonTexture
	
	
func resetProgress():
	set_value(min_value)
	textRectX.visible = true
	textRectXTransparent.visible = false
	textRectY.visible = false
	textRectYTransparent.visible = true
	textRectB.visible = false
	textRectBTransparent.visible = true
func fillPart1():
	animated_set_value(ONE_THIRD_FILL)
	
	textRectX.visible = true
	textRectXTransparent.visible = false
	textRectY.visible = true
	textRectYTransparent.visible = false
	textRectB.visible = false
	textRectBTransparent.visible = true

func fillPart2():
	animated_set_value(2*ONE_THIRD_FILL)
	
	textRectX.visible = true
	textRectXTransparent.visible = false
	textRectY.visible = true
	textRectYTransparent.visible = false
	textRectB.visible = true
	textRectBTransparent.visible = false
	
func fillCompletly():
	animated_set_value(max_value)
	textRectX.visible = true
	textRectXTransparent.visible = false
	textRectY.visible = true
	textRectYTransparent.visible = false
	textRectB.visible = true
	textRectBTransparent.visible = false
	

#animates setting value
func animated_set_value(_value):
	
	#target value equal max?
	if _value >= max_value: 
		particles.emitting = true
	else:
		particles.emitting = false
		
	fillTween.stop()
	
	var fromValue = null
	#value to animate towards
	var targetValue = null
	#were trying to set to one thirds?
	if _value == ONE_THIRD_FILL:
		
		#reset to 0 and animate back to 1/3 to give feedback even if setting same fill amount
		targetValue=_value
		fromValue = 0
	else:
		
		#animate from current value
		targetValue=_value
		fromValue = value
		
	value = fromValue
	#fillTween.interpolate_property(self,"value",fromValue,targetValue,animationDuration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	fillTween.start_interpolate_property(self,"value",fromValue,targetValue,animationDuration)
	#fillTween.start()


func hideButtonSprites():
	textRectX.visible = false
	textRectXTransparent.visible = false
	textRectY.visible = false
	textRectYTransparent.visible = false
	textRectB.visible = false
	textRectBTransparent.visible = false