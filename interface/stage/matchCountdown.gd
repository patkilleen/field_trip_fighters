extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const frameTimerResource = preload("res://frameTimer.gd")

const OUTLINE_COLOR_PROPERTY = "outline_color"
const COLOR_PROPERTY = "custom_colors/font_color"
const FONT_PROPERTY = "custom_fonts/font"
export (float) var transparencyAnimationDelay = 0.5
export (float) var transparencyAnimationDuration = 0.5

export (float) var growAnimationDelay = 0.1
export (float) var growAnimationDuration = 0.6

export (float) var ungrowAnimationDuration = 0.2

export (float) var growAnimationFontSizeIncrease = 60
export (Vector2) var growAnimationScaleIncrease = Vector2(1.2,1.2)
export (float) var ungrowAnimationFontSizeDecrease = 40
export (Vector2) var ungrowAnimationScaleDecrease = Vector2(0.8,0.8)

var sizeTween = null
var transparencyTween = null

var defaultFontSize = null
var defaultSize = null
var defaultColor = null
var defaultOutlineColor = null
var targetTransparentColor = null
#var targetTransparentOutlineColor = null

var transparencyDelayTimer = null
var growTimer = null
const MyTweenResource = preload("res://MyTween.gd")
func _ready():
	
		
		#ripostSlowMotionTween.connect("tween_completed",self,"_on_slow_down_game_complete",[ripostSlowMotionTween,startingGlobalSpeed,speedupDuration],CONNECT_ONESHOT)
		#ripostSlowMotionTween.interpolate_method(self,"changeGlobalSpeedMod",startingGlobalSpeed,endingGlobalSpeed,slowDownDuration,Tween.TRANS_QUAD,Tween.EASE_OUT)
		#ripostSlowMotionTween.start()
		
		#want to make sure not to change the default values of font resource 
		#so make deep copy
	#var font = self.get(FONT_PROPERTY)
	#set(FONT_PROPERTY,font.duplicate(true))
	pass

func init():
	if sizeTween == null:
		sizeTween = MyTweenResource.new()
		self.add_child(sizeTween)
	if transparencyTween == null:
		transparencyTween = MyTweenResource.new()
		self.add_child(transparencyTween)
	
	growTimer= frameTimerResource.new()
	transparencyDelayTimer = frameTimerResource.new()
	
	add_child(transparencyDelayTimer)
	add_child(growTimer)
	
	if defaultColor == null:
		#defaultColor = self.get(COLOR_PROPERTY)
		defaultColor = self.modulate
		
	
	#double get sinze the outline color is the font's property, not lable's property
	
	#if defaultOutlineColor == null:
		#defaultOutlineColor = self.get(FONT_PROPERTY).get(OUTLINE_COLOR_PROPERTY)
	
	#if defaultFontSize == null:
		#defaultFontSize = self.get(FONT_PROPERTY).size
	
	if defaultSize == null:
		defaultSize = rect_size
		
	if targetTransparentColor == null:
		targetTransparentColor = defaultColor
		targetTransparentColor.a = 0 #transparent default color
	#if targetTransparentOutlineColor == null:
		#targetTransparentOutlineColor = defaultOutlineColor
		#targetTransparentOutlineColor.a = 0 #transparent default color
		
	setDefaultValues()
func activateWithoutAnimation(text):
	setDefaultValues()
	self.visible = true
	self.text = text
	
	#setDefaultValues()
func setDefaultValues():
	#self.set(COLOR_PROPERTY,defaultColor)
	self.modulate = defaultColor
	
	#self.get(FONT_PROPERTY).set(OUTLINE_COLOR_PROPERTY,defaultOutlineColor)
		
	#var myfont = self.get(FONT_PROPERTY)
	#myfont.size = defaultFontSize
	rect_size = defaultSize 
func activateAnimation(text):
	
	activateWithoutAnimation(text)
	startTransparencyAnimation()
	#startSizeAnimation()

func startTransparencyAnimation():
	
	transparencyTween.stop()
	#transparencyTween.stop(get(FONT_PROPERTY))
	#self.set("custom_colors/font_color",defaultColor)
	
	self.modulate = defaultColor
	#wait a delay
	#yield(get_tree().create_timer(transparencyAnimationDelay),"timeout")
	
	transparencyDelayTimer.startInSeconds(transparencyAnimationDelay)
	yield(transparencyDelayTimer,"timeout")

	
	#"custom_colors/font_color"
	#fade both font color and font outline color to transparent
	#transparencyTween.interpolate_property(self,COLOR_PROPERTY,defaultColor,targetTransparentColor,transparencyAnimationDuration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	#transparencyTween.interpolate_property(self,"modulate",defaultColor,targetTransparentColor,transparencyAnimationDuration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	
	transparencyTween.start_interpolate_property(self,"modulate",defaultColor,targetTransparentColor,transparencyAnimationDuration)
	
	#transparencyTween.interpolate_property(get(FONT_PROPERTY),OUTLINE_COLOR_PROPERTY,defaultOutlineColor,targetTransparentOutlineColor,transparencyAnimationDuration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	#transparencyTween.start()

func startSizeAnimation():
	
	#var myfont = self.get(FONT_PROPERTY)
	#sizeTween.stop(myfont)
	sizeTween.stop()
	
	
#	myfont.size = defaultFontSize
	
	#wait a delay
	#yield(get_tree().create_timer(growAnimationDelay),"timeout")
	
	growTimer.startInSeconds(growAnimationDelay)
	yield(growTimer,"timeout")


	#var targetFontSize = growAnimationFontSizeIncrease + defaultFontSize
	var targetSize = growAnimationScaleIncrease*defaultSize
	
	#"custom_colors/font_color"
	#sizeTween.interpolate_property(myfont,"size",defaultFontSize,targetFontSize,growAnimationDuration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	#sizeTween.interpolate_property(self,"rect_size",defaultSize,targetSize,growAnimationDuration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	sizeTween.start_interpolate_property(self,"rect_size",defaultSize,targetSize,growAnimationDuration)
	#sizeTween.start()
	
	#wait for the grow to finish
	yield(sizeTween,"finished")
	
	#targetFontSize = myfont.size - ungrowAnimationFontSizeDecrease
	targetSize = defaultSize*ungrowAnimationScaleDecrease
	#"custom_colors/font_color"
	#sizeTween.interpolate_property(myfont,"size",myfont.size,targetFontSize,ungrowAnimationDuration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	#sizeTween.interpolate_property(self,"rect_size",rect_size,targetSize,ungrowAnimationDuration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	sizeTween.start_interpolate_property(self,"rect_size",rect_size,targetSize,ungrowAnimationDuration)
#	sizeTween.start()
	
	#now start the ungrow animation
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func hide():
	self.visible = false
	setDefaultValues()