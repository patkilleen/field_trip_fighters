extends TextureRect

export (int) var command = -1 setget setCommand,getCommand

export (bool) var animated = false
var cmdMap = null
var textureMap = null
var textures = null
var particles = null
func _ready():
	#THE CHILDREN OF THIS TEXTURE RECT SHOULD BE 
	#TEXTURES THAT ARE ORDERED BY INPUT COMMAND
	#ID, SO FIRST CHILD SHOOULD BE JUMP COMMAND'S BUTTON TEXTURE
	particles = $Particles2D
	cmdMap =$CommandMap
	
	#var maxSize = Vector2(0,0)
	#make sure to grow this rect to be size of biggest textture
	#for n in cmdMap.textureMap:
	#	if n.texture == null:
	#		continue
	#	if maxSize.x < n.texture.get_width():
	#		maxSize.x = n.texture.get_width()
	#	if maxSize.y < n.texture.get_height():
	#		maxSize.y = n.texture.get_height()
	
	#self.rect_min_size = maxSize
	
func setCommand(cmd):

	#invalid arg, hide button texture (since no such texture exists to show)?
	if (cmd ==null) or (cmd < 0) or (cmd >= cmdMap.getNumberOfTextures()):
		command = cmd
		self.visible = false
		return
	if animated:
		particles.emitting=false
		particles.emitting=true
	self.visible = true
	command = cmd
	
	#set texture to button pressed's texture 
	self.set_texture(cmdMap.lookupTexture(cmd))
	
func getCommand():
	return command
	
func _draw():
	
	pass		
#	draw_rect(Rect2(self.rect_position,self.rect_min_size),Color("#ffffff"),false)