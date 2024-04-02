extends Node2D

const GLOBALS = preload("res://Globals.gd")

const HITBOX_SCRIPT_RESOURCE = preload("res://HitboxArea.gd")
const HURTBOX_SCRIPT_RESOURCE = preload("res://HurtboxArea.gd")
const PROXIMITY_GUARD_SCRIPT_RESOURCE = preload("res://ProximityGuardArea.gd")

var numberActivatedAreas = [] #2 cell 1 d array, 0num actived hitboxes, 1: num activea hurtboex

var collisionAreas = []#2d array [type of collision box][area ix] of collision areas

var collisionShapeMap = []#3d array [type of collision box][area ix][boxis]
var numActivatedCollisionShapes = []#2d array [type of collision box][area ix],how many of it's collision nodes actiavated

var collisionAreasNode = null

const HITBOX_IX = 0
const HURTBOX_IX = 1
const SELFONLY_HITBOX_IX = 2
const SELFONLY_HURTBOX_IX = 3
const PROXIMITY_GUARD_AREA_IX = 4


const LARGEST_AREA_IX = PROXIMITY_GUARD_AREA_IX

var collisionTypeNameMap={HITBOX_IX:"hitbox",
HURTBOX_IX:"hurtbox",
SELFONLY_HITBOX_IX:"self-only hitbox",
SELFONLY_HURTBOX_IX: "self-only hurtbox",
PROXIMITY_GUARD_AREA_IX: "proximity guard"}

var activationsPerFramesCounter = 0
var deactivationsPerFramesCounter = 0
	

export (Color) var hurtbox_debug_color = null
export (Color) var hitbox_debug_color = null
export (Color) var proximity_guard_area_debug_color = null
var debugColorMap = []
var debugCollisionScript = null
#export (Color) var bobox_debug_color = null
func _ready():
	for i in range(LARGEST_AREA_IX+1):
		debugColorMap.append(null)
	
	debugColorMap[HITBOX_IX]=hitbox_debug_color
	debugColorMap[HURTBOX_IX]=hurtbox_debug_color
	debugColorMap[SELFONLY_HITBOX_IX]=hitbox_debug_color
	debugColorMap[SELFONLY_HURTBOX_IX]=hurtbox_debug_color
	debugColorMap[PROXIMITY_GUARD_AREA_IX]=proximity_guard_area_debug_color
	
	collisionAreasNode = get_node("collisionAreas")
	
	for i in range(LARGEST_AREA_IX+1):
		
		numActivatedCollisionShapes.append([])
		collisionAreas.append([])
		collisionShapeMap.append([])		
		initializeAreas(i)
	
	self.set_physics_process(false)

func getProximityGuardAreas():
	return collisionAreas[PROXIMITY_GUARD_AREA_IX]
	
func getHitboxAreas():
	return collisionAreas[HITBOX_IX]
	
func getHurtboxAreas():
	return collisionAreas[HURTBOX_IX]

func getSelfOnlyHitboxAreas():
	return collisionAreas[SELFONLY_HITBOX_IX]
	
func getSelfOnlyHurtboxAreas():
	return collisionAreas[SELFONLY_HURTBOX_IX]
	
func enableAreas():
	for i in range(LARGEST_AREA_IX+1):
		
		var area2ds = collisionAreas[i]
		
		for a in area2ds:
			a.monitorable = true
			a.monitoring = true
			#a.set_deferred("monitorable",true)
			#a.set_deferred("monitoring",true)
		
	
	
func initializeAreas(collisionTypeIx):
	
	#yield(get_tree(),"idle_frame")
	#var startTime = OS.get_ticks_msec()
	#var curTime = startTime
	
	numberActivatedAreas.append(0)
	var area2ds = collisionAreas[collisionTypeIx]
	#initialisze collisionAreas with GLOBALS.MAX_NUM_COLLISION_AREAS_PER_SPRITE_FRAME areas
	#for i in range(GLOBALS.MAX_NUM_COLLISION_AREAS_PER_SPRITE_FRAME):
	for i in range(GLOBALS.MAX_NUM_COLLISION_AREAS_PER_SPRITE_FRAME_MAP[collisionTypeIx]):
	
		var area2D = Area2D.new()
		#has to be true all the time, cause godot has bug of using this flags 
		#make it false at first so that it doesn't take forever to load when adding player to stage
		
		area2D.monitorable = false
		
		area2D.monitoring = false
		
		area2D.visible = false #disabled by default
		area2ds.append(area2D)
		
		#collision boxes initializing
		var collisionShapes = []
			
		#initialisze collisionBoxes with GLOBALS.MAX_NUM_COLLISION_AREAS_PER_SPRITE_FRAME x GLOBALS. MAX_NUM_COLLISION_BOXES_PER_COLLISION_AREA  boxes
		
		#no activate collision shpaes by default
		numActivatedCollisionShapes[collisionTypeIx].append(0)
		
		for j in range(GLOBALS.MAX_NUM_COLLISION_BOXES_PER_COLLISION_AREA):
			var colShape = CollisionShape2D.new()
				
	#		curTime = OS.get_ticks_msec()
				
			#more than a frame ellapsed?
	#		if curTime - startTime > 33:
	#			startTime = curTime
				#give up cpu, wait for next frame to continue
				#main thread will update graphis and other things
	#			yield(get_tree(),"idle_frame")
					
			
			#shows a different color for debuggin
			colShape.modulate = debugColorMap[collisionTypeIx]
			#make sure it's above sprite of player
			colShape.z_index= 10
			
			colShape.disabled = true#disabled by default
			colShape.visible = false
			
			#no shape by default (ie, set_shape(null) for now, until actiavted)
			
			collisionShapes.append(colShape)
			
			#add the collisionshape under the area
			area2D.call_deferred("add_child",colShape)
			#area2D.add_child(colShape)
			#colShape.owner = area2D
			
			
		collisionShapeMap[collisionTypeIx].append(collisionShapes)
		
		#add the area to this secene
		collisionAreasNode.call_deferred("add_child",area2D)
		#collisionAreasNode.call_deferred("add_child",area2D)
		#area2D.owner = collisionAreasNode

func deactivateAll():
	for i in range(LARGEST_AREA_IX+1):
		_deactivateAll(i)
	
func deactivateHitboxes():
	
	_deactivateAll(HITBOX_IX)
	_deactivateAll(PROXIMITY_GUARD_AREA_IX)
	

func deactivateSelfOnlyHitboxes():
	_deactivateAll(SELFONLY_HITBOX_IX)
	
	
		
func _deactivateAll(collisionTypeIx):
	
	deactivationsPerFramesCounter +=1
	#iterate all the previously activated areas to disable them and collision boxes
	#for i in range(numberActivatedAreas[collisionTypeIx]):
	#for i in range(GLOBALS.MAX_NUM_COLLISION_AREAS_PER_SPRITE_FRAME):
	for i in range(GLOBALS.MAX_NUM_COLLISION_AREAS_PER_SPRITE_FRAME_MAP[collisionTypeIx]):
	
		
		var area2D = collisionAreas[collisionTypeIx][i]
		#if debugging collision boxes, don't display disabled areas
		area2D.visible = false 
		area2D.monitorable = false
		area2D.monitoring = false
		
		var collisionShapes = collisionShapeMap[collisionTypeIx][i]
		
		var numActivatedShapes = numActivatedCollisionShapes[collisionTypeIx][i]
		
		#itterate the active shapes of area i
		#for j in range(numActivatedShapes):
		for j in range(GLOBALS.MAX_NUM_COLLISION_BOXES_PER_COLLISION_AREA):
			var cshape = collisionShapes[j]
			cshape.disabled = true
			#cshape.set_deferred("disabled",true)
		
			cshape.visible = false
			
		#no more shapes are activated for area i
		numActivatedCollisionShapes[collisionTypeIx][i] = 0
	numberActivatedAreas[collisionTypeIx] = 0
	
#this takes a list of areas used to copy their configuration
#over to the preloaded areas of this scene
#it does not affect/write to any of areas in list
func _activate(areaList,collisionTypeIx):

	activationsPerFramesCounter +=1
	#if areaList.size() > GLOBALS.MAX_NUM_COLLISION_AREAS_PER_SPRITE_FRAME:
	if areaList.size() > GLOBALS.MAX_NUM_COLLISION_AREAS_PER_SPRITE_FRAME_MAP[collisionTypeIx]:
	
		print("warning: trying to activate more areas ("+str(areaList.size())+") than allowed maximum of "+str(GLOBALS.MAX_NUM_COLLISION_AREAS_PER_SPRITE_FRAME_MAP[collisionTypeIx])+". Skipping some areas of type: "+collisionTypeNameMap[collisionTypeIx])
		
	
	#first we deactive everything
	_deactivateAll(collisionTypeIx)
	
	#nothing to activate?
	if areaList.size() == 0 or areaList==null:
		
		#return here, since it may be case a frame doesn't have areas that are active
		return
	
	numberActivatedAreas[collisionTypeIx]=areaList.size()
	
	#iterate over areas, and activate only necessary ones
	#min(): process at most maximm number of areas that are preloaded in this scene
	#for i in range(min(areaList.size(),GLOBALS.MAX_NUM_COLLISION_AREAS_PER_SPRITE_FRAME)):
	for i in range(min(areaList.size(),GLOBALS.MAX_NUM_COLLISION_AREAS_PER_SPRITE_FRAME_MAP[collisionTypeIx])):
	
		
		var srcArea = areaList[i]
		var dstArea = collisionAreas[collisionTypeIx][i]
		
		#make copy members of the source area into destination area
		copy(srcArea,dstArea)
	
		dstArea.visible = true
		dstArea.monitorable = true
		#dstArea.set_deferred("monitorable",true)
		dstArea.monitoring = true
		#dstArea.set_deferred("monitoring",true)
		
		var numCollisionShapes = 0
		
		#index to iterate throuw destination collision shapes
		var j = 0
		#iterate children of srcArea, and search for collision shape 2ds to copy over
		for srcShape in srcArea.get_children():
			
			#only conside collisions shape 2ds
			if srcShape is CollisionShape2D:
				numCollisionShapes = numCollisionShapes + 1
			else:
				continue
				
			#don't process more shapes than maximum allowed
			if numCollisionShapes > GLOBALS.MAX_NUM_COLLISION_BOXES_PER_COLLISION_AREA:
				print("warning: trying to activate more collision shapes ("+str(numCollisionShapes.size())+") than allowed maximum of "+str(GLOBALS.MAX_NUM_COLLISION_BOXES_PER_COLLISION_AREA)+". Skipping some shapes")	
				break
		
			#-1, since want to use it as index
			var dstShape = collisionShapeMap[collisionTypeIx][i][j]
			j = j +1
			
			
			#copy the important members of srce shape
			dstShape.set_shape(srcShape.get_shape())
			dstShape.position = srcShape.position
			dstShape.rotation = srcShape.rotation
			dstShape.disabled = srcShape.disabled
			if dstShape.disabled:
				dstShape.visible = false
			else:
				dstShape.visible = true
			
		#area i has this many activated collision shapes
		numActivatedCollisionShapes[collisionTypeIx][i] = numCollisionShapes
		

func activateProximityGuardAreas(areaList):	

	_activate(areaList,PROXIMITY_GUARD_AREA_IX)
	
func activateHitboxes(areaList):	

	_activate(areaList,HITBOX_IX)
	
func activateHurtboxes(areaList):	

	_activate(areaList,HURTBOX_IX)

func activateSelfOnlyHitboxes(areaList):	

	_activate(areaList,SELFONLY_HITBOX_IX)
	
func activateSelfOnlyHurtboxes(areaList):	
		
	_activate(areaList,SELFONLY_HURTBOX_IX)	
	
#this is a function that will make a copy of the area, by 
#giving the script at run time and copying over memebers
func copy(srcArea, dstArea):
	
	if srcArea == null or dstArea == null:
		print("warning: trying to copy a null area2d into another possibly null area2d")
		return
	
	#THE COLLISION bit parameters are set when game object (projectile/player) are intiated
	#can't change theses at runtime due to godot not registering signal upon change
	#dstArea.collision_layer = srcArea.collision_layer
	#dstArea.collision_mask = srcArea.collision_mask
	dstArea.position = srcArea.position
	var srcScript = srcArea.get_script()
	
	if srcArea is preload("res://SpriteCollisionArea.gd"):
		
		dstArea.set_script(srcScript)
		
		#copy over member of spritecolisionarea script (dont copy over collisionshape array)
		#no
		dstArea.collisionShapes = []
		dstArea.playerController = srcArea.playerController
		dstArea.projectileController=srcArea.projectileController
		dstArea.spriteAnimation = srcArea.spriteAnimation
		dstArea.spriteFrame = srcArea.spriteFrame
		dstArea.selfOnly = srcArea.selfOnly
		dstArea.cmd = srcArea.cmd
		dstArea.facingRightWhenPlayed = srcArea.facingRightWhenPlayed
		dstArea.commonSFXSoundId = srcArea.commonSFXSoundId
		dstArea.heroSFXSoundId = srcArea.heroSFXSoundId
		dstArea.collisionPriority = srcArea.collisionPriority
	
		var cmd = dstArea.cmd

		if srcArea is HITBOX_SCRIPT_RESOURCE:
			dstArea.behavior = srcArea.behavior
			dstArea.clashType = srcArea.clashType
			dstArea.hitstunType = srcArea.hitstunType
			dstArea.damage = srcArea.damage
			dstArea.abilityRegenMod = srcArea.abilityRegenMod
			dstArea.ripostabled = srcArea.ripostabled
			dstArea.onHitAutoCancelable = srcArea.onHitAutoCancelable
			dstArea.duration = srcArea.duration
			dstArea.abilityGainMod = srcArea.abilityGainMod
			dstArea.hpGainMod = srcArea.hpGainMod
			dstArea.on_hit_action_id = srcArea.on_hit_action_id
			dstArea.hitFreezeDuration = srcArea.hitFreezeDuration
			dstArea.is_projectile = srcArea.is_projectile
			dstArea.hitStunLandingType = srcArea.hitStunLandingType
			dstArea.minDurationBeforeFallProne = srcArea.minDurationBeforeFallProne
			dstArea.hitstunMovementAnimation = srcArea.hitstunMovementAnimation
			dstArea.projectileParentSpriteAnimation = srcArea.projectileParentSpriteAnimation
			dstArea.stopHitMomentumOnLand = srcArea.stopHitMomentumOnLand
			dstArea.isThrow = srcArea.isThrow
			dstArea.affectsHitstunProration = srcArea.affectsHitstunProration
			dstArea.affectsDmgStarFill = srcArea.affectsDmgStarFill
			dstArea.blockStunDuration = srcArea.blockStunDuration
			dstArea.low = srcArea.low
			dstArea.hitstunDurationType = srcArea.hitstunDurationType
			dstArea.canHitActiveFrame = srcArea.canHitActiveFrame
			dstArea.canHitStartupFrame=srcArea.canHitStartupFrame
			dstArea.guardHPDamage = srcArea.guardHPDamage
			dstArea.blockChipDamageMod = srcArea.blockChipDamageMod
			dstArea.histunProratrion = srcArea.histunProratrion
			dstArea.dmgProratrion = srcArea.dmgProratrion
			dstArea.affectsMoveSpamHistunProratrion=srcArea.affectsMoveSpamHistunProratrion
			dstArea.hitstunAngleMatchesAttackerMomentum=srcArea.hitstunAngleMatchesAttackerMomentum
			dstArea.removesEmptyStar=srcArea.removesEmptyStar
			dstArea.blockstunMovementAnimation=srcArea.blockstunMovementAnimation
			dstArea.attackerOnBlockedMovementAnimation=srcArea.attackerOnBlockedMovementAnimation
			dstArea.abilityFeedProrationMod=srcArea.abilityFeedProrationMod
			dstArea.blockstunAngleMatchesAttackerMomentum=srcArea.blockstunAngleMatchesAttackerMomentum
			dstArea.techExceptions=srcArea.techExceptions
			dstArea.airBlockStunLandingRecoveryDuration=srcArea.airBlockStunLandingRecoveryDuration
			dstArea.hitstunLinkMovementAnimation=srcArea.hitstunLinkMovementAnimation
			dstArea.emitsAttackSFXSignal=srcArea.emitsAttackSFXSignal
			dstArea.incorrectBlockGuardHPDamage=srcArea.incorrectBlockGuardHPDamage
			dstArea.blockStunDurationType=srcArea.blockStunDurationType
			dstArea.tmpLocalSFXSprites=srcArea.tmpLocalSFXSprites
			dstArea.tmpGlobalSFXSprites=srcArea.tmpGlobalSFXSprites
			dstArea.stopMomentumOnPushOpponent=srcArea.stopMomentumOnPushOpponent
			dstArea.playSoundSFX=srcArea.playSoundSFX
			dstArea.ignoreComboTracking=srcArea.ignoreComboTracking
			dstArea.countsAsBlockString=srcArea.countsAsBlockString
			dstArea.guardDamageClass=srcArea.guardDamageClass
			dstArea.cornerHitPushAwayMovementAnimation=srcArea.cornerHitPushAwayMovementAnimation
			dstArea.pushesBackOnHitInCorner=srcArea.pushesBackOnHitInCorner
			dstArea.incorrectBlockStunDuration=srcArea.incorrectBlockStunDuration
			dstArea.blockCornerHitPushAwayMovementAnimation = srcArea.blockCornerHitPushAwayMovementAnimation
			dstArea.clashRecoveryDuration = srcArea.clashRecoveryDuration
			dstArea.dmgProrationClass=srcArea.dmgProrationClass
			dstArea.falseCelingLockDuration = srcArea.falseCelingLockDuration
			dstArea.falseWallLockDuration = srcArea.falseWallLockDuration
			dstArea.specialBounceMvmAnimations=srcArea.specialBounceMvmAnimations
			dstArea.spamHistunProration = srcArea.spamHistunProration
			dstArea.stopMomentumOnOpponentAnimationPlay = srcArea.stopMomentumOnOpponentAnimationPlay
			dstArea.on_link_hit_action_id = srcArea.on_link_hit_action_id
			dstArea.newHitstunDurationOnLand = srcArea.newHitstunDurationOnLand
			dstArea.disableBodyBox=srcArea.disableBodyBox
			dstArea.preventsAnimationStaleness = srcArea.preventsAnimationStaleness
			dstArea.mvmStpOnOppAutoAbilityCancel = srcArea.mvmStpOnOppAutoAbilityCancel
			dstArea.durationOnLink = srcArea.durationOnLink
			dstArea.unblockable=srcArea.unblockable
			dstArea.incorrectBlockUnblockable=srcArea.incorrectBlockUnblockable			
			dstArea.preventBlockSetKnockBackDuration=srcArea.preventBlockSetKnockBackDuration
			dstArea.shakeIntensity = srcArea.shakeIntensity
			dstArea.shakeTrauma = srcArea.shakeTrauma
			dstArea.shakeDecay = srcArea.shakeDecay
			dstArea.shakeMaxOffset = srcArea.shakeMaxOffset
			dstArea.shakePower = srcArea.shakePower
			dstArea.shakeDuration = srcArea.shakeDuration
			dstArea.projectileInstancer=srcArea.projectileInstancer
			dstArea.ignoreProjectileCollisions=srcArea.ignoreProjectileCollisions
			dstArea.canHitGroundedTarget =srcArea.canHitGroundedTarget
			dstArea.canHitAirborneTarget =srcArea.canHitAirborneTarget
			dstArea.hitsWakeupOpponent = srcArea.hitsWakeupOpponent
			dstArea.on_hit_starting_sprite_frame_ix=srcArea.on_hit_starting_sprite_frame_ix
			dstArea.preventOnHitActionWhenOnGround= srcArea.preventOnHitActionWhenOnGround
			dstArea.preventOnHitActionWhenInAir= srcArea.preventOnHitActionWhenInAir
			dstArea.hideHitstunSprite = srcArea.hideHitstunSprite			
			
		elif  srcArea is HURTBOX_SCRIPT_RESOURCE:
			dstArea.subClass=srcArea.subClass
			dstArea.heavyArmorDamageLimit =srcArea.heavyArmorDamageLimit
			dstArea.damageResistance =srcArea.damageResistance
			dstArea.preventAutocancelOnHit =srcArea.preventAutocancelOnHit
			dstArea.canHoldBackBlock =srcArea.canHoldBackBlock
			dstArea.projectileInvulnerability =srcArea.projectileInvulnerability
			dstArea.onGettingHitCounterActionId =srcArea.onGettingHitCounterActionId
			dstArea.superArmorHitLimit =srcArea.superArmorHitLimit
			
		elif srcArea is PROXIMITY_GUARD_SCRIPT_RESOURCE:	
			dstArea.preventDisableOnHitboxHit = srcArea.preventDisableOnHitboxHit
			
	else:
		print("unknow script ("+srcScript.get_path().get_file()+") on area 2d, could not copy.")
	

#rotates the collision areas to given anlge
func rotateCollisionAreas(rotation_degrees):
	collisionAreasNode.rotation_degrees=rotation_degrees
	
#just used for debugging	
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	if activationsPerFramesCounter > 4:
		print("more than activated sprite frames in a refresh")	
	
	if deactivationsPerFramesCounter > 4:
		print("more than activated sprite frames in a refresh")	
		
	activationsPerFramesCounter = 0
	deactivationsPerFramesCounter = 0
	
	
	