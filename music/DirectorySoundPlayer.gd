extends "MultiSoundPlayer.gd"
const GLOBALS = preload("res://Globals.gd")
var singleSoundPlayerScene = preload("SingleSoundPlayer.gd")
enum LoadType{
	PRELOAD,
	LOAD_AT_RUNTIME
}

export (LoadType) var type = 0
export (String) var soundDirectory = ""
export (bool) var loop = false
export (String) var soundFileType = "wav"
export (float) var volume_db = 0

func _readyHook():
		
	#search the directory for all sound files
	#note that we don't need to worry about preloading vs. loading at runtime
	#cause the SingleSoundPlayer objects will deal with the logic
		
	#var audioFiles = []
	
	#get all the music files in target directory
	#var files = GLOBALS.list_files_in_directory(soundDirectory)
	
	#append all the wav file paths to audioFiles array
	#for f in files:
	#	if f.ends_with("."+soundFileType):
	#		audioFiles.append(soundDirectory+f)
	
	#now create a single sound player for each wav file
	#for wavFile in audioFiles:
		#instance a new SingleSoundPlayer
	#	var soundPlayer = singleSoundPlayerScene.instance()
	#	soundPlayer.type = type
	#	soundPlayer.loop = loop
	#	soundPlayer.soundFilePath=wavFile
	#	soundPlayer.volume_db=volume_db
		#now add as child and keep a reference for parent
	#	self.add_child(soundPlayer)
	#	soundPlayer.owner = self
	#	soundPlayers.append(soundPlayer)
			
	
	#get all the files in the sound directory
	var files = GLOBALS.list_files_in_directory(soundDirectory)
	
	var numSoundPlayers= 0
	
	for f in files:
		var fileFullPath=soundDirectory+"/"+f
		#the appropriate sfx sound file type?
		if f.ends_with("."+soundFileType):
			numSoundPlayers=numSoundPlayers+1
	
	
	#allocate buffer
	for i in numSoundPlayers:
		soundPlayers.append(null)
		
	for f in files:
		
		var fileFullPath=soundDirectory+"/"+f
		var dashIx = f.find("-")
		
		#ignore files that don't follow format of <ID>-NAME_OF_FIALES.WAV
		#where first characters represent index of sound in list
		if dashIx == -1:
			continue
		
		var soundPlayerIx = int(f.substr(0,dashIx))
		
		#the appropriate sfx sound file type?
		if f.ends_with("."+soundFileType):
			#instance a new SingleSoundPlayer
			var soundPlayer = singleSoundPlayerScene.new()
			soundPlayer.type = type
			soundPlayer.loop = loop
			soundPlayer.soundFilePath=fileFullPath
			soundPlayer.volume_db=volume_db
			#now add as child and keep a reference for parent
			self.add_child(soundPlayer)
			soundPlayer.owner = self
			soundPlayers[soundPlayerIx] = soundPlayer
				
	
	
func changeVolume(newDB):
	
	if newDB ==volume_db:
		return
	volume_db=newDB
	for sp in soundPlayers:
		sp.volume_db=newDB