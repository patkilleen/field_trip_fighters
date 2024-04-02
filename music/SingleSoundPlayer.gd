extends AudioStreamPlayer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

enum LoadType{
	PRELOAD,
	LOAD_AT_RUNTIME
}

export (LoadType) var type = 0
export (String) var soundFilePath = ""
export (bool) var loop = false
export (bool) var loopWithDiffStartPos = false
export (float) var loopStartPos = 0

var soundData = null
var loadedFlag = false

func _ready():
	
	if type == LoadType.PRELOAD:
		loadSound()

func isLoaded():
	return loadedFlag
	
func loadSound():

	var soundData = load(soundFilePath) 
	if soundData == null:
		print("error loading song: "+soundFilePath)
		return
	soundData.format = soundData.FORMAT_16_BITS
	
	#set up the looping
	if loop:
		soundData.set_loop_mode(soundData.LOOP_FORWARD)
	# devide number bytes by 2 since 16-bit format
	var endByte = (soundData.data.size()/2)-1
	var maxSongByteLength = endByte-1
	soundData.loop_end = maxSongByteLength#make sure play till end (song shouldn't exceed this length)
	
	
	self.stream = soundData
	
	#finished loading song
	loadedFlag= true
	
func playSound(playbackPos = 0.0):
	#trying to play a song without loading it into memorey?
	#when this type of sound player requires pre-loading?
	if not isLoaded() and type == LoadType.PRELOAD:
		print("error: trying to player a preloaded sound ("+soundFilePath+") but we forgot to load it")
		return
	elif not isLoaded() and type == LoadType.LOAD_AT_RUNTIME:
		#we load sound into memory dynamically here each time a request to play song is made
		loadSound()
	
	if loopWithDiffStartPos:
		if not is_connected("finished",self,"_on_repeat_loop"):
			connect("finished",self,"_on_repeat_loop")
		
	self.play(playbackPos)

func stop():
	
	#make sure to not trigger the loop from a different position
	#when manually stopped the sound
	if is_connected("finished",self,"_on_repeat_loop"):
		disconnect("finished",self,"_on_repeat_loop")
	.stop()
	
func _on_repeat_loop():
	if loopWithDiffStartPos:
		playSound(loopStartPos)
		