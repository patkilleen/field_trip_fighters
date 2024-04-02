extends CollisionShape2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (bool) var facingRight = true
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func setNewPosition(p):
	
	if not facingRight:
		p.x = p.x * (-1)
		
	self.set_position(p)
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
