extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var comboHitsText = null
var stars = null
var subCombos = null
var damageText = null
var dmgProgress= null
var focusProgress= null

var bgdColor = null
var dmgProrationBar = null
var focusProrationBar = null
var abilityBarFeedingHUD = null

var dmgIncreaseLockTextureRect = null
var focusIncreaseLockTextureRect = null
var dmgIncreaseUnlockedTextureRect = null
var focusIncreaseUnlockedTextureRect = null

var displayDmgLock = false
var displayFocusLock = false


var magicSeriesComboLevelHUD = null
var reverseBeatComboLevelHUD = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	comboHitsText=$"Combo/Combo-count"
	stars = $Stars
	subCombos=$SubCombos
	damageText = $Combo/damage
	#dmgProgress = $CircularDamageProgressBar
	#focusProgress = $CircularFocusProgressBar
	#dmgProgress = get_node("../icon_notifiers/CircularDamageProgressBar")
	dmgProgress = $CircularDamageProgressBar
	#focusProgress = get_node("../icon_notifiers/CircularFocusProgressBar")
	
	
	magicSeriesComboLevelHUD = $"VBoxContainer/MagicSeriesComboLevelHUD"
	reverseBeatComboLevelHUD = $"VBoxContainer/ReverseBeatComboLevelHUD"
	
	magicSeriesComboLevelHUD.visible = true
	reverseBeatComboLevelHUD.visible = false

	#hide the bar increase lock when circular progress is hidden
	#dmgProgress.connect("visibility_changed",self,"setDmgIncreaseLockVisibility",[false])
	#focusProgress.connect("visibility_changed",self,"setFocusIncreaseLockVisibility",[false])
	#dmgProgress.connect("visibility_changed",self,"setDmgIncreaseUnlockVisibility",[false])
	#focusProgress.connect("visibility_changed",self,"setFocusIncreaseUnlockVisibility",[false])
	
#	if not dmgProgress.is_connected("changed_visibility",self,"setDisplayDamageLock"):
#		dmgProgress.connect("changed_visibility",self,"setDisplayDamageLock")
	
#	if not focusProgress.is_connected("changed_visibility",self,"setDisplayFocusLock"):
#		focusProgress.connect("changed_visibility",self,"setDisplayFocusLock")
	
#	if not dmgProgress.is_connected("changed_visibility",self,"setDisplayDamageLock"):
#		dmgProgress.connect("changed_visibility",self,"setDisplayDamageLock")
	
#	if not focusProgress.is_connected("changed_visibility",self,"setDisplayFocusLock"):
#		focusProgress.connect("changed_visibility",self,"setDisplayFocusLock")
	
	bgdColor = $bgdColor
	dmgProrationBar = $DamageProrationBar
	#focusProrationBar = $FocusProrationBar
	abilityBarFeedingHUD = $abilityBarFeedingHUD
	
	#dmgIncreaseLockTextureRect = $DmgLockTextureRect
#	dmgIncreaseLockTextureRect.visible = false
	
	#focusIncreaseLockTextureRect = $FocusLockTextureRect
#	focusIncreaseLockTextureRect.visible = false
	
	#dmgIncreaseUnlockedTextureRect = $DmgUnlockedTextureRect
	#dmgIncreaseUnlockedTextureRect.visible = false
	
	#focusIncreaseUnlockedTextureRect = $FocusUnlockedTextureRect
	#focusIncreaseUnlockedTextureRect.visible = false
	pass

func setDisplayDamageLock(flag):
	pass
	#displayDmgLock = flag
	
	#if not flag:
		#dmgIncreaseLockTextureRect.visible = false
		#dmgIncreaseUnlockedTextureRect.visible = false
func setDisplayFocusLock(flag):
	pass
#	displayFocusLock = flag
	
#	if not flag:
		#focusIncreaseLockTextureRect.visible = false
		#focusIncreaseUnlockedTextureRect.visible = false

		
func setDmgIncreaseLockVisibility(flag):
	pass
	#if not displayDmgLock:
	#	return
		
	#if dmgIncreaseLockTextureRect != null:
	#	dmgIncreaseLockTextureRect.visible = flag
	
func setFocusIncreaseLockVisibility(flag):
	pass
	#if not displayFocusLock:
	#	return
	#if focusIncreaseLockTextureRect != null:
	#	focusIncreaseLockTextureRect.visible = flag

func setDmgIncreaseUnlockVisibility(flag):
	pass
	#if not displayDmgLock:
	#	return
		
	#if dmgIncreaseUnlockedTextureRect != null:
	#	dmgIncreaseUnlockedTextureRect.visible = flag
	
func setFocusIncreaseUnlockVisibility(flag):
	pass
	#if not displayFocusLock:
	#	return
		
	#if focusIncreaseUnlockedTextureRect != null:
	#	focusIncreaseUnlockedTextureRect.visible = flag
#TODO MOVE THE circular progress bar logic to interface
func setVisibility(flag):
	
	if flag:
		
		#first time displaying panel?
		
		if self.visible == false:
			pass
			#dmgProgress._on_combo_panel_displayed()
			#focusProgress._on_combo_panel_displayed()
		self.visible = true
		
	else:
		
		if self.visible == true:
			subCombos.clear()
			#dmgProgress._on_combo_panel_hidden()
			#focusProgress._on_combo_panel_hidden()
		self.visible = false
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_magic_series_sub_combo_level_changed(subComboLevel,cmd,playerState):
	handleComboLevelHUDVisibility(playerState)
func _on_reverse_beat_sub_combo_level_changed(subComboLevel,cmd,playerState):
	handleComboLevelHUDVisibility(playerState)

func handleComboLevelHUDVisibility(playerState):
	
	#only when doing reverse beat combo does the reverse beat start display
	#otherwise, by default it's the magic series start
	if playerState.focusSubComboLevel > playerState.subComboLevel:
		magicSeriesComboLevelHUD.visible = false
		reverseBeatComboLevelHUD.visible = true
	else:
		magicSeriesComboLevelHUD.visible = true
		reverseBeatComboLevelHUD.visible = false
		