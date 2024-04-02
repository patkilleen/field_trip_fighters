extends Node

#all variable types in godot a Variant, and little-eendian-endocded, so least 
#significant bit encoded at 0th byte in memory
#https://docs.godotengine.org/en/stable/tutorials/misc/binary_serialization_api.html

#note that 'character' refers to the player the ghost ai is copying or immitating,
#while 'enemy' is the opponent 

#maximum distance of two states (incdluding 1 bit flags)
const STATE_PARAM_MAX_DISTANCE = 1

const STATE_PARAM_TYPE = 0
const INTEGER_PARAM_TYPE = 1


const NUMBER_OF_SERIALIZED_PARAMETERS = 21
const NUMBER_BITS_IN_INT = 64

const BIT_FROM_IX = 0
const BIT_TO_IX = 1

const MOST_SIMILAR_SITUATION_ID_IX=0
const MOST_SIMILAR_SITUATION_SIM_IX=1


var ghostAIDBResource = preload("res://ai/GhostAIDB.gd")


const CHARACTER_SPRITE_ANIMATION_ID_IX=0
const DELTA_X_POS_IX=1
const DELTA_Y_POS_IX=2
const ENEMY_SPRITE_ANIMATION_ID_IX=3
const NUMBER_ACTIVE_ENEMY_PROJECTILES_IX=4
const ENEMY_PROJECTILES_STATE_IX=5
const ENEMY_TOTAL_DAMAGE_TAKEN_IX=6##REFRACTORED TO TOTAL SUM OF ANIMATION IDs
const CHARACTER_FACING_RIGHT_IX=7
const CHARACTER_IN_CORNER_IX=8
const ENEMY_IN_CORNER_IX=9
const CHARACTER_NUMBER_JUMPS_REMAINING_IX=10
const ENEMY_NUMBER_JUMPS_REMAINING_IX=11
const CHARACTER_ON_PLATFORM_IX=12
const ENEMY_ON_PLATFORM_IX=13
const ENEMY_BLOCKING_STATUS_IX=14
const CHARACTER_BLOCKING_STATUS_IX=15
const CHARACTER_ON_GROUND_IX=16
const ENEMY_ON_GROUND_IX=17
const CHARACTER_SPRITE_ANIMATION_STATE_IX=18
const ENEMY_SPRITE_ANIMATION_STATE_IX=19
const ENEMY_IS_ABOVE_IX = 20
#only allocate this once
var findMostSimilarSituationResultBuffer = [null,null]


#size NUMBER_OF_SERIALIZED_PARAMETERS
var paramBitPositionMap = [ 
#FROM,TO, U(bit positions)
[0,7],#	CHARACTER_SPRITE_ANIMATION_ID_IX,
[8,12],#	DELTA_X_POS_IX,
[13,17],#	DELTA_Y_POS_IX,
[18,25],#	ENEMY_SPRITE_ANIMATION_ID_IX,
[26,28],#	NUMBER_ACTIVE_ENEMY_PROJECTILES_IX,
[29,34],#	ENEMY_PROJECTILES_STATE_IX,
[35,43],#	ENEMY_TOTAL_DAMAGE_TAKEN_IX, #REFRACTORED TO TOTAL SUM OF ANIMATION IDs
[44,44],#	CHARACTER_FACING_RIGHT_IX,
[45,45],#	CHARACTER_IN_CORNER_IX,
[46,46],#	ENEMY_IN_CORNER_IX,
[47,48],#	CHARACTER_NUMBER_JUMPS_REMAINING_IX,
[49,50],#	ENEMY_NUMBER_JUMPS_REMAINING_IX,
[51,51],#	CHARACTER_ON_PLATFORM_IX,
[52,52],#	ENEMY_ON_PLATFORM_IX,
[53,54],#	ENEMY_BLOCKING_STATUS_IX,
[55,56],#	CHARACTER_BLOCKING_STATUS_IX,
[57,57],#	CHARACTER_ON_GROUND_IX,
[58,58],#	ENEMY_ON_GROUND_IX,
[59,60],#	CHARACTER_SPRITE_ANIMATION_STATE_IX,
[61,62],#	ENEMY_SPRITE_ANIMATION_STATE_IX
[63,63]# 	ENEMY_IS_ABOVE_IX
]

#list of max values for each paramter given the number of bits used 
#e.g., delta_x_pos_ix could take 32 values, but only 19 values used.
#flags/state are 1, since this relates to distance computations
#only ints can have distances more than 1
var paramMaxValueUsed = [
STATE_PARAM_MAX_DISTANCE,#	CHARACTER_SPRITE_ANIMATION_ID_IX,
19,#	DELTA_X_POS_IX,  using 20  (max dist 19, since its 0 to 19) bins out of 32
19,#	DELTA_Y_POS_IX,  using 20  (max dist 19, since its 0 to 19) bins out of 32
STATE_PARAM_MAX_DISTANCE,#	ENEMY_SPRITE_ANIMATION_ID_IX,
4,#	NUMBER_ACTIVE_ENEMY_PROJECTILES_IX, only 2 projectile creating moves, and each one at most 2
STATE_PARAM_MAX_DISTANCE,#	ENEMY_PROJECTILES_STATE_IX,
STATE_PARAM_MAX_DISTANCE,#	ENEMY_TOTAL_DAMAGE_TAKEN_IX, although damage is int, we use it as a state to track combos
STATE_PARAM_MAX_DISTANCE,#	CHARACTER_FACING_RIGHT_IX,
STATE_PARAM_MAX_DISTANCE,#	CHARACTER_IN_CORNER_IX,
STATE_PARAM_MAX_DISTANCE,#	ENEMY_IN_CORNER_IX,
2,#	CHARACTER_NUMBER_JUMPS_REMAINING_IX, max num jumps is 2
2,#	ENEMY_NUMBER_JUMPS_REMAINING_IX,max num jumps is 2
STATE_PARAM_MAX_DISTANCE,#	CHARACTER_ON_PLATFORM_IX,
STATE_PARAM_MAX_DISTANCE,#	ENEMY_ON_PLATFORM_IX,
STATE_PARAM_MAX_DISTANCE,#	ENEMY_BLOCKING_STATUS_IX,
STATE_PARAM_MAX_DISTANCE,#	CHARACTER_BLOCKING_STATUS_IX,
STATE_PARAM_MAX_DISTANCE,#	CHARACTER_ON_GROUND_IX,
STATE_PARAM_MAX_DISTANCE,#	ENEMY_ON_GROUND_IX,
STATE_PARAM_MAX_DISTANCE,#	CHARACTER_SPRITE_ANIMATION_STATE_IX,
STATE_PARAM_MAX_DISTANCE,#	ENEMY_SPRITE_ANIMATION_STATE_IX
STATE_PARAM_MAX_DISTANCE#ENEMY_IS_ABOVE_IX
]

#holds the maximum distances from one paramters to another
#foor state params (enenmy state, characreter sprite id) and bools, 1 is most distance, while for positions or counts
#it will just be max observed distance so far
var paramTypeArray = [
STATE_PARAM_TYPE,#	CHARACTER_SPRITE_ANIMATION_ID_IX,
INTEGER_PARAM_TYPE,#	DELTA_X_POS_IX,
INTEGER_PARAM_TYPE,#	DELTA_Y_POS_IX,
STATE_PARAM_TYPE,#	ENEMY_SPRITE_ANIMATION_ID_IX,
INTEGER_PARAM_TYPE,#	NUMBER_ACTIVE_ENEMY_PROJECTILES_IX,
STATE_PARAM_TYPE,#	ENEMY_PROJECTILES_STATE_IX,
STATE_PARAM_TYPE,#	ENEMY_TOTAL_DAMAGE_TAKEN_IX, , although damage is int, we use it as a state to track combos
STATE_PARAM_TYPE,#	CHARACTER_FACING_RIGHT_IX,
STATE_PARAM_TYPE,#	CHARACTER_IN_CORNER_IX,
STATE_PARAM_TYPE,#	ENEMY_IN_CORNER_IX,
INTEGER_PARAM_TYPE,#	CHARACTER_NUMBER_JUMPS_REMAINING_IX,
INTEGER_PARAM_TYPE,#	ENEMY_NUMBER_JUMPS_REMAINING_IX,
STATE_PARAM_TYPE,#	CHARACTER_ON_PLATFORM_IX,
STATE_PARAM_TYPE,#	ENEMY_ON_PLATFORM_IX,
STATE_PARAM_TYPE,#	ENEMY_BLOCKING_STATUS_IX,
STATE_PARAM_TYPE,#	CHARACTER_BLOCKING_STATUS_IX,
STATE_PARAM_TYPE,#	CHARACTER_ON_GROUND_IX,
STATE_PARAM_TYPE,#	ENEMY_ON_GROUND_IX,
STATE_PARAM_TYPE,#	CHARACTER_SPRITE_ANIMATION_STATE_IX,
STATE_PARAM_TYPE,#	ENEMY_SPRITE_ANIMATION_STATE_IX
STATE_PARAM_TYPE #ENEMY_IS_ABOVE_IX
]
var initialized = false
var aiDB=  null
var aiDBFilePath = null # String formaated like "res://data/file.extension"

var sumOfMaxDistValues = 0
func _ready():
	pass
	

func init(_aiDBFilePath=null):
	sumOfMaxDistValues = 0
	initialized = true
	aiDB = null
	aiDBFilePath  = _aiDBFilePath
	
	
	#create an empty ai database object
	aiDB = ghostAIDBResource.new()
		
	
	if aiDBFilePath != null :
		
		
		loadAIDBIntoMemory()
	else:
		aiDB.init()
		#nothing to do, since ai database will be empty
		pass
		
		
	#pre-compute the maximum distance sum
	for maxValue in paramMaxValueUsed:
		
		sumOfMaxDistValues = sumOfMaxDistValues + maxValue


func loadAIDBIntoMemory():
	
	#read the databse bytes into memory
	var aiDBFileBytes = readGhostDBFileBytes(aiDBFilePath)
		
	#ghost db ai database file already exists on disk?
	#that is, bytes were read		
	if aiDBFileBytes != null and aiDBFileBytes.size() > 0:	
		#parse the bytes into DB file, and load the database properties of object
		aiDB.importSerialization(aiDBFileBytes)
	else:
		aiDB.init()
		
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
func saveGhostDBFile():
	
	if (aiDBFilePath == null) or (not initialized):
		print("warning, trying to save ghost db file but handler isn't properly initialized")
		return
	
	print("saving ghost air db file: "+str(aiDBFilePath))
	var aiDBFile = File.new()
	
	#open for write
	aiDBFile.open(aiDBFilePath,File.WRITE)
	
	#convert db to byte array
	var outputBytes = aiDB.serialize()
	
	#write the serialized database to file
	aiDBFile.store_buffer(outputBytes)
	
	aiDBFile.close()
	

#here we give array, since parameter number may change, which will be a pain to deal with
#if hardecoded parameters
#parses parameters into a situation id (64 bit usigned int)
#the parameters assume to be processed, so positions will be discretized, and states (like enemny state)
#are defined, only need bit operations left
func createSituationId(paramArray):
	
	#may want to consider removing all this error checkin for efficenciy
	if paramArray == null:
		print("failed to create situation id, null parameter array")
		return
	
	#make sure its an array	
	if typeof(paramArray) != TYPE_ARRAY:
		print("failed to create situation id, invalid parameter ("+str(paramArray)+"), expected array type but wasn't array")
		return
	
	#make sure expected number params given	
	if paramArray.size() !=NUMBER_OF_SERIALIZED_PARAMETERS:
		print("failed to create situation id, parameter array expected size ("+str(NUMBER_OF_SERIALIZED_PARAMETERS)+") but was ("+str(paramArray.size())+")")
		return
		
	var situationId = int(0)
	
	#endianess matters here, gona need to decide if we shift 
	#the parameter left or right to align its bits with the mask (for non-state params 
	#like characper sprite aniation id)
	
	
	#iterate the parameters and map them into the situation id
	for i in range(paramArray.size()):
		
		
		
		#the value of ith paramter (either a flag or an int)
		var paramValue = paramArray[i]
		
		#problem creating parameter values?
		if paramValue == null:
			return null
		
		#get the from-to indexes for the parameter
		var bitRangePair = paramBitPositionMap[i]
		
		#boolean value? (only needs 1 bit, some indexs are same)
		if bitRangePair[BIT_FROM_IX] == bitRangePair[BIT_TO_IX]:
			
			#insert the flag as a bit in desired position of situation id
			situationId = maskFlagToBitPosition(paramValue,bitRangePair[BIT_FROM_IX],situationId)
		else:
			
			
		
				
			#we don't want to change bits that outstide range
			
			#we need to shift the parameter value to align with the bits
			# e.g: xxx000 would become 0xxx00 after shift by 1 where x are bits of parameter 
			paramValue = paramValue << bitRangePair[BIT_FROM_IX]
			
	
			#now update situation id by maskign, ussing xor
			#eg.  0000yy..yy xor 0xxx00...00 would be 0xxxyy...yy, since the ys are bits areleady filled
			#while all other bits not maske dinto situation id are 0
			situationId = situationId ^ paramValue 
					
	return situationId

#now, we want the 1 bit reflect value of flag
#e.g xxx1x...x for flag = true, and xxx0x..x for flag = false, for bitPos = 3
#where bianry word is the variable to add the desired flag/bit to
func maskFlagToBitPosition(flag,bitPos, binaryWord):
	
	#e.g 00010000, shifitng 1 three times to right
	var mask1 = 1 #bit shift 0 is 1
	if bitPos > 0:
		 mask1 = 1 << bitPos
	
	#bit wise comp: e.g. 11101111
	var mask2 = ~mask1
	
	if flag:
		#want to place a 1 in the target bit position of binaryWord
		return mask1 | binaryWord
	else:
		#want to place a 0 in the target bit position of binaryWord
		return mask2 & binaryWord
	
#computes the distance (a float)of two situations, following the logic from paper
#it doesn't compute similarity , so max distance not required
func computeParameterDistance(param1,param2,paramtype):
	
	var dist = -1
	#at this point we check the paramter type
		#gis parameter a state?
	if paramtype == STATE_PARAM_TYPE:
	
		#state parameters are equal, or their not (binary dsitance value)
		
		#equal states?
		if param1 ==param2:
			dist = 0.0
		else:
			dist = 1.0
	elif paramtype ==INTEGER_PARAM_TYPE:
		dist = abs(param2 - param1) #absolute value since were normalizing distance from 0 to 1 in similarity
	else:
		print("design error, can't compute distance of situation ids, since unknow parameter type: "+str(paramtype))
		
			
	return dist


#computes the similarity score of two situation ids based on distance measures
#value returned is between	0 and 1. 0 being completly diffrent, and 1 being 100% identical		
func computeSituationSimilarity(situationId1,situationId2):
#,#		
#,#		
	if situationId1 == null or situationId2==null:
		return null
	
	if not initialized:
		print("cannot compute similarity of situations, not initialized")
		return null
	var distSum = 0.0
	
#iterate the parameters and map them into the situation id
	for i in range(paramBitPositionMap.size()):
		
		#situation parameters values
		var s1ParamValue = 0
		var s2ParamValue = 0
		
		#get the from-to indexes for the parameter
		var bitRangePair = paramBitPositionMap[i]
		
		
		#boolean value? (only needs 1 bit, some indexs are same)
		if bitRangePair[BIT_FROM_IX] == bitRangePair[BIT_TO_IX]:
			
			#insert a bit into 0000 word where the flag is stored in situation id
			#example: 00000 -> 000100 .
			#want to do this to use bit-wise-and to determine the flag's value
			# 000x00 & 000100 give you flag value
			var mask = maskFlagToBitPosition(true,bitRangePair[BIT_FROM_IX],0)
			
			#extract flag value (non-zero int means flag is true)
			s1ParamValue = (mask & situationId1) > 0
			s2ParamValue = (mask & situationId2) > 0
		else:
			
			#create mask to extract the parameter from situation id
			var mask = 0
			
			var paramBitLength = bitRangePair[BIT_TO_IX] - bitRangePair[BIT_FROM_IX]  + 1
			
			#add number of 1 bits equal to parameter's length
			for j in range(paramBitLength):
				mask = mask | (1 << j)
				
			#now offset the mask to match bit range of parameter in situatin id
			mask = mask << bitRangePair[BIT_FROM_IX]
			
			#extrate the parameters values, by masking 000111000 & xxxyyyxxx = 000yyy000,, then shifting 000yyy000 = yyy000
			s1ParamValue = (mask & situationId1) >> bitRangePair[BIT_FROM_IX]
			s2ParamValue = (mask & situationId2) >> bitRangePair[BIT_FROM_IX]
		
		#compute distnace of the parameters
		var dist = computeParameterDistance(s1ParamValue,s2ParamValue, paramTypeArray[i])
		
		#sume the distances
		distSum = distSum + dist
		
	#compute and return simularity value (0 is 100% similar)	
	return 1 - (distSum/sumOfMaxDistValues)
		
	
	
#estimates the likelyhood a command be used given a situation
#usually a situation that occured before will have a list of commands
#that have been used, but when a situation has never been encountered before,
#we must consider all passed situations that have used the command,
#then comapare those previous situation to target situation
#and we assume the siaution most similar reflects likely hood of using command

#returns 2 element array, 0th element is situationid that is most similar
#and elmenet at index 1 is its similarity

func findMostSimilarSituation(cmd,currSituationId):
	
	#[situationId,similarity]
	#var res = [null,-1]

	var bestSituationId = null
	var bestSimilarity = -1
	var candidateSituations = aiDB.getSituationsCommandUsedIn(cmd)
	
	#iterate all situations
	for sid in candidateSituations:
		
		var sim = computeSituationSimilarity(sid,currSituationId)
		
		if sim == null:
			continue
			
		#found better similarity, more similar situation?
		if sim > bestSimilarity:
			bestSituationId=sid
			bestSimilarity=sim
	
	findMostSimilarSituationResultBuffer[MOST_SIMILAR_SITUATION_ID_IX] = bestSituationId
	findMostSimilarSituationResultBuffer[MOST_SIMILAR_SITUATION_SIM_IX] = bestSimilarity
	return findMostSimilarSituationResultBuffer