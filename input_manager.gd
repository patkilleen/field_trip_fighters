extends Node

signal controller_disconnected
signal controller_connected
signal input_update
#number of frames to store inputs for
export (int) var bufferSize = 10
#number of frames to consider a double tapped button
export (float) var doubleTapWindow = 10


const JUST_PRESSED_MAP_IX = 0
const HOLDING_MAP_IX = 1
const RELEASED_MAP_IX = 2

const leakyVariableResource = preload("res://leakyVariable.gd")

#directional input last 5 frames for ripost
var leakyDI = null
#button input last 5 frames for ripost
var leakyBtn = null
#variable to store true when ripost input for a couple frames
var leakyRipostInput= null
var leakyCounterRipostInput= null

#var defaultBufferSize = 5

var inputDeviceId = null

#flag that indicates if we should shrink the input buffer each fram back
#down to the default size
var resetBufferFlag = false

#var manualPhysicsProcessHookCallFlag = false

var grabDIReleaseBlackList={}
#assume game starts with plugged in controllers
var controllerConnected = true

var stopBufferLeakFlag = false

var movementOnlyCommands = false setget setMvmOnlyCommands,getMvmOnlyCommands
var bufferingRipostInputFlag = false setget setBufferingRipostInputFlag,getBufferingRipostInputFlag
const BTN_NO_DIRECTIONAL_INPUT = 0



var btnBitMapBuffer = [0,0,0]


#const BTN_A = 1 # 0001 in binary, 1 decimal
#const BTN_B = 2 # 0010 in binary, 2 deciaml 
#const BTN_X = 4 # 0100 in binary, 4 decimal
#const BTN_Y = 8 # 1000 in binary, 8 decimal

#const BTN_LEFT = 16 #  0001 0000 in binary, 16 decimal
#const BTN_RIGHT = 32 # 0010 0000 in binary, 32 deciaml
#const BTN_UP = 64 #    0100 0000 in binary
#const BTN_DOWN = 128 # 1000 0000 in binary

#const BTN_RIGHT_BUMPER = 256 # 0001 0000 0000 in binary
#const BTN_START = 512 # 0010 0000 0000 in binary
#const BTN_RIGHT_TRIGGER = 1024 # 0100 0000 0000 in binary
#const BTN_LEFT_TRIGGER = 2048 # 1000 0000 0000 in binary
#const BTN_LEFT_BUMPER = 4096 # 0001 0000 0000 0000 in binary

#c-stick (right stick)
#const BTN_C_STICK_LEFT = 8192  # 0010 0000 0000 0000 in binary
#const BTN_C_STICK_RIGHT = 16384 # 0100 0000 in binary
#const BTN_C_STICK_UP = 32768 
#    1000 0000 in binary
#const BTN_C_STICK_DOWN = 65536 # 0001 0000 0000 0000 in binary 

const BTN_A = 1 #(BIT SHIFT 0) 0001 in binary, 1 decimal
const BTN_B = 1 << 1 # 0010 in binary, 2 deciaml 
const BTN_X = 1 << 2 # 0100 in binary, 4 decimal
const BTN_Y = 1 << 3 # 1000 in binary, 8 decimal

const BTN_LEFT = 1 << 4 #  0001 0000 in binary, 16 decimal
const BTN_RIGHT = 1 << 5 # 0010 0000 in binary, 32 deciaml
const BTN_UP = 1 << 6 #    0100 0000 in binary
const BTN_DOWN = 1 << 7 # 1000 0000 in binary

const BTN_RIGHT_BUMPER = 1 << 8 # 0001 0000 0000 in binary
const BTN_START = 1 << 9 # 0010 0000 0000 in binary
const BTN_RIGHT_TRIGGER = 1 << 10 # 0100 0000 0000 in binary
const BTN_LEFT_TRIGGER = 1 << 11 # 1000 0000 0000 in binary
const BTN_LEFT_BUMPER = 1 << 12 # 0001 0000 0000 0000 in binary

#c-stick (right stick)
const BTN_C_STICK_LEFT = 1 << 13  # 0010 0000 0000 0000 in binary
const BTN_C_STICK_RIGHT = 1 << 14 # 0100 0000 in binary
const BTN_C_STICK_UP = 1 << 15 #    1000 0000 in binary
const BTN_C_STICK_DOWN = 1 << 16 # 0001 0000 0000 0000 in binary 

var GLOBALS = preload("res://Globals.gd")
#changing this will globaly alter speed of animations
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

var cmdStringToEnumMap = {}


var mirrorDIMap = {}
var cmdDIMap = {}
#note that the order of the enum commands is a dependancy of CommandTExtureREct.tsnc 
enum Command{
	CMD_JUMP,
	CMD_NEUTRAL_MELEE,
	CMD_BACKWARD_MELEE,
	CMD_FORWARD_MELEE,
	CMD_DOWNWARD_MELEE,
	CMD_UPWARD_MELEE,
	CMD_NEUTRAL_SPECIAL,
	CMD_BACKWARD_SPECIAL,
	CMD_FORWARD_SPECIAL,
	CMD_DOWNWARD_SPECIAL,
	CMD_UPWARD_SPECIAL,#10
	CMD_NEUTRAL_TOOL,
	CMD_BACKWARD_TOOL,
	CMD_FORWARD_TOOL,
	CMD_DOWNWARD_TOOL,
	CMD_UPWARD_TOOL,
	CMD_MOVE_FORWARD,
	CMD_MOVE_BACKWARD,
	CMD_STOP_MOVE_FORWARD,
	CMD_STOP_MOVE_BACKWARD,
	CMD_DASH_FORWARD,#20
	CMD_DASH_BACKWARD,
	CMD_CROUCH,
	CMD_STOP_CROUCH,
	CMD_JUMP_FORWARD,
	CMD_JUMP_BACKWARD,
	CMD_AIR_DASH_DOWNWARD,
	CMD_START,
	CMD_AUTO_RIPOST,
	CMD_GRAB,
	CMD_RIPOST_NEUTRAL_MELEE,#30
	CMD_RIPOST_NEUTRAL_SPECIAL,
	CMD_RIPOST_NEUTRAL_TOOL,
	CMD_RIPOST_BACKWARD_SPECIAL,
	CMD_RIPOST_FORWARD_SPECIAL,
	CMD_RIPOST_DOWNWARD_SPECIAL,
	CMD_RIPOST_UPWARD_SPECIAL,
	CMD_RIPOST_BACKWARD_MELEE,
	CMD_RIPOST_FORWARD_MELEE,
	CMD_RIPOST_DOWNWARD_MELEE,
	CMD_RIPOST_UPWARD_MELEE,#40
	CMD_RIPOST_BACKWARD_TOOL,
	CMD_RIPOST_FORWARD_TOOL,
	CMD_RIPOST_DOWNWARD_TOOL,
	CMD_RIPOST_UPWARD_TOOL,
	CMD_ABILITY_BAR_CANCEL_NEXT_MOVE,
	CMD_COUNTER_RIPOST_NEUTRAL_MELEE,
	CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL,
	CMD_COUNTER_RIPOST_NEUTRAL_TOOL,
	CMD_COUNTER_RIPOST_BACKWARD_SPECIAL,
	CMD_COUNTER_RIPOST_FORWARD_SPECIAL,#50
	CMD_COUNTER_RIPOST_DOWNWARD_SPECIAL,
	CMD_COUNTER_RIPOST_UPWARD_SPECIAL,
	CMD_COUNTER_RIPOST_BACKWARD_MELEE,
	CMD_COUNTER_RIPOST_FORWARD_MELEE,
	CMD_COUNTER_RIPOST_DOWNWARD_MELEE,
	CMD_COUNTER_RIPOST_UPWARD_MELEE,
	CMD_COUNTER_RIPOST_BACKWARD_TOOL,
	CMD_COUNTER_RIPOST_FORWARD_TOOL,
	CMD_COUNTER_RIPOST_DOWNWARD_TOOL
	CMD_COUNTER_RIPOST_UPWARD_TOOL,#60
	CMD_FORWARD_CROUCH,
	CMD_BACKWARD_CROUCH,
	CMD_DASH_FORWARD_NO_DIRECTIONAL_INPUT,
	CMD_FORWARD_UP,
	CMD_BACKWARD_UP,
	CMD_UP,
	CMD_BACKWARD_CROUCH_PUSH_BLOCK,
	CMD_BACKWARD_UP_PUSH_BLOCK,
	CMD_BACKWARD_PUSH_BLOCK,
	CMD_FORWARD_CROUCH_PUSH_BLOCK, #necessary for mirroring, 
	CMD_FORWARD_UP_PUSH_BLOCK,
	CMD_FORWARD_PUSH_BLOCK,
	CMD_BUFFERED_PUSH_BLOCK#,CAN'T Be input by player, but will be buffered when player inputs usual push block
	CMD_UP_PUSH_BLOCK,
	CMD_CROUCH_PUSH_BLOCK
	
}


#the button id's of the form 'Pi_<id of button>', where i is 1 or 2 for player 1 or 2, 
#and <id of button> is the input map definition in project settings
const BTN_A_KEY = "A"
const BTN_B_KEY = "B"
const BTN_X_KEY = "X"
const BTN_Y_KEY = "Y"
const BTN_LEFT_KEY = "LEFT"
const BTN_RIGHT_KEY = "RIGHT"
const BTN_UP_KEY = "UP"
const BTN_DOWN_KEY = "DOWN"
const BTN_RIGHT_BUMPER_KEY = "RIGHT_BUMPER"
const BTN_START_KEY = "START"
const BTN_RIGHT_TRIGGER_KEY = "RIGHT_TRIGGER"
const BTN_LEFT_TRIGGER_KEY = "LEFT_TRIGGER"
const BTN_LEFT_BUMPER_KEY = "LEFT_BUMPER"
const BTN_C_STICK_LEFT_KEY = "C_STICK_LEFT"
const BTN_C_STICK_RIGHT_KEY = "C_STICK_RIGHT"
const BTN_C_STICK_UP_KEY = "C_STICK_UP"
const BTN_C_STICK_DOWN_KEY = "C_STICK_DOWN"

#these aren't part of input device buttons, but are used nevertheless in the remapping map
#to check if a move remaps or not
const CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_UP_KEY = "DOUBLE_TAP_UP"
const CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_DOWN_KEY = "DOUBLE_TAP_DOWN"
const CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_RIGHT_KEY = "DOUBLE_TAP_RIGHT"
const CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_LEFT_KEY = "DOUBLE_TAP_LEFT"
const CUSTOM_INPUT_SETTINGS_RIPOST_INPUT_MATCH_FACING_KEY = "RIPOST_INPUT_MATCH_FACING_KEY"

const cStickBtnKeyMap = {BTN_C_STICK_LEFT_KEY:null,BTN_C_STICK_RIGHT_KEY:null,BTN_C_STICK_UP_KEY:null,BTN_C_STICK_DOWN_KEY:null}
#contains the mapping from button string value to constant value
var btnMap = {}

#player input map: contains remapped buttons of player's custom settings
var pInRemap = {}

#array of inputBitMaps that represent buttons pressed each frame
var inputHistory  = []

#buffer of commands
var cmdBuffer = []

#commands found in this map won't get buffered
var unbufferableCommands = {}

var lastCommand = null

#last directional input
var lastDI= GLOBALS.DirectionalInput.NEUTRAL

#last directional input held when release grab
var lastGrabDI=GLOBALS.DirectionalInput.NEUTRAL

var ignoreGrabDI = true
#holds commands pair that differe depending on facing
var mirroredCommandMap = {}

#holds the ripost and counter ripost commnads, linking them to the command they ripost/counter
var ripostCommandMap = {}
var counterRipostCommandMap = {}
var ripostCommandReverseMap = {}
var costumSettignsRipostCommandReverseMap = {} #the map used when you gotting copy (not mirror) the ripost input. custom ssetting from name
var counterRipostCommandReverseMap = {}
var counterRipostAirCommandMap = {}
var ripostToCounterRipostMap = {}
var commandMap = {}
var mvmOnlyCmdMap = {}
var holdingBackCmdMap = {}
var holdingDownCmdMap = {}
var abilityCancelInputCmdMap = {}

#var inputBufferRemappingMap ={}
func _ready():
	
		#make sure this node is part of group that gets notification
	#on global speed mod change
	#add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	
	bufferSize = GLOBALS.INPUT_BUFFER_SIZE
	
	set_physics_process(false)
	
	
	

func setMvmOnlyCommands(f):
	if f == false:
		pass
	movementOnlyCommands = f
func getMvmOnlyCommands():
	return movementOnlyCommands

func setBufferingRipostInputFlag(f):
	bufferingRipostInputFlag = f
	
func getBufferingRipostInputFlag():
	return bufferingRipostInputFlag
func populateLookupMaps():
	
	#fill the unburreable commands
	unbufferableCommands[Command.CMD_STOP_CROUCH] = true
	unbufferableCommands[Command.CMD_CROUCH]=true
	unbufferableCommands[Command.CMD_MOVE_FORWARD]=true
	unbufferableCommands[Command.CMD_MOVE_BACKWARD]=true
	unbufferableCommands[Command.CMD_FORWARD_CROUCH]=true
	unbufferableCommands[Command.CMD_BACKWARD_CROUCH]=true
	unbufferableCommands[Command.CMD_UP]=true
	unbufferableCommands[Command.CMD_FORWARD_UP]=true
	unbufferableCommands[Command.CMD_BACKWARD_UP]=true
	unbufferableCommands[Command.CMD_STOP_MOVE_FORWARD]=true
	unbufferableCommands[Command.CMD_STOP_MOVE_BACKWARD]=true
	#unbufferableCommands[Command.CMD_RELEASED_GRAB]=true
	
	#unbufferableCommands[Command.CMD_BACKWARD_CROUCH_PUSH_BLOCK]=true
	#unbufferableCommands[Command.CMD_BACKWARD_PUSH_BLOCK]=true
	#unbufferableCommands[Command.CMD_BACKWARD_UP_PUSH_BLOCK]=true
	#unbufferableCommands[Command.CMD_FORWARD_CROUCH_PUSH_BLOCK]=true
	#unbufferableCommands[Command.CMD_FORWARD_PUSH_BLOCK]=true
	#unbufferableCommands[Command.CMD_FORWARD_UP_PUSH_BLOCK]=true

	#initialize button map
	btnMap[BTN_A_KEY] = BTN_A
	btnMap[BTN_B_KEY] = BTN_B
	btnMap[BTN_X_KEY] = BTN_X
	btnMap[BTN_Y_KEY] = BTN_Y
	btnMap[BTN_LEFT_KEY] = BTN_LEFT
	btnMap[BTN_RIGHT_KEY] = BTN_RIGHT
	btnMap[BTN_UP_KEY] = BTN_UP
	btnMap[BTN_DOWN_KEY] = BTN_DOWN
	btnMap[BTN_RIGHT_BUMPER_KEY] = BTN_RIGHT_BUMPER
	btnMap[BTN_START_KEY] = BTN_START
	btnMap[BTN_RIGHT_TRIGGER_KEY] = BTN_RIGHT_TRIGGER
	btnMap[BTN_LEFT_TRIGGER_KEY] = BTN_LEFT_TRIGGER
	btnMap[BTN_LEFT_BUMPER_KEY]= BTN_LEFT_BUMPER
	btnMap[BTN_C_STICK_LEFT_KEY] = BTN_C_STICK_LEFT
	btnMap[BTN_C_STICK_RIGHT_KEY] = BTN_C_STICK_RIGHT
	btnMap[BTN_C_STICK_UP_KEY] = BTN_C_STICK_UP
	btnMap[BTN_C_STICK_DOWN_KEY] = BTN_C_STICK_DOWN
	
	#no remapping by default
	for k in btnMap.keys():
		pInRemap[k]=btnMap[k]

	pInRemap[BTN_C_STICK_LEFT_KEY] = BTN_LEFT | BTN_RIGHT_TRIGGER #BACK DASH
	pInRemap[BTN_C_STICK_RIGHT_KEY] =  BTN_RIGHT | BTN_RIGHT_TRIGGER #FORWARD DASH
	pInRemap[BTN_C_STICK_UP_KEY] =  BTN_LEFT_TRIGGER | BTN_RIGHT_BUMPER #AUTO RIPOST
	pInRemap[BTN_C_STICK_DOWN_KEY] = BTN_DOWN | BTN_RIGHT_TRIGGER #FAST FALL
	
	#debug, uncomment below 4 lines of code to enable double tap to dash/jump
	#disabled by default (settings for a name can allow such inputs)
	#pInRemap[CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_UP_KEY]=null
	#pInRemap[CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_DOWN_KEY]=null
	#pInRemap[CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_RIGHT_KEY]=null
	#pInRemap[CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_LEFT_KEY]=null

	#initialize the map for getting command based on direction and button
	commandMap[BTN_X] = {}
	commandMap[BTN_X][BTN_LEFT]=Command.CMD_BACKWARD_MELEE
	commandMap[BTN_X][BTN_RIGHT]=Command.CMD_FORWARD_MELEE
	commandMap[BTN_X][BTN_DOWN]=Command.CMD_DOWNWARD_MELEE
	commandMap[BTN_X][BTN_UP]=Command.CMD_UPWARD_MELEE
	commandMap[BTN_X][BTN_NO_DIRECTIONAL_INPUT]=Command.CMD_NEUTRAL_MELEE	
	
	commandMap[BTN_Y] = {}
	commandMap[BTN_Y][BTN_LEFT]=Command.CMD_BACKWARD_SPECIAL
	commandMap[BTN_Y][BTN_RIGHT]=Command.CMD_FORWARD_SPECIAL
	commandMap[BTN_Y][BTN_DOWN]=Command.CMD_DOWNWARD_SPECIAL
	commandMap[BTN_Y][BTN_UP]=Command.CMD_UPWARD_SPECIAL
	commandMap[BTN_Y][BTN_NO_DIRECTIONAL_INPUT]=Command.CMD_NEUTRAL_SPECIAL
	
	commandMap[BTN_B] = {}
	commandMap[BTN_B][BTN_LEFT]=Command.CMD_BACKWARD_TOOL
	commandMap[BTN_B][BTN_RIGHT]=Command.CMD_FORWARD_TOOL
	commandMap[BTN_B][BTN_DOWN]=Command.CMD_DOWNWARD_TOOL
	commandMap[BTN_B][BTN_UP]=Command.CMD_UPWARD_TOOL
	commandMap[BTN_B][BTN_NO_DIRECTIONAL_INPUT]=Command.CMD_NEUTRAL_TOOL
	

	#commands that indicate back is pressed/held
	#no need for value, only key used for looking up whether cmd counts as hold back or not
	holdingBackCmdMap[Command.CMD_MOVE_BACKWARD]=null 
	holdingBackCmdMap[Command.CMD_BACKWARD_CROUCH]=null 
	holdingBackCmdMap[Command.CMD_BACKWARD_UP]=null 
	holdingBackCmdMap[Command.CMD_JUMP_BACKWARD]=null 
	holdingBackCmdMap[Command.CMD_BACKWARD_MELEE]=null 
	holdingBackCmdMap[Command.CMD_BACKWARD_SPECIAL]=null 
	holdingBackCmdMap[Command.CMD_BACKWARD_TOOL]=null 
	holdingBackCmdMap[Command.CMD_BACKWARD_CROUCH_PUSH_BLOCK]=null 
	holdingBackCmdMap[Command.CMD_BACKWARD_PUSH_BLOCK]=null 
	holdingBackCmdMap[Command.CMD_BACKWARD_UP_PUSH_BLOCK]=null 
	holdingBackCmdMap[Command.CMD_DASH_BACKWARD]=null 
	holdingBackCmdMap[Command.CMD_RIPOST_BACKWARD_MELEE]=null 
	holdingBackCmdMap[Command.CMD_RIPOST_BACKWARD_SPECIAL]=null 
	holdingBackCmdMap[Command.CMD_RIPOST_BACKWARD_TOOL]=null 
	holdingBackCmdMap[Command.CMD_COUNTER_RIPOST_BACKWARD_MELEE]=null 
	holdingBackCmdMap[Command.CMD_COUNTER_RIPOST_BACKWARD_SPECIAL]=null 
	holdingBackCmdMap[Command.CMD_COUNTER_RIPOST_BACKWARD_TOOL]=null 

	#commands that involved holding/pressing down
	holdingDownCmdMap[Command.CMD_DOWNWARD_MELEE]=null
	holdingDownCmdMap[Command.CMD_DOWNWARD_SPECIAL]=null
	holdingDownCmdMap[Command.CMD_DOWNWARD_TOOL]=null
	holdingDownCmdMap[Command.CMD_CROUCH]=null
	holdingDownCmdMap[Command.CMD_AIR_DASH_DOWNWARD]=null
	holdingDownCmdMap[Command.CMD_RIPOST_DOWNWARD_MELEE]=null
	holdingDownCmdMap[Command.CMD_RIPOST_DOWNWARD_SPECIAL]=null
	holdingDownCmdMap[Command.CMD_RIPOST_DOWNWARD_TOOL]=null
	holdingDownCmdMap[Command.CMD_COUNTER_RIPOST_DOWNWARD_MELEE]=null
	holdingDownCmdMap[Command.CMD_COUNTER_RIPOST_DOWNWARD_SPECIAL]=null
	holdingDownCmdMap[Command.CMD_COUNTER_RIPOST_DOWNWARD_TOOL]=null
	holdingDownCmdMap[Command.CMD_FORWARD_CROUCH]=null
	holdingDownCmdMap[Command.CMD_BACKWARD_CROUCH]=null
	holdingDownCmdMap[Command.CMD_BACKWARD_CROUCH_PUSH_BLOCK]=null
	holdingDownCmdMap[Command.CMD_FORWARD_CROUCH_PUSH_BLOCK]=null
	
	#command that involve pressing/holding left-rigger/L2
	#no need for value, only key used for looking up whether cmd counts as hold back or not
	abilityCancelInputCmdMap[Command.CMD_AUTO_RIPOST]=null
	abilityCancelInputCmdMap[Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE]=null
	abilityCancelInputCmdMap[Command.CMD_BACKWARD_CROUCH_PUSH_BLOCK]=null
	abilityCancelInputCmdMap[Command.CMD_BACKWARD_UP_PUSH_BLOCK]=null
	abilityCancelInputCmdMap[Command.CMD_CROUCH_PUSH_BLOCK]=null
	abilityCancelInputCmdMap[Command.CMD_UP_PUSH_BLOCK]=null
	abilityCancelInputCmdMap[Command.CMD_BACKWARD_PUSH_BLOCK]=null
	abilityCancelInputCmdMap[Command.CMD_FORWARD_CROUCH_PUSH_BLOCK]=null
	abilityCancelInputCmdMap[Command.CMD_FORWARD_UP_PUSH_BLOCK]=null
	abilityCancelInputCmdMap[Command.CMD_FORWARD_PUSH_BLOCK]=null
	
	#initialize map used to lookup the opposite command
	#when facing is command dependant
	mirroredCommandMap[Command.CMD_BACKWARD_MELEE]=Command.CMD_FORWARD_MELEE
	mirroredCommandMap[Command.CMD_FORWARD_MELEE]=Command.CMD_BACKWARD_MELEE
	mirroredCommandMap[Command.CMD_BACKWARD_SPECIAL]=Command.CMD_FORWARD_SPECIAL
	mirroredCommandMap[Command.CMD_FORWARD_SPECIAL]=Command.CMD_BACKWARD_SPECIAL
	mirroredCommandMap[Command.CMD_BACKWARD_TOOL]=Command.CMD_FORWARD_TOOL
	mirroredCommandMap[Command.CMD_FORWARD_TOOL]=Command.CMD_BACKWARD_TOOL
	mirroredCommandMap[Command.CMD_MOVE_FORWARD]=Command.CMD_MOVE_BACKWARD
	mirroredCommandMap[Command.CMD_MOVE_BACKWARD]=Command.CMD_MOVE_FORWARD
	mirroredCommandMap[Command.CMD_BACKWARD_PUSH_BLOCK]=Command.CMD_FORWARD_PUSH_BLOCK
	mirroredCommandMap[Command.CMD_FORWARD_PUSH_BLOCK]=Command.CMD_BACKWARD_PUSH_BLOCK
	mirroredCommandMap[Command.CMD_BACKWARD_CROUCH]=Command.CMD_FORWARD_CROUCH
	mirroredCommandMap[Command.CMD_BACKWARD_CROUCH_PUSH_BLOCK]=Command.CMD_FORWARD_CROUCH_PUSH_BLOCK
	mirroredCommandMap[Command.CMD_FORWARD_CROUCH_PUSH_BLOCK]=Command.CMD_BACKWARD_CROUCH_PUSH_BLOCK
	mirroredCommandMap[Command.CMD_FORWARD_CROUCH]=Command.CMD_BACKWARD_CROUCH
	mirroredCommandMap[Command.CMD_BACKWARD_UP]=Command.CMD_FORWARD_UP
	mirroredCommandMap[Command.CMD_FORWARD_UP]=Command.CMD_BACKWARD_UP
	mirroredCommandMap[Command.CMD_BACKWARD_UP_PUSH_BLOCK]=Command.CMD_FORWARD_UP_PUSH_BLOCK
	mirroredCommandMap[Command.CMD_FORWARD_UP_PUSH_BLOCK]=Command.CMD_BACKWARD_UP_PUSH_BLOCK	
	mirroredCommandMap[Command.CMD_STOP_MOVE_FORWARD]=Command.CMD_STOP_MOVE_BACKWARD
	mirroredCommandMap[Command.CMD_STOP_MOVE_BACKWARD]=Command.CMD_STOP_MOVE_FORWARD
	mirroredCommandMap[Command.CMD_DASH_FORWARD]=Command.CMD_DASH_BACKWARD
	mirroredCommandMap[Command.CMD_DASH_BACKWARD]=Command.CMD_DASH_FORWARD
	mirroredCommandMap[Command.CMD_JUMP_FORWARD]=Command.CMD_JUMP_BACKWARD
	mirroredCommandMap[Command.CMD_JUMP_BACKWARD]=Command.CMD_JUMP_FORWARD
	
	
	
	
	#mirroredCommandMap[Command.CMD_BACKWARD_UP_RELEASE]=Command.CMD_GRAB
	#mirroredCommandMap[Command.CMD_GRAB]=Command.CMD_BACKWARD_UP_RELEASE
	mirroredCommandMap[Command.CMD_RIPOST_BACKWARD_MELEE]=Command.CMD_RIPOST_FORWARD_MELEE
	mirroredCommandMap[Command.CMD_RIPOST_FORWARD_MELEE]=Command.CMD_RIPOST_BACKWARD_MELEE
	mirroredCommandMap[Command.CMD_RIPOST_BACKWARD_SPECIAL]=Command.CMD_RIPOST_FORWARD_SPECIAL
	mirroredCommandMap[Command.CMD_RIPOST_FORWARD_SPECIAL]=Command.CMD_RIPOST_BACKWARD_SPECIAL
	mirroredCommandMap[Command.CMD_RIPOST_BACKWARD_TOOL]=Command.CMD_RIPOST_FORWARD_TOOL
	mirroredCommandMap[Command.CMD_RIPOST_FORWARD_TOOL]=Command.CMD_RIPOST_BACKWARD_TOOL
	mirroredCommandMap[Command.CMD_COUNTER_RIPOST_FORWARD_MELEE]=Command.CMD_COUNTER_RIPOST_BACKWARD_MELEE
	mirroredCommandMap[Command.CMD_COUNTER_RIPOST_BACKWARD_MELEE]=Command.CMD_COUNTER_RIPOST_FORWARD_MELEE
	mirroredCommandMap[Command.CMD_COUNTER_RIPOST_FORWARD_SPECIAL]=Command.CMD_COUNTER_RIPOST_BACKWARD_SPECIAL
	mirroredCommandMap[Command.CMD_COUNTER_RIPOST_BACKWARD_SPECIAL]=Command.CMD_COUNTER_RIPOST_FORWARD_SPECIAL
	mirroredCommandMap[Command.CMD_COUNTER_RIPOST_FORWARD_TOOL]=Command.CMD_COUNTER_RIPOST_BACKWARD_TOOL
	mirroredCommandMap[Command.CMD_COUNTER_RIPOST_BACKWARD_TOOL]=Command.CMD_COUNTER_RIPOST_FORWARD_TOOL
	
	
	mirrorDIMap[GLOBALS.DirectionalInput.UP]=GLOBALS.DirectionalInput.UP
	mirrorDIMap[GLOBALS.DirectionalInput.FORWARD_UP]=GLOBALS.DirectionalInput.BACKWARD_UP
	mirrorDIMap[GLOBALS.DirectionalInput.FORWARD]=GLOBALS.DirectionalInput.BACKWARD
	mirrorDIMap[GLOBALS.DirectionalInput.FORWARD_DOWN]=GLOBALS.DirectionalInput.BACKWARD_DOWN
	mirrorDIMap[GLOBALS.DirectionalInput.DOWN]=GLOBALS.DirectionalInput.DOWN
	mirrorDIMap[GLOBALS.DirectionalInput.BACKWARD_DOWN]=GLOBALS.DirectionalInput.FORWARD_DOWN
	mirrorDIMap[GLOBALS.DirectionalInput.BACKWARD]=GLOBALS.DirectionalInput.FORWARD
	mirrorDIMap[GLOBALS.DirectionalInput.BACKWARD_UP]=GLOBALS.DirectionalInput.FORWARD_UP
	mirrorDIMap[GLOBALS.DirectionalInput.NEUTRAL]=GLOBALS.DirectionalInput.NEUTRAL
	
	
	
	cmdDIMap[Command.CMD_JUMP]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_NEUTRAL_MELEE]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_BACKWARD_MELEE]=GLOBALS.DirectionalInput.BACKWARD
	cmdDIMap[Command.CMD_FORWARD_MELEE]=GLOBALS.DirectionalInput.FORWARD
	cmdDIMap[Command.CMD_DOWNWARD_MELEE]=GLOBALS.DirectionalInput.DOWN
	cmdDIMap[Command.CMD_UPWARD_MELEE]=GLOBALS.DirectionalInput.UP
	cmdDIMap[Command.CMD_NEUTRAL_SPECIAL]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_BACKWARD_SPECIAL]=GLOBALS.DirectionalInput.BACKWARD
	cmdDIMap[Command.CMD_FORWARD_SPECIAL]=GLOBALS.DirectionalInput.FORWARD
	cmdDIMap[Command.CMD_DOWNWARD_SPECIAL]=GLOBALS.DirectionalInput.DOWN
	cmdDIMap[Command.CMD_UPWARD_SPECIAL]=GLOBALS.DirectionalInput.UP
	cmdDIMap[Command.CMD_NEUTRAL_TOOL]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_BACKWARD_TOOL]=GLOBALS.DirectionalInput.BACKWARD
	cmdDIMap[Command.CMD_FORWARD_TOOL]=GLOBALS.DirectionalInput.FORWARD
	cmdDIMap[Command.CMD_DOWNWARD_TOOL]=GLOBALS.DirectionalInput.DOWN
	cmdDIMap[Command.CMD_UPWARD_TOOL]=GLOBALS.DirectionalInput.UP
	cmdDIMap[Command.CMD_MOVE_FORWARD]=GLOBALS.DirectionalInput.FORWARD
	cmdDIMap[Command.CMD_MOVE_BACKWARD]=GLOBALS.DirectionalInput.BACKWARD
	cmdDIMap[Command.CMD_STOP_MOVE_FORWARD]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_STOP_MOVE_BACKWARD]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_DASH_FORWARD]=GLOBALS.DirectionalInput.FORWARD
	cmdDIMap[Command.CMD_DASH_BACKWARD]=GLOBALS.DirectionalInput.BACKWARD
	cmdDIMap[Command.CMD_CROUCH]=GLOBALS.DirectionalInput.DOWN
	cmdDIMap[Command.CMD_STOP_CROUCH]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_JUMP_FORWARD]=GLOBALS.DirectionalInput.FORWARD
	cmdDIMap[Command.CMD_JUMP_BACKWARD]=GLOBALS.DirectionalInput.BACKWARD
	cmdDIMap[Command.CMD_AIR_DASH_DOWNWARD]=GLOBALS.DirectionalInput.DOWN
	cmdDIMap[Command.CMD_START]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_AUTO_RIPOST]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_GRAB]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_RIPOST_NEUTRAL_MELEE]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_RIPOST_NEUTRAL_SPECIAL]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_RIPOST_NEUTRAL_TOOL]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_RIPOST_BACKWARD_SPECIAL]=GLOBALS.DirectionalInput.BACKWARD
	cmdDIMap[Command.CMD_RIPOST_FORWARD_SPECIAL]=GLOBALS.DirectionalInput.FORWARD
	cmdDIMap[Command.CMD_RIPOST_DOWNWARD_SPECIAL]=GLOBALS.DirectionalInput.DOWN
	cmdDIMap[Command.CMD_RIPOST_UPWARD_SPECIAL]=GLOBALS.DirectionalInput.UP
	cmdDIMap[Command.CMD_RIPOST_BACKWARD_MELEE]=GLOBALS.DirectionalInput.BACKWARD
	cmdDIMap[Command.CMD_RIPOST_FORWARD_MELEE]=GLOBALS.DirectionalInput.FORWARD
	cmdDIMap[Command.CMD_RIPOST_DOWNWARD_MELEE]=GLOBALS.DirectionalInput.DOWN
	cmdDIMap[Command.CMD_RIPOST_UPWARD_MELEE]=GLOBALS.DirectionalInput.UP
	cmdDIMap[Command.CMD_RIPOST_BACKWARD_TOOL]=GLOBALS.DirectionalInput.BACKWARD
	cmdDIMap[Command.CMD_RIPOST_FORWARD_TOOL]=GLOBALS.DirectionalInput.FORWARD
	cmdDIMap[Command.CMD_RIPOST_DOWNWARD_TOOL]=GLOBALS.DirectionalInput.DOWN
	cmdDIMap[Command.CMD_RIPOST_UPWARD_TOOL]=GLOBALS.DirectionalInput.UP
	cmdDIMap[Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_COUNTER_RIPOST_BACKWARD_SPECIAL]=GLOBALS.DirectionalInput.BACKWARD
	cmdDIMap[Command.CMD_COUNTER_RIPOST_FORWARD_SPECIAL]=GLOBALS.DirectionalInput.FORWARD
	cmdDIMap[Command.CMD_COUNTER_RIPOST_DOWNWARD_SPECIAL]=GLOBALS.DirectionalInput.DOWN
	cmdDIMap[Command.CMD_COUNTER_RIPOST_UPWARD_SPECIAL]=GLOBALS.DirectionalInput.UP
	cmdDIMap[Command.CMD_COUNTER_RIPOST_BACKWARD_MELEE]=GLOBALS.DirectionalInput.BACKWARD
	cmdDIMap[Command.CMD_COUNTER_RIPOST_FORWARD_MELEE]=GLOBALS.DirectionalInput.FORWARD
	cmdDIMap[Command.CMD_COUNTER_RIPOST_DOWNWARD_MELEE]=GLOBALS.DirectionalInput.DOWN
	cmdDIMap[Command.CMD_COUNTER_RIPOST_UPWARD_MELEE]=GLOBALS.DirectionalInput.UP
	cmdDIMap[Command.CMD_COUNTER_RIPOST_BACKWARD_TOOL]=GLOBALS.DirectionalInput.BACKWARD
	cmdDIMap[Command.CMD_COUNTER_RIPOST_FORWARD_TOOL]=GLOBALS.DirectionalInput.FORWARD
	cmdDIMap[Command.CMD_COUNTER_RIPOST_DOWNWARD_TOOL]=GLOBALS.DirectionalInput.DOWN
	cmdDIMap[Command.CMD_COUNTER_RIPOST_UPWARD_TOOL]=GLOBALS.DirectionalInput.UP
	cmdDIMap[Command.CMD_FORWARD_CROUCH]=GLOBALS.DirectionalInput.FORWARD_DOWN
	cmdDIMap[Command.CMD_BACKWARD_CROUCH]=GLOBALS.DirectionalInput.BACKWARD_DOWN
	cmdDIMap[Command.CMD_DASH_FORWARD_NO_DIRECTIONAL_INPUT]=GLOBALS.DirectionalInput.NEUTRAL
	cmdDIMap[Command.CMD_FORWARD_UP]=GLOBALS.DirectionalInput.FORWARD_UP
	cmdDIMap[Command.CMD_BACKWARD_UP]=GLOBALS.DirectionalInput.BACKWARD_UP
	cmdDIMap[Command.CMD_UP]=GLOBALS.DirectionalInput.UP
	cmdDIMap[Command.CMD_BACKWARD_CROUCH_PUSH_BLOCK]=GLOBALS.DirectionalInput.BACKWARD_DOWN
	cmdDIMap[Command.CMD_BACKWARD_UP_PUSH_BLOCK]=GLOBALS.DirectionalInput.BACKWARD_UP
	cmdDIMap[Command.CMD_BACKWARD_PUSH_BLOCK]=GLOBALS.DirectionalInput.BACKWARD
	cmdDIMap[Command.CMD_FORWARD_CROUCH_PUSH_BLOCK]=GLOBALS.DirectionalInput.FORWARD_DOWN
	cmdDIMap[Command.CMD_FORWARD_UP_PUSH_BLOCK]=GLOBALS.DirectionalInput.FORWARD_UP
	cmdDIMap[Command.CMD_FORWARD_PUSH_BLOCK]=GLOBALS.DirectionalInput.FORWARD
	cmdDIMap[Command.CMD_BUFFERED_PUSH_BLOCK]=GLOBALS.DirectionalInput.NEUTRAL
	#cmdDIMap[Command.CMD_RELEASED_GRAB]=GLOBALS.DirectionalInput.NEUTRAL
	
	
	
	
	#INITIAL grab di map where realseing stick/buttons won't affect diagonal inputs
	var innerMap = {}
	innerMap[GLOBALS.DirectionalInput.BACKWARD]=null
	innerMap[GLOBALS.DirectionalInput.DOWN]=null
	grabDIReleaseBlackList[GLOBALS.DirectionalInput.BACKWARD_DOWN]=innerMap
	
	innerMap = {}
	innerMap[GLOBALS.DirectionalInput.BACKWARD]=null
	innerMap[GLOBALS.DirectionalInput.UP]=null
	grabDIReleaseBlackList[GLOBALS.DirectionalInput.BACKWARD_UP]=innerMap
	
	innerMap = {}
	innerMap[GLOBALS.DirectionalInput.FORWARD]=null
	innerMap[GLOBALS.DirectionalInput.UP]=null
	grabDIReleaseBlackList[GLOBALS.DirectionalInput.FORWARD_UP]=innerMap
	
	innerMap = {}
	innerMap[GLOBALS.DirectionalInput.FORWARD]=null
	innerMap[GLOBALS.DirectionalInput.DOWN]=null
	grabDIReleaseBlackList[GLOBALS.DirectionalInput.FORWARD_DOWN]=innerMap
	
	
	#initialize maps that will assosiate ripost commands
	#to the commands they ripost
	
	ripostCommandMap[Command.CMD_RIPOST_NEUTRAL_MELEE]=Command.CMD_NEUTRAL_MELEE
	ripostCommandMap[Command.CMD_RIPOST_NEUTRAL_SPECIAL]=Command.CMD_NEUTRAL_SPECIAL
	ripostCommandMap[Command.CMD_RIPOST_NEUTRAL_TOOL]=Command.CMD_NEUTRAL_TOOL
	ripostCommandMap[Command.CMD_RIPOST_BACKWARD_MELEE]=Command.CMD_BACKWARD_MELEE
	ripostCommandMap[Command.CMD_RIPOST_FORWARD_MELEE]=Command.CMD_FORWARD_MELEE
	ripostCommandMap[Command.CMD_RIPOST_DOWNWARD_MELEE]=Command.CMD_DOWNWARD_MELEE
	ripostCommandMap[Command.CMD_RIPOST_UPWARD_MELEE]=Command.CMD_UPWARD_MELEE
	ripostCommandMap[Command.CMD_RIPOST_BACKWARD_SPECIAL]=Command.CMD_BACKWARD_SPECIAL
	ripostCommandMap[Command.CMD_RIPOST_FORWARD_SPECIAL]=Command.CMD_FORWARD_SPECIAL
	ripostCommandMap[Command.CMD_RIPOST_DOWNWARD_SPECIAL]=Command.CMD_DOWNWARD_SPECIAL
	ripostCommandMap[Command.CMD_RIPOST_UPWARD_SPECIAL]=Command.CMD_UPWARD_SPECIAL
	ripostCommandMap[Command.CMD_RIPOST_BACKWARD_TOOL]=Command.CMD_BACKWARD_TOOL
	ripostCommandMap[Command.CMD_RIPOST_FORWARD_TOOL]=Command.CMD_FORWARD_TOOL
	ripostCommandMap[Command.CMD_RIPOST_DOWNWARD_TOOL]=Command.CMD_DOWNWARD_TOOL
	ripostCommandMap[Command.CMD_RIPOST_UPWARD_TOOL]=Command.CMD_UPWARD_TOOL
	
	
	#reverse ripost command lookup
	ripostCommandReverseMap[Command.CMD_NEUTRAL_MELEE]=Command.CMD_RIPOST_NEUTRAL_MELEE
	ripostCommandReverseMap[Command.CMD_NEUTRAL_SPECIAL]=Command.CMD_RIPOST_NEUTRAL_SPECIAL
	ripostCommandReverseMap[Command.CMD_NEUTRAL_TOOL]=Command.CMD_RIPOST_NEUTRAL_TOOL
	ripostCommandReverseMap[Command.CMD_BACKWARD_MELEE]=Command.CMD_RIPOST_BACKWARD_MELEE
	ripostCommandReverseMap[Command.CMD_FORWARD_MELEE]=Command.CMD_RIPOST_FORWARD_MELEE
	ripostCommandReverseMap[Command.CMD_DOWNWARD_MELEE]=Command.CMD_RIPOST_DOWNWARD_MELEE
	ripostCommandReverseMap[Command.CMD_UPWARD_MELEE]=Command.CMD_RIPOST_UPWARD_MELEE
	ripostCommandReverseMap[Command.CMD_BACKWARD_SPECIAL]=Command.CMD_RIPOST_BACKWARD_SPECIAL
	ripostCommandReverseMap[Command.CMD_FORWARD_SPECIAL]=Command.CMD_RIPOST_FORWARD_SPECIAL
	ripostCommandReverseMap[Command.CMD_DOWNWARD_SPECIAL]=Command.CMD_RIPOST_DOWNWARD_SPECIAL
	ripostCommandReverseMap[Command.CMD_UPWARD_SPECIAL]=Command.CMD_RIPOST_UPWARD_SPECIAL
	ripostCommandReverseMap[Command.CMD_BACKWARD_TOOL]=Command.CMD_RIPOST_BACKWARD_TOOL
	ripostCommandReverseMap[Command.CMD_FORWARD_TOOL]=Command.CMD_RIPOST_FORWARD_TOOL
	ripostCommandReverseMap[Command.CMD_DOWNWARD_TOOL]=Command.CMD_RIPOST_DOWNWARD_TOOL
	ripostCommandReverseMap[Command.CMD_UPWARD_TOOL]=Command.CMD_RIPOST_UPWARD_TOOL
	
	
	costumSettignsRipostCommandReverseMap[Command.CMD_NEUTRAL_MELEE]=Command.CMD_RIPOST_NEUTRAL_MELEE
	costumSettignsRipostCommandReverseMap[Command.CMD_NEUTRAL_SPECIAL]=Command.CMD_RIPOST_NEUTRAL_SPECIAL
	costumSettignsRipostCommandReverseMap[Command.CMD_NEUTRAL_TOOL]=Command.CMD_RIPOST_NEUTRAL_TOOL
	costumSettignsRipostCommandReverseMap[Command.CMD_BACKWARD_MELEE]=Command.CMD_RIPOST_FORWARD_MELEE
	costumSettignsRipostCommandReverseMap[Command.CMD_FORWARD_MELEE]=Command.CMD_RIPOST_BACKWARD_MELEE
	costumSettignsRipostCommandReverseMap[Command.CMD_DOWNWARD_MELEE]=Command.CMD_RIPOST_DOWNWARD_MELEE
	costumSettignsRipostCommandReverseMap[Command.CMD_UPWARD_MELEE]=Command.CMD_RIPOST_UPWARD_MELEE
	costumSettignsRipostCommandReverseMap[Command.CMD_BACKWARD_SPECIAL]=Command.CMD_RIPOST_FORWARD_SPECIAL
	costumSettignsRipostCommandReverseMap[Command.CMD_FORWARD_SPECIAL]=Command.CMD_RIPOST_BACKWARD_SPECIAL
	costumSettignsRipostCommandReverseMap[Command.CMD_DOWNWARD_SPECIAL]=Command.CMD_RIPOST_DOWNWARD_SPECIAL
	costumSettignsRipostCommandReverseMap[Command.CMD_UPWARD_SPECIAL]=Command.CMD_RIPOST_UPWARD_SPECIAL
	costumSettignsRipostCommandReverseMap[Command.CMD_BACKWARD_TOOL]=Command.CMD_RIPOST_FORWARD_TOOL
	costumSettignsRipostCommandReverseMap[Command.CMD_FORWARD_TOOL]=Command.CMD_RIPOST_BACKWARD_TOOL
	costumSettignsRipostCommandReverseMap[Command.CMD_DOWNWARD_TOOL]=Command.CMD_RIPOST_DOWNWARD_TOOL
	costumSettignsRipostCommandReverseMap[Command.CMD_UPWARD_TOOL]=Command.CMD_RIPOST_UPWARD_TOOL
	
	
	#COMMANDS TO COUNTER RIPOST
	counterRipostCommandMap[Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE]=Command.CMD_NEUTRAL_MELEE
	counterRipostCommandMap[Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL]=Command.CMD_NEUTRAL_SPECIAL
	counterRipostCommandMap[Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL]=Command.CMD_NEUTRAL_TOOL
	counterRipostCommandMap[Command.CMD_COUNTER_RIPOST_BACKWARD_MELEE]=Command.CMD_BACKWARD_MELEE
	counterRipostCommandMap[Command.CMD_COUNTER_RIPOST_FORWARD_MELEE]=Command.CMD_FORWARD_MELEE
	counterRipostCommandMap[Command.CMD_COUNTER_RIPOST_DOWNWARD_MELEE]=Command.CMD_DOWNWARD_MELEE
	counterRipostCommandMap[Command.CMD_COUNTER_RIPOST_UPWARD_MELEE]=Command.CMD_UPWARD_MELEE
	counterRipostCommandMap[Command.CMD_COUNTER_RIPOST_BACKWARD_SPECIAL]=Command.CMD_BACKWARD_SPECIAL
	counterRipostCommandMap[Command.CMD_COUNTER_RIPOST_FORWARD_SPECIAL]=Command.CMD_FORWARD_SPECIAL
	counterRipostCommandMap[Command.CMD_COUNTER_RIPOST_DOWNWARD_SPECIAL]=Command.CMD_DOWNWARD_SPECIAL
	counterRipostCommandMap[Command.CMD_COUNTER_RIPOST_UPWARD_SPECIAL]=Command.CMD_UPWARD_SPECIAL
	counterRipostCommandMap[Command.CMD_COUNTER_RIPOST_BACKWARD_TOOL]=Command.CMD_BACKWARD_TOOL
	counterRipostCommandMap[Command.CMD_COUNTER_RIPOST_FORWARD_TOOL]=Command.CMD_FORWARD_TOOL
	counterRipostCommandMap[Command.CMD_COUNTER_RIPOST_DOWNWARD_TOOL]=Command.CMD_DOWNWARD_TOOL
	counterRipostCommandMap[Command.CMD_COUNTER_RIPOST_UPWARD_TOOL]=Command.CMD_UPWARD_TOOL
	
	#counter ripost commands in air mapped to neutral counter riposts
	counterRipostAirCommandMap[Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE]=Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE
	counterRipostAirCommandMap[Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL]=Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL
	counterRipostAirCommandMap[Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL]=Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL
	counterRipostAirCommandMap[Command.CMD_COUNTER_RIPOST_BACKWARD_MELEE]=Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE
	counterRipostAirCommandMap[Command.CMD_COUNTER_RIPOST_FORWARD_MELEE]=Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE
	counterRipostAirCommandMap[Command.CMD_COUNTER_RIPOST_DOWNWARD_MELEE]=Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE
	counterRipostAirCommandMap[Command.CMD_COUNTER_RIPOST_UPWARD_MELEE]=Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE
	counterRipostAirCommandMap[Command.CMD_COUNTER_RIPOST_BACKWARD_SPECIAL]=Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL
	counterRipostAirCommandMap[Command.CMD_COUNTER_RIPOST_FORWARD_SPECIAL]=Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL
	counterRipostAirCommandMap[Command.CMD_COUNTER_RIPOST_DOWNWARD_SPECIAL]=Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL
	counterRipostAirCommandMap[Command.CMD_COUNTER_RIPOST_UPWARD_SPECIAL]=Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL
	counterRipostAirCommandMap[Command.CMD_COUNTER_RIPOST_BACKWARD_TOOL]=Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL
	counterRipostAirCommandMap[Command.CMD_COUNTER_RIPOST_FORWARD_TOOL]=Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL
	counterRipostAirCommandMap[Command.CMD_COUNTER_RIPOST_DOWNWARD_TOOL]=Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL
	counterRipostAirCommandMap[Command.CMD_COUNTER_RIPOST_UPWARD_TOOL]=Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL
	
	#rverse lookup
	counterRipostCommandReverseMap[Command.CMD_NEUTRAL_MELEE]=Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE
	counterRipostCommandReverseMap[Command.CMD_NEUTRAL_SPECIAL]=Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL
	counterRipostCommandReverseMap[Command.CMD_NEUTRAL_TOOL]=Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL
	counterRipostCommandReverseMap[Command.CMD_BACKWARD_MELEE]=Command.CMD_COUNTER_RIPOST_BACKWARD_MELEE
	counterRipostCommandReverseMap[Command.CMD_FORWARD_MELEE]=Command.CMD_COUNTER_RIPOST_FORWARD_MELEE
	counterRipostCommandReverseMap[Command.CMD_DOWNWARD_MELEE]=Command.CMD_COUNTER_RIPOST_DOWNWARD_MELEE
	counterRipostCommandReverseMap[Command.CMD_UPWARD_MELEE]=Command.CMD_COUNTER_RIPOST_UPWARD_MELEE
	counterRipostCommandReverseMap[Command.CMD_BACKWARD_SPECIAL]=Command.CMD_COUNTER_RIPOST_BACKWARD_SPECIAL
	counterRipostCommandReverseMap[Command.CMD_FORWARD_SPECIAL]=Command.CMD_COUNTER_RIPOST_FORWARD_SPECIAL
	counterRipostCommandReverseMap[Command.CMD_DOWNWARD_SPECIAL]=Command.CMD_COUNTER_RIPOST_DOWNWARD_SPECIAL
	counterRipostCommandReverseMap[Command.CMD_UPWARD_SPECIAL]=Command.CMD_COUNTER_RIPOST_UPWARD_SPECIAL
	counterRipostCommandReverseMap[Command.CMD_BACKWARD_TOOL]=Command.CMD_COUNTER_RIPOST_BACKWARD_TOOL
	counterRipostCommandReverseMap[Command.CMD_FORWARD_TOOL]=Command.CMD_COUNTER_RIPOST_FORWARD_TOOL
	counterRipostCommandReverseMap[Command.CMD_DOWNWARD_TOOL]=Command.CMD_COUNTER_RIPOST_DOWNWARD_TOOL
	counterRipostCommandReverseMap[Command.CMD_UPWARD_TOOL]=Command.CMD_COUNTER_RIPOST_UPWARD_TOOL
	
	
	ripostToCounterRipostMap[Command.CMD_RIPOST_NEUTRAL_MELEE]=Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE
	ripostToCounterRipostMap[Command.CMD_RIPOST_NEUTRAL_SPECIAL]=Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL
	ripostToCounterRipostMap[Command.CMD_RIPOST_NEUTRAL_TOOL]=Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL
	ripostToCounterRipostMap[Command.CMD_RIPOST_BACKWARD_MELEE]=Command.CMD_COUNTER_RIPOST_BACKWARD_MELEE
	ripostToCounterRipostMap[Command.CMD_RIPOST_FORWARD_MELEE]=Command.CMD_COUNTER_RIPOST_FORWARD_MELEE
	ripostToCounterRipostMap[Command.CMD_RIPOST_DOWNWARD_MELEE]=Command.CMD_COUNTER_RIPOST_DOWNWARD_MELEE
	ripostToCounterRipostMap[Command.CMD_RIPOST_UPWARD_MELEE]=Command.CMD_COUNTER_RIPOST_UPWARD_MELEE
	ripostToCounterRipostMap[Command.CMD_RIPOST_BACKWARD_SPECIAL]=Command.CMD_COUNTER_RIPOST_BACKWARD_SPECIAL
	ripostToCounterRipostMap[Command.CMD_RIPOST_FORWARD_SPECIAL]=Command.CMD_COUNTER_RIPOST_FORWARD_SPECIAL
	ripostToCounterRipostMap[Command.CMD_RIPOST_DOWNWARD_SPECIAL]=Command.CMD_COUNTER_RIPOST_DOWNWARD_SPECIAL
	ripostToCounterRipostMap[Command.CMD_RIPOST_UPWARD_SPECIAL]=Command.CMD_COUNTER_RIPOST_UPWARD_SPECIAL
	ripostToCounterRipostMap[Command.CMD_RIPOST_BACKWARD_TOOL]=Command.CMD_COUNTER_RIPOST_BACKWARD_TOOL
	ripostToCounterRipostMap[Command.CMD_RIPOST_FORWARD_TOOL]=Command.CMD_COUNTER_RIPOST_FORWARD_TOOL
	ripostToCounterRipostMap[Command.CMD_RIPOST_DOWNWARD_TOOL]=Command.CMD_COUNTER_RIPOST_DOWNWARD_TOOL
	ripostToCounterRipostMap[Command.CMD_RIPOST_UPWARD_TOOL]=Command.CMD_COUNTER_RIPOST_UPWARD_TOOL
	
	
	
	
	#commands that are movement only related
	mvmOnlyCmdMap[Command.CMD_JUMP]=true
	mvmOnlyCmdMap[Command.CMD_MOVE_FORWARD]=true
	mvmOnlyCmdMap[Command.CMD_MOVE_BACKWARD]=true
	mvmOnlyCmdMap[Command.CMD_STOP_MOVE_FORWARD]=true
	mvmOnlyCmdMap[Command.CMD_STOP_MOVE_BACKWARD]=true
	mvmOnlyCmdMap[Command.CMD_DASH_FORWARD]=true
	mvmOnlyCmdMap[Command.CMD_DASH_BACKWARD]=true
	mvmOnlyCmdMap[Command.CMD_CROUCH]=true
	mvmOnlyCmdMap[Command.CMD_STOP_CROUCH]=true
	mvmOnlyCmdMap[Command.CMD_JUMP_FORWARD]=true
	mvmOnlyCmdMap[Command.CMD_JUMP_BACKWARD]=true
	mvmOnlyCmdMap[Command.CMD_FORWARD_CROUCH]=true
	mvmOnlyCmdMap[Command.CMD_BACKWARD_CROUCH]=true
	mvmOnlyCmdMap[Command.CMD_DASH_FORWARD_NO_DIRECTIONAL_INPUT]=true
	mvmOnlyCmdMap[Command.CMD_FORWARD_UP]=true
	mvmOnlyCmdMap[Command.CMD_BACKWARD_UP]=true
	mvmOnlyCmdMap[Command.CMD_UP]=true
	mvmOnlyCmdMap[Command.CMD_AIR_DASH_DOWNWARD]=true
	
	
	#map the command enum string values to enums, so with string, can fetch the command enum
	for cmdEnum in Command.keys():
		cmdStringToEnumMap[str(cmdEnum)] = Command[cmdEnum]
		
func setGlobalSpeedMod(mod):
	globalSpeedMod=mod
	adjustBufferSize()
	
#makes the buffer sizes biger/smaller depending 
#on speed of game
func adjustBufferSize():
	
	pass
func init(physProcFlag=true):
	
	#adjustBufferSize()
	

	#filled the input buffer with null inputs
	for i in range(0,bufferSize):
		cmdBuffer.append(null)
	
	populateLookupMaps()
	
	if not Input.is_connected("joy_connection_changed",self,"_on_joy_connection_changed"):
		Input.connect("joy_connection_changed",self,"_on_joy_connection_changed")
	
	
	bufferSize = GLOBALS.INPUT_BUFFER_SIZE
	
	#instance 2 leaky variables to store directional input and buttons
	leakyDI = leakyVariableResource.new()
	leakyBtn = leakyVariableResource.new()
	leakyRipostInput = leakyVariableResource.new()
	leakyCounterRipostInput =leakyVariableResource.new()

	self.add_child(leakyDI)
	self.add_child(leakyBtn)
	self.add_child(leakyRipostInput)
	self.add_child(leakyCounterRipostInput)
	var leakyWindowInFrames =5#if press R1 within 5 frames of pressing an attack and DI in hitstun, counts as ripost
	leakyDI.init(leakyWindowInFrames)
	leakyBtn.init(leakyWindowInFrames)
	leakyWindowInFrames =5#if press R1 within 5 frames of pressing an attack and DI in hitstun, counts as ripost
	leakyRipostInput.init(leakyWindowInFrames)
	leakyWindowInFrames=4#make it 4. we don't want to remove ability to ripost while grabbing
	leakyCounterRipostInput.init(leakyWindowInFrames)
	
	bufferingRipostInputFlag=false
	set_physics_process(physProcFlag)
	movementOnlyCommands = false
#returns the command appropriate depending on given facing and command
#paras: cmd: command used to find appropriate mirrored command
#params: facingRight: fflag that is true when facing right, and false otherwise
func getFacingDependantCommand(cmd, facingRight):
	
	#mirror command map doesn't have target command?
	if not mirroredCommandMap.has(cmd):
		#command is independant from facing
		return cmd
	
	#by default, commands are parsed from buttons assuming facing right
	#so only need to treat case when facing left
	if not facingRight:
		return mirroredCommandMap[cmd]
	else:
		return cmd

#returns true when command is a ripost command and false otherwise
func isRipostCommand(cmd):
	return ripostCommandMap.has(cmd)
	
#returns true when command is a ripost command and false otherwise
func isCounterRipostCommand(cmd):
	return counterRipostCommandMap.has(cmd)

		
#returns the riposted command associated to a ripost command
#that is, for a command that indicates its riposting, the command
#that is attempted to be riposted is returned
#null is returned if the parameter ripostCmd was not
#a ripost command
func getRipostedCommand(ripostCmd):
	#invalid input?
	if not isRipostCommand(ripostCmd):
		return null

	return ripostCommandMap[ripostCmd]

#similar to above getRipostedCommand function, but
#for counter ripost commands
func getCounterRipostedCommand(counterRipostCmd):
	#invalid input?
	if not isCounterRipostCommand(counterRipostCmd):
		return null
	return counterRipostCommandMap[counterRipostCmd]	
	
#targetBtn is a string representing button (will be used as key to access the button maps)
#newBtns is an array of strings, representing the buttons to map to when pressing target button
func remapButton(targetBtn, newBtns):
	
	if (targetBtn == null):
		return
		
	var btnCode =null
	
	#only compute the button bit maps for none empty remapping
	if newBtns != null and newBtns.size() > 0:
		btnCode=0
		#go set all bits of btnCode, for each new button
		for b in newBtns:
			btnCode = btnCode | btnMap[b]
		
	#remap
	pInRemap[targetBtn] = btnCode
	
	
func _physics_process(delta):
	
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	
	
	physics_process_hook(delta)
	
	
func physics_process_hook(delta):


	if inputDeviceId == null:
		set_physics_process(false)
		return
		
	var cmd
	
	#store the bit map of buttons pressed in a buffer (so sub classes can make use of logic)
	#do it this way cause can't return3 variables
	_parseBtnBitMaps()
	
	
	var inputJustPressedBitMap = btnBitMapBuffer[JUST_PRESSED_MAP_IX]
	var inputHoldingBitMap = btnBitMapBuffer[HOLDING_MAP_IX]
	var inputReleasedBitMap = btnBitMapBuffer[RELEASED_MAP_IX]
			
	
	cmd = processInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap)
	
	return


func _parseBtnBitMaps():
	var inputJustPressedBitMap = 0
	var inputHoldingBitMap = 0
	var inputReleasedBitMap = 0
	#var btnKeys = btnMap.keys()
	var btnKeys = pInRemap.keys()
	#iterate all buttons to create bit map
	for k in btnKeys:
		
		#remapping of buttons made it so a button maps to no input?
		if pInRemap[k] == null:
			continue
		#tranlate button id to device button (2 different devices have same button)
		#differentiate devices via inputDevice id. Needd to map this in input seetings
		var inputId = inputDeviceId+"_"+k
		#check if player just pressed it
		if Input.is_action_just_pressed(inputId):
			
			inputJustPressedBitMap = inputJustPressedBitMap | pInRemap[k]
		elif Input.is_action_just_released(inputId):
			
			#C-stick only supports 1 frame button presses (no holding or releasing)
			if cStickBtnKeyMap.has(k):
				continue
				
			inputReleasedBitMap = inputReleasedBitMap | pInRemap[k]
		elif Input.is_action_pressed(inputId):
			
			#C-stick only supports 1 frame button presses (no holding or releasing)
			if cStickBtnKeyMap.has(k):
				continue

			inputHoldingBitMap = inputHoldingBitMap | pInRemap[k]
		
	btnBitMapBuffer[JUST_PRESSED_MAP_IX]=inputJustPressedBitMap
	btnBitMapBuffer[HOLDING_MAP_IX]=inputHoldingBitMap
	btnBitMapBuffer[RELEASED_MAP_IX]=inputReleasedBitMap
	
func handleInputSignaling(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap):
	emit_signal("input_update",inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap)
	
func processInput(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap):
	
	handleInputSignaling(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap)
	
	var cmd=null


	bufferRipostInputs(inputJustPressedBitMap,inputHoldingBitMap)

		
	cmd = parseCommand(inputJustPressedBitMap,inputHoldingBitMap, inputReleasedBitMap)
	lastDI = parseDirectionalInput(inputJustPressedBitMap,inputHoldingBitMap)
	
	
	lastGrabDI = parseGrabDirectionalInput(inputJustPressedBitMap,inputHoldingBitMap, inputReleasedBitMap)
	
	#only accepting movement commands?
	if movementOnlyCommands:
		#not a mvmv command?
		if not isMvmOnlyCmd(cmd):
			
			#ignore it
			cmd = null
		
	
	#add input to history, throwing away oldest frames 
	if inputHistory.size() > doubleTapWindow:
		inputHistory.pop_back()
	inputHistory.push_front(inputJustPressedBitMap)

	
	#inputs in buffer shifted by 1(oldest input lost if buffer full)
	storeCommandInBuffer(null)
	
	lastCommand = cmd	
	
	
	return cmd


func parseGrabDirectionalInput(inputJustPressedBitMap,inputHoldingBitMap, inputReleasedBitMap):
	#by default
	var di=lastGrabDI
	#did we release grab button (negative edge)?
	if((inputReleasedBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER):		
		ignoreGrabDI=false
		#lastGrabDI=lastDI
	#pressing grab button resets the grab DI
	elif((inputJustPressedBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER):
		#avoid input throw DI WHEN pressing button. should be able
		#to hold a direction while attempting to grab
		#and it be considered neutral grab
		ignoreGrabDI = true
		#attempting to grab clears the throw DI
		di=GLOBALS.DirectionalInput.NEUTRAL
		#lastGrabDI=lastDI # so never letting go of grab should be equivalent to di that direction	
	
	#are we looking for grab throw directional input?
	if not ignoreGrabDI:
		
		#grab DI will be parsed. 
		#can only override the trhow direction with a new non-neutral direction
		#so you don't have to hold it. tapping direction is fine
		if lastDI !=GLOBALS.DirectionalInput.NEUTRAL:
			
			#for grab diagonals, make sure the if diagonal chosen 
			#that u can't over ride it with any of it's combo pair.
			# So top right can't be overrided by top or right. 
			#it will prevent releasing top right and not frame 
			#perfectly releasing both. would have to move stick
			# another way and then do forward or top
			
			#special case where need check btn release black lists?
			if grabDIReleaseBlackList.has(lastGrabDI):
				var blacklist = grabDIReleaseBlackList[lastGrabDI]
				#goota make sure the new direction isn't blacklisted by a diagonal direction
				if not blacklist.has(lastDI):
	
					di	=lastDI
					
			else:
				#a typical case where you overide direction
				di	=lastDI
		
	return di

func storeBufferableCommandInBuffer(cmd):
	#ignroe some commands and don't buffer them
	if unbufferableCommands.has(cmd):
		return
	
	storeCommandInBuffer(cmd)

#stores any command into buffer without checking
func storeCommandInBuffer(cmd):
	
	#throw away the exccess old frames (they may have accumulated during hitfreeze) and store in buffer command
	while cmdBuffer.size() > bufferSize and not stopBufferLeakFlag:
	#if cmdBuffer.size() > bufferSize :
		cmdBuffer.pop_back()
		
	cmdBuffer.push_front(cmd)
	

	
func readBufferedCommand():
	var cmd = null
	#in this case, go look in input buffer for last 'bufferSize' frames
	#each element represents a frame that may have an input
	#while (not cmdBuffer.empty()):
	#	cmd = cmdBuffer.pop_back()
		#found command?
	#	if cmd != null:
	#		break;
	
	#iterate from end to fron
	var i = cmdBuffer.size()-1
	while(i >=0):	
		cmd = cmdBuffer[i]
		if cmd != null:
			break
		i -=1
	
	return cmd

#this will erased first non-null command starting from back of input buffer
func eraseBufferedCommand():
	#iterate from end to fron
	var i = cmdBuffer.size()-1
	while(i >=0):	
		if cmdBuffer[i] != null:
			cmdBuffer[i] = null
			break;
		i -=1
		
func readCommand():
	
	
	
	#is the last command inputed a non-bufferable
	if unbufferableCommands.has(lastCommand):
		#buffered commands take priority
		var bufferedCmd = readBufferedCommand()	
		#nothing in buffer?
		if bufferedCmd == null:
			
			return lastCommand
			
		else:
			eraseBufferedCommand()
			return bufferedCmd
	else:#it's bufferable
		return lastCommand
	
#	pass

func readLastCommand():
	return lastCommand
	
func parseCommand(inputJustPressedBitMap, inputHoldingBitMap,inputReleasedBitMap):
	
	var cmd  = parseComplexCommands(inputJustPressedBitMap,inputHoldingBitMap)
	
	if cmd == null:
		cmd = parseSimpleCommand(inputJustPressedBitMap, inputHoldingBitMap,inputReleasedBitMap)
	
	return cmd	

func parseRipostCommand(inputJustPressedBitMap, inputHoldingBitMap, inputReleasedBitMap):
	
	#since autoripost involves holding down R1 and L2, lock out
	#riposting and counterriposting when both R1 and L2 are pressed/held-down
	if(inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER and (((inputJustPressedBitMap & BTN_LEFT_TRIGGER) == BTN_LEFT_TRIGGER)):
		return null
	if(inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER and (((inputHoldingBitMap & BTN_LEFT_TRIGGER) == BTN_LEFT_TRIGGER)):
		return null
	if(inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER and (((inputJustPressedBitMap & BTN_LEFT_TRIGGER) == BTN_LEFT_TRIGGER)):
		return null
	if(inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER and (((inputHoldingBitMap & BTN_LEFT_TRIGGER) == BTN_LEFT_TRIGGER)):
		return null
		
	var bumpersInputFlag = false
	bumpersInputFlag = ((inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER)
	bumpersInputFlag = bumpersInputFlag  or ((inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER)
	bumpersInputFlag = bumpersInputFlag or ((inputHoldingBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER)
	bumpersInputFlag = bumpersInputFlag  or ((inputJustPressedBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER)
	
	if not bumpersInputFlag:
		return null
		
	#iterate all possible buttons pressed
	for btn_id in commandMap.keys():
		#counter ripost input		
		if((inputJustPressedBitMap & btn_id) == btn_id) or ((inputHoldingBitMap & btn_id) == btn_id):
			if((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT) or ((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT):
				#EITHER riposting or counter riposting?				
				if((inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER) or ((inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER):
					
					#counter riposting (both bumpers presssed)?
					if((inputHoldingBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER) or ((inputJustPressedBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER):
						return counterRipostCommandReverseMap[commandMap[btn_id][BTN_LEFT]]										
			elif((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT) or ((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT):
			#EITHER riposting or counter riposting?				
				if((inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER) or ((inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER):
					
					#counter riposting (both bumpers presssed)?
					if((inputHoldingBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER) or ((inputJustPressedBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER):
						return counterRipostCommandReverseMap[commandMap[btn_id][BTN_RIGHT]]									
						
			elif((inputHoldingBitMap & BTN_DOWN) == BTN_DOWN) or ((inputJustPressedBitMap & BTN_DOWN) == BTN_DOWN):
				#EITHER riposting or counter riposting?				
				if((inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER) or ((inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER):
					
					#counter riposting (both bumpers presssed)?
					if((inputHoldingBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER) or ((inputJustPressedBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER):
						return counterRipostCommandReverseMap[commandMap[btn_id][BTN_DOWN]]									
						
			elif((inputHoldingBitMap & BTN_UP) == BTN_UP) or ((inputJustPressedBitMap & BTN_UP) == BTN_UP):
				#EITHER riposting or counter riposting?				
				if((inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER) or ((inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER):
					
					#counter riposting (both bumpers presssed)?
					if((inputHoldingBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER) or ((inputJustPressedBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER):
						return counterRipostCommandReverseMap[commandMap[btn_id][BTN_UP]]					

						
			else:#no horizontale direction (neutral moves)
			
				#EITHER riposting or counter riposting?				
				if((inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER) or ((inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER):
					
					#counter riposting (both bumpers presssed)?
					if((inputHoldingBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER) or ((inputJustPressedBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER):
						return counterRipostCommandReverseMap[commandMap[btn_id][BTN_NO_DIRECTIONAL_INPUT]]										
						
		#HOLDING DOWN RIGHT BUMPER ANND PRESSED THE BUTTON?
		if((inputJustPressedBitMap & btn_id) == btn_id):
			if((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT) or ((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT):
				#EITHER riposting or counter riposting?				
				if((inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER) :
																				
					#does the player have a cutstom setting to make ripost commands require matching the
					#input with respect to opponent facing instead of player's facing (match instead of mirror input)?
					if pInRemap.has(CUSTOM_INPUT_SETTINGS_RIPOST_INPUT_MATCH_FACING_KEY):
						return costumSettignsRipostCommandReverseMap[commandMap[btn_id][BTN_LEFT]]
					else:
						return ripostCommandReverseMap[commandMap[btn_id][BTN_LEFT]]
				
						
			elif((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT) or ((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT):
				#EITHER riposting or counter riposting?				
				if((inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER) :
					
					#does the player have a cutstom setting to make ripost commands require matching the
					#input with respect to opponent facing instead of player's facing (match instead of mirror input)?
					if pInRemap.has(CUSTOM_INPUT_SETTINGS_RIPOST_INPUT_MATCH_FACING_KEY):
						return costumSettignsRipostCommandReverseMap[commandMap[btn_id][BTN_RIGHT]]
					else:
						return ripostCommandReverseMap[commandMap[btn_id][BTN_RIGHT]]
			
			elif((inputHoldingBitMap & BTN_DOWN) == BTN_DOWN) or ((inputJustPressedBitMap & BTN_DOWN) == BTN_DOWN):
				#EITHER riposting or counter riposting?				
				if((inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER) :
							
					#does the player have a cutstom setting to make ripost commands require matching the
					#input with respect to opponent facing instead of player's facing (match instead of mirror input)?
					#SHOULDHN'T affect up/down/neutral ripost, but just for completlness, do it this way
					if pInRemap.has(CUSTOM_INPUT_SETTINGS_RIPOST_INPUT_MATCH_FACING_KEY):
						return costumSettignsRipostCommandReverseMap[commandMap[btn_id][BTN_DOWN]]
					else:
						return ripostCommandReverseMap[commandMap[btn_id][BTN_DOWN]]
								
					
						
			elif((inputHoldingBitMap & BTN_UP) == BTN_UP) or ((inputJustPressedBitMap & BTN_UP) == BTN_UP):
				#EITHER riposting or counter riposting?				
				if((inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER) :
							
										#does the player have a cutstom setting to make ripost commands require matching the
					#input with respect to opponent facing instead of player's facing (match instead of mirror input)?
					#SHOULDHN'T affect up/down/neutral ripost, but just for completlness, do it this way
					if pInRemap.has(CUSTOM_INPUT_SETTINGS_RIPOST_INPUT_MATCH_FACING_KEY):
						return costumSettignsRipostCommandReverseMap[commandMap[btn_id][BTN_UP]]
					else:
						return ripostCommandReverseMap[commandMap[btn_id][BTN_UP]]
			
					
						
			else:#no horizontale direction (neutral moves)
						
				#EITHER riposting or counter riposting?				
				if((inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER) :
						#input with respect to opponent facing instead of player's facing (match instead of mirror input)?
					#SHOULDHN'T affect up/down/neutral ripost, but just for completlness, do it this way
					if pInRemap.has(CUSTOM_INPUT_SETTINGS_RIPOST_INPUT_MATCH_FACING_KEY):
						return costumSettignsRipostCommandReverseMap[commandMap[btn_id][BTN_NO_DIRECTIONAL_INPUT]]
					else:
						return ripostCommandReverseMap[commandMap[btn_id][BTN_NO_DIRECTIONAL_INPUT]]
					
		#PRSSED RIGHT BUMPER ANND HOLDING THE BUTTON? (holding both buttons and rigth bumper doesn't count as ripost input
		if((inputHoldingBitMap & btn_id) == btn_id):
			if((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT) or ((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT):
				#EITHER riposting or counter riposting?				
				if((inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER) :
										
					#does the player have a cutstom setting to make ripost commands require matching the
					#input with respect to opponent facing instead of player's facing (match instead of mirror input)?
					if pInRemap.has(CUSTOM_INPUT_SETTINGS_RIPOST_INPUT_MATCH_FACING_KEY):
						return costumSettignsRipostCommandReverseMap[commandMap[btn_id][BTN_LEFT]]
					else:
						return ripostCommandReverseMap[commandMap[btn_id][BTN_LEFT]]
						
			elif((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT) or ((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT):
				#EITHER riposting or counter riposting?				
				if((inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER) :
										
					#does the player have a cutstom setting to make ripost commands require matching the
					#input with respect to opponent facing instead of player's facing (match instead of mirror input)?
					if pInRemap.has(CUSTOM_INPUT_SETTINGS_RIPOST_INPUT_MATCH_FACING_KEY):
						return costumSettignsRipostCommandReverseMap[commandMap[btn_id][BTN_RIGHT]]
					else:
						return ripostCommandReverseMap[commandMap[btn_id][BTN_RIGHT]]
						
			elif((inputHoldingBitMap & BTN_DOWN) == BTN_DOWN) or ((inputJustPressedBitMap & BTN_DOWN) == BTN_DOWN):
				#EITHER riposting or counter riposting?				
				if((inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER) :
										
					#does the player have a cutstom setting to make ripost commands require matching the
					#input with respect to opponent facing instead of player's facing (match instead of mirror input)?
					#SHOULDHN'T affect up/down/neutral ripost, but just for completlness, do it this way
					if pInRemap.has(CUSTOM_INPUT_SETTINGS_RIPOST_INPUT_MATCH_FACING_KEY):
						return costumSettignsRipostCommandReverseMap[commandMap[btn_id][BTN_DOWN]]
					else:
						return ripostCommandReverseMap[commandMap[btn_id][BTN_DOWN]]
						
			elif((inputHoldingBitMap & BTN_UP) == BTN_UP) or ((inputJustPressedBitMap & BTN_UP) == BTN_UP):
				#EITHER riposting or counter riposting?				
				if((inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER) :
										
										#does the player have a cutstom setting to make ripost commands require matching the
					#input with respect to opponent facing instead of player's facing (match instead of mirror input)?
					#SHOULDHN'T affect up/down/neutral ripost, but just for completlness, do it this way
					if pInRemap.has(CUSTOM_INPUT_SETTINGS_RIPOST_INPUT_MATCH_FACING_KEY):
						return costumSettignsRipostCommandReverseMap[commandMap[btn_id][BTN_UP]]
					else:
						return ripostCommandReverseMap[commandMap[btn_id][BTN_UP]]
						
			else:#no horizontale direction (neutral moves)
						
				#EITHER riposting or counter riposting?				
				if((inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER) :
										
					#input with respect to opponent facing instead of player's facing (match instead of mirror input)?
					#SHOULDHN'T affect up/down/neutral ripost, but just for completlness, do it this way
					if pInRemap.has(CUSTOM_INPUT_SETTINGS_RIPOST_INPUT_MATCH_FACING_KEY):
						return costumSettignsRipostCommandReverseMap[commandMap[btn_id][BTN_NO_DIRECTIONAL_INPUT]]
					else:
						return ripostCommandReverseMap[commandMap[btn_id][BTN_NO_DIRECTIONAL_INPUT]]
	#no ripost or counter ripost
	return null
	
func parseAttackCommand(inputJustPressedBitMap, inputHoldingBitMap, inputReleasedBitMap):

		
	#iterate all possible buttons pressed
	for btn_id in commandMap.keys():
		if((inputJustPressedBitMap & btn_id) == btn_id):
			if((inputHoldingBitMap & BTN_DOWN) == BTN_DOWN) or ((inputJustPressedBitMap & BTN_DOWN) == BTN_DOWN):
				return commandMap[btn_id][BTN_DOWN]
			#elif((inputHoldingBitMap & BTN_DOWN) == BTN_DOWN) or ((inputJustPressedBitMap & BTN_DOWN) == BTN_DOWN):
#				return commandMap[btn_id][BTN_DOWN]
			elif((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT) or ((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT):
				return commandMap[btn_id][BTN_LEFT]
			elif((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT) or ((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT):
				return commandMap[btn_id][BTN_RIGHT]			
			elif((inputHoldingBitMap & BTN_UP) == BTN_UP) or ((inputJustPressedBitMap & BTN_UP) == BTN_UP):
				return commandMap[btn_id][BTN_UP]
			else:
				return commandMap[btn_id][BTN_NO_DIRECTIONAL_INPUT]
	
	return null
func parseSimpleCommand(inputJustPressedBitMap, inputHoldingBitMap, inputReleasedBitMap):
		
	
	#if((inputReleasedBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER):
	#	return Command.CMD_RELEASED_GRAB
		
	#have cancel in front so it trumps anything your pressing
	#that way you can buffer it in first
	if((inputJustPressedBitMap & BTN_LEFT_TRIGGER) == BTN_LEFT_TRIGGER):
		if(inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER:
			resetRipostInputBuffer()
			return Command.CMD_AUTO_RIPOST
		elif(inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER:
			resetRipostInputBuffer()
			return Command.CMD_AUTO_RIPOST
		else:
			
			
			#AUTO RIPOST has priority over pushblock as command 
			var pushBlockCmd = parsePushBlockCommands(inputJustPressedBitMap,inputHoldingBitMap)
			
			
			if pushBlockCmd != null:
				
				#a push block command was issued
				return pushBlockCmd
			else:
				
				#not a push block, so any input + left trigger that isn't autripost or pushblock must be ability cancel
				return Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE
		
	if((inputHoldingBitMap & BTN_LEFT_TRIGGER) == BTN_LEFT_TRIGGER):
		if(inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER:
			resetRipostInputBuffer()
			return Command.CMD_AUTO_RIPOST
		#dont consider hodling ripost, since accidently holding input may make u auto ripost twice,
		#which would cost bar twice	
	# AUTO - RIPOST (OLD block / autoparry block)
	
	#if(inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER and (((inputJustPressedBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER)):
	#	resetRipostInputBuffer()
	#	return Command.CMD_AUTO_RIPOST
	#if(inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER and (((inputHoldingBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER)):
	#	resetRipostInputBuffer()
	#	return Command.CMD_AUTO_RIPOST
	#if(inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER and (((inputJustPressedBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER)):
	#	resetRipostInputBuffer()
	#	return Command.CMD_AUTO_RIPOST
	
		

	
	###########################################################
	###########        JUMPING COMMANDS  #################
	###########################################################
	#holzing direction?
	#if(((inputJustPressedBitMap & BTN_UP) == BTN_UP) and ((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT)):
	#	return Command.CMD_JUMP_FORWARD
	#if(((inputJustPressedBitMap & BTN_UP) == BTN_UP) and ((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT)):
#		return Command.CMD_JUMP_BACKWARD
	if(((inputJustPressedBitMap & BTN_A) == BTN_A) and ((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT)):
		return Command.CMD_JUMP_FORWARD
	if(((inputJustPressedBitMap & BTN_A) == BTN_A) and ((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT)):
		return Command.CMD_JUMP_BACKWARD
	
	#just pressed?
	if(((inputJustPressedBitMap & BTN_A) == BTN_A)):
		return Command.CMD_JUMP
	if(((inputJustPressedBitMap & BTN_A) == BTN_A) and ((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT)):
		return Command.CMD_JUMP_FORWARD
	if(((inputJustPressedBitMap & BTN_A) == BTN_A) and ((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT)):
		return Command.CMD_JUMP_BACKWARD
	#if(((inputJustPressedBitMap & BTN_UP) == BTN_UP) and ((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT)):
#		return Command.CMD_JUMP_FORWARD
	#if(((inputJustPressedBitMap & BTN_UP) == BTN_UP) and ((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT)):
	#	return Command.CMD_JUMP_BACKWARD
	###########################################################
	###########         JUST PRESSED COMMANDS  #################
	###########################################################
	
	if(((inputJustPressedBitMap & BTN_START) == BTN_START)):
		return Command.CMD_START
	
	
	
	#only grab if not trying to counter ripost (both bumpers pressed)
	if not ((inputJustPressedBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER):
		if not ((inputHoldingBitMap & BTN_RIGHT_BUMPER) == BTN_RIGHT_BUMPER):
			if((inputJustPressedBitMap & BTN_LEFT_BUMPER) == BTN_LEFT_BUMPER):
				return Command.CMD_GRAB
			
	#UP release +forward grab.
	#if((inputReleasedBitMap & BTN_UP) == BTN_UP) and ((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT):
	#	return Command.CMD_GRAB
	#if((inputReleasedBitMap & BTN_UP) == BTN_UP) and ((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT):
	#	return Command.CMD_GRAB
	
	#command used to enable left-right facing (forward facing only for grabs)
	
	#UP release +backward (no grab if facing left, grab if facing right).
	#if((inputReleasedBitMap & BTN_UP) == BTN_UP) and ((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT):
	#	return Command.CMD_BACKWARD_UP_RELEASE
	#if((inputReleasedBitMap & BTN_UP) == BTN_UP) and ((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT):
	#	return Command.CMD_BACKWARD_UP_RELEASE
		
		
	if(inputJustPressedBitMap & BTN_RIGHT_TRIGGER) == BTN_RIGHT_TRIGGER and (inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT:
		return Command.CMD_DASH_BACKWARD
	if(inputJustPressedBitMap & BTN_RIGHT_TRIGGER) == BTN_RIGHT_TRIGGER and (inputHoldingBitMap & BTN_LEFT) == BTN_LEFT:
		return Command.CMD_DASH_BACKWARD
	
	if(inputJustPressedBitMap & BTN_RIGHT_TRIGGER) == BTN_RIGHT_TRIGGER and (inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT:
		return Command.CMD_DASH_FORWARD
	if(inputJustPressedBitMap & BTN_RIGHT_TRIGGER) == BTN_RIGHT_TRIGGER and (inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT:
		return Command.CMD_DASH_FORWARD
		
	if(inputJustPressedBitMap & BTN_RIGHT_TRIGGER) == BTN_RIGHT_TRIGGER and (inputJustPressedBitMap & BTN_DOWN) == BTN_DOWN:
		return Command.CMD_AIR_DASH_DOWNWARD
	if(inputJustPressedBitMap & BTN_RIGHT_TRIGGER) == BTN_RIGHT_TRIGGER and (inputHoldingBitMap & BTN_DOWN) == BTN_DOWN:
		return Command.CMD_AIR_DASH_DOWNWARD
		
				
	if(inputJustPressedBitMap & BTN_RIGHT_TRIGGER) == BTN_RIGHT_TRIGGER:
		return Command.CMD_DASH_FORWARD_NO_DIRECTIONAL_INPUT#this is required to be able to dash forward when facing left
		
	###########################################################
	###########         RIPOSTING + COUNTERING  #################
	###########################################################
		
	var ripostCmd = parseRipostCommand(inputJustPressedBitMap, inputHoldingBitMap, inputReleasedBitMap)
	
	#maybe player failed to input ripsot properly, so check if in short history, input suggests ripost command
	if ripostCmd == null:
		
		ripostCmd = searchForRecentRipostInput()
	
	#ripost/counter inputed?
	if ripostCmd !=null:
		resetRipostInputBuffer()
		
		#ripost?
		if isRipostCommand(ripostCmd):
			
			#did we just input the left bumper for counter ripost?
			if leakyCounterRipostInput.value != null:
				
				#conver the ripost command to counter ripost, since cleary player tried to
				#counter ripost,since they inpput grab within last couple frames
				ripostCmd = ripostToCounterRipostMap[ripostCmd]
		return ripostCmd

	#########################end ripost counter + ripost
	
	
	
	var attackCmd = parseAttackCommand(inputJustPressedBitMap, inputHoldingBitMap, inputReleasedBitMap)
	#there is an attack command?
	if attackCmd != null:
		return attackCmd
	
		
	#if((inputJustPressedBitMap & BTN_Y) == BTN_Y):
	#	if((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT):
	#		return Command.CMD_BACKWARD_SPECIAL
	#	elif((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT):
	#		return Command.CMD_FORWARD_SPECIAL
	
	#if((inputJustPressedBitMap & BTN_X) == BTN_X):
	#	if((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT):
	#		return Command.CMD_BACKWARD_MELEE
	#	elif((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT):
	#		return Command.CMD_FORWARD_MELEE
	#	elif((inputHoldingBitMap & BTN_DOWN) == BTN_DOWN):
	#		return Command.CMD_DOWNWARD_MELEE	
		
	#if(inputJustPressedBitMap & BTN_X) == BTN_X:
	#	return Command.CMD_NEUTRAL_MELEE
	#if(inputJustPressedBitMap & BTN_Y) == BTN_Y:
	#	return Command.CMD_NEUTRAL_SPECIAL
	#if(inputJustPressedBitMap & BTN_B) == BTN_B:
	#	return Command.CMD_NEUTRAL_TOOL	
						
	 
	#C-STICK COMMANDS (1 frame special multi-button-press) commands
	#if(inputJustPressedBitMap & BTN_C_STICK_RIGHT) == BTN_C_STICK_RIGHT:
		#return Command.CMD_DASH_FORWARD
	#if(inputJustPressedBitMap & BTN_C_STICK_LEFT) == BTN_C_STICK_LEFT:
		#return Command.CMD_DASH_BACKWARD
	#if(inputJustPressedBitMap & BTN_C_STICK_DOWN) == BTN_C_STICK_DOWN:
		#return Command.CMD_AIR_DASH_DOWNWARD
	#if(inputJustPressedBitMap & BTN_C_STICK_UP) == BTN_C_STICK_UP:		
	#	return Command.CMD_AUTO_RIPOST
		
	#bottom diagnal left held?
	if((inputJustPressedBitMap & BTN_DOWN) == BTN_DOWN) and ((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT):
		return Command.CMD_BACKWARD_CROUCH
		#bottom diagnal left held?
	if((inputHoldingBitMap & BTN_DOWN) == BTN_DOWN) and ((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT):
		return Command.CMD_BACKWARD_CROUCH
	if((inputJustPressedBitMap & BTN_DOWN) == BTN_DOWN) and ((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT):
		return Command.CMD_BACKWARD_CROUCH
	if((inputHoldingBitMap & BTN_DOWN) == BTN_DOWN) and ((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT):
		return Command.CMD_BACKWARD_CROUCH
	
	#bottom diagnal RIGHT held?
	if((inputJustPressedBitMap & BTN_DOWN) == BTN_DOWN) and ((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT):
		return Command.CMD_FORWARD_CROUCH
		#bottom diagnal left held?
	if((inputHoldingBitMap & BTN_DOWN) == BTN_DOWN) and ((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT):
		return Command.CMD_FORWARD_CROUCH
	if((inputJustPressedBitMap & BTN_DOWN) == BTN_DOWN) and ((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT):
		return Command.CMD_FORWARD_CROUCH
	if((inputHoldingBitMap & BTN_DOWN) == BTN_DOWN) and ((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT):
		return Command.CMD_FORWARD_CROUCH
	
		
	#just pressed directional movement commands
	if(inputJustPressedBitMap & BTN_DOWN) == BTN_DOWN:
		return Command.CMD_CROUCH
	if(inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT:
		return Command.CMD_MOVE_FORWARD
	if(inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT:
		return Command.CMD_MOVE_BACKWARD
	
	#TOP RIGHT diagnals held?
	if((inputJustPressedBitMap & BTN_UP) == BTN_UP) and ((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT):
		return Command.CMD_FORWARD_UP
		#bottom diagnal left held?
	if((inputHoldingBitMap & BTN_UP) == BTN_UP) and ((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT):
		return Command.CMD_FORWARD_UP
	if((inputJustPressedBitMap & BTN_UP) == BTN_UP) and ((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT):
		return Command.CMD_FORWARD_UP
	if((inputHoldingBitMap & BTN_UP) == BTN_UP) and ((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT):
		return Command.CMD_FORWARD_UP
	
	
	#top diagnal left held?
	if((inputJustPressedBitMap & BTN_UP) == BTN_UP) and ((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT):
		return Command.CMD_BACKWARD_UP
		#bottom diagnal left held?
	if((inputHoldingBitMap & BTN_UP) == BTN_UP) and ((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT):
		return Command.CMD_BACKWARD_UP
	if((inputJustPressedBitMap & BTN_UP) == BTN_UP) and ((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT):
		return Command.CMD_BACKWARD_UP
	if((inputHoldingBitMap & BTN_UP) == BTN_UP) and ((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT):
		return Command.CMD_BACKWARD_UP
	
	
	
	
	###########################################################
	###########         HOLDING BUTTONS     ###################
	###########################################################
	
	
		
	if(inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT:
		return Command.CMD_MOVE_FORWARD
	if(inputHoldingBitMap & BTN_LEFT) == BTN_LEFT:
		return Command.CMD_MOVE_BACKWARD
	if(inputHoldingBitMap & BTN_DOWN) == BTN_DOWN:
		return Command.CMD_CROUCH
		

		
	###########################################################
	###########         RELEASED BUTTONS  #####################
	###########################################################
	
	#don't miss any button release signals
	#now check for releasing commands
	if(inputReleasedBitMap & BTN_RIGHT) == BTN_RIGHT:
		return Command.CMD_STOP_MOVE_FORWARD
	if(inputReleasedBitMap & BTN_LEFT) == BTN_LEFT:
		return Command.CMD_STOP_MOVE_BACKWARD
	if(inputReleasedBitMap & BTN_DOWN) == BTN_DOWN:
		return Command.CMD_STOP_CROUCH

	#oNLY used for grab DI
	if (inputJustPressedBitMap & BTN_UP) == BTN_UP:
		return Command.CMD_UP
	if (inputHoldingBitMap & BTN_UP) == BTN_UP:
		return Command.CMD_UP
			
	return null	
	
func parsePushBlockCommands(inputJustPressedBitMap,inputHoldingBitMap):
	
		
	#not pressing the left trigger for pushblock? no command of pushblock exists without left trigger
	if not (inputJustPressedBitMap & BTN_LEFT_TRIGGER):
		return null
	
	#abilityCancelInputCmdMap[Command.CMD_CROUCH_PUSH_BLOCK]=null
#	abilityCancelInputCmdMap[Command.CMD_UP_PUSH_BLOCK]=null

	#up held/pressed?
	if((inputHoldingBitMap & BTN_UP) == BTN_UP) or ((inputJustPressedBitMap & BTN_UP) == BTN_UP):
		#right held/pressed
		if ((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT) or ((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT):
			return Command.CMD_FORWARD_UP_PUSH_BLOCK
		#left
		elif ((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT) or ((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT):
			return Command.CMD_BACKWARD_UP_PUSH_BLOCK		
		else: #up neutral
			return Command.CMD_UP_PUSH_BLOCK
			
	#DOWN held/pressed?
	elif((inputHoldingBitMap & BTN_DOWN) == BTN_DOWN) or ((inputJustPressedBitMap & BTN_DOWN) == BTN_DOWN):
		#right held/pressed?
		if ((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT) or ((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT):			
			return Command.CMD_FORWARD_CROUCH_PUSH_BLOCK
		#left held/pressed
		elif ((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT) or ((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT):
			return Command.CMD_BACKWARD_CROUCH_PUSH_BLOCK
		else: #simply holding up
			return Command.CMD_CROUCH_PUSH_BLOCK
	else:#holding right or left
		#right held/pressed?
		if ((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT) or ((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT):			
			return Command.CMD_FORWARD_PUSH_BLOCK
		#left held/pressed
		elif ((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT) or ((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT):
			return Command.CMD_BACKWARD_PUSH_BLOCK
				
	return null #neutral push block just treated as ability cancel cmd
		
func parseComplexCommands(inputJustPressedBitMap,inputHoldingBitMap):
	#parse the commands
	#check for complex commands
	#iterate the input history to search for double taps (complex commands)
	for oldinputJustPressedBitMap in inputHistory:
			
		
				#check if previously pressed up
		if(oldinputJustPressedBitMap & BTN_UP) == BTN_UP:
			#check if pressed right this frame nd input manager supports double tap  UP TO jump
			if(inputJustPressedBitMap & BTN_UP) == BTN_UP and pInRemap.has(CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_UP_KEY):
				
				#WE DOULBE - tapped up. jump
				
				if(((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT) or ((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT) or ((oldinputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT)):
					return Command.CMD_JUMP_FORWARD
				if(((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT) or ((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT) or ((oldinputJustPressedBitMap & BTN_LEFT) == BTN_LEFT)):					
					return Command.CMD_JUMP_BACKWARD
				
				return Command.CMD_JUMP
				
				
		
			
		#HAVE This in place so jumping back/forward doesn't eat dash forward/back input
	#	if(oldinputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT and (((inputJustPressedBitMap & BTN_RIGHT_TRIGGER) == BTN_RIGHT_TRIGGER)):
	#		if(((inputJustPressedBitMap & BTN_A) == BTN_A)):
	#			return Command.CMD_DASH_FORWARD

	#	if(oldinputJustPressedBitMap & BTN_LEFT) == BTN_LEFT and (((inputJustPressedBitMap & BTN_RIGHT_TRIGGER) == BTN_RIGHT_TRIGGER)):
	#		if(((inputJustPressedBitMap & BTN_A) == BTN_A)):
	#			return Command.CMD_DASH_BACKWARD

		#check if previously pressed right
		if(oldinputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT:
			#check if pressed right this frame and input manager supports double tap dash forward
			if(inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT and pInRemap.has(CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_RIGHT_KEY):

				return Command.CMD_DASH_FORWARD
		#	if(((inputJustPressedBitMap & BTN_A) == BTN_A) or ((inputJustPressedBitMap & BTN_UP) == BTN_UP)):
			if(((inputJustPressedBitMap & BTN_A) == BTN_A)):
				return Command.CMD_JUMP_FORWARD
		#check if previously pressed right
		if(oldinputJustPressedBitMap & BTN_LEFT) == BTN_LEFT:
			#check if pressed left this frame and input manager supports double tap dash BACK
			if(inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT and pInRemap.has(CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_LEFT_KEY):
				return Command.CMD_DASH_BACKWARD
			#if(((inputJustPressedBitMap & BTN_A) == BTN_A) or ((inputJustPressedBitMap & BTN_UP) == BTN_UP)):
			if(((inputJustPressedBitMap & BTN_A) == BTN_A)):
				return Command.CMD_JUMP_BACKWARD
				

		#check if previously pressed down
		if(oldinputJustPressedBitMap & BTN_DOWN) == BTN_DOWN:
			#check if pressed right this frame nd input manager supports double tap dash BACK
			if(inputJustPressedBitMap & BTN_DOWN) == BTN_DOWN and pInRemap.has(CUSTOM_INPUT_SETTINGS_DOUBLE_TAP_DOWN_KEY):
				
				return Command.CMD_AIR_DASH_DOWNWARD
				
	

	return null
	
	
func changeBufferSize(newSize):
	
	bufferSize = newSize
	#resetBufferFlag = false
	
func resetBufferSize():
	#bufferSize=defaultBufferSize
	bufferSize = GLOBALS.INPUT_BUFFER_SIZE


#called when device periferale (controller) connects and disconnects
func _on_joy_connection_changed(deviceId, isConnected):
	#in this function we make some checks to avoid double handling the signal (for some reaosn the function
	#is called many times when controller dc/cnx)
	
	#not such device?
	if inputDeviceId == null or not GLOBALS.PLAYER_INPUT_RAW_DEVICE_ID_MAP.has(inputDeviceId):
		#we may be in training mod where the device id isn't set
	#	print("info: controller connected but input manager not ready to handle it (inputDeviceId null)")
		pass
		return 
	var thisInputManageDeviceId = GLOBALS.PLAYER_INPUT_RAW_DEVICE_ID_MAP[inputDeviceId]
	
	#input manager not responsible for this device?
	if deviceId != thisInputManageDeviceId:
		return
		
	if not controllerConnected and isConnected:
		print("Controller ("+str(inputDeviceId)+") connected")
		
		#if Input.is_joy_known(deviceId):
		#	print("Recongnized controller")
		#	print(Input.get_joy_name(deviceId) + " (Player "+str(GLOBALS.PLAYER_INPUT_RAW_DEVICE_ID_REVERSE_MAP[deviceId])+") device found")
		controllerConnected =isConnected
		emit_signal("controller_connected",inputDeviceId)
	elif controllerConnected and not isConnected:
		print("Controller Disconnected")
		controllerConnected =isConnected	
		
		emit_signal("controller_disconnected",inputDeviceId)
	else:
		
		#reapeating the controller connection changes, ignore
		pass
	
	
func _on_hit_freeze_started():
	#don't want to drop commands during hitfreeze
	stopBufferLeakFlag = true
	
func _on_hit_freeze_stopped():
	#can now drop commmands again
	stopBufferLeakFlag = false
	
static func isJumpCommand(cmd):
	return cmd == Command.CMD_JUMP or cmd ==  Command.CMD_JUMP_FORWARD or cmd ==  Command.CMD_JUMP_BACKWARD
	
	
	
#called everytime a button is pressed and saves any directional input or
#attack butoon temporarily
#func bufferRipostInputs(btn,holdingButtonFlag):
func bufferRipostInputs(inputJustPressedBitMap,inputHoldingBitMap):
	
	
		
	#BUFFER the counter ripost input (grab)
	if (inputJustPressedBitMap & BTN_LEFT_BUMPER)==BTN_LEFT_BUMPER:
		leakyCounterRipostInput.value=BTN_LEFT_BUMPER
		
		
	#need to lock ripost buffering since
	#auto-ripost riquires right-bumper + A to input,
	#and if pressed an attack button (X,Y,B within buffer window),
	#it'll count it as a ripost. As auto-ripost doesn't work in hitstun
	#it makes sense to not bufer ripost inputs when not in hit stun
	#and only buffer it in hitstun
	if bufferingRipostInputFlag:
		#melee, special or tool input button
#		if not holdingButtonFlag and (btn == BTN_B or btn == BTN_Y or btn == BTN_X):

		#althought there is prioirty here (if hold two buttons down), players
		#shoudl never need to hold to aattack buttons down while riposting, so it should be 
		#fine like this
		if ((inputJustPressedBitMap & BTN_B) == BTN_B): 
			leakyBtn.value = BTN_B
		elif ((inputJustPressedBitMap & BTN_Y) == BTN_Y):
			leakyBtn.value = BTN_Y
		elif ((inputJustPressedBitMap & BTN_X) == BTN_X):
			leakyBtn.value = BTN_X
			
			
#		elif holdingButtonFlag and (btn == BTN_LEFT or btn == BTN_UP or btn == BTN_DOWN or btn == BTN_RIGHT):
		if ((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT): 
			leakyDI.value = BTN_LEFT
		elif ((inputHoldingBitMap & BTN_UP) == BTN_UP):
			leakyDI.value = BTN_UP
		elif ((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT):
			leakyDI.value = BTN_RIGHT
		elif ((inputHoldingBitMap & BTN_DOWN) == BTN_DOWN):
			leakyDI.value = BTN_DOWN	
			
#		elif not holdingButtonFlag and (btn == BTN_RIGHT_BUMPER):
		if (inputJustPressedBitMap & BTN_RIGHT_BUMPER)==BTN_RIGHT_BUMPER:
			leakyRipostInput.value=BTN_RIGHT_BUMPER			

func searchForRecentRipostInput():
	
	var ripostCmd = null
	#we recently pressed ripost?
	if leakyRipostInput.value != null:
		ripostCmd = mapRipostInputsToCommand(leakyBtn.value,leakyDI.value)	
		
	return ripostCmd
		
			
func mapRipostInputsToCommand(btn,di):

	
	#when previous buttons pressed right before ripost input,
	#consider it a command of ripost
	if btn != null:
		
		#we will add the button and di input to input map
		var _inputJustPressedBitMap= btn
		var _inputHoldingBitMap= BTN_RIGHT_BUMPER
		var _inputReleasedBitMap=0#unused
		
		var ripostCmd = null
		if di !=null:
			#directional input processed as well for ripost		
			#_inputJustPressedBitMap = _inputJustPressedBitMap | di
			_inputHoldingBitMap = _inputHoldingBitMap | di
			#_inputHoldingBitMap = _inputHoldingBitMap | di
			
		else:
			#no directional input ripost
			pass
		
		return  parseRipostCommand(_inputJustPressedBitMap, _inputHoldingBitMap, _inputReleasedBitMap)
		
		
	
	else:
		
		return null

func resetRipostInputBuffer():
	if leakyBtn != null:
		leakyBtn.resetValue()
	if leakyDI != null:
		leakyDI.resetValue()
	if leakyRipostInput!= null:
		leakyRipostInput.resetValue()	
	if leakyCounterRipostInput != null:
		leakyCounterRipostInput.resetValue()

func enabledMovementOnlyCommands():
	
	setMvmOnlyCommands(true)
	#movementOnlyCommands = true
	
func disableMovementOnlyCommands():
	setMvmOnlyCommands(false)
	#movementOnlyCommands = false
	
func isMvmOnlyCmd(cmd):
	if cmd == null:
		return true #true for sake of not doing anything is a movement option
	return mvmOnlyCmdMap.has(cmd)

#returns true if back is held/pressed in the given command
func isHoldBackCommand(cmd):
	if cmd == null:
		return false
	
	return holdingBackCmdMap.has(cmd)

#returns true if down is held/pressed in the given command
func isHoldDownCommand(cmd):
	if cmd == null:
		return false
	
	return holdingDownCmdMap.has(cmd)


#returns true if forward is held/pressed in the given command
func isHoldForwardCommand(cmd):
	if cmd == null:
		return false
		
	
	#mirror the command to look in backholding map (if the mirror isn't a backward command, then it's not a forward command)
	if not mirroredCommandMap.has(cmd):
		return false
	var backMirror = mirroredCommandMap[cmd]
	
	return isHoldBackCommand(backMirror)
	
#returns true if the given command involves pressing L2/left-trigger (ability cancel)
func isAbilityCancelInput_basedCommand(cmd):
	if cmd == null:
		return false
	
	return abilityCancelInputCmdMap.has(cmd)



	
	
#get last DI input from a grab release
func getLastGrabDirectinalInput(facingRight):
	return _getLastDirectinalInput(lastGrabDI,facingRight)
	
#get last DI input
func getLastDirectinalInput(facingRight):
	return _getLastDirectinalInput(lastDI, facingRight)
	
func _getLastDirectinalInput(_lastDI,facingRight):
	
	if facingRight:
		return _lastDI
	else:
		
		#convert the direction to mirrored as facing left
		return mirrorDIMap[_lastDI]
		
		
#given the input bit maps, returns the directional input enum assuming player is facing right
func parseDirectionalInput(inputJustPressedBitMap, inputHoldingBitMap):
	
	var pressingLeft = false
	var pressingRight = false
	var pressingDown = false
	var pressingUp = false
	pressingLeft = ((inputJustPressedBitMap & BTN_LEFT) == BTN_LEFT) or ((inputHoldingBitMap & BTN_LEFT) == BTN_LEFT)
	pressingRight = ((inputJustPressedBitMap & BTN_RIGHT) == BTN_RIGHT) or ((inputHoldingBitMap & BTN_RIGHT) == BTN_RIGHT)
	pressingUp = ((inputJustPressedBitMap & BTN_UP) == BTN_UP) or ((inputHoldingBitMap & BTN_UP) == BTN_UP)
	pressingDown = ((inputJustPressedBitMap & BTN_DOWN) == BTN_DOWN) or ((inputHoldingBitMap & BTN_DOWN) == BTN_DOWN)

	return GLOBALS.parseDirectionalInput(pressingLeft,pressingRight,pressingDown,pressingUp)
		
		
#converts a command to direction input enum
#necessary for AI and training bot
#func cmdToDI(_cmd):
	
#	if _cmd == null:
#		return GLOBALS.DirectionalInput.NEUTRAL
#	if not cmdDIMap.has(_cmd):
#		return GLOBALS.DirectionalInput.NEUTRAL
	
#	return cmdDIMap[_cmd]
	
	
#converts a counter ripost command to it's base form, 
#and simply returns the command when it isn't a counter ripost command
func counterRipostCmdToBaseCmd(_cmd):
	if isCounterRipostCommand(_cmd):
		return getCounterRipostedCommand(_cmd)
	else:
		return _cmd
	
func reset():
	resetRipostInputBuffer()
	resetBufferFlag = false
	resetBufferSize()
	stopBufferLeakFlag=false
	bufferingRipostInputFlag =false
	inputHistory.clear()
	cmdBuffer.clear()
	cmdBuffer=[]

 	#filled the input buffer with null inputs
	for i in range(0,bufferSize):
		cmdBuffer.append(null)
	
	inputHistory=[]
	lastCommand = null
	lastDI= GLOBALS.DirectionalInput.NEUTRAL
	lastGrabDI=GLOBALS.DirectionalInput.NEUTRAL
	ignoreGrabDI = true
	
	
func addCustomButtonScheme(newBtnMap):
	if newBtnMap == null:
		return
	#we update the buton remaps given the map
	for k in newBtnMap.keys():
		pInRemap[k] = newBtnMap[k]
	