extends Node2D

enum Type{
	VISIBILITY,
	PHYSICS_PROCESS,
	MODULATE
}

export (Type) var type = 0



func _ready():
	
	#make animations disabled by default
	_on_departure(null)
	

func _on_bus_arrived(area2d):
	
	#we display or animate children on arrival
	for c in get_children():
		
		if type == Type.VISIBILITY:
			c.visible = true
		elif type == Type.PHYSICS_PROCESS:
			c.set_physics_process(true)
		elif type == Type.MODULATE:
			c.modulate.a = 1
		
	pass
	
func _on_departure(area2d):
	#we hide or  stop animation of children on arrival
	for c in get_children():
		
		if type == Type.VISIBILITY:
			c.visible = false
		elif type == Type.PHYSICS_PROCESS:
			c.set_physics_process(false)
		elif type == Type.MODULATE:
			c.modulate.a = 0