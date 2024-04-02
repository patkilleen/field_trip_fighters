extends "res://input_manager.gd"

signal replay_missing_input

var btnPressedBuffer=null
var btnHoldBuffer=null
var btnReleasedBuffer=null

var tick = 0

var mirrorDebugFlag = false

func setupInputs(_btnPressedBuffer,_btnHoldBuffer,_btnReleasedBuffer):
	
	btnPressedBuffer=_btnPressedBuffer
	btnHoldBuffer=_btnHoldBuffer
	btnReleasedBuffer=_btnReleasedBuffer

func processInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap):
	
	#this will happen if a desyn issue occurs and the game should have ended (no more input to play)
	if tick >= btnPressedBuffer.size():
		emit_signal("replay_missing_input")
		set_physics_process(false)
		return

	#upon investigation, replays on restart have a desyn where hitfreeze occured in restarted version of replay but not original...
	#if tick == 200:
	#	pass
	inputJustPressedBitMap=btnPressedBuffer[tick]
	inputHoldingBitMap =btnHoldBuffer[tick]
	inputReleasedBitMap =btnReleasedBuffer[tick] 
	tick = tick + 1
	
	#this only used for debugging. one of iput managers wil lmirror raw input, 
	#while both received the same buttons. so if ever the players get out of synch, it's a game
	#engine issue, not the AI input being processed incorrectly
	if mirrorDebugFlag:
		inputJustPressedBitMap = mirrorBtnInput(inputJustPressedBitMap)
		inputHoldingBitMap = mirrorBtnInput(inputHoldingBitMap)
		inputReleasedBitMap = mirrorBtnInput(inputReleasedBitMap)
	.processInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap)
	

func mirrorBtnInput(btnBitMap):
	
	
	#left held?
	if (btnBitMap & BTN_LEFT) == BTN_LEFT:
		
		#clear the left bit in map
		var tmp =  btnBitMap^BTN_LEFT
		
		#replace it with right
		return tmp|BTN_RIGHT #assume can't hold left and right at same time
	
	#right held?
	if (btnBitMap & BTN_RIGHT) == BTN_RIGHT:
		
		#clear the right bit in map
		var tmp =  btnBitMap^BTN_RIGHT
		
		#replace it with right
		return tmp|BTN_LEFT 
	
	
	return btnBitMap
		
	 