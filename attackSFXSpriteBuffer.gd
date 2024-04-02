extends Node2D

export (PackedScene) var scene=null
export (int) var queueSize=16

var index = 0

func _ready():
	
	#the type of scene to make many instances of is not defined?
	
	for _i in range(queueSize):

		add_child(scene.instance())

func get_next_scene_instance():
	var res=get_child(index)
	index = (index+1)%queueSize
	return res
