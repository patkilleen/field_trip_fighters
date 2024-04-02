extends "res://frameTimer.gd"

var pausedInHitFreezeFlag = false
var inHitFreeze = false

func reset():
	.reset()
	pausedInHitFreezeFlag = false
	inHitFreeze = false

#to be implemented as hook by subclass
func _on_hit_freeze_finished():
	inHitFreeze=false
	if pausedInHitFreezeFlag:
		pausedInHitFreezeFlag=false
		self.set_physics_process(true)
	
	
#to be implemented as hook by subclass
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	
	handleHitFreezeStarted()
	
func handleHitFreezeStarted():
	inHitFreeze=true
	if is_physics_processing():
		pausedInHitFreezeFlag=true
		self.set_physics_process(false)
	pass
	
	

func startInSeconds(_lengthInSeconds):
	.startInSeconds(_lengthInSeconds)
	if inHitFreeze:

		#don't emidiatly start, wait till hitfreeze is complete before starting
		pausedInHitFreezeFlag=true
		set_physics_process(false)
	
		
	
func start(_lengthInFrames):
	.start(_lengthInFrames)
	if inHitFreeze:

		#don't emidiatly start, wait till hitfreeze is complete before starting
		pausedInHitFreezeFlag=true
		set_physics_process(false)
	