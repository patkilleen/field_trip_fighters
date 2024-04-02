extends Node

const ADV_CHILD_NODE_NAME = "advantage"
const DIS_CHILD_NODE_NAME = "disadvantage"

export (String) var profName = ""

export (Texture) var icon = null

var id = 0
var advantageMinorProfSet = null
var disadvantageMinorProfSet = null

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if not self.has_node(ADV_CHILD_NODE_NAME):
		print("error: the ProficiencyDataModel scene isn't setup properly." + self.name + " missing advantage child node ")
		return
	if not self.has_node(DIS_CHILD_NODE_NAME):
		print("error: the ProficiencyDataModel scene isn't setup properly." + self.name + " missing disadvantage child node ")
		return
		
	advantageMinorProfSet = get_node(ADV_CHILD_NODE_NAME)
	
	disadvantageMinorProfSet = get_node(DIS_CHILD_NODE_NAME)
	
	
func getMinorProficiencySet(isAdvantage):
	
	if isAdvantage:
		return advantageMinorProfSet.minorProfSet
	else:
		return disadvantageMinorProfSet.minorProfSet
		
		
func getDescription(isAdvantage):
	if isAdvantage:
		return advantageMinorProfSet.description
	else:
		return disadvantageMinorProfSet.description