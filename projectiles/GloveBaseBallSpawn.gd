extends "res://projectiles/ProjectileSpawn.gd"

func _ready():
	pass
	
func readyHook():
	projectileScene=preload("res://projectiles/glove-baseball.tscn")
	
	loadSpawnPoint()

