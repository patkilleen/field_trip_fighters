extends "res://ActionAnimationManager.gd"


const STARTUP_SPRITE_ANIME_ID = 0
const ACTIVE_SPRITE_ANIME_ID = 1
const COMPLETION_SPRITE_ANIME_ID = 2
const STARTUP2_SPRITE_ANIME_ID = 3
const JUMP_TO_WHISTLE_SPRITE_ANIME_ID = 4

#Movement animation ids
const STARTUP_MVM_ANIME_ID = 0
const ACTIVE_MVM_ANIME_ID = 1
const COMPLETION_MVM_ANIME_ID = 2
const JUMP_TO_WHISTLE_MVM_ANIME_ID = 3

#action  animation ids
const STARTUP_ACTION_ID = 0
const ACTIVE_ACTION_ID = 1
const COMPLETION_ACTION_ID = 2
const STARTUP2_ACTION_ID = 3
const JUMP_TO_WHISTLE_ACTION_ID = 4

func _ready():

#keep in mind, that playing animations, if one of the actionid are  any below, it will no function properly
#LANDING_HITSTUN_ACTION_ID = 35
	#INVULNERABLE_AIR_HITSTUN_ACTION_ID = 38
	#AIR_HITSTUN_ACTION_ID=HITSTUN_ACTION_ID
	
	animationLookup[SPRITE_ANIME_IX][STARTUP_ACTION_ID]=STARTUP_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][ACTIVE_ACTION_ID]=ACTIVE_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][COMPLETION_ACTION_ID]=COMPLETION_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][STARTUP2_ACTION_ID]=STARTUP2_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][JUMP_TO_WHISTLE_ACTION_ID]=JUMP_TO_WHISTLE_SPRITE_ANIME_ID
	
	
	animationLookup[MVM_ANIME_IX][STARTUP_ACTION_ID]=STARTUP_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][ACTIVE_ACTION_ID]=ACTIVE_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][COMPLETION_ACTION_ID]=COMPLETION_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][STARTUP2_ACTION_ID]=null#keep startup mvm
	animationLookup[MVM_ANIME_IX][JUMP_TO_WHISTLE_ACTION_ID]=JUMP_TO_WHISTLE_MVM_ANIME_ID
	
		#make a backup of the map of animations	
	for actionId in animationLookup[SPRITE_ANIME_IX].keys():
		animationLookupDefault[SPRITE_ANIME_IX][actionId]=animationLookup[SPRITE_ANIME_IX][actionId]
	for actionId in animationLookup[MVM_ANIME_IX].keys():
		animationLookupDefault[MVM_ANIME_IX][actionId]=animationLookup[MVM_ANIME_IX][actionId]
		