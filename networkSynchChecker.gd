extends Node

signal resolve_desynch #signal when both peers are on same tick to resolve issue
const GLOBALS = preload("res://Globals.gd")

enum State{
	HOST_IN_SYNCH,
	HOST_AWAITING_DESYNCH_CHECK_RESPONSE,
	HOST_DESYNCH_CHECK_RESPONSE_ARRIVED,
	CLIENT_IN_SYNCH,
	CLIENT_AWAITING_DESYNCH_CHECK_RESPONSE,
	HOST_DESYNCH_CHECK_RESPONSE_ARRIVED,
}
const SYNCH_CHECK_EVERY_X_TICKS=60*10 # EVERY 10 seconds check for desynch

const TICK_IX=0
const P1_IX=1
const P2_IX=2
var player1State = null
var player2State = null

var netMngr = null

var checkCounter = 0 

var tickToHashPlayerState=null

var gameStateHash = null

var peerGameStateHash = null

var desynchedFlag = false
var resynchTick = GLOBALS.MAX_INT

var stateHashMap = {}

#tick,player1 state hash, player 2 state hash
var storedHashes = [null,null,null]

const frameTimerResource = preload("res://frameTimer.gd")


var timer = null

var checkingForDesyncs = false
func _ready():
	set_physics_process(false)
	pass # Replace with function body.

func init(_netMngr,_player1State,_player2State):
	player1State=_player1State
	player2State=_player2State
	netMngr=_netMngr
	checkCounter = 0
	resynchTick=GLOBALS.MAX_INT
	desynchedFlag = false
	set_physics_process(false)
	
	timer = frameTimerResource.new()
	add_child(timer)
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	#are we already handling the desync?
	if desynchedFlag:
		var tick = netMngr.getFrameTick()
		
		#arrive at tick to resycn?
		if resynchTick<=tick: #<= since net lag miight have delayed the msg and it arrive late
			resynchTick=GLOBALS.MAX_INT
			emit_signal("resolve_desynch")
			#print("player 1 state")
			#player1State.printHashCodeMembers()
			#print("player 2 state")
			#player2State.printHashCodeMembers()
	
	#desynch check tick?
	if checkCounter >= SYNCH_CHECK_EVERY_X_TICKS:
		
		checkCounter=0
		
		#only process hashing and desync checks if enabled.
		#we otherwise keep counting check counter to make sure the game desync checkers
		#remain in sync
		if checkingForDesyncs:
			var p1Hash = player1State.hashCode()
			var p2Hash = player2State.hashCode()
			
			var tick = netMngr.getFrameTick()
			
			
			#the host sends the hash, while client stores it and awaits the synch cheeck hash
			if netMngr.isHost:
				#wait a moment before sending to make sure peer receives it
				#yield(get_tree().create_timer(0.5),"timeout")
				timer.startInSeconds(0.5)
				yield(timer,"timeout")
				
				#do this check as game might have disconnected
				if netMngr.initialized:
					netMngr.netPublisher.peerUDP_RPC("_on_desynch_hash_check",[tick,p1Hash,p2Hash])
			else:
				storeGameStateHash(tick,p1Hash,p2Hash)
			
	checkCounter = checkCounter+1
		

func _on_desynch_hash_check(tick,hostP1Hash,hostP2Hash):
	
	#paramter validity check
	if tick == null or hostP1Hash == null or hostP2Hash == null:
		return
		
	var p1Hash = getStoredHash(tick,P1_IX)
	var p2Hash = getStoredHash(tick,P2_IX)
	
	#no hash for this tick, do nothing
	if p1Hash == null or p2Hash == null:
		return

	#the player state hashes don't match up on same tick. aka, desynch?
	if p1Hash !=hostP1Hash or p2Hash != hostP2Hash:
		
		var pingInTicks = netMngr.netLantencyHandler.getPingInTicks()
		
		var currGameTick = netMngr.getFrameTick()
		#determine furture tick to resynch based on ping. making sure message 
		#should arrive by time tick occurs
		var _resynchTick = currGameTick+(8*pingInTicks)
		
		_on_desynch_occured(_resynchTick)
		netMngr.netPublisher.peerTCP_RPC("_on_desynch_occured",[_resynchTick])
		

func _on_desynch_occured(_resynchTick):
	
	print("desynch occured, will try to resynch shortly")
	#desynch occured so we get ready to resynch with peer by having both
	#games pause at tick 'resynchTick' and having host control the menu
	#to restart or quit
	checkingForDesyncs=false
	resynchTick=_resynchTick
	desynchedFlag=true
	
	
func getStoredHash(tick,playerIX):
	var storedTick = storedHashes[TICK_IX]
	
	#ticks don't match? (maybe we missed a synch tick. no matter, we will check next tick we received)
	if tick != storedTick:
		return null
	
	return storedHashes[playerIX]
	
	pass
	
	
func storeGameStateHash(tick,p1Hash,p2Hash):

	#store the hases for given tick and replaced old hashes
	storedHashes[TICK_IX]=tick
	storedHashes[P1_IX]=p1Hash
	storedHashes[P2_IX]=p2Hash
	pass

func _on_game_start_tick_occured():
	
	#can start looking for desynchs as the players are now able to act
	checkingForDesyncs=true
	set_physics_process(true)
	
	
#TODO: connect
func _on_game_started():
	
	#only start processing if a restart occured from being out of synch
	if desynchedFlag:
		desynchedFlag=false
		resynchTick=GLOBALS.MAX_INT
		
		checkingForDesyncs=true
		
	