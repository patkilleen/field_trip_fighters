extends Label

signal confirmation #param: menu text, menu item argument

var animationPlayer = null
#button argument that is passed to caller

var argument = null

var selectedFlag = false

export (int) var defaultFontSize = 35

export (Vector2) var pencilOffset = Vector2(303,28)

var pencilSprite =null
func _ready():
	animationPlayer = $AnimationPlayer
	get("custom_fonts/font").size = defaultFontSize
	pencilSprite = $pencil
	
	pencilSprite.visible = false
	pencilSprite.position = pencilOffset
	pass

func select():
	
	if not selectedFlag:
		animationPlayer.play("selected")
		selectedFlag = true
		pencilSprite.visible = true
	
func unselect():
	
	if selectedFlag:
		animationPlayer.play("unselected")
		selectedFlag=false
		pencilSprite.visible = false
	
func confirm(inputDeviceId):
	animationPlayer.play("confirmed")
	
	#wait a sec, let the button response be visible (1 second)
#	yield(get_tree().create_timer(0.3),"timeout")
	
	emit_signal("confirmation", self.text, argument,inputDeviceId)
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
