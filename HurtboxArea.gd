extends "SpriteCollisionArea.gd"


#same as GLOBALS, TODO: make only in globalas
const SUBCLASS_BASIC = 0
const SUBCLASS_HYPER_ARMOR = 1
const SUBCLASS_HEAVY_ARMOR = 2
const SUBCLASS_INVINCIBILITY = 3
const SUBCLASS_SUPER_ARMOR = 4

export (int, "Basic","Hyper Armor","Heavy Armor","Invincibility","Super Armor") var subClass = 0

export (float) var heavyArmorDamageLimit = 0 
export (float) var damageResistance = 1 #1 is 1 x relative damage = normal damage. 0.5 = half damag. 2 = vunlernability twice damage
export (bool) var is_projectile = false
export (bool) var preventAutocancelOnHit = false
export (bool) var canHoldBackBlock= false
export (bool) var projectileInvulnerability= false
export (int) var onGettingHitCounterActionId= -1
export (int) var superArmorHitLimit= 0 #number of hits before super armor breaks