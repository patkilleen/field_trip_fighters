extends "res://AlphaSpriteFrame.gd"



func _ready():
	#adjusts the positions of collision boxes to be positioned relative to sprite offset and bodybox offset
	#override the alpha. Now the body box and sprites
	#will have their position shifted all at once equal to sprite offset
	#for c in collisionShapes:		
	#	c.position = c.position - sprite_Offset
	
	
	pass
	
func init(sprite,collisionAreas,bodyBox,activeNodes,playerController):
	.init(sprite,collisionAreas,bodyBox,activeNodes,playerController)
	for c in collisionShapes:		
		c.position = c.position - sprite_Offset-playerController.kinbody.alphaSpriteFrameYOffset#shift by default bodybox offeset
	for s in tmpLocalSFXSprites:
		s.position = s.position - sprite_Offset-playerController.kinbody.alphaSpriteFrameYOffset#shift by default bodybox offeset				
	for s in tmpGlobalSFXSprites:
		s.position = s.position - sprite_Offset-playerController.kinbody.alphaSpriteFrameYOffset#shift by default bodybox offeset						
		
	for hb in hitboxes:
		hb.adjustOnHitSFXSpriteOffsets((-1*sprite_Offset)-playerController.kinbody.alphaSpriteFrameYOffset)#shift by default bodybox offeset						
	for hb in selfonly_hitboxes:
		hb.adjustOnHitSFXSpriteOffsets((-1*sprite_Offset)-playerController.kinbody.alphaSpriteFrameYOffset)#shift by default bodybox offeset						
func changeActiveNodesRelativePosition():
	
	var playerController = spriteAnimation.playerController
	var kinbody = playerController.kinbody
	
	applyRelativeBodyBoxPosition()
	targetSprite.position = sprite_Offset-kinbody.alphaSpriteFrameYOffset#shift by default bodybox offeset
	spriteAnimationManager.kinbody.spriteSFXNode.position = sprite_Offset-kinbody.alphaSpriteFrameYOffset#duno if this is necesarry
	