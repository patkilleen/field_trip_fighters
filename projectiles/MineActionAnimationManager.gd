extends "res://projectiles/ProjectileActionAnimationManager.gd"

const STICK_MVM_ANIME_ID = 3

const STICK_ACTION_ID = 3
func _ready():
	
	animationLookup[SPRITE_ANIME_IX][STICK_ACTION_ID]=null # don't change aniatiion
	animationLookup[MVM_ANIME_IX][STICK_ACTION_ID]=STICK_MVM_ANIME_ID
	
	pass # Replace with function body.


