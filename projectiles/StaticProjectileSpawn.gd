extends "res://projectiles/ProjectileSpawn.gd"


var playerController = null

var staticPorjectileSpawn = null

#can be used by subclass and player controller sync
#to decide how projectiles are instanced
#could be used as an id of type of projectile to spawn, for example
export (int) var customProjectileSpawnData = 0
func _ready():
	pass

#override the ready logic of parent
func readyHook():
	
	#don't load the scene, we use a preloaded scene from glove controller
	loadSpawnPoint()
	
func init(_maxNumProjectiles,_playerController):
	
	maxNumProjectiles = _maxNumProjectiles
	
	playerController = _playerController
	
	staticPorjectileSpawn = playerController.getStaticProjectileSpawn(customProjectileSpawnData)
	
	
func _on_projectile_destroy(projectile):
	#do nothing, just override parent function
	pass
	
	
#fetches an inactive projectile from preloaded list
#any instance of this calls will fetch same projectie, only requiring loading once per scene,
#instead of once per spawn scrip
func getProjectileInstance():
	
	#get an instance from the global spawn point that manages the one type of projectile
	var staticProjectile = staticPorjectileSpawn.getProjectileInstance()

	if(staticProjectile ==null):
		#print("failed to get projectile instance, jmake sure it isn't being destoryed and spawn nearly at same time")
		return 
	staticProjectile.mvmType = mvmType
	staticProjectile.behaviorType = behaviorType
	
	
	#we have defined a different starting action animation than default?
	if projectileStartingActionId != NO_USER_DEFINED_STARTING_ACTION_ANIMATION:
		staticProjectile.startingActionId=projectileStartingActionId
		
	return staticProjectile

	
func createProjectileInstance():
	#do nothing, just override parent function
	pass
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

