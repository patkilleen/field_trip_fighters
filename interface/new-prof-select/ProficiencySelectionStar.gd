extends Control
const GLOBALS  = preload("res://Globals.gd")
export (float) var unconfirmedTransparancy = 0.4
var profSelectedIcon = null
var profStarPair = null
var glow = null
var majorClassid = null

func _ready():
	profSelectedIcon = $"prof-selected"
	profStarPair=$"class-stars"
	glow = $"glow"
	profStarPair.modulate.a = unconfirmedTransparancy
	profSelectedIcon.modulate.a = unconfirmedTransparancy
	#unconfirmSelection()


func hideClassStars():
	profStarPair.visible = false

func displayClassStars():
	profStarPair.visible = true
	
		
func select(profIconTexture,profClass, _majorClassid):
	majorClassid =_majorClassid
	profSelectedIcon.texture = profIconTexture
	profStarPair.displayProficiencyClassStars(profClass)
	profSelectedIcon.visible = true
	
	glow.visible = true
	
	if majorClassid == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
		hideClassStars()
	else:
		displayClassStars()
	

func unselect():
	profSelectedIcon.visible = false
	profStarPair.visible = false
	glow.visible = false

func confirmSelection():
	glow.visible = false
	profStarPair.modulate.a = 1
	profSelectedIcon.modulate.a = 1
	
func unconfirmSelection():
	glow.visible = true
	profStarPair.modulate.a = unconfirmedTransparancy
	profSelectedIcon.modulate.a = unconfirmedTransparancy

	