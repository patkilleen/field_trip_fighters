extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (NodePath) var playerState = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	set_process(false)
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.

	#update hud here
#	var pState = get_node(playerState)
	
#	var output = ""
#	output += str(self.get_parent().inputDeviceId)

#	self.text = output
