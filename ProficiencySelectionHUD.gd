extends Control
var GLOBALS = preload("res://Globals.gd")
var advLabel = null
var disLabel = null

var advIcon = null
var disIcon = null
#enum Proficiency{
#	RIPOST_COST,
#	BAR_COST,
#	DAMAGE_INCREASE,
#	ACROBATICS,
#	DEFENDER,
#	NONE
#}

var profDataModel = null
#var profMap = {}
func _ready():
	init()
	
func init():
	advLabel = $"HBoxContainer3/advProfLabel"
	disLabel = $"HBoxContainer4/disProfLabel"
	
	profDataModel = $ProficiencyDataModel
	
	advIcon = $advantageIcon
	disIcon = $disadvantageIcon
	
	#profMap[GLOBALS.Proficiency.RIPOST_COST]= "Ripost"
	#profMap[GLOBALS.Proficiency.BAR_COST]= "Ability Cancel"
	#profMap[GLOBALS.Proficiency.DAMAGE_INCREASE]= "Offensive \nMastery"
	#profMap[GLOBALS.Proficiency.ACROBATICS]= "Acrobatics"
	#profMap[GLOBALS.Proficiency.DEFENDER]= "Defender"
	#profMap[GLOBALS.Proficiency.NONE]= "None"

#func displayProficiencies(advProf, disProf):
func displayProficiencies(prof1MajorClassIxSelect,prof1MinorClassIxSelect,
						prof2MajorClassIxSelect,prof2MinorClassIxSelect):
							
	var prof1Name = profDataModel.getProficiencySetName(prof1MajorClassIxSelect,prof1MinorClassIxSelect,true)
	var prof2Name = profDataModel.getProficiencySetName(prof2MajorClassIxSelect,prof2MinorClassIxSelect,false)
	#advLabel.text =profMap[advProf]
	#disLabel.text =profMap[disProf]
	advLabel.text =prof1Name
	disLabel.text =prof2Name
	
	#advIcon.setProficiencyTexture(advProf)
	#disIcon.setProficiencyTexture(disProf)
	
	var prof1ClassType = null
	var prof2ClassType = null
	
	#generalist doesn't have stars
	if prof1MajorClassIxSelect == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
		prof1ClassType=null
		prof2ClassType=null
	else:
		prof1ClassType=GLOBALS.ProficiencyClass.MAJOR_ADVANTAGE
		prof2ClassType=GLOBALS.ProficiencyClass.MAJOR_DISADVANTAGE
	#major advantage, major disadvantage chosen?
	#elif prof1MinorClassIxSelect == -1:
	#	prof1ClassType=GLOBALS.ProficiencyClass.MAJOR_ADVANTAGE
	#	prof2ClassType=GLOBALS.ProficiencyClass.MAJOR_DISADVANTAGE
	#else:
	#	prof1ClassType=GLOBALS.ProficiencyClass.MINOR
	#	prof2ClassType=GLOBALS.ProficiencyClass.MINOR
	
	
	advIcon.setProficiencyTexture(prof1MajorClassIxSelect,prof1MinorClassIxSelect,prof1ClassType,true)
	disIcon.setProficiencyTexture(prof2MajorClassIxSelect,prof2MinorClassIxSelect,prof2ClassType,false)
