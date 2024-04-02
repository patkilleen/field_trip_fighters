extends Control
signal back
signal replay_launch_request
var launchReplayBtn = null

#var replayInputField = null
var replayHandler = null
var templateLabel = null

var buttonTemplate = null
var gridLayout = null

var backArrow = null
#var replayIdChosen = null
func _ready():
	
	templateLabel = $template
	gridLayout = $ScrollContainer/GridContainer
	
	buttonTemplate = $"Button-tempate"
	
	backArrow = $"Control/back-arrow"
	backArrow.connect("back",self,"emit_signal",["back"])#emit back signal when back arrow node goes back
	#replayInputField = $TextEdit
	
	#replayInputField.connect("text_changed",self,"_on_replay_id_input_changed")
#	launchReplayBtn = $Button
	
#	replayIdChosen = int(replayInputField.text)
	
	#launchReplayBtn.connect("button_up",self,"_on_lauch_replay_confirm")
	pass # Replace with function body.
	
func init(_replayHandler):
	
	replayHandler = _replayHandler
	
	#TODO: only populate when the player clicks on the replays tab.
	populateReplayInformation()
	
	


func populateReplayInformation():
	var numReplays = replayHandler.countNumberOfAvailableReplays()
	
	#go over reach one
	for replayId in numReplays:
		readReplayFileIntoRow(replayId)
		
func readReplayFileIntoRow(fileId):
	
	if not replayHandler.loadReplay(fileId):
		#failed to read replays
		return
	
	var heroName1 = replayHandler.getHeroName(replayHandler.PLAYER1_IX)
	var heroName2 = replayHandler.getHeroName(replayHandler.PLAYER2_IX)
	
	var stageResourcePath=replayHandler.getStage()
	#convert stage node path to name 
	var lastSlashIx = stageResourcePath.find_last("/")
	
	var stageName =stageResourcePath.substr(lastSlashIx+1,stageResourcePath.length())
	#remove the .tscn	
	var dotIx = stageName.find(".")
	stageName = stageName.substr(0,dotIx)
	
	var timestamp = replayHandler.gaetReplayDate()
	
	var playBtn = buttonTemplate.duplicate()
	playBtn.visible = true
	playBtn.connect("pressed",self,"_on_play_replay",[fileId])
	
	addReplayInfoRow(playBtn,fileId,heroName1,heroName2,stageName,timestamp)
	
func addReplayInfoRow(playBtn,id,heroName1,heroName2,stageName,fileDate):
	gridLayout.add_child(playBtn)
	addGridEntry(str(id))
	addGridEntry(heroName1)
	addGridEntry(heroName2)
	addGridEntry(stageName)	
	addGridEntry(fileDate)
	
	
func addGridEntry(text):
		
	var label = templateLabel.duplicate()
	label.text = text
	label.visible  =true
	gridLayout.add_child(label)
	
#func _on_lauch_replay_confirm():
	
	
#	print("attempting to play newest replay")
	
	#one replay, with id 0,, two replays means id 1 is newerst. -1 for no replays
	#var newestReplayId = replayHandler.countNumberOfAvailableReplays()-1
	
#	var text = replayInputField.text
#	if not text.is_valid_integer():
#		 replayInputField.text=str(replayIdChosen)
#	else:
#		var value = int(text)
		
#		if value < 0:
#			replayInputField.text="0"
#			replayIdChosen=0
#		else:
#			
#			var  maxValue =replayHandler.countNumberOfAvailableReplays()-1
#			if value > maxValue:
#				replayInputField.text = str(maxValue)
#				replayIdChosen=maxValue
			
#	emit_signal("replay_launch_request",replayIdChosen)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#func _on_replay_id_input_changed():
#	var text = replayInputField.text
#	if text.is_valid_integer():
		
		
#		var minValue = 0
#		var maxValue =replayHandler.countNumberOfAvailableReplays()-1
#		var value = clamp(int(text),minValue,maxValue)

#		replayInputField.text=str(value)
		
#		replayIdChosen = value	
#	else:
#		replayInputField.text = str(replayIdChosen)
		
	
func _on_play_replay(replayId):
	emit_signal("replay_launch_request",replayId)
	