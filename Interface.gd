extends Control

signal dmg_circular_progress_newly_activated
signal focus_circular_progress_newly_activated
var GLOBALS = preload("res://Globals.gd")
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (float) var hp = 1000 setget setHP,getHP
export (float) var damageGauge = 1 setget setDamageGauge,getDamageGauge
export (float) var damageGaugeCapacity = 1.05 setget setDamageGaugeCapacity,getDamageGaugeCapacity
export (float) var ability = 1000 setget setAbility,getAbility
export (float) var abilityChunkPadding = 10 setget setAbilityChunkPadding,getAbilityChunkPadding
export (int) var combo = 0 setget setCombo,getCombo
export (int) var maxCombo = 0 setget setMaxCombo,getMaxCombo
export (float) var comboDamage = 0 setget setComboDamage,getComboDamage

export (Color) var comboPanelBgdColor = Color("#1a000000")
export (String) var playerId = "P"
export (Color) var playerIdColor = Color(1,0,0)

const RED_HP_CLEAR_TIMEOUT_IN_SECONDS = 1.5 # seconds

var hpBar = null
var damageGaugeBar = null
var abilityBar = null
var stars = null
var subCombos = null
var blockIcon = null
#var antiBlockIcon = null
var comboNumLabel = null
var maxComboNumLabel = null
var comboDamageLabel = null
var cmdList = null
var ripostNotification = null
var counterRipostNotification = null
var comboPanel = null
var blockEfficiencyElem = null
var notifyciationPanel = null
var focusBar = null
var commandPairDisplay =null
var guardHPBar = null
var frameCounterBar = null
var anitCampingIcon = null
var trainingModeElements = null

var focus = 1
var focusCapacity = 1


var whistleHUD = null

var beltAngryHUD = null
var micRapHUD = null
var hatHUD = null
var micOperaHUD = null
var gloveActiveBallHUD= null
var gloveBrokenStringHUD=null
var playerTextId = null
 
var advProfIcon =null
var disProfIcon =null

var dmgProrationBar = null
var focusProrationBar = null
var redHPTimer =null

var prorationLabelLocked = true
var delayedSetRedHPLock = false
var delayedSetRedHPDisabled = false

var frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")

var circularDamageProgress=null
var circularFocusProgress=null

var frameDataLabel = null

#var hasGrabIcon = null
#var grabOnCooldownIcon = null

var heroStateInfo = null


var longestComboLabel = null
var comboLengthLabel = null
var comboDmgLabel = null
var bestComboDmgLabel = null

var ripostAbilityStatusHUD = null
var autoRipostAbilityStatusHUD = null
var counterRipostAbilityStatusHUD = null
var grabResourceHUD = null
var grabResourceHUD2ndCharge = null
var dmgProrationLabel = null
var hitstunProrationLabel= null
func _ready():
	pass
func init():
	hpBar = $HPBar
	notifyciationPanel = $NotificationPanel #impleneted in stage
	damageGaugeBar = $DamageBar #implemented in scene instancing this scene
	#focusBar = $FocusBar #implemented in scene instancing this scene
	abilityBar = $AbilityBar
	
	circularDamageProgress = $icon_notifiers/CircularDamageProgressBar
	circularFocusProgress = $icon_notifiers/CircularFocusProgressBar
	
	ripostAbilityStatusHUD = $ripostAbilityStatusHUD
	autoRipostAbilityStatusHUD = $autoRipostAbilityStatusHUD
	grabResourceHUD = $grabResourceHUD
	grabResourceHUD2ndCharge = $grabResourceHUD2ndCharge
	counterRipostAbilityStatusHUD = $counterRipostAbilityStatusHUD
	
	frameDataLabel = $"frame-data/data"
	
	advProfIcon =$proficiencies/advProficiencyIcon
	disProfIcon =$proficiencies/disProficiencyIcon

	circularDamageProgress.connect("circular_progress_newly_activated",self,"_on_dmg_circular_progress_newly_activated")
	circularFocusProgress.connect("circular_progress_newly_activated",self,"_on_focus_circular_progress_newly_activated")
	
	
	trainingModeElements= $"trainingModeElements"
	
	comboPanel = $"ComboPanel"
	comboPanel.bgdColor.color = comboPanelBgdColor
	dmgProrationBar = comboPanel.dmgProrationBar
	focusProrationBar = comboPanel.focusProrationBar
	
	comboDamageLabel = comboPanel.damageText
	subCombos = comboPanel.subCombos
	stars = comboPanel.stars
	blockIcon = $icon_notifiers/blockIcon
	#antiBlockIcon = $"icon_notifiers/anti-blockIcon"
	
	anitCampingIcon = $"negative-level-icon"
	
	frameCounterBar = $"trainingModeElements/FrameCounterBar"
	
	heroStateInfo = $heroStateInfo
	
	#hasGrabIcon = $"has-grab-icon"
	#grabOnCooldownIcon = $"no-grab-icon"

	#make sure no colldown icon displaeyd (starts with grab)
	#var offCooldown = true
	#_on_grab_cooldown_changed(offCooldown)
	
	guardHPBar = $guardHP
	commandPairDisplay = $CommandPairDisplay
	commandPairDisplay.init()
	#comboNumLabel = $"Combo/Combo-count"
	comboNumLabel = comboPanel.comboHitsText
	blockEfficiencyElem = $"shield-efficiency-ui"
	
	playerTextId = $playerId
	playerTextId.text = playerId
	playerTextId.set("custom_colors/font_color",playerIdColor)
	
	#timer for red hp delay disapear
	redHPTimer = frameTimerResource.new()
	
	add_child(redHPTimer)
	
	#maxComboNumLabel = $"Max-Combo/Combo-count"
	#comboDamageLabel = $"Combo-Damage/Damage-count"
	
	
	
	bestComboDmgLabel=$"trainingModeElements/bestComboDamageValue"
	comboLengthLabel = $"trainingModeElements/comboLengthValue"
	
	longestComboLabel=$"trainingModeElements/longestComboValue"
	comboDmgLabel = $"trainingModeElements/comboDamageValue"
		
	dmgProrationLabel = $"trainingModeElements/prorationValue"
	hitstunProrationLabel = $"trainingModeElements/hitstunProrationValue"
	ripostNotification = $icon_notifiers/ripostNotification
	counterRipostNotification = $icon_notifiers/counterRipostNotification
	
	cmdList = $Node2D/CommandInputList
	

	
	if comboNumLabel == null:
		print("warning, HUD missing combo label")
		
	if damageGaugeBar == null:
		print("warning, HUD missing damage bar")
	
	#if focusBar == null:
	#	print("warning, HUD missing focus bar")
	
		
#	if maxComboNumLabel == null:
#		print("warning, HUD missing max combo label")
		
	if comboDamageLabel == null:
		print("warning, HUD missing combo damage label")
	pass

func connectPlayerStateToTrainingModeElements(player,opponent):
	var playerState = player.playerController.playerState
	var opponentPlayerState = opponent.playerController.playerState
	playerState.connect("combo_changed",self,"set_text_field_value",[comboLengthLabel])
	playerState.connect("max_combo_changed",self,"set_text_field_value",[longestComboLabel])
	playerState.connect("max_combo_damage_changed",self,"set_text_field_value",[bestComboDmgLabel])
	playerState.connect("changed_combo_damage",self,"set_text_field_value",[comboDmgLabel])
	playerState.connect("damageScaleChanged",self,"_on_damage_scale_changed")
	opponentPlayerState.connect("changed_in_hitstun",self,"_on_opponent_hitstun_changed")
	
	opponent.playerController.connect("hitstun_proration_mod_applied",self,"_on_hitstun_proration_mod_applied")
	
func _on_opponent_hitstun_changed(_inHitstun):
	#start combo?
	if _inHitstun:
		dmgProrationLabel.text = "1.000" 
		hitstunProrationLabel.text = "1.000" 
	#locked when not in hitstun, so preoration from last combo displayed until 
	#start new combo
	prorationLabelLocked = not _inHitstun
func _on_damage_scale_changed(oldVal,newVal):
	if not prorationLabelLocked:
		#take first 3 decimal places
		var trimmmedStr =  "%.3f" % newVal
		dmgProrationLabel.text = str(trimmmedStr)

func _on_hitstun_proration_mod_applied(mod):
	if not prorationLabelLocked:
		#take first 3 decimal places
		var trimmmedStr =  "%.3f" % mod
		hitstunProrationLabel.text = str(trimmmedStr)
func set_text_field_value(value,labelNode):
	if labelNode ==comboLengthLabel:
		if value == 0:
			return #ignore setting a combo length of 0, since wnat to keep visualizing the last combo's length
	if labelNode ==comboDmgLabel:
		if value == 0:
			return #ignore setting a combo length of 0, since wnat to keep visualizing the last combo's length
				
	labelNode.text = str(int(round(value)))
	
func setAbilityChunkPadding(x):
	#abilityChunkPadding = x
	#if abilityBar != null:
	#	abilityBar.padding = x
	pass
func getAbilityChunkPadding():
	return abilityChunkPadding
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func setComboDamage(dmg):
	
	
	comboDamage = dmg
	if comboDamageLabel != null:
		#comboDamageLabel.text = "("+str(dmg)+")"
		comboDamageLabel.text = str(dmg)

func getComboDamage():
	return comboDamage
	
func setMaxCombo(c):
	if c < 0:
		c = 0
	maxCombo = c
	if maxComboNumLabel != null:
		maxComboNumLabel.text = str(c)
	
func getMaxCombo():
	return maxCombo


func setCombo(c):
	if c < 0:
		c = 0
	combo = c
	if comboNumLabel != null:
		comboNumLabel.text = str(c)
	
func getCombo():
	return combo
	
func setHP(newHP):
	hp = newHP
	if hpBar != null:
		hpBar.setAmount(hp)
	
func getHP():
	return hp
	
func setDamageGauge(_damageGauge):
	damageGauge = _damageGauge
	if damageGaugeBar != null:
		damageGaugeBar.setAmount(damageGauge)
		comboPanel.dmgProgress.setAmount(damageGauge)

func setDamageGaugeNextHit(value):
	if comboPanel != null:
		comboPanel.dmgProgress.setNextHitAmount(value)
		
	
func getDamageGauge():
	return damageGauge


	
func setFocus(f):
	pass
	#focus = f
	#if focusBar != null:
	#	focusBar.setAmount(focus)
	#	comboPanel.focusProgress.setAmount(f)
	
func setFocusNextHit(value):
	pass
	#if comboPanel != null:
	#	comboPanel.focusProgress.setNextHitAmount(value)
		
func getFocus():
	return focus	

func setDamageGaugeCapacity(c):
	damageGaugeCapacity = c
	if damageGaugeBar != null:
		damageGaugeBar.setCapacity(damageGaugeCapacity)
		comboPanel.dmgProgress.setCapacity(damageGaugeCapacity)


func _on_damageGaugeCapacityReached(newDamage):
	if damageGaugeBar != null:
		damageGaugeBar._on_damageGaugeCapacityReached(newDamage)
		comboPanel.dmgProgress._on_capacityReached()
		


func getDamageGaugeCapacity():
	return damageGaugeCapacity


func setFocusCapacity(c):
	pass
	#focusCapacity = c
	#if focusBar != null:
#		focusBar.setCapacity(focusCapacity)
#		comboPanel.focusProgress.setCapacity(c)


func _on_focusCapacityReached(newFocus):
	pass
	#if focusBar != null:
	#	focusBar._on_damageGaugeCapacityReached(newFocus)
	#	comboPanel.focusProgress._on_capacityReached()

func getFocusCapacity():
	return focusCapacity

	
func setAbility(_ability):
	ability = _ability
	if abilityBar != null:
		abilityBar.setAmount(_ability)
	
func getAbility():
	return ability
	
	
func setUnderHPBar(amount):
	
	hpBar.setUnderBarAmount(amount)
	
func setUnderAbilityBarWithTimeout(amount):
	if abilityBar != null:
		abilityBar.setUnderBarAmountWithTimeout(amount)
	
	
func clearRed(flag,playerState):
	
	#self.comboPanel._on_changed_in_hitstun(flag)
	# bring the red bar down to hp to hide it
	if (not flag):
		#setUnderHPBar(playerState.hp)
		#stopRedHPTimer()
		delayedSetRedHP(playerState)#wait a few seconds before removing red
		
func stopRedHPTimer():
	if redHPTimer.is_connected("timeout",self,"on_red_HP_timer_timeout"):
		redHPTimer.disconnect("timeout",self,"on_red_HP_timer_timeout")
	redHPTimer.stop()
	#delayedSetRedHPLock = false
func setRedHP(hp):
	
	setUnderHPBar(hp)
	
	#don't change the red hp when delay is up, overridding it
	stopRedHPTimer()

func delayedSetRedHP(playerState):
	
	
	if not redHPTimer.is_connected("timeout",self,"on_red_HP_timer_timeout"):
		redHPTimer.connect("timeout",self,"on_red_HP_timer_timeout",[playerState])
		
	#reset the timer and count again
	redHPTimer.stop()
	redHPTimer.startInSeconds(RED_HP_CLEAR_TIMEOUT_IN_SECONDS)
	
	#wait 1 second
	#yield(get_tree().create_timer(waitTimeInSeconds),"timeout")
	
	
	
func on_red_HP_timer_timeout(playerState):

	#delayedSetRedHPLock = false
	#setRedHP(playerState.hp)
	
	startRedHpAnimation(playerState.hp)
	
func setBlockEfficiency(be):
	if blockEfficiencyElem != null:
		blockEfficiencyElem.updateBlockEfficiency(be)
	
	
func _on_dmg_circular_progress_newly_activated():
	emit_signal("dmg_circular_progress_newly_activated")

func _on_focus_circular_progress_newly_activated():
	emit_signal("focus_circular_progress_newly_activated")
	
	
func _on_animation_frame_data(frameStr):
	frameDataLabel.text = frameStr
	
	frameCounterBar.setRelativeFrameData(frameStr)
	
	
func _on_guard_hp_changed(old,new):
	#guardHPBar.value = new
	guardHPBar.guardSetAmount(old,new)
	
#func _on_grab_cooldown_changed(_off_cooldown):
	
#	if _off_cooldown:
					
#		hasGrabIcon.visible=true
#		grabOnCooldownIcon.visible = false	
		
#	else:#on cooldown
#		hasGrabIcon.visible=false
#		grabOnCooldownIcon.visible = true
		
		
func updateHeroStateInfoText(text):
	
	
	#playing belt?
	if beltAngryHUD != null:
		
		heroStateInfo.text = text
		#became angry?
		if text == GLOBALS.BELT_NOTIFICATION_TEXT_ANGRY:
			
			#display the blnking angry HUD 
			beltAngryHUD.visible = true
			beltAngryHUD.enable()
		else:
			#hide the blnking angry HUD 
			beltAngryHUD.visible = false
			beltAngryHUD.disable()
	elif micRapHUD != null: #playing mic?
		heroStateInfo.text = text
		#stance changed to rap?
		if text == GLOBALS.MIC_NOTIFICATION_TEXT_RAP:
			
			#display purple note
			micRapHUD.visible =true
			micOperaHUD.visible = false
		elif text == GLOBALS.MIC_NOTIFICATION_TEXT_OPERA: #opera?
		
			#display pink note
			micRapHUD.visible =false
			micOperaHUD.visible = true
	
	elif whistleHUD != null: #playing whistle?
		whistleHUD.visible=true
		whistleHUD.updateBoneCount(text)
		
		#heroStateInfo.text = text
	
#	elif gloveActiveBallHUD != null: #playing glove?
#		heroStateInfo.text = text
		#stance changed to rap?
#		if text == GLOBALS.GLOVE_NOTIFICATION_TEXT_ACTIVE_BALL:
					
#			gloveActiveBallHUD.visible =true
#			gloveBrokenStringHUD.visible = false
#		elif text == GLOBALS.GLOVE_NOTIFICATION_TEXT_BROKEN_STRING: #opera?
		

#			gloveActiveBallHUD.visible =false
#			gloveBrokenStringHUD.visible = true
#		else:
#			gloveActiveBallHUD.visible =false
#			gloveBrokenStringHUD.visible = false
	elif hatHUD != null: #playing hat?
	
		if text == GLOBALS.HAT_BALL_CAP_ON_BATTLEFIELD_IN_FRONT_OF_HAT_IX:
			hatHUD.showRightIcon()
		elif text == GLOBALS.HAT_BALL_CAP_ON_BATTLEFIELD_BEHIND_HAT_IX:
			hatHUD.showLeftIcon()
		elif text == GLOBALS.HAT_BALL_CAP_ON_BATTLEFIELD_ABOVE_OR_BELOW_HAT_IX:
			hatHUD.showUpDownIcon()
		elif text == GLOBALS.HAT_BALL_CAP_OFF_BATTLEFIELD_IX:
			hatHUD.hideAll()
#func setProficiencies(advProf,disProf):
func setProficiencies(prof1MajorIx,prof1MinorIx,prof2MajorIx,prof2MinorIx):
	#advProfIcon.setProficiencyTexture(advProf)
	#disProfIcon.setProficiencyTexture(disProf)
	
	var prof1ClassType = null
	var prof2ClassType = null
	
	#generalist doesn't have stars
	if prof1MajorIx == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
		prof1ClassType=null
		prof2ClassType=null
	#major advantage, major disadvantage chosen?
#	elif prof1MinorIx == -1:
	else:
		prof1ClassType=GLOBALS.ProficiencyClass.MAJOR_ADVANTAGE
		prof2ClassType=GLOBALS.ProficiencyClass.MAJOR_DISADVANTAGE
#	else:
#		prof1ClassType=GLOBALS.ProficiencyClass.MINOR
#		prof2ClassType=GLOBALS.ProficiencyClass.MINOR
		
	advProfIcon.setProficiencyTexture(prof1MajorIx,prof1MinorIx,prof1ClassType,true)
	disProfIcon.setProficiencyTexture(prof2MajorIx,prof2MinorIx,prof2ClassType,false)
	
	
func startRedHpAnimation(hp):
	hpBar.animateHPLossBar(hp)