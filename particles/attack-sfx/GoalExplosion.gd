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

const frameTimerResource = preload("res://frameTimer.gd")

export (Direction) var direction = 0 setget setDirection,getDirection
export (Texture) var texture = null
export (float) var completionDelay = 1
export (bool) var cached = false
var initialize = false

var yDirectionalPositionOffset = 75
var xDirectionalPositionOffset = 40
var numberFinishedParticles = 0
var numParticles = -1

var expBot = null
var expMain = null
var expTop =null
var expN = null
var expEnd = null

var timer = null

var particles = null

var defaultPosition = null
func _ready():
	pass
func init():	
	particles = $particles
	
	expBot = $particles/ExplosionBottom
	expMain = $particles/ExplosionMain
	expTop = $particles/ExplosionTop
	expN = $particles/ExplosionNeutral
	expEnd= $particles/ExplosionEnding
	
	defaultPosition = position
	for p in $particles.get_children():
		#p.connect("finished",self,"_on_particles_finished")
		p.texture = texture
	
	
	
	#timer = Timer.new()
	timer = frameTimerResource.new()
	#timer.one_shot = true #set to true to indicate don't conitune ticking (only executed once called)
	timer.connect("timeout",self,"_finished_emitting")
	

	self.add_child(timer)
	
	initialize=true

func _finished_emitting():
	
	if not cached:
		#delete this node
		 queue_free()
		
		
func setDirection(d):
	direction = d	
	
	if initialize:
		if direction == Direction.LEFT :
			expBot.rotation_degrees  = 180
			expMain.rotation_degrees  = 180
			expTop.rotation_degrees  = 180
			expEnd.rotation_degrees  = 180
			position.x = defaultPosition.x + xDirectionalPositionOffset
			position.y = defaultPosition.y - 25 # center on player
		elif direction == Direction.UP:
			expBot.rotation_degrees  = 270
			expMain.rotation_degrees  = 270
			expTop.rotation_degrees  = 270
			expEnd.rotation_degrees  = 270
			position.x = defaultPosition.x + 25 # center on player
			position.y = defaultPosition.y  + yDirectionalPositionOffset
		elif direction == Direction.RIGHT:
			expBot.rotation_degrees  = 0
			expMain.rotation_degrees  = 0
			expTop.rotation_degrees  = 0
			expEnd.rotation_degrees  = 0
			position.x = defaultPosition.x- xDirectionalPositionOffset
			position.y = defaultPosition.y - 25 # center on player
		elif direction == Direction.DOWN:
			expBot.rotation_degrees  = 90
			expMain.rotation_degrees  = 90
			expTop.rotation_degrees  = 90
			expEnd.rotation_degrees  = 90
			position.x = defaultPosition.x + 25 # center on player
			position.y = defaultPosition.y  - yDirectionalPositionOffset
		elif direction == Direction.NEUTRAL:
			position.x = defaultPosition.x
			position.y = defaultPosition.y
func getDirection():
	return direction
	
func activate(d):
	
	
	#go find particles that take longest to execute
	var maxLifetime = -1
	for p in $particles.get_children():
		var lifetime = p.lifetime / p.speed_scale
		if lifetime > maxLifetime:
			maxLifetime=lifetime
			
	var waitTime = completionDelay+maxLifetime
#	timer.wait_time = completionDelay+maxLifetime

	
	
	setDirection(d)
	
	
	
	if direction != Direction.NEUTRAL:
		
		
		expMain.set_emitting(true)
		expTop.set_emitting(true)
		expBot.set_emitting(true)
		expEnd.set_emitting(true)
	else:
		
		#its neutral, so only use lifetime of neutral particles
#		timer.wait_time = completionDelay+ (expN.lifetime / expN.speed_scale)
		waitTime=completionDelay+ (expN.lifetime / expN.speed_scale)
		expN.set_emitting(true)
	timer.startInSeconds(waitTime)
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
