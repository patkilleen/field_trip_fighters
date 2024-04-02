extends Node

signal reset_bar_amount_increase_process
signal lock_circular_progress
signal unlock_circular_progress
signal bar_amount_increased

enum StateMachineType{
	
	DAMAGE_AMOUNT_INCREASE,
	FOCUS_AMOUNT_INCREASE	
	
}

enum ComboLevelState{
	START,
	NO_BAR_AMOUNT_INCREASE_SUBCOMBO1, # DON'T increase bar
	NO_BAR_AMOUNT_INCREASE_SUBCOMBO2, # DON'T increase bar
	BAR_AMOUNT_INCREASE, # increase bar
	DEFAULT
}

var hurtboxAreaResource = preload("res://HurtboxArea.gd")

const CURRENT_STATE_KEY  = "CURRENT_STATE_KEY" # ComboLevelState
const ATTACK_TYPE_KEY =  "ATTACK_TYPE_KEY" #MELEE/SPECIAL/TOOL
const NEXT_STATE_KEY =  "NEXT_STATE_KEY" # ComboLevelState

var GLOBALS = preload("res://Globals.gd")

export (StateMachineType) var stateMachineType = 0


var state = 0

var stateTransitionTables = []

var damageTransitionTable = [
#current state,				#hit command type, 				#next state
{CURRENT_STATE_KEY:ComboLevelState.START,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1},
{CURRENT_STATE_KEY:ComboLevelState.START,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.START,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.START,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO2},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO2,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO2,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO2,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO2,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1},
{CURRENT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},

{CURRENT_STATE_KEY:ComboLevelState.DEFAULT,ATTACK_TYPE_KEY:null, NEXT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1} #  the error handling state, where next state not found
]

var focusTransitionTable = [
#current state,				#hit command type, 				#next state
{CURRENT_STATE_KEY:ComboLevelState.START,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.START,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.START,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1},
{CURRENT_STATE_KEY:ComboLevelState.START,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO2},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO2,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO2,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO2,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1},
{CURRENT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO2,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE,	ATTACK_TYPE_KEY:GLOBALS.MELEE_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE,	ATTACK_TYPE_KEY:GLOBALS.SPECIAL_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},
{CURRENT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE,	ATTACK_TYPE_KEY:GLOBALS.TOOL_IX, NEXT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1},
{CURRENT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE,	ATTACK_TYPE_KEY:GLOBALS.OTHER_IX, NEXT_STATE_KEY:ComboLevelState.BAR_AMOUNT_INCREASE},

{CURRENT_STATE_KEY:ComboLevelState.DEFAULT,ATTACK_TYPE_KEY:null, NEXT_STATE_KEY:ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1} #  the error handling state, where next state not found
]


#number of hit (combo length) that reamined in the increase bar amount state
var consecutiveHits = 0 

var comboLevelUpMidComboFlag = false

#this can be set,  like when bar capacity is reached, to stop state machine
var increasingBarFlag = false
func _ready():
	stateTransitionTables.append(damageTransitionTable)
	stateTransitionTables.append(focusTransitionTable)

func _on_combo_started():
	state = ComboLevelState.START
	consecutiveHits = 0 
	comboLevelUpMidComboFlag =false
	#don't keep the increase process between combos. Gotta 
	#do long combos to cash in the combo level ups
	emit_signal("reset_bar_amount_increase_process")
	emit_signal("unlock_circular_progress")

#func _on_hitstun_changed(inHitstun):
#	if inHitstun:
#		_on_combo_started()
#	else:
#		_on_combo_finished()

func _on_opponent_hitstun_changed(inHitstun):
	if inHitstun:
		_on_combo_started()
	else:
		_on_combo_finished()
	
func _on_combo_finished():
	
	#reset the progress on combo finish
	emit_signal("reset_bar_amount_increase_process")
	emit_signal("unlock_circular_progress")
	pass
	
func _on_combo_level_up():
	comboLevelUpMidComboFlag = true
	
	#block any progress since levelup up mid combo
	emit_signal("lock_circular_progress")
	
func _on_hit(cmdType,victimHurtboxSubClass,affectsDmgStarFill): #type == melee, special, tool type from globals.gd
#func _on_hit(meleeFlag,specialFlag,toolFlag,victimHurtboxSubClass,affectsDmgStarFill): #type == melee, special, tool type from globals.gd



	#don't process bar amount increase if leveled-up mid combo
	if comboLevelUpMidComboFlag:
		return
	
	#also ignore any attack that ignored bar increase proration
	if not affectsDmgStarFill:
		return 
			
	if not increasingBarFlag:
		return
	if cmdType !=  GLOBALS.TOOL_IX and cmdType !=  GLOBALS.SPECIAL_IX and cmdType !=  GLOBALS.MELEE_IX:
		print("warning: in combo ui state machine, unknown hit command type: "+str(cmdType))
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
		print("failed to transition states in the combo handler of bar increase")
		return 

	#now we decide what ui elements to change based on current state and next state
	match(nextState):
		
		ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO1:
			
			emit_signal("reset_bar_amount_increase_process")		
			emit_signal("lock_circular_progress")		
			consecutiveHits=0
		ComboLevelState.NO_BAR_AMOUNT_INCREASE_SUBCOMBO2:
			emit_signal("reset_bar_amount_increase_process")		
			emit_signal("lock_circular_progress")		
			consecutiveHits=0
		ComboLevelState.BAR_AMOUNT_INCREASE:
			
			#don't count hitting invincible character toward consecutive hits
			#treat such a hit as just 1
			if hurtboxAreaResource.SUBCLASS_INVINCIBILITY == victimHurtboxSubClass:
				var oneTimeHitConsecutiveHitCount = 1
				emit_signal("bar_amount_increased",oneTimeHitConsecutiveHitCount)
			else:
				
				consecutiveHits = consecutiveHits +1
				emit_signal("bar_amount_increased",consecutiveHits)		
				
			emit_signal("unlock_circular_progress")
		_:#no transition goes to start state
			print("next state inthe bar increase combo handlerstate machine should not be the case: "+ str(nextState))
	state = nextState




















