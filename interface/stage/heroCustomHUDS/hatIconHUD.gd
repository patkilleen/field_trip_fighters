extends Node2D

var ballCapIcon = null
var leftArrowIcon=null
var rightArrowIcon=null
var upDownArrowIcon=null

func _ready():
	ballCapIcon = get_node("ball-cap-icon")
	leftArrowIcon=get_node("ball-cap-left-of-hat")
	rightArrowIcon=get_node("ball-cap-right-of-hat")
	upDownArrowIcon=get_node("ball-cap-above-or-below-hat")
	hideAll()

func hideAll():
	self.visible = false
	ballCapIcon.visible=false
	leftArrowIcon.visible = false
	rightArrowIcon.visible = false
	upDownArrowIcon.visible = false
	
func showLeftIcon():
	self.visible = true
	ballCapIcon.visible=true
	leftArrowIcon.visible = true
	rightArrowIcon.visible = false
	upDownArrowIcon.visible = false
	
func showRightIcon():
	self.visible = true
	ballCapIcon.visible=true
	leftArrowIcon.visible = false
	rightArrowIcon.visible = true
	upDownArrowIcon.visible = false
	
func showUpDownIcon():
	self.visible = true
	ballCapIcon.visible=true
	leftArrowIcon.visible = false
	rightArrowIcon.visible = false
	upDownArrowIcon.visible = true