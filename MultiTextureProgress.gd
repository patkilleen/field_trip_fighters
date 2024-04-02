extends Control

signal bar_animation_finished
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (float) var underBarDuration = 2
export (float) var underBarBlinkFrequency = 0.4
export (float) var barAnimationSpeed=0.1
export (float) var barAnimationAcceleration=5

export (Texture) var mainProgressTexture = null setget setMainTexture,getMainTexture
export (Texture) var underProgressTexture = null setget setUnderTexture,getUnderTexture
export (Texture) var backgroundProgressTexture = null setget setBackgroundTexture,getBackgroundTexture
export (Texture) var foregroundProgressTexture = null setget setForegroundTexture,getForegroundTexture

const frameTimerResource = preload("res://frameTimer.gd")
const MyTweenResource = preload("res://MyTween.gd")
var barAnimatorTween = null

var mainBar = null
var underBar = null

var timer = null

var blinkTimer = null

var oldUnderBarAmount = 0


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	mainBar = $mainBar
	underBar = $underBar
	mainBar.texture_over =foregroundProgressTexture
	mainBar.texture_progress = mainProgressTexture
	underBar.texture_under = backgroundProgressTexture
	underBar.texture_progress = underProgressTexture
	
	timer = frameTimerResource.new()
	blinkTimer= frameTimerResource.new()
	#timer.one_shot = true #set to true to indicate don't conitune ticking (only executed once called)
	#blinkTimer.one_shot = false
	timer.connect("timeout",self,"_on_under_bar_time_expired")
	blinkTimer.connect("timeout",self,"_under_bar_blink")
	self.add_child(timer)
	self.add_child(blinkTimer)
	
	
	barAnimatorTween = MyTweenResource.new()
	add_child(barAnimatorTween)
	barAnimatorTween.connect("finished",self,"_on_bar_animation_finished")
	
	barAnimatorTween.speed = barAnimationSpeed
	barAnimatorTween.acceleration=barAnimationAcceleration
	barAnimatorTween.maxSpeed=100
	barAnimatorTween.minSpeed=0
	barAnimatorTween.ignoreHitFreeze=false


func setMainTexture(t):
	
	mainProgressTexture =  t
	
	if mainBar !=null:
		mainBar.texture_progress = t
func getMainTexture():
	return mainProgressTexture
	
func setUnderTexture(t):
	underProgressTexture = t
	if underBar != null:
		underBar.texture_progress = t

func getUnderTexture():
	return underProgressTexture
	
func setBackgroundTexture(t):
	backgroundProgressTexture=t
	if underBar != null:
		underBar.texture_under = t
	
func getBackgroundTexture():
	return backgroundProgressTexture
	
func setForegroundTexture(t):
	foregroundProgressTexture = t
	if mainBar != null:
		mainBar.texture_over =t
func getForegroundTexture():
	return foregroundProgressTexture

func setMin(m):
	mainBar.min_value = m
	underBar.min_value = m
	
func setMax(m):
	mainBar.max_value = m
	underBar.max_value = m
	
func setScale(s):
	mainBar.set_scale(s)	
	underBar.set_scale(s)
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func setAmount(amount):
	
	mainBar.value = amount
	
func getAmount():
	return mainBar.value 
	
func setUnderBarAmount(amount):
	
	stopBarAnimation()
	underBar.value = amount
	
func setUnderBarAmountWithTimeout(amount):
	
	if underBar.value == 0 and amount == 0:
		return
	
	stopBarAnimation()
	
	clearUnderBar()
	
	underBar.value = amount
	#timer.stop()
	#timer.wait_time = underBarDuration
	timer.startInSeconds(underBarDuration)
	
	#blinkTimer.stop()
	
	#make it blink for the duration until it disaperas
	#blinkTimer.wait_time= underBarBlinkFrequency
	blinkTimer.startInSeconds(underBarBlinkFrequency)

func setUnderBarAmountWithTimeoutNoBlink(amount,cutomDuration = null):
	
	if underBar.value == 0 and amount == 0:
		return
		
	clearUnderBar()
	
	underBar.value = amount
	#timer.stop()
	 
	if cutomDuration == null:
		timer.start(underBarDuration)
	else:
		timer.start(cutomDuration)
	
	
	
func clearUnderBar():
	stopBarAnimation()
	underBar.value = 0
	
	blinkTimer.stop()
	timer.stop()
func _on_under_bar_time_expired():
	clearUnderBar()
	
	
func stopBarAnimation():
	var wasAnimationRunning = barAnimatorTween.running
	barAnimatorTween.stop()
	
	if wasAnimationRunning:
		emit_signal("bar_animation_finished")
	
func animateBar(bar,initialValue,finalValue,duration):
		
	#barAnimatorTween.start_interpolate_property(underBar,"value",underBar.value,mainBar.value,2)
	barAnimatorTween.start_interpolate_property(bar,"value",initialValue,finalValue,duration)
	
func _under_bar_blink():
	stopBarAnimation()
	if underBar.value == 0:
		underBar.value = oldUnderBarAmount
	else:
		oldUnderBarAmount =  underBar.value
		underBar.value = 0
		
		
		
func _on_bar_animation_finished():
	emit_signal("bar_animation_finished")