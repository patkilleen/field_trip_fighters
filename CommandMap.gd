extends Node

var textureMap = null
var textures = null

func _ready():
	#THE CHILDREN OF THIS TEXTURE RECT SHOULD BE 
	#TEXTURES THAT ARE ORDERED BY INPUT COMMAND
	#ID, SO FIRST CHILD SHOOULD BE JUMP COMMAND'S BUTTON TEXTURE
	textures=$textures
	textureMap = textures.get_children()

func init():
	textures=$textures
	textureMap = textures.get_children()
	
func getNumberOfTextures():
	return textures.get_child_count()
	
func lookupTexture(cmd):
	if cmd == null:
		return null
	if cmd >= textureMap.size():
		return null
	return textureMap[cmd].texture
