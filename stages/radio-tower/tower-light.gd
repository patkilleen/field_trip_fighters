extends Sprite



export (float) var lightUpDuration = 0.15 #  seconds to brighten the light to full
export (float) var dimDuration = 0.15 #  seconds to dim the light to  transparent
export (float) var fullLightDuration = 0.04 #  seconds that the light remains full power before dimming
export (float) var blinkFrequency = 3 # 3 seconds between blinks
export (float) var initialBlinkDelay =0 #number of seconds to wait before starting the blink process. useful to desychrnoize two lights

const MyTweenResource = preload("res://MyTween.gd")
const hitFreezeAwareFrameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")

var lightUpTween=null
var dimTween=null

var blinkFreqTimer = null
var fullPowerLightTimer = null
var initDelayTimer = null

var lightFullPowerModulation = null
var lightTurnedOffModulation = null

var enabled=true
func _ready():
	blinkFreqTimer = hitFreezeAwareFrameTimerResource.new()
	add_child(blinkFreqTimer)
	blinkFreqTimer.connect("timeout",self,"startBlink")
	
	fullPowerLightTimer = hitFreezeAwareFrameTimerResource.new()
	add_child(fullPowerLightTimer)
	fullPowerLightTimer.connect("timeout",self,"startDim")
	
	initDelayTimer = hitFreezeAwareFrameTimerResource.new()
	add_child(initDelayTimer)
	initDelayTimer.connect("timeout",self,"startDim")
	
	
	
	
	lightUpTween=MyTweenResource.new()
	dimTween=MyTweenResource.new()
	
	add_child(lightUpTween)
	add_child(dimTween)
	
	dimTween.ignoreHitFreeze=false
	lightUpTween.ignoreHitFreeze=false
	
	lightUpTween.connect("finished",self,"startFullLightTimer")
	dimTween.connect("finished",self,"startBlinkFreqTimer")
	
	lightFullPowerModulation = self.modulate
	
	#transparent when light is off
	lightTurnedOffModulation = lightFullPowerModulation
	lightTurnedOffModulation.a = 0 
	
	if initialBlinkDelay > 0:
		self.visible = false #for the moment we wait to desycn, don't appear on
		initDelayTimer.startInSeconds(initialBlinkDelay)
		#wait a momemnt before start to dim
		yield(initDelayTimer,"timeout")
		self.visible = true 
	
	##sttart the blink process
	startDim()

func startFullLightTimer():
	
	fullPowerLightTimer.startInSeconds(fullLightDuration)
	pass
func startBlinkFreqTimer():
	
	if enabled:
		blinkFreqTimer.startInSeconds(blinkFrequency)
	pass
	
func enable():
	enabled=true
	blinkFreqTimer.startInSeconds(blinkFrequency)
	
func disable():
	enabled=false
	
func startBlink():
	lightUpTween.start_interpolate_property(self,"modulate",lightTurnedOffModulation,lightFullPowerModulation,lightUpDuration)
func startDim():
	dimTween.start_interpolate_property(self,"modulate",lightFullPowerModulation,lightTurnedOffModulation,dimDuration)
	
	