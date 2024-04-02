extends MenuButton

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var bgd = null

var btnName = null
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	bgd = $TextureRect
	
	self.connect("focus_entered",self,"_on_focus_entered")
	self.connect("focus_exited",self,"_on_focus_exited")
	
	btnName = $Label.text
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
