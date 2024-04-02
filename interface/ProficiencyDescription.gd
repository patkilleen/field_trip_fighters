extends Control

const GLOBALS = preload("res://Globals.gd")

const ADVANTAGE_IX = 0
const DISADVANTAGE_IX = 1
#description map
var descMap = [{},{}]

var visibleNode = null
func _ready():
	var advMap = descMap[ADVANTAGE_IX]
	advMap[GLOBALS.Proficiency.BAR_COST]=$"ability-cancel-advantage"
	advMap[GLOBALS.Proficiency.DAMAGE_INCREASE]=$"off-mastery-advantage"
	advMap[GLOBALS.Proficiency.ACROBATICS]=$"acrobatics-advantage"
	advMap[GLOBALS.Proficiency.DEFENDER]=$"defender-advantage"
	advMap[GLOBALS.Proficiency.NONE]=$"non-proficiency"
	
	var disMap = descMap[DISADVANTAGE_IX]
	disMap[GLOBALS.Proficiency.BAR_COST]=$"ability-cancel-disadvantage"
	disMap[GLOBALS.Proficiency.DAMAGE_INCREASE]=$"off-mastery-disadvantage"
	disMap[GLOBALS.Proficiency.ACROBATICS]=$"acrobatics-disadvantage"
	disMap[GLOBALS.Proficiency.DEFENDER]=$"defender-disadvantage"
	disMap[GLOBALS.Proficiency.NONE]=$"non-proficiency"


	#hide all desciprtions by default
	for k in advMap.keys():
		advMap[k].visible = false 
		
		
	for k in disMap.keys():
		disMap[k].visible = false
		
func displayProfDescription(advDisIx, profEnum):
	
	if advDisIx == null or advDisIx < 0 or advDisIx >=descMap.size():
		return
	
	
	var map = descMap[advDisIx]
	
	if not map.has(profEnum):
		print("unkown proficiency: "+profEnum)
		return
	
	#a node was previously displayed?
	if visibleNode != null:
		#hide it
		visibleNode.visible = false
		
	#display the appropriate description
	visibleNode = map[profEnum]
	visibleNode.visible = true