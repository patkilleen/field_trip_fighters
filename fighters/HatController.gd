extends "res://PlayerController.gd"

export (int, FLAGS, "Jump","F-Jump", "B-Jump","Ground Idle","Ground F-Move","Ground B-Move" ,"Crouch","N-Melee","N-Special","N-Tool","B-Special","auto ripost","Air Idle","Air F-Move","Air B-Move", "Air F-Dash", "Air B-Dash","Air-Melee","Air-Special","Air-Tool","Fast Fall","Air Move Stop", "Air auto ripost","F-Special","D-Melee","U-Tool","D-Tool","F-Tool","B-Tool","U-Special","F-Melee","B-Special") var noHatPushBlockAcrobaticsAutoCancels = 0
export (int, FLAGS, "D-Special","B-Melee","U-Melee","F-Ground-Dash","B-Ground-Dash", "Air-grab","grab","crouching-hold-back-block","Platform Drop", "Leave Platform Keep Animation","F-dash crouch cancel","non-cancelable f-ground-dash","non-cancelable b-ground-dash","apex-of-jump-only fast-fall","standing-hold-back-block","air-hold-back-block","standing-push-block","air-push-block","Air Jump","Air F-Jump", "Air B-Jump","b-dash-Crouch-cancel", "basic crouch cancel", "non-GDC jump","non-GDC F-jump", "non-GDC b-jump") var noHatPushBlockAcrobaticsAutoCancels2 = 0
var trackStarParticles = null

#LIGHT damae is like [0,20)
const LIGHT_ATTACK_DAMAGE_THRESHOLD=20 
#medium damage is [20,45)
const MEDIUM_ATTACK_DAMAGE_THRESHOLD=45
#heavy damage is [45+


const VERTICAL_ALIGNMENT_DASH_TO_HAT_WIDTH =25 #IF ball cap withing distance (x-axis) from hat center, it's considered vertically aligned for dash to ball cap purposes
var ballCapRef  = null 

var preloadedBallCap= null

var ballCapSpawn = null

var backBallCapHitFlyOffSpawn = null

var preHitstunAnimationId= null
#list of all follow mvmv related to dash to ball cap animations
#var dashToHatFollowMvms = []

#ball cap action ids
const B_BALL_CAP_HIT_BY_LIGHT_ACTION_ID=17
const B_BALL_CAP_HIT_BY_MEDIUM_ACTION_ID=18
const B_BALL_CAP_HIT_BY_HEAVY_ACTION_ID=19

var dashToBallCapFollowMvm=null
#var dashToBallCapFollowMvmParent=null
var dashToBallCapFollowMvmAirOffset=Vector2(0,-20)
var dashToBallCapFollowMvmGroundOffset=Vector2(0,30) #into the ground
#var trackStarSpeedBuffEnabled=false
func init(sprite,collisionAreas,attackSFXs,bodyBox,activeNodes):
	
	HERO_HITSTUN_STUN_SOUND_ID = 30
	HERO_RIPOST_SOUND_ID = 17
	HERO_COUNTER_RIPOST_SOUND_ID = 18
	HERO_INCORRECT_BLOCK_SOUND_ID=27

	ripostVoicelineVolumeOffset=5
	counterRipostVoicelineVolumeOffset=5
	badBlockVoicelineVolumeOffset=0
	gettingHitVoicelineVolumeOffset=-2
	
	ballCapSpawn = $"ballcap-spawn"
	ballCapSpawn.init(1,self) #one ball cap will ever exist

	backBallCapHitFlyOffSpawn = $"b-ball-cap-hit-projectile"
	#null sprite animation id since will dynamically set it
	backBallCapHitFlyOffSpawn.init(self,null)
	backBallCapHitFlyOffSpawn.connect("create_projectile",self,"_on_ball_cap_fly_off_when_hat_hit")
	
	#call parent's init
	.init(sprite,collisionAreas,attackSFXs,bodyBox,activeNodes)	
	
	
	self.connect("about_to_be_applied_hitstun",self,"_on_about_to_be_applied_hitstun")
	
	self.connect("attack_hit",self,"_on_hit_opponent")
		
	actionAnimeManager.connect("ball_cap_relative_position_changed",self,"_on_ball_cap_relative_position_changed")
	
	#make sure grab handler's sprite animation id throw lookup includes OPERA throws
	#so stance change briefly to populate the maps
	#actionAnimeManager.toggleStanceChange()
	#grabHandler.populateThrowSpriateAnimationIdMap()
	#actionAnimeManager.toggleStanceChange()
	
	trackStarParticles = $"../newtrackstarParticles"
	
	#make sure trackstar particles off by default
	trackStarParticles.visible = false
	#trackStarParticles.emitting=false
	
	#populate the follow mvm for dash to ball cap
	dashToBallCapFollowMvm=$"ActionAnimationManager/MovementAnimationManager/MovementAnimations/direct-route-ball-cap-dash/cplx_mvm5/bm0"
	#dashToBallCapFollowMvmParent = dashToBallCapFollowMvm.get_parent()
	
	

	actionAnimeManager.connect("track_star_stance_started",self,"_on_track_star_stance_started")
	actionAnimeManager.connect("track_star_stance_ended",self,"_on_track_star_stance_ended")
		
	#stance change can be done on match start countdown
	inputManager.mvmOnlyCmdMap[inputManager.Command.CMD_NEUTRAL_TOOL]=true
	
	actionAnimeManager.populateDashBasicMvmNodeList()
	for bm in actionAnimeManager.dashBasicMvmNodes:
		bm.connect("stopped",self,"_on_track_star_dash_basic_movement_stopped")
	
	#acrobatics enabled dashing out of pusblock?
	if kinbody.enableJumpDashOutOfPushBlock:		
		var sa = actionAnimeManager.spriteAnimationManager.spriteAnimations[actionAnimeManager.NO_BALL_CAP_PUSH_BLOCK_SPRITE_ANIME_ID]
		for sf in sa.spriteFrames:
			#add jump and dash + dash-to-ball-cap F/B special to auto cancel movs of no-hat pushblock
			sf.autoCancels= sf.autoCancels | noHatPushBlockAcrobaticsAutoCancels
			sf.autoCancels2= sf.autoCancels2 | noHatPushBlockAcrobaticsAutoCancels2

#track star dash basicm ovement ended
func _on_track_star_dash_basic_movement_stopped(endedDashBM):
	
	if actionAnimeManager.isInTrackStarStance():
		
		#if we crouch cancel the dash, we keep track star
		
		if actionAnimeManager.isSpriteAnimationIdLinkedToAction(actionAnimeManager.currentSpriteAnimation,actionAnimeManager.FORWARD_GROUND_DASH_CANCEL_RECOVERY_ACTION_ID) or actionAnimeManager.isSpriteAnimationIdLinkedToAction(actionAnimeManager.currentSpriteAnimation,actionAnimeManager.BACK_GROUND_DASH_CANCEL_RECOVERY_ACTION_ID):
			pass
		else:
				
			actionAnimeManager.leaveTrackStarStance()
	
#function just to set the appropriate anime id parent of projectile
#this overrides _on_create projectile, so call it manually
func _on_ball_cap_fly_off_when_hat_hit(projectileInstance,spawnPoint):
	projectileInstance.projectileParentSpriteAnimation=preHitstunAnimationId
	_on_create_projectile(projectileInstance,spawnPoint)
	
func _on_about_to_be_applied_hitstun(attackSpriteId,relativeDamage):
	preHitstunAnimationId = actionAnimeManager.currentSpriteAnimation
	#wearing ball cap back?
	if actionAnimeManager.isBallCapWornBackwardStance():
		
		#the ball cap fly off speed changes based on attack damage
		if relativeDamage < LIGHT_ATTACK_DAMAGE_THRESHOLD:
			backBallCapHitFlyOffSpawn.projectileSpawns[0].projectileStartingActionId=B_BALL_CAP_HIT_BY_LIGHT_ACTION_ID  #only 1 ball cap, so acces direclty
			
		elif relativeDamage>= LIGHT_ATTACK_DAMAGE_THRESHOLD and  relativeDamage <MEDIUM_ATTACK_DAMAGE_THRESHOLD:
			backBallCapHitFlyOffSpawn.projectileSpawns[0].projectileStartingActionId=B_BALL_CAP_HIT_BY_MEDIUM_ACTION_ID  #only 1 ball cap, so acces direclty
		else:
			#heacy
			backBallCapHitFlyOffSpawn.projectileSpawns[0].projectileStartingActionId=B_BALL_CAP_HIT_BY_HEAVY_ACTION_ID  #only 1 ball cap, so acces direclty
			pass
			
		#BALL cap flies off when hat is hit when it's worn backward
		backBallCapHitFlyOffSpawn.signalProjectileCreation()
			
func _on_action_animation_finished(spriteAnimationId):
	if actionAnimeManager.isInSprinterStance():
		actionAnimeManager.leaveSprinterStance()
		

	#check to see if we stance changed
	if spriteAnimationId == actionAnimeManager.NEUTRAL_TOOL_SPRITE_ANIME_ID:
		
		actionAnimeManager.enterWearBallCapBackStance()
	elif  spriteAnimationId == actionAnimeManager.B_BALL_CAP_NEUTRAL_TOOL_SPRITE_ANIME_ID:
		actionAnimeManager.enterWearBallCapForwardStance()
		#actionAnimeManager.toggleStanceChange()

	#did we finish the track star animation? 
	elif actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimationId,actionAnimeManager.NEUTRAL_SPECIAL_ACTION_ID):
		
	
		if not actionAnimeManager.isInTrackStarStance():
		
			actionAnimeManager.enterTrackStarStance()
			
	._on_action_animation_finished(spriteAnimationId)
	
func _on_sprite_animation_played(spriteAnimation):
	._on_sprite_animation_played(spriteAnimation)
	
	if actionAnimeManager.isInSprinterStance():
		actionAnimeManager.leaveSprinterStance()
		
	if actionAnimeManager.isSpriteAnimationIdLinkedToAction(spriteAnimation.id,actionAnimeManager.DOWNWARD_SPECIAL_ACTION_ID):
		
		actionAnimeManager.enterSprinterStance()
			

	#disable the magnifying glass when dashing to hat  so it looks like a true screen wrap
	#without a brief moment of magnifing gla
	if isDashingToBallCap():
		kinbody.offScreenMagnifyingGlass=false
	else:
		kinbody.offScreenMagnifyingGlass=true
func handleAirSpecialAttackInput(actualCmd,treatAsCmd):
	var commandConsummed  =false
	if ballCapRef == null:
		commandConsummed= .handleAirSpecialAttackInput(actualCmd,treatAsCmd)
		
	else:
		#ball cap is not on hat's head, so he can ball cap dash in air
		match(actualCmd):
			inputManager.Command.CMD_FORWARD_SPECIAL,inputManager.Command.CMD_COUNTER_RIPOST_FORWARD_SPECIAL:
				commandConsummed= playUserInputAction(actionAnimeManager.FORWARD_SPECIAL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(actualCmd))
			inputManager.Command.CMD_BACKWARD_SPECIAL,inputManager.Command.CMD_COUNTER_RIPOST_BACKWARD_SPECIAL:
				commandConsummed= playUserInputAction(actionAnimeManager.BACKWARD_SPECIAL_ACTION_ID,inputManager.counterRipostCmdToBaseCmd(actualCmd))
			_:#NOT forward or back aspecial. so doe normal
				commandConsummed= .handleAirSpecialAttackInput(actualCmd,treatAsCmd)
	return commandConsummed	




func handleGroundMeleeAttackInput(actualCmd,expectedActionId):
	
	#here over ride ground attack command processing so spritner stance
	#can support any number of directions, as long as press attack button
	#the sprinter stance attack comes out (counts as neutral for riposting 
	#and command internal processing)
	if actionAnimeManager.isInSprinterStance():
		
		var reMappedCmd = inputManager.Command.CMD_NEUTRAL_MELEE
		expectedActionId=actionAnimeManager.NEUTRAL_MELEE_ACTION_ID
										
		return playUserInputAction(expectedActionId,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))
	
		
	else:
		return .handleGroundMeleeAttackInput(actualCmd,expectedActionId)


func handleGroundSpecialAttackInput(actualCmd,expectedActionId):
	
	#here over ride ground attack command processing so spritner stance
	#can support any number of directions, as long as press attack button
	#the sprinter stance attack comes out (counts as neutral for riposting 
	#and command internal processing)
	if actionAnimeManager.isInSprinterStance():
		
		var reMappedCmd = inputManager.Command.CMD_NEUTRAL_SPECIAL
		expectedActionId=actionAnimeManager.NEUTRAL_SPECIAL_ACTION_ID
										
		return playUserInputAction(expectedActionId,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))
	
		
	else:
		return .handleGroundSpecialAttackInput(actualCmd,expectedActionId)
						



func handleGroundToolAttackInput(actualCmd,expectedActionId):
	
	#here over ride ground attack command processing so spritner stance
	#can support any number of directions, as long as press attack button
	#the sprinter stance attack comes out (counts as neutral for riposting 
	#and command internal processing)
	if actionAnimeManager.isInSprinterStance():
		
		var reMappedCmd = inputManager.Command.CMD_NEUTRAL_TOOL
		expectedActionId=actionAnimeManager.NEUTRAL_TOOL_ACTION_ID
										
		return playUserInputAction(expectedActionId,inputManager.counterRipostCmdToBaseCmd(reMappedCmd))
	
		
	else:
		return .handleGroundToolAttackInput(actualCmd,expectedActionId)
	


#hook for subclasses to change the counter ripost command
#for special stances where some DI + attack input just do neutral, for example
#(like hat sprinter stance attacsK0
func preProcessCounterRipostCmd(facingCounterRipostCmd):
	match(facingCounterRipostCmd):
		inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE:
			return inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE
		inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL:
			return inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL
		inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL:
			return inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL
		inputManager.Command.CMD_COUNTER_RIPOST_BACKWARD_SPECIAL:
			return inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL
		inputManager.Command.CMD_COUNTER_RIPOST_FORWARD_SPECIAL:
			return inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL
		inputManager.Command.CMD_COUNTER_RIPOST_DOWNWARD_SPECIAL:
			return inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL
		inputManager.Command.CMD_COUNTER_RIPOST_UPWARD_SPECIAL:
			return inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_SPECIAL
		inputManager.Command.CMD_COUNTER_RIPOST_BACKWARD_MELEE:
			return inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE
		inputManager.Command.CMD_COUNTER_RIPOST_FORWARD_MELEE:
			return inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE
		inputManager.Command.CMD_COUNTER_RIPOST_DOWNWARD_MELEE:
			return inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE
		inputManager.Command.CMD_COUNTER_RIPOST_UPWARD_MELEE:
			return inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_MELEE
		inputManager.Command.CMD_COUNTER_RIPOST_BACKWARD_TOOL:
			return inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL
		inputManager.Command.CMD_COUNTER_RIPOST_FORWARD_TOOL:
			return inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL
		inputManager.Command.CMD_COUNTER_RIPOST_DOWNWARD_TOOL:
			return inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL
		inputManager.Command.CMD_COUNTER_RIPOST_UPWARD_TOOL:
			return inputManager.Command.CMD_COUNTER_RIPOST_NEUTRAL_TOOL
		_:
			print("interanl design error with pre processing counter ripost command for hat controller. unkwonc cmd")
			return null
	
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
	#actionAnimeManager.currentActionIdGroup = actionAnimeManager.F_BALL_CAP_ANIMATIONS_IX
	
	if ballCapRef != null: 
		_on_retreived_ball_cap(ballCapRef)
	
	
	#always start in rap mode
	#emit_signal("player_state_info_text_changed",GLOBALS.MIC_NOTIFICATION_TEXT_RAP)
	actionAnimeManager.currentActionIdGroup = actionAnimeManager.F_BALL_CAP_ANIMATIONS_IX
	
	trackStarParticles.visible = false
	#trackStarParticles.emitting=false
	
	.restart_hook()
	
	
	
	#by default just the raw grab handler mask is returned. subclasses will deal with different situtations
func getGrabAutoAbilityCancelMask(stanceIx,mask1Flag):
	
	if stanceIx== actionAnimeManager.F_BALL_CAP_ANIMATIONS_IX:
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
			
			
func _on_track_star_stance_started():
	trackStarParticles.visible = true
	for c in trackStarParticles.get_children():
		if c is Particles2D:
			c.emitting=true
			c.restart()
			c.visible = true
	#trackStarParticles.emitting=true
	
	
func _on_track_star_stance_ended():
	#trackStarParticles.emitting=false
	trackStarParticles.visible = false
	
func _on_ball_cap_relative_position_changed(positionIx):
	#let the interface know ball cap relative position to hat changed so it can update HUD
	
	#the facing of hat will be necessary for relatifve positioning of
	#the arrow display for where ball cap is
	if positionIx ==GLOBALS.HAT_BALL_CAP_ON_BATTLEFIELD_ABOVE_OR_BELOW_HAT_IX:
		
		#easy case where ball cap directly above/below hat
		emit_signal("player_state_info_text_changed",positionIx)
	elif positionIx ==GLOBALS.HAT_BALL_CAP_ON_BATTLEFIELD_BEHIND_HAT_IX:
		if kinbody.facingRight:
			emit_signal("player_state_info_text_changed",GLOBALS.HAT_BALL_CAP_ON_BATTLEFIELD_BEHIND_HAT_IX)
		else:
			emit_signal("player_state_info_text_changed",GLOBALS.HAT_BALL_CAP_ON_BATTLEFIELD_IN_FRONT_OF_HAT_IX)
			
	elif positionIx ==GLOBALS.HAT_BALL_CAP_ON_BATTLEFIELD_IN_FRONT_OF_HAT_IX:
		if kinbody.facingRight:
			emit_signal("player_state_info_text_changed",GLOBALS.HAT_BALL_CAP_ON_BATTLEFIELD_IN_FRONT_OF_HAT_IX)
		else:
			emit_signal("player_state_info_text_changed",GLOBALS.HAT_BALL_CAP_ON_BATTLEFIELD_BEHIND_HAT_IX)
	else:
		print("warning: unknown ball cap position ix for stance notification")
	pass

func _on_create_projectile(projectile,spawnPoint):
	
	#can't lose the ball cap if ball cap is on the battlefield (must have the ball to lose it)
	if ballCapRef == null:
		
		ballCapRef = projectile
		actionAnimeManager._on_lost_ball_cap()
		if not projectile.is_connected("retreived_ball_cap",self,"_on_retreived_ball_cap"):
			projectile.connect("retreived_ball_cap",self,"_on_retreived_ball_cap")
	else:
		print("warning, in bug state where trying to create (throw) baseball, but it already on field")

	#connect to ball cap land signal
	if not ballCapRef.is_connected("landed",self,"_on_ball_cap_landed"):
		 ballCapRef.connect("landed",self,"_on_ball_cap_landed")

	dashToBallCapFollowMvm.offset=dashToBallCapFollowMvmAirOffset
	#dashToBallCapFollowMvmParent.gravEffect =dashToBallCapFollowMvmParent.GravityEffect.STOP
	#if ballCapRef!=null:
		#make sure the follow movements of hat are tied to the ball cap
	#	for flwMvm in dashToHatFollowMvms:
	
	#		flwMvm.src = kinbody #the source boject being moved is hat himself
	#		flwMvm.dst = ballCapRef #follow the ball cap
		
	#	dashToHatFollowMvms.clear() # we 
	#we did some book keeping before signaling to create projectile
	._on_create_projectile(projectile,spawnPoint)
	
	
func _on_retreived_ball_cap(ballCap):
	ballCapRef = null
	
	#LET hud know ball cap no longer on stage
	emit_signal("player_state_info_text_changed",GLOBALS.HAT_BALL_CAP_OFF_BATTLEFIELD_IX)
	
	if ballCap != null:
		ballCap.disconnect("retreived_ball_cap",self,"_on_retreived_ball_cap")
		ballCap.destroy()
		
	dashToBallCapFollowMvm.offset=dashToBallCapFollowMvmAirOffset	
	#dashToBallCapFollowMvmParent.gravEffect =dashToBallCapFollowMvmParent.GravityEffect.STOP
	
	#make it so glove now has the ball again
	actionAnimeManager._on_retreived_ball_cap()
	
	#hat goes into a temporary aniamtion to indicate ball caught
	if my_is_on_floor():
		playActionKeepOldCommand(actionAnimeManager.NO_BALL_CAP_GROUND_RETREIVED_BALL_CAP_ACTION_ID)
	else:
		playActionKeepOldCommand(actionAnimeManager.NO_BALL_CAP_AIR_RETREIVED_BALL_CAP_ACTION_ID)
		
	#MAKE THE dash to ball cap have a hitbox again (only can hit once per ball cap lost/catch session)	
	actionAnimeManager.refreshOneTimeHitAnimation(actionAnimeManager.NO_BALL_CAP_DASH_TOWARD_BALL_CAP_SPRITE_ANIME_ID)
	actionAnimeManager.refreshOneTimeHitAnimation(actionAnimeManager.NO_BALL_CAP_DASH_AWAY_FROM_BALL_CAP_SPRITE_ANIME_ID)
	actionAnimeManager.refreshOneTimeHitAnimation(actionAnimeManager.NO_BALL_CAP_POST_SCREEN_WRAP_DASH_TOWARD_BALL_CAP_SPRITE_ANIME_ID)



		
#to be implemented by subclasses. Used to load a single type of projectile 
#to be spawned at multiple areas
func getStaticProjectileSpawn(customProjectileSpawnData):
	
	return ballCapSpawn
	


#overrides parent function
func readyToCreateProjectileHook(projectileFrame):
	return ballCapRef == null #no ball on field means create, otherwise don't create ball
		


func trainingModeEnterCharDependentState(params):
	#should put player in a special state like a stance change or something 
	#when game upaunses in training mode and the setting is enabled
	
	#catches ball from anywhere. to eanble retreving ball faster
	if ballCapRef != null:
		ballCapRef._on_ball_cap_caught() 	
	
	

func reset():
	.reset()
	ballCapRef  = null 

	preloadedBallCap= null

	ballCapSpawn = null
	
	emit_signal("player_state_info_text_changed",GLOBALS.HAT_BALL_CAP_OFF_BATTLEFIELD_IX)
	
	dashToBallCapFollowMvm.offset=dashToBallCapFollowMvmAirOffset
	#dashToBallCapFollowMvmParent.gravEffect =dashToBallCapFollowMvmParent.GravityEffect.STOP

#called when a follow movement is initiated (starts/activates) and
#the follow destination type is other (not caster, nor opponent)
func _on_following_special_object_type_hook(followMvm):
	
	#dashToHatFollowMvms.append(followMvm)
	#Hat's dash to hat follow mvmv?
	if followMvm.movementAnimationManager.playerController==self:
	#if ballCapRef == null:	
	#	print("design error, the ball cap projectile is null when trying to connect it to hat's follow mvmv")
	
		followMvm.src = kinbody #the source boject being moved is hat himself
		followMvm.dst = ballCapRef #follow the ball cap
			
	else:
		pass#some other form of scoop in mvmv using a custom destiantion is affter hat

	
func isDashingToBallCap():
	var dashingToBallCap=false
	match(actionAnimeManager.currentSpriteAnimation):
		actionAnimeManager.NO_BALL_CAP_DASH_TOWARD_BALL_CAP_SPRITE_ANIME_ID:
			dashingToBallCap=true
		actionAnimeManager.NO_BALL_CAP_DASH_AWAY_FROM_BALL_CAP_SPRITE_ANIME_ID:
			dashingToBallCap=true
		actionAnimeManager.NO_BALL_CAP_POST_SCREEN_WRAP_DASH_TOWARD_BALL_CAP_SPRITE_ANIME_ID:
			dashingToBallCap=true
		actionAnimeManager.STALE_NO_BALL_CAP_DASH_TOWARD_BALL_CAP_SPRITE_ANIME_ID:
			dashingToBallCap=true
		actionAnimeManager.STALE_NO_BALL_CAP_DASH_AWAY_FROM_BALL_CAP_SPRITE_ANIME_ID:
			dashingToBallCap=true
		actionAnimeManager.STALE_NO_BALL_CAP_POST_SCREEN_WRAP_DASH_TOWARD_BALL_CAP_SPRITE_ANIME_ID:
			dashingToBallCap=true
		_:
			dashingToBallCap=false	
	return dashingToBallCap
#	var isDashToBallCapAnime = actionAnimeManager.currentSpriteAnimation == actionAnimeManager.NO_BALL_CAP_DASH_TOWARD_BALL_CAP_SPRITE_ANIME_ID
#	isDashToBallCapAnime = isDashToBallCapAnime or  (actionAnimeManager.currentSpriteAnimation == actionAnimeManager.NO_BALL_CAP_DASH_AWAY_FROM_BALL_CAP_SPRITE_ANIME_ID)
#	isDashToBallCapAnime = isDashToBallCapAnime or  (actionAnimeManager.currentSpriteAnimation == actionAnimeManager.NO_BALL_CAP_POST_SCREEN_WRAP_DASH_TOWARD_BALL_CAP_SPRITE_ANIME_ID)	
#	return  isDashToBallCapAnime

func isScreenWrapDashingToBallCap():

	
	return actionAnimeManager.currentSpriteAnimation == actionAnimeManager.NO_BALL_CAP_DASH_AWAY_FROM_BALL_CAP_SPRITE_ANIME_ID or actionAnimeManager.currentSpriteAnimation == actionAnimeManager.STALE_NO_BALL_CAP_DASH_AWAY_FROM_BALL_CAP_SPRITE_ANIME_ID
	


func _on_player_left_screen(exitedScreenLeftSide,screenRect):
	
	#so we left the screen, but gotta make sure were dashing to ball cap to screen wrap
	#since at times hat is so fast he leaves screen cause false walls can't keep up
	
	if isScreenWrapDashingToBallCap():
		#screen wrap right
		if exitedScreenLeftSide:
			kinbody.position.x = screenRect.end.x - 1 #-50 so doesn't infinitly screen wrap and spawns inside screen
		else:
			kinbody.position.x = screenRect.position.x + 1 #+50 so doesn't infinitly screen wrap and spawns inside screen
		
		#now that hat screen wrapped, travel directly toward ball cap		
		#the GAME mgith not have registred the cross up, so manually play the appropriate actio nbased on what wall screen
		#warape from (exited the left wall means facing lef, exit right wall means facing right
		var tmp = actionAnimeManager.commandActioned 
		var forcedFacingRight =not exitedScreenLeftSide
		actionAnimeManager.playAction(actionAnimeManager.NO_BALL_CAP_POST_SCREEN_WRAP_DASH_TOWARD_BALL_CAP_ACTION_ID,forcedFacingRight)
		actionAnimeManager.commandActioned = tmp
		
		
func _on_hit_opponent(hitbox,hurtbox):
	if isDashingToBallCap():
		#MAKE THE dash to ball cap hitbox disabled. only get it back when catch ball or combo ends
		actionAnimeManager.expireOneTimeHitAnimation(actionAnimeManager.NO_BALL_CAP_DASH_TOWARD_BALL_CAP_SPRITE_ANIME_ID)
		actionAnimeManager.expireOneTimeHitAnimation(actionAnimeManager.NO_BALL_CAP_DASH_AWAY_FROM_BALL_CAP_SPRITE_ANIME_ID)
		actionAnimeManager.expireOneTimeHitAnimation(actionAnimeManager.NO_BALL_CAP_POST_SCREEN_WRAP_DASH_TOWARD_BALL_CAP_SPRITE_ANIME_ID)
			
	
func _on_ball_cap_landed():
	#THIS WAY hat keeps to floor collision to supports dashing and canceling to keep momentum
	dashToBallCapFollowMvm.offset=dashToBallCapFollowMvmGroundOffset
	#dashToBallCapFollowMvmParent.gravEffect =dashToBallCapFollowMvmParent.GravityEffect.REPLAY_AND_KEEP_FLOOR_COLLISION
	
	pass

func _physics_process(delta):
	
	#is thi scalled after or before player controllers '_physics_process' func?
	#ball cap on battle field?
	if ballCapRef != null:
		var hatCenter = kinbody.getCenter()
		var ballCapCenter = ballCapRef.getCenter()
		
		var xAxisDist =hatCenter.x -ballCapCenter.x
		
		#ball cap vertically aligned with hat?
		if abs(xAxisDist) <= VERTICAL_ALIGNMENT_DASH_TO_HAT_WIDTH:
			actionAnimeManager.enterBallCapVerticallyAlignedWithHatStance()
		elif xAxisDist > 0: #ball cap left of hat
			if kinbody.facingRight:
				actionAnimeManager.enterBallCapBehindHatStance()
			else:
				actionAnimeManager.enterBallCapInFrontOfHatStance()
		else: #ballc cap right of hat
			if kinbody.facingRight:
				actionAnimeManager.enterBallCapInFrontOfHatStance()
			else:
				actionAnimeManager.enterBallCapBehindHatStance()



