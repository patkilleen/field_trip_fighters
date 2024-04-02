extends "res://projectiles/ProjectileController.gd"



func _on_hitting_player(selfHitboxArea, otherHurtboxArea):
	
	#play sound of on hit
	#playOnHitSound(otherHurtboxArea.commonSFXSoundId,selfHitboxArea.commonSFXSoundId)
	playOnHitSound(otherHurtboxArea,selfHitboxArea)
	
	#selfHitboxArea.spriteAnimation.disableAllHitboxes()
	masterPlayerController._check_on_block_autoparry_hit(selfHitboxArea, otherHurtboxArea)
	#actionAnimationManager.playUserAction(actionAnimationManager.COMPLETION_ACTION_ID,facingRight,command)
	

func _on_hitting_invincible_player(selfHitboxArea, otherHurtboxArea):
	
	#for now, no different than hitting a normal target with basic hurtbox (don't want to disapear on hit someone with
	#invicibility frames)
	_on_hitting_player(selfHitboxArea, otherHurtboxArea)	
	#playOnHitSound(otherHurtboxArea.commonSFXSoundId,selfHitboxArea.commonSFXSoundId)
	
	
#	actionAnimationManager.playUserAction(actionAnimationManager.COMPLETION_ACTION_ID,facingRight,command)