extends Node
const GLOBALS = preload("res://Globals.gd")
export (Color) var baseAirDashModulate = Color(0,0,0,1) setget setBaseAirDashColor,getBaseAirDashColor
export (Color) var extraAirDashModulate = Color(0,0,0,1) setget setExtraAirDashColor,getExtraAirDashColor
export (Color) var baseJumpModulate = Color(0,0,0,1) setget setBaseJumpColor,getBaseJumpColor
export (Color) var extraJumpModulate = Color(0,0,0,1) setget setExtraJumpColor,getExtraJumpColor

#number of air dashes performed since last jump/land
var airDashes={}
var jumps={}

var player1= null
var player2= null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(_player1,_player2):
	player1=_player1
	player2=_player2

	reset()
	player1.playerController.connect("jumped",self,"_on_player_jumped",[player1])
	player1.playerController.connect("landed",self,"_on_player_landed",[player1])
	player1.playerController.connect("air_dashed",self,"_on_player_air_dashed",[player1])
	
	player2.playerController.connect("jumped",self,"_on_player_jumped",[player2])
	player2.playerController.connect("landed",self,"_on_player_landed",[player2])
	player2.playerController.connect("air_dashed",self,"_on_player_air_dashed",[player2])

func reset():
		
	airDashes[player1] = 0
	airDashes[player2] = 0
	jumps[player1] = 0
	jumps[player2] = 0	
func setBaseAirDashColor(c):
	baseAirDashModulate = c
func getBaseAirDashColor():
	return baseAirDashModulate 
	
func setExtraAirDashColor(c):
	extraAirDashModulate = c
func getExtraAirDashColor():
	return extraAirDashModulate

func setBaseJumpColor(c):
	baseJumpModulate = c
func getBaseJumpColor():
	return baseJumpModulate
	
func setExtraJumpColor(c):
	extraJumpModulate=c
	
func getExtraJumpColor():
	return extraJumpModulate


func _on_player_landed(player):
	airDashes[player]=0
	jumps[player] = 0
	
	pass

#func _on_player_left_ground(player):
#	pass
	
func _on_player_jumped(player):
	airDashes[player]=0
	jumps[player] = jumps[player] +1
	pass
	
func _on_player_air_dashed(airDashType,player):
	
	if airDashType ==GLOBALS.AirDashType.BACKWARD or airDashType == GLOBALS.AirDashType.FORWARD:
		airDashes[player]= airDashes[player] +1
	pass

func lookupAirDashDustColor(airDashType,player):
	
	#downward dash never changes color
	if airDashType == GLOBALS.AirDashType.DOWNWARD:
		return baseAirDashModulate
		
	var airDashCount = airDashes[player]
	
	#standard air dash?
	if airDashCount < 1:
		return baseAirDashModulate
	else:
		#player had addition air dash, so special color
		return extraAirDashModulate

func lookupJumpDustColor(player):
	

	var jumpCount = jumps[player]
	
	#standard air dash?
	if jumpCount < 1:
		return baseJumpModulate
	else:
		#player had addition air dash, so special color
		return extraJumpModulate
	