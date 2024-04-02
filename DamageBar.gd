extends Control

const DEBUG_OFFSET_MODIFIER = 0.085

var damageAmountTextureProgress = null
var damageCapacityTextureProgress = null
var icon = null

export (int) var numBarLabels = 4
export (float) var legendXOffset = 50
export (float) var legendSize = 2
export (bool) var displayLegend = true
export (Vector2) var iconOffset = Vector2(0,0)
export (float) var maxDamageGauge = 5 setget setMax,getMax
export (bool) var onLeft = true
export (float) var particleDuration = 1
export (float) var generationProgressRadius = 55
export (Color) var generationProgressColor = Color(1,0,0,0.8)
export (Texture) var backgroundTexture = null
export (Texture) var amountTexture = null
export (Texture) var capacityTexture = null
export (Texture) var iconTexture = null
export (float) var transparancy = 0.8
export (float) var debugCapacityOffset = 0
export (float) var amountBarShiftYOffset = 0

const frameTimerResource = preload("res://frameTimer.gd")
var GLOBALS = preload("res://Globals.gd")
var capacity =0
var legendLables = []

var particlesDamageGain = null
var particlesDamageReduce = null
var particleDamageGainTimer = null
var particleDamageReduceTimer = null
var amountLabel = null

var black_smoke  = null
var ambers = null

var newDamageBar = null

var dmgGainProgressUI = null
var newBarTextures = []

var enableParticles = true

#the control node that is placed at center above the capacity
#this allows children of this node to be moved every time capacity chagnes
var capacityTip= null
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here

	
	damageAmountTextureProgress = $dmgAmountTextureProgress
	damageAmountTextureProgress.rect_position.y += amountBarShiftYOffset
	damageAmountTextureProgress.texture_progress = amountTexture
	damageAmountTextureProgress.max_value = GLOBALS.MAXIMUM_DMG_FOCUS_BAR_AMOUNT
	damageCapacityTextureProgress = $dmgCapacityTextureProgress
	damageCapacityTextureProgress.texture_progress = capacityTexture
	damageCapacityTextureProgress.max_value = GLOBALS.MAXIMUM_DMG_FOCUS_BAR_AMOUNT
	damageCapacityTextureProgress.texture_under = backgroundTexture
	damageCapacityTextureProgress.modulate = Color(1,1,1,transparancy)
	capacityTip = $"capacity-tip"
	icon = $icon
	icon.texture = iconTexture
	amountLabel = $"capacity-tip/amount"
	particlesDamageGain = $"damage-gain-particles"
	particlesDamageReduce = $"particles-damage-reduction"
	
	#I think below  3 lines are legacy unused code
	#dmgGainProgressUI = $dmgGenerationProgress
	#dmgGainProgressUI.progressRadius= generationProgressRadius
	#dmgGainProgressUI.color=generationProgressColor
	
	
	
	#newDamageBar.mainBar.max_value = textureProgress.max_value
	#newDamageBar.mainBar.min_value = textureProgress.min_value
	#newDamageBar.mainBar.value = textureProgress.value
	
#	newDamageBar.underBar.max_value = textureProgress.max_value
#	newDamageBar.underBar.min_value = textureProgress.min_value
#	newDamageBar.underBar.value = textureProgress.value + (textureProgress.value*0.1)
	

	#make copy so won't affect other player's particlesDamageGain when change direction
	#particlesDamageGain.process_material = particlesDamageGain.process_material.duplicate()
	#particlesDamageReduce.process_material =particlesDamageReduce.process_material.duplicate()
	
	#if not onLeft:	
	#	particlesDamageGain.process_material.gravity = particlesDamageGain.process_material.gravity*-1	
	#	particlesDamageReduce.process_material.gravity = particlesDamageReduce.process_material.gravity*-1
	moveCapacityTipToBarCapacity()
	
	#updateLegend()
	
	particleDamageGainTimer = frameTimerResource.new()
	#particleDamageGainTimer.one_shot = true #set to true to indicate don't conitune ticking (only executed once called)
	particleDamageGainTimer.connect("timeout",self,"_particlesDamageGain_finished")
	self.add_child(particleDamageGainTimer)
	
	particleDamageReduceTimer = frameTimerResource.new()
	#particleDamageReduceTimer.one_shot = true #set to true to indicate don't conitune ticking (only executed once called)
	particleDamageReduceTimer.connect("timeout",self,"_particlesDamageReduction_finished")
	self.add_child(particleDamageReduceTimer)
	
	#var chunk = textureProgress.max_value/4
	
	#label100.text = "x"+str(chunk*4)
	#label75.text = "x"+str(chunk*3)
	#label50.text = "x"+str(chunk*2)
	#label25.text = "x"+str(chunk*1)
	pass

func moveCapacityTipToBarCapacity():
	
	#position of capacity
	var pos = _getBarFilledPosition(damageCapacityTextureProgress.value)
	
	#var barwidth = damageAmountTextureProgress.rect_size.x
	
	#pos.x = pos.x + barwidth/2.0
	capacityTip.rect_position = pos

func _particlesDamageGain_finished():
	particlesDamageGain.emitting=false

func _particlesDamageReduction_finished():
	particlesDamageReduce.emitting=false
	
func startparticlesDamageReduce():
	var pos = getBarFilledPosition()
	particlesDamageReduce.position.y = pos.y
	particlesDamageReduce.emitting = true
	#particleDamageReduceTimer.wait_time = particleDuration
	particleDamageReduceTimer.startInSeconds(particleDuration)
	
func startparticlesDamageGain():
	var pos = getBarFilledPosition()
	particlesDamageGain.position.y = pos.y
	particlesDamageGain.emitting = true
	#particleDamageGainTimer.wait_time = particleDuration
	particleDamageGainTimer.startInSeconds(particleDuration)
	

func _getBarFilledPosition(barVal):
	
	#0-1 of how much bar is filled
	
	var fracFilled = (barVal-damageAmountTextureProgress.min_value)/(damageAmountTextureProgress.max_value-damageAmountTextureProgress.min_value)
	
	#var yPosition = damageAmountTextureProgress.rect_size.y*0.2 * fracFilled
	#var yPosition = damageAmountTextureProgress.rect_size.y * (fracFilled-0.1)#-10% to compensiate for fact their is margin 
	var yPosition = damageAmountTextureProgress.rect_size.y * fracFilled 
	#var pos = damageAmountTextureProgress.get_global_rect().position
	var pos = damageAmountTextureProgress.rect_position
	var size = damageAmountTextureProgress.rect_size
	return Vector2(pos.x,pos.y+size.y-yPosition)
	
	
func getBarFilledPosition():
	return _getBarFilledPosition(damageAmountTextureProgress.value)
	
func updateLegend():
	
	if not displayLegend:
		return
		
	var y = damageAmountTextureProgress.rect_position.y
	var dmgMod= damageAmountTextureProgress.max_value
	
	var barSize = damageAmountTextureProgress.rect_size.y
	
	var yinc = barSize/numBarLabels
	var dmginc = (damageAmountTextureProgress.max_value-damageAmountTextureProgress.min_value)/numBarLabels
	
	#if previously create legned, erase it
	for label in legendLables:
		self.remove_child(label)
		
	#iterate from numBarLabesl times
	for i in numBarLabels+1:
		var label = Label.new()
		self.add_child(label)
		legendLables.append(label)
		label.text = ("-%0.1f" %dmgMod)
		label.rect_position.x = legendXOffset
		label.rect_position.y = y - amountBarShiftYOffset # shift cause shift bar for d3ebug purposes
		label.rect_scale = Vector2(legendSize,legendSize)
		dmgMod -= dmginc
		y+= yinc
	
		
		
func setMax(newMax):
	if damageAmountTextureProgress == null:
		return
	

	damageAmountTextureProgress.max_value = newMax
	damageCapacityTextureProgress.max_value = newMax
	maxDamageGauge = newMax
	#updateLegend()
func getMax():
	return maxDamageGauge
	
func setCapacity(amount): 
	var oldAmount = capacity
	capacity = amount
	#var oldAmount = damageCapacityTextureProgress.value
	
	damageCapacityTextureProgress.value = amount 
	
	#reduction?
	if oldAmount > amount:
		if enableParticles:
			startparticlesDamageReduce()
	elif oldAmount == amount:
		return
	else:#gain
		if enableParticles:
			startparticlesDamageGain()
	
	moveCapacityTipToBarCapacity()
	
#func _on_start_tracking_damage_gain(dmgGaugeAmount,capacity, nextHitAmount):
	#damageCapacityTextureProgress.value = capacity + capacity * DEBUG_OFFSET_MODIFIER
	#dmgGainProgressUI.activate(dmgGaugeAmount,capacity,nextHitAmount)
	
func setAmount(amount):
	
	#var oldAmount = damageAmountTextureProgress.value
	damageAmountTextureProgress.value = amount
	
	#done updating?
	#if dmgGainProgressUI._on_dmg_amount_changed(amount):
#		damageCapacityTextureProgress.value = 0
#	else:
#		if amount < oldAmount:
			#the damage gauage has gone down. start tracking it again
#			_on_start_tracking_damage_gain(amount,capacity)
		
#		damageCapacityTextureProgress.value = capacity 
	var precent = int(round(amount * 100))
	amountLabel.text = str(precent)+"%"
	
	
func setMaximum(amount):
	damageAmountTextureProgress.max_value = amount
	damageCapacityTextureProgress.max_value = amount
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _on_damageGaugeCapacityReached(newDmg):
	#dmgGainProgressUI.visible = false
	#damageCapacityTextureProgress.value = 0
	pass