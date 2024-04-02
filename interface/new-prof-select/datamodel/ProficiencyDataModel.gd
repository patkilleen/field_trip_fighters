extends Node

const GLOBALS = preload("res://Globals.gd")
export (Texture) var defaultMinorProfIcon = null #texture to display for selecting a major class without hybrid

var majorProfs = []

var profPropertyDescriptions = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	
	var id = 0
	for c in self.get_children():
		
		if c is preload("res://interface/new-prof-select/datamodel/majorProficiency.gd"):
			majorProfs.append(c)
			c.id = id
			id = id +1
			
		
func loadProficiencyPropertyDescriptions():
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_CAN_LOW_BLOCK_IN_AIR] = "Can block low in the air"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_REGENERATE_GUARD_IN_AIR]="Regenerate guard in the air"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_GAIN_JUMP_FROM_ABILITY_CANCEL] = "Ability canceling gives an extra jump in the air"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_RECOVER_AIR_DASH_ON_BLOCK] = "Recover an air dash upon blocking in the air"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LOSE_AIR_DASH_AND_JUMP_ON_BLOCK] = "Lose your dash and jumps upon blocking in the air"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_RECOVER_AIR_DASH_ON_HIT] = "Hitting in the air recovers an air dash (at most once during a combo)"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_RECOVER_AIR_DASH_AND_JUMP_ON_TECH] = "Recover dash and jump upon tech'ing in the air"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_PERFECT_BLOCK_ABILITY_BAR_REGEN] = "You gain a small amount of Ability meter from perfect blocking"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_BAR_GAIN_BY_GRABBING_AUTORIPOSTER] = "Grabbing an auto-riposting opponent grants a small Ability meter increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_BAR_GAIN_BY_GRABBING_AUTORIPOSTER] = "Grabbing an auto-riposting opponent grants a medium Ability meter increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_BAR_GAIN_BY_GRABBING_AUTORIPOSTER] = "Grabbing an auto-riposting opponent grants a large Ability meter increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_GRAB_WHIF_PROVOKES_COOLDOWN] = "Whiffing a grab makes it go on cooldown"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_AIR_ANIMATION_AND_LANDING_LAG_CANCEL_COST_INCREASE] = "Small increase to (auto) Ability cancel cost of landing lag and air animations"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_AIR_ANIMATION_AND_LANDING_LAG_CANCEL_COST_INCREASE] = "Medium increase to (auto) Ability cancel cost of landing lag and air animations"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_AIR_ANIMATION_AND_LANDING_LAG_CANCEL_COST_INCREASE] = "Large increase to (auto) Ability cancel cost of landing lag and air animations"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_ONLY_1_JUMP] = "You have only 1 jump"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_NO_AIR_DASHING] = "You can't air dash"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_DONT_RECOVER_AIR_DASH_FROM_JUMPING] = "You don't recover air dash from jumping"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_CANT_DI_TECH] = "You can't apply directional influence to tech’s. All techs are in-place"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_TAKE_TRIPLE_DAMAGE_IN_STUN] = "You take triple damage while stunned"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_CANT_GRAB_WHILE_IN_AIR] = "You can't grab in the air"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_ABILITY_CANCELING_NO_RESET_STALE_MOVES] = "Stale moves (character dependent) are not reset by Ability canceling"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_PREVENT_GROUND_DASHING] = "You can't ground dash"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_BAR_GAIN_FROM_GUARD_BREAK] = "Small decrease to Ability meter gained from breaking opponent's guard"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_BAR_GAIN_FROM_GUARD_BREAK] = "Medium decrease to Ability meter gained from breaking opponent's guard"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_BAR_GAIN_FROM_GUARD_BREAK] = "Large decrease to Ability meter gained from breaking opponent's guard"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_BAR_GAIN_FROM_GUARD_BREAK] = "Small increase to Ability meter gained from breaking opponent's guard"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_BAR_GAIN_FROM_GUARD_BREAK] = "Medium increase to Ability meter gained from breaking opponent's guard"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_BAR_GAIN_FROM_GUARD_BREAK] = "Large increase to Ability meter gained from breaking opponent's guard"

	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_BAR_FEED_FROM_GUARD_BREAK] = "Small increase to Ability meter fed to opponent from getting guard broken"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCCREASE_TO_BAR_FEED_FROM_GUARD_BREAK] = "Medium increase to Ability meter fed to opponent from getting guard broken"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCCREASE_TO_BAR_FEED_FROM_GUARD_BREAK] = "Large increase to Ability meter fed to opponent from getting guard broken"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_BAR_FEED_FROM_GUARD_BREAK] = "Small decrease to Ability meter fed to opponent from getting guard broken"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_BAR_FEED_FROM_GUARD_BREAK] = "Medium decrease to Ability meter fed to opponent from getting guard broken"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_BAR_FEED_FROM_GUARD_BREAK] = "Large decrease to Ability meter fed to opponent from getting guard broken"

	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_AUTO_RIPOSTE_COST] = "Small auto riposte cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_AUTO_RIPOSTE_COST] = "Medium auto riposte cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_AUTO_RIPOSTE_COST] = "Large auto riposte cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_AUTO_RIPOSTE_COST] = "Small auto riposte cost decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_AUTO_RIPOSTE_COST] = "Medium auto riposte cost decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_AUTO_RIPOSTE_COST] = "Large auto riposte cost decrease"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_AUTO_ABILITY_CANCEL_COST] = "Small auto Ability cancel cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_AUTO_ABILITY_CANCEL_COST] = "Medium auto Ability cancel cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_AUTO_ABILITY_CANCEL_COST] = "Large auto Ability cancel cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_AUTO_ABILITY_CANCEL_COST] = "Small auto Ability cancel cost decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_AUTO_ABILITY_CANCEL_COST] = "Medium auto Ability cancel cost decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_AUTO_ABILITY_CANCEL_COST] = "Large auto Ability cancel cost decrease"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_GUARD_DAMAGE_DEALT] = "Small decrease to overall guard damage dealt"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_GUARD_DAMAGE_DEALT] = "Medium decrease to overall guard damage dealt"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_GUARD_DAMAGE_DEALT] = "Large decrease to overall guard damage dealt"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_GUARD_DAMAGE_DEALT] = "Small increase to overall guard damage dealt"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_GUARD_DAMAGE_DEALT] = "Medium increase to overall guard damage dealt"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_GUARD_DAMAGE_DEALT] = "Large increase to overall guard damage dealt"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT] = "Small decrease to additional guard damage dealt against airborne opponents"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT] = "Medium decrease to additional guard damage dealt against airborne opponents"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT] = "Large decrease to additional guard damage dealt against airborne opponents"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT] = "Small increase to additional guard damage dealt against airborne opponents"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT] = "Medium increase to additional guard damage dealt against airborne opponents"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT] = "Large increase to additional guard damage dealt against airborne opponents"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT] = "Small decrease to guard damage dealt against correct blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT] = "Medium decrease to guard damage dealt against correct blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT] = "Large decrease to guard damage dealt against correct blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT] = "Small increase to guard damage dealt against correct blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT] = "Medium increase to guard damage dealt against correct blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT] = "Large increase to guard damage dealt against correct blocks"
	
	
		
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT] = "Small decrease to guard damage dealt against incorrect blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT] = "Medium decrease to guard damage dealt against incorrect blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT] = "Large decrease to guard damage dealt against incorrect blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT] = "Small increase to guard damage dealt against incorrect blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT] = "Medium increase to guard damage dealt against incorrect blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT] = "Large increase to guard damage dealt against incorrect blocks"

	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_GUARD_DAMAGE_TAKEN] = "Small increase to overall guard damage taken"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_GUARD_DAMAGE_TAKEN] = "Medium increase to overall guard damage taken"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_GUARD_DAMAGE_TAKEN] = "Large increase to overall guard damage taken"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_GUARD_DAMAGE_TAKEN] = "Small decrease to overall guard damage taken"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_GUARD_DAMAGE_TAKEN] = "Medium decrease to overall guard damage taken"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_GUARD_DAMAGE_TAKEN] = "Large decrease to overall guard damage taken"

	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR] = "Small increase to additional guard damage taken while airborne"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR] = "Medium increase to additional guard damage taken while airborne"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR] = "Large increase to additional guard damage taken while airborne"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR] = "Small decrease to additional guard damage taken while airborne"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR] = "Medium decrease to additional guard damage taken while airborne"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR] = "Large decrease to additional guard damage taken while airborne"

	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN] = "Small increase to guard damage taken on correct blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN] = "Medium increase to guard damage taken on correct blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN] = "Large increase to guard damage taken on correct blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN] = "Small decrease to guard damage taken on correct blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN] = "Medium decrease to guard damage taken on correct blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN] = "Large decrease to guard damage taken on correct blocks"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN] = "Small increase to guard damage taken on incorrect blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN] = "Medium increase to guard damage taken on incorrect blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN] = "Large increase to guard damage taken on incorrect blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN] = "Small decrease to guard damage taken on incorrect blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN] = "Medium decrease to guard damage taken on incorrect blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN] = "Large decrease to guard damage taken on incorrect blocks"

	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_BLOCK_CHIP_DAMAGE_DEALT] = "Small decrease to block chip damage dealt"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_BLOCK_CHIP_DAMAGE_DEALT] = "Medium decrease to block chip damage dealt"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_BLOCK_CHIP_DAMAGE_DEALT] = "Large decrease to block chip damage dealt"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_BLOCK_CHIP_DAMAGE_DEALT] = "Small increase to block chip damage dealt"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_BLOCK_CHIP_DAMAGE_DEALT] = "Medium increase to block chip damage dealt"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_BLOCK_CHIP_DAMAGE_DEALT] = "Large increase to block chip damage dealt"


	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_GUARD_REGEN_RATE] = "Small decrease to guard HP regeneration rate"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_GUARD_REGEN_RATE] = "Medium decrease to guard HP regeneration rate"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_GUARD_REGEN_RATE] = "Large decrease to guard HP regeneration rate"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_GUARD_REGEN_RATE] = "Small increase to guard HP regeneration rate"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_GUARD_REGEN_RATE] = "Medium increase to guard HP regeneration rate"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_GUARD_REGEN_RATE] = "Large increase to guard HP regeneration rate"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES] = "Small decrease to Ability meter gain from Magic series (Melee + Special + Tool) combos"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES] = "Medium decrease to Ability meter gain from Magic series (Melee + Special + Tool) combos"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES] = "Large decrease to Ability meter gain from Magic series (Melee + Special + Tool) combos"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES] = "Small increase to Ability meter gain from Magic series (Melee + Special + Tool) combos"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES] = "Medium increase to Ability meter gain from Magic series (Melee + Special + Tool) combos"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES] = "Large increase to Ability meter gain from Magic series (Melee + Special + Tool) combos"

	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_RIPOST_COST] = "Small riposte cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_RIPOST_COST] = "Medium riposte cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_RIPOST_COST] = "Large riposte cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_RIPOST_COST] = "Small riposte cost decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_RIPOST_COST] = "Medium riposte cost decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_RIPOST_COST] = "Large riposte cost decrease"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_COUNTERRIPOST_COST] = "Small counter-riposte cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_COUNTERRIPOST_COST] = "Medium counter-riposte cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_COUNTERRIPOST_COST] = "Large counter-riposte cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_COUNTERRIPOST_COST] = "Small counter-riposte cost decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_COUNTERRIPOST_COST] = "Medium counter-riposte cost decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_COUNTERRIPOST_COST] = "Large counter-riposte cost decrease"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_TECH_COST] = "Small tech cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_TECH_COST] = "Medium tech cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_TECH_COST] = "Large tech cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_TECH_COST] = "Small tech cost decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_TECH_COST] = "Medium tech cost decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_TECH_COST] = "Large tech cost decrease"


	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_PUSH_BLOCK_COST] = "Small push-block cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_PUSH_BLOCK_COST] = "Medium push-block cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_PUSH_BLOCK_COST] = "Large push-block cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_PUSH_BLOCK_COST] = "Small push-block cost decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_PUSH_BLOCK_COST] = "Medium push-block cost decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_PUSH_BLOCK_COST] = "Large push-block cost decrease"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK] = "Small decrease to damage boost from Ability canceling a long combo"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK] ="Medium decrease to damage boost from Ability canceling a long combo"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK] = "Large decrease to damage boost from Ability canceling a long combo"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK] = "Small increase to damage boost from Ability canceling a long combo"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK] = "Medium increase to damage boost from Ability canceling a long combo"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK] = "Large increase to damage boost from Ability canceling a long combo"
	
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_ABILITY_CANCEL_COST] = "Small Ability cancel cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_ABILITY_CANCEL_COST] = "Medium Ability cancel cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_ABILITY_CANCEL_COST] = "Large Ability cancel cost increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_ABILITY_CANCEL_COST] = "Small Ability cancel cost decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_ABILITY_CANCEL_COST] = "Medium Ability cancel cost decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_ABILITY_CANCEL_COST] = "Large Ability cancel cost decrease"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_TO_GRAB_COOLDOWN] = "Small grab cooldown duration increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_TO_GRAB_COOLDOWN] = "Medium grab cooldown duration increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_TO_GRAB_COOLDOWN] = "Large grab cooldown duration increase"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_DECREASE_TO_GRAB_COOLDOWN] = "Small grab cooldown duration decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_DECREASE_TO_GRAB_COOLDOWN] = "Medium grab cooldown duration decrease"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_DECREASE_TO_GRAB_COOLDOWN] = "Large grab cooldown duration decrease"
	
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR] = "Small decrease to Ability meter gain from Magic series (Melee + Special + Tool) combos while airborne"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR] = "Medium decrease to Ability meter gain from Magic series (Melee + Special + Tool) combos while airborne"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR] = "Large decrease to Ability meter gain from Magic series (Melee + Special + Tool) combos while airborne"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR] = "Small increase to Ability meter gain from Magic series (Melee + Special + Tool) combos while airborne"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR] ="Medium increase to Ability meter gain from Magic series (Melee + Special + Tool) combos while airborne"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR] = "Large increase to Ability meter gain from Magic series (Melee + Special + Tool) combos while airborne"

	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_BAR_COST_FROM_MISSING_AUTORIPOSTE] = "Missing an auto-riposte costs a small amount of Ability meter"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_BAR_COST_FROM_MISSING_AUTORIPOSTE] = "Missing an auto-riposte costs a medium amount of Ability meter"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_BAR_COST_FROM_MISSING_AUTORIPOSTE] = "Missing an auto-riposte costs a large amount of Ability meter"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_GRAB_COOLDOWN_REFRESHED_ON_AUTO_ABILITY_CANCEL] = "Auto Ability cancelling refreshes grab cooldown"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_GRAB_COOLDOWN_REFRESHED_ON_ABILITY_CANCEL] = "Ability cancelling refreshes grab cooldown"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_DECREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN] = "Small increase to block chip damage taken"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_DECREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN] = "Medium increase to block chip damage taken"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_DECREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN] = "Large increase to block chip damage taken"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_INCREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN] = "Small decrease to block chip damage taken"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_MEDIUM_INCREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN] = "Medium decrease to block chip damage taken"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_LARGE_INCREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN] = "Large decrease to block chip damage taken"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_INCREASE_COOLDOWN_TO_AIR_GRAB] = "Small increase to grab cooldown duration while airborne"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_MEDIUM_INCREASE_COOLDOWN_TO_AIR_GRAB] = "Medium increase to grab cooldown duration while airborne"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LARGE_INCREASE_COOLDOWN_TO_AIR_GRAB] = "Large increase to grab cooldown duration while airborne"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_PREVENT_BLOCKING_GROUND_ATTACKS_IN_AIR] = "You can't block ground attacks in the air"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_PREVENT_INCORRECT_BLOCKING] = "Incorrect blocks doesn't guard, you get hit."

	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_SMALL_SETBACK_DECREASE_TO_SPAM_HISTUN_ON_ABILITY_CANCEL] = "Hitstun duration reduction from hitting with the same attack is setback less from ability canceling"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_SMALL_SETBACK_INCREASE_TO_SPAM_HISTUN_ON_ABILITY_CANCEL] = "Hitstun duration reduction from hitting with the same attack is setback more from ability canceling"
	
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_YOU_CAN_DASH_OR_JUMP_OUT_OF_PUSHBLOCK]="You can dash and jump out of push-block"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_PERFECT_BLOCK_REGENS_GUARD]="Perfect blocking regenerate a bit of guard"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_LOSE_TECH_INVINCIBILITY]="You lose tech invincibility"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_ENOURMOUS_BLOCK_CHIP_DAMAGE]="You take enormous block chip damage"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_COUNTER_RIPOST_STEAL_ABILITY_BAR]="Counter riposting drains and steals the opponent's ability bar"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_CANT_AUTORIPOSTE]="You can't auto riposte"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_GAIN_NO_BAR_FROM_MAGIC_SERIES]="Gain no ability bar from magic series combos"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.GOOD_GAIN_ADDITIONAL_GRAB_CHARGE]="You gain an additional grab charge"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_CANT_GRAB]="You can't grab"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_50_PRECENT_INCORRECT_BLOCK_GUARD_DMG_REDUCTION]="Deal 50% less guard damage for incorrect blocks"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_ABILITY_CANCEL_ON_HIT_ONLY]="You can only ability cancel after hitting an opponent"
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_DONT_TURN_AROUND_IN_AIR]="You don't turn around in the air after a cross-up. You have to land first."
	profPropertyDescriptions[GLOBALS.ProficiencyPropertyID.BAD_CANT_PUSH_BLOCK]="You can't push-block."
	
	
	

	pass # Replace with function body.

func getMajorProficiency(majorClassid):
	
	if majorClassid < 0 or majorClassid >= majorProfs.size():
		return null
		
	return majorProfs[majorClassid]

func getProficiencyProperties(majorClassid,isAdvantage):
	
	var res = []
	var majorClass =getMajorProficiency(majorClassid)
	
	if majorClass != null:
		
		
		var minorProfSet = majorClass.getMinorProficiencySet(isAdvantage)
		
		#by design, when it's disadvantage, only negative properties are expected
		#when it's advantage, then it could be all advantage (pure major class)
		#or a mix of both when doing hybrid build		
		if isAdvantage:
			
			
			var minorProfs =minorProfSet.getMinorProficiencies()
			#return only teh advantage properties of mionor prof set
			#as major class has all good benifits, gotta iterate over every minor prof
			#and get good properties
			
			for mp in minorProfs:
				var goodProperties = mp.getGoodProperties()
				
				#iterate over the propoerites and add to result
				for goodProp in goodProperties:
					res.append(goodProp)
		else:#disadvantage
			var minorProfs =minorProfSet.getMinorProficiencies()

			for mp in minorProfs:
				var badProperties = mp.getBadProperties()
				
				#iterate over the propoerites and add to result
				for badProp in badProperties:
					res.append(badProp)	
	return res			
				
				
func getMinorProficiencies(majorClassid,isAdvantage):
	
	var res = []
	var majorClass =getMajorProficiency(majorClassid)
	
	if majorClass != null:	
		
		res =  majorClass.getMinorProficiencySet(isAdvantage)
				
	return res
	
func getMinorProficiency(majorClassid,minorClassId,isAdvantage):
	
	var res = null
	var majorClass =getMajorProficiency(majorClassid)
	
	if majorClass != null:	
		
		var minorProfs =  majorClass.getMinorProficiencySet(isAdvantage)
		
		return minorProfs[minorClassId]
				
	return res
				
func getAllProficiencyBuildProperties(prof1MajorClassIxSelect,prof1MinorClassIxSelect,prof2MajorClassIxSelect,prof2MinorClassIxSelect):

	var allProfBuildProperties = []
	
	var propMap = {}
	#chose two  major prof sets (advantage + disadvantage)?
	if prof1MinorClassIxSelect  == -1:

		#populate the list of properites
		var isAdvantage = true
		var minorProfs = getMinorProficiencies(prof1MajorClassIxSelect,isAdvantage)
	
		#iterate over all minor profs
		for mp in minorProfs:

			var props = mp.getGoodProperties()
				
			#iterate over the properties
			for prop in props:
				
				#only add the property if it hasn't already been added or if stacking the same property twice is fine				
				if (not propMap.has(prop.id)) or prop.stacks:
					allProfBuildProperties.append(prop)
					propMap[prop.id] = null
		isAdvantage = false
		minorProfs = getMinorProficiencies(prof2MajorClassIxSelect,isAdvantage)
	
		#iterate over all minor profs
		for mp in minorProfs:

			var props = mp.getAllProperties()
				
			#iterate over the properties
			for prop in props:
				#only add the property if it hasn't already been added or if stacking the same property twice is fine				
				if (not propMap.has(prop.id)) or prop.stacks:
					allProfBuildProperties.append(prop)
					propMap[prop.id] = null
	else:
		
		#populate the list of properites
		var isAdvantage = true
		var minorProfs = getMinorProficiencies(prof1MajorClassIxSelect,isAdvantage)	
		
		
		#buggy case? this should be a hack around to stop the array out of bounds
		#i think it occurs when generalizst taken and then proficiencies unsulected
		#and what not in training
		if prof1MinorClassIxSelect >= minorProfs.size():
			return 
			
		var minorProf1 =minorProfs[prof1MinorClassIxSelect]
		isAdvantage = false
		minorProfs = getMinorProficiencies(prof2MajorClassIxSelect,isAdvantage)
		var minorProf2 =minorProfs[prof2MinorClassIxSelect]
		
		
		var props = minorProf1.getAllProperties()
			
		#iterate over the properties
		for prop in props:
			#only add the property if it hasn't already been added or if stacking the same property twice is fine							
			if (not propMap.has(prop.id)) or prop.stacks:
				allProfBuildProperties.append(prop)
				propMap[prop.id] = null
		
		props = minorProf2.getAllProperties()
			
		#iterate over the properties
		for prop in props:
			#only add the property if it hasn't already been added or if stacking the same property twice is fine							
			if (not propMap.has(prop.id)) or prop.stacks:
				allProfBuildProperties.append(prop)
				propMap[prop.id] = null
	
	return allProfBuildProperties
				
				
func getProficiencySetName(majorIx,minorIx,isAdvantage):
	
	if majorIx== null or minorIx== null:
		return ""
		
	#major class selected?
	if minorIx == -1:
		
		#return major class name
		var majorProf = getMajorProficiency(majorIx)
		return majorProf.profName
		
	else:
		#return name of minor class
		#var isAdvantage = true
		var minorProf = getMinorProficiency(majorIx,minorIx,isAdvantage)
		return minorProf.profName
				
				
func getProficiencySetTexture(majorIx,minorIx,isAdvantage):
	if majorIx== null or minorIx== null:
		return null
	#major class selected?
	if minorIx == -1:
		
		#return major class name
		var majorProf = getMajorProficiency(majorIx)
		return majorProf.icon
		
	else:
		#return name of minor class
		#var isAdvantage = true
		var minorProf = getMinorProficiency(majorIx,minorIx,isAdvantage)
		return minorProf.icon
				
				
				
				
				
				
				
func getProficiencyPropertyDescription(propId):
	if propId == null or not profPropertyDescriptions.has(propId):
		return ""
	return profPropertyDescriptions[propId]