extends HBoxContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (int) var subComboLevel = 0
var oldLvl = 0
var meleeRect = null
var specialRect = null
var toolRect = null

var rectArray = []

var inputedCmd = null

const DMG_TYPE = 0
const FOCUS_TYPE = 1

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	meleeRect=$melee
	specialRect=$special
	toolRect=$_tool
	rectArray.append(meleeRect)
	rectArray.append(specialRect)
	rectArray.append(toolRect)
	
	pass


func _on_sub_combo_level_changed(newSubLevel,cmd):
	inputedCmd=cmd
	setDamageSubComboLevel(newSubLevel)
	
func _on_focus_sub_combo_level_changed(newSubLevel,cmd):
	inputedCmd=cmd
	setFocusSubComboLevel(newSubLevel)


func clear():
	inputedCmd = null
	for slot in rectArray:
		slot.setMode(slot.Mode.EMPTY)
		slot.setPlayerCommand(null)
		
		slot.unselect()	
	oldLvl = 0
	
func selectSlot(ix):
	rectArray[ix %  rectArray.size()].select()
	
	for i in rectArray.size():
		if i == ix:
			rectArray[i].select()
		else:
			rectArray[i].unselect()
	
func enableCheckMark(ix,type):
	
	#limit the index to last element and must be greater or equal 0
	#ix = min(ix,rectArray.size()-1)
	if type == FOCUS_TYPE:
		rectArray[ix].setMode(rectArray[ix].Mode.FOCUS_SUCCESS)
	elif type == DMG_TYPE:
		rectArray[ix].setMode(rectArray[ix].Mode.DMG_SUCCESS)
	
	rectArray[ix].setPlayerCommand(inputedCmd)
	for i in range(ix+1,rectArray.size()):
		rectArray[i].setMode(rectArray[i].Mode.EMPTY)
		rectArray[i].setPlayerCommand(null)


func enableX(ix):
	
	#limit the index to last element and must be greater or equal 0
	#ix = min(ix,rectArray.size()-1)
	rectArray[ix].setMode(rectArray[ix].Mode.FAILURE)
	rectArray[ix].setPlayerCommand(inputedCmd)
	for i in range(ix+1,rectArray.size()):
		rectArray[i].setMode(rectArray[i].Mode.EMPTY)	
		rectArray[i].setPlayerCommand(null)
				
func getSubComboLevel():
	return subComboLevel

func setFocusSubComboLevel(lvl):
	_setSubComboLevel(lvl,FOCUS_TYPE)
	
func setDamageSubComboLevel(lvl):
	_setSubComboLevel(lvl,DMG_TYPE)
	
func _setSubComboLevel(lvl,type):
	if rectArray.empty():
		return
	#invalid arg checking
	if lvl < 0:
		lvl = 0

	subComboLevel=lvl
	
	var nextSlotIx =  (lvl) % rectArray.size()
	selectSlot(nextSlotIx)
	
	#combo landed in right order
	if (lvl > 0):
		
		#if  lvl == 1:
			
		enableCheckMark(lvl-1,type)  #PUT CHECH MARK IN RIGHT SLOT AND CLEAR THE NEXT SLOTS AFTER
		
		if lvl == 1 and oldLvl >= 1:
			
			#not case where doing melee + special + tool + melee?
			if oldLvl != 3:
				inputedCmd = null #make sure not to dislay command twice in 2 diff slots
				#it may be the case that we melee and messed up the special into tool or melee into special (put X where we messed up)
				enableX(oldLvl%3)
				
	else:
		#here we failed , so gotta decide where to put the x
		enableX(oldLvl%3)

	oldLvl = subComboLevel		
	