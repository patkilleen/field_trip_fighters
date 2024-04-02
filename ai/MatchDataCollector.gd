extends Node

const PLAYER1=0
const PLAYER2=2

var GLOBALS = preload("res://Globals.gd")
var situationHandlerResource = preload("res://ai/GhostAISituationHandler.gd")
var stateCollectionResource = preload("res://ai/GhostAIStateCollector.gd")
var stateCollectors = []

const FORWARD_SLASH = "/"
const NEW_LINE = "\r\n"
const DEMO_DATA_FILE_EXTENSION = ".ser"
const MATCH_SUM_FILE_NAME = "matchSummary.info"
var matchDemoDataOutputDir = null
var matchDirectoryPath = null

var p1PlayerController = null
var p2PlayerController = null
var stageName = null

var initialized = false
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


#matchDemoDataOutputDir, directory (without ending '/') of where to create and store match info
func init(_matchDemoDataOutputDir,_p1PlayerController,_p2PlayerController,_stageName):

	stageName=_stageName
	matchDemoDataOutputDir=_matchDemoDataOutputDir
	p1PlayerController=_p1PlayerController
	p2PlayerController=_p2PlayerController
	
	#try to make directory for output match dolfers,
	if not mkdir(matchDemoDataOutputDir):
		
		
		print("MatchDataCollector, failed to create match output directory: "+str(matchDemoDataOutputDir))
		initialized =false
		return
	
	initialized=true		
	
func startCollectingMatchData():

	if not initialized:
		return
	
	#get the number of files/folders in the directory
	var numMatchEntires = countNumberFilesInDirectory(matchDemoDataOutputDir)
	
	#no files, means first foler called "0", if there are 5 files folders (names 0,1,2,3,4),
	#then 5 is new folder name
	var dirName = str(numMatchEntires)
	
	matchDirectoryPath = matchDemoDataOutputDir+FORWARD_SLASH+dirName
	
	#in case already started before, clear the old stat colletors
	for sc in stateCollectors:
		remove_child(sc)
		sc.queue_free()
	
	stateCollectors.clear()
	
	#lets create  the new match folder
	#try to make directory for output match dolfers,
	if not mkdir(matchDirectoryPath):
		
		
		print("MatchDataCollector, failed to create match output directory: "+str(matchDirectoryPath))
		return
	#create new state collectors instances for both players
	stateCollectors.append(createStateCollector(matchDirectoryPath,PLAYER1,p1PlayerController))
	stateCollectors.append(createStateCollector(matchDirectoryPath,PLAYER2,p2PlayerController))

#called when match ends
func _on_match_end(victoryType):
	
	if not initialized:
		return
		
	#save the demo data of players
	for sc in stateCollectors:
		sc.collectingDemoData=false
		sc.situationHandler.saveGhostDBFile()
		
	
	#save match summary
	var matchSummaryPath= matchDirectoryPath+FORWARD_SLASH+MATCH_SUM_FILE_NAME
	
	var matchFile = File.new()
	
	#open for write
	matchFile.open(matchSummaryPath,File.WRITE)
	
	
	#create ouput string with match info
	var outputString = "player 1 Hero name  = "+str(p1PlayerController.heroName) +NEW_LINE
	outputString = outputString + "player 2 Hero name  = "+str(p2PlayerController.heroName) +NEW_LINE
	outputString = outputString + "player 1 gamertag  = "+str(p1PlayerController.kinbody.playerName) +NEW_LINE
	outputString = outputString +  "player 2 gamertag  = "+str(p2PlayerController.kinbody.playerName) +NEW_LINE
	outputString = outputString +  "stage  = "+str(stageName)+NEW_LINE
	
	match(victoryType):
		GLOBALS.VictoryType.PLAYER1_WINS_VIA_KO:
			outputString = outputString +  "winner  = player 1"
		GLOBALS.VictoryType.PLAYER2_WINS_VIA_KO:
			outputString = outputString +  "winner  = player 2"
		GLOBALS.VictoryType.DRAW_VIA_KO:
			outputString = outputString +  "winner  = draw"
		GLOBALS.VictoryType.PLAYER1_WINS_VIA_TIMEOUT:
			outputString = outputString +  "winner  = player 1"
		GLOBALS.VictoryType.PLAYER2_WINS_VIA_TIMEOUT:
			outputString = outputString +  "winner  = player 2"
		GLOBALS.VictoryType.DRAW_VIA_TIMEOUT:
			outputString = outputString +  "winner  = draw"
		_:
			outputString = outputString +  "winner  = null"
			print("match collector: unknown victory type")
	
	#write the match info to file
	matchFile.store_string(outputString)
	
	matchFile.close()
	
	print("saved match data in : "+str(matchDirectoryPath))
	
#create a stat collector and creates path to db file
func createStateCollector(newMatchDirPath,playerId,playerController):
	
	var demoDataDBPath = newMatchDirPath+FORWARD_SLASH+str(playerId)+DEMO_DATA_FILE_EXTENSION
	
	var situationHandler = situationHandlerResource.new()
	situationHandler.init(demoDataDBPath)

	var stateCollector = stateCollectionResource.new()
	
	var aiAgent = null
	stateCollector.init(playerController,situationHandler,aiAgent)
	stateCollector.collectingDemoData=true
	
	self.add_child(stateCollector)
	return stateCollector

#returns the number of files/folders  in a directory or null upon error
func countNumberFilesInDirectory(dirPath):
	
	var counter = null
	var dir = Directory.new()
	if dir.open(dirPath) == OK:
		counter = 0
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			#counter number of file/dirs in directory
			counter = counter +1
			file_name = dir.get_next()
	else:

		print("MatchDataCollector: An error occurred when trying to access the path "+str(dirPath))
		
	return counter
	
	
#makes directry, return true on success, false on fail
#returns true when it exists too
func mkdir(dirPath):
	
	var dir = Directory.new()
	
	#does the directory path not exist?
	if not dir.dir_exists(dirPath):
		#create the direction
		if dir.make_dir_recursive(dirPath) != OK:
			print("failed to create directory: "+str(dirPath))
			#something went wrong
			return false
		else:
			return true
	else:
		#already exists
		return true