extends Node

#NOTE: to combat the where you get
#ERROR: Script Debugger failed to connect, but being used anyway.
   #At: core/script_debugger_remote.cpp:139
# see https://github.com/godotengine/godot/issues/32933

signal connected
signal disconnected
signal ping
signal input_delay_changed
signal received_peer_sync_info
signal game_start_tick_arrived#signaled when both player can start affecting match
signal resolve_desynch #signaled when game unsynchs and try to resolve it via pause + restart
signal udp_socket_listening #signaled when udp socket first starts listening
var isHost = null

var ipaddr = null
var tcpPort = null
var udpPort = null

var baseInputDelay = 2

const DEBUG_DEADLOCK_CHECKING_ENABLED = false

#const TICKS_BEFORE_RESEND_PACKET =15

const RESEND_TIME_PING_MOD = 2.5 # 2.5 the ping before resending a input


var deadlockCheckThread = null 

const MAX_CLIENTS = 1 #host vs opponent

const GLOBALS = preload("res://Globals.gd")
#const networkRPCWorkerResource = preload("res://networkRPCWorker.gd")
const networkPublisherResource = preload("res://networkPublisher.gd")
const networkConsummerResource = preload("res://networkConsummer.gd")
const networkMsgResenderResource = preload("res://networkMsgResender.gd")
var tickCounterResource = preload("res://frame_tick_counter.gd")
var baseInputDelaySyncherResource = preload("res://baseInputDelaySyncher.gd")
var netLatencyResource = preload("res://networkLatencyHandler.gd")
const driftHandlerResource = preload("res://networkDriftHandler.gd")
const netDesynchCheckerResource = preload("res://networkSynchChecker.gd")
const netTimeoutCheckerResource = preload("res://networkTimeoutChecker.gd")

const frameTimerResource = preload("res://frameTimer.gd")
var tickCounter = null

var netLantencyHandler = null
var baseInputDelaySyncher = null
var localInputManager = null
var remoteInputManager = null
var driftHandler =null
var desynchChecker = null
var netTimeoutChecker = null


var loadGameSemaphore = null

var deadlockCounter = 0


var udpSocketListening = false
var deadlockMutex = null

var netPublisher =null
var netConsummer = null
var netMsgResender = null


#var networkRPCWorker = null
const TICK_DETERMINE_LATENCY_FREQUENCY = 30#EVERY 30 TICKS (0.5 SECOND) DETERMINE LATENCY

var connected = false

var numHandlersProcessedInputs  = 0


#var numStoredPacketsBeforeUnpause = 3

var debugRNG = null

var simulatedLatencyThread = null

var keepThreadAlive = true

var simulatedLatencyMutex = null
var receivedPeerInputQueue = []
var receivedSynchReqQueue = []
var receivedSynchReqAckQueue = []
var receivedCmdAckQueue = []
var startTickHandshakeReqQueue = []
var startTickHandshakeReqReceivedQueue = []

var timer =null

#var receivedPeerCmdQueue = []
#var resendUnAckedInputsInputQueue = []
#var receivedUnAckedInputsInputQueue = []
#const DEBUG_PRINT_FLAG = true
export (bool) var DEBUG_PRINT_FLAG = false
export (bool) var simulatingLatency = false
export (float) var minimumLatency = 20#ms
export (float) var maximumLatency = 25#ms


const SIMULATING_RANDOM_DC = false

#inputs that have not yet been acknoledged as received
#var unackedInputMaps = [{},{},{}]

var gameDoneLoadingMutex = null

const JUST_PRESSED_MAP_IX = 0
const HOLDING_MAP_IX = 1
const RELEASED_MAP_IX = 2
const TICK_IX = 3

var gameStartTickMutex = null
#var unackedInputMutex = null

var tcpServer = null
var wrapped_peer_cnx = null
#var clientCnx = null

var peerCnx = null

var udpSocket = null


const SIMULATING_OCCASIONAL_DESYNCH = false
var hasGameStartTickArrived=false
var tickGameStarts = null

var peerDoneLoadingGame = false
var weDoneLoadingGame = false
#var wrapped_client_cnx  =null
var startedGameLoadingSyncFlag =  false

var initialized = false

var disconnecting = false
var disconnectingMutex = null

var udpCnxOkay = false
func _ready():
	initialized=false
	set_physics_process(false)
	pass
	
#ip: ip address of host (only required if not host)
#_tcpPort: the port number to listen on for tcp server (host), or the server's tcp port we will connect to (not host)
#isHost: flag indicating if were hosting the match
#_udpPort : the port for the udp connection
#_isRemotePeer: flag indicating whether this input manager is controlling the remote peer's character
func init(ip,_tcpPort,_udpPort,_isHost):
	initialized=true
	ipaddr = ip
	tcpPort =_tcpPort
	
	udpPort = _udpPort
	
	isHost = _isHost
	tickCounter = tickCounterResource.new()
	
	timer = frameTimerResource.new()
	add_child(timer)
		
	
	numHandlersProcessedInputs = 0
	
	driftHandler =  driftHandlerResource.new()
	add_child(driftHandler)	
	driftHandler.init(self)
	
	#the drift handler will start when game starts
	
	connect("game_start_tick_arrived",driftHandler,"_on_game_start_tick_arrived")
	
	
	netLantencyHandler = netLatencyResource.new()	
	add_child(netLantencyHandler)
	netLantencyHandler.init(self)
	
	baseInputDelaySyncher = baseInputDelaySyncherResource.new()
	add_child(baseInputDelaySyncher)
	baseInputDelaySyncher.init(self)
	
	baseInputDelaySyncher.connect("input_delay_changed",self,"_on_input_delay_changed")
	
	baseInputDelaySyncher.connect("input_delay_changed",driftHandler,"_on_input_delay_changed")
	
	
	
	
	if isHost:
		netLantencyHandler.connect("ping",self,"_on_ping")
		netLantencyHandler.connect("ping",baseInputDelaySyncher,"_on_ping")
		
	if _isHost:
		tcpServer = TCP_Server.new()
			
	else:
		tcpServer = null
	
	udpSocket = PacketPeerUDP.new()	
	
	disconnecting = false
	disconnectingMutex = Mutex.new()

	loadGameSemaphore = Semaphore.new()
	gameDoneLoadingMutex = Mutex.new()
	
	deadlockMutex = Mutex.new()
	
	gameStartTickMutex = Mutex.new()

	
	netPublisher =networkPublisherResource.new()
	netConsummer = networkConsummerResource.new()
	netTimeoutChecker = netTimeoutCheckerResource.new()
	
	netConsummer.connect("lost_connection",self,"disconnectCleanup",[GLOBALS.NetworkDisconnectionType.LOST_CONNECTION])
	netTimeoutChecker.connect("connection_timeout",self,"disconnectCleanup",[GLOBALS.NetworkDisconnectionType.TIMEOUT])
	
	netMsgResender = networkMsgResenderResource.new()
	add_child(netPublisher)
	add_child(netConsummer)
	add_child(netMsgResender)
	add_child(netTimeoutChecker)
	

	add_child(tickCounter)
	
	debugRNG = RandomNumberGenerator.new()
	
	#genreate time-based seed
	debugRNG.randomize()
	
	
	set_physics_process(true)

func setInputManagers(_localInputManager,_remoteInputManager):
	
	#by default they aren't processing
	localInputManager = _localInputManager
	remoteInputManager = _remoteInputManager
	
	numHandlersProcessedInputs = 0
	localInputManager.connect("finished_processing_input",self,"_on_finished_processing_input",[localInputManager])
	remoteInputManager.connect("finished_processing_input",self,"_on_finished_processing_input",[remoteInputManager])
	
	#have remote input manager connect so that it's notified when local input manager finished processing input
	localInputManager.connect("finished_processing_input",remoteInputManager,"_on_local_input_handler_processed_input")
	
	
	localInputManager.set_physics_process(false)
	remoteInputManager.set_physics_process(false)

func getLocalInputManager():
	return localInputManager
	
func getRemoteInputManager():
	return remoteInputManager
	
#see https://github.com/stisa/godot-tcp-example/blob/master/godot_tcp/script/client.gd 
#https://github.com/Kermer/Godot/blob/master/Tutorials/tut_tcp_connection.md
func setupNetwork():
	
	
	udpSocketListening =false
	
	if DEBUG_PRINT_FLAG:
		print("setting up network")
		
		
	if isHost:
		set_physics_process(true)
			
		
	if (udpSocket.listen(udpPort) != OK):
		print("error listening for UDP messages on port: " + str(udpPort))	
	else:
		print("Listing for upd messages on port: " + str(udpPort))
		
		if isHost:
			#since we need client to initiate the udp session, wait
			#for udp socket to listen before starting the tcp server
			#otherwise client might load game first and udp packet
			#won't have to time arrive
			yield(self,"udp_socket_listening")
			
		
	#are we hosting?
	if isHost:		
		
		if tcpServer.listen(tcpPort) != OK:	
			print("error starting server on port "+str(tcpPort))
		else:
			print("server listening on port: "+str(tcpPort))	
		
	else:
	
		
		peerCnx = StreamPeerTCP.new()
		
		
		print("tcp client connecting to server...")
		
		
		peerCnx.connect_to_host(ipaddr,tcpPort)
		
			
		
	
		
		if peerCnx.get_status() == peerCnx.STATUS_CONNECTED:
			print("Connected to "+ipaddr+" :"+str(tcpPort)) 
			wrapped_peer_cnx = PacketPeerStream.new()
			wrapped_peer_cnx.set_stream_peer(peerCnx)
			_player_tcp_connected(0)
			_tcp_connected_ok()
			
		elif peerCnx.get_status() == StreamPeerTCP.STATUS_CONNECTING:
			print( "...Trying to connect "+ipaddr+" :"+str(tcpPort) )
			set_physics_process(true) # or if trying to connect
		elif peerCnx.get_status() == peerCnx.STATUS_NONE or peerCnx.get_status() == StreamPeerTCP.STATUS_ERROR:
			print( "Couldn't connect to "+ipaddr+" :"+str(tcpPort) )
			
	
	
	
	
	
func _player_tcp_connected(id):
    # Called on both clients and server when a peer connects. Send my info to it.
    #rpc_id(id, "register_player", my_info)
	#this 
	print("[server/client] client connected")
	connected=true
	#tickCounter.reset()
	
	
		
	#test
	#var peer = get_tree().network_peer
	#var rc= peer.put_var("hello world!",true)
	
	#if rc != OK:
	#	print("error sending test packet to peer")
	
	#var testPacket = peer.get_var(true)
	
	#print("test packet: "+str(testPacket))
	
	#start the thread to handle async. rpc
	#networkRPCWorker.start(self)
	if DEBUG_PRINT_FLAG:
		print("starting net threads")
	
	
	netPublisher.start(peerCnx,wrapped_peer_cnx,udpSocket,udpPort)
	netConsummer.start(self,peerCnx,wrapped_peer_cnx,udpSocket)
	
	
	#wait for game to start for latency checking
	netLantencyHandler.disable()
	
	#comment below code to stop input delay changing
	netLantencyHandler.startPingWorker()
		
	
	
	
	#2.5 * base input delay is to give a chance for input to go (baseInputDelay ticks) then get acknolwedge (baseInputDelay)
	# and .5 just so don't have any boundery cases where mesg arrive 0.1ms after resend
	netMsgResender.start(self,baseInputDelay*RESEND_TIME_PING_MOD,tickCounter)
	if DEBUG_PRINT_FLAG:
		print("done starting net threads")
	#localInputManager.call_deferred("set_physics_process",false)
	#remoteInputManager.call_deferred("set_physics_process",false)

	netLantencyHandler.delayedDetermine_latency()
	
	if isHost:
		#over the established tcp connection, request the client to send the host 
		#the initial udp packet to start the UDP session
		netPublisher.peerTCP_RPC("_on_request_start_UDP_session",[])
	
	call_deferred("emit_signal","connected")
	pass

#func _player_disconnected(id):
#	if connected:
#		print("[server] client disconnected")
#	disconnectCleanup()

func _tcp_connected_ok():
	connected=true
	#tickCounter.reset()
	
	print("[client] client connected to server")
	
	#don't need to sync clock on connect. We sync clock when game starts
	#synchClock()
	
	

	
	netLantencyHandler.delayedDetermine_latency()

	
	call_deferred("emit_signal","connected")
	pass # Only called on clients, not server. 

func _on_request_start_UDP_session():
	#print("requesting UDP sessiosn start")
		#the client starts the UDP messaging to allow connection through NATs
	if not isHost:
		#print("cleitn sending udp initial connection")
		#host will reply by calling same func
		netPublisher.peerUDP_RPC("_udp_connected",[])
		
#func _server_disconnected():
#	if connected:
#		print("[client] disconnected from server")
#	disconnectCleanup()

#called when first udp message was received
func _udp_connected():
	#print("/UDP CONNECTED")
	udpCnxOkay = true
	#client called
	if isHost:
		#print("host received udp initial connection")
		#host will reply by calling same func
		netPublisher.peerUDP_RPC("_udp_connected",[])
		
	#else:
		#print("cleitn received udp initial connection's reply")
		
#called by peer (via TCP) when there waas an issue establishing UDP sessiosn
func _udp_connection_failed():
	#print("UDP FAILED")
	if udpCnxOkay:
		print("we recevied a UDP message but peer did not. likely firewall or router issue")
	
		call_deferred("disconnectCleanup",GLOBALS.NetworkDisconnectionType.FAILED_TO_ESTABLISH_UDP_CNX)
	else:
		#don't want to disconnect cleanup twice. both peers fail to establish the udp session
		pass
			
#may want to implement so logic so that ungracful disconnects are singal with an
#error message, and then manin menu is displayed with the message (desync, timeout, disconnected, etc.)
func disconnectCleanup(disconnectType):
	print("disconnect clearnup")
	
	if not initialized:
		return
		
	udpSocketListening = false
	udpCnxOkay=false
	#can only start the disconnect process once
	disconnectingMutex.lock()
	
	if disconnecting:
		disconnectingMutex.unlock()
		return
		
	#being disconnecting process
	disconnecting = true
	disconnectingMutex.unlock()
	

	
	var wasConnected= connected
	
	initialized=false
	
	if gameStartTickMutex != null:
		gameStartTickMutex.lock()
		tickGameStarts = null #no longer accepting input
		gameStartTickMutex.unlock()
		
	
	#this may or may not be called from a thread. So make sure main thread unblocks before synching to main thread
	if localInputManager != null:
		localInputManager.call_deferred("set_physics_process",false)
		localInputManager.semaphore.post()
	
	
	if remoteInputManager != null:			
		remoteInputManager.call_deferred("set_physics_process",false)
		remoteInputManager.semaphore.post()
				
	#wait for main
	yield(get_tree(),"physics_frame")
	
	
		

	
	#make sure that we stop looking for signal that handles lost connections, as we are about to end the connection anyway
	#otherwise this function would be called twice and netStatus would be overwritten
	if netConsummer!= null:
		netConsummer.disconnect("lost_connection",self,"disconnectCleanup")
	
	
	#if we are gracfully disconnecting. Wait half a second to let the other peer
	#disconnect from the lost_connection signal to avoid peer signaling lost connection instead
	#of a graceful disconnect
	if disconnectType == GLOBALS.NetworkDisconnectionType.GRACEFUL_DISCONNECT:
		
		
		#yield(get_tree().create_timer(0.5),"timeout")
		timer.startInSeconds(0.5)
		yield(timer,"timeout")
		
	if netMsgResender != null:
		netMsgResender.stop()
		remove_child(netMsgResender)
		
		
	if netLantencyHandler != null:
		netLantencyHandler.stop()
		remove_child(netLantencyHandler)
		
	#stop the thread to handle async. rpc
	#networkRPCWorker.stop()
	if netPublisher != null:
		netPublisher.stop()
		remove_child(netPublisher)
		
	
	if netConsummer != null:	
		netConsummer.stop()
		remove_child(netConsummer)
		
	if netTimeoutChecker != null:		
		netTimeoutChecker.stop()
		remove_child(netTimeoutChecker)
		

		
	if baseInputDelaySyncher != null:
		baseInputDelaySyncher.set_physics_process(false)
		remove_child(baseInputDelaySyncher)
		baseInputDelaySyncher = null
		
	if driftHandler != null:
		driftHandler.set_physics_process(false)
		remove_child(driftHandler)
		driftHandler=null
	
	
	if desynchChecker != null:
		desynchChecker.set_physics_process(false)
		remove_child(desynchChecker)
		desynchChecker=null
	

	
	#get_tree().network_peer = null
	
	
	keepThreadAlive = false
	
	if simulatedLatencyThread != null:
		simulatedLatencyThread.call_deferred("wait_to_finish")
	
	if deadlockCheckThread != null:
		deadlockCheckThread.call_deferred("wait_to_finish")
		deadlockCheckThread = null
	
	    #player_info.erase(id) # Erase player from info.
	if tickCounter != null:
		
		#tickCounter.call_deferred("set_physics_process",false)
		remove_child(tickCounter)		
		tickCounter =null
	
	connected=false
	netMsgResender=null
	netPublisher=null
	netConsummer=null
	netTimeoutChecker = null
		
	netLantencyHandler = null
	if wasConnected:
		if peerCnx!= null:
			peerCnx.disconnect_from_host()
			peerCnx=null
		if udpSocket!=null:
			#udpSocket.close() #closed by the consummer thread
			udpSocket=null
		if tcpServer!= null:
			tcpServer.stop()
			tcpServer=null
	
	
	
	set_physics_process(false)
	if wasConnected:
		call_deferred("emit_signal","disconnected",disconnectType)
	pass


#syncrhonizes the clock with peer's clock
remote func synchClock():
	if connected:
		#netLantencyHandler.enabled=true
		tickCounter.reset()
		 #start the input (input will be ignored but ticks will be counted)
		#localInputManager.set_physics_process(true)
		#remoteInputManager.set_physics_process(true)
		localInputManager.call_deferred("set_physics_process",true)
		remoteInputManager.call_deferred("set_physics_process",true)
		if DEBUG_PRINT_FLAG:
			print("sending synching clock request...")
		#var tick =getFrameTick()
		var timeSent = OS.get_system_time_msecs()
		if simulatingLatency:
			#create simulated latency on downlink
			var randLatency = debugRNG.randf_range( minimumLatency, maximumLatency)
			if DEBUG_PRINT_FLAG:
				print("simulated latency: ",randLatency ,"ms")
			randLatency = randLatency + OS.get_system_time_msecs()
			#yield(get_tree().create_timer(randLatency/1000.0),"timeout")
			simulatedLatencyMutex.lock()
			receivedSynchReqQueue.append([randLatency,timeSent])
			simulatedLatencyMutex.unlock()
			if DEBUG_PRINT_FLAG:
				print("synching clock request sent...")
			
		else:
			#rpc("_on_request_clock_sync",timeSent)
			#networkRPCWorker.asyncrhonousRCP(["_on_request_clock_sync",timeSent])
			#netPublisher.peerTCP_RPC("_on_request_clock_sync",[timeSent])
			__synchClock(timeSent)
			if DEBUG_PRINT_FLAG:
				print("synching clock request sent...")
		#synching... ignore all commands issued to sync clocks
		#remoteInputManager.resetDelayedInputBuffer()
		#localInputManager.resetDelayedInputBuffer()
func __synchClock(timeSent):	
		netPublisher.peerTCP_RPC("_on_request_clock_sync",[timeSent])
		
	
remote func _on_request_clock_sync(timeSent):
	if connected:
		
		tickCounter.reset()
#		netLantencyHandler.enabled=true
	
#		localInputManager.call_deferred("set_physics_process",true)
#		remoteInputManager.call_deferred("set_physics_process",true)
		
		
		if DEBUG_PRINT_FLAG:
			print("received synching clock request. Sending acknoledgement... ")
		if simulatingLatency:
			#create simulated latency on downlink
			var randLatency = debugRNG.randf_range( minimumLatency, maximumLatency)
			#yield(get_tree().create_timer(randLatency/1000.0),"timeout")
			if DEBUG_PRINT_FLAG:
				print("lantency: ",randLatency)
			randLatency = randLatency + OS.get_system_time_msecs()
			#print("appending time sent to recyeived synch req ack queu")
			simulatedLatencyMutex.lock()			
			receivedSynchReqAckQueue.append([randLatency,timeSent])
			simulatedLatencyMutex.unlock()
		else:
			#rpc("_on_request_clock_sync_ack",timeSent)
			#networkRPCWorker.asyncrhonousRCP(["_on_request_clock_sync_ack",timeSent])
		#	netPublisher.peerTCP_RPC("_on_request_clock_sync_ack",[timeSent])
			__on_request_clock_sync(timeSent)
			netLantencyHandler.enabled=true
	
			#remoteInputManager.resetDelayedInputBuffer()
			#localInputManager.resetDelayedInputBuffer()
			localInputManager.call_deferred("set_physics_process",true)
			remoteInputManager.call_deferred("set_physics_process",true)
#		tickCounter.tick = tickSent
		
		#synching... ignore all commands issued to sync clocks
		#remoteInputManager.resetDelayedInputBuffer()
		#localInputManager.resetDelayedInputBuffer()
		
func __on_request_clock_sync(timeSent):
	netPublisher.peerTCP_RPC("_on_request_clock_sync_ack",[timeSent])
remote func _on_request_clock_sync_ack(timeSent):
	if connected:
				
		
		#determine we should be at
		#var ping = getFrameTick() - tickSent
		
		
		#tickCounter.tick = int(floor(ping/2.0))
		var latency =(OS.get_system_time_msecs()-timeSent)
		var ping = latency/2.0
		#1+ since ping might be 0 and don't want 0 in multiplications for start tick
		#var ticks = 1+int(floor(ping / GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS)) #compute number of fixed delta ticks
		var ticks = 1+int(ceil(ping / GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS)) #compute number of fixed delta ticks
		#should we do ceiling instead of floor here ?
		
		
		if DEBUG_PRINT_FLAG:
			print("received acknoledgeement of synching clock request: clock ticks "+str(ticks))
			
#		var newBaseInputLag=ceil(ceil(ping/GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS)/netLantencyHandler.LATENCY_INPUT_DELAY_BOUNDARY_MOD)
		
#		baseInputDelaySyncher.setBaseInputLagDelay(newBaseInputLag)
		
#		netPublisher.peerTCP_RPC("_on_pre_match_input_delay_update_request",[newBaseInputLag])
		
		#tickCounter.tick=ticks
		tickCounter.setTick(ticks) #although you wait for end of main loop to set tick (1 tick behind) all other logic does same so should be fine
		#tickCounter.call_deferred("set_physics_process",false)
		#localInputManager.resetDelayedInputBuffer()
		#remoteInputManager.resetDelayedInputBuffer()
		#localInputManager.call_deferred("set_physics_process",true)
		#remoteInputManager.call_deferred("set_physics_process",true)
		
		#input will be able to be played in this many ticks (+1 make sure no rounding error made off by one error, 
		#so just to be safe start 1 tick later to be sure)
		
		gameStartTickMutex.lock()
		#tickGameStarts = ticks+baseInputDelaySyncher.getBaseInputDelay()+60#+400 ethis will make sure they will both start same time even if latency and fps drop
		tickGameStarts = ticks+(50*ticks)#just to be safe we startapproximatly 100 times the ping to make sure games start at same time
		hasGameStartTickArrived=false
		print("game start processing input on tick: "+str(tickGameStarts))
				
		gameStartTickMutex.unlock()
		
		remoteInputManager.resetDelayedInputBuffer()
		localInputManager.resetDelayedInputBuffer()
		#were not in critical sectio since above code is only code that changes tickGameStarts on this node
		#for peer another code peice will change it
		remoteInputManager._on_ready_for_delayed_input(tickGameStarts)
		localInputManager._on_ready_for_delayed_input(tickGameStarts)
				
		
		sendStartTickHandshakeReq()
		
		#we have to send the null inputs of ticks input manager wasn't running since we were clock synching
		#start at tick -1 since the input manager will have time to send for the current tick we just set
		#var tmpTick = int(floor(latency/GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS))-1
		
		#while(tmpTick>=0):
		#	var futureTick =tmpTick+baseInputDelay
		#	sendPeerInput(0,0,0,futureTick)
		#	tmpTick = tmpTick -1

func sendStartTickHandshakeReq():

	if connected:
		
		if DEBUG_PRINT_FLAG:
			print("sending game start tick handshake request...")
		
		if simulatingLatency:
			#create simulated latency on downlink
			var randLatency = debugRNG.randf_range( minimumLatency, maximumLatency)
			
			randLatency = randLatency + OS.get_system_time_msecs()
			#yield(get_tree().create_timer(randLatency/1000.0),"timeout")
			simulatedLatencyMutex.lock()
			startTickHandshakeReqQueue.append([randLatency])
			simulatedLatencyMutex.unlock()
			
			
		else:
			#rpc("_on_request_clock_sync",timeSent)
			#networkRPCWorker.asyncrhonousRCP(["_on_request_clock_sync",timeSent])
			#netPublisher.peerTCP_RPC("_on_request_clock_sync",[timeSent])
			__sendStartTickHandshakeReq()
			if weDoneLoadingGame:
				baseInputDelaySyncher.setEnabled(true)
			
		if DEBUG_PRINT_FLAG:
			print("game start tick handshake  request sent...")
	pass

func __sendStartTickHandshakeReq():
	netPublisher.peerTCP_RPC("_on_request_start_tick_handshake",[tickGameStarts])
	
remote func _on_request_start_tick_handshake(_tickGameStarts):
	
	if connected:
		
		
		
		if simulatingLatency:
			#create simulated latency on downlink
			var randLatency = debugRNG.randf_range( minimumLatency, maximumLatency)
			
			randLatency = randLatency + OS.get_system_time_msecs()
			#yield(get_tree().create_timer(randLatency/1000.0),"timeout")
			simulatedLatencyMutex.lock()
			startTickHandshakeReqReceivedQueue.append([randLatency,_tickGameStarts])
			simulatedLatencyMutex.unlock()
			
			
		else:
			#rpc("_on_request_clock_sync",timeSent)
			#networkRPCWorker.asyncrhonousRCP(["_on_request_clock_sync",timeSent])
			#netPublisher.peerTCP_RPC("_on_request_clock_sync",[timeSent])
			
			__on_request_start_tick_handshake(_tickGameStarts)
			
			
				
func __on_request_start_tick_handshake(_tickGameStarts):
	if DEBUG_PRINT_FLAG:
		print("received start tick handshake request: "+str(_tickGameStarts))
	gameStartTickMutex.lock()	
	tickGameStarts = _tickGameStarts
	hasGameStartTickArrived=false
	gameStartTickMutex.unlock()
	
	#were not in critical sectio since above code is only code that changes tickGameStarts on this node
	#for peer another code peice will change it
	remoteInputManager._on_ready_for_delayed_input(tickGameStarts)
	localInputManager._on_ready_for_delayed_input(tickGameStarts)
	
	if weDoneLoadingGame:
		baseInputDelaySyncher.setEnabled(true)

#func sendPeerInputForcePostOnDuplicate(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick):		
#	if connected:
#		netMsgResender._on_msg_sent(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick)			
#		netPublisher.peerUDP_RPC("_on_rec_peer_cmd_force_post_duplicate",[inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick])

#func _on_rec_peer_cmd_force_post_duplicate(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick):
		
	
#		var ignorePostOnDuplicateFlag=true
#		remoteInputManager._storeInputForFutureTick(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick,ignorePostOnDuplicateFlag)

#		netPublisher.peerUDP_RPC("_on_received_command_ack",[inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick])
							
	

func sendPeerInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick):	

	if connected:
		#var tick = getFrameTick()
		
	#	unackedInputMutex.lock()
		#store the message were sending to keep trac of messages that have been received
	#	if unackedInputMaps[JUST_PRESSED_MAP_IX].has(futureTick):
	#		print("warning, ovewritting unacknoledged input sent to peer")
			
		#delay the time to process the input by input delay		
	#	unackedInputMaps[JUST_PRESSED_MAP_IX][futureTick]=inputJustPressedBitMap
	#	unackedInputMaps[HOLDING_MAP_IX][futureTick]=inputHoldingBitMap
	#	unackedInputMaps[RELEASED_MAP_IX][futureTick]=inputReleasedBitMap
	#	unackedInputMutex.unlock()
	
		
		netMsgResender._on_msg_sent(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick)			
		
		_sendPeerInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick)
		
#send peer input without saving the inputs to acknoledge
func _sendPeerInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick,resendFlag=false):
	
	
	if connected:
		
		
		#if get_tree().is_network_server():
		if isServer():
			if DEBUG_PRINT_FLAG:
				
				if resendFlag:
					print("[server: "+str(getFrameTick())+"] RE-sending input : "+str(futureTick))
				else:
					print("[server: "+str(getFrameTick())+"] sending input : "+str(futureTick))
		
		else:
			if DEBUG_PRINT_FLAG:
				if resendFlag:	
					print("[ client "+str(getFrameTick())+"] RE-sending input : "+str(futureTick))
				else:
					print("[ client "+str(getFrameTick())+"] sending input : "+str(futureTick))
			
			
		#var tick = getFrameTick()
				
		if simulatingLatency:
			#create simulated latency on uplink
			var randLatency = debugRNG.randf_range( minimumLatency, maximumLatency) + OS.get_system_time_msecs()
		#	yield(get_tree().create_timer(randLatency/1000.0),"timeout")
			#print("[server "+str(get_tree().is_network_server())+"] finished up link latency")
		
			simulatedLatencyMutex.lock()
			receivedPeerInputQueue.append([randLatency,inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick])
			simulatedLatencyMutex.unlock()
		else:
			#rpc("_on_received_peer_command",inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick)
			#networkRPCWorker.asyncrhonousRCP(["_on_received_peer_command",inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick])
			#netPublisher.peerTCP_RPC("_on_received_peer_command",[inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick])
			__sendPeerInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick)

func __sendPeerInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick):
	if isServer():
		if DEBUG_PRINT_FLAG:
			print(" DEBUG [server actual send tick "+str(getFrameTick())+"] sending input : "+str(futureTick))		
	else:
		if DEBUG_PRINT_FLAG:
			print("DEBUG [ client actual send tick "+str(getFrameTick())+"] sending input : "+str(futureTick))
		
		
	netPublisher.peerUDP_RPC("_on_received_peer_command",[inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick])
	
	
remote func _on_received_peer_command(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay):
	
	var tick =getFrameTick()
		

	#print("peer cmd received")
	if connected:
		
		#rpc("_on_received_command_ack",inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay)
		#networkRPCWorker.asyncrhonousRCP(["_on_received_command_ack",inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay])
		
			
		#if simulatingLatency:
		#create simulated latency on downlink
	#		var randLatency = debugRNG.randf_range( minimumLatency, maximumLatency)+ OS.get_system_time_msecs()
			#yield(get_tree().create_timer(randLatency/1000.0),"timeout")
			#print("[server "+str(get_tree().is_network_server())+"]finished downlink latency")
			
	#		simulatedLatencyMutex.lock()
	#		receivedPeerCmdQueue.append([randLatency,inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay])
	#		simulatedLatencyMutex.unlock()
	#	else:
				
			#__on_received_peer_command(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay)
		__on_received_peer_command(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay)
		
func __on_received_peer_command(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay):
	
		if SIMULATING_OCCASIONAL_DESYNCH:
			#with probability 15% desynch the input by nulling command
			if driftHandler.generateProbabilistichEvent(0.15):
				inputJustPressedBitMap=0
				inputHoldingBitMap=0
				inputReleasedBitMap=0
				
		var tick =getFrameTick()
		
		if remoteInputManager.waitingForPeerInput:
			if tick == tickToPlay:
				if DEBUG_PRINT_FLAG:
					print("						received the input that should unblock the locksetep (curr tick "+str(tick)+" future tick: "+str(tickToPlay)+")")
	
		#make sure to start processing remote peer's inputs
		#remoteInputManager.set_physics_process(true)
			#if get_tree().is_network_server():
		if isServer():
			if DEBUG_PRINT_FLAG:
				print("						[server: "+str(tick)+"] received input : "+str(tickToPlay))
			
		else:
			if DEBUG_PRINT_FLAG:		
				print("						[ client "+str(tick)+"] received input : "+str(tickToPlay))

			
		if tick > tickToPlay:
			var error = tick-tickToPlay
		
			#only report commands that didn't meet deadline if it's after game ticks are sync'ed
			if isTickAfterGameStart(tickToPlay):	
				#since this func is in thread, the tick might have changed, so a real sync issue if 2 ticks late (1 tick alter might be just harmless race condition)
				#if abs(error) >=2:
				if DEBUG_PRINT_FLAG:
					print("					syncrhonization issue. received command that we missed the daeldline to play: (curr tick: "+str(tick)+") (expect play time: "+str(tickToPlay)+"): offset : "+str(error))
				#rpc("synchClock")

		
		
		remoteInputManager.storeInputForFutureTick(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay)
		#call_deferred("_nonThreadSafe_storeInputForFutureTick",remoteInputManager,inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay)
		
		
					#if get_tree().is_network_server():
		if isServer():
			if DEBUG_PRINT_FLAG:
				print("			[server: "+str(tick)+"] sending ack: "+str(tickToPlay))
			
		else:
			if DEBUG_PRINT_FLAG:		
				print("			[ client "+str(tick)+"] sending ack: "+str(tickToPlay))
			
		netPublisher.peerUDP_RPC("_on_received_command_ack",[inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay])
							
		#remoteInputManager.semaphore.post() #unlock blocking
		
		
remote func _on_received_command_ack(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay):
	
	var tick =getFrameTick()
	#if get_tree().is_network_server():
	if isServer():
		if DEBUG_PRINT_FLAG:
			print("					DEBUG [server actual receive time"+str(tick)+"] received ack : "+str(tickToPlay))
		
	else:	
		if DEBUG_PRINT_FLAG:		
			print("					DEBUG	[ client actual receive time "+str(tick)+"] received ack : "+str(tickToPlay))
		
		
			
		
	#keep track of the most recent tick opponent acknoledge input will be processed.
	#any tick after that we can't process since we don't know what peer's input is,
	#so freeze the tick counter
	#tickCounter.tickLimit=max(tickToPlay-1,tickCounter.tickLimit)
	
	if connected:
		if simulatingLatency:
			#create simulated latency on downlink
			var randLatency = debugRNG.randf_range( minimumLatency, maximumLatency)+ OS.get_system_time_msecs()
			#yield(get_tree().create_timer(randLatency/1000.0),"timeout")
			#print("[server "+str(get_tree().is_network_server())+"]finished downlink latency")
			
			
			
				#yield(get_tree().create_timer(randLatency/1000.0),"timeout")
			
			simulatedLatencyMutex.lock()
			receivedCmdAckQueue.append([randLatency,inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay])
			simulatedLatencyMutex.unlock()
			
		else:		
	
			__on_received_command_ack(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay)

func __on_received_command_ack(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay):
		
			var tick = getFrameTick()
			
			if localInputManager.waitingForPeerInput:
				if tick == tickToPlay:
					if DEBUG_PRINT_FLAG:
						print("					received the input that should unblock the locksetep (curr tick "+str(tick)+" future tick: "+str(tickToPlay)+")")
			if isServer():
				if DEBUG_PRINT_FLAG:
					print("					[server: "+str(tick)+"] received ack : "+str(tickToPlay))
				
			else:
				if DEBUG_PRINT_FLAG:		
					print("						[ client "+str(tick)+"] received ack : "+str(tickToPlay))
				
			
			
			#we are now safe to play this command for local player as remote peer has it too
			#localInputManager.storeInputForFutureTick(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay)
			
			#localInputManager.semaphore.post() #unlock blocking
			#call_deferred("_nonThreadSafe_storeInputForFutureTick",localInputManager,inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay)
			netMsgResender._on_msg_ack_received(tickToPlay)
			

func getFrameTick():
	return tickCounter.getTick()
	
func computeDelayedInputTick():
		return getFrameTick()+baseInputDelaySyncher.getBaseInputDelay()
	
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	if isHost:
		
		#DOES THE HOST RANDOMLY DISCONNECT?
		if SIMULATING_RANDOM_DC:
			#only disconnect during match
			if readyForDelayedInput():
				if driftHandler.generateProbabilistichEvent(0.001):#0.1% chance each tick to quit,simulating host dc 
					get_tree().quit()
		
		#if tcpServer.is_listening():
			
		#no client connected?
		if peerCnx == null and tcpServer != null:
						
			if tcpServer.is_connection_available ( ):
				print("[server] client connection avaialble. connecting...")
				peerCnx = tcpServer.take_connection()
				
				print("[server] client connected.")
				
				wrapped_peer_cnx = PacketPeerStream.new()
				wrapped_peer_cnx.set_stream_peer(peerCnx)
				_player_tcp_connected(0)
				
			
		
		#we check for the udp socket to see if we it starting listening 
		if not udpSocketListening and udpSocket.is_listening():
			udpSocketListening = true
			emit_signal("udp_socket_listening") #signaled once udp sockets listening
	else:
		if not connected and peerCnx != null:
			
			if peerCnx.get_status() == peerCnx.STATUS_CONNECTED:
				print("[client] Connected to server")
				wrapped_peer_cnx = PacketPeerStream.new()
				wrapped_peer_cnx.set_stream_peer(peerCnx)
				_player_tcp_connected(0)
				_tcp_connected_ok()
						
	if not connected:
		return
	
	#tick where input can be played not arrived yet?
	if not hasGameStartTickArrived:
		if readyForDelayedInput():
			hasGameStartTickArrived=true
			emit_signal("game_start_tick_arrived")
			
		
			netTimeoutChecker.start(self)
			
	#make sure to compute latency every now and then, but to avoid netrowk congestion
	#don't compute ping on same tick
	#if isHost:
	#	if getFrameTick() % TICK_DETERMINE_LATENCY_FREQUENCY == 0:
	#		netLantencyHandler.determineLatency()
	#else:
	#	if getFrameTick() % (TICK_DETERMINE_LATENCY_FREQUENCY+5) == 0:
	#		netLantencyHandler.determineLatency()
		
remote func _on_determine_latency(peerOSTime):
	netLantencyHandler._on_determine_latency(peerOSTime)
		
remote func _on_determine_latency_ack(osTimeSent):
	netLantencyHandler._on_determine_latency_ack(osTimeSent)
		
func _runSimulatedLatencyWorker(params):
	var timeEllapsed = null

	var ixToDeleteList = []
				
	var arrays = [receivedPeerInputQueue,receivedSynchReqQueue,receivedSynchReqAckQueue,receivedCmdAckQueue,startTickHandshakeReqQueue,startTickHandshakeReqReceivedQueue]
	#var randIxArray = []
	#for i in range arrays.size():
		#randIxArray.append(i)
	
	#var startTime =  OS.get_system_time_msecs()
	#var threadTickEllapsedTime =0
	while keepThreadAlive:
		
		deadlockMutex.lock()
		deadlockCounter= 0
		deadlockMutex.unlock()
		#access the request queue
		
		#threadTickEllapsedTime = OS.get_system_time_msecs()- startTime
		
		#only run the latency logic once per frame
		#if threadTickEllapsedTime <= 1 *GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS:
			#continue
		
		#startTime=OS.get_system_time_msecs()
		timeEllapsed = OS.get_system_time_msecs()
			
		#TODO: permutatue randomly the order requests are handled to simulated
		#non deterministic behavior of network. %https://godotengine.org/qa/2547/how-to-randomize-a-list-array
		#randIxArray = debugRNG
		simulatedLatencyMutex.lock()
		for targetArray in arrays:
			#****************************************************************************
			
			
			#go through all requested items and call the rpc functions when latency time is up
			for i1 in targetArray.size():
				var item = targetArray[i1]
				
				if timeEllapsed >= item[0]: #latency time is up?
					
					if targetArray == receivedPeerInputQueue:
						#[randLatency,inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,futureTick])
						__sendPeerInput(item[1],item[2],item[3],item[4])
					elif targetArray == receivedSynchReqQueue:
						#.([randLatency,timeSent])
						__synchClock(item[1])
					elif targetArray == receivedSynchReqAckQueue:
						#.([randLatency,timeSent])
						__on_request_clock_sync(item[1])
					elif targetArray == receivedCmdAckQueue:
						#receivedCmdAckQueue.append([randLatency,inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay])
						__on_received_command_ack(item[1],item[2],item[3],item[4])												
					elif targetArray == startTickHandshakeReqQueue:
						__sendStartTickHandshakeReq()
					elif targetArray == startTickHandshakeReqReceivedQueue:
						__on_request_start_tick_handshake(item[1])
					ixToDeleteList.append(item)
					
			for item in ixToDeleteList:
				#targetArray.remove(ix)
				targetArray.erase(item)
			
			
			ixToDeleteList.clear()
			
		simulatedLatencyMutex.unlock()
	
		#sleep for a tick
		#yield(get_tree().create_timer(GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS),"timeout")
		
		#timeEllapsed += GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS
		pass
	if DEBUG_PRINT_FLAG:
		print("thread finished")


#func resendUnAckedInputs():
#	print("resending unacked inputs")
#	unackedInputMutex.lock()
	
#	var ticks = unackedInputMaps[JUST_PRESSED_MAP_IX].keys()
#	print(str(ticks.size())+" unacknoledged inputs: ")
	
#	var inputs = []
#	var debugPrintStr = ""
	#resend all unacknoledged inputs
#	for tick in ticks:
		
#		var inputJustPressedBitMap = unackedInputMaps[JUST_PRESSED_MAP_IX][tick]
#		var inputHoldingBitMap = unackedInputMaps[HOLDING_MAP_IX][tick]
#		var inputReleasedBitMap = unackedInputMaps[RELEASED_MAP_IX][tick]
		
#		inputs.append([inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tick])
		
#		debugPrintStr= debugPrintStr + "," +str(tick)
		
#	unackedInputMutex.unlock()
#	print(debugPrintStr)
	
#	_resendUnAckedInputs(inputs)
	
#	print(" done resending unacked inputs")
#	pass
	

#func _resendUnAckedInputs(inputs):
	
	
#	if connected:
		#var tick = getFrameTick()
				
#		if simulatingLatency:
			#create simulated latency on uplink
#			var randLatency = debugRNG.randf_range( minimumLatency, maximumLatency) + OS.get_system_time_msecs()
		
#			simulatedLatencyMutex.lock()
#			resendUnAckedInputsInputQueue.append([randLatency,inputs])
#			simulatedLatencyMutex.unlock()
#		else:
			
#			__resendUnAckedInputs(inputs)

#func __resendUnAckedInputs(inputs):
#	netPublisher.peerTCP_RPC("_on_received_unacked_inputs",[inputs])




#remote func _on_received_unacked_inputs(inputs):
#	
	
#	if connected:
#		#var tick = getFrameTick()
				
#		if simulatingLatency:
			#create simulated latency on uplink
#			var randLatency = debugRNG.randf_range( minimumLatency, maximumLatency) + OS.get_system_time_msecs()
		
#			simulatedLatencyMutex.lock()
#			receivedUnAckedInputsInputQueue.append([randLatency,inputs])
#			simulatedLatencyMutex.unlock()
#		else:
			
#			__on_received_unacked_inputs(inputs)

#func __on_received_unacked_inputs(inputs):
	
	#var ticks = unackedInputMaps[JUST_PRESSED_MAP_IX].keys()
#	if isServer():
#		print("[server] received unacked inputs")
		
#	else:			
#		print("[CLIENT] received unacked inputs")

	
#	for input in inputs:
#		
#		var inputJustPressedBitMap = input[JUST_PRESSED_MAP_IX]
#		var inputHoldingBitMap = input[HOLDING_MAP_IX]
#		var inputReleasedBitMap = input[RELEASED_MAP_IX]
#		var tick =input[TICK_IX]

		
#		remoteInputManager.storeInputForFutureTick(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tick)
		
#		netPublisher.peerTCP_RPC("_on_received_command_ack",[inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tick])
							
		
		
#	remoteInputManager.semaphore.post() #unlock blocking
		
	
#func resendUnAckedInputOld():
#	print("resending unacked inputs")
#	unackedInputMutex.lock()
	
#	var ticks = unackedInputMaps[JUST_PRESSED_MAP_IX].keys()
#	print(str(ticks.size())+" unacknoledged inputs: ")
#	var debugPrintStr = ""
	#resend all unacknoledged inputs
#	for tick in ticks:
#		var inputJustPressedBitMap = unackedInputMaps[JUST_PRESSED_MAP_IX][tick]
#		var inputHoldingBitMap = unackedInputMaps[HOLDING_MAP_IX][tick]
#		var inputReleasedBitMap = unackedInputMaps[RELEASED_MAP_IX][tick]
#		_sendPeerInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tick)
		
#		debugPrintStr= debugPrintStr + "," +str(tick)
#	print(debugPrintStr)
#	unackedInputMutex.unlock()
	
#	print(" done resending unacked inputs")
#	pass
	
func isServer():
	return tcpServer != null

#i don't think this will ever happen
#func _exit_tree():
#	if initialized:
		
#		disconnectCleanup(GLOBALS.NetworkDisconnectionType.GRACEFUL_DISCONNECT)
	
	
#func _deadlockChecker(params):
#	var deadlockDebugPrintFlag =true
		
#	var startTime = OS.get_system_time_msecs()
#	var ellapsedTime=0
	
			
#	while(keepThreadAlive):
		
#		if connected:
			
#			ellapsedTime = OS.get_system_time_msecs()- startTime
		
			#EVERY 10 FRAMES MAKE THE CHECK
#			if ellapsedTime > 10 *GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS:
#				startTime=OS.get_system_time_msecs()
		
		
#				deadlockMutex.lock()
#				deadlockCounter= deadlockCounter +1
#				if deadlockCounter > 10: 
#					if deadlockDebugPrintFlag:
#						if DEBUG_PRINT_FLAG:
#							print("possible deadlock in network manager latency simulation thread")
#						deadlockDebugPrintFlag=false
#				deadlockMutex.unlock()
		#yield(get_tree().create_timer(GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS),"timeout")
		
		
#func _nonThreadSafe_storeInputForFutureTick(inputMngr,inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay):
	#inputMngr.storeInputForFutureTick(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,tickToPlay)
	#inputMngr.semaphore.post()

func isTickAfterGameStart(_tick):
		
	var res = false	
	gameStartTickMutex.lock()
	res = _isTickAfterGameStart(_tick,tickGameStarts)
	gameStartTickMutex.unlock()
	
	return res
	
func _isTickAfterGameStart(_tick,_tickGameStarts):
	
	#haven't finished handshake with peer to decide when game starts (players can have
	#their input affect game)?
	if _tickGameStarts == null:
		return false
	else:
		#true when we arrived at tick that input can be processed for both players
		return _tick >=_tickGameStarts
	
func readyForDelayedInput():
		
	var _tick = getFrameTick()
	return isTickAfterGameStart(_tick)
	
	
func setPlayerStates(p1State,p2State):
	desynchChecker = netDesynchCheckerResource.new()
	add_child(desynchChecker)
	desynchChecker.connect("resolve_desynch",self,"_on_resolve_desynch") 
	connect("game_start_tick_arrived",desynchChecker,"_on_game_start_tick_occured")
	var _player1State = null
	var _player2State = null
	desynchChecker.init(self,p1State,p2State)
	#TODO: somehow get reference to player states and initialize desynch checker
	
func _on_loading_game():
			
	if connected:
		
		
		gameStartTickMutex.lock()
		tickGameStarts=null
		hasGameStartTickArrived=false
		gameStartTickMutex.unlock()
		#remoteInputManager.set_physics_process(true)
		localInputManager.set_physics_process(false)
		remoteInputManager.set_physics_process(false)
		
		localInputManager.resetDelayedInputBuffer()
		remoteInputManager.resetDelayedInputBuffer()
		netLantencyHandler.disable()
		

func _on_peer_done_loading_game():
	
	print("peer done loading")
	loadGameSemaphore.post()
	pass
#called when peer finished loading game
#func OLD_on_peer_done_loading_game():
#	if connected:
#		var startSynchingClockFlag = false
#		gameDoneLoadingMutex.lock()
#		peerDoneLoadingGame=true
		
#		if weDoneLoadingGame and not startedGameLoadingSyncFlag:
#			startSynchingClockFlag = true
#			startedGameLoadingSyncFlag =true
#		gameDoneLoadingMutex.unlock()
##		baseInputDelaySyncher.setEnabled(true)
	#	if startSynchingClockFlag and not startedGameLoadingSyncFlag:
			#wait 3 seconds to make sure everything is loaded nicly before synching inputs
	#		yield(get_tree().create_timer(3),"timeout")
			
	#		synchClock()
	#	pass

func _on_done_loading_game():
	if connected:
		if isHost:
			print("host done loading")
		else:
			print("client done loading")
		
		
			
		#call this so stage updates its label
		call_deferred("emit_signal","input_delay_changed",baseInputDelay,0)
		
		netPublisher.peerTCP_RPC("_on_peer_done_loading_game",[])
		
		
		
		loadGameSemaphore.wait()
		
		
		#the udp connection never got established but the TCP connection wsa fine?
		#likely some firewall or router issue
		if udpCnxOkay == false:
			
			#let the peer know we failed to establish udp connection
			netPublisher.peerTCP_RPC("_udp_connection_failed",[])
			
			#wait a moment to allow the tcp connection to send the udp connection faile
			#give up
			timer.startInSeconds(0.5)
			yield(timer,"timeout")
			
			call_deferred("disconnectCleanup",GLOBALS.NetworkDisconnectionType.FAILED_TO_ESTABLISH_UDP_CNX)
			return
			
			
		driftHandler._on_done_loading_game()
		
		print("fnished waiting for peer to load game")
		if isHost:
			#wait 3 seconds to make sure everything is loaded nicly before synching inputs
			#yield(get_tree().create_timer(3),"timeout")
			timer.startInSeconds(3)
			yield(timer,"timeout")
			print("fnished waiting on yield to synch clock")	
			synchClock()
			
		weDoneLoadingGame =true
	pass
#called when we finished loading game
#func OLD_on_done_loading_game():
#	if connected:
#		var startSynchingClockFlag = false
		
#		gameDoneLoadingMutex.lock()
#		weDoneLoadingGame =true
#		netPublisher.peerTCP_RPC("_on_peer_done_loading_game",[])
		
#		if peerDoneLoadingGame and not startedGameLoadingSyncFlag:
#			startSynchingClockFlag = true
#			startedGameLoadingSyncFlag =true
#		gameDoneLoadingMutex.unlock()
		#baseInputDelaySyncher.setEnabled(true)
#		if startSynchingClockFlag:
			#wait 3 seconds to make sure everything is loaded nicly before synching inputs
#			yield(get_tree().create_timer(3),"timeout")
			
#			synchClock()
			
		
#func _on_pre_match_input_delay_update_request(newBaseInputDelay):
#	baseInputDelaySyncher.setBaseInputLagDelay(newBaseInputDelay)


#only host should send this request
#newBaseInputDelay: the new input delay to delay in a brief moment
#tickToSynch: the tick this new base input delay will take place
func _on_request_base_input_lag_sync(_newBaseInputDelay,_tickToSynch):
	baseInputDelaySyncher._on_request_base_input_lag_sync(_newBaseInputDelay,_tickToSynch)
	
	
func getBaseInputDelay():
	return baseInputDelaySyncher.getBaseInputDelay()


#func _on_input_delay_changed_request_ack(old,newInputDelay,tickSent):
	#remoteInputManager._on_input_delay_increased(old,newInputDelay,tickSent)
#func _on_input_delay_changed_request(newInputDelay):
	
	#wait for tick to increment so alway changed delay at end of processing input
#	yield(tickCounter,"tick_changed")
#	
#	#only add filler input inputs if increased the delay
#	#if newInputDelay >baseInputDelaySyncher.baseInputDelay:
#		#we know the host won't send certain ticks due to base input delay, so add null
#		#iputs for each of those ticks
#		#remoteInputManager._on_input_delay_increased(baseInputDelaySyncher.baseInputDelay,newInputDelay,tickSent)
#	
#	#want to make sure this is syncrhonized with main thread
#	#as we want to make sure base delay is not changed between remote and local
#	#input delay phsycis process	
#	#yield(get_tree(),"physics_frame")
#	

#	#wait for the inputs to have been send/processed
#	#yield(tickCounter,"tick_changed")
	
#	#at this point, were at a new tick where for current tick no input was process/sent
	
#	var old =baseInputDelaySyncher.baseInputDelay
#	#baseInputDelaySyncher.setBaseInputLagDelay(newInputDelay)
#	
#	#only add filler input inputs if increased the delay
#	#if newInputDelay >baseInputDelaySyncher.baseInputDelay:
#		#baseInputDelaySyncher.baseInputDelay=newInputDelay
#		#var tick = getFrameTick()	
#	
#		#localInputManager._on_input_delay_increased(old,newInputDelay,tick)
	
#		#netPublisher.peerTCP_RPC("_on_input_delay_changed_request_ack",[old,newInputDelay,tick])
#	#emit_signal("input_delay_changed",newInputDelay,old)
#	baseInputDelaySyncher.changeInputDelay(newInputDelay)
##	#call_deferred("emit_signal","input_delay_changed",newInputDelay,old)
#	emit_signal("input_delay_changed",newInputDelay,old)
func _on_input_delay_changed_request(newInputDelay):
	

	#at this point, were at a new tick where for current tick no input was process/sent
	
	var old =baseInputDelay

	baseInputDelaySyncher.changeInputDelay(newInputDelay)
	call_deferred("emit_signal","input_delay_changed",newInputDelay,old)
	

func _on_input_delay_changed(newInputDelay,old):
	
	if newInputDelay == old:
		print("design error, signaled input delay changed but new delay same as old")
		return
		
	if not isHost:
		print("design error, only host should handle the input delay change")
		return
		
	print("input delay changed from "+str(old)+" to "+str(newInputDelay))
	#var tick = getFrameTick()
	if isHost:
		netPublisher.peerTCP_RPC("_on_input_delay_changed_request",[newInputDelay])
	#there is nothing to do if the input delay decreased, as we will
	#only send inputs for (~old-new) ticks already sent, so just ignore duplicate inputs for same tick
#	var deltaInputDelay = newInputDelay -old
#	if deltaInputDelay < 0:
		#TODO: put logic here to some how specify what tick what we ignore duplicate input and post anyway
		#cause I messed up and put that logic below, which is in correct
#		pass
#	elif deltaInputDelay > 0:
		
		#for a couple ticks we won't have access to them, so send null inputs
		#e.g.: new = 9, old = 5, current tick 100
		#this means we already sent 100,101,102,103, 104. WIthout the change, this tick we
		#would send 105, but since the base input delay changed, were skipping 105,106,107, and 108
		#and sending 109. That means 9-5 = 4 ticks are sent, so we gotta send empty inputs
		#to sync the lock steps
#		localInputManager._on_input_delay_increased(old,newInputDelay,tick)
		
	call_deferred("emit_signal","input_delay_changed",newInputDelay,old)
	
func OLD_on_input_delay_changed(new,old):
	
	print("input delay changed from "+str(old)+" to "+str(new))
	
	if isHost:
		netPublisher.peerTCP_RPC("_on_input_delay_changed",[new,old])
	#there is nothing to do if the input delay decreased, as we will
	#only send inputs for (~old-new) ticks already sent, so just ignore duplicate inputs for same tick
	var deltaInputDelay = new -old
	if deltaInputDelay < 0:
		#TODO: put logic here to some how specify what tick what we ignore duplicate input and post anyway
		#cause I messed up and put that logic below, which is in correct
		pass
	elif deltaInputDelay > 0:
		
		#for a couple ticks we won't have access to them, so send null inputs
		#e.g.: new = 9, old = 5, current tick 100
		#this means we already sent 100,101,102,103, 104. WIthout the change, this tick we
		#would send 105, but since the base input delay changed, were skipping 105,106,107, and 108
		#and sending 109. That means 9-5 = 4 ticks are sent, so we gotta send empty inputs
		#to sync the lock steps
		var tick =getFrameTick() 
		#var fromTick = tick + old
		var fromTick = tick + old -1
		var toTick = tick +new -1
		
		var i = fromTick
		while i <= toTick:
			var inputJustPressedBitMap = 0
			var inputHoldingBitMap= 0
			var inputReleasedBitMap = 0
			#sendPeerInputForcePostOnDuplicate(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,i)
			sendPeerInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,i)
			#localInputManager.storeInputForFutureTick(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,i)
			baseInputDelaySyncher.uninputableTickMap[i] =null
			#var ignorePostOnDuplicateFlag=false
			#localInputManager._storeInputForFutureTick(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,i,ignorePostOnDuplicateFlag)
			
			i = i + 1
		pass
		
	else:
		#won't happen, but just in case do nothing
		return
	
	emit_signal("input_delay_changed",new,old)
	

func _on_received_ping_from_host(_ping):
	#interface to main game to decouple netcode from ping
	#so main thread will receive ping
	call_deferred("_on_ping",_ping)
	
func _on_ping(_ping):
	
	#only host computes ping manualy. the client receives avg ping from host, so save on ping msgs
	if isHost:
		netPublisher.peerTCP_RPC("_on_received_ping_from_host",[_ping])
		
	#we need to give a chance for message to arrive and get acknoledged.
	# Since the ping is the one-way link time, we need to consider
	# round trip time (*2) and give a bit of wiggle round (+0.5)
	netMsgResender.setTimerBeforeResendOffset(_ping * RESEND_TIME_PING_MOD) 
	
	call_deferred("emit_signal","ping",_ping)
	
	
#func sendPeerSyncInfo(_peerHeroName,_peerPlayerName,_peerAdvProf,_peerDisProf,_peerHeroSkin,_peerStageScenePath):
func sendPeerSyncInfo(_peerHeroName,_peerPlayerName,
						_peerProf1MajorClassIxSelect,_peerProf1MinorClassIxSelect,
						_peerProf2MajorClassIxSelect,_peerProf2MinorClassIxSelect
						,_peerHeroSkin,_peerStageScenePath,_peerRemapButtonModel):

	#netPublisher.peerTCP_RPC("_on_received_peer_sync_info",[_peerHeroName,_peerPlayerName,_peerAdvProf,_peerDisProf,_peerHeroSkin,_peerStageScenePath])
	netPublisher.peerTCP_RPC("_on_received_peer_sync_info",[_peerHeroName,_peerPlayerName,_peerProf1MajorClassIxSelect,_peerProf1MinorClassIxSelect,_peerProf2MajorClassIxSelect,_peerProf2MinorClassIxSelect,_peerHeroSkin,_peerStageScenePath,_peerRemapButtonModel])
	
#func _on_received_peer_sync_info(_peerHeroName,_peerPlayerName,_peerAdvProf,_peerDisProf,_peerHeroSkin,_peerStageScenePath):
#	call_deferred("emit_signal","received_peer_sync_info",_peerHeroName,_peerPlayerName,_peerAdvProf,_peerDisProf,_peerHeroSkin,_peerStageScenePath)
func _on_received_peer_sync_info(_peerHeroName,_peerPlayerName,
								_peerProf1MajorClassIxSelect,_peerProf1MinorClassIxSelect,
								_peerProf2MajorClassIxSelect,_peerProf2MinorClassIxSelect,
								_peerHeroSkin,_peerStageScenePath,_peerRemapButtonModel):
	call_deferred("emit_signal","received_peer_sync_info",_peerHeroName,_peerPlayerName,_peerProf1MajorClassIxSelect,_peerProf1MinorClassIxSelect,_peerProf2MajorClassIxSelect,_peerProf2MinorClassIxSelect,_peerHeroSkin,_peerStageScenePath,_peerRemapButtonModel)

func _on_peer_init_fps_received_ack(meanFps):
	driftHandler.call_deferred("_on_peer_init_fps_received_ack",meanFps)

func _on_peer_init_fps_received(meanFps):
	driftHandler.call_deferred("_on_peer_init_fps_received",meanFps)
	
func _on_peer_fps_received(meanFps):
	driftHandler.call_deferred("_on_peer_fps_received",meanFps)
	
func _on_desynch_hash_check(tick,hostP1Hash,hostP2Hash):
	desynchChecker.call_deferred("_on_desynch_hash_check",tick,hostP1Hash,hostP2Hash)
	
func _on_desynch_occured(tickToResynch):
	desynchChecker.call_deferred("_on_desynch_occured",tickToResynch)
	
func _on_resolve_desynch():
	
	emit_signal("resolve_desynch")
	

	
#called whens stage restarts match
func _on_game_started(): 
	if netLantencyHandler != null:
		netLantencyHandler.enabled = true
	if desynchChecker != null:
		desynchChecker._on_game_started()
	if driftHandler != null:
		driftHandler._on_game_started()
		
	
	

#this is called when game quits by shutting it down, but it bugs out and doesn't gracfully 
#clean up
#func _notification(what):
#	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
#		disconnectCleanup(GLOBALS.NetworkDisconnectionType.GRACEFUL_DISCONNECT)


func _on_finished_processing_input(inputHandler):
	
	#increment number of input handlers that finishes processing an input
	numHandlersProcessedInputs = numHandlersProcessedInputs +1
	
	#both finished processing?
	if numHandlersProcessedInputs == 2:
		numHandlersProcessedInputs = 0
		#proceed to next tick
		tickCounter.incrementTick()
	
	
func _on_game_starting():
	netLantencyHandler.disable()
	if driftHandler!= null:
		driftHandler._on_game_starting()
		