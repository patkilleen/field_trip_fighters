extends "res://MultiTextureProgress.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (Texture) var middleBarTexture = null setget setMiddleBarTexture,getMiddleBarTexture

var middleBar = null
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	middleBar = $middleBar
	middleBar.texture_progress  = middleBarTexture
	pass


func setMiddleBarTexture(t):
	
	middleBarTexture =  t
	
	if middleBar !=null:
		middleBar.texture_progress = t
		
func getMiddleBarTexture():
	return middleBarTexture
	
	
func setMin(m):
	.setMin(m)
	middleBar.min_value = m
	
func setMax(m):
	.setMax(m)
	middleBar.max_value = m
	
func setMiddleBarAmount(amount):
	middleBar.value = amount
func setScale(s):
	.setScale(s)
	middleBar.set_scale(s)	
#func _process(delta):
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
