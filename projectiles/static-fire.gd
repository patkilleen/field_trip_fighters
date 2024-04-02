extends "res://projectiles/fire.gd"

var inputManager = preload("res://input_manager.gd")
var DOWN_SPECIAL_COMMAND = null
func init():
	.init()
	
	masterPlayerController.opponentPlayerController.connect("ripost_attempted",self,"_on_opponent_ripost_attempted")
	DOWN_SPECIAL_COMMAND = inputManager.Command.CMD_DOWNWARD_SPECIAL
func _on_opponent_ripost_attempted(cmd, ripostedFlag):
	
	#make sure this fire ball disapears upon getting riposted
	#don't want opponent to be able to farm a ripost from multi hit  hitbox
	#that persists after a ripost
	if ripostedFlag and cmd == DOWN_SPECIAL_COMMAND:
		destroy()
	
