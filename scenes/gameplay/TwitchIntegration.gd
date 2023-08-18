extends Gift

func _ready() -> void:
	cmd_no_permission.connect(no_permission)
	chat_message.connect(on_chat)
	event.connect(on_event)
	
	var authfile := FileAccess.open("./auth.txt", FileAccess.READ)
	client_id = authfile.get_line()
	client_secret = authfile.get_line()
	var initial_channel = authfile.get_line()
	
	# When calling this method, a browser will open.
	# Log in to the account that should be used.
	await(authenticate(client_id, client_secret))
	var success = await(connect_to_irc())
	if (success):
		request_caps()
		join_channel(initial_channel)
	await(connect_to_eventsub())
	# Refer to https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/ for details on
	# what events exist, which API versions are available and which conditions are required.
	# Make sure your token has all required scopes for the event.
	subscribe_event("channel.follow", 2, {"broadcaster_user_id": user_id, "moderator_user_id": user_id})

func no_permission(cmd_info : CommandInfo) -> void:
	chat("NO PERMISSION!")

func on_chat(data : SenderData, msg : String) -> void:
#	print(data.user)
#	print(data.channel)
#	print(data.tags)
	if len(msg) == 1:
		if get_parent().is_paused == true:
			return
		msg = msg.capitalize()
		var name : String = data.tags['display-name']
		owner.spawn_player(name)
		owner._process_player_and_letter(name, msg)
	
func on_event(type : String, data : Dictionary) -> void:
	match(type):
		"channel.follow":
			print("%s followed your channel!" % data["user_name"])
