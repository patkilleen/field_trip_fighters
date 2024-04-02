extends ColorRect

enum UniversalMove{
	NA,
	AUTO_RIPOST,
	RIPOST,
	COUNTER_RIPOST,
	ABILITY_CANCEL,
	PUSH_BLOCK,
	TECH,
	GRAB,
	MAGIC_SERIES,
	CROUCH,
	JUMP,
	GROUND_DASH_FORWARD,
	GROUND_DASH_BACK,
	CROUCH_CANCEL,
	AIR_DASH_FORWARD,
	AIR_DASH_BACK,
	FAST_FALL,
	LANDING_LAG
}


enum ProjectileFrameDataType{
	BASIC,
	SINGLE_ANIMATION,
	FUSE_MANY_ANIMATIONS
}


export (int) var actionId=-1
export (String) var type = ""
export (String) var description=""
var nameLabel = null
export (int, FLAGS, "Basic","On-hit", "on-hit auto ability cancel", "landing lag", "on-hit landing lag") var autoCancelsTypeBlackList = 0

export (bool) var disableComboCancelView = false #true means can't look at auto-cancels
export (bool) var staleAnimation = false
export (int) var stanceIx = 0 #used to get the dsecription and auto cancel action id list
export (int) var autoCancelNamingStanceIx = -1 #-1 means use same stance as stanceIx when getting names of action ids for auto cancel name loojup.  when > -1, means the stance changed as a result of the cancel, so names of actions change
export (int) var comboCancelActionId=-1 # <= -1 means use actionId for both the description and combo cancel details. > -1 means use this action id to determine the auto cancel (useful for on hit animations)
export (int) var specialCase=-1 # <= -1  means do nothing special. > -1 means a special case is to be considered, like GRAB
export (UniversalMove) var universalMove = 0 #anything but NA means the NewComboList will use a global name and description
export (String) var additionalProperties = ""

export (int) var autoCancelNextRekaActionId = -1 #> -1 means this entry canceling into itself will display it's reka's aciton name (instead of showing it's own name)
export (int) var autoCancelPreviousRekaActionId = -1 #> -1 means this entry was canceled into by previous reka
export (bool) var ignoreHitstunMeatyProperty=false #true means if has meaty hitbox, not illustrated in properties
export (bool) var ignoreBlockMeatyProperty=false #true means if has meaty hitbox, not illustrated in properties
export (int, FLAGS, "Jump","F-Jump", "B-Jump","Ground Idle","Ground F-Move","Ground B-Move" ,"Crouch","N-Melee","N-Special","N-Tool","B-Special","auto ripost","Air Idle","Air F-Move","Air B-Move", "Air F-Dash", "Air B-Dash","Air-Melee","Air-Special","Air-Tool","Fast Fall","Air Move Stop", "Air auto ripost","F-Special","D-Melee","U-Tool","D-Tool","F-Tool","B-Tool","U-Special","F-Melee","B-Special") var autoCancelBlackList = 0
export (int, FLAGS, "D-Special","B-Melee","U-Melee","F-Ground-Dash","B-Ground-Dash", "Air-grab","grab","crouching-hold-back-block","Platform Drop", "Leave Platform Keep Animation","F-dash crouch cancel","non-cancelable f-ground-dash","non-cancelable b-ground-dash","apex-of-jump-only fast-fall","standing-hold-back-block","air-hold-back-block","standing-push-block","air-push-block","Air Jump","Air F-Jump", "Air B-Jump","b-dash-Crouch-cancel", "basic crouch cancel", "non-GDC jump","non-GDC F-jump", "non-GDC b-jump") var autoCancelBlackList2 = 0
export (int) var additionalStartupFrames = 0
export (String) var hitAdvantageOverride=""
export (String) var linkHitAdvantageOverride=""
export (String) var goodBlockAdvantageOverride=""
export (String) var badBlockAdvantageOverride=""
export (String) var startupAdvOverride=""
export (String) var recoveryAdvOverride=""
export (String) var activeAdvOverride=""
export (String) var projectileOverrideNodePath=""
export (bool) var displayRawMeatyFrameData=false #false means advantage frame data is relative.  true means raw duration displayed

export (ProjectileFrameDataType) var projectileFrameDataType = 0 
export (String) var fusedCSVActionIDs=""#WHEN projectileFrameDataType is FUSE_MANY_ANIMATIONS, this is used to specify actions via items seperated by commas
export (bool) var ignoreOnHitAnimationDuration=false #true means don't use duration of on hit animation to copute frame data for hit and blokcing
export (bool) var addKnockdownOkiDurationToHitstun = false #true means add the duraitn of oki konckdown hitstun to frame data on hit computation
export (bool) var replaceHitAdvWithKnockdown=false #true means hitadvantage replaced with 'knockdown'
export (int) var startupFrameDataOverideActionId=-1 #non -1 means we override startup frame calculation using this action id
export (int) var activeFrameDataOverideActionId=-1 #non -1 means we override active frame and hit frame data calculation using this action id
export (int) var recoveryFrameDataOverideActionId=-1 #non -1 means we override recovery frame calculation using this action id
#note that for grab, we making strong assumption that for all the different throw directions, same sprite animation is use. True for now, but in future will need to think about this (or if they all have same frame data, this assumption holds)

#const AUTO_CANCEL_COMMANDS_BASIC = 0 #masks: autoCancels +autoCancels2
#const AUTO_CANCEL_COMMANDS_ONHIT=1 #autoCancelsOnHit + autoCancelsOnHit2 + autoCancelsOnHitAllAnimation +autoCancelsOnHitAllAnimation2
#const AUTO_CANCEL_COMMANDS_ALL=2
#const AUTO_CANCEL_COMMANDS_ONHIT_AUTO_ABILITY_CANCEL=3 #abilityAutoCancelsOnHit+abilityAutoCancelsOnHit2
#const AUTO_CANCEL_COMMANDS_LANDING_LAG_CANCEL=4#landingLagAutoCancels+landingLagAutoCancels2
#const AUTO_CANCEL_COMMANDS_ON_HIT_LANDING_LAG_CANCEL=5#landingLagAutoCancelsOnHit+landingLagAutoCancelsOnHit2
func _ready():
	if self.has_node("container/moveName"):
		nameLabel = $"container/moveName"
	#else:
	#	print("bug in combo list, missing child node 'container/moveName' in node of type: "+str(type))
		
	pass
	
func getName():
	if nameLabel != null:
		return nameLabel.text
	else:
		return ""
	
func setName(text):
	nameLabel.text=text