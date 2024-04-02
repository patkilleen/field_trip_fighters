extends Control

export (String) var inputDeviceId = "P1"

const GLOBALS = preload("res://Globals.gd")
#var profDesc = null

var advProf = null
var disProf = null


var advDisIx = null

#var cursors = []
func _ready():
	#profDesc = $ProficiencyDescription
	
#	cursors.append($"adv-cursor")
#	cursors.append($"dis-cursor")
	set_physics_process(false)

func init(_advProf,_disProf):
	advProf=_advProf
	disProf = _disProf
	
	#advDisIx =profDesc.ADVANTAGE_IX
		
	#by default display advantage (0) attributes
	#profDesc.displayProfDescription(advDisIx,advProf)
	
	##don't show pencils when no proficiency taken
	#if advProf != GLOBALS.Proficiency.NONE:
	#	cursors[profDesc.ADVANTAGE_IX].visible=true
	#	cursors[profDesc.DISADVANTAGE_IX].visible=false
	#else:
	#	cursors[profDesc.ADVANTAGE_IX].visible=false
	#	cursors[profDesc.DISADVANTAGE_IX].visible=false
	#set_physics_process(true)
	
#func _physics_process(delta):
		
#	var diPressed= false
	#let players scroll through stats
#	if Input.is_action_just_released(inputDeviceId+"_RIGHT"):
#		diPressed = true
#	elif Input.is_action_just_released(inputDeviceId+"_LEFT"):
#		diPressed = true
		
#	#pressed a direction to change description?
#	if diPressed == true:
#		if advDisIx  == profDesc.ADVANTAGE_IX:
#			advDisIx = profDesc.DISADVANTAGE_IX
#			profDesc.displayProfDescription(advDisIx,disProf)
#			if advProf != GLOBALS.Proficiency.NONE:
#				cursors[profDesc.ADVANTAGE_IX].visible=false
#				cursors[profDesc.DISADVANTAGE_IX].visible=true
#		else:
#			advDisIx=profDesc.ADVANTAGE_IX
#			profDesc.displayProfDescription(advDisIx,advProf)
#			if advProf != GLOBALS.Proficiency.NONE:
#				cursors[profDesc.ADVANTAGE_IX].visible=true
#				cursors[profDesc.DISADVANTAGE_IX].visible=false
