extends Node2D

@export var letter: String = ''

var sprites: Dictionary = {
	'A': Vector2(0,8),
	'B': Vector2(1,8),
	'C': Vector2(2,8),
	'D': Vector2(3,8),
	'E': Vector2(4,8),
	'F': Vector2(5,8),
	'G': Vector2(6,8),
	'H': Vector2(7,8),
	'I': Vector2(8,8),
	'J': Vector2(9,8),
	'K': Vector2(10,8),
	'L': Vector2(11,8),
	'M': Vector2(0,9),
	'N': Vector2(1,9),
	'O': Vector2(2,9),
	'P': Vector2(3,9),
	'Q': Vector2(4,9),
	'R': Vector2(5,9),
	'S': Vector2(6,9),
	'T': Vector2(7,9),
	'U': Vector2(8,9),
	'V': Vector2(9,9),
	'W': Vector2(10,9),
	'X': Vector2(11,9),
	'Y': Vector2(0,10),
	'Z': Vector2(1,10)
}

func _ready():
	set_letter_sprite(letter)

func set_letter_sprite(letter: String):
	var frame_coords = sprites.get(letter)
	if frame_coords != null:
		$Sprite2D.frame_coords = frame_coords
