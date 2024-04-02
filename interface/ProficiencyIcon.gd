extends TextureRect

export (Texture) var abilityCancelingTexture = null
export (Texture) var acrobaticsTexture = null
export (Texture) var defenderTexture = null
export (Texture) var generalistTexture = null
export (Texture) var offensiveMasteryTexture = null

const GLOBALS  = preload("res://Globals.gd")
var textureMap = {}
var profDataModel = null

var starPair = null
func _ready():
	
	profDataModel = $ProficiencyDataModel
	starPair = $"class-stars"
	#textureMap[GLOBALS.Proficiency.BAR_COST]=abilityCancelingTexture
	#textureMap[GLOBALS.Proficiency.ACROBATICS]=acrobaticsTexture
	#textureMap[GLOBALS.Proficiency.DEFENDER]=defenderTexture
	#textureMap[GLOBALS.Proficiency.NONE]=generalistTexture
	#textureMap[GLOBALS.Proficiency.DAMAGE_INCREASE]=offensiveMasteryTexture
	
	
func setProficiencyTexture(majorClassIx,minorClassIx,profClassType,isAdvantage):
	
	#unknown proficinecy?
	#if profEnum == null or not textureMap.has(profEnum):
	#	self.texture=null
	#	return
	
	#set the texture of proficiency icon given the enum
	#self.texture = textureMap[profEnum]
	self.texture = profDataModel.getProficiencySetTexture(majorClassIx,minorClassIx,isAdvantage)
	
	if profClassType == null:
		starPair.visible = false
	else:
		starPair.visible = true
	starPair.displayProficiencyClassStars(profClassType)
