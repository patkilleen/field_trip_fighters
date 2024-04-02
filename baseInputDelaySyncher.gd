extends Node

signal input_delay_changed

#const MINIMUM_BASE_INPUT_LAG = 7
const MINIMUM_BASE_INPUT_LAG = 2 #so anything lower bugs the game loading. I think next step is to have reall ysimple net code for loading game, and once players loaded, then can start synching game with really low input lag and progressivly increase it if latency sucks
const MAXIMUM_BASE_INPUT_LAG = 20



#var synchingBaseInputDelay=false
var newBaseInputDelay=null
var baseInputDelaySynchTick=null
var deltaInputDelay = null
var oldInputDelay=null
var tickUpdatedBaseInputDelay = null
var netMngr = null

#var uninputableTickMap = {}
var enabled = false
var mutex = null

var ignoreTickLeft=-1
var ignoreTickRight=-1

const GLOBALS = preload("res://Globals.gd")

enum State{
	SYNCHRONIZED,
	AWAITING_SYNCH_TICK,
	POST_SYNCH_TICK
}

var pingMutex = null
var processingPing = false
var state = State.SYNCHRONIZED
# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)
	mutex = Mutex.new()
	pingMutex = Mutex.new()
	pass # Replace with function body.

func init(_netMngr):
	netMngr = _netMngr
	state = State.SYNCHRONIZED
	processingPing= false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	#print("physics tick from delay input sync")
	
	#are we synch'ing the base input delay in near future?
	if getSynchingBaseInputDelay():
		var tick= netMngr.getFrameTick()
		#we syncrhonize on this tick?
		if baseInputDelaySynchTick==tick:
			#print("in the tick to set new base input delay")
		#	oldInputDelay=baseInputDelay
			netMngr.baseInputDelay = newBaseInputDelay
			tickUpdatedBaseInputDelay = tick
			mutex.lock()
			state = State.POST_SYNCH_TICK
			mutex.unlock()
			#print("in post synch tick")
		else:
			mutex.lock()
			if state == State.POST_SYNCH_TICK:
				mutex.unlock()
				#arrived at point where no longer synching (since last tick went by)
				if (tick-tickUpdatedBaseInputDelay)-max(netMngr.baseInputDelay,oldInputDelay)==1:
					print("syncrhonized the baes input delay")
					#setSynchingBaseInputDelay(false)
					set_physics_process(false)
					mutex.lock()
					state = State.SYNCHRONIZED
					mutex.unlock()
			else:
				mutex.unlock()


func _on_ping(ping):
		
	if not isEnabled():
		return
		
	var deltaInutDelay = netMngr.netLantencyHandler.inputDelayCheck(netMngr.baseInputDelay,ping)
	
	if deltaInutDelay != 0:
		
		var newBaseInputDelay =max(netMngr.baseInputDelay+deltaInutDelay,MINIMUM_BASE_INPUT_LAG) 
		newBaseInputDelay = min(newBaseInputDelay,MAXIMUM_BASE_INPUT_LAG)
		if newBaseInputDelay != netMngr.baseInputDelay:
			var old =netMngr.baseInputDelay
			changeInputDelay(newBaseInputDelay)
			
			emit_signal("input_delay_changed",netMngr.baseInputDelay,old)
			


#func _on_ping(ping):
		
#	if not isEnabled():
#		return
		
		
#	#make sure only 1 thread processing input delay change
#	var canProceed = false
#	pingMutex.lock()
#	canProceed = not processingPing
	
#	if canProceed:
#		processingPing=true
#	pingMutex.unlock()
	
#	if not canProceed:
#		return 
		
#	var deltaInutDelay = netMngr.netLantencyHandler.inputDelayCheck(baseInputDelay)
	
#	if deltaInutDelay != 0:
		
#		var newBaseInputDelay =max(baseInputDelay+deltaInutDelay,MINIMUM_BASE_INPUT_LAG) 
#		newBaseInputDelay = min(newBaseInputDelay,MAXIMUM_BASE_INPUT_LAG)
#		if newBaseInputDelay != baseInputDelay:
#			var old =baseInputDelay
			
			
			#wait for tick to increment so alway changed delay at end of processing input
#			yield(netMngr.tickCounter,"tick_changed")
			
#			changeInputDelay(newBaseInputDelay)
			
#			emit_signal("input_delay_changed",baseInputDelay,old)
			
#			pingMutex.lock()	
#			processingPing=false
#			pingMutex.unlock()
#	else:
#		pingMutex.lock()	
#		processingPing=false
#		pingMutex.unlock()
#		
#			#TODO: change logic here. The dynamic input delay change isn't working (can't rely on yield to sync wsith
#			#main trhead. gotta only manage loca input manager, ignore remote, and send null inputs when expands
#			#delay and ignore inputs when in windows of decreased input delay
#			#remote input manager should never get a duplicate or have to delay. Should always 
#			#have consistent stream of input comming in each tick
#			#all signal handling should be addressed as well)
#			#need to know if we already sent a local input to peer using current tick + base delay
#			#or if the current tick hasn't been used for delay peer input
#			#var sentInputThisTick = null
#			#if sentInputThisTick:
#				
#			#else:
	
#only host should send this request
#newBaseInputDelay: the new input delay to delay in a brief moment
#tickToSynch: the tick this new base input delay will take place
func _on_request_base_input_lag_sync(_newBaseInputDelay,_tickToSynch):
	
	#print("_on_request_base_input_lag_sync called")
	#don't process a duplicate request message
	if not getSynchingBaseInputDelay():
		
		#synchronize to main thread and then start phsysics process
		#yield(get_tree(),"idle_frame")
		#print("synching with main thread...")
		
		#set_physics_process(true)
		call_deferred("awaitSynchTick",_newBaseInputDelay,_tickToSynch)
		#call_deferred("__on_request_base_input_lag_sync",_newBaseInputDelay,_tickToSynch)
		
	#print("end _on_request_base_input_lag_sync")	

func awaitSynchTick(_newBaseInputDelay,_tickToSynch):
	mutex.lock()
	state = State.AWAITING_SYNCH_TICK
	mutex.unlock()
	newBaseInputDelay=_newBaseInputDelay
	oldInputDelay=netMngr.baseInputDelay
	baseInputDelaySynchTick=_tickToSynch
	deltaInputDelay=newBaseInputDelay-netMngr.baseInputDelay
	#setSynchingBaseInputDelay(true)
	set_physics_process(true)

		
func getBaseInputDelay():
	return netMngr.baseInputDelay
	
#func setSynchingBaseInputDelay(f):
#	mutex.lock()
#	synchingBaseInputDelay = f
#	mutex.unlock()

func getSynchingBaseInputDelay():
	mutex.lock()
	#var res = synchingBaseInputDelay
	var res = state != State.SYNCHRONIZED
	mutex.unlock()
	
	return res

#func isInUninputableTick(tick):
	
	#var tick = netMngr.getFrameTick()
	
#	return uninputableTickMap.has(tick)
		

#func clearUninputableTick(tick):
#	uninputableTickMap.erase(tick)
	
#returns true when were in the tick where inputs can't actually request
#to be played on this tick since we recently changed input delay (the delay increasaed)
#and false otherwise
func OLDisInUninputableTick():
	mutex.lock()
	if state != State.POST_SYNCH_TICK:
		mutex.unlock()
		return false
	mutex.unlock()
	#if getSynchingBaseInputDelay():

	#there may actully not have any logic for when delay reduced, but think about it
	if deltaInputDelay > 0: #don't haven't logic for decreased input delay yet (deltaInputDelay<0)
		#check if logic make sense for border cases
		var minTick = tickUpdatedBaseInputDelay+oldInputDelay
		var maxTick = tickUpdatedBaseInputDelay+ newBaseInputDelay
		
			
		var tick = netMngr.getFrameTick()
		return tick >=  minTick and tick <= maxTick
	else: #we assume here deltaInputDelay can't be 0 by design
	
		#so this is case where we didn't increase base input delay, so can't be in a section that doesn't exist
		return false
		
	#else:
	#	return false
		
#returns true when were in the tick where future inputs could in theory be overrided but shouldn't
#. since we recently changed input delay (the delay decreasaed), so the computation of baseInputDelay + curr tick
#would result in a future tick we sent a few moments ago, so ignore input in these ticks and commit to what plyaer
#has already inputed
#and false otherwise
func isInNonOverridableInputTick():
	mutex.lock()
	if state != State.POST_SYNCH_TICK:
		mutex.unlock()
		return false
	mutex.unlock()
	#if getSynchingBaseInputDelay():
	
	#i don't think any logic required if increase the delay of input
	if deltaInputDelay < 0:
		#check if logic make sense for border cases
		var minTick = tickUpdatedBaseInputDelay+newBaseInputDelay
		var maxTick = tickUpdatedBaseInputDelay+ oldInputDelay
		
		
		var tick = netMngr.getFrameTick()
		return tick >=  minTick and tick <= maxTick
	else: #we assume here deltaInputDelay can't be 0 by design
	
		#so this is case where we didn't increase base input delay, so can't be in a section that doesn't exist
		return false
			
#	else:
#		return false

func isEnabled():
	mutex.lock()
	var res = enabled
	mutex.unlock()
	
	return res
	
func setEnabled(f):
	mutex.lock()
	enabled=f
	mutex.unlock()
	
	
func setBaseInputLagDelay(_newBaseInputLag):
	mutex.lock()
	print("input lag set to: "+str(_newBaseInputLag))
	netMngr.baseInputDelay = _newBaseInputLag
	mutex.unlock()
	

func isTickInsideIgnoreLocalInputWindow(_tick):
	return _tick>=ignoreTickLeft and  _tick<=ignoreTickRight
	
func _on_input_delay_decreased(oldInputDelay,newInputDelay,lastTickSent):
	if newInputDelay >=oldInputDelay:
		print("warning: calling _on_input_delay_decreased but new input delay isn't smaller ")
		return 
		
	
	#e.g.::
	#[input delay, last tick sent,tick]			[peer's remote input manager delayed input buffer]
	#							(last  tick sent is 7 here)
	#[4,8,5]				[5,6,7,8]
	#		-----> 9
	#tick++
	#[4,9,6]				[6,7,8,9]
	#		-----> 10
	#tick++
	#change input delay from 4 to 2 (last tick sent is 10)
	#[2,10,7]				[7,8,9,10]
	#		send nothing, skip local input
	#tick++
	#[2,10,8]				[8,9,10]
	#		send nothing, skip local input
	#tick++
	#[2,10,9]				[9,10]
	#		-----> 11
	#tick++
	#[2,11,10]				[10,11]
	#		-----> 12
	#tick++
	
	
	

	
			
	#e.g.:
	#[input delay, last tick sent]			[peer's remote input manager delayed input buffer]
	#							(last  tick sent is 7 here)
	#[6,12]				[7,8,9,10,11,12]
	#		-----> 13
	#[6,13]				[8,9,10,11,12,13]
	#		-----> 14
	#change input delay from 6 to 3 (last tick sent is 14)
	#[3,14]				[9,10,11,12,13,14]
	#		send nothing, skip local input
	#[3,14]				[10,11,12,13,14]
	#		send nothing, skip local input
	#[3,14]				[11,12,13,14]
	#		send nothing, skip local input
	#[3,14]				[12,13,14]
	#		-----> 15
	#[3,15]				[13,14,15]
	#		-----> 16
	
	var deltaInputDelayDecrease=(oldInputDelay-newInputDelay)
	ignoreTickLeft=lastTickSent-oldInputDelay+1
	
	ignoreTickRight=ignoreTickLeft+deltaInputDelayDecrease-1
	
	#in this example:
	#deltaInputDelayDecrease =4 -2 = 2 
	#ignoreTickLeft = 10 - 4 +1 = 6 + 1 = 7
	#ignoreTickRight = 7 + 2 -1 = 9 -1 = 8
			
func _on_input_delay_increased(oldInputDelay,newInputDelay,lastTickSent):
	
	if newInputDelay <=oldInputDelay:
		print("warning: calling _on_input_delay_increased but new input delay isn't bigger ")
		return 
		
		
	#e.g.:
	#[input delay, tick]			[peer's remote input manager delayed input buffer]
	#							(last  tick sent is 7 here)
	#[3,5]				[5,6,7]
	#		-----> 8
	#[3,6]				[6,7,8]
	#		-----> 9
	#change input delay from 3 to 5 (last tick sent is 9)
	#[5,7]				[7,8,9]
	#		-----> 12
	#[5,8]				[8,9,12] # 10, and 11 are missing
	#here the increased delay is by 2
	#so send next 2 empty future ticks for from 'lasat tick sent' + 1 
	var deltaInputDelayIncrease=(newInputDelay-oldInputDelay)
	var fromTick = lastTickSent + 1
	var toTick = lastTickSent + deltaInputDelayIncrease
	
	
	var i = fromTick
	while i <= toTick:
		var inputJustPressedBitMap = 0
		var inputHoldingBitMap= 0
		var inputReleasedBitMap = 0
		
		
		netMngr.localInputManager.storeInputForFutureTick(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,i)			
		netMngr.sendPeerInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,i)
		netMngr.localInputManager.lastFutureTickSent=i
		i = i + 1



			
func changeInputDelay(newBaseInputDelay):
		print("changing input delay to "+str(newBaseInputDelay)+"....")
		netMngr.localInputManager.inputDelayMutex.lock()
		
		var lastTickSent = netMngr.localInputManager.lastFutureTickSent
		#wait for the inputs to have been send/processed
		#yield(netMngr.tickCounter,"tick_changed")
		#at this point, were at a new tick where for current tick no input was process/sent
		var old = netMngr.baseInputDelay
		netMngr.baseInputDelay =newBaseInputDelay
		
		if netMngr.baseInputDelay >old:
			 _on_input_delay_increased(old,netMngr.baseInputDelay,lastTickSent)
		else:
			#CALLING THIS isn't necessary. TODO: remove unused code (online input manager donesn't need the window)
			_on_input_delay_decreased(old,netMngr.baseInputDelay,lastTickSent)
			
		#print("new recommended base input delay: "+str(_newBaseInputDelay))
	
			
		netMngr.localInputManager.inputDelayMutex.unlock()