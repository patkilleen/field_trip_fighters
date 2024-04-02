extends Control

signal back
var GLOBALS = preload("res://Globals.gd")
var settingsItemResource = preload("res://interface/settings-menu/settingsItem.tscn")

var settings = null
var settingsHBoxContainer = null

var restoreDefaultsButton = null
var focusedItem = null

var backArrow = null
func _ready():
		
	set_process(false)
	
func init(_settings):
	
	#settingsHBoxContainer = $Settings/leftPane/scrollContainer/settings
	settingsHBoxContainer = $"Settings/middlePane/scrollContainer/settings"
	settings = _settings
	
	restoreDefaultsButton = $"Settings/leftPane/Button"
	
	if not restoreDefaultsButton.is_connected("pressed",self,"_on_default_button_pressed"):
		restoreDefaultsButton.connect("pressed",self,"_on_default_button_pressed")
	var userSettingTriples = settings.getUserChangeableSettingTriples()
	
	#iterate all the changeable settings and add to pane
	for i in userSettingTriples.size():
		
		var triple = userSettingTriples[i]
		var section = triple[settings.SECTION_IX]

		#only process stettings that can be changed by user
		if (section == settings.PERSISTENT_USER_SETTINGS_SECTION) or (section == settings.TEMP_USER_SETTINGS_SECTION):
			
			var key = triple[settings.KEY_IX]
			var value = triple[settings.VALUE_IX]
			
			#get the nice displayable name for entyr
			var userFriendlyKey = settings.keyToUserFriendlyString(key)
			
			var settingsItem = settingsItemResource.instance()
			#connect to when text is entered into box
			
			settingsItem.init(userFriendlyKey,value,section,key,settings)
			settingsHBoxContainer.add_child(settingsItem)
			
			
			settingsItem.lineEdit.connect("focus_entered",self,"_on_focus_in_setting_item",[settingsItem])
			settingsItem.checkBox.connect("focus_entered",self,"_on_focus_in_setting_item",[settingsItem])
			
	
	backArrow = $"Settings/Control/back-arrow"
	if not backArrow.is_connected("back",self,"emit_signal"):
		backArrow.connect("back",self,"emit_signal",["back"])#emit back signal when back arrow node goes back
	

#called when text entered into settings item
func _on_focus_in_setting_item(settingsItem):
	#first time changing an item?
	if focusedItem == null:
		focusedItem = settingsItem
	#changing item we focused on?
	elif focusedItem == settingsItem:
		pass # do nothing
	else: #new item is click on, undo the unsaved (no pressed enter) wok on last focused item
		focusedItem.resetText()
		focusedItem = settingsItem
	
func _on_default_button_pressed():
	
	if settings != null:
		settings.restoreDefaults()
		
		#delete all the old entries to replace with new ones
		for c in settingsHBoxContainer.get_children():
			settingsHBoxContainer.remove_child(c)
			c.queue_free()
		
		
		init(settings)
#called when options menu is left. save any changes made
func _on_back():
	if settings != null:
		settings.saveSettings()
