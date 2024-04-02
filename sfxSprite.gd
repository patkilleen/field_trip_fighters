extends Sprite

enum VisibilityCondition{#same AS globals
	NONE,
	FACING_RIGHT_ONLY,
	FACING_LEFT_ONLY	
}
export (int) var lifetimeInFrames = 60
export (int) var disapearDurationInFrames = 60
export (bool) var preventMirroring = false #true means sprite won't be affected by facing
export (VisibilityCondition)  var visibilityCondition = 0 #by default always display. When is FACING_RIGHT_ONLY or FACING_LEFT_ONLY, will only be displayed when appropriate facing met
export (bool) var overrideSpriteFrameOffset=false #true means can specify a different offset than the sprite frame's
export (Vector2) var myoffset = Vector2(0,0)
export (bool) var disableSkinModuleOverride= false
export (bool) var opponentIsParent = false #flag, when true means these sprite sfx are signal from opponent. So can place status effect sprite on opponent or where opponet is
export (bool) var disapearOnAnimationChange = true#true means any change in animation hides sprite. false means can exist in between multiple animations
export (bool) var disapearOnHitstun = true#true means when go into hitstun, disapear
export (bool) var disapearOnAnimationFinish = true#true means when go into hitstun, disapear
#export (bool) var disapearOnOpponentAnimationChange = false#true means any change in opponent animation hides sprite. false means can exist in between multiple animations
export (bool) var disapearOnOpponentHitstun = false#true means when opponent go into hitstun, disapear
#export (bool) var disapearOnOpponentAnimationFinish = false#true means when opponent go into hitstun, disapear
#export (bool) var facingParentSpriteDependent = true#true means facing of this sprite will be based on facing of the animation of parent, not the position with respect to opponent (false, means crossups will change sprite facing if cosroup happens before it appears but after its parent animation started)
export (bool) var animateScale = false #true means will animate the scale 
export (int) var scaleAnimationLifeTime=60  #duration of scale animation
export (Vector2) var targetScale = Vector2(0,0) #the ending scale of sprite
#NOTE: MAY NEED TO CHANGE 'temporarySprite.gd', DEPENDING on how the property is used. Like the command SFX use the same API

var spriteAnimationManager = null #will be set when game initiated

func _ready():
	visible = false
