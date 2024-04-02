extends CanvasLayer

export (Color) var fadeOutColor = Color(1,1,1,1)

export (float) var spinVelocity = 180
var colorRect = null
var tween = null
var spinningIcon

const GLOBALS = preload("res://Globals.gd")
var fighter1ProfHUD = null
var fighter2ProfHUD = null

const MyTweenResource = preload("res://MyTween.gd")
#var fighter1HUD = null
#var fighter2HUD = null
var info = null

const stageFriendlyNameMap = {"res://stages/art-museum.tscn":"Art Museum",
"res://stages/farm.tscn":"Farm",
"res://stages/haunted-mansion.tscn":"Haunted Mansion",
"res://stages/kayaking.tscn":"Kayaking",
"res://stages/mountain-climbing.tscn":"Mountain Climbing",
"res://stages/observatory.tscn":"Observatory",
"res://stages/radio-tower.tscn": "Radio Tower",
"res://stages/snow-carnaval.tscn" : "Snow Carnaval",
"res://stages/bridge.tscn" : "Bridge",
"res://stages/theater.tscn": "Theater"}

const stageBackgroundMap = {"res://stages/art-museum.tscn":"res://stages/loading-screen-bgds/art-museum.tscn",
"res://stages/radio-tower.tscn":"res://stages/loading-screen-bgds/radio-tower.tscn",
"res://stages/bridge.tscn":"res://stages/loading-screen-bgds/bridge.tscn",
"res://stages/kayaking.tscn": "res://stages/loading-screen-bgds/kayaking.tscn",
"res://stages/haunted-mansion.tscn": "res://stages/loading-screen-bgds/haunted-house.tscn",
"res://stages/farm.tscn":"res://stages/loading-screen-bgds/farm.tscn",
"res://stages/mountain-climbing.tscn":"res://stages/loading-screen-bgds/mountain-climbing.tscn",
"res://stages/observatory.tscn": "res://stages/loading-screen-bgds/observatory.tscn",
"res://stages/snow-carnaval.tscn": "res://stages/loading-screen-bgds/snow-carnaval.tscn",
"res://stages/theater.tscn": "res://stages/loading-screen-bgds/theater.tscn"}


var stageBackgroundNode= null
var stageNameLabel = null
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	spinningIcon = $Control/icon
	stageNameLabel = $Control/stageName
	
	stageBackgroundNode = $Control/stageBgdContainer
	
	fighter1ProfHUD = $"Control/info/fighter1-info/ProficiencySelectionHUD"
	fighter2ProfHUD = $"Control/info/fighter2-info/ProficiencySelectionHUD"
	
	#fighter1HUD = $"Control/info/fighter1-info"
	#fighter2HUD = $"Control/info/fighter2-info"
	#make sure it spins from center, not top left corner
	#spinningIcon.rect_pivot_offset = spinningIcon.rect_size/2
	#spinningIcon.offset = spinningIcon.get_texture().get_size()/2
	
	colorRect = $ColorRect
	colorRect.color = fadeOutColor
	
	#tween = $Control/Tween
	tween = MyTweenResource.new()
	add_child(tween)
	
	info = $Control/info
	#info.visible = false
	
	setVisibile(false)
	$Control.visible = false
	self.set_physics_process(false)
	pass
	
#func init(fighter1Texture, fighter1Name, player1Name, fighter1AdvProf, fighter1DisProf, fighter2Texture, fighter2Name, player2Name,fighter2AdvProf,fighter2DisProf):
func init(fighter1Texture, fighter1Name, player1Name, 
	p1Prof1MajorClassIxSelect,p1Prof1MinorClassIxSelect,
	p1Prof2MajorClassIxSelect,p1Prof2MinorClassIxSelect,
	fighter2Texture, fighter2Name, player2Name,
	p2Prof1MajorClassIxSelect,p2Prof1MinorClassIxSelect,
	p2Prof2MajorClassIxSelect,p2Prof2MinorClassIxSelect,stageScenePath):
	
	
	
	#copy over the stage-specific loadingscreen background elements
	addStageBackgroundElements(stageScenePath)
	
	#set the stage name on loading screen
	var stageFriendlyName = findStageFriendlyName(stageScenePath)
	setStageName(stageFriendlyName)
	
	#fighter1ProfHUD.displayProficiencies(fighter1AdvProf,fighter1DisProf)
	#fighter2ProfHUD.displayProficiencies(fighter2AdvProf,fighter2DisProf)
	fighter1ProfHUD.displayProficiencies(p1Prof1MajorClassIxSelect,p1Prof1MinorClassIxSelect,
										p1Prof2MajorClassIxSelect,p1Prof2MinorClassIxSelect)
	fighter2ProfHUD.displayProficiencies(p2Prof1MajorClassIxSelect,p2Prof1MinorClassIxSelect,
										p2Prof2MajorClassIxSelect,p2Prof2MinorClassIxSelect)
	
	#fighter1HUD.init(fighter1AdvProf,fighter1DisProf)
	#fighter2HUD.init(fighter2AdvProf,fighter2DisProf)
	
	$"Control/info/fighter1-info/textureRect".texture = fighter1Texture
	$"Control/info/fighter2-info/textureRect".texture = fighter2Texture
	
	#inlcude the name in loading screen if it was specified
	if player1Name != null:
		$"Control/info/fighter1-info/name".text = player1Name+ " ("+fighter1Name+")"
	else:
		
		if fighter1Name != null:
			$"Control/info/fighter1-info/name".text = fighter1Name			
	
	if player2Name != null:
		$"Control/info/fighter2-info/name".text = player2Name+ " ("+fighter2Name+")"
	else:
		
		if fighter2Name != null:
			$"Control/info/fighter2-info/name".text = fighter2Name
		
	#setVisibile(true)
	$Control.visible = true
	colorRect.visible = true

func setStageName(_name):
	if _name != null:
		stageNameLabel.text=_name
		

func setVisibile(b):
	$Control.visible = b
	spinningIcon.visible = b
	colorRect.visible = b
	info.visible = b
func fadeOut(duration):
	colorRect.visible = true
	
	
	tween.start_interpolate_property(colorRect,"color",fadeOutColor,Color(0,0,0,0),duration)
	#tween.interpolate_property(colorRect,"color",Color(0,0,0,0),fadeOutColor,duration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	#tween.start()
	
	#wait for the screen to fade to balck
	#yield(tween,"tween_completed")
	yield(tween,"finished")
	
	
	#make the icon appear and spin
	#tween.stop(colorRect)
	
	info.visible = true
	spinningIcon.visible = true
	self.set_physics_process(true)
	

func disapear(duration):	
	
	#hide icon 
	spinningIcon.visible = false
	info.visible = false
	$Control.visible = false
	setVisibile(false)
	#tween.interpolate_property(colorRect,"color",fadeOutColor,Color(0,0,0,0),duration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	#tween.start()
	tween.start_interpolate_property(colorRect,"color",fadeOutColor,Color(0,0,0,0),duration)
	
	#wait for the black screen to fade away
	#yield(tween,"tween_completed")
	yield(tween,"finished")
	#tween.stop(colorRect)
	colorRect.visible = false
	
func _physics_process(delta):	
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	#spinningIcon.rect_rotation += spinVelocity * delta
	spinningIcon.rotation_degrees += spinVelocity * delta



func addStageBackgroundElements(stageScenePath):
	
	if stageScenePath == null or not stageBackgroundMap.has(stageScenePath) :
		return
		
	
	#copy over the stage-specific loadingscreen background elements	
	var stageBdgScenePath = stageBackgroundMap[stageScenePath]
	
	
	#remove old stage elements
	for c in stageBackgroundNode.get_children():
		stageBackgroundNode.remove_child(c)
		c.queue_free()
		
	
	var stageBgd = load(stageBdgScenePath).instance()
	stageBackgroundNode.add_child(stageBgd)
	
func findStageFriendlyName(stageResourcePath):
	if stageResourcePath == null or not stageFriendlyNameMap.has(stageResourcePath):
		return "Unknown stage"
	return stageFriendlyNameMap[stageResourcePath]
	