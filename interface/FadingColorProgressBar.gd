extends TextureProgress


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	#value = 100
	updateColor()
	pass

func init():
	updateColor()
	
func updateColor():
	
	var median = (max_value - min_value)/2.0
	#convert desired colors to 0-1 value
	#235 and 57 obtained from googling color picker in google and scrolling in green
	#var maxGreen = range_lerp(235, 0, 100, 0, 1)
	#var minGreen =range_lerp(52, 0, 100, 0, 1)
	
	var maxGreen = 1
	var minGreen =0
	
	
	#var blue = range_lerp(52, 0, 100, 0, 1)
	var blue = 0
	
	#var maxRed = range_lerp(235, 0, 100, 0, 1)
	#var minRed =range_lerp(52, 0, 100, 0, 1)
	var maxRed = 1
	var minRed =0
	
	#now map the progress bar value to desired color
	
	var green =0
	var red = 0
	#from 100% to 50% bar green stays maxed out
	#from 49% to 0% bar green goes from max to min
	
	if value  >=  median:
		green = maxGreen
	else:
		green = range_lerp(value, min_value, median, minGreen, maxGreen)
		
	#from 0% to 49% bar red stays maxed out
	#from 50% to 100% bar red goes from max to min
	
	if value  <  median:
		red = maxRed
	else:
		red = range_lerp(value, median,max_value, maxRed, minRed)
	
	
	
	#var styleBox = $ProgressBar.get("custom_styles/fg")
	
	modulate = Color(red,green,blue)

