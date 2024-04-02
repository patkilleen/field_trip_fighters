extends Camera2D

enum CameraState{
	
	ATTACHED,
	DETTACHED,
	SMOOTH_FOLLOW
}
const PLAYER1_IX=0
const PLAYER2_IX =1

export (float, 0.01, 0.5) var zoom_offset = 0.2
export (bool) var debug_mode = false
export (float) var maxZoom = 1
export (float) var minZoom = 0.1
#export (float) var falseWallOffset = 100
export (int) var ripostZoomInNumberFrames = 10
export (float) var ripostZoomInOffset = 0.1
#export (float) var falseWallBBOffset = 2

export (float) var ripostZoomInDuration = 0.07
export (float) var ripostRemainZoomedInDuration = 0.2
export (float) var ripostZoomOutDuration = 0.07
export (float) var ripostZoomOffset = 0.07

#export (float) var updateFrequency =30 
export (float) var zoomFollowSpeed = 0.1

#number of seconds to move camera 
export (float) var cameraFollowTimeRequired = 0.25
export (bool) var manualCameraControl = false
var cameraSnapBackTimeRequired = 0.05


#shaking parameters
#https://kidscancode.org/godot_recipes/2d/screen_shake/
export var shake_decay = 0.8 # How quickly the shaking stops [0, 1].
export var shake_max_offset = Vector2(15, 15)  # Maximum hor/ver shake in pixels.

var shake_trauma = 0.0  # Current shake strength.
var shake_trauma_power = 2  # Trauma exponent. Use [2, 3].

#used to zoom in and out smoothly for camera effects
var zoomSFXOffset = 0.0
var zoomInSFXTween = null
var zoomOutSFXTween = null

var myZoomInSFXTween = null
var myZoomOutSFXTween = null

#the flase wall/ceiling offset the player's current sprite frame applies
#some aniamtion may raise ceiling
var p1FalseWallOffset= 0
var p1FalseCeilingOffset = 0
var p2FalseWallOffset= 0
var p2FalseCeilingOffset= 0


var p1CameraPositionOffset=Vector2(0,0)
var p2CameraPositionOffset=Vector2(0,0)

var camera_rect = Rect2()
var bb_rect = Rect2()
var viewport_rect = Rect2()
const frameTimerResource = preload("res://frameTimer.gd")
const MyTweenResource = preload("res://MyTween.gd")

var players = []

var manualControlFirstTimeCallFlag=false
var boundingBox = null
#var leftWall = null
#var rightWall = null
#var ceiling = null

var GLOBALS = preload("res://Globals.gd")
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD

var ripostingEffect = false
var reverseRipostingEffect = false
var ripostingFrames = 0
var ripostingTotalTime = 0

var gameMode = null
#var cameraFollowTween = null
var interpolating = false

var zoomInSFXTweenDefaultSpeed = 1
var zoomOutSFXTweenDefaultSpeed = 1

var disconnectedFromPlayerFlagMap={}
var lastPlayerPositionMap={}

var cameraStateMap = {}

var cameraFollowSmoothlyTween = null
var myCameraFollowSmoothlyTween = null
#var cameraFollowSmoothlyEndTween = null
var defaultCameraFollowSmoothlyTweenSpeed = null
#var defaultCameraFollowSmoothlyEndTweenSpeed = null
var interpolatingCamPosition = false
var smootCameraMovement = false

var defaultOffset=null
var defaultZoom = null
var cameraState = 0

var snappingBackSmoothlyEndOffsetEpsilon = 5
var snappingBackSmoothlyEnd = false

var inHitFreezeFlag = false

var playersNode = null

var spriteCenter = null
func _ready():
	
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	set_physics_process(false)
	

 
	pass
	
	
	
func setGlobalSpeedMod(mod):
	globalSpeedMod=mod
	#adjustTweenSpeed()
	
#matches the speed to the global speed mod
func adjustTweenSpeed():
	zoomInSFXTween.playback_speed = zoomInSFXTweenDefaultSpeed * globalSpeedMod
	zoomOutSFXTween.playback_speed = zoomOutSFXTweenDefaultSpeed * globalSpeedMod	

	#cameraFollowSmoothlyTween.playback_speed = defaultCameraFollowSmoothlyTweenSpeed * globalSpeedMod
	#cameraFollowSmoothlyEndTween.playback_speed = defaultCameraFollowSmoothlyEndTweenSpeed * globalSpeedMod
	
func init(_limit_bottom,_limit_top,_limit_right,_limit_left,_playersNode, _boundingBox,initialPosition,_gameMode):
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	playersNode = _playersNode
	gameMode = _gameMode
	zoomInSFXTween = $ZoomInTween
	zoomOutSFXTween = $ZoomOutTween
	
	spriteCenter = get_parent().get_node("cameraCenterSprite")
	
	myZoomInSFXTween = $myRipostZoomInTween
	myZoomOutSFXTween = $myRipostZoomOutTween

	defaultOffset = self.offset
	defaultZoom = self.zoom
	
	zoomInSFXTweenDefaultSpeed=zoomInSFXTween.playback_speed
	zoomOutSFXTweenDefaultSpeed=zoomOutSFXTween.playback_speed
	
	
	position = initialPosition 
	zoomInSFXTween.connect("tween_completed",self,"_on_zoom_in_tween_complete")
	zoomOutSFXTween.connect("tween_completed",self,"_on_zoom_out_tween_complete")
	
	myZoomInSFXTween.connect("finished",self,"_on_zoom_in_tween_complete")
	myZoomOutSFXTween.connect("finished",self,"_on_zoom_out_tween_complete")
	#cameraFollowTween = Tween.new()
	#self.add_child(cameraFollowTween)
	
	
	viewport_rect = get_viewport_rect()
	
	#boundingBox = $boundingBox
	boundingBox=_boundingBox
	
	#limit the bounding box based on min and max zoom
	
	boundingBox.maxWidth = self.maxZoom * viewport_rect.size.x/2
	boundingBox.maxHeight = self.maxZoom * viewport_rect.size.y/2
	
	boundingBox.minWidth = self.minZoom * viewport_rect.size.x/2
	boundingBox.minHeight = self.minZoom * viewport_rect.size.y/2
	#leftWall = $"left-false-wall"
	#rightWall = $"right-false-wall"
	#ceiling = $"false-ceiling"
	
	
	limit_bottom=_limit_bottom
	limit_top=_limit_top
	limit_right=_limit_right
	limit_left=_limit_left

	
#	var playersNode = $players
	
	#look for player children
	for c in playersNode.get_children():
		if c is KinematicBody2D:
			players.append(c)
			disconnectedFromPlayerFlagMap[c]=false
			#lastPlayerPositionMap[c]=c.position
			lastPlayerPositionMap[c]=c.getCenter()
			c.playerController.actionAnimeManager.spriteAnimationManager.connect("sprite_frame_activated",self,"_on_sprite_frame_activated",[c])
			cameraStateMap[c] = CameraState.ATTACHED
	
	
	
	#cameraFollowSmoothlyTween = MyTweenResource.new()
	myCameraFollowSmoothlyTween =MyTweenResource.new()
	#cameraFollowSmoothlyTween.playback_process_mode = cameraFollowSmoothlyTween.TWEEN_PROCESS_PHYSICS
	#self.add_child(cameraFollowSmoothlyTween)
	self.add_child(myCameraFollowSmoothlyTween)
	#defaultCameraFollowSmoothlyTweenSpeed = cameraFollowSmoothlyTween.playback_speed
	#cameraFollowSmoothlyEndTween = Tween.new()
	#defaultCameraFollowSmoothlyEndTweenSpeed = cameraFollowSmoothlyEndTween.playback_speed
	#cameraFollowSmoothlyEndTween.connect("tween_completed",self,"_on_follow_camera_smoothly_endtween_completed")
	#self.add_child(cameraFollowSmoothlyEndTween)
	
	interpolatingCamPosition = false
	adjustTweenSpeed()
	
	#only process camera if has players
	set_physics_process(players.size() > 0)
	
	#boundingBox.init(self)
	
	
	var cameraCenterSprite = get_parent().get_node("cameraCenterSprite")
	if not debug_mode:
		cameraCenterSprite.visible = false
	else:
		cameraCenterSprite.visible = true
		
	pass
func reset():
	p1CameraPositionOffset=Vector2(0,0)
	p2CameraPositionOffset=Vector2(0,0)
	#look for player children
	for c in playersNode.get_children():
		if c is KinematicBody2D:	
			disconnectedFromPlayerFlagMap[c]=false
			#lastPlayerPositionMap[c]=c.position
			lastPlayerPositionMap[c]=c.getCenter()			
			cameraStateMap[c] = CameraState.ATTACHED
			
		if c is frameTimerResource:
			#if c.is_physics_processing():
				#c.emit_signal("timeout")
				#c.stop()
			c.reset()
	
	adjustTweenSpeed()
	snappingBackSmoothlyEnd = false	
	interpolatingCamPosition = false
	interpolating =false
	camera_rect = Rect2()
	bb_rect = Rect2()
	manualControlFirstTimeCallFlag=false
	viewport_rect = get_viewport_rect()
	zoomSFXOffset=0
	
	ripostingEffect = false
	myZoomInSFXTween.stop()
	myZoomOutSFXTween.stop()
	myZoomInSFXTween.init()
	myZoomOutSFXTween.init()

	
	myCameraFollowSmoothlyTween.stop()
	myCameraFollowSmoothlyTween.init()
	zoom =defaultZoom
	offset=defaultOffset
	
func computeScreenCenter():
	
	var minPos = computeMinimumPointBoundary()
	var maxPos = computeMaximumPointBoundary()
	
	var screenRect = Rect2(minPos,Vector2())
	screenRect = screenRect.expand(maxPos)
	return calculate_center(screenRect)
	
#func _on_zoom_in_tween_complete(object,key):
func _on_zoom_in_tween_complete():
	
	#wait a moement before zooming out again
	var tmpFrameTimer = frameTimerResource.new()
	add_child(tmpFrameTimer)
	
	
	if gameMode == GLOBALS.GameModeType.ONLINE_HOSTING or gameMode == GLOBALS.GameModeType.ONLINE_CONNECTING_TO_HOST:
		#make tween deterministic in online mode
		#tmpFrameTimer.fixedDeltaFlag = true
		pass
	
	tmpFrameTimer.startInSeconds(ripostRemainZoomedInDuration)
	
	#wait for a duration before speeding backup again
	yield(tmpFrameTimer,"timeout")
	
	remove_child(tmpFrameTimer)
	
	var startingOffset=zoomSFXOffset
	var endingOffset=0
	var duration = 0.4
	
	#myZoomOutSFXTween.speed=zoomOutSpd
	#myZoomOutSFXTween.acceleration=zoomOutAccel


	myZoomOutSFXTween.start_interpolate_property(self,"zoomSFXOffset",startingOffset,endingOffset,ripostZoomOutDuration)
	#zoomOutSFXTween.interpolate_property(self,"zoomSFXOffset",startingOffset,endingOffset,duration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	#zoomOutSFXTween.start()
	
	
#func _on_zoom_out_tween_complete(object,key):
func _on_zoom_out_tween_complete():
	ripostingEffect = false

	
func _on_ripost(shakeFlag):
	zoomSFXOffset=0
	ripostingEffect = true
	#reverseRipostingEffect = false
	#ripostingTotalTime=0
	#ripostingFrames=0
	var startingOffset=zoomSFXOffset
	var endingOffset=0.2
	var duration = 0.4 #0.8 seconds
	
	if shakeFlag:
		set_shake_trauma(0.6)

	#myZoomInSFXTween.speed=zoomInSpd
	#myZoomInSFXTween.acceleration=zoomInAccel
	myZoomInSFXTween.start_interpolate_property(self,"zoomSFXOffset",startingOffset,ripostZoomOffset,ripostZoomInDuration)
#	zoomInSFXTween.interpolate_property(self,"zoomSFXOffset",startingOffset,endingOffset,duration,Tween.TRANS_QUAD,Tween.EASE_OUT)
#	zoomInSFXTween.start()

func _on_grab_auto_riposter():
	zoomSFXOffset=0
	ripostingEffect = true
	#reverseRipostingEffect = false
	#ripostingTotalTime=0
	#ripostingFrames=0
	var startingOffset=zoomSFXOffset
	var endingOffset=0.05
	var duration = 0.8 #0.8 seconds

	#myZoomInSFXTween.speed=zoomInSpd
	#myZoomInSFXTween.acceleration=zoomInAccel
	myZoomInSFXTween.start_interpolate_property(self,"zoomSFXOffset",startingOffset,ripostZoomOffset,ripostZoomInDuration)

func _physics_process(delta):
	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	delta = delta * globalSpeedMod
	
	if not manualCameraControl:
		#print(str(zoomSFXOffset))
		#applyRipostEffect(delta)
	#	# Called every frame. Delta is time since last frame.
	#	# Update game logic here.
		
		
		if not inHitFreezeFlag:
			processCameraRect(delta)
			processBBRect(delta)
			
		updateZoom(camera_rect)
		
		if not inHitFreezeFlag:
			updateBoundingBox(bb_rect)
	
		
	else:
	
		if not manualControlFirstTimeCallFlag:
			
			if not inHitFreezeFlag:
				processCameraRect(delta)
				processBBRect(delta)
				
			updateZoom(camera_rect)
			
			if not inHitFreezeFlag:
				updateBoundingBox(bb_rect)
		
			manualControlFirstTimeCallFlag = true
		else:
		
			if Input.is_action_pressed("ui_up"):
				offset+= (Vector2(0, -1)*delta*500)
			if Input.is_action_pressed("ui_down"):
				offset+= (Vector2(0, 1)*delta*500)
			
			if Input.is_action_pressed("ui_left"):
				offset+= (Vector2(-1, 0)*delta*500)
			
			if Input.is_action_pressed("ui_right"):
				offset+= (Vector2(1, 0)*delta*500)
			
		
	#leftWall.position.x = zoom.x * viewport_rect.size.x
	if debug_mode:
		update()
		
	
	spriteCenter.position = offset+position
	
	#camera shaking?
	if shake_trauma:
		#decay the shake so it eventually stops
		shake_trauma = max(shake_trauma - shake_decay * delta, 0)
		
		#apply the shake
		var amount = pow(shake_trauma, shake_trauma_power)
		offset.x = offset.x+(shake_max_offset.x * amount * rand_range(-1, 1))
		offset.y = offset.y+(shake_max_offset.y * amount * rand_range(-1, 1))
	pass

func processCameraRect(delta):
	#only base the rectable left corner on player if attached
		if cameraStateMap[players[PLAYER1_IX]] == CameraState.DETTACHED:		
			#camerea rectangle is based on last position of player
			camera_rect = Rect2(lastPlayerPositionMap[players[PLAYER1_IX]]-position,Vector2())
		else:
			#camera_rect = Rect2(players[PLAYER1_IX].position,Vector2())
			camera_rect = Rect2(players[PLAYER1_IX].getCenter()+p1CameraPositionOffset-position,Vector2())
			
		
		#only base the rectable right corner on player if attached
		if cameraStateMap[players[PLAYER2_IX]] == CameraState.DETTACHED:		
			#camerea rectangle is based on last position of player
			camera_rect = camera_rect.expand(lastPlayerPositionMap[players[PLAYER2_IX]]-position)
		else:
			#camera_rect = camera_rect.expand(players[PLAYER2_IX].position)
			camera_rect = camera_rect.expand(players[PLAYER2_IX].getCenter()+p2CameraPositionOffset-position)
		
	
		var targetOffset = calculate_center(camera_rect)
		#only doing smooth camera movement when sprite frame indicates so, or if we finished 
		#dettaching from player and need to snap back smootly
		#this is true when snap back to player after discnonect camerea
		#if smootCameraMovement:
		
		
		if cameraStateMap[players[PLAYER1_IX]] == CameraState.SMOOTH_FOLLOW or cameraStateMap[players[PLAYER2_IX]] == CameraState.SMOOTH_FOLLOW or snappingBackSmoothlyEnd:
			
			moveCameraSmoothly(targetOffset)
		else:
			#move camera normaly
			offset = targetOffset
		
		if snappingBackSmoothlyEnd and (offset.distance_to(targetOffset) <= snappingBackSmoothlyEndOffsetEpsilon): #now check if camera center we arrived to target offset withint esilon
			
			#snappingBackSmootly=false
			#snap it back
			offset = targetOffset
			snappingBackSmoothlyEnd = false
		#	if not cameraFollowSmoothlyEndTween.is_active():
			#cameraFollowSmoothlyTween.stop_all()
			#cameraFollowSmoothlyEndTween.stop_all()
			#cameraFollowSmoothlyEndTween.interpolate_property(self,"offset",offset,targetOffset,cameraSnapBackTimeRequired,Tween.TRANS_LINEAR, Tween.EASE_IN)
			#cameraFollowSmoothlyEndTween.start()

func processBBRect(delta):
		var p1Center = players[PLAYER1_IX].getCenter()
		var p2Center = players[PLAYER2_IX].getCenter()
		
		p1Center.x = p1Center.x+p1FalseWallOffset
		p1Center.y = p1Center.y+p1FalseCeilingOffset
		
		p2Center.x = p2Center.x+p2FalseWallOffset
		p2Center.y = p2Center.y+p2FalseCeilingOffset
		
		#only base the rectable left corner on player if attached
		if cameraStateMap[players[PLAYER1_IX]] == CameraState.DETTACHED:		
			#camerea rectangle is based on last position of player
			bb_rect = Rect2(lastPlayerPositionMap[players[PLAYER1_IX]]-position,Vector2())
		else:
			
			#the center of bounding box only ever moves up if both players in the air.
			#if one on ground, they controll the ceiling, and it's as if both player on ground
			
			var playerCenter=p1Center
			playerCenter.y = max(p1Center.y,p2Center.y)
			#player 2 on ground while player 1 in air?
			#if players[PLAYER2_IX].playerController.my_is_on_floor() and  (not players[PLAYER1_IX].playerController.my_is_on_floor()):
				
			#	playerCenter.y =p2Center.y
				
			bb_rect = Rect2(playerCenter-position,Vector2())
			
		
		#only base the rectable right corner on player if attached
		if cameraStateMap[players[PLAYER2_IX]] == CameraState.DETTACHED:		
			#camerea rectangle is based on last position of player
			bb_rect = bb_rect.expand(lastPlayerPositionMap[players[PLAYER2_IX]]-position)
		else:
			#camera_rect = camera_rect.expand(players[PLAYER2_IX].position)
			
			var playerCenter=p2Center
			playerCenter.y = max(p1Center.y,p2Center.y)
			##player 1 on ground while player 2 in air?
			#if players[PLAYER1_IX].playerController.my_is_on_floor() and  (not players[PLAYER2_IX].playerController.my_is_on_floor()):
				
			#	playerCenter.y =p1Center.y
				
				
			bb_rect = bb_rect.expand(playerCenter-position)
		
		#apply flase wall offset
		#bb_rect.position.x = bb_rect.position.x+p1FalseWallOffset+p2FalseWallOffset
		#bb_rect.position.y = bb_rect.position.y+p1FalseCeilingOffset+p2FalseCeilingOffset
#		p1Center.x = p1Center.x+p1FalseWallOffset
#		p1Center.y = p1Center.y+p1FalseCeilingOffset
		
#		p2Center.x = p2Center.x+p2FalseWallOffset
#		p2Center.y = p2Center.y+p2FalseCeilingOffset
			

#returns true if a point is outside camera
#offset is the amount the decision is being pushed toward center of
#camera, so xOffset = 50 means anything outstide right or left bounds or 50 pixels inside is 
#considered out of bounds
func isOutsideCamera(point, rightOffScreenOffset,leftOffScreenOffset,topOffScreenOffset,botOffScreenOffset):
	
	
	
	#var center = calculate_center(camera_rect)
	#var cameraLimitRight =computeRelativeRightBoundary()
	#var cameraLimitLeft = computeRelativeLeftBoundary()
	#var cameraLimitTop = computeRelativeTopBoundary()
	#var cameraLimitBot = computeRelativeBotBoundary()
	
	
	
	var minPos = computeMinimumPointBoundary()
	var maxPos = computeMaximumPointBoundary()
	
	if point.x > maxPos.x - rightOffScreenOffset:
		return true
	if point.x < minPos.x + leftOffScreenOffset:
		return true
	if point.y < minPos.y + topOffScreenOffset: #going up on the scree = smaller y
		return true
	if point.y > maxPos.y - botOffScreenOffset:
		return true
		
	return false

func computeMinimumPointBoundary():
		# Get view rectangle
	var ctrans = get_canvas_transform()
	var min_pos = (-ctrans.get_origin() / ctrans.get_scale())
	return min_pos

func computeMaximumPointBoundary():
		# Get view rectangle
	var ctrans = get_canvas_transform()
	var min_pos = -ctrans.get_origin() / ctrans.get_scale()
	
	var view_size = get_viewport_rect().size / ctrans.get_scale()
	var max_pos = min_pos + view_size

	return max_pos
	
func updateZoom(camera_rect):
	zoom = calculate_zoom(camera_rect, viewport_rect.size)

func _on_offset_tween_finished():
	interpolating =false
func updateBoundingBox(rect):

	boundingBox.updateBoundingBox(rect)

func calculate_center(rect):
	return Vector2(
			rect.position.x + rect.size.x/2,
			rect.position.y + rect.size.y/2)

func calculate_zoom(rect,viewport_size):
	
	var xZoom =min(1,(rect.size.x / viewport_size.x) + zoom_offset )
	var yZoom = min(1, (rect.size.y / viewport_size.y) + zoom_offset)
	
	var newZoom = max(xZoom,yZoom)
	
	if newZoom > maxZoom:
		newZoom = maxZoom
	if newZoom < minZoom:
		newZoom = minZoom

	newZoom=newZoom
	
	if ripostingEffect:	
		#return Vector2(newZoom-ripostingTotalTime*ripostZoomInOffset,newZoom-ripostingTotalTime*ripostZoomInOffset)
		return Vector2(newZoom-zoomSFXOffset,newZoom-zoomSFXOffset)
	else:
		return Vector2(newZoom,newZoom)

func _draw():
	if not debug_mode:
		return
	
	var minPos = computeMinimumPointBoundary()
	var maxPos = computeMaximumPointBoundary()
	
	var debugBoundaryRect = Rect2(minPos+Vector2(10,10),Vector2())
	debugBoundaryRect = debugBoundaryRect.expand(maxPos-Vector2(10,10))
	
	
	draw_rect(debugBoundaryRect,Color("#000000"),false)
	draw_circle(calculate_center(debugBoundaryRect),5,Color("#0000"))
	
	#draw the camera rect
	draw_rect(camera_rect,Color("#ffffff"),false)
	draw_circle(calculate_center(camera_rect),5,Color("#ffffff"))
	
	
	
func dettachCameraFromPlayer(player):
	
	#already dettached?
	if cameraStateMap[player] ==CameraState.DETTACHED:
		return
	
	#indicate player dettached from cmaera and save player position
	cameraStateMap[player] = CameraState.DETTACHED
	#lastPlayerPositionMap[player] = player.position
	lastPlayerPositionMap[player] = player.getCenter()
	
	#now make sure the camera offset is considered as well in las tknown position
	#player1?
	if player == players[PLAYER1_IX]:
		
		lastPlayerPositionMap[player]=lastPlayerPositionMap[player]+p1CameraPositionOffset
	else:#player2
		
		lastPlayerPositionMap[player]=lastPlayerPositionMap[player]+p2CameraPositionOffset
	

func attachCameraToPlayer(player):
	
	#already attached?
	if cameraStateMap[player] ==CameraState.ATTACHED:
		return
	cameraStateMap[player] =CameraState.ATTACHED
	
	#indicate that we want to smootly follow player and snap back to player when
	#close enough to prevent big jittering/snapping
	#if not cameraFollowSmoothlyEndTween.is_active():
	snappingBackSmoothlyEnd=true
	#smootCameraMovement=true
	#disconnectedFromPlayerFlagMap[player] = false

func smoothlyFollowPlayer(player):
	#already following smoothly?
	if cameraStateMap[player] ==CameraState.SMOOTH_FOLLOW:
		return
	cameraStateMap[player] =CameraState.SMOOTH_FOLLOW
	

func moveCameraSmoothly(newOffset):
	
	#cameraFollowSmoothlyTween.stop_all()
	myCameraFollowSmoothlyTween.stop()
	
	#cameraFollowSmoothlyTween.interpolate_property(self,"offset",offset,newOffset,cameraFollowTimeRequired,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	myCameraFollowSmoothlyTween.start_interpolate_property(self,"offset",offset,newOffset,cameraFollowTimeRequired)
	
#	cameraFollowSmoothlyTween.start()

func _on_sprite_frame_activated(spriteFrame, player):

	match(spriteFrame.cameraBehavior):
		spriteFrame.CameraBehavior.ATTACHED:
			attachCameraToPlayer(player)
		spriteFrame.CameraBehavior.DETTACHED:
			dettachCameraFromPlayer(player)
		spriteFrame.CameraBehavior.SMOOTH_FOLLOW:
			smoothlyFollowPlayer(player)


	#player1?
	if player == players[PLAYER1_IX]:
		p1CameraPositionOffset.y=spriteFrame.cameraPositionOffset.y

		p1FalseCeilingOffset = spriteFrame.falseCeilingOffset
		#positive p1FalseWallOffset offset means false walls behave as if player is further forward
		#negative p1FalseWallOffset offset means false walls behave as if player is further back
		#mirror offset based on player facing
		if player.facingRight:
			p1CameraPositionOffset.x=spriteFrame.cameraPositionOffset.x
			p1FalseWallOffset= spriteFrame.falseWallOffset			
		else:
			p1CameraPositionOffset.x=-spriteFrame.cameraPositionOffset.x
			p1FalseWallOffset= -spriteFrame.falseWallOffset			
	else:#player2
		p2CameraPositionOffset.y=spriteFrame.cameraPositionOffset.y
		p2FalseCeilingOffset = spriteFrame.falseCeilingOffset
		
		if player.facingRight:
			p2CameraPositionOffset.x=spriteFrame.cameraPositionOffset.x
			p2FalseWallOffset= spriteFrame.falseWallOffset			
		else:
			p2CameraPositionOffset.x=-spriteFrame.cameraPositionOffset.x
			p2FalseWallOffset= -spriteFrame.falseWallOffset					


	
	
	
func _on_hit_freeze_finished():
	inHitFreezeFlag=false
	#reset_shake_trauma()
	#self.set_physics_process(true)
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	
	inHitFreezeFlag=true
	#add_shake_trauma(inverse_lerp(0,15,duration))
	#add_shake_trauma(0.3)
	#self.set_physics_process(false)
	


func atleast1PlayerOnGround():
	return players[PLAYER1_IX].playerController.my_is_on_floor() or players[PLAYER2_IX].playerController.my_is_on_floor()
	
	
#shaking intesity set here
func set_shake_trauma(amount):
	#print("shaking by: "+str(amount))
	shake_trauma =amount
#stop shaking 
func reset_shake_trauma():
	
	shake_trauma =0
	
func computeScreenRect2D():
	var minPos = computeMinimumPointBoundary()
	var maxPos = computeMaximumPointBoundary()
	
	var screenRect = Rect2(minPos,Vector2())
	screenRect = screenRect.expand(maxPos)
	return screenRect