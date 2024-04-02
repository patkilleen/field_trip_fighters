extends Control


var fillChunk = null

var fullChunk = null

var timesLabel =null

#will be set externally
var chunkSize = 20 setget setChunkSize,getChunkSize

#the amount of bar fed to opponent
var amountBarFed = 0

export (Texture) var mainProgressTexture = null
export (Texture) var underProgressTexture = null
export (Texture) var partialProgressTexture = null
export (Texture) var backgroundProgressTexture = null
export (Texture) var foregroundProgressTexture = null


func _ready():
	fillChunk = $fillingBarChunk
	fullChunk = $fullBarChunk
	timesLabel = $timesLabel

	initAbilityChunk(fillChunk)
	initAbilityChunk(fullChunk)
	
	reset()
	
	pass

func setChunkSize(s):
	chunkSize = s
	fillChunk.setMax(chunkSize)
	
	
	fullChunk.setMax(chunkSize)
	fullChunk.setAmount(chunkSize) #will awlays be full blue
	

func getChunkSize():
	return chunkSize
	
	
func initAbilityChunk(chunk):
	chunk.setMin(0)
	chunk.setMax(chunkSize)
	chunk.setAmount(chunkSize)
	chunk.setUnderBarAmount(0)
	chunk.setMiddleBarAmount(0)
	
	chunk.mainProgressTexture = mainProgressTexture
	chunk.underProgressTexture = underProgressTexture
	chunk.middleBarTexture = partialProgressTexture
	chunk.backgroundProgressTexture = backgroundProgressTexture
	chunk.foregroundProgressTexture = foregroundProgressTexture
	
func reset():
	
	amountBarFed=0
	fullChunk.visible = false
	timesLabel.visible = false
	fillChunk.setAmount(0)
	fillChunk.setMiddleBarAmount(0)

	
func displayNumberAdditionalChunks(num):
	timesLabel.text = "x" + str(num)

func inreaseBarFed(amount):
	
	amountBarFed = amountBarFed + amount
	
	#the amount of bar to display in bar that gets filled
	#var fillAmount = int(floor(amountBarFed)) % int(round(chunkSize))
	var fillAmount =fmod(amountBarFed,chunkSize)
	fillChunk.setMiddleBarAmount(fillAmount)
	
	#decide if we filled more than one chunk
	if amountBarFed >= chunkSize:
		var chunksFed = int(floor(amountBarFed/chunkSize))
		displayNumberAdditionalChunks(chunksFed)
		fullChunk.visible = true
		timesLabel.visible = true
