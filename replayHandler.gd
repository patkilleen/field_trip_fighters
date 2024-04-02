extends Node

const GLOBALS = preload("res://Globals.gd")

signal restart_replay
enum State {
	IDLE,
	RECORDING
}

const RECORDING_BUFFER_LENTH = 2
const INTERNAL_RECORDING_BUFFER_LIST_LENTH = 11

#OUTER LIST INDICES
const PLAYERS_IX=0
const STAGE_NODE_PATH_IX=1
#const SETTINGS_IX = 2

#INNER LIST INDICES
const PLAYER1_IX=0
const PLAYER2_IX=1
#FOR both input managers
const BTN_PRESSED_IX=0
const BTN_HOLD_IX=1
const BTN_RELEASED_IX=2
const HERO_NAME_IX=3
const PROF1_MAJOR_CLASS_SELECT_IX=4
const PROF1_MINOR_CLASS_SELECT_IX=5
const PROF2_MAJOR_CLASS_SELECT_IX=6
const PROF2_MINOR_CLASS_SELECT_IX=7
const PLAYER_NAME_IX=8
const PLAYER_SKIN_COLOR_IX=9
const PLAYER_REMAP_BUTTON_MODEL_IX = 10

var player1 =null
var player2=null
export (String) var replayFilePath = "user://savegame.save"

export (String) var replaySaveDirPath = "user://replays/"

export (String) var replayFileExt = "replay"

var state = State.IDLE

var inputDevices = []
var recordingBuffer = []

var replayingIdSaved = null

var replayTimeStamp = null


func _ready():
	
	var list = [null,null]
	list[PLAYER1_IX]=[[],[],[],null,null,null,null,null,null,null,null] #{bnt pressed buf,btn hold buf, btn released buf,heroname string...}
	list[PLAYER2_IX]=[[],[],[],null,null,null,null,null,null,null,null] #{bnt pressed buf,btn hold buf, btn released buf,heroname string...}
	recordingBuffer.append(list)#input manager info maps go here
	recordingBuffer.append(null)#stage name goes here
	
	inputDevices.clear()
	inputDevices.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDevices.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	
	set_physics_process(false)
	


#called whenever the input manager read new controller input
func _on_input_update(inputJustPressedBitMap,inputHoldingBitMap,inputReleasedBitMap,inputManager,playerIx):	 
	if state == State.RECORDING:

		#get map that stores input buffers
		var list = recordingBuffer[PLAYERS_IX][playerIx]
		
		#get buffers
		var btnPressedBuf = list[BTN_PRESSED_IX]
		var btnHoldBuf = list[BTN_HOLD_IX]
		var btnReleasedBuf = list[BTN_RELEASED_IX]
		
		
		#append the input to store it
		btnPressedBuf.append(inputJustPressedBitMap)
		btnHoldBuf.append(inputHoldingBitMap)
		btnReleasedBuf.append(inputReleasedBitMap)
	
func startRecording():
	reset()
	state = State.RECORDING
	
func stopRecording():
	
	state = State.IDLE
	
#clears all recording buffers
func reset():

	state = State.IDLE	
	
	recordingBuffer.clear()
	
	var list = [null,null]
	list[PLAYER1_IX]=[[],[],[],null,null,null,null,null,null,null,null] #{bnt pressed buf,btn hold buf, btn released buf,heroname string...}
	list[PLAYER2_IX]=[[],[],[],null,null,null,null,null,null,null,null] #{bnt pressed buf,btn hold buf, btn released buf,heroname string...}
	recordingBuffer=[]
	recordingBuffer.append(list)#input manager info maps go here
	recordingBuffer.append(null)#stage name goes here
	
#countrs number of replay files in the replay dir
func countNumberOfAvailableReplays():
	
	var dir = Directory.new()
	
	#no replay directory?
	if not dir.dir_exists(replaySaveDirPath):
		return 0
		
	#get all the files in the directory of replay
	var files = GLOBALS.list_files_in_directory(replaySaveDirPath)
	
	var numReplays= 0
	
	for f in files:
		var fileFullPath=replaySaveDirPath+"/"+f
		#the appropriate replay file type?
		if f.ends_with("."+replayFileExt):
			numReplays=numReplays+1
	
	return numReplays
	
func saveReplay(_player1HeroName, _player2HeroName,
			_p1Prof1MajorClassIxSelect,	_p1Prof1MinorClassIxSelect,
			_p1Prof2MajorClassIxSelect,_p1Prof2MinorClassIxSelect,
			_p2Prof1MajorClassIxSelect,_p2Prof1MinorClassIxSelect,
			_p2Prof2MajorClassIxSelect,_p2Prof2MinorClassIxSelect
			,_player1Name,_player2Name,_player1Color,_player2Color,_stageNodePath,
			_player1ButtonRemapModel,_player2ButtonRemapModel
			):
				
	#don't save recording with empty inputs
	if not hasButtonRecordings():
		return
			


	recordingBuffer[PLAYERS_IX][PLAYER1_IX][HERO_NAME_IX]=_player1HeroName
	recordingBuffer[PLAYERS_IX][PLAYER1_IX][PROF1_MAJOR_CLASS_SELECT_IX]=_p1Prof1MajorClassIxSelect
	recordingBuffer[PLAYERS_IX][PLAYER1_IX][PROF1_MINOR_CLASS_SELECT_IX]=_p1Prof1MinorClassIxSelect
	recordingBuffer[PLAYERS_IX][PLAYER1_IX][PROF2_MAJOR_CLASS_SELECT_IX]=_p1Prof2MajorClassIxSelect
	recordingBuffer[PLAYERS_IX][PLAYER1_IX][PROF2_MINOR_CLASS_SELECT_IX]=_p1Prof2MinorClassIxSelect
	recordingBuffer[PLAYERS_IX][PLAYER1_IX][PLAYER_NAME_IX]=_player1Name
	recordingBuffer[PLAYERS_IX][PLAYER1_IX][PLAYER_SKIN_COLOR_IX]=_player1Color
	recordingBuffer[PLAYERS_IX][PLAYER1_IX][PLAYER_REMAP_BUTTON_MODEL_IX]=_player1ButtonRemapModel
	
	recordingBuffer[PLAYERS_IX][PLAYER2_IX][HERO_NAME_IX]=_player2HeroName
	recordingBuffer[PLAYERS_IX][PLAYER2_IX][PROF1_MAJOR_CLASS_SELECT_IX]=_p2Prof1MajorClassIxSelect
	recordingBuffer[PLAYERS_IX][PLAYER2_IX][PROF1_MINOR_CLASS_SELECT_IX]=_p2Prof1MinorClassIxSelect
	recordingBuffer[PLAYERS_IX][PLAYER2_IX][PROF2_MAJOR_CLASS_SELECT_IX]=_p2Prof2MajorClassIxSelect
	recordingBuffer[PLAYERS_IX][PLAYER2_IX][PROF2_MINOR_CLASS_SELECT_IX]=_p2Prof2MinorClassIxSelect
	recordingBuffer[PLAYERS_IX][PLAYER2_IX][PLAYER_NAME_IX]=_player2Name
	recordingBuffer[PLAYERS_IX][PLAYER2_IX][PLAYER_SKIN_COLOR_IX]=_player2Color
	recordingBuffer[PLAYERS_IX][PLAYER1_IX][PLAYER_REMAP_BUTTON_MODEL_IX]=_player2ButtonRemapModel
	
	recordingBuffer[STAGE_NODE_PATH_IX]=_stageNodePath
	#recordingBuffer[SETTINGS_IX]=var2bytes(_settings)
	

	 
	var dir = Directory.new()
	
	#no replay directory?
	if not dir.dir_exists(replaySaveDirPath):
		#create the directory
		dir.make_dir_recursive(replaySaveDirPath)
    	
    	

	 
	#get name of replay which will be number of replays
	var replayId = str(countNumberOfAvailableReplays())
	
	var replayFile = File.new()
	
	var replayFilePath=replayIdToPath(replayId)
	
	#open for write
	replayFile.open(replayFilePath,File.WRITE)
	
	#convert recording to byte array
	var outputBytes = var2bytes(recordingBuffer)
	
	#write the recording to the file
	replayFile.store_buffer(outputBytes)
	
	replayFile.close()
	
	#can only save once
	reset()
	
	stopRecording()

func replayIdToPath(replayId):
	return replaySaveDirPath+"/"+str(replayId)+"."+replayFileExt
	
func startReplayingTracking(replayId,_player1,_player2):
	set_physics_process(true)
	replayingIdSaved=replayId
	player1=_player1
	player2=_player2


#will return true when a valid replay file loaded into memory. returns false if replay file wasn't loaded or  ir a replay was recenlty recorded without having all its config info saved
func isEmptyReplay():
	return recordingBuffer[STAGE_NODE_PATH_IX] == null #use the stage entry as indicator that replay is empty or not (all attributes written and loaded at same time, so reasonable sassupmtion)

#returns trune when buttons have been logged, false otherwise (so if a replay was loaded or if a recodring just happened)
func hasButtonRecordings():
	return  recordingBuffer[PLAYERS_IX][PLAYER1_IX][BTN_PRESSED_IX].size()>0	

	
func loadReplay(replayId):
	
	var success=false
	var numReplays = countNumberOfAvailableReplays()
	
	if numReplays < replayId:
		print("could not load replay "+str(replayId)+", it doesn't exist")
		return success
		
	reset()
	
	
	
	var replayFile = File.new()
	
	var replayFilePath=replayIdToPath(replayId)
	
	
	var unixTimeStamp = replayFile.get_modified_time (replayFilePath) 
	var timeMap = OS.get_datetime_from_unix_time(unixTimeStamp)
	#year/month/day: HH/mm/ss
	replayTimeStamp =str(timeMap["year"])+"/"+str(timeMap["month"])+"/"+str(timeMap["day"])+" - "+str(timeMap["hour"])+":"+str(timeMap["minute"])+":"+str(timeMap["second"])
	
	var exists = replayFile.file_exists(replayFilePath)
	
	#no such ai database file?
	if not exists:
		print("could not load replay "+replayFilePath+", it doesn't exist")
		return success
	
	
	
	
	#open for write
	replayFile.open(replayFilePath,File.READ)


	var numBytesToRead = replayFile.get_len()
	
	#read in entire file into a buffer
	var bytes = replayFile.get_buffer(numBytesToRead)
	
	replayFile.close()
	
	
	if bytes != null and bytes.size() > 0:	
		

						
		#convert byte arrway to recording buffer
		var _recordingBuffer = bytes2var(bytes)
		
		if _recordingBuffer.size() != RECORDING_BUFFER_LENTH:
			print("corrupt replay file  "+replayFilePath+". Cannot load")
			return success
			
			
		if _recordingBuffer[PLAYERS_IX][PLAYER1_IX].size() != INTERNAL_RECORDING_BUFFER_LIST_LENTH:
			print("corrupt replay file  "+replayFilePath+". Cannot load")
			return success 
		if _recordingBuffer[PLAYERS_IX][PLAYER2_IX].size() != INTERNAL_RECORDING_BUFFER_LIST_LENTH:
			print("corrupt replay file  "+replayFilePath+". Cannot load")
			return success

		recordingBuffer = _recordingBuffer
		#print("succesfully loaded replay: "+replayFilePath)
		
		success = true
		
	else:
		print("empty replay file "+replayFilePath+". cannot load")
		return success
		
	return success


func toUsrDataArray():
	
	if isEmptyReplay():
		return null
		
	return [recordingBuffer[PLAYERS_IX][PLAYER1_IX][HERO_NAME_IX], recordingBuffer[PLAYERS_IX][PLAYER2_IX][HERO_NAME_IX],
			recordingBuffer[PLAYERS_IX][PLAYER1_IX][PROF1_MAJOR_CLASS_SELECT_IX],	recordingBuffer[PLAYERS_IX][PLAYER1_IX][PROF1_MINOR_CLASS_SELECT_IX],
			recordingBuffer[PLAYERS_IX][PLAYER1_IX][PROF2_MAJOR_CLASS_SELECT_IX],	recordingBuffer[PLAYERS_IX][PLAYER1_IX][PROF2_MINOR_CLASS_SELECT_IX],
			recordingBuffer[PLAYERS_IX][PLAYER2_IX][PROF1_MAJOR_CLASS_SELECT_IX],	recordingBuffer[PLAYERS_IX][PLAYER2_IX][PROF1_MINOR_CLASS_SELECT_IX],
			recordingBuffer[PLAYERS_IX][PLAYER2_IX][PROF2_MAJOR_CLASS_SELECT_IX],	recordingBuffer[PLAYERS_IX][PLAYER2_IX][PROF2_MINOR_CLASS_SELECT_IX],
			recordingBuffer[PLAYERS_IX][PLAYER1_IX][PLAYER_NAME_IX],recordingBuffer[PLAYERS_IX][PLAYER2_IX][PLAYER_NAME_IX],
			recordingBuffer[PLAYERS_IX][PLAYER1_IX][PLAYER_SKIN_COLOR_IX],recordingBuffer[PLAYERS_IX][PLAYER2_IX][PLAYER_SKIN_COLOR_IX],
			load(recordingBuffer[STAGE_NODE_PATH_IX]),
			recordingBuffer[PLAYERS_IX][PLAYER1_IX][PLAYER_REMAP_BUTTON_MODEL_IX],recordingBuffer[PLAYERS_IX][PLAYER2_IX][PLAYER_REMAP_BUTTON_MODEL_IX]]
#func getHeroName(playerIx):
	#if isEmptyReplay():
		#return null
		
	#return recordingBuffer[PLAYERS_IX][playerIx][HERO_NAME_IX]
	
#func getStageResourceName(playerIx):
#	if isEmptyReplay():
#		return null
		
#	return recordingBuffer[STAGE_NODE_PATH_IX]
	
	
#func getSettings():
	#if isEmptyReplay():
	#	return null
		
	#return bytes2var(recordingBuffer[SETTINGS_IX])
func getButtonsPressedBuffer(playerIx):
	if isEmptyReplay():
		return null
		
	return recordingBuffer[PLAYERS_IX][playerIx][BTN_PRESSED_IX]
	
func getButtonsHoldBuffer(playerIx):
	if isEmptyReplay():
		return null
		
	return recordingBuffer[PLAYERS_IX][playerIx][BTN_HOLD_IX]
	
func getButtonsReleasedBuffer(playerIx):
	if isEmptyReplay():
		return null
		
	return recordingBuffer[PLAYERS_IX][playerIx][BTN_RELEASED_IX]
#
func getStage():
	if isEmptyReplay():
		return null
		
	return recordingBuffer[STAGE_NODE_PATH_IX]

func getHeroName(playerIx):
	if isEmptyReplay():
		return null
		
	return recordingBuffer[PLAYERS_IX][playerIx][HERO_NAME_IX]

func gaetReplayDate():
	return replayTimeStamp
	
func _physics_process(delta):

	if  state == State.IDLE:
		#can interact with replay
		#any controller can leave post online match lobby
		for inputDeviceId in inputDevices:	
			
			if Input.is_action_just_pressed(inputDeviceId+"_START"):
				
				
				var opponentInputDevice = null
				if inputDeviceId == player1.playerController.inputManager.inputDeviceId:
					opponentInputDevice = GLOBALS.PLAYER2_INPUT_DEVICE_ID
				else:
					opponentInputDevice = GLOBALS.PLAYER1_INPUT_DEVICE_ID
				  
				player1.playerController.emit_signal("pause",inputDeviceId,opponentInputDevice,player1.playerController,GLOBALS.PauseMode.IN_GAME)
				return
				
			if Input.is_action_just_pressed(inputDeviceId+"_SELECT"):
				
				emit_signal("restart_replay",replayingIdSaved)
				return
