extends Node2D

# class member variables go here, for example:
# var a = 2
const frameTimerResource = preload("res://frameTimer.gd")
export (float) var duration = 0.5
var timer = null
var wings = []
var animePlayer = null
var particles = null
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	timer = frameTimerResource.new()
	#timer.one_shot = true #set to true to indicate don't conitune ticking (only executed once called)
	timer.connect("timeout",self,"_on_emit_finished")
	self.add_child(timer)

	for c in $particles.get_children():
		wings.append(c)
	
	animePlayer = $AnimationPlayer
	particles = $particles
	
func _on_emit_finished():
	particles.visible=false
	for wing in wings:
		wing.emitting = false
	animePlayer.stop()
	
	

func start():
	particles.visible=true
	#timer.wait_time = duration
	timer.startInSeconds(duration)
	for wing in wings:
		wing.emitting = true
	animePlayer.play("spin-clock-wise")
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
