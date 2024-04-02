extends "res://SpriteAnimation.gd"

#LEGACY CODE. just set the 'onPlayHitFlagEnabled' to true
func play(_cmd,_facingRight,on_hit_starting_sprite_frame_ix=0):
	.play(_cmd,_facingRight,on_hit_starting_sprite_frame_ix)
	#on hit sprite animation were triggered from a hit
	#hittingWithJumpCancelableHitbox = true
	setHittingWithJumpCancelableHitbox(true)
	
