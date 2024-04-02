extends Control

signal proficiencies_selection_confirmed
signal proficiency_1_confirmed
signal proficiency_2_confirmed
signal proficiency_1_unconfirmed
signal proficiency_2_unconfirmed


const propertyDescriptionResource = preload("res://interface/new-prof-select/profPropertyRow.tscn")

const GLOBALS = preload("res://Globals.gd")
export (Color) var advantageTint = Color(0,1,0)
export (Color) var disadvantageTint = Color(1,0,0)
export (Color) var disabledColor = Color(0.2,0.2,0.2,0.4)
export (String) var inputDeviceId = "P1"

const ITEM_SELECT_SOUND_IX=0
const ITEM_CONFIRMATION_SOUND_IX=4
const INVALID_SELECTION_SOUND_IX=5

const NUMBER_MAJOR_CLASSES = 7
var nodeSelectionMap = {}

var majorProfMap = {}


var heldDirInput = null

var profDataModel = null

var proficiencyNameLabel = null

#var minorClassSlotsNode = null

var minorClassTintedNodes = []

var minorClassSlot1 = null
var minorClassSlot2 = null

var greenStar= null
var redStar= null
var goldenStar = null

const MINOR_CLASS_SLOT1_IX = 0
const MINOR_CLASS_SLOT2_IX = 1
var minorClassSlots = []

var profDescriptionLabel = null

var propertiesList = null
var prof2ndSelectionDisableMap={} #keys: major prof. value : list of disabled major classes
var majorProfSlotReverseMap= {}

var dinputReverseMap={}

var soundPlayer = null
var invalidOptionSoundPlayer = null
var rng = null
#state info
enum State{
	MAJOR_CLASS_FIRST_SELECTION, # advantage pre prof selection. Navigating circle menu via left-right-down-up
	MINOR_CLASS_FIRST_SELECTION, # advantage selected major prof, now selecting minor prof via left-right input
	MAJOR_CLASS_SECOND_SELECTION, # advantage pre prof selection. Navigating circle menu via left-right-down-up
	MINOR_CLASS_SECOND_SELECTION, # advantage selected major prof, now selecting minor prof via left-right input
	SELECTION_FINISHED
}

var state = State.MAJOR_CLASS_FIRST_SELECTION

var prof1MajorClassIxSelect=null
var prof2MajorClassIxSelect=null
var minorProf1=null
var minorProf2=null
var prof1MinorClassIxSelect = GLOBALS.PROFICIENCY_NO_MINOR_CLASS
var prof2MinorClassIxSelect = GLOBALS.PROFICIENCY_NO_MINOR_CLASS
var signaledReadyFlag = false

func _ready():
	nodeSelectionMap[GLOBALS.DirectionalInput.UP] =null
	nodeSelectionMap[GLOBALS.DirectionalInput.FORWARD_UP] =$"major-class-slots/mage-slot" #mage
	nodeSelectionMap[GLOBALS.DirectionalInput.FORWARD] =$"major-class-slots/defender-slot" #defender
	nodeSelectionMap[GLOBALS.DirectionalInput.FORWARD_DOWN] =$"major-class-slots/offensive-master-slot" #offensive mastery
	nodeSelectionMap[GLOBALS.DirectionalInput.NEUTRAL] =$"major-class-slots/generalist-slot" #generalist
	nodeSelectionMap[GLOBALS.DirectionalInput.DOWN] =null
	nodeSelectionMap[GLOBALS.DirectionalInput.BACKWARD_DOWN] =$"major-class-slots/psychic-slot" #psychic
	nodeSelectionMap[GLOBALS.DirectionalInput.BACKWARD] =$"major-class-slots/acrobatics-slot" #acrobatics
	nodeSelectionMap[GLOBALS.DirectionalInput.BACKWARD_UP] =$"major-class-slots/hardcore-slot" #hardcore / no johns

	soundPlayer = $sfxPlayer
	invalidOptionSoundPlayer = $invalidOptionsfxPlayer
	propertiesList = $propertyList 
	

	majorProfSlotReverseMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST]=$"major-class-slots/generalist-slot"
	majorProfSlotReverseMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_ABILITY_CANCEL]=$"major-class-slots/mage-slot"
	majorProfSlotReverseMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_DEFENDER]=$"major-class-slots/defender-slot"
	majorProfSlotReverseMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_OFFESIVE_MASTERY]=$"major-class-slots/offensive-master-slot"
	majorProfSlotReverseMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_PSYCHIC]=$"major-class-slots/psychic-slot"
	majorProfSlotReverseMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_ACROBATICS]=$"major-class-slots/acrobatics-slot"
	majorProfSlotReverseMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_NO_JOHNS]=$"major-class-slots/hardcore-slot"
	
	
		
	
	rng = RandomNumberGenerator.new()
	
	#genreate time-based seed
	rng.randomize()


	greenStar=$greenStar
	redStar=$redStar
	goldenStar = $goldenStar
	
	proficiencyNameLabel = $proficiencyName
	proficiencyNameLabel.text = ""
	
	#minorClassSlotsNode = $minorClassSlots
	
	minorClassSlots.append($"minor-class-slots/slot1")
	minorClassSlots.append($"minor-class-slots/slot2")
	
	profDescriptionLabel = $profDesc
	
	profDescriptionLabel.text = ""
	proficiencyNameLabel.text = ""
	
	profDescriptionLabel = $"profDesc"

	minorClassTintedNodes.append($"minor-class-slots/slot1/line")
	minorClassTintedNodes.append($"minor-class-slots/slot1/border")
	minorClassTintedNodes.append($"minor-class-slots/slot2/line")
	minorClassTintedNodes.append($"minor-class-slots/slot2/border")
	
	
	hideAllMajorClassSelectedStars()
	
	profDataModel =  $profDataModel
	profDataModel.loadProficiencyPropertyDescriptions()
	majorProfMap[GLOBALS.DirectionalInput.UP] =null
	majorProfMap[GLOBALS.DirectionalInput.FORWARD_UP] =GLOBALS.PROFICIENCY_MAJOR_CLASS_ABILITY_CANCEL
	majorProfMap[GLOBALS.DirectionalInput.FORWARD] =GLOBALS.PROFICIENCY_MAJOR_CLASS_DEFENDER
	majorProfMap[GLOBALS.DirectionalInput.FORWARD_DOWN] =GLOBALS.PROFICIENCY_MAJOR_CLASS_OFFESIVE_MASTERY
	majorProfMap[GLOBALS.DirectionalInput.NEUTRAL] =GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST
	majorProfMap[GLOBALS.DirectionalInput.DOWN] =null
	majorProfMap[GLOBALS.DirectionalInput.BACKWARD_DOWN] =GLOBALS.PROFICIENCY_MAJOR_CLASS_PSYCHIC
	majorProfMap[GLOBALS.DirectionalInput.BACKWARD] =GLOBALS.PROFICIENCY_MAJOR_CLASS_ACROBATICS
	majorProfMap[GLOBALS.DirectionalInput.BACKWARD_UP] =GLOBALS.PROFICIENCY_MAJOR_CLASS_NO_JOHNS
	
			
		
	dinputReverseMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST]=GLOBALS.DirectionalInput.NEUTRAL
	dinputReverseMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_ABILITY_CANCEL]=GLOBALS.DirectionalInput.FORWARD_UP
	dinputReverseMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_DEFENDER]=GLOBALS.DirectionalInput.FORWARD
	dinputReverseMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_OFFESIVE_MASTERY]=GLOBALS.DirectionalInput.FORWARD_DOWN
	dinputReverseMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_PSYCHIC]=GLOBALS.DirectionalInput.BACKWARD_DOWN
	dinputReverseMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_ACROBATICS]=GLOBALS.DirectionalInput.BACKWARD
	dinputReverseMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_NO_JOHNS]=GLOBALS.DirectionalInput.BACKWARD_UP
	
	
	
	prof2ndSelectionDisableMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST]=[GLOBALS.PROFICIENCY_MAJOR_CLASS_ABILITY_CANCEL,GLOBALS.PROFICIENCY_MAJOR_CLASS_DEFENDER,GLOBALS.PROFICIENCY_MAJOR_CLASS_OFFESIVE_MASTERY,GLOBALS.PROFICIENCY_MAJOR_CLASS_PSYCHIC,GLOBALS.PROFICIENCY_MAJOR_CLASS_ACROBATICS,GLOBALS.PROFICIENCY_MAJOR_CLASS_NO_JOHNS]
	prof2ndSelectionDisableMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_ABILITY_CANCEL]=[GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST,GLOBALS.PROFICIENCY_MAJOR_CLASS_ABILITY_CANCEL]
	prof2ndSelectionDisableMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_DEFENDER]=[GLOBALS.PROFICIENCY_MAJOR_CLASS_DEFENDER,GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST]
	prof2ndSelectionDisableMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_OFFESIVE_MASTERY]=[GLOBALS.PROFICIENCY_MAJOR_CLASS_OFFESIVE_MASTERY,GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST]
	prof2ndSelectionDisableMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_PSYCHIC]=[GLOBALS.PROFICIENCY_MAJOR_CLASS_PSYCHIC,GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST]
	prof2ndSelectionDisableMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_ACROBATICS]=[GLOBALS.PROFICIENCY_MAJOR_CLASS_ACROBATICS,GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST]
	prof2ndSelectionDisableMap[GLOBALS.PROFICIENCY_MAJOR_CLASS_NO_JOHNS]=[GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST]
	
	#inputDeviceId =GLOBALS.PLAYER1_INPUT_DEVICE_ID
	
	changeState(State.MAJOR_CLASS_FIRST_SELECTION)

func updateNoSelectionDisplayedText():
	if state == State.MAJOR_CLASS_FIRST_SELECTION:
		setDescriptionText("0/2 proficiency selections made")
		setProficiencyName("Choose your strength")
		clearPropertyList()
	elif state == State.MINOR_CLASS_FIRST_SELECTION:
		pass
	elif state == State.MAJOR_CLASS_SECOND_SELECTION:
		setDescriptionText("1/2 proficiency selections made")
		setProficiencyName("Choose your weakness")
		clearPropertyList()
	elif state == State.MINOR_CLASS_FIRST_SELECTION:
		pass
	elif state == State.SELECTION_FINISHED:	
		setProficiencyName("Ready")
		pass
		

func populateMinorProfSlotTextures(majorProfix,isAdvantage):
	#make the minor prof selection  cursor green
	setMinorClassSlotsTint(isAdvantage)

	var minorProfs = profDataModel.getMinorProficiencies(majorProfix,isAdvantage)		
		
	#show all the minor class slots based on major classes' nubmer of minor profs
	updateMinorClassSlotVisibility(minorProfs.size())
	
	#display the icon and names of pros
	for i in range(0,minorProfs.size()):			
		var minorProf=minorProfs[i]			
		setMinorClassSlotTexture(i,minorProf.icon)
	
		
	updateMinorProfInfo(majorProfix,isAdvantage,0) #first minor prof always selected
		
	
func changeState(newState):
	var stateChangedFlag =  newState != state
	var oldState=state
	state=newState
	
	#any state change means we ready again to signal selections made
	signaledReadyFlag = false
	if state == State.MAJOR_CLASS_FIRST_SELECTION:
		enableAllMajorClassesSlots()				
		
		greenStar.visible=true
		redStar.visible=false
		goldenStar.visible=false
		
		prof1MajorClassIxSelect=null		
		minorProf1=null
		prof1MinorClassIxSelect = GLOBALS.PROFICIENCY_NO_MINOR_CLASS		
		prof2MajorClassIxSelect=null		
		minorProf2=null
		prof2MinorClassIxSelect = GLOBALS.PROFICIENCY_NO_MINOR_CLASS
		
		hideAllMajorClassSelectedStars()
		
		if stateChangedFlag:
			soundPlayer.playSound(ITEM_CONFIRMATION_SOUND_IX)
		
		unselectAllSlots()
		
		updateMinorClassSlotVisibility(0) 
		updateNoSelectionDisplayedText()
		
		#we previously had selected both prof chocies?
		if oldState ==State.MAJOR_CLASS_SECOND_SELECTION:
			emit_signal("proficiency_1_unconfirmed")
			
	elif state == State.MINOR_CLASS_FIRST_SELECTION:
		
		prof2MajorClassIxSelect=null		
		minorProf2=null	
		prof2MinorClassIxSelect = GLOBALS.PROFICIENCY_NO_MINOR_CLASS
		
		if stateChangedFlag:
			soundPlayer.playSound(ITEM_CONFIRMATION_SOUND_IX)
		greenStar.visible=true
		redStar.visible=false
		goldenStar.visible=false
		
		hideAllMajorClassSelectedStars()
		displayMajorClassSelectedStar(true,prof1MajorClassIxSelect)
				
		#by default the 1st minor prof is selected
		var minorProfs = profDataModel.getMinorProficiencies(prof1MajorClassIxSelect,true)
		minorProf1=minorProfs[0]
		prof1MinorClassIxSelect = 0
		var isAdvantage = true
		

		populateMinorProfSlotTextures(prof1MajorClassIxSelect,isAdvantage)
		
		unselectAllSlots()
		heldDirInput= dinputReverseMap[prof1MajorClassIxSelect] #make sure direction held is appropriate to major class selected
		selectSlot(heldDirInput)
		
		
	elif state == State.MAJOR_CLASS_SECOND_SELECTION:
				
		prof2MajorClassIxSelect=null		
		minorProf2=null			
		prof2MinorClassIxSelect = GLOBALS.PROFICIENCY_NO_MINOR_CLASS
		
		if stateChangedFlag:
			soundPlayer.playSound(ITEM_CONFIRMATION_SOUND_IX)
		
		greenStar.visible=false
		redStar.visible=true
		goldenStar.visible=false
		
		updateNoSelectionDisplayedText()
		
		
		#grey out and disable all the major prof classes that 
		#can't be chosen after the select major prof was selected
		disableMajorClassesSlots(prof1MajorClassIxSelect)
		
		hideAllMajorClassSelectedStars()
		displayMajorClassSelectedStar(true,prof1MajorClassIxSelect)
		
		updateNoSelectionDisplayedText()
		
		updateMinorClassSlotVisibility(0) 
		
		unselectAllSlots()
		
		#selected first proficiency choice?
		if oldState ==State.MINOR_CLASS_FIRST_SELECTION:
			emit_signal("proficiency_1_confirmed")
		#we previously had selected both prof chocies?
		elif oldState ==State.SELECTION_FINISHED:
			emit_signal("proficiency_2_unconfirmed")
	elif state == State.MINOR_CLASS_SECOND_SELECTION:
		
		var isAdvantage = false
		if stateChangedFlag:
			soundPlayer.playSound(ITEM_CONFIRMATION_SOUND_IX)
		greenStar.visible=false
		redStar.visible=true
		goldenStar.visible=false
		
		#by default the 1st minor prof is selected	
		var minorProfs = profDataModel.getMinorProficiencies(prof2MajorClassIxSelect,isAdvantage)
		minorProf2=minorProfs[0]
		prof2MinorClassIxSelect = 0
		
		hideAllMajorClassSelectedStars()
		displayMajorClassSelectedStar(true,prof1MajorClassIxSelect)
		displayMajorClassSelectedStar(false,prof2MajorClassIxSelect)
		
		#make the minor prof selection cursor red
		setMinorClassSlotsTint(isAdvantage)
							
		populateMinorProfSlotTextures(prof2MajorClassIxSelect,isAdvantage)
		
				
		unselectAllSlots()
		heldDirInput= dinputReverseMap[prof2MajorClassIxSelect] #make sure direction held is appropriate to major class selected
		selectSlot(heldDirInput)
	
	elif state == State.SELECTION_FINISHED:	
				
		greenStar.visible=false
		redStar.visible=false
		goldenStar.visible=true
		
		if stateChangedFlag:
			soundPlayer.playSound(ITEM_CONFIRMATION_SOUND_IX)
		
		hideAllMajorClassSelectedStars()
		displayMajorClassSelectedStar(true,prof1MajorClassIxSelect)
		displayMajorClassSelectedStar(false,prof2MajorClassIxSelect)
						
		disableAllMajorClassesSlots()
		updateMinorClassSlotVisibility(0) 
		
		unselectAllSlots()
		displayReady()
		
		#selected first proficiency choice?
		if oldState ==State.MINOR_CLASS_SECOND_SELECTION:
			emit_signal("proficiency_2_confirmed")
		
		
		
		
		
		
				
func unselectAllSlots():
	for inputDir in nodeSelectionMap.keys():
		if inputDir != null:
			unselectSlot(inputDir)
	
func selectSlot(inputDir):
	
	
	
	if not nodeSelectionMap.has(inputDir):
		return
	

	var slot = nodeSelectionMap[inputDir]
	
	if slot == null:
		return
	var selectSprite = slot.get_node("selected-bgd")
	
	
	
	
	selectSprite.visible = true
	
func unselectSlot(inputDir):
	if not nodeSelectionMap.has(inputDir):
		return
		
	var slot = nodeSelectionMap[inputDir]
	
	if slot== null:
		return 
	var selectSprite = slot.get_node("selected-bgd")
	selectSprite.visible = false

func displayMajorClassSelectedStar(isAdvantage,majorClassIx):
	var slot = majorProfSlotReverseMap[majorClassIx]
	
	var greenStar = slot.get_node("choice-stars/greenStar")
	var redStar = slot.get_node("choice-stars/redStar")
	if isAdvantage:
		greenStar.visible=true
		#redStar.visible=false
	else:
		#greenStar.visible=false
		redStar.visible=true

func hideAllMajorClassSelectedStars():
	for majorClassIx in majorProfSlotReverseMap.keys():
		var slot = majorProfSlotReverseMap[majorClassIx]
	
		var greenStar = slot.get_node("choice-stars/greenStar")
		var redStar = slot.get_node("choice-stars/redStar")
		
		greenStar.visible=false
		redStar.visible=false
		
func isMajorClassSelectable(majorClass):
	#nothing disable at first.
	#made a selection and choosing 2nd major prof?
	if prof1MajorClassIxSelect != null:
		
		#now we check if given class index inside the disable list of chosen major classe
		var disabledList = prof2ndSelectionDisableMap[prof1MajorClassIxSelect]
		
		for disabledMajorClass in disabledList:
			if majorClass ==disabledMajorClass:
				return false
	
	return true
		
		
		
func disableAllMajorClassesSlots():
	
	for k in majorProfSlotReverseMap:
		
		var slot = majorProfSlotReverseMap[k]
		var icon = slot.get_node("prof-icon")
		icon.modulate = disabledColor
func disableMajorClassesSlots(majorClassSelected):
	enableAllMajorClassesSlots()
	var disabledMajorClassIxs = prof2ndSelectionDisableMap[majorClassSelected]
	
	for majorClassToDisable in disabledMajorClassIxs:
		
		var slot = majorProfSlotReverseMap[majorClassToDisable]
		var icon = slot.get_node("prof-icon")
		icon.modulate = disabledColor
	
func enableAllMajorClassesSlots():
	for k in majorProfSlotReverseMap:
		var slot = majorProfSlotReverseMap[k]
		var icon = slot.get_node("prof-icon")
		icon.modulate = Color(1,1,1,1)
	
func setMinorClassSlotsTint(advantageFlag):
	for n in minorClassTintedNodes:
		if advantageFlag:
			n.modulate = advantageTint
		else:
			n.modulate = disadvantageTint

func updateMinorClassSlotVisibility(numSlots):
		
	#no slots visible?	
	if numSlots <= 0:
		
		minorClassSlots[MINOR_CLASS_SLOT1_IX].visible = false
		minorClassSlots[MINOR_CLASS_SLOT2_IX].visible = false
	elif numSlots == 1:# 1 slots (e.g., hardcore oly has 1 choice)
		minorClassSlots[MINOR_CLASS_SLOT1_IX].visible = true
		minorClassSlots[MINOR_CLASS_SLOT2_IX].visible = false
	else:#2 slots (e.g,. most major profs have 2 minor choices)
		minorClassSlots[MINOR_CLASS_SLOT1_IX].visible = true
		minorClassSlots[MINOR_CLASS_SLOT2_IX].visible = true

func setMinorClassSlotTexture(slotix,texture):
	var sprite = minorClassSlots[slotix].get_node("prof-icon")
	sprite.texture=texture
	
func setDescriptionText(text):
	profDescriptionLabel.text = text
func setProficiencyName(text):
	proficiencyNameLabel.text = text

func selectMinorClassSlot(slotix):
	var slot = minorClassSlots[slotix]
	
	#highlihgth select slot
	var hightlightedBgd = slot.get_node("background2")
	hightlightedBgd.visible = true
	
	#make other slot not highlited
	slot = minorClassSlots[(slotix+1)%2]
	
	#highlihgth select slot
	hightlightedBgd = slot.get_node("background2")
	hightlightedBgd.visible = false
	
func updateMinorProfInfo(majorProfIx,isAdvantage,slotIx):
	#updateMinorClassSlotVisibility(slotIx) 
	var minorProfs = profDataModel.getMinorProficiencies(majorProfIx,isAdvantage)
	
	if slotIx >= minorProfs.size():
		return
	
	if slotIx == 0:
		$"minor-class-slots/slot1/line".visible =true
		$"minor-class-slots/slot2/line".visible = false
	else:	
		$"minor-class-slots/slot1/line".visible =false
		$"minor-class-slots/slot2/line".visible = true
	selectMinorClassSlot(slotIx)
	var minorProf = minorProfs[slotIx]

	setProficiencyName(minorProf.profName)
	setMinorClassSlotTexture(slotIx,minorProf.icon)
	
	setMinorClassSlotsTint(isAdvantage)
	
	var descText ="Properties: \n"

	var props = null
	
	if isAdvantage:
		props=minorProf.goodProperties
	else:
		props=minorProf.badProperties
	
	clearPropertyList()	
	
	if props.size() == 0:
		descText = descText+"    > None\n"
		
		addPropertyDescription(isAdvantage,"None")
		
	else:
		
		for prop in props:
			
			var desc = profDataModel.getProficiencyPropertyDescription(prop.id)
			#var desc = profDataModel.profPropertyDescriptions[prop.id]		
			descText = descText+"    "+desc+"\n"		
			addPropertyDescription(isAdvantage,desc)
		
	#setDescriptionText(descText)
	setDescriptionText("Properties")
			

func displayReady():
	proficiencyNameLabel.text = "Ready!"
	
	
	
	var majorClass1 = profDataModel.getMajorProficiency(prof1MajorClassIxSelect)
	var majorClass2 = profDataModel.getMajorProficiency(prof2MajorClassIxSelect)	
		
		
	#updateMinorClassSlotVisibility(slotIx) 
	var minorProfs = profDataModel.getMinorProficiencies(prof1MajorClassIxSelect,true)


	#both slots not highlighted
	var slot = minorClassSlots[0]	
	var hightlightedBgd = slot.get_node("background2")
	hightlightedBgd.visible = false		
	slot = minorClassSlots[1]		
	hightlightedBgd = slot.get_node("background2")
	hightlightedBgd.visible = false
	
	

	#$"minor-class-slots/slot1/line".modulate = advantageTint
	$"minor-class-slots/slot1/border".modulate = advantageTint
	#$"minor-class-slots/slot2/line".modulate = disadvantageTint
	$"minor-class-slots/slot2/border".modulate = disadvantageTint
	
	
	$"minor-class-slots/slot1/line".visible = false
	
	$"minor-class-slots/slot2/line".visible = false
	
	
	updateMinorClassSlotVisibility(2) 
			 
	setMinorClassSlotTexture(0,minorProf1.icon)
	setMinorClassSlotTexture(1,minorProf2.icon)			
	
	clearPropertyList()
	if prof1MajorClassIxSelect == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
		profDescriptionLabel.text="An all around average build."		
	else:
		
		var descText = "Strenths: \n"

		if minorProf1.goodProperties.size() == 0:
			descText = descText+"    > None\n"
				
			addPropertyDescription(true,"None")
		else:
				
			for prop in minorProf1.goodProperties:
				
				var desc = profDataModel.getProficiencyPropertyDescription(prop.id)
		
				descText = descText+"    > "+desc+"\n"
				addPropertyDescription(true,desc)
		
		if minorProf2.badProperties.size() == 0:
			descText = descText+"    > None\n"	
			addPropertyDescription(false,"None")	
		else:
				
			descText = descText+"Weaknesses: \n" 
			for prop in minorProf2.badProperties:
				
				var desc = profDataModel.getProficiencyPropertyDescription(prop.id)
		
				descText = descText+"    > "+desc+"\n"
				addPropertyDescription(false,desc)
			
		#setDescriptionText(descText)
		setDescriptionText("Properties")
		
		
			
func updateMajorProfText(majorClassProf,isAdvantage):
					
	#update the name of major proff
	
	var majorClass = profDataModel.getMajorProficiency(majorClassProf)
	setProficiencyName(majorClass.profName)

	setDescriptionText(majorClass.getDescription(isAdvantage))
	
					

func makeRandomChoice():
	
	if state == State.MAJOR_CLASS_FIRST_SELECTION:
		#select a random major class
		prof1MajorClassIxSelect = rng.randi_range(0,NUMBER_MAJOR_CLASSES-1)
		
			
		heldDirInput= dinputReverseMap[prof1MajorClassIxSelect] #emulate a directional input
	
		#we also chose the initial minor prof selected (instead of first one)
		#randomly chosen
		
		changeState(State.MINOR_CLASS_FIRST_SELECTION)
		
		var isAdvantage = true
		var minorProfs = profDataModel.getMinorProficiencies(prof1MajorClassIxSelect,isAdvantage)
		
		var minorProfIx = rng.randi_range(0,minorProfs.size()-1)
		minorProf1 = minorProfs[minorProfIx]
		prof1MinorClassIxSelect = minorProfIx

		updateMinorProfInfo(prof1MajorClassIxSelect,isAdvantage,minorProfIx)
		
		
		
	
		
		
		#updateMinorProfInfo(prof1MajorClassIxSelect,true,0)
	elif state == State.MINOR_CLASS_FIRST_SELECTION:	
		#same as just confirming the selection, since already randomly chosen from 
		#major selection to minor selection

		
		changeState(State.MAJOR_CLASS_SECOND_SELECTION)
	elif state == State.MAJOR_CLASS_SECOND_SELECTION:	
		#select a random major class
		prof2MajorClassIxSelect = rng.randi_range(0,NUMBER_MAJOR_CLASSES-1)
		
		#keep choosing until we get a valid choice
		while not isMajorClassSelectable(prof2MajorClassIxSelect):
			prof2MajorClassIxSelect = rng.randi_range(0,NUMBER_MAJOR_CLASSES-1)
			
		heldDirInput= dinputReverseMap[prof2MajorClassIxSelect] #emulate a directional input

		#dsiplay major class text description and name
		#updateMajorProfText(prof2MajorClassIxSelect,true)
		changeState(State.MINOR_CLASS_SECOND_SELECTION)

				
		var isAdvantage = false
		var minorProfs = profDataModel.getMinorProficiencies(prof2MajorClassIxSelect,isAdvantage)
		
		var minorProfIx = rng.randi_range(0,minorProfs.size()-1)
		minorProf2 = minorProfs[minorProfIx]
		prof2MinorClassIxSelect = minorProfIx

		updateMinorProfInfo(prof2MajorClassIxSelect,isAdvantage,minorProfIx)
		
		
		
	elif state == State.MINOR_CLASS_SECOND_SELECTION:	
	
		#same as just confirming the selection, since already randomly chosen from 
		#major selection to minor selection
		
		changeState(State.SELECTION_FINISHED)		 
	elif state == State.SELECTION_FINISHED:	
		pass
		

func addPropertyDescription(isAdvantageFlag,descText):
	
	var propertyDescription = propertyDescriptionResource.instance()
	
	
	#create a row describing proficiency
	propertiesList.add_child(propertyDescription)
	
	#propertyDescription.propertyLabel.margin_right = propertyDescription.propertyLabel.margin_right * 1.2
	#var textContainer = propertyDescription.get_node("text-container")
	#textContainer.rect_size.x = textContainer.rect_size.x* 1.2
	propertyDescription.propertyLabel.rect_min_size.x = propertyDescription.propertyLabel.rect_min_size.x* 1.3
	propertyDescription.propertyLabel.rect_size.x = propertyDescription.propertyLabel.rect_size.x* 1.3
	
	var font = propertyDescription.propertyLabel.get("custom_fonts/font")
	font.size = 21
	
	
	propertyDescription.setDescription(descText)
	propertyDescription.setBullet(isAdvantageFlag)
	
func clearPropertyList():
	var childs = []
	for c in propertiesList.get_children():
		childs.append(c)
		
	for c in childs:
		propertiesList.remove_child(c)
		c.queue_free()
	
func _physics_process(delta):
	
	var pressingLeft = false
	var pressingRight = false
	var pressingDown = false
	var pressingUp = false
	
	if inputDeviceId== null:
		return 
		
	pressingLeft = Input.is_action_just_pressed(inputDeviceId+"_LEFT") or  Input.is_action_pressed(inputDeviceId+"_LEFT")
	pressingRight = Input.is_action_just_pressed(inputDeviceId+"_RIGHT") or  Input.is_action_pressed(inputDeviceId+"_RIGHT")
	pressingUp = Input.is_action_just_pressed(inputDeviceId+"_UP") or  Input.is_action_pressed(inputDeviceId+"_UP")
	pressingDown = Input.is_action_just_pressed(inputDeviceId+"_DOWN") or  Input.is_action_pressed(inputDeviceId+"_DOWN")

	var di= GLOBALS.parseDirectionalInput(pressingLeft,pressingRight,pressingDown,pressingUp)
	
	if state == State.MAJOR_CLASS_FIRST_SELECTION:
		var majorClassProf = majorProfMap[di]
		
		#changed the direction player is holding?
		if heldDirInput != di:
			unselectSlot(heldDirInput) #un highlight previous selection
			
			
			
			heldDirInput=di
			if heldDirInput == GLOBALS.DirectionalInput.UP or heldDirInput == GLOBALS.DirectionalInput.DOWN:
				#not major prof selected
				updateNoSelectionDisplayedText()				
			else:
				
				soundPlayer.playSound(ITEM_SELECT_SOUND_IX)
				
				#highlinght slot player is selection via directional input
				selectSlot(di)
				
				#dsiplay major class text description and name
				updateMajorProfText(majorClassProf,true)
				
		
		if Input.is_action_just_pressed(inputDeviceId+"_A"):
			
			if heldDirInput == GLOBALS.DirectionalInput.UP or heldDirInput == GLOBALS.DirectionalInput.DOWN:
				invalidOptionSoundPlayer.playSound(INVALID_SELECTION_SOUND_IX)
				return 
		
			
			var majorClass = profDataModel.getMajorProficiency(majorClassProf)
			
#			if  majorClassProf==GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
				
				#prof1MajorClassIxSelect=GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST
				#prof2MajorClassIxSelect=GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST								
				#minorProf1=null
				#minorProf2=null
				#changeState(State.SELECTION_FINISHED)
				
		
			#else:
			prof1MajorClassIxSelect= majorProfMap[di]
			changeState(State.MINOR_CLASS_FIRST_SELECTION)
				
				
		elif Input.is_action_just_pressed(inputDeviceId+"_X"):
			makeRandomChoice()		
				
	elif state == State.MINOR_CLASS_FIRST_SELECTION:	
		var isAdvantage = true
		
		#players is selecting between the two (or 1) choice of minor profs
		if pressingLeft:
			
			updateMinorProfInfo(prof1MajorClassIxSelect,isAdvantage,0)
			
			#holding left means first minor prof selected
			var minorProfs = profDataModel.getMinorProficiencies(prof1MajorClassIxSelect,true)
			
			prof1MinorClassIxSelect = 0%minorProfs.size()
			var newMinorProf=minorProfs[prof1MinorClassIxSelect]
			
			#new choice?
			if minorProf1!=newMinorProf:
				soundPlayer.playSound(ITEM_SELECT_SOUND_IX)
				
			minorProf1 = newMinorProf	
			
		elif pressingRight:
			updateMinorProfInfo(prof1MajorClassIxSelect,isAdvantage,1)
			
			#holding right means 2nd minor prof selected
			var minorProfs = profDataModel.getMinorProficiencies(prof1MajorClassIxSelect,true)
			
			prof1MinorClassIxSelect=1%minorProfs.size()
			var newMinorProf =minorProfs[prof1MinorClassIxSelect]
			
			#new choice?
			if minorProf1!=newMinorProf:
				soundPlayer.playSound(ITEM_SELECT_SOUND_IX)
				
			minorProf1 = newMinorProf	
			
		if Input.is_action_just_pressed(inputDeviceId+"_B"):
			changeState(State.MAJOR_CLASS_FIRST_SELECTION)
			

		elif Input.is_action_just_pressed(inputDeviceId+"_A"):
			changeState(State.MAJOR_CLASS_SECOND_SELECTION)
		elif Input.is_action_just_pressed(inputDeviceId+"_X"):
			makeRandomChoice()
			
			
	elif state == State.MAJOR_CLASS_SECOND_SELECTION:
		var majorClassProf = majorProfMap[di]
		
		#changed the direction player is holding?
		if heldDirInput != di:
			unselectSlot(heldDirInput) #un highlight previous selection
			
			heldDirInput=di
			if heldDirInput == GLOBALS.DirectionalInput.UP or heldDirInput == GLOBALS.DirectionalInput.DOWN:
				#not major prof selected
				updateNoSelectionDisplayedText()
				
			else:
				
				#get class we trying to select
				
				#check if the choice of major class is acdceptable (can't pick same major class twice, for example)
				if isMajorClassSelectable(majorClassProf):
					
					soundPlayer.playSound(ITEM_SELECT_SOUND_IX)
					
					#highlingt select slot player is selecting via diractional input
					selectSlot(di)
					
					#dsiplay major class text description and name
													
					updateMajorProfText(majorClassProf,false)
				else:
					
					#can't select this prof. back to default text
					#not major prof selected
					updateNoSelectionDisplayedText()
					
					
		if Input.is_action_just_pressed(inputDeviceId+"_B"):
			changeState(State.MAJOR_CLASS_FIRST_SELECTION)
		
		elif Input.is_action_just_pressed(inputDeviceId+"_A"):
			if heldDirInput == GLOBALS.DirectionalInput.UP or heldDirInput == GLOBALS.DirectionalInput.DOWN:
				invalidOptionSoundPlayer.playSound(INVALID_SELECTION_SOUND_IX)
				return 
				
			#check if the choice of major class is acdceptable (can't pick same major class twice, for example)
			if not isMajorClassSelectable(majorClassProf):
				invalidOptionSoundPlayer.playSound(INVALID_SELECTION_SOUND_IX)
				return
			
			prof2MajorClassIxSelect= majorProfMap[di]					
			changeState(State.MINOR_CLASS_SECOND_SELECTION)
		elif Input.is_action_just_pressed(inputDeviceId+"_X"):
			makeRandomChoice()	
	elif state == State.MINOR_CLASS_SECOND_SELECTION:		
		var isAdvantage = false
		if pressingLeft:
			updateMinorProfInfo(prof2MajorClassIxSelect,isAdvantage,0)			
			
			#holding left means 1st minor prof selected
			var minorProfs = profDataModel.getMinorProficiencies(prof2MajorClassIxSelect,isAdvantage)
			
			prof2MinorClassIxSelect=0%minorProfs.size()
			
			
			var newMinorProf =minorProfs[prof2MinorClassIxSelect]
			
			#new choice?
			if minorProf2!=newMinorProf:
				soundPlayer.playSound(ITEM_SELECT_SOUND_IX)
				
			minorProf2=newMinorProf
		elif pressingRight:
			updateMinorProfInfo(prof2MajorClassIxSelect,isAdvantage,1)
			
			#holding right means 2nd minor prof selected
			var minorProfs = profDataModel.getMinorProficiencies(prof2MajorClassIxSelect,isAdvantage)
			
			prof2MinorClassIxSelect=1%minorProfs.size()
			var newMinorProf=minorProfs[prof2MinorClassIxSelect]
			
			#new choice?
			if minorProf2!=newMinorProf:
				soundPlayer.playSound(ITEM_SELECT_SOUND_IX)
			
			minorProf2=newMinorProf
			
		if Input.is_action_just_pressed(inputDeviceId+"_B"):
			changeState(State.MAJOR_CLASS_SECOND_SELECTION)
		
			
		elif Input.is_action_just_pressed(inputDeviceId+"_A"):
			
			changeState(State.SELECTION_FINISHED)			
		elif Input.is_action_just_pressed(inputDeviceId+"_X"):
			makeRandomChoice()
		
	elif state == State.SELECTION_FINISHED:	
		if Input.is_action_just_pressed(inputDeviceId+"_A"):
			#allow spam the confirmation
			soundPlayer.playSound(ITEM_CONFIRMATION_SOUND_IX)
			
			if not signaledReadyFlag:
				signaledReadyFlag=true
				emit_signal("proficiencies_selection_confirmed",prof1MajorClassIxSelect,prof1MinorClassIxSelect,prof2MajorClassIxSelect,prof2MinorClassIxSelect)
		elif Input.is_action_just_pressed(inputDeviceId+"_B"):
									
			#if prof1MajorClassIxSelect == GLOBALS.PROFICIENCY_MAJOR_CLASS_GENERALIST:
			#	changeState(State.MAJOR_CLASS_FIRST_SELECTION)
			#else:
			changeState(State.MAJOR_CLASS_SECOND_SELECTION)				
