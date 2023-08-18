extends Node
class_name TwitchAPI

signal response(result, response_code, headers, body)

@export var client_id = 'hifxi1p8nl8mphy0fl9mxodimlo5gb'

func _ready():
	$HTTPRequest.request_completed.connect(_on_request_completed)
#	get_channel_information()
	get_banned_users()
	
func get_channel_information():
	var url := 'https://api.twitch.tv/helix/channels'
	var params: Dictionary = {
		'broadcaster_id': TwitchData.id
	}
	var query_string = _dictionary_to_querystring(params)#.uri_encode()
	url = url + '?' + query_string
	
	var headers := [
		'Authorization: Bearer ' + TwitchData.access_token,
		'Client-Id: ' + client_id
	]
	
	$HTTPRequest.request(url, headers, HTTPClient.METHOD_GET, '')

func get_user(id: String = '', login: String = ''):
	var url := 'https://api.twitch.tv/helix/users'
	
	var params: Dictionary = {}
	if id != '':
		params['id'] = id
	if login != '':
		params['login'] = login
	
	var query_string = _dictionary_to_querystring(params)#.uri_encode()
	url = url + '?' + query_string
	
	var headers := [
		'Authorization: Bearer ' + TwitchData.access_token,
		'Client-Id: ' + client_id
	]
	
	$HTTPRequest.request(url, headers, HTTPClient.METHOD_GET, '')

func get_banned_users():
	const required_scopes = [
		'moderation:read',
		'moderator:manage:banned_users'
	]
	var url := 'https://api.twitch.tv/helix/moderation/banned'
	var params: Dictionary = {
		'broadcaster_id': TwitchData.id
	}
	var query_string = _dictionary_to_querystring(params)#.uri_encode()
	url = url + '?' + query_string
	
	var headers := [
		'Authorization: Bearer ' + TwitchData.access_token,
		'Client-Id: ' + client_id
	]
	
	$HTTPRequest.request(url, headers, HTTPClient.METHOD_GET, '')

func ban_user(user_id: String, duration: int = 0, reason: String = ''):
	const required_scopes = [
		'moderator:manage:banned_users'
	]
	var url := 'https://api.twitch.tv/helix/moderation/bans'
	var params: Dictionary = {
		'broadcaster_id': TwitchData.id,
		'moderator_id': TwitchData.id
	}
	var query_string = _dictionary_to_querystring(params)#.uri_encode()
	url = url + '?' + query_string
	
	var body: Dictionary = {
		'data': {
			'user_id': user_id,
			'duration': duration,
			'reason': reason
		}
	}
	var body_string = JSON.stringify(body)
	
	var headers := [
		'Authorization: Bearer ' + TwitchData.access_token,
		'Client-Id: ' + client_id,
		'Content-Type: application/json'
	]
	
	$HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, body_string)

func validate_token(oauth_token: String):
	var url = 'https://id.twitch.tv/oauth2/validate'
	
	var headers := [
		'Authorization: OAuth ' + oauth_token
	]
	
	$HTTPRequest.request(url, headers, HTTPClient.METHOD_GET, '')

func _on_request_completed(result, response_code, headers, body):
#	print(result)
#	print(response_code)
#	print(headers)
#	print(body)
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	response.emit(result, response_code, headers, json)

func _dictionary_to_querystring(data: Dictionary):
	var string := ''
	for key in data:
		string += key + '=' + data[key] + '&'
	return string

