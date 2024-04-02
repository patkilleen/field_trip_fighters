extends Node

var thread = null


var active = false

const GLOBALS = preload("res://Globals.gd")
var deadlockCheckThread = null
var mutex = null
var tickCounter = null
var netMngr = null
#inputs that have not yet been acknoledged as received
var unackedInputMaps = [{},{},{},{}]

const RESEND_FLAG=true
var deadlockCounter = 0

var deadlockMutex = null

#var ticksBeforeResendOffset = 0
var msBeforeResendOffset = 0
const JUST_PRESSED_MAP_IX = 0
const HOLDING_MAP_IX = 1
const RELEASED_MAP_IX = 2
const TIME_MS_WHEN_RESEND_IX = 3

const DEBUG_PRINT_FLAG = false 

#const RESEND_CHECK_DELAY_MS = 3*GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS #EVERY 3 FRAMES DO CHECK
const RESEND_CHECK_DELAY_MS = GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS/2.0 #twice per frame to make sure didn't miss msg
var unAckedMsgCount = 0
func _ready():
	
	thread = Thread.new()
	
	mutex = 	Mutex.new()


func start(_netMngr,_msBeforeResend, _tickCounter):
	
	if _netMngr == null or _tickCounter == null:
		print("can't start net msg resender: null params")
		return
	
	
		
	#we don't need nay deadlock check. the code is good I think	
	if _netMngr.DEBUG_DEADLOCK_CHECKING_ENABLED:
		deadlockMutex = Mutex.new()
		deadlockCheckThread = Thread.new()
	
	
	#ticksBeforeResendOffset = _ticksBeforeResendOffset
	msBeforeResendOffset =_msBeforeResend
	
	#print("ticks before resend msg: "+str(ticksBeforeResendOffset))
	tickCounter = _tickCounter
	netMngr = _netMngr
	active=true
	var rc = thread.start(self,"_workerFunc",[]) 
	if rc != OK:
		
		print("failed to start TCP netowrk rpc thread")
		active=false
		return
	
	#we don't need nay deadlock check. the code is good I think	
	if _netMngr.DEBUG_DEADLOCK_CHECKING_ENABLED:
		deadlockCheckThread.start(self,"_deadlockChecker",[]) 
	
#stops  thread and waits for it to finish
func stop():
	
	
	#stop thread
	active = false
	
	#wait for worker to finish
	if thread != null:
		thread.wait_to_finish()
		thread = null
		
	if deadlockCheckThread != null:
		deadlockCheckThread.wait_to_finish()	
		deadlockCheckThread = null


func setTimerBeforeResendOffset(_msBeforeResend):
	mutex.lock()
	#ticksBeforeResendOffset = _ticksBeforeResendOffset
	msBeforeResendOffset =_msBeforeResend
	mutex.unlock()
#called when input is sent to peer
func _on_msg_sent(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick):
	#var tick = getFrameTick()
		
		var tick =tickCounter.getTick()
		var time = OS.get_system_time_msecs()
		var timeBeforeResend = msBeforeResendOffset + time
		
		mutex.lock()
		
		#store the message were sending to keep trac of messages that have been received
		if hasUnackedMessage(futureTick):
			if DEBUG_PRINT_FLAG:
				print("(tick: "+str(tick)+")warning, sending 2nd mesage to be played on same future tick: "+str(futureTick)+"  as other input")
			
			
		#delay the time to process the input by input delay		
		unackedInputMaps[JUST_PRESSED_MAP_IX][futureTick]=inputJustPressedBitMap
		unackedInputMaps[HOLDING_MAP_IX][futureTick]=inputHoldingBitMap
		unackedInputMaps[RELEASED_MAP_IX][futureTick]=inputReleasedBitMap
		unackedInputMaps[TIME_MS_WHEN_RESEND_IX][futureTick]=timeBeforeResend
		
		unAckedMsgCount = unAckedMsgCount +1
		mutex.unlock()
func _on_msg_ack_received(futureTick):
	mutex.lock()
	
	#duplicate acks received? no big deal, do nothing
	if not hasUnackedMessage(futureTick):
		#print("warning,received ack for input (tick: "+str(tickToPlay)+") we didn't send")
		pass
	else:
		#erace the input  packet to indicate it has been received and avoid resending it after timeout
		unackedInputMaps[JUST_PRESSED_MAP_IX].erase(futureTick)	
		unackedInputMaps[HOLDING_MAP_IX].erase(futureTick)							
		unackedInputMaps[RELEASED_MAP_IX].erase(futureTick)
		unackedInputMaps[TIME_MS_WHEN_RESEND_IX].erase(futureTick)
		
		unAckedMsgCount = unAckedMsgCount - 1
	mutex.unlock()	 
		
		

#not thread safe, have to lock mutrex outside
#returns true if for given tick the message hasn't been acnoledge
func hasUnackedMessage(tick):
	
	return unackedInputMaps[JUST_PRESSED_MAP_IX].has(tick)

#returns true when no messages unackednoledged
func isEmptyUnackedMessages():
	mutex.lock()
	#var keys = unackedInputMaps[JUST_PRESSED_MAP_IX].keys()
	#var res =keys.empty()
	var res = unAckedMsgCount ==0
	mutex.unlock()
	
	return res
	
#publishes array of parameters t
func _workerFunc(params):
	var time  = OS.get_system_time_msecs()
	var startTime =time
	var delay = int(RESEND_CHECK_DELAY_MS)
	#var threadTickEllapsedTime =0
	while(active):
		
		OS.delay_msec(delay)
		
		if deadlockMutex != null:
			deadlockMutex.lock()
			deadlockCounter= 0
			deadlockMutex.unlock()
			
		#threadTickEllapsedTime = OS.get_system_time_msecs()- startTime
		
		#only check to resend messages once per frame
		#if threadTickEllapsedTime > 1 *GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS:
		#startTime=OS.get_system_time_msecs()
		#only proceed if unack'ed messages exist
		if not isEmptyUnackedMessages():
		
			time  = OS.get_system_time_msecs()
			
			#var delayedResendTick= tick +ticksBeforeResendOffset
			
			mutex.lock()
			
			#iterate over the inputs sent
			for futureTick in unackedInputMaps[JUST_PRESSED_MAP_IX].keys():
				
				var timeWhenReplay = unackedInputMaps[TIME_MS_WHEN_RESEND_IX][futureTick]
				
				#have we reached the deadline to resend the messages (no ack received in time?)
				if time >= timeWhenReplay:
					var inputJustPressedBitMap = unackedInputMaps[JUST_PRESSED_MAP_IX][futureTick]
					var inputHoldingBitMap = unackedInputMaps[HOLDING_MAP_IX][futureTick]
					var inputReleasedBitMap = unackedInputMaps[RELEASED_MAP_IX][futureTick]
					
					#now, make sure to refresh the tick timer of when to resend (we don't want to resend next tick
				#so any msg resent should be delayed before resent again)
					var timeBeforeResend = msBeforeResendOffset + time
					unackedInputMaps[TIME_MS_WHEN_RESEND_IX][futureTick]=timeBeforeResend
					
					#if get_tree().is_network_server():

					#print("["+str(tick)+"] re----sending input : "+str(futureTick))
					if DEBUG_PRINT_FLAG:
						print("RE----")
					
					netMngr._sendPeerInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick,RESEND_FLAG)
					
	
			mutex.unlock()

	#sleep for a tick
	#yield(get_tree().create_timer(GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS),"timeout")
		
	pass
	
	
func _deadlockChecker(params):
	var deadlockDebugPrintFlag =true
	var startTime = OS.get_system_time_msecs()
	var ellapsedTime=0
	var delay =int(10 *GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS)
	while(active):
		#ellapsedTime = OS.get_system_time_msecs()- startTime
		#EVERY 10 FRAMES MAKE THE CHECK BY having thread sleep for 10 ticks
		OS.delay_msec(delay)
		
		
		#if ellapsedTime > 10 *GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS:
		#	startTime=OS.get_system_time_msecs()
		deadlockMutex.lock()
		deadlockCounter= deadlockCounter +1
		if deadlockCounter > 100:
			if deadlockDebugPrintFlag:
				print("possible deadlock in network msg resender")
				deadlockDebugPrintFlag=false
		deadlockMutex.unlock()
			#yield(get_tree().create_timer(GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS),"timeout")
		