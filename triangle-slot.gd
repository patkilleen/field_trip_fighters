extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

enum Mode{
	EMPTY,
	FOCUS_SUCCESS,
	DMG_SUCCESS,
	FAILURE	
}

export (Mode) var mode = 0 setget setMode,getMode
export (Texture) var buttonTexture = null
var xRect = null
var dmgCheckMarkRect = null
var focusCheckMarkRect = null
var underline = null
var buttonRect = null
var playerCmdRect = null
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	xRect = $x
	underline = $underline
	dmgCheckMarkRect = $"dmg-checkmark"
	dmgCheckMarkRect.visible = false
	focusCheckMarkRect = $"focus-checkmark"
	focusCheckMarkRect.visible = false
	xRect.visible=false
	buttonRect = $button
	buttonRect.texture = self.buttonTexture
	playerCmdRect = $playerCommand
	pass

func select():
	underline.visible = true
	
func unselect():
	underline.visible = false
	
	
func setPlayerCommand(cmd):
	playerCmdRect.command = cmd
	
func setMode(m):
	mode = m
	
	match(m):
		Mode.EMPTY:
			if dmgCheckMarkRect != null:
				dmgCheckMarkRect.visible = false
			if focusCheckMarkRect != null:
				focusCheckMarkRect.visible = false
			if xRect != null:
				xRect.visible = false
		Mode.DMG_SUCCESS:
			if dmgCheckMarkRect != null:
				dmgCheckMarkRect.visible = true
			if focusCheckMarkRect != null:
				focusCheckMarkRect.visible = false
			if xRect != null:
				xRect.visible = false
		Mode.FOCUS_SUCCESS:
			if dmgCheckMarkRect != null:
				dmgCheckMarkRect.visible = false
			if focusCheckMarkRect != null:
				focusCheckMarkRect.visible = true
			if xRect != null:
				xRect.visible = false
		Mode.FAILURE:
			if dmgCheckMarkRect != null:
				dmgCheckMarkRect.visible = false
			if focusCheckMarkRect != null:
				focusCheckMarkRect.visible = false
			if xRect != null:
				xRect.visible = true
			
func getMode():
	return mode
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
