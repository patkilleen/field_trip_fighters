extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var GLOBALS = preload("res://Globals.gd")
var staticBody = null
func _ready():
	staticBody = $StaticBody2D
	staticBody.collision_layer = 1 << GLOBALS.PLAYER1_STAGE_COLLISION_LAYER_BIT
	staticBody.collision_layer =  staticBody.collision_layer | (1 << GLOBALS.PLAYER2_STAGE_COLLISION_LAYER_BIT)
	staticBody.collision_layer =  staticBody.collision_layer | (1 << GLOBALS.PLAYER1_PLATFORM_LAYER_BIT)
	#staticBody.collision_layer =  1 << GLOBALS.PLAYER1_PLATFORM_LAYER_BIT
	staticBody.collision_layer =  staticBody.collision_layer | (1 << GLOBALS.PLAYER2_PLATFORM_LAYER_BIT)
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
