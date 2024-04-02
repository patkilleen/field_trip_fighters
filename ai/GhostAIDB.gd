extends Node

const DEFAULT_SITUATION_FREQUENCY = 1



const SITUATION_FREQUENCY_IX = 0
const SITUATION_COMMAND_LIST_IX = 1

const COMMAND_FREQUENCY_IX = 0
const COMMAND_VALUE_IX = 1



const SER_PRIOR_SITUATION_MAP_IX = 0
const SER_DEMO_DATA_MAP_IX = 1
const SER_SPRITE_FRAME_ACTIVATION_FREQUENCY_MAP_IX = 2
const SER_SPRITE_FRAME_ABILITY_CANCEL_FREQUENCY_MAP_IX = 3
const SER_ENV_COLLISION_FREQUENCY_IX = 4
const SER_TECH_FREQUENCY_IX = 5

const NUMBER_OF_SERIALIZABLE_MEMBERS = 6

var priorSituationMap = {}
var demoDataMap = {}


#tracks the number of tiems sprite frames activate
var spriteFrameActivationFreqMap = {}

#tracks number of times sprite frame ability canceled
var spriteFrameAbilityCancelFreqMap = {}


var currSpriteFrame = null


const WALL_COLLIDE_IX = 0
const FLOOR_COLLIDE_IX = 1
const CEILING_COLLIDE_IX = 2

var environmentCollisionFrequencies = [0,0,0] # COLLISIONs starts off at 0

const WALL_TECH_IX = 0
const CEILING_TECH_IX = 1
const FLOOR_TECH_IN_PLACE_IX = 2
const FLOOR_TECH_BACKWARD_IX = 3
const FLOOR_TECH_FORWARD_IX = 4

var techFrequencies = [0,0,0,0,0] #techs start off at 0 

#var freqRationMutex = null
func _ready():
	pass # Replace with function body.

func init():
	
	techFrequencies=[0,0,0,0,0]
	environmentCollisionFrequencies = [0,0,0]
	spriteFrameAbilityCancelFreqMap = {}
	priorSituationMap = {}
	demoDataMap = {}
	spriteFrameActivationFreqMap = {}
	
#	freqRationMutex =  Mutex.new()
		
		
#saves the situation into demo data and increases its frequency
#and records the action taken in the situation (increment encryt of action)
#or create new entry
func logCommandSituationPair(cmd,situationId):
	
	if situationId == null:
		return
		
	#creaet the situation entry or increment frequency of situation
	logSituation(situationId)
	
	var cmdMap = getSituationCommandMap(situationId)
	
	#command already present in list?
	if cmdMap.has(cmd):
		
		#increase the frequency of the action
		cmdMap[cmd] = cmdMap[cmd]  + 1
	else:
		
		#create a new entry, and the action has occured once
		cmdMap[cmd] = 1
	
	
	#now populate the inverse lookup map
	populateSituationMap(cmd,situationId)
	
	
#saves the situation into demo data and increases its frequency
func logSituation(situationId):
	
	if situationId  == null:
		return
		
	#already exists?
	if demoDataMap.has(situationId):
		
		
		#increase the situation frequency entry
		var entry = demoDataMap[situationId]
		entry[SITUATION_FREQUENCY_IX] = entry[SITUATION_FREQUENCY_IX] + 1
		return
	
	
	#create the situation entry	
	var entry = []
	var emptyCmdMap = {}
	
	entry.append(DEFAULT_SITUATION_FREQUENCY)
	entry.append(emptyCmdMap)
	
	#log the situation
	demoDataMap[situationId] = entry
	
#gets the frequency of a command for a given situation	
func getCommandFrequency(cmd,situationId):
	var cmdMap = getSituationCommandMap(situationId)
	
	#command already present in list?
	if cmdMap.has(cmd):
		return cmdMap[cmd]
	else:
		return 0 
	
#gets an array of commands that are found for a given situation
func getListOfCommands(situationId):
	
	if situationId == null:
		return null 
		
	var cmdMap = getSituationCommandMap(situationId)
	return cmdMap.keys()
	
#given a situatin id, returns the frequency of occurence 
#of the situation in demo data
#or null if situation id is null		
func getSituationFrequency(situationId):

	if situationId  == null:
		return null
	
	#get the frequency from entry of situation
	var freq = _getSituationProperty(situationId,SITUATION_FREQUENCY_IX,0)
		
	return freq


func hasSituationId(situationId):
	return demoDataMap.has(situationId)
	
#returns the command map of commands taken in past given the situation
func getSituationCommandMap(situationId):
	
	if situationId  == null:
		return null
	
	#get the command list from entry of situation
	var cmdList = _getSituationProperty(situationId,SITUATION_COMMAND_LIST_IX,{})
	
	#there is a design problem if cmdList is null
	#if cmdList == null:
	#	print("GhostAIDB: error in the situation command list fecthing")
	
	return cmdList

#returns the value of the property at given index of situation entry
#or the given default value (or null if not provided) if it doesn't exist
func _getSituationProperty(situationId,propertyIx, defaultValue = null):
		
	if situationId  == null:
		return null
		
	var res = defaultValue
	#the situatin exists in demo data?
	if demoDataMap.has(situationId):
		
		#now we gotta fetch it and get the property
		var situationEntry = demoDataMap[situationId]
	
		#should do bound checking, but a good design will avoid an indexing out of bounds error
		#and we can save isntructions
		res = situationEntry[propertyIx]
			
	return res
	
	
#returns a list of situations a command (or null command) was unsed in in the demodata
func getSituationsCommandUsedIn(cmdKey):
	#if cmdKey == null:
	#	return null
	
	#command used before?
	if priorSituationMap.has(cmdKey):
		#get dictionary for the command
		var situationDic = priorSituationMap[cmdKey]
		
		#recall that the keys are the situations id
		return situationDic.keys()
		
	else:
		
		#no situation entry for command
		return []
	
	
#given a command key (which can be null) and a situation id, 
#returns true when command was used in the given siutation 
#and false it hasn't
func hasCommandBeenUsedInSituation(cmdKey, situationId):
	
	#if cmdKey == null or situationId == null:
	if situationId == null:
		return null
		
		
	#command never used before?
	if not priorSituationMap.has(cmdKey):
		return false
	
	#get dictionary for the command
	var situationDic = priorSituationMap[cmdKey]
	
	#now we check if the situation occured before and the given command was input
	return situationDic.has(situationId)
		
		
#adds a situationId to the map, given a command key
func populateSituationMap(cmdKey, situationId):
	
	#if cmdKey == null:
	#	print("GHOSTAIDB: cannot populate situatin map, due to null actionId")
	#	return
	
	#ignore null situations
	if situationId == null:
		print("GHOSTAIDB: cannot populate situatin map, due to null situation id")
		return
	
	
	#first time command used?
	if not priorSituationMap.has(cmdKey):
		
		#create a new situation id dictionary
		var situationDic = {}
		
		#just use the keys for lookup, no need to store value
		situationDic[situationId] = null
		
		priorSituationMap[cmdKey] = situationDic
		
		#we just populated the map with first entries/values, so nothing 
		#left to do
		return
	
	#dictionary for the command exists already
	var situationDic = priorSituationMap[cmdKey]
	
	#now we check if the situation occured before and the given command was input
	if not situationDic.has(situationId):
		
		#in this case, in the demo data, we never inputed the given command
		#in the given situation, so take note of this
		#first time we doing this command in the situation
		situationDic[situationId] = null
		
	#otherwise, we already encounrted this situation for the command
	pass
		
	
#converts this database into a byte sequence	
func serialize():
	
	var outputArray = []
	
	#here we append the imporatant memebers to array
	outputArray.append(priorSituationMap)
	outputArray.append(demoDataMap)
	outputArray.append(spriteFrameActivationFreqMap)
	outputArray.append(spriteFrameAbilityCancelFreqMap)
	outputArray.append(environmentCollisionFrequencies)
	outputArray.append(techFrequencies)
	return var2bytes(outputArray)
	
#converts a byte array, representing a serialized DB, into a ghost ai db
func importSerialization(bytes):
	
	if bytes == null:
		print("failed to import a serizalied ghost ai db. the input array is null")
		return
		
	#
	var inputArray = bytes2var(bytes)
	
	if inputArray.size() != NUMBER_OF_SERIALIZABLE_MEMBERS:
		print("failed to import a serizalied ghost ai db. the input array doesn't match number of properties")
		return 
	
	
	priorSituationMap = inputArray[SER_PRIOR_SITUATION_MAP_IX]
	demoDataMap =  inputArray[SER_DEMO_DATA_MAP_IX]
	spriteFrameActivationFreqMap =  inputArray[SER_SPRITE_FRAME_ACTIVATION_FREQUENCY_MAP_IX]
	spriteFrameAbilityCancelFreqMap =  inputArray[SER_SPRITE_FRAME_ABILITY_CANCEL_FREQUENCY_MAP_IX]
	environmentCollisionFrequencies =  inputArray[SER_ENV_COLLISION_FREQUENCY_IX]
	techFrequencies =  inputArray[SER_TECH_FREQUENCY_IX]
	
#returns the fraction of time a sprite frame occured vs. the number of times it 
#was active during an ability cancel
func getSpriteFrameActivation_AbilityCancelRatio(spriteFrame):
	
	if spriteFrame == null:
		return null
		
	var ratio = 0.0
	
	#freqRationMutex.lock()
	
	#only compute the ratio if sprite frame occured before
	if spriteFrameActivationFreqMap.has(spriteFrame):
		
		var cancelFreq = 0.0
		
		
		#fetch teh cancel frequency only if cnacel occured before 
		#for the given sprite frame
		if spriteFrameAbilityCancelFreqMap.has(spriteFrame):
			cancelFreq = spriteFrameAbilityCancelFreqMap[spriteFrame]
		else:
			
			#no cancel occured, so frequency is 0 when key doesn't exist
			pass
			
		
		ratio = cancelFreq / float(spriteFrameActivationFreqMap[spriteFrame]) #cast to float to make sure we don't have int division
	
	#freqRationMutex.unlock()
		
	return ratio
	
#increases the frequency of sprite frames
func incrementSpriteFrameFrequency(spriteFrame):
	
	if spriteFrame == null:
		return
	
	#freqRationMutex.lock()
	
	#no entry for this frame?
	if not spriteFrameActivationFreqMap.has(spriteFrame):
		
		#initialize the default frequency to 1, sprite
		#frame activate for first tiem
		spriteFrameActivationFreqMap[spriteFrame] = 0

	
	#increment the sprite frame frequency
	spriteFrameActivationFreqMap[spriteFrame] =  spriteFrameActivationFreqMap[spriteFrame] + 1

	#freqRationMutex.unlock()	

func incrementAbilityCancelFrequency(spriteFrame):
	
	if spriteFrame == null:
		return 
		

	
	#the sprite frame hasn't been ability canceled before?
	if not spriteFrameAbilityCancelFreqMap.has(spriteFrame):
		spriteFrameAbilityCancelFreqMap[spriteFrame] = 1
	else:
		#increment the ability cancel count
		spriteFrameAbilityCancelFreqMap[spriteFrame] = spriteFrameAbilityCancelFreqMap[spriteFrame]+1
		

func increaseWallCollisionFrequency():

	environmentCollisionFrequencies[WALL_COLLIDE_IX] =  environmentCollisionFrequencies[WALL_COLLIDE_IX] + 1
#	
func increaseCeilingCollisionFrequency():
	
	environmentCollisionFrequencies[CEILING_COLLIDE_IX] =  environmentCollisionFrequencies[CEILING_COLLIDE_IX] + 1
	
func increaseFloorCollisionFrequency():
	
	environmentCollisionFrequencies[FLOOR_COLLIDE_IX] =  environmentCollisionFrequencies[FLOOR_COLLIDE_IX] + 1
	
#incresase frequency of a tech given a type index
func increaseTechFrequency(typeIx):
	
	techFrequencies[typeIx] =  techFrequencies[typeIx] + 1
	
func getWallCollision_TechRatio():
	return getEnvironmentCollision_TechRatio(WALL_COLLIDE_IX,WALL_TECH_IX)

func getFloorCollision_TechInPlaceRatio():
	return getEnvironmentCollision_TechRatio(FLOOR_COLLIDE_IX,FLOOR_TECH_IN_PLACE_IX)

func getFloorCollision_TechForwardRatio():
	return getEnvironmentCollision_TechRatio(FLOOR_COLLIDE_IX,FLOOR_TECH_FORWARD_IX)

func getFloorCollision_TechBackwardRatio():
	return getEnvironmentCollision_TechRatio(FLOOR_COLLIDE_IX,FLOOR_TECH_BACKWARD_IX)
		
func getCeilingCollision_TechRatio():
	return getEnvironmentCollision_TechRatio(CEILING_COLLIDE_IX,CEILING_TECH_IX)		

#returns the ration of techs to collisions with envrionement
func getEnvironmentCollision_TechRatio(envix,techix):
	
	var res = null
	
	#freqRationMutex.lock()
	
	#avoid divisions by 0
	if environmentCollisionFrequencies[envix] == 0:
		res = 0
	else:
		#convert atleast one int to float to make sure is real # division
		res = techFrequencies[techix]/float(environmentCollisionFrequencies[envix])
		
	#freqRationMutex.unlock()
	
	return res
	

#takes another ghost ai db and merges it's sats with this' DB
func mergeGhostDB(otherDB):
	#**************************
	#merge the prior situations
	#**************************
	for cmd in otherDB.priorSituationMap.keys():
		
		#get dictionary for the command
		var otherSituationDic = otherDB.priorSituationMap[cmd]
		
		#trivila case is cmd wasn't found in DB, so just add the dictionery of situatainos
		if not self.priorSituationMap.has(cmd):
			self.priorSituationMap[cmd] = otherSituationDic
		else:
			
			#our map
			var selfSituationDic=priorSituationMap[cmd]
			
			#iterate other's map. command already used, so go through keys and add them all to current dict (values all null, just
			#usef for lookup)
			for situaionId in otherSituationDic.keys():
				
				#only add new situations
				if not selfSituationDic.has(situaionId):
					selfSituationDic[situaionId] = null #value isn't important, just key for lookup
	
	#finished merging prior situations
	
	#**************************
	#merge demo data map
	#**************************
	for otherSituationId in otherDB.demoDataMap.keys():
	
		var otherEntry = otherDB.demoDataMap[otherSituationId]
		
		#trivial case where situation not encounrted before?
		if not self.demoDataMap.has(otherSituationId):
			#add entry to our map
			demoDataMap[otherSituationId] = otherEntry
		else:
			#alread exists
			var selfEntry = demoDataMap[otherSituationId] 
			
			#combien situation frequency
			selfEntry[SITUATION_FREQUENCY_IX] = selfEntry[SITUATION_FREQUENCY_IX]+otherEntry[SITUATION_FREQUENCY_IX]
			
			#combine the commadn frequency map for this situation
			var otherCmdMap = otherEntry[SITUATION_COMMAND_LIST_IX]
			var selfCmdMap = selfEntry[SITUATION_COMMAND_LIST_IX]
			
			for otherCmd in otherCmdMap.keys():
				
				#trivial case where command not previously used in this situation
				if not selfCmdMap.has(otherCmd):
					#simply add the frequency of new cmd
					selfCmdMap[otherCmd]=otherCmdMap[otherCmd]
					
				else:
					#already existed command, so combine frequencies
					selfCmdMap[otherCmd] = selfCmdMap[otherCmd]+ otherCmdMap[otherCmd]
				
	
	#end merge demo data map 
	
	#**************************
	#merging spriteFrameActivationFreqMap
	#**************************
	
	for otherSf in otherDB.spriteFrameActivationFreqMap.keys():
		
		var otherSFFreq =otherDB.spriteFrameActivationFreqMap[otherSf]
		#tirvial case where sprite frame doesnt exist in self' map?
		if not self.spriteFrameActivationFreqMap.has(otherSf):
			spriteFrameActivationFreqMap[otherSf] =otherSFFreq
			
		else:
			#combine the frequencies
			spriteFrameActivationFreqMap[otherSf] = spriteFrameActivationFreqMap[otherSf] + otherSFFreq
		
		
	#end merge spriteFrameActivationFreqMap
	
	#**************************
	#merging spriteFrameAbilityCancelFreqMap
	#**************************
	
	for otherSf in otherDB.spriteFrameAbilityCancelFreqMap.keys():
		
		var otherSFFreq =otherDB.spriteFrameAbilityCancelFreqMap[otherSf]
		#tirvial case where sprite frame doesnt exist in self' map?
		if not self.spriteFrameAbilityCancelFreqMap.has(otherSf):
			spriteFrameAbilityCancelFreqMap[otherSf] =otherSFFreq
			
		else:
			#combine the frequencies
			spriteFrameAbilityCancelFreqMap[otherSf] = spriteFrameAbilityCancelFreqMap[otherSf] + otherSFFreq
		
		
	#end merge spriteFrameAbilityCancelFreqMap
	
		#**************************
	#merging environmentCollisionFrequencies
	#**************************
	
	for i in range(0,environmentCollisionFrequencies.size()-1):
		environmentCollisionFrequencies[i] =  environmentCollisionFrequencies[i] + otherDB.environmentCollisionFrequencies[i]
	
	
	#end merging environmentCollisionFrequencies
	
	#**************************
	#merging techFrequencies
	#**************************
	
	for i in range(0,techFrequencies.size()-1):
		techFrequencies[i] =  techFrequencies[i] + otherDB.techFrequencies[i]
	
	
	#end merging techFrequencies
	
	pass
	