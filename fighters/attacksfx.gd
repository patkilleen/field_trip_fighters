extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (Texture) var meleeParticle = null
export (Texture) var specialParticle = null
export (Texture) var toolParticle = null
var attackSFXResource = preload("res://particles/attack-sfx/AttackSFX.tscn")

var inputManager = null
func _ready():
	#not using input manager for processing input, just to access command enums
	inputManager = $inputManager
	inputManager.set_process(false)
	inputManager.set_physics_process(false)
	pass
	
func displayCommandParticles(cmd):
	
	
	
	var dir = 0
	match(cmd):
		inputManager.Command.CMD_NEUTRAL_MELEE:
			var sfx = attackSFXResource.instance()
			sfx.texture=meleeParticle
			dir = sfx.Direction.NEUTRAL
			self.add_child(sfx)
			sfx.owner = self
			sfx.init()
			sfx.activate(dir)
		inputManager.Command.CMD_DOWNWARD_MELEE:
			var sfx = attackSFXResource.instance()
			sfx.texture=meleeParticle
			dir = sfx.Direction.DOWN
			self.add_child(sfx)
			sfx.owner = self
			sfx.init()
			sfx.activate(dir)
		inputManager.Command.CMD_UPWARD_MELEE:
			var sfx = attackSFXResource.instance()
			sfx.texture=meleeParticle
			dir = sfx.Direction.UP
			self.add_child(sfx)
			sfx.owner = self
			sfx.init()
			sfx.activate(dir)
		inputManager.Command.CMD_FORWARD_MELEE:
			var sfx = attackSFXResource.instance()
			sfx.texture=meleeParticle
			dir = sfx.Direction.RIGHT
			self.add_child(sfx)
			sfx.owner = self
			sfx.init()
			sfx.activate(dir)
		inputManager.Command.CMD_BACKWARD_MELEE:
			var sfx = attackSFXResource.instance()
			sfx.texture=meleeParticle
			dir = sfx.Direction.LEFT	
			self.add_child(sfx)
			sfx.owner = self
			sfx.init()
			sfx.activate(dir)
		inputManager.Command.CMD_NEUTRAL_SPECIAL:
			var sfx = attackSFXResource.instance()
			sfx.texture=specialParticle
			dir = sfx.Direction.NEUTRAL
			self.add_child(sfx)
			sfx.owner = self
			sfx.init()
			sfx.activate(dir)
		inputManager.Command.CMD_DOWNWARD_SPECIAL:
			var sfx = attackSFXResource.instance()
			sfx.texture=specialParticle
			dir = sfx.Direction.DOWN
			self.add_child(sfx)
			sfx.owner = self
			sfx.init()
			sfx.activate(dir)
		inputManager.Command.CMD_UPWARD_SPECIAL:
			var sfx = attackSFXResource.instance()
			sfx.texture=specialParticle
			dir = sfx.Direction.UP
			self.add_child(sfx)
			sfx.owner = self
			sfx.init()
			sfx.activate(dir)
		inputManager.Command.CMD_FORWARD_SPECIAL:
			var sfx = attackSFXResource.instance()
			sfx.texture=specialParticle
			dir = sfx.Direction.RIGHT
			self.add_child(sfx)
			sfx.owner = self
			sfx.init()
			sfx.activate(dir)
		inputManager.Command.CMD_BACKWARD_SPECIAL:
			var sfx = attackSFXResource.instance()
			sfx.texture=specialParticle
			dir = sfx.Direction.LEFT
			self.add_child(sfx)
			sfx.owner = self
			sfx.init()
			sfx.activate(dir)
		inputManager.Command.CMD_NEUTRAL_TOOL:
			var sfx = attackSFXResource.instance()
			sfx.texture=toolParticle
			dir = sfx.Direction.NEUTRAL
			self.add_child(sfx)
			sfx.owner = self
			sfx.init()
			sfx.activate(dir)
		inputManager.Command.CMD_DOWNWARD_TOOL:
			var sfx = attackSFXResource.instance()
			sfx.texture=toolParticle
			dir = sfx.Direction.DOWN
			self.add_child(sfx)
			sfx.owner = self
			sfx.init()
			sfx.activate(dir)
		inputManager.Command.CMD_UPWARD_TOOL:
			var sfx = attackSFXResource.instance()
			sfx.texture=toolParticle
			dir = sfx.Direction.UP
			self.add_child(sfx)
			sfx.owner = self
			sfx.init()
			sfx.activate(dir)
		inputManager.Command.CMD_FORWARD_TOOL:
			var sfx = attackSFXResource.instance()
			sfx.texture=toolParticle
			dir = sfx.Direction.RIGHT
			self.add_child(sfx)
			sfx.owner = self
			sfx.init()
			sfx.activate(dir)
		inputManager.Command.CMD_BACKWARD_TOOL:
			var sfx = attackSFXResource.instance()
			sfx.texture=toolParticle
			dir = sfx.Direction.LEFT	
			self.add_child(sfx)
			sfx.owner = self
			sfx.init()
			sfx.activate(dir)
				

	