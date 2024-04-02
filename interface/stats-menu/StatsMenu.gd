extends Control
signal back

var GLOBALS = preload("res://Globals.gd")
var settingsItemResource = preload("res://interface/settings-menu/settingsItem.tscn")

var stats = null
var statsHBoxContainer = null

var focusedItem = null

var inputSelections = null
var backArrow = null
var nameIOHandler = null
func _ready():
		
	set_process(false)
	
func init(_stats,_nameIOHandler):
	inputSelections = $"StatsMenu/input-selections"
	
	inputSelections.connect("player_name_hero_stats_chosen",self,"_on_player_name_hero_stats_chosen")
	inputSelections.connect("hero_stats_chosen",self,"_on_hero_stats_chosen")

	nameIOHandler = _nameIOHandler
	stats = _stats
	statsHBoxContainer = $"StatsMenu/middlePane/scrollContainer/stats"
	
	inputSelections.init(_stats,nameIOHandler)
	
	backArrow = $"StatsMenu/Control/back-arrow"
	backArrow.connect("back",self,"emit_signal",["back"])#emit back signal when back arrow node goes back
	

func _on_player_name_hero_stats_chosen(selectedHero,selectedPlayerName):
	var statPairs = stats.getPlayerNameHeroStats(selectedPlayerName,selectedHero)
	displayStatPairs(statPairs)
	
func _on_hero_stats_chosen(selectedHero):
	var statPairs = stats.getHeroStats(selectedHero)
	displayStatPairs(statPairs)

func displayStatPairs(statPairs):
	var noStatsLabel = $"StatsMenu/middlePane/noStats"
	var scrollContainer = $"StatsMenu/middlePane/scrollContainer"
	if statPairs == null:
		
		noStatsLabel.visible = true
		scrollContainer.visible = false
		return
	else:
		noStatsLabel.visible = false
		scrollContainer.visible = true
	
	var keyIx = 0
	var valueIx = 1
	
	#delete all the old entries to replace with new ones
	for c in statsHBoxContainer.get_children():
		statsHBoxContainer.remove_child(c)
		c.queue_free()
	
	#iterate all the changeable settings and add to pane
	for i in statPairs.size():
		
		var pair = statPairs[i]
		var key = pair[keyIx]
		var value = pair[valueIx]
		
		#get the nice displayable name for entyr
		#var userFriendlyKey = stats.keyToUserFriendlyString(key)
		var userFriendlyKey = key
		var settingsItem = settingsItemResource.instance()
		#connect to when text is entered into box
		
		settingsItem.init2(userFriendlyKey,value)
		statsHBoxContainer.add_child(settingsItem)
		
		
#		settingsItem.lineEdit.connect("focus_entered",self,"_on_focus_in_setting_item",[settingsItem])
#		settingsItem.checkBox.connect("focus_entered",self,"_on_focus_in_setting_item",[settingsItem])


#called when options menu is left. save any changes made
func _on_back():
	if stats != null:
		stats.saveStats()
