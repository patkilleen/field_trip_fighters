extends HBoxContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (int) var numberOfChunks = 5 setget setNumberOfChunks, getNumberOfChunks
export (float) var amount = 500 setget setAmount,getAmount
export (float) var xLength = 250
export (Vector2) var padding = Vector2(10,0)
export (Texture) var mainProgressTexture = null
export (Texture) var underProgressTexture = null
export (Texture) var partialProgressTexture = null
export (Texture) var backgroundProgressTexture = null
export (Texture) var foregroundProgressTexture = null
export (float) var noBarRedBlinkDuration = 0.5
export (float) var noBarRedBlinkFrequency = 0.1

var label = null
var chunkSize = null
var chunks = []
var barCostChunkUnderligns = []
var numberFilledChunks = 0

var capacity = 0
var multiTextureProgressResource = preload("res://TriTextureProgress.tscn")
var abilityBarDropParticleResource = preload("res://particles/AbilityBarDropParticle.tscn")

var chunksNode = null

var chunkDroppingParticle = []

var enableParticles = false
func _ready():
	
	chunksNode = $chunks
	#init()
		
	pass

func init():
	chunks = []
	#remove all children
	for i in chunksNode.get_children():
		chunksNode.remove_child(i)
	#var chunkScale = 0.9 / numberOfChunks
	var chunkScale = 0.9 / chunksNode.columns
	var chunkXSize = (xLength/numberOfChunks) + padding.x
	#chunkSize = int(ceil(amount / numberOfChunks))
	chunkSize = amount / numberOfChunks
	numberFilledChunks = numberOfChunks
	capacity = amount
	chunksNode.rect_min_size = Vector2(xLength,0) 
	#create all the bar chuncks multi tehxture bars
	for i in numberOfChunks:
		var chunk = multiTextureProgressResource.instance()
		chunksNode.add_child(chunk)
		chunk.rect_min_size = Vector2(chunkScale*mainProgressTexture.get_width() + padding.x,mainProgressTexture.get_height()+padding.y)
	#	chunk.rect_size =Vector2(chunkXSize,0)
		chunk.mainProgressTexture = mainProgressTexture
		chunk.underProgressTexture = underProgressTexture
		chunk.middleBarTexture = partialProgressTexture
		chunk.backgroundProgressTexture = backgroundProgressTexture
		chunk.foregroundProgressTexture = foregroundProgressTexture
		chunk.underBarDuration = noBarRedBlinkDuration
		chunk.underBarBlinkFrequency = noBarRedBlinkFrequency
		chunk.setMin(0)
		chunk.setMax(chunkSize)
		chunk.setAmount(chunkSize)
		chunk.setUnderBarAmount(0)
		chunk.setMiddleBarAmount(0)
		chunk.setScale(Vector2(chunkScale,0.5))
		
		#add particles to chunk
		var chunkParticle = abilityBarDropParticleResource.instance()
		chunk.add_child(chunkParticle)
		chunkParticle.scale = Vector2(chunkScale,0.5)
		chunkParticle.texture = mainProgressTexture
		#chunkParticle.set_emitting(false)
		#chunk.setScale(Vector2(0.1,1))
		#chunk.scale.x = chunkScale
		#chunk.scale.y = chunkScale
		chunks.append(chunk)
		chunkDroppingParticle.append(chunkParticle)
		
		var colorRect = initUnderlineColorRect(chunk)
		barCostChunkUnderligns.append(colorRect)
		
func setNumberOfChunks(n):
	numberOfChunks = n
	if chunksNode != null:
		#chunksNode.columns = n/2
		chunksNode.columns = 8
	
func getNumberOfChunks():
	return numberOfChunks

func setMaximum(m):
	amount = m
	init()
	pass


func setAmount(val):
	if val == null or chunkSize == null:
		return
	if(val < 0):
		val = 0
	elif val > capacity:
		val = capacity
	amount=val

	var numFilledChunks = getNumberOfFilledChunks()
	
	#now fill all the chunks that are filled
	for i in numFilledChunks:
		chunks[i].setAmount(chunkSize)
		#zero the partial bar
		chunks[i].setMiddleBarAmount(0)
		
	#now partially fill (if any) the next chunk
	if numFilledChunks < numberOfChunks:
		#var fillAmount = int(round(amount)) % int(round(chunkSize))
		var fillAmount = fmod(amount,chunkSize)
		
		if chunks[numFilledChunks].getAmount() > 0:
			if enableParticles:
				chunkDroppingParticle[numFilledChunks].set_emitting(true)
		#make sure no blue appears when partially filled
		chunks[numFilledChunks].setAmount(0)
		#make the yelloish bar appear when partially filled
		chunks[numFilledChunks].setMiddleBarAmount(fillAmount)
		
	
	var i = numFilledChunks+1
	
	while i <numberOfChunks:
		if chunks[i].getAmount() > 0:
			if enableParticles:
				chunkDroppingParticle[i].set_emitting(true)
		chunks[i].setAmount(0)
		chunks[i].setMiddleBarAmount(0)
		i+=1


func setUnderBarAmount(val):
	if(val < 0):
		val = 0
	elif val > capacity:
		val = capacity
	amount=val
	
	var numFilledChunks = getNumberOfFilledChunks()
	
	#now fill all the chunks that are filled
	for i in numFilledChunks:
		chunks[i].setUnderBarAmount(chunkSize)
		
	#now partially fill (if any) the next chunk
	if numFilledChunks < numberOfChunks:
		#var fillAmount = int(round(amount)) % chunkSize
		var fillAmount = fmod(amount,chunkSize)
		chunks[numFilledChunks].setUnderBarAmount(fillAmount)
	
	var i = numFilledChunks+1
	
	while i <numberOfChunks:
		chunks[i].setUnderBarAmount(0)
		i+=1


func setUnderBarAmountWithTimeout(val):
	if(val < 0):
		val = 0
	elif val > capacity:
		val = capacity
	amount=val
	
	var numFilledChunks = getNumberOfFilledChunks()
	
	#now fill all the chunks that are filled
	for i in numFilledChunks:
		chunks[i].setUnderBarAmountWithTimeout(chunkSize)
		
	#now partially fill (if any) the next chunk
	if numFilledChunks < numberOfChunks:
		#var fillAmount = int(round(amount)) % int(round(chunkSize))
		var fillAmount = fmod(amount,chunkSize)
		chunks[numFilledChunks]._on_under_bar_time_expired()
		chunks[numFilledChunks].setUnderBarAmountWithTimeout(fillAmount)
		
	
	var i = numFilledChunks+1
	
	while i <numberOfChunks:
		
		#chunks[i].setUnderBarAmountWithTimeout(0)
		chunks[i].setUnderBarAmount(0)
		chunks[i]._on_under_bar_time_expired()
		#stop all the chunks that were blinking before
		#chunks[i]._on_under_bar_time_expired()
		i+=1

#func setUnderBarAmount(amount):	
	#multiProgressBar.setUnderBarAmount(amount)
#func setUnderBarAmountWithTimeout(amount):
	#multiProgressBar.setUnderBarAmountWithTimeout(amount)
			
func getAmount():
	return amount
	
func getNumberOfFilledChunks():
	return floor(amount/chunkSize)
		
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func initUnderlineColorRect(chunk):
	var underlignColor = ColorRect.new()
	
#	
	#underlignColor.color = Color(1, 0, 0, 1)
	chunk.add_child(underlignColor)
	
	var chunkScale = 0.9 / chunksNode.columns
		
	var chunkXSize = (xLength/numberOfChunks) + padding.x
	
	underlignColor.rect_size.x = (chunk.mainProgressTexture.get_width() * chunkScale) * 0.85
	#underlignColor.rect_size.x = chunk.rect_min_size.x * chunkScale
	#underlignColor.rect_size.x  = chunkXSize
	underlignColor.rect_size.y = 8
	
	underlignColor.rect_position.y =  chunk.rect_min_size.y * chunkScale   + 17
	underlignColor.rect_position.x = (chunk.mainProgressTexture.get_width() * chunkScale) * 0.075
	
	underlignColor.visible = false
	return underlignColor
	
func hideUnderlines():
	#iterate through the underlines
	for i in barCostChunkUnderligns.size():
		var colorRect = barCostChunkUnderligns[i]
		colorRect.visible = false
		pass
		
func displayUnderlines(numChunksToUndeline,color):
	#iterate through the underlines
	for i in barCostChunkUnderligns.size():
		var colorRect = barCostChunkUnderligns[i]
		
		if i <numChunksToUndeline:
			colorRect.visible = true	
			colorRect.color = color
		else:
			colorRect.visible = false