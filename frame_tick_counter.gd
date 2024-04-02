extends Node

signal tick_changed
var tick = 0

#var mutex = null
#var tickLimit = 0
var mutex = null
func _ready():
	#set_physics_process(false)
	mutex = Mutex.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta):
	
	#can't increase tick passed the largest future tick peer acknoledge 
#	if tick +1 <= tickLimit:
#	incrementTick()
	
func reset():
	
	#call_deferred("set_physics_process",true)
	mutex.lock()
	tick = 0
	mutex.unlock()
	
func setTick(_tick):
	mutex.lock()
	tick = _tick	
	mutex.unlock()
	
func getTick():
	var res = null
	mutex.lock()
	res =tick
	mutex.unlock()
	
	return tick
	
func incrementTick():
	mutex.lock()
	tick = tick +1
	mutex.unlock()
	
	
	#call_deferred("emit_signal","tick_changed",tick)
	emit_signal("tick_changed",tick)