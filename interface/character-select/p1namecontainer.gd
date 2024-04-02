extends HBoxContainer

signal player_name_selected

const GLOBALS = preload("res://Globals.gd")

#var stats = null
var nameIOHandler = null
var pNameLabel = null

var playerId = null

var nameSelectionList = null
var gameMode = null
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	pNameLabel = $pnameLabel
	nameSelectionList = $NameSelectionList
	set_physics_process(false)
	pass

func init(_nameIOHandler,_playerId,_gameMode):
	gameMode = _gameMode
	nameIOHandler = _nameIOHandler
	playerId = _playerId
	#var playerNames = stats.getEntityNames(stats.PLAYER_NAME_SID)	
	var playerNames = nameIOHandler.readAllNames()
	
	
	#nameSelectionList
	
	var csvNames = ""
	#nameOptions.clear()
	
	#add a filler selection, to make events of selection register 
	#(dont forget to consider the index offset by 1)
	#nameOptions.add_item(playerId)
	if playerNames.size() > 0:
		csvNames = playerId+","
	else:
		csvNames = playerId
	
	var i= 0
	#create the option list of players dynamically
	for n in playerNames:
#		nameOptions.add_item(n)
		
		
		csvNames=csvNames+n
		#not last name
		if i <playerNames.size()-1: #-1 since player id is part of the csv string list but not in name array
			csvNames=csvNames+","
		i = i + 1
	
	nameSelectionList.csvOptions =csvNames
	
	nameSelectionList.connect("option_selected",self,"_on_player_name_selected")
	nameSelectionList.init(gameMode)
	disable()
	
	#connect to selecting a player name to remove
	#nameOptions.connect("item_selected",self,"_on_player_name_selected",[playerNames])

func enable():
	set_physics_process(true)
	nameSelectionList.activate()
	nameSelectionList.visible =true

func disable():
	nameSelectionList.deactivate()
	nameSelectionList.visible =false
	set_physics_process(false)
	
func displayPlayerName(pname):
	pNameLabel.text=pname
func _on_player_name_selected(pname):
	
	disable()
	emit_signal("player_name_selected",pname,playerId)
#func _on_player_name_selected(id,playerNames):
	
#	id = id -1 #offset by 1 from the template filler 1st item
#	var pname = playerNames[id]
#	emit_signal("player_name_selected",pname,playerId)
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


	
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	if Input.is_action_just_pressed(nameSelectionList.inputDeviceId+"_B"):
		disable()		
		emit_signal("player_name_selected",playerId,playerId)
		
	