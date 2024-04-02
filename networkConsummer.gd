extends Node

signal lost_connection
var tcpThread = null
var udpThread = null
#var deadlockCheckThread = null
var active = false

var netMngr = null

#var tcpDeadlockCounter = 0
#var udpDeadlockCounter = 0

#var tcpDeadlockMutex = null
#var udpDeadlockMutex = null


const GLOBALS = preload("res://Globals.gd")
const FUNC_NAME_IX = 0
const PARAM_IX = 1
var client = null
var wrapped_client = null
var udpSocket = null
var udpPort=null
var peerIP= null
const DEBUG_PRINT_FLAG = false
#keys in this indicate functions that are allowed to be called from packets sent by peer
var funcCallWhiteList = {}


func _ready():
	
	tcpThread = Thread.new()
	udpThread = Thread.new()
	#deadlockCheckThread = Thread.new()
	#tcpDeadlockMutex = Mutex.new()
	#udpDeadlockMutex = Mutex.new()
	
	funcCallWhiteList["synchClock"]=null
	funcCallWhiteList["_on_request_clock_sync"]=null
	funcCallWhiteList["_on_request_clock_sync_ack"]=null
	funcCallWhiteList["_on_received_peer_command"]=null
	funcCallWhiteList["_on_received_command_ack"]=null
	funcCallWhiteList["_on_determine_latency"]=null
	funcCallWhiteList["_on_determine_latency_ack"]=null
	funcCallWhiteList["_on_received_unacked_inputs"]=null
	funcCallWhiteList["_on_request_start_tick_handshake"]=null
	funcCallWhiteList["_on_peer_done_loading_game"]=null
	funcCallWhiteList["_on_request_base_input_lag_sync"]=null
	funcCallWhiteList["_on_pre_match_input_delay_update_request"]=null
	funcCallWhiteList["_on_input_delay_changed"]=null
	funcCallWhiteList["_on_received_ping_from_host"]=null
	funcCallWhiteList["_on_input_delay_changed_request"]=null
	funcCallWhiteList["_on_input_delay_changed_request_ack"]=null
	funcCallWhiteList["_on_received_peer_sync_info"]=null
	funcCallWhiteList["_on_peer_fps_received"]=null
	funcCallWhiteList["_on_peer_init_fps_received"]=null
	funcCallWhiteList["_on_peer_init_fps_received_ack"]=null
	funcCallWhiteList["_on_desynch_occured"]=null
	funcCallWhiteList["_on_desynch_hash_check"]=null
	funcCallWhiteList["_udp_connected"]=null
	funcCallWhiteList["_udp_connection_failed"]=null
	funcCallWhiteList["_on_request_start_UDP_session"]=null
	


	
func start(_netMngr,_client, _wrapped_client,_udpSocket):
	
	if _netMngr == null or _client == null or  _wrapped_client == null or _udpSocket == null:
		print("can't start net consumemr: null params")
		return
	active=true
		
	netMngr = _netMngr
	wrapped_client = _wrapped_client
	udpSocket = _udpSocket
	client = _client

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
		
	#deadlockCheckThread.start(self,"_deadlockChecker",[]) 
	
	

#stops  thread and waits for it to finish
func stop():
	
		#stop thread
	active = false
	udpSocket.close()
	#wait for worker to finish
	if tcpThread != null:
		tcpThread.wait_to_finish()
		tcpThread = null
	#wait for worker to finish
	if udpThread != null:
		udpThread.wait_to_finish()	
		udpThread =null
	
#	if deadlockCheckThread != null:
#		deadlockCheckThread.wait_to_finish()	
#		deadlockCheckThread = null
	
	
func _tcpWorker(param):
	#var peer = get_tree().network_peer	
	#var delay = int(GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS)
	var delay = 1 #sleep for 1 milli second to not miss any msgs
	while(active):
		
	
		#tcpDeadlockMutex.lock()
		#tcpDeadlockCounter= 0
		#tcpDeadlockMutex.unlock()

	
		#have the network consummer thread be 60FPS by waiting 1 frame every loop
		OS.delay_msec(delay)
		
		if not client.is_connected_to_host ( ):
			#only signal lost connection if was active and unexpectidly disconnected
			#if its not active, means we shutting down socket worker
			if active:
				print("error reading from netrowkr, null cnx")
				
				emit_signal("lost_connection")
				
			#tcpThread=null
			active = false
			#call_deferred("stop") #stop and join with main thread
			#return
			return
			

			
	
		 #continously read incoming data and treat it as rcp
		#true to allow objects (arrays I imagine to bet sent)
		
		#wait for a packet to arrive
		while wrapped_client.get_available_packet_count ( ) > 0:
		#if wrapped_client.get_available_packet_count ( ) > 0:
			
				
			#var byteStream = wrapped_client.get_packet()
			
			
			#if byteStream == null or byteStream.size()==0:
			#	continue
			#var token = bytes2var(byteStream)
			var token = wrapped_client.get_var(true)
			
			var error = wrapped_client.get_packet_error()
			
			if error != OK:
				print("Error on packet get: %s" % error)
				continue				
			if token == null:
				continue
			
			
			
			var funcName = token[FUNC_NAME_IX]
			var params = token[PARAM_IX]
			
			#print("thread received func call: "+str(funcName))	
			
			#for security reasons only allow whitelist of function calls to be made (avoid 
			#attacker deleting scene tree, for example)
			
			if funcCallWhiteList.has(funcName):
				#it should have the rcp format where first param is the func name, and reset are params				=
				if params == null or params.empty():
					netMngr.call(funcName)
				else:
					netMngr.callv(funcName,params)
			else:
				print("tcp netcode: permission issue: func '"+funcName+"' not in function white list. Cannot execute.")
				
				
func _udpWorker(param):
	#var peer = get_tree().network_peer	
	while(active):
				
		#udpDeadlockMutex.lock()
		#udpDeadlockCounter= 0
		#udpDeadlockMutex.unlock()

		if not udpSocket.is_listening():
			
			#while the udp connect isn't established, wait 1 frame before checking again
			OS.delay_msec(int(GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS))
			
		#	print("Can't send USP packet over network, no cnx.")
		#	call_deferred("stop") #stop and join with main thread
			continue
		
		#I THINK this blocks so no need to sleep
		var rc = udpSocket.wait()
		
		if rc!=OK:			
			print("failed to read incoming UDP packet.")
			continue
			
		 #continously read incoming data and treat it as rcp
		#true to allow objects (arrays I imagine to bet sent)
		
		while udpSocket.get_available_packet_count ( ) > 0:
		#wait for a packet to arrive
		#if udpSocket.get_available_packet_count ( ) > 0:
			
				
			var byteStream = udpSocket.get_packet()
			

			#var token = wrapped_client.get_var(true)
			
			var error = udpSocket.get_packet_error()
			
			if error != OK:
				print("Error on packet get: %s" % error)
				continue				
				
						
			if byteStream == null or byteStream.size()==0:
				continue
				
			var token = bytes2var(byteStream)
#			if token == null:
#				continue
			
			
			
			
			var funcName = token[FUNC_NAME_IX]
			var params = token[PARAM_IX]
			
			#print("thread received func call: "+str(funcName))	
			
			#for security reasons only allow whitelist of function calls to be made (avoid 
			#attacker deleting scene tree, for example)
			
			if funcCallWhiteList.has(funcName):
				#it should have the rcp format where first param is the func name, and reset are params				=
				
				if params == null or params.empty():
					netMngr.call(funcName)	
				else:
					netMngr.callv(funcName,params)
			else:
				print("udp netcode: permission issue: func '"+funcName+"' not in function white list. Cannot execute.")
				
				
#func _deadlockChecker(params):
#	var deadlockDebugPrintFlag =true
#	var startTime = OS.get_system_time_msecs()
#	var ellapsedTime=0
#	while(active):
		
#		ellapsedTime = OS.get_system_time_msecs()- startTime
		
		#EVERY 3 FRAMES MAKE THE CHECK
#		if ellapsedTime > 10 *GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS:
#			startTime=OS.get_system_time_msecs()
				
#			udpDeadlockMutex.lock()
#			udpDeadlockCounter= udpDeadlockCounter +1
#			if udpDeadlockCounter > 100:
#				if deadlockDebugPrintFlag:
#					print("possible deadlock in network consummer udp")
#					deadlockDebugPrintFlag =false
#			udpDeadlockMutex.unlock()
			
#			tcpDeadlockMutex.lock()
#			tcpDeadlockCounter= udpDeadlockCounter +1
			
#			if tcpDeadlockCounter > 100:
#				if deadlockDebugPrintFlag:
#					print("possible deadlock in network consummer tcp")
#					deadlockDebugPrintFlag =false
#			tcpDeadlockMutex.unlock()
			#yield(get_tree().create_timer(GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS),"timeout")
		