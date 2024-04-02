extends Sprite

signal new_sprite_position
signal new_sprite_texture
const GLOBALS = preload("res://Globals.gd")
var lastPos = null


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#shaking parameters
#https://kidscancode.org/godot_recipes/2d/screen_shake/
var shake_decay = 0.8 # How quickly the shaking stops [0, 1].
var shake_max_offset = Vector2(15, 15)  # Maximum hor/ver shake in pixels.

var shake_trauma = 0.0  # Current shake strength.
var shake_trauma_power = 2  # Trauma exponent. Use [2, 3].
var shake_duration=-1
var shake_duration_in_seconds=-1
var shake_time_ellapsed=0
var preShakeOffset=null
func _ready():
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	set_physics_process(true)
	lastPos = position	
	preShakeOffset=offset
	pass
	
func set_texture(value):
	.set_texture(value)
	#emit a signal that it's texture changed
	emit_signal("new_sprite_texture",value)
	
#func set_position(p):
	#calll parent
#	.set_position(p)
	
	#emit a signal that it's position changed
#	emit_signal("new_sprite_position",p)
	
	
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	if lastPos.x != position.x and lastPos.y != position.y:
		lastPos = position
		emit_signal("new_sprite_position",position)
		
	
	
	#sprite shaking?
	if shake_trauma:
		#decay the shake so it eventually stops
		shake_trauma = max(shake_trauma - shake_decay * delta, 0)
		
		#apply the shake
		var amount = pow(shake_trauma, shake_trauma_power)
		offset.x = offset.x+(shake_max_offset.x * amount * rand_range(-1, 1))
		offset.y = offset.y+(shake_max_offset.y * amount * rand_range(-1, 1))
		
		#only track the shake duration for positive numbers
		if shake_duration>0:
			shake_time_ellapsed = shake_time_ellapsed +delta
			
			#shake duration ellapsed?
			if GLOBALS.has_frame_based_duration_ellapsed(shake_time_ellapsed,shake_duration_in_seconds):
				reset_shake_trauma()
		
func _on_about_to_be_applied_hitstun(attackSpriteId,relativeDamage):
	#shaking?
	if shake_trauma:
		#stop shaking when hit by another move
		reset_shake_trauma()
		
func _on_changed_in_hitstun(inHitstun):
	if not inHitstun:
		
		#shaking?
		if shake_trauma:
			#stop shaking when break free from hitstun
			reset_shake_trauma()
	
func startShaking(_shake_trauma,_shake_decay,_shake_max_offset,_shake_trauma_power,_duration):
	reset_shake_trauma()
	shake_trauma=_shake_trauma
	shake_decay=_shake_decay
	shake_max_offset=_shake_max_offset
	shake_trauma_power=_shake_trauma_power
	preShakeOffset = offset
	shake_duration=_duration
	shake_duration_in_seconds = shake_duration*GLOBALS.SECONDS_PER_FRAME
#stop shaking 
func reset_shake_trauma():
	offset=preShakeOffset
	shake_trauma =0
	shake_time_ellapsed=0
	
	
func _on_hit_freeze_started(duration):
	
	pass
	
#stage connects this
func _on_hit_freeze_finished():
	#only stop the shaking on hitfreeze end for shaking that doesn't specificy duration
	if shake_duration<=0:
		reset_shake_trauma()