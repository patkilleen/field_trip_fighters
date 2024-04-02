extends Node2D

signal stage_selected
signal back

const UP_ROUTE_IX =0
const RIGHT_ROUTE_IX =1
const DOWN_ROUTE_IX =2
const LEFT_ROUTE_IX =3

const ONE_SECOND = 1

enum SelectionState{
	BUS_TRAVEL,
	QUICK_LIST_SELECT	
}


export (Vector2) var defaultBusPosition=Vector2(455,259)

var selectionState=SelectionState.BUS_TRAVEL

var currentStage = null
var isEnRoute = false

var gameMode= null
var stageIcon = null
var stageNameLabel = null

var inputDevices = []
var holdingBTime = {}
var GLOBALS = preload("res://Globals.gd")

var rng = null

var busSprite = null

const listOfRandomStagePaths = ["res://stages/farm.tscn","res://stages/observatory.tscn","res://stages/snow-carnaval.tscn","res://stages/kayaking.tscn","res://stages/radio-tower.tscn","res://stages/art-museum.tscn","res://stages/haunted-mansion.tscn","res://stages/mountain-climbing.tscn","res://stages/theater.tscn","res://stages/bridge.tscn","res://stages/baseball-stadium.tscn"]

var lastStageSelectedPath = null
var checkPoints = []

const BUS_DEPART_SOUND_ID=0
const BUS_HORN_SOUND_ID=1

var stageSizeStars = null

var soundSfxPlayer = null

var fastStageSelectList=null
var quickStageSelectNode = null
var quickStageSelectNodeMap={}

var stageSelectionLock=false
#help on path2d : https://www.youtube.com/watch?v=-JOI9HzPanw
func _ready():
	
	#RANDOME NUM gen for quote selection
	rng = RandomNumberGenerator.new()
	stageSelectionLock=false
	soundSfxPlayer = $sfxPlayer
	
	#genreate time-based seed
	rng.randomize()
	
	
	stageSizeStars = $"HUD/HBoxContainer/right-pane/footer/HBoxContainer/star-array"
	stageSizeStars.setNumberOfStars(0)
	
	quickStageSelectNode=$"HUD/quickStageSelect"
	fastStageSelectList=$"HUD/quickStageSelect/stageFastListSelection"
	fastStageSelectList.init(null)#null cause the input selection should be affected by game mode. Stage select same for any gamemode
	fastStageSelectList.deactivate()
	quickStageSelectNode.visible=false
	

	fastStageSelectList.connect("option_selected",self,"_on_quick_stage_selected")
	fastStageSelectList.connect("option_focused",self,"_on_quick_stage_focused")

	quickStageSelectNodeMap["Winter Carnaval"]=$"check-points/snow"
	quickStageSelectNodeMap["Art Museum"]=$"check-points/art-museum"
	quickStageSelectNodeMap["Theater"]=$"check-points/theater"
	quickStageSelectNodeMap["Haunted Mansion"]=$"check-points/haunted-house"
	quickStageSelectNodeMap["Farm"]=$"check-points/farm"
	quickStageSelectNodeMap["Rapid Kayaking"]=$"check-points/kayak"
	quickStageSelectNodeMap["Observatory"]=$"check-points/observatory"
	quickStageSelectNodeMap["Radio Tower"]=$"check-points/radio-tower"
	quickStageSelectNodeMap["Rock Climbing"]=$"check-points/mountain-climbing"
	
	
	
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	stageNameLabel = $"HUD/HBoxContainer/right-pane/footer/HBoxContainer/Label"
	stageIcon = $"HUD/HBoxContainer/right-pane/header/stageIcon"
	
	
	
	busSprite = $"bus2/busSprite"
#	busSprite.position = defaultBusPosition
#	var bus = $bus
	
	currentStage = $"check-points/random"
	
	displayeStageInfo()

	
	var checkPoints = $"check-points"
	#iterate all stage checkpoints
	for stage in checkPoints.get_children():
		if stage is preload("res://stage-checkpoint.gd"):
			#connect to the bus arrival signals
			stage.connect("bus_arrived",self,"_on_bus_arrived")
			stage.connect("bus_entered_area",self,"_on_bus_arriving")
	
	
	holdingBTime[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = 0
	holdingBTime[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = 0

	inputDevices.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDevices.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	
	set_physics_process(true)
	
	
func _on_departure(_route):
	
	if _route ==null:
		print("null route on departure")
	
	#hide the stage info
	var hud = get_node("HUD/HBoxContainer")
	hud.visible = false	
	stageIcon.texture = null
	
	var stageiconBgd = get_node("HUD/ColorRect")
	stageiconBgd.visible = false	
	
	
	soundSfxPlayer.playSound(BUS_DEPART_SOUND_ID)
	
	#var checkPointLeft = _route.get_parent()
	#checkPointLeft._on_departure(_route)
	
	isEnRoute = true
		
	currentStage.navigationArrowsNode.visible = false
	
	#start moving bus along route
	_route.activate()
	
	
func _on_bus_arriving(stage):
	currentStage = stage
	
		
func _on_bus_arrived(_route):
	
	
	if _route == null:
		print("null route on arrival")
		return
	
	if currentStage.id != null:
		var hud = get_node("HUD/HBoxContainer")
		hud.visible = true
		
		var stageiconBgd = get_node("HUD/ColorRect")
		stageiconBgd.visible = true	
	
	
	isEnRoute = false
	
	
	#stop at destination
	_route.deactivate()
	
	if currentStage.id != null:
		displayeStageInfo()
	
	pass
	
func displayeStageInfo():
	stageIcon.texture = currentStage.texture 
	stageNameLabel.text =currentStage.id
	
	if stageNameLabel.text == "Random":
		stageSizeStars.setNumberOfStars(0)
	else:
		stageSizeStars.setNumberOfStars(currentStage.stage_size)
	
func _physics_process(delta):
	
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	
	if selectionState==SelectionState.BUS_TRAVEL:
		#here we process user input, to determine what direction to take
		#the routes are assumed to be UP,RIGHT,DOWN,LEFT by order of children
	
		#don't change direction mid travel
		if isEnRoute:
			return
		
		#haven't arrived at stage yet?
	#	if currentStage == null:
	#		return	
		var _route = null
		
			#iterate both players
		#for player in 	inputManagers.keys():
		for player in inputDevices:
			#the player connecting to host (player 2) can't select map in online mode
			if gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST and player == GLOBALS.PLAYER2_INPUT_DEVICE_ID:
				continue
			
			#Handle arrow key presses
			if(Input.is_action_just_pressed(player+"_LEFT")):
				attemptDepartur(LEFT_ROUTE_IX)
				busSprite.scale = Vector2(abs(busSprite.scale.x)*-1, busSprite.scale.y)
				
			elif(Input.is_action_just_pressed(player+"_RIGHT")):
				attemptDepartur(RIGHT_ROUTE_IX)
				busSprite.scale = Vector2(abs(busSprite.scale.x), busSprite.scale.y)
				
			elif(Input.is_action_just_pressed(player+"_UP")):
				attemptDepartur(UP_ROUTE_IX)
				
			elif(Input.is_action_just_pressed(player+"_DOWN")):
				attemptDepartur(DOWN_ROUTE_IX)
				
			elif(Input.is_action_just_pressed(player+"_A")) or (Input.is_action_just_pressed(player+"_START")):
				
				#only if were at a valid stage (may be at a cross walk
				if currentStage.id != null:
					
					#can't select stage when locked (already selected)
					if not stageSelectionLock:
						stageSelectionLock=true
						
						print("stage selected: " + currentStage.id)
						set_physics_process(false)
						#emit_signal("stage_selected",currentStage)
						
						var resStagePath = null
						if  currentStage.id == "Random":
							resStagePath = chooseRandomStage()
							
							#we previsouly chose a stage?
							if lastStageSelectedPath != null:
								
								#avoid picking the same stage twice when choosing random
								while resStagePath ==lastStageSelectedPath:
									resStagePath = chooseRandomStage()
						else:
							resStagePath=currentStage.stage_scene_path
						
						soundSfxPlayer.playSound(BUS_HORN_SOUND_ID)
						
						
						emit_signal("stage_selected",resStagePath)
						
						return
					return
			#players may be holding b to go back
			elif Input.is_action_pressed(player+"_B"):
				
				#count how long holding B
				holdingBTime[player] += delta
				
				if holdingBTime[player] > ONE_SECOND:
					
					emit_signal("back")
					
			elif Input.is_action_just_released(player+"_B"):
				#reset the holding b timer, were done trying to go back
				holdingBTime[player] =0
			elif Input.is_action_just_pressed(player+"_X"):
				changeSelectState(SelectionState.QUICK_LIST_SELECT)			
				fastStageSelectList.inputDeviceId=player
				return
	elif selectionState==SelectionState.QUICK_LIST_SELECT:
		for player in inputDevices:
				#players may be holding b to go back
			if Input.is_action_pressed(player+"_B") or Input.is_action_just_pressed(player+"_X"):
				changeSelectState(SelectionState.BUS_TRAVEL)
				return
			
	
func attemptDepartur(routeIx):
	
	if currentStage == null:
		return
	
	var _route = currentStage.getRoute(routeIx)

	if _route != null:
		_on_departure(_route)
		
		

	

func setGameMode(gm):
	gameMode = gm
	
	
	
func chooseRandomStage():
	

	#choose a stage at ramdon
	var ix = rng.randi_range(0,listOfRandomStagePaths.size()-1)

	return listOfRandomStagePaths[ix]

		
#generate an event (true or false ) with given probabliity
#pvalue: probablity of evnet [0,1]
#ture returns when event occurs
#false returned when it doesn't
func generateProbabilistichEvent(pvalue):

	var eventOccured = false


	#generate number between 0 -1 
	var r = rng.randf()
	
	#event occured? note that pobability 0 will never happen
	if r < pvalue:
		eventOccured = true
			
	return eventOccured
	
	
func initCamera():
	var boundariesRect = $cameraBoundaries
	var camera = $"bus2/Camera2D"
	camera.limit_bottom  = boundariesRect.rect_position.y + boundariesRect.rect_size.y
	camera.limit_top = boundariesRect.rect_position.y
	camera.limit_right  = boundariesRect.rect_position.x + boundariesRect.rect_size.x
	camera.limit_left  = boundariesRect.rect_position.x
	
	
func setLastStageSelected(stage_scene_path):
	lastStageSelectedPath =stage_scene_path

func changeSelectState(_newState):
	selectionState=_newState
	
	if selectionState==SelectionState.BUS_TRAVEL:
		fastStageSelectList.deactivate()
		quickStageSelectNode.visible=false
		
	elif selectionState==SelectionState.QUICK_LIST_SELECT:
		fastStageSelectList.activate()
		quickStageSelectNode.visible=true
		
		var hud = get_node("HUD/HBoxContainer")
		hud.visible = true
		
		var stageiconBgd = get_node("HUD/ColorRect")
		stageiconBgd.visible = true	
		
	else:
		print("unknown stage selection state")
		pass

#caled when navigate the quick select menu, will update stage info
func _on_quick_stage_focused(stageName):
	if not quickStageSelectNodeMap.has(stageName):
		print("error looking up stage checkpoint node. stage not found for : " +stageName)
		return 
	currentStage = quickStageSelectNodeMap[stageName]
	displayeStageInfo()
	pass

#called when quick stage select confirmed
func _on_quick_stage_selected(stageName):
	if selectionState!=SelectionState.QUICK_LIST_SELECT:
		print("warning, a quick stage was selected but in the bus navigation state")
		return 
		
		
	if not quickStageSelectNodeMap.has(stageName):
		print("error looking up stage checkpoint node. stage not found for : " +stageName)
		return 
	
	#can't select stage when locked (already selected)
	if not stageSelectionLock:
		stageSelectionLock=true
		
	
		currentStage = quickStageSelectNodeMap[stageName]
	
		soundSfxPlayer.playSound(BUS_HORN_SOUND_ID)
	
		emit_signal("stage_selected",currentStage.stage_scene_path)
	
