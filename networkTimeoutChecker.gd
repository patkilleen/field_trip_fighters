extends Node

signal connection_timeout
var thread = null

var active = false

var netMngr = null

const GLOBALS = preload("res://Globals.gd")

const ELLAPSED_TIME_MS_BEFORE_TIMEOUT=GLOBALS.MILLISECONDS_PER_SECOND*3 #3 SECONDS BEFORE TIMEOUT
func _ready():
	
	thread = Thread.new()

	
func start(_netMngr):
	
	active=true
		
	netMngr = _netMngr

	var rc = thread.start(self,"_timeoutWorker",[]) 
	if rc != OK:
		
		print("failed to start network timeout thread")
		active=false
		return
	

#stops  thread and waits for it to finish
func stop():
	
		#stop thread
	active = false
	
	#wait for worker to finish
	if thread != null:
		thread.wait_to_finish()
		thread = null
	
	
	
func _timeoutWorker(param):
	#var peer = get_tree().network_peer	
	
	
	var delay = GLOBALS.MILLISECONDS_PER_SECOND#1 SECOND OF DELAY
	
	var oldTick = netMngr.getFrameTick()
	var newTick = null
	var startTime = OS.get_system_time_msecs()
	var ellapsedTime = 0
	while(active):
		
		
		
		
		#we sleep most of time (the duration before timeout occurs)
		OS.delay_msec(delay)
		
		ellapsedTime = OS.get_system_time_msecs() - startTime
		
		#reach point to check for timeout?
		if ellapsedTime >= ELLAPSED_TIME_MS_BEFORE_TIMEOUT:
				
			#restart tracking ellapsed time again
			startTime=OS.get_system_time_msecs()
			ellapsedTime=0
						
			newTick = netMngr.getFrameTick()
			
			#main thread blocked for at least ELLAPSED_TIME_MS_BEFORE_TIMEOUT milliseconds?
			#that is, a timeout occured?
			#no change in tick since sleep?
			if newTick == oldTick:
				active = false
				emit_signal("connection_timeout")
			else:
				oldTick = newTick
	
	