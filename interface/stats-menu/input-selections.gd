extends VBoxContainer

#signal stats_entity_chosen #the entity (hero or player name) to display stats for, params: entityId,type
signal player_name_hero_stats_chosen
signal hero_stats_chosen 

const HERO_IX = 0
const PLAYER_NAME_IX = 1

var GLOBALS = preload("res://Globals.gd")

const HERO_ITEM = "Hero"
const PLAYER_NAME_ITEM = "Player Name"

var stats = null

var showTypeSelection = null
#var entitySelection = null

var heroSelection = null
var playerNameSelection = null

var entityLabel = null
#var addNameBtn = null
#var removeNameBtn = null
var addNameConfirmPopup = null
var typeSelected = null

var nameInputField = null

var line3 = null
#var line4 = null

#var nameOptions = null

var selectedHeroIx = null
var selectedPlayerNameIx = null

var nameIOHandler = null
func _ready():
	
	pass

	
func init(_stats,_nameIOHandler):
	
	showTypeSelection = $line1/TypeItemList
	#entitySelection = $line2/TypeItemList
	heroSelection= $line2/TypeItemList
	playerNameSelection= $line3/TypeItemList
	
	#entityLabel = $line2/Label
	#addNameBtn = $addNameBtn
	#removeNameBtn = $rmNameBtn
	
	line3 = $line3
	#line4 = $line4
	#nameInputField = $line4/LineEdit
	
	nameIOHandler = _nameIOHandler
	
	#nameOptions = $playerNameRemoveOptions
	#not visible at first, since add player buttons toggle visibility
	line3.visible = false
	hidePlayerNameInputOptions()
	
	#only appear wheen click remove name button
	#nameOptions.visible = false

	stats = _stats
	
	selectedHeroIx = 0
	selectedPlayerNameIx = -1
	#heros are selecte first
	#entityLabel.text = HERO_ITEM
	
	#entitySelection.connect("item_selected",self,"_on_entity_chosen")
	heroSelection.connect("item_selected",self,"_on_hero_chosen")
	playerNameSelection.connect("item_selected",self,"_on_player_name_chosen")
	showTypeSelection.connect("item_selected",self,"_on_type_chosen")
	#addNameBtn.connect("pressed",self,"_on_add_name_button_pressed")
	
	
	
	#nameInputField.connect("text_entered",self,"_on_player_add_name_confirmed")
	
#	addNameConfirmPopup.connect("confirmed",self,"_on_player_add_name_confirmed")
	
	#fill in the hero name and player name selection buttons
	populateSelectionList(heroSelection,stats.HERO_SECTIONS_SID)
	#populateSelectionList(playerNameSelection,stats.PLAYER_NAME_SID)
	
	populatePlayerNames()
	
	#fill in the selection type options
	showTypeSelection.add_item(HERO_ITEM)
	showTypeSelection.add_item(PLAYER_NAME_ITEM)
	
	#showTypeSelection.select(HERO_IX)
	#heroSelection.select(0)
	_on_hero_chosen(0)
	_on_type_chosen(HERO_IX)
	#_on_entity_chosen(0) #first in list populate with stats
	#_on_selection_made() #don't need to call this, type chosen does this
	#removeNameBtn.connect("pressed",self,"_on_remove_player_name_button_pressed")
	
	pass

func populatePlayerNames():
	
	
	
	var names = nameIOHandler.readAllNames()
	
	for _name in names:
		
		playerNameSelection.add_item(_name)
		
func showPlayerNameInputOptions():
	line3.visible = true
	#line4.visible = true
#	addNameBtn.visible = true
#	removeNameBtn.visible = true
	
func hidePlayerNameInputOptions():
	line3.visible = false
	#line4.visible = false
	#addNameBtn.visible = false #will be reshown when click add player button
	#removeNameBtn.visible = false
	#nameOptions.visible = false #will be reshown upon clicking the remove button
	

func populateSelectionList(selectionList, statsSection):
	
	
	selectionList.clear()
	#var entityIds = stats.getEntityNames(statsSection)
	var entityIds = stats.HERO_KIDS
	#iterate the ids to add them to list
	for id in entityIds:
		
		selectionList.add_item(id)

func _on_hero_chosen(itemIx):
	selectedHeroIx = itemIx
	_on_selection_made()
	pass
func _on_player_name_chosen(itemIx):
	selectedPlayerNameIx = itemIx
	_on_selection_made()
	pass
	
#func _on_add_name_button_pressed():
#	line4.visible = true
	
func _on_type_chosen(itemIx):
	
	#var entityId = showTypeSelection.get_item_text(itemIx)
	#print(entityId)
	
	typeSelected = itemIx
	
	#selectedPlayerNameIx = playerNameSelection.get_selected_id()
	#selectedHeroIx = heroSelection.get_selected_id()
	if itemIx == HERO_IX:
		hidePlayerNameInputOptions()
		#selectedPlayerNameIx = -1
		#populateSelectionList(entitySelection,stats.HERO_SECTIONS_SID)
	
	elif itemIx == PLAYER_NAME_IX:
		showPlayerNameInputOptions()
		
		#first time selecting name to display?
		if selectedPlayerNameIx == -1 and playerNameSelection.get_item_count() > 0:
			selectedPlayerNameIx=0 #choose first name to display stats
			
		#selectedPlayerNameIx = playerNameSelection.get_selected_id()
		#selectedHeroIx = 0
		#populateSelectionList(entitySelection,stats.PLAYER_NAME_SID)
	
		
	#make sure names exist
	#f entitySelection.get_item_count() > 0:
		#now update the stats with first entity in list
	#_on_entity_chosen(0)
	_on_selection_made()
	
#called when players or hero selection item is activated
func _on_selection_made():
	
	
	
	var selectedHero = heroSelection.get_item_text(selectedHeroIx)
	

	if typeSelected == HERO_IX:
		emit_signal("hero_stats_chosen",selectedHero)
	elif typeSelected == PLAYER_NAME_IX:
		#problem handling the player select
		if selectedPlayerNameIx == -1:
			#print("error selected player name from list for stats display")
			pass
		else:
			var selectedPlayerName  =playerNameSelection.get_item_text(selectedPlayerNameIx)
			emit_signal("player_name_hero_stats_chosen",selectedHero,selectedPlayerName)
		
	#var entityId = entitySelection.get_item_text(itemIx)
	#emit_signal("stats_entity_chosen",entityId,type)
	
		
#func _on_player_add_name_confirmed(newname):
	
#	if newname == GLOBALS.CPU_NAME:
#		nameInputField.text = ""
		#illegal name
#		return
	#line4.visible = false
#	stats.addPlayerName(newname)
	
	#we in playing add stats mode?
#	if typeSelected == PLAYER_NAME_IX:
		
		
#		var playerSelectIx = playerNameSelection.get_selected_id() 
		
		#refresh the player name list
#		populateSelectionList(playerNameSelection,stats.PLAYER_NAME_SID)
		
		#make sure to re-select old selected player
#		if playerSelectIx != -1:
#			playerNameSelection.select(playerSelectIx)
		
#func _on_remove_player_name_selected(id,playerNames):
	#var playerNames = stats.getEntityNames(stats.PLAYER_NAME_SID)
#	id = id - 1 #-1 cause of the offset of dummy item
#	nameOptions.visible = false
#	nameOptions.disconnect("item_selected",self,"_on_remove_player_name_selected")
	
#	var removedPlayer = playerNames[id]
#	stats.removePlayerName(removedPlayer)
	
	#we in playing add stats mode?
#	if typeSelected == PLAYER_NAME_IX:
		
		#refresh the player name list
#		populateSelectionList(playerNameSelection,stats.PLAYER_NAME_SID)

#func _on_remove_player_name_button_pressed():
	
	
#	nameOptions.visible = true
	
#	var playerNames = stats.getEntityNames(stats.PLAYER_NAME_SID)	
	
#	nameOptions.clear()
	
	#add a filler selection, to make events of selection register 
	#(dont forget to consider the index offset by 1)
#	nameOptions.add_item("(select a player to remove)")
	#create the option list of players dynamically
#	for n in playerNames:
#		nameOptions.add_item(n)
	
	#connect to selecting a player name to remove
#	nameOptions.connect("item_selected",self,"_on_remove_player_name_selected",[playerNames])
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
