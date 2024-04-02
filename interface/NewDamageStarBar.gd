extends Control

export (int) var maxNumStars = 5 #5 stars max, so 6 is default value that shouldn't ever occur

export (Texture) var emptyStarTexture = null
export (Texture) var filledStarTexture = null

var starArray = null


func _ready():

	starArray = $"HBoxContainer/star-array"
	
	starArray.maxNumStars = maxNumStars
	starArray.emptyStarTexture=emptyStarTexture
	starArray.filledStarTexture=filledStarTexture


func _on_num_empty_dmg_stars_changed(old,new):
	starArray.setNumberOfEmptyStars(new)
	
	
func _on_num_filled_dmg_stars_changed(old,new):
	starArray.setNumberOfFilledStars(new)
	



func _on_combo_level_changed(new):
	
	starArray._on_combo_level_changed(new)
	
		
func _on_riposted(ripostedInNeutralFlag):
	starArray._on_riposted(ripostedInNeutralFlag)
	
	

func _on_guard_broken(highBlockFlag,amountGuardRegened):
	starArray._on_guard_broken()
	

func _on_fill_combo_sub_level_changed(old,new):
	starArray._on_fill_combo_sub_level_changed(old,new)
	
	
	
