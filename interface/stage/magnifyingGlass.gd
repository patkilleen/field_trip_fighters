extends Node2D
const GLOBALS = preload("res://Globals.gd")
export (float) var radius = 60 setget setRadius,getRadius
export (float) var pointerAngle = 0 setget setPointerAngle,getPointerAngle
#how far away magnifying glass is from edge of screen
export (float) var margin = 80
export (float) var scaleSubtractFactorPerPixel = 0.3/100.0 #20% scale for each 100 pixel = 0.2/100 = 
export (float) var minScale = 0.5
export (float) var scaleReduceProjectileFactor = 1.2
export (Texture) var player1Background = null
export (Texture) var player2Background = null
export (Texture) var player1Arrow = null
export (Texture) var player2Arrow = null

var spriteOffset = null

var pointerSprite = null

#copy of the sprite that will be in magnifying glass (should share a texture resource)
var cloneSprite = null
var targetSprite = null

var bgd = null

#the thing we are aiming for
var targetNode2D = null
var gameObject = null
var camera= null

var enabled = false

#var firstcall = true

var defaultScale = Vector2()
var defaultDefaultScale = Vector2()

var isProjectile = false
enum ObjectType{
	PLAYER,
	PROJECTILE
}
const PLAYER1 = 1
const PLAYER2 = 2

func _ready():
	
	pointerSprite = $pointer
	cloneSprite = $Node2D/target
	defaultScale = self.scale
	
	bgd = $background
	disable()
		
	
func enable(_targetSprite, _targetNode2D, _camera,_gameObject,isProjectileFlag,player,_spriteCurrentlyFacingRight):
	
	
			
	if (_targetSprite == null or _targetNode2D == null or _camera == null or _gameObject == null):
		print("warning, could not init magnifying glass, null parameters")
		return
	
	if isProjectileFlag:
		defaultScale = defaultScale/Vector2(scaleReduceProjectileFactor,scaleReduceProjectileFactor)
		#half thee scale, projectiles are small
		self.scale = defaultScale
		
	#decide what collor the magnifying glass is
	if player == PLAYER1:
		bgd.texture = player1Background
		pointerSprite.texture = player1Arrow
	else:
		bgd.texture = player2Background
		pointerSprite.texture = player2Arrow
	
	#connect once to the necessary signals (don't connect more than once)
	#
	if not _targetSprite.is_connected("new_sprite_texture",self,"_on_new_sprite_texture"):
		_targetSprite.connect("new_sprite_texture",self,"_on_new_sprite_texture")
	if not _targetSprite.is_connected("new_sprite_position",self,"_on_new_sprite_position"):
		_targetSprite.connect("new_sprite_position",self,"_on_new_sprite_position")
	if not _gameObject.is_connected("changed_sprite_facing",self,"_on_changed_sprite_facing"):
		_gameObject.connect("changed_sprite_facing",self,"_on_changed_sprite_facing")
		
	#obj.connect("changed_sprite_facing",mg,"_on_changed_sprite_facing")
	#if not _gameObject.is_connected("changed_facing",self,"_on_changed_facing"):
	#	_gameObject.connect("changed_facing",self,"_on_changed_facing")
		
		
	#copy over the sprite into magnyfing glass
	spriteOffset = _gameObject.magnifyingGlassSpriteOffset
	cloneSprite.texture = _targetSprite.texture
	cloneSprite.position = _targetSprite.position +spriteOffset
	
	isProjectile =isProjectileFlag
	targetSprite = _targetSprite
	targetNode2D= _targetNode2D
	camera = _camera
	enabled = true
	
	
	_on_changed_sprite_facing(_spriteCurrentlyFacingRight)
	
	set_visible(true)
	set_physics_process(true)
	
	
func disable():
	
	#only disconnect form signals when previously connect
	if (targetSprite != null):
	
		if targetSprite.is_connected("new_sprite_texture",self,"_on_new_sprite_texture"):
			targetSprite.disconnect("new_sprite_texture",self,"_on_new_sprite_texture")
		if targetSprite.is_connected("new_sprite_position",self,"_on_new_sprite_position"):
			targetSprite.disconnect("new_sprite_position",self,"_on_new_sprite_position")
		
	if gameObject != null:
	#	if gameObject.is_connect("changed_facing",self,"_on_changed_facing"):
	#		gameObject.disconnect("changed_facing",self,"_on_changed_facing")
		if gameObject.is_connected("changed_sprite_facing",self,"_on_changed_sprite_facing"):
			gameObject.disconnect("changed_sprite_facing",self,"_on_changed_sprite_facing")
	
	targetSprite = null
	gameObject = null
	targetNode2D= null
	camera= null
	enabled = false
	#scale = defaultDefaultScale
	#defaultScale = defaultDefaultScale
	set_visible(false)
	set_physics_process(false)
	

	
func setRadius(r):
	radius = r

func getRadius():
	return radius
	
func setPointerAngle(a):
	pointerAngle = a
	
func getPointerAngle():
	return pointerAngle
	
func repositionPointer():
	
	var newY = sin(pointerAngle * PI / 180) * radius
	var newX = cos(pointerAngle * PI / 180) * radius
	
	pointerSprite.position.x = newX
	pointerSprite.position.y = newY
	
	pointerSprite.rotation_degrees = pointerAngle

func adjustScale():
	
	#rescale to illustrate distance of target object from magnifying glass
	
	var dist =targetNode2D.global_position.distance_to(self.global_position)
	
	#magnifying glass is smaller the further it is from the object off-screen
	var scaleSubtraction = scaleSubtractFactorPerPixel * dist
	
	#don't reduce scale as fast since projectile maginfying glass is smaller
	if isProjectile:
		scaleSubtraction = scaleSubtraction/scaleReduceProjectileFactor
	scale = defaultScale -  Vector2(scaleSubtraction,scaleSubtraction)
	scale.x = max(scale.x,minScale)
	scale.y = max(scale.y,minScale)
	
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	if not enabled:
		return

	
	#get the camera dimensions
	var cameraCenter = camera.computeScreenCenter()
	
	#pointerAngle = rad2deg((targetNode2D.global_position-cameraCenter).angle())	
	pointerAngle = rad2deg((targetNode2D.global_position - self.global_position).angle())	
	
	#point towards the target
	repositionPointer()
	
	adjustScale()
	
	
	var minPos = camera.computeMinimumPointBoundary()
	var maxPos = camera.computeMaximumPointBoundary()
	
	
	var yLimitTop = minPos.y + margin
	var yLimitBot = maxPos.y - margin
	var xLimitRight = maxPos.x - margin
	var xLimitLeft = minPos.x + margin
	
	#position the magnifying glass where the camera_center-targetNode2D vector collides with
	#border of camera (while considering margin)
	if targetNode2D.global_position.x > cameraCenter.x:
		
		#don't exceed right side of camera
		self.position.x = min(xLimitRight,targetNode2D.global_position.x)
		
	else:
		#don't exceed left side of camera
		self.position.x = max(xLimitLeft,targetNode2D.global_position.x)
	
	if targetNode2D.global_position.y > cameraCenter.y:
		
		#don't exceed bottom of camera
		self.position.y = min(yLimitBot,targetNode2D.global_position.y)
		
	else:
		#don't exceed top of camera
		self.position.y = max(yLimitTop,targetNode2D.global_position.y)
	
func _on_new_sprite_texture(texture):
	cloneSprite.texture = texture
	
func _on_new_sprite_position(pos):
	cloneSprite.position = pos+spriteOffset

func _on_changed_sprite_facing(facingRight):
	
	if targetSprite != null:
		if facingRight:
			
			cloneSprite.set_scale(Vector2(1*targetSprite.scale.x,targetSprite.scale.y))
		else:
			cloneSprite.set_scale(Vector2(-1*targetSprite.scale.x,targetSprite.scale.y))
		