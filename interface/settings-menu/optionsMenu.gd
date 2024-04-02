extends Control

signal back
signal replay_launch_request

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const ONE_SECOND = 1


var GLOBALS = preload("res://Globals.gd")

var settingsMenu = null
var statsMenu = null
var replayMenu = null
var focusedItem = null

var inputDevices = []
var holdingBTime = {}


func _ready():
	
	inputDevices.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDevices.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	
	holdingBTime[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = 0
	holdingBTime[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = 0
	
	set_process(true)
	
func init(_settings,_stats,_replayHandler):
	
	settingsMenu = $VBoxContainer/TabContainer/Settings
	statsMenu = $VBoxContainer/TabContainer/Stats
	replayMenu = $VBoxContainer/TabContainer/Replays
	
	replayMenu.connect("replay_launch_request",self,"_on_replay_launch_request")
	
	settingsMenu.init(_settings)
	statsMenu.init(_stats)
	replayMenu.init(_replayHandler)
	
	self.connect("back",settingsMenu,"_on_back")
	self.connect("back",statsMenu,"_on_back")
	
	#self.connect("back",statsMenu,"_on_back")
#called when text entered into settings item
#func _on_text_changed_in_setting_item(new_text,settingsItem):
#	_on_focus_in_setting_item(settingsItem)
	
func _process(delta):

	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.

	#iterate both players
	#for player in 	inputManagers.keys():
	for player in inputDevices:
		
		
		#players may be holding b to go back
		if Input.is_action_pressed(player+"_B"):
			
			#count how long holding B
			holdingBTime[player] += delta
			
			if holdingBTime[player] > ONE_SECOND:
				
				#save any changes to the settings
				#if settings != null:
				#	settings.saveSettings()
				emit_signal("back")
				
		elif Input.is_action_just_released(player+"_B"):
			#reset the holding b timer, were done trying to go back
			holdingBTime[player] =0
		
		
func _on_replay_launch_request(replayId):
	emit_signal("replay_launch_request",replayId)
	