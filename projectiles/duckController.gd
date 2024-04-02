extends "res://projectiles/ProjectileController.gd"

var secondActiveFrame=null
var duckFlying=false
func init():
	.init()
	secondActiveFrame = $"ProjectileController/ActionAnimationManager/SpriteAnimationManager/SpriteAnimations/active/active-frame11"
	
	#connect to entered hitstun function of whistle
	masterPlayerController.playerState.connect("changed_in_hitstun",self,"_on_whistle_changed_in_hitstun")
	
func fire():
	.fire()
	duckFlying=true

func destroy():
	.destroy()
	duckFlying=false
func _on_hitting_player(selfHitboxArea, otherHurtboxArea):
	
	#hitting opponent with 2nd hit of duck?
	if selfHitboxArea.spriteFrame == secondActiveFrame:
		#is whistle doing the DP? if so, no more active frames comming
		#so disable the proximity guard 
		#there is a proximity guard for the duck stuck to whilste. So gotta disable it after duck hits
		if masterPlayerController.actionAnimeManager.isCurrentSpriteAnimation(masterPlayerController.actionAnimeManager.UPWARD_SPECIAL_ACTION_ID):		
			var saDP = masterPlayerController.actionAnimeManager.spriteAnimationLookup(masterPlayerController.actionAnimeManager.UPWARD_SPECIAL_ACTION_ID)
			if saDP != null:
				saDP.forceProximityGuardDisable=true
	._on_hitting_player(selfHitboxArea, otherHurtboxArea)
	
	
func _on_whistle_changed_in_hitstun(inHitstun):
	#whistle was hit?
	if inHitstun:
		#hit during duck animation?
		if duckFlying:
			#destroy the duck
			destroy()