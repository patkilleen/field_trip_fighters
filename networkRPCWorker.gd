extends Node

var thread = null

var semaphore = null

var active = false


var mutex = null
var rpcParamArrayRequests = []

var netMngr = null
func _ready():
	
	thread = Thread.new()
	semaphore = Semaphore.new()
	mutex = 	Mutex.new()

func start(_netMngr):
	active=true
	
	var rc = thread.start(self,"_workerFunc",[]) 
	if rc != OK:
		
		print("failed to start netowrk rpc thread")
		
	netMngr = _netMngr

#stops  thread and waits for it to finish
func stop():
	#stop thread
	active = false
	
	#wait for worker to finish
	if thread != null:
		thread.wait_to_finish()
		

#does a remote procedure call but asyncrhonously (in case main thread blocked)
#param array is of format: ["name-of-rpc-function-to-call", arg1, arg2, ... , argn]
func asyncrhonousRCP(_rpcParamArray):
	
	#null param array and arrays that have no function name inside are invalid
	if _rpcParamArray == null or _rpcParamArray.empty():
		return
		
	mutex.lock()
	rpcParamArrayRequests.append(_rpcParamArray)
	#let the worker know there is a request to do a rpc
	semaphore.post()
	mutex.unlock()
	
	
	
	
func _workerFunc(param):
	
	while(active):
		
		#wait for a rpc request to be issued
		semaphore.wait()
		
		mutex.lock()
		#iterate over all the requests and run them
		for i in rpcParamArrayRequests.size():
			var rpcParamArray = rpcParamArrayRequests[i]
			
			#call the remote process call function given dynamic function name and parameter array
			netMngr.callv("rpc",rpcParamArray)
		
		#clear all requests
		rpcParamArrayRequests.clear()
		
		mutex.unlock()
		