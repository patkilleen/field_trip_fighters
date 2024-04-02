extends Node

const GLOBALS = preload("res://Globals.gd")
var tcpThread = null
var udpThread = null


var tcpSemaphore = null
var udpSemaphore = null

var active = false


var tcpMutex = null
var udpMutex = null
var paramTCPPublishRequests = [[],[]]
var paramUDPPublishRequests = [[],[]]


#var tcpDeadlockCounter = 0
#var udpDeadlockCounter = 0

#var tcpDeadlockMutex = null
#var udpDeadlockMutex = null

const FUNC_NAME_IX = 0
const PARAM_IX = 1

#var netMngr = null
var client = null
var wrapped_client = null
var udpSocket = null
var udpPort=null
var peerIP= null

var deadlockDebugPrintFlag=true
func _ready():
	
	tcpThread = Thread.new()
	udpThread = Thread.new()
	
	tcpSemaphore = Semaphore.new()
	tcpMutex = 	Mutex.new()
	udpSemaphore = Semaphore.new()
	udpMutex = 	Mutex.new()
	#tcpDeadlockMutex = Mutex.new()
	#udpDeadlockMutex = Mutex.new()


func start(_client, _wrapped_client,_udpSocket,_udpPort):
	if _client == null or _wrapped_client == null or  _udpSocket == null or _udpPort == null:
		print("can't start net published: null params")
		return
		
	wrapped_client=	_wrapped_client
	udpSocket = _udpSocket
	client = _client
	
	#get ip of peer were connected to
	peerIP=_client.get_connected_host()

	udpPort = _udpPort
	active=true
	var rc = tcpThread.start(self,"_tcpWorker",[]) 
	if rc != OK:
		
		print("failed to start TCP netowrk rpc thread")
		active=false
		return
	
	rc = udpThread.start(self,"_udpWorker",[]) 
	if rc != OK:
		
		print("failed to start UDP netowrk rpc thread")
		active=false
		tcpThread.wait_to_finish()
		return
	
	
	#netMngr = _netMngr

#stops  thread and waits for it to finish
func stop():
	#stop thread
	active = false
	tcpSemaphore.post()
	udpSemaphore.post()
	#wait for worker to finish
	if tcpThread != null:
		tcpThread.wait_to_finish()
		tcpThread = null
	#wait for worker to finish
	if udpThread != null:
		udpThread.wait_to_finish()	
		udpThread = null

#publishes array of parameters to peer (in case main thread blocked)
#will be used for rpc without main thread's help
#param array is of format: ["name-of-rpc-function-to-call", arg1, arg2, ... , argn]
func peerTCP_RPC(funcName,params):
	
	#null param array and arrays that have no function name inside are invalid
	#if params == null or params.empty():
	#	print("warning trying to send null parameters over tcp")
	#	return     
	
	
	tcpMutex.lock()
	paramTCPPublishRequests[FUNC_NAME_IX].append(funcName)
	paramTCPPublishRequests[PARAM_IX].append(params)
	
	#let the worker know there is a request to do a rpc
	tcpSemaphore.post()
		
	tcpMutex.unlock()
	
	
	
	#tcpDeadlockMutex.lock()
	
#	tcpDeadlockCounter= tcpDeadlockCounter +1
#	if tcpDeadlockCounter > 100:
#		if deadlockDebugPrintFlag:
#			print("possible deadlock in network published tcp")
#			deadlockDebugPrintFlag =false
#	tcpDeadlockMutex.unlock()

#publishes array of parameters to peer (in case main thread blocked)
#will be used for rpc without main thread's help
#param array is of format: ["name-of-rpc-function-to-call", arg1, arg2, ... , argn]
func peerUDP_RPC(funcName,params):
	
	#null param array and arrays that have no function name inside are invalid
	#if params == null or params.empty():
	#	if deadlockDebugPrintFlag:
	#		print("possible deadlock in network published udp")
	#		deadlockDebugPrintFlag =false
	#	return
	
	
	udpMutex.lock()
	paramUDPPublishRequests[FUNC_NAME_IX].append(funcName)
	paramUDPPublishRequests[PARAM_IX].append(params)
	#let the worker know there is a request to do a rpc
	udpSemaphore.post()
	udpMutex.unlock()
	
	
	
	#udpDeadlockMutex.lock()
	#udpDeadlockCounter= udpDeadlockCounter +1
	#if udpDeadlockCounter > 100:
		#print("possible deadlock in network publisher udp")
	#udpDeadlockMutex.unlock()
	
func _tcpWorker(param):
	
	#var peer = get_tree().network_peer
	
	while(active):
		
		#tcpDeadlockMutex.lock()
		#tcpDeadlockCounter= 0
		#tcpDeadlockMutex.unlock()
		
		#wait for a rpc request to be issued
		tcpSemaphore.wait()
		
		#if the thread was forcefully stopped, return
		if not active:
			return
		
		#if peer == null:
		if not client.is_connected_to_host():
			print("error publishing, null peer cnx")
			call_deferred("stop") #stop and join with main thread
			continue
		tcpMutex.lock()
		
	
		#iterate over all the requests and run them
		for i in paramTCPPublishRequests[FUNC_NAME_IX].size():
			var funcName = paramTCPPublishRequests[FUNC_NAME_IX][i]
			var params = paramTCPPublishRequests[PARAM_IX][i]		
			 
			#print("thread sending data...")
			#call the remote process call function given dynamic function name and parameter array
			#true to allow objects (arrays I imagine to bet sent)
			#var byteStream =var2bytes([funcName,params])
			#var rc = wrapped_client.put_var([funcName,params],true)
			#var rc = wrapped_client.put_packet(byteStream)
			
			wrapped_client.put_var([funcName,params],true)
			var error = wrapped_client.get_packet_error()
			if error != OK:
				print("Error on tcp packet put: %s" % error)
				
		
			#if rc != OK:
			
			#	print("failed to send data to peer, error code: "+str(rc))
		
		#clear all requests
		paramTCPPublishRequests[FUNC_NAME_IX].clear()
		paramTCPPublishRequests[PARAM_IX].clear()
		
		tcpMutex.unlock()
		
		
func _udpWorker(param):
	
	#var peer = get_tree().network_peer
	
	while(active):
		
		#udpDeadlockMutex.lock()
		#udpDeadlockCounter= 0
		#udpDeadlockMutex.unlock()
		
		#wait for a rpc request to be issued
		udpSemaphore.wait()
		
		#if the thread was forcefully stopped, return
		if not active:
			return
		
		#if peer == null:
		if not udpSocket.is_listening():			
			#while the udp connect isn't established, wait 1 frame before checking again
			OS.delay_msec(int(GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS))
			
			#print("Can't send UDP packet over network, no cnx.")	
			#call_deferred("stop") #stop and join with main thread
			continue
		udpMutex.lock()
		
	
		#iterate over all the requests and run them
		for i in paramUDPPublishRequests[FUNC_NAME_IX].size():
			var funcName = paramUDPPublishRequests[FUNC_NAME_IX][i]
			var params = paramUDPPublishRequests[PARAM_IX][i]		
			 
			udpSocket.set_dest_address(peerIP,udpPort)
			
			#print("thread sending data...")
			#call the remote process call function given dynamic function name and parameter array
			#true to allow objects (arrays I imagine to bet sent)
			
			var byteStream =var2bytes([funcName,params])
			#var rc = wrapped_client.put_var([funcName,params],true)
			var error = udpSocket.put_packet(byteStream)
			#wrapped_client.put_var([funcName,params],true)
			#var error = wrapped_client.get_packet_error()			
			if error != OK:
				print("Error on UDP packet put: %s" % error)
				
		
			#if rc != OK:
			
			#	print("failed to send data to peer, error code: "+str(rc))
		
		#clear all requests
		paramUDPPublishRequests[FUNC_NAME_IX].clear()
		paramUDPPublishRequests[PARAM_IX].clear()
		
		udpMutex.unlock()



		