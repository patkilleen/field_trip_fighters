extends Control

export (int) var overFlowLabelFontSize = 15
export (int) var starOverflowSize = 5
export (Texture) var startTexture = null

var numberOfStars = 0 setget setNumberOfStars,getNumberOfStars


var starsNode = null
var overFlowStarsNode = null
var starCountLabel = null
var overFlowStarTextureRect = null

func _ready():
	starsNode = $stars
	overFlowStarsNode = $"overflow-stars"
	starCountLabel = $"overflow-stars/StarCountLabel"
	overFlowStarTextureRect = $"overflow-stars/StarTextureRect"
	
	#fill the star node with max number of stars before overflow
	for i in starOverflowSize:
		var starTextureRect = TextureRect.new()
		starTextureRect.texture = startTexture
		
		starsNode.add_child(starTextureRect)
		
	overFlowStarTextureRect.texture = startTexture
	#apply desired font size of to overflow label
	var font = starCountLabel.get("custom_fonts/font")
	font.size = overFlowLabelFontSize
	
	#default # of stars is 0
	setNumberOfStars(0)

func setStarTexture(texture):
	
	startTexture = texture
	
	#put texture on the star array
	for c in starsNode.get_children():
		c.texture = startTexture	
	
	overFlowStarTextureRect.texture = startTexture
	
func setNumberOfStars(value):
	numberOfStars = value
	
	#too many starts? ie, overflow?
	if numberOfStars >starOverflowSize:
		
		#display the over flow ui
		starsNode.visible = false
		overFlowStarsNode.visible = true
		
		updateOverFlowLabel()
	else:
		#no overflow, diplsya the array of stars
		starsNode.visible = true
		overFlowStarsNode.visible = false
		updateStarArray()
		

		
func getNumberOfStars():
	return numberOfStars


#will update the label to match number of stars
func updateOverFlowLabel():
	
	var labelString = "x"+str(numberOfStars)
	starCountLabel.text = labelString
	
#will display correct number of stars in array
func updateStarArray():
	
	#iterate all the stars to make them invisible
	#by default, and only make the first 'numberOfStars'
	#stars visible
	for i in starsNode.get_child_count():
		var star = starsNode.get_child(i)
		
		#less than, since 0 stras means non are visible, while the 1st star has index 0
		if i < numberOfStars:
			star.visible = true
		else:
			star.visible = false
	