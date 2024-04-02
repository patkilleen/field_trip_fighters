extends Node

const GLOBALS = preload("res://Globals.gd")
const SFX_SOUND_BASE_DIR = "res://assets/sounds/sfx/fighters/"

const directorySoundPlayerResource = preload("res://music/DirectorySoundPlayer.gd")
const singleSoundPlayerResource = preload("res://music/SingleSoundPlayer.gd")

export (float) var volume_db = 0
export (String) var soundFileType = "wav"

var soundPlayers =[]


func _ready():
	pass # Replace with function body.


func init(heroName):
	

	#ccreate the sound sfx path directory using hero name
	var sfxDir = SFX_SOUND_BASE_DIR + heroName
	
	#get all the files in the hero sfx sound directory
	var files = GLOBALS.list_files_in_directory(sfxDir)
	
	var numSoundPlayers= 0
	
	for f in files:
		var fileFullPath=sfxDir+"/"+f
		#the appropriate sfx sound file type?
		if f.ends_with("."+soundFileType):
			numSoundPlayers=numSoundPlayers+1
		else:
			
			var dir = Directory.new()
		#	dir.open(fileFullPath)
			
			#directory?
			if dir.dir_exists(fileFullPath):
				numSoundPlayers=numSoundPlayers+1
				
	
	#allocate buffer
	for i in numSoundPlayers:
		soundPlayers.append(null)
		
	for f in files:
		
		var fileFullPath=sfxDir+"/"+f
		var dashIx = f.find("-")
		
		#ignore files that don't follow format of <ID>-NAME_OF_FIALES.WAV
		#where first characters represent index of sound in list
		if dashIx == -1:
			continue
		
		var soundPlayerIx = int(f.substr(0,dashIx))
		
		#the appropriate sfx sound file type?
		if f.ends_with("."+soundFileType):
			#wave file, create single wave file player
			#instance a new SingleSoundPlayer
			var soundPlayer = singleSoundPlayerResource.new()
			soundPlayer.type = singleSoundPlayerResource.LoadType.PRELOAD
			soundPlayer.loop = false
			soundPlayer.soundFilePath=fileFullPath
			soundPlayer.volume_db=volume_db
			#now add as child and keep a reference for parent
			self.add_child(soundPlayer)
			soundPlayer.owner = self
			soundPlayers[soundPlayerIx] = soundPlayer
			
		else:
			
			var dir = Directory.new()
			#dir.open(fileFullPath)
			
			#directory?
			if dir.dir_exists(fileFullPath):
				#create a directory sound file wave player
					#instance a new SingleSoundPlayer
					var soundPlayer = directorySoundPlayerResource.new()
					soundPlayer.type = directorySoundPlayerResource.LoadType.PRELOAD
					soundPlayer.loop = false
					soundPlayer.soundDirectory=fileFullPath+"/"
					soundPlayer.volume_db=volume_db
					#now add as child and keep a reference for parent
					self.add_child(soundPlayer)
					soundPlayer.owner = self
					soundPlayers[soundPlayerIx] = soundPlayer
			
	
	
	
func changeVolume(sfxId,newDB):
	volume_db=newDB
	
	#out of bounds?
	if sfxId >= soundPlayers.size():
		return
		
	var sfx = soundPlayers[sfxId]
	
	if sfx is directorySoundPlayerResource:
		sfx.changeVolume(newDB)
	else:
		sfx.volume_db = volume_db
			

#	if newDB==volume_db:
#		return 
#	volume_db=newDB
#	for i in  soundPlayers.size():
#		var sfx = soundPlayers[i]
		
#		if sfx is directorySoundPlayerResource:
#			for j in  sfx.soundPlayers.size():
#				var subsfx = sfx.soundPlayers[j]
#				subsfx.volume_db = volume_db
#		else:
#			sfx.volume_db = volume_db
func stopAll():
	
	for i in  soundPlayers.size():
		var sfx = soundPlayers[i]
		
		if sfx is directorySoundPlayerResource:
			
			sfx.stopAll()
		elif sfx is singleSoundPlayerResource:
			sfx.stop()


#plays the song at index 'ix' (or a random song in direcotry ff the index represents a direcotySoundplayer)
func playSound(ix,playback_position=0):
	#bounds check
	if ix < 0 or ix >= soundPlayers.size():
		print("warning: trying to play sound but index out of bounds: "+str(ix))
		return
	
	
	var sfx = soundPlayers[ix]
	

	#although it shouldn't be null, errors happen
	if sfx != null:
		
		if sfx is directorySoundPlayerResource:
			#avoid overlapping sounds
			stopAll()
			sfx.playRandomSound()
			
		elif sfx is singleSoundPlayerResource:
			#avoid overlapping sounds
			stopAll()
			sfx.playSound(playback_position)


		
	else:
		print("error: null sound in multisound player")
	

	