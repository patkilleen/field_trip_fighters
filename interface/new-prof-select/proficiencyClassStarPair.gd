extends Control
const GLOBALS = preload("res://Globals.gd")
var starContainerMap = {}

var visibleStarsContainer = null
func _ready():
	starContainerMap[GLOBALS.ProficiencyClass.MAJOR_ADVANTAGE] = $"adv-major-class-Container"
	starContainerMap[GLOBALS.ProficiencyClass.MAJOR_DISADVANTAGE] = $"dis-major-class-Container"
	starContainerMap[GLOBALS.ProficiencyClass.MINOR] = $"minor-class-Container"
	
	visibleStarsContainer=starContainerMap[GLOBALS.ProficiencyClass.MAJOR_ADVANTAGE]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func displayProficiencyClassStars(profClass):
	if profClass == null:
		return

		
		
	for k in starContainerMap.keys():
		starContainerMap[k].visible = false
	#hide old stars
	#visibleStarsContainer.visible = false
	
	visibleStarsContainer=starContainerMap[profClass]
	
	#show new starts
	visibleStarsContainer.visible = true
	