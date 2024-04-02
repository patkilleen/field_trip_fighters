extends Control

enum StarState{
	INACTIVE,
	EMPTY,
	ONE_THIRD_FILLED,
	TWO_THIRD_FILLED,
	FILLED
}
var defaultColor =null
var targetTransparentColor = null

var state = null

var filledStarTextureRect = null
var emptyStarTextureRect = null
var circularProgressStar = null

var enabled = false

#var enabledGlow = null
#var glowTextureRect = null
var shineSprite=null

var defaultScale = null
# Called when the node enters the scene tree for the first time.
func _ready():
	defaultScale = self.rect_scale
	defaultColor = self.modulate
	targetTransparentColor = defaultColor
	targetTransparentColor.a = 0.2# 80 %transparent
	
	filledStarTextureRect = $filledStarTextureRect
	emptyStarTextureRect = $emptyStarTextureRect
	circularProgressStar = $CircularProgressStar
	
	#glowTextureRect = $glowTextureRect
	#enabledGlow = $glowTextureRect/enableGlow
	shineSprite = $shine
	#glowTextureRect.visible = false
	shineSprite.visible = false
	#enabledGlow.enabled=false
	#by default inactive
	changeState(StarState.INACTIVE)
	
	

func enable():
	enabled=true
	enableGlow()
	if state == StarState.EMPTY:
		
		#make sure the appropriate empty star is displayed
		changeToEmptyState()
	
func disable():
	enabled=false
	disableGlow()
	if state == StarState.EMPTY:
		
		#make sure the appropriate empty star is displayed
		changeToEmptyState()
	
func enableGlow():
	#glowTextureRect.visible = true
	shineSprite.visible = true
	
	#enabledGlow.enabled=true
func disableGlow():
	#glowTextureRect.visible = false
	shineSprite.visible = false
	
	#enabledGlow.enabled=false
	
func changeState(newState):
	
	if newState == state:
		return
	state = newState	
	uiUpdate()
	
func uiUpdate():
	
	
	match(state):
		StarState.INACTIVE:
			#go transparent
			self.modulate = targetTransparentColor
			#empty the progress
			circularProgressStar.resetProgress()
			
			#filled star hidden
			filledStarTextureRect.visible = false
			
			#progress filled star hidden
			circularProgressStar.visible = false
			
			#empty star displayed
			emptyStarTextureRect.visible = true
			
			disableGlow()
			enabled =false
		StarState.EMPTY:
			
			changeToEmptyState()
			
			
		StarState.ONE_THIRD_FILLED:
			
			
			#remove transparentcy
			self.modulate = defaultColor
			
			#fill star by 1/3
			circularProgressStar.fillPart1()
			
			#filled star hidden
			filledStarTextureRect.visible = false
			
			#empty star hidden
			emptyStarTextureRect.visible = false

			#progress filled star shown
			circularProgressStar.visible = true
				
							
				
			
		StarState.TWO_THIRD_FILLED:
			
				#remove transparentcy
			self.modulate = defaultColor
			
			#fill star by 1/3
			circularProgressStar.fillPart2()
			
			#filled star hidden
			filledStarTextureRect.visible = false
			
			#empty star hidden
			emptyStarTextureRect.visible = false

			#progress filled star shown
			circularProgressStar.visible = true
		StarState.FILLED:
			
			#remove transparentcy
			self.modulate = defaultColor
			
			#fill star by 1/3
			circularProgressStar.fillCompletly()
			
			#filled star visible, since star filled
			filledStarTextureRect.visible = true
			
			#empty star hidden
			emptyStarTextureRect.visible = false

			#progress filled star shown, but the filled star is ontop, so will be hidden, but 
			#any particle animation will be visible
			circularProgressStar.visible = true
			circularProgressStar.hideButtonSprites()
			#no longer respond to combos. were filled.
			enabled =false
			disableGlow()
			
func _on_combo_level_changed(new):
	
	#combo level up (combo levels only increase)?
	if new != 0:
		
		if enabled:
			#combo level ups stop ability to increase the star
			enabled=false
			disableGlow()
		
			#enabled
			changeToEmptyState()
		
func _on_riposted(ripostedInNeutralFlag):
	#changeState(StarState.INACTIVE)
	pass

func _on_guard_broken():
	changeState(StarState.INACTIVE)

func _on_fill_combo_sub_level_changed(old,new):
	if enabled:
		
		#don't remove filling of star if already eanred
		if state != StarState.FILLED:
			match(new):
				0:
					changeState(StarState.EMPTY)
				1:
					changeState(StarState.ONE_THIRD_FILLED)
				2:
					changeState(StarState.TWO_THIRD_FILLED)
				3:
					changeState(StarState.FILLED)
				
				
			
func changeToEmptyState():
	#remove transparentcy
	self.modulate = defaultColor
	
	#empty the progress
	circularProgressStar.resetProgress()
	
	#filled star hidden
	filledStarTextureRect.visible = false
	#here we have to decide if were an enable empty star (cen be filled from speacil/tool fill combo)
	#or if were an extra empty star that can't be filled yet (a star before this one is enabled and empty)
	if enabled:
		#progress star shown while the empty is hidden
		circularProgressStar.visible = true
		emptyStarTextureRect.visible = false
	else:
					
		#empty star is displayed while the progress is hidden
		emptyStarTextureRect.visible = true
		circularProgressStar.visible = false
		
	state = StarState.EMPTY