extends Node

@export var access_token := ''
@export var refresh_token := ''

@export var id := ''
@export var login := ''
@export var display_name := ''

func _ready():
	load_data()
	if not access_token.is_empty():
		var is_valid = await validate_token(access_token)
		if not is_valid:
			logout()

func load_data():
	var exists: bool = FileAccess.file_exists('user://credentials.json')
	if not exists:
		return
	var save_game = FileAccess.open("user://credentials.json", FileAccess.READ)
	var json_string = save_game.get_line()
	var parsed = JSON.parse_string(json_string)
	if parsed != null:
		set_data(parsed)

func save_data():
	# Guardar en almacenamiento las credenciales
	var save_game = FileAccess.open("user://credentials.json", FileAccess.WRITE)
	var data := {
		'access_token': access_token,
		'refresh_token': refresh_token,
		'id': id,
		'login': login,
		'display_name': display_name
	}
	var json_string = JSON.stringify(data)
	save_game.store_line(json_string)

func is_authorized() -> bool:
	return access_token != ''
	
func logout():
	clear_data()
	DirAccess.remove_absolute("user://credentials.json")

func set_data(data: Dictionary):
	access_token = data['access_token']
	refresh_token = data['refresh_token']
	
	id = data['id']
	login = data['login']
	display_name = data['display_name']
	save_data()

func clear_data():
	access_token = ''
	refresh_token = ''
	
	id = ''
	login = ''
	display_name = ''

func validate_token(token: String):
	var scene = load('res://scenes/twitch-api/twitch-api.tscn')
	var instance = scene.instantiate()
	add_child(instance)
	instance.validate_token(token)
	var response = await instance.response
	instance.queue_free()
	if response[1] == 200:
		return true
	else:
		return false

func try_refresh_token():
	if not refresh_token.is_empty():
		var scene = load('res://scenes/twitch-api/twitch-api.tscn')
		var instance = scene.instantiate()
		add_child(instance)
#		instance.validate_token(token)
#		var response = await instance.response
		instance.queue_free()
