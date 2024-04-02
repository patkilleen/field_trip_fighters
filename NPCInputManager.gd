extends "res://input_manager.gd"

signal initiated

var cmd = null

const BTN_PRESSED_MAP_IX=0
const BTN_HOLD_MAP_IX=1
const BTN_RELEASED_MAP_IX=2
enum Behavior{
	SPAM, # a command is spammed every frame	
	CONTROL_2ND_CONTROLLER, # another player controls npc with a 2nd controller
	CONTROL_MAIN_CONTROLLER, #give up control on your character and control np
	MIRROR_INPUT, #the main player controls both characeters asynchronously (facing will affect heros differently)
	MIRROR_COMMAND #the main player controls both characeters Synchronously (facing DOESN'T affect heros differently),
}

var behavior = Behavior.SPAM

var btnCmdReverseMap ={}

var controller1InputDevice = null #the controller controlling opponent player 
var controller2InputDevice = null  #the controller controlling training bot that controls this kinmeatic body

#used by training mode recording inputs
var recInputJustPressedBitMap=0
var recInputHoldingBitMap=0
var recInputReleasedBitMap=0
var playingInputRecording = false #true means recInputJustPressedBitMap,recInputHoldingBitMap, recInputReleasedBitMap used a button bot input

func init(flag=true):
	.init(flag)
	playingInputRecording = false
	#[PRESS,HOLD,RELEASE]
	btnCmdReverseMap[null]=[0,0,0]
	btnCmdReverseMap[Command.CMD_JUMP]=[BTN_A,0,0]
	btnCmdReverseMap[Command.CMD_JUMP_FORWARD]=[BTN_A,BTN_RIGHT,0]
	btnCmdReverseMap[Command.CMD_JUMP_BACKWARD]=[BTN_A,BTN_LEFT,0]
	
	btnCmdReverseMap[Command.CMD_NEUTRAL_MELEE]=[BTN_X,0,0]
	btnCmdReverseMap[Command.CMD_BACKWARD_MELEE]=[BTN_X,BTN_LEFT,0]
	btnCmdReverseMap[Command.CMD_FORWARD_MELEE]=[BTN_X ,BTN_RIGHT,0]
	btnCmdReverseMap[Command.CMD_DOWNWARD_MELEE]=[BTN_X ,BTN_DOWN,0]
	btnCmdReverseMap[Command.CMD_UPWARD_MELEE]=[BTN_X ,BTN_UP,0]
	
	btnCmdReverseMap[Command.CMD_NEUTRAL_SPECIAL]=[BTN_Y ,0,0]
	btnCmdReverseMap[Command.CMD_BACKWARD_SPECIAL]=[BTN_Y,BTN_LEFT,0]
	btnCmdReverseMap[Command.CMD_FORWARD_SPECIAL]=[BTN_Y ,BTN_RIGHT,0]
	btnCmdReverseMap[Command.CMD_DOWNWARD_SPECIAL]=[BTN_Y ,BTN_DOWN,0]
	btnCmdReverseMap[Command.CMD_UPWARD_SPECIAL]=[BTN_Y ,BTN_UP,0]
	
	btnCmdReverseMap[Command.CMD_NEUTRAL_TOOL]=[BTN_B,0,0]
	btnCmdReverseMap[Command.CMD_BACKWARD_TOOL]=[BTN_B ,BTN_LEFT,0]
	btnCmdReverseMap[Command.CMD_FORWARD_TOOL]=[BTN_B ,BTN_RIGHT,0]
	btnCmdReverseMap[Command.CMD_DOWNWARD_TOOL]=[BTN_B ,BTN_DOWN,0]
	btnCmdReverseMap[Command.CMD_UPWARD_TOOL]=[BTN_B ,BTN_UP,0]
	
	btnCmdReverseMap[Command.CMD_MOVE_FORWARD]=[BTN_RIGHT,0,0]
	btnCmdReverseMap[Command.CMD_MOVE_BACKWARD]=[BTN_LEFT,0,0]
	btnCmdReverseMap[Command.CMD_STOP_MOVE_FORWARD]=[0,0,BTN_RIGHT]
	btnCmdReverseMap[Command.CMD_STOP_MOVE_BACKWARD]=[0,0,BTN_LEFT]
	btnCmdReverseMap[Command.CMD_DASH_FORWARD]=[BTN_RIGHT_TRIGGER,BTN_RIGHT,0]
	btnCmdReverseMap[Command.CMD_DASH_BACKWARD]=[BTN_RIGHT_TRIGGER,BTN_LEFT,0]
	btnCmdReverseMap[Command.CMD_CROUCH]=[BTN_DOWN,0,0]
	btnCmdReverseMap[Command.CMD_STOP_CROUCH]=[0,0,BTN_DOWN]
	
	btnCmdReverseMap[Command.CMD_AIR_DASH_DOWNWARD]=[BTN_RIGHT_TRIGGER,BTN_DOWN,0]
	btnCmdReverseMap[Command.CMD_START]=[BTN_START,0,0]
	btnCmdReverseMap[Command.CMD_AUTO_RIPOST]=[BTN_LEFT_TRIGGER|BTN_RIGHT_BUMPER,0,0]
	btnCmdReverseMap[Command.CMD_GRAB]=[BTN_LEFT_BUMPER,0,0]
	btnCmdReverseMap[Command.CMD_RIPOST_NEUTRAL_MELEE]=[BTN_RIGHT_BUMPER|BTN_X,0,0]
	btnCmdReverseMap[Command.CMD_RIPOST_NEUTRAL_SPECIAL]=[BTN_RIGHT_BUMPER|BTN_Y,0,0]
	btnCmdReverseMap[Command.CMD_RIPOST_NEUTRAL_TOOL]=[BTN_RIGHT_BUMPER|BTN_B,0,0]
	btnCmdReverseMap[Command.CMD_RIPOST_BACKWARD_SPECIAL]=[BTN_RIGHT_BUMPER|BTN_Y,BTN_LEFT,0]
	btnCmdReverseMap[Command.CMD_RIPOST_FORWARD_SPECIAL]=[BTN_RIGHT_BUMPER|BTN_Y,BTN_RIGHT,0]
	btnCmdReverseMap[Command.CMD_RIPOST_DOWNWARD_SPECIAL]=[BTN_RIGHT_BUMPER|BTN_Y,BTN_DOWN,0]
	btnCmdReverseMap[Command.CMD_RIPOST_UPWARD_SPECIAL]=[BTN_RIGHT_BUMPER|BTN_Y,BTN_UP,0]
	btnCmdReverseMap[Command.CMD_RIPOST_BACKWARD_MELEE]=[BTN_RIGHT_BUMPER|BTN_X,BTN_LEFT,0]
	btnCmdReverseMap[Command.CMD_RIPOST_FORWARD_MELEE]=[BTN_RIGHT_BUMPER|BTN_X,BTN_RIGHT,0]
	btnCmdReverseMap[Command.CMD_RIPOST_DOWNWARD_MELEE]=[BTN_RIGHT_BUMPER|BTN_X,BTN_DOWN,0]
	btnCmdReverseMap[Command.CMD_RIPOST_UPWARD_MELEE]=[BTN_RIGHT_BUMPER|BTN_X,BTN_UP,0]
	btnCmdReverseMap[Command.CMD_RIPOST_BACKWARD_TOOL]=[BTN_RIGHT_BUMPER|BTN_B,BTN_LEFT,0]
	btnCmdReverseMap[Command.CMD_RIPOST_FORWARD_TOOL]=[BTN_RIGHT_BUMPER|BTN_B,BTN_RIGHT,0]
	btnCmdReverseMap[Command.CMD_RIPOST_DOWNWARD_TOOL]=[BTN_RIGHT_BUMPER|BTN_B,BTN_DOWN,0]
	btnCmdReverseMap[Command.CMD_RIPOST_UPWARD_TOOL]=[BTN_RIGHT_BUMPER|BTN_B,BTN_UP,0]
	btnCmdReverseMap[Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE]=[BTN_LEFT_TRIGGER,0,0]
	btnCmdReverseMap[Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE]=[BTN_LEFT_BUMPER|BTN_RIGHT_BUMPER|BTN_X,0,0]
	btnCmdReverseMap[Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL]=[BTN_LEFT_BUMPER|BTN_RIGHT_BUMPER|BTN_Y,0,0]
	btnCmdReverseMap[Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL]=[BTN_LEFT_BUMPER|BTN_RIGHT_BUMPER|BTN_B,0,0]
	btnCmdReverseMap[Command.CMD_COUNTER_RIPOST_BACKWARD_SPECIAL]=[BTN_LEFT_BUMPER|BTN_RIGHT_BUMPER|BTN_Y,BTN_LEFT,0]
	btnCmdReverseMap[Command.CMD_COUNTER_RIPOST_FORWARD_SPECIAL]=[BTN_LEFT_BUMPER|BTN_RIGHT_BUMPER|BTN_Y,BTN_RIGHT,0]
	btnCmdReverseMap[Command.CMD_COUNTER_RIPOST_DOWNWARD_SPECIAL]=[BTN_LEFT_BUMPER|BTN_RIGHT_BUMPER|BTN_Y,BTN_DOWN,0]
	btnCmdReverseMap[Command.CMD_COUNTER_RIPOST_UPWARD_SPECIAL]=[BTN_LEFT_BUMPER|BTN_RIGHT_BUMPER|BTN_Y,BTN_UP,0]
	btnCmdReverseMap[Command.CMD_COUNTER_RIPOST_BACKWARD_MELEE]=[BTN_LEFT_BUMPER|BTN_RIGHT_BUMPER|BTN_X,BTN_LEFT,0]
	btnCmdReverseMap[Command.CMD_COUNTER_RIPOST_FORWARD_MELEE]=[BTN_LEFT_BUMPER|BTN_RIGHT_BUMPER|BTN_X,BTN_RIGHT,0]
	btnCmdReverseMap[Command.CMD_COUNTER_RIPOST_DOWNWARD_MELEE]=[BTN_LEFT_BUMPER|BTN_RIGHT_BUMPER|BTN_X,BTN_DOWN,0]
	btnCmdReverseMap[Command.CMD_COUNTER_RIPOST_UPWARD_MELEE]=[BTN_LEFT_BUMPER|BTN_RIGHT_BUMPER|BTN_X,BTN_UP,0]
	btnCmdReverseMap[Command.CMD_COUNTER_RIPOST_BACKWARD_TOOL]=[BTN_LEFT_BUMPER|BTN_RIGHT_BUMPER|BTN_B,BTN_LEFT,0]
	btnCmdReverseMap[Command.CMD_COUNTER_RIPOST_FORWARD_TOOL]=[BTN_LEFT_BUMPER|BTN_RIGHT_BUMPER|BTN_B,BTN_RIGHT,0]
	btnCmdReverseMap[Command.CMD_COUNTER_RIPOST_DOWNWARD_TOOL]=[BTN_LEFT_BUMPER|BTN_RIGHT_BUMPER|BTN_B,BTN_DOWN,0]
	btnCmdReverseMap[Command.CMD_COUNTER_RIPOST_UPWARD_TOOL]=[BTN_LEFT_BUMPER|BTN_RIGHT_BUMPER|BTN_B,BTN_UP,0]
	btnCmdReverseMap[Command.CMD_FORWARD_CROUCH]=[0,BTN_RIGHT|BTN_DOWN,0]
	btnCmdReverseMap[Command.CMD_BACKWARD_CROUCH]=[0,BTN_LEFT|BTN_DOWN,0]
	btnCmdReverseMap[Command.CMD_DASH_FORWARD_NO_DIRECTIONAL_INPUT]=[BTN_RIGHT_TRIGGER,0,0]
	btnCmdReverseMap[Command.CMD_FORWARD_UP]=[0,BTN_RIGHT|BTN_UP,0]
	btnCmdReverseMap[Command.CMD_BACKWARD_UP]=[0,BTN_LEFT|BTN_UP,0]
	btnCmdReverseMap[Command.CMD_UP]=[0,BTN_UP,0]
	btnCmdReverseMap[Command.CMD_BACKWARD_CROUCH_PUSH_BLOCK]=[BTN_LEFT_TRIGGER,BTN_LEFT|BTN_DOWN,0]
	btnCmdReverseMap[Command.CMD_BACKWARD_UP_PUSH_BLOCK]=[BTN_LEFT_TRIGGER,BTN_LEFT|BTN_UP,0]
	btnCmdReverseMap[Command.CMD_BACKWARD_PUSH_BLOCK]=[BTN_LEFT_TRIGGER,BTN_LEFT,0]
	btnCmdReverseMap[Command.CMD_FORWARD_CROUCH_PUSH_BLOCK]=[BTN_LEFT_TRIGGER,BTN_RIGHT|BTN_DOWN,0]
	btnCmdReverseMap[Command.CMD_FORWARD_UP_PUSH_BLOCK]=[BTN_LEFT_TRIGGER,BTN_UP|BTN_RIGHT,0]
	btnCmdReverseMap[Command.CMD_FORWARD_PUSH_BLOCK]=[BTN_LEFT_TRIGGER,BTN_RIGHT,0]
	btnCmdReverseMap[Command.CMD_BUFFERED_PUSH_BLOCK]=[BTN_LEFT_TRIGGER,0,0]
	
	#testButtonMapping()
	emit_signal("initiated")

func testButtonMapping():
	var success = true
	for _cmdKey in  btnCmdReverseMap.keys():
		 
		#don't allow CMD_BUFFERED_PUSH_BLOCK as a command. We leave it to the playercontroller to buffer it in
		#when they see ability cancel
		if _cmdKey ==Command.CMD_BUFFERED_PUSH_BLOCK:
			_cmdKey =Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE
			
			
		cmd =_cmdKey
		#var remappedInputs = btnCmdReverseMap[_cmdKey]
		#var inputJustPressedBitMap=remappedInputs[BTN_PRESSED_MAP_IX]
		#var inputHoldingBitMap=remappedInputs[BTN_HOLD_MAP_IX]
		#var inputReleasedBitMap=remappedInputs[BTN_RELEASED_MAP_IX]
		
	
		var actualCmd = processInput(0,0,0)
		
		if actualCmd !=_cmdKey:
			success=false
			var valsMap = Command.keys()
			print("failed for command. Expected "+str(valsMap[_cmdKey])+" but was "+str(valsMap[actualCmd]))
		reset()
	print("testing the npc input bunttons reverse mapping. Success?: "+str(success))	
	
#func handleInputSignaling(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap):
	
#	if behavior != Behavior.SPAM:
#		
#		#we process input as usual when not controlling command via scrip
#		handleInputSignaling(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap)
#	else:
		#gotta convert command to button
		
#		var remappedInputs = btnCmdReverseMap[cmd]
#		emit_signal("input_update",remappedInputs[BTN_PRESSED_MAP_IX],remappedInputs[BTN_HOLD_MAP_IX],remappedInputs[BTN_RELEASED_MAP_IX])
	
	
func processInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap):
	
	var spamBehaviorFlag =false
		
	
	match(behavior):
		Behavior.SPAM:
			spamBehaviorFlag=true
		Behavior.CONTROL_2ND_CONTROLLER:		
			if controller2InputDevice != null:
				self.inputDeviceId = controller2InputDevice#this will make next call to processInput have correct buttons
			else:
				spamBehaviorFlag=true #spam behavior, since controller input device not specified
				
		Behavior.CONTROL_MAIN_CONTROLLER:		
			if controller1InputDevice != null:
				self.inputDeviceId = controller1InputDevice #this will make next call to processInput have correct buttons								
			else:
				spamBehaviorFlag=true #spam behavior, since controller input device not specified
										
		Behavior.MIRROR_INPUT:
			if controller1InputDevice != null:
				self.inputDeviceId = controller1InputDevice  #this will make next call to processInput have correct buttons												
			else:
				spamBehaviorFlag=true #spam behavior, since controller input device not specified	
		Behavior.MIRROR_COMMAND:
			if controller1InputDevice != null:
				self.inputDeviceId = controller1InputDevice  #this will make next call to processInput have correct buttons											
			else:
				spamBehaviorFlag=true #spam behavior, since controller input device not specified	
	
	#were not playing a training mode recording
	if not playingInputRecording:
		#we need to convert the given command to button presses
		if spamBehaviorFlag:
			
			#don't allow CMD_BUFFERED_PUSH_BLOCK as a command. We leave it to the playercontroller to buffer it in
			#when they see ability cancel
			if cmd ==Command.CMD_BUFFERED_PUSH_BLOCK:
				cmd =Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE
			
			if btnCmdReverseMap.has(cmd):
				var remappedInputs = btnCmdReverseMap[cmd]
			
				inputJustPressedBitMap=remappedInputs[BTN_PRESSED_MAP_IX]
				inputHoldingBitMap=remappedInputs[BTN_HOLD_MAP_IX]
				inputReleasedBitMap=remappedInputs[BTN_RELEASED_MAP_IX]
			else:
				
				inputJustPressedBitMap=0
				inputHoldingBitMap=0
				inputReleasedBitMap=0
		else:
			pass
	else:
		inputJustPressedBitMap = recInputJustPressedBitMap
		inputHoldingBitMap = recInputHoldingBitMap
		inputReleasedBitMap = recInputReleasedBitMap
	return .processInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap)
	
#func parseCommand(inputJustPressedBitMap,inputHoldingBitMap, inputReleasedBitMap):
	#lastDI = parseDirectionalInput(inputJustPressedBitMap,inputHoldingBitMap)
#	match(behavior):
#		Behavior.SPAM:
#			return cmd
#		Behavior.CONTROL_2ND_CONTROLLER:		
#			if controller2InputDevice != null:
#				self.inputDeviceId = controller2InputDevice			
#				return .parseCommand(inputJustPressedBitMap,inputHoldingBitMap, inputReleasedBitMap)
				
#			else:
#				return cmd #spam behavior, since controller input device not specified
				
#		Behavior.CONTROL_MAIN_CONTROLLER:		
#			if controller1InputDevice != null:
#				self.inputDeviceId = controller1InputDevice
#				return .parseCommand(inputJustPressedBitMap,inputHoldingBitMap, inputReleasedBitMap)
				
#			else:
#				return cmd #spam behavior, since controller input device not specified
										
#		Behavior.MIRROR_INPUT:
#			if controller1InputDevice != null:
#				self.inputDeviceId = controller1InputDevice
#				return .parseCommand(inputJustPressedBitMap,inputHoldingBitMap, inputReleasedBitMap)
#			else:
#				return cmd #spam behavior, since controller input device not specified	
#		Behavior.MIRROR_COMMAND:
#			if controller1InputDevice != null:
#				self.inputDeviceId = controller1InputDevice
#				return .parseCommand(inputJustPressedBitMap,inputHoldingBitMap, inputReleasedBitMap)
#			else:
#				return cmd #spam behavior, since controller input device not specified	

#returns the command appropriate depending on given facing and command
#paras: cmd: command used to find appropriate mirrored command
#params: facingRight: fflag that is true when facing right, and false otherwise
func getFacingDependantCommand(cmd, facingRight):
	
	#when mirroring a command, make sure the facing of both characters will be intepreted same
	if behavior == Behavior.MIRROR_COMMAND:	
		return .getFacingDependantCommand(cmd, not facingRight)
	else:
		return .getFacingDependantCommand(cmd, facingRight)
	
	
func reset():
	.reset()
	#just to make sure no input
	cmd = null