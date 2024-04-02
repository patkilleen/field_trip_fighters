extends "res://PlayerController.gd"

var ripostStrikeSFXMap = []

var baseBallRef  = null 

var preloadedBaseBaseBall= null

var gloveBaseBallSpawn = null


const CATCH_BALL_SOUND_ID = 28
const STRIKE_1_SOUND_ID=6
const STRIKE_2_SOUND_ID=38
const STRIKE_3_SOUND_ID=39

var ripostStrikeCounter = 0
func init(sprite,collisionAreas,attackSFXs,bodyBox,activeNodes):
	HERO_HITSTUN_STUN_SOUND_ID = 0
	HERO_RIPOST_SOUND_ID = 6
	HERO_COUNTER_RIPOST_SOUND_ID = 8
	HERO_INCORRECT_BLOCK_SOUND_ID=32
	
	ripostStrikeCounter = 0
	#INITIALIZE the map that indicates which "strike" voiceline to play
	#next once it players (strike 1, stricke 2, strike 3, striek 1, strike 2...)
	#using 'ripostStrikeCounter' as index
	ripostStrikeSFXMap.append(STRIKE_1_SOUND_ID)
	ripostStrikeSFXMap.append(STRIKE_2_SOUND_ID)
	ripostStrikeSFXMap.append(STRIKE_3_SOUND_ID)
	
	ripostVoicelineVolumeOffset=3
	counterRipostVoicelineVolumeOffset=3
	badBlockVoicelineVolumeOffset=3
	gettingHitVoicelineVolumeOffset=5
	
	var actionBroadCastFrameResource = load("res://ActionBroadcastSpriteFrame.gd")
	gloveBaseBallSpawn = $"baseball-spawn"
	gloveBaseBallSpawn.init(1,self) #one baseball will ever exist
	
	#call parent's init
	.init(sprite,collisionAreas,attackSFXs,bodyBox,activeNodes)
	#actionAnimeManager.connect("create_projectile",self,"_on_create_projectile")
	
	#we want to connect to all the glove sprite frames that 
	#signal the aciton to apply to the ball when activated
	#iterate all basic movment, and connect to follow complete
	for sAnimes in actionAnimeManager.spriteAnimationManager.spriteAnimations:
		for sframe in sAnimes.spriteFrames:
		
			#the sprite frame is a action broacast sprite frame?
			#if sframe is actionBroadCastFrameResource:
			if sframe.frameActivationNotifier != null:
				sframe.connect("activated",self,"_on_ball_interaction",[sframe.frameActivationNotifier.actionId])



func _on_create_projectile(projectile,spawnPoint):
	
	#can't throw ball if ball is on the battlefield (must have the ball to trhow it)
	if baseBallRef == null:
		#make it so action anime manager now goes towards no-ball animations
		actionAnimeManager.setHasBallFlag(false)
		
		baseBallRef = projectile
		
		if not projectile.is_connected("caught_ball",self,"_on_ball_catch"):
			projectile.connect("caught_ball",self,"_on_ball_catch")
	else:
		print("warning, in bug state where trying to create (throw) baseball, but it already on field")

	#we did some book keeping before signaling to create projectile
	._on_create_projectile(projectile,spawnPoint)
	
func _on_ball_catch(ball):
	baseBallRef = null
	
	if ball != null:
		ball.disconnect("caught_ball",self,"_on_ball_catch")
		ball.destroy()
		
		
	var soundVolumeOffset=7
	_on_request_play_special_sound(CATCH_BALL_SOUND_ID,HERO_SOUND_SFX,soundVolumeOffset)
	#make it so glove now has the ball again
	actionAnimeManager.setHasBallFlag(true)
	
	
#this is called when player's unique self hitbox hit's the ball
#it means we pickup the ball
func _on_ball_collision():
	
	_on_ball_catch(baseBallRef)
	
	
#this is called when a glovespriteframe is activated
#and tries to interact with the live ball
func _on_ball_interaction(spriteFrame,actionId):
	
	#can't interact with ball if it doesn't exist. make sure it does
	if baseBallRef != null:
		
		#only play if auto cancelable
		if baseBallRef.actionAnimationManager.isAutoCancelable(actionId):
			#save the command used to interact with the ball
			baseBallRef.command = actionAnimeManager.commandActioned
			baseBallRef.actionAnimationManager.playUserAction(actionId,kinbody.facingRight,baseBallRef.command)
	
#override		
func on_grabbing_opponent():
	
	#go into on hit anti block animation
	#print("old content")
	pass
	#make sure opponent not being hit during same attack
	#if not playerState.inHitStun:
		#find id of ground idle for opponent animtion to cancel recovery frames of anti block
	#	playActionKeepOldCommand(actionAnimeManager.ANTI_BLOCK_ON_HIT_ACTION_ID)	
		
		
#to be implemented by subclasses. Used to load a single type of projectile 
#to be spawned at multiple areas
func getStaticProjectileSpawn(customProjectileSpawnData):
	
	return gloveBaseBallSpawn
	
	
#when match is restarted, this is called
func restart_hook():

	actionAnimeManager.setHasBallFlag(true)
	baseBallRef= null
	
	emit_signal("player_state_info_text_changed","")
	
		
	.restart_hook()
	
	
	
#called when a follow movement is initiated (starts/activates) and
#the follow destination type is other (not caster, nor opponent)
func _on_following_special_object_type_hook(followMvm):
	
	pass

#overrides parent function
func readyToCreateProjectileHook(projectileFrame):
	return baseBallRef == null #no ball on field means create, otherwise don't create ball
		


func trainingModeEnterCharDependentState(params):
	#should put player in a special state like a stance change or something 
	#when game upaunses in training mode and the setting is enabled
	
	#catches ball from anywhere. to eanble retreving ball faster
	if baseBallRef != null:
		baseBallRef._on_ball_caught() 	
	
	

func reset():
	.reset()
	baseBallRef  = null 

	preloadedBaseBaseBall= null

	gloveBaseBallSpawn = null
	ripostStrikeCounter=0
	
func _on_request_play_special_sound(soundId,soundType,soundVolumeOffset=null):
	#ripost strike sound?
	if soundId ==STRIKE_1_SOUND_ID:
		#instead use the strike 1,2,3 sfx based on how many times riposted/auto riposted
		soundId = ripostStrikeSFXMap[ripostStrikeCounter]
		ripostStrikeCounter = (ripostStrikeCounter +1 ) % ripostStrikeSFXMap.size()
	
	._on_request_play_special_sound(soundId,soundType,soundVolumeOffset)