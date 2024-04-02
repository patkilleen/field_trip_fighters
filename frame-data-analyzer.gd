extends Node
signal animation_frame_data
#true when we perform frame data printing analysis, false to disable
const FRAME_DEBUG_FLAG = true
var GLOBALS = preload("res://Globals.gd")

const INPUT_LAG_OFFSET = 5.0 #5 frames of input lag, apparantly, since for just frame setups, if a hitbox lands when hitstun ends, you can't followup, so offset for clarity


const INACTIVE_STATE=0
const VICTIM_HITSTUN_BEGAN_STATE=1
const VICTIM_BROKE_FREE_FROM_HITSTUN_STATE=2
const ATTACKER_ANIMATION_ENDED_STATE=3
var state = INACTIVE_STATE

const PLUS_STR = "+" #INCLUDES NEUTRAL = 0
const MINUS_STR = "-"
#const NEUTRAL_STR = "="
var attackType= null

#changing this will globaly alter speed of animations
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD
var ellapsedTimeInSeconds = 0

var timerCountingFlag = false

var playerController = null
var opponentOnGroundOki=false
var blockStunFrameDataTracking =false


func _ready():
	
		
		
	#make sure if speed was specified elsewhere other than globals, that speed is up to date
	#var globalSpeedNodes = get_tree().get_nodes_in_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	#setGlobalSpeedMod(globalSpeedNodes[1].globalSpeedMod)
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	
	reset()
	
func setGlobalSpeedMod(g):
	globalSpeedMod = g
	
func init(_playerController):
	playerController=_playerController
	if FRAME_DEBUG_FLAG:
		
		playerController.opponentPlayerController.connect("entered_block_hitstun",self,"_on_opponent_entered_block_hitstun")
		playerController.opponentPlayerController.connect("exited_block_stun",self,"_on_opponent_exited_block_stun")
		playerController.opponentPlayerController.playerState.connect("changed_in_hitstun",self,"_on_opponent_hitstun_changed")
		playerController.actionAnimeManager.connect("action_animation_finished",self,"_on_animation_ended")
		#playerController.connect("start_hitfreeze",self,"_on_hit_freeze_started")
		#playerController.connect("stop_hitfreeze",self,"_on_hit_freeze_stopped")
		playerController.actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_animation_played")
		playerController.opponentPlayerController.actionAnimeManager.spriteAnimationManager.connect("sprite_animation_played",self,"_on_opponent_animation_played")
		
		blockStunFrameDataTracking =false
		
		reset()

func _on_opponent_hitstun_changed(inhitstunFlag):
	
	if opponentOnGroundOki and not inhitstunFlag:
		opponentOnGroundOki = false
		#ingore case where get up from oki
		return
	#broke free from hitstun
	if not inhitstunFlag:
		#print("opponent out hitstun")
		
		#attacker's animation already ended (plus)
		if state == ATTACKER_ANIMATION_ENDED_STATE:
			attackType=PLUS_STR
		
			analyzeFrameData()
			
			
		else:
			state = VICTIM_BROKE_FREE_FROM_HITSTUN_STATE
			
			#don't start tracking time until hitfreeze ends
			if not playerController.inHitFreezeFlag:
				set_physics_process(true)
			timerCountingFlag=true
			attackType=MINUS_STR
			
	else: #entering hitstun
		blockStunFrameDataTracking =false
		reset()
		#emit_signal("animation_frame_data","") #clear the last  frame data label
		state=VICTIM_HITSTUN_BEGAN_STATE
		#set_physics_process(true)

	
	pass
	
func _on_animation_ended(animationId):
	
	handleAttackAnimationFinished()
func _on_animation_played(animation):
	#handleAttackAnimationFinished()
	pass
	
func _on_opponent_animation_played(animation):
	
	#landed prone into oki, so stop tracking frames
	if animation.id == playerController.opponentPlayerController.actionAnimeManager.LANDING_HITSTUN_SPRITE_ANIME_ID:
		opponentOnGroundOki=true
		reset()
		#emit_signal("animation_frame_data","")#clear the fraem data field
	elif animation.id == playerController.opponentPlayerController.actionAnimeManager.STUNNED_SPRITE_ANIME_ID:
		reset()
		#emit_signal("animation_frame_data","")#clear the fraem data field
		
#	elif animation.id == playerController.opponentPlayerController.actionAnimeManager.AIR_HITSTUN_SPRITE_ANIME_ID:
		#reset the ellapsed time
#	pass
	
func handleAttackAnimationFinished():
	#ended aniamtion before hitstun end (plus)?
	if state == VICTIM_HITSTUN_BEGAN_STATE:
		state=ATTACKER_ANIMATION_ENDED_STATE
		attackType=PLUS_STR
		#don't start tracking time until hitfreeze ends
		if not playerController.inHitFreezeFlag:				
			set_physics_process(true)
		timerCountingFlag=true
	elif state == INACTIVE_STATE:
		#do nothing, no attack occured from this animation
		pass
		 
	elif state == VICTIM_BROKE_FREE_FROM_HITSTUN_STATE: #victim broke free before end (aniamtion is minus)?
		attackType=MINUS_STR
		
		analyzeFrameData()
		reset()
	#print("opponent out hitstun")
	pass
func reset():
	state=INACTIVE_STATE
	attackType=null
	set_physics_process(false)
	ellapsedTimeInSeconds = 0
	timerCountingFlag = false
	
	
	
func _physics_process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	delta = delta *globalSpeedMod
	
	ellapsedTimeInSeconds= ellapsedTimeInSeconds+delta
	
	
func _on_hit_freeze_started():
	#wait for hitfreeze to stop before counting duratio nof hitstun
	if timerCountingFlag:
		set_physics_process(false)
		
func _on_hit_freeze_stopped():
	#restart counting
	if timerCountingFlag:
		set_physics_process(true)

func analyzeFrameData():
	
	#onld content. don't use this code
	# warning-ignore:UNREACHABLE_CODE
	return
	if not blockStunFrameDataTracking:
		##NOTE THAT THERE IS APPARANTLY A 4 FRAME INUT LAG OR lag betwene animation transitions, so need to add 4 more frames. So if duration is 12, and animation is +5, the +5 is actually +1, so need add $( need make it 17 )
		#this is only the case for hitstun
		
		#since there is this odd + 4 lag, adjust the labels to make it clear what duration is wit hrespect to move startup speed
		var framesEllapsed = float(ellapsedTimeInSeconds)/float(GLOBALS.SECONDS_PER_FRAME)
		
		
		var rawframesEllapsed=framesEllapsed
		var estimated =0
		
		framesEllapsed = framesEllapsed - INPUT_LAG_OFFSET
		framesEllapsed = stepify(framesEllapsed,0.01) #leave 2 decimal places for debuggin purposes
		rawframesEllapsed = stepify(rawframesEllapsed,0.01) #leave 2 decimal places for debuggin purposes
		#we round the fractional frames up, since a fractional frame means 1 more frame in additon has 
		#to be run to satisfy the ellapsed time (negative frames round down, since they represent 
		#time taken for opponent to ellapse fram)
		
		
		estimated = rawframesEllapsed-(rawframesEllapsed-framesEllapsed)/2.0
		estimated = stepify(estimated,0.01)
			
	
		var minFrame = min(rawframesEllapsed,framesEllapsed)
		var maxFrame = max(rawframesEllapsed,framesEllapsed)
		var resStr = "HS: "+str(attackType)+"[("+str(minFrame)+")-("+str(maxFrame)+")] ~ "+ str(attackType)+str(estimated)
		#print("animation frames(+/-)(frames): "+str(attackType)+str(round(framesEllapsed)))
		#emit_signal("animation_frame_data",resStr)
	else:
		var framesEllapsed = float(ellapsedTimeInSeconds)/float(GLOBALS.SECONDS_PER_FRAME)
		framesEllapsed = stepify(framesEllapsed,0.01) 
		var resStr = "BS: "+str(attackType)+"("+str(framesEllapsed)+")"
	#	emit_signal("animation_frame_data",resStr)
func _on_opponent_entered_block_hitstun(attackerHitbox,blockResult, facingRight):
	
	blockStunFrameDataTracking =true
	reset()
	state=VICTIM_HITSTUN_BEGAN_STATE
	#emit_signal("animation_frame_data","") #clear the last  frame data label
	
	
func _on_opponent_exited_block_stun():
	#attacker's animation already ended (plus)
	if state == ATTACKER_ANIMATION_ENDED_STATE:
		attackType=PLUS_STR
	
		analyzeFrameData()
		reset()
		
	else:
		state = VICTIM_BROKE_FREE_FROM_HITSTUN_STATE
		set_physics_process(true)
		timerCountingFlag=true
		attackType=MINUS_STR
		
	


func handleFrameDataLableUpdate(framesRemainingForAttacker,hitStunDuration):
	var diff = framesRemainingForAttacker - hitStunDuration
	if  diff<0:
		attackType = "+"
	elif diff >0:
		attackType = "-"
	else:
		attackType = ""
		

	var resStr = str(attackType)+"("+str(abs(stepify(diff,0.01)))+")"
	emit_signal("animation_frame_data",resStr)
	



	