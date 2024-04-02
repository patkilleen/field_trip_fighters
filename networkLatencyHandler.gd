extends Node
signal ping

const GLOBALS = preload("res://Globals.gd")
const frameTimerResource = preload("res://frameTimer.gd")
const LATENCY_COUNT_BEFORE_AVERAGE = 5
const LATENCY_MID_IX=LATENCY_COUNT_BEFORE_AVERAGE/2.0
const PING_FREQUENCY = 8.0 #8 times per second check ping

var latency_array = []
#const LATENCY_INPUT_DELAY_BOUNDARY_MOD = 0.7
const LATENCY_INPUT_DELAY_BOUNDARY_MOD = 1
var avgLatency = 0

var determineLatencyMutex = null
var timer = null
const MEAN_AVG_LATENCY_MOVING_WINDOW_SIZE = 4
var meanAvgLatencyArray=[]
var netMngr = null

var thread = null
var keepThreadAlive = false

var enabled = true
# Called when the node enters the scene tree for the first time.
func _ready():

	pass

func init(_netMngr):
	
	latency_array.clear()
	netMngr = _netMngr
	determineLatencyMutex = Mutex.new()
	
	if netMngr.isHost:
		thread = Thread.new()
	#timer used to delay latency computation check
	timer = frameTimerResource.new()
	#timer.wait_time = 0.5
	timer.connect("timeout",self,"determineLatency")
	self.add_child(timer)

func startPingWorker():
	if thread != null:
		keepThreadAlive = true
		var rc = thread.start(self,"_latencyWorker",[]) 
		if rc != OK:
			
			print("failed to start ping thread worker")

func delayedDetermine_latency():
	
	#call the determine latency funciont after half a second
	#if timer.is_stopped():
	if not timer.is_physics_processing():
		timer.startInSeconds(0.5)
	else:
		#tgimer will ellapse soon, no need to restart it
		pass
	
#step 1		
func determineLatency():
	if netMngr.connected:
		#rpc("_on_determine_latency",getFrameTick())
		#rpc("_on_determine_latency",OS.get_system_time_msecs())
		#networkRPCWorker.asyncrhonousRCP(["_on_determine_latency",OS.get_system_time_msecs()])
		#netPublisher.peerTCP_RPC("_on_determine_latency",[OS.get_system_time_msecs()])
		netMngr.netPublisher.peerUDP_RPC("_on_determine_latency",[OS.get_system_time_msecs()])
	

#step 2	
remote func _on_determine_latency(peerOSTime):
	if netMngr.connected:
		#rpc("_on_determine_latency_ack",peerOSTime)
		#networkRPCWorker.asyncrhonousRCP(["_on_determine_latency_ack",peerOSTime])
		netMngr.netPublisher.peerUDP_RPC("_on_determine_latency_ack",[peerOSTime])

#step 3
#this functio ncomputes the average latency, although it isn't used at the moment
remote func _on_determine_latency_ack(osTimeSent):
	
	var emitSignalFlag = false
	#var latency = (getFrameTick()-peerTick)/2.0
	var latency = (OS.get_system_time_msecs()- osTimeSent)/2.0
	
	determineLatencyMutex.lock()
	latency_array.append(latency)
	
	var latencyCount = 0
	if latency_array.size() == LATENCY_COUNT_BEFORE_AVERAGE:
		var total_latency = 0
		latency_array.sort()
		
		var mid_point = latency_array[int(floor(LATENCY_MID_IX))]
		
		for i in range(latency_array.size()-1,-1,-1):
			#if latency_array[i] >(2*mid_point) and latency_array[i]>2.5: #REMOVE extreme values but allows super fast connections of 2.5 ticks or less
			if latency_array[i] >(2*mid_point) and latency_array[i]>20: #REMOVE extreme values but allows super fast connections of 20ms or less
#				latency_array.remove(i)
				pass
			else:
				latencyCount = latencyCount +1
				total_latency+=latency_array[i]
				
		
		#update the input lag 
		#baseInputDelay = max(delta_latency,MINIMUM_BASE_INPUT_LAG) #should match the timne it takes to send message to opponent
		
		if latencyCount != 0:
			avgLatency = total_latency / latencyCount
			
			if meanAvgLatencyArray.size() > MEAN_AVG_LATENCY_MOVING_WINDOW_SIZE:
				meanAvgLatencyArray.pop_back()
			meanAvgLatencyArray.push_front(avgLatency)
			
			if netMngr.DEBUG_PRINT_FLAG:
				print("new latency: ",avgLatency)
			#netMngr.call_deferred("emit_signal","ping",avgLatency)
			#call_deferred("emit_signal","ping",avgLatency)
			emitSignalFlag = true
			#emit_signal("ping",avgLatency)
#		print("baseInputDelay: "+str(baseInputDelay))
		#print("**")
		latency_array.clear()
		
	determineLatencyMutex.unlock()

	if emitSignalFlag:
		emit_signal("ping",avgLatency)
func computeMeanPing():
	determineLatencyMutex.lock()
	var mean = 0
	
	if meanAvgLatencyArray.size() != 0:
			
		for _latency in meanAvgLatencyArray:
			mean=mean+_latency
		
		mean =mean/meanAvgLatencyArray.size()
		
	else:
		mean = 0
	determineLatencyMutex.unlock()
	
	return mean

#RETURNs 0 if the input delay doesn't need to change and returns by
#how much it changes (positive for increse, negative for decrease) if it 
#requires change
func inputDelayCheck(_baseInputDelay,_ping):
	
	#var meanPing= computeMeanPing()
	#var meanPing = getPing()
	
	if _baseInputDelay < 0:
		_baseInputDelay = 0
	#uppoer bound on ping that won't have lag given input delay
	#minimum 0 max ping, and -1 to make sure were not on border getting lag
	#so any ping whitin a tick's time of upper bound considered out of bounds
	#var upperBoundPing =  max(_baseInputDelay,netMngr.baseInputDelaySyncher.MINIMUM_BASE_INPUT_LAG)  * GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS 
	
	var deltaInputDelay = null
	#var lowerBoundPing = max(_baseInputDelay-2,netMngr.baseInputDelaySyncher.MINIMUM_BASE_INPUT_LAG) * GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS 
		
	#if meanPing > upperBoundPing or meanPing < lowerBoundPing:
	#var pingInTicks = int(ceil(meanPing/GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS))
	var pingInTicks = int(ceil((_ping/LATENCY_INPUT_DELAY_BOUNDARY_MOD)/GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS))
		
	deltaInputDelay =(pingInTicks- _baseInputDelay)
	
	#don't change it if the input delay is only 1 away, since might introduce bounder cases
	#if abs(deltaInputDelay) <=1:
	#	deltaInputDelay=0
		
	#else:
	#	deltaInputDelay= 0
	
	return deltaInputDelay


func _getRecommendedInputDelay(_meanPing):
	
	#the average ping, divide by 0.9 to rise abit to consider latency jitter
	#and round up to be safe
	return int(ceil((_meanPing/LATENCY_INPUT_DELAY_BOUNDARY_MOD)/GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS))
	
func getRecommendedInputDelay():
	var meanPing = computeMeanPing()
	return _getRecommendedInputDelay(meanPing)
	
	
	
func getPing():
	var res = 0
	determineLatencyMutex.lock()
	res = avgLatency
	determineLatencyMutex.unlock()
	
	return res
	

func getPingInTicks():
	var _ping = getPing()
	
	#convert ping to number of ticks
	return int(ceil(_ping/GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS))
	
	#don't compute ping on same tick
	#if isHost:
	#	if getFrameTick() % TICK_DETERMINE_LATENCY_FREQUENCY == 0:
	#		netLantencyHandler.determineLatency()
	#else:
	#	if getFrameTick() % (TICK_DETERMINE_LATENCY_FREQUENCY+5) == 0:
	#		netLantencyHandler.determineLatency()
		
func _latencyWorker(params):
	
	#var checkPointTime  = OS.get_system_time_msecs()
	var ellapsedTime=0
	#example:
	#30 times per second
	#60 frames per second
	#so 60 / 30 = 2, which means wait 2 ticks before sending
	#a tick is GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS (16.666 ms)
	#so sleep time in ms = (60 / 30) *  GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS 
	var sleepTimeMs =(float(GLOBALS.FRAMES_PER_SECOND)/PING_FREQUENCY) *GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS
	print("lseep time in ms for ping worker: "+str(sleepTimeMs))
	while keepThreadAlive:
		
		#wait a moment to satisfy the ping frequency requirement (dont' busy wait)
		OS.delay_msec(sleepTimeMs)
		
		if not enabled:
			continue
		if netMngr.connected:
			
			determineLatency()
		
func stop():
	
	keepThreadAlive= false
	
	if thread != null:
		thread.call_deferred("wait_to_finish")
		thread = null
	

func disable():	
	determineLatencyMutex.lock()
	latency_array.clear()
	avgLatency = 0
	meanAvgLatencyArray.clear()
	enabled=false
	determineLatencyMutex.unlock()

func _exit_tree():
	stop()