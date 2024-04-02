extends "res://particles/LandingDust.gd"

export (float) var duration = 1.0

func configureTimerWaitTime():
	if inHitFreezeFlag and pauseOnHitFreeze:
		return self.duration / speedBeforeHitFreeze #we put speed to 0 for particles in hitfreeze, so gotta use the original speed
	else:
		if self.speed_scale!=0:
			return self.duration / self.speed_scale
		else:
			return self.duration / speedBeforeHitFreeze