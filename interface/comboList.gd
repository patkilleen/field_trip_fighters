extends Control

const GLOBALS = preload("res://Globals.gd")
var inputManagerResource = preload("res://input_manager.gd")
var cmdTextureRecScene = preload("res://CommandTextureRect.tscn")

const UNKNWON_BAR_COST_STR = "?"
const FREE_BAR_COST_STR = "x0"
const NON_CANCELABLE_STR="Not ability cancelable"
const ON_HIT_STR="On hit cancel           \n only (red dot)" #white space for padding of columsn for cursor pencil to have space
const ABILITY_BAR_CANCEL_COST_STR="Ability bar \n cancel cost"
var cmdWhiteList = {}
var cmdToStringMap = {}

const ACTION_ID_IX = 0
const ACTION_NAME_IX = 1
const ACTION_CMD_IX = 2
const ACTION_FULL_DETAILS_IX = 3


export (int) var scrollSpeed = 600
export (Texture) var abilityBarChunkTexture = null
export (Texture) var onHitCancelableTexture = null

var templateLabel = null
var rowTemplateLabel = null
var gridContainer = null
var navigation = null
var scrollContainer = null


var active = false
var playerController = null

var cmdNameLabel =null
var cmdDetailsLabel = null

var cursorCmdIx = 0

var cursorTemplate = null

var cmdCursors = []

var cursorActionIdMap=[]



func _ready():
	templateLabel = $templateLabel
	rowTemplateLabel = $rowTemplateLabel
	scrollContainer=$ScrollContainer
	gridContainer = $ScrollContainer/GridContainer
	navigation = $navigation
	
	
	
	cursorTemplate = $"cursor-template"
	
	cmdNameLabel =$CommandDetails/HBoxContainer/cmdName
	cmdDetailsLabel =$CommandDetails/HBoxContainer2/cmdDetails
	set_physics_process(false)
	init()
		
func init():
	
	cmdWhiteList[inputManagerResource.Command.CMD_NEUTRAL_MELEE]=inputManagerResource.Command.CMD_NEUTRAL_MELEE
	cmdWhiteList[inputManagerResource.Command.CMD_BACKWARD_MELEE]=inputManagerResource.Command.CMD_BACKWARD_MELEE
	cmdWhiteList[inputManagerResource.Command.CMD_FORWARD_MELEE]=inputManagerResource.Command.CMD_FORWARD_MELEE
	cmdWhiteList[inputManagerResource.Command.CMD_DOWNWARD_MELEE]=inputManagerResource.Command.CMD_DOWNWARD_MELEE
	cmdWhiteList[inputManagerResource.Command.CMD_UPWARD_MELEE]=inputManagerResource.Command.CMD_UPWARD_MELEE
	#specials
	cmdWhiteList[inputManagerResource.Command.CMD_NEUTRAL_SPECIAL]=inputManagerResource.Command.CMD_NEUTRAL_SPECIAL
	cmdWhiteList[inputManagerResource.Command.CMD_BACKWARD_SPECIAL]=inputManagerResource.Command.CMD_BACKWARD_SPECIAL
	cmdWhiteList[inputManagerResource.Command.CMD_FORWARD_SPECIAL]=inputManagerResource.Command.CMD_FORWARD_SPECIAL
	cmdWhiteList[inputManagerResource.Command.CMD_DOWNWARD_SPECIAL]=inputManagerResource.Command.CMD_DOWNWARD_SPECIAL
	cmdWhiteList[inputManagerResource.Command.CMD_UPWARD_SPECIAL]=inputManagerResource.Command.CMD_UPWARD_SPECIAL
	#tools
	cmdWhiteList[inputManagerResource.Command.CMD_NEUTRAL_TOOL]=inputManagerResource.Command.CMD_NEUTRAL_TOOL
	cmdWhiteList[inputManagerResource.Command.CMD_BACKWARD_TOOL]=inputManagerResource.Command.CMD_BACKWARD_TOOL
	cmdWhiteList[inputManagerResource.Command.CMD_FORWARD_TOOL]=inputManagerResource.Command.CMD_FORWARD_TOOL
	cmdWhiteList[inputManagerResource.Command.CMD_DOWNWARD_TOOL]=inputManagerResource.Command.CMD_DOWNWARD_TOOL
	cmdWhiteList[inputManagerResource.Command.CMD_UPWARD_TOOL]=inputManagerResource.Command.CMD_UPWARD_TOOL
	#movement
	cmdWhiteList[inputManagerResource.Command.CMD_JUMP]=inputManagerResource.Command.CMD_JUMP
	cmdWhiteList[inputManagerResource.Command.CMD_DASH_BACKWARD]=inputManagerResource.Command.CMD_DASH_BACKWARD
	cmdWhiteList[inputManagerResource.Command.CMD_DASH_FORWARD]=inputManagerResource.Command.CMD_DASH_FORWARD
	cmdWhiteList[inputManagerResource.Command.CMD_AIR_DASH_DOWNWARD]=inputManagerResource.Command.CMD_AIR_DASH_DOWNWARD
	
	cmdWhiteList[inputManagerResource.Command.CMD_CROUCH]=inputManagerResource.Command.CMD_CROUCH
	cmdWhiteList[inputManagerResource.Command.CMD_AUTO_RIPOST]=inputManagerResource.Command.CMD_AUTO_RIPOST
	cmdWhiteList[inputManagerResource.Command.CMD_GRAB]=inputManagerResource.Command.CMD_GRAB
	
	
	cmdToStringMap[inputManagerResource.Command.CMD_NEUTRAL_MELEE]="Neutral-Melee"
	cmdToStringMap[inputManagerResource.Command.CMD_BACKWARD_MELEE]="Back-Melee"
	cmdToStringMap[inputManagerResource.Command.CMD_FORWARD_MELEE]="Forward-Melee"
	cmdToStringMap[inputManagerResource.Command.CMD_DOWNWARD_MELEE]="Down-Melee"
	cmdToStringMap[inputManagerResource.Command.CMD_UPWARD_MELEE]="Up-Melee"
	#specials
	cmdToStringMap[inputManagerResource.Command.CMD_NEUTRAL_SPECIAL]="Neutral-Special"
	cmdToStringMap[inputManagerResource.Command.CMD_BACKWARD_SPECIAL]="Back-Special"
	cmdToStringMap[inputManagerResource.Command.CMD_FORWARD_SPECIAL]="Forward-Special"
	cmdToStringMap[inputManagerResource.Command.CMD_DOWNWARD_SPECIAL]="Down-Special"
	cmdToStringMap[inputManagerResource.Command.CMD_UPWARD_SPECIAL]="Up-Special"
	#tools
	cmdToStringMap[inputManagerResource.Command.CMD_NEUTRAL_TOOL]="Neutral-Tool"
	cmdToStringMap[inputManagerResource.Command.CMD_BACKWARD_TOOL]="Back-Tool"
	cmdToStringMap[inputManagerResource.Command.CMD_FORWARD_TOOL]="Forward-Tool"
	cmdToStringMap[inputManagerResource.Command.CMD_DOWNWARD_TOOL]="Down-Tool"
	cmdToStringMap[inputManagerResource.Command.CMD_UPWARD_TOOL]="Up-Tool"
	
	cmdToStringMap[inputManagerResource.Command.CMD_JUMP]="Jump"
	cmdToStringMap[inputManagerResource.Command.CMD_JUMP_FORWARD]="Forward-Jump"
	cmdToStringMap[inputManagerResource.Command.CMD_JUMP_BACKWARD]="Back-Jump"
	
	
	cmdToStringMap[inputManagerResource.Command.CMD_MOVE_FORWARD]="Hold-Forward"
	cmdToStringMap[inputManagerResource.Command.CMD_MOVE_BACKWARD]="Hold-Back"
	cmdToStringMap[inputManagerResource.Command.CMD_DASH_FORWARD]="R2"
	cmdToStringMap[inputManagerResource.Command.CMD_DASH_BACKWARD]="Back-R2"
	cmdToStringMap[inputManagerResource.Command.CMD_AIR_DASH_DOWNWARD]="Down-R2"
	
	#other
	cmdToStringMap[inputManagerResource.Command.CMD_CROUCH]="Hold-Down"
	cmdToStringMap[inputManagerResource.Command.CMD_STOP_CROUCH]="Release-Down"
	cmdToStringMap[inputManagerResource.Command.CMD_AUTO_RIPOST]="R1 -> L2"
	cmdToStringMap[inputManagerResource.Command.CMD_GRAB]="L1"
	
	
	#gridContainer.rect_scale =  gridContainer.rect_scale * 0.6
	
func populateGridWithCmdInfo(_playerController):
	playerController=_playerController
	var onHitComboMap = computeComboOnHitMap(playerController)
	var basicComboMap = computeBasicComboMap(playerController)
	
	
	
	addTextCellToGrid("Cmd")
	addTextCellToGrid(ON_HIT_STR)
	addTextCellToGrid("Cancels")
	addTextCellToGrid(" into")
	#addTextCellToGrid("Ability bar \n cancel cost")
	#addTextCellToGrid("and Autocancel cmd names")
	
	var mapPair = [basicComboMap,onHitComboMap]
	
	#build a map of all the action ids in both onhit autocancel and basic autocancel maps
	#(keys will give unique set of action ids
	var uniqueSetOfActionIds = {}
	for comboMap in mapPair:
		for parentActionId in comboMap.keys():
			
			#command already found in another map?
			if uniqueSetOfActionIds.has(parentActionId):
				#skip it
				continue
			uniqueSetOfActionIds[parentActionId] = null
	
	#iterate over all unique actions ids in union of  on hit and basic auto cancelsmaps
	for parentActionId in uniqueSetOfActionIds.keys():
		
		
		#ignore action ids that are start of delayed tap, since their simply filler
		if playerController.actionAnimeManager.isInitialActionIdOfDelayedTapAniamtion(parentActionId):
			continue
		
		var parentCmd = playerController.actionAnimeManager.getCommand(parentActionId)
		
		if not cmdWhiteList.has(parentCmd):
			continue
		
		#create a row for the command (action's COMMAND TUXTURE, action's name, chunk texture, ability cost)
		var parentActionName = playerController.actionAnimeManager.getActionName(parentActionId)
		var parentActionFullDetails=playerController.actionAnimeManager.getActionFullDetails(parentActionId)
		addTextCellToGrid("-----")
		addTextCellToGrid("-----")
		addTextCellToGrid("-----")
		addTextCellToGrid("-----")
		addActionInfoToGrid(playerController,parentActionId,parentActionName,parentCmd,parentActionFullDetails)
		#addTextCellToGrid("-----")
		#addTextCellToGrid("-----")
		#addTextCellToGrid("-----")
		#addTextCellToGrid("-----")
		#itearte over all the action ids that auto cancel  (basi c and on hit)		
		for comboMap in  mapPair:
			
			#the action ids the current action auto cancels into
			var autoCancelActionIds = comboMap[parentActionId]
			
			
			#iterate over this action ids
			for autoCancelableActionId in autoCancelActionIds:
				
				
				
				#already processed the command (it was basic autocancelable and on hit autocancelable)?
				#if actionsProcessedMap.has(autoCancelableActionId):
					#skip it
				#	continue
					
				#indicate we processed it (key just needs to exist, so null value is fine)
				#actionsProcessedMap[autoCancelableActionId] =null
				
				var cmdCancelsInto = playerController.actionAnimeManager.getCommand(autoCancelableActionId)
				if not cmdWhiteList.has(cmdCancelsInto):
					continue
				var actionNameCancelsInto = playerController.actionAnimeManager.getActionName(autoCancelableActionId)
				
				
				#this will act as tab to make it clear what parent/starting command your observing
				addEmtpyGridCell()
					
				#on hit autocancelable?
				if comboMap ==onHitComboMap:
					
					#on hit auctocancelable icon
					var iconTextureRect = TextureRect.new()
					iconTextureRect.margin_right = 10
					iconTextureRect.margin_bottom= 5
					iconTextureRect.rect_min_size=Vector2(0,0)
					iconTextureRect.rect_size = Vector2(0,0)
					iconTextureRect.texture = onHitCancelableTexture
					#add to grid
					gridContainer.add_child(iconTextureRect)
				else:
					addEmtpyGridCell()
				
				#add command pairs
				addCommandButtonToGrid(cmdCancelsInto)
				#name of action
				addTextCellToGrid(actionNameCancelsInto)
				
				
			
	updateCommandDetails()	
	
#func populateGridWithCombos(_playerController):
#	playerController = _playerController
#	var comboMap = computeComboOnHitMap(playerController)
	
#	#iterate all the actions/commands in map
#	for actionKey in comboMap.keys():
		
		
#		var cmdKey = playerController.actionAnimeManager.getCommand(actionKey)
		
#		if not cmdWhiteList.has(cmdKey):
#			continue
			
		#create header for command
		
#		var actionName2 = playerController.actionAnimeManager.getActionName(actionKey)
#		addTextRow("----------")
#		addActionInfoToGrid(playerController,actionKey,actionName2)
#		var actionIds = comboMap[actionKey]
		
#		var addedCombo = false
#		for autoCancelableActionId in actionIds:
			
#			var cmdValue = playerController.actionAnimeManager.getCommand(autoCancelableActionId)
#			var actionName = playerController.actionAnimeManager.getActionName(autoCancelableActionId)
#			if not cmdWhiteList.has(cmdValue):
			#	continue
#			addedCombo = true
#			#add command pairs
#			addCommandButtonToGrid(cmdKey)
#			addCommandButtonToGrid(cmdValue)
#			addTextCellToGrid(actionName)
		
		#didn't add any combos?
#		if not addedCombo:
#			populateGridWithBasicCombo(cmdKey,playerController,actionKey)
		

#func populateGridWithBasicCombo(cmdKey,playerController,actionKey):
	
#	var comboMap = computeBasicComboMap(playerController)
	
#	var actionIds = comboMap[actionKey]
		
#	var addedCombo = false
#	for autoCancelableActionId in actionIds:
		
#		var cmdValue = playerController.actionAnimeManager.getCommand(autoCancelableActionId)
#		var actionName = playerController.actionAnimeManager.getActionName(autoCancelableActionId)
#		if not cmdWhiteList.has(cmdValue):
#			continue
#		addedCombo = true
		#add command pairs
#		addCommandButtonToGrid(cmdKey)
#		addCommandButtonToGrid(cmdValue)
#		addTextCellToGrid(actionName)
	
	
#	if not addedCombo:
#		addCommandButtonToGrid(cmdKey)
#		addEmtpyGridCell()
#		addEmtpyGridCell()
		
func addActionInfoToGrid(playerController,actionId,actionName,cmdKey,actionFullDetails):
	
	var sa = playerController.actionAnimeManager.spriteAnimationLookup(actionId)
	
	var barCost = null
	var barCostStr = null
	if sa == null:
		barCostStr = UNKNWON_BAR_COST_STR
	else:
		
		if 	not sa.barCancelableble:
			barCost=-1
		else:
			#barCost = playerController.computeAbilityBarCancelCost(sa)
			barCost = sa.abilityCancelCostTypeToNumberOfChunks()
			
	
	
	
	if barCost== 0:
	#	barCostStr= FREE_BAR_COST_STR
		barCostStr = "Ability cancel base cost"
	elif barCost == null or barCost ==-1:
		barCostStr = NON_CANCELABLE_STR
	else:
		barCostStr = "Ability cancel base cost + "+str(barCost)
	
	
	#add the command of action
	addMainCommandButtonToGrid(cmdKey)
	
	#add the action id gand link to cursor ix
	cursorActionIdMap.append([actionId,actionName,cmdKey,actionFullDetails])
	
	addTextCellToGrid("")
	
	#bar chunk icon
	var iconTextureRect = TextureRect.new()
	iconTextureRect.margin_right = 10
	iconTextureRect.margin_top= 15
	iconTextureRect.rect_min_size=Vector2(0,0)
	iconTextureRect.rect_size = Vector2(0,0)
	iconTextureRect.texture = abilityBarChunkTexture
	#add to grid
	gridContainer.add_child(iconTextureRect)
	
	#bar cost
	addTextCellToGrid(barCostStr)
	
func addCommandButtonToGrid(cmd):
	var btnTextureRect = _createCmdTextureRect()
	#add to grid
	gridContainer.add_child(btnTextureRect)
	#choose command
	btnTextureRect.command = cmd
	
#adds the starting command of a row to grid and creates invisible cursor 
func addMainCommandButtonToGrid(cmd):
	
	var btnTextureRect = _createCmdTextureRect()
	
	
	
	#create cursor for cmd navigation
	var cmdCursor = cursorTemplate.duplicate()
	cmdCursor.visible=false #don't show cursor by default
	
	#want to pair the command witha  cursor for navigation
	var wrapper= Control.new()

	#save the cursor in list
	cmdCursors.append(cmdCursor)
	
	#add the pair to grid
	gridContainer.add_child(btnTextureRect)
	
	#choose command
	btnTextureRect.command = cmd
	
	btnTextureRect.add_child(cmdCursor)
func _createCmdTextureRect():
	var btnTextureRect = cmdTextureRecScene.instance()
	btnTextureRect.margin_right = 10
	#btnTextureRect.margin_bottom= 25
	btnTextureRect.margin_bottom= 5
	btnTextureRect.margin_top= 10
	btnTextureRect.rect_min_size=Vector2(0,0)
	btnTextureRect.rect_size = Vector2(0,0)
	return btnTextureRect
	
func addTextCellToGrid(text):
	var label = templateLabel.duplicate()
	label.text = text
	label.visible = true
	gridContainer.add_child(label)
	
func addEmtpyGridCell():
	var cell = Control.new()
	cell.rect_size = Vector2(15,15)
	#add to grid
	gridContainer.add_child(cell)


		
func _addTextRow(text,_label):
	var label = _label.duplicate()
	label.visible = true
	label.text = text
	gridContainer.add_child(label)
	addEmtpyGridCell()
	addEmtpyGridCell()
			
func addTextRow(text):
	_addTextRow(text,templateLabel)


#func printComboMap(playerController):
#	var comboMap = computeComboOnHitMap(playerController)
	
#	for actionKey in comboMap.keys():
		
		
#		var cmdKey = playerController.actionAnimeManager.getCommand(actionKey)
			
#		if not cmdWhiteList.has(cmdKey):
#			continue
			
#		var actionIds = comboMap[actionKey]
		
#		var keyStr = str(cmdKey)
#		if cmdToStringMap.has(cmdKey):
#			keyStr = cmdToStringMap[cmdKey]
			
#		print("-----"+keyStr+" (" + str(actionKey)+")")	
			
#		for autoCancelableActionId in actionIds:
			
#			var cmdValue = playerController.actionAnimeManager.getCommand(autoCancelableActionId)
			
#			if not cmdWhiteList.has(cmdValue):
#				continue
		
		
#			var valueStr = str(cmdValue)
#			if cmdToStringMap.has(cmdValue):
#				valueStr = cmdToStringMap[cmdValue]
			
#			print(keyStr + " + " + valueStr)
			
		
#func printComboStringsMap(playerController):
#	var comboMap = computeComboMap(playerController)
	
#	var emtpyComboCharacterString = ""
#	var depth =0
	#iterate the starting combo
#	for startActionId in comboMap.keys():
#		var commandString = []
#		_printCombStringMap(playerController,startActionId,comboMap[startActionId],comboMap,emtpyComboCharacterString,commandString)

#recursive function that prints all combos strings	
#func _printCombStringMap(playerController,startActionId,autoCancelableOnHitActionIds,comboMap,comboCharacterString,commandString):
	 
#	var startCmd = playerController.actionAnimeManager.getCommand(startActionId)
		
#	if not cmdWhiteList.has(startCmd):
#		return 
	#base case?
#	if autoCancelableOnHitActionIds.size() == 0 or listContainsElement(commandString,startActionId) or startCmd == inputManagerResource.Command.CMD_JUMP:
		
#		if cmdToStringMap.has(startCmd):
#			comboCharacterString = comboCharacterString + cmdToStringMap[startCmd]
#		else:
#			comboCharacterString = comboCharacterString + str(startCmd)
			
#		if listContainsElement(commandString,startActionId):
#			comboCharacterString = comboCharacterString + " (infinite combo) ..."
			
#		print(comboCharacterString)
#		return
	
	#mark as command part of combo string	
#	commandString.push_front(startActionId)
	
#	comboCharacterString = comboCharacterString + cmdToStringMap[startCmd] + " + "
	
	#recursivly process all the auto cancel on hit commands
#	for nextactionId in autoCancelableOnHitActionIds:
			
#		_printCombStringMap(playerController,nextactionId,comboMap[nextactionId],comboMap,comboCharacterString,commandString)
#		#comming back from iteration, pop last command put on string
#		commandString.pop_front()
	
#func listContainsElement(list,elem):
#	var res = false
#	for e in list:
#		if e==elem:
#			res=true
#			break
	
#	return res
func computeComboOnHitMap(playerController):
	var actionAnimeManager =playerController.actionAnimeManager
	return _computeComboMap(playerController,actionAnimeManager.AUTO_CANCEL_COMMANDS_ONHIT)
func computeBasicComboMap(playerController):
	var actionAnimeManager =playerController.actionAnimeManager
	return _computeComboMap(playerController,actionAnimeManager.AUTO_CANCEL_COMMANDS_BASIC)


func _computeComboMap(playerController,type):
	var actionAnimeManager = playerController.actionAnimeManager
	
	var comboList = {} #key = initial command, value = autocancelable command on hit
	#iterate all the commands to start combo with
	for actionIdKey in actionAnimeManager.commandLookupMap.keys():

		#the command to start combo with
		#var cmdKey = actionAnimeManager.commandLookupMap[actionIdKey]
		
		var duplicateLookup = {}
		
			
		comboList[actionIdKey] =[]
		#else:

		#get the sprite animation associated to command/actionid
		var spriteAnimation = actionAnimeManager.spriteAnimationLookup(actionIdKey)
		
		#ignore actions that don't have a sprite animation, like fast fall
		if spriteAnimation == null:
			continue
		var autoCancelOnHitActionIds =_getAllAutocancelableActionIds(spriteAnimation,playerController,type)
		
		
		#store the action ids in comb list
		for actionId in autoCancelOnHitActionIds:
			#where actionId would be starting action of delayed tap and actionIdKey could be one of the actions of the series		
			#ingore the parent starting delayed tap animation, since its a filler/template
			if actionAnimeManager.isActionIdPartOfDelayedTapString(actionId,actionIdKey): 
			#might be case for current action, it is a delayed tap animation so the auto cancel action for the delayed tap
			#will actually be another action id than one found in autoCancelOnHitActionIds
			
				#remap the action 
				actionId = actionAnimeManager.delayedTapActionIdLookup[actionIdKey]
				
			if not duplicateLookup.has(actionId):
				#ignore add actionId like fast
				comboList[actionIdKey].append(actionId) 
				duplicateLookup[actionId] = null
		
		#iterate all the commands you can do on hit for current command (cmdKey)
	
	return comboList

#returns all possible autocancelable (on hit or basic, depends on type) commands

func _getAllAutocancelableActionIds(spriteAnimation,playerController,type):
	
	var actionAnimeManager =playerController.actionAnimeManager
	
	var res = []
	
	var duplicateLookup = {}
	#only get all the possible autocancels (on-hit and normal) when hitting oppoentn
	var autoCancelActionIds  = []

	#const COMBO_TYPE_ALL = 0
	#const COMBO_TYPE_NORMAL = 1
	#const COMBO_TYPE_ON_HIT_ONLY = 2
	
	#iterate all sprite frames of animation
	for sf in spriteAnimation.spriteFrames:
		
		#autocancelable action ids for sprite frame
		var tmpAutoCancelActionIds = actionAnimeManager.__getAutoCancelableActionIds(type,sf)
		
		#iterate all the on-hit autocancelable actionids and append to temperary array
		for aid in tmpAutoCancelActionIds:
			autoCancelActionIds.append(aid)
	
	#go through all the actions that are autocancelable, and get the  commands that are input to 
	#create/play those actions
	for actionId in autoCancelActionIds:
		#var cmd = actionAnimeManager.getCommand(actionId)
		
		#don't include null commands or duplicates in results
		if not duplicateLookup.has(actionId):
			res.append(actionId)
			
			#sotre in lookup map to avoid duplicates
			duplicateLookup[actionId] = null
			
	return res
	
	
func removeAllCommandUIElements():
	for n in gridContainer.get_children():
		gridContainer.remove_child(n)
		n.queue_free()
		
func activate():
	
	#display current  cursor
	cmdCursors[cursorCmdIx].visible = true
	
	active = true
	navigation.visible = true
	set_physics_process(true)
func disable():
	active = false
	navigation.visible = false
	set_physics_process(false)
	
func updateCommandDetails():
	

	var triple = cursorActionIdMap[cursorCmdIx]
	
	var actionId = triple[ACTION_ID_IX]
	var actionName = triple[ACTION_NAME_IX]
	var actionCmd = triple[ACTION_CMD_IX]
	var actionDetails = triple[ACTION_FULL_DETAILS_IX]
	
	var cmdName = cmdToStringMap[actionCmd]
	
	#update the lower pane with command information
	cmdNameLabel.text = actionName + " --  "+cmdName
	cmdDetailsLabel.text =actionDetails

func _physics_process(delta):

	delta = GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
		
	if not active:
		set_physics_process(false)
		return
		
	var deviceId = playerController.inputManager.inputDeviceId
	
	#let players scroll through commands
	if Input.is_action_pressed(deviceId+"_DOWN"):
		
		scrollContainer.scroll_vertical= scrollContainer.scroll_vertical + delta*scrollSpeed
		scrollContainer.update()# after changing the value of scroll_vertical
	elif Input.is_action_pressed(deviceId+"_UP"):
		scrollContainer.scroll_vertical= scrollContainer.scroll_vertical - delta*scrollSpeed
		scrollContainer.update()# after changing the value of scroll_vertical

	#let player navigate and select command to display info
	#let players scroll through commands
	if Input.is_action_just_released(deviceId+"_DOWN"):
		
		#hide old cursor
		cmdCursors[cursorCmdIx].visible = false
		#move cursor by one down, not allowing going beyond command list
		cursorCmdIx = clamp(cursorCmdIx + 1,0,cmdCursors.size()-1)
		
		#display current  cursor
		cmdCursors[cursorCmdIx].visible = true
		updateCommandDetails()

			
		
	elif Input.is_action_just_released(deviceId+"_UP"):
		#hide old cursor
		cmdCursors[cursorCmdIx].visible = false
		#move cursor by one down, not allowing going beyond command list
		cursorCmdIx = clamp(cursorCmdIx -1,0,cmdCursors.size()-1)
		
		#display current  cursor
		cmdCursors[cursorCmdIx].visible = true
		updateCommandDetails()	
		
		

	