extends Node

const CROUCH_SHORT_ANIMATION_FRAME_LIMIT = 14
const MOVE_FORWARD_SHORT_ANIMATION_FRAME_LIMIT = 10
var frameTimerResource = preload("res://frameTimer.gd")
var GLOBALS = preload("res://Globals.gd")
var shortAnimationTimer = null
var collectingDemoData = false setget setCollectingDemoData,getCollectingDemoData
var situationHandler = null
var aiAgent = null
var playerController =null

const PROJECTILE_SAFE_BIT = 0
const PROJECTILE_DANGER_BIT = 1
const PROJECTILE_CREATED_ON_GROUND_BIT = 1 << 1
const PROJECTILE_CREATED_ON_PLATFORM_BIT = 1 << 2

const NOT_BLOCKING_STATE = 0
const BLOCKING_STATE = 1
const BUDGET_BLOCKING_STATE = 2
const CROUCH_BUDGET_BLOCKING_STATE = 3

const DELTA_POS_FROM_IX = 0
const DELTA_POS_TO_IX = 1

const TRUE_BIT=1
const FALSE_BIT=0
#TODO: map design distances to this table
var deltaPositionHistogramBinRanges = [
#from,		to
[0,5], #e.g: 4.99 is bin 0, 5 is bin 1
[5,10],
[10,20],
[20,30],
[30,40],
[40,50],
[50,60],
[60,70],
[70,80],
[80,100],
[100,130],
[130,170],
[170,220],
[220,270],
[270,350],
[350,450],
[450,500],
[500,600],
[600,700],
[700,5000],#last bin, 5000 should exceed cmaera dimensions
]

# map that stores the types and indexces of techs: key = tech type (defined in globals), and value = tech frequency index
#in ai db
var techTypeIxMap = {}
var paramBuffer = []

var enemyProjectiles = {}

#key: sprite animation id, value : frames until no longer considered short animation
var shortSpriteAnimationMap = {}

#key: sprite animation id of a block, value : the block status 
var blockSpriteAnimationMap = {}
var blockEnemySpriteAnimationMap = {}

var paramBufferMutex = null
func _ready():
	pass # Replace with function body.

func init(_playerController,_situationHandler, _aiAgent):
	playerController = _playerController
	situationHandler= _situationHandler
	aiAgent = _aiAgent
	
	#TODO ADD logic for the new DI tech types. for now do nothing
	techTypeIxMap[GLOBALS.TYPE_GROUND_TECH_IN_PLACE]=situationHandler.aiDB.FLOOR_TECH_IN_PLACE_IX
	techTypeIxMap[GLOBALS.TYPE_GROUND_TECH_ROLL_BACKWARD]=situationHandler.aiDB.FLOOR_TECH_BACKWARD_IX
	techTypeIxMap[GLOBALS.TYPE_GROUND_TECH_ROLL_FORWARD]=situationHandler.aiDB.FLOOR_TECH_FORWARD_IX
	techTypeIxMap[GLOBALS.TYPE_GROUND_TECH_BOUNCE_UP]=situationHandler.aiDB.FLOOR_TECH_IN_PLACE_IX

	techTypeIxMap[GLOBALS.TYPE_CEILING_TECH_IN_PLACE]=situationHandler.aiDB.FLOOR_TECH_IN_PLACE_IX
	techTypeIxMap[GLOBALS.TYPE_CEILING_TECH_BOUNCE_DOWN]=situationHandler.aiDB.FLOOR_TECH_IN_PLACE_IX
	techTypeIxMap[GLOBALS.TYPE_CEILING_TECH_BOUNCE_FORWARD]=situationHandler.aiDB.FLOOR_TECH_IN_PLACE_IX
	techTypeIxMap[GLOBALS.TYPE_CEILING_TECH_BOUNCE_BACK]=situationHandler.aiDB.FLOOR_TECH_IN_PLACE_IX
		
	techTypeIxMap[GLOBALS.TYPE_WALL_TECH_IN_PLACE]=situationHandler.aiDB.WALL_TECH_IX
	techTypeIxMap[GLOBALS.TYPE_WALL_TECH_BOUNCE_UP]=situationHandler.aiDB.WALL_TECH_IX
	techTypeIxMap[GLOBALS.TYPE_WALL_TECH_BOUNCE_AWAY]=situationHandler.aiDB.WALL_TECH_IX
	techTypeIxMap[GLOBALS.TYPE_WALL_TECH_BOUNCE_DOWN]=situationHandler.aiDB.WALL_TECH_IX
	
	#pre-allocated the paramter buffer
	for i in range(situationHandler.NUMBER_OF_SERIALIZED_PARAMETERS):
	
		paramBuffer.append(null)
	
	#initialize some of the parameters to default values that would
	#otherwise not necessarily be set in next frame or create a bug if let null
	paramBuffer[situationHandler.NUMBER_ACTIVE_ENEMY_PROJECTILES_IX] = 0
	paramBuffer[situationHandler.ENEMY_TOTAL_DAMAGE_TAKEN_IX] = 0
	paramBuffer[situationHandler.CHARACTER_ON_PLATFORM_IX] = FALSE_BIT
	paramBuffer[situationHandler.ENEMY_ON_PLATFORM_IX] = FALSE_BIT
	paramBuffer[situationHandler.ENEMY_BLOCKING_STATUS_IX]=NOT_BLOCKING_STATE
	paramBuffer[situationHandler.CHARACTER_BLOCKING_STATUS_IX]=NOT_BLOCKING_STATE
	paramBuffer[situationHandler.ENEMY_IS_ABOVE_IX]=0
	
	paramBufferMutex = Mutex.new()
	
	
	#populate the short animation sprite map (we do it here
	#since the ids of sprite animation change based on 
	#action anaimation manager, so it must be done dynamically)
	shortSpriteAnimationMap[playerController.actionAnimeManager.CROUCH_SPRITE_ANIME_ID] = CROUCH_SHORT_ANIMATION_FRAME_LIMIT
	shortSpriteAnimationMap[playerController.actionAnimeManager.WALK_FORWARD_SPRITE_ANIME_ID] = MOVE_FORWARD_SHORT_ANIMATION_FRAME_LIMIT
	
	#same thing for blocking state sprite ids
	blockSpriteAnimationMap[playerController.actionAnimeManager.AUTO_RIPOST_SPRITE_ANIME_ID]= BLOCKING_STATE
	blockSpriteAnimationMap[playerController.actionAnimeManager.WALK_BACKWARD_SPRITE_ANIME_ID]= BUDGET_BLOCKING_STATE
	blockSpriteAnimationMap[playerController.actionAnimeManager.PROXIMITY_GUARD_CROUCHING_HOLD_BACK_BLOCK_SPRITE_ANIME_ID]= CROUCH_BUDGET_BLOCKING_STATE
	blockSpriteAnimationMap[playerController.actionAnimeManager.BUDGET_BLOCK_HIT_LAG_SPRITE_ANIME_ID]= BUDGET_BLOCKING_STATE # this is when were in hit lag from block, but stil budget blocking
	blockSpriteAnimationMap[playerController.actionAnimeManager.CROUCHING_BUDGET_BLOCK_HIT_LAG_SPRITE_ANIME_ID]= CROUCH_BUDGET_BLOCKING_STATE # this is when were in hit lag from block, but stil crouch budget blocking
	
	#populate map for enemey as well (if not dittos, sprite ids may be different)
	blockEnemySpriteAnimationMap[playerController.opponentPlayerController.actionAnimeManager.AUTO_RIPOST_SPRITE_ANIME_ID]= BLOCKING_STATE
	blockEnemySpriteAnimationMap[playerController.opponentPlayerController.actionAnimeManager.WALK_BACKWARD_SPRITE_ANIME_ID]= BUDGET_BLOCKING_STATE
	blockEnemySpriteAnimationMap[playerController.opponentPlayerController.actionAnimeManager.PROXIMITY_GUARD_CROUCHING_HOLD_BACK_BLOCK_SPRITE_ANIME_ID]= CROUCH_BUDGET_BLOCKING_STATE
	blockEnemySpriteAnimationMap[playerController.opponentPlayerController.actionAnimeManager.BUDGET_BLOCK_HIT_LAG_SPRITE_ANIME_ID]= BUDGET_BLOCKING_STATE # this is when were in hit lag from block, but stil budget blocking
	blockEnemySpriteAnimationMap[playerController.opponentPlayerController.actionAnimeManager.CROUCHING_BUDGET_BLOCK_HIT_LAG_SPRITE_ANIME_ID]= CROUCH_BUDGET_BLOCKING_STATE # this is when were in hit lag from block, but stil crouch budget blocking
	
	
	shortAnimationTimer = frameTimerResource.new()
	
	self.call_deferred("add_child",shortAnimationTimer)
	
	
	playerController.collisionHandler.connect("pushed_against_wall",self,"_on_wall_collide")
	playerController.connect("landed",self,"_on_ground_collide")
	playerController.collisionHandler.connect("pushed_against_ceiling",self,"_on_ceiling_collide")
	
	
	playerController.techHandler.connect("successful_tech",self,"_on_successful_tech")
	playerController.connect("ability_cancel",self, "_on_ability_cancel")
	
	playerController.collisionHandler.connect("left_ground",self,"_on_left_floor")
	playerController.collisionHandler.connect("landing_on_ground",self,"_on_land_on_floor")
	playerController.collisionHandler.connect("left_platform",self,"_on_left_platform")
	playerController.collisionHandler.connect("landing_on_platform",self,"_on_landed_on_platform")
	
	playerController.opponentPlayerController.collisionHandler.connect("left_ground",self,"_on_enemy_left_floor")
	playerController.opponentPlayerController.collisionHandler.connect("landing_on_ground",self,"_on_enemy_land_on_floor")
	playerController.opponentPlayerController.collisionHandler.connect("left_platform",self,"_on_enemy_left_platform")
	playerController.opponentPlayerController.collisionHandler.connect("landing_on_platform",self,"_on_enemy_landed_on_platform")
	
	playerController.actionAnimeManager.spriteAnimationManager.connect("sprite_frame_activated",self,"_on_sprite_frame_activated")
	playerController.opponentPlayerController.actionAnimeManager.spriteAnimationManager.connect("sprite_frame_activated",self,"_on_enemy_sprite_frame_activated")
	playerController.actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_sprite_animation_played")
	playerController.opponentPlayerController.actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_enemy_sprite_animation_played")
	#playerController.connect("base_damage_taken",self,"_on_base_damage_taken")
	playerController.opponentPlayerController.connect("about_to_be_applied_hitstun",self,"_on_about_to_apply_hitstun_to_player")
	
	playerController.connect("starting_new_combo",self,"_on_combo_started")
	
	#playerController.connect("cmd_action_changed",self,"_on_command_consummed")
	playerController.connect("cmd_inputed",self,"_on_command_inputed")
	
	
	playerController.actionAnimeManager.connect("create_projectile",self,"_on_enemy_projectile_created")
	
	
#convert a flag to 1 or 0 integer
func boolToInt(flag):
	if flag:
		return TRUE_BIT
	else:
		return FALSE_BIT
		
func setCollectingDemoData(flag):
	collectingDemoData = flag
	
func getCollectingDemoData():
	return collectingDemoData

#gathers all the states and parses them into a situation id
func parseCurentSituationId():
	
	var paramBufferCopy = []
	#parse the delta positions ()
	#get center of sprites
	var charPos = playerController.kinbody.getCenter()
	var enemyPos = playerController.opponentPlayerController.kinbody.getCenter()
	
	
	paramBuffer[situationHandler.ENEMY_IS_ABOVE_IX] = boolToInt(enemyPos.y < charPos.y) #(smaller y means higher on stage)
	
	#distance of players
	var deltaX = abs(charPos.x - enemyPos.x)
	var deltaY = abs(charPos.y - enemyPos.y)
	
	paramBufferMutex.lock()
	
	paramBuffer[situationHandler.DELTA_X_POS_IX] = discretizeDeltaPosition(deltaX)
	paramBuffer[situationHandler.DELTA_Y_POS_IX] = discretizeDeltaPosition(deltaY)
	
	#parse the projectile states
	computeEnemyProjectilesState()
	
	paramBuffer[situationHandler.CHARACTER_FACING_RIGHT_IX] =boolToInt(playerController.kinbody.facingRight)
	paramBuffer[situationHandler.CHARACTER_IN_CORNER_IX] = boolToInt(playerController.kinbody.leftWallDetector.is_colliding() or playerController.kinbody.rightWallDetector.is_colliding())
	paramBuffer[situationHandler.ENEMY_IN_CORNER_IX] = boolToInt(playerController.opponentPlayerController.kinbody.leftWallDetector.is_colliding() or playerController.opponentPlayerController.kinbody.rightWallDetector.is_colliding())
	paramBuffer[situationHandler.CHARACTER_NUMBER_JUMPS_REMAINING_IX] = playerController.playerState.currentNumJumps
	paramBuffer[situationHandler.ENEMY_NUMBER_JUMPS_REMAINING_IX] = playerController.opponentPlayerController.playerState.currentNumJumps
	
	
	#copy over parameters so the creation of situation 
	#is done on a local array only (so elements can't be touched 
	#during calculations
	
	for p in paramBuffer:
		paramBufferCopy.append(p)
	paramBufferMutex.unlock()
	
	
	return situationHandler.createSituationId(paramBufferCopy)
	
	
#note that ai agent liek for glove can override this 
#for custom projectile states
func computeEnemyProjectilesState():

#for now, ignore if create on ground or platform. furutre work is to check the ray casts of
#the enemy, to see if on ground during projectile creation, and put the bool in a map,
#and query map right now
	
	#position of character's center
	var charCenter = playerController.kinbody.getCenter()
	
	paramBufferMutex.lock()
	
	#reset preojctile state
	paramBuffer[situationHandler.ENEMY_PROJECTILES_STATE_IX] = 0
	
	
	
	#iterate the projectiles
	for p in enemyProjectiles.keys():
		
		#projectile is active?
		if enemyProjectiles[p] != null:
			
			#check if its safe. A safe proectjile (samus/ken) is one that is
			#heading away from the character/player
			#so: cases where safe follow:
			#note that projectile faces the direction its going
			var safeFlag = false
			
			#player 1 is left of projectile heading right
			if charCenter.x < p.position.x and p.facingRight:
				safeFlag=true
			#player 1 is right of projectile heading right
			elif charCenter.x > p.position.x and not p.facingRight:
				safeFlag=true
			
			
			#add bit to projectile state	
			if safeFlag:
				paramBuffer[situationHandler.ENEMY_PROJECTILES_STATE_IX] = paramBuffer[situationHandler.ENEMY_PROJECTILES_STATE_IX] | PROJECTILE_SAFE_BIT
			else: #note safe
				paramBuffer[situationHandler.ENEMY_PROJECTILES_STATE_IX] = paramBuffer[situationHandler.ENEMY_PROJECTILES_STATE_IX] | PROJECTILE_DANGER_BIT

	paramBufferMutex.unlock()
#convert the relateive position to a bin position
func discretizeDeltaPosition(pos):
	
	#TODO: make a binary search for what bin it is found in
	#iterate through the bins to find where position lies
	for i in range(deltaPositionHistogramBinRanges.size()):
		
		var bin = deltaPositionHistogramBinRanges[i]
		#position in bin?
		if pos >= bin[DELTA_POS_FROM_IX] and  pos < bin[DELTA_POS_TO_IX]:
			return i
	
	#should never happen		
	return -1	
	
func _on_wall_collide(collider):
	if not collectingDemoData:
		return
	#count number of wall collisions
	situationHandler.aiDB.increaseWallCollisionFrequency()

func _on_ceiling_collide(collider):
	if not collectingDemoData:
		return
	#count number of ceiling collisions
	situationHandler.aiDB.increaseCeilingCollisionFrequency()

#called when land on platform or floor
func _on_ground_collide():
	if not collectingDemoData:
		return
	#count number of floor collisions
	situationHandler.aiDB.increaseFloorCollisionFrequency()
		
				
func _on_successful_tech(framesRemaining,type):
	
	if not collectingDemoData:
		return
		
	var techTypeIx = techTypeIxMap[type]
	
	#COUNT FREQUNECY of the given tech (type is in-place, left, right, celiling, or wall)	
	situationHandler.aiDB.increaseTechFrequency(techTypeIx)

func _on_ability_cancel(numberOfChunks,spriteFrame,autoAbilityCancelFlag):

	if not collectingDemoData:
		return
		
	situationHandler.aiDB.incrementAbilityCancelFrequency(spriteFrame)
	
func _on_sprite_frame_activated(spriteFrame):
	
	paramBufferMutex.lock()
	#note, this works, since the enums align with state valeus
	#ie NEUTRAL = 0, STARTUP = 1, ACTIVE = 2, RECOVERY = 3
	paramBuffer[situationHandler.CHARACTER_SPRITE_ANIMATION_STATE_IX] = int(spriteFrame.type) 
	
	paramBufferMutex.unlock()
	
	if not collectingDemoData:
		return
		
	situationHandler.aiDB.incrementSpriteFrameFrequency(spriteFrame)

func _on_enemy_sprite_frame_activated(spriteFrame):
	
	paramBufferMutex.lock()
	#note, this works, since the enums align with state valeus
	#ie NEUTRAL = 0, STARTUP = 1, ACTIVE = 2, RECOVERY = 3
	paramBuffer[situationHandler.ENEMY_SPRITE_ANIMATION_STATE_IX] = int(spriteFrame.type) 	

	paramBufferMutex.unlock()
	#don't need to track enemy's sprite frame frequency, since just need the type of current
	#spreite frame for situations	

#called when land on floor (not on platform)	
func _on_land_on_floor():
	paramBufferMutex.lock()
	paramBuffer[situationHandler.CHARACTER_ON_GROUND_IX] = TRUE_BIT
	paramBufferMutex.unlock()

func _on_enemy_land_on_floor():
	paramBufferMutex.lock()
	paramBuffer[situationHandler.ENEMY_ON_GROUND_IX] = TRUE_BIT
	paramBufferMutex.unlock()
	
func _on_left_floor():
	paramBufferMutex.lock()
	paramBuffer[situationHandler.CHARACTER_ON_GROUND_IX] = FALSE_BIT
	paramBufferMutex.unlock()
	
func _on_enemy_left_floor():
	paramBufferMutex.lock()
	paramBuffer[situationHandler.ENEMY_ON_GROUND_IX] = FALSE_BIT
	paramBufferMutex.unlock()
	
func _on_left_platform():
	paramBufferMutex.lock()
	paramBuffer[situationHandler.CHARACTER_ON_PLATFORM_IX] = FALSE_BIT
	paramBufferMutex.unlock()
	
func _on_enemy_left_platform():
	paramBufferMutex.lock()
	paramBuffer[situationHandler.ENEMY_ON_PLATFORM_IX] = FALSE_BIT
	paramBufferMutex.unlock()
	
func _on_landed_on_platform():
	paramBufferMutex.lock()
	paramBuffer[situationHandler.CHARACTER_ON_PLATFORM_IX] = TRUE_BIT
	paramBufferMutex.unlock()
	
func _on_enemy_landed_on_platform():
	paramBufferMutex.lock()
	paramBuffer[situationHandler.ENEMY_ON_PLATFORM_IX] = TRUE_BIT
	paramBufferMutex.unlock()
	
#called when character starts a combo on opponent
func _on_combo_started():
	paramBufferMutex.lock()
	#reset damage given
	paramBuffer[situationHandler.ENEMY_TOTAL_DAMAGE_TAKEN_IX]  = 0
	paramBufferMutex.unlock()
	
#called when dealing damage to opponent, 
#ignoring all modifiers, just giving the base damage of the hitbox
#func _on_base_damage_taken(dmg):
func _on_about_to_apply_hitstun_to_player(spriteAnimeId,relativeDamage):
	
	if spriteAnimeId == null:
		return
	
	paramBufferMutex.lock()
	#keep track of total base damage dealt during combo
	#paramBuffer[situationHandler.ENEMY_TOTAL_DAMAGE_TAKEN_IX]  = paramBuffer[situationHandler.ENEMY_TOTAL_DAMAGE_TAKEN_IX]  + int(dmg)
	paramBuffer[situationHandler.ENEMY_TOTAL_DAMAGE_TAKEN_IX]  = paramBuffer[situationHandler.ENEMY_TOTAL_DAMAGE_TAKEN_IX]  + int(spriteAnimeId)
	paramBufferMutex.unlock()

func _on_enemy_projectile_created(projectile,spawnPoint):
	
	paramBufferMutex.lock()
	#increment projectile count of enemey
	paramBuffer[situationHandler.NUMBER_ACTIVE_ENEMY_PROJECTILES_IX] = paramBuffer[situationHandler.NUMBER_ACTIVE_ENEMY_PROJECTILES_IX] + 1
	paramBufferMutex.unlock()
	
	enemyProjectiles[projectile]=projectile
	
	if not projectile.is_connected("destroyed",self,"_on_enemy_projectile_destroyed") :
		projectile.connect("destroyed",self,"_on_enemy_projectile_destroyed")
	

func _on_enemy_projectile_destroyed(projectile):
	
	paramBufferMutex.lock()
	#decrement projectile count of enemey
	paramBuffer[situationHandler.NUMBER_ACTIVE_ENEMY_PROJECTILES_IX] = paramBuffer[situationHandler.NUMBER_ACTIVE_ENEMY_PROJECTILES_IX] -1
	paramBufferMutex.unlock()
	#remove the proejctile referecne
	enemyProjectiles[projectile] = null
	
#called when a new sprite animation is played by enemy/opponent 
func _on_enemy_sprite_animation_played(spriteAnimation):
	
	paramBufferMutex.lock()
	#ignore short animation logic for enemy sprite animations
	paramBuffer[situationHandler.ENEMY_SPRITE_ANIMATION_ID_IX] =spriteAnimation.id
	
	
	#is it a block sprite animation?
	if blockEnemySpriteAnimationMap.has(spriteAnimation.id):
		paramBuffer[situationHandler.ENEMY_BLOCKING_STATUS_IX]=blockEnemySpriteAnimationMap[spriteAnimation.id]
	else:
		paramBuffer[situationHandler.ENEMY_BLOCKING_STATUS_IX]=NOT_BLOCKING_STATE
		
	paramBufferMutex.unlock()
#called when a new sprite animation is played
func _on_sprite_animation_played(spriteAnimation):
	
	paramBufferMutex.lock()
	#check for special case when first time playing an animation (start of match)
	if paramBuffer[situationHandler.CHARACTER_SPRITE_ANIMATION_ID_IX] == null:
		paramBuffer[situationHandler.CHARACTER_SPRITE_ANIMATION_ID_IX]=spriteAnimation.id
		paramBufferMutex.unlock()
		return 
	
	#this is an animation that may be short animation, so don't replace last recoded sprite
	#aniamtion id
	if shortSpriteAnimationMap.has(spriteAnimation.id):
	
		#start the timer for short animation duratino 
		#(can just squash the last short animation timer
		#since it clearly didn't go off, since were in new animation
		#before time limit occured)
		shortAnimationTimer.start(shortSpriteAnimationMap[spriteAnimation.id])
		
		#we reconnect every tiem to pass the shortanimation sprite id as paramter
		#for when timout occurs
		if shortAnimationTimer.is_connected("timeout",self,"_on_short_animation_time_limit_ellapsed"):
			shortAnimationTimer.disconnect("timeout",self,"_on_short_animation_time_limit_ellapsed")
			
		shortAnimationTimer.connect("timeout",self,"_on_short_animation_time_limit_ellapsed",[spriteAnimation.id])
		
	else:
		#we now changed into a non-shortanimation, so don't worry about keeping track of short animation frames anymore
		shortAnimationTimer.stop()
		paramBuffer[situationHandler.CHARACTER_SPRITE_ANIMATION_ID_IX] = spriteAnimation.id
		
		#is it a block sprite animation?
		if blockSpriteAnimationMap.has(spriteAnimation.id):
			paramBuffer[situationHandler.CHARACTER_BLOCKING_STATUS_IX]=blockSpriteAnimationMap[spriteAnimation.id]
		else:
			paramBuffer[situationHandler.CHARACTER_BLOCKING_STATUS_IX]=NOT_BLOCKING_STATE
	
	paramBufferMutex.unlock()
#called when player consummed a commmand (command wasn't eaten due 
#to non-cancelable or poor input buffering)
#func _on_command_consummed(cmd):
func _on_command_inputed(cmd, ripostCmdFlag,counterRipostCmdFlag):
	
	#for now we assume pause commands won't appear here (by desing of player controler's handlerUserinput)
	#if not collectingDemoData or cmd == null or ripostCmdFlag or counterRipostCmdFlag:
	if not collectingDemoData or ripostCmdFlag or counterRipostCmdFlag:
	#if not collectingDemoData or cmd == null:
		return
		
		
	#do consider logging null commands as no ops
	var situationId = parseCurentSituationId()
	
	#store the situation id and command
	if aiAgent != null:		
		aiAgent.agentWorker.requestLogCommandSituationPair(cmd,situationId)
	else:
		situationHandler.aiDB.logCommandSituationPair(cmd,situationId)
#called when the short aniamtion frame time limit expires, indicating the
#short animatin is now actually an animation to consider for parsing sprite animation ids	
func _on_short_animation_time_limit_ellapsed(shortSpriteAnimationId):
	paramBufferMutex.lock()
	paramBuffer[situationHandler.CHARACTER_SPRITE_ANIMATION_ID_IX] = shortSpriteAnimationId
	paramBufferMutex.unlock()
