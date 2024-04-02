extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const DEFAULT_VALUE = 0
var window = []

var initiated = false

var locked = false
const HEAD_IX = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(_size):
	locked = false
	if _size == null or _size <= 0:
		return 
	
	initiated=true
	
	
	var i = 0
	
	#populate window with empty counts
	while i <_size:
		window.push_front(DEFAULT_VALUE)
		i = i +1

#makes the counter immutable
func lock():
	locked = true

#makes the counter changable again
func unlock():
	locked=false	
#increments counter by 1
func increment():
	
	if not locked:
		window[HEAD_IX] = window[HEAD_IX] +1
	
	
#decrements counter by 1
func decrement():
	if not locked:
		window[HEAD_IX] = window[HEAD_IX] -1
	
	
#decrements counter by X
func decrementX(x):
	if not locked:
		window[HEAD_IX] = window[HEAD_IX] -x
	
	
#incrementX counter by X
func incrementX(x):
	if not locked:
		window[HEAD_IX] = window[HEAD_IX] +x
	

#sets all values to 0 in window	
func reset():
	unlock()
	for i in window.size():
		window[i]=DEFAULT_VALUE
			
#progress by one time period, forgetting oldest chnage
func update():
	if not locked:
		window.push_front(DEFAULT_VALUE)
		window.pop_back()

#computes sum of elements in window
func computeSum():
	var res = 0
	
	for v in window:
		res = res + v
	
	return res