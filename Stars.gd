extends HBoxContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var stars = []

export (int) var numberLitStars = 0 setget setNumberLitStars,getNumberLitStars

var starIx = 0


#
# NEED TO add logic to adde starts indefinately if combo reaches lvl 5
#
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	for c in self.get_children():
		stars.append(c)
		c.visible = false
		
	#only display first inactive star
	stars[0].visible = true
	
	pass

#para is unused, just like this cause of signal desing
func addDamageStar(comboLvl):
	
	if comboLvl > 0:
		
		stars[starIx].enableDamageStar()

		starIx+=1
	#only display the first un-obtained star to remove clutter on screen
	if starIx < stars.size()-1:
		stars[starIx].visible = true
	
	
#para is unused, just like this cause of signal desing
func addFocusStar(comboLvl):
	
	if comboLvl > 0:
		
		stars[starIx].enableFocusStar()
		stars[starIx].visible = true
		starIx+=1
	
	#only display the first un-obtained star to remove clutter on screen
	if starIx < stars.size()-1:
		stars[starIx].visible = true
	pass
func clearStars():
	
	starIx = 0
	#disable the remainder
	for i in range(stars.size()):
		stars[i].disable()
		stars[i].visible = false
		i +=1
	#only display the first un-obtained star to remove clutter on screen
	stars[starIx].visible = true
	
func setNumberLitStars(n):
	
	if n == null:
		return
	#minimum 0
	if n < 0:
		n = 0
	#max is number of stars
	if n > stars.size():
		n = stars.size()
		
	numberLitStars = n
	var i = 0
	
	#light up first n start
	while (i < numberLitStars):
		stars[i].enabled = true
		stars[i].visible = true
		i +=1
	
	var firstInactiveStarFlag = true
	#disable the remainder
	while (i <  stars.size()):
		
		#only display the first inactive start
		#hide the remainder
		if (firstInactiveStarFlag):
			firstInactiveStarFlag = false
			stars[i].visible = true
		else:
			stars[i].visible = false
		stars[i].enabled = false
		i +=1
		
		
func getNumberLitStars():
	return numberLitStars
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
