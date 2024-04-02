extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal game_ended
signal game_ending


const DEBUG_COMMAND_MIRRORING = false
var debugP1CmdInput = null
var debugP2CmdInput = null
var debugP1CmdPostBufferInput= null
var debugP2CmdPostBufferInput= null
#number of frames required to turn around
export (int) var turnAroundDelay = 5

var GLOBALS = preload("res://Globals.gd")
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD
#var turnAroundEllapsedFrames = 0

#true when delay activated for turning around, false when not waiting to turn
var turnAroundFlag = false
var player1ShoudFaceRight = false
var player1 = null
var player2 =null
var gameEnding = false
var winnerText = null

var frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")

var turnAroundTimer = null

var endGamePlayer1State = null
var endGamePlayer2State = null

var inStylePointsState= false
var victoryType = null


var enableStylePointsRoundFlag = false
const TIMER_RAN_OUT_END = 0
const KO_END=1

func _ready():
	
	set_physics_process(false)
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	
	pass
	
func setGlobalSpeedMod(g):
	globalSpeedMod = g
	
func reset():
	set_physics_process(true)
	turnAroundTimer.stop()
func init(_player1,_player2):
	# Called when the node is added to the scene for the first time.
	# Initialization here
	player1 = _player1
	player2 = _player2
	
#	player1.playerController.ripostCounterHandler.opponentRipostHandler = player2.playerController.ripostHandler
#	player2.playerController.ripostCounterHandler.opponentRipostHandler = player1.playerController.ripostHandler
	
	#DONE IN ROOT
	player1.playerController.opponentPlayerController = player2.playerController
	player2.playerController.opponentPlayerController = player1.playerController
	
	#initialize here since need opponent controller initialize
	player1.playerController.frame_analyzer.init(player1.playerController)
	player2.playerController.frame_analyzer.init(player2.playerController)
	
	player1.playerController.comboHandler.init(player1.playerController,player1.playerController.playerState,player1.damageGaugeRateMode,player1.damageGaugeComboLevelUpModIncrease,player1.focusRateMode,player1.focusComboLevelUpModIncrease,player1.focusCashInMod,player1.damageGaugeCashInMod,player1.profAbilityBarComboProrationMod,player1.profAbilityBarComboLvlProrationMod,player1.histunAbilityCancelProrationReductionRate,player1.abCancel_SpamProrationSetback)
	player2.playerController.comboHandler.init(player2.playerController,player2.playerController.playerState,player2.damageGaugeRateMode,player2.damageGaugeComboLevelUpModIncrease,player2.focusRateMode,player2.focusComboLevelUpModIncrease,player2.focusCashInMod,player2.damageGaugeCashInMod,player2.profAbilityBarComboProrationMod,player2.profAbilityBarComboLvlProrationMod,player2.histunAbilityCancelProrationReductionRate,player2.abCancel_SpamProrationSetback)
	
	player1.playerController.guardHandler.init(player1.playerController,player1.playerController.actionAnimeManager,player1.playerController.guardHpRegenRate,player1.playerController.guardHpLossRate,player1.playerController.loseGuardHPWhileWalkingBack,player1.playerController.boostedBuffGuardRegenMod)
	player2.playerController.guardHandler.init(player2.playerController,player2.playerController.actionAnimeManager,player2.playerController.guardHpRegenRate,player2.playerController.guardHpLossRate,player2.playerController.loseGuardHPWhileWalkingBack,player2.playerController.boostedBuffGuardRegenMod)
	
	player1.playerController.initFollowMovements()
	player2.playerController.initFollowMovements()
	
	player1.playerController.playerState.connect("changed_in_hitstun",self,"_on_hitstun_change")
	player2.playerController.playerState.connect("changed_in_hitstun",self,"_on_hitstun_change")
	
	
	if DEBUG_COMMAND_MIRRORING:
		player1.playerController.connect("cmd_inputed",self,"_on_command_inputed",[1])
		player2.playerController.connect("cmd_inputed",self,"_on_command_inputed",[2])
		player1.playerController.connect("cmd_inputed_post_buffer",self,"_on_cmd_inputed_post_buffer",[1])
		player2.playerController.connect("cmd_inputed_post_buffer",self,"_on_cmd_inputed_post_buffer",[2])
		
		
	turnAroundTimer = frameTimerResource.new()
	self.add_child(turnAroundTimer)
	turnAroundTimer.connect("timeout",self,"_on_turn_around_delay_ellapsed")
	
	
	
	set_physics_process(true)

func resetDefaultValues():
	inStylePointsState=false
	gameEnding=false
	winnerText = null
	victoryType = null
	turnAroundFlag = false
	player1ShoudFaceRight = false
	endGamePlayer1State = null
	endGamePlayer2State = null
	if turnAroundTimer != null:
		turnAroundTimer.stop()
#need to make this frame independant and consider the global speed mod
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	#if player1.playerController.inputManager.is_physics_processing():
	#	player1.playerController.inputManager.physics_process_hook(delta)
	#if player2.playerController.inputManager.is_physics_processing():
	#	player2.playerController.inputManager.physics_process_hook(delta)
	
	#if player1.playerController.is_physics_processing():
	#	player1.playerController._physics_process_hook()
	#if player2.playerController.is_physics_processing():
	#	player2.playerController._physics_process_hook()
		
	checkForTurningAround()
	
	_checkForGameEnd(KO_END)
	
	if DEBUG_COMMAND_MIRRORING:
		if debugP1CmdInput  != debugP2CmdInput:
			var commandsStrings = player1.playerController.inputManager.Command.keys()
			if commandsStrings.has(debugP1CmdInput) and  commandsStrings.has(debugP2CmdInput) :
				print("mirrored input differed for commands: "+str(commandsStrings[debugP1CmdInput])+" vs. "+str(commandsStrings[debugP2CmdInput]))
				
			else:
				print("mirror input different command: "+str(debugP1CmdInput) + " and "+str(debugP2CmdInput))
			pass

		if debugP1CmdPostBufferInput != debugP2CmdPostBufferInput:
			var commandsStrings = player1.playerController.inputManager.Command.keys()
			if commandsStrings.has(debugP1CmdPostBufferInput) and  commandsStrings.has(debugP2CmdPostBufferInput) :
				print("mirrored input differed for commands: "+str(commandsStrings[debugP1CmdPostBufferInput])+" vs. "+str(commandsStrings[debugP2CmdPostBufferInput]))
				
			else:
				print("mirror input different command: "+str(debugP1CmdPostBufferInput) + " and "+str(debugP2CmdPostBufferInput))
			pass
	
func checkForTurningAround():
	
	
	#are we in the special case where someone is contesting the corner?
	if player1.playerController.occupyingRightCorner or player2.playerController.occupyingRightCorner or player1.playerController.occupyingLeftCorner or player2.playerController.occupyingLeftCorner:
			
		#ignore any facing change when a player that occupies corner is facing correct direction
		#so even if opponent tries to steal corner, they won't change facing and 
		#the movement system will pop them out of corner
		if player1.facingRight and player1.playerController.occupyingLeftCorner:
			return
		if not player1.facingRight and player1.playerController.occupyingRightCorner:
			return
		if player2.facingRight and player2.playerController.occupyingLeftCorner:
			return
		if not player2.facingRight and player2.playerController.occupyingRightCorner:
			return
			
	var p1CenterX = player1.getCenterX()
	var p2CenterX = player2.getCenterX()
	
	
	var startTurnAroundTimer = false
	#player 1 crossed right over player 2 and should now face left?
	if (not turnAroundFlag) and (p1CenterX > p2CenterX) and player1.facingRight:
		
		turnAroundFlag=true
		player1ShoudFaceRight =false
		#turnAroundEllapsedFrames=0
		startTurnAroundTimer = true
	
	#player 1 crossed left over player 2 and should now face right?	
	elif (not turnAroundFlag) and (p1CenterX < p2CenterX) and (not player1.facingRight):
		turnAroundFlag=true
		player1ShoudFaceRight=true
		#turnAroundEllapsedFrames=0
		startTurnAroundTimer=true
	
	#trigger the turn around?
	if startTurnAroundTimer:
		#TODO: we may want to change this logic, where the facing Right for input will always be frame
		#perfect up to date, and it's the spritefacing that is delayed. Otherwise, result might be why
		#the dash  crossups feels like you input wrong direction a lot
		#turnAroundTimer.start(turnAroundDelay)
		_on_turn_around_delay_ellapsed()

	
func _on_turn_around_delay_ellapsed():
	if not player1ShoudFaceRight:
		player1.facingRight = false
		player2.facingRight = true
	else:
		player1.facingRight = true
		player2.facingRight = false
	
	turnAroundFlag = false

func _checkForGameEnd(endType):
	if not gameEnding and not inStylePointsState:
		
		if endType == KO_END:
			if player1.playerController.playerState.hp <= 0:
				if player2.playerController.playerState.hp <= 0:	
					#draw
					winnerText = "Draw!"
					victoryType = GLOBALS.VictoryType.DRAW_VIA_KO
				else:
					#player 2 win
					winnerText = "Player 2"
					victoryType = GLOBALS.VictoryType.PLAYER2_WINS_VIA_KO					
					player1.playerController.gameEndingStun = true
			elif player2.playerController.playerState.hp <= 0:	
				#player 1 win
				winnerText = "Player 1"
				victoryType = GLOBALS.VictoryType.PLAYER1_WINS_VIA_KO
				player2.playerController.gameEndingStun = true
		elif endType == TIMER_RAN_OUT_END: #match timer ran out, winner is player with most HP
			
			if player1.playerController.playerState.hp == player2.playerController.playerState.hp:
				
				#draw
				winnerText = "Draw!"
				victoryType = GLOBALS.VictoryType.DRAW_VIA_TIMEOUT
		
			elif player1.playerController.playerState.hp < player2.playerController.playerState.hp:	
				#player 2 win
				winnerText = "Player 2"
				victoryType = GLOBALS.VictoryType.PLAYER2_WINS_VIA_TIMEOUT
				player1.playerController.gameEndingStun = true
			else:
				#player 1 win
				winnerText = "Player 1"
				victoryType = GLOBALS.VictoryType.PLAYER1_WINS_VIA_TIMEOUT
				player2.playerController.gameEndingStun = true
		else:
			print("internal error in playersNode for checking end mathch")
		#game ending for first time?			
		if winnerText != null:
			
			#gameEnding = true	
			#store the player state so end game style points don't over ride them 
			endGamePlayer1State = player1.playerController.playerState.deepCopy() # i think there is a bug atm with tracking player state
			endGamePlayer2State = player2.playerController.playerState.deepCopy()
			
			#stun the players if they not in hitstun
			if player2.playerController.gameEndingStun:
				if not player2.playerController.playerState.inHitStun:
					player2.playerController.goIntoVulnerableStunState(player2.playerController.END_MATCH_LOSER_STUN_DURATION)
			if player1.playerController.gameEndingStun:
				if not player1.playerController.playerState.inHitStun:
					player1.playerController.goIntoVulnerableStunState(player1.playerController.END_MATCH_LOSER_STUN_DURATION)
			startTrackingStylePointsPlayerState()
			if enableStylePointsRoundFlag:
				emit_signal("game_ending",victoryType,player1.playerController.playerState,player2.playerController.playerState)
			else:
				emit_signal("game_ending",victoryType,endGamePlayer1State,endGamePlayer2State)	

func _on_game_match_timeout():
	_checkForGameEnd(TIMER_RAN_OUT_END)
	
func startTrackingStylePointsPlayerState():
	#not implemente yet
	#should set up below state so that player that one, 
	#his stats are tracked, so best combo and damage for the
	#ending combo 
	inStylePointsState = true
	
	#reset all the stats tracking to enable style points
	player1.playerController.playerState.resetStatTracking()
	player2.playerController.playerState.resetStatTracking()
	pass

#ends the sylte points round
func style_point_round_end():
			
	var stylePointsPlayerState = null
	#resolve what player state is of winenr
	if victoryType == GLOBALS.VictoryType.PLAYER1_WINS_VIA_KO or victoryType == GLOBALS.VictoryType.PLAYER1_WINS_VIA_TIMEOUT:
		stylePointsPlayerState=player1.playerController.playerState.deepCopy() #deep copy to avoid having stats change during end of game
	elif victoryType == GLOBALS.VictoryType.PLAYER2_WINS_VIA_KO or victoryType == GLOBALS.VictoryType.PLAYER2_WINS_VIA_TIMEOUT:
		stylePointsPlayerState=player2.playerController.playerState.deepCopy()
	elif victoryType == GLOBALS.VictoryType.DRAW_VIA_KO or victoryType == GLOBALS.VictoryType.DRAW_VIA_TIMEOUT:
		#no style points
		pass
	emit_signal("game_ended",victoryType,winnerText,endGamePlayer1State,endGamePlayer2State,stylePointsPlayerState)

func _on_hitstun_change(hitstunFlag):
	
	#make sure is breaking out of hitstun, not entering it
	if gameEnding and not hitstunFlag:
		style_point_round_end()


func _on_command_inputed(cmd, ripostCmdFlag,counterRipostCmdFlag,pId):
	if pId ==1:
		
		#debugP1CmdInput=player1.playerController.inputManager.getFacingDependantCommand(cmd,player1.facingRight)
		debugP1CmdInput=cmd
	elif pId ==2:
		
		#debugP2CmdInput=player2.playerController.inputManager.getFacingDependantCommand(cmd,player2.facingRight)
		debugP2CmdInput=cmd
		
func _on_cmd_inputed_post_buffer(cmd,pId):
	if pId ==1:
		
		#debugP1CmdInput=player1.playerController.inputManager.getFacingDependantCommand(cmd,player1.facingRight)
		debugP1CmdPostBufferInput=cmd
	elif pId ==2:
		
		#debugP2CmdInput=player2.playerController.inputManager.getFacingDependantCommand(cmd,player2.facingRight)
		debugP2CmdPostBufferInput=cmd
		
				
