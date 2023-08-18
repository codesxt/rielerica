extends Node2D

@onready var Animations = $AnimationPlayer

@export var cart_speed : int = 32
@export var payload : String = 'small'

var target = null

signal target_reached

func _ready():
	randomize()
	select_payload()
	engine_start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	position.x += cart_speed * delta
#	pass
	if target != null:
		var direction = position.direction_to(target)
		var velocity  = direction * cart_speed * delta
		position = position + velocity
#		position.x += cart_speed * delta
#		print(position.x, target.x)
		if abs(position.x - target.x) < 0.3:
			target = null
			target_reached.emit()

func select_payload():
	var value = randf()
	# small_bomb 40
	# normal_bomb 30
	# large_bomb 20
	# giant_bomb 10
	if value < 0.4:
		payload = 'small_bomb'
	elif value < 0.7:
		payload = 'normal_bomb'
	elif value < 0.9:
		payload = 'large_bomb'
	else:
		payload = 'giant_bomb'
		
	if payload == 'small_bomb':
		$BombSprite.frame_coords = Vector2(0,0)
	elif payload == 'normal_bomb':
		$BombSprite.frame_coords = Vector2(1,0)
	elif payload == 'large_bomb':
		$BombSprite.frame_coords = Vector2(2,0)
	elif payload == 'giant_bomb':
		$BombSprite.frame_coords = Vector2(3,0)

func engine_start():
	Animations.play("Engine")
	
func engine_stop():
	Animations.play("RESET")

func bomb_up():
	Animations.play("BombUp")
	await Animations.animation_finished

func move_to_target(target: Vector2):
	self.target = target
