extends Particles2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal finished_emitting

const frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")

var GLOBALS = preload("res://Globals.gd")
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD
var timer = null

export (bool) var pauseOnHitFreeze = true
#var frameTimerResource = preload("res://frameTimer.gd")
#var frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")

var defaultSpeedScale = 1
#var defaultLifeTime = 1

var inHitFreezeFlag = false
var speedBeforeHitFreeze = null
func _ready():
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
#	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	#timer = Timer.new()
	timer = frameTimerResource.new()
	#timer = frameTimerResource.new()
	#timer.one_shot = true #set to true to indicate don't conitune ticking (only executed once called)
	timer.connect("timeout",self,"_finished_emitting")
	#self.call_deferred("add_child",timer)
	add_child(timer)
	
	defaultSpeedScale = self.speed_scale
	#defaultLifeTime = self.defaultLifeTime
	self.speed_scale = defaultSpeedScale*globalSpeedMod

	#timer.owner = self

#func set_speed_scale(value):
#	.set_speed_scale(value)
#	defaultSpeedScale = value
	
func setGlobalSpeedMod(g):
	globalSpeedMod = g
	self.speed_scale = defaultSpeedScale*globalSpeedMod
	
func set_emitting(value):

	#starting to emit?
	if (self.emitting == false) and (value == true):

		#var timeToWaitInSeconds = self.lifetime / self.speed_scale
		#ready the timer to stop particles from constatnly exploding
		
		var waitTime = configureTimerWaitTime()
		#timer.startInSeconds(timeToWaitInSeconds)
		timer.startInSeconds(waitTime)

	self.emitting = value
	
func configureTimerWaitTime():
	if inHitFreezeFlag and pauseOnHitFreeze:
		#timer.wait_time = self.lifetime / speedBeforeHitFreeze #we put speed to 0 for particles in hitfreeze, so gotta use the original speed
		return	self.lifetime / speedBeforeHitFreeze
	else:
		#timer.wait_time = self.lifetime / self.speed_scale
		if self.speed_scale != 0:
			return self.lifetime / self.speed_scale
		else:
			return	self.lifetime / speedBeforeHitFreeze
func _finished_emitting():
	self.emitting = false
	emit_signal("finished_emitting")
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _on_hit_freeze_finished():
	if pauseOnHitFreeze:
		#timer.paused = false
		if inHitFreezeFlag:
			if speedBeforeHitFreeze != null:
				self.speed_scale = speedBeforeHitFreeze
				speedBeforeHitFreeze=null
				inHitFreezeFlag = false
		
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	
	if pauseOnHitFreeze:
		#timer.paused = true
		if not inHitFreezeFlag:
			if duration > 0:
				inHitFreezeFlag=true
				speedBeforeHitFreeze = speed_scale
				self.speed_scale = 0