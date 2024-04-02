extends "res://projectiles/ProjectileController.gd"


func _on_land():
	actionAnimationManager.playUserAction(actionAnimationManager.STICK_ACTION_ID,facingRight,command)
	

func _on_wall_collision():
	actionAnimationManager.playUserAction(actionAnimationManager.STICK_ACTION_ID,facingRight,command)
	pass
