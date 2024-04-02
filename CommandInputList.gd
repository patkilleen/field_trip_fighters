extends GridContainer
export (int) var size = 4

var btnTextureRects = []

var cmdTextureRecScene = preload("res://CommandTextureRect.tscn")
var inputManagerResource = preload("res://input_manager.gd")

var whiteList = {}
func _ready():
	#THE CHILDREN OF THIS node are button TEXTURE RECTs 
	#add all the button texture rects
	for i in size:
		var btnTextureRect = cmdTextureRecScene.instance()
		#no command to start with (now texture will be shown)
		btnTextureRect.command = null
		btnTextureRects.append(btnTextureRect)
		self.add_child(btnTextureRect)
	
	
		
	whiteList[inputManagerResource.Command.CMD_NEUTRAL_MELEE]=null
	whiteList[inputManagerResource.Command.CMD_FORWARD_MELEE]=null
	whiteList[inputManagerResource.Command.CMD_BACKWARD_MELEE]=null
	whiteList[inputManagerResource.Command.CMD_DOWNWARD_MELEE]=null
	whiteList[inputManagerResource.Command.CMD_UPWARD_MELEE]=null
	
	whiteList[inputManagerResource.Command.CMD_NEUTRAL_SPECIAL]=null
	whiteList[inputManagerResource.Command.CMD_FORWARD_SPECIAL]=null
	whiteList[inputManagerResource.Command.CMD_BACKWARD_SPECIAL]=null
	whiteList[inputManagerResource.Command.CMD_DOWNWARD_SPECIAL]=null
	whiteList[inputManagerResource.Command.CMD_UPWARD_SPECIAL]=null
	
	whiteList[inputManagerResource.Command.CMD_NEUTRAL_TOOL]=null
	whiteList[inputManagerResource.Command.CMD_FORWARD_TOOL]=null
	whiteList[inputManagerResource.Command.CMD_BACKWARD_TOOL]=null
	whiteList[inputManagerResource.Command.CMD_DOWNWARD_TOOL]=null
	whiteList[inputManagerResource.Command.CMD_UPWARD_TOOL]=null
		
# will push all button images down by one and place 1st texture as new command's image		
func displayCommand(cmd):
	
	#no command or command that isn't part of acceptable commadns to display?
	if cmd == null or not whiteList.has(cmd):
		return
		
	
	if btnTextureRects.size() == 0:
		return
	
	
	#make sure the button about to display isn't null texture
	#if btnTextureRects[btnTextureRects.size()-1].lookupTexture(cmd) == null:
	if btnTextureRects[0].cmdMap.lookupTexture(cmd) == null:
		return
		
	#iterate the button texture rects backwards, starting from last element to the 2nd element
	#(will set first element's command manally)
	#and update their texture based on previous command
	#var i =btnTextureRects.size() -1
	#while i > 0:
	#	btnTextureRects[i].command = btnTextureRects[i-1].command
	#	i-=1
	
	#now add display new command's button texture
	#btnTextureRects[0].command = cmd
	
	#for i in range (btnTextureRects.size()-1):
	#for i in range(btnTextureRects.size()-1,0):
	var i = btnTextureRects.size()-1
	while i > 0:
		#btnTextureRects[i].command = btnTextureRects[i+1].command
		btnTextureRects[i].command = btnTextureRects[i-1].command
		i-=1
	#now add display new command's button texture
	#btnTextureRects[btnTextureRects.size()-1].command = cmd
	btnTextureRects[0].command = cmd
		