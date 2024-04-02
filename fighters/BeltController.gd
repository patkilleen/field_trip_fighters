extends "res://PlayerController.gd"

var angerSmoke = null
var angerSmoke2 = null
#var angerSmoke3 = null
var isAngry = false

const GETTING_ANGRY_SOUND_ID=1
const ANGRY_GUARD_DAMAGE_BONUS_MOD = 1.15
const LOSING_ANGRY_STATE_HITFREEZE = 15
const ANGRY_STATE_DURATION_IN_SECONDS = 4
var angryStateTimer = null

var angryVoiceLineSoundVolume=5

var angryProgressBar = null

func init(sprite,collisionAreas,attackSFXs,bodyBox,activeNodes):	
	HERO_HITSTUN_STUN_SOUND_ID = 0
	HERO_RIPOST_SOUND_ID = 13
	HERO_COUNTER_RIPOST_SOUND_ID = 15
	HERO_INCORRECT_BLOCK_SOUND_ID=30
	
	ripostVoicelineVolumeOffset=10
	counterRipostVoicelineVolumeOffset=10
	badBlockVoicelineVolumeOffset=7
	gettingHitVoicelineVolumeOffset=5
	
	.init(sprite,collisionAreas,attackSFXs,bodyBox,activeNodes)
	angerSmoke = get_node("../AngerSmoke")
	angerSmoke2 = get_node("../AngerSmoke2")
	#angerSmoke3=get_node("../AngerSmoke3")
	
	
	
	
	angryStateTimer = frameTimerResource.new()
	self.add_child(angryStateTimer)
	
	angryStateTimer.connect("timeout",self,"_on_angry_state_timeout")
	
	
	#set the angry progress bar to max value same as angry duration
	#and make it invisible by default
	angryProgressBar = get_node("../HUD/angryProgressBar")
	angryProgressBar.max_value =ANGRY_STATE_DURATION_IN_SECONDS
	angryProgressBar.init(angryStateTimer)

	
func becomeAngry():
	
	emit_signal("player_state_info_text_changed",GLOBALS.BELT_NOTIFICATION_TEXT_ANGRY)
	isAngry=true
	actionAnimeManager.setAngryFlag(isAngry)
	angerSmoke.visible = true
	angerSmoke2.visible = true
	
	#angerSmoke3.visible =true
	angerSmoke.emitting = true
	angerSmoke2.emitting = true
	
	angerSmoke.restart()
	angerSmoke2.restart()
	#angerSmoke3.emitting=true
	
	angryStateTimer.startInSeconds(ANGRY_STATE_DURATION_IN_SECONDS)
	angryProgressBar.start()
	
	_on_request_play_special_sound(GETTING_ANGRY_SOUND_ID,HERO_SOUND_SFX,angryVoiceLineSoundVolume)
	pass
	
func becomeCalm(applyHitFreezeFlag = false):
	emit_signal("player_state_info_text_changed","")
	#if isAngry and applyHitFreezeFlag:
		#startHitFreezeNotification(LOSING_ANGRY_STATE_HITFREEZE)

		
	isAngry=false
	actionAnimeManager.setAngryFlag(isAngry)
	
	angryStateTimer.stop()
	angryProgressBar.stop()
	
	angerSmoke.visible = false
	angerSmoke2.visible = false
	#angerSmoke3.visible =false
	angerSmoke.emitting = false
	angerSmoke2.emitting = false
	#angerSmoke3.emitting=false
	
#calm at start of match
func restart_hook():
	.restart_hook()
	
	becomeCalm()
	
	#connect to signals of invincibility hitting of opponent to remove port priority bug of when super armor disappears
	if not opponentPlayerController.get_node("CollisionHandler").is_connected("player_invincible_was_hit",self,"_on_opponent_invincible_was_hit"):
		opponentPlayerController.get_node("CollisionHandler").connect("player_invincible_was_hit",self,"_on_opponent_invincible_was_hit")
			
	if not opponentPlayerController.is_connected("being_attacked",self,"_on_opponent_being_attacked"):
		opponentPlayerController.connect("being_attacked",self,"_on_opponent_being_attacked")

#override this function to check if we were hit and should lose anger state
func attemptApplyHitstun(attackSpriteId, attackerHitbox,victimHurtbox):
	
	#if isAngry:
		
		#dynamically give super armor to lesser hurtboxes (should be fine to dynamically changes attributes, since the collision
		#boxes used in signals are deep copies of the collision boxes in the player scenes)
	#	if victimHurtbox.subClass == victimHurtbox.SUBCLASS_BASIC or victimHurtbox.subClass == victimHurtbox.SUBCLASS_HEAVY_ARMOR:
	#		victimHurtbox.subClass=victimHurtbox.SUBCLASS_SUPER_ARMOR
	#		victimHurtbox.superArmorHitLimit = 1# can tank one hit
	
	.attemptApplyHitstun(attackSpriteId, attackerHitbox,victimHurtbox)

		
	if attackerHitbox.hitstunType == GLOBALS.HitStunType.KNOCKBACK_ONLY or attackerHitbox.hitstunType == GLOBALS.HitStunType.NO_HITSTUN or attackerHitbox.hitstunType == GLOBALS.HitStunType.ON_LINK_ONLY_AND_HITSTUNLESS: 
		return 
	
	#only become calm at end of frame to prevent simultaneous hitting that give port priority to when
	#super armor levaes	
	call_deferred("becomeCalm")
	
	
	
	
func _on_sprite_animation_played(spriteAnimation):
	._on_sprite_animation_played(spriteAnimation)
	
	match( spriteAnimation.id):
	#check if we become angry (either n-tool parry or the up-tool reka on hit)
		actionAnimeManager.NEUTRAL_TOOL_COUNTER_HIT_SPRITE_ANIME_ID:
		
		#are we already angry, and countering again? This counts as getting hit, so loose angry
		#if isAngry:
		#	becomeCalm()
		#else:
		#IT MAY Be case were already angry, but if the player can counter/parry every attack, they
		#should be rewarded by keeping the angry state (refreshing it)
			becomeAngry()
		
		actionAnimeManager.UP_TOOL_REKA_ON_HIT_SPRITE_ANIME_ID:
			becomeAngry()
	
		actionAnimeManager.FORWARD_TOOL_REKA_ON_HIT_SPRITE_ANIME_ID:
			becomeAngry()
	
		actionAnimeManager.ANGRY_D_TOOL_SPRITE_ANIME_ID:
			becomeCalm(true)
	
func _on_action_animation_finished(spriteAnimationId):
	
	#CHECK to see whehter we should lose angry state from the animation finished
	if spriteAnimationId == actionAnimeManager.BACKWARD_TOOL_SPRITE_ANIME_ID:
		becomeCalm(true)	
	._on_action_animation_finished(spriteAnimationId)
	
	
func _on_angry_state_timeout():
	becomeCalm(true)
	

#func _on_hitting_player(selfHitboxArea, otherHurtboxArea):
func _on_opponent_being_attacked(selfHitboxArea, opponentHurtboxArea,attackSpriteId):
	
	#special case where just became angry from triggering counter hit animation
	#of n-tool, and now hitting player?
	#so become calm in any other case when hitting, except when first counter hit the oppoennt
	if attackSpriteId != actionAnimeManager.NEUTRAL_TOOL_COUNTER_HIT_SPRITE_ANIME_ID:
		#make sure to only become calm after the current frame ends, hitting someone the same frame as you get hit 
		#would otherwise not let you tank the hit if the hit is processed before being hit on same frame
		
		#some attack sdon't have hitstun. they dno't count
		if selfHitboxArea.hitstunType != GLOBALS.HitStunType.NO_HITSTUN and selfHitboxArea.hitstunType != GLOBALS.HitStunType.ON_LINK_ONLY_AND_HITSTUNLESS:
			
			#only become calm upon attacking opponent for specific attacks (typically angry specials)
			if attackSpriteId != null and actionAnimeManager.onHitLoseAngryAnimes.has(attackSpriteId):
				#actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimationId,actionAnimeManager.GROUND_RIPOST_ACTION_ID)
				call_deferred("becomeCalm")
		
	#._on_hitting_player(selfHitboxArea, otherHurtboxArea)
	
		
#override this since we need to know if canceling angry n-special into crouch cancel
func handleCrouchCancel(facingCmd):

	var wasInAngryNSpecialFlag = false
	
	
	if actionAnimeManager.spriteAnimationManager.currentAnimation != null:
		
		#current animation is angry n-special?
		wasInAngryNSpecialFlag = actionAnimeManager.isCurrentSpriteAnimation(actionAnimeManager.ANGRY_N_SPECIAL_ACTION_ID)

	var commandConsummed = .handleCrouchCancel(facingCmd)
	
	
	#we canceled into crouch cancel from n-special??
	if commandConsummed and wasInAngryNSpecialFlag:
		#lose angry state
		becomeCalm(true)
	return commandConsummed
	
	
func _on_player_was_hit(otherHitboxArea, selfHurtboxArea):
	
	if isAngry:
		
		#dynamically give super armor to lesser hurtboxes (should be fine to dynamically changes attributes, since the collision
		#boxes used in signals are deep copies of the collision boxes in the player scenes)
		if selfHurtboxArea.subClass == selfHurtboxArea.SUBCLASS_BASIC or selfHurtboxArea.subClass == selfHurtboxArea.SUBCLASS_HEAVY_ARMOR:
			selfHurtboxArea.subClass=selfHurtboxArea.SUBCLASS_SUPER_ARMOR
			selfHurtboxArea.superArmorHitLimit = 1# can tank one hit
	
	
	var hittinSpriteAnimeId = otherHitboxArea.spriteAnimation.id 
	#not sure in which order the signals are handled, but this is to be sure belt
	#loses angry state when hitting autoriposting opponent, and if the opponent was hit
	#signal called first, then will have a special case to lose angry state when hit by auto ripost
	if hittinSpriteAnimeId == opponentPlayerController.actionAnimeManager.AUTO_RIPOST_SPRITE_ANIME_ID or hittinSpriteAnimeId == opponentPlayerController.actionAnimeManager.AUTO_RIPOST_ON_HIT_SPRITE_ANIME_ID:
	
		if isAngry:
			becomeCalm()
			
	._on_player_was_hit(otherHitboxArea, selfHurtboxArea)
	

func _on_opponent_invincible_was_hit(otherHitboxArea, selfInvincibilityboxArea):
	#not sure in which order the signals are handled, but this is to be sure belt
	#loses angry state when hitting autoriposting opponent, and if the opponent was hit
	#signal called first, then will have a special case to lose angry state when hit by auto ripost
	var hittingAutoRipostingOpponent = opponentPlayerController.actionAnimeManager.isCurrentSpriteAnimation(opponentPlayerController.actionAnimeManager.AUTO_RIPOST_ACTION_ID)
	hittingAutoRipostingOpponent = hittingAutoRipostingOpponent or opponentPlayerController.actionAnimeManager.isCurrentSpriteAnimation(opponentPlayerController.actionAnimeManager.AUTO_RIPOST_ON_HIT_ACTION_ID)
	hittingAutoRipostingOpponent = hittingAutoRipostingOpponent or opponentPlayerController.actionAnimeManager.isCurrentSpriteAnimation(opponentPlayerController.actionAnimeManager.AIR_AUTO_RIPOST_ACTION_ID)
	hittingAutoRipostingOpponent = hittingAutoRipostingOpponent or opponentPlayerController.actionAnimeManager.isCurrentSpriteAnimation(opponentPlayerController.actionAnimeManager.AIR_AUTO_RIPOST_ON_HIT_ACTION_ID)
	
	if hittingAutoRipostingOpponent:
		if isAngry:
			becomeCalm()

func _on_hitting_player(selfHitboxArea, otherHurtboxArea):
	
	if isAngry:
		selfHitboxArea.guardHPDamage= selfHitboxArea.guardHPDamage *ANGRY_GUARD_DAMAGE_BONUS_MOD
		selfHitboxArea.incorrectBlockGuardHPDamage= selfHitboxArea.incorrectBlockGuardHPDamage *ANGRY_GUARD_DAMAGE_BONUS_MOD
		
	._on_hitting_player(selfHitboxArea, otherHurtboxArea)
	
	
func _on_hitting_invincible_player(selfHitboxArea, otherHurtboxArea):

	#not sure in which order the signals are handled, but this is to be sure belt
	#loses angry state when hitting autoriposting opponent, and if the opponent was hit
	#signal called first, then will have a special case to lose angry state when hit by auto ripost
	var hittingAutoRipostingOpponent = opponentPlayerController.actionAnimeManager.isCurrentSpriteAnimation(opponentPlayerController.actionAnimeManager.AUTO_RIPOST_ACTION_ID)
	hittingAutoRipostingOpponent = hittingAutoRipostingOpponent or opponentPlayerController.actionAnimeManager.isCurrentSpriteAnimation(opponentPlayerController.actionAnimeManager.AUTO_RIPOST_ON_HIT_ACTION_ID)
	hittingAutoRipostingOpponent = hittingAutoRipostingOpponent or opponentPlayerController.actionAnimeManager.isCurrentSpriteAnimation(opponentPlayerController.actionAnimeManager.AIR_AUTO_RIPOST_ACTION_ID)
	hittingAutoRipostingOpponent = hittingAutoRipostingOpponent or opponentPlayerController.actionAnimeManager.isCurrentSpriteAnimation(opponentPlayerController.actionAnimeManager.AIR_AUTO_RIPOST_ON_HIT_ACTION_ID)
	
	if hittingAutoRipostingOpponent:
		if isAngry:
			becomeCalm()
			
			
		
		
func trainingModeEnterCharDependentState(params):
	#should put player in a special state like a stance change or something 
	#when game upaunses in training mode and the setting is enabled
	becomeAngry()
	

func reset():
	.reset()
	angryStateTimer.stop()
	angryProgressBar.stop()
	isAngry = false