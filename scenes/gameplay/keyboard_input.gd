extends Node2D

@export var enabled = false

func _input(event):
	if enabled:
		if event is InputEventKey and event.is_pressed():
			owner.spawn_player('EseMismoBruno')
			owner._process_player_and_letter('EseMismoBruno', OS.get_keycode_string(event.key_label))
		
		if event is InputEventMouseButton:
			event = make_input_local(event)
			
			var player = owner.players.get('EseMismoBruno')
			if player != null:
				player.set_target_location(event.position)
