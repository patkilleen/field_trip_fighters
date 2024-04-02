extends Node2D

var countLabel = null
func _ready():
	
	visible = false
	countLabel = $Label
	pass # Replace with function body.


func _on_negative_level_changed(new,old):
	#first 2 levels don't count, cause there are
	#many false positives, but when 
	#you reach level 2, your clearly camping
	if new <=1:
		visible = false	
	else:
		visible = true
		countLabel.text = str(new-1) #-1 since treat level 2 as the first negative level