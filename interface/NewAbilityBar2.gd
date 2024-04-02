extends Node2D



const PLAYER1_IX = 0
const PLAYER2_IX = 1


export (float) var noBarRedBlinkDuration = 0.5
export (float) var noBarRedBlinkFrequency = 0.1

const GLOBALS  = preload("res://Globals.gd")
var numChunksNode = null
var chunkProgress = null


var costIndicatorBar = null
var mainBar = null

var chunkBar = null
var chunkCountLabel = null
var chunkCostLabel = null
var mainBarRef = null


var numberOfChunks = null
var amount = null setget setAmount,getAmount

var enableParticles = true

var chunkSize = null

var numberFilledChunks = null

var capacity = null

var consummedBarParticles = null


func _ready():
	numChunksNode = $"numChunksBgd"
	chunkProgress = $"chunk"
	chunkCountLabel = $"numChunksBgd/HBoxContainer/chunkCountLabel"
	chunkCostLabel = $"numChunksBgd/HBoxContainer2/chunkCostLabel"
	consummedBarParticles = $"numChunksBgd/abilityCancelParticles"
	
	costIndicatorBar = $"cost-indicator"
	mainBar = $mainBar
	
	#only required for editor to get visual reference of where things are
	mainBarRef = $"mainBar/main-bar-ref"
	mainBarRef.visible = false
	
	chunkCostLabel.visible = false
	
	mainBar.timer.connect("timeout",self,"_on_under_bar_time_expired")
	mainBar.blinkTimer.connect("timeout",self,"_under_bar_blink")
	
	
	mainBar.underBarDuration = noBarRedBlinkDuration
	mainBar.underBarBlinkFrequency = noBarRedBlinkFrequency
	
	
	
	chunkBar = $chunk
	

func init(playerIx,_capacity,_amount,_chunkSize):
	
	
	
	
	#make sure the bar fills appropirate direction (full is at center of screen, and empties away
	#from center depending on player)
	setFillType(playerIx,costIndicatorBar)
#	setFillType(playerIx,chunkBar)

	
	if playerIx == PLAYER1_IX:
		chunkBar.fill_mode= chunkBar.FILL_LEFT_TO_RIGHT
	elif playerIx == PLAYER2_IX:
		chunkBar.fill_mode= chunkBar.FILL_RIGHT_TO_LEFT
		
	
	setFillType(playerIx,mainBar.mainBar)
	setFillType(playerIx,mainBar.underBar)
	setFillType(playerIx,mainBar.middleBar)
	
	#save attributes
	capacity = _capacity
	amount = _amount
	chunkSize = _chunkSize
	
	
	#initialize bar sizes
	costIndicatorBar.min_value = 0
	costIndicatorBar.max_value = int(_capacity/chunkSize) #here represented in # of chunks as bar value, since will display cost (in number bar chunks)
	costIndicatorBar.value = 0
	
	
	mainBar.setMax(_capacity)
	mainBar.setMin(0)
	
	chunkBar.min_value = 0
	chunkBar.max_value = _chunkSize
	
	
	#update the ui
	setAmount(amount)
	
func setFillType(playerIx,bar):
	if playerIx == PLAYER1_IX:
		bar.fill_mode= bar.FILL_COUNTER_CLOCKWISE
	elif playerIx == PLAYER2_IX:
		bar.fill_mode= bar.FILL_CLOCKWISE
		
func setAmount(val):
	if val == null or chunkSize == null:
		return
		
	val = clamp(val,0,capacity)
	
	#emit particles for spending bar?
	if enableParticles and amount > val:
		var newParticles = consummedBarParticles.duplicate()
		newParticles.connect("finished_emitting",self,"_on_particles_finished_emitting",[newParticles])		
		newParticles.visible = true
		newParticles.emitting=true
		numChunksNode.add_child(newParticles)
		
	amount=val

	
	#update the main partial fill bar representing how much execess we got
	mainBar.setMiddleBarAmount(amount)
	
	#var numFilledChunks = int(getNumberOfFilledChunks())
	var numFilledChunks = int(GLOBALS.getNumberOfChunks(amount,chunkSize))
	
	#update the main blue bar representing how much chunks we got
	mainBar.setAmount(numFilledChunks*chunkSize)
	
	#update the textfield dislaying number of chunks we have
	chunkCountLabel.text = str(numFilledChunks)
	
	#update the partially filled chunk
	#var partialChunkFillAmount = int(round(amount)) % int(round(chunkSize))
	
	var partialChunkFillAmount = null
	
	#does the amount of bar we have get perfectly divided into a number of chunks?
	#when we reach max, the partial filled bar is maxed
	if amount ==capacity:
		partialChunkFillAmount=0
	else:
		partialChunkFillAmount = fmod(amount,chunkSize)
		
		#we basically are at exactly a filled chunk with no overlap (18.99, would mean 19 chunks, 0% fill partial)
		if GLOBALS.is_float_almost_equal(chunkSize,partialChunkFillAmount,GLOBALS.NUMBER_CHUNKS_EPSILON):
			partialChunkFillAmount=0
	chunkBar.value = partialChunkFillAmount
	
func getAmount():
	return amount
		
#func getNumberOfFilledChunks():
	
	
#	return floor(amount/chunkSize)		
	
	
func hideUnderlines():
	costIndicatorBar.value = 0
	
	#label that shows cost hide
	chunkCostLabel.visible = false

#displays a dynamically colored texture progress below the main blue bar	
func displayUnderlines(numChunksToUndeline,color):
	
	costIndicatorBar.modulate = color
	costIndicatorBar.value = numChunksToUndeline
	#label that shows cost show
	chunkCostLabel.visible = true
	chunkCostLabel.text = str(numChunksToUndeline)
	chunkCostLabel.modulate=color
#permanent set red under bar
func setUnderBarAmount(val):
			
	val = clamp(val,0,capacity)
	
	
	#var numFilledChunks = getNumberOfFilledChunks()
	var numFilledChunks = GLOBALS.getNumberOfChunks(amount,chunkSize)
	 
	#stop blinking
	mainBar._on_under_bar_time_expired()
	#display temporary red to indicate main bar doesn't have enought
	mainBar.setUnderBarAmount(val)
	


#sets the red blinking under the bar for a duration
func setUnderBarAmountWithTimeout(val):
		
	val = clamp(val,0,capacity)
	
	
	#var numFilledChunks = getNumberOfFilledChunks()
	 
	#stop blinking
	mainBar._on_under_bar_time_expired()
	#display temporary red to indicate main bar doesn't have enought
	mainBar.setUnderBarAmountWithTimeout(val)
	chunkCostLabel.visible=true
	chunkCostLabel.text = str(int(val/chunkSize))
	
#make the cost label blink when not enough bar
func _on_under_bar_time_expired():
	chunkCostLabel.visible = false
	
func _under_bar_blink():
	chunkCostLabel.visible = not chunkCostLabel.visible
	
func _on_particles_finished_emitting(newParticles):
	numChunksNode.remove_child(newParticles)
	newParticles.queue_free()