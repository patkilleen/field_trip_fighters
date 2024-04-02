extends Label

const GLOBALS = preload("res://Globals.gd")


func _ready():
	self.text = GLOBALS.GAME_VERSION_STRING

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
