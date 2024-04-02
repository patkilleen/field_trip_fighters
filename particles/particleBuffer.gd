extends Node2D

export (PackedScene) var particle=null
export (int) var queueSize=16
const ONE_SHOT_PARTICLES_RESOURCE = preload("res://particles/one-shot-particles.gd")
var index = 0

func _ready():
	
	#the type of scene to make many instances of is not defined?
	if particle != null:
		for _i in range(queueSize):
			
			#make srue oneshot particles don't have process any finished emitting logic. 
			#the buffer does all of the work
			if particle is preload("res://particles/one-shot-particles.gd"):
				particle.timer.disconnect("timeout",particle,"_finished_emitting")
			add_child(particle.instance())
	else:
		
		var particles=null
		#maybe a child is defined (no scene exists, it's just a particles 2d )
		for c in self.get_children():
			
			#found particles2d child?
			if c is Particles2D:
				particles=c
				
		#make copy of the particles
		for _i in range(queueSize-1):
			var newParticles = particles.duplicate()
			self.add_child(newParticles)
func get_next_particle():
	
	return get_child(index)

func trigger():
	var particles = get_next_particle()
	
	if particles is ONE_SHOT_PARTICLES_RESOURCE:
		particles.set_emitting(true)
	else:
		particles.emitting=true
	particles.visible=true
	index = (index+1)%queueSize
	
	if particles.one_shot:
		particles.restart()
	