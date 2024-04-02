extends Control

const WHEEL_ITEM_RESOURCE = preload("res://interface/new-prof-select-wheel/WheelItem.gd")
const GLOBALS = preload("res://Globals.gd")

export (float) var nextItemSpinDuration = 0.75
var center = null
var selectionPoint = null
var wheel = null
var spinTween = null


var icons = []
var selectedIconIx = -1

var spinning = false
func _ready():
	
	wheel = $wheel
	center = $wheelCenter
	selectionPoint = $selectionPoint
	
	#populate icon list
	for i in wheel.get_children():
		
		#is it a wheel icon?
		if i is WHEEL_ITEM_RESOURCE:
			icons.append(i)
	
	selectedIconIx=0
	
	spinTween = $spinTween
	spinTween.connect("finished",self,"_on_change_item_spin_wheel_finished")

func getNextItem():
	
	var ix = (selectedIconIx + 1) % icons.size()
	return icons[ix]

func getPreviousItem():
	
	var ix = selectedIconIx -1
	
	if ix < 0:
		ix = icons.size() -1 
		
	return icons[ix]


func spinWheel(spinRightFlag):
	if not spinning:
		spinning=true
		var targetAngle = getSpinWheelRightAngle(spinRightFlag)
		var ix = (selectedIconIx + 1) % icons.size()
		selectedIconIx=ix

		spinTween.start_interpolate_property(wheel,"rect_rotation",wheel.rect_rotation,targetAngle,nextItemSpinDuration)

func _on_change_item_spin_wheel_finished():
	spinning=false
func getSpinWheelRightAngle(spinRightFlag):	
	#see the https://www.mathsisfun.com/algebra/trig-solving-sss-triangles.html 
	#for angle and triangles
	var selectedIcon = icons[selectedIconIx]
	var nextIcon = getNextItem()
	var previousIcon =getPreviousItem()
	
	
	var s = null
	var n = null
	if spinRightFlag:
		
		s = previousIcon.position
	#	n = selectedIcon.position
		n = selectionPoint.position
	else:
		
		s = nextIcon.position
		#n = selectedIcon.position
		n = selectionPoint.position
		
	var w=center.position
	
	
	var a = w.distance_to(s)
	var b = s.distance_to(n)
	var c = w.distance_to(n)
	
	var nominator =a*a + c*c - b*b
	var denaminator=2.0*a*c
	var fraction = nominator/denaminator
	var radangleDelta=cosh(fraction)
	
	var angleDelta= rad2deg(radangleDelta)
	if spinRightFlag:
		return wheel.rect_rotation+angleDelta
	else:
		return wheel.rect_rotation-angleDelta
	
	
func _physics_process(delta):
	
	if  Input.is_action_just_pressed(GLOBALS.PLAYER1_INPUT_DEVICE_ID+"_RIGHT"):
		spinWheel(true)
	elif  Input.is_action_just_pressed(GLOBALS.PLAYER1_INPUT_DEVICE_ID+"_LEFT"):
		spinWheel(false)
	