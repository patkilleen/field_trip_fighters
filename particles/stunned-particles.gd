extends Node2D

var animePlayer = null
func _ready():
	animePlayer = $AnimationPlayer
	animePlayer.play("bird-spin")
