extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

enum MovementType{
	RELATIVE_TO_STAGE,
	RELATIVE_TO_PLAYER
}

enum BehaviorType{
	BASIC,
	MATERIAL,
	MATERIAL_NO_FALSE_WALLS,
	PUSHES,
	PUBLIC_ENVIRONMENT,
	SELF_ENVIRONMENT,
	OPPONENT_ENVIRONMENT,
	MATERIAL_NO_FALSE_CEILING
}

const NO_USER_DEFINED_STARTING_ACTION_ANIMATION = -1
export (String) var projectileScenePath = "res://projectiles/pushable_projectile.tscn"
#var projectileScene = preload("res://projectiles/pushable_projectile.tscn")

export (MovementType) var mvmType = 0
export (BehaviorType) var behaviorType = 0
export (int) var projectileStartingActionId = -1
var projectileScene = null

var position2DNode = null

var maxNumProjectiles = -1 #set by parent projectile sprite frame
var inactiveProjectilesNode = null
var inactiveProjectiles = []
var spawnPoint  = null

var projectileParentSpriteAnimation = null
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	readyHook()
	pass
	
func readyHook():
	projectileScene=load(projectileScenePath)
	
	loadSpawnPoint()

func loadSpawnPoint():
	if self.has_node("Position2D"):
		position2DNode = get_node("Position2D")
	
	#resolve position
	if position2DNode != null:
		spawnPoint = Vector2(position2DNode.position.x,position2DNode.position.y)
	else:
		#undefined, so just (0,0)
		spawnPoint = Vector2(0,0)
		
func init(_maxNumProjectiles,playerController):
	
	
	maxNumProjectiles = _maxNumProjectiles
	#create node to store inactive projectiles
	inactiveProjectilesNode = Node.new()
	self.call_deferred("add_child",inactiveProjectilesNode)
	#inactiveProjectilesNode.owner = self
	
	#instance a projectile for all potentia projectiles created
	#to load them all as inactive projectils
	#multiply by 2 since we always want an entire set of projectiles to
	#isntance in case all the previous active ones get destoryed same frame as we activating
	#new ones
	for i in range(maxNumProjectiles): 
		
		var projectile = createProjectileInstance()
		inactiveProjectilesNode.call_deferred("add_child",projectile)
		inactiveProjectiles.append(projectile)
		yield(projectile,"projectile_ready")
		#projectile.owner = inactiveProjectilesNode
		projectile.masterPlayerController = playerController
		projectile.init()
		projectile.connect("destroyed",self,"_on_projectile_destroy")
		playerController._on_inactive_projectile_instanced(projectile,projectileScenePath)
	
	
func _on_projectile_destroy(projectile):
	
	if projectile.supportsReparentingOnDestroy:
		#reparent the projectile. Remove from it's current parent and place back into inactive
		var projectileParent = projectile.get_parent()
		projectileParent.remove_child(projectile)
		inactiveProjectilesNode.add_child(projectile)
		
		projectile.set_owner(inactiveProjectilesNode)
		
	inactiveProjectiles.append(projectile)
	
#fetches an inactive projectile from preloaded list
func getProjectileInstance():
	
	var res = null
	
	#iterate the preloaded inactive projectile instances
#	for inactiveProjectile in inactiveProjectilesNode.get_children():
	for i in inactiveProjectiles.size():
		var inactiveProjectile = inactiveProjectiles[i]
		#var projectile = inactiveProjectilesNode.get_child(i)
		
		res = inactiveProjectile
							
		#only remove child if reparenting projectile
		if inactiveProjectilesNode.is_a_parent_of(inactiveProjectile):
			inactiveProjectilesNode.remove_child(inactiveProjectile) #no longer an inactive projectil
		inactiveProjectiles.remove(i)
		break
			
		
	return res
	
func createProjectileInstance():
	var obj = projectileScene.instance()
	obj.mvmType = mvmType
	obj.behaviorType = behaviorType
	
	
	#we have defined a different starting action animation than default?
	if projectileStartingActionId != NO_USER_DEFINED_STARTING_ACTION_ANIMATION:
		obj.startingActionId=projectileStartingActionId
	
	obj.projectileParentSpriteAnimation = projectileParentSpriteAnimation
	return obj
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func getInactiveProjectiles():
	#if inactiveProjectilesNode != null:
	#	return inactiveProjectilesNode.get_children()
	#else:
	#	return []
	return inactiveProjectiles