extends HBoxContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var blockEffBar =null
export var xBarLength = 25

func _ready():
	blockEffBar = $AbilityBar
	pass

#initiates the bars
func init(defaultBE,maxBE, minBE):
	
	#since ability bar share red and blue,
	#the red bars represent negative block efficiency
	#theb blue bar represents positive block efficiency
	#then the ability bar UI for BE needs to be large
	#enough to accomondate largest BE (max ablosute value of 
	#maxBE and min BE)
	
	var numBarChunks = max(abs(maxBE),abs(minBE))
	
	#error checking
	if(numBarChunks <= 0):
		print("error initializing block efficiency UI, non-positive number of bar chunks")
	
	
	#initialize the ability bar chunk ui
	blockEffBar.numberOfChunks=numBarChunks
	blockEffBar.xLength = xBarLength
	blockEffBar.init()
	updateBlockEfficiency(0)#empty the bars first
	updateBlockEfficiency(defaultBE)

#will update the UI to represent new be
func updateBlockEfficiency(be):
	
	#compute the amount of bar required to fill 'be' number of chunks
	# (absolute value since negative BE is represented in positive
	# nubmer of bar chunks#
	

	if be < 0: #negative block efficiency?
		var amountFillBar = blockEffBar.chunkSize * abs(be)
		blockEffBar.setUnderBarAmount(amountFillBar)
		blockEffBar.setAmount(0)
	else: #positive block efficiency (>=0)
		var amountFillBar = blockEffBar.chunkSize * (abs(be)+1)
		blockEffBar.setAmount(amountFillBar+1)
		blockEffBar.setUnderBarAmount(0)
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
