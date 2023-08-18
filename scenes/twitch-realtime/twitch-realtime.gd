extends Node

var websocket: WebSocketPeer

# List of channels the user is in
var channels: Array[String] = []

var connected := false

signal connected_to_irc
signal chat_message(sender_data, message)

var user_regex : RegEx = RegEx.new()

func _init():
	user_regex.compile("(?<=!)[\\w]*(?=@)")

func _ready():
	if TwitchData.is_authorized():
		connect_to_twitch()

func _process(delta):
	websocket.poll()
	var state = websocket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if !connected:
			connected = true
			connected_to_irc.emit()
		while websocket.get_available_packet_count():
			process_irc_message(websocket.get_packet())
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = websocket.get_close_code()
		var reason = websocket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.

func connect_to_twitch():
	connect_to_irc()

func connect_to_irc():
	websocket = WebSocketPeer.new()
	var error = websocket.connect_to_url("wss://irc-ws.chat.twitch.tv:443")
	if error != OK:
		print("Unable to connect")
		set_process(false)
		return
	print("Connecting to Twitch IRC.")
#	await(twitch_connected)
#	var success = await(login_attempt)
#	if (success):
#		connected = true
#	return success
#
#	ws = WebSocketClient.new()
#	ws.connect("data_received", self, "_on_data")
#	ws.connect("connection_established", self, "_connected")
#	ws.connect("connection_closed", self, "_closed")
#	#var err = ws.connect_to_url("wss://irc-ws.chat.twitch.tv:443");
#
#	var err = ws.connect_to_url("ws://irc-ws.chat.twitch.tv:80");
#
#	print("err=",err)
#	if err != OK:
#		print("Unable to connect")
#		set_process(false)

func send_irc(text : String):
	print(text)
	websocket.send_text(text)

func join_channel(channel : String) -> void:
	var lower_channel : String = channel.to_lower()
	channels.append(lower_channel)
	send_irc("JOIN #" + lower_channel)

func leave_channel(channel : String) -> void:
	var lower_channel : String = channel.to_lower()
	send_irc("PART #" + lower_channel)
	channels.erase(lower_channel)


func _on_connected_to_irc():
	send_irc("PASS oauth:%s" % [TwitchData.access_token])
	send_irc("NICK " + TwitchData.display_name)
	join_channel(TwitchData.display_name)

func process_irc_message(data: PackedByteArray) -> void:
	var messages : PackedStringArray = data.get_string_from_utf8().strip_edges(false).split("\r\n")
	var tags = {}
	for message in messages:
		if(message.begins_with("@")):
			var msg : PackedStringArray = message.split(" ", false, 1)
			message = msg[1]
			for tag in msg[0].split(";"):
				var pair = tag.split("=")
				tags[pair[0]] = pair[1]
		if (OS.is_debug_build()):
			print("> " + message)
		handle_message(message, tags)

func process_event(data: PackedByteArray) -> void:
	print(data.get_string_from_utf8())
	var msg : Dictionary = JSON.parse_string(data.get_string_from_utf8())

func handle_message(message : String, tags : Dictionary) -> void:
	if(message == "PING :tmi.twitch.tv"):
		send_irc("PONG :tmi.twitch.tv")
#		pong.emit()
		return
	var msg : PackedStringArray = message.split(" ", true, 3)
	match msg[1]:
		"NOTICE":
			var info : String = msg[3].right(-1)
			if (info == "Login authentication failed" || info == "Login unsuccessful"):
				print_debug("Authentication failed.")
#				login_attempt.emit(false)
			elif (info == "You don't have permission to perform that action"):
				print_debug("No permission. Check if access token is still valid. Aborting.")
#				user_token_invalid.emit()
				set_process(false)
			else:
#				unhandled_message.emit(message, tags)
				pass
		"001":
			print_debug("Authentication successful.")
#			login_attempt.emit(true)
		"PRIVMSG":
			var sender_data : SenderData = SenderData.new(user_regex.search(msg[0]).get_string(), msg[2], tags)
#			handle_command(sender_data, msg[3].split(" ", true, 1))
			chat_message.emit(sender_data, msg[3].right(-1))
		"WHISPER":
			var sender_data : SenderData = SenderData.new(user_regex.search(msg[0]).get_string(), msg[2], tags)
#			handle_command(sender_data, msg[3].split(" ", true, 1), true)
#			whisper_message.emit(sender_data, msg[3].right(-1))
#		"RECONNECT":
#			twitch_restarting = true
#		"USERSTATE", "ROOMSTATE":
#			var room = msg[2].right(-1)
#			if (!last_state.has(room)):
#				last_state[room] = tags
#			else:
#				for key in tags:
#					last_state[room][key] = tags[key]
		_:
#			unhandled_message.emit(message, tags)
			pass

#func data_received(data : PackedByteArray) -> void:
#	var messages : PackedStringArray = data.get_string_from_utf8().strip_edges(false).split("\r\n")
#	var tags = {}
#	for message in messages:
#		if(message.begins_with("@")):
#			var msg : PackedStringArray = message.split(" ", false, 1)
#			message = msg[1]
#			for tag in msg[0].split(";"):
#				var pair = tag.split("=")
#				tags[pair[0]] = pair[1]
#		if (OS.is_debug_build()):
#			print("> " + message)
#		handle_message(message, tags)
	

#func process_event(data : PackedByteArray) -> void:
#	var msg : Dictionary = JSON.parse_string(data.get_string_from_utf8())
#	if (eventsub_messages.has(msg["metadata"]["message_id"])):
#		return
#	eventsub_messages[msg["metadata"]["message_id"]] = Time.get_ticks_msec()
#	var payload : Dictionary = msg["payload"]
#	last_keepalive = Time.get_ticks_msec()
#	match msg["metadata"]["message_type"]:
#		"session_welcome":
#			session_id = payload["session"]["id"]
#			keepalive_timeout = payload["session"]["keepalive_timeout_seconds"]
#			events_id.emit(session_id)
#		"session_keepalive":
#			if (payload.has("session")):
#				keepalive_timeout = payload["session"]["keepalive_timeout_seconds"]
#		"session_reconnect":
#			eventsub_restarting = true
#			eventsub_reconnect_url = payload["session"]["reconnect_url"]
#			events_reconnect.emit()
#		"revocation":
#			events_revoked.emit(payload["subscription"]["type"], payload["subscription"]["status"])
#		"notification":
#			var event_data : Dictionary = payload["event"]
#			event.emit(payload["subscription"]["type"], event_data)
