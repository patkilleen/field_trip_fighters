extends "res://ActionAnimationManager.gd"


const STARTUP_SPRITE_ANIME_ID = 0
const ACTIVE_SPRITE_ANIME_ID = 1
const COMPLETION_SPRITE_ANIME_ID = 2
const IN_AIR_SPRITE_ANIME_ID = 3
const ON_GROUND_SPRITE_ANIME_ID = 4
const OFF_BATTLEFIELD_SPRITE_ANIME_ID=5


#Movement animation ids
const STARTUP_MVM_ANIME_ID = 0
const ACTIVE_MVM_ANIME_ID = 1
const COMPLETION_MVM_ANIME_ID = 2
const B_TOOL_MVM_ANIME_ID = 3
const ON_GROUND_MVM_ANIME_ID = 4
const OFF_BATTLEFIELD_MVM_ANIME_ID=5
const U_TOOL_MVM_ANIME_ID=6
const F_TOOL_MVM_ANIME_ID=7
const D_TOOL_MVM_ANIME_ID=8
const AIR_TOOL_ANGLE_0_MVM_ANIME_ID=9
const AIR_TOOL_ANGLE_45_MVM_ANIME_ID=10
const AIR_TOOL_ANGLE_90_MVM_ANIME_ID=11
const AIR_TOOL_ANGLE_135_MVM_ANIME_ID=12
const AIR_TOOL_ANGLE_180_MVM_ANIME_ID=13
const AIR_TOOL_ANGLE_225_MVM_ANIME_ID=14
const AIR_TOOL_ANGLE_270_MVM_ANIME_ID=15
const SPRINTER_TOOL_MVM_ANIME_ID=16
const B_BALL_CAP_HIT_BY_LIGHT_MVM_ANIME_ID=17
const B_BALL_CAP_HIT_BY_MEDIUM_MVM_ANIME_ID=18
const B_BALL_CAP_HIT_BY_HEAVY_MVM_ANIME_ID=19

#action  animation ids
const STARTUP_ACTION_ID = 0
const ACTIVE_ACTION_ID = 1
const COMPLETION_ACTION_ID = 2
const B_TOOL_ACTION_ID = 3
const ON_GROUND_ACTION_ID = 4
const OFF_BATTLEFIELD_ACTION_ID=5
const U_TOOL_ACTION_ID=6
const F_TOOL_ACTION_ID=7
const D_TOOL_ACTION_ID=8
const AIR_TOOL_ANGLE_0_ACTION_ID=9
const AIR_TOOL_ANGLE_45_ACTION_ID=10
const AIR_TOOL_ANGLE_90_ACTION_ID=11
const AIR_TOOL_ANGLE_135_ACTION_ID=12
const AIR_TOOL_ANGLE_180_ACTION_ID=13
const AIR_TOOL_ANGLE_225_ACTION_ID=14
const AIR_TOOL_ANGLE_270_ACTION_ID=15
const SPRINTER_TOOL_ACTION_ID=16
const B_BALL_CAP_HIT_BY_LIGHT_ACTION_ID=17
const B_BALL_CAP_HIT_BY_MEDIUM_ACTION_ID=18
const B_BALL_CAP_HIT_BY_HEAVY_ACTION_ID=19

func _ready():

#keep in mind, that playing animations, if one of the actionid are  any below, it will no function properly
#LANDING_HITSTUN_ACTION_ID = 35
	#INVULNERABLE_AIR_HITSTUN_ACTION_ID = 38
	#AIR_HITSTUN_ACTION_ID=HITSTUN_ACTION_ID
	
	animationLookup[SPRITE_ANIME_IX][STARTUP_ACTION_ID]=STARTUP_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][ACTIVE_ACTION_ID]=ACTIVE_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][COMPLETION_ACTION_ID]=COMPLETION_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][B_TOOL_ACTION_ID]=IN_AIR_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][ON_GROUND_ACTION_ID]=ON_GROUND_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][OFF_BATTLEFIELD_ACTION_ID]=OFF_BATTLEFIELD_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][U_TOOL_ACTION_ID]=IN_AIR_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][F_TOOL_ACTION_ID]=IN_AIR_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][D_TOOL_ACTION_ID]=IN_AIR_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][AIR_TOOL_ANGLE_0_ACTION_ID]=IN_AIR_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][AIR_TOOL_ANGLE_45_ACTION_ID]=IN_AIR_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][AIR_TOOL_ANGLE_90_ACTION_ID]=IN_AIR_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][AIR_TOOL_ANGLE_135_ACTION_ID]=IN_AIR_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][AIR_TOOL_ANGLE_180_ACTION_ID]=IN_AIR_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][AIR_TOOL_ANGLE_225_ACTION_ID]=IN_AIR_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][AIR_TOOL_ANGLE_270_ACTION_ID]=IN_AIR_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][SPRINTER_TOOL_ACTION_ID]=IN_AIR_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][B_BALL_CAP_HIT_BY_LIGHT_ACTION_ID]=IN_AIR_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][B_BALL_CAP_HIT_BY_MEDIUM_ACTION_ID]=IN_AIR_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][B_BALL_CAP_HIT_BY_HEAVY_ACTION_ID]=IN_AIR_SPRITE_ANIME_ID


	animationLookup[MVM_ANIME_IX][STARTUP_ACTION_ID]=STARTUP_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][ACTIVE_ACTION_ID]=ACTIVE_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][COMPLETION_ACTION_ID]=COMPLETION_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][B_TOOL_ACTION_ID]=B_TOOL_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][ON_GROUND_ACTION_ID]=ON_GROUND_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][OFF_BATTLEFIELD_ACTION_ID]=OFF_BATTLEFIELD_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][U_TOOL_ACTION_ID]=U_TOOL_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][F_TOOL_ACTION_ID]=F_TOOL_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][D_TOOL_ACTION_ID]=D_TOOL_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][AIR_TOOL_ANGLE_0_ACTION_ID]=AIR_TOOL_ANGLE_0_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][AIR_TOOL_ANGLE_45_ACTION_ID]=AIR_TOOL_ANGLE_45_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][AIR_TOOL_ANGLE_90_ACTION_ID]=AIR_TOOL_ANGLE_90_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][AIR_TOOL_ANGLE_135_ACTION_ID]=AIR_TOOL_ANGLE_135_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][AIR_TOOL_ANGLE_180_ACTION_ID]=AIR_TOOL_ANGLE_180_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][AIR_TOOL_ANGLE_225_ACTION_ID]=AIR_TOOL_ANGLE_225_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][AIR_TOOL_ANGLE_270_ACTION_ID]=AIR_TOOL_ANGLE_270_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][SPRINTER_TOOL_ACTION_ID]=SPRINTER_TOOL_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][B_BALL_CAP_HIT_BY_LIGHT_ACTION_ID]=B_BALL_CAP_HIT_BY_LIGHT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][B_BALL_CAP_HIT_BY_MEDIUM_ACTION_ID]=B_BALL_CAP_HIT_BY_MEDIUM_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][B_BALL_CAP_HIT_BY_HEAVY_ACTION_ID]=B_BALL_CAP_HIT_BY_HEAVY_MVM_ANIME_ID




		#make a backup of the map of animations	
	for actionId in animationLookup[SPRITE_ANIME_IX].keys():
		animationLookupDefault[SPRITE_ANIME_IX][actionId]=animationLookup[SPRITE_ANIME_IX][actionId]
	for actionId in animationLookup[MVM_ANIME_IX].keys():
		animationLookupDefault[MVM_ANIME_IX][actionId]=animationLookup[MVM_ANIME_IX][actionId]
		