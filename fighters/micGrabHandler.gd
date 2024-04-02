extends "res://grabHandler.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (int, FLAGS, "Jump","F-Jump", "B-Jump","Ground Idle","Ground F-Move","Ground B-Move" ,"Crouch","N-Melee","N-Special","N-Tool","B-Special","auto ripost","Air Idle","Air F-Move","Air B-Move", "Air F-Dash", "Air B-Dash","Air-Melee","Air-Special","Air-Tool","Fast Fall","Air Move Stop", "Air auto ripost","F-Special","D-Melee","U-Tool","D-Tool","F-Tool","B-Tool","U-Special","F-Melee","B-Special") var operaAbilityAutoCancelsOnHit = 0
export (int, FLAGS, "D-Special","B-Melee","U-Melee","F-Ground-Dash","B-Ground-Dash","Air-grab","grab","crouching-hold-back-block", "Platform Drop","Leave Platform Keep Animation", "F-dash crouch cancel","non-cancelable f-ground-dash","non-cancelable b-ground-dash","apex-of-jump-only fast-fall","standing-hold-back-block","air-hold-back-block","standing-push-block","air-push-block","Air Jump","Air F-Jump", "Air B-Jump","b-dash-Crouch-cancel","basic crouch cancel", "non-GDC jump","non-GDC F-jump", "non-GDC b-jump") var operaAbilityAutoCancelsOnHit2 = 0

export (int, FLAGS, "Jump","F-Jump", "B-Jump","Ground Idle","Ground F-Move","Ground B-Move" ,"Crouch","N-Melee","N-Special","N-Tool","B-Special","auto ripost","Air Idle","Air F-Move","Air B-Move", "Air F-Dash", "Air B-Dash","Air-Melee","Air-Special","Air-Tool","Fast Fall","Air Move Stop", "Air auto ripost","F-Special","D-Melee","U-Tool","D-Tool","F-Tool","B-Tool","U-Special","F-Melee","B-Special") var rapAbilityAutoCancelsOnHit = 0
export (int, FLAGS, "D-Special","B-Melee","U-Melee","F-Ground-Dash","B-Ground-Dash","Air-grab","grab","crouching-hold-back-block", "Platform Drop","Leave Platform Keep Animation", "F-dash crouch cancel","non-cancelable f-ground-dash","non-cancelable b-ground-dash","apex-of-jump-only fast-fall","standing-hold-back-block","air-hold-back-block","standing-push-block","air-push-block","Air Jump","Air F-Jump", "Air B-Jump","b-dash-Crouch-cancel","basic crouch cancel", "non-GDC jump","non-GDC F-jump", "non-GDC b-jump") var rapAbilityAutoCancelsOnHit2 = 0

func _ready():
		#TODO: remove autoability canceling from game
	#for now just zero the cancel options
	operaAbilityAutoCancelsOnHit=0
	operaAbilityAutoCancelsOnHit2=0
	rapAbilityAutoCancelsOnHit=0
	rapAbilityAutoCancelsOnHit2=0

func _on_sprite_animation_played(sa):
	

	
	if playerController != null:
		#make sure to map the auto ability cancels to appropriate stance
		#so rap mic can use fast tools without spending bar,
		#while opera will need to spend bar to autoaility cancel for tools
		if playerController.actionAnimeManager.isInOperaStance():
			abilityAutoCancelsOnHit=operaAbilityAutoCancelsOnHit
			abilityAutoCancelsOnHit2=operaAbilityAutoCancelsOnHit2
		else:
			abilityAutoCancelsOnHit=rapAbilityAutoCancelsOnHit
			abilityAutoCancelsOnHit2=rapAbilityAutoCancelsOnHit2
			
	._on_sprite_animation_played(sa)