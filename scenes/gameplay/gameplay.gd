extends Node2D

@onready var Map = $Level/TileMap
@onready var CartSpawner = $CartSpawner
@onready var Ticker = $Ticker
@onready var Start = $Start
@onready var Remaining = $Remaining

var rail = []
var default_letters: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T']
var letters: Array[String]         = []

@export var rail_size : int = 20

var cart_instance = null

var players : Dictionary = {}

# Coordenada Y en la que se gatilla el toggle del riel
var TRIGGER_TILE_INDEX = 3

var seconds_remaining : int = 0

@export var is_paused: bool = false :
	get:
		return is_paused
	set(value):
		for child in get_children():
			if child is Player:
				child.is_paused = value

func _ready():
	_start_game()

func _start_game():
	_initialize_letters()
	_display_letters()
	start_timer()
	
	if cart_instance != null:
		cart_instance.queue_free()
		cart_instance = null
	
	rail = []
	for i in rail_size:
		rail.append(0)
	rail[0] = 1
	rail[1] = 1
	rail[2] = 1
	display_rails()
	
	$Label.text = ''
	$Remaining.text = ''
	is_paused = false

func _process(delta):
	if cart_instance != null:
		if $End.position.x - cart_instance.position.x < 0.1:
			despawn_cart()
			$CartSpawner.start()

func spawn_player(player_name: String):
	var existing_player = players.get(player_name)
	if existing_player == null:
		var scene = load("res://scenes/player/player.tscn")
		var instance = scene.instantiate()
		var cell := randi()%20+1
		instance.position = Vector2(8 * cell, 16)
		instance.player_name = player_name
		get_node('Players').add_child(instance)
		instance.target_reached.connect(_on_target_reached)
		
		players[player_name] = instance

func display_rails():
	Map.clear_layer(1)
	for i in len(rail):
		var rail_value = rail[i]
		if rail_value == 0:
			pass
		else:
			Map.set_cell(1, Vector2(i, 4), 0, Vector2(10, 5))

func toggle_at(i : int):
	if rail[i] == 0:
		rail[i] = 1
	else:
		rail[i] = 0
	display_rails()

func _on_cart_spawner_timeout():
	if len(players.keys()) > 0:
		spawn_cart()
		# Ocultar la cuenta regresiva
		Ticker.stop()
		Remaining.text = ''
	else:
		var gameover_scene = load("res://scenes/gameover/gameover.tscn")
		var gameover_instance = gameover_scene.instantiate()
		gameover_instance.title = 'No hay trabajadores disponibles'
		gameover_instance.subtitle = 'Se postergó el envío...'
		add_child(gameover_instance)
		
		await get_tree().create_timer(3).timeout
		gameover_instance.queue_free()
		start_timer()

func _on_target_reached(node: Node):
	var tile_coords = $Level/TileMap.local_to_map(node.position)
	
	if tile_coords.y == TRIGGER_TILE_INDEX:
		toggle_at(tile_coords.x)

func spawn_cart():
	var cart_scene = load("res://scenes/cart/cart.tscn")
	var instance = cart_scene.instantiate()
	instance.position = Start.position
	add_child(instance)
	cart_instance = instance
	run_through_rail()

func run_through_rail():
	var victory = false
	for i in len(rail):
		var target = Vector2(i * 16, 64)
		print(target)
		cart_instance.move_to_target(target)
		await cart_instance.target_reached
		var cell_value = rail[i]
		if cell_value == 0:
			victory = false
			break
		else:
			victory = true
	if victory == true:
		# MOSTRAR ESCENA DE VICTORIA
		await game_success()
		pass
	else:
		# MOSTRAR ESCENA DE PÉRDIDA
		await bomb_explode()
		pass

	_start_game()

func bomb_explode():
	is_paused = true
	await cart_instance.bomb_up()
	# Elegir castigado
	if len(players.keys()) > 0:
		var min_distance = 99999999
		var closest_player = ''
		for key in players:
			var dist = players[key].position.distance_to(cart_instance.position)
			if dist < min_distance:
				min_distance = dist
				closest_player = key
		var p = players.get(closest_player)
		
		var title := ''
		var subtitle := ''
		var timeout_seconds := 10 
	
		if cart_instance.payload == 'small_bomb':
			title = p.player_name + ' recibió una bomba pequeña'
			subtitle = '(timeout de 10 segundos)'
			timeout_seconds = 10
		elif cart_instance.payload == 'normal_bomb':
			title = p.player_name + ' recibió una bomba normal'
			subtitle = '(timeout de 30 segundos)'
			timeout_seconds = 30
		elif cart_instance.payload == 'large_bomb':
			title = p.player_name + ' recibió una bomba grande'
			subtitle = '(timeout de 60 segundos)'
			timeout_seconds = 60
		elif cart_instance.payload == 'giant_bomb':
			title = p.player_name + ' recibió una bomba gigante'
			subtitle = '(timeout de 3 minutos)'
			timeout_seconds = 180
		
		var scene = load("res://scenes/bomb/bomb.tscn")
		var instance = scene.instantiate()
		instance.position = p.position
		
		if cart_instance.payload == 'small_bomb':
			instance.get_node('BombSprite').frame_coords = Vector2(0,0)
		elif cart_instance.payload == 'normal_bomb':
			instance.get_node('BombSprite').frame_coords = Vector2(1,0)
		elif cart_instance.payload == 'large_bomb':
			instance.get_node('BombSprite').frame_coords = Vector2(2,0)
		elif cart_instance.payload == 'giant_bomb':
			instance.get_node('BombSprite').frame_coords = Vector2(3,0)
			
		p.z_index = 999
		add_child(instance)
		await instance.fall_and_explode()
		
		await p.explode()
		await p.slide()
		
		var gameover_scene = load("res://scenes/gameover/gameover.tscn")
		var gameover_instance = gameover_scene.instantiate()
		gameover_instance.title = title
		gameover_instance.subtitle = subtitle
		add_child(gameover_instance)
		
		$TwitchAPI.get_user('', p.player_name.to_lower())
		var response = await $TwitchAPI.response
		var twitch_user_id = response[3]['data'][0]['id']
		$TwitchAPI.ban_user(twitch_user_id, timeout_seconds, 'Banned in game')
		var response2 = await $TwitchAPI.response
		
		p.queue_free()
		players.erase(closest_player)
		
		await get_tree().create_timer(5).timeout
		gameover_instance.queue_free()

func game_success():
	var gameover_scene = load("res://scenes/gameover/gameover.tscn")
	var gameover_instance = gameover_scene.instantiate()
	gameover_instance.title = '¡Felicidades! ¡El cargamento llegó a su destino!'
	gameover_instance.subtitle = 'Nadie resultó herido...'
	add_child(gameover_instance)
	
	await get_tree().create_timer(5).timeout
	gameover_instance.queue_free()

func despawn_cart():
	cart_instance.queue_free()
	cart_instance = null

func _initialize_letters():
	letters = default_letters.duplicate()
	letters.shuffle()

func start_timer():
	CartSpawner.start()
	# Mostrar la cuenta regresiva
	seconds_remaining = CartSpawner.wait_time
	Ticker.start()
	update_remaining_time_label()
	
func _on_ticker_timeout():
	seconds_remaining -= 1
	update_remaining_time_label()
	
func update_remaining_time_label():
	Remaining.text = 'Carrito en '  + str(seconds_remaining) + ' seg.'

func _display_letters():
	for child in $Letters.get_children():
		$Letters.remove_child(child)
	var scene = load("res://scenes/letter/letter.tscn")
	for i in len(letters):
		var letter = letters[i]
		var instance = scene.instantiate()
		instance.letter = letter
		instance.position.x = i * 16
		$Letters.add_child(instance)

func _process_player_and_letter(player_name: String, letter: String):
	# Obtener player por nombre
	letter = letter.to_upper()
	var existing_player = players.get(player_name)
	if existing_player != null:
		var player = existing_player
		print(player.player_name + ': ' + letter)
		# Encontrar key en la lista de letters
		var letter_index = letters.find(letter, 0)
		if letter_index == -1:
			return
		else:
	#		toggle_at(letter_index)
			$Label.text = player_name + ' escribió ' + letter
			player.set_target_location(Vector2(letter_index * 16 + 16 / 2, 60))

func _on_gift_chat_message(sender_data, message):
	print(sender_data, message)

func _on_twitch_realtime_chat_message(sender_data, message):
	if len(message) == 1:
		var existing_player = players.get(sender_data.user)
		if existing_player != null:
			_process_player_and_letter(sender_data.user, message)
		else:
			spawn_player(sender_data.user)
			await get_tree().create_timer(0.3).timeout
			_process_player_and_letter(sender_data.user, message)
		
