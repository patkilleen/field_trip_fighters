extends TextureProgress


#timer used to track angry duration
var angryTimer = null

func _ready():
	stop()
	pass # Replace with function body.

func init(_angryTimer):
	angryTimer = _angryTimer
	stop()
func start():	
	value = max_value
	visible = true
	set_physics_process(true)
	pass	
func stop():
	set_physics_process(false)
	value = max_value
	visible = false

func _physics_process(delta):
	value =max_value-angryTimer.ellapsedTimeInSeconds
	pass
