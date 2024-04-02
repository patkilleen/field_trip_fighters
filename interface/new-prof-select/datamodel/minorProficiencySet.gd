extends Node

export (String) var description = ""
var minorProfSet = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var id = 0
	for c in self.get_children():
		
		if c is preload("res://interface/new-prof-select/datamodel/minorProficiency.gd"):
			minorProfSet.append(c)
			c.id = id
			id = id +1
			

func getMinorProficiencies():
	return minorProfSet
		
func getMinorProficiency(id):
	if id < 0 or id >=minorProfSet.size():
		return null
	return minorProfSet[id]

