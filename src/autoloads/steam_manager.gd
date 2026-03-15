extends Node
signal lobby_created(response: int, lobby_id: int)
signal user_joined(steam_id: int, username: String)
signal user_left(steam_id: int, username: String)
signal lobby_joined
var current_lobby_id: int = -1
var is_steam_enabled: bool = false


func _ready() -> void:
	enable_steam()
	Steam.lobby_created.connect(_on_steam_lobby_created)
	Steam.lobby_joined.connect(_on_steam_lobby_joined)
	Steam.lobby_chat_update.connect(_on_steam_lobby_chat_update)
	Steam.join_requested.connect(_on_invite_accepted)

func enable_steam() -> Dictionary:
	if is_steam_enabled:
		return {"status": 0}
	NetworkManager.peer = SteamMultiplayerPeer.new()
	var result: Dictionary = Steam.steamInitEx(480, true)
	if result.status == 0:
		is_steam_enabled = true
	print("steam init result ", result)
	return result



func create_host() -> void:
	NetworkManager.peer = SteamMultiplayerPeer.new()
	NetworkManager.peer.create_host()
	multiplayer.set_multiplayer_peer(NetworkManager.peer)
	
func create_client() -> void:
	NetworkManager.peer = SteamMultiplayerPeer.new()
	

func create_lobby(lobby_type: NetworkManager.LobbyType, max_players: int) -> void:
	Steam.createLobby(lobby_type as Steam.LobbyType, max_players)



func leave_lobby() -> void:
	if current_lobby_id != -1:
		Steam.leaveLobby(current_lobby_id)
	current_lobby_id = -1


func join_lobby(lobby_id_string: String) -> Dictionary:
	var lobby_id: int = int(lobby_id_string.strip_edges())
	var result: Dictionary = await SteamManager.check_lobby_code(lobby_id)
	if result.status == OK:
		NetworkManager.switch_connection_type(NetworkManager.ConnectionType.MULTIPLAYER_CLIENT)
		Steam.joinLobby(lobby_id)
	return result


func _on_steam_lobby_created(response: int, lobby_id: int) -> void:
	current_lobby_id = lobby_id
	lobby_created.emit(response, lobby_id)
	var res: bool = Steam.setLobbyData(lobby_id, "is_joinable", "true")
	print("lobby created ", res)


func _on_steam_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		var host_id: int = Steam.getLobbyOwner(lobby_id)
		var user_id: int = Steam.getSteamID()
		if host_id != user_id:
			NetworkManager.peer.create_client(host_id)
			multiplayer.set_multiplayer_peer(NetworkManager.peer)
			current_lobby_id = lobby_id
			lobby_joined.emit()



func _on_steam_lobby_chat_update(_lobby_id: int, changed_id: int, _making_change_id: int, chat_state: int) -> void:
	var username: String = Steam.getFriendPersonaName(changed_id)
	if chat_state == 1:
		user_joined.emit(changed_id, username)
		EventBus.ui.toast_popup_requested.emit(username + " has joined!", false, "Rejoice!")

		
	elif chat_state == 2:
		EventBus.ui.toast_popup_requested.emit(username + " has left!", false, "It's fine!")
		user_left.emit(changed_id, username)


func _on_invite_accepted(lobby_id: int, _steam_id: int) -> void:
	NetworkManager.switch_connection_type(NetworkManager.ConnectionType.MULTIPLAYER_CLIENT)
	Steam.joinLobby(lobby_id)


func create_friends_popup() -> void:
	Steam.activateGameOverlayInviteDialog(current_lobby_id)


func check_lobby_code(lobby_code: int) -> Dictionary:
	var res := {"status": 0, "verbal": "ok"}
	if str(lobby_code).length() <= 15:
		res.status = 1
		res.verbal = "Join code is missing some stuff.."
		return res
	
	Steam.requestLobbyData(lobby_code)
	await Steam.lobby_data_update
	var is_joinable: String = Steam.getLobbyData(lobby_code, "is_joinable")
	if !is_joinable.length():
		res.status = 2
		res.verbal = "Lobby code is for the lobby that does not exist or is not joinable!"
		return res
	var client_id: int = Steam.getSteamID()
	var host_id: int = Steam.getLobbyOwner(lobby_code)
	if client_id == host_id:
		res.status = 3
		res.verbal = "Trying to play with yourself... I see that..."
	return res



func get_avatar_image(user_id: int) -> ImageTexture:
	var handle: int = Steam.getMediumFriendAvatar(user_id)
	if !handle:
		await Steam.avatar_loaded
	var data: Dictionary = Steam.getImageRGBA(handle)
	var img: Image = Image.create_from_data(64, 64, false, Image.FORMAT_RGBA8, data.buffer)
	var tex: ImageTexture = ImageTexture.create_from_image(img)
	return tex
	

func get_users_in_lobby() -> Array:
	if !is_steam_enabled: return []
	var users: Array = []
	var user_count: int = Steam.getNumLobbyMembers(current_lobby_id)
	for u in user_count:
		var steam_id: int = Steam.getLobbyMemberByIndex(current_lobby_id, u)
		if steam_id <= 0:
			continue
		var username: String = Steam.getFriendPersonaName(steam_id)
		users.push_back(
			{
				"steam_id": steam_id,
				"username": username
			}
		)
	return users


func get_peer_steam_username(peer_id: int) -> String:
	var steam_id: int = NetworkManager.peer.get_steam_id_for_peer_id(peer_id)
	if peer_id > 1:
		return Steam.getFriendPersonaName(steam_id)
	else:
		return Steam.getPersonaName()


func get_peer_steam_id(peer_id: int) -> int:
	return NetworkManager.peer.get_steam_id_for_peer_id(peer_id)
