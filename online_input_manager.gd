extends "res://input_manager.gd"

signal finished_processing_input
signal local_input_handler_processed_input

var networkingMngr = null

var isRemotePeer=null

const btnsMaks = [BTN_A,BTN_B,BTN_X,BTN_Y,BTN_LEFT,BTN_RIGHT,BTN_UP,BTN_DOWN,
BTN_RIGHT_BUMPER,BTN_START,BTN_RIGHT_TRIGGER,BTN_LEFT_TRIGGER,BTN_LEFT_BUMPER,
BTN_C_STICK_LEFT,BTN_C_STICK_RIGHT,BTN_C_STICK_UP,BTN_C_STICK_DOWN]


var dealyedInputMaps = [{},{},{}]

var semaphore = null

#var lagOccuredPrintOnceFlag = false

var delayedInputBufferMutex = null
var inputDelayMutex = null

var waitingForPeerMutex = null

var waitingForPeerInput = false

var pollInputResBuffer =[]

const DEBUG_PRINT_FLAG = false

var readyToSemaphorePost =false

var lastFutureTickSent = null

var localInputHandlerProcessedInput = false
func _ready():
	pass # Replace with function body.

#_isRemotePeer false for local player's character and true for the online opponent's character
func initNetwork(_networkingMngr,_isRemotePeer):
	networkingMngr = _networkingMngr
	isRemotePeer=_isRemotePeer
	semaphore = Semaphore.new()
	delayedInputBufferMutex = Mutex.new()
	inputDelayMutex = Mutex.new()
	#waitingForPeerMutex = Mutex.new()
	#resetDelayedInputBuffer()
	
func resetDelayedInputBuffer():
	
	delayedInputBufferMutex.lock()
	#delete all buffered input
	for map in dealyedInputMaps:
		map.clear()
	
	delayedInputBufferMutex.unlock()
	
#	var firstEmptyTicks =  networkingMngr.getFrameTick() +2*(networkingMngr.baseInputDelay) # x2 to make sure now latency-based tick wait issues when first connected
	#var firstEmptyTicks = 2*networkingMngr.baseInputDelay # x2 to make sure now latency-based tick wait issues when first connected
	#var firstEmptyTicks = networkingMngr.baseInputDelay + networkingMngr.getFrameTick()
	#make sure to store first empty commands (there might be desync issues first few frames, but this stops initaail latency issues)
#	print("making the first "+str(firstEmptyTicks)+" ticks empty ")
#	for i in firstEmptyTicks:
#		storeInputForFutureTick(0,0,0,i)
		#semaphore.post() #make sure the polling of input doesn't block for first few empty ticks
		
		
func physics_process_hook(delta):

	if inputDeviceId != null:
					
		#here we store the input temporarily while waiting for peer's command to arrive
		#var inputJustPressedBitMap = 0
		#var inputHoldingBitMap = 0
		#var inputReleasedBitMap = 0
		
		
		
			
		#store the bit map of buttons pressed in a buffer (so sub classes can make use of logic)
		#do it this way cause can't return3 variables
		_parseBtnBitMaps()
		
		
		var inputJustPressedBitMap = btnBitMapBuffer[JUST_PRESSED_MAP_IX]
		var inputHoldingBitMap = btnBitMapBuffer[HOLDING_MAP_IX]
		var inputReleasedBitMap = btnBitMapBuffer[RELEASED_MAP_IX]
				
				
		
		#var btnKeys = pInRemap.keys()
		#iterate all buttons to create bit map
		#for k in btnKeys:
			
			#remapping of buttons made it so a button maps to no input?
		#	if pInRemap[k] == null:
				#continue
				
			#tranlate button id to device button (2 different devices have same button)
			#differentiate devices via inputDevice id. Needd to map this in input seetings
		#	var inputId = inputDeviceId+"_"+k
			#check if player just pressed it
		#	if Input.is_action_just_pressed(inputId):
		#		inputJustPressedBitMap = inputJustPressedBitMap | pInRemap[k]
		#	elif Input.is_action_just_released(inputId):
				#C-stick only supports 1 frame button presses (no holding or releasing)
		#		if cStickBtnKeyMap.has(k):
		#			continue
		#		inputReleasedBitMap = inputReleasedBitMap | pInRemap[k]
		#	elif Input.is_action_pressed(inputId):
				#C-stick only supports 1 frame button presses (no holding or releasing)
		#		if cStickBtnKeyMap.has(k):
		#			continue
		#		inputHoldingBitMap = inputHoldingBitMap | pInRemap[k]
		
		#local input?
		if not isRemotePeer:
			
			inputDelayMutex.lock()
			
			#do this check cause mause have been waiting on input and connection lost (game has to have started)
			#when control came back to main thread
			if networkingMngr.tickCounter == null:
				set_physics_process(false)
				return null


			var tick = networkingMngr.getFrameTick()
			#in case the input delay shrunk and we have to skip ticks to sync
			#ingore input
			#if not networkingMngr.baseInputDelaySyncher.isTickInsideIgnoreLocalInputWindow(tick):
		
			#var processLocalInputFlag = not networkingMngr.baseInputDelaySyncher.isEnabled()
			#processLocalInputFlag = processLocalInputFlag or not hasInput(tick)
			#process local input any time when input delay handling isn't active
			#and when it is active, then we only process for ticks not encountered yet (will
			#skip frames when decr3eased delay) 
			
			#var processLocalInputFlag = true #for now alsway rpcoess it
			#if processLocalInputFlag:
				
				#if hasInput(tick) and readyToSemaphorePost and networkingMngr.isTickAfterGameStart(tick):
					#processing a duplicate tick cause input delay decreased. skip and don't block main thread (ocunt as two inputs)
				#	semaphore.post()	
				#else:
					
			var futureTick = tick+networkingMngr.getBaseInputDelay()
			
			
			#only send to peer an input for a new tick. in case input delay changes, some ticks may already have input
			#we wouldn't want peer to receive an input we ignored but they prcoess it
			if not hasInput(futureTick): #TODO: consider not attempting to tstore the input at all when already present
				networkingMngr.sendPeerInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick)
				
				lastFutureTickSent = futureTick
				#have to wait for ack to store local input
				storeInputForFutureTick(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick)
				
			#else:
				#if hasInput(tick):
				#processing a duplicate tick cause input delay decreased. skip and don't block main thread (ocunt as two inputs)
			#	semaphore.post()
			inputDelayMutex.unlock()
			
			

	processDelayedInput()
	pass

func processDelayedInput():
	
	#we need to guarantee execution order.
	#the local input manager processes input first.
	#then the remote input manager pprocesse input
	
	if isRemotePeer:
		
		#local input manager didnt' process input yet?
		if not localInputHandlerProcessedInput:
			#wait for local input manager to finish processing
			yield(self,"local_input_handler_processed_input")
	
	if not networkingMngr.connected:
		return
	
	var tick = networkingMngr.getFrameTick()


	var resArray = pollDelayedInput(tick)
	
	if resArray == null:
		return
	var inputJustPressedBitMap = resArray[JUST_PRESSED_MAP_IX]
	var inputHoldingBitMap = resArray[HOLDING_MAP_IX]
	var inputReleasedBitMap = resArray[RELEASED_MAP_IX]		
	

	delayedInputBufferMutex.unlock()
	

					
	processInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap)
	
	
	#if isRemotePeer:
	#only incroment tick after both input devices
	#if self.inputDeviceId == GLOBALS.PLAYER2_INPUT_DEVICE_ID:
	#	networkingMngr.tickCounter.incrementTick()
	
	if isRemotePeer:
		localInputHandlerProcessedInput=false
	emit_signal("finished_processing_input")
	
		

func pollDelayedInput(tick):
	#don't process any ticks that before delay to make sure commands
	#process at same time and irrelevant to latency
	#if tick < networkingMngr.baseInputDelay:
	if not networkingMngr.readyForDelayedInput():
			#null input
		return createNullInputArray()
		
	#were at a tick where recently change base input delay and now it's impossible at this 
	#tick that input is availalble so process as if null input
	#if networkingMngr.baseInputDelaySyncher.isInUninputableTick(tick):
	#	networkingMngr.baseInputDelaySyncher.clearUninputableTick(tick)
		#print("null input since in uninputable tick")
	#	return createNullInputArray()
		
	
	var noInputAvailable = true
	
	while noInputAvailable:
		
		#this shouldn't block for first few ticks as we buffered in empty
		#inuts to prevent desync issues (potential source of desyncrhonization at start...)
		#waitingForPeerMutex.lock()
		waitingForPeerInput=true
		
		
		#could this be causeing a desynch?
		#since remote peer and local peer process input in different order depdning on 
		#client or host, here we could be waitinf for peer to send input whlie
		#we processed local input, and other the other peer the local input wasn' tprocessed 
		#and we waiting. I think it's fine, but if all else fails look into this, cause remote input
		#manager's process input doesn't necessarily go after local input process
		if not isRemotePeer:
			semaphore.wait()
				
		#waitingForPeerMutex.unlock()
		#waitingForPeerInput=false
		
		#netowrk insn't initialized, or a disconnect occured, or we are no longer ready for input?
		#if not networkingMngr.connected and isRemotePeer:
		if not networkingMngr.connected or not networkingMngr.initialized or not networkingMngr.readyForDelayedInput():
			set_physics_process(false)
			return null

		#DEADLOCK HERE!
		delayedInputBufferMutex.lock()
		waitingForPeerInput=false
		#no input for tick we have been waiting on (maybe a future packet arrived early before
		#the one we were expecting)?
		if not dealyedInputMaps[JUST_PRESSED_MAP_IX].has(tick):
			
			#if not isRemotePeer:
			#	print("internal design issue, local input manager has no delayed input available")
				
			#semaphore.post() # the input that came in to unblock this step wasn't necessary this tick, so re-increment counter
			delayedInputBufferMutex.unlock()
			noInputAvailable=true
			
			if DEBUG_PRINT_FLAG:
				print("")
				print("*************************************************")
				if networkingMngr.isServer():						
					if isRemotePeer:
						
						print("[remote - server: "+str(tick)+"] locked waiting for remote peer's input")
					else:
						print("[local - server: "+str(tick)+"] locked waiting for remote peer's ack of our input")
				else:
					if isRemotePeer:
						print("[remote - client "+str(tick)+"] locked waiting for remote peer's input")
					else:
						print("[local - client "+str(tick)+"] locked waiting for remote peer's ack of our input")
						
				print("*************************************************")
				print("")
					
			continue
		
		#at this point we have input
		#re-use the same buffer
		pollInputResBuffer.clear()
		
		
		var inputJustPressedBitMap = dealyedInputMaps[JUST_PRESSED_MAP_IX][tick]	
		var inputHoldingBitMap = dealyedInputMaps[HOLDING_MAP_IX][tick]	
		var inputReleasedBitMap = dealyedInputMaps[RELEASED_MAP_IX][tick]
		
		pollInputResBuffer.append(inputJustPressedBitMap)
		pollInputResBuffer.append(inputHoldingBitMap)
		pollInputResBuffer.append(inputReleasedBitMap)
		
			#free up some memory
		dealyedInputMaps[HOLDING_MAP_IX].erase(tick)
		dealyedInputMaps[JUST_PRESSED_MAP_IX].erase(tick)	
		dealyedInputMaps[RELEASED_MAP_IX].erase(tick)
		
		
		delayedInputBufferMutex.unlock()
		
		return pollInputResBuffer
		

func storeInputForFutureTick(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick):	
#	var ignorePostOnDuplicateFlag = true
#	_storeInputForFutureTick(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick,ignorePostOnDuplicateFlag)
#func _storeInputForFutureTick(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick,ignorePostOnDuplicateFlag):
	
	delayedInputBufferMutex.lock()
	var duplicateInputFlag = false
	if dealyedInputMaps[JUST_PRESSED_MAP_IX].has(futureTick):
		duplicateInputFlag=true
	
	#don't overwrite inputs, as when input delay changes, some duplicates may be sent
	if not duplicateInputFlag:
		#delay the time to process the input by input delay		
		dealyedInputMaps[JUST_PRESSED_MAP_IX][futureTick]=inputJustPressedBitMap
		dealyedInputMaps[HOLDING_MAP_IX][futureTick]=inputHoldingBitMap
		dealyedInputMaps[RELEASED_MAP_IX][futureTick]=inputReleasedBitMap

	#	var tick = networkingMngr.getFrameTick()
	
#	if tick == futureTick:

	#ONLY unblock if were don syncrhonizing game ticks
	#and dont' count a input received twice
	if readyToSemaphorePost and not duplicateInputFlag and networkingMngr.isTickAfterGameStart(futureTick):
		semaphore.post()
	#is main thread wiaiting for input to be polled
	#if waitingForPeerMutex.try_lock() == ERR_BUSY and waitingForPeerInput:
					
	delayedInputBufferMutex.unlock()
	
	
#called when we konw what game tick starts at
func _on_ready_for_delayed_input(startingTick):
	delayedInputBufferMutex.lock()
	readyToSemaphorePost =true
	
	#are we waiting ion input from peer?
	#if waitingForPeerInput:
		
	#	var tick = networkingMngr.getFrameTick()
		
		#did we received the input but the post was ignored?
	#	if dealyedInputMaps[JUST_PRESSED_MAP_IX].has(tick):
			#unblock, we got the input
	#		semaphore.pose()
	#we must make sure to unblock semaphore as many times as remote inputs have arrive/ or been acknoloedged
	postForAllInputAvailable()
	
	delayedInputBufferMutex.unlock()
	
#not thread safe
func postForAllInputAvailable():
	var futureTicks = dealyedInputMaps[JUST_PRESSED_MAP_IX].keys()
	
	for futureTick in futureTicks:
		
		#input will be processed after game start?
		if networkingMngr.isTickAfterGameStart(futureTick):
			semaphore.post()
			

#not thread safe	
func computeNumberAvailableInput():
	var count = 0
	var futureTicks = dealyedInputMaps[JUST_PRESSED_MAP_IX].keys()
	var tick = networkingMngr.getFrameTick()
	for futureTick in futureTicks:
		
		#input will be processed after game start?
		if networkingMngr.isTickAfterGameStart(futureTick) and futureTick >= tick:
			count = count +1			
			
	return count
	
	
func createNullInputArray():
	
	pollInputResBuffer.clear()
	
	
	var inputJustPressedBitMap = 0
	var inputHoldingBitMap = 0
	var inputReleasedBitMap = 0
	
	pollInputResBuffer.append(inputJustPressedBitMap)
	pollInputResBuffer.append(inputHoldingBitMap)
	pollInputResBuffer.append(inputReleasedBitMap)

	return pollInputResBuffer
	
	
#func _on_input_delay_increased(oldInputDelay,newInputDelay,tickInputDelayChanged):
		
#	var fromTick = tickInputDelayChanged + oldInputDelay
#	var toTick = tickInputDelayChanged +newInputDelay -1
	
#	var i = fromTick
#	while i <= toTick:
#		var inputJustPressedBitMap = 0
#		var inputHoldingBitMap= 0
#		var inputReleasedBitMap = 0
		
		
#		storeInputForFutureTick(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,i)			
#		networkingMngr.sendPeerInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,i)
#		i = i + 1

	

func hasInput(_tick):
	var res = false
	delayedInputBufferMutex.lock()

	res = dealyedInputMaps[JUST_PRESSED_MAP_IX].has(_tick)
	
	delayedInputBufferMutex.unlock()
	
	return res
	
	
func _on_local_input_handler_processed_input():
	if isRemotePeer:
		localInputHandlerProcessedInput=true
		emit_signal("local_input_handler_processed_input")
	