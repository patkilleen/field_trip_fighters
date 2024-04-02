extends Node2D

signal bus_arrived
signal bus_entered_area

const UP_ROUTE_IX =0
const RIGHT_ROUTE_IX =1
const DOWN_ROUTE_IX =2
const LEFT_ROUTE_IX =3

const MAX_NUMBER_ROUTES = 4

export (String) var id = null
export (Texture) var texture = null
export (String) var stage_scene_path = null
export (int,1,5) var stage_size = 3
var routes = []

var navigationArrowsNode = null

#var animatedObjects = []
func _ready():
	
	var area2D = $Area2D
		#add the routes
	for i in MAX_NUMBER_ROUTES:
		routes.append(null)
		
	navigationArrowsNode = $"navigationArrows"
	navigationArrowsNode.visible = false
	area2D.connect("area_entered",self,"_on_area_entered")
	
	
	
	#add the routes
	for route in get_children():
		if route is preload("res://route.gd"):
			var ix = route.routeType
			routes[ix] = route
			route.pathFollow2D.connect("arrived",self,"_on_bus_arrived")
		elif route is preload("res://interface/stage/animatedObjects.gd"):
			#animatedObjects.append(route)
			area2D.connect("area_entered",route,"_on_bus_arrived")
			area2D.connect("area_exited",route,"_on_departure")
			
			

func getRoute(ix):
	if ix < 0 or ix >= routes.size():
		return null
	return routes[ix]	
	
	
#map selection deals with calling this
#func _on_departure(_route):
#	#make sure all animated objects aware bus left
#	for c in animatedObjects:
#		c._on_departure(_route)
	
	pass
func _on_bus_arrived(route):
	#make sure all animated objects aware bus arrive
#	for c in animatedObjects:
#		c._on_bus_arrived(route)
		
	emit_signal("bus_arrived",route)

func _on_area_entered(area):
	navigationArrowsNode.visible = true
	emit_signal("bus_entered_area",self)