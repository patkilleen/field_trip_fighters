extends Control

#var heroScenePathArray = ["res://fighters/ken.tscn","res://fighters/marth.tscn","res://fighters/glove.tscn","res://fighters/falcon.tscn","res://fighters/samus.tscn"]
var heroGroundIdleResourceArray = [preload("res://fighters/main-menu-idle-animations/mic-rap.tscn"),preload("res://fighters/main-menu-idle-animations/mic-opera.tscn"),preload("res://fighters/main-menu-idle-animations/glove.tscn"),preload("res://fighters/main-menu-idle-animations/belt.tscn"),preload("res://fighters/main-menu-idle-animations/hat.tscn"),preload("res://fighters/main-menu-idle-animations/whistle.tscn")]
var scaleArray = [0.32,0.32,0.32,0.42,0.32,0.32] #scale of sprite
var animationSpeedArray = [1,1,1,1,1,1] #scale of sprite
var modulateList = [Color(1,1,1),Color(1,1,1),Color(1,1,1),Color(1,1,1),Color(1,1,1),Color(1,1,1)]
var GLOBALS = preload("res://Globals.gd")
var heroGroundIdleInstance = null
var textureRect = null
var idleSpriteFrame = []
var spriteFrameEllapsedTimeInSeconds = 0
var currSpriteFrameIx = 0
var animationSpeed = null

var heroGroundIdleSceneIx =-1

func _ready():
	textureRect = $TextureRect
	
	
	var rng = RandomNumberGenerator.new()
	
	#genreate time-based seed
	rng.randomize()
	
	#choose hero randomly to display
	heroGroundIdleSceneIx = rng.randi_range(0,heroGroundIdleResourceArray.size()-1)
	var heroGroundIdleResource = heroGroundIdleResourceArray[heroGroundIdleSceneIx]
	#var Sprscale = spriteScale[heroGroundIdleSceneIx]
	heroGroundIdleInstance = heroGroundIdleResource.instance()
	var scale = scaleArray[heroGroundIdleSceneIx]
	#var spriteAniamtionManager = heroInstance.get_node("PlayerController/ActionAnimationManager/SpriteAnimationManager/SpriteAnimations")
	#var actionAniamtionManager = heroInstance.get_node("PlayerController/ActionAnimationManager")
	#var groundIdleIx = actionAniamtionManager.GROUND_IDLE_SPRITE_ANIME_ID
	#var groundIdleSpriteAnimation = spriteAniamtionManager.get_child(groundIdleIx)
	var spriteModulate = modulateList[heroGroundIdleSceneIx]
	
	#animationSpeed= groundIdleSpriteAnimation.speed
	animationSpeed= animationSpeedArray[heroGroundIdleSceneIx]
	#fetch all the sprite frames of ground idle
	for c in heroGroundIdleInstance.get_children():
		if c is preload("res://AlphaSpriteFrame.gd"):
			idleSpriteFrame.append(c)
	
	var sf = idleSpriteFrame[currSpriteFrameIx]
	#change texture displayed on screen
	textureRect.texture = sf.texture 
	textureRect.self_modulate = spriteModulate
	textureRect.scale = textureRect.scale*scale
	set_process(true)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	#track time sprite frame ellasped
	spriteFrameEllapsedTimeInSeconds = spriteFrameEllapsedTimeInSeconds + (delta*animationSpeed)
	var scale = scaleArray[heroGroundIdleSceneIx]
	#current sprite frame
	var sf = idleSpriteFrame[currSpriteFrameIx]
	
	var frameDurationInSeconds = GLOBALS.SECONDS_PER_FRAME * sf.duration
	
	
	#the sprite frame duration has ellapsed?	
	if spriteFrameEllapsedTimeInSeconds  > frameDurationInSeconds:
		#frame transition
		spriteFrameEllapsedTimeInSeconds=0
		currSpriteFrameIx = (currSpriteFrameIx + 1) % idleSpriteFrame.size()
		#next frame
		sf = idleSpriteFrame[currSpriteFrameIx]
		
		var nonAlphaSpriteFlag = sf is preload("res://SpriteFrame.gd")
		
		#change texture displayed on screen
		textureRect.texture = sf.texture 
	
		#for glove, sprite already offseted	
		#if not nonAlphaSpriteFlag:
			
		textureRect.offset =  sf.sprite_Offset
#	pass


	