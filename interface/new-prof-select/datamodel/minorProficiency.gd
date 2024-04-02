extends Node


export (String) var profName = "" setget setProfName,getProfName
export (Texture) var icon = null

var id = 0 #will be set by parent, used for lookup using minor proficiency reference

var properties = []

#2ndary arrays to avoid iterating over all properties if desire good/bad exclusivly
var goodProperties = []
var badProperties = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#iterate children to look for proficincy properties
	for c in self.get_children():
		
		#proficiency property?
		if c is preload("res://interface/new-prof-select/datamodel/proficiencyProperty.gd"):
			properties.append(c)
			
			# put property in appropriate bin
			if c.isGood:
				goodProperties.append(c)
			else:
				badProperties.append(c)

func setProfName(n):
	profName = n
	
func getProfName():
	return profName
	
	
func getAllProperties():
	return properties
	
func getGoodProperties():
	return goodProperties
	
func getBadProperties():
	return badProperties