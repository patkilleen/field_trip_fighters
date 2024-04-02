extends Node2D



const PLAYER1_IX = 0
const PLAYER2_IX = 1

export (float) var redConsummedBarDuration=2
export (float) var noBarRedBlinkDuration = 0.5
export (float) var noBarRedBlinkFrequency = 0.1

export (float) var usedBarRedkDuration = 1

export (Texture) var gainBarTexture = null
export (float) var gainDisplayDuration =1.5 #seconds the gain will display after state changed
const GLOBALS  = preload("res://Globals.gd")

#const frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")

var numChunksNode = null
var chunkProgress = null

var numChunksNodePositions = []
var chunkProgressPositions = []

var costIndicatorBar = null
var mainBar = null
var gainBar = null

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

#var consummedBarParticles = null

#var gainDisplayTimer =null
enum State{
	DISPLAY_STANDRAD_BAR,
	DISPLAY_BAR_GAIN	
}

var state = State.DISPLAY_STANDRAD_BAR

var particleBuffer = null
func _ready():
	numChunksNode = $"numChunksBgd"
	chunkProgress = $"chunk"
	chunkCountLabel = $"numChunksBgd/HBoxContainer/chunkCountLabel"
	chunkCostLabel = $"numChunksBgd/HBoxContainer2/chunkCostLabel"
	#consummedBarParticles = $"numChunksBgd/abilityCancelParticles"
	particleBuffer = $"numChunksBgd/particleBuffer"
	costIndicatorBar = $"cost-indicator"
	mainBar = $mainBar
	gainBar = $gainBar
	
	gainBar.visible = false
	#gainDisplayTimer = frameTimerResource.new()
	
	#add_child(gainDisplayTimer)
	
	#gainDisplayTimer.connect("timeout",self,"_on_gain_display_timeout")
	gainBar.connect("bar_animation_finished",self,"_on_gain_display_timeout")
	
	#only required for editor to get visual reference of where things are
	mainBarRef = $"mainBar/main-bar-ref"
	mainBarRef.visible = false
	
	chunkCostLabel.visible = false
	
	mainBar.timer.connect("timeout",self,"_on_under_bar_time_expired")
	mainBar.blinkTimer.connect("timeout",self,"_under_bar_blink")
	
	
	#store position of where elements will be depending on player (left vs right for p1 and p2 resp.)
	numChunksNodePositions.append($numChunckPlayer1Position)
	numChunksNodePositions.append($numChunckPlayer2Position)
	
	chunkProgressPositions.append($chunckPlayer1Position)
	chunkProgressPositions.append($chunckPlayer2Position)
	
	mainBar.underBarDuration = noBarRedBlinkDuration
	mainBar.underBarBlinkFrequency = noBarRedBlinkFrequency
	
	
	
	chunkBar = $chunk
	

func init(playerIx,_capacity,_amount,_chunkSize):
	var chunkProgressPos =chunkProgressPositions[playerIx].position
	chunkProgress.rect_position=chunkProgressPos
	
	var numChunkNodePos =numChunksNodePositions[playerIx].position
	numChunksNode.position=numChunkNodePos
	
	
	
	#make sure the bar fills appropirate direction (full is at center of screen, and empties away
	#from center depending on player)
	setFillType(playerIx,costIndicatorBar)
	setFillType(playerIx,chunkBar)
	setFillType(playerIx,mainBar.mainBar)
	setFillType(playerIx,mainBar.underBar)
	setFillType(playerIx,mainBar.middleBar)
	setFillType(playerIx,gainBar.mainBar)
	setFillType(playerIx,gainBar.underBar)
	setFillType(playerIx,gainBar.middleBar)
	
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
	gainBar.setMax(_capacity)
	gainBar.setMin(0)
	
	chunkBar.min_value = 0
	chunkBar.max_value = _chunkSize
	
	
	#update the ui
	setAmount(amount)
	
	
func setFillType(playerIx,bar):
	if playerIx == PLAYER1_IX:
		bar.fill_mode= bar.FILL_RIGHT_TO_LEFT
	elif playerIx == PLAYER2_IX:
		bar.fill_mode= bar.FILL_LEFT_TO_RIGHT
		
		
func setAmount(val):
	if val == null or chunkSize == null:
		return
		
	val = clamp(val,0,capacity)
	
	#emit particles for spending bar?
	if enableParticles and amount > val:
		particleBuffer.trigger()
		#var newParticles = consummedBarParticles.duplicate()
		#newParticles.connect("finished_emitting",self,"_on_particles_finished_emitting",[newParticles])		
		#newParticles.visible = true
		#newParticles.emitting=true
		#numChunksNode.add_child(newParticles)
		
		
	#if we ever spend bar, then we stop displaying the bar gain
	if amount > val:
		_on_gain_display_timeout()
	#else:
		#we gained bar, so remove the red
		#mainBar._on_under_bar_time_expired()
	amount=val

	
	#update the main partial fill bar representing how much execess we got
	mainBar.setMiddleBarAmount(amount)

	#make sure the color-ed bar indicating gain is always up to date with current amount
	gainBar.setUnderBarAmount(amount)
	
	#var numFilledChunks = int(getNumberOfFilledChunks())
	var numFilledChunks = int(GLOBALS.getNumberOfChunks(amount,chunkSize))
	
	#update the main blue bar representing how much chunks we got
	mainBar.setAmount(numFilledChunks*chunkSize)
	#gainBar.setMiddleBarAmount(numFilledChunks*chunkSize)
	#update the textfield dislaying number of chunks we have
	chunkCountLabel.text = str(int(numFilledChunks))
	
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
	
	var chunkCost = int(GLOBALS.getNumberOfChunks(val,chunkSize))
	chunkCostLabel.text = str(chunkCost)


func displayRedBarConsummed(newAbilityBarAmt,oldAbilityBarAmt):
	oldAbilityBarAmt = clamp(oldAbilityBarAmt,0,capacity)
		
	#display temporary red to indicate main bar doesn't have enought
	mainBar.setUnderBarAmountWithTimeoutNoBlink(oldAbilityBarAmt,redConsummedBarDuration)
	
	#wait for red bar to be ready to disapear
	yield(mainBar.timer,"timeout")
	
	#wait for the 
	mainBar.animateBar(mainBar.underBar,oldAbilityBarAmt,newAbilityBarAmt,0.75)
		
#make the cost label blink when not enough bar
func _on_under_bar_time_expired():
	chunkCostLabel.visible = false
	
func _under_bar_blink():
	chunkCostLabel.visible = not chunkCostLabel.visible
	
#func _on_particles_finished_emitting(newParticles):
#	numChunksNode.remove_child(newParticles)
#	newParticles.queue_free()
	
func _on_gain_display_timeout():
		
	
	#yield(gainBar,"bar_animation_finished")
	
	gainBar.visible =false
	mainBar.visible =true
	state = State.DISPLAY_STANDRAD_BAR
	#gainDisplayTimer.set_physics_process(false)
	gainBar.stopBarAnimation()
	
	
func _on_start_tracking_ability_gain():
	gainBar.visible =true
	mainBar.visible =false
	state = State.DISPLAY_BAR_GAIN 
	
	#the blue bar should appear to stay static where it was as ability gain occurs
	gainBar.setAmount(mainBar.getAmount())
	gainBar.setUnderBarAmount(0) #make sure no gain-colored bar is displayed for now, since didn't gain any ability yet
	gainBar.setMiddleBarAmount(0) #make sure no gain-colored bar is displayed for now, since didn't gain any ability yet
	
	#gainDisplayTimer.set_physics_process(false)
	gainBar.stopBarAnimation()
	
func _on_stop_tracking_ability_gain():
	
	#Wait a sec before making the gain disapear
	#gainDisplayTimer.startInSeconds(gainDisplayDuration)
	#wait for the animation to end
	gainBar.animateBar(gainBar.mainBar,gainBar.mainBar.value,gainBar.underBar.value,gainDisplayDuration)
	