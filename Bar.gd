extends Control

const GLOBALS = preload("res://Globals.gd")
export (float) var hpLossTimeout = 1.25 # 2 seconds
export (float) var hpAnimationDuration = 0.75 # 2 seconds

export (float) var barAnimationSpeed=0.1
export (float) var barAnimationAcceleration=5

const frameTimerResource = preload("res://frameTimer.gd")
var timer = null
var redHPAmount=10000000

var hpLabel = null

var maxHP=1850
var halfMaxHP = 1850.0/2.0

var forceDisplayHPLabel = false
func setAmount(amount):
	setHP(amount)
	#textureProgress.value = amount
	#amountLabel.text = str(int(amount))
	
#func setMaximum(amount):
#	textureProgress.max_value = amount
#	underTextureProgress.max_value = amount
	
func setUnderBarAmount(amount):	
	#multiProgressBar.setUnderBarAmount(amount)
	setHPLoss(amount)
	
func setUnderBarAmountWithTimeout(amount):
	#underTextureProgress.value = amount
	#multiProgressBar.setUnderBarAmountWithTimeout(amount)
	setHPLoss(amount)
	#yield(get_tree().create_timer(hpLossTimeout),"timeout")
	timer.startInSeconds(hpLossTimeout)
	yield(timer,"timeout")

	setHPLoss(hpTextureProgress.value)
	#setHPLoss(hpTextureProgress2.value)
	
	
func setUnderBarToMaximumAmount():
	#setUnderBarAmount(underTextureProgress.max_value)
	setUnderBarAmount(hpTextureProgress.max_value)
	setUnderBarAmount(hpTextureProgress2.max_value)
	
##above is legacy code
#below is revamped version of hp bar



var hpTextureProgress = null
var hpLossTextureProgress = null
var hpTextureProgress2 = null
var hpLossTextureProgress2 = null



export (Texture) var backgroundTexture = null
export (Texture) var hpTexture = null
export (Texture) var hpLossTexture = null
export (Texture) var hpForegroundTexture = null


var capacity =0



var newDamageBar = null

var newBarTextures = []

const MyTweenResource = preload("res://MyTween.gd")
var barAnimatorTween = null

func _ready():
	maxHP=1850
	# Called when the node is added to the scene for the first time.
	# Initialization here
	timer = frameTimerResource.new()

	add_child(timer)
	hpTextureProgress = $hpbar1/hpTextureProgress
	hpTextureProgress2 = $hpbar2/hpTextureProgress2#2nd half of hp bar

	#hidden by default
	hpLabel = $hpLabel
	hpLabel.visible = false
	
	#hpTextureProgress.rect_position.y += amountBarShiftYOffset
	hpTextureProgress.texture_over=hpForegroundTexture
	hpTextureProgress.texture_progress = hpTexture
	hpTextureProgress2.texture_progress = hpTexture
	hpTextureProgress2.texture_over = hpForegroundTexture
	
	hpLossTextureProgress = $hpbar1/hpLossTextureProgress
	
	hpLossTextureProgress2 = $hpbar2/hpLossTextureProgress2
	
	hpLossTextureProgress.texture_progress = hpLossTexture
	hpLossTextureProgress.texture_under = backgroundTexture
	hpLossTextureProgress2.texture_progress = hpLossTexture
	hpLossTextureProgress2.texture_under = backgroundTexture
	
	#hpLossTextureProgress.modulate = Color(1,1,1,transparancy)
	
	barAnimatorTween = MyTweenResource.new()
	add_child(barAnimatorTween)
	
	
	barAnimatorTween.speed = barAnimationSpeed
	barAnimatorTween.acceleration=barAnimationAcceleration
	barAnimatorTween.maxSpeed=100
	barAnimatorTween.minSpeed=0
	barAnimatorTween.ignoreHitFreeze=false

	pass

func animateHPLossBar(finalValue):
		
	#barAnimatorTween.start_interpolate_property(underBar,"value",underBar.value,mainBar.value,2)
	barAnimatorTween.start_interpolate_method(self,"setHPLoss",redHPAmount,finalValue,hpAnimationDuration)
		
func setMax(newMax):
	if hpTextureProgress == null:
		return
	

	hpTextureProgress.max_value = newMax
	hpLossTextureProgress.max_value = newMax
	
	hpTextureProgress.min_value = newMax/2.0
	hpLossTextureProgress.min_value = newMax/2.0
	
	#2nd hp bar starts when first one is drained
	hpTextureProgress2.max_value = newMax/2.0
	hpLossTextureProgress2.max_value = newMax/2.0
	#maxDamageGauge = newMax
	maxHP=newMax
	halfMaxHP = maxHP/2.0
	
#func getMax():
#	return maxDamageGauge
	
func setHPLoss(amount): 
	var oldAmount = capacity
	capacity = amount
	#var oldAmount = hpLossTextureProgress.value
	redHPAmount=amount
	hpLossTextureProgress.value = amount 
	hpLossTextureProgress2.value = amount 
	
func getHP():
	
	if hpTextureProgress.value > hpTextureProgress.min_value:
		
		return hpTextureProgress.value
	else:
		return hpTextureProgress2.value
	
func setHP(amount):
	
	#if amount < hpTextureProgress.min_value:
	#	hpTextureProgress.modulate.a = 0.4
	#	hpLossTextureProgress.modulate.a = 0.4
	#else:
	#	hpLossTextureProgress.modulate.a = 1
	#	hpTextureProgress.modulate.a = 1
	
	#if amount > hpTextureProgress2.max_value:
	#	hpTextureProgress2.modulate.a = 0.4
	#	hpLossTextureProgress2.modulate.a = 0.4
	#else:
	#	hpLossTextureProgress2.modulate.a = 1
	#	hpTextureProgress2.modulate.a = 1
	
	if amount < hpTextureProgress.min_value:
		#first hp bar ran out
		#check if should move below otherone
		#if get_child(0) == hpLossTextureProgress:
			$hpbar2.z_index = -1
			$hpbar1.z_index = -2
			#move_child(hpTextureProgress2,3)
			#move_child(hpLossTextureProgress2,2)	
			#move_child(hpTextureProgress,1)
			#move_child(hpLossTextureProgress,0)
			
	else:
		$hpbar2.z_index = -2
		$hpbar1.z_index = -1
			
	#display the hp label when under 100 hp
	if amount < GLOBALS.DISPLAY_HP_LABEL_THRESHOLD or forceDisplayHPLabel:
		hpLabel.visible = true
		hpLabel.text = str(int(ceil(amount)))
	else:
		hpLabel.visible = false
		
	
	#var oldAmount = hpTextureProgress.value
	hpTextureProgress.value = amount
	hpTextureProgress2.value = amount
	
	#tint_progress
	#color the progress bar tint based on total health
	
	var red=0
	var green=0
	var blue=0
	#bar starts full green (0,255,0), then goes yellow to (255,255,0), then goes orange to (255,72,0) after half
	if amount >  halfMaxHP:
		red = 1 - range_lerp(amount, halfMaxHP,maxHP, 0,1)
		green=1
		blue = 0
	else:
		red = 1
		blue =0
		#green  = range_lerp(amount, 0,halfMaxHP, 0.28,1)
		green  = range_lerp(amount, 0,halfMaxHP, 0,1)
		

	hpTextureProgress.tint_progress = Color(red,green,blue)
	#hpTextureProgress.tint_progress.r = red
	#hpTextureProgress.tint_progress.g = green
	#hpTextureProgress.tint_progress.b = blue
	hpTextureProgress2.tint_progress = Color(red,green,blue)
	#hpTextureProgress2.tint_progress.r = red
	#hpTextureProgress2.tint_progress.g = green
	#hpTextureProgress2.tint_progress.b = blue
	
	

func setMaximum(amount):
	#hpTextureProgress.max_value = amount
	#hpLossTextureProgress.max_value = amount
	
	hpTextureProgress.max_value = amount
	hpLossTextureProgress.max_value = amount
	
	hpTextureProgress.min_value = amount/2.0
	hpLossTextureProgress.min_value = amount/2.0
	
	#2nd hp bar starts when first one is drained
	hpTextureProgress2.max_value = amount/2.0
	hpLossTextureProgress2.max_value = amount/2.0
	
	#maxDamageGauge = newMax
	maxHP=amount
	halfMaxHP = maxHP/2.0
	
	
func setFillRightToLeft():
	hpTextureProgress.fill_mode= hpTextureProgress.FILL_RIGHT_TO_LEFT
	hpLossTextureProgress.fill_mode= hpTextureProgress.FILL_RIGHT_TO_LEFT
	hpTextureProgress2.fill_mode= hpTextureProgress.FILL_RIGHT_TO_LEFT
	hpLossTextureProgress2.fill_mode= hpTextureProgress.FILL_RIGHT_TO_LEFT
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func forceHPLabelDisplay(amountToDisplay):
	forceDisplayHPLabel=true
	hpLabel.visible = true
	hpLabel.text =amountToDisplay
	pass