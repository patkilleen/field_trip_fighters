extends HBoxContainer
const propertyDescriptionResource = preload("res://interface/new-prof-select/profPropertyRow.tscn")

export (Texture) var activePropertyNameBgdTexture = null
export (Texture) var disabledPropertyNameBgdTexture = null

var propertiesList = null

var minorClassNameLabel = null
var minorClassNameDisabledLabel = null

var minorClassNameBgd = null

var minorClassIcon = null
var propertyDescList =[]

var iconLinkingBar = null

var pencilCursor = null 
var pencilCursorP1 = null 
var pencilCursorP2 = null 
func _ready():
	
	propertiesList = $"container/ProficiencyMinorClassDescription/propertyList"
	minorClassNameLabel= $"container/ProficiencyMinorClassDescription/propertyList/minor-class-text-bgd/minorProfNameContainer/proficiencyName"
	minorClassNameDisabledLabel=$"container/ProficiencyMinorClassDescription/propertyList/minor-class-text-bgd/minorProfNameContainer/disabledProficiencyName"
	
	minorClassNameBgd=$"container/ProficiencyMinorClassDescription/propertyList/minor-class-text-bgd"
	minorClassIcon=$"container/ProficiencyMinorClassDescription/minoclassProfIcon"
	
	pencilCursorP1 = $"container/ProficiencyMinorClassDescription/propertyList/minor-class-text-bgd/p1pencil"
	pencilCursorP2 = $"container/ProficiencyMinorClassDescription/propertyList/minor-class-text-bgd/p2pencil"
	
	iconLinkingBar = $"container/ProficiencyMinorClassDescription/minoclassProfIcon/iconLinkingBar"
	enable()
	pencilCursorP1.visible = false
	pencilCursorP2.visible = false
	minorClassNameLabel.visible = true
	minorClassNameDisabledLabel.visible = false
	
	#by default the linking icon bar is hidden
	hideLinkingBar()

func setPencilSelectionVisibility(player1Flag,visibleFlag):
	if player1Flag:
		pencilCursorP1.visible = visibleFlag
	else:
		pencilCursorP2.visible = visibleFlag
func enable():
	#make the minor class name appear vibrant  
	minorClassNameLabel.visible = true
	minorClassNameDisabledLabel.visible = false

	minorClassIcon.modulate.a = 1
	propertiesList.modulate.a = 1
	#make the minor class name have nice background
	minorClassNameBgd.texture=activePropertyNameBgdTexture
	
	#iterate over all the properties and make sure they are visible
	#for row in propertyDescList:
	#	row.visible = true
		
	#pencilCursor.visible = true
func disable():
	
	#pencilCursor.visible = false
	#make the minor class name appear gray 
	minorClassNameLabel.visible = false
	minorClassNameDisabledLabel.visible = true
	
	propertiesList.modulate.a = 0.25
	minorClassIcon.modulate.a = 0.25
	#make the minor class name have dull inative gray background
	minorClassNameBgd.texture=disabledPropertyNameBgdTexture
	
	#iterate over all the properties and make sure they are hidden
	#for row in propertyDescList:
	#	row.visible = false

func setMinorClassProficiencyIcon(texture):
	minorClassIcon.texture=texture

func getMinorClassProficiencyIcon():
	return minorClassIcon.texture
		
	
func setMinorClassProficiencyName(text):
	minorClassNameLabel.text=text
	minorClassNameDisabledLabel.text = text

func getMinorClassProficiencyName():
	return minorClassNameLabel.text
	
	
		
	
func addPropertyDescription(isAdvantageFlag,descText):
	
	var propertyDescription = propertyDescriptionResource.instance()
	
	#create a row describing proficiency
	propertiesList.add_child(propertyDescription)
	
	propertyDescription.setDescription(descText)
	propertyDescription.setBullet(isAdvantageFlag)
	
	#keep track of the rows added for later access
	propertyDescList.append(propertyDescription)
	
	#make sure the bar on left linking icons expands accordingly
	updateIconLinkingBarSize()
	
	
func updateIconLinkingBarSize():
	#iconLinkingBar.rect_size.y = self.rect_size.y
	pass
	
func hideLinkingBar():
	iconLinkingBar.visible = false
	
func showLinkingBar():
	#iconLinkingBar.visible = true
	iconLinkingBar.visible = false