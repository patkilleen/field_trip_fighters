extends "res://complexMovement.gd"

export (NodePath) var followMvmPath = null

var followMvmNode = null

var readyToStartFlag=false
# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	if has_node(followMvmPath):
		followMvmNode = get_node(followMvmPath)
	
		followMvmNode.connect("arrived",self,"_on_follow_mvm_arrived")
		followMvmNode.connect("start_following",self,"_on_follow_mvm_start_following")	
		#just to make sure the animation doesn't get stalled out
		followMvmNode.connect("stopped",self,"_on_follow_mvm_stopped")	


func readyToStart(timeEllapsed):
	

	return readyToStartFlag
	pass
	
func _on_follow_mvm_stopped(followMvm):
	readyToStartFlag=true

func _on_follow_mvm_start_following(src,dst,followMvm):
	readyToStartFlag=false
	
func _on_follow_mvm_arrived(src,dst,followMvm):
	readyToStartFlag=true
	
	
#func _on_basic_movement_stopped(bm):
#	._on_basic_movement_stopped(bm)
	
	#not longer ready to start when all our basic movements finished
#	if not active:
#		readyToStartFlag=false