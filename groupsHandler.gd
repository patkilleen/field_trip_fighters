extends Node

#this node is responsible for detecting when there is a new node that get's added to groups and
#respond accordingly. Since groups lack signals, this will make up for it.

var GLOBALS = preload("res://Globals.gd")
var oldGlobalSpeedGroup = []
var oldFixedDeltaRateNodes = []


var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	set_physics_process(true)
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	
	pass

func setGlobalSpeedMod(m):
	globalSpeedMod = m
	

	
	
#makes sure any node joining the group has their global speed mod ajusted
#there may exist a off-by-one frame bug here, where for the 1st frame
#the physics process of new node in the groups is called before this physics process
#is called, so for 1 frame, the speed will be off
#but so far, it looks good, falcon's f-tool works
func checkGlobalSpeedModGroup():
	#get current nodes in the group
	var globalSpeedNodes = get_tree().get_nodes_in_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	
	var equalFlag = true
	
	if globalSpeedNodes.size() ==oldGlobalSpeedGroup.size():
	
		#the same as last time
		for i in globalSpeedNodes.size():
			var n1 = globalSpeedNodes[i]
			var n2 = oldGlobalSpeedGroup[i]
			
			if n1 != n2:
				equalFlag=false
				break
	else:
		equalFlag= false
		
	if not equalFlag:
		#make sure all the nodes have up to date global speed
		for n in globalSpeedNodes:
			n.setGlobalSpeedMod(globalSpeedMod)
		oldGlobalSpeedGroup=globalSpeedNodes
		
		
	#now for the fixed delta rate 
	#var fixedDeltaRateNodes = get_tree().get_nodes_in_group(GLOBALS.GLOBAL_FORCE_FIXED_DELTA_GROUP)
	
	#equalFlag = true
	
#	if fixedDeltaRateNodes.size() ==oldFixedDeltaRateNodes.size():
	
		#the same as last time
#		for i in fixedDeltaRateNodes.size():
#			var n1 = fixedDeltaRateNodes[i]
#			var n2 = oldFixedDeltaRateNodes[i]
			
#			if n1 != n2:
#				equalFlag=false
#				break
#	else:
#		equalFlag= false
		
#	if not equalFlag:
		#make sure all the nodes have up to date global speed
#		for n in fixedDeltaRateNodes:

#		oldFixedDeltaRateNodes=fixedDeltaRateNodes
	
func _physics_process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	
	#so the below line of code bugs out the game and crashes. This
	#was source of hat up tool head butt busting game when against the wall
	#(replicate via HAT b-melee + forward dash + b-special + f-dash + up tool: version 0.48.15, when
	#opponent hugs wall upward instead of bouncing and up tool connects, uncommenting below will freeze game)
	#
	#i had worried about this logic.
	#i think we can aford to allow groups to be 1 frame behind when a node joins the group for
	#the speed mod
	#nvm
	#checkGlobalSpeedModGroup()
	
	
	pass