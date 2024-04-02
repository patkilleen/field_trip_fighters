extends Control

var GLOBALS = preload("res://Globals.gd")

var ripostDefaultLabel=null
var counterRipostDefaultLabel=null
var techDefaultLabel=null
var pushBlockDefaultLabel=null
var autoAbilityCancelDefaultLabel=null
var autoRipostCancelDefaultLabel=null
var abilityCancelDefaultLabel =null
var airAbilityCancelDefaultLabel = null
var provokeGuardBreakDefaultLabel=null
var	magicSeriesDefaultLabel=null
var	airMagicSeriesDefaultLabel=null
var	grabCooldownDefaultLabel=null
var	airGrabCooldownDefaultLabel=null
	

var ripostActualLabel=null
var counterRipostActualLabel=null
var techActualLabel=null
var pushBlockActualLabel=null
var autoAbilityCancelActualLabel=null
var autoRipostCancelActualLabel=null
var abilityCancelActualLabel =null
var airAbilityCancelActualLabel = null
var provokeGuardBreakActualLabel=null
var	magicSeriesActualLabel=null
var	airMagicSeriesActualLabel=null
var	grabCooldownActualLabel=null
var	airGrabCooldownActualLabel=null


var negativeActualLabelTemplate = null
var positiveActualLabelTemplate = null
var neutralActualLabelTemplate = null



var settings = null
func _ready():
	
	#gridContainer.rect_scale =  gridContainer.rect_scale * 0.6
	ripostDefaultLabel=$Rows/ripost/default
	counterRipostDefaultLabel=$Rows/counterRipost/default
	autoRipostCancelDefaultLabel=$Rows/autoRipost/default
	techDefaultLabel=$Rows/tech/default
	pushBlockDefaultLabel=$"Rows/push-block/default"
	abilityCancelDefaultLabel = $Rows/abilityCancel/default
	airAbilityCancelDefaultLabel = $Rows/airAbilityCancel/default
	autoAbilityCancelDefaultLabel=$Rows/autoAbilityCancel/default
	provokeGuardBreakDefaultLabel=$Rows/provokeGuardBreak/default
	magicSeriesDefaultLabel=$Rows/magicSeries/default
	airMagicSeriesDefaultLabel=$"Rows/airborne-magicSeries/default"
	grabCooldownDefaultLabel=$"Rows/grab/default"
	airGrabCooldownDefaultLabel=$"Rows/airGrab/default"
	
	
	ripostActualLabel=$Rows/ripost/actual
	counterRipostActualLabel=$Rows/counterRipost/actual
	autoRipostCancelActualLabel=$Rows/autoRipost/actual
	techActualLabel=$Rows/tech/actual
	pushBlockActualLabel=$"Rows/push-block/actual"
	abilityCancelActualLabel = $Rows/abilityCancel/actual
	airAbilityCancelActualLabel = $Rows/airAbilityCancel/actual
	autoAbilityCancelActualLabel=$Rows/autoAbilityCancel/actual
	provokeGuardBreakActualLabel=$Rows/provokeGuardBreak/actual
	magicSeriesActualLabel=$Rows/magicSeries/actual
	airMagicSeriesActualLabel=$"Rows/airborne-magicSeries/actual"
	grabCooldownActualLabel=$"Rows/grab/actual"
	airGrabCooldownActualLabel=$"Rows/airGrab/actual"
	
	negativeActualLabelTemplate = $negativeModTemplate
	positiveActualLabelTemplate = $positiveModTemplate
	neutralActualLabelTemplate= $neutralModTemplate
func init(_settings):
	settings = _settings

	
func applyProfLabelColor(targetLabel,delta, smallerBetterFlag):
	
	if smallerBetterFlag:
		if delta > 0:
			targetLabel.set("custom_colors/font_color",positiveActualLabelTemplate.get("custom_colors/font_color"))
		elif delta < 0:
			targetLabel.set("custom_colors/font_color",negativeActualLabelTemplate.get("custom_colors/font_color"))
		else:
			targetLabel.set("custom_colors/font_color",neutralActualLabelTemplate.get("custom_colors/font_color"))
	else:
		if delta < 0:
			targetLabel.set("custom_colors/font_color",positiveActualLabelTemplate.get("custom_colors/font_color"))
		elif delta > 0:
			targetLabel.set("custom_colors/font_color",negativeActualLabelTemplate.get("custom_colors/font_color"))
		else:
			targetLabel.set("custom_colors/font_color",neutralActualLabelTemplate.get("custom_colors/font_color"))
func populateGridWithAbilityBasedCmdInfo(_playerController):
	
	if _playerController !=null:
		#ripostDefaultLabel.text = str(_playerController.ripostingAbilityBarCost)
		#counterRipostDefaultLabel.text =str(_playerController.counterRipostingAbilityBarCost)
		#pushBlockDefaultLabel.text =str(_playerController.pushBlockCost)
		#techDefaultLabel.text=str(_playerController.techAbilityBarCost)
		
		#autoRipostCancelDefaultLabel.text=str(_playerController.autoRipostAbilityBarCost)
		
		
		
		#abilityCancelDefaultLabel.text=str(totalCost)
		
		
		
		parseAndSetCostActualLabel(ripostDefaultLabel,ripostActualLabel,"-",float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.RIPOSTING_ABILITY_BAR_COST_NOPROF_KEY)),_playerController.ripostingAbilityBarCost,true)
		parseAndSetCostActualLabel(counterRipostDefaultLabel,counterRipostActualLabel,"-",float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.COUNTER_RIPOSTING_ABILITY_BAR_COST_NOPROF_KEY)),_playerController.counterRipostingAbilityBarCost,true)
		parseAndSetCostActualLabel(autoRipostCancelDefaultLabel,autoRipostCancelActualLabel,"-",float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.AUTO_RIPOST_BAR_COST_NO_PROF_KEY)),_playerController.autoRipostAbilityBarCost,true)
		parseAndSetCostActualLabel(techDefaultLabel,techActualLabel,"-",float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.TECH_ABILITY_BAR_COST_NO_PROF_KEY)),_playerController.techAbilityBarCost,true)
		parseAndSetCostActualLabel(pushBlockDefaultLabel,pushBlockActualLabel,"-",float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.PUSH_BLOCK_BAR_COST_NO_PROF_KEY)),_playerController.pushBlockCost,true)
		var baseAbilityBarCost = int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.BASE_ABILITY_CANCEL_COST_KEY))#0
		var playerProfBarCostMod =_playerController.playerState.profAbilityBarCostMod
		var totalCost = playerProfBarCostMod+baseAbilityBarCost
		parseAndSetCostActualLabel(abilityCancelDefaultLabel,abilityCancelActualLabel,"-",baseAbilityBarCost,totalCost,true)		
		parseAndSetCostActualLabel(airAbilityCancelDefaultLabel,airAbilityCancelActualLabel,"-",baseAbilityBarCost,baseAbilityBarCost+_playerController.airAbilityCancelCostInChunksTax,true)		
		parseAndSetCostActualLabel(autoAbilityCancelDefaultLabel,autoAbilityCancelActualLabel,"-",float(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.AUTO_ABILITY_CANCEL_COST_NOPROF_KEY)),_playerController.autoAbilityCancelBaseCost,true)		
		parseAndSetCostActualLabel(provokeGuardBreakDefaultLabel,provokeGuardBreakActualLabel,"+",float(settings.getValue(settings.TEMP_USER_SETTINGS_SECTION,settings.BAR_GAIN_FROM_GUARD_BREAK_KEY)),_playerController.opponentPlayerController.computeBarFeedFromABrokenGuard(),false)		
		
		var magicSeriesBarGainInChunks =_playerController.numAbChunksGainOnComboLvl
		var defaultMagicSeriesBarGain=int(settings.getValue(settings.INTERNAL_SETTINGS_SECTION,settings.COMBO_LEVEL_ABILITY_INCREASE_NOPROF_KEY))
		parseAndSetCostActualLabel(magicSeriesDefaultLabel,magicSeriesActualLabel,"+",defaultMagicSeriesBarGain,magicSeriesBarGainInChunks,false)			
					
		var magicSeriesBarGainInChunksInAir = magicSeriesBarGainInChunks+_playerController.additionalNumChunksGainMagicSeriesInAir
		parseAndSetCostActualLabel(airMagicSeriesDefaultLabel,airMagicSeriesActualLabel,"+",defaultMagicSeriesBarGain,magicSeriesBarGainInChunksInAir,false)			
		
		var grabCooldown =float(settings.getValue(settings.TEMP_USER_SETTINGS_SECTION,settings.GRAB_COOLDOWN_DURATION_SECONDS_KEY))
		parseAndSetCostActualLabel(grabCooldownDefaultLabel,grabCooldownActualLabel," sec",grabCooldown,_playerController.grabCooldownTime ,true,false)			
	
		parseAndSetCostActualLabel(airGrabCooldownDefaultLabel,airGrabCooldownActualLabel," sec",grabCooldown,_playerController.additionalCooldownToAirGrab+_playerController.grabCooldownTime ,true,false)			
			
		
		visible= true
	else:
		visible= false		

func parseAndSetCostActualLabel(defaultLabel,actualLabel,symboleStr,baseCost,playerCost,smallerBetterFlag,prefixSymbolFlag=true):
	
	
	#symbolStr = '+' or '-' or ''
	if prefixSymbolFlag:
		
		if symboleStr == "-" and playerCost< 0:
			symboleStr="" #don't add the '-' twice
		defaultLabel.text = symboleStr+str(baseCost)
		actualLabel.text = symboleStr+str(playerCost)
	else:
		defaultLabel.text = str(baseCost)+symboleStr
		actualLabel.text = str(playerCost)+symboleStr
		
	var delta = baseCost-playerCost
	applyProfLabelColor(actualLabel,delta,smallerBetterFlag)
	#targetLabel.text = "("+str(-1*delta)+")" # times -1,  since bigger numbers is worse, since things costing more is bad
	