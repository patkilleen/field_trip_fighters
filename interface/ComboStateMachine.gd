extends Node

enum StateMachineType{
	
	DAMAGE_COMBO_LEVEL,
	FOCUS_COMBO_LEVEL,
	DAMAGE_AMOUNT_INCREASE,
	FOCUS_AMOUNT_INCREASE	
	
}

enum ComboLevelState{
	EMTPY_SUBLEVEL
	SUBLEVEL1,
	SUBLEVEL2,
	SUBLEVEL3,
	DEFAULT
}


const CURRENT_STATE_KEY  = "CURRENT_STATE_KEY" # ComboLevelState
const ATTACK_TYPE_KEY =  "ATTACK_TYPE_KEY" #MELEE/SPECIAL/TOOL
const NEXT_STATE_KEY =  "NEXT_STATE_KEY" # ComboLevelState

var GLOBALS = preload("res://Globals.gd")

export (StateMachineType) var stateMachineType = 0


var state = 0

var stateTransitionTables = []

var damageComboLevelTransitionTable = [
#current state,				#hit command type, 				#next state
{CURRENT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.SUBLEVEL1},
{CURRENT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL1,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.SUBLEVEL1},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL1,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.SUBLEVEL2},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL1,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL1,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL2,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.SUBLEVEL1},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL2,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL2,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.SUBLEVEL3},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL2,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL3,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.SUBLEVEL1},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL3,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL3,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL3,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.DEFAULT,ATTACK_TYPE_KEY:null, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL} #  the error handling state, where next state not found
]

var focusComboLevelTransitionTable = [
#current state,				#hit command type, 				#next state
{CURRENT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.SUBLEVEL1},
{CURRENT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL1,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL1,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.SUBLEVEL2},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL1,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.SUBLEVEL1},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL1,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL2,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.SUBLEVEL3},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL2,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL2,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.SUBLEVEL1},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL2,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL3,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL3,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL3,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.SUBLEVEL1},
{CURRENT_STATE_KEY:ComboLevelState.SUBLEVEL3,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL},
{CURRENT_STATE_KEY:ComboLevelState.DEFAULT,ATTACK_TYPE_KEY:null, NEXT_STATE_KEY:ComboLevelState.EMTPY_SUBLEVEL} #  the error handling state, where next state not found
]
func _ready():
	stateTransitionTables.append(damageComboLevelTransitionTable)
	stateTransitionTables.append(focusComboLevelTransitionTable)
	stateTransitionTables.append(null)
	stateTransitionTables.append(null)

func _on_combo_started():
	state = ComboLevelState.EMTPY_SUBLEVEL
	
	var parent = get_parent()
	
	
	#parent.checkMarkRect.visible = false
	#reset the progress star
	parent.circularProgessStar.resetProgress()
	
	parent.starArray.numberOfStars = 0

func _on_hitstun_changed(inHitstun):
	if inHitstun:
		_on_combo_started()
	else:
		_on_combo_finished()
func _on_combo_finished():
	
	pass
func _on_hit(cmdType,hurtBoxSubClass,affectsDmgStarFill): #type == melee, special, tool type from globals.gd
#func _on_hit(meleeFlag,specialFlag,toolFlag,hurtBoxSubClass,affectsDmgStarFill): #type == melee, special, tool type from globals.gd


	if cmdType !=  GLOBALS.TOOL_IX and cmdType !=  GLOBALS.SPECIAL_IX and cmdType !=  GLOBALS.MELEE_IX:
	#if not meleeFlag and not specialFlag and not toolFlag:
		print("warning: in combo ui state machine, unknown hit command type")
		#deafault widl card to go back into empty level state
		cmdType = GLOBALS.OTHER_IX
		
	var stateTransitionTable = stateTransitionTables[stateMachineType]
	
	var nextState = null
	var targetState = null
	#iterate the state transition table. we want to find next state given the command type
	for transition in stateTransitionTable:
	
		
		targetState = transition[CURRENT_STATE_KEY]
		
		#found our current state?
		if targetState == state:
			
			var targetAttackType = transition[ATTACK_TYPE_KEY]
			#found the transition associated to attack type hitting?
			if targetAttackType == cmdType:
				nextState = transition[NEXT_STATE_KEY]
				break
			
	
	if targetState == ComboLevelState.DEFAULT:
		print("failed to transition states in combo ui")
		return 

	var parent = get_parent()
	
	
		
	#now we decide what ui elements to change based on current state and next state
	match(nextState):
		
		ComboLevelState.EMTPY_SUBLEVEL:
				
		#	parent.checkMarkRect.visible = false
			#reset the progress star
			parent.circularProgessStar.resetProgress()
			
		ComboLevelState.SUBLEVEL1:
		#	parent.checkMarkRect.visible = true
			parent.circularProgessStar.fillPart1()
			
		ComboLevelState.SUBLEVEL2:
		#	parent.checkMarkRect.visible = true
			parent.circularProgessStar.fillPart2()
		ComboLevelState.SUBLEVEL3:
		#	parent.checkMarkRect.visible = true
			parent.circularProgessStar.fillCompletly()
			parent.starArray.numberOfStars = parent.starArray.numberOfStars + 1
		_:
			print("unkonwn state in comob ui state machine")
	state = nextState


#call when the other type of combo level occurs to reset the circular progress
#example, a reverse beat occured so this start (magic sereis) resets
func _on_opposite_combo_level_changed(lvl):
	
	if lvl != 0:
		state = ComboLevelState.EMTPY_SUBLEVEL
		
		var parent = get_parent()
		
		
		#parent.checkMarkRect.visible = false
		#reset the progress star
		parent.circularProgessStar.resetProgress()



















