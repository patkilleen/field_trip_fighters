extends Sprite

export (float,0,1) var spawnProbability=0.5 #the probability of being visible when added to scene tre
var rng = null
func _ready():
	
	#RANDOME NUM gen for quote selection
	rng = RandomNumberGenerator.new()
	
	#genreate time-based seed
	rng.randomize()

	visible = generateProbabilistichEvent(spawnProbability)

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