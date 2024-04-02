extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (float) var progressRadius = 30
export (Color) var color = Color(1,0,0)
var pro = 0

var intialDmgAmount = 0 #when we activate
var currDmgAmount = 0
var targetDmgAmount = 0 #capacity
func _ready():
	
	self.visible = false
	#update()
	pass

	
func activate(amount,capacity):
	#self.visible = true
	intialDmgAmount=amount
	currDmgAmount=amount
	targetDmgAmount=capacity
	#update()
	
	
#updates the circle progress, and resturns true when done (false otherwise)
func _on_dmg_amount_changed(newAmount):
	currDmgAmount = newAmount
	
	if abs(newAmount - targetDmgAmount) <= 0.0001:
		
		self.visible = false	
		return true
#	else:
#		update()	
	
	return false
#this function should draw a circly based on amount of time remaining for cooldonw of shield
#so its a full circle when block used, its half circle when 2 seconds (assuming 4 s cooldown)
#and it goes clockwise to 12 o clock until disapear and block icon comes back up
func _draw():
	
	var center = Vector2(0,0)
	
	var divider = targetDmgAmount-intialDmgAmount
	#  avoid division by 0
	if divider == 0:
		return
	var completionPercent = (currDmgAmount-intialDmgAmount)/(divider)
	
	
	var angle_from = 0
	var angle_to = completionPercent * 360
	draw_circle_arc_poly(center, progressRadius, angle_from, angle_to, color)
	
	
func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
    var nb_points = 16
    var points_arc = PoolVector2Array()
    points_arc.push_back(center)
    var colors = PoolColorArray([color])

    for i in range(nb_points + 1):
        var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
        points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
    draw_polygon(points_arc, colors)
	
