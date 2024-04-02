extends Node2D
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

enum Direction{
	RIGHT,
	DOWN,
	LEFT,
	UP,
	NEUTRAL	
}

export (bool) var cached = false
var GLOBALS = preload("res://Globals.gd")
var inputManager = preload("res://input_manager.gd")

#export (Direction) var direction = 0 setget setDirection,getDirection



var facingRightLeftDiXOffset=30
var facingRightRightDiXOffset=-5
var facingLeftLeftDiXOffset=0
var facingLeftRightDiXOffset=-30

var upDiYOffset=10
var downDiYOffset=-20
#var yDirectionalPositionOffset = 75
#var xDirectionalPositionOffset = 40


var nattackSfx =null
var diattackSfx =null


func _ready():
		

	nattackSfx=$"n-attack-hit-particles"
	diattackSfx=$"di-attack-hit-particles"
	
	nattackSfx.connect("finished",self,"_on_finished")
	diattackSfx.connect("finished",self,"_on_finished")

func _on_finished():
	visible = false
	pass
	#if not cached:
	#	self.call_deferred("delete_node")
	
func delete_node():
	var parent = get_parent()
	if parent != null:
		parent.remove_child(self)
	queue_free()


func playClashSfx(_position, inHitFreeze):
	nattackSfx.visible = true
	diattackSfx.visible = false
	nattackSfx.play(GLOBALS.CLASH_IX,inHitFreeze)
	
	#make sure to force hitfreeze for this sfx if already in hitfreeze
	if inHitFreeze:
		nattackSfx._on_hit_freeze_started(null)
		
	self.position = _position
	pass
	
func playAttackHitSfx(cmd,attackTypeIx,spriteFacingRight,_position,inHitFreeze):
	
	#attacktypeIx:
	
#const MELEE_IX = 0
#const SPECIAL_IX = 1
#const TOOL_IX = 2
#const OTHER_IX = 3
#const CLASH_IX = 4

	var direction = parseDirection(cmd,spriteFacingRight)
	self.position = _position
	
	var sfxPlayed = null
	if direction == Direction.LEFT :
		diattackSfx.scale.x =diattackSfx.scale.x*(-1)
		
		if spriteFacingRight:
			diattackSfx.position.x = diattackSfx.position.x + facingRightLeftDiXOffset
		else:
			diattackSfx.position.x = diattackSfx.position.x + facingLeftLeftDiXOffset
		
		nattackSfx.visible = false
		diattackSfx.visible = true
		
		#if attackTypeIx!= null:
		diattackSfx.play(attackTypeIx,inHitFreeze)
		sfxPlayed=diattackSfx
		#else:
		#	diattackSfx.play(GLOBALS.OTHER_IX)
	elif direction == Direction.UP:
		diattackSfx.rotation_degrees = 270
		diattackSfx.position.y = diattackSfx.position.y + upDiYOffset
		nattackSfx.visible = false
		diattackSfx.visible = true
				
		#if attackTypeIx!= null:
		diattackSfx.play(attackTypeIx,inHitFreeze)
		sfxPlayed=diattackSfx
		#else:
			#diattackSfx.play(GLOBALS.OTHER_IX)
	elif direction == Direction.RIGHT:
		if spriteFacingRight:
			diattackSfx.position.x = diattackSfx.position.x + facingRightRightDiXOffset
		else:
			diattackSfx.position.x = diattackSfx.position.x + facingLeftRightDiXOffset
		nattackSfx.visible = false
		diattackSfx.visible = true
				
	#	if attackTypeIx!= null:
		diattackSfx.play(attackTypeIx,inHitFreeze)
		sfxPlayed=diattackSfx
	#	else:
	#		diattackSfx.play(GLOBALS.OTHER_IX)
		
		
	elif direction == Direction.DOWN:
		diattackSfx.rotation_degrees = 90
		diattackSfx.position.y = diattackSfx.position.y + downDiYOffset
		nattackSfx.visible = false
		diattackSfx.visible = true
				
		#if attackTypeIx!= null:
		diattackSfx.play(attackTypeIx,inHitFreeze)
		sfxPlayed=diattackSfx
		#else:
		#	diattackSfx.play(GLOBALS.OTHER_IX)
	elif direction == Direction.NEUTRAL or direction == null:
		nattackSfx.visible = true
		diattackSfx.visible = false
				
#		if attackTypeIx!= null:
		nattackSfx.play(attackTypeIx,inHitFreeze)
		sfxPlayed=nattackSfx
#		else:
#			nattackSfx.play(GLOBALS.OTHER_IX)


	
func parseDirection(cmd,spriteFacingRight):
	
	
	
	var dir = null
	match(cmd):
		inputManager.Command.CMD_NEUTRAL_MELEE:

			dir = Direction.NEUTRAL

		inputManager.Command.CMD_DOWNWARD_MELEE:
			dir = Direction.DOWN

		inputManager.Command.CMD_UPWARD_MELEE:
			
			dir = Direction.UP
			
		inputManager.Command.CMD_FORWARD_MELEE:
			
			dir = Direction.RIGHT
			
		inputManager.Command.CMD_BACKWARD_MELEE:
			
			dir =Direction.LEFT	
			
		inputManager.Command.CMD_NEUTRAL_SPECIAL:
			
			dir = Direction.NEUTRAL
			
		inputManager.Command.CMD_DOWNWARD_SPECIAL:
			
			dir = Direction.DOWN
			
		inputManager.Command.CMD_UPWARD_SPECIAL:
			
			dir = Direction.UP
			
		inputManager.Command.CMD_FORWARD_SPECIAL:
			
			dir = Direction.RIGHT
			
		inputManager.Command.CMD_BACKWARD_SPECIAL:

			dir = Direction.LEFT

		inputManager.Command.CMD_NEUTRAL_TOOL:
			
			dir = Direction.NEUTRAL
			
		inputManager.Command.CMD_DOWNWARD_TOOL:
			
			dir = Direction.DOWN
			
		inputManager.Command.CMD_UPWARD_TOOL:
		
			dir = Direction.UP
		
		inputManager.Command.CMD_FORWARD_TOOL:
			
			dir = Direction.RIGHT
			
		inputManager.Command.CMD_BACKWARD_TOOL:
			
			dir = Direction.LEFT	
		
	#have to mirror the direction?
	if not spriteFacingRight:
		if dir ==Direction.LEFT:
			dir =Direction.RIGHT
		elif dir ==Direction.RIGHT:
			dir =Direction.LEFT
		
	
	return dir
