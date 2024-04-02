extends "res://ai/GhostAIDB.gd"



func test_getCommandFrequency():
	init()
	
	assertEquals(0,getCommandFrequency(0,0),"test_getCommandFrequency")
	assertEquals(0,getCommandFrequency(1,0),"test_getCommandFrequency")
	assertEquals(0,getCommandFrequency(0,1),"test_getCommandFrequency")
	assertEquals(0,getCommandFrequency(1,1),"test_getCommandFrequency")
	
	
	logCommandSituationPair(0, 0)
	
	assertEquals(1,getCommandFrequency(0,0),"test_getCommandFrequency")
	assertEquals(0,getCommandFrequency(1,0),"test_getCommandFrequency")
	assertEquals(0,getCommandFrequency(0,1),"test_getCommandFrequency")
	assertEquals(0,getCommandFrequency(1,1),"test_getCommandFrequency")
	
	logCommandSituationPair(0, 0)
	
	assertEquals(2,getCommandFrequency(0,0),"test_getCommandFrequency")
	assertEquals(0,getCommandFrequency(1,0),"test_getCommandFrequency")
	assertEquals(0,getCommandFrequency(0,1),"test_getCommandFrequency")
	assertEquals(0,getCommandFrequency(1,1),"test_getCommandFrequency")
	
	logCommandSituationPair(1, 0)
	
	assertEquals(2,getCommandFrequency(0,0),"test_getCommandFrequency")
	assertEquals(1,getCommandFrequency(1,0),"test_getCommandFrequency")
	assertEquals(0,getCommandFrequency(0,1),"test_getCommandFrequency")
	assertEquals(0,getCommandFrequency(1,1),"test_getCommandFrequency")
	
	logCommandSituationPair(1, 0)
	
	assertEquals(2,getCommandFrequency(0,0),"test_getCommandFrequency")
	assertEquals(2,getCommandFrequency(1,0),"test_getCommandFrequency")
	assertEquals(0,getCommandFrequency(0,1),"test_getCommandFrequency")
	assertEquals(0,getCommandFrequency(1,1),"test_getCommandFrequency")

	logCommandSituationPair(0, 1)
	logCommandSituationPair(1, 1)
	
	assertEquals(2,getCommandFrequency(0,0),"test_getCommandFrequency")
	assertEquals(2,getCommandFrequency(1,0),"test_getCommandFrequency")
	assertEquals(1,getCommandFrequency(0,1),"test_getCommandFrequency")
	assertEquals(1,getCommandFrequency(1,1),"test_getCommandFrequency")
	
	logCommandSituationPair(0, 1)
	logCommandSituationPair(1, 1)
	
	assertEquals(2,getCommandFrequency(0,0),"test_getCommandFrequency")
	assertEquals(2,getCommandFrequency(1,0),"test_getCommandFrequency")
	assertEquals(2,getCommandFrequency(0,1),"test_getCommandFrequency")
	assertEquals(2,getCommandFrequency(1,1),"test_getCommandFrequency")
		
func test_getListOfCommands():
	
	init()
	
	assertArrayAlmostEquals([],getListOfCommands(0),"test_getListOfCommands")
	assertArrayAlmostEquals([],getListOfCommands(1),"test_getListOfCommands")
	
	logCommandSituationPair(0, 0)
	
	assertArrayAlmostEquals([0],getListOfCommands(0),"test_getListOfCommands")
	assertArrayAlmostEquals([],getListOfCommands(1),"test_getListOfCommands")
	
	logCommandSituationPair(1, 0)

	assertArrayAlmostEquals([0,1],getListOfCommands(0),"test_getListOfCommands")
	assertArrayAlmostEquals([],getListOfCommands(1),"test_getListOfCommands")
	
	logCommandSituationPair(2, 0)

	assertArrayAlmostEquals([0,1,2],getListOfCommands(0),"test_getListOfCommands")
	assertArrayAlmostEquals([],getListOfCommands(1),"test_getListOfCommands")
	
	logCommandSituationPair(2, 1)

	assertArrayAlmostEquals([0,1,2],getListOfCommands(0),"test_getListOfCommands")
	assertArrayAlmostEquals([2],getListOfCommands(1),"test_getListOfCommands")
	
	logCommandSituationPair(3, 1)

	assertArrayAlmostEquals([0,1,2],getListOfCommands(0),"test_getListOfCommands")
	assertArrayAlmostEquals([2,3],getListOfCommands(1),"test_getListOfCommands")
	
	logCommandSituationPair(4, 1)

	assertArrayAlmostEquals([0,1,2],getListOfCommands(0),"test_getListOfCommands")
	assertArrayAlmostEquals([2,3,4],getListOfCommands(1),"test_getListOfCommands")
	

func test_getSituationCommandMap():
	init()
	
	assertMapEquals({},getSituationCommandMap(0),"test_getSituationCommandMap")
	assertMapEquals({},getSituationCommandMap(1),"test_getSituationCommandMap")
	
	logCommandSituationPair(0, 0)
	
	assertMapEquals({0:1},getSituationCommandMap(0),"test_getSituationCommandMap")
	assertMapEquals({},getSituationCommandMap(1),"test_getSituationCommandMap")
	
	logCommandSituationPair(1, 0)

	assertMapEquals({0:1,1:1},getSituationCommandMap(0),"test_getSituationCommandMap")
	assertMapEquals({},getSituationCommandMap(1),"test_getSituationCommandMap")
	
	logCommandSituationPair(2, 0)

	assertMapEquals({0:1,1:1,2:1},getSituationCommandMap(0),"test_getSituationCommandMap")
	assertMapEquals({},getSituationCommandMap(1),"test_getSituationCommandMap")
	
	logCommandSituationPair(2, 1)

	assertMapEquals({0:1,1:1,2:1},getSituationCommandMap(0),"test_getSituationCommandMap")
	assertMapEquals({2:1},getSituationCommandMap(1),"test_getSituationCommandMap")
	
	logCommandSituationPair(3, 1)

	assertMapEquals({0:1,1:1,2:1},getSituationCommandMap(0),"test_getSituationCommandMap")
	assertMapEquals({2:1,3:1},getSituationCommandMap(1),"test_getSituationCommandMap")
	
	logCommandSituationPair(4, 1)

	assertMapEquals({0:1,1:1,2:1},getSituationCommandMap(0),"test_getSituationCommandMap")
	assertMapEquals({2:1,3:1,4:1},getSituationCommandMap(1),"test_getSituationCommandMap")
	

	logCommandSituationPair(4, 1)
	logCommandSituationPair(4, 1)

	assertMapEquals({0:1,1:1,2:1},getSituationCommandMap(0),"test_getSituationCommandMap")
	assertMapEquals({2:1,3:1,4:3},getSituationCommandMap(1),"test_getSituationCommandMap")
	
	logCommandSituationPair(3, 1)
	logCommandSituationPair(2, 1)

	assertMapEquals({0:1,1:1,2:1},getSituationCommandMap(0),"test_getSituationCommandMap")
	assertMapEquals({2:2,3:2,4:3},getSituationCommandMap(1),"test_getSituationCommandMap")
	
	logCommandSituationPair(1, 0)
	logCommandSituationPair(1, 0)

	assertMapEquals({0:1,1:3,2:1},getSituationCommandMap(0),"test_getSituationCommandMap")
	assertMapEquals({2:2,3:2,4:3},getSituationCommandMap(1),"test_getSituationCommandMap")
	
	logCommandSituationPair(2, 0)
	logCommandSituationPair(0, 0)

	assertMapEquals({0:2,1:3,2:2},getSituationCommandMap(0),"test_getSituationCommandMap")
	assertMapEquals({2:2,3:2,4:3},getSituationCommandMap(1),"test_getSituationCommandMap")
	
func test_getSituationFrequency():
	
	init()
	
	assertEquals(0,getSituationFrequency(0),"test_getSituationFrequency")
	assertEquals(0,getSituationFrequency(1),"test_getSituationFrequency")
	
	logCommandSituationPair(0, 0)
	
	assertEquals(1,getSituationFrequency(0),"test_getSituationFrequency")
	assertEquals(0,getSituationFrequency(1),"test_getSituationFrequency")
	
	logCommandSituationPair(0, 0)
	
	assertEquals(2,getSituationFrequency(0),"test_getSituationFrequency")
	assertEquals(0,getSituationFrequency(1),"test_getSituationFrequency")
	
	logCommandSituationPair(0, 0)
	
	assertEquals(3,getSituationFrequency(0),"test_getSituationFrequency")
	assertEquals(0,getSituationFrequency(1),"test_getSituationFrequency")
	
	logCommandSituationPair(0, 1)
	
	assertEquals(3,getSituationFrequency(0),"test_getSituationFrequency")
	assertEquals(1,getSituationFrequency(1),"test_getSituationFrequency")

	logCommandSituationPair(0, 1)
	
	assertEquals(3,getSituationFrequency(0),"test_getSituationFrequency")
	assertEquals(2,getSituationFrequency(1),"test_getSituationFrequency")	
	
	logCommandSituationPair(0, 1)
	
	assertEquals(3,getSituationFrequency(0),"test_getSituationFrequency")
	assertEquals(3,getSituationFrequency(1),"test_getSituationFrequency")
	
	logCommandSituationPair(1, 1)
	logCommandSituationPair(2, 1)
	logCommandSituationPair(3, 1)
	
	assertEquals(3,getSituationFrequency(0),"test_getSituationFrequency")
	assertEquals(6,getSituationFrequency(1),"test_getSituationFrequency")
	
	
	logCommandSituationPair(6, 0)
	logCommandSituationPair(7, 0)
	logCommandSituationPair(8, 0)
	
	assertEquals(6,getSituationFrequency(0),"test_getSituationFrequency")
	assertEquals(6,getSituationFrequency(1),"test_getSituationFrequency")
func test_hasSituationId():
	init()
	
	assertEquals(false,hasSituationId(0),"test_hasSituationId")
	assertEquals(false,hasSituationId(1),"test_hasSituationId")
	assertEquals(false,hasSituationId(2),"test_hasSituationId")
	
	logCommandSituationPair(0, 0)
	
	assertEquals(true,hasSituationId(0),"test_hasSituationId")
	assertEquals(false,hasSituationId(1),"test_hasSituationId")
	assertEquals(false,hasSituationId(2),"test_hasSituationId")
	
	logCommandSituationPair(1, 0)
	
	assertEquals(true,hasSituationId(0),"test_hasSituationId")
	assertEquals(false,hasSituationId(1),"test_hasSituationId")
	assertEquals(false,hasSituationId(2),"test_hasSituationId")


	logCommandSituationPair(1, 1)
	
	assertEquals(true,hasSituationId(0),"test_hasSituationId")
	assertEquals(true,hasSituationId(1),"test_hasSituationId")
	assertEquals(false,hasSituationId(2),"test_hasSituationId")

	logCommandSituationPair(2, 1)
	
	assertEquals(true,hasSituationId(0),"test_hasSituationId")
	assertEquals(true,hasSituationId(1),"test_hasSituationId")
	assertEquals(false,hasSituationId(2),"test_hasSituationId")
	
	
	logCommandSituationPair(2, 2)
	
	assertEquals(true,hasSituationId(0),"test_hasSituationId")
	assertEquals(true,hasSituationId(1),"test_hasSituationId")
	assertEquals(true,hasSituationId(2),"test_hasSituationId")
	
	logCommandSituationPair(2, 2)
	
	assertEquals(true,hasSituationId(0),"test_hasSituationId")
	assertEquals(true,hasSituationId(1),"test_hasSituationId")
	assertEquals(true,hasSituationId(2),"test_hasSituationId")
	
func test_getSituationsCommandUsedIn():
	
	init()
	
	assertArrayAlmostEquals([],getSituationsCommandUsedIn(0),"test_getSituationsCommandUsedIn")
	assertArrayAlmostEquals([],getSituationsCommandUsedIn(1),"test_getSituationsCommandUsedIn")
	
	populateSituationMap(0, 0)
	
	assertArrayAlmostEquals([0],getSituationsCommandUsedIn(0),"test_getSituationsCommandUsedIn")
	assertArrayAlmostEquals([],getSituationsCommandUsedIn(1),"test_getSituationsCommandUsedIn")
	
	populateSituationMap(0,1)

	assertArrayAlmostEquals([0,1],getSituationsCommandUsedIn(0),"test_getSituationsCommandUsedIn")
	assertArrayAlmostEquals([],getSituationsCommandUsedIn(1),"test_getSituationsCommandUsedIn")
	
	populateSituationMap(0,2)

	assertArrayAlmostEquals([0,1,2],getSituationsCommandUsedIn(0),"test_getSituationsCommandUsedIn")
	assertArrayAlmostEquals([],getSituationsCommandUsedIn(1),"test_getSituationsCommandUsedIn")
	
	populateSituationMap(1,2)

	assertArrayAlmostEquals([0,1,2],getSituationsCommandUsedIn(0),"test_getSituationsCommandUsedIn")
	assertArrayAlmostEquals([2],getSituationsCommandUsedIn(1),"test_getSituationsCommandUsedIn")
	
	populateSituationMap(1,3)

	assertArrayAlmostEquals([0,1,2],getSituationsCommandUsedIn(0),"test_getSituationsCommandUsedIn")
	assertArrayAlmostEquals([2,3],getSituationsCommandUsedIn(1),"test_getSituationsCommandUsedIn")
	
	populateSituationMap(1,4)

	assertArrayAlmostEquals([0,1,2],getSituationsCommandUsedIn(0),"test_getSituationsCommandUsedIn")
	assertArrayAlmostEquals([2,3,4],getSituationsCommandUsedIn(1),"test_getSituationsCommandUsedIn")
func test_hasCommandBeenUsedInSituation():
	init()
	
	assertEquals(false,hasCommandBeenUsedInSituation(0, 0),"test_hasCommandBeenUsedInSituation")
	assertEquals(false,hasCommandBeenUsedInSituation(0, 1),"test_hasCommandBeenUsedInSituation")
	assertEquals(false,hasCommandBeenUsedInSituation(1, 0),"test_hasCommandBeenUsedInSituation")
	assertEquals(false,hasCommandBeenUsedInSituation(1, 1),"test_hasCommandBeenUsedInSituation")
	
	populateSituationMap(0, 0)
	
	assertEquals(true,hasCommandBeenUsedInSituation(0, 0),"test_hasCommandBeenUsedInSituation")
	assertEquals(false,hasCommandBeenUsedInSituation(0, 1),"test_hasCommandBeenUsedInSituation")
	assertEquals(false,hasCommandBeenUsedInSituation(1, 0),"test_hasCommandBeenUsedInSituation")
	assertEquals(false,hasCommandBeenUsedInSituation(1, 1),"test_hasCommandBeenUsedInSituation")
	
	populateSituationMap(0, 0)
	populateSituationMap(0, 1)
	assertEquals(true,hasCommandBeenUsedInSituation(0, 0),"test_hasCommandBeenUsedInSituation")
	assertEquals(true,hasCommandBeenUsedInSituation(0, 1),"test_hasCommandBeenUsedInSituation")
	assertEquals(false,hasCommandBeenUsedInSituation(1, 0),"test_hasCommandBeenUsedInSituation")
	assertEquals(false,hasCommandBeenUsedInSituation(1, 1),"test_hasCommandBeenUsedInSituation")
	
	populateSituationMap(0, 0)
	populateSituationMap(1, 1)
	assertEquals(true,hasCommandBeenUsedInSituation(0, 0),"test_hasCommandBeenUsedInSituation")
	assertEquals(true,hasCommandBeenUsedInSituation(0, 1),"test_hasCommandBeenUsedInSituation")
	assertEquals(false,hasCommandBeenUsedInSituation(1, 0),"test_hasCommandBeenUsedInSituation")
	assertEquals(true,hasCommandBeenUsedInSituation(1, 1),"test_hasCommandBeenUsedInSituation")
	
	populateSituationMap(1,0)
	populateSituationMap(0,1)
	assertEquals(true,hasCommandBeenUsedInSituation(0, 0),"test_hasCommandBeenUsedInSituation")
	assertEquals(true,hasCommandBeenUsedInSituation(0, 1),"test_hasCommandBeenUsedInSituation")
	assertEquals(true,hasCommandBeenUsedInSituation(1, 0),"test_hasCommandBeenUsedInSituation")
	assertEquals(true,hasCommandBeenUsedInSituation(1, 1),"test_hasCommandBeenUsedInSituation")
	pass	


func test_importSerialization():
	init()
	
	logCommandSituationPair(0, 0)
	logCommandSituationPair(0, 0)
	logCommandSituationPair(0, 0)
	
	logCommandSituationPair(1, 0)
	logCommandSituationPair(1, 0)
	
	logCommandSituationPair(2, 0)
	
	
	logCommandSituationPair(0, 1)
	
	logCommandSituationPair(1, 1)
	logCommandSituationPair(1, 1)
	
	logCommandSituationPair(2, 1)
	logCommandSituationPair(2, 1)
	logCommandSituationPair(2, 1)
	
	increaseFloorCollisionFrequency()
	increaseFloorCollisionFrequency()
	increaseFloorCollisionFrequency()
	
	increaseCeilingCollisionFrequency()
	increaseCeilingCollisionFrequency()
	
	increaseTechFrequency(0)
	increaseTechFrequency(0)
	increaseTechFrequency(1)
	increaseTechFrequency(2)
	increaseTechFrequency(2)
	increaseTechFrequency(2)
	increaseTechFrequency(3)
	
	increaseWallCollisionFrequency()
	increaseWallCollisionFrequency()
	
	incrementSpriteFrameFrequency(0)
	incrementSpriteFrameFrequency(0)
	incrementSpriteFrameFrequency(0)
	incrementSpriteFrameFrequency(1)
	incrementSpriteFrameFrequency(1)
	incrementSpriteFrameFrequency(2)
	
	incrementAbilityCancelFrequency(0)
	incrementAbilityCancelFrequency(2)
	
	var bytes = serialize()
	
	var aidb2 = preload("res://ai/GhostAIDB.gd").new()
	
	aidb2.importSerialization(bytes)
	
	assertEquals(priorSituationMap.hash(),aidb2.priorSituationMap.hash(),"test_importSerialization")
	assertEquals(demoDataMap.hash(),aidb2.demoDataMap.hash(),"test_importSerialization")
	assertEquals(spriteFrameActivationFreqMap.hash(),aidb2.spriteFrameActivationFreqMap.hash(),"test_importSerialization")
	assertEquals(spriteFrameAbilityCancelFreqMap.hash(),aidb2.spriteFrameAbilityCancelFreqMap.hash(),"test_importSerialization")
	assertArrayEquals(techFrequencies,aidb2.techFrequencies,"test_importSerialization")
	

func test_getSpriteFrameActivation_AbilityCancelRatio():
	init()
	
	assertEquals(null,getSpriteFrameActivation_AbilityCancelRatio(null),"test_getSpriteFrameActivation_AbilityCancelRatio null")
	assertEquals(0.0,getSpriteFrameActivation_AbilityCancelRatio("testspriteframe1"),"test_getSpriteFrameActivation_AbilityCancelRatio no sprite frame increment")
	
	incrementSpriteFrameFrequency("testspriteframe1")
	
	assertEquals(0.0,getSpriteFrameActivation_AbilityCancelRatio("testspriteframe1"),"test_getSpriteFrameActivation_AbilityCancelRatio incremented 1 time")
	
	incrementSpriteFrameFrequency("testspriteframe1")
	
	assertEquals(0.0,getSpriteFrameActivation_AbilityCancelRatio("testspriteframe1"),"test_getSpriteFrameActivation_AbilityCancelRatio incremented 2 times")
	
	incrementSpriteFrameFrequency("testspriteframe1")
	incrementSpriteFrameFrequency("testspriteframe2")
	incrementAbilityCancelFrequency("testspriteframe1")
	assertEquals(1.0/3.0,getSpriteFrameActivation_AbilityCancelRatio("testspriteframe1"),"test_getSpriteFrameActivation_AbilityCancelRatio incremented 2 times ability cancled once")
	assertEquals(0.0,getSpriteFrameActivation_AbilityCancelRatio("testspriteframe2"),"test_getSpriteFrameActivation_AbilityCancelRatio incremented 2 times ability cancled once")
	
	incrementSpriteFrameFrequency("testspriteframe1")
	incrementSpriteFrameFrequency("testspriteframe2")
	incrementAbilityCancelFrequency("testspriteframe2")
	assertEquals(1.0/4.0,getSpriteFrameActivation_AbilityCancelRatio("testspriteframe1"),"test_getSpriteFrameActivation_AbilityCancelRatio incremented 2 times ability cancled once")
	assertEquals(1.0/2.0,getSpriteFrameActivation_AbilityCancelRatio("testspriteframe2"),"test_getSpriteFrameActivation_AbilityCancelRatio incremented 2 times ability cancled once")

	
	
	incrementAbilityCancelFrequency("testspriteframe2")
	incrementAbilityCancelFrequency("testspriteframe1")
	assertEquals(2.0/4.0,getSpriteFrameActivation_AbilityCancelRatio("testspriteframe1"),"test_getSpriteFrameActivation_AbilityCancelRatio incremented 2 times ability cancled once")
	assertEquals(2.0/2.0,getSpriteFrameActivation_AbilityCancelRatio("testspriteframe2"),"test_getSpriteFrameActivation_AbilityCancelRatio incremented 2 times ability cancled once")
	pass


	

func test_getAllTypeCollision_TechRatio():
	init()
	
	var testMsg = "test_getAllTypeCollision_TechRatio0"
	
	assertEquals(0,getWallCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechInPlaceRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechBackwardRatio(),testMsg)
	assertEquals(0,getCeilingCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechForwardRatio(),testMsg)
	
	increaseWallCollisionFrequency()
	
	testMsg = "test_getAllTypeCollision_TechRatio1"
	assertEquals(0,getWallCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechInPlaceRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechBackwardRatio(),testMsg)
	assertEquals(0,getCeilingCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechForwardRatio(),testMsg)

	increaseWallCollisionFrequency()
	increaseTechFrequency(WALL_TECH_IX)
	
	testMsg = "test_getAllTypeCollision_TechRatio2"
	assertEquals(1.0/2.0,getWallCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechInPlaceRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechBackwardRatio(),testMsg)
	assertEquals(0,getCeilingCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechForwardRatio(),testMsg)

	increaseWallCollisionFrequency()
	increaseTechFrequency(WALL_TECH_IX)
	
	testMsg = "test_getAllTypeCollision_TechRatio3"
	assertEquals(2.0/3.0,getWallCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechInPlaceRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechBackwardRatio(),testMsg)
	assertEquals(0,getCeilingCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechForwardRatio(),testMsg)

	increaseFloorCollisionFrequency()
	
	testMsg = "test_getAllTypeCollision_TechRatio4"
	assertEquals(2.0/3.0,getWallCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechInPlaceRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechBackwardRatio(),testMsg)
	assertEquals(0,getCeilingCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechForwardRatio(),testMsg)


	increaseFloorCollisionFrequency()
	increaseTechFrequency(FLOOR_TECH_BACKWARD_IX)
	
	testMsg = "test_getAllTypeCollision_TechRatio5"
	assertEquals(2.0/3.0,getWallCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechInPlaceRatio(),testMsg)
	assertEquals(1.0/2.0,getFloorCollision_TechBackwardRatio(),testMsg)
	assertEquals(0,getCeilingCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechForwardRatio(),testMsg)

	increaseFloorCollisionFrequency()
	increaseTechFrequency(FLOOR_TECH_BACKWARD_IX)
	
	testMsg = "test_getAllTypeCollision_TechRatio6"
	assertEquals(2.0/3.0,getWallCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechInPlaceRatio(),testMsg)
	assertEquals(2.0/3.0,getFloorCollision_TechBackwardRatio(),testMsg)
	assertEquals(0,getCeilingCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechForwardRatio(),testMsg)

	increaseFloorCollisionFrequency()
	increaseTechFrequency(FLOOR_TECH_BACKWARD_IX)
	
	testMsg = "test_getAllTypeCollision_TechRatio7"
	assertEquals(2.0/3.0,getWallCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechInPlaceRatio(),testMsg)
	assertEquals(3.0/4.0,getFloorCollision_TechBackwardRatio(),testMsg)
	assertEquals(0,getCeilingCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechForwardRatio(),testMsg)

	
	increaseTechFrequency(FLOOR_TECH_FORWARD_IX)
	
	testMsg = "test_getAllTypeCollision_TechRatio8"
	assertEquals(2.0/3.0,getWallCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechInPlaceRatio(),testMsg)
	assertEquals(3.0/4.0,getFloorCollision_TechBackwardRatio(),testMsg)
	assertEquals(0,getCeilingCollision_TechRatio(),testMsg)
	assertEquals(1.0/4.0,getFloorCollision_TechForwardRatio(),testMsg)

	increaseTechFrequency(FLOOR_TECH_FORWARD_IX)
	
	testMsg = "test_getAllTypeCollision_TechRatio9"
	assertEquals(2.0/3.0,getWallCollision_TechRatio(),testMsg)
	assertEquals(0,getFloorCollision_TechInPlaceRatio(),testMsg)
	assertEquals(3.0/4.0,getFloorCollision_TechBackwardRatio(),testMsg)
	assertEquals(0,getCeilingCollision_TechRatio(),testMsg)
	assertEquals(2.0/4.0,getFloorCollision_TechForwardRatio(),testMsg)
	
	
	increaseTechFrequency(FLOOR_TECH_IN_PLACE_IX)
	
	testMsg = "test_getAllTypeCollision_TechRatio10"
	assertEquals(2.0/3.0,getWallCollision_TechRatio(),testMsg)
	assertEquals(1.0/4.0,getFloorCollision_TechInPlaceRatio(),testMsg)
	assertEquals(3.0/4.0,getFloorCollision_TechBackwardRatio(),testMsg)
	assertEquals(0,getCeilingCollision_TechRatio(),testMsg)
	assertEquals(2.0/4.0,getFloorCollision_TechForwardRatio(),testMsg)
	
	increaseTechFrequency(FLOOR_TECH_IN_PLACE_IX)
	
	testMsg = "test_getAllTypeCollision_TechRatio11"
	assertEquals(2.0/3.0,getWallCollision_TechRatio(),testMsg)
	assertEquals(2.0/4.0,getFloorCollision_TechInPlaceRatio(),testMsg)
	assertEquals(3.0/4.0,getFloorCollision_TechBackwardRatio(),testMsg)
	assertEquals(0,getCeilingCollision_TechRatio(),testMsg)
	assertEquals(2.0/4.0,getFloorCollision_TechForwardRatio(),testMsg)
	
	increaseTechFrequency(CEILING_TECH_IX)
	increaseCeilingCollisionFrequency()
	increaseCeilingCollisionFrequency()
	
	testMsg = "test_getAllTypeCollision_TechRatio12"
	assertEquals(2.0/3.0,getWallCollision_TechRatio(),testMsg)
	assertEquals(2.0/4.0,getFloorCollision_TechInPlaceRatio(),testMsg)
	assertEquals(3.0/4.0,getFloorCollision_TechBackwardRatio(),testMsg)
	assertEquals(1.0/2.0,getCeilingCollision_TechRatio(),testMsg)
	assertEquals(2.0/4.0,getFloorCollision_TechForwardRatio(),testMsg)
func test_getWallCollision_TechRatio():
	init()
	var techIx = WALL_TECH_IX
	var testMsg = "test_getWallCollision_TechRatio"
	var expected = 0
	var actual = getWallCollision_TechRatio()
	assertEquals(expected,actual,testMsg)
	
	increaseWallCollisionFrequency()
	
	expected = 0
	actual = getWallCollision_TechRatio()
	assertEquals(expected,actual,testMsg)
	
	increaseWallCollisionFrequency()
	increaseTechFrequency(techIx)
	
	expected = 1.0/2.0
	actual = getWallCollision_TechRatio()
	assertEquals(expected,actual,testMsg)
	
	increaseWallCollisionFrequency()
	increaseTechFrequency(techIx)
	
	expected = 2.0/3.0
	actual = getWallCollision_TechRatio()
	assertEquals(expected,actual,testMsg)
	
	increaseTechFrequency(techIx)
	
	expected = 3.0/3.0
	actual = getWallCollision_TechRatio()
	assertEquals(expected,actual,testMsg)

func test_getFloorCollision_TechInPlaceRatio():
	init()
	var techIx = FLOOR_TECH_IN_PLACE_IX
	var testMsg = "test_getFloorCollision_TechInPlaceRatio"
	var expected = 0
	var actual = getFloorCollision_TechInPlaceRatio()
	assertEquals(expected,actual,testMsg)
	
	increaseFloorCollisionFrequency()
	
	expected = 0
	actual = getFloorCollision_TechInPlaceRatio()
	assertEquals(expected,actual,testMsg)
	
	increaseFloorCollisionFrequency()
	increaseTechFrequency(techIx)
	
	expected = 1.0/2.0
	actual = getFloorCollision_TechInPlaceRatio()
	assertEquals(expected,actual,testMsg)
	
	increaseFloorCollisionFrequency()
	increaseTechFrequency(techIx)
	
	expected = 2.0/3.0
	actual = getFloorCollision_TechInPlaceRatio()
	assertEquals(expected,actual,testMsg)
	
	increaseTechFrequency(techIx)
	
	expected = 3.0/3.0
	actual = getFloorCollision_TechInPlaceRatio()
	assertEquals(expected,actual,testMsg)
	

func test_getFloorCollision_TechForwardRatio():
	init()
	var techIx = FLOOR_TECH_FORWARD_IX
	var testMsg = "test_getFloorCollision_TechForwardRatio"
	var expected = 0
	var actual = getFloorCollision_TechForwardRatio()
	assertEquals(expected,actual,testMsg)
	
	increaseFloorCollisionFrequency()
	
	expected = 0
	actual = getFloorCollision_TechForwardRatio()
	assertEquals(expected,actual,testMsg)
	
	increaseFloorCollisionFrequency()
	increaseTechFrequency(techIx)
	
	expected = 1.0/2.0
	actual = getFloorCollision_TechForwardRatio()
	assertEquals(expected,actual,testMsg)
	
	increaseFloorCollisionFrequency()
	increaseTechFrequency(techIx)
	
	expected = 2.0/3.0
	actual = getFloorCollision_TechForwardRatio()
	assertEquals(expected,actual,testMsg)
	
	increaseTechFrequency(techIx)
	
	expected = 3.0/3.0
	actual = getFloorCollision_TechForwardRatio()
	assertEquals(expected,actual,testMsg)
	

func test_getFloorCollision_TechBackwardRatio():
	init()
	var expected = 0
	var actual = getFloorCollision_TechBackwardRatio()
	assertEquals(expected,actual,"test_getFloorCollision_TechBackwardRatio")
	
	increaseFloorCollisionFrequency()
	
	expected = 0
	actual = getFloorCollision_TechBackwardRatio()
	assertEquals(expected,actual,"test_getFloorCollision_TechBackwardRatio")
	
	increaseFloorCollisionFrequency()
	increaseTechFrequency(FLOOR_TECH_BACKWARD_IX)
	
	expected = 1.0/2.0
	actual = getFloorCollision_TechBackwardRatio()
	assertEquals(expected,actual,"test_getFloorCollision_TechBackwardRatio")
	
	increaseFloorCollisionFrequency()
	increaseTechFrequency(FLOOR_TECH_BACKWARD_IX)
	
	expected = 2.0/3.0
	actual = getFloorCollision_TechBackwardRatio()
	assertEquals(expected,actual,"test_getFloorCollision_TechBackwardRatio")
	
	increaseTechFrequency(FLOOR_TECH_BACKWARD_IX)
	
	expected = 3.0/3.0
	actual = getFloorCollision_TechBackwardRatio()
	assertEquals(expected,actual,"test_getFloorCollision_TechBackwardRatio")
		
func test_getCeilingCollision_TechRatio():
	
	init()
	var expected = 0
	var actual = getCeilingCollision_TechRatio()
	assertEquals(expected,actual,"test_getCeilingCollision_TechRatio")
	
	increaseCeilingCollisionFrequency()
	
	expected = 0
	actual = getCeilingCollision_TechRatio()
	assertEquals(expected,actual,"test_getCeilingCollision_TechRatio")
	
	increaseCeilingCollisionFrequency()
	increaseTechFrequency(CEILING_TECH_IX)
	
	expected = 1.0/2.0
	actual = getCeilingCollision_TechRatio()
	assertEquals(expected,actual,"test_getCeilingCollision_TechRatio")
	
	increaseCeilingCollisionFrequency()
	increaseTechFrequency(CEILING_TECH_IX)
	
	expected = 2.0/3.0
	actual = getCeilingCollision_TechRatio()
	assertEquals(expected,actual,"test_getCeilingCollision_TechRatio")
	
	increaseTechFrequency(CEILING_TECH_IX)
	
	expected = 3.0/3.0
	actual = getCeilingCollision_TechRatio()
	assertEquals(expected,actual,"test_getCeilingCollision_TechRatio")

func testAll():
	test_getCeilingCollision_TechRatio()
	test_getFloorCollision_TechBackwardRatio()
	test_getFloorCollision_TechForwardRatio()
	test_getFloorCollision_TechInPlaceRatio()
	test_getWallCollision_TechRatio()
	test_getAllTypeCollision_TechRatio()
	test_getSpriteFrameActivation_AbilityCancelRatio()
	test_hasCommandBeenUsedInSituation()
	test_getSituationsCommandUsedIn()
	test_getListOfCommands()
	test_getSituationCommandMap()
	test_getSituationFrequency()
	test_hasSituationId()
	test_getCommandFrequency()
	test_importSerialization()
	print("End Unit Testing")

#todo, make this test function global for the testing modules
func assertMapEquals(a1,a2,msg):
	
	if (a1 == null and a2 !=null) or (a2 == null and a1 !=null) or (typeof(a1)!= TYPE_DICTIONARY) or (typeof(a2)!= TYPE_DICTIONARY):
		print("Test failed: expected ("+str(a1)+") but was ("+str(a2)+"). "+ msg)
		return

	if a1.size() != a2.size():
		print("Test failed: expected size of map ("+str(a1.size())+") but was ("+str(a2.size())+"). "+ msg)
	
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
	
	for i in range(a1.size()):
		assertEquals(a1[i],a2[i], msg)

#arrays are the same, but the elements order may differ (e.g., [0,1,2] = [0,2,1] but [0,1,2] != [1,2,3]
func assertArrayAlmostEquals(a1,a2,msg):
	
	if (a1 == null and a2 !=null) or (a2 == null and a1 !=null) or (typeof(a1)!= TYPE_ARRAY) or (typeof(a2)!= TYPE_ARRAY):
		print("Test failed: expected ("+str(a1)+") but was ("+str(a2)+"). "+ msg)
		return

	if a1.size() != a2.size():
		print("Test failed: expected array size of ("+str(a1.size())+") but was ("+str(a2.size())+"). "+ msg)
	
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
