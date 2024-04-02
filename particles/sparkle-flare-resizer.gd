extends Sprite

var time = 0
export var power = 0
export var speed =1

const GLOBALS = preload("res://Globals.gd")


func _ready():
	#i don't think i use this in current game, so just disable the processing
	set_process(false)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS	
	#each time it's bigger than 1, it wraps back to 0
	time = wrapf(time+delta*speed,-PI,PI)
	
	scale = Vector2.ONE + Vector2.ONE*(sin(time)*power)



	