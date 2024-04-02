extends Control

export (Texture) var kenTexture = null
export (Texture) var gloveTexture = null

export (Texture) var beltTexture = null

export (Texture) var micTexture = null

export (Texture) var hatTexture = null

export (Texture) var whistleTexture = null


const GLOBALS = preload("res://Globals.gd")

const P_VALUE_PICKING_SPECIAL_QUOTES = 0.6

const P_VALUE_PICKING_MATCHUP_QUOTES = 0.7 # STAGE special quote probablilyt = 1 -P_VALUE_PICKING_MATCHUP_QUOTES


var heroPortrait = null
var heroNameLabel = null
var heroTextureMap = {}

#stores arrays of quotes for each character
var victoryQuoteListMap = {}

#store special quotes that are only said in specific matchup (belt vs glove, their share lore
# will be in these messages, only displayed durign the belt-glove matchup)
#keys are in form: "victorhero1name;loserhero2name".
const SPECIAL_MAP_HERO_NAME_DELIMITER = ";"

var matchupSpecialQuoteListMap= {}
var stageSpecialQuoteListMap= {} #keys are heros, values ares maps  with [key: stage scene path, value : list of quotes for that stage]

#stores the attributes (e.g., bloodtype) of studnets
#using hero name as key, and the list of attributes (in key-value pairs using a map) as value
var heroAttributeListMap = {}

const SCHOOL_ATTRIBUTES_KEY = "School:"
const LIKES_ATTRIBUTES_KEY = "Likes:"
const DISLIKES_ATTRIBUTES_KEY = "Dislikes:"
const BLOOD_TYPE_ATTRIBUTES_KEY = "Blood Type:"
const HIEGHT_ATTRIBUTES_KEY = "Height:"
const WEIGHT_ATTRIBUTES_KEY = "Weight:"
const GENDER_ATTRIBUTES_KEY = "Gender:"
const AGE_ATTRIBUTES_KEY = "Age:"


var attributeTemplate = null

var heroAttributesGridContainer = null

var heroQuoteLabel = null
var rng = null
func _ready():
	
	#RANDOME NUM gen for quote selection
	rng = RandomNumberGenerator.new()
	
	#genreate time-based seed
	rng.randomize()
	
	heroTextureMap[GLOBALS.KEN_HERO_NAME] =kenTexture
	heroTextureMap[GLOBALS.GLOVE_HERO_NAME] =gloveTexture
	heroTextureMap[GLOBALS.BELT_HERO_NAME] =beltTexture
	heroTextureMap[GLOBALS.MICROPHONE_HERO_NAME] =micTexture
	heroTextureMap[GLOBALS.HAT_HERO_NAME] =hatTexture
	heroTextureMap[GLOBALS.WHISTLE_HERO_NAME] =whistleTexture
	

	heroPortrait = $heroPortrait
	heroNameLabel = $heroNameLabel

	attributeTemplate = $attributeTemplate
	heroAttributesGridContainer = $heroAttributesGridContainer
	heroQuoteLabel = $heroVictoryQuoteLabel
	populateQuoteMaps()
	
	populateAttributeMaps()
	
func populateQuoteMaps():
		
	#kens quotes
	var kenQuotes = [
	"I am an alpha character (I dread the day I will be removed)",
	"I was the first character to be added to the alpha",
	"Alex was the best ken main in the first alpha built (spamming B infinite active frames baby!)"
	]
	
	#glove quotes
	var gloveQuotes = [
	"I usually play baseball alone",
	"I don't need to play catch with someone, since my ball is on a string."
	]
	
	#belt quotes
	var beltQuotes = [
	"Look Hat, I won!",
	"Wow, you're even weaker than Hat."
	]
	
	#microphone quotes
	
	var micQuotes = [
	"Awww you lost? Sounds like you're having a rough day",
	"You're just a kid... I am a queen.",
	"Sorry I cant hear your crying over my amazing voice :P",
	"Soprano to contralto, opera to rap, dancing, Beatboxing.... I really do have it all~"
	]
	
	var whistleQuotes = [
	"The Latin name for Shoebill Storks is Balaeniceps rex",#stork facts
	"Shoebill Storks are among the top 5 favored birds by bridwatchers", #stork facts
	"On average, Shoebill Storks have up to 3 nests per square kilometer in nesting areas ", #stork facts
	"Shoebill Storks tend to stay quiet, but display bill-clattering when they are by their nest", #stork facts
	"Corgies don't usually drool much compared to other dog breeds", #corgi facts
	"Corgies like to bark a lot", #corgi facts
	"Corgies are quite affectionate when it comes to being a family dog", #corgi facts
	"The Latin name for dog is Canis lupus familiaris", #corgi facts
	"Tarantulas are in the family of spiders called Theraphosidae", #tarantual facts
	"Tarantula sizes can vary from the size of a BB gun pellet to a dinner plate", #tarantual facts
	"Tarantulas live longer than most other types of spiders", #tarantual facts
	"Tarantulas are not a type of spider, Tarantulas are in fact a group of large spiders", #tarantual facts
	"To avoid mis-identifying a tarantulas with another type of spider, look for the direction of the fangs: tarantualas have teeth facing downward while most spiders have teeth that face each other", #tarantual facts
	"Another name for eastern hognose snakes is the 'spreading adder'", #snake facts
	"Eastern hognose snakes tend to have a home range of 40 hectares", #snake facts
	"When a eastern hognose snakes is threatened, it rises its head and flattens its neck", #snake facts
	"The Latin name for eastern hognose snake is Heterodon platirhinos", #snake facts
	"Hedgehogs are a mammal in the subfamily Eriaceinaen", #hedgehog facts
	"There are 17 types of hedgehog species", #hedgehog facts
	"The spiky hair on hedgehogs is made of stiff keratin ", #hedgehog facts
	"Skunks are mammals in the family Mephitidae ", #skunk facts
	"The stinky spray of skunks is not actually a fart, it's a liquid produced by their anal glands", #skunk facts
	"Skunks are also in the same family as weasels" #skunk facts
	]
	
	var hatQuotes = [ 
	"What should Hat say when he wins?"
	]
	
	
	victoryQuoteListMap[GLOBALS.KEN_HERO_NAME] =kenQuotes
	victoryQuoteListMap[GLOBALS.GLOVE_HERO_NAME] =gloveQuotes
	victoryQuoteListMap[GLOBALS.BELT_HERO_NAME] =beltQuotes
	victoryQuoteListMap[GLOBALS.MICROPHONE_HERO_NAME] =micQuotes
	victoryQuoteListMap[GLOBALS.HAT_HERO_NAME] =hatQuotes
	victoryQuoteListMap[GLOBALS.WHISTLE_HERO_NAME] =whistleQuotes
	
	#ken-ken quotes
	var kenDittoQuotes = [
	"I find it odd to fight against myself",
	"May the better ken main win",
	"I think I might be top tier"
	]
	
	#glove-glove quotes
	var gloveDittoQuotes = [
	"We should play baseball together some time.",
	"My fastballs are way faster than yours.",
	"It is too bad I can't bat away my clone's ball (feature coming soon!)"
	]
	
	#belt-belt quotes
	var beltDittoQuotes = [
	"You have good Judo talent. We should be friends.",
	"You are a worthy opponent. Good match."
	]
	
	#MIC-MIC quotes
	var micDittoQuotes = [
	"There can only be one queen.",
	"I am way more popular than you.",
	]
	
		#hat-hat quotes
	var hatDittoQuotes = [
	"Give me back my ball cap.",
	]
	
	#winglove-loseken quotes
	var gloveWinKenLoseQuotes = [
	"You cannot win if you cannot approach me",
	"My projectile is much longer range than yours"
	]
	
	
	
	var gloveWinHatLoseQuotes = [
	"Fuck you, Hat.",
	"You were so weak this match. I bet your dad would be disappointed"
	]
	
	var gloveWinMicLoseQuotes = [
	"At least you found a social group you strongly relate to"
	]
	
	
	var beltWinMicLoseQuotes = [
	"Step down step up.", "Step down highschool musical."
	]
	
	var beltWinHatLoseQuotes = [
	"What should belt say to hat?"
	]
	
	#winken-loseGlove quotes
	var kenWinGloveLoseQuotes = [
	"You cannot win if your ball is always broken",
	"If I am in your face, you cannot throw your ball at me"
	]
	
		
	#winmic-loseglove quotes
	var micWinGloveLoseQuotes = [
	"so you're a baseball star? So what. I'm a superstar!"
	]
	
	#winmic-losebelt quotes
	var micWinBeltLoseQuotes = [
	"I can get down with your tomboy style, but think twice before you can step to the Queen"
	]
	
	
	var micWinHatLoseQuotes = [
	"What should mic say to hat?"
	]
	
	#winmic-losehat quotes
	var hatWinBeltLoseQuotes = [
	"What should hat say to belt?"
	]
	
	
	var hatWinMicLoseQuotes = [
	"Singing... That's cute."
	]
	
	var hatWinGloveLoseQuotes = [
	"It's good to see you Glove."
	]
	
	var fillerQuotes = [
	"[debug]:to be filled out"
	]
	
	

	#quotes dedicated to special matchups
	matchupSpecialQuoteListMap[GLOBALS.KEN_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.KEN_HERO_NAME]=kenDittoQuotes
	matchupSpecialQuoteListMap[GLOBALS.GLOVE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.GLOVE_HERO_NAME]=gloveDittoQuotes
	matchupSpecialQuoteListMap[GLOBALS.BELT_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.BELT_HERO_NAME]=beltDittoQuotes
	matchupSpecialQuoteListMap[GLOBALS.MICROPHONE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.MICROPHONE_HERO_NAME]=micDittoQuotes
	matchupSpecialQuoteListMap[GLOBALS.HAT_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.HAT_HERO_NAME]=hatDittoQuotes
	matchupSpecialQuoteListMap[GLOBALS.WHISTLE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.WHISTLE_HERO_NAME]=["What should Whistle say to Whistle when he wins?"]
	
	
	matchupSpecialQuoteListMap[GLOBALS.GLOVE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.KEN_HERO_NAME]=gloveWinKenLoseQuotes
	matchupSpecialQuoteListMap[GLOBALS.GLOVE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.BELT_HERO_NAME]=["You can't even win at fighting? This is why baseball is the star team of our school."]
	matchupSpecialQuoteListMap[GLOBALS.GLOVE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.MICROPHONE_HERO_NAME]=gloveWinMicLoseQuotes
	matchupSpecialQuoteListMap[GLOBALS.GLOVE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.HAT_HERO_NAME]=gloveWinHatLoseQuotes
	matchupSpecialQuoteListMap[GLOBALS.GLOVE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.WHISTLE_HERO_NAME]=["\"Bro\", nobody cares about your pets.", "Wow, the only things that accept you are animals."]
	
	matchupSpecialQuoteListMap[GLOBALS.KEN_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.GLOVE_HERO_NAME]=gloveWinKenLoseQuotes
	matchupSpecialQuoteListMap[GLOBALS.KEN_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.BELT_HERO_NAME]=fillerQuotes
	
	matchupSpecialQuoteListMap[GLOBALS.BELT_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.GLOVE_HERO_NAME]=["What should Belt say to Glove when she wins?"]
	matchupSpecialQuoteListMap[GLOBALS.BELT_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.KEN_HERO_NAME]=fillerQuotes
	matchupSpecialQuoteListMap[GLOBALS.BELT_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.MICROPHONE_HERO_NAME]=beltWinHatLoseQuotes
	matchupSpecialQuoteListMap[GLOBALS.BELT_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.HAT_HERO_NAME]=beltWinHatLoseQuotes
	matchupSpecialQuoteListMap[GLOBALS.BELT_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.WHISTLE_HERO_NAME]=["What should Belt say to Whistle when she wins?"]
	
	matchupSpecialQuoteListMap[GLOBALS.MICROPHONE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.GLOVE_HERO_NAME]=micWinGloveLoseQuotes
	matchupSpecialQuoteListMap[GLOBALS.MICROPHONE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.BELT_HERO_NAME]=micWinBeltLoseQuotes
	matchupSpecialQuoteListMap[GLOBALS.MICROPHONE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.HAT_HERO_NAME]=micWinHatLoseQuotes
	matchupSpecialQuoteListMap[GLOBALS.MICROPHONE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.WHISTLE_HERO_NAME]=["What should Mic say to Whistle when she wins?"]
	
	matchupSpecialQuoteListMap[GLOBALS.HAT_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.GLOVE_HERO_NAME]=hatWinGloveLoseQuotes
	matchupSpecialQuoteListMap[GLOBALS.HAT_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.BELT_HERO_NAME]=hatWinBeltLoseQuotes
	matchupSpecialQuoteListMap[GLOBALS.HAT_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.MICROPHONE_HERO_NAME]=hatWinMicLoseQuotes
	matchupSpecialQuoteListMap[GLOBALS.HAT_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.WHISTLE_HERO_NAME]=["What should Hat say to Whistle when she wins?"]
		

	matchupSpecialQuoteListMap[GLOBALS.WHISTLE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.GLOVE_HERO_NAME]=["What should Whistle say to Glove when he wins?"]
	matchupSpecialQuoteListMap[GLOBALS.WHISTLE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.BELT_HERO_NAME]=["What should Whistle say to Belt when he wins?"]
	matchupSpecialQuoteListMap[GLOBALS.WHISTLE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.MICROPHONE_HERO_NAME]=["What should Whistle say to Mic when he wins?"]
	matchupSpecialQuoteListMap[GLOBALS.WHISTLE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.HAT_HERO_NAME]=["What should Whistle say to Hat when he wins?"]
	matchupSpecialQuoteListMap[GLOBALS.WHISTLE_HERO_NAME+SPECIAL_MAP_HERO_NAME_DELIMITER+GLOBALS.WHISTLE_HERO_NAME]=["What should Whistle say to Whistle when he wins?"]
		
	#quotes dedicated to special character + stage
	#microphone has a special quote for theatre stage
	var stageQuoteMap={}
	stageSpecialQuoteListMap[GLOBALS.MICROPHONE_HERO_NAME]=stageQuoteMap	
	var stageQuoteList=["I won a signing competition here when I was a kid!"]
	stageQuoteMap[GLOBALS.THEATER_SCENE_PATH]=stageQuoteList
	
	stageQuoteMap={}
	stageSpecialQuoteListMap[GLOBALS.BELT_HERO_NAME]=stageQuoteMap	
	stageQuoteList=["I can't believe some people think this place is haunted..."]
	stageQuoteMap[GLOBALS.HAUNTED_MANSION_SCENE_PATH]=stageQuoteList
	
	stageQuoteMap={}
	stageSpecialQuoteListMap[GLOBALS.GLOVE_HERO_NAME]=stageQuoteMap	
	#hints to the platform easter eg
	stageQuoteList=["This one time I threw my ball so highup it nearly went over the tower.\n It must have gotten stuck on something, it took forever to fall down."]
	stageQuoteMap[GLOBALS.RADIO_TOWER_SCENE_PATH]=stageQuoteList
	
	stageQuoteMap={}
	stageSpecialQuoteListMap[GLOBALS.WHISTLE_HERO_NAME]=stageQuoteMap	
	stageQuoteList=["Have you guys met all the animals here. Me and Fred (the crow) became friends."]
	stageQuoteMap[GLOBALS.FARM_SCENE_PATH]=stageQuoteList
	stageQuoteList=["I saw a pair of bald eagles here once. They must be nesting nearby."]
	stageQuoteMap[GLOBALS.MOUNTAIN_CLIMBING_SCENE_PATH]=stageQuoteList
	stageQuoteList=["Did you know Red Diamond Rattlesnakes (Crotalus ruber) are native here?","Did you know Black Widow Spiders (Latrodecturs hesperus) \n are native here and are 15 times more toxic than rattlesnakes?"]
	stageQuoteMap[GLOBALS.OBSERVATORY_SCENE_PATH]=stageQuoteList
	stageQuoteList=["I used to come see the great blue herons here, before they \n filled the swamp and built a museum..."]
	stageQuoteMap[GLOBALS.ART_MUSEUM_SCENE_PATH]=stageQuoteList
	stageQuoteList=["Did you know the chirping in the distance is not made by birds, \n it's made by spring peepers (Pseudacris crucifer), which are frogs."]
	stageQuoteMap[GLOBALS.HAUNTED_MANSION_SCENE_PATH]=stageQuoteList
	stageQuoteList=["Although many bird migrate south during the winter, you may be able to see a northern cardinal or eastern chickadee. If your lucky, you might even spot a snowy owl, but they tend to stay silent during the day."]
	stageQuoteMap[GLOBALS.SNOW_CARNAVAL_SCENE_PATH]=stageQuoteList
	
	
	
	
	#glove will have a quote for baseball stadium
	
func populateAttributeMaps():
		
		
		
		#ken attributes
		var kenAttributePairs={}
		
		kenAttributePairs[SCHOOL_ATTRIBUTES_KEY]="street fighter"
		kenAttributePairs[LIKES_ATTRIBUTES_KEY]="alpha character"
		kenAttributePairs[DISLIKES_ATTRIBUTES_KEY]="alpha character"
		kenAttributePairs[BLOOD_TYPE_ATTRIBUTES_KEY]="B"
		kenAttributePairs[HIEGHT_ATTRIBUTES_KEY]="5'5\""
		kenAttributePairs[WEIGHT_ATTRIBUTES_KEY]="185 lbs"
		kenAttributePairs[GENDER_ATTRIBUTES_KEY]="Male"
		kenAttributePairs[AGE_ATTRIBUTES_KEY]="69"
		
		#glove attributes
		var gloveAttributePairs={}
		gloveAttributePairs[SCHOOL_ATTRIBUTES_KEY]=["Scoreboard Academy"]
		gloveAttributePairs[LIKES_ATTRIBUTES_KEY]=["Baseball","Soccer","Basketball","Practicing alone","Training","Winning","People losing", "Winning (again)"]
		gloveAttributePairs[DISLIKES_ATTRIBUTES_KEY]=["People","Competition", "Being underestimated","Quitters","Abandonners"]
		gloveAttributePairs[BLOOD_TYPE_ATTRIBUTES_KEY]=["O-"]
		gloveAttributePairs[HIEGHT_ATTRIBUTES_KEY]=["5'5\""]
		gloveAttributePairs[WEIGHT_ATTRIBUTES_KEY]=["120 lbs"]
		gloveAttributePairs[GENDER_ATTRIBUTES_KEY]=["Male"]
		gloveAttributePairs[AGE_ATTRIBUTES_KEY]=["15"]
		
		#BELT attributes
		var beltAttributePairs={}
		beltAttributePairs[SCHOOL_ATTRIBUTES_KEY]=["Scoreboard Academy"]
		beltAttributePairs[LIKES_ATTRIBUTES_KEY]=["Hat","Judo", "Playing Tag", "Friends"]
		beltAttributePairs[DISLIKES_ATTRIBUTES_KEY]=["Cry babies", "Bad friends"]
		beltAttributePairs[BLOOD_TYPE_ATTRIBUTES_KEY]=["O+"]
		beltAttributePairs[HIEGHT_ATTRIBUTES_KEY]=["5'5\""]
		beltAttributePairs[WEIGHT_ATTRIBUTES_KEY]=["115 lbs"]
		beltAttributePairs[GENDER_ATTRIBUTES_KEY]=["Female"]
		beltAttributePairs[AGE_ATTRIBUTES_KEY]=["14"]
		
		#MIC attributes
		var micAttributePairs={}
		micAttributePairs[SCHOOL_ATTRIBUTES_KEY]=["Easel School of Fine Arts"]
		micAttributePairs[LIKES_ATTRIBUTES_KEY]=["Herself","Opera", "Rap", "Beat boxing", "Being popular"]
		micAttributePairs[DISLIKES_ATTRIBUTES_KEY]=["Unpopular kids","Haters", "Being looked down on"]
		micAttributePairs[BLOOD_TYPE_ATTRIBUTES_KEY]=["B+"]
		micAttributePairs[HIEGHT_ATTRIBUTES_KEY]=["5'5\""]
		micAttributePairs[WEIGHT_ATTRIBUTES_KEY]=["110 lbs"]
		micAttributePairs[GENDER_ATTRIBUTES_KEY]=["Trans. Female"]
		micAttributePairs[AGE_ATTRIBUTES_KEY]=["13"]
		
		
			#hat attributes
		var hatAttributePairs={}
		hatAttributePairs[SCHOOL_ATTRIBUTES_KEY]=["Scoreboard Academy"]
		hatAttributePairs[LIKES_ATTRIBUTES_KEY]=["Being alone","Proving himself","Getting into fights","Running"]
		hatAttributePairs[DISLIKES_ATTRIBUTES_KEY]=["Being pressured","Responsibilities","Losing","Taking off his hat"]
		hatAttributePairs[BLOOD_TYPE_ATTRIBUTES_KEY]=["O-"]
		hatAttributePairs[HIEGHT_ATTRIBUTES_KEY]=["5'5\""]
		hatAttributePairs[WEIGHT_ATTRIBUTES_KEY]=["118 lbs"]
		hatAttributePairs[GENDER_ATTRIBUTES_KEY]=["Male"]
		hatAttributePairs[AGE_ATTRIBUTES_KEY]=["15"]
		
		#sciuence school kids use metric system
				#whistle attributes
		var whistleAttributePairs={}
		whistleAttributePairs[SCHOOL_ATTRIBUTES_KEY]=["Beaker Institute of Higher Education"]
		whistleAttributePairs[LIKES_ATTRIBUTES_KEY]=["Animals","Collar","Vivian","Lynetta","Finn","Poppy","Clementine", "Biology","Bird Watching", "The environment"]
		whistleAttributePairs[DISLIKES_ATTRIBUTES_KEY]=["Zoos","Animal testing", "Climate change","Hamburgers"]
		whistleAttributePairs[BLOOD_TYPE_ATTRIBUTES_KEY]=["?"]
		whistleAttributePairs[HIEGHT_ATTRIBUTES_KEY]=["165 cm\""]
		whistleAttributePairs[WEIGHT_ATTRIBUTES_KEY]=["50.8 kg"]
		whistleAttributePairs[GENDER_ATTRIBUTES_KEY]=["Trans. Male"]
		whistleAttributePairs[AGE_ATTRIBUTES_KEY]=["14"]
		
		heroAttributeListMap[GLOBALS.KEN_HERO_NAME] =kenAttributePairs
		heroAttributeListMap[GLOBALS.GLOVE_HERO_NAME] =gloveAttributePairs
		heroAttributeListMap[GLOBALS.BELT_HERO_NAME] =beltAttributePairs
		heroAttributeListMap[GLOBALS.MICROPHONE_HERO_NAME] =micAttributePairs
		heroAttributeListMap[GLOBALS.HAT_HERO_NAME]=hatAttributePairs
		heroAttributeListMap[GLOBALS.WHISTLE_HERO_NAME]=whistleAttributePairs
	
func init(victorHeroName,victorPlayerName,opponentHeroName,stageScenePath):
	
	#display picture of winner
	heroPortrait.texture = heroTextureMap[victorHeroName]
	
	#display name of winner
	#gametag available?
	if victorPlayerName != null:
		
		#display gamertag too 
		heroNameLabel.text = victorHeroName + "(" + victorPlayerName  + ")"
	else:
		heroNameLabel.text = victorHeroName

	
	displayRandomQuote(victorHeroName,opponentHeroName,stageScenePath)
	
	displayHeroAttributes(victorHeroName)
	
func displayRandomQuote(victorHeroName,opponentHeroName, stageScenePath):
	
	if stageScenePath ==null:
		print("warning: stage scene path is null when determining victory quote")
		
		#stageSpecialQuoteListMap
	#determine if selecting from special quotes or from standrad
	var specialQuoteFlag = generateProbabilistichEvent(P_VALUE_PICKING_SPECIAL_QUOTES)
	
	var quoteList = null
	
	if specialQuoteFlag:
		
		#does the winner have a stage specific quote?
		var hasStageQuote = false
		if stageSpecialQuoteListMap.has(victorHeroName):
			var stageQuoteMap =stageSpecialQuoteListMap[victorHeroName]
			hasStageQuote = stageQuoteMap.has(stageScenePath)
			
		#we only choose randomly between stage quote and matchup quote if the 
		#winner has quote unique to the stage
		if hasStageQuote:
						
			#do we pick matchup quotes?
			if generateProbabilistichEvent(P_VALUE_PICKING_MATCHUP_QUOTES):
				quoteList = matchupSpecialQuoteListMap[victorHeroName + SPECIAL_MAP_HERO_NAME_DELIMITER + opponentHeroName]
			else:
				#pick the hero-stage quotes
				quoteList =stageSpecialQuoteListMap[victorHeroName][stageScenePath]
		else:
			quoteList = matchupSpecialQuoteListMap[victorHeroName + SPECIAL_MAP_HERO_NAME_DELIMITER + opponentHeroName]
	else:
		quoteList = victoryQuoteListMap[victorHeroName]
		
	#choose a quote randomly from available in list
	var ix = rng.randi_range(0,quoteList.size()-1)
	
	var quote = quoteList[ix]
	
	heroQuoteLabel.text = quote

func displayHeroAttributes(victorHeroName):
	
	var attributePairMap = heroAttributeListMap[victorHeroName]
	
	#iterate over all attributes and add to grid pan
	for attributeName in attributePairMap.keys():
		
		var valueList = attributePairMap[attributeName]
		#choose a attribute value randomly from available in list (some have only 1 option, so always pick)
		var ix = rng.randi_range(0,valueList.size()-1)
	
		var value  = valueList[ix]
	
		addAttributePair(attributeName,value)
		
#generate an event (true or false ) with given probabliity
#pvalue: probablity of evnet [0,1]
#ture returns when event occurs
#false returned when it doesn't
func generateProbabilistichEvent(pvalue):

	var eventOccured = false


	#generate number between 0 -1 
	var r = rng.randf()
	
	#event occured? note that pobability 0 will never happen
	if r < pvalue:
		eventOccured = true
			
	return eventOccured
	
	
func addAttributePair(attributeName,attributeValue):
	var attributeNameLabel = attributeTemplate.duplicate()
	var attributeValueLabel = attributeTemplate.duplicate()
	
	
	attributeNameLabel.visible = true
	attributeNameLabel.text = attributeName
	
	attributeValueLabel.visible = true
	attributeValueLabel.text = attributeValue
	
	heroAttributesGridContainer.add_child(attributeNameLabel)
	heroAttributesGridContainer.add_child(attributeValueLabel)