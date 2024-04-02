extends Node

var nameFilePath = null
var stats = null
var nameDataModel = []

const NAME_IX = 0
const INPUT_REMAP_MODEL_IX=1

var inputRemapModelMap = {}
#data model: [string, {}] for [name , input remap model (null if non)]
func _ready():
	pass # Replace with function body.

func init(_nameFilePath,_stats):
	nameFilePath = _nameFilePath
	stats=_stats
	var fileBytes = readNameFileBytes()
	
	if fileBytes == null:
		nameDataModel=[] #empty
	else:
		
		if fileBytes.size() >0:
			nameDataModel = bytes2var(fileBytes,true)
			
			if nameDataModel == null or  (not nameDataModel is Array):
				print("possibly corrupt names file "+ nameFilePath +" create new names file")
				nameDataModel=[] #empty
		else:
			nameDataModel=[] #empty
	#want to cr3eate index over names to make it easy to lookup input models
	
	#iterate over evry entry in model
	for entry in nameDataModel:
		
		#extract name
		var _name = entry[NAME_IX]
		var inputRemapModel = entry[INPUT_REMAP_MODEL_IX]
		
		inputRemapModelMap[_name]=inputRemapModel


	
		
#reads and returns the bytes (PoolByteArray) from file specified by nameFilePath
#or null if there was a problem reading such a file
func readNameFileBytes():
	
	#not in appropriate state to read the file?
	if (nameFilePath == null):
		return null
	
	#check whether file exists
	var nameFile = File.new()
	var exists = nameFile.file_exists(nameFilePath)
	
	#no such  file?
	if not exists:
		return null
	
	#open for read-only
	nameFile.open(nameFilePath,File.READ)
	
	var numBytesToRead = nameFile.get_len()
	
	#read in entire file into a buffer
	var bytes = nameFile.get_buffer(numBytesToRead)
	
	nameFile.close()
	
	return bytes
	

#saves the database as serialized bytes to file
func saveNamesFileBytes():
	
	if (nameFilePath == null):
		print("warning, trying to save names file but namehandler isn't properly initialized")
		return
	
	
	var nameFile = File.new()
	
	#open for write
	nameFile.open(nameFilePath,File.WRITE)
	
	#convert data model to byte array
	var outputBytes = var2bytes(nameDataModel)
	
	#write the serialized database to file
	nameFile.store_buffer(outputBytes)
	
	nameFile.close()
	
	
func saveInputRemapModel(pName,_inputRemapModel):
	inputRemapModelMap[pName]=_inputRemapModel
	
	for entry in nameDataModel:
		var _name = entry[NAME_IX]
		
		#found name?
		if _name ==pName:
			
			#update the input remap model
			entry[INPUT_REMAP_MODEL_IX]=_inputRemapModel
			
	#SAVE changes
	saveNamesFileBytes()
	pass
	
func addNewName(newName):
	var inputRemapModel = null
	var entry = [newName,inputRemapModel]
	
	#add new name with empty input remap model (default input)
	nameDataModel.append(entry)
	
	#SAVE changes
	saveNamesFileBytes()
	
func readAllNames():
	var names = []
	
	#iterate over evry entry in mode
	for entry in nameDataModel:
		
		#extract name
		var _name = entry[NAME_IX]
		
		names.append(_name)
	
	return names
	pass
	
func readInputRemapModel(pname):
	if pname == null:
		return 
	
	if inputRemapModelMap.has(pname):
		return inputRemapModelMap[pname]
	else:
		return null
	
func removeName(pname):
	
	if pname == null:
		return 
		
	if inputRemapModelMap.has(pname):
		inputRemapModelMap.erase(pname)
	
	var ixToRemove = -1
	
	#find the index of entry to remove
	for ix in  nameDataModel.size():
		var entry = nameDataModel[ix]
		
		var _name =entry[NAME_IX]
		if _name ==pname:
			ixToRemove=ix
			break
			
	if	ixToRemove != -1:
		nameDataModel.remove(ixToRemove)
	
	stats.removePlayerName(pname)
	saveNamesFileBytes()
	pass
	
func nameExists(pname):
	if pname == null:
		return false
		
	return inputRemapModelMap.has(pname)
	