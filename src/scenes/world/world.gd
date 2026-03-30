class_name World extends Node3D
@export var player_scene: PackedScene
@onready var player_spawner: NetworkSpawner = %PlayerSpawner

#@onready var player_spawner: MultiplayerSpawner = %PlayerSpawner

## 2 chunks render distance -> 1 we are currently in + 2 on each side and dioganally
## every time we discover new chunk we will generate its data, load it because we just entered it
## and then when we unload it, we save it into a file

## NOTE this is for debug purposes to simulate loading chunk data from filesystem


func _ready() -> void:
	#ItemDb.init()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Globals.world = self
	#NetworkManager.peer_disconnected.connect(_on_peer_disconnected)

	# Currently there is a possibility that while player's data is saving, someone else is editing the chunk
	# for this to happen it has to happen at the same time with difference of the time it would take to save a json file





@rpc("any_peer", "call_local")
func _request_player_spawn(_display_name: String = "") -> void:
	if multiplayer.is_server():
		await player_spawner.request_spawn(multiplayer.get_remote_sender_id())
