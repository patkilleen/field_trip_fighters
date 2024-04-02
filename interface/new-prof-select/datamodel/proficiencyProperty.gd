extends Node

#same sas GLOBALS
enum ProficiencyPropertyID{
	GOOD_CAN_LOW_BLOCK_IN_AIR,
	GOOD_REGENERATE_GUARD_IN_AIR,
	GOOD_GAIN_JUMP_FROM_ABILITY_CANCEL,
	GOOD_RECOVER_AIR_DASH_ON_BLOCK,
	BAD_LOSE_AIR_DASH_AND_JUMP_ON_BLOCK,
	GOOD_RECOVER_AIR_DASH_ON_HIT,
	GOOD_RECOVER_AIR_DASH_AND_JUMP_ON_TECH,
	GOOD_PERFECT_BLOCK_ABILITY_BAR_REGEN,
	GOOD_SMALL_BAR_GAIN_BY_GRABBING_AUTORIPOSTER,
	GOOD_MEDIUM_BAR_GAIN_BY_GRABBING_AUTORIPOSTER,
	GOOD_LARGE_BAR_GAIN_BY_GRABBING_AUTORIPOSTER,
	BAD_GRAB_WHIF_PROVOKES_COOLDOWN,
	BAD_SMALL_AIR_ANIMATION_AND_LANDING_LAG_CANCEL_COST_INCREASE,
	BAD_MEDIUM_AIR_ANIMATION_AND_LANDING_LAG_CANCEL_COST_INCREASE,
	BAD_LARGE_AIR_ANIMATION_AND_LANDING_LAG_CANCEL_COST_INCREASE,
	BAD_ONLY_1_JUMP,
	BAD_NO_AIR_DASHING,
	BAD_DONT_RECOVER_AIR_DASH_FROM_JUMPING,
	BAD_CANT_DI_TECH,
	BAD_TAKE_TRIPLE_DAMAGE_IN_STUN,
	BAD_CANT_GRAB_WHILE_IN_AIR,
	BAD_ABILITY_CANCELING_NO_RESET_STALE_MOVES,
	#GAURD BREAK BAR GAIN
	BAD_SMALL_DECREASE_TO_BAR_GAIN_FROM_GUARD_BREAK,
	BAD_MEDIUM_DECREASE_TO_BAR_GAIN_FROM_GUARD_BREAK,
	BAD_LARGE_DECREASE_TO_BAR_GAIN_FROM_GUARD_BREAK,
	GOOD_SMALL_INCREASE_TO_BAR_GAIN_FROM_GUARD_BREAK,
	GOOD_MEDIUM_INCREASE_TO_BAR_GAIN_FROM_GUARD_BREAK,
	GOOD_LARGE_INCREASE_TO_BAR_GAIN_FROM_GUARD_BREAK,
	#GAURD BREAK BAR FEED
	BAD_SMALL_INCREASE_TO_BAR_FEED_FROM_GUARD_BREAK,
	BAD_MEDIUM_INCCREASE_TO_BAR_FEED_FROM_GUARD_BREAK,
	BAD_LARGE_INCCREASE_TO_BAR_FEED_FROM_GUARD_BREAK,
	GOOD_SMALL_DECREASE_TO_BAR_FEED_FROM_GUARD_BREAK,
	GOOD_MEDIUM_DECREASE_TO_BAR_FEED_FROM_GUARD_BREAK,
	GOOD_LARGE_DECREASE_TO_BAR_FEED_FROM_GUARD_BREAK,
	#AUTO RIPOST COST
	BAD_SMALL_INCREASE_TO_AUTO_RIPOSTE_COST,
	BAD_MEDIUM_INCREASE_TO_AUTO_RIPOSTE_COST,
	BAD_LARGE_INCREASE_TO_AUTO_RIPOSTE_COST,
	GOOD_SMALL_DECREASE_TO_AUTO_RIPOSTE_COST,
	GOOD_MEDIUM_DECREASE_TO_AUTO_RIPOSTE_COST,
	GOOD_LARGE_DECREASE_TO_AUTO_RIPOSTE_COST,
	#AUTO ABILITY CANCEL COST
	BAD_SMALL_INCREASE_TO_AUTO_ABILITY_CANCEL_COST,
	BAD_MEDIUM_INCREASE_TO_AUTO_ABILITY_CANCEL_COST,
	BAD_LARGE_INCREASE_TO_AUTO_ABILITY_CANCEL_COST,
	GOOD_SMALL_DECREASE_TO_AUTO_ABILITY_CANCEL_COST,
	GOOD_MEDIUM_DECREASE_TO_AUTO_ABILITY_CANCEL_COST,
	GOOD_LARGE_DECREASE_TO_AUTO_ABILITY_CANCEL_COST,
	#GUARD DAMAGE DEALT
	BAD_SMALL_DECREASE_TO_GUARD_DAMAGE_DEALT,
	BAD_MEDIUM_DECREASE_TO_GUARD_DAMAGE_DEALT,
	BAD_LARGE_DECREASE_TO_GUARD_DAMAGE_DEALT,
	GOOD_SMALL_INCREASE_TO_GUARD_DAMAGE_DEALT,
	GOOD_MEDIUM_INCREASE_TO_GUARD_DAMAGE_DEALT,
	GOOD_LARGE_INCREASE_TO_GUARD_DAMAGE_DEALT,
	#GUARD DAMAGE DEALT TO AIR OPPONENT
	BAD_SMALL_DECREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT,
	BAD_MEDIUM_DECREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT,
	BAD_LARGE_DECREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT,
	GOOD_SMALL_INCREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT,
	GOOD_MEDIUM_INCREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT,
	GOOD_LARGE_INCREASE_TO_GUARD_DAMAGE_DEALT_VS_AIR_OPPONENT,
	#CORRECT_BLOCK GUARD DAMAGE DEALT
	BAD_SMALL_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT,
	BAD_MEDIUM_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT,
	BAD_LARGE_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT,
	GOOD_SMALL_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT,
	GOOD_MEDIUM_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT,
	GOOD_LARGE_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_DEALT,
	#INCORRECT_BLOCK GUARD DAMAGE DEALT
	BAD_SMALL_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT,
	BAD_MEDIUM_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT,
	BAD_LARGE_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT,
	GOOD_SMALL_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT,
	GOOD_MEDIUM_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT,
	GOOD_LARGE_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_DEALT,
	#GUARD DAMAGE TAKEN
	BAD_SMALL_INCREASE_TO_GUARD_DAMAGE_TAKEN,
	BAD_MEDIUM_INCREASE_TO_GUARD_DAMAGE_TAKEN,
	BAD_LARGE_INCREASE_TO_GUARD_DAMAGE_TAKEN,
	GOOD_SMALL_DECREASE_TO_GUARD_DAMAGE_TAKEN,
	GOOD_MEDIUM_DECREASE_TO_GUARD_DAMAGE_TAKEN,
	GOOD_LARGE_DECREASE_TO_GUARD_DAMAGE_TAKEN,
	#GUARD DAMAGE TAKEN IN AIR
	BAD_SMALL_INCREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR,
	BAD_MEDIUM_INCREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR,
	BAD_LARGE_INCREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR,
	GOOD_SMALL_DECREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR,
	GOOD_MEDIUM_DECREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR,
	GOOD_LARGE_DECREASE_TO_GUARD_DAMAGE_TAKEN_IN_AIR,
	#CORRECT_BLOCK GUARD DAMAGE TAKEN
	BAD_SMALL_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN,
	BAD_MEDIUM_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN,
	BAD_LARGE_INCREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN,
	GOOD_SMALL_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN,
	GOOD_MEDIUM_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN,
	GOOD_LARGE_DECREASE_TO_CORRECT_BLOCK_GUARD_DAMAGE_TAKEN,
	#INCORRECT_BLOCK GUARD DAMAGE TAKEN
	BAD_SMALL_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN,
	BAD_MEDIUM_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN,
	BAD_LARGE_INCREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN,
	GOOD_SMALL_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN,
	GOOD_MEDIUM_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN,
	GOOD_LARGE_DECREASE_TO_INCORRECT_BLOCK_GUARD_DAMAGE_TAKEN,
	#BLOCK CHIP DAMAGE DEALT
	BAD_SMALL_DECREASE_TO_BLOCK_CHIP_DAMAGE_DEALT,
	BAD_MEDIUM_DECREASE_TO_BLOCK_CHIP_DAMAGE_DEALT,
	BAD_LARGE_DECREASE_TO_BLOCK_CHIP_DAMAGE_DEALT,
	GOOD_SMALL_INCREASE_TO_BLOCK_CHIP_DAMAGE_DEALT,
	GOOD_MEDIUM_INCREASE_TO_BLOCK_CHIP_DAMAGE_DEALT,
	GOOD_LARGE_INCREASE_TO_BLOCK_CHIP_DAMAGE_DEALT,
	#GUARD REGEN RATE
	BAD_SMALL_DECREASE_TO_GUARD_REGEN_RATE,
	BAD_MEDIUM_DECREASE_TO_GUARD_REGEN_RATE,
	BAD_LARGE_DECREASE_TO_GUARD_REGEN_RATE,
	GOOD_SMALL_INCREASE_TO_GUARD_REGEN_RATE,
	GOOD_MEDIUM_INCREASE_TO_GUARD_REGEN_RATE,
	GOOD_LARGE_INCREASE_TO_GUARD_REGEN_RATE,
	#MAGIC SEREIS BAR GAIN
	BAD_SMALL_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES,
	BAD_MEDIUM_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES,
	BAD_LARGE_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES,
	GOOD_SMALL_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES,
	GOOD_MEDIUM_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES,
	GOOD_LARGE_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES,
	#RIPOST COST
	BAD_SMALL_INCREASE_TO_RIPOST_COST,
	BAD_MEDIUM_INCREASE_TO_RIPOST_COST,
	BAD_LARGE_INCREASE_TO_RIPOST_COST,
	GOOD_SMALL_DECREASE_TO_RIPOST_COST,
	GOOD_MEDIUM_DECREASE_TO_RIPOST_COST,
	GOOD_LARGE_DECREASE_TO_RIPOST_COST,
	#counter RIPOST COST
	BAD_SMALL_INCREASE_TO_COUNTERRIPOST_COST,
	BAD_MEDIUM_INCREASE_TO_COUNTERRIPOST_COST,
	BAD_LARGE_INCREASE_TO_COUNTERRIPOST_COST,
	GOOD_SMALL_DECREASE_TO_COUNTERRIPOST_COST,
	GOOD_MEDIUM_DECREASE_TO_COUNTERRIPOST_COST,
	GOOD_LARGE_DECREASE_TO_COUNTERRIPOST_COST,
	#TECH COST
	BAD_SMALL_INCREASE_TO_TECH_COST,
	BAD_MEDIUM_INCREASE_TO_TECH_COST,
	BAD_LARGE_INCREASE_TO_TECH_COST,
	GOOD_SMALL_DECREASE_TO_TECH_COST,
	GOOD_MEDIUM_DECREASE_TO_TECH_COST,
	GOOD_LARGE_DECREASE_TO_TECH_COST,
	#PUSH BLOCK COST
	BAD_SMALL_INCREASE_TO_PUSH_BLOCK_COST,
	BAD_MEDIUM_INCREASE_TO_PUSH_BLOCK_COST,
	BAD_LARGE_INCREASE_TO_PUSH_BLOCK_COST,
	GOOD_SMALL_DECREASE_TO_PUSH_BLOCK_COST,
	GOOD_MEDIUM_DECREASE_TO_PUSH_BLOCK_COST,
	GOOD_LARGE_DECREASE_TO_PUSH_BLOCK_COST,
	#ABILITY CANCELING DMG PRORATION
	BAD_SMALL_DECREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK,
	BAD_MEDIUM_DECREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK,
	BAD_LARGE_DECREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK,
	GOOD_SMALL_INCREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK,
	GOOD_MEDIUM_INCREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK,
	GOOD_LARGE_INCREASE_TO_ABILITY_CANCEL_DMG_PRORATION_SET_BACK,
	#ABILITY CANCELING COST
	BAD_SMALL_INCREASE_TO_ABILITY_CANCEL_COST,
	BAD_MEDIUM_INCREASE_TO_ABILITY_CANCEL_COST,
	BAD_LARGE_INCREASE_TO_ABILITY_CANCEL_COST,
	GOOD_SMALL_DECREASE_TO_ABILITY_CANCEL_COST,
	GOOD_MEDIUM_DECREASE_TO_ABILITY_CANCEL_COST,
	GOOD_LARGE_DECREASE_TO_ABILITY_CANCEL_COST,
	#grab cooldown
	BAD_SMALL_INCREASE_TO_GRAB_COOLDOWN,
	BAD_MEDIUM_INCREASE_TO_GRAB_COOLDOWN,
	BAD_LARGE_INCREASE_TO_GRAB_COOLDOWN,
	GOOD_SMALL_DECREASE_TO_GRAB_COOLDOWN,
	GOOD_MEDIUM_DECREASE_TO_GRAB_COOLDOWN,
	GOOD_LARGE_DECREASE_TO_GRAB_COOLDOWN,
	#MAGIC SEREIS BAR GAIN in the air
	BAD_SMALL_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR,
	BAD_MEDIUM_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR,
	BAD_LARGE_DECREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR,
	GOOD_SMALL_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR,
	GOOD_MEDIUM_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR,
	GOOD_LARGE_INCREASE_TO_BAR_GAIN_FROM_MAGIC_SERIES_IN_THE_AIR,
	#auto ripost
	BAD_SMALL_BAR_COST_FROM_MISSING_AUTORIPOSTE,
	BAD_MEDIUM_BAR_COST_FROM_MISSING_AUTORIPOSTE,
	BAD_LARGE_BAR_COST_FROM_MISSING_AUTORIPOSTE,
	#GRAB ABILITY CANCEL COOLDOWN
	GOOD_GRAB_COOLDOWN_REFRESHED_ON_AUTO_ABILITY_CANCEL,
	GOOD_GRAB_COOLDOWN_REFRESHED_ON_ABILITY_CANCEL,
	#BLOCK CHIP DAMAGE taken
	BAD_SMALL_DECREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN,
	BAD_MEDIUM_DECREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN,
	BAD_LARGE_DECREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN,
	GOOD_SMALL_INCREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN,
	GOOD_MEDIUM_INCREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN,
	GOOD_LARGE_INCREASE_TO_BLOCK_CHIP_DAMAGE_TAKEN,	
	BAD_SMALL_INCREASE_COOLDOWN_TO_AIR_GRAB,
	BAD_MEDIUM_INCREASE_COOLDOWN_TO_AIR_GRAB,
	BAD_LARGE_INCREASE_COOLDOWN_TO_AIR_GRAB,
	BAD_PREVENT_GROUND_DASHING,
	BAD_PREVENT_BLOCKING_GROUND_ATTACKS_IN_AIR,
	BAD_PREVENT_INCORRECT_BLOCKING,
	GOOD_SMALL_SETBACK_INCREASE_TO_SPAM_HISTUN_ON_ABILITY_CANCEL,
	BAD_SMALL_SETBACK_DECREASE_TO_SPAM_HISTUN_ON_ABILITY_CANCEL	,
	GOOD_YOU_CAN_DASH_OR_JUMP_OUT_OF_PUSHBLOCK,
	GOOD_PERFECT_BLOCK_REGENS_GUARD,
	BAD_LOSE_TECH_INVINCIBILITY,
	BAD_ENOURMOUS_BLOCK_CHIP_DAMAGE,
	GOOD_COUNTER_RIPOST_STEAL_ABILITY_BAR,
	BAD_CANT_AUTORIPOSTE,
	BAD_GAIN_NO_BAR_FROM_MAGIC_SERIES,
	GOOD_GAIN_ADDITIONAL_GRAB_CHARGE,
	BAD_CANT_GRAB,
	BAD_50_PRECENT_INCORRECT_BLOCK_GUARD_DMG_REDUCTION,
	BAD_ABILITY_CANCEL_ON_HIT_ONLY,
	BAD_DONT_TURN_AROUND_IN_AIR,
	BAD_CANT_PUSH_BLOCK
}

#THIS ID will be used to determine how will player's attributes be affected. literatly what defines
#what will be applied to player
export (ProficiencyPropertyID) var id = 0 setget setId,getId
export (bool) var isGood = true setget setIsGood,getIsGood
#export (String) var description = "" setget setDescription,getDescription
export (bool) var stacks = false setget setStacks,getStacks #indicates whether include this property twice if there is overlap in hybrid builds
func _ready():
	pass # Replace with function body.

func setIsGood(f):
	isGood = f
	
func getIsGood():
	return isGood
	
#func setDescription(text):
#	description=text
	
#func getDescription():
#	return description
	
	
func setId(_id):
	id = _id
	
func getId():
	return id
	
func setStacks(f):
	stacks = f
	
func getStacks():
	return stacks
	