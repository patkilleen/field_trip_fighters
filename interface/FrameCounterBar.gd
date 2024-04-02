extends Node2D

var GLOBALS = preload("res://Globals.gd")
#var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

const frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")
var frameTimer = null

var active = false
#var ellapsedTime = 0
var targetTime =0

var textureProgress = null
var frameCountLabel=null
var relativeFrameCountLabel=null

var defaultModulate = null

#var globalSpeedMod = 1
const GREEN_FONT_COLOR = Color(0,1,0)
const RED_FONT_COLOR = Color(1,0,0)
const WHITE_FONT_COLOR = Color(0,0,0)


# Called when the node enters the scene tree for the first time.
func _ready():
	
	#add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	#make sure this node is part of group that gets notification
	#on global speed mod change
	#add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)

	#globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD
	defaultModulate = self.modulate
	
	frameCountLabel= $frameCountLabel
	relativeFrameCountLabel=$relativeFrameCountLabel
	textureProgress = $TextureProgress
	
	frameTimer =frameTimerResource.new()	
	add_child(frameTimer)
	frameTimer.connect("timeout",self,"_on_timeout")
	
	reset()



	
func activate(numberFrames,inHitFreezeFlag):
	visible=true
	#remove 1, since takes one frame to activate and have a move collide, so a frame 0 dp happens on frame 1, not frame 
	#it's activated, for examplt
	#numberFrames = numberFrames -1 
	if numberFrames <= 0:
		return
	modulate = defaultModulate
	active = true
	
	frameTimer.start(numberFrames)
	
	#already in hitfreze? pause the timer that we just started
	#if inHitFreezeFlag:
	#	frameTimer.handleHitFreezeStarted()
		
	#only start processing when not in hitfreeze
	#if not inHitFreezeFlag:
		#set_physics_process(true)
		
	set_physics_process(true)
	
	#ellapsedTime = 0
	targetTime =numberFrames*GLOBALS.SECONDS_PER_FRAME
	
	
	textureProgress.max_value=targetTime#*100
	textureProgress.value=targetTime#*100
	frameCountLabel.text = str(stepify(numberFrames,0.1))
	pass
	
func reset():
	visible=false
	modulate.a = 0.7
	active = false 
	
	
	if frameTimer != null:
		frameTimer.stop()
	set_physics_process(false)
	textureProgress.value=0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	if not active:
		reset()
		return
		
	#delta = delta *globalSpeedMod
	#ellapsedTime = ellapsedTime+delta
	
	var ellapsedTime=frameTimer.ellapsedTimeInSeconds
	
	#var numFramesEllapsed = int(round(ellapsedTime/GLOBALS.SECONDS_PER_FRAME))
	#textureProgress.value=textureProgress.max_value-numFramesEllapsed
	textureProgress.value=textureProgress.max_value-(ellapsedTime)#*100)
	
	#if ellapsedTime >= targetTime:
	#if GLOBALS.frame_duration_almost_equal(ellapsedTime,targetTime) or ellapsedTime >= targetTime:
	#if GLOBALS.has_frame_based_duration_ellapsed(ellapsedTime,targetTime):
	#	reset()
	
	


#func setGlobalSpeedMod(g):
#	globalSpeedMod = g
	
	
#func _on_hit_freeze_finished():
	
#	if active:
#		set_physics_process(true)

	
# warning-ignore:unused_argument
#func _on_hit_freeze_started(duration):
#	if active:
#		set_physics_process(false)
		
		

	

	
func _on_timeout():
	reset()
	
func setRelativeFrameData(frameStr):
	
	
	relativeFrameCountLabel.text=frameStr
	
	var frameNum= int(frameStr)
	
	#we set the color of relative frames based on + or -
	if frameNum > 0:
		relativeFrameCountLabel.set("custom_colors/font_color",GREEN_FONT_COLOR)
	elif frameNum < 0:
		relativeFrameCountLabel.set("custom_colors/font_color",RED_FONT_COLOR)
	else:
		relativeFrameCountLabel.set("custom_colors/font_color",WHITE_FONT_COLOR)
