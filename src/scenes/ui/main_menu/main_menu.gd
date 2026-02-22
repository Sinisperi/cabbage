extends Control
@onready var load_game_button: Button = %LoadGameButton
@onready var new_game_button: Button = %NewGameButton
@onready var join_game_button: Button = %JoinGameButton

func _ready() -> void:
	load_game_button.pressed.connect(_on_load_game_button_pressed)
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	join_game_button.pressed.connect(_on_play_online_button_pressed)
	NetworkManager.peer_connected.connect(_on_peer_connected)


## TODO Show a list of all saves, hosted games included.
## Upon clicking on a hosted game, attempt to host the game,
## otherwise, play offline.
## Load not hosted games as usual

func _on_load_game_button_pressed() -> void:
	pass


func _on_new_game_button_pressed() -> void:
	SceneLoader.load_scene(SceneLoader.Scene.NEW_GAME_SCREEN)

func _on_play_online_button_pressed() -> void:
	NetworkManager.enable_multiplayer(true)
	NetworkManager.join_game()
	
	
## TODO Instead of loading the world, check if player has a save here
## if they do, load the world and spawn the player with data,
## otherwise, switch to character creator
func _on_peer_connected(_peer_id: int) -> void:
	
	call_deferred("_load_world")


func _load_world() -> void:
	SceneLoader.load_scene(
		SceneLoader.Scene.WORLD_SCENE, 
		func(world: World) -> void: 
			world._request_player_spawn.rpc_id(1))
