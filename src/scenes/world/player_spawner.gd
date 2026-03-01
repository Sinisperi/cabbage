extends MultiplayerSpawner
@export var player_scene: PackedScene
@onready var spawn_area: SpawnArea = %SpawnArea


func _ready() -> void:
	spawn_function = _spawn_function 

func _spawn_function(data: Dictionary) -> Node:
	
	var player: Player = player_scene.instantiate()
	player.name = str(data.peer_id)
	var spawn_point: Vector2 = spawn_area.get_spawn_point()
	#player.position = spawn_area.get_spawn_point()
	player.position = Vector3(spawn_point.x, player.position.y, spawn_point.y)
	return player
