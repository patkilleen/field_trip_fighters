extends Particles2D
signal finished
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var timer = null
func _ready():
#	timer = Timer.new()
#	timer.one_shot = true #set to true to indicate don't conitune ticking (only executed once called)
#	timer.connect("timeout",self,"_finished_emitting")
#	self.add_child(timer)
	pass

func set_emitting(value):
	#starting to emit?
	#if (self.emitting == false) and (value == true): 
	#if (value == true): 
		#ready the timer to stop particles from constatnly exploding
	#	timer.wait_time = self.lifetime / self.speed_scale
	#	timer.start()

	self.emitting = value
	
	
func _finished_emitting():
	self.emitting = false
	#emit_signal("finished")
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
