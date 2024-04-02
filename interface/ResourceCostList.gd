extends Control

var GLOBALS = preload("res://Globals.gd")

var ripostCostLabel=null
var counterRipostCostLabel=null
var techCostLabel=null
var pushBlockCostLabel=null
var autoAbilityCancelCostLabel=null
var autoRipostCancelCostLabel=null
var abilityCancelCostLabel =null

var ripostModLabel=null
var counterRipostModLabel=null
var techModLabel=null
var pushBlockModLabel=null
var autoAbilityCancelModLabel=null
var autoRipostCancelModLabel=null
var abilityCancelModLabel=null



var negativeModLabelTemplate = null
var positiveModLabelTemplate = null
var neutralModLabelTemplate = null



var settings = null
func _ready():
	
	ripostCostLabel=$GridContainer/HBoxContainer2/ripostCost
	counterRipostCostLabel=$GridContainer/HBoxContainer3/counterRipostCost
	pushBlockCostLabel=$GridContainer/HBoxContainer4/pushBlockCost
	autoRipostCancelCostLabel=$GridContainer/HBoxContainer5/autoRipostCost
	autoAbilityCancelCostLabel=$GridContainer/HBoxContainer6/autoAbilityCancelCost
	techCostLabel=$GridContainer/HBoxContainer7/techCost
	abilityCancelCostLabel = $GridContainer/HBoxContainer8/abilityCancelCost
	
	ripostModLabel=$GridContainer/HBoxContainer2/ripostMod
	counterRipostModLabel=$GridContainer/HBoxContainer3/counterRipostMod
	techModLabel=$GridContainer/HBoxContainer7/techMod
	pushBlockModLabel=$GridContainer/HBoxContainer4/pushBlockMod
	autoAbilityCancelModLabel=$GridContainer/HBoxContainer6/autoAbilityCancelMod
	autoRipostCancelModLabel=$GridContainer/HBoxContainer5/autoRipostMod
	abilityCancelModLabel = $GridContainer/HBoxContainer8/abilityCancelMod
	
	negativeModLabelTemplate = $negativeModTemplate
	positiveModLabelTemplate = $positiveModTemplate
	neutralModLabelTemplate= $neutralModTemplate
	#gridContainer.rect_scale =  gridContainer.rect_scale * 0.6

func init(_settings):
	settings = _settings

func applyProfLabelColor(targetLabel,delta):
	
	if delta > 0:
		targetLabel.set("custom_colors/font_color",positiveModLabelTemplate.get("custom_colors/font_color"))
	elif delta < 0:
		targetLabel.set("custom_colors/font_color",negativeModLabelTemplate.get("custom_colors/font_color"))
	else:
		targetLabel.set("custom_colors/font_color",neutralModLabelTemplate.get("custom_colors/font_color"))
func populateGridWithAbilityBasedCmdInfo(_playerController):
	
	if _playerController !=null:
		ripostCostLabel.text = str(_playerController.ripostingAbilityBarCost)
		counterRipostCostLabel.text =str(_playerController.counterRipostingAbilityBarCost)
		pushBlockCostLabel.text =str(_playerController.pushBlockCost)
		techCostLabel.text=str(_playerController.techAbilityBarCost)
		
		autoRipostCancelCostLabel.text=str(_playerController.autoRipostAbilityBarCost)
		
		var baseAbilityBarCost = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.BASE_ABILITY_CANCEL_COST_KEY))#0
		var playerProfBarCostMod =_playerController.playerState.profAbilityBarCostMod
		var totalCost = playerProfBarCostMod+baseAbilityBarCost
		abilityCancelCostLabel.text=str(totalCost)
		
		#ability cancel base cost +  autoAbilityCancelCost mod
		autoAbilityCancelCostLabel.text =str(_playerController.autoAbilityCancelBaseCost+baseAbilityBarCost)
		
		parseAndSetCostModLabel(ripostModLabel,float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.RIPOSTING_ABILITY_BAR_COST_NOPROF_KEY)),_playerController.ripostingAbilityBarCost)
		parseAndSetCostModLabel(counterRipostModLabel,float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.COUNTER_RIPOSTING_ABILITY_BAR_COST_NOPROF_KEY)),_playerController.counterRipostingAbilityBarCost)
		parseAndSetCostModLabel(pushBlockModLabel,float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.PUSH_BLOCK_BAR_COST_NO_PROF_KEY)),_playerController.pushBlockCost)
		parseAndSetCostModLabel(techModLabel,float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.TECH_ABILITY_BAR_COST_NO_PROF_KEY)),_playerController.techAbilityBarCost)
		parseAndSetCostModLabel(autoAbilityCancelModLabel,float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.AUTO_ABILITY_CANCEL_COST_NOPROF_KEY)),_playerController.autoAbilityCancelBaseCost)
		parseAndSetCostModLabel(autoRipostCancelModLabel,float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.AUTO_RIPOST_BAR_COST_NO_PROF_KEY)),_playerController.autoRipostAbilityBarCost)
		parseAndSetCostModLabel(abilityCancelModLabel,float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.ABILITY_BAR_CANCEL_COST_MOD_NOPROF_KEY)),playerProfBarCostMod)
		
		
		visible= true
	else:
		visible= false		

func parseAndSetCostModLabel(targetLabel,baseCost,playerCost):
	var delta = baseCost-playerCost
	applyProfLabelColor(targetLabel,delta)
	targetLabel.text = "("+str(-1*delta)+")" # times -1,  since bigger numbers is worse, since things costing more is bad
	