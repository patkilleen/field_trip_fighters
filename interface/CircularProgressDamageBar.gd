extends TextureProgress

signal changed_visibility
signal circular_progress_newly_activated

var pro = 0
var GLOBALS = preload("res://Globals.gd")

const DEAFULT_NEXT_HIT_DMG_AMOUNT = 0
#for now, default is damage. extern scripts will need to
#change logic of default amount if focus and damage ever don't start same default value
var intialDmgAmount = GLOBALS.DEFAULT_FOCUS_AMOUNT
var currDmgAmount = GLOBALS.DEFAULT_FOCUS_AMOUNT
var targetDmgAmount = GLOBALS.DEFAULT_FOCUS_AMOUNT

#not sure how to set this default value without adding huge coupling/reducing modularity
var nextHitDmgAmount = DEAFULT_NEXT_HIT_DMG_AMOUNT

var delayedMakeInvisibleFlag = false

var  completionDisplayedFlag = false

var activeFlag = false

var hideTimer = null
var frameTimerResource = preload("res://frameTimer.gd")

var nextIncreaseProgressCirc = null

var newlyActivatedFlag = false


var defaultColor = null
var targetTransparentColor= null
func _ready():
	
	set_visible(false)
	#self.visible = false
	hideTimer = frameTimerResource.new()
	add_child(hideTimer)
	hideTimer.connect("timeout",self,"_on_hide_timeout")
	
	createNextIncreaseBar()
	
	defaultColor = self.modulate
	targetTransparentColor = defaultColor
	targetTransparentColor.a =0.4# 60% (100-40) transparent
	
	pass

func createNextIncreaseBar():
	#identical to this progress circle, but will make trasnparent
	nextIncreaseProgressCirc = TextureProgress.new()
	nextIncreaseProgressCirc.texture_progress=self.texture_progress
	nextIncreaseProgressCirc.fill_mode=self.fill_mode
	nextIncreaseProgressCirc.min_value = self.min_value
	nextIncreaseProgressCirc.max_value = self.max_value
	var defaultColor = nextIncreaseProgressCirc.modulate
	defaultColor.a=0.5
	nextIncreaseProgressCirc.modulate = defaultColor
	nextIncreaseProgressCirc.value = 0
	add_child(nextIncreaseProgressCirc)
	
func resetInitialValues():
	pro = 0
	set_visible(false)
	#self.visible = false
	#intialDmgAmount = 0 #when we activate
	#currDmgAmount = 0
	#targetDmgAmount = 0 #capacity

#for now, default is damage. extern scripts will need to
#change logic of default amount if focus and damage ever don't start same default value
	
	#set to minimum value of the bar
	intialDmgAmount = GLOBALS.DEFAULT_FOCUS_AMOUNT #when we activate
	currDmgAmount = GLOBALS.DEFAULT_FOCUS_AMOUNT
	targetDmgAmount = GLOBALS.DEFAULT_FOCUS_AMOUNT #capacity
	nextHitDmgAmount = DEAFULT_NEXT_HIT_DMG_AMOUNT
	
	delayedMakeInvisibleFlag = false

	completionDisplayedFlag = false
	newlyActivatedFlag=false
	activeFlag = false
	
	if hideTimer != null:
		hideTimer.stop()
		
	updateProgess()
func activate(amount,capacity,nextHitAmount):
	#self.visible = true
	#delayedMakeInvisibleFlag=false
	if not activeFlag:
		_on_newly_activate()
	completionDisplayedFlag=false
	activeFlag = true
	intialDmgAmount=amount
	currDmgAmount=amount
	targetDmgAmount=capacity
	nextHitDmgAmount = nextHitAmount
	#completionDisplayedFlag=false
	updateProgess()

func setCapacity(c):
	
	var oldCap = targetDmgAmount
	
	targetDmgAmount = c
	
	#capacity increased?
	if oldCap < c:
		
		#don't monitor if we got riposted or game restarted, and we don't have any
		#capacity
		
		if targetDmgAmount > 1:
			#restart the monitoring, can now increase damage to acheive capacity
			reactivate()
	elif oldCap > c: #recuded capaicty?
	
		#lower amount accordingly with capacity
		if intialDmgAmount > targetDmgAmount:
			intialDmgAmount = targetDmgAmount
			#delayedMakeInvisibleFlag = true #capacity lowered to point we don't increase anymore, so disapear
		if currDmgAmount > targetDmgAmount:
			currDmgAmount=targetDmgAmount
			#i think this works, but will have to think about it
			nextHitDmgAmount=currDmgAmount
			
			
		
	updateProgess()
	
func updateProgess():
	
	#var divider = targetDmgAmount-intialDmgAmount
	#  avoid division by 0
	#if divider == 0:
	#	return
	#var completionPercent = (currDmgAmount-intialDmgAmount)/(divider)
	
	#completionPercent = completionPercent*100 #multi by 100 to be same scale as the process bar
	
	#get the percentage complete of amount progress
	var completionPercent =  getCompletionPercent(currDmgAmount)
	
	if completionPercent==null:
		return
		
	#set the circular progress bar
	if currDmgAmount >= targetDmgAmount:
		self.value = self.max_value
	else:	
		self.value = completionPercent
	
	#get percentage of complete of the next hit amount progress
	var nextHitCompletionPercent =  getCompletionPercent(nextHitDmgAmount)
	
	if nextHitCompletionPercent==null:
		return
	
	#set the transparent next hit circular progress to show how much will increase
	#the actual progress bar next hit
	if nextHitDmgAmount >= targetDmgAmount:
		nextIncreaseProgressCirc.value = nextIncreaseProgressCirc.max_value
	else:	
		nextIncreaseProgressCirc.value = nextHitCompletionPercent
	
	
func getCompletionPercent(_dmgAmount):
	
	var divider = targetDmgAmount-intialDmgAmount
	#  avoid division by 0
	if divider == 0:
		return null
	var completionPercent = (_dmgAmount-intialDmgAmount)/(divider)
	completionPercent = completionPercent*100 #multi by 100 to be same scale as the process bar
	
	return completionPercent
		
func _on_hitstun_changed(flag):
	
	#no hitstun?
#	if flag == false:
#		_on_combo_finished()
#	else:
#		_on_combo_hit()
	pass
		
func _on_combo_finished():

	pass
func _on_combo_panel_hidden():

	return
	
	pass
	#if newlyActivatedFlag:
	#	newlyActivatedFlag=false
	#	emit_signal("circular_progress_newly_activated")
			
#	if activeFlag:
#		#did we fill bar completly?
#		if isComplete():
#			#in this case player saw the bar fill
#			completionDisplayedFlag = true
#			activeFlag = false
			
#			hideAfterTimeout()
			
#		else:
#			completionDisplayedFlag = false
	
#			set_visible(true)
#			hideTimer.stop()
#	
	
func hideAfterTimeout():
	
	hideTimer.startInSeconds(1)
	
func _on_hide_timeout():
	set_visible(false)
	#self.visible = false
			
#called first time combo panel displaye
func _on_combo_panel_displayed():

	return

#	newlyActivatedFlag=false
		
#	if activeFlag and not completionDisplayedFlag:
		#reached goal, dont display?
		#potential to increase progess
		#self.visible = true
#		set_visible(true)
#		hideTimer.stop()
#	else:
#		#self.visible = false
#		set_visible(false)
		
		
#the combo counter tracking the proration of recourse increase change
func _on_increase_resource_combo_change(from,to):
	
	#this is handled by BarCapcityAmountCombHandler.gd i think
	pass
	#here, the combo restarted, so re re-begin the tracking of resoruce incrase
	#since player messed up a combo (combo level up strings reset the increase rate progress)
	#if to == 0:
	#	reset()
#resets the progress bar
func reset():
	
	#don't reset the progrees in circular, although
	#the rate of increase will be reset (handled by combo handler)
	#intialDmgAmount = currDmgAmount
	updateProgess()

func _on_capacityReached():
	#delayedMakeInvisibleFlag=true
	pass
	
func disable():
	set_visible(false)
	#self.visible = false
	#self.value = 0
	#intialDmgAmount = 0 #when we activate
	#currDmgAmount = 0
	#targetDmgAmount = 0 #capacity
#func setAmount(amount):
	
#	var oldAmount = self.value
	
	#done updating?
#	if oldAmount != amount and _on_dmg_amount_changed(amount):
#		pass
#	else:
#		if amount < oldAmount:
			#the damage gauage has gone down. start tracking it again
#			activate(amount,targetDmgAmount)


#updates the circle progress, and resturns true when done (false otherwise)
func setAmount(newAmount):
	var oldAmount = currDmgAmount
	currDmgAmount = newAmount
	
	#in the case where amount was a reduction, restart tracking the progress
	if oldAmount > currDmgAmount:
		
		#don't track if the amount is equal to capacity 
		#(e.g., maybe are damage cap and amount were both reduce equally, when
		#they were previously maxed)
		if currDmgAmount < targetDmgAmount:
			reactivate()
	elif newAmount >= targetDmgAmount: 
		#we acheive the goal, hide progress once hitstun stops
		currDmgAmount = min (newAmount, targetDmgAmount)
		#delayedMakeInvisibleFlag=true
		#no longer want to reset upon 
		#delayedMakeInvisibleFlag = false
	
	#if abs(newAmount - targetDmgAmount) <= 0.0001:
		
	#	self.visible = false	
#		return true
#	else:
	updateProgess()	
	
#	return false#should be called before setting amount, since this won't update the p
func setNextHitAmount(newAmount):
	
	
	var oldAmount = nextHitDmgAmount
	nextHitDmgAmount = newAmount
	
	if newAmount >= targetDmgAmount: 
		#next hit we acheive the goal, so cap the nexthit amount to max
		nextHitDmgAmount = min (newAmount, targetDmgAmount)
	
	updateProgess()	
	
#	

#restart tracking the increase with current value
func reactivate():
	activate(currDmgAmount,targetDmgAmount,nextHitDmgAmount)
	
func isComplete():
	return currDmgAmount == targetDmgAmount
	
	
#true when cover up, false when show without cover up
func setTransparancy(transparentFlag):
	
	if transparentFlag:
		#make transparent
		self.modulate=targetTransparentColor
	
	else:
		#make non-transparent
		self.modulate = defaultColor
	#$TextureRect.visible = transparentFlag

	
func set_visible(flag):
	var oldFlag = visible
	.set_visible(flag)
	
	if flag != oldFlag:
		emit_signal("changed_visibility",flag)
		

#called to indicate how much the next hit's increase will be	
#func _on_next_hit_amount_increase():
	
#nextIncreaseProgressCirc

func _on_combo_level_changed(lvl):
	
	#increased combo level (as opposed to reseting it)?
	if lvl != 0:
		#make the progress disappear, since we can't increase it after a level up
		set_visible(false)

#called when wasn't active and then activated
func _on_newly_activate():
	
	return 
	#newlyActivatedFlag = true
	#required for start of match 
	#set_visible(true) 
	