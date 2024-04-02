extends Control

signal proficiencies_selection_confirmed
signal proficiency_1_confirmed
signal proficiency_2_confirmed
signal proficiency_1_unconfirmed
signal proficiency_2_unconfirmed

const GLOBALS = preload("res://Globals.gd")

export (String) var inputDeviceId= "P1"

enum PlayerID{
	PLAYER1,
	PLAYER2
}

export (PlayerID) var player = PlayerID.PLAYER1
const minorClassDescriptionResource = preload("res://interface/new-prof-select/ProficiencyMinorClassDescription.tscn")
const NO_MINOR_PROF_SELECTED = "ALL"
var majorClassProfDescBox = null
var minorClassPropertyListNode = null

var minorClassProfDescriptions = {}
var profDataModel = null

var selectionStars = []
var largerSelectionStars = []
var starSelectionContainer = null
var largerStarSelectionContainer=null
const SELECT_STAR_1_IX=0
const SELECT_STAR_2_IX=1


		

#var selectedMajorClassAdvantage= false
var currMajorClassIx= 0	
var currMinorClassIx= -1
var numMajorClasses= -1
var isAdvantage = true
var inputDevices = [] #only needed for debugging
var selectionStarIx = 0


var prof1MajorClassIxSelect = null
var prof1MinorClassIxSelect = null

var prof2MajorClassIxSelect = null
var prof2MinorClassIxSelect = null

var player1Label = null
var player2Label = null
var readyIcon = null

enum SelectionState{
	SELECTING_PROFICIENCY_1,
	SELECTING_PROFICIENCY_2,
	SELECTED_PROFICIENCIES
}
var selectionState = SelectionState.SELECTING_PROFICIENCY_1

var rng = null
# Called when the node enters the scene tree for the first time.
func _ready():
	majorClassProfDescBox = $"NewProfSelectOptionBox"
	majorClassProfDescBox.visible = true
	minorClassPropertyListNode = $"MinorProfPropertyList"
	
	profDataModel = $"ProficiencyDataModel"
	profDataModel.loadProficiencyPropertyDescriptions()
	
	player1Label = $"player1-label"
	player2Label = $"player2-label"
	readyIcon = $"readyIcon"

	readyIcon.visible = false

	#the stars displayed as player makes selections
	starSelectionContainer = $"smaller-star-selections"
	selectionStars.append($"smaller-star-selections/ProficiencySelectionStar")
	selectionStars.append($"smaller-star-selections/ProficiencySelectionStar2")
	selectionStars[SELECT_STAR_1_IX].unselect()
	selectionStars[SELECT_STAR_2_IX].unselect()
	starSelectionContainer.visible =true
	
	#the stars displayed when to summarize to player their proficiency
	#build and allow them to then confirm ready
	largerStarSelectionContainer=$"larger-star-selections"
	largerSelectionStars.append($"larger-star-selections/ProficiencySelectionStar")
	largerSelectionStars.append($"larger-star-selections/ProficiencySelectionStar2")
	largerSelectionStars[SELECT_STAR_1_IX].unselect()
	largerSelectionStars[SELECT_STAR_2_IX].unselect()
	largerStarSelectionContainer.visible = false
	
	#don't show arrows as generalist is default
	majorClassProfDescBox.hideMinorClassNameArrows()
	
	numMajorClasses = profDataModel.majorProfs.size()
	displayProficiencyInfo(currMajorClassIx,GLOBALS.ProficiencyClass.MAJOR_ADVANTAGE,-1,true)
	updateDisplay()
	
	
	rng = RandomNumberGenerator.new()
	
	#genreate time-based seed
	rng.randomize()


	if player == PlayerID.PLAYER1:
		starSelectionContainer.rect_position = $player1StarsPos.position
		player1Label.visible = true
		player2Label.visible = false
	else:
		starSelectionContainer.rect_position = $player2StarsPos.position
		player1Label.visible = false
		player2Label.visible = true
		
	set_process(false)
	set_physics_process(true)
	#debugReady()
#profClassType: GLOBALS.ProficiencyClass.*
func displayProficiencyInfo(majorClassid,profClassType,minorClassId,advantageFlag):
	
	#display the texture of next major classes to pick from
	var previousMajorClassIx = _getPreviousMajorClassIx()
	var nextMajorClassIx = _getNextMajorClassIx()
	
	var previousMajorClass=profDataModel.getMajorProficiency(previousMajorClassIx)
	var nextMajorClass=profDataModel.getMajorProficiency(nextMajorClassIx)
	
	majorClassProfDescBox.setPreviousMajorClassIcon(previousMajorClass.icon)
	majorClassProfDescBox.setNextMajorClassIcon(nextMajorClass.icon)
	#end setting the textures for next and previous major classes
	
	var majorClass = profDataModel.getMajorProficiency(majorClassid)
	
	if majorClass == null:
		return
	
	#remove the old prof property info 
	clearMinorProficiencyList()
	
	#var isAdvantage = profClassType != GLOBALS.ProficiencyClass.MAJOR_DISADVANTAGE
	var isAdvantage = advantageFlag
	
	majorClassProfDescBox.setMajorProficiencyName(majorClass.profName)
	majorClassProfDescBox.setProficiencyDescription(majorClass.getDescription(isAdvantage))
	majorClassProfDescBox.setMajorProficiencyTexture(majorClass.icon)

	var isHybridProf = profClassType ==GLOBALS.ProficiencyClass.MINOR
	#not selecting a hybrid?
	if isHybridProf:
		
		#were dsipalying info for a major class
		majorClassProfDescBox.setMinorProficiencyName(NO_MINOR_PROF_SELECTED)
		majorClassProfDescBox.setMinorProficiencyTexture(profDataModel.defaultMinorProfIcon)		

		
	#we only show stars for non-generalist
	if majorClassid == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
		majorClassProfDescBox.hideProficiencyClassStars()
	else:
		
		if selectionState == SelectionState.SELECTING_PROFICIENCY_1:
			majorClassProfDescBox.displayProficiencyClassStars(GLOBALS.ProficiencyClass.MAJOR_ADVANTAGE)
		else:
			majorClassProfDescBox.displayProficiencyClassStars(GLOBALS.ProficiencyClass.MAJOR_DISADVANTAGE)
	

	#populate the list of properites
	var minorProfs = profDataModel.getMinorProficiencies(majorClassid,isAdvantage)
	
	#iterate over all minor profs
	for mp in minorProfs:
		
		#dynamically create a description for minor proficiency properties
		var mpDesc = minorClassDescriptionResource.instance()
		minorClassPropertyListNode.add_child(mpDesc)
		minorClassProfDescriptions[mp.id]= mpDesc
				
		mpDesc.setMinorClassProficiencyIcon(mp.icon)
		mpDesc.setMinorClassProficiencyName(mp.profName)
		
		var props = mp.getAllProperties()
			
		#iterate over the properties
		for prop in props:
			
			var desc =profDataModel.getProficiencyPropertyDescription(prop.id)
			mpDesc.addPropertyDescription(prop.isGood,desc)
				
			#ignore bad properties when were showcasing majorclass advantage (disadvangtage major class doesn't have
			#good properties, so can ignore that case)
			#if isAdvantage and not isHybridProf:
				
			#	if prop.isGood:
					#mpDesc.addPropertyDescription(prop.isGood,prop.description)
					
			#		var desc =profDataModel.getProficiencyPropertyDescription(prop.id)
			#		mpDesc.addPropertyDescription(prop.isGood,desc)
			#else:
				#mpDesc.addPropertyDescription(prop.isGood,prop.description)
			#	var desc =profDataModel.getProficiencyPropertyDescription(prop.id)
			#	mpDesc.addPropertyDescription(prop.isGood,desc)
	
	updateMinorClassSelected(minorClassId)

func updateMinorClassSelected(minorClassId):
	
	#display the general info for all major class?
	if minorClassId == -1:		
		#were dsipalying info for a major class
		majorClassProfDescBox.setMinorProficiencyName(NO_MINOR_PROF_SELECTED)
		majorClassProfDescBox.setMinorProficiencyTexture(profDataModel.defaultMinorProfIcon)	
		
		#iterate over minor proficiency ids to highlight everything
		for mpId in minorClassProfDescriptions.keys():
			
			#get description linked to the id of minor prof
			var desc = minorClassProfDescriptions[mpId]
			
			
			desc.enable()
			#desc.pencilCursor.visible=false
			desc.setPencilSelectionVisibility(player == PlayerID.PLAYER1,false)
		
	else:
		if not minorClassProfDescriptions.has(minorClassId):
			return 
		
		#iterate over minor proficiency ids to highlight the selecte minor prof and disable/hide rest
		for mpId in minorClassProfDescriptions.keys():
			
			#get description linked to the id of minor prof
			var desc = minorClassProfDescriptions[mpId]
			#found the minor proficiency to highlight?
			if mpId ==minorClassId:
				desc.enable()
				#desc.pencilCursor.visible=true
				desc.setPencilSelectionVisibility(player == PlayerID.PLAYER1,true)
			else:
				desc.disable()
				#desc.pencilCursor.visible=false
				desc.setPencilSelectionVisibility(player == PlayerID.PLAYER1,false)
		
		
		
		#display the minor prof info in the major class prof box
		var desc = minorClassProfDescriptions[minorClassId]
		majorClassProfDescBox.setMinorProficiencyName(desc.getMinorClassProficiencyName())
		majorClassProfDescBox.setMinorProficiencyTexture(desc.getMinorClassProficiencyIcon())		
	
	var numChildren = minorClassPropertyListNode.get_child_count()
		
	#make sure all children but last have the colored linking line dispalyed
	for i in numChildren:
		var c = minorClassPropertyListNode.get_child(i)
		
		if i + 1 <numChildren:
			c.showLinkingBar()
		else:
			c.hideLinkingBar()
	
func clearMinorProficiencyList():
	
	
	for k in minorClassProfDescriptions.keys():
		var c = minorClassProfDescriptions[k]
		minorClassPropertyListNode.remove_child(c)
		c.queue_free()
	minorClassProfDescriptions.clear()

#summarizes all properties of the build into two sets: advantage, and disadvantage
func updateProficiencyBuildSelectionSummary():
	
	#remove the old prof property info 
	clearMinorProficiencyList()
	
	if prof1MajorClassIxSelect == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
		prof1MinorClassIxSelect=-1
		prof2MinorClassIxSelect=-1
		
	var allProfBuildProperties = profDataModel.getAllProficiencyBuildProperties(prof1MajorClassIxSelect,prof1MinorClassIxSelect,prof2MajorClassIxSelect,prof2MinorClassIxSelect)
	var advantageIX =0
	var disadvantageIX =1
	#descrition of advantage properties
	var descNode = minorClassDescriptionResource.instance()		
	minorClassPropertyListNode.add_child(descNode)
	minorClassProfDescriptions[advantageIX]= descNode
	descNode.setMinorClassProficiencyIcon(null) #no icon
	descNode.setMinorClassProficiencyName("Summary")
	#descrition of disadvantage properties
#	var disDesc = minorClassDescriptionResource.instance()		
#	minorClassPropertyListNode.add_child(disDesc)
#	minorClassProfDescriptions[disadvantageIX]= disDesc
#	disDesc.setMinorClassProficiencyIcon(null) #no icon
#	disDesc.setMinorClassProficiencyName("Bad Properties")
	
	var dupMap= {}
	
	if allProfBuildProperties != null:
		#look for duplicates to avoid showing text twice
		for prop in allProfBuildProperties:
			#first occurence of property?
			if not dupMap.has(prop.id):
				
				#keep track of duplicates by having each bucket have a list of all properties
				#with same id
				dupMap[prop.id]=[prop]
				
			else:
				dupMap[prop.id].append(prop)
				
		#iterate over the properties to add good properties first
		for propId in dupMap.keys():
			var propList =dupMap[propId]
			var prop = propList[0]
			var propFreq = propList.size()
		
		#for prop in allProfBuildProperties:
			
			#add good properties to the the set
			if prop.isGood:
				
				if propFreq == 1:
					#descNode.addPropertyDescription(prop.isGood,prop.description)		
					var desc =profDataModel.getProficiencyPropertyDescription(prop.id)
					descNode.addPropertyDescription(prop.isGood,desc)
				else:
					#var newDescription = "x"+str(propFreq) + " "+prop.description
					#descNode.addPropertyDescription(prop.isGood,newDescription)		
					var desc =profDataModel.getProficiencyPropertyDescription(prop.id)
					var newDescription = "x"+str(propFreq) + " "+desc
					descNode.addPropertyDescription(prop.isGood,newDescription)
		

	#iterate over the properties to add bad properties 2nd
	#iterate over the properties to add good properties first
	for propId in dupMap.keys():
		var propList =dupMap[propId]
		var prop = propList[0]
		var propFreq = propList.size()

		#add bad properties to the the set
		if not prop.isGood:
			
			if propFreq == 1:
				#descNode.addPropertyDescription(prop.isGood,prop.description)		
				var desc =profDataModel.getProficiencyPropertyDescription(prop.id)
				descNode.addPropertyDescription(prop.isGood,desc)
			else:
				#var newDescription = "x"+str(propFreq) + " "+prop.description
				#descNode.addPropertyDescription(prop.isGood,newDescription)		
				var desc =profDataModel.getProficiencyPropertyDescription(prop.id)
				var newDescription = "x"+str(propFreq) + " "+desc
				descNode.addPropertyDescription(prop.isGood,newDescription)
			
	descNode.enable()
	
func updateProfSelectionStars(_starIx,majorClassid,profClassType,minorClassId=-1):
	_updateProfSelectionStars(selectionStars,_starIx,majorClassid,profClassType,false,minorClassId)
	_updateProfSelectionStars(largerSelectionStars,_starIx,majorClassid,profClassType,true,minorClassId)
	
		
func _updateProfSelectionStars(_selectionStarsArray,_starIx,majorClassid,profClassType,applyToLargeStarPair,minorClassId=-1):
	if _starIx == -1:
		return
	
	
	
	var majorClass = profDataModel.getMajorProficiency(majorClassid)
	
	if majorClass == null:
		return

	#var isHybridProf = profClassType ==GLOBALS.ProficiencyClass.MINOR
	var isHybridProf = minorClassId != -1
	
	var texture = null
	#were selection a full major class of  proficiencies?
	if not isHybridProf:
		
		if majorClassid == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
			#display texture of major class only for generalist
			texture=majorClass.icon
		else:
			#otherwise don't display themajor clsas texture, cause
			#can't select the class
			texture=null
		
	else:
		if minorClassProfDescriptions.has(minorClassId):
			#display the minor prof info in the major class prof box
			var desc = minorClassProfDescriptions[minorClassId]
			texture = desc.getMinorClassProficiencyIcon()		
			

		else:
			
			#this is case for generalist major class whoe doesn't have any minor classes
			texture=majorClass.icon
			#its a minor class texture
	
	
	_selectionStarsArray[_starIx].select(texture,profClassType,majorClassid)	

	#were seelecting 2nd prof and already selected same hybrid prof?
	if selectionState == SelectionState.SELECTING_PROFICIENCY_2 and not applyToLargeStarPair:
		
		if majorClassid == prof1MajorClassIxSelect and  prof1MinorClassIxSelect ==minorClassId:
		
			#hide the prof icon and stars when hovering over same hybrid minor prof selected as
			#first prof
			_selectionStarsArray[_starIx].select(null,profClassType,majorClassid)	
			_selectionStarsArray[_starIx].hideClassStars()
			
	


func checkInvalidMajorClassSelection(majorClassIx = -1):
	
	if majorClassIx == -1:
		majorClassIx = currMajorClassIx
		
	var invalidMajorClass= false
	
	#make sure were not selecting the same major class we picked as advantage for disadvantage
	#if hasSelectedMajorClassAdvantage() and  prof1MajorClassIxSelect == currMajorClassIx:
			
	#can't select same major class for disadvantage and advantage
	if prof1MajorClassIxSelect == majorClassIx:
		
		#unless it's no johns, then it's fine
		if majorClassIx != GLOBALS.PROFICIENCY_MAJOR_CLASS_NO_JOHNS:
			invalidMajorClass=true

	#choosing 2nd prof, means can't pick generalist as 2nd proficiency
	elif selectionState == SelectionState.SELECTING_PROFICIENCY_2 and majorClassIx == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
		invalidMajorClass=true
	#if we picked a hybrid as first selection, then can't have no johns as 2nd dary prof
#	elif selectionState == SelectionState.SELECTING_PROFICIENCY_2 and hasSelectedHybridProciency() and currMajorClassIx == GLOBALS.PROFICIENCY_MAJOR_CLASS_NO_JOHNS:
#		invalidMajorClass=true
		
	return invalidMajorClass
func selectNextMajorClass():
		
	#if selectionState != SelectionState.SELECTED_PROFICIENCIES:
	#haven't finished selecting our build yet?
	if not hasSelectedBothProficiencies():
		
		
		currMajorClassIx = _getNextMajorClassIx()
		
			
		#can't pick major class when cyrcling through minor classes and already pickyed hybird
		#if hasSelectedHybridProciency():
		#	currMinorClassIx=0
		#else:
		currMinorClassIx= 0
		
		var parent = get_parent()
		parent.sfxPlayer.playSound(parent.UI_MOVE_CURSOR_SOUND_ID)	
		updateDisplay()	
		
	if currMajorClassIx == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
		#don't show arrows as generalist is default
		majorClassProfDescBox.hideMinorClassNameArrows()
	elif selectionState == SelectionState.SELECTING_PROFICIENCY_1:
		majorClassProfDescBox.displayMinorClassNameArrows()

func _getNextMajorClassIx():
	var res = currMajorClassIx
	var invalidMajorClass = true
		
	while(invalidMajorClass):
		res = res-1 
		if res < 0:
			res=numMajorClasses-1
			
		invalidMajorClass=checkInvalidMajorClassSelection(res)
	return res		
	
func selectPreviousMajorClass():
	#if selectionState != SelectionState.SELECTED_PROFICIENCIES:
	#haven't finished selecting our build yet?
	if not hasSelectedBothProficiencies():
		
				
		
		currMajorClassIx = _getPreviousMajorClassIx()
	
		#can't pick major class when cyrcling through minor classes and already pickyed hybird
		#if hasSelectedHybridProciency():
		if currMajorClassIx != GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
			currMinorClassIx=0
		else:
			currMinorClassIx= -1
		
		var parent = get_parent()
		parent.sfxPlayer.playSound(parent.UI_MOVE_CURSOR_SOUND_ID)
		updateDisplay()	
		
	if currMajorClassIx == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
		#don't show arrows as generalist is default
		majorClassProfDescBox.hideMinorClassNameArrows()
	elif selectionState == SelectionState.SELECTING_PROFICIENCY_1:
		majorClassProfDescBox.displayMinorClassNameArrows()

func _getPreviousMajorClassIx():
	var res = currMajorClassIx
			
	var invalidMajorClass = true
	
	while(invalidMajorClass):
		
		res = res+1
		if res >= numMajorClasses:
			res=0
			
		
		invalidMajorClass=checkInvalidMajorClassSelection(res)
	return res
func selectNextMinorClass():
 
	if minorClassProfDescriptions.size()==0:
		return
		
	#if selectionState != SelectionState.SELECTED_PROFICIENCIES:
	#haven't finished selecting our build yet?
	if not hasSelectedBothProficiencies():
		#can't iterate over minor classes if picked major class advantage
		if not hasSelectedMajorClassAdvantage():
			
			if currMinorClassIx==-1:
				
				currMinorClassIx=0
			else:
				
				currMinorClassIx = currMinorClassIx+1
				if currMinorClassIx >= minorClassProfDescriptions.size():
					
					#can't pick major class when cyrcling through minor classes and already pickyed hybird
				#	if hasSelectedHybridProciency():
				#		currMinorClassIx=0
				#	else:
					currMinorClassIx=0
			
			var parent = get_parent()
			parent.sfxPlayer.playSound(parent.UI_MOVE_CURSOR_SOUND_ID)
			updateDisplay()	
			
func selectPreviousMinorClass():
	if minorClassProfDescriptions.size()==0:
		return 
	#if selectionState != SelectionState.SELECTED_PROFICIENCIES:
	#haven't finished selecting our build yet?
	if not hasSelectedBothProficiencies():
		#can't iterate over minor classes if picked major class advantage
		if not hasSelectedMajorClassAdvantage(): 
		
		
			if currMinorClassIx==-1:
				
				currMinorClassIx=minorClassProfDescriptions.size()-1
			else:
				
				currMinorClassIx = currMinorClassIx-1
				
				if currMinorClassIx == -1:
					currMinorClassIx = minorClassProfDescriptions.size()-1
				#can't pick major class when cyrcling through minor classes and already pickyed hybird
				#if hasSelectedHybridProciency() and currMinorClassIx == -1:
				#	currMinorClassIx=minorClassProfDescriptions.size()-1
					
			var parent = get_parent()
			parent.sfxPlayer.playSound(parent.UI_MOVE_CURSOR_SOUND_ID)
			updateDisplay()
				
func confirmProficiencySelection():
	
	var selectNextMajorClassFlag = false	
	#only cofirm selection if not already selected both proficiencies?
	#if not selectionState == SelectionState.SELECTED_PROFICIENCIES:
	#haven't finished selecting our build yet?
	if not hasSelectedBothProficiencies():
		
		if selectionState == SelectionState.SELECTING_PROFICIENCY_1:
			
			
			#selected a major class as 1st proficiency?
			if currMinorClassIx== -1:
				if currMajorClassIx == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
					#selectedMajorClassAdvantage=true
					selectNextMajorClassFlag=true #make sure to notify to change currenct ui selection mof major class
					majorClassProfDescBox.hideMinorClassNameArrows()
				else:
					return #can't pick a major class. gotta choose one of choces
			else:
				
				majorClassProfDescBox.displayMinorClassNameArrows()
				
				
				
			
			if currMajorClassIx == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
				#GENERALIST CHOOSES BOTH SLOTS
				prof1MajorClassIxSelect = currMajorClassIx
				prof1MinorClassIxSelect = currMinorClassIx

				#confirm the proficiency 1 selection
				prof2MajorClassIxSelect = currMajorClassIx
				prof2MinorClassIxSelect = currMinorClassIx
		
				#selectionState =SelectionState.SELECTED_PROFICIENCIES
				updateProfSelectionStars(SELECT_STAR_1_IX,currMajorClassIx,GLOBALS.ProficiencyClass.MAJOR_ADVANTAGE)
				selectionStars[SELECT_STAR_1_IX].confirmSelection()
				updateProfSelectionStars(SELECT_STAR_2_IX,currMajorClassIx,GLOBALS.ProficiencyClass.MAJOR_ADVANTAGE)
				selectionStars[SELECT_STAR_2_IX].confirmSelection()
		
				changeState(SelectionState.SELECTED_PROFICIENCIES)
				
				emit_signal("proficiency_1_confirmed")
				emit_signal("proficiency_2_confirmed")
			else:
					
				#confirm the proficiency 1 selection
				prof1MajorClassIxSelect = currMajorClassIx
				prof1MinorClassIxSelect = currMinorClassIx				
				
				changeState(SelectionState.SELECTING_PROFICIENCY_2)
				#selectionState =SelectionState.SELECTING_PROFICIENCY_2
				selectionStars[SELECT_STAR_1_IX].confirmSelection()
				selectionStarIx=SELECT_STAR_2_IX
				
				#can't pick same disadvantage class choice as advantage major class
				if prof1MajorClassIxSelect != GLOBALS.PROFICIENCY_MAJOR_CLASS_NO_JOHNS:
					selectNextMajorClass()
				
					
				emit_signal("proficiency_1_confirmed")
		elif selectionState == SelectionState.SELECTING_PROFICIENCY_2:
			
			var validSelection =false
			
			#can't pick a major class as disadvantage
			if currMinorClassIx != -1:				
				validSelection=true
			#if hasSelectedMajorClassAdvantage():
				#can't pick disadvantage  and advatage asame major class
				
			#	if prof1MajorClassIxSelect !=currMajorClassIx:
			#		validSelection=true	
					
			#else:
				#can't pick the exact same minor prof twice
			#	if( prof1MajorClassIxSelect !=currMajorClassIx or prof1MinorClassIxSelect != currMinorClassIx):
			#		validSelection=true
					
			if validSelection:
				
					if prof1MajorClassIxSelect == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
						prof1MinorClassIxSelect=-1
						prof2MinorClassIxSelect=-1
		
				#confirm the proficiency 2 selection
					prof2MajorClassIxSelect = currMajorClassIx
					prof2MinorClassIxSelect = currMinorClassIx

					changeState(SelectionState.SELECTED_PROFICIENCIES)
					#selectionState = SelectionState.SELECTED_PROFICIENCIES
					selectionStars[SELECT_STAR_2_IX].confirmSelection()
					
					emit_signal("proficiency_2_confirmed")
					#selectionStarIx=-1		
					
					
		#make sure to undisplay the major class we just select as advantage
		if selectNextMajorClassFlag:
			selectNextMajorClass()
				
		updateDisplay()
	else:
		var parent = get_parent()
		#make sound of ui selection to allow spamming to get opponent to hury
		parent.sfxPlayer.playSound(parent.PROF_CONFIRMED_CURSOR_SOUND_ID)
		playerReadyCheck()		

func unconfirmProficiencySelection():
	

		#only unconrfirm selection if picked a proficiency
		if not selectionState == SelectionState.SELECTING_PROFICIENCY_1:
			
			#picked prof 1?
			if selectionState == SelectionState.SELECTING_PROFICIENCY_2:
				
				currMajorClassIx=prof1MajorClassIxSelect
				currMinorClassIx=prof1MinorClassIxSelect
				
				#selectedMajorClassAdvantage=false
				#undo the prof 1 selection
				prof1MajorClassIxSelect = null
				prof1MinorClassIxSelect = null

	
				majorClassProfDescBox.displayMinorClassNameArrows()
				
				changeState(SelectionState.SELECTING_PROFICIENCY_1)
				#selectionState =SelectionState.SELECTING_PROFICIENCY_1
				
				#star 1 tranpsrante content
				selectionStars[SELECT_STAR_1_IX].unconfirmSelection()
				
				#star 2 no content
				selectionStars[SELECT_STAR_2_IX].unselect()
				selectionStarIx=SELECT_STAR_1_IX
				
				emit_signal("proficiency_1_unconfirmed")
			#picked all prof 2?
			elif selectionState == SelectionState.SELECTED_PROFICIENCIES:
				readyIcon.visible = false
				#genrealist chosen?	
				if prof1MajorClassIxSelect == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
					#GENERALIST CHOOSES BOTH SLOTS
					prof1MajorClassIxSelect = null
					prof1MinorClassIxSelect = null
					prof2MajorClassIxSelect = null
					prof2MinorClassIxSelect = null
					
					selectionStars[SELECT_STAR_2_IX].unconfirmSelection()
					selectionStars[SELECT_STAR_2_IX].unselect()
					selectionStars[SELECT_STAR_1_IX].unconfirmSelection()
					selectionStarIx=SELECT_STAR_1_IX
					#selectionState = SelectionState.SELECTING_PROFICIENCY_1
					changeState(SelectionState.SELECTING_PROFICIENCY_1)
					
					emit_signal("proficiency_2_unconfirmed")
					emit_signal("proficiency_1_unconfirmed")
				else:	
					#undo the prof 2 selection
					prof2MajorClassIxSelect = null
					prof2MinorClassIxSelect = null
					#selectionState = SelectionState.SELECTING_PROFICIENCY_2
					changeState(SelectionState.SELECTING_PROFICIENCY_2)
					#star 2 tranpsrante content
					selectionStars[SELECT_STAR_2_IX].unconfirmSelection()
					selectionStarIx=SELECT_STAR_2_IX
					
					emit_signal("proficiency_2_unconfirmed")
		updateDisplay()
							
	

func updateDisplay():	
			
		#selecting fisrst prof?
		if selectionState ==SelectionState.SELECTING_PROFICIENCY_1:
			
			#display the major class pencil to indicate generlist as a whole class is being selected
			if currMajorClassIx == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
				
				
				majorClassProfDescBox.setMajorClassPencilVisibility(player == PlayerID.PLAYER1,true)
			else:
				majorClassProfDescBox.setMajorClassPencilVisibility(player == PlayerID.PLAYER1,false)
					
			#did we select a major class?
			if currMinorClassIx == -1:
				
				displayProficiencyInfo(currMajorClassIx,GLOBALS.ProficiencyClass.MAJOR_ADVANTAGE,currMinorClassIx,true)
				updateProfSelectionStars(selectionStarIx,currMajorClassIx,GLOBALS.ProficiencyClass.MAJOR_ADVANTAGE,currMinorClassIx)
			else:
				
				#we selected minor prof hybrid build
				displayProficiencyInfo(currMajorClassIx,GLOBALS.ProficiencyClass.MINOR,currMinorClassIx,true)
				#updateProfSelectionStars(selectionStarIx,currMajorClassIx,GLOBALS.ProficiencyClass.MINOR,currMinorClassIx)
				updateProfSelectionStars(selectionStarIx,currMajorClassIx,GLOBALS.ProficiencyClass.MAJOR_ADVANTAGE,currMinorClassIx)
		elif selectionState ==SelectionState.SELECTING_PROFICIENCY_2:
			
			#can't select generist other than for 1st choise, so hide major class 
			#pencil
			majorClassProfDescBox.setMajorClassPencilVisibility(player == PlayerID.PLAYER1,false)
			#did we confrimed a major class as our avdantage prof?
			#if prof1MinorClassIxSelect == -1:
			if currMinorClassIx==-1:
				
				#display disadvnatage
				displayProficiencyInfo(currMajorClassIx,GLOBALS.ProficiencyClass.MAJOR_DISADVANTAGE,currMinorClassIx,false)
				updateProfSelectionStars(selectionStarIx,currMajorClassIx,GLOBALS.ProficiencyClass.MAJOR_DISADVANTAGE,currMinorClassIx)
			else:
				#we selected minor prof hybrid build
				displayProficiencyInfo(currMajorClassIx,GLOBALS.ProficiencyClass.MINOR,currMinorClassIx,false)
				#updateProfSelectionStars(selectionStarIx,currMajorClassIx,GLOBALS.ProficiencyClass.MINOR,currMinorClassIx)
				updateProfSelectionStars(selectionStarIx,currMajorClassIx,GLOBALS.ProficiencyClass.MAJOR_DISADVANTAGE,currMinorClassIx)
		elif selectionState ==SelectionState.SELECTED_PROFICIENCIES:
			#can't select generist other than for 1st choise, so hide major class 
			#pencil
			majorClassProfDescBox.setMajorClassPencilVisibility(player == PlayerID.PLAYER1,false)
			updateProficiencyBuildSelectionSummary()
	#if displayMinorInfo:
	#	updateMinorClassSelected(currMinorClassIx)	
			
			
func hasSelectedMajorClassAdvantage():
	return prof1MajorClassIxSelect != null and prof1MinorClassIxSelect == -1
	
func hasSelectedHybridProciency():
	return prof1MajorClassIxSelect != null and prof1MinorClassIxSelect != -1
	

func selectRandomProficiency():
	
	#if selectionState == SelectionState.SELECTED_PROFICIENCIES:
	#do nothign in case we already selected both profs
	if hasSelectedBothProficiencies():
		return
	
	var loopUntilValidSelection = true
	
	var oldMajorClass =currMajorClassIx
	var oldMinorClass =currMinorClassIx
	while loopUntilValidSelection:
		#when selecting 2nd prof , there are restrictions on selection
		
		
		#SELECT a random major class
		currMajorClassIx= rng.randi_range(0,numMajorClasses-1)
		
		currMinorClassIx = 0
		
		
		
		#we only consider minor class random if we haven't picked advantage yet
		#picking advnatage forces random to only include disadvantages
	#	if not hasSelectedMajorClassAdvantage():			
		
		#only select random hybrid (which could be no hbyrid at all) if were not doing generalist
		#if currMajorClassIx != GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST and currMajorClassIx != GLOBALS.PROFICIENCY_MAJOR_CLASS_NO_JOHNS:
		if currMajorClassIx != GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
			var _isAdvantage = false
			if selectionState ==SelectionState.SELECTING_PROFICIENCY_1:
				_isAdvantage=true
			var minorClases = profDataModel.getMinorProficiencies(currMajorClassIx,_isAdvantage)
				
			var numMinorClassses = minorClases.size()
			
			if numMinorClassses>0:
			
			#	if hasSelectedHybridProciency():			
					#select random minor class (exlcuding no minor class, as were forced to pick 
					#hybrid given our first selection is hybrid)
				currMinorClassIx =rng.randi_range(0,numMinorClassses-1)
			#	else:
					#select random minor class (including no minor class)
			#		currMinorClassIx =rng.randi_range(-1,numMinorClassses)
		
			#else:
			#	continue		
			#threare are not restriction for picking first random prof, 
			#but for 2nd prof, can't pick same major class as selected 1st
		
		else:
			currMinorClassIx=-1	
			
		#TODO: FIND bug that allows random to let you access major classes you shouldn't acess. 
		#only minor classes should be availalbe
		if currMinorClassIx==-1	 and currMajorClassIx != GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
			continue
		
		#prevent random from select the current selection by chance. should always be a
		#different choice
		if oldMajorClass==	currMajorClassIx and oldMinorClass==currMinorClassIx:
			continue
		loopUntilValidSelection=checkInvalidMajorClassSelection()
		

		
	#confirmProficiencySelection()
	#selectNextMajorClass()
	
	updateDisplay()
		
func hasSelectedBothProficiencies():
	return selectionState != SelectionState.SELECTING_PROFICIENCY_1 and selectionState != SelectionState.SELECTING_PROFICIENCY_2
	
	
func changeState(newState):
	
	if newState ==SelectionState.SELECTED_PROFICIENCIES:
	
		selectionStarIx=-1		
		
		var star1ProfType = null
		var star2ProfType = null
		
		if hasSelectedMajorClassAdvantage():
			star1ProfType=GLOBALS.ProficiencyClass.MAJOR_ADVANTAGE
			star2ProfType=GLOBALS.ProficiencyClass.MAJOR_DISADVANTAGE
		else:
			star1ProfType=GLOBALS.ProficiencyClass.MINOR
			star2ProfType=GLOBALS.ProficiencyClass.MINOR
			
		#updateLargeProfSelectionStars(SELECT_STAR_1_IX,prof1MajorClassIxSelect,star1ProfType,prof1MinorClassIxSelect)
		#largerSelectionStars[SELECT_STAR_1_IX].confirmSelection()
		#updateLargeProfSelectionStars(SELECT_STAR_2_IX,prof2MajorClassIxSelect,star2ProfType,prof2MinorClassIxSelect)
		#largerSelectionStars[SELECT_STAR_2_IX].confirmSelection()
		
		#the 2 large selection stars displayed
		majorClassProfDescBox.visible = false
		
		largerStarSelectionContainer.visible = true
		starSelectionContainer.visible = false
		
		if  selectionState != newState:
			var parent = get_parent()
			#make sound of ui selection when make new selection
			parent.sfxPlayer.playSound(parent.PROF_CONFIRMED_CURSOR_SOUND_ID)
			
	elif newState == SelectionState.SELECTING_PROFICIENCY_2 or newState == SelectionState.SELECTING_PROFICIENCY_1:
		
		if  selectionState != newState:
			var parent = get_parent()
			#make sound of ui selection when make new selection
			parent.sfxPlayer.playSound(parent.PROF_CONFIRMED_CURSOR_SOUND_ID)
			
			
		#the 2 large selection stars are hidden
		majorClassProfDescBox.visible = true
		
		largerStarSelectionContainer.visible = false
		starSelectionContainer.visible = true
		
	selectionState=newState			
	
	
func debugReady():
	inputDevices.append(GLOBALS.PLAYER1_INPUT_DEVICE_ID)
	inputDevices.append(GLOBALS.PLAYER2_INPUT_DEVICE_ID)
	self.connect("proficiencies_selection_confirmed",self,"_on_debug_print_seleciton")
	set_process(true)
	set_physics_process(false)
	
func _process(delta):
	
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	#process logic to skip student victory info screen or pause
	for player in inputDevices:
		processInput(player)

func _physics_process(delta):
	delta=GLOBALS.FIXED_FRAME_DURATION_IN_SECONDS
	processInput(inputDeviceId)
	
	
func processInput(inputDeviceId):
	if  Input.is_action_just_pressed(inputDeviceId+"_LEFT"):
		selectPreviousMajorClass()
		
	elif  Input.is_action_just_pressed(inputDeviceId+"_RIGHT"):
		
		selectNextMajorClass()
		
	
	elif  Input.is_action_just_pressed(inputDeviceId+"_DOWN"):
		
		selectNextMinorClass()
	elif  Input.is_action_just_pressed(inputDeviceId+"_UP"):
		selectPreviousMinorClass()
	elif  Input.is_action_just_pressed(inputDeviceId+"_A"):
		
		confirmProficiencySelection()
					
				
	elif  Input.is_action_just_pressed(inputDeviceId+"_B"):
		
		unconfirmProficiencySelection()
	elif  Input.is_action_just_pressed(inputDeviceId+"_X"):
		
		selectRandomProficiency()
	elif  Input.is_action_just_pressed(inputDeviceId+"_START"):
		playerReadyCheck()
		
		

func playerReadyCheck():
	if selectionState == SelectionState.SELECTED_PROFICIENCIES:
		readyIcon.visible = true
		emit_signal("proficiencies_selection_confirmed",prof1MajorClassIxSelect,prof1MinorClassIxSelect,prof2MajorClassIxSelect,prof2MinorClassIxSelect)
	
func _on_debug_print_seleciton(_prof1MajorClassIxSelect,_prof1MinorClassIxSelect,_prof2MajorClassIxSelect,_prof2MinorClassIxSelect):
	print("profs selected")
	
	