extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (int) var area2D_Default_Buffer_Size = 8

var area2DBuffer = []

var numAreasUsed = 0
func _ready():
	
	#fill area buffer with areas to be used each new sprite frame 
	for i in area2D_Default_Buffer_Size:
		var area = Area2D.new()
		area2DBuffer.append(area)
		self.add_child(area)
		area.monitoring=false
		area.monitorable=false
		
	pass

func activateSpriteFrame(frame):
	for area in frame.area2ds:
		activateArea(area)

func deactivateSpriteFrame(frame):
	for area in frame.area2ds:
		deactivateArea(area)
		
func activateArea(containerNode):
	
	if numAreasUsed >= area2D_Default_Buffer_Size:
		print("error, more area2ds in sprite frame than buffer can hold")
		return
	
	var addedScript = containerNode.get_script()
	var collisionShapes = containerNode.get_children()
	
	var activatedArea = area2DBuffer[numAreasUsed]
	activatedArea.monitorable=true
	activatedArea.monitoring=true
	#add the script to area
	activatedArea.set_script(addedScript)
	
	#add collision shapes to area and activate them
	for shape in collisionShapes:
		if not shape is CollisionShape2D:
			continue
		shape.disabled = false
		#var oldPosition = shape.position
		containerNode.remove_child(shape)
		activatedArea.add_child(shape)
		#shape.
		shape.set_owner(activatedArea)
		
	numAreasUsed+=1
func deactivateArea(containerNode):
	
	if numAreasUsed <=0:
		print("error, cannot deactivate area, there aren't any active")
		return
	var deactivatedArea = area2DBuffer[numAreasUsed]
	deactivatedArea.monitorable=false
	deactivatedArea.monitoring=false
	#add the script to area
	deactivatedArea.set_script(null)
	#add collision shapes to area and disable them
	for shape in deactivatedArea.get_children():
		
		if not deactivatedArea.is_a_parent_of(shape):
			return 
		deactivatedArea.remove_child(shape)
		containerNode.add_child(shape)
		shape.disabled = true
		shape.set_owner(containerNode)
		
	numAreasUsed-=1
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
