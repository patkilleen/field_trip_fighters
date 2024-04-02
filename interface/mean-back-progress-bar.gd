extends Node2D



const GLOBALS  = preload("res://Globals.gd")



var mainBar = null


var mainBarRef = null


var amount = null setget setAmount,getAmount

var capacity = null


func _ready():
	
	
	
	
	
	
	
	mainBar = $mainBar
	
	#only required for editor to get visual reference of where things are
	mainBarRef = $"mainBar/main-bar-ref"
	mainBarRef.visible = false
	
	
	

func init(_capacity,_amount,step):
	
	
	
	
	#make sure the bar fills appropirate direction (full is at center of screen, and empties away
	#from center depending on player)
	
#	setFillType(playerIx,chunkBar)

	
	mainBar.mainBar.fill_mode= mainBar.mainBar.FILL_CLOCKWISE
	
	#save attributes
	capacity = _capacity
	amount = _amount
	
	
	#initialize bar sizes
	
	
	mainBar.setMax(_capacity)
	mainBar.mainBar.step=step
	mainBar.setMin(0)
	
	
	#update the ui
	setAmount(amount)

func setAmount(val):
	if val == null:
		return
		
	val = clamp(val,0,capacity)
	
		
	amount=val

	
	
	#update the main blue bar representing how much chunks we got
	mainBar.setAmount(val)
	
	
	
func getAmount():
	return amount
		
#func getNumberOfFilledChunks():
	
	
#	return floor(amount/chunkSize)		
	
	