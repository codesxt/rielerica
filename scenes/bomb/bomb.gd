extends Node2D

@onready var Animations = $AnimationPlayer

func _ready():
	pass

func fall_and_explode():
	Animations.play('Fall')
	await Animations.animation_finished
	queue_free()
