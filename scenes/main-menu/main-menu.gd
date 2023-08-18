extends Node2D

var twitch_authorization_instance = null

func _ready():
	pass

func _process(_delta):
	if TwitchData.is_authorized():
		$LoginButton.visible = false
		$StartButton.visible = true
	else:
		$LoginButton.visible = true
		$StartButton.visible = false

func _on_login_button_pressed():
	if twitch_authorization_instance != null:
		twitch_authorization_instance.authenticate()
	else:
		var scene = load("res://scenes/twitch-integration/twitch.tscn")
		var instance = scene.instantiate()
		instance.auto_start = false
		instance.authorization_server = 'https://twitch-numericajam-auth.fly.dev/authorize'
		instance.server_port = 18297
		instance.authorized.connect(_on_authorization_data)
		instance.authenticate()
		add_child(instance)
		twitch_authorization_instance = instance
	
func _on_authorization_data(data: Dictionary):
	TwitchData.set_data(data)

func _on_start_button_pressed():
	get_tree().change_scene_to_file('res://scenes/gameplay/gameplay.tscn')
