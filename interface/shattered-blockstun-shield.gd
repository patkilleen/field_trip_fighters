extends Sprite

const MyTweenResource = preload("res://MyTween.gd")

export (float) var shieldBreakPixilationDuration = 0.4 #seconds
export (bool) var standingShield = true
var pixilateTween = null
var burstShader = null
func _ready():
	
	
	pass

func init():
	
	burstShader =get_material()
	visible = false
	pixilateTween = MyTweenResource.new()
	self.add_child(pixilateTween)
	pixilateTween.connect("finished",self,"_on_shield_break_pixilation_finished")
	pixilateTween.ignoreHitFreeze=true

func reset():
		set_pixilation_progress(0)
		pixilateTween.stop()
		
		visible = false
		
func set_pixilation_progress(amount):
	
	burstShader.set_shader_param("progress", amount)
	pass
func _on_guard_break(highBlockFlag, amountGuardRegened):
	if standingShield==highBlockFlag:
		visible = true
		pixilateTween.start_interpolate_method(self,"set_pixilation_progress",0,1,shieldBreakPixilationDuration)
	else:
		visible = false
		set_pixilation_progress(0)
	pass
	
func _on_shield_break_pixilation_finished():
	set_pixilation_progress(0)
	visible =false
	pass	
