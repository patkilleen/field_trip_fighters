extends Control

signal back

const GLOBALS = preload("res://Globals.gd")
var inputDeviceIds = []
func _ready():
	inputDeviceIds.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDeviceIds.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	pass

func connectToMenuButtons(target,function):
	var options = $MarginContainer/HBoxContainer/LeftPane/MenuOptions.menuOptions
	
	for op in options:
		op.connect("confirmation",target,function)
		
func _physics_process(delta):
	for deviceId in inputDeviceIds:

		if Input.is_action_just_pressed(deviceId+"_B"):
			emit_signal("back")
			return
				
	