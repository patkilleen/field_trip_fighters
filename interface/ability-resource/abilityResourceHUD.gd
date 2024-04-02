extends Control

export (Texture) var fillTexture = null
export (Texture) var partialFillTexture = null
export (Texture) var foreGroundTexture = null
var redCross = null
var circleProgress = null
var disableOverride = false
func _ready():
	redCross = $"red-cross"
	circleProgress = $circleProgress
	circleProgress.texture_over = foreGroundTexture
	
	
func init(abilityResourceCost,defaultAbilityBarAmount):
	
	circleProgress.min_value = 0
	circleProgress.max_value = abilityResourceCost
	updateProgress(defaultAbilityBarAmount)
	circleProgress.step = abilityResourceCost/100.0
	

func updateProgress(newValue):
	
	circleProgress.value=newValue
	
	#red cross appears only when the ability amount isn't the max value
	if newValue < circleProgress.max_value:
		
		#not 100% filled. display red cross, and display the partial texture
		circleProgress.texture_progress=partialFillTexture
		
	else:
		
		#100% filled. don't display red cross, and display bright texture
		circleProgress.texture_progress=fillTexture
	
	updateRedCrossVisibility()	

func updateRedCrossVisibility():
	
	#is red cross always enabled?
	if disableOverride:
		redCross.visible = true
	else:
		#red cross appears only when the ability amount isn't the max value
		if circleProgress.value < circleProgress.max_value:		
			#not 100% filled. display red cross
			redCross.visible = true		
		else:		
			#100% filled. don't display red cross		
			redCross.visible = false
			
	
		
#sets the disable override flag. true means red slash always appears. false means it appears as normal 
func setDisableOverrideFlag(f):
	disableOverride=f
	
	updateRedCrossVisibility()
	