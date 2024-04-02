extends Control
signal back
const GLOBALS = preload("res://Globals.gd")

export (Texture) var selectedNameIcon = null
export (Texture) var unselectedNameIcon = null
enum State{
	NO_NAME_SELECTED,
	NAME_SELECTED,
	ADDING_NAME,
	CHANGING_BUTTON_LAYOUT	
}
var backArrow = null

var buttonLayout=null
var nameHandler = null

var nameSelection_newNameButton=null
var nameSelection_deleteNameButton=null
var nameSelection_changeControlsButton=null
var addingName_confirm=null
var addingName_cancel=null

var newNameLineEdit = null
var nameSelected=null

var nameList = null

var nameSelectedIx = null

var nameSelectionNode = null
var addingNameNode=null

var state = State.NO_NAME_SELECTED

var inputDeviceIds = []
var controllerCursorIx=-1
func _ready():
	backArrow = $"Footers/back-arrow"
	backArrow.connect("back",self,"emit_signal",["back"])#emit back signal when back arrow node goes back
	
	buttonLayout =$"ControllerButtonLayout"
	buttonLayout.connect("back",self,"_on_button_layout_back")
	buttonLayout.connect("save",self,"_on_button_layout_save")
	
	nameSelection_changeControlsButton = $"Middle/nameSelection/buttons/changeControlsName"
	nameSelection_changeControlsButton.connect("pressed",self,"_on_change_name_control_scheme")
	
	nameSelection_deleteNameButton = $"Middle/nameSelection/buttons/deleteName"
	nameSelection_deleteNameButton.connect("pressed",self,"_on_delete_name")
	
	nameSelection_newNameButton = $"Middle/nameSelection/buttons/newName"
	nameSelection_newNameButton.connect("pressed",self,"_on_add_new_name")

	nameSelectionNode = $"Middle/nameSelection"
	addingNameNode=$"Middle/addingName"

	nameList = $"Middle/nameSelection/ItemList"
	nameList.connect("item_selected",self,"_on_name_selected")
	nameList.connect("nothing_selected",self,"_on_no_name_selected")
	
	addingName_confirm = $"Middle/addingName/buttons2/confirm"
	addingName_confirm.connect("pressed",self,"_on_confirm_add_name")
	
	addingName_cancel = $"Middle/addingName/buttons2/cancel"
	addingName_cancel.connect("pressed",self,"_on_cancel_add_name")
	
	newNameLineEdit = $"Middle/addingName/LineEdit"
	
	inputDeviceIds.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDeviceIds.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	
	pass 

func init(_nameHandler):
	
	nameHandler=_nameHandler
	nameSelectionNode.visible = true
	addingNameNode.visible = false
	
		#not visible by default, have to choose a name first
	nameSelection_changeControlsButton.visible = false
	nameSelection_deleteNameButton.visible = false
	
	#read names from file
	var names = nameHandler.readAllNames()
	
	#add names to list
	if names != null and names.size()>0:
		for _name in names:
			nameList.add_item(_name)
	
	unselectName()		
	pass


func _on_name_selected(ix):
	
	state = State.NAME_SELECTED
	nameSelectedIx=ix
	controllerCursorIx=ix
	nameSelected = nameList.get_item_text(ix)
	
	#set icon selected for selected item and disabled icon for all others
	#make options available when select a name 
	for i in nameList.get_item_count():
		if i == ix:
			nameList.set_item_icon(i,selectedNameIcon)
			
		else:
			nameList.set_item_icon(i,unselectedNameIcon)
	nameSelection_changeControlsButton.visible = true
	nameSelection_deleteNameButton.visible = true
	
func _on_no_name_selected():
	unselectName()
	
	
func _on_delete_name():
	#can't delete name if didn't select  name
	if nameSelected == null:
		return
	
	nameHandler.removeName(nameSelected)
	
	#remove the item and unselect
	nameList.remove_item(nameSelectedIx)
	unselectName()
	
func unselectName():
	nameSelectedIx=null
	nameSelected=null
	controllerCursorIx = -1
	nameList.unselect_all()
	state = State.NO_NAME_SELECTED
	#hide buttons that require name selected
	nameSelection_changeControlsButton.visible = false
	nameSelection_deleteNameButton.visible = false
	
	#set icon not selected for all itesm
	for i in nameList.get_item_count():
		nameList.set_item_icon(i,unselectedNameIcon)

	
func _on_change_name_control_scheme():
	
	#can't change control scheme if didn't select  name
	if nameSelected == null:
		return
		
	
	var inputRemapModel = nameHandler.readInputRemapModel(nameSelected)
	
	buttonLayout.visible = true
	buttonLayout.init(nameSelected,inputRemapModel)
	
	#can't go back from this screen until finish controller layout
	backArrow.disabledFlagInpudDeviceMap[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = true
	backArrow.disabledFlagInpudDeviceMap[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = true
	
	unselectName()
	
	state = State.CHANGING_BUTTON_LAYOUT
	
	
func _on_button_layout_save(pName,inputRemapModel):
	nameHandler.saveInputRemapModel(pName,inputRemapModel)
	pass
func _on_button_layout_back():
	buttonLayout.visible = false
	buttonLayout.disable()
	
	state = State.NO_NAME_SELECTED
	
	#can now go back to main menu, finished controller layout
	backArrow.disabledFlagInpudDeviceMap[GLOBALS.PLAYER1_INPUT_DEVICE_ID] = false
	backArrow.disabledFlagInpudDeviceMap[GLOBALS.PLAYER2_INPUT_DEVICE_ID] = false

func _on_add_new_name():
	#go to the add name view
	nameSelectionNode.visible = false
	addingNameNode.visible = true
	

	#unselect last selected name	
	unselectName()
	
	state = State.ADDING_NAME
		
	
	
	#go back to default name text for next tim
	newNameLineEdit.text = "name"
	
	
func _on_confirm_add_name():
	
	#go back to name list view
	nameSelectionNode.visible = true
	addingNameNode.visible = false
	
	var newName = newNameLineEdit.text
	
	#do not add duplicate names
	if not nameHandler.nameExists(newName):
		
		nameHandler.addNewName(newName)
	
		nameList.add_item(newName,unselectedNameIcon)

	state = State.NO_NAME_SELECTED
	pass
func _on_cancel_add_name():
	#go back to name list view
	nameSelectionNode.visible = true
	addingNameNode.visible = false
	
	
	state = State.NO_NAME_SELECTED
	pass
	
func _physics_process(delta):
	for deviceId in inputDeviceIds:
		
	
		if state == State.NAME_SELECTED or state == State.NO_NAME_SELECTED :
			
			if Input.is_action_just_pressed(deviceId+"_UP"):
				
				#no name selected?
				if controllerCursorIx == -1:
					controllerCursorIx=nameList.get_item_count()-1 #go to bottom of list
				else:
					controllerCursorIx = controllerCursorIx -1
				
				#-1 used as index to count as no name selected
				if controllerCursorIx == -1:
					
					_on_no_name_selected()
				else:	
					_on_name_selected(controllerCursorIx)
					
			elif Input.is_action_just_pressed(deviceId+"_DOWN"):
				#list name selected?
				if controllerCursorIx == nameList.get_item_count() -1:
					controllerCursorIx=-1 #go to start of list, non selected
				else:
					controllerCursorIx = controllerCursorIx +1
				
				#-1 used as index to count as no name selected
				if controllerCursorIx == -1:
					
					_on_no_name_selected()
				else:	
					_on_name_selected(controllerCursorIx)
		if state == State.NAME_SELECTED:
			if Input.is_action_just_pressed(deviceId+"_A"):			
				_on_change_name_control_scheme()