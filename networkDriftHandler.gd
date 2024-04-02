extends Node
const GLOBALS = preload("res://Globals.gd")
var netMngr = null


const NUM_FRAMES_STOP_TRACKING_AFTER_INPUT_DELAY_CHANGE=180
const PRE_MATCH_SYNCH_SLIDING_WINDOW_SIZE = 85
const MATCH_SLIDING_WINDOW_SIZE = 60

const INIT_FPS_SYNCH_DEBUG = false
const INIT_FPS_CLIENT_DEBUG= 45 # client forced 45 fps when INIT_FPS_SYNCH_DEBUG = true

const FPS_SYNCH_TICKS =4 #EVERY 15 FRAMES SEND FPS TO PEER

var fpsArray = []

var peerMeanFPS = 0

var sendPeerFPSCounter = 0
var meanFPS = null

var slidingWindowSize=PRE_MATCH_SYNCH_SLIDING_WINDOW_SIZE

var enabled = false
var driftCorrectionTickCounter = 0

const GENERATED_SIMULATED_CPU_LAG = false
const SIMULATED_CPU_LAG_PVALUE= 0.001
const SIMULATED_CPU_LAG_MAX_TIME_MS = GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS*15
const SIMULATED_CPU_LAG_MIN_TIME_MS = GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS*10

var debugRng=null
const DRIFT_DETECTION_THRESHOLD=15 #if MORE THAn 15 FPS difference, lower FPS

const DRFIT_CORRECTION_DUTRATION = 80 #25 FRAMES of lowered FPS TO try and ctachup

const DRIFT_FPS_SLOW_OFFSET = 5 # become 5 frames slower than peer's fps to let them catchup
const DRIFT_NUM_RECOVER_FPS =3 # increase FPS  slwoly by 10 frames each time until we get back to max speed
const PEER_FPS_CATCHUP_THRESHOLD = 5 #everytime peer gets 5 frames ahead we increase our fps
var forcingFPSReduction = false

var forcedFPSCount = 0

var peerInitialFPS = null

var recoverTickCounter = 0
enum State{
	
	GATHERING_INIT_FPS,
	DRIFT_FPS_CHECKING,
	RECOVERING_FROM_DRIFT,
	MATCH_RESTARTING
}

var targetFPS=GLOBALS.FRAMES_PER_SECOND #default to  60fps
var state = State.GATHERING_INIT_FPS

var inputDelayChangedFrameCounter=0
var inputDelayChangedFlag=false

var fixingDriftTicksEllapsed = 0
const NUM_TICKS_BEFORE_DRIFT_FIX_END = 60 # WAIT one second before sending fps to peer
func _ready():
	
	debugRng = RandomNumberGenerator.new()
	
	#genreate time-based seed
	debugRng.randomize()
	pass # Replace with function body.

func init(_netMngr):
	netMngr = _netMngr
	if INIT_FPS_SYNCH_DEBUG:
		if netMngr.isHost:
			targetFPS=INIT_FPS_CLIENT_DEBUG
			Engine.set_target_fps(targetFPS)

func setEnabled(f):
	enabled = f
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	if not enabled:
		return

	
	if GENERATED_SIMULATED_CPU_LAG:
		simulatedCPULag()
	
	#don't track FPS if just corrected input delay
	if inputDelayChangedFlag:
		inputDelayChangedFrameCounter = inputDelayChangedFrameCounter + 1
		
		if inputDelayChangedFrameCounter<NUM_FRAMES_STOP_TRACKING_AFTER_INPUT_DELAY_CHANGE :
			return
		
		#we finished ignoring fps tracking after input delay change
		inputDelayChangedFlag = false
		inputDelayChangedFrameCounter=0
	
	
	trackMeanFPS()
	
	
	
					
	#we only send the fps when doing drift checking after initial fps synch
	if state == State.DRIFT_FPS_CHECKING:
			
		if not forcingFPSReduction:
				
			sendPeerFPSCounter = sendPeerFPSCounter +1
			
			#did we reach a tick where we should synch the FPS with peer?
			#also make sure not to send our fps as were lowering it
			#briefly to let peer catchup
			if sendPeerFPSCounter > FPS_SYNCH_TICKS:
				
				sendPeerFPSCounter = 0
		
		
				netMngr.netPublisher.peerUDP_RPC("_on_peer_fps_received",[meanFPS])
				
		else:
			
			fixingDriftTicksEllapsed = fixingDriftTicksEllapsed + 1
			
			if fixingDriftTicksEllapsed > NUM_TICKS_BEFORE_DRIFT_FIX_END :
				#print("stopped fixing drift")
				fixingDriftTicksEllapsed =0
				forcingFPSReduction= false
	#	else:
	#		if peerMeanFPS >meanFPS:
				#if abs(peerMeanFPS-meanFPS) <= PEER_FPS_CATCHUP_THRESHOLD:
					#were gona wait a moement to not ping pong the fps of peer
					
	#				forcingFPSReduction=false
	#				state = State.RECOVERING_FROM_DRIFT
	#elif state == State.RECOVERING_FROM_DRIFT:
		#recoverTickCounter = recoverTickCounter +1
		
		#after a second re-enable drift checks
		#if recoverTickCounter > 60: 
		#	recoverTickCounter=0
		#	fpsArray.clear()
		#	meanFPS=peerMeanFPS										
		#	state = State.DRIFT_FPS_CHECKING
func trackMeanFPS():
	var fps = Engine.get_frames_per_second()
		
	fpsArray.push_front(fps)
	
	#add the fps to array in sliding window fasion
	if fpsArray.size() > slidingWindowSize:
		fpsArray.pop_back()
	
	var _mean = 0.0
	#compute mean
	for f in fpsArray:
		_mean = _mean + f
		
	_mean = _mean/fpsArray.size()
	
	meanFPS=_mean

func driftCheckStateChange():
	
	
	#here we already sent our inital FPS and was waiting for peer
	
	#transistion to fps drift checking
	state = State.DRIFT_FPS_CHECKING
	
	
	#make sure restart tracking mean fps freush
	#fpsArray.clear()
	meanFPS=targetFPS
	print("starting drift detection and target fps: "+str(targetFPS))	
	

func matchFPSToSlowestPeer():
	#we dynamically change target fps to be that of slowest system
	targetFPS = min(peerInitialFPS,meanFPS)
	
	#can't go more than 60 fps
	targetFPS = min(GLOBALS.FRAMES_PER_SECOND,targetFPS)

	targetFPS = int(targetFPS)
	Engine.set_target_fps(targetFPS)
	
func _on_peer_init_fps_received_ack(_peerMeanFPS):
	
	if state == State.DRIFT_FPS_CHECKING:
		print("illegale state in drift handler fps initial synch")
		return
	print("received initial fps from client: "+str(_peerMeanFPS))
	peerInitialFPS =_peerMeanFPS
	#driftCheckStateChange()
	matchFPSToSlowestPeer()


func _on_peer_init_fps_received(_peerMeanFPS):
	if state == State.DRIFT_FPS_CHECKING:
		print("illegale state in drift handler fps initial synch")
		return
		
	print("received initial fps from host: "+str(_peerMeanFPS))
	peerInitialFPS =_peerMeanFPS
	#driftCheckStateChange()
	matchFPSToSlowestPeer()
	netMngr.netPublisher.peerTCP_RPC("_on_peer_init_fps_received_ack",[meanFPS])
	
func _on_peer_fps_received(_peerMeanFPS):
	if not enabled:
		return
	
	#not done synching the initial fps?
	if state != State.DRIFT_FPS_CHECKING:
		return
	peerMeanFPS=_peerMeanFPS
	#we only try to correct drift if not already correcting
	#if not forcingFPSReduction:
		
	#we only correct drift if haven't recovered from drift correctio nrecently (need fps to come back up)
	#if fpsArray.size() == SLIDING_WINDOW_SIZE:
		#we have a huge faster tick rate than peer? (likely drift occurs where its laggy for opponent but not us
		#as they are always catching up with receiving packets cause )
	if (meanFPS>peerMeanFPS) and abs(meanFPS-peerMeanFPS)> DRIFT_DETECTION_THRESHOLD:
		#print("correcting drift...")
		forcingFPSReduction=true
		#reduce frame reate by meeting half way between our current frame rate and peers
		#var midPointFPS = int((meanFPS-peerMeanFPS)/2.0)
		
		#var numTicksToWait = min((meanFPS-peerMeanFPS)/2.0,30) #don't wait more than 30 frames
		#var numTicksToWait =  min((meanFPS-peerMeanFPS)/2.0,2)#dcon't wait more than 10 frames
		
		#print("waiting "+str(numTicksToWait)+" tick to let peer catchup")		
		#OS.delay_msec(numTicksToWait*GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS) #WAIT A FRAME TO RESYNCH
		
		#print("drift (peer fps: "+str(peerMeanFPS)+", our fps : "+str(meanFPS)+") waiting 1/4 of a frame")
		OS.delay_msec(int(GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS)*4) #WAIT 1/4 OF frame to try  AN RESYNC
		#forcingFPSReduction=false
		fpsArray.clear()
		#meanFPS=targetFPS
		fixingDriftTicksEllapsed=0
		
		#forcingFPSReduction=false								
#else:
	#	var numTicksToWait = meanFPS-peerMeanFPS
	#	#var numTicksToWait = 1
	#	print("waiting "+str(numTicksToWait)+" tick to let peer catchup")
	#	OS.delay_msec(numTicksToWait*GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS) #WAIT A FRAME TO RESYNCH
		#OS.delay_msec(GLOBALS.FIXED_FRAME_DURATION_IN_MILLISECONDS) #WAIT A FRAME TO RESYNCH	
				#forcedFPSCount=int(peerMeanFPS-midPointFPS)
			#	forcedFPSCount= int(peerMeanFPS) - DRIFT_FPS_SLOW_OFFSET
			#	forcedFPSCount = max(1,forcedFPSCount)
			#	meanFPS=forcedFPSCount
			#	Engine.set_target_fps(meanFPS)#minimum 1 fps. gotta lower our fps below peers so they can catchup
	#else:
		#make sure to synch to peer's fps but be slightly slower
	#	forcedFPSCount= int(peerMeanFPS) - DRIFT_FPS_SLOW_OFFSET
	#	Engine.set_target_fps(max(1,forcedFPSCount))	
	pass
	
func _on_game_start_tick_arrived():
	
	#a race condition occured and never had time to sample the fps mean?
	if meanFPS == null:
		meanFPS=Engine.get_frames_per_second()
	
	
	#only host initiates the initial fps synch
	if netMngr.isHost:
		#we have been gathering FPS info since game finished loading
		#now that we starte the match, synch initial fps to make both peer at lowest machine's fps
		
		#use tcp to make sure the first fps received
		netMngr.netPublisher.peerTCP_RPC("_on_peer_init_fps_received",[meanFPS])

	slidingWindowSize=MATCH_SLIDING_WINDOW_SIZE
	pass
	
func _on_done_loading_game():
	#start gathering fps info to find mean fps rates before games are synchronized
	setEnabled(true)
	state = State.GATHERING_INIT_FPS
	
	
func simulatedCPULag():

	#only host simulates lag to illustrate host is falling behind
	if netMngr.isHost:
		var cpuLagged= generateProbabilistichEvent(SIMULATED_CPU_LAG_PVALUE)
		
		#only simulate lag when not recovery from drift
		if cpuLagged and not forcingFPSReduction:
			var lagTime = debugRng.randf_range(SIMULATED_CPU_LAG_MIN_TIME_MS,SIMULATED_CPU_LAG_MAX_TIME_MS)
			OS.delay_msec(lagTime) #WAIT A FRAME TO RESYNCH

	
func generateProbabilistichEvent(pvalue):

	var eventOccured = false


	#generate number between 0 -1 
	var r = debugRng.randf()
	
	#event occured? note that pobability 0 will never happen
	if r < pvalue:
		eventOccured = true
			
	return eventOccured
	

func _on_game_started():
	driftCheckStateChange()

func _on_game_starting():
	if not forcingFPSReduction and state != State.GATHERING_INIT_FPS:
		print("stoping fps drift detection until match restarts")
		state = State.MATCH_RESTARTING
	
		
func _on_input_delay_changed(newInputDelay,old):
	inputDelayChangedFrameCounter=0
	inputDelayChangedFlag=true