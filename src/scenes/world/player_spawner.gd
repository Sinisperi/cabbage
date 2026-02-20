extends MultiplayerSpawner
@export var player_scene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_function = _spawn_function


func _spawn_function(data: Dictionary) -> Node:
	var player: Player = player_scene.instantiate()
	## Load player data or create based on username???
	
	if PlayerManager.active_players.has(data.username):
		player.stats = PlayerManager.active_players[data.username]
	else:
		player.stats = PlayerData.new()
		player.stats.username = data.username
		player.stats.jog_speed = 5.0
		PlayerManager.active_players[data.username] = player.stats
		
	PlayerManager.active_peers[data.peer_id] = data.username
	
	player.position = Vector3(data.location.x, player.position.y, data.location.y)
	player.name = str(data.peer_id)
	return player
