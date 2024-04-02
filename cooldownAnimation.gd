extends Node2D


export (float) var shieldCooldownRadius = 30
export (Color) var color = Color(0.0, 0.0, 1.0,0.6)
var GLOBALS = preload("res://Globals.gd")

const frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")
var frameTimer = null
var duration = 0
#var ellapsedTime = 0


var countDownLabel = null
func _ready():

	self.visible = false
	countDownLabel = $countDownLabel
	update()
	frameTimer =frameTimerResource.new()	
	add_child(frameTimer)
	frameTimer.connect("timeout",self,"_on_cooldown_timeout")
	set_physics_process(false)
	pass

func activate(_duration):
	frameTimer.startInSeconds(_duration)
	duration = _duration
	#ellapsedTime = 0
	countDownLabel.text = str(int(ceil(duration)))
	self.visible = true
	set_physics_process(true)
	
func deactivate():
	frameTimer.stop()
	duration = 0
	#ellapsedTime = 0
	self.visible = false
	set_physics_process(false)
	
#this function should draw a circly based on amount of time remaining for cooldonw of shield
#so its a full circle when block used, its half circle when 2 seconds (assuming 4 s cooldown)
#and it goes clockwise to 12 o clock until disapear and block icon comes back up
func _draw():
	
	#avoid division by 0
	if duration == 0:
		return 
	var center = Vector2(0,0)
	var ellapsedTime =frameTimer.ellapsedTimeInSeconds
	var completionPercent = ellapsedTime/duration
	var angle_from = 0
	var angle_to = completionPercent * 360
	#var color = Color(0.0, 0.0, 1.0,0.6)
	draw_circle_arc_poly(center, shieldCooldownRadius, angle_from, angle_to, color)
	
	
func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
    var nb_points = 16
    var points_arc = PoolVector2Array()
    points_arc.push_back(center)
    var colors = PoolColorArray([color])

    for i in range(nb_points + 1):
        var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
        points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
    draw_polygon(points_arc, colors)


func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS

#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.

#	ellapsedTime += delta
	#don't go over the duration
#	ellapsedTime = min(duration,ellapsedTime)
	
	update()
	
	var ellapsedTime =frameTimer.ellapsedTimeInSeconds
	#update the countdown label
	var secondsRemaining = duration - int(ellapsedTime)
	
	countDownLabel.text = str(int(ceil(secondsRemaining)))
	
	#if ellapsedTime >= duration:
	#	deactivate()
	pass


func _on_cooldown_timeout():
	deactivate()