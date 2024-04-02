extends Node

signal ripost_command_inputed

var leakyVariableResource = preload("res://leakyVariable.gd")

#directional input last 5 frames
var leakyDI = null
#button input last 5 frames
var leakyBtn = null

var input_manager= null
# Called when the node enters the scene tree for the first time.
func _ready():
	
	#instance 2 leaky variables to store directional input and buttons
	leakyDI = leakyVariableResource.new()
	leakyBtn = leakyVariableResource.new()
	
	self.add_child(leakyDI)
	self.add_child(leakyBtn)
	

#initialize this object with handle to inputmanager for command access
#and provide the duration of input window
func init(_input_manager, leakyWindowInFrames):
	input_manager = _input_manager
	leakyDI.init(leakyWindowInFrames)
	leakyBtn.init(leakyWindowInFrames)
	
#called when right bumper (or whatever the input mapping is) pressed
#that represents trying to ripost
func _on_ripost_input():
	
	#when previous buttons pressed right before ripost input,
	#consider it a command of ripost
	if leakyBtn != null:
		
		var ripostCmd = null
		if leakyDI !=null:
			#directional input processed as well for ripost		
		else:
			#no directional input ripost
		
		emit_signal("ripost_command_inputed",ripostCmd)
		return	
		
	#no buttons 

	
	


