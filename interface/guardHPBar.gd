extends "res://TriTextureProgress.gd"


export (bool) var player1 = true
export (float) var guardLossRedDuration = 2 #2 seconds
export (float) var guardLossAnimationDuration = 0.75
export (float) var step = 0.2 setget setStep,getStep
export (float) var guardBreakRegenAnimationDuration = 2.5 #1.5 second
var guardRegenerationEnabled = true

var guardAmount = 0
var guardLossAnimationPlaying = false

var guardRegenBuffBar = null

var guardBreakRefillTween=null



var guardBreakRegenBar=null
var guardBreakRegenUnderBar=null
var guardBreakRegenBGDBar=null
func _ready():

	guardBreakRefillTween = $myTween
	
	guardBreakRefillTween.connect("finished",self,"_on_guard_break_refill_tween_finished")
	
	guardBreakRegenBar = $guardBreakRegBar
	guardBreakRegenUnderBar = $guardBreakRegUnderBar
	guardBreakRegenBGDBar = $guardBreakRegBGDBar
	
	guardRegenBuffBar =$guardRegenBuffBar
	
	setFillType(guardRegenBuffBar)
	setFillType(mainBar)
	setFillType(underBar)
	setFillType(middleBar)
	setFillType(guardBreakRegenBar)
	setFillType(guardBreakRegenUnderBar)
	setFillType(guardBreakRegenBGDBar)
	
	guardRegenBuffBar.texture_progress = mainBar.texture_progress
	
	guardBreakRegenUnderBar.visible = false
	guardBreakRegenBar.visible = false
	guardBreakRegenBGDBar.visible = false
	connect("bar_animation_finished",self,"_on_guard_loss_animation_finished")
	
	guardRegenBuffBar.value=0
	setUnderBarAmount(0)
	setMiddleBarAmount(0)
	setStep(step)
	
	$barRef.visible = false
	

func setMin(m):
	.setMin(m)
	guardBreakRegenBar.min_value = m
	guardBreakRegenUnderBar.min_value = m
	guardBreakRegenBGDBar.min_value=m
	
func setMax(m):
	.setMax(m)
	guardBreakRegenBar.max_value = m
	guardBreakRegenUnderBar.max_value = m
	guardBreakRegenBGDBar.max_value=m
	
func guardSetAmount(old,new):
	guardAmount=new
	#did we lose guard hp?
	if new < old:
		#make sure to display the red for a moment to
		#show how much was lost
			#_on_under_bar_time_expired()
			
			#first tiem animating guard loss?
			#or its already playing, but the loss bar might be under the gaurd bar (it reached it)
			if (not guardLossAnimationPlaying) or (underBar.value < old):
			#if (not guardLossAnimationPlaying):
				guardLossAnimationPlaying=true
				underBar.value = old
				barAnimatorTween.stop()
				#clearUnderBar()
				
				#timer.wait_time = guardLossRedDuration
				timer.startInSeconds(guardLossRedDuration)
	
	updateMainBar()
	
	
func setStep(_step):
	
	if underBar != null:
		
		underBar.step=_step
		
	if mainBar != null:
		mainBar.step=_step
	step = _step
func getStep():
	return step
func setFillType(bar):
	if player1:
		bar.fill_mode= bar.FILL_RIGHT_TO_LEFT
	else:
		bar.fill_mode= bar.FILL_LEFT_TO_RIGHT
		
		
		
func _on_guard_regen_lock_changed(flag):
	guardRegenerationEnabled = flag
	
	updateMainBar()
	
func updateMainBar():
	if not guardRegenerationEnabled:
		#display the locked version of guard bar to indicate no regen at the moment
		setMiddleBarAmount(guardAmount)
		setAmount(0)
	else:
		#display the regulard version of guard bar to indicate regen occuring
		setMiddleBarAmount(0)
		setAmount(guardAmount)
	

func _on_guard_loss_animation_finished():
	guardLossAnimationPlaying=false
	
func _on_under_bar_time_expired():
	#clearUnderBar()
	
	animateBar(underBar,underBar.value,0,guardLossAnimationDuration)


func startGuardBreakRefillAnimation(targetAmount):
	
	mainBar.visible=false
	underBar.visible=false
	guardBreakRegenBar.visible = true
	guardBreakRegenUnderBar.visible = true	
	guardBreakRegenBGDBar.visible=true
	guardBreakRegenUnderBar.value = targetAmount*1.05 # multiply by 5% more cause guard is regenening  in while bar is animating
	
	guardBreakRefillTween.start_interpolate_property(guardBreakRegenBar,"value",0,targetAmount*1.05,guardBreakRegenAnimationDuration)
	#guardBreakRegenBar.value = 25

func _on_guard_break_refill_tween_finished():
	stopGuardBreakRefillAnimation()
	
func stopGuardBreakRefillAnimation():
	
	guardBreakRegenUnderBar.visible = false
	guardBreakRegenBGDBar.visible=false
	guardBreakRegenBar.visible = false
	guardBreakRefillTween.stop()
	
	mainBar.visible=true
	underBar.visible=true
	
	
	