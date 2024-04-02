extends Node
const GLOBALS = preload("res://Globals.gd")
const recordingEntryResource = preload("res://interface/training/RecordingEntry.tscn")
const inputManagerResource = preload("res://input_manager.gd")
var newRecordingButton= null
var recordingEntryContainer = null

var recordingBuffer = []

const PAUSE_BTN_BITMAP_MASK = ~inputManagerResource.BTN_START #XOR the bits so that the pause bit is 0

var rng = null

enum State{
	IDLE, #NO RECORDING OR PLAYING GOING ON
	RECORDING,
	PLAYING_LOOP,#SPAM
	PLAYING_ONE_SHOT#REVERSAL
}

var state = State.IDLE

var recordingBuffers = []

var pauseLayer = null
var trainingManger = null
var botInputManager = null
var botPlayerController = null

var inputTickIx = 0

var inputBeingPlayed = null

var recordingEntries= []
var reversalRecordingsEnabled=[]
func _ready():
	pass # Replace with function body.

func init(_pauseLayer,_trainingManger,_botInputManager,_botPlayerController):
	pauseLayer=_pauseLayer
	trainingManger=_trainingManger
	botInputManager=_botInputManager
	botPlayerController =_botPlayerController
	recordingBuffers.clear()
	recordingBuffers=[]
	
	recordingBuffer.clear()
	recordingBuffer =[]
	newRecordingButton = pauseLayer.get_node("wrapper/ScrollContainer/TrainingHUD/RecordingButtonContainer/Button")
	
	newRecordingButton.connect("pressed",self,"_on_new_recording")
	
	recordingEntryContainer = pauseLayer.get_node("wrapper/ScrollContainer/TrainingHUD/RecordingEntriesContainer/recordings")

	botInputManager.connect("input_update",self,"_on_bot_input_updated")
	
	
	pauseLayer.connect("activated",self,"_on_paused")
	
	botPlayerController.actionAnimeManager.connect("action_animation_finished",self,"_on_bot_action_animation_finished")
	
	
	rng = RandomNumberGenerator.new()
	
	#genreate time-based seed
	rng.randomize()
	
	
	inputTickIx = 0
	set_physics_process(false)
	
func _on_paused():
	
	if state == State.RECORDING:
		state = State.IDLE
		#playerControler.enableUserInput()
		#botInputManager.behavior = botInputManager.Behavior.SPAM
		trainingManger.__on_behavior_selected(GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_SPAM)
	
		#save the recording fond in recordingBuffer
		
		
func _on_new_recording():
	var recEntry = recordingEntryResource.instance()
	
	_stopPlayingRecording()	
	
	recordingEntryContainer.add_child(recEntry)
	
	recEntry.setId(recordingBuffers.size())
	
	
	recordingEntries.append(recEntry)
	reversalRecordingsEnabled.append(false)
	
	#this will hold the pressed, hold, released bitmap tripples
	recordingBuffer=[] #here we don't clear it since it references a bufer that may still be stored in recordingBuffers
	recordingBuffers.append(recordingBuffer)
	
	
	
	recEntry.connect("play",self,"_on_play_recording",[recEntry])
	recEntry.connect("stop",self,"_on_stop_recording",[recEntry])
	recEntry.connect("erase",self,"_on_erase_recording",[recEntry])
	recEntry.connect("toggle_reversal_action",self,"_on_toggle_reversale_action_recording",[recEntry])
	
	#player loses ability to move his character when controler and recording bot
	#playerControler.disableUserInput()
	#botInputManager.behavior = botInputManager.Behavior.CONTROL_MAIN_CONTROLLER
	trainingManger.__on_behavior_selected(GLOBALS.TRAINING_MODE_NPC_BEHAVIOR_MAIN_CONTROLLER)
	
	state = State.RECORDING
	#start recording emmidiatly and resume game	
	pauseLayer.resumeGame()
	
	
	pass
	
func _on_bot_input_updated(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap):
	
	if state != State.RECORDING:
		return
	
	#we don't allow pause to be recorded
	#mask out the pause
	inputJustPressedBitMap = inputJustPressedBitMap & PAUSE_BTN_BITMAP_MASK
	inputHoldingBitMap = inputHoldingBitMap & PAUSE_BTN_BITMAP_MASK
	inputReleasedBitMap = inputReleasedBitMap & PAUSE_BTN_BITMAP_MASK
	
	#save the input	the bot is doing (player will be controller the bot)
	recordingBuffer.append([inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap])
	
func _on_play_recording(recEntry):
	
	#make sure to make the play button visible for all entires
	#since they all stop (all but the one playing now)
	
	for _recEntry in recordingEntries:
		
		if recEntry != _recEntry:
			_recEntry.playBtn.visible = true
			_recEntry.stopBtn.visible = false

	_playRecording(State.PLAYING_LOOP,recEntry.getId())
	pauseLayer.resumeGame()
func _playRecording(playState,id,_startTickIx=0):
	inputBeingPlayed = recordingBuffers[id]
	state  =playState
	
	inputTickIx=_startTickIx	
	botInputManager.playingInputRecording = true
	
	set_physics_process(true)
	pass
func _on_stop_recording(recEntry):
	_stopPlayingRecording()

	pass
	
func _on_erase_recording(recEntry):
	
	var eraseIx =recEntry.getId()
	
	recordingEntries.remove(eraseIx)
	reversalRecordingsEnabled.remove(eraseIx)
	
	var buffer = recordingBuffers[eraseIx]
	buffer.clear()
	recordingBuffers.remove(eraseIx)
	
	recEntry.disconnect("play",self,"_on_play_recording")
	recEntry.disconnect("stop",self,"_on_stop_recording")
	recEntry.disconnect("erase",self,"_on_erase_recording")
	recEntry.disconnect("toggle_reversal_action",self,"_on_toggle_reversale_action_recording")
	
	recordingEntryContainer.remove_child(recEntry)
	recEntry.queue_free()
	
	#make sure to update all the recording ids
	for i in recordingEntries.size():
		
		var _recEntry = recordingEntries[i]
		_recEntry.setId(i)
	
	_stopPlayingRecording()
	pass

func _stopPlayingRecording():
	inputBeingPlayed =null
	state  =State.IDLE
	set_physics_process(false)
	botInputManager.playingInputRecording = false
	
	for _recEntry in recordingEntries:
				
		_recEntry.playBtn.visible = true
		_recEntry.stopBtn.visible = false
	
func _on_toggle_reversale_action_recording(enableFlag,recEntry):
	reversalRecordingsEnabled[recEntry.getId()]=enableFlag
	pass
	
func _physics_process(delta):
	
	if state !=State.PLAYING_LOOP and state !=State.PLAYING_ONE_SHOT:
		return
		
	if inputBeingPlayed != null:
		#reach end of input
		if inputTickIx>=inputBeingPlayed.size():
			#looping?
			if state ==State.PLAYING_LOOP:
				inputTickIx=0
			else:
				_stopPlayingRecording()
				return
				
	
		var inputTriple = inputBeingPlayed[inputTickIx]
		#manually set the buttons presesd this tick using recorded buttons
		botInputManager.recInputJustPressedBitMap=inputTriple[botInputManager.JUST_PRESSED_MAP_IX]
		botInputManager.recInputHoldingBitMap=inputTriple[botInputManager.HOLDING_MAP_IX]
		botInputManager.recInputReleasedBitMap=inputTriple[botInputManager.RELEASED_MAP_IX]
	
		inputTickIx = inputTickIx+1
		
	
func _on_bot_action_animation_finished(spriteAnimationId):
	

	#animation finished that bot will reversal out of?
	if botPlayerController.actionAnimeManager.isReversableSpriteAnimationId(spriteAnimationId):
		
		#indexs to reversal recordings enabled
		var availableIxs = []
		for i in reversalRecordingsEnabled.size():
			if reversalRecordingsEnabled[i]:
				availableIxs.append(i)
		#recordings availalbe for reversal?
		if availableIxs.size()>0:
			
			var ix
			if trainingManger.reversalNpcCommand != null:
				
				#inlucde the reversal npc command in random
				ix = rng.randi_range(0,availableIxs.size())
				
				if ix ==availableIxs.size():
					#do the npc reversal
					trainingManger._force_training_bot_reversal_cmd()
					return
				
			else:
				ix = rng.randi_range(0,availableIxs.size()-1)
						
			var inputBuff = recordingBuffers[availableIxs[ix]]
			
			
			#find the first non-null button press to make reversale frame perfect
			var startingTickIx=0
			for i in inputBuff.size():
				var inputTriple = inputBuff[i]
				
				#non-null input
				if inputTriple[botInputManager.JUST_PRESSED_MAP_IX] != 0 or inputTriple[botInputManager.HOLDING_MAP_IX] != 0 or inputTriple[botInputManager.RELEASED_MAP_IX] != 0:
					startingTickIx=i
					break
			var inputTriple= inputBuff[startingTickIx]
			
			botInputManager.recInputJustPressedBitMap=inputTriple[botInputManager.JUST_PRESSED_MAP_IX]
			botInputManager.recInputHoldingBitMap=inputTriple[botInputManager.HOLDING_MAP_IX]
			botInputManager.recInputReleasedBitMap=inputTriple[botInputManager.RELEASED_MAP_IX]
		
			_playRecording(State.PLAYING_ONE_SHOT,ix,startingTickIx+1) #+1 since above we just process the first input
			
			var reversalCmd =botInputManager.processInput(inputTriple[botInputManager.JUST_PRESSED_MAP_IX],inputTriple[botInputManager.HOLDING_MAP_IX],inputTriple[botInputManager.RELEASED_MAP_IX])
			botInputManager.cmdBuffer.clear()
			#var _cmd = botInputManager.getFacingDependantCommand(reversalCmd, trainingManger.botKinbody2d.facingRight)
			botInputManager.cmd = reversalCmd
			botInputManager.lastCommand = reversalCmd
			botPlayerController.skipHandleInputThisFrame=true #make sure this early reverasal input is only input processed this frame
			botPlayerController.handleUserInput()
		else:
			if trainingManger.reversalNpcCommand != null:
			
				trainingManger._force_training_bot_reversal_cmd()
				return	