extends "res://SpriteFrame.gd"

#indicates how many projectiles can be create from multiple
#re-uses of this animatio frame
export (int) var maxNumProjectiles = 1

var projectileSpawns = []

var numberOfLiveInstances = 0
var liveInstances = []

var projectileIndexAgeQueue = []

func _ready():	
	var projectileSpawnsParent = $projectiles
	
	#populate the live instances array with null values
	#array will be no larger that max number of projectile that can spawn
	var i = 0
	while i < maxNumProjectiles:
		liveInstances.append(null)
		projectileIndexAgeQueue.append(null)
		i = i +1
	
	#do the projectils potentially exist?
	if projectileSpawnsParent != null:
		for c in projectileSpawnsParent.get_children():
			if c is preload("ProjectileSpawn.gd"):
		#	var script = c.get_script()
		#	if script != null:
		#		var scriptName = script.get_path().get_file()
				#a node with projectile spawn info?
		#		if scriptName == "ProjectileSpawn.gd":
					#add the spawn info to list
				projectileSpawns.append(c)
				

#override parent	
func init(sprite,collisionAreas,bodyBox,activeNodes,playerController):
	.init(sprite,collisionAreas,bodyBox,activeNodes,playerController)
	#initialize all inactive projectiles
	for ps in projectileSpawns:
		ps.init(maxNumProjectiles,playerController)


func signalProjectileCreation():
	#make sure no projectiles are created if max is 0
	if maxNumProjectiles == 0:
		return
	
	#iterate all the projectiles that spawn from this frame
	for spawn in projectileSpawns:
		
		
		#var projectileInstance = spawns.createProjectileInstance()
		
		
		#find a free slot in the live instance array
		var j=0
		
		for i in liveInstances:
			#found a free slot?
			if i == null:
				break
			j = j +1
		
		#the instance buffer is full (too many active projectiles created by this frame)?
		if j == liveInstances.size():
			
			#get index of most old projtile in the live instances
			j = findOldestProjectileIndex()
			
			#validity checking
			if j == null:
				print("error tryig to find oldest projectile index")
				return
				
				
		#now, if we have exceeded max number of projectiles, destroy oldest one
		#older one here is just those at start of looping index
		if liveInstances[j] != null:
			#this will destory it and do some book-keeping using signals
			#(see func _on_destroy_projectile)
			liveInstances[j].destroy()
		
		var projectileInstance = spawn.getProjectileInstance()	
		
		if projectileInstance == null:
			#print("Nullpointer. internal logic error when creating projectile. Expected preloaded instance, but it was null")
			return
		liveInstances[j] = projectileInstance
		
		storeProjectileIndex(j)
		
		#we  connect to signal of projectil destruction, and by providing the current index of
		#live instance array ('numberOfLiveInstances'), when projectile is destoryed we will
		#be notified and the index of the object too
		projectileInstance.connect("destroyed",self,"_on_destroy_projectile",[j])
		
		#get the parent animation of this sprite frame
		var spriteAnimation = getSpriteAnimation()
		
		#save the sprite animation that created this projectile
		projectileInstance.projectileParentSpriteAnimation =spriteAnimation
		
		#use a cyclic index to keep track of what instance we are at
		#emit_signal("create_projectile",projectileInstance,spawns.spawnPoint)
		emit_signal("create_projectile",projectileInstance,spawn.spawnPoint)


#param disableHitboxes: flag that's true when hitboxes are disabled, and false when not
func activate(disableHitboxes,disableSelfOnlyHitboxes,forceProximityGuardDisable,disableActiveFrameSet):
	
	#in addition to activating hitboxes and other frame activation stuff
	#also create projectiles
	.activate(disableHitboxes,disableSelfOnlyHitboxes,forceProximityGuardDisable,disableActiveFrameSet)
	
	var playerController = self.spriteAnimation.playerController
	
	#check with player controller if ready to create a projectil
	#by default will always be ready, but sub classes like gloevcontrolelr
	#will decide yes or no to create ball or not
	if playerController.readyToCreateProjectileHook(self):
		call_deferred("signalProjectileCreation")
	
#ix is index the projectil instance was stored in liveInstances
func storeProjectileIndex(ix):
	
	#find first free slot
	#var j = 0
	#iterate all indexes and search for one to remove
	#for  i in 	projectileIndexAgeQueue:
		
		#found the target index to remove?
	#	if i == null:
	#		projectileIndexAgeQueue[j] = ix
	#		return
	#	j = j + 1
	#var i = 
	
	#no room, so push the index at front of all the others
	projectileIndexAgeQueue.push_front(ix)
	
	#last element not null?
	#if projectileIndexAgeQueue[projectileIndexAgeQueue.size()-1] != null:
	#	print("errro, projectile age index buffer is full. logical bug exists somewhere. Dropping oldest index")

	#bump all the indexs back and make room for new index
	#while i >=0:
		
	#	var ix = projectileIndexAgeQueue[i]
		
		#the buffer is full (last element will be dropped if we don't take care)
		
	#		return ix
	#	i = i -1
	#pass
	
#retreives the index of oldest projectile instance
#null when no oldest instance
func findOldestProjectileIndex():
	
	var i = projectileIndexAgeQueue.size()-1
	
	#iterate the end of queue for first non-null index
	while i >=0:
		var ix = projectileIndexAgeQueue[i]
		
		#we found a projectile's index that is still active (not null)
		if ix != null:
			return ix
		i = i -1
	
	return null
	
func removeProjectileIndex(ix):
	
	#if ix < 0 or ix >= projectileIndexAgeQueue.size():
		#print("error: improper age index usage when forgetting projectiles indexes, index: "+projectilIx)
		#return
	var j = 0
	#iterate all indexes and search for one to remove
	for  i in 	projectileIndexAgeQueue:
		
		#found the target index to remove?
		if i == ix:
			projectileIndexAgeQueue[j] = null
			return
		j = j + 1
		
	
#note, this is called when projectiles get destroyed, and index is managed by signal connection in 
#activate function.
func _on_destroy_projectile(projectile,projectilIx):
	
	if projectilIx < 0 or projectilIx >= liveInstances.size():
		print("error: improper index usage when destorying projectiles, index: "+projectilIx)
		return
	
	if projectile != null: 
		projectile.disconnect("destroyed",self,"_on_destroy_projectile")
	
	#make sure index queue to track age forget about the deleted projectile
	removeProjectileIndex(projectilIx)
	#remove the reference of the projectile from live projectiles
	liveInstances[projectilIx]=null
#	pass


func getAllInactiveProjectiles():
	var res = []
	
	#go over all the projectiles that can spawn in this frame
	for spawn in projectileSpawns:
		
		#iterate over all instances from spawn
		var instances = spawn.getInactiveProjectiles()
		
		for i in instances:
			res.append(i)
			
			
	return res
			
		