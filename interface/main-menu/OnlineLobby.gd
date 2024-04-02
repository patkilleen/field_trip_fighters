extends Control

signal back
signal players_synchronized
signal host_ip_inputed
signal reconnect_to_peer_request


const DEBUG_HOST_TCP_PORT =3000
const DEBUG_HOST_UDP_PORT =3001
const DEBUG_CLIENT_TCP_PORT =2000
const DEBUG_CLIENT_UDP_PORT =2001
const DEBUG_HOST_IP_ADDR="10.0.0.103"

const frameTimerResource = preload("res://frameTimer.gd")

const GLOBALS = preload("res://Globals.gd")

const ELLAPSED_TIME_MS_BEFORE_CNX_TIMEOUT=5 #5 SECONDS BEFORE TIMEOUT

var onlineInputManagerResource = preload("res://online_input_manager.gd")

var lobbyMsgLabel = null

var heroName = null
#var advProf = null
#var disProf = null

var prof1MajorClassIxSelect=null
var prof1MinorClassIxSelect=null
var prof2MajorClassIxSelect=null
var prof2MinorClassIxSelect =null
	
var heroSkin = null
var playerName = null
var gameMode = null
var networkManager=null
var onlineModeMaineInputDeviceId= null
var stageScenePath = null

var remapButtonModel = null
var port=null
var debugNetcodeFlag=false

var connectBtn = null
var reconnectBtn = null
var ipAddrField = null

var tcpPortValueLabel=null
var udpPortValueLabel=null

var savedIpAddr = null
var inputFielsContainer = null
var inPostSessionState = false

var attemptingToConnect = false
var cnxAttemptDuration = 0
var inputDevices = []

var timer = null
func _ready():
	
	timer = frameTimerResource.new()
	add_child(timer)
	
	lobbyMsgLabel = $MarginContainer/HBoxContainer/LeftPane/lobbyMsg
	
	connectBtn = $MarginContainer/HBoxContainer/LeftPane/HBoxContainer8/cnxButton
	
	reconnectBtn = $MarginContainer/HBoxContainer/LeftPane/reConnectButton
	
	ipAddrField = $MarginContainer/HBoxContainer/LeftPane/HBoxContainer8/ipAddrLineEdit
	
	connectBtn.connect("button_up",self,"_on_cnx_button_pressed")
	
	reconnectBtn.connect("button_up",self,"_on_reconnect_button_pressed")
	
	tcpPortValueLabel= $"portInfo/TcpPortValue"
	udpPortValueLabel=$"portInfo/UDPPortValue"

	#not visible when lobby is first created
	reconnectBtn.visible = false
	
	#invisible by default. only visible for client
	inputFielsContainer = $MarginContainer/HBoxContainer/LeftPane/HBoxContainer8
	inputFielsContainer.visible=false
	inPostSessionState=false
	cnxAttemptDuration=0
	
	inputDevices.clear()
	inputDevices.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDevices.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	set_physics_process(true)



#func initOnlinePlay(_heroName,_playerName,_advProf,_disProf,_heroSkin,_gameMode,_netMngr,_stageScenePath,_onlineModeMaineInputDeviceId,_port,_debugNetcodeFlag):
func initOnlinePlay(_heroName,_playerName,
					_prof1MajorClassIxSelect,_prof1MinorClassIxSelect,
					_prof2MajorClassIxSelect,_prof2MinorClassIxSelect,
					_heroSkin,_gameMode,_netMngr,_stageScenePath,_remapButtonModel,_onlineModeMaineInputDeviceId,_port,_debugNetcodeFlag,_ipaddr):

	heroName=_heroName
	playerName=_playerName
	#advProf=_advProf
	#disProf=_disProf
	prof1MajorClassIxSelect=_prof1MajorClassIxSelect
	prof1MinorClassIxSelect=_prof1MinorClassIxSelect
	prof2MajorClassIxSelect=_prof2MajorClassIxSelect
	prof2MinorClassIxSelect =_prof2MinorClassIxSelect
	savedIpAddr=_ipaddr
	heroSkin=_heroSkin
	gameMode=_gameMode
	stageScenePath=_stageScenePath
	remapButtonModel = _remapButtonModel
	networkManager=_netMngr
	port=_port
	debugNetcodeFlag=_debugNetcodeFlag
	onlineModeMaineInputDeviceId=_onlineModeMaineInputDeviceId
	
	var portInfoNode = $"portInfo"
	portInfoNode.visible = true
	init(_port)
	
func init(_port):
	cnxAttemptDuration=0
	inPostSessionState=false
	attemptingToConnect = false
	
	if debugNetcodeFlag:
		if gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
			tcpPortValueLabel.text = str(DEBUG_CLIENT_TCP_PORT)
			udpPortValueLabel.text = str(DEBUG_CLIENT_UDP_PORT)
		else:
			tcpPortValueLabel.text = str(DEBUG_HOST_TCP_PORT)
			udpPortValueLabel.text = str(DEBUG_HOST_UDP_PORT)
			
		ipAddrField.text= str(DEBUG_HOST_IP_ADDR)
		
		
	else:
		tcpPortValueLabel.text = str(_port)
		udpPortValueLabel.text = str(_port+1)
		
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING:
		attemptingToConnect = false
		lobbyMsgLabel.text = "Waiting for connection..."
	elif gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST: 
		
		#starting a new session?
		if savedIpAddr == null:
			attemptingToConnect = false
			lobbyMsgLabel.text = "Connect to a host"
			#not visible when lobby is first created
			reconnectBtn.visible = false
			
			#let player see input fields used to enter ip addresses
			inputFielsContainer.visible=true
		else:
			attemptingToConnect = true
			lobbyMsgLabel.text = "Connecting..."
			#attempting to reconnect to previsou session's host, so don't allow any input
			inputFielsContainer.visible=false
			reconnectBtn.visible = false
					
	else:
		print("online lobby design error. Invalid game mode: "+str(gameMode))
		
		return 
	
	
	handleNetworkSetup(onlineModeMaineInputDeviceId,savedIpAddr)


func initOnlineMatchEnd(netStatus, customMsg=""):
	
	
	if netStatus == GLOBALS.NetworkDisconnectionType.TIMEOUT:
		lobbyMsgLabel.text= "Connection timed out"
		reconnectBtn.visible = true
	elif netStatus == GLOBALS.NetworkDisconnectionType.LOST_CONNECTION:
		lobbyMsgLabel.text= "Connection lost"
		reconnectBtn.visible = true
	elif netStatus == GLOBALS.NetworkDisconnectionType.GRACEFUL_DISCONNECT:
		lobbyMsgLabel.text= "Online session ended"
		reconnectBtn.visible = true
	elif netStatus == GLOBALS.NetworkDisconnectionType.FAILED_TO_ESTABLISH_UDP_CNX:
		lobbyMsgLabel.text= "Failed to connect. Check the configuration of your firewall or router."
		reconnectBtn.visible = true
	elif netStatus ==GLOBALS.MENU_NOTIFICATION_TEXT:
		lobbyMsgLabel.text= customMsg
		reconnectBtn.visible = false
	else:		
		lobbyMsgLabel.text= "Something went wrong"
		reconnectBtn.visible = false
		
		
		
	cnxAttemptDuration=0
	
	inputDevices.clear()
	inputDevices.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDevices.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	
	inPostSessionState=true
	
	#set_physics_process(true)


#only once match ends do we 
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	
	
	#TODO: add logic so can back out of lobby before match
	#IF B PRESSED
	#if networkManager != null:
	#	if networkManager.initialized:
			#networkManager.disconnectClean(GLOBALS.NetworkDisconnectionType.NO_POST_DISCONNECT_LOBBY)
			#goToMainMenuFlag=true
			
	if inPostSessionState:
		var goToMainMenuFlag = false
		#any controller can leave post online match lobby
		for inputDeviceId in inputDevices:	
			if Input.is_action_just_pressed(inputDeviceId+"_B"):
				goToMainMenuFlag=true		
			elif Input.is_action_just_pressed(inputDeviceId+"_START"):
				goToMainMenuFlag=true
			elif Input.is_action_just_pressed(inputDeviceId+"_A"):
				goToMainMenuFlag=true
		if goToMainMenuFlag:
			emit_signal("back")
			return
			
	else:
		
		#raw B press goes back
		var goToMainMenuFlag = false
		#any controller can leave post online match lobby
		for inputDeviceId in inputDevices:	
			if Input.is_action_just_pressed(inputDeviceId+"_B"):
				goToMainMenuFlag=true					
		if goToMainMenuFlag:
			emit_signal("back")
			return
			
		if attemptingToConnect:
			cnxAttemptDuration=cnxAttemptDuration+delta
			
			if cnxAttemptDuration > ELLAPSED_TIME_MS_BEFORE_CNX_TIMEOUT:
				lobbyMsgLabel.text = "Host may be offline. Still trying to connect..."
			
#func _on_player_info_sync(_peerHeroName,_peerAdvProf,_peerDisProf):
func _on_player_info_sync(_peerHeroName,
							_peerProf1MajorClassIxSelect,_peerProf1MinorClassIxSelect,
							_peerProf2MajorClassIxSelect,_peerProf2MinorClassIxSelect):
	
	lobbyMsgLabel.text = "Connected!"
	
	timer.startInSeconds(1)
	#wait 1 sec to let players know connected to peer
	#yield(get_tree().create_timer(1),"timeout")
	yield(timer,"timeout")
	
	
func handleNetworkSetup(selectionInputDeviceId, ipAddr):
	
	if gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		
		#we only wait to get ip address if this is the first session.
		#if already connected and lost connect, then we already have ip address and don't have to wait
		if ipAddr == null:
			#wait for player to enter ip address
			ipAddr = yield(self,"host_ip_inputed")
			
	
	var inputManagerP1 = onlineInputManagerResource.new()
	networkManager.add_child(inputManagerP1)
	inputManagerP1.init()
	var inputManagerP2 =onlineInputManagerResource.new()
	networkManager.add_child(inputManagerP2)
	inputManagerP2.init()
	
	
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING:
		#make sure the host is player 1
		inputManagerP1.inputDeviceId=selectionInputDeviceId
		inputManagerP2.inputDeviceId=null#unused
		#networkManager.init(null,3000,true)
		
		
		
		
		#debugging net code?
		if debugNetcodeFlag:
			#networkManager.init(null,3000,3001,2002,true)#linux prox setup
			networkManager.init(null,DEBUG_HOST_TCP_PORT,DEBUG_HOST_UDP_PORT,true)#linux prox setup		

		else:			
			#networkManager.init(null,port,port+1,port+2,true)
			networkManager.init(null,port,port+1,true)
			
			
		networkManager.setInputManagers(inputManagerP1,inputManagerP2)
		inputManagerP1.initNetwork(networkManager,false)
		inputManagerP2.initNetwork(networkManager,true)
		
	elif gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		
		#make sure the host is player 1
		inputManagerP1.inputDeviceId=null#unused
		inputManagerP2.inputDeviceId=selectionInputDeviceId
		
		#networkManager.init("localhost",3000,3002,3001,false) #local setup
		#debugging net code?
		if debugNetcodeFlag:
			#networkManager.init("10.0.0.103",2000,3002,2001,false)#linux prox setup

			networkManager.init(DEBUG_HOST_IP_ADDR,DEBUG_CLIENT_TCP_PORT,DEBUG_CLIENT_UDP_PORT,false)#linux prox setup
		else:			
			#networkManager.init(ipAddr,port,port+2,port+1,false)#linux prox setup
			networkManager.init(ipAddr,port,port+1,false)#linux prox setup
		networkManager.setInputManagers(inputManagerP2,inputManagerP1)
		inputManagerP1.initNetwork(networkManager,true)
		inputManagerP2.initNetwork(networkManager,false)	
		
	networkManager.connect("connected",self,"_on_connected")
	networkManager.connect("received_peer_sync_info",self,"_on_received_peer_sync_info")
	networkManager.setupNetwork()	
	
func _on_connected():
	#networkManager.sendPeerSyncInfo(heroName,playerName,advProf,disProf,heroSkin,stageScenePath)
	networkManager.sendPeerSyncInfo(heroName,playerName,
	prof1MajorClassIxSelect,prof1MinorClassIxSelect,
	prof2MajorClassIxSelect,prof2MinorClassIxSelect
	,heroSkin,stageScenePath,remapButtonModel)
	pass
	
#func _on_received_peer_sync_info(_peerHeroName,_peerPlayerName,_peerAdvProf,_peerDisProf,_peerHeroSkin,_peerStageScenePath):
func _on_received_peer_sync_info(_peerHeroName,_peerPlayerName,
								_peerProf1MajorClassIxSelect,_peerProf1MinorClassIxSelect,
							_peerProf2MajorClassIxSelect,_peerProf2MinorClassIxSelect
							,_peerHeroSkin,_peerStageScenePath,_peerRemapButtonModel):
	var _player1Choice=null
	var _player2Choice=null
	#var _p1advProf=null
	#var _p1disProf=null
	#var _p2advProf=null
	#var _p2disProf=null
	var _p1Prof1MajorClassIxSelect=null
	var _p1Prof1MinorClassIxSelect=null
	var _p1Prof2MajorClassIxSelect = null
	var _p1Prof2MinorClassIxSelect = null
	var _p2Prof1MajorClassIxSelect=null
	var _p2Prof1MinorClassIxSelect=null
	var _p2Prof2MajorClassIxSelect=null
	var _p2Prof2MinorClassIxSelect=null

	var _player1Name=null
	var _player2Name=null
	var _player1Color=null
	var _player2Color=null
	var _stage_resource=null
	var _player1RemapButtonModel=null
	var _player2RemapButtonModel=null
	
	#we are player 1, peer's info is player 2
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING:
		_player1Choice=heroName
		_player2Choice=_peerHeroName
		#_p1advProf=advProf
		#_p1disProf=disProf
		_p1Prof1MajorClassIxSelect=prof1MajorClassIxSelect
		_p1Prof1MinorClassIxSelect=prof1MinorClassIxSelect
		_p1Prof2MajorClassIxSelect=prof2MajorClassIxSelect
		_p1Prof2MinorClassIxSelect=prof2MinorClassIxSelect
		#_p2advProf=_peerAdvProf
		#_p2disProf=_peerDisProf		
		_p2Prof1MajorClassIxSelect=_peerProf1MajorClassIxSelect
		_p2Prof1MinorClassIxSelect=_peerProf1MinorClassIxSelect
		_p2Prof2MajorClassIxSelect=_peerProf2MajorClassIxSelect
		_p2Prof2MinorClassIxSelect=_peerProf2MinorClassIxSelect
		_player1Name=playerName
		#_player2Name=_peerPlayerName
		_player2Name=null #no support for displaying peer's name TODO: fixe this (create entry in stats dynamically if name doesn't exist)
		_player1Color=heroSkin
		_player2Color=_peerHeroSkin
		_stage_resource=stageScenePath #player 1 selected stage
		_player1RemapButtonModel=remapButtonModel
		_player2RemapButtonModel=_peerRemapButtonModel
	else:# or mode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		_player1Choice=_peerHeroName
		_player2Choice=heroName
		#_p1advProf=_peerAdvProf
		#_p1disProf=_peerDisProf		
		_p1Prof1MajorClassIxSelect=_peerProf1MajorClassIxSelect
		_p1Prof1MinorClassIxSelect=_peerProf1MinorClassIxSelect
		_p1Prof2MajorClassIxSelect=_peerProf2MajorClassIxSelect
		_p1Prof2MinorClassIxSelect=_peerProf2MinorClassIxSelect
		#_p2advProf=advProf
		#_p2disProf=disProf
		_p2Prof1MajorClassIxSelect=prof1MajorClassIxSelect
		_p2Prof1MinorClassIxSelect=prof1MinorClassIxSelect
		_p2Prof2MajorClassIxSelect=prof2MajorClassIxSelect
		_p2Prof2MinorClassIxSelect=prof2MinorClassIxSelect
		#_player1Name=_peerPlayerName
		_player1Name=null #no support for displaying peer's name TODO: fixe this (create entry in stats dynamically if name doesn't exist)
		_player2Name=playerName 
		_player1Color=_peerHeroSkin
		_player2Color=heroSkin
		_stage_resource=_peerStageScenePath #the peer selected the stage
		_player1RemapButtonModel=_peerRemapButtonModel
		_player2RemapButtonModel=remapButtonModel

	#note that _peerStageScenePath is non-null for host, so client will send a null stage
	#emit_signal("players_synchronized",_player1Choice, _player2Choice,_p1advProf,_p1disProf,_p2advProf,_p2disProf,_player1Name,_player2Name,_player1Color,_player2Color,_stage_resource)
	emit_signal("players_synchronized",_player1Choice, _player2Choice,
										_p1Prof1MajorClassIxSelect, _p1Prof1MinorClassIxSelect,
										_p1Prof2MajorClassIxSelect,_p1Prof2MinorClassIxSelect,
										_p2Prof1MajorClassIxSelect,_p2Prof1MinorClassIxSelect,
										_p2Prof2MajorClassIxSelect,_p2Prof2MinorClassIxSelect
	,_player1Name,_player2Name,_player1Color,_player2Color,_stage_resource, 
	_player1RemapButtonModel,_player2RemapButtonModel)
		
		
func _on_reconnect_button_pressed():
	reconnectBtn.visible = false
	emit_signal("reconnect_to_peer_request",self)
		
func _on_cnx_button_pressed():
	
	var ipAddrStr = ipAddrField.text
	if ipAddrStr!= null and ipAddrStr.length() >0:
		
		inputFielsContainer.visible = false
		attemptingToConnect = true
		lobbyMsgLabel.text = "Connecting..."
		#signal the ip chosen
		emit_signal("host_ip_inputed",ipAddrStr)