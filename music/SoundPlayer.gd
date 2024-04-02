extends AudioStreamPlayer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (String) var musicDirectory = ""
export (bool) var loop = false

#note that 0DB is max volume and -24DB is super low volume
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func playRandomSong():
	_playRandomSong(self,musicDirectory)
	
func _playRandomSong(audio_player,dir):
	
	var audioFiles = []
	
	#get all the music files
	var files = list_files_in_directory(dir)
	
	for f in files:
		if f.ends_with(".wav"):
			audioFiles.append(dir+f)
	#audioFiles.append("res://music/amazing_drunken_new_tun.wav")
	#audioFiles.append("res://music/elo_tracker.2_maye_song_wave_to_show_to_friends.wav")
	#audioFiles.append("res://music/stargazewave_final.wav")
	
	if audioFiles.size() == 0:
		print("no songs found in folder: "+str(dir))
		return
	randomize()
	#random int from 0 to 2
	var ix = randi()%audioFiles.size()
	
	var audio_file = audioFiles[ix]


	_playSong(audio_player,audio_file)
func playSong(musicFile):
	_playSong(self,musicFile)
		
func _playSong(audio_player,audio_file):
	
	#if File.new().file_exists(audio_file):
	var sfx = load(audio_file) 
	if sfx == null:
		print("error playing song: "+audio_file)
		return
	sfx.format = sfx.FORMAT_16_BITS
	
	if loop:
		sfx.set_loop_mode(sfx.LOOP_FORWARD)
	
	# devide number bytes by 2 since 16-bit format
	var endByte = (sfx.data.size()/2)-1
	#var endByte = 0
	#var maxSongByteLength = 10000000
	var maxSongByteLength = endByte-1
	sfx.loop_end = maxSongByteLength#make sure play till end (song shouldn't exceed this length)
	audio_player.stream = sfx
	audio_player.play()


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func list_files_in_directory(path):
    var files = []
    var dir = Directory.new()
    dir.open(path)
    dir.list_dir_begin()

    while true:
        var file = dir.get_next()
        if file == "":
            break
        elif not file.begins_with("."):
            files.append(file)

    dir.list_dir_end()

    return files