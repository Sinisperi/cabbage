extends Control
@onready var load_game_button: Button = %LoadGameButton
@onready var new_game_button: Button = %NewGameButton
@onready var play_online_button: Button = %PlayOnlineButton

func _ready() -> void:
	load_game_button.pressed.connect(_on_load_game_button_pressed)
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	play_online_button.pressed.connect(_on_play_online_button_pressed)
	NetworkManager.peer_connected.connect(_on_peer_connected)
func _on_load_game_button_pressed() -> void:
	pass


func _on_new_game_button_pressed() -> void:
	SceneLoader.load_scene(SceneLoader.Scene.NEW_GAME_SCREEN)

func _on_play_online_button_pressed() -> void:
	NetworkManager.enable_multiplayer(true)
	NetworkManager.join_game()
	#SceneLoader.load_scene(SceneLoader.Scene.WORLD_SCENE)
	
func _on_peer_connected(id: int) -> void:
	SceneLoader.load_scene(
		SceneLoader.Scene.WORLD_SCENE, 
		func(world: World) -> void: world._request_player_spawn.rpc_id(1)
		)
