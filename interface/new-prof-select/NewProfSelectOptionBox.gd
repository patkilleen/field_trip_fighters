extends Control

const GLOBALS = preload("res://Globals.gd")

var majorProfNameLabel = null
var minorProfNameLabel = null
var majorProfDescLabel = null 
var majorProfIcon = null
var minorProfIcon = null

var profStarPair = null

var minorClassNameArrows = null

var previousMajorClassIcon=null
var nextMajorClassIcon=null

var majorClassPencilP1=null
var majorClassPencilP2=null
func _ready():
	
	profStarPair = $"options-box/class-stars"
	
	#by default the advantage major is displayed
	profStarPair.displayProficiencyClassStars(GLOBALS.ProficiencyClass.MAJOR_ADVANTAGE)	
	
	majorProfNameLabel=$"options-box/proficiency-name-bgd/profNameContainer/proficiencyName"
	minorProfNameLabel = $"options-box/minor-class-text-bgd/minorProfNameContainer/proficiencyName"
	majorProfDescLabel = $"options-box/descriptionContainer/profDesc"
	majorProfIcon=$"options-box/major-class-icon"
	minorProfIcon = $"options-box/minor-class-icon"
	minorClassNameArrows = $"options-box/minor-class-text-bgd/minor-class-arrows"
	previousMajorClassIcon=$"options-box/previous-major-class-icon"
	nextMajorClassIcon=$"options-box/next-major-class-icon"
	majorClassPencilP1 = $"options-box/major-class-icon/p1Pencil"
	majorClassPencilP2 = $"options-box/major-class-icon/p2Pencil"
	majorClassPencilP1.visible = false
	majorClassPencilP2.visible = false

func setMajorClassPencilVisibility(player1Flag,visibleFlag):
	if player1Flag:
		majorClassPencilP1.visible =visibleFlag
	else:
		majorClassPencilP2.visible =visibleFlag
		
func setPreviousMajorClassIcon(texture):
	previousMajorClassIcon.texture=texture
	
func setNextMajorClassIcon(texture):
	nextMajorClassIcon.texture=texture
	
func setMajorProficiencyName(strName):
	majorProfNameLabel.text = strName

func setMinorProficiencyName(strName):
	minorProfNameLabel.text = strName	

func setProficiencyDescription(descStr):
	majorProfDescLabel.text = descStr
	
func setMajorProficiencyTexture(texture):
	majorProfIcon.texture=texture

func setMinorProficiencyTexture(texture):
	minorProfIcon.texture=texture	
	
func displayProficiencyClassStars(profClass):
	profStarPair.displayProficiencyClassStars(profClass)
	profStarPair.visible = true

func hideProficiencyClassStars():
	profStarPair.visible = false
	
func displayMinorClassNameArrows():
	minorClassNameArrows.visible = true
	
func hideMinorClassNameArrows():
	minorClassNameArrows.visible = false