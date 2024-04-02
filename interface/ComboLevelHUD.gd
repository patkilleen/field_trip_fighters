extends Control

export (int) var starOverflowSize = 3

export (Texture) var starTexture = null
export (Texture) var progressStarTexture = null


export (Texture) var firstButtonTexture = null
export (Texture) var secondButtonTexture = null
export (Texture) var thirdButtonTexture = null

#var checkMarkRect = null
var circularProgessStar = null
var starArray = null
func _ready():
	#checkMarkRect = $HBoxContainer/CheckMarkTextureRect
	circularProgessStar = $HBoxContainer/CircularProgressStar
	starArray = $"HBoxContainer/star-array"
	
	starArray.starOverflowSize = starOverflowSize
	starArray.setStarTexture(starTexture)
	circularProgessStar.setButtonTextures(firstButtonTexture,secondButtonTexture,thirdButtonTexture)
	circularProgessStar.texture_progress=progressStarTexture

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
