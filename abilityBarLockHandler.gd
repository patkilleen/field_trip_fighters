extends Node

signal ability_gain_lock_changed
var frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")
var timer = null
var activated = false

var timeEllasped = false

var currNumHits = 0
var minNumHits = 0

var playerController = null
func _ready():
	timer = frameTimerResource.new()
	timer.connect("timeout",self,"_on_timeout")
	self.add_child(timer)

func reset():
	timer.stop()
	timeEllasped=false
	activated = false
	minNumHits=0
	currNumHits=0

func init(_playerController):
	playerController=_playerController
	
	#playerController.actionAnimeManager.connect("action_animation_finished",self,"_on_action_animation_finished")
	playerController.playerState.connect("changed_in_hitstun",self,"_on_hitstun_changed")
	playerController.collisionHandler.connect("player_was_hit",self,"_on_player_was_hit")
func activate(durationInSeconds,_minNumHits):
	
	if not activated:
		emit_signal("ability_gain_lock_changed",true)
		
	reset()
	minNumHits=_minNumHits
	activated=true
	timer.startInSeconds(durationInSeconds)

#func _on_action_animation_finished(spriteAnimationId):
	
#	if activated:
		#we got locked out cause of stun? opponent failed to followup of failed ripost, unlock ability bar
#		if spriteAnimationId ==playerController.actionAnimeManager.STUNNED_SPRITE_ANIME_ID:
#			reset()
#			emit_signal("ability_gain_lock_changed",false)
#	pass
func _on_hitstun_changed(inHitstunFlag):
	#unlock the bar gain when combo ends
	if activated:
		#broke free from histun?
		if not inHitstunFlag:
			reset()
			emit_signal("ability_gain_lock_changed",false)
			
			
func _on_timeout():
	timeEllasped=true
	
	checkUnlockCondition()
	
func _on_player_was_hit(otherHitboxArea, selfHurtboxArea):
	if not activated:
		return
		
	currNumHits = currNumHits + 1
	checkUnlockCondition()

func checkUnlockCondition():
	
		
	if timeEllasped and currNumHits > minNumHits:
		reset()
		emit_signal("ability_gain_lock_changed",false)
		