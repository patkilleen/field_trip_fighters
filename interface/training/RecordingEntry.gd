extends Control
signal play
signal stop
signal erase
signal toggle_reversal_action

const RECORDING_STR="Recording "
var recordingIdLabel = null

var playBtn = null
var stopBtn = null
var eraseBtn = null

var reversalCheckbox=null
var id = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	recordingIdLabel = $recordingId
	playBtn=$playButton
	stopBtn = $stopButton
	eraseBtn = $removeButton
	reversalCheckbox = $CheckBox
	
	playBtn.connect("pressed",self,"_on_play_pressed")
	stopBtn.connect("pressed",self,"_on_stop_pressed")
	eraseBtn.connect("pressed",self,"_on_erase_pressed")
	reversalCheckbox.connect("pressed",self,"_on_reversal_toggle_pressed")
	playBtn.visible = true
	stopBtn.visible = false
	pass # Replace with function body.

func setId(_id):
	
	id = _id
	recordingIdLabel.text = RECORDING_STR+str(id)
	
func getId():
	return id
	
func _on_play_pressed():
	emit_signal("play")
	playBtn.visible = false
	stopBtn.visible = true
	pass
func _on_stop_pressed():
	emit_signal("stop")
	playBtn.visible = true
	stopBtn.visible = false
	pass
func _on_erase_pressed():
	emit_signal("erase")
func _on_reversal_toggle_pressed():
	emit_signal("toggle_reversal_action",reversalCheckbox.pressed)
	pass