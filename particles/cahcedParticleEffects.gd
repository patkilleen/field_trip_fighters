extends Node2D

const GLOBALS = preload("res://Globals.gd")
const inputManager = preload("res://input_manager.gd")
var techSfx = null
var attackSfx =null
var jumpDust = null

var landingDust = null
#var pushBlockSfx = null
var starBurstSfx = null
var leaveGroundDust = null
var magicGlow = null
var vortex = null
var blackhole = null
var cmdParticles = null
var abilityCancelSwirls = null
var abilityCancelExplosion= null
func _ready():
	
	#emits on enter scene tree
	techSfx=$techSFX
	jumpDust = $jumpDust
	leaveGroundDust = $leavegroundDust
	
	
	attackSfx = $AttackSFX
	
	attackSfx.init()
	attackSfx.setDirection(attackSfx.Direction.NEUTRAL)
	attackSfx.activate(attackSfx.Direction.NEUTRAL)
	
	
	landingDust = $LandingDust
	landingDust.emitting = true
	
	
	#pushBlockSfx = $"pushBlock-particles"
	#pushBlockSfx.emit()
	starBurstSfx = $"star-burst"
	starBurstSfx.emitting = true
	
	magicGlow = $magicGlow
	magicGlow.emitting= true
	
	#by default is emitting
	vortex = $vortex
	
	blackhole = $blackhole
	blackhole.start()
	
	cmdParticles = $CommandParticle
	cmdParticles.emitCommand(inputManager.Command.CMD_NEUTRAL_MELEE)
	
	abilityCancelSwirls = $abilityCancelSwirlParticles
	abilityCancelSwirls.emitting = true
	
	abilityCancelExplosion= $abilityCancelExplosion
	abilityCancelExplosion.emitting = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
