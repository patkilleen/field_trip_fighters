extends "res://PlayerController.gd"

signal entered_sifflet_stance
signal left_sifflet_stance

const NUMBER_BUFFERABLE_COLLAR_ACTIONS=3

const SIFFLET_STANCE_MANUALLY_CANCELED_RC=0
const SIFFLET_STANCE_DURATION_ELLAPSED_RC=1
const SIFFLET_STANCE_INTERRUPTED_RC=2
var staticCollarSpawn = null
var collarSpawn = null

var collarSpawnDelayEllapsedFrames=0

	
const NUM_FRAMES_AFTER_RESTART_TO_SPAWN_COLLAR=5
var spawnedCollarFlag=false

var siffletActionsCounter=0

const HERO_NO_BONES_SOUND_VOLUME=0
const HERO_NO_BONES_SOUND_ID = 49
var collar = null

var mvmOnlyToolCmds = {}
func init(sprite,collisionAreas,attackSFXs,bodyBox,activeNodes):
	
	HERO_HITSTUN_STUN_SOUND_ID = 30
	HERO_RIPOST_SOUND_ID = 17
	HERO_COUNTER_RIPOST_SOUND_ID = 18
	HERO_INCORRECT_BLOCK_SOUND_ID=40
	
	ripostVoicelineVolumeOffset=3
	counterRipostVoicelineVolumeOffset=3
	badBlockVoicelineVolumeOffset=3
	gettingHitVoicelineVolumeOffset=3

	
	
	#call parent's init
	.init(sprite,collisionAreas,attackSFXs,bodyBox,activeNodes)	
	
	
	staticCollarSpawn = $"static-collar-spawn"
	staticCollarSpawn.init(1,self) #one collar instance will ever exist

	collarSpawn = $"collar-projectile"
	#null sprite animation id since will dynamically set it
	collarSpawn.init(self,null)
	collarSpawn.connect("create_projectile",self,"_on_collar_instanced")
	

	
	#allow air tool glide at start of match
	inputManager.mvmOnlyCmdMap[inputManager.Command.CMD_NEUTRAL_TOOL]=true
	inputManager.mvmOnlyCmdMap[inputManager.Command.CMD_BACKWARD_TOOL]=true
	inputManager.mvmOnlyCmdMap[inputManager.Command.CMD_FORWARD_TOOL]=true
	inputManager.mvmOnlyCmdMap[inputManager.Command.CMD_DOWNWARD_TOOL]=true
	inputManager.mvmOnlyCmdMap[inputManager.Command.CMD_UPWARD_TOOL]=true
	
	
	mvmOnlyToolCmds[inputManager.Command.CMD_NEUTRAL_TOOL]=null
	mvmOnlyToolCmds[inputManager.Command.CMD_BACKWARD_TOOL]=null
	mvmOnlyToolCmds[inputManager.Command.CMD_FORWARD_TOOL]=null
	mvmOnlyToolCmds[inputManager.Command.CMD_DOWNWARD_TOOL]=null
	mvmOnlyToolCmds[inputManager.Command.CMD_UPWARD_TOOL]=null
	
#func _on_action_animation_finished(spriteAnimationId):
	
	#check to see if we stance changed
#	if spriteAnimationId == actionAnimeManager.NEUTRAL_TOOL_SPRITE_ANIME_ID or spriteAnimationId == actionAnimeManager.OPERA_NEUTRAL_TOOL_SPRITE_ANIME_ID:
		
		
#		actionAnimeManager.toggleStanceChange()
		
		#rap stance change finished? that is, go into opera?
		#if spriteAnimationId == actionAnimeManager.NEUTRAL_TOOL_SPRITE_ANIME_ID:
		#	emit_signal("player_state_info_text_changed",GLOBALS.MIC_NOTIFICATION_TEXT_OPERA)
		#else:
		#	emit_signal("player_state_info_text_changed",GLOBALS.MIC_NOTIFICATION_TEXT_RAP)
			
#	._on_action_animation_finished(spriteAnimationId)
	
#to be implemented by subclasses. Used to load a single type of projectile 
#to be spawned at multiple areas
func getStaticProjectileSpawn(customProjectileSpawnData):
	
	return staticCollarSpawn
	
	
func handleUserInputHook(_cmd):
	
	#we aren't allowing non movement commands (start of match)?
	if inputManager.movementOnlyCommands:
		#were on ground?
		if my_is_on_floor():
			
			#on the ground and doing a tool?
			if mvmOnlyToolCmds.has(_cmd):
				#don't allow it for mvm only commands
				#only allow it in air
				return null
			
	return _cmd
	
func restart_hook():
	#for replays sake, we always start game as rap
	#actionAnimeManager.currentActionIdGroup = actionAnimeManager.RAP_ANIMATIONS_IX
	siffletActionsCounter=0
	collarSpawnDelayEllapsedFrames=0
	spawnedCollarFlag=false
	
	#always start in rap mode
	#emit_signal("player_state_info_text_changed",GLOBALS.MIC_NOTIFICATION_TEXT_RAP)
	
	.restart_hook()
	
	
	#timer.startInSeconds(1)
	#wait 1 sec to let players know connected to peer
	#yield(get_tree().create_timer(1),"timeout")
	#yield(timer,"timeout")
	
	

func handleAirToolAttackInput(actualCmd,treatAsCmd):
	var commandConsummed  =false

	#special condition where can't cahnge facing ?
	if mirrorAirActionDIRequired():
		match(actualCmd):
			
			inputManager.Command.CMD_BACKWARD_TOOL,inputManager.Command.CMD_COUNTER_RIPOST_BACKWARD_TOOL:
				commandConsummed= playUserInputAction(actionAnimeManager.AIR_NEUTRAL_TOOL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(actualCmd))			
			inputManager.Command.CMD_FORWARD_TOOL,inputManager.Command.CMD_COUNTER_RIPOST_FORWARD_TOOL:
				commandConsummed= playUserInputAction(actionAnimeManager.BACKWARD_TOOL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(actualCmd))			
			_:#NOT Back tool?. so doe normal
				commandConsummed= .handleAirToolAttackInput(actualCmd,treatAsCmd)					
	else:
		#EVERY TOOL INPUT IN THE AIR IS FORWARD AIR TOOL. ONLY BACK INPUT WILL DO BACK TOOL		
		#ball cap is not on hat's head, so he can ball cap dash in air
		match(actualCmd):
			
			inputManager.Command.CMD_BACKWARD_TOOL,inputManager.Command.CMD_COUNTER_RIPOST_BACKWARD_TOOL:
				commandConsummed= playUserInputAction(actionAnimeManager.BACKWARD_TOOL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(actualCmd))			
			_:#NOT Back tool?. so doe normal
				commandConsummed= .handleAirToolAttackInput(actualCmd,treatAsCmd)
		
				
	return commandConsummed	



func _on_land():
	actionAnimeManager.currentActionIdGroup =actionAnimeManager.NORMAL_STANCE_IX
	._on_land()
func _on_left_ground():
	actionAnimeManager.currentActionIdGroup =actionAnimeManager.AIR_STANCE_IX
	._on_left_ground()
	
	#by default just the raw grab handler mask is returned. subclasses will deal with different situtations
func getGrabAutoAbilityCancelMask(stanceIx,mask1Flag):
		#for the rap stance we return the grab auto ability cancel masks of rap
	if mask1Flag:
		return grabHandler.rapAbilityAutoCancelsOnHit
	else:
		return grabHandler.rapAbilityAutoCancelsOnHit2
		
func _on_collar_instanced(projectileInstance,spawnPoint):	 
	collar = projectileInstance
	projectileInstance.projectileParentSpriteAnimation=null#should be fine for null, nothing is creating it. it spawns when game starts
	_on_create_projectile(projectileInstance,spawnPoint)
	

func _on_action_animation_finished(spriteAnimationId):
	
	#sifflet stance wistle animation that ends the sifflet stance?
	if actionAnimeManager.isOnFinishAnimationSiffletStanceEnder(spriteAnimationId):

		#print("leaving sifflet stance, and confirming buffered actions")
		actionAnimeManager.leaveSiffletStance()
		emit_signal("left_sifflet_stance",SIFFLET_STANCE_DURATION_ELLAPSED_RC)
		pass
		
	._on_action_animation_finished(spriteAnimationId)
	
	
func _on_sprite_animation_played(sa):
	
	#did neutral tool to enter sifflet stance?
	if sa != null:
		
		if sa.id == actionAnimeManager.NEUTRAL_TOOL_SPRITE_ANIME_ID:
			siffletActionsCounter=0
			actionAnimeManager.enterSiffletStance()			
			#print("entering sifflet stance")
			emit_signal("entered_sifflet_stance")
		elif sa.id == actionAnimeManager.SIFFLET_STANCE_NEUTRAL_TOOL_SPRITE_ANIME_ID:
				#print("leaving sifflet stance, and confirming buffered actions")
				actionAnimeManager.leaveSiffletStance()
				emit_signal("left_sifflet_stance", SIFFLET_STANCE_MANUALLY_CANCELED_RC)
		
		#so we played an animation during sifflet stance that isn't any of the ground tools? Exit the stance witout having collar do commands
		elif actionAnimeManager.isInSiffletStance():
			
			if actionAnimeManager.isSiffletStanceActionIssuerSpriteAnimation(sa.id):
				#count the number of buffered commands
				siffletActionsCounter = siffletActionsCounter +1
				#print("buffering a collar command in sifflet stance")
				if siffletActionsCounter>=NUMBER_BUFFERABLE_COLLAR_ACTIONS:
					siffletActionsCounter=0
					actionAnimeManager.beginEndingSiffletStance()
			else:
				#print("leaving sifflet stance, and dropping buffered actions")
				actionAnimeManager.leaveSiffletStance()
				emit_signal("left_sifflet_stance",SIFFLET_STANCE_INTERRUPTED_RC)
		
		
	._on_sprite_animation_played(sa)

func _on_number_collar_bones_changed(numBones):
	
	emit_signal("player_state_info_text_changed",numBones)
	
#signals to hud that we tried to do collar action but didn't have anough bones
func signalInsufficientNumberOfBones():
	_on_request_play_special_sound(HERO_NO_BONES_SOUND_ID,HERO_SOUND_SFX,HERO_NO_BONES_SOUND_VOLUME)
	
	emit_signal("player_state_info_text_changed",GLOBALS.WHISTLE_NOT_ENOUGH_BONES_IX)
	
	
#special training mode hook to allow get instead bones back
func trainingModeEnterCharDependentState(params):
	collar.currNumBones = collar.maxNumberOfBones
	
	_on_number_collar_bones_changed(collar.currNumBones)
	pass

func _physics_process(delta):
	
	if not spawnedCollarFlag:
		if collarSpawnDelayEllapsedFrames<	NUM_FRAMES_AFTER_RESTART_TO_SPAWN_COLLAR:
			collarSpawnDelayEllapsedFrames = collarSpawnDelayEllapsedFrames+1
		else:
			spawnedCollarFlag=true
			#spawn collar 
			collarSpawn.signalProjectileCreation()
	
	
	