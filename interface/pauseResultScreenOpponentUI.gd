extends Control

signal menu_override_requested
const GLOBALS = preload("res://Globals.gd")
var opponentInputDeviceId = null

var requestLabel = null

enum Request{
	NONE,
	PROFICIENCY_SELECTION,
	CHARACTER_SELECTION,
	REMATCH,
	STAGE_SELECTION
}

var activated = false
var request = Request.NONE

var btnYParticlesSpawn = null
var btnXParticlesSpawn = null
var btnAParticlesSpawn = null
var btnR2ParticlesSpawn = null
var particleTemplate = null

var btnY=null
var btnX=null
var btnA=null
var btnR2=null
func _ready():
	#don't show this by default. only visible in result screen (pauseLayer will make it visible)
	visible = false
	requestLabel = $request
	btnYParticlesSpawn = $"btn_Y/particleSpawnPos"
	btnXParticlesSpawn = $"btn_X/particleSpawnPos"
	btnAParticlesSpawn = $"btn_A/particleSpawnPos"
	btnR2ParticlesSpawn = $"btn_R2/particleSpawnPos"
	btnY=$"btn_Y"
	btnX=$"btn_X"
	btnA=$"btn_A"
	btnR2=$"btn_R2"
	particleTemplate = $"Particles2Dtemplate"
	set_physics_process(false)
	activated = false

func init():
	visible = false
	resetRequest()
	activated = false

func activate(_opponentInputDeviceId):
	
	if _opponentInputDeviceId == null:
		return
	resetRequest()
	opponentInputDeviceId=_opponentInputDeviceId
	visible = true
	set_physics_process(true)
	activated = true

func deactivate():
	opponentInputDeviceId=null
	visible = false
	set_physics_process(false)
	resetRequest()
	activated = false

func resetRequest():
	requestLabel.visible = false
	requestLabel.text = ""
	request = Request.NONE
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	var createParticleFlag=false
	var btnToAddParticles = null
	var particlePos= null
	#process the input of player that doesn't control the pause menu
	#they have partial conrtol by being able to force character select or proficiency
	#select if player controller menu selects rematch (or prof select if character select requested)
	#the rematch logic is just to allow player to spam something durign result screen
	#it has no real control over UI other than diaplay and hide "rematch requested"
	if Input.is_action_just_pressed(opponentInputDeviceId+"_B"):
		resetRequest()
	elif Input.is_action_just_pressed(opponentInputDeviceId+"_X"):
		requestLabel.visible = true
		requestLabel.text = "Character Selection Requested"
		request = Request.CHARACTER_SELECTION
		createParticleFlag=true
		btnToAddParticles=btnX
		particlePos=btnXParticlesSpawn
		emit_signal("menu_override_requested")
	elif Input.is_action_just_pressed(opponentInputDeviceId+"_Y"):
		requestLabel.visible = true
		requestLabel.text = "Proficiency Selection Requested"
		request = Request.PROFICIENCY_SELECTION
		createParticleFlag=true
		btnToAddParticles=btnY
		particlePos=btnYParticlesSpawn
		emit_signal("menu_override_requested")
	elif Input.is_action_just_pressed(opponentInputDeviceId+"_A"):
		requestLabel.visible = true
		requestLabel.text = "Rematch Requested"
		request = Request.REMATCH
		createParticleFlag=true
		btnToAddParticles=btnA
		particlePos=btnAParticlesSpawn
		emit_signal("menu_override_requested")
	elif Input.is_action_just_pressed(opponentInputDeviceId+"_RIGHT_TRIGGER"):
		requestLabel.visible = true
		requestLabel.text = "Stage Selection Requested"
		request = Request.STAGE_SELECTION
		createParticleFlag=true
		btnToAddParticles=btnR2
		particlePos=btnR2ParticlesSpawn
		emit_signal("menu_override_requested")
	#particesl from pressing button shoudl emit?
	if createParticleFlag:
		var particles = particleTemplate.duplicate()
		btnToAddParticles.add_child(particles)
		particles.emitting=true
		particles.position=particlePos.position
		
		
		
		
		
		
		
		
		
		
		
		
		
		