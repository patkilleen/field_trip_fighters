extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
#signal preemptive_ripost_succeeded
signal preemptive_ripost_window_expired
#signal preemptive_ripost_invalid_prediction
signal reactive_ripost_succeeded
signal reactive_ripost_window_expired
signal reactive_ripost_invalid_prediction
#signal ripost_was_countered


var inputManager_resource = preload("res://input_manager.gd")

var GLOBALS = preload("res://Globals.gd")
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

#note that the pre-react windows below will be set by other modules
var ripostingPreWindow = 5 setget setRipostingPreWindow,getRipostingPreWindow #number of frames to preemptively ripost
var ripostingPreWindowInSeconds = ripostingPreWindow* GLOBALS.SECONDS_PER_FRAME
#var ripostingPreTimeWindow = -1
var ripostingReactWindow = 2 setget setRipostingReactWindow,getRipostingReactWindow #number of frames to react to ripost
var ripostingReactWindowInSeconds = ripostingReactWindow*GLOBALS.SECONDS_PER_FRAME
#var ripostingReactTimeWindow = -1 #

#var predictedActionId = null
var predictedCommand = null

#-1 to be outstide reactive window
#var ripostingWindowFramesRemaining = -ripostingReactWindow-1
var ripostingWindowSecondsRemaining = -ripostingReactWindowInSeconds - GLOBALS.SECONDS_PER_FRAME

#var actualActionId = null
var actualSpriteAnimationId = null
#var actualCommand = null

#hitbox hitting this player
#var hitboxArea = null
#hurtbox being hit
#var hurtboxArea = null

#used to access facing command map for cross-up command changing
var inputManager = null


var enoughBarToRipost=true

#list of commands was hit by in the frame hits being resolved
var hitByCmds = []

#list of [command, hitbox,hjurtbox] triples that keep track of collision /tattacks that hit during 
#ripost period
var attacksHit =[] 

const CMD_IX = 0
const HITBOX_IX = 1
const HURTTBOX_IX = 2
const SPRITE_ANIME_ID_IX=3

#var canRipost=null
func _ready():
	
	
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	
	inputManager = inputManager_resource.new()
	add_child(inputManager)
	inputManager.set_physics_process(false)
	
	set_physics_process(false)
	pass

func reset():
	init()
	hitByCmds.clear()
	attacksHit.clear()
	actualSpriteAnimationId=null
	enoughBarToRipost=true

	#canRipost = null
func setGlobalSpeedMod(mod):
	globalSpeedMod=mod
	
func setRipostingPreWindow(w):
	ripostingPreWindow = w
	ripostingPreWindowInSeconds = ripostingPreWindow* GLOBALS.SECONDS_PER_FRAME
	
func getRipostingPreWindow():
	return ripostingPreWindow

func setRipostingReactWindow(w):
	ripostingReactWindow = w
	ripostingReactWindowInSeconds = ripostingReactWindow*GLOBALS.SECONDS_PER_FRAME
	
func getRipostingReactWindow():
	return ripostingReactWindow
	
func init():
#	predictedActionId = null
	#actualSpriteAnimationId = null
	predictedCommand = null
	#actualCommand = null
	attacksHit.clear()
	#hitboxArea = null
	#hurtboxArea = null
	#-1 to be outstide reactive window
	#ripostingWindowFramesRemaining = -ripostingReactWindow -1	
	ripostingWindowSecondsRemaining = -ripostingReactWindowInSeconds - GLOBALS.SECONDS_PER_FRAME
	
	set_physics_process(false)
	
func signal_riposting_finished(signalStr,cmdRiposted):
	#var _hitboxArea = hitboxArea
	#var _hurtboxArea = hurtboxArea
	#var _predictedActionId = predictedActionId
	var _predictedCommand = predictedCommand
	#var _actualActionId = actualActionId
	#var _actualSpriteAnimationId = actualSpriteAnimationId
	

	match(signalStr):
		#"preemptive_ripost_succeeded":
		#	emit_signal(signalStr,_hitboxArea,cmdRiposted)
		"preemptive_ripost_window_expired":
			stopRipostWindow()
			emit_signal(signalStr,cmdRiposted)
		#"preemptive_ripost_invalid_prediction":
		#	emit_signal(signalStr,_actualSpriteAnimationId,_hitboxArea,_hurtboxArea,cmdRiposted)
		"reactive_ripost_succeeded":
			
			#hitbox we riposted
			var _hitboxArea = null
			
			
			#iterate over attacks hit us this frame to find the attack we riposted
			for attackTriple in attacksHit:				
				var hitByCmd=attackTriple[CMD_IX]
				#found the attack we riposted?
				if hitByCmd==cmdRiposted:					
					_hitboxArea =attackTriple[HITBOX_IX]					
					break
			stopRipostWindow()
			emit_signal(signalStr,_hitboxArea,cmdRiposted)
		"reactive_ripost_window_expired":
			#find the collision info of all attacks that hit us. We didn't try
			#to ripost so they should all take effect			
			#iterate over attacks hit us this frame to find the attack we riposted
			for attackTriple in attacksHit:
				
				var _actualSpriteAnimationId = attackTriple[SPRITE_ANIME_ID_IX]
				var _hitboxArea =attackTriple[HITBOX_IX]
				var _hurtboxArea = attackTriple[HURTTBOX_IX]
				stopRipostWindow()
				emit_signal(signalStr,_actualSpriteAnimationId,_hitboxArea,_hurtboxArea)
		"reactive_ripost_invalid_prediction":
			
			#find the collision info of all attacks that hit us. We didn't try
			#to ripost so they should all take effect			
			#iterate over attacks hit us this frame to find the attack we riposted
			for attackTriple in attacksHit:
				
				var _actualSpriteAnimationId = attackTriple[SPRITE_ANIME_ID_IX]
				var _hitboxArea =attackTriple[HITBOX_IX]
				var _hurtboxArea = attackTriple[HURTTBOX_IX]
				stopRipostWindow()
				emit_signal(signalStr,_actualSpriteAnimationId,_hitboxArea,_hurtboxArea,cmdRiposted)
			
		#"ripost_was_countered":
		#	emit_signal(signalStr,cmdRiposted)
			
		
	#stopRipostWindow()
func stopRipostWindow():
	set_physics_process(false)
	#init()
	reset()
	

#this stops the riposting window since it was countered
#func ripostCountered(cmdCounterRiposted):
#	signal_riposting_finished("ripost_was_countered",cmdCounterRiposted)
	
#this should be called only if enough ability bar available
#func attemptRipost(actionId):
func attemptRipost(cmd):
	
	
	if predictedCommand != null:
		#print("already riposting another move, ignore ripost")
		return 

	predictedCommand = cmd
	
	#in the short window to reactively ripost?
	if isRipostReactiveWindowActive():
		
		#checkForValidRipost()
		pass
		
	else:		
		#at this point  hasn't been activated, so activate preemptive window
		
		#start counting down window
		#ripostingWindowFramesRemaining = ripostingPreWindow
		ripostingWindowSecondsRemaining = ripostingPreWindowInSeconds
		set_physics_process(true)


func _on_reactive_ripost_window_expired():
	
	
	#missed reactive window? AKA: player didn't input a ripost?
	#or we don't have enough bar to ripost?
	if predictedCommand== null or not enoughBarToRipost or attacksHit.size()==0:	

		signal_riposting_finished("reactive_ripost_window_expired",null)
		
	else:	
		var correctCmdPrediction=false
		
		var ripostSucceeded = false
		
		#iterate over commands hit us this frame
		#in case where hit by two things same frame, if succesded on one of th attacks
		#it's a succsess
		for attackTriple in attacksHit:
			var hitByCmd=attackTriple[CMD_IX]
			var hitBox = attackTriple[HITBOX_IX]
			#can only succsefully ripost if proper command 
			#and the hitbox is ripostable
			if hitByCmd == predictedCommand:
				correctCmdPrediction=true
				if hitBox.ripostabled:					
					ripostSucceeded = true
		
					
		#did we predict correct command but unripostable attack?
		if correctCmdPrediction and not ripostSucceeded:
				
			#check if only hit by unripostable attack (then can't fail, it's a simple reactive expire)
			var allUnripostable = true
			for attackTriple in attacksHit:
				var hitBox = attackTriple[HITBOX_IX]
				allUnripostable = allUnripostable and not hitBox.ripostabled
				
			if allUnripostable:
				signal_riposting_finished("reactive_ripost_window_expired",null)
				return
			

		
		#it was proper ripost?
		if ripostSucceeded:
			signal_riposting_finished("reactive_ripost_succeeded",predictedCommand)
			
		else:
			signal_riposting_finished("reactive_ripost_invalid_prediction",predictedCommand)
			
		
func isRipostPreWindowActive():
	#return predictedActionId != null
	return predictedCommand != null

func isRipostReactiveWindowActive():
	
	return attacksHit.size()>0

#func startRipostReactiveWindow(_actualAction):
func startRipostReactiveWindow():
	
	if isInReactiveWindow():
		#print("warning, starting reactive ripost window, but already started")
		return
		
	set_physics_process(true)
	
	
	ripostingWindowSecondsRemaining = 0.0
	

#entire window (preemptive + reactive )hasn't expired? 
func isInsideRipostWindow():
	#return (isRipostPreWindowActive() or isRipostReactiveWindowActive()) and ripostingWindowFramesRemaining >= -ripostingReactWindow 
	return (isRipostPreWindowActive() or isRipostReactiveWindowActive()) and ripostingWindowSecondsRemaining >= -ripostingReactWindowInSeconds 
	
	
#returns true when still in preemptive window  (not in reactive window)
#false if outstide window or not preemtively riposting
func isInPreemptiveWindow():
	#return isRipostPreWindowActive() and ripostingWindowFramesRemaining > 0
	return isRipostPreWindowActive() and ripostingWindowSecondsRemaining > 0

#returns true when still in reactive window (not in preemptive window)
#false if outstide window or not reactively riposting
func isInReactiveWindow():
	#return isRipostReactiveWindowActive() and (ripostingWindowFramesRemaining <= 0) and isInsideRipostWindow()
	return isRipostReactiveWindowActive() and (ripostingWindowSecondsRemaining <= 0) and isInsideRipostWindow()


func _physics_process(delta):
	

	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	delta = delta * globalSpeedMod
	#are we 
	if not isRipostPreWindowActive() and  not isRipostReactiveWindowActive():
		return

	#reactive window active?
	if isRipostReactiveWindowActive():
		
		#no longer inside reactive window?
		if not isInReactiveWindow():
			
			_on_reactive_ripost_window_expired()
		
	#has attempted to ripost (predict being hit)?
	elif isRipostPreWindowActive():
		#wasn't hit during ripost preemptive window?
		if not isInPreemptiveWindow():
			signal_riposting_finished("preemptive_ripost_window_expired",predictedCommand)
			return
	
	#decrease the number of frames remaining to be able to ripost
	#ripostingWindowFramesRemaining = ripostingWindowFramesRemaining - 1 
	ripostingWindowSecondsRemaining = ripostingWindowSecondsRemaining - delta
	
	
#checks for a ripost input on being hit
#returns true when properly handled being hit, and false when the ripost didn't start
#func _on_player_was_hit(_hitboxArea,_hurtboxArea):
func startBriefRipostCheckHitResolveDelay(_hitboxArea,_hurtboxArea,_enoughBarToRipost):
	#print("ripost_on_player_hit")

	#canRipost = _canRipost
	if _hitboxArea == null:
		print("warning, in ripost handler, and hitbox hitting is null when checking for ripost")
		return false
	 
	#a unripostable hitstunless move should not be treated as
	#a hit to make the riposts fail
	#unripostable attacks with hitstun should make ripost fail (by continueing
	if (_hitboxArea.hitstunType == GLOBALS.HitStunType.NO_HITSTUN or _hitboxArea.hitstunType == GLOBALS.HitStunType.ON_LINK_ONLY_AND_HITSTUNLESS) and not _hitboxArea.ripostabled:
		return false
	#if _hurtboxArea == null:
	#	print("warning, in ripost handler, and hurtbox hit is null when checking for ripost")
	#	return false
		

	#TODO: test this code by having really long preemptive window and 
	#having a realllllly long startup move, long enough to crossup
	#and then get hit by it. Should be able to ripost  with same command 
	#during either facing left or right
	var _actualCommand = resolveRipostFacingDependentCommand(_hitboxArea)
	
	
	var actionAnimationManager = _hitboxArea.playerController.actionAnimeManager
	
	var _actualSpriteAnimationId = null
	
	enoughBarToRipost = _enoughBarToRipost
	if not _hitboxArea.is_projectile:
		_actualSpriteAnimationId =actionAnimationManager.currentSpriteAnimation
	else:
		_actualSpriteAnimationId =_hitboxArea.projectileParentSpriteAnimation.id
		
		
	#keep track of collisiosn/attack info
	var triple = []
	triple.append(_hitboxArea.cmd)
	triple.append(_hitboxArea)
	triple.append(_hurtboxArea)
	triple.append(_actualSpriteAnimationId)
	
	
	attacksHit.append(triple)
	
	startRipostReactiveWindow()
		
	return true
		
	#return true


func resolveRipostFacingDependentCommand(_hitboxArea):
	
		
	#here we should do logic to make sure command respects facing of original input  direction
	#(left-B animation will still be ripostable using right-B after/before a crossup)


	if _hitboxArea == null:
		return null
	
	var playerController = get_parent()
	var isVictimFacingRight = playerController.kinbody.facingRight
	
#var _actualCommand = actionAnimationManager.commandActioned
	#if _actualCommand == null:
	var _actualCommand = null
	
	#Case a): attacker was left of victim and began animation that created hitbox
	if _hitboxArea.facingRightWhenPlayed:
		
		#cross-up occured, gotta reverse the command
		if isVictimFacingRight:
			#mirror the input command, cuase cross-up occured since attacker animation played
			_actualCommand = inputManager.getFacingDependantCommand(_hitboxArea.cmd,not isVictimFacingRight) 
		else:
			#no cross-up, command is stil same as direction inputed
			_actualCommand = _hitboxArea.cmd
	else: #attacker was right of victim and began animation that created hitbox
		
		#cross-up occured, gotta reverse the command
		if not isVictimFacingRight:
			#mirror the input command, cuase cross-up occured since attacker animation played
			_actualCommand = inputManager.getFacingDependantCommand(_hitboxArea.cmd,isVictimFacingRight) 
		else:
			#no cross-up, command is stil same as direction inputed
			_actualCommand = _hitboxArea.cmd
	
	return _actualCommand
	
	

func getPreWindowNumberFramesEllapsed():
	return ripostingPreWindowInSeconds-ripostingWindowSecondsRemaining
	