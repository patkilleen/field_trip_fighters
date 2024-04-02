extends Sprite

const MyTweenResource = preload("res://MyTween.gd")

var maxGuardHp = null
var minGuardHp = null
var medianGuardHp = null

var guardHPOffset=null
var guardHPOffsetMod=0.2
var maxGreen = 1
var minGreen =0

var maxBlue = 1
var minBlue =0

	
var maxRed = 1
var minRed =0

var landTween = null
var defaultPosition=null

export (float) var yLandShakeDistance = 10
export (float) var landShakeSpeed=0.15 # seconds to shake

func _ready():
	
	
	pass

func init(_maxGuardHp,_minGuardHp):
	maxGuardHp=_maxGuardHp
	minGuardHp = _minGuardHp
	
	medianGuardHp = (maxGuardHp - minGuardHp)/2.0

	#offset used for get max red color when minimum below this offset
	guardHPOffset = (maxGuardHp - minGuardHp)*guardHPOffsetMod

	landTween = MyTweenResource.new()
	self.add_child(landTween)
	defaultPosition = position
	

#this is the best one, blue to read
func _on_guard_hp_changed(old,new):

	
	
	
	#yellow = (1,1,0)
	#red = (1,0,0)
	#var blue = range_lerp(52, 0, 100, 0, 1)
	var blue = 0

	#now map the progress bar value to desired color
	
	var green =0
	var red = 0
	
	#will start at (1,1,1) : default no color of blue sield
	
	#will drop to (1,1,0) by the middle:  yewllo
	
	#will drop to (1,0,0) by the end:  red
	
	#blue will start max, and drop to 0 by middle
	if new >  medianGuardHp:
		blue = maxBlue	
		green = maxGreen
	else:
		blue = range_lerp(new, minGuardHp+guardHPOffset,medianGuardHp, minBlue,maxBlue)
	
		green = range_lerp(new, minGuardHp+guardHPOffset,medianGuardHp, minGreen,maxGreen)
	

	red = maxRed
	
	modulate = Color(red,green,blue)
	

func _on_land():
	
	if visible:
		var targetDestination=defaultPosition
		targetDestination.y = targetDestination.y + yLandShakeDistance
		
		landTween.start_interpolate_property(self,"position",defaultPosition,targetDestination,landShakeSpeed)
		#landTween.start()
		
		yield(landTween,"finished")
		
		landTween.start_interpolate_property(self,"position",targetDestination,defaultPosition,landShakeSpeed)
		#landTween.start()

#blue to orange to red
func _on_guard_hp_changed_old_best_one(old,new):

	
	
	
	#yellow = (1,1,0)
	#red = (1,0,0)
	#var blue = range_lerp(52, 0, 100, 0, 1)
	var blue = 0

	#now map the progress bar value to desired color
	
	var green =0
	var red = 0
	
	#will start at (1,1,1) : default no color of blue sield
	
	#will drop to (1,1,0) by the middle:  yewllo
	
	#will drop to (1,0,0) by the end:  red
	
	#blue will start max, and drop to 0 by middle
	if new <  medianGuardHp:
		blue = minBlue	
	else:
		blue = range_lerp(new, medianGuardHp,maxGuardHp, minBlue,maxBlue)
	

	green = range_lerp(new, minGuardHp+guardHPOffset,maxGuardHp, minGreen,maxGreen)

	red = maxRed
	
	modulate = Color(red,green,blue)
	

#working, the yellow is qauite distict, but there is unwanted green  before the ywllo
func _on_guard_hp_changed4(old,new):

	
	
	
	#yellow = (1,1,0)
	#red = (1,0,0)
	#var blue = range_lerp(52, 0, 100, 0, 1)
	var blue = 0

	#now map the progress bar value to desired color
	
	var green =0
	var red = 0
	
	
	
	if new  >=  medianGuardHp:
		green = maxGreen
		blue = range_lerp(new, medianGuardHp,maxGuardHp, minBlue,maxBlue)
	else:
		blue = minBlue
		green = range_lerp(new, minGuardHp,medianGuardHp, minGreen,maxGreen)
		
	#from 0% to 49% bar red stays maxed out
	#from 50% to 100% bar red goes from max to min
	
	if new  <  medianGuardHp:
		red = maxRed
	else:
		red = range_lerp(new, medianGuardHp,maxGuardHp, maxRed, minRed)
		#red = maxRed - range_lerp(new, minGuardHp,maxGuardHp, minRed,maxRed)
		
	
	
	#green = range_lerp(new, minGuardHp,maxGuardHp, minGreen,maxGreen)
	#red = maxRed - range_lerp(new, minGuardHp,maxGuardHp, minRed,maxRed)
	
	
	
	#var styleBox = $ProgressBar.get("custom_styles/fg")
	
	
	
	modulate = Color(red,green,blue)
	




#working, but the yellow isn't very distict
func _on_guard_hp_changed3(old,new):

	
	
	
	#yellow = (1,1,0)
	#red = (1,0,0)
	#var blue = range_lerp(52, 0, 100, 0, 1)
	var blue = 0

	#now map the progress bar value to desired color
	
	var green =0
	var red = 0
	
	
	
	if new  >=  medianGuardHp:
		green = maxGreen
	else:
		green = range_lerp(new, minGuardHp,medianGuardHp, minGreen,maxGreen)
		
	#from 0% to 49% bar red stays maxed out
	#from 50% to 100% bar red goes from max to min
	
	if new  <  medianGuardHp:
		red = maxRed
	else:
		red = range_lerp(new, medianGuardHp,maxGuardHp, maxRed, minRed)
		#red = maxRed - range_lerp(new, minGuardHp,maxGuardHp, minRed,maxRed)
		
	
	blue = range_lerp(new, minGuardHp,maxGuardHp, minBlue,maxBlue)
	#green = range_lerp(new, minGuardHp,maxGuardHp, minGreen,maxGreen)
	#red = maxRed - range_lerp(new, minGuardHp,maxGuardHp, minRed,maxRed)
	
	
	
	#var styleBox = $ProgressBar.get("custom_styles/fg")
	
	
	
	modulate = Color(red,green,blue)
	


#working, but no yellow
func _on_guard_hp_changed2(old,new):

	
	
	
	
	#var blue = range_lerp(52, 0, 100, 0, 1)
	var blue = 0

	#now map the progress bar value to desired color
	
	var green =0
	var red = 0
	
	
	
	if new  >=  medianGuardHp:
		green = maxGreen
	else:
		green = range_lerp(new, minGuardHp,maxGuardHp, minGreen,maxGreen)
		
	#from 0% to 49% bar red stays maxed out
	#from 50% to 100% bar red goes from max to min
	
	if new  <  medianGuardHp:
		red = maxRed
	else:
		red = range_lerp(new, medianGuardHp,maxGuardHp, maxRed, minRed)
		#red = maxRed - range_lerp(new, minGuardHp,maxGuardHp, minRed,maxRed)
	
	
	
	
	blue = range_lerp(new, minGuardHp,maxGuardHp, minBlue,maxBlue)
	#green = range_lerp(new, minGuardHp,maxGuardHp, minGreen,maxGreen)
	#red = maxRed - range_lerp(new, minGuardHp,maxGuardHp, minRed,maxRed)
	
	
	
	#var styleBox = $ProgressBar.get("custom_styles/fg")
	
	
	
	modulate = Color(red,green,blue)
	
	



