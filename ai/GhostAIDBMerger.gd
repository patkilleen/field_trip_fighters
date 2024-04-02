extends Node

var ghostAIDBResource = preload("res://ai/GhostAIDB.gd")

func _ready():
	pass # Replace with function body.
	
	
#TODO: merge function logic of situation handler and this script, since a lot of logic for saving/reading files 
#shared

func loadAIDBIntoMemory(aiDBFilePath):
	
	#create an empty ai database object
	var liveGhostDB = ghostAIDBResource.new()
	
	
	#read the databse bytes into memory
	var aiDBFileBytes = readGhostDBFileBytes(aiDBFilePath)
		
	#ghost db ai database file already exists on disk?
	#that is, bytes were read		
	if aiDBFileBytes != null and aiDBFileBytes.size() > 0:	
		#parse the bytes into DB file, and load the database properties of object
		liveGhostDB.importSerialization(aiDBFileBytes)
	else:
		liveGhostDB.init()
		
		
	return liveGhostDB
		
#reads and returns the bytes (PoolByteArray) from file specified by aiDBFilePath
#or null if there was a problem reading such a file
func readGhostDBFileBytes(_aiDBFilePath):
	
	#not in appropriate state to read the file?
	if (_aiDBFilePath == null):
		return null
	
	#check whether database file exists
	var aiDBFile = File.new()
	var exists = aiDBFile.file_exists(_aiDBFilePath)
	
	#no such ai database file?
	if not exists:
		return null
	
	#open for read-only
	aiDBFile.open(_aiDBFilePath,File.READ)
	
	var numBytesToRead = aiDBFile.get_len()
	
	#read in entire file into a buffer
	var bytes = aiDBFile.get_buffer(numBytesToRead)
	
	aiDBFile.close()
	
	return bytes
	

#saves the database as serialized bytes to file
func saveGhostDBFile(ghostDB, outputFilePath):
	
	
	var aiDBFile = File.new()
	
	#open for write
	aiDBFile.open(outputFilePath,File.WRITE)
	
	#convert db to byte array
	var outputBytes = ghostDB.serialize()
	
	#write the serialized database to file
	aiDBFile.store_buffer(outputBytes)
	
	aiDBFile.close()
	


func mergeMatchDataToGhostDB(heroName, liveGhostDBFilePath,matchDataDir, outputMergeDBFilePath):
	
	var matchFileName = "matchSummary.info"
	#read the demoDB of live ghost ai file into memory
	var liveGhostDB = loadAIDBIntoMemory(liveGhostDBFilePath)
	
	#iterate over every match folder in match data directory
	#assumes the match data dir only has folers (prone to bugs if you add a file that isn't folder, but fine for now)
	var matchDirs = list_files_in_directory(matchDataDir)
	
	var dir = Directory.new()
	for matchDir in matchDirs:
		var mergedFlag = false
		
		#read the file that explains the hero's name in match
		var matchSumamryFilePath = matchDataDir + "/" + matchDir +"/"+ matchFileName
		
		if not dir.file_exists(matchSumamryFilePath):
			continue
			
		var f = File.new()
		#open the match infor file and go trhough contents to figuer out heros playaer
		f.open(matchSumamryFilePath, File.READ)
		
		#content format exampel
		#player 1 Hero name  = ken
		#player 2 Hero name  = ken
		#player 1 gamertag  = Null
		#player 2 gamertag  = Null
		#stage  = res://stages/swamp.tscn
		#winner  = player 1
		
		var index = 1
		while not f.eof_reached(): # iterate through all lines until the end of file is reached
			var line = f.get_line()
			
			#file doesnt exist?
			if line.empty():
				break
			var matchHeroName = null
			var tokens = line.split("=") #fromat: player 1 Hero name  = ken -> tokens = [...., ' <heroname>']
			var heroNameWithSpaces = tokens[1]
			#now trim it to make it uniquly hero name by removing white spaces
			matchHeroName = heroNameWithSpaces.strip_edges(heroNameWithSpaces)
			#player 1 parsing
			if index == 1:
				
					#found hero to merge stats of for player 1?
				if(matchHeroName == heroName):
					var matchGhostDBFileName = "0.ser"
					
					#read into memory the DB
					var matchGhostDB = loadAIDBIntoMemory(matchDataDir + "/" + matchDir +"/"+ matchGhostDBFileName)
					
					#merge into curernt DB
					liveGhostDB.mergeGhostDB(matchGhostDB)
					mergedFlag=true
			elif index == 2:
					#now chec for player 2
				#found hero to merge stats of for player 1?
				if(matchHeroName == heroName):
					var matchGhostDBFileName = "2.ser"
					
					#read into memory the DB
					var matchGhostDB = loadAIDBIntoMemory(matchDataDir + "/" + matchDir +"/"+ matchGhostDBFileName)
					
					#merge into curernt DB
					liveGhostDB.mergeGhostDB(matchGhostDB)
					
					mergedFlag=true
		
			else:
				break #stop reading lines after hero names parse
				
				#parse the heor names of match
	

			index += 1
		f.close()
		
		if mergedFlag:
			print("merged "+matchSumamryFilePath)
	print("outputing merged DB to  "+outputMergeDBFilePath)	
	
	saveGhostDBFile(liveGhostDB,outputMergeDBFilePath)

		
	

func list_files_in_directory(path):
    var files = []
    var dir = Directory.new()
    dir.open(path)
    dir.list_dir_begin()

    while true:
        var file = dir.get_next()
        if file == "":
            break
        elif not file.begins_with("."):
            files.append(file)

    dir.list_dir_end()

    return files
	
