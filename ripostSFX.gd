extends Particles2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (float) var duration = 2

const frameTimerResource = preload("res://frameTimer.gd")

var timer = null
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	
	timer = frameTimerResource.new()
	#timer.one_shot = true #set to true to indicate don't conitune ticking (only executed once called)
	timer.connect("timeout",self,"_on_finished")
	self.add_child(timer)
	
	pass

func start():
	self.emitting = true
	#timer.wait_time = duration
	timer.startInSeconds(duration)
func _on_finished():
	self.emitting = false
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
