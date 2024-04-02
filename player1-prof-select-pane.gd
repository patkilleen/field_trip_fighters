extends Control

#signal ready
signal advantage_proficiency_selected
signal disadvantage_proficiency_selected
signal advantage_proficiency_unselected
signal disadvantage_proficiency_unselected


export (String) var inputDeviceId = "P1"


var GLOBALS = preload("res://Globals.gd")
var advStar = null
var advCursor = null
var disStar = null
var disCursor = null
var inputManager = null


var advProf = null
var disProf = null
var readyIcon = null
var ready = false

var rng = null

var gameMode = null
var onlineModeMaineInputDeviceId= null
func _ready():

	
	#RANDOME NUM gen for quote selection
	rng = RandomNumberGenerator.new()
	
	#genreate time-based seed
	rng.randomize()
	
	
	advStar= $"advantage-star"
	disStar = $"disadvantage-star"
	readyIcon = $"player-label/readyIcon"
	
	
	
	advCursor = $"advantage-star/cursor"
	disCursor = $"disadvantage-star/cursor"

	
	pass
#func init(mode, networkManager):
func init(mode,_onlineModeMaineInputDeviceId):
	onlineModeMaineInputDeviceId=_onlineModeMaineInputDeviceId
	gameMode=mode
	#if mode == GLOBALS.GameModeType.ONLINE_HOSTING or mode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		
		
		
	#	if mode == GLOBALS.GameModeType.ONLINE_HOSTING:
			
	#		if inputDeviceId == GLOBALS.PLAYER1_INPUT_DEVICE_ID:
	#			inputManager = networkManager.getLocalInputManager()
	#		else:
	#			inputManager = networkManager.getRemoteInputManager()
			
	#	else:
						
	#		if inputDeviceId == GLOBALS.PLAYER1_INPUT_DEVICE_ID:
	#			inputManager = networkManager.getRemoteInputManager()
	#		else:
	#			inputManager = networkManager.getLocalInputManager()
	
	#else:
	#	inputManager = $inputManager
	inputManager = $inputManager
	inputManager.inputDeviceId = self.inputDeviceId

	
	if mode == GLOBALS.GameModeType.ONLINE_HOSTING or mode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		#only allow one inpute device to control menus in online mode
		if self.inputDeviceId != onlineModeMaineInputDeviceId:
			set_physics_process(false)
		
	#we ingore input from input device that will be later controlled by online peer
	#if gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST and inputDeviceId == GLOBALS.PLAYER1_INPUT_DEVICE_ID:
		#connecting to hosts means were player 2, ignores local player 1 input
	#	set_physics_process(false)
	#if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING and inputDeviceId == GLOBALS.PLAYER2_INPUT_DEVICE_ID:
		#hosting means were player 1, ignores local player 2 input
	#	set_physics_process(false)
		
		
func selectProficiency(prof):
	
	#if prof == NONE:
	#	return
	
	if advProf == null:
		advProf = prof
		advStar.enabled = true
		advCursor.visible = false
		disCursor.visible = true
		emit_signal("advantage_proficiency_selected")
	elif disProf == null:
		
		#can pick NONE twice  
		#if prof == NONE:
	#		disProf = prof
	#		disStar.enabled = true
		#make sure not selecting same prof twice  and can't mix and match none and other profs
		#its a non-prof
		
		
		#ignore any case that we select advantage as non, and trying to pick a dsiadvantage
		if advProf == GLOBALS.Proficiency.NONE and prof != GLOBALS.Proficiency.NONE:
			return
		
		#no proficiency selected for disadvantage?
		if prof == GLOBALS.Proficiency.NONE:
			#can only select if adv prof was non too
			if advProf == GLOBALS.Proficiency.NONE:
				disProf = prof
				disStar.enabled = true
				disCursor.visible = false
				emit_signal("disadvantage_proficiency_selected")
				
		elif advProf != prof: #make sure u can't pick disadvantage and adv same prof
			disProf = prof
			disStar.enabled = true
			disCursor.visible = false
			emit_signal("disadvantage_proficiency_selected")
	
func unselectProficiency():
	
	if disProf != null:
		disProf = null
		disStar.enabled = false
		disCursor.visible = true
		emit_signal("disadvantage_proficiency_unselected")
	elif advProf != null:
		advProf = null
		advStar.enabled = false
		advCursor.visible = true
		disCursor.visible = false
		emit_signal("advantage_proficiency_unselected")
	#print("unselected prof")	
		
		
#func selectNoProficiency():
	#if advProf == null and disProf == null:
		
#		advProf = NONE
#		advStar.enabled = true
#		disProf = NONE
#		disStar.enabled = true
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	#player locked in after confirming prof selection
	#if ready:
	#	return 
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.

	var cmd = inputManager.readCommand()
	var ready = false
	match(cmd):
		
		inputManager.Command.CMD_ABILITY_BAR_CANCEL_NEXT_MOVE:#random?
			selectRandomProficiencies()
		inputManager.Command.CMD_NEUTRAL_MELEE:	#X
			selectProficiency(GLOBALS.Proficiency.BAR_COST)
		inputManager.Command.CMD_NEUTRAL_SPECIAL:#Y
			selectProficiency(GLOBALS.Proficiency.DAMAGE_INCREASE)
		inputManager.Command.CMD_STOP_MOVE_FORWARD:#release RIGHT 	
			selectProficiency(GLOBALS.Proficiency.ACROBATICS)
		inputManager.Command.CMD_STOP_CROUCH:#Release DOWN
			selectProficiency(GLOBALS.Proficiency.DEFENDER)
		inputManager.Command.CMD_JUMP:	#a button
			#selectProficiency(Proficiency.NONE)
			selectProficiency(GLOBALS.Proficiency.NONE)
			ready=true
#			selectNoProficiency()
		inputManager.Command.CMD_NEUTRAL_TOOL:	#B
			unselectProficiency()
			#no prof?
		#	if  (advProf == Proficiency.NONE) :
		#		unselectProficiency() #unselect additional star
				
		inputManager.Command.CMD_START:	#START
			ready=true

	if ready:
		#can only confirm prof selection if both proficiency stars filled
		if (advProf != null) and (disProf != null):
			ready = true
			readyIcon.visible = true
			emit_signal("ready",advProf,disProf)



func selectRandomProficiencies():
	
	#populate list of proficiency enums
	var profList = []
	for enumKey in GLOBALS.Proficiency.keys():
		
		
		var enumValue = GLOBALS.Proficiency[enumKey] 
		profList.append(enumValue)
		
	
	#this takes care of situation where already picked an advantage proficiency?
	var prof1 = advProf
	
	#special case where player selected first star no proficieyc?
	if GLOBALS.Proficiency.NONE == prof1:
		selectProficiency(GLOBALS.Proficiency.NONE)
		return


	var prof2 = null
	while prof2 == null:
		#choose random proficiencies from availalbe liskt
		var ix = rng.randi_range(0,profList.size()-1)
	
		var profEnum = profList[ix]
		
		#case where non chosen? both are none as first choice
		if prof1 == null and GLOBALS.Proficiency.NONE == profEnum:
			prof1=profEnum
			prof2 = profEnum
		elif prof1 == null:# choosing 1st prof?
			prof1=profEnum
		elif prof1 != profEnum: #choosing 2nd prof  and can't pick duplicate prof
			#can't pick neutral as 2nd proficiency
			if GLOBALS.Proficiency.NONE != profEnum:
				prof2=profEnum
	
	#only select first proficiency if we hanve't picke done yet
	if advProf == null:
		selectProficiency(prof1)
		
	selectProficiency(prof2)
