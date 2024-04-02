extends "EnvironmentStaticBody2D.gd"


const MyTweenResource = preload("res://MyTween.gd")
export (float) var smoothAwaySpeed = 1 #away and toward are mirrored depending on x direction. so gotta mirror these for left/right walls
export (float) var smoothTowardSpeed = 1#away and toward are mirrored depending on x direction. so gotta mirror these for left/right walls

export (float) var moveRightSpeed = 1 
export (float) var moveLeftSpeed = 1
export (float) var moveRightDuration = 1 
export (float) var moveLeftDuration = 1

export (float) var moveUpSpeed = 1 
export (float) var moveDownSpeed = 1
export (float) var moveUpDuration = 1 
export (float) var moveDownDuration = 1



export (float) var moveRightAcceleration= 0
export (float) var moveLeftAcceleration = 0
export (float) var moveUpAcceleration = 0
export (float) var moveDownAcceleration = 0


export (bool) var debug_mode = false

export (bool) var isCeiling = false

#members for controlling transparency of wall based on nearest player's distance to wall
export (float,0,1) var fromPlayerDistTranparancyAlpha=1 #alpha transparency value when nereast player is within min threshold distance to wall
export (float,0,1) var toPlayerDistTranparancyAlpha=0.25#alpha transparency value when nereast player is away from max threshold distance to wall
export (float) var maxPlayerDistanceThreshold=300
export (float) var minPlayerDistanceThreshold=80

var playerDistanceAnchor = null

var ceilingLockedFlag = false
var wallLockedFlag = false

var collisionShape =  null

var smoothMovementTween = null
var mySmoothMovementXTween = null
var mySmoothMovementYTween = null

var sprite = null
var interpolatingY = false
var interpolatingX = false

var recSize = null


var GLOBALS = preload("res://Globals.gd")


#changing this will globaly alter speed of animations
var globalSpeedMod = GLOBALS.DEFAULT_GLOBAL_SPEED_MOD


var defaultTweenSpeed = 1

var disablePermanently = false

var defaultPosition = null

var hitFreezePausedMvm=false

var player1=null
var player2=null

var locked = false

#index used to represent what type of tech we can do off this environemnt
var techIx = null
var electricitySprite = null


var gradientTexture = null
var defaultGrdTextureModulate = null
export (Color) var lockedGrdTextureModulate = Color(1,1,1,1)
export (Color) var techableBounceHighlightTextureModulate = Color(0,0.91,1,0.4)
export (Color) var untechableBounceHighlightTextureModulate = Color(0.83,0,0.83,0.5)

func _ready():
	
	
		
	#make sure this node is part of group that gets notification
	#on global speed mod change
	add_to_group(GLOBALS.GLOBAL_SPEED_MOD_GROUP)
	add_to_group(GLOBALS.GLOBAL_HITFREEZE_GROUP)
	
	self.set_physics_process(true)
	
	
	defaultPosition = self.position
		
	sprite = $CollisionShape2D/sprites
	
	electricitySprite = $CollisionShape2D/sprites/electricity
	
	gradientTexture = $CollisionShape2D/sprites/gradientTexture
	defaultGrdTextureModulate = gradientTexture.modulate

	collisionShape = $"CollisionShape2D"
	
	recSize = Vector2(collisionShape.get_shape().extents.x,collisionShape.get_shape().extents.y)
	
	playerDistanceAnchor = $"CollisionShape2D/playerDistanceAnchor"
	
	
	#smoothMovementTween = MyTweenResource.new()
	#smoothMovementTween.playback_process_mode = Tween.TWEEN_PROCESS_PHYSICS
	#self.add_child(smoothMovementTween)
	#defaultTweenSpeed = smoothMovementTween.playback_speed
	
	
	mySmoothMovementXTween = MyTweenResource.new()
	mySmoothMovementXTween.connect("finished",self,"_on_x_pos_tween_finished")
	
	
	self.add_child(mySmoothMovementXTween)

	mySmoothMovementYTween = MyTweenResource.new()
	mySmoothMovementYTween.connect("finished",self,"_on_y_pos_tween_finished")
	self.add_child(mySmoothMovementYTween)
	
	mySmoothMovementXTween.maxSpeed = 1000
	mySmoothMovementYTween.maxSpeed = 1000
	#adjustTweenSpeed()
	#var new_zoom = calculate_zoom(camera_rect, viewport_rect.size)
	#var posNodePath = NodePath(str(self.get_path())+":position").get_as_property_path()
	
	#if not interpolating:
	#	interpolating = true
	#	cameraFollowTween.stop_all()
	
	#	cameraFollowTween.start()
	#	cameraFollowTween.interpolate_callback(self,zoomFollowSpeed,"_on_offset_tween_finished")
	#	cameraFollowTween.start()
	
		
	pass
	
	
func reset():
	ceilingLockedFlag = false
	wallLockedFlag = false

	mySmoothMovementXTween.stop()
	mySmoothMovementYTween.stop()

	interpolatingY = false
	interpolatingX = false

	disablePermanently = false

	hitFreezePausedMvm=false

	locked = false
	
	resetToDefaultPosition()

func init(p1Kinbody,p2Kinbody,_techIx):
	player1=p1Kinbody
	player2=p2Kinbody
	
	techIx=_techIx
	locked = false

func setGlobalSpeedMod(mod):
	globalSpeedMod=mod
	#adjustTweenSpeed()
	pass
	
func disable():
	
	collisionShape.disabled = true
	
	if sprite != null:
		sprite.visible = false	
	
func enable():
	
	if disablePermanently:
		collisionShape.disabled = true
		if sprite != null:
			sprite.visible = false
		return
	
	if sprite != null:
		sprite.visible = true		
	collisionShape.disabled = false
	
func _draw():
	if not debug_mode:
		return
		
	var pos = collisionShape.position
	pos.x = pos.x - recSize.x
	var size = recSize
	size.x = size.x*2
	draw_rect(Rect2(pos,size),Color("#ffffff"),false)
	#draw_circle(calculate_center(camera_rect),5,Color("#ffffff"))
	
func _on_x_pos_tween_finished():
	interpolatingX = false
	
func _on_y_pos_tween_finished():
	interpolatingY = false
func setXPosition(x):
	
	if locked:
		return
		
	if not interpolatingX:
		interpolatingX = true
		#smoothMovementTween.stop_all()
		mySmoothMovementXTween.stop()
		#var spd = 0
		
		#if x < position.x:
		#	spd = smoothAwaySpeed
		#else:
		#	spd = smoothTowardSpeed
			
				
		if x < position.x:
			mySmoothMovementXTween.speed = moveLeftSpeed
			mySmoothMovementYTween.acceleration=moveLeftAcceleration
			mySmoothMovementXTween.start_interpolate_property(self,"position",position,Vector2(x,position.y),moveLeftDuration)
		else:
			mySmoothMovementXTween.speed = moveRightSpeed
			mySmoothMovementYTween.acceleration=moveRightAcceleration
			mySmoothMovementXTween.start_interpolate_property(self,"position",position,Vector2(x,position.y),moveRightDuration)
		
#		spd = spd * globalSpeedMod
		#smoothMovementTween.interpolate_property(self,"position",null,Vector2(x,position.y),spd,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		#smoothMovementTween.start()
		#smoothMovementTween.interpolate_callback(self,spd,"_on_x_pos_tween_finished")
		#smoothMovementTween.start()
		
		#smoothMovementTween.interpolate_property(self,"position",null,Vector2(x,position.y),spd,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		#smoothMovementTween.start()

	
	pass
func setYPosition(y):
	if locked:
		return
		
	#position.y = y
	if not interpolatingY:
		
			
		interpolatingY = true
	#	smoothMovementTween.stop_all()
		mySmoothMovementYTween.stop()
		
		if y > position.y:
			
		
				
			mySmoothMovementYTween.speed = moveDownSpeed
			mySmoothMovementYTween.acceleration=moveDownAcceleration
			
			#mySmoothMovementYTween.stop()
			mySmoothMovementYTween.start_interpolate_property(self,"position",position,Vector2(position.x,y),moveDownDuration)
		else:
			
			var applyMvmFlag = true
			
			#we only move ceiling up if both players are in the air			
			#if isCeiling:
			#	if player1.playerController.my_is_on_floor() or player2.playerController.my_is_on_floor():
			#		applyMvmFlag=false
			
			if applyMvmFlag:
				
				
				
				mySmoothMovementYTween.speed = moveUpSpeed
				mySmoothMovementYTween.acceleration=moveUpAcceleration
				#mySmoothMovementYTween.stop()
				mySmoothMovementYTween.start_interpolate_property(self,"position",position,Vector2(position.x,y),moveUpDuration)
			else:
				interpolatingY = false

func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	if debug_mode:
		update()
		

	updatePlayerDistanceBasedTransparancy()
	
	

func updatePlayerDistanceBasedTransparancy():
	#update transparancy based on nearest player 	
	
	var p1Pos = player1.getCenter()
	var p2Pos = player2.getCenter()
	
	if type == TYPE_CEILING: #ceiling
		
		#ignore x distance
		p1Pos.x=playerDistanceAnchor.position.x
		p2Pos.x=playerDistanceAnchor.position.x
	else: #wall
		#ignore y distance
		p1Pos.y=playerDistanceAnchor.position.y
		p2Pos.y=playerDistanceAnchor.position.y
		

	
	var p1Dist = playerDistanceAnchor.global_position.distance_to(p1Pos)
	var p2Dist = playerDistanceAnchor.global_position.distance_to(p2Pos)
	
	var minDist = min(p1Dist,p2Dist)
	

	#clamp the value between dsitance ranges
	minDist=clamp(minDist,minPlayerDistanceThreshold,maxPlayerDistanceThreshold)
	
	#converts the distance form 0 to 1 ratio, 0 mining equal to or less than minimum distnace
	#and 1 being max or more distance away
	#then
	#1- so that 0 means full distance away so 0 alpha (max transparency)
	# and 1 means close to wall so 1 alpha (no transparencY0
	var distRatio =1- inverse_lerp(minPlayerDistanceThreshold,maxPlayerDistanceThreshold,minDist)
	
		#var middle = lerp(20, 30, 0.75)
# `middle` is now 27.5.
	var alpha = lerp(toPlayerDistTranparancyAlpha,fromPlayerDistTranparancyAlpha,distRatio)
	self.modulate.a= alpha
	
	pass


func resetToDefaultPosition():
	self.position = defaultPosition
	

	
func _on_hit_freeze_finished():
	pass
	
	#paused wall movement?
	#if hitFreezePausedMvm:
	#	hitFreezePausedMvm=false
		#restart moving the walls
	#	smoothMovementTween.resume_all()

	
# warning-ignore:unused_argument
func _on_hit_freeze_started(duration):
	pass
	#wall is moving?
	#if interpolatingY or interpolatingX:
	#	hitFreezePausedMvm=true
		#pause the walls
		#smoothMovementTween.stop_all()
		
#func _on_player_landed(player):
	#only the ceiling will 
#	if isCeiling:


func _on_player_hit_environment(collider,player):
	#play hit this wall/ceiling?
	if collider == self:
		
		#only blink when hitstunplayer hits the wall
		if player.playerController.playerState.inHitStun:
			
			#blink wall from hitting it
			
			#we decide what color wall highlight is based on if techable
			if player.playerController.techHandler.canBeTeched(techIx):
				
				electricitySprite.startAnimation(techableBounceHighlightTextureModulate)
				
			else:
				electricitySprite.startAnimation(untechableBounceHighlightTextureModulate)
				
				
		
		#below is how I would add a shader dynamically if required
		#const flagShaderResource = preload("res://interface/shaders/flag-wave.shader")
		#gradientTexture.material =ShaderMaterial.new()
		#gradientTexture.material.shader =flagShaderResource		


func _on_player_landed():
	pass
	#if isCeiling:		
	#		interpolatingY = false	
	#		mySmoothMovementYTween.stop()
func setLocked(flag):
	locked = flag
	
	#stops the false wall mvm when locked
	if locked:
		gradientTexture.modulate = lockedGrdTextureModulate
		interpolatingX = false
		interpolatingY = false
		
		mySmoothMovementXTween.stop()	
		mySmoothMovementYTween.stop()
	else:
			
		gradientTexture.modulate=defaultGrdTextureModulate


	