class_name World extends Node3D

@export var player_spawner: MultiplayerSpawner
@export var player_spawn_area: SpawnArea

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

@rpc("any_peer", "call_local")
func _request_player_spawn() -> void:
	if multiplayer.is_server():
		var player_id: int = multiplayer.get_remote_sender_id()
		var data: Dictionary = {
			"player_id": player_id,
			"location": player_spawn_area.get_spawn_point()
		}
		player_spawner.spawn(data)
		
		print("spawning player ", player_id)
		
