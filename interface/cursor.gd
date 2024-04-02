extends Sprite

export (float) var speed = 1
export (bool) var horizontal = true
var animationPlayer=null
var movingSprite = null
func _ready():
	animationPlayer = $AnimationPlayer
	
	if horizontal:
		animationPlayer.play("horizontal")
	else:
		animationPlayer.play("vertical")
	animationPlayer.playback_speed = speed
	
