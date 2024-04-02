extends Node

signal successful_tech #params: timeLeftInFrames techType = GLOBALS.{GROUND_TECH_IN_PLACE,GROUND_TECH_ROLL_BACKWARD,GROUND_TECH_ROLL_FORWARD,AIR_TECH_IN_PLACE}
signal failed_tech
signal tech_window_lock_expired

const GLOBALS = preload("res://Globals.gd")
const input_manager_resource = preload("res://input_manager.gd")
export (int) var techWindowFrameLength = 20 setget setTechWindowFrameLength,getTechWindowFrameLength
export (int) var techWindowLockFrameLength = 40 setget setTechWindowLockFrameLength,getTechWindowLockFrameLength
var techWindowLengthInSeconds = 0
var techWindowLockLengthInSeconds = 0

#true when player has attempted tech, and awaiting a landing
var techWindowActiveFlag=false

#true when a lock on tech attempts is in place
var techWindowLockActiveFlag=false

#TIMERS for tracking windows
var techWindowLockTimer = null
var techWindowTimer = null


#below two flags used to resolve the type of tech
#true when player inputed left or right
var holdingDirectionFlag = false
#when holdingDirectionFlag == true: false when player held backward, true when player held forward
var forwardHeldFlag = false

var frameTimerResource = preload("res://hitFreezeAwareFrameTimer.gd")


#const CEILING = 0
#const FLOOR = 1
#const WALL = 2

var techTypeActionMap = {}
var techExceptions = 0

var techCollisionTypeMap={}

enum DirectionalInput{
	UP,#0
	FORWARD_UP,#1
	FORWARD,#2
	FORWARD_DOWN,#3
	DOWN,#4
	BACKWARD_DOWN,#5
	BACKWARD,#6
	BACKWARD_UP,	#7,
	NEUTRAL
}
var actionAnimeManager = null

var dirInput = DirectionalInput.NEUTRAL

var diCmdMap = {}

var fixedDeltaFlag=  false
func _ready():
	#init()
	pass


func init(_actionAnimeManager):
	
	actionAnimeManager = _actionAnimeManager
	#convert frames to seconds
	
	techWindowLengthInSeconds = techWindowFrameLength*GLOBALS.SECONDS_PER_FRAME
	techWindowLockLengthInSeconds = techWindowLockFrameLength*GLOBALS.SECONDS_PER_FRAME
	
	
	
	
	techWindowActiveFlag=false
	techWindowLockActiveFlag=false
	holdingDirectionFlag = false
	forwardHeldFlag = false
	
	
	#initialize the timers
	
	#don't create new timers if already created, just reset
	if techWindowTimer ==null:
		techWindowTimer = frameTimerResource.new()
		techWindowTimer.connect("timeout",self,"_on_tech_window_timout")
		self.call_deferred("add_child",techWindowTimer)
	else:
		techWindowTimer.stop()
		
	
	
	
	if techWindowLockTimer ==null:
		techWindowLockTimer = frameTimerResource.new()
		techWindowLockTimer.connect("timeout",self,"_on_tech_window_lock_timout")
		self.call_deferred("add_child",techWindowLockTimer)
	else:
		techWindowLockTimer.stop()
	
	dirInput = DirectionalInput.NEUTRAL
		
	populateTechTypeActionMap(actionAnimeManager)
	populateDICmdMap()
	populateDirectionTypeMap()
	reset()
	

func reset():
	
	techWindowActiveFlag=false
	techWindowLockActiveFlag=false
	holdingDirectionFlag = false
	forwardHeldFlag = false
	techExceptions=0
	
	techWindowTimer.stop()
	techWindowLockTimer.stop()
	dirInput = DirectionalInput.NEUTRAL
func populateDirectionTypeMap():
	#POPULATE MAPS TO QUICKLY LOOKUP DI and collision environment to decide type of tech
	techCollisionTypeMap[GLOBALS.TECH_CEILING_IX]={}
	techCollisionTypeMap[GLOBALS.TECH_CEILING_IX][DirectionalInput.NEUTRAL] =GLOBALS.TYPE_CEILING_TECH_IN_PLACE
	techCollisionTypeMap[GLOBALS.TECH_CEILING_IX][DirectionalInput.UP] =GLOBALS.TYPE_CEILING_TECH_IN_PLACE #since against ceiling, can't tech up, so tech in place
	techCollisionTypeMap[GLOBALS.TECH_CEILING_IX][DirectionalInput.FORWARD_UP] =GLOBALS.TYPE_CEILING_TECH_BOUNCE_FORWARD
	techCollisionTypeMap[GLOBALS.TECH_CEILING_IX][DirectionalInput.FORWARD] =GLOBALS.TYPE_CEILING_TECH_BOUNCE_FORWARD
	techCollisionTypeMap[GLOBALS.TECH_CEILING_IX][DirectionalInput.FORWARD_DOWN] =GLOBALS.TYPE_CEILING_TECH_BOUNCE_DOWN	
	techCollisionTypeMap[GLOBALS.TECH_CEILING_IX][DirectionalInput.DOWN] =GLOBALS.TYPE_CEILING_TECH_BOUNCE_DOWN
	techCollisionTypeMap[GLOBALS.TECH_CEILING_IX][DirectionalInput.BACKWARD_DOWN] =GLOBALS.TYPE_CEILING_TECH_BOUNCE_DOWN
	techCollisionTypeMap[GLOBALS.TECH_CEILING_IX][DirectionalInput.BACKWARD] =GLOBALS.TYPE_CEILING_TECH_BOUNCE_BACK
	techCollisionTypeMap[GLOBALS.TECH_CEILING_IX][DirectionalInput.BACKWARD_UP] =GLOBALS.TYPE_CEILING_TECH_BOUNCE_BACK
	
	
	techCollisionTypeMap[GLOBALS.TECH_FLOOR_IX]={}
	techCollisionTypeMap[GLOBALS.TECH_FLOOR_IX][DirectionalInput.NEUTRAL] =GLOBALS.TYPE_GROUND_TECH_IN_PLACE
	techCollisionTypeMap[GLOBALS.TECH_FLOOR_IX][DirectionalInput.UP] =GLOBALS.TYPE_GROUND_TECH_BOUNCE_UP 
	techCollisionTypeMap[GLOBALS.TECH_FLOOR_IX][DirectionalInput.FORWARD_UP] =GLOBALS.TYPE_GROUND_TECH_BOUNCE_UP
	techCollisionTypeMap[GLOBALS.TECH_FLOOR_IX][DirectionalInput.FORWARD] =GLOBALS.TYPE_GROUND_TECH_ROLL_FORWARD
	techCollisionTypeMap[GLOBALS.TECH_FLOOR_IX][DirectionalInput.FORWARD_DOWN] =GLOBALS.TYPE_GROUND_TECH_ROLL_FORWARD	
	techCollisionTypeMap[GLOBALS.TECH_FLOOR_IX][DirectionalInput.DOWN] =GLOBALS.TYPE_GROUND_TECH_IN_PLACE #since against GLOBALS.TECH_FLOOR_IX, can't tech down, so tech in place
	techCollisionTypeMap[GLOBALS.TECH_FLOOR_IX][DirectionalInput.BACKWARD_DOWN] =GLOBALS.TYPE_GROUND_TECH_ROLL_BACKWARD
	techCollisionTypeMap[GLOBALS.TECH_FLOOR_IX][DirectionalInput.BACKWARD] =GLOBALS.TYPE_GROUND_TECH_ROLL_BACKWARD
	techCollisionTypeMap[GLOBALS.TECH_FLOOR_IX][DirectionalInput.BACKWARD_UP] =GLOBALS.TYPE_GROUND_TECH_BOUNCE_UP
	

	techCollisionTypeMap[GLOBALS.TECH_WALL_IX]={}
	techCollisionTypeMap[GLOBALS.TECH_WALL_IX][DirectionalInput.NEUTRAL] =GLOBALS.TYPE_WALL_TECH_IN_PLACE
	techCollisionTypeMap[GLOBALS.TECH_WALL_IX][DirectionalInput.UP] =GLOBALS.TYPE_WALL_TECH_BOUNCE_UP 
	techCollisionTypeMap[GLOBALS.TECH_WALL_IX][DirectionalInput.FORWARD_UP] =GLOBALS.TYPE_WALL_TECH_BOUNCE_AWAY
	techCollisionTypeMap[GLOBALS.TECH_WALL_IX][DirectionalInput.FORWARD] =GLOBALS.TYPE_WALL_TECH_BOUNCE_AWAY
	techCollisionTypeMap[GLOBALS.TECH_WALL_IX][DirectionalInput.FORWARD_DOWN] =GLOBALS.TYPE_WALL_TECH_BOUNCE_AWAY	
	techCollisionTypeMap[GLOBALS.TECH_WALL_IX][DirectionalInput.DOWN] =GLOBALS.TYPE_WALL_TECH_BOUNCE_DOWN 
	techCollisionTypeMap[GLOBALS.TECH_WALL_IX][DirectionalInput.BACKWARD_DOWN] =GLOBALS.TYPE_WALL_TECH_BOUNCE_DOWN
	techCollisionTypeMap[GLOBALS.TECH_WALL_IX][DirectionalInput.BACKWARD] =GLOBALS.TYPE_WALL_TECH_IN_PLACE#since against wall AND facing towards center of sptage can't tech toward back, so stay in place
	techCollisionTypeMap[GLOBALS.TECH_WALL_IX][DirectionalInput.BACKWARD_UP] =GLOBALS.TYPE_WALL_TECH_BOUNCE_UP
	
func populateDICmdMap():
	
	#maps all the command  to direction enum
	
	diCmdMap[input_manager_resource.Command.CMD_UP] = DirectionalInput.UP
	diCmdMap[input_manager_resource.Command.CMD_UPWARD_MELEE] = DirectionalInput.UP
	diCmdMap[input_manager_resource.Command.CMD_UPWARD_SPECIAL] = DirectionalInput.UP
	diCmdMap[input_manager_resource.Command.CMD_UPWARD_TOOL] = DirectionalInput.UP
	
	
	diCmdMap[input_manager_resource.Command.CMD_FORWARD_UP] = DirectionalInput.FORWARD_UP
	diCmdMap[input_manager_resource.Command.CMD_FORWARD_UP_PUSH_BLOCK] = DirectionalInput.FORWARD_UP
	
	#diCmdMap[input_manager_resource.Command.CMD_GRAB] = DirectionalInput.FORWARD #HOLDING/PRESESD forward, released up
	diCmdMap[input_manager_resource.Command.CMD_MOVE_FORWARD] = DirectionalInput.FORWARD
	diCmdMap[input_manager_resource.Command.CMD_JUMP_FORWARD] = DirectionalInput.FORWARD
	diCmdMap[input_manager_resource.Command.CMD_FORWARD_MELEE] = DirectionalInput.FORWARD
	diCmdMap[input_manager_resource.Command.CMD_FORWARD_SPECIAL] = DirectionalInput.FORWARD
	diCmdMap[input_manager_resource.Command.CMD_FORWARD_TOOL] = DirectionalInput.FORWARD
	diCmdMap[input_manager_resource.Command.CMD_FORWARD_PUSH_BLOCK] = DirectionalInput.FORWARD
	

	diCmdMap[input_manager_resource.Command.CMD_BACKWARD_UP] = DirectionalInput.BACKWARD_UP
	diCmdMap[input_manager_resource.Command.CMD_BACKWARD_UP_PUSH_BLOCK] = DirectionalInput.BACKWARD_UP
	
	
	diCmdMap[input_manager_resource.Command.CMD_CROUCH] = DirectionalInput.DOWN
	diCmdMap[input_manager_resource.Command.CMD_AIR_DASH_DOWNWARD] = DirectionalInput.DOWN
	diCmdMap[input_manager_resource.Command.CMD_DOWNWARD_MELEE] = DirectionalInput.DOWN
	diCmdMap[input_manager_resource.Command.CMD_DOWNWARD_SPECIAL] = DirectionalInput.DOWN
	diCmdMap[input_manager_resource.Command.CMD_DOWNWARD_TOOL] = DirectionalInput.DOWN
	
	
	diCmdMap[input_manager_resource.Command.CMD_FORWARD_CROUCH] = DirectionalInput.FORWARD_DOWN
	diCmdMap[input_manager_resource.Command.CMD_FORWARD_CROUCH_PUSH_BLOCK] = DirectionalInput.FORWARD_DOWN
	
	
	diCmdMap[input_manager_resource.Command.CMD_BACKWARD_CROUCH] = DirectionalInput.BACKWARD_DOWN
	diCmdMap[input_manager_resource.Command.CMD_BACKWARD_CROUCH_PUSH_BLOCK] = DirectionalInput.BACKWARD_DOWN
	
	
	diCmdMap[input_manager_resource.Command.CMD_MOVE_BACKWARD] = DirectionalInput.BACKWARD
	#diCmdMap[input_manager_resource.Command.CMD_BACKWARD_UP_RELEASE] = DirectionalInput.BACKWARD#HOLDING/PRESESD backward, released up
	diCmdMap[input_manager_resource.Command.CMD_JUMP_BACKWARD] = DirectionalInput.BACKWARD
	diCmdMap[input_manager_resource.Command.CMD_BACKWARD_MELEE] = DirectionalInput.BACKWARD
	diCmdMap[input_manager_resource.Command.CMD_BACKWARD_SPECIAL] = DirectionalInput.BACKWARD
	diCmdMap[input_manager_resource.Command.CMD_BACKWARD_TOOL] = DirectionalInput.BACKWARD
	diCmdMap[input_manager_resource.Command.CMD_DASH_BACKWARD] = DirectionalInput.BACKWARD #DON'T INlucnde dash forward, seince forward dash is default dash from just R2/trigger press
	diCmdMap[input_manager_resource.Command.CMD_BACKWARD_PUSH_BLOCK] = DirectionalInput.BACKWARD
	
	
	#diCmdMap[null] = DirectionalInput.NEUTRAL
func populateTechTypeActionMap(actionAnimeManager):
	
	#GROUND techs
	techTypeActionMap[GLOBALS.TYPE_GROUND_TECH_IN_PLACE]= actionAnimeManager.GROUND_IN_PLACE_TECH_ACTION_ID
	techTypeActionMap[GLOBALS.TYPE_GROUND_TECH_BOUNCE_UP]= actionAnimeManager.GROUND_BOUNCE_UP_TECH_ACTION_ID
	techTypeActionMap[GLOBALS.TYPE_GROUND_TECH_ROLL_BACKWARD]= actionAnimeManager.ROLLING_BACKWARD_TECH_ACTION_ID
	techTypeActionMap[GLOBALS.TYPE_GROUND_TECH_ROLL_FORWARD]= actionAnimeManager.ROLLING_FORWARD_TECH_ACTION_ID
	
	#wall
	techTypeActionMap[GLOBALS.TYPE_WALL_TECH_IN_PLACE]= actionAnimeManager.WALL_TECH_ACTION_ID
	techTypeActionMap[GLOBALS.TYPE_WALL_TECH_BOUNCE_UP]= actionAnimeManager.WALL_BOUNCE_UP_TECH_ACTION_ID
	techTypeActionMap[GLOBALS.TYPE_WALL_TECH_BOUNCE_DOWN]= actionAnimeManager.WALL_BOUNCE_DOWN_TECH_ACTION_ID
	techTypeActionMap[GLOBALS.TYPE_WALL_TECH_BOUNCE_AWAY]= actionAnimeManager.WALL_BOUNCE_AWAY_TECH_ACTION_ID
	
	#ceiling
	techTypeActionMap[GLOBALS.TYPE_CEILING_TECH_IN_PLACE]= actionAnimeManager.CEILING_TECH_ACTION_ID
	techTypeActionMap[GLOBALS.TYPE_CEILING_TECH_BOUNCE_DOWN]= actionAnimeManager.CEILING_BOUNCE_DOWN_TECH_ACTION_ID
	techTypeActionMap[GLOBALS.TYPE_CEILING_TECH_BOUNCE_FORWARD]= actionAnimeManager.CEILING_BOUNCE_FORWARD_TECH_ACTION_ID
	techTypeActionMap[GLOBALS.TYPE_CEILING_TECH_BOUNCE_BACK]= actionAnimeManager.CEILING_BOUNCE_BACK_TECH_ACTION_ID
	
func setTechWindowFrameLength(_len):
	techWindowFrameLength = _len
	techWindowLengthInSeconds = techWindowFrameLength*GLOBALS.SECONDS_PER_FRAME
	
	
	
	
func getTechWindowFrameLength():
	return techWindowFrameLength
	
func setTechWindowLockFrameLength(_len):
	techWindowLockFrameLength = _len
	techWindowLockLengthInSeconds = techWindowLockFrameLength*GLOBALS.SECONDS_PER_FRAME
	
	
func getTechWindowLockFrameLength():
	return techWindowLockFrameLength
	
	

#input the direction of the tech
#true = forward
#false = back
#func attemptHorizontalTech(directionFlag):
	#only allow input to DI a tech if active 
	#if techWindowActiveFlag:
		#holdingDirectionFlag=true
		#forwardHeldFlag=directionFlag
		
		#if forwardHeldFlag:
			#dirInput = TechDirection.FORWARD
		#else:
			#dirInput = TechDirection.BACK

#input the direction of the tech
#true = up
#false = down
#func attemptVerticalTech(directionFlag):
	#only allow input to DI a tech if active 
#	if techWindowActiveFlag:
#		holdingDirectionFlag=true
		
#		if directionFlag:
#			dirInput = TechDirection.UP
#		else:
#			dirInput = TechDirection.DOWN
			
#activate the window to check for tech's upon landing/hitting-cieling
#returns a result code indicating (0:SUCCESFUL_TECH_WINDOW_START) if successfull, 
#(1:FAILED_FROM_LOCKED_WINDOW) if the window is locked, 
#(2:ALREADY_STARTED_TECH_WINDOW) if already activated window
func startTechWindow(_techExceptions):
	
	if techWindowLockActiveFlag:
		
		#extend the lock duration: don't spam so much noob
		startTechWindowLock()
		return GLOBALS.RC_FAILED_FROM_LOCKED_WINDOW
		
	if techWindowActiveFlag:
		#its okay to mash tech if already in the window, but don't extned
		#the tech window	
		return GLOBALS.RC_ALREADY_STARTED_TECH_WINDOW
	
	#reset the flags that trag DI (dir input)
	holdingDirectionFlag = false
	forwardHeldFlag = false
	
	techWindowActiveFlag = true
	#techWindowTimer.wait_time = techWindowLengthInSeconds
	#techWindowTimer.start()
	techWindowTimer.start(techWindowFrameLength)
	
	techExceptions=_techExceptions
	
	#dirInput = DirectionalInput.NEUTRAL #will tech in place by default until direction is pressed
	
	return GLOBALS.RC_SUCCESFUL_TECH_WINDOW_START

#activate the window of time to prevent players from spamming/mashing tech
func startTechWindowLock():
	
	#tech windows is active and trying to lock it?
	if(techWindowActiveFlag):
		print("warning: in tech handling, the tech window is being locked while active")
	
	#it is okay to reset the lock when button mashing tech spam	
	techWindowLockActiveFlag = true
	#techWindowLockTimer.wait_time = techWindowLockLengthInSeconds
	techWindowLockTimer.start(techWindowLockFrameLength)
	#techWindowLockTimer.re
	
func stopTechWindowLock():
	techWindowLockActiveFlag = false
	techWindowLockTimer.stop()
	
func stopTechWindow():
	techWindowActiveFlag = false
	techWindowTimer.stop()
	
######################
#signal handers
######################

#called when land on floor
func _on_land():
	_on_techable_environment_collision(GLOBALS.TECH_FLOOR_IX)
	
	
#called when hit ceiling
func _on_ceiling_collision(collider):
	_on_techable_environment_collision(GLOBALS.TECH_CEILING_IX)

#called when hit a wall
func _on_wall_collision(collider):
	_on_techable_environment_collision(GLOBALS.TECH_WALL_IX)	

func _on_techable_environment_collision(envType):
	
	var successfulTechFlag = false
	var timeLeftInFrames = 0
	var techType = 0
	#input tech ?
	if(techWindowActiveFlag):
		successfulTechFlag=true
		
		#tech'ed off ceiling?
		if envType == GLOBALS.TECH_CEILING_IX:
			
			#CAN'T tech ceiling?
			if techExceptions & GLOBALS.TECH_EXCEPTION_CEILING:
				return false
		elif envType == GLOBALS.TECH_WALL_IX: #on the wall?
			#CAN'T tech WALL?
			if techExceptions & GLOBALS.TECH_EXCEPTION_WALL:
				return false		
		else: #ground
			#can't tech on ground?
			if techExceptions & GLOBALS.TECH_EXCEPTION_FLOOR:
				return false
				
		#convert the time remaining of tech window into # of frames (sec/(sec/frames) = frames)
		#timeLeftInFrames = ceil(techWindowTimer.get_time_left()/GLOBALS.SECONDS_PER_FRAME)
		
			
		#resolve what type of tech we are doing
		techType = techCollisionTypeMap[envType][dirInput]
	
	if successfulTechFlag:
				
		timeLeftInFrames = techWindowTimer.get_time_left_in_frames()
				
	#no longer need to keep track of active tech window since we landed
	#note that we don't reset the lock window, since spamming is discoraged
	#so it may lead into messing up a tech for new combo too if spammed
	stopTechWindow()
	
	if successfulTechFlag:
				
		emit_signal("successful_tech",timeLeftInFrames,techType)

#returns true if the given encrionement tech can be tech'ed given tech exceptions
func canBeTeched(envType):
	
	

	#tech'ed off ceiling?
	if envType == GLOBALS.TECH_CEILING_IX:
		
		#CAN'T tech ceiling?
		if techExceptions & GLOBALS.TECH_EXCEPTION_CEILING:
			return false
	elif envType == GLOBALS.TECH_WALL_IX: #on the wall?
		#CAN'T tech WALL?
		if techExceptions & GLOBALS.TECH_EXCEPTION_WALL:
			return false		
	else: #ground
		#can't tech on ground?
		if techExceptions & GLOBALS.TECH_EXCEPTION_FLOOR:
			return false
	
	return true		

func OLD_on_techable_environment_collision(envType):
	
	var successfulTechFlag = false
	var timeLeftInFrames = 0
	var techType = 0
	#input tech ?
	if(techWindowActiveFlag):
		successfulTechFlag=true
		#convert the time remaining of tech window into # of frames (sec/(sec/frames) = frames)
		#timeLeftInFrames = ceil(techWindowTimer.get_time_left()/GLOBALS.SECONDS_PER_FRAME)
		timeLeftInFrames = techWindowTimer.get_time_left_in_frames()
			
		#tech'ed off ceiling?
		if envType == GLOBALS.TECH_CEILING_IX:
			
			#CAN'T tech ceiling?
			if techExceptions & GLOBALS.TECH_EXCEPTION_CEILING:
				successfulTechFlag=false
			techType=GLOBALS.TYPE_CEILING_TECH_IN_PLACE	
		elif envType == GLOBALS.TECH_WALL_IX: #on the wall?
			#CAN'T tech WALL?
			if techExceptions & GLOBALS.TECH_EXCEPTION_WALL:
				successfulTechFlag=false
			techType=GLOBALS.TYPE_WALL_TECH_IN_PLACE	
		elif not holdingDirectionFlag:#neutral/in-place tech?
			#CAN'T tech FLOOR?
			if techExceptions & GLOBALS.TECH_EXCEPTION_FLOOR:
				successfulTechFlag=false
			techType=GLOBALS.TYPE_GROUND_TECH_IN_PLACE
		elif forwardHeldFlag: #right roll tech
			#CAN'T tech FLOOR?
			if techExceptions & GLOBALS.TECH_EXCEPTION_FLOOR:
				successfulTechFlag=false
			techType=GLOBALS.TYPE_GROUND_TECH_ROLL_FORWARD
		else: #left roll tech
			#CAN'T tech FLOOR?
			if techExceptions & GLOBALS.TECH_EXCEPTION_FLOOR:
				successfulTechFlag=false
			techType=GLOBALS.TYPE_GROUND_TECH_ROLL_BACKWARD
	
		if not successfulTechFlag:
			emit_signal("failed_tech")
			return 
	#no longer need to keep track of active tech window since we landed
	#note that we don't reset the lock window, since spamming is discoraged
	#so it may lead into messing up a tech for new combo too if spammed
	stopTechWindow()
	
	if successfulTechFlag:
		
		#resolve the type of tech
		#GROUND_TECH_IN_PLACE,GROUND_TECH_ROLL_BACKWARD,GROUND_TECH_ROLL_FORWARD,AIR_TECH_IN_PLACE	
		#when holdingDirectionFlag == true: true when player held left, false when player held right
		#var forwardHeldFlag = false
		
		emit_signal("successful_tech",timeLeftInFrames,techType)
	

func _on_tech_window_lock_timout():
	techWindowLockActiveFlag = false
	emit_signal("tech_window_lock_expired")
	
#called after tech is input
# and when the tech window expires witouth landing or hitting cieling
func _on_tech_window_timout():
	
	techWindowActiveFlag = false
	#lock the teching window briefly, to prevent spamming of tech input
	startTechWindowLock()
	emit_signal("failed_tech")
	
	
func readyForFloorTech():
	return techWindowActiveFlag and not (techExceptions & GLOBALS.TECH_EXCEPTION_FLOOR)
	

#func setTechDI(cmd):	
	#is the command mapped to a directoin
#	if diCmdMap.has(cmd):
#		dirInput = diCmdMap[cmd]
#	else:
#		dirInput = DirectionalInput.NEUTRAL
		
		
func _on_directional_input(diEnum):
	
	
#	if not techWindowActiveFlag:
#		return
	
	if(techWindowActiveFlag):
		
		#no direction inputed?
		if diEnum == GLOBALS.DirectionalInput.NEUTRAL:
			
			#we can't override the tech directio if we already inputed a direction before the tech
			#to tech in place you have to press tech and not press anything
			
			return
		else:
			#although we can override the tech direction with another direction
			pass
			
	dirInput = diEnum
	
	

	
	
func _on_sprite_animation_played(spriteAnimation):
	if actionAnimeManager.isCurrentAniamtionHitstunAnimation():
		#update the tech exceptions since tech may have started in between
		#sprite aniamtion so tech exception wasn'tupdated
		var sa = actionAnimeManager.spriteAnimationManager.currentAnimation
		
		if sa != null:
			#might have frame perfect land/tech hitstun situation, so make sure the property iexsits
			if "techExceptions" in sa:
				techExceptions = sa.techExceptions
		