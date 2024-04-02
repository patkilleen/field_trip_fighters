extends HBoxContainer

export (Texture) var advantageBulletTexture = null
export (Texture) var disadvantageBulletTexture = null

var bulletTexture = null
var propertyLabel = null
func _ready():
	bulletTexture = $"bullet"
	propertyLabel = $"text-container/profDesc"


func setDescription(text):
	propertyLabel.text = text


func setBullet(isAdvantageFlag):
	if isAdvantageFlag:
		bulletTexture.texture=advantageBulletTexture
	else:
		bulletTexture.texture=disadvantageBulletTexture