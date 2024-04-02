extends TextureRect

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var p1Label = null
var p2Label = null
export (String) var fighterSceneName = ""

export (Texture) var fighterIcon = null

var GLOBALS = preload("res://Globals.gd")

var labelMap = {}
func _ready():
	p1Label = $"p1-selecting"
	p2Label = $"p2-selecting"
	labelMap[GLOBALS.PLAYER1_INPUT_DEVICE_ID]=p1Label 
	labelMap[GLOBALS.PLAYER2_INPUT_DEVICE_ID]=p2Label
func unselect(player):
	labelMap[player].visible = false
func select(player):
	labelMap[player].visible = true

