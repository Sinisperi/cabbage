extends MultiplayerSpawner
@export var player_scene: PackedScene
@onready var spawn_area: SpawnArea = %SpawnArea


func _ready() -> void:
	spawn_function = _spawn_function 
	spawned.connect(_on_player_spawned)

func _spawn_function(data: Dictionary) -> Node:
	
	var player: Player = player_scene.instantiate()
	player.name = str(data.peer_id)
	return player


func _on_player_spawned(player: Player) -> void:
	var spawn_point: Vector2 = spawn_area.get_spawn_point()
	player.global_position = Vector3(spawn_point.x, player.global_position.y, spawn_point.y)
