extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var udpSocket = null
var isHost = false
var udpThread = null
# Called when the node enters the scene tree for the first time.

var listenPort=null
var dstPort=null
	
func _ready():
	init()
	
	#udpThread = Thread.new()
	pass # Replace with function body.
	
func init():
	udpSocket = PacketPeerUDP.new()	
	#isHost = _isHost
		
	#if isHost:
		
	#	listenPort=3005
	#	dstPort=3006
	#else:		
	#	listenPort=3006
	#	dstPort=3005
	
	var ipaddr = "10.0.0.103"
	var port = 12345
	var rc = udpSocket.listen(port)
	if rc != OK:
		
		print("failed to listen for udp packets")
		return	
		
	
	udpSocket.set_dest_address(ipaddr,port)
	
	sendOverSocket("Hello World From Godot!")

	print("reading from socket")
	var msgs = readFromSocket()
	print("messages arrvied...:")
			
	for msg in msgs:
		print(msg)

	udpSocket.close()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func sendOverSocket(msg):
	var byteStream =var2bytes(msg)
	#var rc = wrapped_client.put_var([funcName,params],true)
	var error = udpSocket.put_packet(byteStream)
	if error != OK:
		print("Error writing over UDP socket to dst port" + str(dstPort))
		
func readFromSocket():
	
	var msgs = []
	while(not udpSocket.is_listening()):
			
			#while the udp connect isn't established, wait 1 ms before checking again
			OS.delay_msec(1)
			
		#	print("Can't send USP packet over network, no cnx.")
		#	call_deferred("stop") #stop and join with main thread
			continue
		
	#I THINK this blocks so no need to sleep
	var rc = udpSocket.wait()
	
	if rc!=OK:			
		print("failed to read incoming UDP packet from port :" + str(listenPort))
		
		return []
		
		
	 #continously read incoming data and treat it as rcp
	#true to allow objects (arrays I imagine to bet sent)
	
	if udpSocket.get_available_packet_count ( ) == 0:
		print("no messages arrived")
		return []
	while udpSocket.get_available_packet_count ( ) > 0:
	#wait for a packet to arrive
	#if udpSocket.get_available_packet_count ( ) > 0:
		
			
		var byteStream = udpSocket.get_packet()
		

		#var token = wrapped_client.get_var(true)
		
		var error = udpSocket.get_packet_error()
		
		if error != OK:
			print("Error on packet get: %s" % error)
			return []
						
			
					
		if byteStream == null or byteStream.size()==0:
			return []
			
			
		var msg = bytes2var(byteStream)
		msgs.append(msg)
		
		
	return msgs		
		
	