extends Control
@onready var load_game_button: Button = %LoadGameButton
@onready var new_game_button: Button = %NewGameButton
@onready var join_game_button: Button = %JoinGameButton
@onready var quit_button: Button = %QuitButton

@onready var new_game_screen: Control = $NewGameScreen


func _ready() -> void:
	load_game_button.pressed.connect(_on_load_game_button_pressed)
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	join_game_button.pressed.connect(_on_join_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	NetworkManager.peer_connected.connect(_on_peer_connected)


## TODO Show a list of all saves, hosted games included.
## Upon clicking on a hosted game, attempt to host the game,
## otherwise, play offline.
## Load not hosted games as usual


func _on_load_game_button_pressed() -> void:
	push_warning("NOT IMPLEMENTED")


## Pessed by a host or a singleplayer
func _on_new_game_button_pressed() -> void:
	new_game_screen.visible = true

## Pressed by a client
func _on_join_button_pressed() -> void:
	NetworkManager.enable_multiplayer(true)
	var status: Error = NetworkManager.join_game()
	if status != OK:
		print("Joining game failed with status: ", status)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
## TODO Instead of loading the world, check if player has a save here
## if they do, load the world and spawn the player with data,
## otherwise, switch to character creator
func _on_peer_connected(_peer_id: int) -> void:
	call_deferred("_load_world")


func _load_world() -> void:
	SceneLoader.load_scene(
		SceneLoader.Scene.WORLD_SCENE, 
		func(world: World) -> void: 
			world._request_player_spawn.rpc_id(1, str(Time.get_datetime_string_from_system())))
