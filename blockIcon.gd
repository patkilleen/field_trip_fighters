extends NinePatchRect

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (bool) var enabled = true setget setEnabled,getEnabled
var offCooldownIcon = null
var onCooldownIcon = null

var cooldownAnimation = null
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	offCooldownIcon = $offCooldownIcon
	onCooldownIcon = $onCooldownIcon
	
	cooldownAnimation = $cooldownAnimation
	pass

func startCooldownAnimation(_enabled,duration):
	setEnabled(_enabled)
	
	#went onto cooldown?
	if not _enabled:
		cooldownAnimation.activate(duration)
		
	else:#back off cooldown before time ellapsed?
		cooldownAnimation.deactivate()
		
func setEnabled(b):
	enabled = b
	
	if enabled:
		if offCooldownIcon != null:
			offCooldownIcon.visible = true
		if onCooldownIcon != null:
			onCooldownIcon.visible = false
	else:
		if offCooldownIcon != null:
			offCooldownIcon.visible = false
		if onCooldownIcon != null:
			onCooldownIcon.visible = true
			
func getEnabled():
	return enabled
	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
