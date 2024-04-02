extends "res://projectiles/ProjectileActionAnimationManager.gd"

const ON_SHIELD_HIT_REEL_LOCK_DURATION_IN_FRAMES = 60
var frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")

#const COMPLETION_SPRITE_ANIME_ID = 2
const D_TOOL_THROW_SPRITE_ANIME_ID = 3
const U_TOOL_THROW_SPRITE_ANIME_ID = 4
const F_TOOL_THROW_SPRITE_ANIME_ID = 5
const B_TOOL_REEL_SPRITE_ANIME_ID = 6
const U_TOOL_REEL_SPRITE_ANIME_ID = 7
const F_TOOL_REEL_SPRITE_ANIME_ID = 8
const BROKEN_STRING_IDLE_SPRITE_ANIME_ID = 9
const IDLE_SPRITE_ANIME_ID = 10
const D_TOOL_REEL_SPRITE_ANIME_ID = 11
const U_SPECIAL_BAT_HIT_SPRITE_ANIME_ID = 12
const F_SPECIAL_BAT_HIT_SPRITE_ANIME_ID = 13
const N_SPECIAL_BAT_HIT_SPRITE_ANIME_ID = 14
const B_MELEE_BAT_HIT_SPRITE_ANIME_ID = 15
const U_MELEE_BAT_HIT_SPRITE_ANIME_ID = 16
const AIR_SPECIAL_BAT_HIT_SPRITE_ANIME_ID = 17#part 1
const D_SPECIAL_BAT_HIT_SPRITE_ANIME_ID = 18
const AIR_TOOL_NO_BALL_THROW_SPRITE_ANIME_ID = 19
const AIR_SPECIAL_BAT_P2_HIT_SPRITE_ANIME_ID = 20
const AIR_SPECIAL_BAT_P3_HIT_SPRITE_ANIME_ID = 21
const AIR_TOOL_NO_BALL_REEL_SPRITE_ANIME_ID = 22
const NO_STRING_D_SPECIAL_BAT_HIT_SPRITE_ANIME_ID = 23
const NO_STRING_U_SPECIAL_BAT_HIT_SPRITE_ANIME_ID = 24
const NO_STRING_F_SPECIAL_BAT_HIT_SPRITE_ANIME_ID = 25
const NO_STRING_N_SPECIAL_BAT_HIT_SPRITE_ANIME_ID = 26
const NO_STRING_B_MELEE_BAT_HIT_SPRITE_ANIME_ID = 27
const NO_STRING_U_MELEE_BAT_HIT_SPRITE_ANIME_ID = 28
const NO_STRING_AIR_SPECIAL_P1_BAT_HIT_SPRITE_ANIME_ID = 29
const NO_STRING_AIR_SPECIAL_P2_BAT_HIT_SPRITE_ANIME_ID = 30
const NO_STRING_AIR_SPECIAL_P3_BAT_HIT_SPRITE_ANIME_ID = 31
const OFF_BATTLEFIELD_SPRITE_ANIME_ID = 32
const NEW_B_SPECIAL_BAT_HIT_SPRITE_ANIME_ID = 33
const NO_STRING_NEW_B_SPECIAL_BAT_HIT_SPRITE_ANIME_ID = 34
#Movement animation ids
const GROUND_IDLE_MVM_ANIME_ID = 2 #SAME AS GROUND IDLE ATTACHED
#const BROKEN_STRING_IDLE_MVM_ANIME_ID = 2 #SAME AS GROUND IDLE ATTACHED
const D_TOOL_THROW_MVM_ANIME_ID = 3
const U_TOOL_THROW_MVM_ANIME_ID = 4
const F_TOOL_THROW_MVM_ANIME_ID = 5
const B_TOOL_REEL_MVM_ANIME_ID = 6
const U_TOOL_REEL_MVM_ANIME_ID = 7
const F_TOOL_REEL_MVM_ANIME_ID = 8
const D_TOOL_REEL_MVM_ANIME_ID = 9
const MOMENTUM_STOP_MVM_ANIME_ID = 10
const U_SPECIAL_BAT_HIT_MVM_ANIME_ID  = 11
const B_SPECIAL_BAT_HIT_MVM_ANIME_ID  = 12
const N_SPECIAL_BAT_HIT_MVM_ANIME_ID  = 13
const B_MELEE_BAT_HIT_MVM_ANIME_ID  = 14
const U_MELEE_BAT_HIT_MVM_ANIME_ID  = 15
const REEL_ARRIVE_KEEP_AIR_MOMENTUM_MVM_ANIME_ID  = 16 #will need abit of dynamic raw speed assignment (xSpeed,ySpeed)
const U_THROW_BOUNCE_OFF_PLAYER_MVM_ANIME_ID  = 17
const F_THROW_BOUNCE_OFF_PLAYER_MVM_ANIME_ID  = 18
const D_THROW_BOUNCE_OFF_PLAYER_MVM_ANIME_ID  = 19
const B_REEL_BOUNCE_OFF_PLAYER_MVM_ANIME_ID  = 20
const AIR_SPECIAL_BAT_HIT_MVM_ANIME_ID  = 21
const REELED_INTO_WALL_BOUNCE_MVM_ANIME_ID  = 22
const D_SPECIAL_BAT_HIT_MVM_ANIME_ID  = 23
const AIR_TOOL_NO_BALL_THROW_MVM_ANIME_ID = 24
const AIR_TOOL_NO_BALL_THROW_BOUNCE_OFF_PLAYER_MVM_ANIME_ID = 25
const AIR_SPECIAL_BAT_P2_HIT_MVM_ANIME_ID = 26
const AIR_SPECIAL_BAT_P3_HIT_MVM_ANIME_ID = 27
const AIR_TOOL_NO_BALL_REEL_MVM_ANIME_ID = 28
const OFF_BATTLEFIELD_MVM_ANIME_ID = 29
const B_REEL_BOUNCE_OFF_SHIELDING_PLAYER_MVM_ANIME_ID = 30
const AIR_REEL_BOUNCE_OFF_SHIELDING_PLAYER_MVM_ANIME_ID = 31
const U_REEL_KEEP_MOMENTUM_ON_HIT_PLAYER_MVM_ANIME_ID = 32
const U_REEL_ON_HIT_SHIELDING_PLAYER_MVM_ANIME_ID = 33
const NEW_B_SPECIAL_BAT_HIT_MVM_ANIME_ID = 34

#action  animation ids
const GROUND_IDLE_ATTACHED_ACTION_ID = 2 #SAME AS COMPLETION, BUT NAMING FOR UNDERSTANDING SAKE
const D_TOOL_THROW_ACTION_ID = 3
const U_TOOL_THROW_ACTION_ID = 4
const F_TOOL_THROW_ACTION_ID = 5
const B_TOOL_REEL_ACTION_ID = 6
const U_TOOL_REEL_ACTION_ID = 7
const F_TOOL_REEL_ACTION_ID = 8
const AIR_BROKEN_STRING_IDLE_ACTION_ID = 9 # in the air
const IDLE_ACTION_ID = 10
const D_TOOL_REEL_ACTION_ID = 11
const GROUND_BROKEN_STRING_IDLE_ACTION_ID= 12
const U_SPECIAL_BAT_HIT_ACTION_ID=13
const B_SPECIAL_BAT_HIT_ACTION_ID  = 14
const N_SPECIAL_BAT_HIT_ACTION_ID  = 15
const B_MELEE_BAT_HIT_ACTION_ID  = 16
const U_MELEE_BAT_HIT_ACTION_ID  = 17
const REEL_ARRIVE_KEEP_AIR_MOMENTUM_ACTION_ID  = 18 #will need abit of dynamic raw speed assignment (xSpeed,ySpeed)
const U_THROW_BOUNCE_OFF_PLAYER_ACTION_ID  = 19
const F_THROW_BOUNCE_OFF_PLAYER_ACTION_ID  = 20
const D_THROW_BOUNCE_OFF_PLAYER_ACTION_ID  = 21
const B_REEL_BOUNCE_OFF_PLAYER_ACTION_ID  = 22
const U_REEL_BOUNCE_OFF_PLAYER_ACTION_ID  = 23 #no animation for this one, but may be in future
const AIR_SPECIAL_BAT_HIT_ACTION_ID  = 24 
const REELED_INTO_WALL_BOUNCE_ACTION_ID  = 25
const D_SPECIAL_BAT_HIT_ACTION_ID  = 26
const AIR_TOOL_NO_BALL_THROW_ACTION_ID  = 27
const AIR_TOOL_NO_BALL_THROW_BOUNCE_OFF_PLAYER_THROW_ACTION_ID  = 28
const AIR_SPECIAL_BAT_P2_HIT_ACTION_ID = 29
const AIR_SPECIAL_BAT_P3_HIT_ACTION_ID = 30
const AIR_TOOL_NO_BALL_REEL_ACTION_ID = 31
const NO_STRING_D_SPECIAL_BAT_HIT_ACTION_ID = 32

const NO_STRING_U_SPECIAL_BAT_HIT_ACTION_ID = 33
const NO_STRING_F_SPECIAL_BAT_HIT_ACTION_ID = 34
const NO_STRING_N_SPECIAL_BAT_HIT_ACTION_ID = 35
const NO_STRING_B_MELEE_BAT_HIT_ACTION_ID = 36
const NO_STRING_U_MELEE_BAT_HIT_ACTION_ID = 37
const NO_STRING_AIR_SPECIAL_P1_BAT_HIT_ACTION_ID = 38
const NO_STRING_AIR_SPECIAL_P2_BAT_HIT_ACTION_ID = 39
const NO_STRING_AIR_SPECIAL_P3_BAT_HIT_ACTION_ID = 40

const OFF_BATTLEFIELD_ACTION_ID = 41
const B_REEL_BOUNCE_OFF_SHIELDING_PLAYER_ACTION_ID = 42
const AIR_REEL_BOUNCE_OFF_SHIELDING_PLAYER_ACTION_ID = 43
const U_REEL_KEEP_MOMENTUM_ON_HIT_PLAYER_ACTION_ID = 44
const U_REEL_ON_HIT_SHIELDING_PLAYER_ACTION_ID = 45
const NEW_B_SPECIAL_BAT_HIT_ACTION_ID  = 46
const NO_STRING_NEW_B_SPECIAL_BAT_HIT_ACTION_ID = 47
const LARGEST_ACTION_ID = 47



const BALL_HIT_ACTION_ID_IX=0
const BALL_HIT_COMPLX_MVM_IX=1

var ballHitBounceOffPlayerMap = [{},{}]

var ballHitShieldingOpponentBounceOffPlayerMap = [{},{}]




#const FORWARD_SPECIAL_ACTION_ID = -1
#const DOWNWARD_MELEE_ACTION_ID = -1

const STRING_ATTACHED_ANIMATIONS_IX = 0
const STRING_BROKEN_ANIMATIONS_IX = 1


var currentActionIdGroup = STRING_ATTACHED_ANIMATIONS_IX

#2D ARRAY that holds the action id pairs of with String vs no string
#column 0 is action id when ball is attached
#column 1 is action id when ball string broken
#row i is starnd actionId = i
#animations that aren't different with and without ball are idential in a row

var actionIdGroups = []




var reelBackShieldHitTimer = null
var reelUpShieldHitTimer = null
var airReelShieldHitTimer = null


const ON_SHIELD_HIT_MAP_TIMER_IX =0
const ON_SHIELD_HIT_MAP_SPRITE_ANIME_ID_IX =1
const ON_SHIELD_HIT_MAP_ACTION_ID_IX =2
const ON_SHIELD_HIT_MAP_LOCKED_FALG_IX =3
#key: sprite anime id of reel: value [TIMER, sprite anime id of reel,reel action animat id, locked falg]
var onShieldHitReelMapSI = {}
#key: reel action animat id: value [TIMER, sprite anime id of reel,reel action animat id, locked falg]
var onShieldHitReelMapAI = {}


#any action id key in this map means the facing direction for animation depends on 
#relation of ball to opponent (specially useful for bouncing away from opponents)
var opponentDirectionDependentFacingMap = {}

func _ready():
	
	visualSFXAttackMap=attackMaps
	#attackTypeIx[MELEE_IX]
	#the special effects attack type map is same as attack map in belt's case. so just coyp it over
#	for bin in attackMaps:
		#var bin = attackMaps[attackTypeIx]
		
#		for spriteAnimeId in bin.keys():
			
#			visualSFXAttackMap[attackTypeIx][spriteAnimeId]=bin[spriteAnimeId]
 

	attackMaps[TOOL_IX][D_TOOL_THROW_SPRITE_ANIME_ID] =true
	attackMaps[TOOL_IX][U_TOOL_THROW_SPRITE_ANIME_ID] =true
	attackMaps[TOOL_IX][F_TOOL_THROW_SPRITE_ANIME_ID] =true
	attackMaps[TOOL_IX][B_TOOL_REEL_SPRITE_ANIME_ID] =true
	attackMaps[TOOL_IX][U_TOOL_REEL_SPRITE_ANIME_ID] =true
	attackMaps[TOOL_IX][AIR_TOOL_NO_BALL_THROW_SPRITE_ANIME_ID] =true
	attackMaps[TOOL_IX][AIR_TOOL_NO_BALL_REEL_SPRITE_ANIME_ID] =true
	
	attackMaps[SPECIAL_IX][U_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =true
	attackMaps[SPECIAL_IX][F_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =true
	attackMaps[SPECIAL_IX][N_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =true	
	attackMaps[SPECIAL_IX][AIR_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =true
	attackMaps[SPECIAL_IX][D_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =true
	attackMaps[SPECIAL_IX][AIR_SPECIAL_BAT_P2_HIT_SPRITE_ANIME_ID] =true
	attackMaps[SPECIAL_IX][AIR_SPECIAL_BAT_P3_HIT_SPRITE_ANIME_ID] =true
	attackMaps[SPECIAL_IX][NEW_B_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =true


	attackMaps[SPECIAL_IX][NO_STRING_D_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =true
	attackMaps[SPECIAL_IX][NO_STRING_U_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =true
	attackMaps[SPECIAL_IX][NO_STRING_F_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =true
	attackMaps[SPECIAL_IX][NO_STRING_N_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =true
	attackMaps[SPECIAL_IX][NO_STRING_AIR_SPECIAL_P1_BAT_HIT_SPRITE_ANIME_ID] =true
	attackMaps[SPECIAL_IX][NO_STRING_AIR_SPECIAL_P2_BAT_HIT_SPRITE_ANIME_ID] =true
	attackMaps[SPECIAL_IX][NO_STRING_AIR_SPECIAL_P3_BAT_HIT_SPRITE_ANIME_ID] =true
	attackMaps[SPECIAL_IX][NO_STRING_NEW_B_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =true

	attackMaps[MELEE_IX][NO_STRING_B_MELEE_BAT_HIT_SPRITE_ANIME_ID] =true
	attackMaps[MELEE_IX][NO_STRING_U_MELEE_BAT_HIT_SPRITE_ANIME_ID] =true
	attackMaps[MELEE_IX][B_MELEE_BAT_HIT_SPRITE_ANIME_ID] =true
	attackMaps[MELEE_IX][U_MELEE_BAT_HIT_SPRITE_ANIME_ID] =true
	
	#the special effects attack type map is same as attack map in gloves's case
	visualSFXAttackMap=attackMaps
	audioSFXAttackMap=attackMaps
	
	#animationLookup[SPRITE_ANIME_IX][STARTUP_ACTION_ID]=STARTUP_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][D_TOOL_THROW_ACTION_ID]=D_TOOL_THROW_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][U_TOOL_THROW_ACTION_ID]=U_TOOL_THROW_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][F_TOOL_THROW_ACTION_ID]=F_TOOL_THROW_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][B_TOOL_REEL_ACTION_ID]=B_TOOL_REEL_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][U_TOOL_REEL_ACTION_ID]=U_TOOL_REEL_SPRITE_ANIME_ID
	#animationLookup[SPRITE_ANIME_IX][F_TOOL_REEL_ACTION_ID]=F_TOOL_REEL_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][F_TOOL_REEL_ACTION_ID]=B_TOOL_REEL_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][AIR_BROKEN_STRING_IDLE_ACTION_ID]=BROKEN_STRING_IDLE_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][GROUND_BROKEN_STRING_IDLE_ACTION_ID]=BROKEN_STRING_IDLE_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][IDLE_ACTION_ID]=IDLE_SPRITE_ANIME_ID
	#animationLookup[SPRITE_ANIME_IX][D_TOOL_REEL_ACTION_ID]=D_TOOL_REEL_ACTION_ID
	animationLookup[SPRITE_ANIME_IX][D_TOOL_REEL_ACTION_ID]=B_TOOL_REEL_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][U_SPECIAL_BAT_HIT_ACTION_ID]=U_SPECIAL_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][N_SPECIAL_BAT_HIT_ACTION_ID]=N_SPECIAL_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][B_SPECIAL_BAT_HIT_ACTION_ID]=F_SPECIAL_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][B_MELEE_BAT_HIT_ACTION_ID]=B_MELEE_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][U_MELEE_BAT_HIT_ACTION_ID]=U_MELEE_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][REEL_ARRIVE_KEEP_AIR_MOMENTUM_ACTION_ID]=null
	animationLookup[SPRITE_ANIME_IX][U_THROW_BOUNCE_OFF_PLAYER_ACTION_ID]=null
	animationLookup[SPRITE_ANIME_IX][F_THROW_BOUNCE_OFF_PLAYER_ACTION_ID]=null
	animationLookup[SPRITE_ANIME_IX][D_THROW_BOUNCE_OFF_PLAYER_ACTION_ID]=null
	animationLookup[SPRITE_ANIME_IX][B_REEL_BOUNCE_OFF_PLAYER_ACTION_ID]=null
	#animationLookup[SPRITE_ANIME_IX][U_REEL_BOUNCE_OFF_PLAYER_ACTION_ID]=null
	animationLookup[SPRITE_ANIME_IX][AIR_SPECIAL_BAT_HIT_ACTION_ID]=AIR_SPECIAL_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][REELED_INTO_WALL_BOUNCE_ACTION_ID]=null
	animationLookup[SPRITE_ANIME_IX][D_SPECIAL_BAT_HIT_ACTION_ID]=D_SPECIAL_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][AIR_TOOL_NO_BALL_THROW_ACTION_ID]=AIR_TOOL_NO_BALL_THROW_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][AIR_TOOL_NO_BALL_THROW_BOUNCE_OFF_PLAYER_THROW_ACTION_ID]=null
	animationLookup[SPRITE_ANIME_IX][AIR_SPECIAL_BAT_P2_HIT_ACTION_ID]=AIR_SPECIAL_BAT_P2_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][AIR_SPECIAL_BAT_P3_HIT_ACTION_ID]=AIR_SPECIAL_BAT_P3_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][AIR_TOOL_NO_BALL_REEL_ACTION_ID]=AIR_TOOL_NO_BALL_REEL_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][OFF_BATTLEFIELD_ACTION_ID]=OFF_BATTLEFIELD_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][B_REEL_BOUNCE_OFF_SHIELDING_PLAYER_ACTION_ID]=null
	animationLookup[SPRITE_ANIME_IX][AIR_REEL_BOUNCE_OFF_SHIELDING_PLAYER_ACTION_ID]=null
	animationLookup[SPRITE_ANIME_IX][U_REEL_KEEP_MOMENTUM_ON_HIT_PLAYER_ACTION_ID]=null
	animationLookup[SPRITE_ANIME_IX][U_REEL_ON_HIT_SHIELDING_PLAYER_ACTION_ID]=null
	
	animationLookup[SPRITE_ANIME_IX][NEW_B_SPECIAL_BAT_HIT_ACTION_ID]=NEW_B_SPECIAL_BAT_HIT_SPRITE_ANIME_ID
	
	#no string sprite mappings
	animationLookup[SPRITE_ANIME_IX][NO_STRING_D_SPECIAL_BAT_HIT_ACTION_ID]=NO_STRING_D_SPECIAL_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][NO_STRING_U_SPECIAL_BAT_HIT_ACTION_ID]=NO_STRING_U_SPECIAL_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][NO_STRING_F_SPECIAL_BAT_HIT_ACTION_ID]=NO_STRING_F_SPECIAL_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][NO_STRING_N_SPECIAL_BAT_HIT_ACTION_ID]=NO_STRING_N_SPECIAL_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][NO_STRING_B_MELEE_BAT_HIT_ACTION_ID]=NO_STRING_B_MELEE_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][NO_STRING_U_MELEE_BAT_HIT_ACTION_ID]=NO_STRING_U_MELEE_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][NO_STRING_AIR_SPECIAL_P1_BAT_HIT_ACTION_ID]=NO_STRING_AIR_SPECIAL_P1_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][NO_STRING_AIR_SPECIAL_P2_BAT_HIT_ACTION_ID]=NO_STRING_AIR_SPECIAL_P2_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][NO_STRING_AIR_SPECIAL_P3_BAT_HIT_ACTION_ID]=NO_STRING_AIR_SPECIAL_P3_BAT_HIT_SPRITE_ANIME_ID
	animationLookup[SPRITE_ANIME_IX][NO_STRING_NEW_B_SPECIAL_BAT_HIT_ACTION_ID]=NO_STRING_NEW_B_SPECIAL_BAT_HIT_SPRITE_ANIME_ID
	


	
	
	#animationLookup[MVM_ANIME_IX][STARTUP_ACTION_ID]=STARTUP_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][D_TOOL_THROW_ACTION_ID]=D_TOOL_THROW_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][U_TOOL_THROW_ACTION_ID]=U_TOOL_THROW_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][F_TOOL_THROW_ACTION_ID]=F_TOOL_THROW_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][B_TOOL_REEL_ACTION_ID]=B_TOOL_REEL_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][U_TOOL_REEL_ACTION_ID]=U_TOOL_REEL_MVM_ANIME_ID
	#animationLookup[MVM_ANIME_IX][F_TOOL_REEL_ACTION_ID]=F_TOOL_REEL_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][F_TOOL_REEL_ACTION_ID]=B_TOOL_REEL_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][AIR_BROKEN_STRING_IDLE_ACTION_ID]=MOMENTUM_STOP_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][GROUND_BROKEN_STRING_IDLE_ACTION_ID]=GROUND_IDLE_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][IDLE_ACTION_ID]=MOMENTUM_STOP_MVM_ANIME_ID
	#animationLookup[MVM_ANIME_IX][D_TOOL_REEL_ACTION_ID]=D_TOOL_REEL_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][D_TOOL_REEL_ACTION_ID]=B_TOOL_REEL_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][U_SPECIAL_BAT_HIT_ACTION_ID]=U_SPECIAL_BAT_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][N_SPECIAL_BAT_HIT_ACTION_ID]=N_SPECIAL_BAT_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][B_SPECIAL_BAT_HIT_ACTION_ID]=B_SPECIAL_BAT_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][B_MELEE_BAT_HIT_ACTION_ID]=B_MELEE_BAT_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][U_MELEE_BAT_HIT_ACTION_ID]=U_MELEE_BAT_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][REEL_ARRIVE_KEEP_AIR_MOMENTUM_ACTION_ID]=REEL_ARRIVE_KEEP_AIR_MOMENTUM_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][U_THROW_BOUNCE_OFF_PLAYER_ACTION_ID]=U_THROW_BOUNCE_OFF_PLAYER_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][F_THROW_BOUNCE_OFF_PLAYER_ACTION_ID]=F_THROW_BOUNCE_OFF_PLAYER_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][D_THROW_BOUNCE_OFF_PLAYER_ACTION_ID]=D_THROW_BOUNCE_OFF_PLAYER_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][B_REEL_BOUNCE_OFF_PLAYER_ACTION_ID]=B_REEL_BOUNCE_OFF_PLAYER_MVM_ANIME_ID
	#animationLookup[MVM_ANIME_IX][U_REEL_BOUNCE_OFF_PLAYER_ACTION_ID]=null
	animationLookup[MVM_ANIME_IX][AIR_SPECIAL_BAT_HIT_ACTION_ID]=AIR_SPECIAL_BAT_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][REELED_INTO_WALL_BOUNCE_ACTION_ID]=REELED_INTO_WALL_BOUNCE_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][D_SPECIAL_BAT_HIT_ACTION_ID]=D_SPECIAL_BAT_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][AIR_TOOL_NO_BALL_THROW_ACTION_ID]=AIR_TOOL_NO_BALL_THROW_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][AIR_TOOL_NO_BALL_THROW_BOUNCE_OFF_PLAYER_THROW_ACTION_ID]=AIR_TOOL_NO_BALL_THROW_BOUNCE_OFF_PLAYER_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][AIR_SPECIAL_BAT_P2_HIT_ACTION_ID]=AIR_SPECIAL_BAT_P2_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][AIR_SPECIAL_BAT_P3_HIT_ACTION_ID]=AIR_SPECIAL_BAT_P3_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][AIR_TOOL_NO_BALL_REEL_ACTION_ID]=AIR_TOOL_NO_BALL_REEL_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][OFF_BATTLEFIELD_ACTION_ID]=OFF_BATTLEFIELD_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][U_REEL_KEEP_MOMENTUM_ON_HIT_PLAYER_ACTION_ID]=U_REEL_KEEP_MOMENTUM_ON_HIT_PLAYER_MVM_ANIME_ID
	
	
	animationLookup[MVM_ANIME_IX][NEW_B_SPECIAL_BAT_HIT_ACTION_ID]=NEW_B_SPECIAL_BAT_HIT_MVM_ANIME_ID

	
	#shield bounces
	animationLookup[MVM_ANIME_IX][B_REEL_BOUNCE_OFF_SHIELDING_PLAYER_ACTION_ID]=B_REEL_BOUNCE_OFF_SHIELDING_PLAYER_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][AIR_REEL_BOUNCE_OFF_SHIELDING_PLAYER_ACTION_ID]=AIR_REEL_BOUNCE_OFF_SHIELDING_PLAYER_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][U_REEL_ON_HIT_SHIELDING_PLAYER_ACTION_ID]=U_REEL_ON_HIT_SHIELDING_PLAYER_MVM_ANIME_ID
	
	
	#no string mvm mappings
	animationLookup[MVM_ANIME_IX][NO_STRING_D_SPECIAL_BAT_HIT_ACTION_ID]=D_SPECIAL_BAT_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][NO_STRING_U_SPECIAL_BAT_HIT_ACTION_ID]=U_SPECIAL_BAT_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][NO_STRING_F_SPECIAL_BAT_HIT_ACTION_ID]=B_SPECIAL_BAT_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][NO_STRING_N_SPECIAL_BAT_HIT_ACTION_ID]=N_SPECIAL_BAT_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][NO_STRING_B_MELEE_BAT_HIT_ACTION_ID]=B_MELEE_BAT_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][NO_STRING_U_MELEE_BAT_HIT_ACTION_ID]=U_MELEE_BAT_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][NO_STRING_AIR_SPECIAL_P1_BAT_HIT_ACTION_ID]=AIR_SPECIAL_BAT_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][NO_STRING_AIR_SPECIAL_P2_BAT_HIT_ACTION_ID]=AIR_SPECIAL_BAT_P2_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][NO_STRING_AIR_SPECIAL_P3_BAT_HIT_ACTION_ID]=AIR_SPECIAL_BAT_P3_HIT_MVM_ANIME_ID
	animationLookup[MVM_ANIME_IX][NO_STRING_NEW_B_SPECIAL_BAT_HIT_ACTION_ID]=NEW_B_SPECIAL_BAT_HIT_MVM_ANIME_ID
	#make a backup of the map of animations	
	for actionId in animationLookup[SPRITE_ANIME_IX].keys():
		animationLookupDefault[SPRITE_ANIME_IX][actionId]=animationLookup[SPRITE_ANIME_IX][actionId]
	for actionId in animationLookup[MVM_ANIME_IX].keys():
		animationLookupDefault[MVM_ANIME_IX][actionId]=animationLookup[MVM_ANIME_IX][actionId]
		
	#THIS IS where define the action aniamtion to play on hit (bounce) depending on what sprite hitting opponent
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][D_TOOL_THROW_SPRITE_ANIME_ID] =D_THROW_BOUNCE_OFF_PLAYER_ACTION_ID
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][U_TOOL_THROW_SPRITE_ANIME_ID] =U_THROW_BOUNCE_OFF_PLAYER_ACTION_ID  
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][F_TOOL_THROW_SPRITE_ANIME_ID] =F_THROW_BOUNCE_OFF_PLAYER_ACTION_ID
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][B_TOOL_REEL_SPRITE_ANIME_ID] =B_REEL_BOUNCE_OFF_PLAYER_ACTION_ID  
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][U_TOOL_REEL_SPRITE_ANIME_ID] =U_REEL_KEEP_MOMENTUM_ON_HIT_PLAYER_ACTION_ID  
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][U_SPECIAL_BAT_HIT_SPRITE_ANIME_ID ] =U_THROW_BOUNCE_OFF_PLAYER_ACTION_ID#
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][NO_STRING_U_SPECIAL_BAT_HIT_SPRITE_ANIME_ID ] =ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][U_SPECIAL_BAT_HIT_SPRITE_ANIME_ID ] 
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][F_SPECIAL_BAT_HIT_SPRITE_ANIME_ID ] =F_THROW_BOUNCE_OFF_PLAYER_ACTION_ID  
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][NO_STRING_F_SPECIAL_BAT_HIT_SPRITE_ANIME_ID ] =ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][F_SPECIAL_BAT_HIT_SPRITE_ANIME_ID ]
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][N_SPECIAL_BAT_HIT_SPRITE_ANIME_ID ] =B_REEL_BOUNCE_OFF_PLAYER_ACTION_ID
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][NO_STRING_N_SPECIAL_BAT_HIT_SPRITE_ANIME_ID ]=ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][N_SPECIAL_BAT_HIT_SPRITE_ANIME_ID ]
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][B_MELEE_BAT_HIT_SPRITE_ANIME_ID ] =F_THROW_BOUNCE_OFF_PLAYER_ACTION_ID  
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][NO_STRING_B_MELEE_BAT_HIT_SPRITE_ANIME_ID ]=ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][B_MELEE_BAT_HIT_SPRITE_ANIME_ID ]
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][U_MELEE_BAT_HIT_SPRITE_ANIME_ID ] =U_THROW_BOUNCE_OFF_PLAYER_ACTION_ID  
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][NO_STRING_U_MELEE_BAT_HIT_SPRITE_ANIME_ID ]=ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][U_MELEE_BAT_HIT_SPRITE_ANIME_ID ]
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][AIR_SPECIAL_BAT_HIT_SPRITE_ANIME_ID  ] =U_THROW_BOUNCE_OFF_PLAYER_ACTION_ID
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][NO_STRING_AIR_SPECIAL_P1_BAT_HIT_SPRITE_ANIME_ID  ]=ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][AIR_SPECIAL_BAT_HIT_SPRITE_ANIME_ID  ]
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][D_SPECIAL_BAT_HIT_SPRITE_ANIME_ID  ] =D_THROW_BOUNCE_OFF_PLAYER_ACTION_ID
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][NO_STRING_D_SPECIAL_BAT_HIT_SPRITE_ANIME_ID  ] =D_THROW_BOUNCE_OFF_PLAYER_ACTION_ID
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][AIR_TOOL_NO_BALL_THROW_SPRITE_ANIME_ID  ] =AIR_TOOL_NO_BALL_THROW_BOUNCE_OFF_PLAYER_THROW_ACTION_ID
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][AIR_SPECIAL_BAT_P2_HIT_SPRITE_ANIME_ID  ] =F_THROW_BOUNCE_OFF_PLAYER_ACTION_ID
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][NO_STRING_AIR_SPECIAL_P2_BAT_HIT_SPRITE_ANIME_ID  ]=ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][AIR_SPECIAL_BAT_P2_HIT_SPRITE_ANIME_ID  ]
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][AIR_SPECIAL_BAT_P3_HIT_SPRITE_ANIME_ID  ] =U_THROW_BOUNCE_OFF_PLAYER_ACTION_ID
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][NO_STRING_AIR_SPECIAL_P3_BAT_HIT_SPRITE_ANIME_ID  ]=ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][AIR_SPECIAL_BAT_P3_HIT_SPRITE_ANIME_ID  ]
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][AIR_TOOL_NO_BALL_REEL_SPRITE_ANIME_ID  ] =D_THROW_BOUNCE_OFF_PLAYER_ACTION_ID
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][NEW_B_SPECIAL_BAT_HIT_SPRITE_ANIME_ID  ]=F_THROW_BOUNCE_OFF_PLAYER_ACTION_ID
	ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][NO_STRING_NEW_B_SPECIAL_BAT_HIT_SPRITE_ANIME_ID  ]=F_THROW_BOUNCE_OFF_PLAYER_ACTION_ID
		
	
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][D_TOOL_THROW_SPRITE_ANIME_ID] =get_node("MovementAnimationManager/MovementAnimations/d-throw-bounce-off-player/cplx_mvm6")
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][U_TOOL_THROW_SPRITE_ANIME_ID] =get_node("MovementAnimationManager/MovementAnimations/u-throw-bounce-off-player/cplx_mvm6")
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][F_TOOL_THROW_SPRITE_ANIME_ID] =get_node("MovementAnimationManager/MovementAnimations/f-throw-bounce-off-player/cplx_mvm6")
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][B_TOOL_REEL_SPRITE_ANIME_ID] =get_node("MovementAnimationManager/MovementAnimations/b-reel-in-bounce-off-player/cplx_mvm7")
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][U_TOOL_REEL_SPRITE_ANIME_ID] =null
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][U_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][U_TOOL_THROW_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][NO_STRING_U_SPECIAL_BAT_HIT_SPRITE_ANIME_ID]=ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][U_SPECIAL_BAT_HIT_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][F_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][F_TOOL_THROW_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][NO_STRING_F_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] = ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][F_SPECIAL_BAT_HIT_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][N_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][B_TOOL_REEL_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][NO_STRING_N_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] = ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][N_SPECIAL_BAT_HIT_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][B_MELEE_BAT_HIT_SPRITE_ANIME_ID] =ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][F_TOOL_THROW_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][NO_STRING_B_MELEE_BAT_HIT_SPRITE_ANIME_ID]=ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][B_MELEE_BAT_HIT_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][U_MELEE_BAT_HIT_SPRITE_ANIME_ID] =ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][U_TOOL_THROW_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][NO_STRING_U_MELEE_BAT_HIT_SPRITE_ANIME_ID]=ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][U_MELEE_BAT_HIT_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][AIR_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][U_TOOL_THROW_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][NO_STRING_AIR_SPECIAL_P1_BAT_HIT_SPRITE_ANIME_ID]=ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][AIR_SPECIAL_BAT_HIT_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][D_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][D_TOOL_THROW_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][NO_STRING_D_SPECIAL_BAT_HIT_SPRITE_ANIME_ID]=ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][D_SPECIAL_BAT_HIT_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][AIR_TOOL_NO_BALL_THROW_SPRITE_ANIME_ID] =get_node("MovementAnimationManager/MovementAnimations/air-tool-no-ball-throw-bounce-off-player/cplx_mvm6")
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][AIR_SPECIAL_BAT_P2_HIT_SPRITE_ANIME_ID] =ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][F_TOOL_THROW_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][NO_STRING_AIR_SPECIAL_P2_BAT_HIT_SPRITE_ANIME_ID]=ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][AIR_SPECIAL_BAT_P2_HIT_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][AIR_SPECIAL_BAT_P3_HIT_SPRITE_ANIME_ID] =ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][U_TOOL_THROW_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][NO_STRING_AIR_SPECIAL_P3_BAT_HIT_SPRITE_ANIME_ID]=ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][AIR_SPECIAL_BAT_P3_HIT_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][AIR_TOOL_NO_BALL_REEL_SPRITE_ANIME_ID] =ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][D_TOOL_THROW_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][NEW_B_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][F_TOOL_THROW_SPRITE_ANIME_ID]
	ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][NO_STRING_NEW_B_SPECIAL_BAT_HIT_SPRITE_ANIME_ID] =ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][F_TOOL_THROW_SPRITE_ANIME_ID]
	
	
	#overriding animations for on hit shield
	ballHitShieldingOpponentBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][B_TOOL_REEL_SPRITE_ANIME_ID]=B_REEL_BOUNCE_OFF_SHIELDING_PLAYER_ACTION_ID  
	ballHitShieldingOpponentBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][AIR_TOOL_NO_BALL_REEL_SPRITE_ANIME_ID]=AIR_REEL_BOUNCE_OFF_SHIELDING_PLAYER_ACTION_ID	
	ballHitShieldingOpponentBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][U_TOOL_REEL_SPRITE_ANIME_ID]=U_REEL_ON_HIT_SHIELDING_PLAYER_ACTION_ID	
	ballHitShieldingOpponentBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][B_TOOL_REEL_SPRITE_ANIME_ID]= get_node("MovementAnimationManager/MovementAnimations/b-reel-in-bounce-off-shielding-player/cplx_mvm7")
	ballHitShieldingOpponentBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][AIR_TOOL_NO_BALL_REEL_SPRITE_ANIME_ID]=get_node("MovementAnimationManager/MovementAnimations/air-reel-bounce-off-shielding-player/cplx_mvm6")	
	ballHitShieldingOpponentBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][U_TOOL_REEL_SPRITE_ANIME_ID]=null
	
	
#const BALL_HIT_SPRITE_ANIMATION_ID_IX=0
	#const BALL_HIT_COMPLX_MVM_IX=1
	
	
	#bad desing on autocancel mpa, which is hard coded fither actions, so just make due
	autoCancelMaskMap[GROUND_IDLE_ATTACHED_ACTION_ID]= 1 #jump
	autoCancelMaskMap[D_TOOL_THROW_ACTION_ID]= 1 << 1#f-jump
	autoCancelMaskMap[U_TOOL_THROW_ACTION_ID]= 1 << 2#b-jump
	autoCancelMaskMap[F_TOOL_THROW_ACTION_ID]= 1 << 3#ground idle
	autoCancelMaskMap[B_TOOL_REEL_ACTION_ID]= 1 << 4#ground f move
	autoCancelMaskMap[U_TOOL_REEL_ACTION_ID]= 1 << 5#ground b move
	autoCancelMaskMap[F_TOOL_REEL_ACTION_ID]= 1 << 6#crouch
	autoCancelMaskMap[AIR_BROKEN_STRING_IDLE_ACTION_ID]= 1 << 7#N-MELEE
	autoCancelMaskMap[IDLE_SPRITE_ANIME_ID]= 1 << 8#N-SPECIAL
	autoCancelMaskMap[D_TOOL_REEL_ACTION_ID]= 1 << 9#N-TOOL
	autoCancelMaskMap[GROUND_BROKEN_STRING_IDLE_ACTION_ID]= 1 << 10#B-SPECIAL
	autoCancelMaskMap[AIR_TOOL_NO_BALL_REEL_ACTION_ID]= 1 << 11#BLOCK
	
	
	#iterate all actions
	var i = 0
	while i <= LARGEST_ACTION_ID:
		
		#by default actions are the same regardless
		#of if glove has ball of not
		var actionPairRow = []
		actionPairRow.append(i)
		actionPairRow.append(i)
		
		#add the id pair row
		actionIdGroups.append(actionPairRow)
		i = i +1
	
	#now here we explicilty state which animation is dependent on 
	#if glove has ball or not
	
	actionIdGroups[D_SPECIAL_BAT_HIT_ACTION_ID][STRING_BROKEN_ANIMATIONS_IX]=NO_STRING_D_SPECIAL_BAT_HIT_ACTION_ID
	actionIdGroups[U_SPECIAL_BAT_HIT_ACTION_ID][STRING_BROKEN_ANIMATIONS_IX]=NO_STRING_U_SPECIAL_BAT_HIT_ACTION_ID
	actionIdGroups[B_SPECIAL_BAT_HIT_ACTION_ID][STRING_BROKEN_ANIMATIONS_IX]=NO_STRING_F_SPECIAL_BAT_HIT_ACTION_ID
	actionIdGroups[N_SPECIAL_BAT_HIT_ACTION_ID][STRING_BROKEN_ANIMATIONS_IX]=NO_STRING_N_SPECIAL_BAT_HIT_ACTION_ID
	actionIdGroups[B_MELEE_BAT_HIT_ACTION_ID][STRING_BROKEN_ANIMATIONS_IX]=NO_STRING_B_MELEE_BAT_HIT_ACTION_ID
	actionIdGroups[U_MELEE_BAT_HIT_ACTION_ID][STRING_BROKEN_ANIMATIONS_IX]=NO_STRING_U_MELEE_BAT_HIT_ACTION_ID
	actionIdGroups[AIR_SPECIAL_BAT_HIT_ACTION_ID][STRING_BROKEN_ANIMATIONS_IX]=NO_STRING_AIR_SPECIAL_P1_BAT_HIT_ACTION_ID
	actionIdGroups[AIR_SPECIAL_BAT_P2_HIT_ACTION_ID][STRING_BROKEN_ANIMATIONS_IX]=NO_STRING_AIR_SPECIAL_P2_BAT_HIT_ACTION_ID
	actionIdGroups[AIR_SPECIAL_BAT_P3_HIT_ACTION_ID][STRING_BROKEN_ANIMATIONS_IX]=NO_STRING_AIR_SPECIAL_P3_BAT_HIT_ACTION_ID
	

	reelBackShieldHitTimer = frameTimerResource.new()
	reelUpShieldHitTimer = frameTimerResource.new()
	airReelShieldHitTimer = frameTimerResource.new()

	add_child(reelBackShieldHitTimer)
	add_child(reelUpShieldHitTimer)
	add_child(airReelShieldHitTimer)
	
	
	#SETUP the maps and lists for locking reel on shield hit

	var triple =[reelBackShieldHitTimer,B_TOOL_REEL_SPRITE_ANIME_ID,B_TOOL_REEL_ACTION_ID,false]
	onShieldHitReelMapSI[B_TOOL_REEL_SPRITE_ANIME_ID]=triple
	onShieldHitReelMapAI[B_TOOL_REEL_ACTION_ID]=triple
	reelBackShieldHitTimer.connect("timeout",self,"_on_sheild_hit_reel_lock_timeout",[triple])
	
	
	triple =[reelUpShieldHitTimer,U_TOOL_REEL_SPRITE_ANIME_ID,U_TOOL_REEL_ACTION_ID,false]
	onShieldHitReelMapSI[U_TOOL_REEL_SPRITE_ANIME_ID]=triple
	onShieldHitReelMapAI[U_TOOL_REEL_ACTION_ID]=triple
	reelUpShieldHitTimer.connect("timeout",self,"_on_sheild_hit_reel_lock_timeout",[triple])
	
	triple =[airReelShieldHitTimer,AIR_TOOL_NO_BALL_REEL_SPRITE_ANIME_ID,AIR_TOOL_NO_BALL_REEL_ACTION_ID,false]
	onShieldHitReelMapSI[AIR_TOOL_NO_BALL_REEL_SPRITE_ANIME_ID]=triple
	onShieldHitReelMapAI[AIR_TOOL_NO_BALL_REEL_ACTION_ID]=triple
	airReelShieldHitTimer.connect("timeout",self,"_on_sheild_hit_reel_lock_timeout",[triple])
	

	opponentDirectionDependentFacingMap[U_REEL_ON_HIT_SHIELDING_PLAYER_ACTION_ID]=null



		
#override to deal with reel lock logic
func _playAction(actionId,facingRight,cmd,on_hit_starting_sprite_frame_ix=0,preventOnHitFlagEnabled=false):	

	#we trying to play a reeel that may be locked from a shield hit?
	#was it a reel that get's locked out on sheild hit?
	if onShieldHitReelMapAI.has(actionId):
			
			var triple = onShieldHitReelMapAI[actionId]
			#can't play a reel taht recently hit a shield
			if triple[ON_SHIELD_HIT_MAP_LOCKED_FALG_IX]:
				return
	
	#check if we need to adjust the facing of ball in relation to where opponent is
	if opponentDirectionDependentFacingMap.has(actionId):
		
		var ballPos = playerController.kinbody.getCenter()
		var oppPos = playerController.masterPlayerController.opponentPlayerController.kinbody.getCenter()
		var ballRightOfOpponent = ballPos.x >= oppPos.x
		if ballRightOfOpponent:
			facingRight=false
		else:
			facingRight=true
	#call parrent script's function as useual
	._playAction(actionId,facingRight,cmd,on_hit_starting_sprite_frame_ix)			
			
#toggle the action id group index based on if string broken or not
func setStringAttachedFlag(flag):
	if flag:
		currentActionIdGroup = STRING_ATTACHED_ANIMATIONS_IX
	else:
		currentActionIdGroup = STRING_BROKEN_ANIMATIONS_IX



	
#sub classes can override this to change the aciton id dynamically
#depending on some special state. This function will be called when resolving the
#sprite id and movement id
func actionIdRemapHook(actionId):
	if actionId == null:
		return null
	return actionIdGroups[actionId][currentActionIdGroup]
	
func getBallHitBounceOffPlayerActionId(ballSpriteAnimeId,isOpponentBlocking):
	
	#special bounce properties when hitting shielding oppoent?
	if isOpponentBlocking and ballHitShieldingOpponentBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX].has(ballSpriteAnimeId):
		return ballHitShieldingOpponentBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][ballSpriteAnimeId]
	
	if not ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX].has(ballSpriteAnimeId):
		return null
	return ballHitBounceOffPlayerMap[BALL_HIT_ACTION_ID_IX][ballSpriteAnimeId]
func getBallHitBounceOffPlayerComplexMvm(ballSpriteAnimeId,isOpponentBlocking):
	#special bounce properties when hitting shielding oppoent?
	if isOpponentBlocking and ballHitShieldingOpponentBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX].has(ballSpriteAnimeId):
		return ballHitShieldingOpponentBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][ballSpriteAnimeId]
	
	if not ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX].has(ballSpriteAnimeId):
		return null
	return ballHitBounceOffPlayerMap[BALL_HIT_COMPLX_MVM_IX][ballSpriteAnimeId]
	
	
func _on_opponent_entered_block_stun(attackerHitbox,blockResult,spriteFacingRight):
	
	#it is the ball that caused block stun?
	if attackerHitbox.is_projectile:
		var sa = attackerHitbox.spriteAnimation
		
		#was it a reel that get's locked out on sheild hit?
		if onShieldHitReelMapSI.has(sa.id):
			
			var triple = onShieldHitReelMapSI[sa.id]
			triple[ON_SHIELD_HIT_MAP_LOCKED_FALG_IX] = true #lock that reel
			triple[ON_SHIELD_HIT_MAP_TIMER_IX].start(ON_SHIELD_HIT_REEL_LOCK_DURATION_IN_FRAMES) #start the lock coolodown
			#print("starting reel lock")

	
func unlockAllReels():
	for k in onShieldHitReelMapSI.keys():
		var triple = onShieldHitReelMapSI[k]
		triple[ON_SHIELD_HIT_MAP_LOCKED_FALG_IX]= false 
		
		
			
func _on_sheild_hit_reel_lock_timeout(triple):
	#triple indcies: timer, sprite anime id of reel, action anime id of reel, locked flag
	#unlock the reel
	#print("ending reel lock")
	triple[ON_SHIELD_HIT_MAP_LOCKED_FALG_IX]= false

