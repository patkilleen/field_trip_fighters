extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var soundPlayers = []

var playing = false

var currSoundPlayerIx = -1
func _ready():
	
	
	for c in self.get_children():
		var script = c.get_script()
		if script != null:
			var scriptName = script.get_path().get_file()
			#found signle sound node?
			if scriptName == "SingleSoundPlayer.gd":
					soundPlayers.append(c)
					
	currSoundPlayerIx=-1
	playing=false				
	_readyHook()
		
#func for subclass to have accesss to _ready
func _readyHook():
	pass
	
func stopAll():
	currSoundPlayerIx=-1
	playing=false
	for i in  soundPlayers.size():
		var sfx = soundPlayers[i]
		
		if sfx != null:
			sfx.stop()
#plays the song at index 'ix'
func playSound(ix,playback_position=0):
	#bounds check
	if ix < 0 or ix > soundPlayers.size():
		print("warning: trying to play sound but index out of bounds: "+ix)
		return
		
	var sfx = soundPlayers[ix]
	
	#although it shouldn't be null, errors happen
	if sfx != null:
		sfx.playSound(playback_position)
	#else:
	#	print("error: null sound in multisound player")
	
	playing=true
	currSoundPlayerIx = ix
	
func playSoundFromCurrentPosition(ix):
	
	if (ix < 0 or ix >= soundPlayers.size()):
		return
	var playback_position = soundPlayers[ix].get_playback_position()
	playSound(ix,playback_position)
	
#plays one of the sounds of this multi sound player	
func playRandomSound():
	
	if soundPlayers.size() ==0:
		return
		
	randomize()
	#random int from 0 to 2
	var ix = randi()%soundPlayers.size()
	
	playSound(ix)
	
	currSoundPlayerIx = ix
	
func getCurrentSoundPlayer():
	if currSoundPlayerIx == -1:
		return null
	return soundPlayers[currSoundPlayerIx]