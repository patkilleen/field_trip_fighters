extends Node2D

export (int) var maxNumSprites = 64

var tempSpriteResource = preload("res://temporarySprite.tscn")

var sprites = []

#stores the sprites that can be used to display
var availableSprites = {}

#stores keys tmeporarily to remove keys
var buffer = []
func _ready():
	
	#populate temporyr sprites that are invisible for now until actiavte during moves
	for i in maxNumSprites:
		var sprite = tempSpriteResource.instance()
		sprites.append(sprite)
		self.add_child(sprite)
		
		sprite.connect("disapeared",self,"_on_sprite_disapeared")
		availableSprites[sprite]=null #null since not using the value, just key for lookup

#will deactivate all active sprites
func deactivateAll():
	
	for s in sprites:
		s.deactivate()
	

func displayGlobalTemporarySprites(sfxSprites,inHitFreeze, referencePoint,facingRight):
	displayLocalTemporarySprites(sfxSprites,inHitFreeze, referencePoint,facingRight)
func displayLocalTemporarySprites(sfxSprites,inHitFreeze, referencePoint = Vector2(0,0),facingRight=true):
	
	if sfxSprites == null or sfxSprites.size() == 0:
		return
		
	var keys = availableSprites.keys()
	
	#buffer to small?
	if keys.size() < sfxSprites.size():
		print("warning: not enough buffered temporary srptiees to display sfx, ignoring excess")
		
	
	#iterate over buffered sprites and copy over the spprites to display
	for i in keys.size():
		
		if i >= sfxSprites.size():
			break
			
		var tmpSprite =keys[i]
		
		var sfxSprite =sfxSprites[i] 
		buffer.append(tmpSprite)
	
		tmpSprite.disconnectTmpSpriteFromSignals()
		
		
		#todo: implement for below
		#var disapearOnOpponentAnimationChange = false
		#var disapearOnOpponentHitstun = false
		#var disapearOnOpponentAnimationFinish = false
		#issue is need rerefence to opppoent but sprite animation manager might
		#belong to projectile
		#does the sfx disapear when animation changed?
		if sfxSprite.disapearOnAnimationChange:
			if sfxSprite.spriteAnimationManager != null:
				#if sfxSprite.spriteAnimationManager.is_connected("sprite_animation_played",self,"_on_disapear_from_animation_played"):					
				#connect to signal of aniamtion that's played
				sfxSprite.spriteAnimationManager.connect("sprite_animation_played",tmpSprite,"_on_disapear_from_animation_played",[sfxSprite.spriteAnimationManager.currentAnimation])				
		
		if sfxSprite.disapearOnAnimationFinish:		
			if sfxSprite.spriteAnimationManager != null:
				sfxSprite.spriteAnimationManager.connect("finished",tmpSprite,"_on_disapear_from_animation_changed")#we pass null as the white list parent aniation,  since a null aniamtion can't emit finished signal, so any finish means end tmp sprite
		
#		else:
#			if sfxSprite.spriteAnimationManager != null:			
#				if sfxSprite.spriteAnimationManager.is_connected("sprite_animation_played",self,"_on_disapear_from_animation_played"):
#					sfxSprite.spriteAnimationManager.disconnect("sprite_animation_played",self,"_on_disapear_from_animation_played")
			
		if sfxSprite.disapearOnHitstun	:
			if sfxSprite.spriteAnimationManager != null:
				#projectiles don't go into hitstun, so ignore projectiles
				if sfxSprite.spriteAnimationManager.playerController is preload("res://PlayerController.gd"):
					#connect to signal of aniamtion that's played
					sfxSprite.spriteAnimationManager.playerController.playerState.connect("changed_in_hitstun",tmpSprite,"_on_disapear_from_hitstun_check")			
					
		if sfxSprite.disapearOnOpponentHitstun:
			if sfxSprite.spriteAnimationManager != null:
				var opponentPlayerController = null
				#player				
				if sfxSprite.spriteAnimationManager.playerController is preload("res://PlayerController.gd"):
					opponentPlayerController=sfxSprite.spriteAnimationManager.playerController.opponentPlayerController
					
					#connect to signal of aniamtion that's played
					#sfxSprite.spriteAnimationManager.playerController.opponentPlayerController.connect("about_to_be_applied_hitstun",tmpSprite,"_on_disapear_from_opponent_hitstun_check")						
				#'its a projectile?					
				elif sfxSprite.spriteAnimationManager.playerController is preload("res://projectiles/ProjectileController.gd"):
					if sfxSprite.spriteAnimationManager.playerController.masterPlayerController is preload("res://PlayerController.gd"):
						opponentPlayerController=sfxSprite.spriteAnimationManager.playerController.masterPlayerController.opponentPlayerController
					#make sure the parent of the projectile isn't a projectile. We don't go that deep. should be fine. only glove basebal create strings
					#don't don't care about hitstun of opponent
					
						# sfxSprite.spriteAnimationManager.playerController.masterPlayerController.opponentPlayerController.connect("about_to_be_applied_hitstun",tmpSprite,"_on_disapear_from_opponent_hitstun_check")						
						
				
				if opponentPlayerController != null:
					opponentPlayerController.connect("about_to_be_applied_hitstun",tmpSprite,"_on_disapear_from_opponent_hitstun_check")										
					tmpSprite.opponentPlayerController=opponentPlayerController
	#	else:	
	#		if sfxSprite.spriteAnimationManager != null:
	#			
	#			if sfxSprite.spriteAnimationManager.playerController.playerState.is_connected("changed_in_hitstun",self,"_on_disapear_from_hitstun_check"):					
	#				sfxSprite.spriteAnimationManager.playerController.playerState.disconnect("changed_in_hitstun",self,"_on_disapear_from_hitstun_check")
		tmpSprite.activate(sfxSprite,referencePoint,facingRight,sfxSprite.lifetimeInFrames,sfxSprite.disapearDurationInFrames,inHitFreeze,sfxSprite.preventMirroring,sfxSprite.visibilityCondition,sfxSprite.spriteAnimationManager,sfxSprite.animateScale,sfxSprite.scaleAnimationLifeTime,sfxSprite.targetScale)
	#fetch the first available sprites
	
	#remove all the keys of temprary sprite that are now active
	for tmpSprite in buffer:
		availableSprites.erase(tmpSprite)
		
	buffer.clear()
	
	

func _on_sprite_disapeared(sprite):
		
	#sprite disappear, and is now free to display again
	availableSprites[sprite] = null
	pass
	
