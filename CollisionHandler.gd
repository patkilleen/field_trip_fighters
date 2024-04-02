extends Node

signal player_was_hit
signal player_attack_clashed
signal player_invincible_was_hit
signal hitting_invincible_player
signal hitting_player

signal player_was_hit_collision_info

signal landing_on_ground
signal left_ground
signal landing_on_platform
signal pushed_against_wall
signal left_wall
signal pushed_against_ceiling
signal left_ceiling
signal left_platform
signal entered_ground_ledge
signal left_ground_ledge
signal entered_platform_left_ledge
signal entered_platform_right_ledge
signal left_platform_right_ledge
signal left_platform_left_ledge
signal landed_on_opponent
signal stopped_standing_on_opponent
signal proximity_guard_enabled_changed
signal exited_left_corner
signal exited_right_corner
signal entered_left_corner
signal entered_right_corner
signal entered_opponent_body_box
signal exited_opponent_body_box

#signal entered_disabled_body_box_wall_area
#signal exited_disabled_body_box_wall_area

enum CollisionType{
	HITBOX_HITBOX,#CLASH
	HITBOX_HURTBOX,#WAS HIT
	HURTBOX_HITBOX#IS HITTING
}

const ENTERING_AREA_KEY = "enteringArea"
const ENTERED_AREA_KEY = "enteredArea"
const ACTION_MANAGER_KEY = "actionManager"


var gameCollisionInfoRes = preload("res://GameCollisionInfo.gd")
var GLOBALS = preload("res://Globals.gd")

var collisionAreas = []

var wasInAir = true
var wasAgainstWall = false
var wasAgainstCeiling = false

var wasOnPlatform = false
var wasOnGround = false

var wasProximityGuardEnabled = false
var wasStandingOnOpponent = false
var wasAgainstOpponentAsWall = false
var wasAgainstOpponentAsCeiling = false

#start true to avoid signaling on land
var wasGroundRayCastColliding = true
var wasLeftPlatformRayCastColliding = true
var wasRightPlatformRayCastColliding = true

var wasLeftOpponentRayCastColliding = false
var wasRightOpponentRayCastColliding = false

var wasInDisabledBodyBoxWallArea = false
var wasInLeftCorner=false
var wasInRightCorner = false
var wasInsideOpponent=false

var playerController = null

#var wasGettingHitProtectionEnabled = false
#var wasHittingProtectionEnabled = false
#var proximityGuardEnabled = false
#var proximityGuardEnabledSignal = false

var numProxityGuardAreasInRange = 0
#var numGettingHitProtectionAreasInRange = 0
#var numHittingProtectionAreasInRange = 0
var ignoreCollisions = false
func _ready():

	pass

func init():
	wasInAir = true
	wasAgainstWall = false
	wasAgainstCeiling = false
	
	wasOnPlatform = false
	wasOnGround = false
	
	wasProximityGuardEnabled=false
	#wasGettingHitProtectionEnabled = false
	#wasHittingProtectionEnabled = false
	wasStandingOnOpponent = false
	wasAgainstOpponentAsWall = false
	wasAgainstOpponentAsCeiling = false
	
	#start true to avoid signaling on land
	wasGroundRayCastColliding = true
	wasLeftPlatformRayCastColliding = true
	wasRightPlatformRayCastColliding = true
	
	wasLeftOpponentRayCastColliding = false
	wasRightOpponentRayCastColliding = false
	
	wasInDisabledBodyBoxWallArea = false
	wasInsideOpponent = false
	
	wasInLeftCorner=false
	wasInRightCorner = false
	ignoreCollisions = false

	numProxityGuardAreasInRange=0
	
	collisionAreas.clear()
	collisionAreas=[]
	#numProxityGuardAreasInRange = 0
	#numGettingHitProtectionAreasInRange=0
func isHitbox(hb):
	
	var script = hb.get_script()
	if script != null:
		var scriptName = script.get_path().get_file()
		#found movement node?
		if scriptName == "HitboxArea.gd":
				return true
	return false

func isHurtbox(hb):
	
	var script = hb.get_script()
	if script != null:
		var scriptName = script.get_path().get_file()
		#found movement node?
		if scriptName == "HurtboxArea.gd":
				return true
	return false

	

#extracts a list of all the collision-pairs of each collision type
#from recent collisions
#return a hasmap of pairs, where key = CollisionType
func categorizeCollisionPairs():
	var res = {}
	
	#initialize the empty arrays of pairs for each type
	res[CollisionType.HITBOX_HITBOX] = []
	res[CollisionType.HURTBOX_HITBOX] = []
	res[CollisionType.HITBOX_HURTBOX] = []
	
	#iterate all the collision pairs that happned this frame
	for collisionAreaPair in collisionAreas:
		

		var _enteringArea = collisionAreaPair[ENTERING_AREA_KEY]
		var _enteredArea = collisionAreaPair[ENTERED_AREA_KEY]	
		
		
		if isHitbox(_enteringArea) and isHitbox(_enteredArea):
			res[CollisionType.HITBOX_HITBOX].append(collisionAreaPair)
		elif isHurtbox(_enteringArea) and isHitbox(_enteredArea):
			#only process the collision of hiting if were not 
			#protecting opponent with protectiong hitbox that overrides the hit
			#if not wasHittingProtectionEnabled:
				
			res[CollisionType.HURTBOX_HITBOX].append(collisionAreaPair)
			
		elif isHitbox(_enteringArea) and isHurtbox(_enteredArea):
			
			#only process the collision of getting hit if were not 
			#being hit by protection hitbox that overrides the hit
			#if not wasGettingHitProtectionEnabled:
			res[CollisionType.HITBOX_HURTBOX].append(collisionAreaPair)
		else: #no other types should be possible by design
			print("(CollisionHandler) warning, unknown type of collision pairs")
	
	
	#see if protection hitbox preventing hitbox collisions
	if collisionsPairsContainProtectionHitbox(res[CollisionType.HURTBOX_HITBOX]):
		#we are getting hit by protection hitbox, which makes us immune to getting hit
		res[CollisionType.HURTBOX_HITBOX].clear()
	
	
	if collisionsPairsContainProtectionHitbox(res[CollisionType.HITBOX_HURTBOX]):
		#we are hitting with protection hitbox, dwhich makes oppoenent immune to getting hit
		res[CollisionType.HITBOX_HURTBOX].clear()
	
		
	return res

#finds the collision pair with highest priority
#however, in case projectil also active, then it will also be returned without priority
#checking (so in theory, multiple proejctiles can hit at same time as a sweetspot and sour spot hit,
#in which case the sour spot and the projectile collissions will be returned)
#therefore, any collsison involved with a projectile will be returned (you may hit 3 projectiles
#with one attack, for example)
#ties are broken by order in map
#params: collisionPairMap : hash map created from 'categorizeCollisionPairs'
#params: cType : the type of collision to fetch
#params: selfOnlyFlag: trueu indicates that only self only collision boxes considered, and false means non-self only considered
func findHighestPriorityCollisionPair(collisionPairMap,cType,selfOnlyFlag):
	
	var res = []
	
	#highest priority is 0, 
	var highestPriority = 123456789 # a low default priorty that will be bigger than any of pairs
	 
	#the list of pairs of the desired type
	var cPairs = collisionPairMap[cType]
	
	var highestPriorityPair = null
	
	#iterate all pairs of the chosen type
	for collisionAreaPair in cPairs:
		

		var _enteringArea = collisionAreaPair[ENTERING_AREA_KEY]
		var _enteredArea = collisionAreaPair[ENTERED_AREA_KEY]
		
		#they will both be self only or not, since can't have a non self only collide with a self only and vice versa,
		#but check both to be safe
		if _enteringArea.selfOnly != selfOnlyFlag or _enteredArea.selfOnly != selfOnlyFlag:
			#skip the pair, they aren't of desired self only type
			continue
		#projectile collision?
		if _enteringArea.is_projectile or _enteredArea.is_projectile:
			res.append(collisionAreaPair)
		
		else:
			#priority will be decided by the pair's total (so 1+2 and 2+1 are same)
			var tmpPriority = _enteringArea.collisionPriority + _enteredArea.collisionPriority
		
			#found a new highest priority pair?
			if tmpPriority < highestPriority:
				highestPriority=tmpPriority
				highestPriorityPair= collisionAreaPair
		
	#did we have a non-projectile collision?
	if highestPriorityPair != null:
		res.append(highestPriorityPair)
		
	#return highestPriorityPair
	return res
func handleHitboxCollision():
		
	if collisionAreas.size() > 0:

		
		var collisionPairMap = categorizeCollisionPairs()
		var selfOnly = false
		#find the players hitting each other collisiosn first
		var hitboxhitboxCollisionPairsNonSelfOnly = findHighestPriorityCollisionPair(collisionPairMap,CollisionType.HITBOX_HITBOX,selfOnly)
		var wasHitCollisionPairsNonSelfOnly = findHighestPriorityCollisionPair(collisionPairMap,CollisionType.HITBOX_HURTBOX,selfOnly)
		var isHittingCollisionPairsNonSelfOnly = findHighestPriorityCollisionPair(collisionPairMap,CollisionType.HURTBOX_HITBOX,selfOnly)
		
		selfOnly=true
		#now find collision of self only nature and add to already found collisison
		var hitboxhitboxCollisionPairsSelfOnly = findHighestPriorityCollisionPair(collisionPairMap,CollisionType.HITBOX_HITBOX,selfOnly)
		var wasHitCollisionPairsSelfOnly = findHighestPriorityCollisionPair(collisionPairMap,CollisionType.HITBOX_HURTBOX,selfOnly)
		var isHittingCollisionPairsSelfOnly = findHighestPriorityCollisionPair(collisionPairMap,CollisionType.HURTBOX_HITBOX,selfOnly)
		
		#now combine both types of collisions (can have a self only hitbox-hurtbox collision and normal hitbox-hurtbox colision
		# at same time. seperate types (as opposed to a sour spot prioritizing sweet spot))
		var hitboxhitboxCollisionPairs = []
		var wasHitCollisionPairs = []
		var isHittingCollisionPairs = []
		#add self only to collisison pairs
		
		#HITBOX-HITBOX
		for pair in hitboxhitboxCollisionPairsNonSelfOnly:
			hitboxhitboxCollisionPairs.append(pair)
		
		for pair in hitboxhitboxCollisionPairsSelfOnly:
			hitboxhitboxCollisionPairs.append(pair)
			
		#HHITBXO-HURTBOX
		for pair in wasHitCollisionPairsNonSelfOnly:
			wasHitCollisionPairs.append(pair)
		
		for pair in wasHitCollisionPairsSelfOnly:
			wasHitCollisionPairs.append(pair)
			
						
		#HURTBOX-HIBOX
		for pair in isHittingCollisionPairsNonSelfOnly:
			isHittingCollisionPairs.append(pair)
		
		for pair in isHittingCollisionPairsSelfOnly:
			isHittingCollisionPairs.append(pair)
			
		collisionAreas.clear()
		
		if (hitboxhitboxCollisionPairs.size() == 0) and (wasHitCollisionPairs.size() ==0) and (isHittingCollisionPairs.size() == 0):
			
			#a collisison was dropped. For exampel, a protection box soaked up the
			#hittbox collision
			return	
	
		
		#before we process any collision, we check for clash (hitbox-hitbox) collisions
		#since disjoint type hitboxes will prioritize a clash over a hurtbox-hitbox collision
		# (by defualt, clashes are ignored when hurtbox-hitbox collisions occur)		
		for hitboxhitboxCollisionPair in hitboxhitboxCollisionPairs:
			var _selfArea = hitboxhitboxCollisionPair[ENTERED_AREA_KEY] 
			var _opponentArea = hitboxhitboxCollisionPair[ENTERING_AREA_KEY] 
			
			#one of the hitboxes trancendant (ignores clashing and hitbox-hitbox collisions entirley)?
			if _opponentArea.clashType == _opponentArea.CLASH_TYPE_TRANS or _selfArea.clashType == _selfArea.CLASH_TYPE_TRANS:
				#CAN'T CLASH WITH TRANSENDENT
				continue
				
			#are the hitboxes clash types that prioritize clashes and override hurtbox collisions?
			if _opponentArea.clashType == _opponentArea.CLASH_TYPE_CLASH_PRIORITY or _selfArea.clashType == _selfArea.CLASH_TYPE_CLASH_PRIORITY:
				#remove the any hurtbox collision the clashing hitboxes are involved with
				removeCollisionPair(_opponentArea,wasHitCollisionPairs)
				removeCollisionPair(_selfArea,isHittingCollisionPairs)
				
				
			
		for wasHitCollisionPair in wasHitCollisionPairs:
			#if (wasHitCollisionPair !=null): 
			
			var hitboxArea = wasHitCollisionPair[ENTERING_AREA_KEY]
			var hurtboxArea = wasHitCollisionPair[ENTERED_AREA_KEY]
					
			var processCollision=true
			if hurtboxArea.projectileInvulnerability and hitboxArea.is_projectile:
				processCollision=false
				#ignore this, hurtbox ignored projectils
			elif hurtboxArea.belongsToProjectile() and hitboxArea.ignoreProjectileCollisions:
				processCollision=false #ignore this, hitbox ignores projectiles
			#were hitting a player with a link-only	hitbox?
			elif not hurtboxArea.belongsToProjectile() and (hitboxArea.hitstunType==GLOBALS.HitStunType.ON_LINK_ONLY or hitboxArea.hitstunType==GLOBALS.HitStunType.ON_LINK_ONLY_AND_HITSTUNLESS):
				#can't hit player that's not in hitstu n with this type of hitbox
				if not hurtboxArea.playerController.playerState.inHitStun: #careful with design here. if a character has link-only hitboxes and projectiles, there may be a frame perfect situation wheere u hit with link only and projectle, and so its' 50/50 if hitstun applies (did projectile hitstunapply first?)
					processCollision=false			
			
			if processCollision:
				#check for hitboxes that are restricted to hitting grounded or airborn opponents
				if not hitboxArea.canHitGroundedTarget and hurtboxArea.playerController.my_is_on_floor(): #hitbox can't hit target on ground?
					processCollision=false
				elif not hitboxArea.canHitAirborneTarget and not hurtboxArea.playerController.my_is_on_floor(): #hitbox can't hit target in air?
					processCollision=false
				elif hitboxArea.hitsWakeupOpponent: #OTG
					#can only hit knocked down opponents?
					#has to be invincibility frames in oki
					
					processCollision= not hurtboxArea.belongsToProjectile() #can't be a projectile. projectiles don't go into wakeup state
					processCollision = processCollision and hurtboxArea.subClass == hurtboxArea.SUBCLASS_INVINCIBILITY #can't hit hormal hurtboxes, has to be invincibility. (part of the wakupe animation has vulnerability frames)
					processCollision = processCollision and hurtboxArea.playerController.wasInInvincibleOki #can only hit opponent in knockdown state		
				
				
			if processCollision:	
				var hittingKnockedDownOpponent=hitboxArea.hitsWakeupOpponent
			
				
				#only trigger the invincibility signal for stanard invincibility hits
				#special hitboxes can peirce trhough knock down invincibility state
				if hurtboxArea.subClass == hurtboxArea.SUBCLASS_INVINCIBILITY:
					if  not hittingKnockedDownOpponent:
						emit_signal("player_invincible_was_hit",hitboxArea,hurtboxArea)
					else:
						
						#TODO: make sure this doesn't bug anything
						#a hack to work around not being able to apply hitstun to knocked down opponent
						#we remove the invincibility from the temporary hurtbox (will only bug out
						#if 2 hitboxes can hitsame frame where the hurtbox is process next in line, and
						hurtboxArea.subClass=hurtboxArea.SUBCLASS_BASIC
						emit_signal("player_was_hit",hitboxArea,hurtboxArea)
				else:
					emit_signal("player_was_hit",hitboxArea,hurtboxArea)
					
				
			#remove any hitboxes that clashed with those that hit a hurtbox (hitting a 
			#hurtbox is higher prioirity than clahsing)
			removeCollisionPair(hitboxArea,hitboxhitboxCollisionPairs)
		
		#end iteratre was hit (hurtbox-hitbox) collision pairs			
		
		
		for isHittingCollisionPair in isHittingCollisionPairs:
			#if (isHittingCollisionPair !=null): 
			var hurtboxArea = isHittingCollisionPair[ENTERING_AREA_KEY]
			var hitboxArea = isHittingCollisionPair[ENTERED_AREA_KEY]
				
			if hurtboxArea.projectileInvulnerability and hitboxArea.is_projectile:
				pass #ignore this, hurtbox ignored projectils
			elif hurtboxArea.subClass == hurtboxArea.SUBCLASS_INVINCIBILITY:
				emit_signal("hitting_invincible_player",hitboxArea,hurtboxArea)
			else:
				emit_signal("hitting_player",hitboxArea,hurtboxArea)	
			
			#remove any hitboxes that clashed with those that hit a hurtbox (hitting a 
			#hurtbox is higher prioirity than clahsing)
			removeCollisionPair(hitboxArea,hitboxhitboxCollisionPairs)
		
		#end iteratre hitting (hurtbox-hitbox) collision pairs			
		
		#handle the hitbox clashing
		for hitboxhitboxCollisionPair in hitboxhitboxCollisionPairs:
			#print("handling clashing")
			var _selfArea = hitboxhitboxCollisionPair[ENTERED_AREA_KEY] 
			var _opponentArea = hitboxhitboxCollisionPair[ENTERING_AREA_KEY] 
			
				#are one of the hitboxes trancendant (ignores clashing and hitbox-hitbox collisions entirley)?
			if _opponentArea.clashType == _opponentArea.CLASH_TYPE_TRANS or _selfArea.clashType == _selfArea.CLASH_TYPE_TRANS:
				#CAN'T CLASH WITH TRANSENDENT
				continue

			emit_signal("player_attack_clashed",_opponentArea,_selfArea)		
		
		#end iteratre clash (hitbox-hitbox) collision pairs			
		
#removes any collision-area pair from an array of pairs that includes the hitboxKey collision area in the pair 
func removeCollisionPair(hitboxKey,pairArr):
	
	var pairsToRemove = []
	
	#go over each collision pair
	for i in pairArr.size():
		
		var collisionPair1 = pairArr[i]
		#print("handling clashing")
		var _selfArea = collisionPair1[ENTERED_AREA_KEY] 
		var _opponentArea = collisionPair1[ENTERING_AREA_KEY] 
		
		#found a collision involving hitbox to remove?
		if (_selfArea ==hitboxKey) or  (_opponentArea ==hitboxKey):
			#we will remove this pair
			pairsToRemove.append(collisionPair1)
			
	#iterate over all indices to remove  (avoid removing objects while iterating over array)
	for objToRemove in	pairsToRemove:
		pairArr.erase(objToRemove)
	
		
			
func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	if ignoreCollisions:
		return
		
	#if proximityGuardEnabledSignal:
		#proximityGuardEnabledSignal=false
		#emit_signal("proximity_guard_enabled_changed",proximityGuardEnabled)
	
	if not wasProximityGuardEnabled and isProximityGuardEnabled():
		wasProximityGuardEnabled=true
		emit_signal("proximity_guard_enabled_changed",true)
	elif wasProximityGuardEnabled and not isProximityGuardEnabled():
		wasProximityGuardEnabled=false
		emit_signal("proximity_guard_enabled_changed",false)
		
		
	#if isGettingHitProtectionEnabled():
	#	wasGettingHitProtectionEnabled=true
	#else:
		#wasGettingHitProtectionEnabled=false
		
	
	#if isHittingProtectionEnabled():
		#wasHittingProtectionEnabled=true
	#else:
		
	#	if wasHittingProtectionEnabled:
			
			#make sure to delay the protection disable by a frame, since 
			#hitbox collision might happend the same frame it got disabled
	
	#		wasHittingProtectionEnabled=false
			
	
	handleHitboxCollision()
	
	
	
	#environmentCollisionCheck()
	

#handles hitting hitboxes
func _on_area_entered_hitbox(_enteringArea,_enteredArea):
	
	if ignoreCollisions:
		return
		
	#protection hitboxes don't interact with other hitboxes
	if _enteringArea is preload("res://HitboxArea.gd"):
		
		if _enteringArea.hitstunType == GLOBALS.HitStunType.PROTECTION:
			return
	
	#our hitbox may be protectino opponent by having their hurtbox enter the protectio nbox
	#if _enteredArea is preload("res://HitboxArea.gd"):
		
	#	if _enteredArea.hitstunType == GLOBALS.HitStunType.PROTECTION:
			
	#		if _enteringArea is preload("res://HurtboxArea.gd"):
	#			numHittingProtectionAreasInRange		= numHittingProtectionAreasInRange	+1
	#			return



				
#	print("in player: " + str(self.get_parent().get_parent())+" area entered hitbox, entered: "+ _enteredArea.name + ", entering"+_enteringArea.name)

	var collisionPair = {
		ENTERED_AREA_KEY:_enteredArea,
		ENTERING_AREA_KEY :_enteringArea
	}
	collisionAreas.push_front(collisionPair)
	pass


func _on_area_exited_hitbox(_enteringArea,_enteredArea):
	if ignoreCollisions:
		return
		
		
	
	#our hitbox may be protectino opponent by having their hurtbox enter the protectio nbox
	#if _enteredArea is preload("res://HitboxArea.gd"):
		
	#	if _enteredArea.hitstunType == GLOBALS.HitStunType.PROTECTION:
			
	#		if _enteringArea is preload("res://HurtboxArea.gd"):
	#			numHittingProtectionAreasInRange	= numHittingProtectionAreasInRange	-1
	#			return
				
	pass



#handles hitting hurtboxes
func _on_area_entered_hurtbox(_enteringArea,_enteredArea):
#	print("in player: " + str(self.get_parent().get_parent())+" area_entered_hurtbox: entered "+_enteredArea.name+ ", entering "+_enteringArea.name)

	if ignoreCollisions:
		return
		
	if _enteringArea is preload("res://ProximityGuardArea.gd"):
		
		#a proxity guard area in range for first time?
		#if not isProximityGuardEnabled():	
		#if not proximityGuardEnabled:
			#proximityGuardEnabledSignal=true
			#var proximityGuardEnabled = true
			
			#defer the signal since this signal handler function called during physiscs step
			#need to wait for collision processing to finish
			#call_deferred("emit_signal","proximity_guard_enabled_changed",proximityGuardEnabled)
		numProxityGuardAreasInRange = numProxityGuardAreasInRange + 1
		#proximityGuardEnabled=true
		return
	
	#if _enteringArea is preload("res://HitboxArea.gd"):
		
	#	if _enteringArea.hitstunType == GLOBALS.HitStunType.PROTECTION:
			
	#		numGettingHitProtectionAreasInRange= numGettingHitProtectionAreasInRange +1
			#will prevent victim from getting hit 
	#		return
	
	
	
	var collisionPair = {
		ENTERED_AREA_KEY:_enteredArea,
		ENTERING_AREA_KEY :_enteringArea
	}
	
	#var collisionInfo = findOverlappingShapes(_enteringArea,_enteredArea)
	#if collisionInfo:
	#	call_deferred("emit_signal","player_was_hit_collision_info",collisionInfo)
	collisionAreas.push_front(collisionPair)
	

#handles areas exiting hurtboxes ()
func _on_area_exited_hurtbox(_enteringArea,_enteredArea):
#	print("in player: " + str(self.get_parent().get_parent())+" area_entered_hurtbox: entered "+_enteredArea.name+ ", entering "+_enteringArea.name)
	if ignoreCollisions:
		return
		
	if _enteringArea is preload("res://ProximityGuardArea.gd"):
		
		
		#if isProximityGuardEnabled():
		#	var proximityGuardEnabled = false
			#defer the signal since this signal handler function called during physiscs step
			#need to wait for collision processing to finish
		#	call_deferred("emit_signal","proximity_guard_enabled_changed",proximityGuardEnabled)
			
		numProxityGuardAreasInRange = numProxityGuardAreasInRange - 1
		return

	#if _enteringArea is preload("res://HitboxArea.gd"):
		
	#	if _enteringArea.hitstunType == GLOBALS.HitStunType.PROTECTION:
			
	#		numGettingHitProtectionAreasInRange= numGettingHitProtectionAreasInRange -1
			#will prevent victim from getting hit 
	#		return
	
	#if _enteredArea is preload("res://HitboxArea.gd"):
		
#		if _enteredArea.hitstunType == GLOBALS.HitStunType.PROTECTION:
			
#			numHittingProtectionAreasInRange		= numHittingProtectionAreasInRange	-1
			#will prevent victim from getting hit 
#			return
	
	pass
	

#func environmentCollisionCheck():
func environmentCollisionCheck(mvmManager):
	
	#here, by design, you can't be bumping into a wall and bumping into an opponent 
	#as a wall (would have to simultaneously move left and right)
		#here, by design, you can't land on floor and opponent at same time
	#since will makeu platforms and floor hegith != opponent bodybox hieght
	#here, by design, you can't be bumping into a celing and bumping into an opponent from below
	
	if playerController == null:
		return

	var kinbody = playerController.kinbody
	#var opponentKinbody = playerController.opponentPlayerController.kinbody

	#save if we were on the ground last frame
	#var wasOnGroundCopy = wasOnGround
	#var wasOnPlatformCopy = wasOnPlatform

	var kinematicBodyCollisionFlag = false
	var staticBodyCollisionFlag = false
	#for colliderIx in kinbody.get_slide_count():		
	for collider in mvmManager.colliders:		
		#var collision = kinbody.get_slide_collision(colliderIx)

		
		
		#var collider = collision.collider
		if collider is KinematicBody2D: #hit player
			kinematicBodyCollisionFlag=true
			#don't signal any player hits
		elif collider is StaticBody2D: #hit environment
			
			staticBodyCollisionFlag = true
			#error checking
			#if not collision.collider is preload("res://EnvironmentStaticBody2D.gd"):
			if not collider is preload("res://EnvironmentStaticBody2D.gd"):
				print("warning, bumping into rogue envrionemnt. (forgot to attach EnvironmentStaticBody2D.gd to static body)")
				#ignore this collision
				continue
			#by design, we can't be standing on two envrionemntes at same time 
			#so, if on floor, then collider is our floor
			if collider.type == collider.TYPE_FLOOR or collider.type == collider.TYPE_PLATFORM:
				#were in the air last frame, but now on ground? ie, landed
				if wasInAir: 
					wasInAir= false
					
					#	print("warning, landing on something that wasn't TYPE_FLOOR or TYPE_PLATFORM")
					#else:
						
					if collider.type == collider.TYPE_FLOOR:
						
					#	print("new event: landing on floor: "+str(self))
						emit_signal("landing_on_ground")
						wasOnGround = true
						wasOnPlatform = false
					elif collider.type == collider.TYPE_PLATFORM:
						wasOnGround = false
						wasOnPlatform = true
						emit_signal("landing_on_platform")
					#	print("new event: landing on platform: "+str(self))	
					else:
						print("new event: landing on some other unknown envrionemnt: "+str(self))	
				#else:
					#already on ground, ignore this, don't signal anything
				#	pass
			elif collider.type == collider.TYPE_WALL: #elif kinbody.is_on_wall():
					
				#last frame not against wall?
				if not wasAgainstWall:
					wasAgainstWall= true
					#if collider.type != collider.TYPE_WALL:
					#	print("warning, bumping into something that wasn't TYPE_WALL")
					#else:
						
					#print("new event: against wall: "+str(self))
					emit_signal("pushed_against_wall",collider)
				else:
					#already on ground, ignore this, don't signal anything
					pass
			if collider.type == collider.TYPE_CEILING: #elif kinbody.is_on_ceiling():
					
				#last frame not against ceiling?
				if not wasAgainstCeiling:
					wasAgainstCeiling= true
					#if collider.type != collider.TYPE_CEILING:
					#	print("warning, bumping into something that wasn't TYPE_CEILING")
					#else:
						
				#	print("new event: against ceiling: "+str(self))
					emit_signal("pushed_against_ceiling",collider)
				else:
					#already on ground, ignore this, don't signal anything
					pass
	#end loop
	
	
	#projectiles don't implement this ray cast
	if playerController.leftCornerDetector != null:
		if playerController.leftCornerDetector.is_colliding():
		
			
			#not in the corner last frame?
			if not wasInLeftCorner:
				wasInLeftCorner=true
				emit_signal("entered_left_corner")
		else:
			#in the corner last frame?
			if wasInLeftCorner:
				wasInLeftCorner=false
				emit_signal("exited_left_corner")
				
		#near wall right left
	#projectiles don't implement this ray cast
	if playerController.rightCornerDetector != null:
		if playerController.rightCornerDetector.is_colliding():
			#not in the corner last frame?
			if not wasInRightCorner:
				wasInRightCorner=true
				emit_signal("entered_right_corner")
		else:
			#in the corner last frame?
			if wasInRightCorner:
				wasInRightCorner=false
				emit_signal("exited_right_corner")
	
	#projectiles don't implement this ray cast
	#if kinbody.hittingLeftWallDetector != null:
	#	var againstDisableBodyBoxWall = false
		#for now using hitting left wall detector, but might want a dedicated raycast for this
	#	againstDisableBodyBoxWall = playerController.kinbody.disableBodyBoxLeftWallDetector.is_colliding()
	#	againstDisableBodyBoxWall = againstDisableBodyBoxWall or playerController.kinbody.disableBodyBoxRightWallDetector.is_colliding()
		
		#not against wall last frame
	#	if againstDisableBodyBoxWall and not wasInDisabledBodyBoxWallArea:
	#		wasInDisabledBodyBoxWallArea=true
	#		emit_signal("entered_disabled_body_box_wall_area")
	#	elif not againstDisableBodyBoxWall and wasInDisabledBodyBoxWallArea:
	#		wasInDisabledBodyBoxWallArea=false
	#		emit_signal("exited_disabled_body_box_wall_area")


func stoppedEnvironmentCollisionCheck(wasOnGroundCopy,wasOnPlatformCopy,mvmManager):
	
	
	if playerController == null:
		return

	var kinbody = playerController.kinbody
	
	#if not kinematicBodyCollisionFlag:
		
	#left the ground? (last frame we were on ground, and not we are not?)
	#if not kinbody.is_on_wall() and wasAgainstWall:
	if not mvmManager.on_wall and wasAgainstWall:
	
		wasAgainstWall = false
		#print("new event: left wall: "+str(self))
		emit_signal("left_wall")

	#left the ground? (last frame we were on ground, and not we are not?)
	#if not kinbody.is_on_ceiling() and wasAgainstCeiling:
	if not mvmManager.on_ceiling and wasAgainstCeiling:
		wasAgainstCeiling = false
		#print("new event: left ceiling: "+str(self))
		emit_signal("left_ceiling")

	#left the ground? (last frame we were on ground, and not we are not?)
	#if not kinbody.is_on_floor() and not wasInAir:
	if not mvmManager.on_floor and not wasInAir:
		wasInAir = true
		
		if wasOnGround:
			#print("new event: left ground: "+str(self))	
			emit_signal("left_ground")
		elif wasOnPlatform:
			#print("new event: left platform: "+str(self))	
			emit_signal("left_platform")
		else:
			print("new event: left unknown floor type")	
		wasOnGround = false
		wasOnPlatform = false
		#start true to avoid signaling on land, we only signal upon walking onto edge, and back into ground center mass
		wasGroundRayCastColliding = true
		wasLeftPlatformRayCastColliding = true
		wasRightPlatformRayCastColliding = true


	#only check the ray casts walk on edge signal when we were already on the ground last frame
	#and still are on ground
	if wasOnGroundCopy and wasOnGround:
		#check to see if ray casts arn't hitting but were on ground/platform
		if wasGroundRayCastColliding and not playerController.floorDetector.is_colliding():
			wasGroundRayCastColliding = false
			#print("new event: arrived at edge of ground (ground ray cast not colliding): "+str(self))
			emit_signal("entered_ground_ledge")
			
		#check to see if ray casts arn't hitting but were on ground/platform
		if not wasGroundRayCastColliding and playerController.floorDetector.is_colliding():
			wasGroundRayCastColliding = true
			#print("new event:  returned to ground center mass (ground ray cast colliding): "+str(self))
			emit_signal("left_ground_ledge")
	
#	if  wasOnPlatformCopy and wasOnPlatform:
	#check to see if ray casts arn't hitting but were on ground/platform
	if wasLeftPlatformRayCastColliding and not playerController.leftPlatformDetector.is_colliding() and playerController.rightPlatformDetector.is_colliding(): # the 2nd colliding check is to make sure your not wlaking off, where both stop touching
		wasLeftPlatformRayCastColliding = false
		#print("new event: arrived at left edge of platform (platform ray cast not colliding): "+str(self))
		emit_signal("entered_platform_left_ledge")
	
	#check to see if ray casts arn't hitting but were on ground/platform
	if not wasLeftPlatformRayCastColliding and playerController.leftPlatformDetector.is_colliding():
		wasLeftPlatformRayCastColliding = true
		#print("new event:  returned (from left) to platform center mass (platform ray cast colliding): "+str(self))
		emit_signal("left_platform_left_ledge")
	
	#check to see if ray casts arn't hitting but were on ground/platform
	if wasRightPlatformRayCastColliding and not playerController.rightPlatformDetector.is_colliding() and playerController.leftPlatformDetector.is_colliding():
		wasRightPlatformRayCastColliding = false
	#	print("new event: arrived at right edge of platform (platform ray cast not colliding): "+str(self))
		emit_signal("entered_platform_right_ledge")
	
	#check to see if ray casts arn't hitting but were on ground/platform
	if not wasRightPlatformRayCastColliding and playerController.rightPlatformDetector.is_colliding():
		wasRightPlatformRayCastColliding = true
		#print("new event:  returned (from right) to platform center mass (platform ray cast colliding): "+str(self))
		emit_signal("left_platform_right_ledge")


	
	pass


func onOpponentCheck(mvmManager):
	
#	var wasOnOpponentLastFrame = isOnOpponent()
	
	#will be true when we landed on opponent this frame
#	var landedOnOpponentLeftRayCastFlag = false
#	var landedOnOpponentRightRayCastFlag = false
	
	#will be true when stopped being on opponent
#	var exitOpponentLeftRayCastFlag = false
#	var exitOpponentRightRayCastFlag = false
	
	
	#check if last frame we weren't on the opponent and slightly right
#	if playerController.leftOpponentDetector.is_colliding():
#		if not wasLeftOpponentRayCastColliding:
#			wasLeftOpponentRayCastColliding = true
#			landedOnOpponentLeftRayCastFlag = true
#	else: #we may be leaving the opponent now (no longer on them
#		if wasLeftOpponentRayCastColliding:
#			wasLeftOpponentRayCastColliding = false
#			exitOpponentLeftRayCastFlag = true
			
		#print("new event:  returned (from left) to platform center mass (platform ray cast colliding): "+str(self))
		#emit_signal("left_platform_left_ledge")
	#check if last frame we weren't on the opponent and slightly left
#	if playerController.rightOpponentDetector.is_colliding():
#		if not landedOnOpponentRightRayCastFlag:
#			wasRightOpponentRayCastColliding = true
#			landedOnOpponentRightRayCastFlag = true	
#	else:
#		if landedOnOpponentRightRayCastFlag:
#			wasRightOpponentRayCastColliding = false
#			exitOpponentRightRayCastFlag = true	
	
	#for now, signal every frame
	#now, when either ray cast collided this frame, we on opponent
#	if landedOnOpponentLeftRayCastFlag or landedOnOpponentRightRayCastFlag:

	if playerController.rightOpponentDetector.enabled and playerController.leftOpponentDetector.enabled:
		if playerController.rightOpponentDetector.is_colliding() or playerController.leftOpponentDetector.is_colliding():
			
			
			#default to no wall raycast collisions
			var inCornerStatus = GLOBALS.OnOpponentStatus.NOT_AGAINST_WALL 
			
			#against wall on left (in left corner)
			if playerController.leftWallDetector.is_colliding():
				inCornerStatus= GLOBALS.OnOpponentStatus.AGAINST_LEFT_WALL
			elif playerController.rightWallDetector.is_colliding():
				inCornerStatus= GLOBALS.OnOpponentStatus.AGAINST_RIGHT_WALL
			#avoid signaling on opponent twic
		#	if not wasOnOpponentLastFrame:
			emit_signal("landed_on_opponent",inCornerStatus)
		else:
			emit_signal("stopped_standing_on_opponent")
	else:	
		emit_signal("stopped_standing_on_opponent")
		return 
	#both ray casts musn't be colliding with opponent to trigger stop standing on opponent signal
#	if (not playerController.rightOpponentDetector.is_colliding()) and (not playerController.leftOpponentDetector.is_colliding()):
#		emit_signal("stopped_standing_on_opponent")
		
#func isOnOpponent():
#	return wasRightOpponentRayCastColliding or wasLeftOpponentRayCastColliding


func isProximityGuardEnabled():
	#there exist at least one area in range
	return numProxityGuardAreasInRange > 0
	
#func isGettingHitProtectionEnabled():
	#a protection box is colliding with us, so we immune to hitboxe collisions
#	return numGettingHitProtectionAreasInRange > 0

#func isHittingProtectionEnabled():
	#a protection box is colliding with opponent, so opponent immune to hitboxe collisions
#	return numHittingProtectionAreasInRange > 0


#returns information on the collision of two areas, and null if they don't overlap
func findOverlappingShapes(hitboxArea,hurtboxArea):
	
	
	
	var query = Physics2DShapeQueryParameters.new()
	query.collide_with_areas=true
	query.collide_with_bodies=false
	
	query.collision_layer=hurtboxArea.collision_layer
	var space_state = hurtboxArea.get_world_2d().get_direct_space_state() #Physics2DDirectSpaceState
	
	#var transform =playerController.opponentPlayerController.kinbody.get_transform()
	var transform =hitboxArea.getParentKinbody().activeNodes.get_transform()
	#var transform = playerCokinbody.get_transform()
	#transform = transform.scaled(hitboxArea.playerController.kinbody.activeNodes.scale)
	#var transform =hitboxArea.get_transform()
	#var transform =layerController.opponentPlayerController.kinbody.get_transform()
	#var transform =hitboxArea.get_transform()
	for shp1 in hitboxArea.get_children():
		
		if not shp1 is CollisionShape2D or shp1.disabled:
			continue
		#var newTransform = transform
		#newTransform.rotated(deg2rad(shp1.rotation_degrees))
		query.set_transform(transform)
		query.set_shape(shp1.shape)	
		
		#var result = space_state.get_rest_info(query) 
		var max_res = 5#at most 16 point2
		var result = space_state.collide_shape(query,max_res) 
		
		
		#TODO: do logic to find a point where intersectin of
		#the two shapes are, CAUSE ATM the points found is prtetty close, but
		#definely feels off, since at time the little icon is way off
		#if result:
		#	return result
		if result.size()>0:
			
			#return  result[0]+shp1.global_position
			#return result[0]
#			var tmpres = []
			
			var centerPoint = Vector2(0,0)
			var maxX = result[0].x
			var maxY = result[0].y
			var minX = result[0].x
			var minY = result[0].y
			for i in result.size():
				result[i] = result[i]+shp1.position
				#meanPoint=meanPoint+result[i]+shp1.position
				if result[i].x >maxX:
					maxX= result[i].x
				if result[i].y >maxY:
					maxY= result[i].y
				if result[i].x <minX:
					minX= result[i].x
				if result[i].y <minY:
					minY= result[i].y
			#	var rotation_point = result[i]
			#	var rotation_around_point =  deg2rad(shp1.rotation_degrees)
			#	var distance_from_point = rotation_point.distance_to(rotation_around_point)
			#	var pos =rotation_point
			#	pos = pos + Vector2(cos(rotation_around_point), sin(rotation_around_point)) * distance_from_point
			#	var t = Transform2D()
			#	t.origin=result[i]+shp1.position
			#	var rot = deg2rad(shp1.rotation_degrees)
			#	t.x.x=cos(rot)
			#	t.y.y=cos(rot)
			#	t.x.y=sin(rot)
			#	t.y.x=-sin(rot)
				
			#	t.x =t.y*shp1.scale.x
			#	t.y =t.y*shp1.scale.y
				
				#result[i]=t.p
				#tmpres.append(pos)
			var minVec = Vector2(minX,minY)
			var maxVec = Vector2(maxX,maxY)
		#	centerPoint.x =minX +((maxX+minX)/2.0)
		#	centerPoint.y =minY +((maxY+minY)/2.0)
			
			
			#distance between glove and the ball
			var distance = minVec.distance_to(maxVec)
			
			#compute a vector that is follwoing the vector between glove and ball, and got beyond glove
			#20% of distance. #use that as target
			centerPoint = Vector2(maxVec.x - minVec.x,maxVec.y - minVec.y)
			
			centerPoint = centerPoint * 0.5
			var target = minVec + centerPoint
			
			#meanPoint.x = meanPoint.x/float(result.size())
			#meanPoint.y = meanPoint.y/float(result.size())
			result.append(target)
			return result
			#iterate over all points, searching for those nearest to center of playre
		#	var center = playerController.kinbody.getCenter()
			
		#	var res = result[0]
		#	var minDist=result[0].distance_to(center)
			
		#	for pt in result:
		#		if pt.distance_to(center) < minDist:
		#			res = pt
		#			minDist=pt.distance_to(center)
			
		#	return res
			
			
	
	return null			
#	gameCollisionInfoRes


func _on_hitbox_activated(hb):
	pass
	
	
func _on_entered_opponents_body_box(enteredBody):
	if ignoreCollisions:
		return
		
	wasInsideOpponent=true
	emit_signal("entered_opponent_body_box")

func _on_exited_opponents_body_box(exitedBody):
	if ignoreCollisions:
		return
	wasInsideOpponent=false
	emit_signal("exited_opponent_body_box")
	
func collisionsPairsContainProtectionHitbox(pairs):
	
	#handle the hitbox clashing
	for collisionPair in pairs:
		
		var _selfArea = collisionPair[ENTERED_AREA_KEY] 
		var _opponentArea = collisionPair[ENTERING_AREA_KEY] 
		
		if _selfArea is preload("res://HitboxArea.gd"):
			if _selfArea.hitstunType == GLOBALS.HitStunType.PROTECTION:
				return true
		elif _opponentArea is preload("res://HitboxArea.gd"):
			if _opponentArea.hitstunType == GLOBALS.HitStunType.PROTECTION:
				return true
	return false	