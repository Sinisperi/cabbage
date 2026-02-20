class_name World extends Node3D

@export var player_spawner: MultiplayerSpawner
@export var player_spawn_area: SpawnArea

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

@rpc("any_peer", "call_local")
func _request_player_spawn(username: String = "NO USERNAME") -> void:
	if multiplayer.is_server():
		var peer_id: int = multiplayer.get_remote_sender_id()
		var data: Dictionary = {
			"peer_id": peer_id,
			"location": player_spawn_area.get_spawn_point(),
			"username": username
		}
		player_spawner.spawn(data)
		
		print("spawning player ", peer_id)
		
