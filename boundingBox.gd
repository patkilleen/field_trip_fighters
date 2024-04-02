extends Node2D

const frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")
const GLOBALS = preload("res://Globals.gd")
export (float) var falseWallOffset = 10
export (float) var falseCeilingOffset = 10
export (float) var maxWidth = 10
export (float) var minWidth = 10
export (float) var maxHeight = 10
export (float) var minHeight = 10
var leftWall = null
var rightWall = null
var ceiling = null

var leftWallDefaultPos = null
var rightWallDefaultPos = null
var ceilingDefaultPos = null

var invisibleLight = null

var ceilingLockFrameTimer = null
var wallLockFrameTimer = null

var camera=null
func _ready():
	leftWall = $"left-false-wall"
	rightWall = $"right-false-wall"
	ceiling = $"false-ceiling"
	
	ceilingLockFrameTimer = frameTimerResource.new()
	wallLockFrameTimer= frameTimerResource.new()
	ceilingLockFrameTimer.connect("timeout",self,"_on_ceiling_lock_timeout")
	wallLockFrameTimer.connect("timeout",self,"_on_wall_lock_timeout")
	self.add_child(ceilingLockFrameTimer)
	self.add_child(wallLockFrameTimer)
	
	
	#invisibleLight = $"invisiblity-area"
	
	
#record starting position
func init(_camera,player1KinBody,player2KinBody):
	leftWallDefaultPos = leftWall.position
	rightWallDefaultPos = rightWall.position
	ceilingDefaultPos = ceiling.position
	camera=_camera
	leftWall.init(player1KinBody,player2KinBody,GLOBALS.TECH_WALL_IX)
	rightWall.init(player1KinBody,player2KinBody,GLOBALS.TECH_WALL_IX)
	ceiling.init(player1KinBody,player2KinBody,GLOBALS.TECH_FLOOR_IX)
	
	player1KinBody.playerController.get_node("CollisionHandler").connect("pushed_against_wall",leftWall,"_on_player_hit_environment",[player1KinBody])
	player1KinBody.playerController.get_node("CollisionHandler").connect("pushed_against_wall",rightWall,"_on_player_hit_environment",[player1KinBody])
	player1KinBody.playerController.get_node("CollisionHandler").connect("pushed_against_ceiling",ceiling,"_on_player_hit_environment",[player1KinBody])#pass ceiling as param cause signal doesn't send it, and only 1 ceiling exists
	player2KinBody.playerController.get_node("CollisionHandler").connect("pushed_against_wall",leftWall,"_on_player_hit_environment",[player2KinBody])
	player2KinBody.playerController.get_node("CollisionHandler").connect("pushed_against_wall",rightWall,"_on_player_hit_environment",[player2KinBody])
	player2KinBody.playerController.get_node("CollisionHandler").connect("pushed_against_ceiling",ceiling,"_on_player_hit_environment",[player2KinBody])#pass ceiling as param cause signal doesn't send it, and only 1 ceiling exists

	player1KinBody.playerController.connect("landed",ceiling,"_on_player_landed")
	player2KinBody.playerController.connect("landed",ceiling,"_on_player_landed")
	
	
	player1KinBody.playerController.connect("false_ceiling_lock",self,"_on_false_ceiling_lock")
	player1KinBody.playerController.connect("false_wall_lock",self,"_on_false_wall_lock")
	player2KinBody.playerController.connect("false_ceiling_lock",self,"_on_false_ceiling_lock")
	player2KinBody.playerController.connect("false_wall_lock",self,"_on_false_wall_lock")
	
	player1KinBody.playerController.connect("false_ceiling_unlock",self,"_on_false_ceiling_unlock")
	player1KinBody.playerController.connect("false_wall_unlock",self,"_on_false_wall_unlock")
	player2KinBody.playerController.connect("false_ceiling_unlock",self,"_on_false_ceiling_unlock")
	player2KinBody.playerController.connect("false_wall_unlock",self,"_on_false_wall_unlock")
	
	player1KinBody.playerController.connect("entered_oki",self,"_on_entered_oki")
	player2KinBody.playerController.connect("entered_oki",self,"_on_entered_oki")
	

	player1KinBody.playerController.get_node("PlayerState").connect("changed_in_hitstun",self,"_on_hitstun_changed",[player1KinBody])
	player2KinBody.playerController.get_node("PlayerState").connect("changed_in_hitstun",self,"_on_hitstun_changed",[player2KinBody])
	
	
	
func reset():
		
	unlockWalls()	
	unlockCeiling()
	resetDefaultPosition()
	
#resets walls to were they were on game start
func resetDefaultPosition():
	
	leftWall.setLocked(false)
	rightWall.setLocked(false)
	ceiling.setLocked(false)
	
	ceilingLockFrameTimer.reset()
	wallLockFrameTimer.reset()
	var environment = [leftWall,rightWall,ceiling]
	for e in environment:
		#e.resetToDefaultPosition()
		e.reset()
		e.mySmoothMovementXTween.stop()
		e.mySmoothMovementYTween.stop()
		e._on_y_pos_tween_finished()
		e._on_x_pos_tween_finished()
		e.mySmoothMovementXTween.init()
		e.mySmoothMovementYTween.init()
	#leftWall.resetToDefaultPosition()
	#rightWall.resetToDefaultPosition()
	#ceiling.resetToDefaultPosition()
	
	#leftWall.smoothMovementTween.stop_all()
	#leftWall.mySmoothMovementXTween.stop()
	#leftWall.mySmoothMovementYTween.stop()
	
	leftWall.position = leftWallDefaultPos
	#leftWall._on_y_pos_tween_finished()
	#leftWall._on_x_pos_tween_finished()
	
	#rightWall.smoothMovementTween.stop_all()
	#rightWall.mySmoothMovementXTween.stop()
	#rightWall.mySmoothMovementYTween.stop()
	rightWall.position = rightWallDefaultPos
	#rightWall._on_y_pos_tween_finished()
	#rightWall._on_x_pos_tween_finished()

	#ceiling.smoothMovementTween.stop_all()
	#ceiling.mySmoothMovementXTween.stop()
	#ceiling.mySmoothMovementYTween.stop()
	
	ceiling.position = ceilingDefaultPos
	#ceiling._on_y_pos_tween_finished()
	#ceiling._on_x_pos_tween_finished()
func disableFalseWalls():
	leftWall.disable()
	rightWall.disable()
	ceiling.disable()

func enableFalseWalls():
	leftWall.enable()
	rightWall.enable()
	ceiling.enable()
		
func updateBoundingBox(player_rect,forceInstantSnap =false):
	
	#must offset the rectangle by the caemra position
	player_rect.position = player_rect.position+camera.position
	
	var playersCenter = Vector2(player_rect.position.x + player_rect.size.x/2, player_rect.position.y + player_rect.size.y/2)
	
	var boudningRectSize =Vector2(minWidth,minHeight)
	
	#get width of player rectangle (distance bewteen players)
	#limit the boundaries
	if player_rect.size.x > maxWidth:
		boudningRectSize.x = maxWidth
	elif player_rect.size.x > minWidth:
		boudningRectSize.x = player_rect.size.x
	
	#get height of player rectangle (distance bewteen players)
	#limit the boundaries
	if player_rect.size.y > maxHeight:
		boudningRectSize.y = maxHeight
	elif player_rect.size.y > minHeight:
		boudningRectSize.y = player_rect.size.y
		
			
	var half_width = boudningRectSize.x/2
	var half_height = boudningRectSize.y/2
	
	#allow player to walk away and expand the camara until max zoom
	#leftWall.position.x = playersCenter.x -  half_width - falseWallOffset 
	#rightWall.position.x = playersCenter.x + half_width + falseWallOffset
	#ceiling.position.y = playersCenter.y - half_height + falseCeilingOffset
	
	if not forceInstantSnap:
		leftWall.setXPosition(playersCenter.x -  half_width - falseWallOffset)
		rightWall.setXPosition(playersCenter.x + half_width + falseWallOffset)
		ceiling.setYPosition(playersCenter.y - half_height + falseCeilingOffset)
	else:
			
		leftWall.reset()
		rightWall.reset()
		ceiling.reset()
		
		leftWall.position.x = playersCenter.x -  half_width - falseWallOffset
		rightWall.position.x =playersCenter.x + half_width + falseWallOffset
		ceiling.position.y =playersCenter.y - half_height + falseCeilingOffset
	
	

func getFalseBoxLeftPosition():
	var leftWallShapePos =leftWall.collisionShape.global_position
	var wallExtent = leftWall.collisionShape.shape.get_extents()
	
	return leftWallShapePos.x  +wallExtent.x
	
func getFalseBoxRightPosition():
	var rightWallShapePos =rightWall.collisionShape.global_position
	return rightWallShapePos.x  
	
func getFalseBoxTopPosition():
	var ceilingShapePos =ceiling.collisionShape.global_position
	var ceilingExtent = ceiling.collisionShape.shape.get_extents()
	return ceilingShapePos.y+ceilingExtent.y
	
func unlockWalls():
	leftWall.setLocked(false)
	rightWall.setLocked(false)
	wallLockFrameTimer.stop()
	
func unlockCeiling():	
	ceiling.setLocked(false)
	ceilingLockFrameTimer.stop()	
		
func _on_ceiling_lock_timeout():
	#print("ceiling lock timeout")
	ceiling.setLocked(false)
	
	pass
func _on_wall_lock_timeout():
	#print("wall lock timeout")
	leftWall.setLocked(false)
	rightWall.setLocked(false)
	pass
	
	
func _on_hitstun_changed(inHitstunFlag,player):
	#broke free from hitstun?
	if not inHitstunFlag:
		#print("hitstun done. stone false ceiling/wall lock")
		#stop any freeze on the walls (may be odd if both players hit each other at same time
		#but it shhoudln't be too bad since trading won't affect combo pathing using walls too much)
		unlockWalls()
		unlockCeiling()

func _on_false_ceiling_unlock():
	unlockCeiling()	
func _on_false_ceiling_lock(durationInFrames):
	#print("false celining locked for "+str(durationInFrames)+" frames)")

	ceiling.setLocked(true)
	
	#only start timer if duratin limited. otherwise it's infinite (until histun ends)
	if durationInFrames > 0:		
		ceilingLockFrameTimer.start(durationInFrames)
	pass
	
func _on_false_wall_unlock():
	unlockWalls()
	
func _on_false_wall_lock(durationInFrames):
	#print("false wall locked for "+str(durationInFrames)+" frames)")
	leftWall.setLocked(true)
	rightWall.setLocked(true)
	#only start timer if duratin limited. otherwise it's infinite (until histun ends)
	if durationInFrames > 0:
		wallLockFrameTimer.start(durationInFrames)
	pass
	
func _on_entered_oki():
	unlockWalls()
	unlockCeiling()	