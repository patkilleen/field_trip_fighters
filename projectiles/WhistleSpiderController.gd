extends "res://projectiles/ProjectileController.gd"
const GOOSE_WIND_SPIDER_SPEED_BUFF = 1.5

export (float) var jumpToWhistleXDistThresh=15
var endingAnimation=false


var crawlingFollowMvm=null
var defaultCrawlingXSpeedMod = null
var trailParticles = null

func init():
	
	.init()
	trailParticles = $"Particles2D"
	trailParticles.visible = false
	trailParticles.emitting = true
	
	actionAnimationManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_sprite_animation_played")
	
	#iterate all basic movment, and connect to follow complete
	for mAnimes in movementAnimationManager.movementAnimations:
		for cm in mAnimes.complexMovements:
			for bm in cm.basicMovements:
				#the basic movement is a follow movement?
				if bm is preload("res://FollowMovement.gd"):
										
					bm.connect("arrived",self,"_on_whistle_caught_spdier")
	crawlingFollowMvm = get_node("ProjectileController/ActionAnimationManager/MovementAnimationManager/MovementAnimations/completion/delayed-ground-follow-whistle/bm1")
	defaultCrawlingXSpeedMod=crawlingFollowMvm.rawSpeedMod.x
func fire():
	.fire()
	trailParticles.restart()
	trailParticles.visible = true
	
	crawlingFollowMvm.rawSpeedMod.x = defaultCrawlingXSpeedMod
func _on_sprite_animation_played(anime):
	
	if anime!= null and anime.id ==actionAnimationManager.ACTIVE_SPRITE_ANIME_ID:
		trailParticles.visible = false
		
	if anime!= null and anime.id ==actionAnimationManager.COMPLETION_SPRITE_ANIME_ID:
		endingAnimation=true			
		

func _on_action_animation_finished(spriteAnimationId):
	
	if spriteAnimationId == actionAnimationManager.JUMP_TO_WHISTLE_SPRITE_ANIME_ID:
		endingAnimation=false
		destroy()	
	else:	
		._on_action_animation_finished(spriteAnimationId)
			

#the goose can speed up the spider crawl back recall via wind from wing attack
func _on_projectile_was_hit(otherHitboxArea, selfHurtboxArea):
	
	if endingAnimation:
		
		#it's the whistle goose hitting spider with wind?
		if otherHitboxArea.selfOnly:
			
			
			#depending on where the goose is, we slow down or speed up spider
			#based on wind direction relative to spider velocity
			var gooseController = otherHitboxArea.projectileController
			var windGoingLeft = gooseController.facingRight #goose turns around to flap
			
			var goosePos =gooseController.getCenter()
			var whistlePos = masterPlayerController.kinbody.getCenter()
			
			var whistleLeftOfGoose = whistlePos.x < goosePos.x
			var travelingWithGooseWind=null
			
			if windGoingLeft and whistleLeftOfGoose:
				travelingWithGooseWind=true
			elif not windGoingLeft and whistleLeftOfGoose:
				travelingWithGooseWind=false
			elif windGoingLeft and not whistleLeftOfGoose:
				travelingWithGooseWind=false
			else:# not windGoingLeft and not whistleLeftOfGoose:
				travelingWithGooseWind=true
				
			if travelingWithGooseWind:
				#speed up the crawl speed when hit by wings of goose, since going with wind
				crawlingFollowMvm.rawSpeedMod.x =  crawlingFollowMvm.rawSpeedMod.x + (crawlingFollowMvm.rawSpeedMod.x * GOOSE_WIND_SPIDER_SPEED_BUFF)
			else:
				#slown the crawl speed when hit by wings of goose, since going agaisnt wind
				crawlingFollowMvm.rawSpeedMod.x =  crawlingFollowMvm.rawSpeedMod.x - (crawlingFollowMvm.rawSpeedMod.x * GOOSE_WIND_SPIDER_SPEED_BUFF)
			
			
			pass
		
func _physics_process(delta):
	#spider is crawling to whistle?
	if endingAnimation:
		#check x-axis distance
		var spiderPos = self.getCenter()
		var whistlePos = masterPlayerController.kinbody.getCenter()
	
		var puppetMasterDistance = abs(whistlePos.x-spiderPos.x)
	
		#spider beneath/above whiste?
		if puppetMasterDistance<=jumpToWhistleXDistThresh:
			endingAnimation=false
			
			#not within catching distance?			
			if spiderPos.distance_to(whistlePos) >= 15:
				#jump to whistle
				actionAnimationManager.playUserAction(actionAnimationManager.JUMP_TO_WHISTLE_ACTION_ID,facingRight,command)
			else:
				destroy()	
			
		
func _on_whistle_caught_spdier(src,dst,followMvm):
	endingAnimation=false
	destroy()				