extends NinePatchRect

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (bool) var enabled = false setget setEnabled,getEnabled

var filledDmgStar = null
var filledFocusStar = null
var basicStar = null
var unfilledStar = null
var particles = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	filledDmgStar = $filledDamageStar
	filledFocusStar = $filledFocusStar
	unfilledStar = $unfillledStar
	basicStar = $basicStar
	particles = $Particles2D
	pass

func enableDamageStar():
	enabled = true
	if filledDmgStar !=null:
		filledDmgStar.visible = true
	if filledFocusStar !=null:
		filledFocusStar.visible = false
	if unfilledStar != null:
		unfilledStar.visible = false
	if particles != null:
		particles.emitting = true
	if basicStar != null:
		basicStar.visible = false
func enableFocusStar():
	enabled = true
	if filledDmgStar !=null:
		filledDmgStar.visible = false
	if filledFocusStar !=null:
		filledFocusStar.visible = true
	if unfilledStar != null:
		unfilledStar.visible = false
	if particles != null:
		particles.emitting = true
	if basicStar != null:
		basicStar.visible = false
func disable():
	enabled = false
	if filledDmgStar !=null:
		filledDmgStar.visible = false
	if filledFocusStar !=null:
		filledFocusStar.visible = false
	if unfilledStar != null:
		unfilledStar.visible = true
	if particles != null:
		particles.emitting = false
	if basicStar != null:
		basicStar.visible = false
func setEnabled(b):
	enabled=b
	if enabled:
		if filledDmgStar !=null:
			filledDmgStar.visible = true
		if unfilledStar != null:
			unfilledStar.visible = false
		if filledFocusStar !=null:
			filledFocusStar.visible = false
		if particles != null:
			particles.emitting = true
			
		if basicStar != null:
			basicStar.visible = true
	else:
		if filledDmgStar !=null:
			filledDmgStar.visible = false
		if unfilledStar != null:
			unfilledStar.visible = true
		if particles != null:
			particles.emitting = false
			
		if basicStar != null:
			basicStar.visible = false
func getEnabled():
	return enabled
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
