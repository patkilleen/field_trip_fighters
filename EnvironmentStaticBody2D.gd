extends StaticBody2D


const TYPE_WALL = 0
const TYPE_CEILING = 1
const TYPE_FLOOR = 2
const TYPE_PLATFORM = 3
export (int, "Wall","Ceiling","Floor", "Platform") var type = 0

func _ready():
	pass