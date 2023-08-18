extends CharacterBody2D
class_name Player

@onready var NavigationAgent = $NavigationAgent2D
@onready var Animator = $AnimationPlayer

@export var player_name: String = ''
@export var is_paused: bool = false

signal target_reached

var did_arrive : bool = false

var sprites : Array[Vector2] = [
	Vector2(0, 7),
	Vector2(1, 7),
	Vector2(2, 7),
	Vector2(3, 7),
	Vector2(4, 7),
	Vector2(0, 8),
	Vector2(1, 8),
	Vector2(2, 8),
	Vector2(3, 8),
	Vector2(4, 8),
	Vector2(0, 9),
	Vector2(1, 9),
	Vector2(2, 9),
	Vector2(3, 9),
	Vector2(4, 9),
	Vector2(0, 10),
	Vector2(1, 10),
	Vector2(2, 10),
	Vector2(3, 10),
	Vector2(4, 10)
]

func _ready():
	$Label.text = player_name
	Animator.play("Idle")
	$Sprite2D.frame_coords = sprites.pick_random()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _physics_process(_delta):
	if not visible:
		return
	
	if is_paused == true:
		velocity = Vector2.ZERO
	else:
		var move_direction = position.direction_to(NavigationAgent.get_next_path_position())
		velocity = move_direction * 64
	NavigationAgent.velocity = velocity

func explode():
	Animator.play('Explode')
	await Animator.animation_finished

func slide():
	Animator.play('Slide')
	await Animator.animation_finished

func set_target_location(target: Vector2) -> void:
	Animator.play("Walk")
	did_arrive = false
	NavigationAgent.target_position = target

func _arrived_at_location() -> bool:
	return NavigationAgent.is_navigation_finished()

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	if not _arrived_at_location():
		velocity = safe_velocity
		move_and_slide()
	elif not did_arrive:
		did_arrive = true
		Animator.play("Idle")
		target_reached.emit(self)
