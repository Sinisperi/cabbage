extends LineEdit


func _ready() -> void:
	$Button.pressed.connect(_on_button_pressed)
	
func _on_button_pressed() -> void:
	send_print.rpc(self.text)


@rpc("any_peer", "call_local")
func send_print(message: String) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	var username: String
	if sender_id != multiplayer.get_unique_id():
		var steam_id: int = SteamManager.peer.get_steam_id_for_peer_id(sender_id)
		username = Steam.getFriendPersonaName(steam_id)
	else:
		username = Steam.getPersonaName()
	print(username, ": ", message)
