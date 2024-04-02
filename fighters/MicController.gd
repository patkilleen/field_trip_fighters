extends "res://PlayerController.gd"


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
	
	#make sure grab handler's sprite animation id throw lookup includes OPERA throws
	#so stance change briefly to populate the maps
	actionAnimeManager.toggleStanceChange()
	grabHandler.populateThrowSpriateAnimationIdMap()
	actionAnimeManager.toggleStanceChange()
	
	#stance change can be done on match start countdown
	inputManager.mvmOnlyCmdMap[inputManager.Command.CMD_NEUTRAL_TOOL]=true
	
	
func _on_action_animation_finished(spriteAnimationId):
	
	#check to see if we stance changed
	if spriteAnimationId == actionAnimeManager.NEUTRAL_TOOL_SPRITE_ANIME_ID or spriteAnimationId == actionAnimeManager.OPERA_NEUTRAL_TOOL_SPRITE_ANIME_ID:
		
		
		actionAnimeManager.toggleStanceChange()
		
		#rap stance change finished? that is, go into opera?
		#if spriteAnimationId == actionAnimeManager.NEUTRAL_TOOL_SPRITE_ANIME_ID:
		#	emit_signal("player_state_info_text_changed",GLOBALS.MIC_NOTIFICATION_TEXT_OPERA)
		#else:
		#	emit_signal("player_state_info_text_changed",GLOBALS.MIC_NOTIFICATION_TEXT_RAP)
			
	._on_action_animation_finished(spriteAnimationId)
	

	
func handleUserInputHook(_cmd):
	
	#we aren't allowing non movement commands (start of match)?
	if inputManager.movementOnlyCommands:
		#were in air?
		if not my_is_on_floor():
			#were trying stance change?
			if _cmd == inputManager.Command.CMD_NEUTRAL_TOOL:
				#don't allow n-air-tool attack
				return null
	return _cmd
	
func restart_hook():
	#for replays sake, we always start game as rap
	#actionAnimeManager.currentActionIdGroup = actionAnimeManager.RAP_ANIMATIONS_IX
	
	#always start in rap mode
	#emit_signal("player_state_info_text_changed",GLOBALS.MIC_NOTIFICATION_TEXT_RAP)
	
	.restart_hook()
	
	
	
	#by default just the raw grab handler mask is returned. subclasses will deal with different situtations
func getGrabAutoAbilityCancelMask(stanceIx,mask1Flag):
	
	if stanceIx== actionAnimeManager.RAP_ANIMATIONS_IX:
		#for the rap stance we return the grab auto ability cancel masks of rap
		if mask1Flag:
			return grabHandler.rapAbilityAutoCancelsOnHit
		else:
			return grabHandler.rapAbilityAutoCancelsOnHit2
	else:
		#for the rap stance we return the grab auto ability cancel masks of opera
		if mask1Flag:
			return grabHandler.operaAbilityAutoCancelsOnHit
		else:
			return grabHandler.operaAbilityAutoCancelsOnHit2