extends Control

var displayTimer = null
var notifyLableResource =preload("res://interface/notificationLabel.tscn")

const NUMBER_BUFFERED_LABELS=16
#var uiText = null
var listNode = null
var facingRight = false
func _ready():
	
	listNode = $VBoxContainer
	
	#pre-instance all the labels
	for i in range(NUMBER_BUFFERED_LABELS):
		
		var cachedLabel =notifyLableResource.instance()
		cachedLabel.connect("hidden",self,"_on_label_hidden")
	
		if facingRight:
			cachedLabel.align=cachedLabel.ALIGN_LEFT
		else:
			cachedLabel.align=cachedLabel.ALIGN_RIGHT
			
		listNode.add_child(cachedLabel)
		

	pass
	
func applyFacing(_facingRight):
	facingRight=_facingRight
	
	#apply text alignment to labels
	for c in listNode.get_children():
		if facingRight:
			c.align=c.ALIGN_LEFT
		else:
			c.align=c.ALIGN_RIGHT
			
	pass
	
	#if facingRight:
	#	pass
	#else:
	#	uiText.rect_rotation =  -1 *uiText.rect_rotation
func display(text, duration):
	
	
	#only make the visibility expire for positive duration values.
	# non-positive makes indefinate notifactions
	if duration > 0:
		
		
		var cachedLabel = findCachedLabel()
		
		if cachedLabel == null:
			print("warning, too many notifications. Can't display notifiaction...")
			return
			
		cachedLabel.init(text,duration)
		
		#displayTimer.wait_time = duration
		#displayTimer.start()
	else:
		print("warning, trying to dispaly ("+text+") indefinitly")
	
#returns a hidden label (if such a label exsits) that will soon disapear
#that is found in list
func findCachedLabel():
	for c in listNode.get_children():
		if c.text == "":
			return c
			
	
	#no label is avialbe (either none exist or their all visible)
	return null

func _on_label_hidden(label):

	var visibleLabelExists = false
	#check to see if all labels have been removed or are not visible anymore
	for c in listNode.get_children():
		if c.active:
			visibleLabelExists=true
			break
		
	#no labels are visible or exist?
	if not visibleLabelExists:
		clear()

	#want to make sure visible label's aren't moved around as the lists adds are removes chilren
	
func clear():
	for c in listNode.get_children():
		c.delete()