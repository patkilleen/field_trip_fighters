extends Node

const GLOBALS = preload("res://Globals.gd")
const inputManager = preload("res://input_manager.gd")


enum Direction{
	RIGHT,
	DOWN,
	LEFT,
	UP,
	NEUTRAL	
}


export (Texture) var diMeleeTexture=null
export (Texture) var diSpecialTexture=null
export (Texture) var diToolTexture=null

export (Texture) var nMeleeTexture=null
export (Texture) var nSpecialTexture=null
export (Texture) var nToolTexture=null

export (Color) var meleeModulate = Color(1,1,1,1)
export (Color) var specialModulate = Color(1,1,1,1)
export (Color) var toolModulate = Color(1,1,1,1)

export (Color) var diMeleeModulate = Color(1,1,1,1)
export (Color) var diSpecialModulate = Color(1,1,1,1)
export (Color) var diToolModulate = Color(1,1,1,1)

export (float) var marginLeft = 0
export (float) var marginRight = 0
export (float) var marginTop = 0
export (float) var marginBottom = 0

export (Vector2) var diHSpriteScale=Vector2(1,1)
export (Vector2) var diVSpriteScale=Vector2(1,1)
export (Vector2) var nSpriteScale=Vector2(1,1)
var diTextures = []
var nTextures = []

var diTextureHeights = []

var stage = null 
var camera=null
var boundingBox = null
#lots of code copied from newAttackSFX.gd btw, bad design but ok for now

var diTmpSprite = null
var nTmpSprite = null
export (int) var diSFXLifetimeInFrames = 5
export (int) var diSFXDisapearDurationInFrames = 15
export (int) var neutralSFXLifetimeInFrames = 5
export (int) var neutralSFXDisapearDurationInFrames = 15

var modulates = []
var diModulates = []
var diSprites = []
var nSprites= []
# Called when the node enters the scene tree for the first time.
func _ready():
	
	diTextures.append(null)
	diTextures.append(null)
	diTextures.append(null)
	
	nTextures.append(null)
	nTextures.append(null)
	nTextures.append(null)
	
	modulates.append(null)
	modulates.append(null)
	modulates.append(null)
	
	diModulates.append(null)
	diModulates.append(null)
	diModulates.append(null)	
	
	
	diTextures[GLOBALS.MELEE_IX]=diMeleeTexture
	diTextures[GLOBALS.SPECIAL_IX]=diSpecialTexture
	diTextures[GLOBALS.TOOL_IX]=diToolTexture
	
	nTextures[GLOBALS.MELEE_IX]=nMeleeTexture
	nTextures[GLOBALS.SPECIAL_IX]=nSpecialTexture
	nTextures[GLOBALS.TOOL_IX]=nToolTexture
	
	modulates[GLOBALS.MELEE_IX]=meleeModulate
	modulates[GLOBALS.SPECIAL_IX]=specialModulate
	modulates[GLOBALS.TOOL_IX]=toolModulate
	
	diModulates[GLOBALS.MELEE_IX]=diMeleeModulate
	diModulates[GLOBALS.SPECIAL_IX]=diSpecialModulate
	diModulates[GLOBALS.TOOL_IX]=diToolModulate
	
	diTmpSprite = $largeDIHitTempSprite
	nTmpSprite = $largeNeutralHitTempSprite
	
	diSprites.append(diTmpSprite)
	nSprites.append(nTmpSprite)
	
	#populate height of diTextures
	for texture in diTextures:
		
		diTextureHeights.append(texture.get_height())

func init(_stage,_camera,_boundingBox):
	stage = _stage
	camera = _camera
	boundingBox = _boundingBox
func get_view_port_rect():

	
	#get the camera dimensions
	var cameraCenter = camera.computeScreenCenter()
	
	
	var minPos = camera.computeMinimumPointBoundary()
	var maxPos = camera.computeMaximumPointBoundary()
	
	
	#var yLimitTop = max(minPos.y,boundingBox.getFalseBoxTopPosition()) # max since want tthe one nearest to play (if false ceiling outside view, use camera screen boundary instead)

#no false floor, so the bottom position is the screen view at bottom
	#var yLimitBot = maxPos.y
	#var xLimitRight = min(maxPos.x,boundingBox.getFalseBoxRightPosition()) #nearest right boundary (in corner, false walls outside screent)
	#var xLimitLeft = max(minPos.x,boundingBox.getFalseBoxLeftPosition()) #nearest left boundary (in corner, false walls outside screent)
	 
	var yLimitTop = minPos.y

#no false floor, so the bottom position is the screen view at bottom
	var yLimitBot = maxPos.y
	var xLimitRight = maxPos.x
	var xLimitLeft = minPos.x
	
	
	#since falsoe walls are a thign, emit the beam starting from fasles walls/celing
	
#	var xLimitLeft = 
	return Rect2(xLimitLeft,yLimitTop,xLimitRight-xLimitLeft,yLimitBot-yLimitTop)
	
func displayAttackHitSfx(cmd,attackTypeIx,spriteFacingRight,_collisionPosition,inHitFreeze):
	
	if attackTypeIx < 0 or attackTypeIx >= diTextures.size():
		return
		
	
	#attacktypeIx:
	
#const MELEE_IX = 0
#const SPECIAL_IX = 1
#const TOOL_IX = 2
#const OTHER_IX = 3
#const CLASH_IX = 4

	
	
	var direction = parseDirection(cmd,spriteFacingRight)
	var viewPortRect = null
	
	#only need to copmute rectangle of screen for DI attacks
	if direction != Direction.NEUTRAL :
		viewPortRect = get_view_port_rect()
	else:
		
		nTmpSprite.modulate = modulates[attackTypeIx]
		nTmpSprite.lifetimeInFrames =neutralSFXLifetimeInFrames 
		nTmpSprite.disapearDurationInFrames =neutralSFXDisapearDurationInFrames 

		nTmpSprite.position=_collisionPosition
		
		nTmpSprite.texture = nTextures[attackTypeIx]
		
		

		nTmpSprite.scale = nSpriteScale
		#vector 00 is cause were playign with global position, no need reference, and true since always display right facing 
		#always face right, since don't want ot move away the sprite offset (it would mirror the x position)
		#we displaye the neutral attack spx in the stage 
		stage.spriteSFXNode.displayGlobalTemporarySprites(nSprites,inHitFreeze,Vector2(0,0),true)
		return 
		
		
	#the texture depends on attack tyep
	diTmpSprite.texture =diTextures[attackTypeIx]
	diTmpSprite.lifetimeInFrames =diSFXLifetimeInFrames 
	diTmpSprite.disapearDurationInFrames =diSFXDisapearDurationInFrames 
	diTmpSprite.modulate = diModulates[attackTypeIx]
	
	var textureHeigh =diTextureHeights[attackTypeIx]*diTmpSprite.scale.y
	
	if direction == Direction.LEFT :
		
		diTmpSprite.scale = diHSpriteScale

		#back attack (the beam emmits from LEFT of screen)
	#	if spriteFacingRight:
			
			
		diTmpSprite.position.y =_collisionPosition.y - textureHeigh/2.0
		diTmpSprite.position.x = viewPortRect.position.x + marginRight
		
		diTmpSprite.position = get_viewport().get_canvas_transform() *  diTmpSprite.position
		#diTmpSprite.position = stage.uiLayerSpriteSFXNode.get_canvas_transform() *  diTmpSprite.position
		diTmpSprite.rotation_degrees=0
	#	else:
			#back attack (the beam emmits from RIGHT of screen)
	#		diTmpSprite.position.y =_collisionPosition.y + textureHeigh/2.0
	#		diTmpSprite.position.x = viewPortRect.end.x + marginRight
	#		diTmpSprite.rotation_degrees=180
		
	elif direction == Direction.UP:
		#up attack (the beam emmits from CELING)
		diTmpSprite.scale =diVSpriteScale
		diTmpSprite.position.y =viewPortRect.position.y + marginTop
		diTmpSprite.position.x = _collisionPosition.x + textureHeigh/2.0
		diTmpSprite.position = get_viewport().get_canvas_transform() *  diTmpSprite.position
		#diTmpSprite.position = stage.uiLayerSpriteSFXNode.get_canvas_transform() *  diTmpSprite.position
		diTmpSprite.rotation_degrees=90

	elif direction == Direction.RIGHT:
		#forward attack, beam emmits from LEFT of screen
	#	if spriteFacingRight:
		diTmpSprite.scale = diHSpriteScale
		diTmpSprite.position.y =_collisionPosition.y + textureHeigh/2.0
		diTmpSprite.position.x = viewPortRect.end.x +  marginLeft
		diTmpSprite.position =get_viewport().get_canvas_transform()*  diTmpSprite.position
		#diTmpSprite.position = stage.uiLayerSpriteSFXNode.get_canvas_transform() *  diTmpSprite.position
		diTmpSprite.rotation_degrees=180
	#	else:
			#forward attack, beam emmits from RIGHT of screen
	#		diTmpSprite.position.y =_collisionPosition.y - textureHeigh/2.0
	#		diTmpSprite.position.x = viewPortRect.position.x +  marginLeft
	#		diTmpSprite.rotation_degrees=0	
		
			
		
	elif direction == Direction.DOWN:
		diTmpSprite.scale =diVSpriteScale
	#down attack (the beam emmits from FLOOR)
		diTmpSprite.position.y =viewPortRect.end.y + + marginBottom
		diTmpSprite.position.x = _collisionPosition.x - textureHeigh/2.0
		diTmpSprite.position = get_viewport().get_canvas_transform() *  diTmpSprite.position
		#diTmpSprite.position = stage.uiLayerSpriteSFXNode.get_canvas_transform() *  diTmpSprite.position
		diTmpSprite.rotation_degrees=270
			
	else:
		return

	#vector 00 is cause were playign with global position, no need reference, and true since always display right facing 
	#the falg spriteFacingRight was only used to determine position
	#we sdiaplye the sfx on THE UI layer
	stage.uiLayerSpriteSFXNode.displayGlobalTemporarySprites(diSprites,inHitFreeze,Vector2(0,0),true)
	
	
	
	#TEST
	
func parseDirection(cmd,spriteFacingRight):
	
	
	
	var dir = null
	match(cmd):
		inputManager.Command.CMD_NEUTRAL_MELEE:

			dir = Direction.NEUTRAL

		inputManager.Command.CMD_DOWNWARD_MELEE:
			dir = Direction.DOWN

		inputManager.Command.CMD_UPWARD_MELEE:
			
			dir = Direction.UP
			
		inputManager.Command.CMD_FORWARD_MELEE:
			
			dir = Direction.RIGHT
			
		inputManager.Command.CMD_BACKWARD_MELEE:
			
			dir =Direction.LEFT	
			
		inputManager.Command.CMD_NEUTRAL_SPECIAL:
			
			dir = Direction.NEUTRAL
			
		inputManager.Command.CMD_DOWNWARD_SPECIAL:
			
			dir = Direction.DOWN
			
		inputManager.Command.CMD_UPWARD_SPECIAL:
			
			dir = Direction.UP
			
		inputManager.Command.CMD_FORWARD_SPECIAL:
			
			dir = Direction.RIGHT
			
		inputManager.Command.CMD_BACKWARD_SPECIAL:

			dir = Direction.LEFT

		inputManager.Command.CMD_NEUTRAL_TOOL:
			
			dir = Direction.NEUTRAL
			
		inputManager.Command.CMD_DOWNWARD_TOOL:
			
			dir = Direction.DOWN
			
		inputManager.Command.CMD_UPWARD_TOOL:
		
			dir = Direction.UP
		
		inputManager.Command.CMD_FORWARD_TOOL:
			
			dir = Direction.RIGHT
			
		inputManager.Command.CMD_BACKWARD_TOOL:
			
			dir = Direction.LEFT	
		
	#have to mirror the direction?
	if not spriteFacingRight:
		if dir ==Direction.LEFT:
			dir =Direction.RIGHT
		elif dir ==Direction.RIGHT:
			dir =Direction.LEFT
		
	
	return dir



