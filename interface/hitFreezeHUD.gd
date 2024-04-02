extends Control
const GLOBALS = preload("res://Globals.gd")
var hitFreezeValueLabel = null

var gameMode =null
func _ready():
	self.visible = false
	
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	

func init(_gameMode):
	gameMode=_gameMode
	hitFreezeValueLabel = $"hitFreezeAmount"

func _on_hit_freeze_started(duration):
	
	#we displaye the training UI elements in training mod		
	if gameMode == GLOBALS.GameModeType.TRAINING:
		hitFreezeValueLabel.text = str(duration)
		#display 	
		self.visible = true
	
func _on_hit_freeze_finished():
	self.visible = false