extends HBoxContainer


var settingsSection =null
var settingsKey = null
var value = null
var settings = null

var nameLabel = null
var lineEdit = null
var checkBox = null

var valuetype = null
func _ready():
	
	pass
	
#init for read-only purposes
func init2(_text, _value):
	
	nameLabel = $"attribute-name"
	lineEdit = $LineEdit
	checkBox = $CheckBox
	
	nameLabel.text = _text
	
	value = _value
	valuetype = typeof(value) 
	
	checkBox.visible = false
	lineEdit.visible = true
	lineEdit.text = str(value)
	
	
#init with write-ability on the settings
func init(_text, _value,_settingsSection,_settingsKey,_settings):
	
	nameLabel = $"attribute-name"
	lineEdit = $LineEdit
	checkBox = $CheckBox
	
	nameLabel.text = _text
	
	value = _value
	valuetype = typeof(value) 
	
	#are we using checkboxes for booleans?
	if valuetype == TYPE_BOOL:
		checkBox.visible = true
		lineEdit.visible = false
		checkBox.pressed = value
		checkBox.connect("pressed",self,"_on_check_box_pressed")
	else: #using text editor for ints, floats, and strings
		checkBox.visible = false
		lineEdit.visible = true
		lineEdit.text = str(value)
		lineEdit.connect("text_entered",self,"_on_text_entered")
		
	
	
	settingsSection = _settingsSection
	
	settingsKey = _settingsKey
	
	settings = _settings
	
	
	
	
func resetText():
	#lineEdit.clear()
	#lineEdit.append_at_cursor(str(value))
	lineEdit.text = str(value)
	
func _on_check_box_pressed():
	var enableFlag  = checkBox.pressed
	value = bool(enableFlag)
	
	settings.setValue(settingsSection,settingsKey,value)
func _on_text_entered(new_text):
	
	
	match(valuetype):
		TYPE_BOOL:
			value=bool(new_text)
		TYPE_STRING:
			value=str(new_text) #should be arleady a string, but be consistent
		TYPE_INT:
			value=int(new_text)
		TYPE_REAL:
			value=float(new_text)
		_:
			print("unknown type ("+str(valuetype)+") when entering settings")
			
	settings.setValue(settingsSection,settingsKey,value)		
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
