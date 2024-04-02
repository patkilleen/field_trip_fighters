extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

enum ProrationType{	
	DAMAGE,
	FOCUS,
	STANDARD
}

export (ProrationType) var type = 0
var playerState = null

var basicScale = 1
var comboLevelScale = 1

var fillBar = null

#max comobo level ability regen proration is 2 (see applyComboLevelProration in ComboHandler)
const MAX_COMBO_LEVEL_ABILITY_REGEN_SCALE = 3
#max comobo level ability regen proration is 2 (see on_combo_hit in ComboHandler)
const MAX_BASIC_ABILITY_REGEN_SCALE = 2

const MAX_ABILITY_TOTAL_PRORATION =MAX_COMBO_LEVEL_ABILITY_REGEN_SCALE*MAX_BASIC_ABILITY_REGEN_SCALE

func _ready():
	fillBar = $fill
	
	if type == ProrationType.FOCUS:
		fillBar.min_value = 1
		fillBar.max_value = 6
		fillBar.value = 6
		fillBar.step = 0.05
	elif type == ProrationType.DAMAGE or type == ProrationType.STANDARD:
		fillBar.min_value = 0
		fillBar.max_value = 100
		fillBar.value = 100
		fillBar.step = 1
	
	fillBar.init()

func connectToPlayerStateDamageSignals(playerState):
	playerState.connect("comboLevelDamageScaleChanged",self,"_on_comboLevelScaleChanged")
	playerState.connect("damageScaleChanged",self,"_on_basicScaleChanged")
	
func connectToPlayerStateFocusSignals(playerState):
	playerState.connect("comboLevelAbilityRegenScaleChanged",self,"_on_comboLevelScaleChanged")
	playerState.connect("abilityRegenScaleChanged",self,"_on_basicScaleChanged")

	
func _on_comboLevelScaleChanged(oldValue,newValue):
	comboLevelScale=newValue
	
	updateProgress()

func _on_basicScaleChanged(oldValue,newValue):
	basicScale=newValue
	updateProgress()
	
	
func updateProgress():
	#var damagePrecentage =  100*comboLevelScale*basicScale
	var prorationValue = 0
	
	if type == ProrationType.FOCUS:
		#prorationValue = comboLevelScale*basicScale
		#prorationValue= fillBar.max_value - prorationValue + fillBar.min_value
		#old content
		pass
	elif type == ProrationType.DAMAGE or type == ProrationType.STANDARD:
		#prorationValue = comboLevelScale*basicScale*100
		prorationValue = basicScale*100
		pass
	
	fillBar.value =prorationValue
	fillBar.updateColor()
	
func setValue(value):
	fillBar.value =value
	fillBar.updateColor()