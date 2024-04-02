extends Control

export (int) var maxNumStars = 5
export (Texture) var emptyStarTexture = null
export (Texture) var filledStarTexture = null

var dmgStarResource = preload("res://interface/DamageBarCircularProgressStar.tscn")
var numberOfEmptyStars = 0 setget setNumberOfEmptyStars,getNumberOfEmptyStars
var numberOfFilledStars = 0 setget setNumberOfFilledStars,getNumberOfFilledStars
#var currEnabledStarIx = 0

var starsNode = null
var comboLevel = 0
func _ready():
	starsNode = $stars
	
	#fill the star node with max number of stars before overflow
	for i in maxNumStars:
		var dmgStar = dmgStarResource.instance()
		
		starsNode.add_child(dmgStar)
		#dmgStar.visible = false
		


func _on_combo_level_changed(new):
	
	comboLevel = new
	for star in starsNode.get_children():
		star._on_combo_level_changed(new)
		
	#wan to check to enale the fist empty star since combo elvel reset
	#combo level reset?
	if new == 0:
		#only check if an empty star exists
		if numberOfEmptyStars>= 1:
			var star = starsNode.get_child(numberOfFilledStars)
			if star.state == star.StarState.EMPTY:
				star.enable()
			else:
				print("desing error, empty star exists but isn't next one after fileld star")
				
		
func _on_riposted(ripostedInNeutralFlag):
	for star in starsNode.get_children():
		star._on_riposted(ripostedInNeutralFlag)

func _on_guard_broken():
	for star in starsNode.get_children():
		star._on_guard_broken()

func _on_fill_combo_sub_level_changed(old,new):
	for star in starsNode.get_children():
		star._on_fill_combo_sub_level_changed(old,new)
	
	
	
func setNumberOfEmptyStars(n):
	#can't exceed most number stars
	#if n > maxNumStars:
	#	n=maxNumStars
	
	numberOfEmptyStars=n
	
	#make  all stars empty from starting after curre enabled star
	#for all the empty stars
	
	for i in range(numberOfFilledStars,numberOfFilledStars+numberOfEmptyStars):
		
		#index out of bounds?
		if i >= maxNumStars:
			break
			
		var star = starsNode.get_child(i)
		
		# first star?
		if i == numberOfFilledStars:
			
			#only enable the star if haven't level up combo
			if comboLevel == 0:
				star.enable()
			
		#display empty star
		star.changeState(star.StarState.EMPTY)
	
	#now disable the rests, we may have lost an empty star
	for i in range(numberOfFilledStars+numberOfEmptyStars,maxNumStars):
		var star = starsNode.get_child(i)
		
		star.changeState(star.StarState.INACTIVE)
func getNumberOfEmptyStars():
	return numberOfEmptyStars
	
func setNumberOfFilledStars(n):
	

	numberOfFilledStars=n
	var i = 0
	#make sure to update which star is enabled
	for star in starsNode.get_children():
		
		#the next star after filled star is empty (aka, combo level up unlocked it?)
		if i==numberOfFilledStars and star.state == star.StarState.EMPTY:
			#enable it to display fill combos
			#only enable the star if haven't level up combo
			if comboLevel == 0:
				star.enable()
			
			
		elif i < numberOfFilledStars:
			star.changeState(star.StarState.FILLED)
		else:
			
			#all other stars (or the next star after filled one that is inactive)
			#are disabled
			star.disable()
			
		i = i+1
	
	#MAKE SURE TO UPDATE EMPTY STARS IF DECREASED FILLED STARS
	setNumberOfEmptyStars(numberOfEmptyStars)
	
		
func getNumberOfFilledStars():
	return numberOfFilledStars
	
func uiUpdate():
	
	for star in starsNode.get_children():
		star.uiUpdate()

