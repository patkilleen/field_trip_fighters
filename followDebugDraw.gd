extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const GLOBALS = preload("res://Globals.gd")
var debugsrc = null
var debugdst = null
var debugfollowMvm = null

#var drawingDestination = true
func _ready():
	if GLOBALS.DEBUGGING_FOLLOW_MVM:
		set_physics_process(true)
	else:
		set_physics_process(false)
	pass # Replace with function body.

func init(player1,player2):
	player1.playerController.connect("debug_follow_mvm_started",self,"_on_debug_follow_mvm_started",[player1])
	player2.playerController.connect("debug_follow_mvm_started",self,"_on_debug_follow_mvm_started",[player2])
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	update()
#	pass
func _draw():

	if debugfollowMvm == null or debugdst == null or debugsrc== null:
		return
		
		
	#done?
	#if debugfollowMvm != null and not debugfollowMvm.isActive():
	#	debugfollowMvm=null
	#	debugdst=null
	#	debugsrc= null
	#	return
	#draw the srouce	
	draw_circle(debugsrc.global_position,5,Color(0,1,0,1))
	
	#if drawingDestination:

	

	if debugfollowMvm.destinationUpdate == debugfollowMvm.DestinationUpdate.STATIC:
			
		draw_circle(debugfollowMvm.dstInitialPosition+debugfollowMvm.offset,5,Color(0,0,1,1))
		
		#draw radius around destination
		draw_circle(debugfollowMvm.dstInitialPosition+debugfollowMvm.offset,debugfollowMvm.epsilon,Color(1,0,0,0.3))
	else:
					#draw the destination
		draw_circle(debugdst.global_position+debugfollowMvm.offset,5,Color(0,0,1,1))
		
		#draw radius around destination
		draw_circle(debugdst.global_position+debugfollowMvm.offset,debugfollowMvm.epsilon,Color(1,0,0,0.3))
			
	##
		#only print destiantion once?	
	#	if debugfollowMvm.destinationUpdate == debugfollowMvm.DestinationUpdate.STATIC:
	#		drawingDestination=false
	#destinationUpdate
	#DestinationUpdate
	#STATIC

func _on_debug_follow_mvm_started(_debugsrc,_debugdst,_debugfollowMvm,player):
#	drawingDestination = true
	debugsrc = _debugsrc
	debugdst = _debugdst 
	debugfollowMvm = _debugfollowMvm