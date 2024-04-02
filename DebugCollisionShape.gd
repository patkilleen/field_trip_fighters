extends CollisionShape2D

var GLOBALS = preload("res://Globals.gd")

var debug_color = Color(1,1,1,0.5)

func _ready():
	update()
	pass

func _draw():
	if not GLOBALS.DEBUG:
		return
	var shape = self.get_shape()
	
	if shape is CircleShape2D:
		draw_circle(self.global_position,shape.radisu,debug_color)	
	elif shape is RectangleShape2D:
		
		var extent = shape.get_extents()
		var rec = Rect2(self.global_position,extent)
		draw_rect(rec,debug_color,false)
	
	
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
