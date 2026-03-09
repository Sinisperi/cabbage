extends Node
var peer: SteamMultiplayerPeer = null
signal lobby_created(response: int, lobby_id: int)
var current_lobby_id: int = -1
var is_steam_enabled: bool = false

func enable_steam() -> Dictionary:
	if is_steam_enabled:
		return {"status": 0}
	peer = SteamMultiplayerPeer.new()
	var result: Dictionary = Steam.steamInitEx(480, true)
	if result.status == 0:
		is_steam_enabled = true
	return result

func _ready() -> void:
	enable_steam()
	Steam.lobby_created.connect(_on_steam_lobby_created)
	Steam.lobby_joined.connect(_on_steam_lobby_joined)

func create_lobby(lobby_type: Steam.LobbyType, max_players: int) -> void:
	if current_lobby_id > 0:
		Steam.leaveLobby(current_lobby_id)
	else:
		peer.create_host()
		multiplayer.set_multiplayer_peer(peer)
	Steam.createLobby(lobby_type, max_players)
	

func join_lobby(lobby_id: int) -> void:
	Steam.joinLobby(lobby_id)


func _on_steam_lobby_created(response: int, lobby_id: int) -> void:
	current_lobby_id = lobby_id
	lobby_created.emit(response, lobby_id)
	Steam.setLobbyData(lobby_id, "is_joinable", "true")


func _on_steam_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		var host_id: int = Steam.getLobbyOwner(lobby_id)
		var user_id: int = Steam.getSteamID()
		if host_id != user_id:
			peer.create_client(host_id)
			multiplayer.set_multiplayer_peer(peer)


func create_friends_popup() -> void:
	Steam.activateGameOverlayInviteDialog(current_lobby_id)


func check_lobby_code(code_string: String) -> Dictionary:
	var code: int = int(code_string)
	var res := {"status": 0, "verbal": "ok"}
	if code_string.length() <= 15:
		res.status = 1
		res.verbal = "Join code is missing some stuff.."
		return res
	
	var is_joinable: String = Steam.getLobbyData(code, "is_joinable")
	if !is_joinable.length():
		res.status = 2
		res.verbal = "Lobby code is for the lobby that does not exist or is not joinable!"
		return res
	var client_id: int = Steam.getSteamID()
	var host_id: int = Steam.getLobbyOwner(code)
	if client_id == host_id:
		res.status = 3
		res.verbal = "Trying to play with yourself... I see that..."
	return res
