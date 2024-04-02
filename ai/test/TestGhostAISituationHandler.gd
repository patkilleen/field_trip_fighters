extends "res://ai/GhostAISituationHandler.gd"

func _ready():
	pass # Replace with function body.


func test_init():
	
	var dbFilePath = "user://test.tmp"
	init(dbFilePath)
	
	assertEquals(true,initialized,"test_init")
	
	var expectedMaxSum = 61
	
	assertEquals(expectedMaxSum,sumOfMaxDistValues,"test_init")
	
	pass

func test_saveReadGhostDBFile():
	var dbFilePath = "user://test.tmp"
	
	#remove file first 
	
	var file = File.new()
	var exists = file.file_exists(dbFilePath)
	
	if exists:
		var dir = Directory.new()
		dir.remove(dbFilePath)

	init(dbFilePath)
	assertEquals(null,readGhostDBFileBytes(null),"test_saveReadGhostDBFile")
	assertEquals(null,readGhostDBFileBytes(dbFilePath),"test_saveReadGhostDBFile")
	
	#save empty ai db
	saveGhostDBFile()
	
	var bytes = readGhostDBFileBytes(dbFilePath)
	
	var aidb2 = ghostAIDBResource.new()
	
	aidb2.importSerialization(bytes)
	
	assertEquals(aiDB.priorSituationMap.hash(),aidb2.priorSituationMap.hash(),"test_saveReadGhostDBFile")
	assertEquals(aiDB.demoDataMap.hash(),aidb2.demoDataMap.hash(),"test_saveReadGhostDBFile")
	assertEquals(aiDB.spriteFrameActivationFreqMap.hash(),aidb2.spriteFrameActivationFreqMap.hash(),"test_saveReadGhostDBFile")
	assertEquals(aiDB.spriteFrameAbilityCancelFreqMap.hash(),aidb2.spriteFrameAbilityCancelFreqMap.hash(),"test_saveReadGhostDBFile")
	assertArrayEquals(aiDB.techFrequencies,aidb2.techFrequencies,"test_saveReadGhostDBFile")
	
	populateTestAIDBValues()
	
	#save empty ai db
	saveGhostDBFile()
	
	bytes = readGhostDBFileBytes(dbFilePath)
	
	aidb2 = ghostAIDBResource.new()
	
	aidb2.importSerialization(bytes)
	
	assertEquals(aiDB.priorSituationMap.hash(),aidb2.priorSituationMap.hash(),"test_saveReadGhostDBFile")
	assertEquals(aiDB.demoDataMap.hash(),aidb2.demoDataMap.hash(),"test_saveReadGhostDBFile")
	assertEquals(aiDB.spriteFrameActivationFreqMap.hash(),aidb2.spriteFrameActivationFreqMap.hash(),"test_saveReadGhostDBFile")
	assertEquals(aiDB.spriteFrameAbilityCancelFreqMap.hash(),aidb2.spriteFrameAbilityCancelFreqMap.hash(),"test_saveReadGhostDBFile")
	assertArrayEquals(aiDB.techFrequencies,aidb2.techFrequencies,"test_saveReadGhostDBFile")
	
	
	pass

func populateTestAIDBValues():
	
	aiDB.init()
	
	aiDB.logCommandSituationPair(0, 0)
	aiDB.logCommandSituationPair(0, 0)
	aiDB.logCommandSituationPair(0, 0)
	
	aiDB.logCommandSituationPair(1, 0)
	aiDB.logCommandSituationPair(1, 0)
	
	aiDB.logCommandSituationPair(2, 0)
	
	
	aiDB.logCommandSituationPair(0, 1)
	
	aiDB.logCommandSituationPair(1, 1)
	aiDB.logCommandSituationPair(1, 1)
	
	aiDB.logCommandSituationPair(2, 1)
	aiDB.logCommandSituationPair(2, 1)
	aiDB.logCommandSituationPair(2, 1)
	
	aiDB.increaseFloorCollisionFrequency()
	aiDB.increaseFloorCollisionFrequency()
	aiDB.increaseFloorCollisionFrequency()
	
	aiDB.increaseCeilingCollisionFrequency()
	aiDB.increaseCeilingCollisionFrequency()
	
	aiDB.increaseTechFrequency(0)
	aiDB.increaseTechFrequency(0)
	aiDB.increaseTechFrequency(1)
	aiDB.increaseTechFrequency(2)
	aiDB.increaseTechFrequency(2)
	aiDB.increaseTechFrequency(2)
	aiDB.increaseTechFrequency(3)
	
	aiDB.increaseWallCollisionFrequency()
	aiDB.increaseWallCollisionFrequency()
	
	aiDB.incrementSpriteFrameFrequency(0)
	aiDB.incrementSpriteFrameFrequency(0)
	aiDB.incrementSpriteFrameFrequency(0)
	aiDB.incrementSpriteFrameFrequency(1)
	aiDB.incrementSpriteFrameFrequency(1)
	aiDB.incrementSpriteFrameFrequency(2)
	
	aiDB.incrementAbilityCancelFrequency(0)
	aiDB.incrementAbilityCancelFrequency(2)
	
	
	
func test_createSituationId():
	#
#	[0,7],#	CHARACTER_SPRITE_ANIMATION_ID_IX,
#[8,12],#	DELTA_X_POS_IX,
#[13,18],#	DELTA_Y_POS_IX,
#[19,26],#	ENEMY_SPRITE_ANIMATION_ID_IX,
#[27,29],#	NUMBER_ACTIVE_ENEMY_PROJECTILES_IX,
#[30,35],#	ENEMY_PROJECTILES_STATE_IX,
#[36,44],#	ENEMY_TOTAL_DAMAGE_TAKEN_IX,
#[45,45],#	CHARACTER_FACING_RIGHT_IX,
#[46,46],#	CHARACTER_IN_CORNER_IX,
#[47,47],#	ENEMY_IN_CORNER_IX,
#[48,49],#	CHARACTER_NUMBER_JUMPS_REMAINING_IX,
#[50,51],#	ENEMY_NUMBER_JUMPS_REMAINING_IX,
#[52,52],#	CHARACTER_ON_PLATFORM_IX,
#[53,53],#	ENEMY_ON_PLATFORM_IX,
#[54,55],#	ENEMY_BLOCKING_STATUS_IX,
#[56,57],#	CHARACTER_BLOCKING_STATUS_IX,
#[58,58],#	CHARACTER_ON_GROUND_IX,
#[59,59],#	ENEMY_ON_GROUND_IX,
#[60,61],#	CHARACTER_SPRITE_ANIMATION_STATE_IX,
#[62,63],#	ENEMY_SPRITE_ANIMATION_STATE_IX
	
	#test_createSituationId_helper(["00000000","00000","00000","00000000","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["00000000","00000","00000","01000000","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10000000","00000","00000","00000000","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10000001","00000","00000","00000000","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","00000","00000","00000000","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10000","00000","00000000","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10001","00000","00000000","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","00000","00000000","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10000","00000000","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","00001","00000000","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","00000000","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["00010000","10101","10001","00000000","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010101","11001","01100","00100000","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","00100001","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","100","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","101","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","101","100000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","101","100001","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","101","100101","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","101","100101","000000001","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","101","100101","000010001","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","101","100101","010010001","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","101","100101","110010001","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","101","100101","110010001","1","0","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","101","100101","110010001","0","1","0","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","101","100101","110010001","0","1","1","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","101","100101","110010001","0","0","1","00","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","101","100101","110010001","1","0","1","01","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["10010001","10101","10001","10100001","101","100101","110010001","1","0","1","10","00","0","0","00","00","0","0","00","00"])
	test_createSituationId_helper(["11010001","11101","10001","10100101","001","110101","110010001","1","0","1","01","10","0","1","01","10","0","1","01","10"])
	test_createSituationId_helper(["01010001","01100","10001","10100001","001","110111","110010101","0","1","1","00","11","1","0","11","01","1","0","10","11"])
	
	
	pass

func test_createSituationId_helper(binParamsArray):
	var expectedBinString = ""
	#iterate the param array in reverse order to build the expected binary string
	var i = binParamsArray.size()-1
	while i >=0:
		
		expectedBinString = expectedBinString + binParamsArray[i]
		i = i - 1
		
	#convert the binary string array into decimal form
	for i in range(binParamsArray.size()):
		binParamsArray[i] = bin2dec(binParamsArray[i])
		
	assertEquals(bin2dec(expectedBinString),createSituationId(binParamsArray),"test_createSituationId")
	
func binStringArrayToDec(binParamsArray):
	var expectedBinString = ""
	#iterate the param array in reverse order to build the expected binary string
	var i = binParamsArray.size()-1
	while i >=0:
		
		expectedBinString = expectedBinString + binParamsArray[i]
		i = i - 1
	return bin2dec(expectedBinString)
	
func test_maskFlagToBitPosition():
	# maskFlagToBitPosition(flag,bitPos, binaryWord):
	assertEquals(0,maskFlagToBitPosition(false,0,0),"test_maskFlagToBitPosition")
	assertEquals(1,maskFlagToBitPosition(true,0,0),"test_maskFlagToBitPosition")
	assertEquals(2,maskFlagToBitPosition(true,1,0),"test_maskFlagToBitPosition")
	assertEquals(0,maskFlagToBitPosition(false,1,0),"test_maskFlagToBitPosition")
	assertEquals(1,maskFlagToBitPosition(false,1,1),"test_maskFlagToBitPosition")
	assertEquals(0,maskFlagToBitPosition(false,1,2),"test_maskFlagToBitPosition")
	assertEquals(1,maskFlagToBitPosition(false,1,3),"test_maskFlagToBitPosition")
	assertEquals(2,maskFlagToBitPosition(false,0,3),"test_maskFlagToBitPosition")
	assertEquals(4,maskFlagToBitPosition(true,2,0),"test_maskFlagToBitPosition")
	assertEquals(7,maskFlagToBitPosition(true,2,3),"test_maskFlagToBitPosition")
	assertEquals(5,maskFlagToBitPosition(false,1,7),"test_maskFlagToBitPosition")
	pass

func test_computeParameterDistance():
	
	 #computeParameterDistance(param1,param2,STATE_PARAM_TYPE):
	#computeParameterDistance(param1,param2,INTEGER_PARAM_TYPE):
	assertEquals(1,computeParameterDistance(false,true,STATE_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(1,computeParameterDistance(true,false,STATE_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(0,computeParameterDistance(true,true,STATE_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(0,computeParameterDistance(false,false,STATE_PARAM_TYPE),"test_computeParameterDistance")
	
	assertEquals(0,computeParameterDistance(0,0,STATE_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(1,computeParameterDistance(0,1,STATE_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(1,computeParameterDistance(0,2,STATE_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(1,computeParameterDistance(1,0,STATE_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(0,computeParameterDistance(1,1,STATE_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(1,computeParameterDistance(1,2,STATE_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(1,computeParameterDistance(2,0,STATE_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(1,computeParameterDistance(2,1,STATE_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(0,computeParameterDistance(2,2,STATE_PARAM_TYPE),"test_computeParameterDistance")
	
	assertEquals(0,computeParameterDistance(0,0,INTEGER_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(1,computeParameterDistance(1,0,INTEGER_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(1,computeParameterDistance(0,1,INTEGER_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(2,computeParameterDistance(2,0,INTEGER_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(2,computeParameterDistance(0,2,INTEGER_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(0,computeParameterDistance(1,1,INTEGER_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(5,computeParameterDistance(10,5,INTEGER_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(0,computeParameterDistance(10,10,INTEGER_PARAM_TYPE),"test_computeParameterDistance")
	assertEquals(22,computeParameterDistance(32,10,INTEGER_PARAM_TYPE),"test_computeParameterDistance")
	

func test_computeSituationSimilarity():
	init(null)
	#[19,26],#	ENEMY_SPRITE_ANIMATION_ID_IX,
#[27,29],#	NUMBER_ACTIVE_ENEMY_PROJECTILES_IX,
#[30,35],#	ENEMY_PROJECTILES_STATE_IX,
#[36,44],#	ENEMY_TOTAL_DAMAGE_TAKEN_IX,
#[45,45],#	CHARACTER_FACING_RIGHT_IX,
#[46,46],#	CHARACTER_IN_CORNER_IX,
#[47,47],#	ENEMY_IN_CORNER_IX,
#[48,49],#	CHARACTER_NUMBER_JUMPS_REMAINING_IX,
#[50,51],#	ENEMY_NUMBER_JUMPS_REMAINING_IX,
#[52,52],#	CHARACTER_ON_PLATFORM_IX,
#[53,53],#	ENEMY_ON_PLATFORM_IX,
#[54,55],#	ENEMY_BLOCKING_STATUS_IX,
#[56,57],#	CHARACTER_BLOCKING_STATUS_IX,
#[58,58],#	CHARACTER_ON_GROUND_IX,
#[59,59],#	ENEMY_ON_GROUND_IX,
#[60,61],#	CHARACTER_SPRITE_ANIMATION_STATE_IX,
#[62,63],#	ENEMY_SPRITE_ANIMATION_STATE_IX
	var situationId1 = binStringArrayToDec(["10010001","01101","01001","10100001","011","100100","001010100","1","1","0","01","10","0","0","01","00","1","1","10","00"])
	var situationId2 = binStringArrayToDec(["10010001","01101","01001","10100001","011","100100","001010100","1","1","0","01","10","0","0","01","00","1","1","10","00"])
	var situationId3 = binStringArrayToDec(["10000001","01101","01000","10100001","001","100101","001010100","1","0","0","01","10","0","0","11","00","1","1","11","00"])
	var situationId4 = binStringArrayToDec(["00000000","00000","00000","00000000","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	
	var sim12 =	computeSituationSimilarity(situationId1,situationId2)
	var sim13 =	computeSituationSimilarity(situationId1,situationId3)
	var sim14 =	computeSituationSimilarity(situationId1,situationId4)
	
	assertEquals(1,sim12,"test_computeSituationSimilarity")
	assertEquals(true,sim12 > sim13,"test_computeSituationSimilarity")
	assertEquals(true,sim12 > sim14,"test_computeSituationSimilarity")
	assertEquals(true,sim13 > sim14,"test_computeSituationSimilarity")
	pass	
	
func test_findMostSimilarSituation():
	init()
	aiDB.init()
	
	#situations defined in order of similarity tos ituation id 1
	var situationId1 = binStringArrayToDec(["10010001","01101","01001","10100001","011","100100","001010100","1","1","0","01","10","0","0","01","00","1","1","10","00"])
	var situationId2 = binStringArrayToDec(["10010001","01101","01001","10100001","011","100100","001010100","1","0","0","01","10","0","0","01","00","1","1","10","00"])
	var situationId3 = binStringArrayToDec(["10010001","01101","01001","10100001","011","100100","001010100","1","0","0","01","10","0","0","01","00","0","1","10","00"])
	var situationId4 = binStringArrayToDec(["10000001","01101","01000","10100001","001","100101","001010100","1","0","0","01","10","0","0","11","00","1","1","11","00"])
	var situationId5 = binStringArrayToDec(["01000000","00000","00000","00000100","000","000000","000000000","0","0","0","00","00","0","0","00","00","0","0","00","00"])
	
	
	
	aiDB.logCommandSituationPair(0, situationId5)
	aiDB.logCommandSituationPair(0, situationId2)
	aiDB.logCommandSituationPair(0, situationId4)
	
	aiDB.logCommandSituationPair(1, situationId3)
	aiDB.logCommandSituationPair(1, situationId5)
	aiDB.logCommandSituationPair(1, situationId4)	
	
	
	assertEquals(situationId2,findMostSimilarSituation(0,situationId1)[0],"test_findMostSimilarSituation")
	assertEquals(situationId3,findMostSimilarSituation(1,situationId1)[0],"test_findMostSimilarSituation")
	pass

func testAll():
	test_findMostSimilarSituation()	
	test_computeSituationSimilarity()
	test_computeParameterDistance()
	test_maskFlagToBitPosition()
	test_createSituationId()
	test_saveReadGhostDBFile()
	test_init()
func assertMapEquals(a1,a2,msg):
	
	if (a1 == null and a2 !=null) or (a2 == null and a1 !=null) or (typeof(a1)!= TYPE_DICTIONARY) or (typeof(a2)!= TYPE_DICTIONARY):
		print("Test failed: expected ("+str(a1)+") but was ("+str(a2)+"). "+ msg)
		return

	if a1.size() != a2.size():
		print("Test failed: expected size of map ("+str(a1.size())+") but was ("+str(a2.size())+"). "+ msg)
		return
	
	var keys1 = a1.keys()
	var keys2 = a2.keys()
	
	assertArrayAlmostEquals(keys1,keys2,msg)
	
	for k in keys1:
		assertEquals(a1[k],a2[k], msg)



func assertArrayEquals(a1,a2,msg):
	
	if (a1 == null and a2 !=null) or (a2 == null and a1 !=null) or (typeof(a1)!= TYPE_ARRAY) or (typeof(a2)!= TYPE_ARRAY):
		print("Test failed: expected ("+str(a1)+") but was ("+str(a2)+"). "+ msg)
		return

	if a1.size() != a2.size():
		print("Test failed: expected size of array ("+str(a1.size())+") but was ("+str(a2.size())+"). "+ msg)
		return
	
	for i in range(a1.size()):
		assertEquals(a1[i],a2[i], msg)

#arrays are the same, but the elements order may differ (e.g., [0,1,2] = [0,2,1] but [0,1,2] != [1,2,3]
func assertArrayAlmostEquals(a1,a2,msg):
	
	if (a1 == null and a2 !=null) or (a2 == null and a1 !=null) or (typeof(a1)!= TYPE_ARRAY) or (typeof(a2)!= TYPE_ARRAY):
		print("Test failed: expected ("+str(a1)+") but was ("+str(a2)+"). "+ msg)
		return

	if a1.size() != a2.size():
		print("Test failed: expected array size of ("+str(a1.size())+") but was ("+str(a2.size())+"). "+ msg)
		return
	
	for i in range(a1.size()):
		
		var foundFlag = false
		#contains?
		for j in range(a2.size()):
			foundFlag = foundFlag or (a1[i] == a2[j])
		
		assertEquals(true,foundFlag, msg)

		
func assertEquals(v1,v2, msg):
	if v1 != v2:
		print("Test failed: expected ("+str(v1)+") but was ("+str(v2)+"). "+ msg)
		pass




var ASCII_1 = "1".to_ascii()[0]
var ASCII_0 = "0".to_ascii()[0]

# Takes in a binary value (int) and returns the decimal value (int)
func bin2dec(var binaryString):
	var decimal_value = 0
	
	#convert the binarystring to a byte array
	var bytes = binaryString.to_ascii()
	
	var pow2 = 1
	
	#parse in reverse (001 = 1 and 100 = 4)
	var i = bytes.size() -1
	
	while i>=0:
		var b = bytes[i]
		if b == ASCII_1:
			decimal_value = decimal_value + pow2
		
		#increase the power of 2			
		pow2 = pow2 << 1
		i = i -1
	
	return  decimal_value  
# var decimal_value = 0
    #var count = 0
   #var temp
   # while(binary_value != 0):
    #    temp = binary_value % 10
     #   binary_value /= 10
      #  decimal_value += temp * pow(2, count)
       # count += 1
    #return decimal_value