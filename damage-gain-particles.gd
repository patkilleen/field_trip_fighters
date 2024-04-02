extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (bool) var emitting = false setget setEmitting,getEmmitting

var particles = []
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	for c in self.get_children():
		particles.append(c)
	pass

func setEmitting(e):
	emitting = e
	
	for p in particles:
		p.emitting = e
	
func getEmmitting():
	return emitting

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
