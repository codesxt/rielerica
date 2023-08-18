extends Node
class_name TwitchIntegration

@export var auto_start : bool = false
@export var authorization_server : String = 'http://localhost:3000'

@export_category("Server")

## Server port
@export var server_port : int = 18297

var server : TCPServer = TCPServer.new()
var connections : Array[StreamPeerTCP] = []

signal authorized(data)

func _ready():
	if auto_start:
		authenticate()

func authenticate():
	OS.shell_open(authorization_server)
	
	# Se crea un servidor HTTP que escucha en el puerto indicado
	# Llega el access token y se emite una señal
	
	var server_result : int = server.listen(server_port)
	if server_result == 0:
		print('Server listening on port ' + str(server_port))
	print("Waiting for user to login.")

func _process(_delta : float) -> void:
	if server.is_listening():
		if server.is_connection_available():
			var client = server.take_connection()
			connections.append(client)
	for client in connections:
		var index = connections.find(client)
		var status = client.get_status()
		if status == client.STATUS_CONNECTED:
			var poll_error : Error = client.poll()
			var available_bytes : int = client.get_available_bytes()
			if (available_bytes > 0):
				var response = client.get_utf8_string(available_bytes)
				var start : int = response.find("?")
				response = response.substr(start + 1, response.find(" ", start) - start)
				var data : Dictionary = {}
				for entry in response.split("&"):
					var pair = entry.split("=")
					data[pair[0]] = pair[1] if pair.size() > 0 else ""
				authorized.emit(data)
#				if (data.has("error")):
#					var msg = "Error %s: %s" % [data["error"], data["error_description"]]
#					print(msg)
#					send_response(client, "400 BAD REQUEST",  msg.to_utf8_buffer())
#					client.disconnect_from_host()
#					break
#				else:
#					print("Success.")
				send_response(client, "200 OK", "¡Conexión exitosa!".to_utf8_buffer())
				client.disconnect_from_host()
				connections.remove_at(index)

func send_response(peer : StreamPeer, response : String, body : PackedByteArray) -> void:
	peer.put_data(("HTTP/1.1 %s\r\n" % response).to_utf8_buffer())
	peer.put_data("Server: GIFT (Godot Engine)\r\n".to_utf8_buffer())
	peer.put_data(("Content-Length: %d\r\n"% body.size()).to_utf8_buffer())
	peer.put_data("Connection: close\r\n".to_utf8_buffer())
	peer.put_data("Content-Type: text/plain; charset=UTF-8\r\n".to_utf8_buffer())
	peer.put_data("\r\n".to_utf8_buffer())
	peer.put_data(body)
