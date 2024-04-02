extends Node

signal counter_ripost_failed
const frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")
var counterRipostDisabled = false
var counterRiposting = false
var cmd = null

var playerController = null

var customDurationTimer = null

var customDurationEnabled = false
func _ready():
	pass # Replace with function body.

func init(_playerController):
	playerController =_playerController
	
	customDurationTimer  = frameTimerResource.new()	
	add_child(customDurationTimer)
	customDurationEnabled=false
	customDurationTimer.connect("timeout",self,"_on_custom_duration_expired")
	#connoect to appropriate signals here
	if not playerController.actionAnimeManager.spriteAnimationManager.is_connected("sprite_animation_played",self,"_on_sprite_animation_played"):
		playerController.actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_sprite_animation_played")
		

	if not playerController.actionAnimeManager.spriteAnimationManager.is_connected("finished",self,"_on_sprite_animation_finished"):
		playerController.actionAnimeManager.spriteAnimationManager.connect("finished",self,"_on_sprite_animation_finished")
		
	
	reset()
	pass

func reset():
	customDurationTimer.stop()
	customDurationEnabled=false
	counterRiposting=false
	counterRipostDisabled=false
	cmd =null
	
func startCounterRipostTracking(_cmd,_customCounterRipostWindowDuration):
	
	#can't counter ripost a null commanad
	if _cmd == null:
		return 
	
	cmd=_cmd
	counterRiposting = true
	
	#a special duration is enabled for this command and will expire not necessarily when animation ends?
	if _customCounterRipostWindowDuration> -1:
		customDurationEnabled=true
		customDurationTimer.start(_customCounterRipostWindowDuration)
	else:
		customDurationEnabled=false
	
	

#resutrns true when counter riposted succeded
#false if there was not counter ripost or it didn't succed
func succsfulCounterRipostCheck(_cmd):
	
	if counterRiposting:
		
		#only counter ripost if same command
		return cmd ==_cmd
		
	#by default not counter riposted		
	return false

func signalCounterRipostFailed():
	if not counterRiposting:
		return
		
	customDurationTimer.stop()
	#make sure to save command we counter riposting before reseting
	var _cmd = cmd
	reset()
	
	#we fail the counter ripost
	emit_signal("counter_ripost_failed",_cmd)
	
func _on_active_counter_ripost_and_projectile_hit_with_no_ripost():
	signalCounterRipostFailed()
func _on_custom_duration_expired():
	signalCounterRipostFailed()
	
	
	
func _on_sprite_animation_finished(spriteAnimation):

	#were not counter riposting?
	if not counterRiposting:
		#nothing do do
		return
	
	#a custom duration is enabled?
	if customDurationEnabled:
		#don't fail yet
		return
			
	if spriteAnimation!= null:
		#do we prevent failing counter ripost from ended animation?
		if spriteAnimation.preventCounterRipostFailOnEnd:
			return
			
	#finishign aniamtion will count as fail
		
	#make sure to save command we counter riposting before reseting
	var _cmd = cmd
	reset()
	
	#we fail the counter ripost
	emit_signal("counter_ripost_failed",_cmd)
	
func _on_sprite_animation_played(spriteAnimation):
	if spriteAnimation == null:
		return
	
		
	#if the animation prevents counter riposts, we flag this for later
	if spriteAnimation.preventCounterRipost:
		counterRipostDisabled=true
	else:
		counterRipostDisabled=false
		
		
	#were not counter riposting?
	if not counterRiposting:
		#nothing do do
		return
	

	#special case were we extend counter ripost aniamtion to a new animation?
	#would likelly apply to multi tap animations, special rekas, or on hit animations
	if spriteAnimation.preventCounterRipostFailOnPlay:
		return
	
		
	#a custom duration is enabled?
	if customDurationEnabled:
		#don't fail yet
		return
			
			
	#make sure to save command we counter riposting before reseting
	var _cmd = cmd
	reset()
	
	#we fail the counter ripost
	emit_signal("counter_ripost_failed",_cmd)


func attemptCounterRipost(counterRipostCmd,_customCounterRipostWindowDuration):
	
	if counterRipostDisabled:
		reset()
		return 
	var facingCmd = playerController.inputManager.getCounterRipostedCommand(counterRipostCmd)
	#we succesfuly started an attack that we wish to counter the incomming ripost
	#start the counter ripost tracking
	
	#now gotta check for enough bar and if legal to counter ripost
	
	
	#don't bother if you have not bar
	
	if playerController.playerState.hasEnoughAbilityBar(playerController.counterRipostingAbilityBarCost):
		
		#only allow counter riposting specific directional commands if on the ground
		#since we can't he a player with anything other than N-melee, n-special, and n-tool
		#in air
		if playerController.my_is_on_floor():
							
			startCounterRipostTracking(facingCmd,_customCounterRipostWindowDuration)								
		else:
			
			#get neutral version of counter ripost command
			var neutralCounterRipostCommand = playerController.inputManager.counterRipostAirCommandMap[counterRipostCmd]
			
			#convert counter ripost comand to normal command
			facingCmd = playerController.inputManager.getCounterRipostedCommand(neutralCounterRipostCommand)
						
				
			startCounterRipostTracking(facingCmd,_customCounterRipostWindowDuration)																									
	else:
		playerController.emit_signal("insufficient_ability_bar",playerController.counterRipostingAbilityBarCost*playerController.playerState.abilityChunkSize)

