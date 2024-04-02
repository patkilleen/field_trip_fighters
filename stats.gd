extends Node

const GLOBALS = preload("res://Globals.gd")

#TODO: add style points partition of stats
enum VictoryType{
	WIN,
	LOSS,
	DRAW
}
const HERO_STATS_TYPE = 0
const PLAYER_NAME_STATS_TYPE = 1

const STATS_FILE_PATH = "user://stats.cfg" 

#the section containing all the hero sections containing their stats
const HERO_SECTIONS_SID = "HERO_SECTIONS_SID"

#const KEN_KID = "ken"
#const MARTH_KID = "marth"
#const FALCON_KID = "falcon"
#const SAMUS_KID = "samus"
#const GLOVE_KID = "glove"
#const HAT_KID = "hat"
#const BELT_KID = "belt"
#const MICROPHONE_KID = "microphone"

const KEN_STATS_SECTION_SID = "KEN_STATS_SECTION_SID"
const MARTH_STATS_SECTION_SID = "MARTH_STATS_SECTION_SID"
const FALCON_STATS_SECTION_SID = "FALCON_STATS_SECTION_SID"
const SAMUS_STATS_SECTION_SID = "SAMUS_STATS_SECTION_SID"
const GLOVE_STATS_SECTION_SID = "GLOVE_STATS_SECTION_SID"
const HAT_STATS_SECTION_SID = "HAT_STATS_SECTION_SID"
const BELT_STATS_SECTION_SID = "BELT_STATS_SECTION_SID"
const WHISTLE_STATS_SECTION_SID = "WHISTLE_STATS_SECTION_SID"
const MICROPHONE_STATS_SECTION_SID = "MICROPHONE_STATS_SECTION_SID"


#below 2 should be same length and use same hero indices
#const HERO_KIDS = [KEN_KID,MARTH_KID,FALCON_KID,SAMUS_KID,GLOVE_KID,HAT_KID,BELT_KID,MICROPHONE_KID]
const HERO_KIDS = [GLOBALS.MICROPHONE_HERO_NAME,GLOBALS.BELT_HERO_NAME,GLOBALS.GLOVE_HERO_NAME,GLOBALS.HAT_HERO_NAME,GLOBALS.WHISTLE_HERO_NAME]

const HERO_SECTIONS = [KEN_STATS_SECTION_SID,MARTH_STATS_SECTION_SID,FALCON_STATS_SECTION_SID,SAMUS_STATS_SECTION_SID,GLOVE_STATS_SECTION_SID,HAT_STATS_SECTION_SID,BELT_STATS_SECTION_SID,MICROPHONE_STATS_SECTION_SID,WHISTLE_STATS_SECTION_SID]

const heroSectionIdMap={
	GLOBALS.MICROPHONE_HERO_NAME:MICROPHONE_STATS_SECTION_SID,
	GLOBALS.BELT_HERO_NAME:BELT_STATS_SECTION_SID,
	GLOBALS.GLOVE_HERO_NAME:GLOVE_STATS_SECTION_SID,
	GLOBALS.HAT_HERO_NAME:HAT_STATS_SECTION_SID,
	GLOBALS.WHISTLE_HERO_NAME:WHISTLE_STATS_SECTION_SID
	
}
#example entry: <HERO_SECTIONS_SID,Ken,KEN_STATS_SECTION_SID>
#--> <KEN_STATS_SECTION_SID,maxBestComboDamage,1234>

#ENd sections for hero stats sections


const PLAYER_NAME_SID = "PLAYER_NAME_SID"


#example name entry: <PLAYER_NAME_SID,l33tsk1llz,l33tsk1llz>

const NUMBER_GAMES_KID = "NUMBER_GAMES_KID" #used to store number of games to compute average and other aggregates


const MAX_PREFIX = "MAX_"
const TOTAL_PREFIX = "TOTAL_"
const AVG_PREFIX = "AVG_"

const STYLE_SID_PREFIX = "STYLE_"

const WIN_COUNT_KID = "WIN_COUNT"
const LOSS_COUNT_KID = "LOSS_COUNT"

const playerStateResource = preload("res://PlayerState.gd")

var playerStateTemplate = null 

#const DEFAULT_VALUE_MAP = [[TEMP_USER_SETTINGS_SECTION,HP_KEY, DEFAULT_HP]]
   
var ioErrorFlag = false

var config = null

func _ready():
	playerStateTemplate = playerStateResource.new()
	pass

#store stats onto disk
func saveStats():
	
	#don't try to save settings if failed to open the file
	#if ioErrorFlag:
	#	print("cannot save settings file, failed to open settings")
	#	return
	if config == null:
		print("cannot save settings file, null config (did you forget to load the settings?)")
		return

	config.save(STATS_FILE_PATH)

#load settings from disk, or load default values upon failur to open file	
#failure to open the file means a new settings file will be created
#whcih will have all default values
func loadStats():
	
	
	var file = File.new( )
	config = ConfigFile.new()
	
	#is the settings file missing?
	if not file.file_exists(STATS_FILE_PATH):
		
		print("stats file '"+STATS_FILE_PATH+"' not found, creating a new one.")
		#create a new default settings file
		file.open(STATS_FILE_PATH, File.WRITE)
		
		#create new empty settings file to write to
		file.close()
		
		#config = createDefaultConfiguration()
			
		#write all the ssettings to the new file
		config.save(STATS_FILE_PATH)
		
	else: # settings file exists
	
		print("loading settings file "+STATS_FILE_PATH)
		#open the settings file
		var err = config.load(STATS_FILE_PATH)
		if err != OK: #something went wrong with the file loading?
			print("error loading settings file " + STATS_FILE_PATH + ", error code "+str(err)+", will used default values and won't be able to save settings.")
			
			#load default values from a script into the config
			config = ConfigFile.new()
			#config = createDefaultConfiguration()
			

#func createDefaultConfiguration():
	
	#create new config object
#	var defaultConfig = ConfigFile.new()
		
#	#create the entries that point to hero stat sections
#	for i in HERO_KIDS.size():
#		var heorkey = HERO_KIDS[i]
#		var heroSection = HERO_SECTIONS[i]
		#value is the section stats of said hero will be stored in
#		defaultConfig.set_value(HERO_SECTIONS_SID,heorkey,heroSection)
		
#		_populateStatsSectionWithEmptyStats(defaultConfig,heroSection)
		#CREATE stat partition for style points stats
#		_populateStatsSectionWithEmptyStats(defaultConfig,STYLE_SID_PREFIX+heroSection)
		
		
#	return defaultConfig


#create a stats section (for a player name or hero info) with empty stats
func populateStatsSectionWithEmptyStats(section):
	_populateStatsSectionWithEmptyStats(config,section)
	
func _populateStatsSectionWithEmptyStats(_config,section):
	
	if _config==null:
		print("warning, can't populate empty stats section, null config")
		return
	
	#number games is 0 to start
	_config.set_value(section,NUMBER_GAMES_KID,0)
	#wins are 0
	_config.set_value(section,WIN_COUNT_KID,0)
	#losses are 0
	_config.set_value(section,LOSS_COUNT_KID,0)
		
	#get relevant properties in player state 
#	var list = playerStateTemplate.getStatsMemberNames()
	var maxMembersList = playerStateTemplate.getMemberNamesToKeepTrackofMaximums()
	
	#add a max, average, and total to all the members of player state we
	#keeping track of
	for member in maxMembersList:
		_config.set_value(section,MAX_PREFIX+member,0.0)
	
	var totalsMembersList = playerStateTemplate.getMemberNamesToKeepTrackofTotals()
	
	#add a max, average, and total to all the members of player state we
	#keeping track of
	for member in totalsMembersList:
		# member that have totals will have their averages shown at display time, not stored
		#_config.set_value(section,AVG_PREFIX+member,0.0) 
		_config.set_value(section,TOTAL_PREFIX+member,0.0)
	
#returns the hero section ids assosiated
#to a given player name. For example, for l33tsk1llz as player name
#could have sections of each hero assosiated to the name as follows (not exactly, but 
#the idea is there):
#> l33tsk1llz_ken_section
#> l33tsk1llz_marth_section
#...
#param: pname, player name
func getPlayerNameHeroSectionIDs(pname):
	
	var sids = []
	
	#genearte the sids dynamically
	for heroSID in HERO_SECTIONS:
		var pNameHeroSID = pname + "_" + heroSID
		sids.append(pNameHeroSID)
	return sids
	
#returns the section id related to hero and player name
#param: pname, player name (e.g., l33tsk1llz)
#param: hero, hero name (e.g., "ken")
func getPlayerNameHeroSectionID(pname,hero):
	var pNameHeroSID  = null
	
	#var heroSID = config.get_value(HERO_SECTIONS_SID,hero)
	var heroSID = heroSectionIdMap[hero]	
	
	pNameHeroSID = pname + "_" + heroSID
	
	return pNameHeroSID

func updateHeroStylePointsStats(hero,playerState,victoryType):
	#var section = config.get_value(HERO_SECTIONS_SID,hero)
	var section =heroSectionIdMap[hero]	
	updateStatsSection(STYLE_SID_PREFIX+section,playerState,victoryType)
	
	pass
func updatePlayerNameStylePointsStats(playerName,hero,playerState,victoryType):
	var section = getPlayerNameHeroSectionID(playerName,hero)
	updateStatsSection(STYLE_SID_PREFIX+section,playerState,victoryType)
	pass
	
func updateHeroStats(hero,playerState,victoryType):
	
	var section =heroSectionIdMap[hero]	
	
	#make sure the section exists before updating the stats.
	if not config.has_section(section):
		
		#create it	 and populate with empty stats
		_populateStatsSectionWithEmptyStats(config,section)
		#CREATE stat partition for style points stats
		_populateStatsSectionWithEmptyStats(config,STYLE_SID_PREFIX+section)
		

	updateStatsSection(section,playerState,victoryType)
	
func updatePlayerNameStats(playerName, hero, playerState,victoryType):
	if playerName == null:
		return	
	
	var section = getPlayerNameHeroSectionID(playerName,hero)

	#make sure the section exists before updating the stats.
	if not config.has_section(section):
		
		#create it	 and populate with empty stats
		_populateStatsSectionWithEmptyStats(config,section)
		#CREATE stat partition for style points stats
		_populateStatsSectionWithEmptyStats(config,STYLE_SID_PREFIX+section)
			
	
	updateStatsSection(section,playerState,victoryType)
	
#updates the current stats with new stats 
func updateStatsSection(section,playerState,victoryType):
	
	
	#make a check for non existing section. if so, create it.
	if config==null:
		print("warning, can't update stats section, null config")
		return
	
	if playerState == null:
		return
	#increment number of games
	incrementValue(section,NUMBER_GAMES_KID)
		
	#count the wins vs loses
	if victoryType == VictoryType.WIN:
		incrementValue(section,WIN_COUNT_KID)
	elif victoryType == VictoryType.LOSS:
		incrementValue(section,LOSS_COUNT_KID)
	else:
		#ignore draws in W/L ratio
		pass
	#get relevant properties in player state 
	#var list = playerStateTemplate.getStatsMemberNames()
	var maxMembersList = playerStateTemplate.getMemberNamesToKeepTrackofMaximums()

	
	
	#update the max of all the members of player state we
	#keeping track of
	for member in maxMembersList:
		
		var oldMaxValue =  config.get_value(section,MAX_PREFIX+member)
		
		#in case we add a new stat to keep track off, assume max is 0
		if oldMaxValue == null:
			oldMaxValue = 0
			
		var memberValue = playerState.get(member)
		
		#compute new max
		var newMax = max(oldMaxValue,memberValue)
		
		#update max in stats
		config.set_value(section,MAX_PREFIX+member,newMax)
		
		
		
	var totalsMembersList = playerStateTemplate.getMemberNamesToKeepTrackofTotals()
	
	var numGamesPlayed = config.get_value(section,NUMBER_GAMES_KID)
	#update the  average, and total of all the members of player state we
	#keeping track of
	for member in totalsMembersList:
		
		var memberValue = playerState.get(member)
		var totalValue =  config.get_value(section,TOTAL_PREFIX+member)
		
		#check for null in case we added a new stat to playerState and
		#stats file isn't up to date 
		if totalValue == null:
			totalValue = 0
		#add to total
		var newTotal = totalValue + memberValue
		
		#update stats
		config.set_value(section,TOTAL_PREFIX+member,newTotal)
		
		
		#compute the new average
		#var newMean = newTotal/numGamesPlayed
		#update stats
		#config.set_value(section,AVG_PREFIX+member,newMean)
		

#will only check max, since total + average aren't not linked to 
#records
#return true when newValue is greater than current record, and false otherwise when the record doesn't exist or record not broken/beaten
#param: hero, the name of hero checking stats of
#param: member, name of playerState property/member we checking for new record
#param: newValue, value to check against current record
func isNewHeroStatRecord(hero,member,newValue):
	
	#var statSection = config.get_value(HERO_SECTIONS_SID,hero)
	var statSection =heroSectionIdMap[hero]	
	
	if statSection == null:
		#print("null hero stat section query: "+hero+", "+member+","+newValue)
		return false
	
	if not config.has_section_key(statSection,MAX_PREFIX+member):
		#print("non existing stat section query: "+str(hero)+", "+str(member)+","+str(newValue))
		return false
		
	var oldValue = config.get_value(statSection,MAX_PREFIX+member)
	
	#stats not tracking this property?
	if oldValue == null:
		return false
	else:
		return newValue > oldValue

#will only check max, since total + average aren't not linked to 
#records
#return true when newValue is greater than current record, and false otherwise when the record doesn't exist or record not broken/beaten
#param: pname, the name of palyer checking stats of
#param: member, name of playerState property/member we checking for new record
#param: newValue, value to check against current record
func isNewPlayerNameHeroStatRecord(pname,hero,member,newValue):
	
	#var statSection = config.get_value(PLAYER_NAME_SID,pname)
	var statSection = getPlayerNameHeroSectionID(pname,hero)
	
	if statSection == null:
		#print("null hero stat section query: "+hero+", "+member+","+newValue)
		return false
	
	if not config.has_section_key(statSection,MAX_PREFIX+member):
		#print("non existing stat section query: "+hero+", "+member+","+newValue)
		return false
		
	var oldValue = config.get_value(statSection,MAX_PREFIX+member)
	
	#stats not tracking this property?
	if oldValue == null:
		return false
	else:
		return newValue > oldValue



func isNewHeroStatStylePointsRecord(hero,member,newValue):
	
	#var statSection = config.get_value(HERO_SECTIONS_SID,hero)
	var statSection =heroSectionIdMap[hero]	
	
	if statSection == null:
		#print("null hero stat section query: "+hero+", "+member+","+newValue)
		return false
	
	if not config.has_section_key(STYLE_SID_PREFIX+statSection,MAX_PREFIX+member):
		#print("non existing stat section query: "+str(hero)+", "+str(member)+","+str(newValue))
		return false
		
	var oldValue = config.get_value(STYLE_SID_PREFIX+statSection,MAX_PREFIX+member)
	
	#stats not tracking this property?
	if oldValue == null:
		return false
	else:
		return newValue > oldValue


func isNewPlayerNameHeroStatStylePointsRecord(pname,hero,member,newValue):
	
	#var statSection = config.get_value(PLAYER_NAME_SID,pname)
	var statSection = getPlayerNameHeroSectionID(pname,hero)
	
	if statSection == null:
		#print("null hero stat section query: "+hero+", "+member+","+newValue)
		return false
	
	if not config.has_section_key(statSection,STYLE_SID_PREFIX+MAX_PREFIX+member):
		#print("non existing stat section query: "+hero+", "+member+","+newValue)
		return false
		
	var oldValue = config.get_value(statSection,STYLE_SID_PREFIX+MAX_PREFIX+member)
	
	#stats not tracking this property?
	if oldValue == null:
		return false
	else:
		return newValue > oldValue
		
	
func getValue(section,key):
	
	var res = null
	if config != null:
		res=config.get_value(section,key)
	
	return res
	
func setValue(section,key,value):
	
	if config == null:
		print("warning, trying to set value in settings will null config")
	
	config.set_value(section, key, value)
	
	# Look for the display/width pair, and default to 1024 if missing
	#var screen_width = config.get_value("display", "width", 1024)
	## Store a variable if and only if it hasn't been defined yet
	#f not config.has_section_key("audio", "mute"):
	#	config.set_value("audio", "mute", false)
		# Save the changes by overwriting the previous file
	#	config.save("user://settings.cfg")

func playerStateMemberToUserFriendlyString(member):
	
	#not impelemtned yet
	return member


func getEntityNames(entitySection):
	if config == null:
		print("warning: try to get number of player names, but stats config is null")
		return null
		
	#no names yet?
	if not config.has_section(entitySection):
		return []
		
	#get all the keys/names. Size is number of heors
	return config.get_section_keys(entitySection)


#func getHeroNames():
#	return getEntityNames(HERO_SECTIONS_SID)
	
	
#returns list of player names entered in stats
#func getNumberOfPlayerNames():
	
#	if config == null:
#		print("warning: try to get number of player names, but stats config is null")
#		return null
		
	#no names yet?
#	if not config.has_section(PLAYER_NAME_SID):
#		return 0
		
	#get all the keys/names. Size is number of names
#	var names = config.get_section_keys(PLAYER_NAME_SID)
	
#	return names.size()

#func getPlayerNames():
#	return getEntityNames(PLAYER_NAME_SID)
	
	
	
#adds pplayer name to stats config
#func addPlayerName(pname):
	
#	if pname == null:
#		print("warning, cannot create null player name")
#		return

	#var playerNameSection = pname+NAME_SECTION_SID_SUFFIX
#	if config.has_section_key(PLAYER_NAME_SID,pname):
#		print("warning, cannot create player name "+pname+", it already exists")
#		return
	
	#add player name to list of player names (key = value, just used for name lookup)
#	config.set_value(PLAYER_NAME_SID,pname,pname)#example entry: <PLAYER_NAME_SID,l33tsk1llz,l33tsk1llz_STATS_SID>
	
	
	#get the section ids of hero-playername
#	var pNameHeroSIDs = getPlayerNameHeroSectionIDs(pname)
	
	#add empty stats for player name for each hero 
#	for pnameHeroSID in pNameHeroSIDs:
	
		#add empty stats section
#		populateStatsSectionWithEmptyStats(pnameHeroSID)
		#add empty style points stat section
#		populateStatsSectionWithEmptyStats(STYLE_SID_PREFIX+pnameHeroSID)

#removes pplayer name to stats config
func removePlayerName(pname):
	
	if pname == null:
		#print("warning, cannot remove null player name")
		return
		
	#var playerNameSection = pname+NAME_SECTION_SID_SUFFIX
	
	#if not config.has_section(playerNameSection):
	#if not config.has_section_key(PLAYER_NAME_SID,pname):
	#	print("warning, cannot remove player name "+pname+", it doesn't exist")
	#	return
	
	
	
	#get the section ids of hero-playername
	var pNameHeroSIDs = getPlayerNameHeroSectionIDs(pname)
	
	#remoev stats for player name for each hero 
	for pnameHeroSID in pNameHeroSIDs:
	
		if config.has_section(pnameHeroSID):
			#erase the stats section of hero-player name	
			config.erase_section(pnameHeroSID)
		
		if config.has_section(STYLE_SID_PREFIX+pnameHeroSID):
			#erase style points section
			config.erase_section(STYLE_SID_PREFIX+pnameHeroSID)
		
	#erase reference to player name
	#my_erase_section_key(PLAYER_NAME_SID,pname)
	
	
func my_erase_section_key(section,key):
	
	var keys = config.get_section_keys(section)
	var pairs = []
	#copy the key-value pairs
	for k in keys:
		
		#skip the pair we gona delete
		if k == key:
			continue
		
		var value = config.get_value(section,k)
		var pair = [k,value]
		pairs.append(pair)
		
	#now, we delete the entire section, and populate it anew with its
	#old content minus the deletion
	config.erase_section(section)
	for pair in pairs:
		var k = pair[0]
		var value = pair[1]
		config.set_value(section,k,value)


#returns a list of stats pairs (key,value)
#assosiated to the hero
#param, hero: name of hero
func getHeroStats(hero):
	#var heroSID = config.get_value(HERO_SECTIONS_SID,hero)
	var heroSID =heroSectionIdMap[hero]	
	
	var res = []
	
	if not config.has_section(heroSID):
		populateStatsSectionWithEmptyStats(heroSID)
		populateStatsSectionWithEmptyStats(STYLE_SID_PREFIX+heroSID)
		return null #this assum
		
	var heroStats = getStatsHelper(heroSID)
	var heroStyleStats = getStatsHelper(STYLE_SID_PREFIX+heroSID)
	
	#combine both stats into the result
	for pair in heroStats:
		res.append(pair)
		
	#delimit the style points
	res.append(["----","-"]) #- just filler
	res.append(["--Style points below--","-"]) #- just filler
	res.append(["----","-"]) #- just filler
	
	for pair in heroStyleStats:
		res.append(pair)
	return res

#returns a list of stats pairs (key,value)
#assosiated to the hero or player-name+hero
#param, hero: name of hero
#param, pname: player name or null if only general hero stats desired (as opposed to player-name hero stats)
func getPlayerNameHeroStats(pname,hero):
	
	var playerNameHeroSection  = getPlayerNameHeroSectionID(pname,hero)
	
	#player name doesn't exist?
	if not config.has_section(playerNameHeroSection):
		#print("warning, cannot get stats from player name "+pname+", it doesn't exist")
		return null
	
	
	
		
#	if not config.has_section(playerNameHeroSection):
#		populateStatsSectionWithEmptyStats(playerNameHeroSection)
#		populateStatsSectionWithEmptyStats(STYLE_SID_PREFIX+playerNameHeroSection)
	
	
	var res = []
	
	var pnameStats = getStatsHelper(playerNameHeroSection)
	var pnameStyleStats = getStatsHelper(STYLE_SID_PREFIX+playerNameHeroSection)
	
	#combine both stats into the result
	for pair in pnameStats:
		res.append(pair)
		
	#delimit the style points
	res.append(["----","-"]) #- just filler
	res.append(["--Style points below--","-"]) #- just filler
	res.append(["----","-"]) #- just filler
	
	for pair in pnameStyleStats:
		res.append(pair)
	return res
	
	
#returns the stats in [description string, value] pairs
#param: entityStatSection, section where an entity's (hero of playername-hero) stats are stored
func getStatsHelper(entityStatSection):

	
	#player name doesn't exist?
	if not config.has_section(entityStatSection):
		print("warning, cannot get stats from section "+entityStatSection+", it doesn't exist")
		return []
	
	var res = []
		
		#increment number of games
	var numGames = config.get_value(entityStatSection,NUMBER_GAMES_KID)
	var wins = config.get_value(entityStatSection,WIN_COUNT_KID)
	var losses = config.get_value(entityStatSection,LOSS_COUNT_KID)
		
	res.append(["Number of games",numGames])
	res.append(["Wins",wins])
	res.append(["Losses",losses])
	
	if losses != 0:
		res.append(["Win/Loss Ratio",float(float(wins)/float(losses))])
	else:
		res.append(["Win/Loss Ratio",1.0]) #100% win ratio, since no losses
	var maxMembersList = playerStateTemplate.getMemberNamesToKeepTrackofMaximums()

	
	
	#update the max of all the members of player state we
	#keeping track of
	for member in maxMembersList:
		
		var key = MAX_PREFIX+member
		var userFriendlyKey = playerStateMemberToUserFriendlyString(member)
		var value =  config.get_value(entityStatSection,key)
	
		var pair = ["Max " + userFriendlyKey,value]
		res.append(pair)
		
		
		
		
		
	var totalsMembersList = playerStateTemplate.getMemberNamesToKeepTrackofTotals()
	
	var numGamesPlayed = config.get_value(entityStatSection,NUMBER_GAMES_KID)
	#update the  average, and total of all the members of player state we
	#keeping track of
	for member in totalsMembersList:
		
		
		var key = TOTAL_PREFIX+member
		var userFriendlyKey = playerStateMemberToUserFriendlyString(member)
		var value =  config.get_value(entityStatSection,key)
	
		var pair = ["Total " +userFriendlyKey,value]
		res.append(pair)

		if	numGamesPlayed != 0 and value != null:
			#dynamically compute mean to display
			var mean =  value/numGamesPlayed
		
			pair = ["Average "+userFriendlyKey,mean]
			res.append(pair)
		else:
			pair = ["Average "+userFriendlyKey,"N/A"]
			res.append(pair)
		
		#compute the new average
		#var newMean = newTotal/numGamesPlayed
		#update stats
		#config.set_value(section,AVG_PREFIX+member,newMean)
		
	
	
	return res
	
func incrementValue(section,key):
	var oldValue = config.get_value(section,key)
	var newValue = oldValue + 1
	config.set_value(section,key,newValue)

func toString():
	var res = ""
	if config == null:
		res = "null"
	else:
		res = "["
		#iterate all sections
		for sec in config.get_sections():	
			#iterae keys
			for key in config.get_section_keys(sec):
				var value = config.get_value(sec,key)
				res = res + "('"+str(sec)+"','"+str(key)+"': "+str(value)+")"
		
		res = res+ "]"		
	return res