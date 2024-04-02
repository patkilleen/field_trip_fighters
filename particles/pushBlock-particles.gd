extends Node2D


var particles = []

func _ready():
	for c in self.get_children():
		if c is Particles2D:
			particles.append(c)
			

func emit():
	for p in particles:
		p.set_emitting(true)

