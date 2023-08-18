extends Node2D

@export var title : String = '' :
	get:
		return title
	set(value):
		title = value
		%Title.text = title
@export var subtitle : String = '' :
	get:
		return subtitle
	set(value):
		subtitle = value
		%Title.text = subtitle

func _ready():
	%Title.text = title
	%Subtitle.text = subtitle
