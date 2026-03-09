extends Control
@onready var quit_button: Button = %QuitButton
@onready var new_game_button: Button = %StartNewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var online_play_button: Button = %OnlinePlayButton

@onready var new_game_screen: Control = %NewGameScreen
@onready var title_menu: Control = %TitleMenu
@onready var online_play_screen: Control = %OnlinePlayScreen

enum ScreenType {
	TITLE_MENU = 1,
	NEW_GAME_SCREEN = 1 << 1,
	ONLINE_PLAY_SCREEN = 1 << 2,
}

var ui_state: int = ScreenType.TITLE_MENU

func _ready() -> void:

	new_game_button.pressed.connect(_on_new_game_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)
	online_play_button.pressed.connect(_on_online_play_button_pressed)

	quit_button.pressed.connect(_on_quit_button_pressed)
	
	new_game_screen.back_button_pressed.connect(func() -> void: toggle_screen(ScreenType.NEW_GAME_SCREEN))
	online_play_screen.back_button_pressed.connect(func() -> void: toggle_screen(ScreenType.ONLINE_PLAY_SCREEN))
	
	#NetworkManager.peer_connected.connect(_on_peer_connected)
	

func toggle_screen(screen_type: ScreenType) -> void:
	ui_state ^= screen_type
	new_game_screen.visible = ui_state & ScreenType.NEW_GAME_SCREEN
	online_play_screen.visible = ui_state & ScreenType.ONLINE_PLAY_SCREEN
	title_menu.visible = !title_menu.visible


func _on_continue_button_pressed() -> void:
	push_warning("NOT IMPLEMENTED")

func _on_online_play_button_pressed() -> void:
	toggle_screen(ScreenType.ONLINE_PLAY_SCREEN)



## Pessed by a host or a singleplayer
func _on_new_game_button_pressed() -> void:
	toggle_screen(ScreenType.NEW_GAME_SCREEN)
	## NEED TO SOMEHOW MAKE IT SO IT aCTUALLY STARSTS A NEW GAME AND NOT LOADING
	#_load_world()
	#new_game_screen.visible = true
## Pressed by a client
#func _on_join_button_pressed() -> void:
	#NetworkManager.enable_multiplayer(true)
	#var status: Error = NetworkManager.join_game()
	#if status != OK:
		#print("Joining game failed with status: ", status)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
## TODO Instead of loading the world, check if player has a save here
## if they do, load the world and spawn the player with data,
## otherwise, switch to character creator

#func _on_peer_connected(_peer_id: int) -> void:
	#call_deferred("_load_world")
#
#
#func _load_world() -> void:
	#SceneLoader.load_scene(
		#SceneLoader.Scene.WORLD_SCENE, 
		#func(world: World) -> void: 
			#world._request_player_spawn.rpc_id(1, str(Time.get_datetime_string_from_system())))
