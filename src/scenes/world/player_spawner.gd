extends MultiplayerSpawner
@export var player_scene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_function = _spawn_function


func _spawn_function(data: Dictionary) -> Node:
	var player: Player = player_scene.instantiate()
	player.position = Vector3(data.location.x, player.position.y, data.location.y)
	player.name = str(data.player_id)
	#print(data.player_id, data.location)
	return player
