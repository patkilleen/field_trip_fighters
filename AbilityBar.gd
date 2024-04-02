extends "res://Bar.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var textureProgressInvalid = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	textureProgressInvalid = $TextureProgressInvalid
	textureProgressInvalid.value = textureProgress.value
	textureProgressInvalid.min_value = textureProgress.min_value
	pass

	
func setMaximum(amount):
	ttextureProgressInvalid.max_value = amount
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
