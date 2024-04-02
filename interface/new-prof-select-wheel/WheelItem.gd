extends Sprite


func _ready():
	pass

func getCenter():
	var h = texture.get_height()
	var w = texture.get_width()
	
	var center = position
	center.x = center.x - w/2.0
	center.y = center.y - h/2.0
	return center
	
	
func _physics_process(delta):
	self.global_rotation_degrees=0 #this makes the icon always upright
	pass
