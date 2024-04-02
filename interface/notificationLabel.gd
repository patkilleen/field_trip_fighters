extends Label

signal hidden

const FADE_OUT_DURATION = 0.45
const frameTimerResource = preload("res://frameTimer.gd")
const myTweenResource = preload("res://MyTween.gd")

var visibleTimer = null
var myTween = null
var active = false

var defaultModulate=null
var targetTransparentModulate=null
func _ready():
	
	
	defaultModulate=modulate
	targetTransparentModulate=defaultModulate
	targetTransparentModulate.a=0

	#visibleTimer = Timer.new()
	visibleTimer = frameTimerResource.new()
	visibleTimer.connect("timeout",self,"_on_visible_timeout")	
	#visibleTimer.one_shot = true
	self.add_child(visibleTimer)
	
	myTween=myTweenResource.new()
	myTween.connect("finished",self,"_on_fadeout_timeout")	
	self.add_child(myTween)
	
#display text for period of time before delete lable
func init(_text,_lifetime):
	active=true
	self.text = _text
	#visibleTimer.wait_time = _lifetime
	visibleTimer.startInSeconds(_lifetime)
	self.visible = true
	modulate = defaultModulate
	
func _on_fadeout_timeout():
	active=false
	self.text="" # hide it like this, to make sure element occupise a space in list
	#delete notification after a moment, to keep it's place in the list
	emit_signal("hidden",self)

func _on_visible_timeout():
	
	myTween.start_interpolate_property(self,"modulate",defaultModulate,targetTransparentModulate,FADE_OUT_DURATION)
	#
func delete():
	
	visibleTimer.stop()
	self.visible = false
	#var parent = self.get_parent()
	
	#make sure has a parrent before trying to remove from scene tree
	#if parent != null:
		#parent.remove_child(self)
	#call_deferred("queue_free")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
