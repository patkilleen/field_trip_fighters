extends Node2D

var GLOBALS = preload("res://Globals.gd")
export (Texture) var correctBlockAuraTexture = null
export (Texture) var badBlockAuraTexture = null
export (Texture) var correctBlockRingTexture = null
export (Texture) var badBlockRingTexture = null
export (Texture) var perfecttBlockRingTexture = null
export (Texture) var perfectAuraTexture = null

var ringSprite = null
var auraSprite = null
var animePlayer = null

#ignores hitfreeze when true, played immediatly. When false, wait till hitfreeze to start
#var playImmediatly = false

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	
	ringSprite = $ring
	auraSprite = $aura
	animePlayer = $AnimationPlayer
	animePlayer.connect("animation_finished",self,"_on_animation_finished")
	self.visible = false

func playAnimation(blockResult, facingRight):
	
	if blockResult == GLOBALS.BlockResult.CORRECT:
		ringSprite.texture=correctBlockRingTexture
		auraSprite.texture =correctBlockAuraTexture
	elif blockResult == GLOBALS.BlockResult.INCORRECT:
		ringSprite.texture=badBlockRingTexture
		auraSprite.texture =badBlockAuraTexture
	elif blockResult == GLOBALS.BlockResult.PERFECT:
		ringSprite.texture=perfecttBlockRingTexture
		auraSprite.texture =perfectAuraTexture
	else:
		#dont' play aniation
		return
		
	self.visible = true	
	if not facingRight:
		self.scale.x = abs(self.scale.x) * -1
	else:
		self.scale.x = abs(self.scale.x)
		
	#make sure to play the animation and then emmideatly pause it, as it's played after hitfreeze
	#started and will continue upon hitfreeze finish
	animePlayer.play("main")
	var reset = false #don't reset animation, pause it
	animePlayer.stop(reset)
	
func _on_animation_finished(animation):
	visible = false
	pass
	#get_parent().remove_child(self)
	#self.call_deferred("queue_free")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_hit_freeze_finished():
	if visible:
		#if not playImmediatly:
		animePlayer.play("main")
	
	
	
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	#if not playImmediatly:
	#var reset = false #don't reset animation, pause it
	#animePlayer.stop(reset)
	
	#sfx addded to scene after hitfreeze started but before end so do nothign
	pass
	