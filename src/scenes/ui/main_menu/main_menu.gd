extends Control

@export var LOBBY_AVATAR: PackedScene

@onready var quit_button: Button = %QuitButton
@onready var new_game_button: Button = %StartNewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var online_play_button: Button = %OnlinePlayButton

@onready var new_game_screen: Control = %NewGameScreen
@onready var title_menu: Control = %TitleMenu
@onready var online_play_screen: Control = %OnlinePlayScreen
@onready var continue_screen: Control = %ContinueScreen

@onready var lobby_avatars: HBoxContainer = %LobbyAvatars

@onready var toast_popup: PanelContainer = %ToastPopup
@onready var toast_text_label: Label = %ToastTextLabel
@onready var toast_title: Label = %ToastTitle

enum ScreenType {
	TITLE_MENU = 1,
	NEW_GAME_SCREEN = 1 << 1,
	ONLINE_PLAY_SCREEN = 1 << 2,
	CONTINUE_SCREEN = 1 << 3
}

var ui_state: int = ScreenType.TITLE_MENU
var tween: Tween = null

func _ready() -> void:

	new_game_button.pressed.connect(_on_new_game_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)
	online_play_button.pressed.connect(_on_online_play_button_pressed)

	quit_button.pressed.connect(_on_quit_button_pressed)
	
	new_game_screen.back_button_pressed.connect(func() -> void: toggle_screen(ScreenType.NEW_GAME_SCREEN))
	online_play_screen.back_button_pressed.connect(func() -> void: toggle_screen(ScreenType.ONLINE_PLAY_SCREEN))
	
	EventBus.ui.toast_popup_requested.connect(create_toast_popup)
	EventBus.world.world_spawn_requested.connect(func(_callback: Callable) -> void: hide())
	SteamManager.user_joined.connect(_on_user_joined)
	SteamManager.user_left.connect(_on_user_left)
	SteamManager.lobby_created.connect(_on_lobby_created)
	SteamManager.lobby_joined.connect(_on_lobby_joined)
	SteamManager.peer_connected.connect(_on_peer_connected)
	SteamManager.host_disconnected.connect(_on_host_disconnected)

	#NetworkManager.peer_connected.connect(_on_peer_connected)
	await show_active_users_avatars()

func toggle_screen(screen_type: ScreenType) -> void:
	ui_state ^= screen_type
	title_menu.visible = !title_menu.visible
	_update_ui()


func _update_ui() -> void:
	new_game_screen.visible = ui_state & ScreenType.NEW_GAME_SCREEN
	online_play_screen.visible = ui_state & ScreenType.ONLINE_PLAY_SCREEN
	continue_screen.visible = ui_state & ScreenType.CONTINUE_SCREEN

func _on_continue_button_pressed() -> void:
	toggle_screen(ScreenType.CONTINUE_SCREEN)

func _on_online_play_button_pressed() -> void:
	toggle_screen(ScreenType.ONLINE_PLAY_SCREEN)



## Pessed by a host or a singleplayer
func _on_new_game_button_pressed() -> void:
	toggle_screen(ScreenType.NEW_GAME_SCREEN)



func _on_quit_button_pressed() -> void:
	get_tree().quit()


func create_toast_popup(text: String, is_error: bool = false, title: String = "") -> void:
	if tween:
		toast_popup.position.y = size.y
		tween.kill()
	if is_error:
		%ToastTitle.text = title if title.length() else "Oh no!"
		%ToastTitle.modulate = Color.RED
		toast_text_label.text = text
		toast_popup.size.y = 0.0
		tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		%ToastTitle.text = title if title.length() else "Oh yeah!"
		%ToastTitle.modulate = Color.SEA_GREEN
		toast_text_label.text = text
		toast_popup.size.y = 0.0
		tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
	var original_pos: float = size.y
	tween.tween_property(toast_popup, "position:y", original_pos - toast_popup.size.y, 0.2)
	tween.tween_interval(3.0)
	tween.chain().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(toast_popup, "position:y", original_pos, 0.2)



func _on_user_joined(user_id: int, _username: String) -> void:
	create_lobby_avatar(await SteamManager.get_avatar_image(user_id), user_id)
	
func _on_user_left(user_id: int, _username: String) -> void:
	var avatar_to_remove: TextureRect = null
	for c in lobby_avatars.get_children():
		if c.user_id == user_id:
			avatar_to_remove = c
			break
	lobby_avatars.remove_child(avatar_to_remove)
	avatar_to_remove.queue_free()
	
	
func create_lobby_avatar(image: ImageTexture, user_id: int) -> void:
	var avatar: TextureRect = LOBBY_AVATAR.instantiate()
	avatar.texture = image
	avatar.user_id = user_id
	lobby_avatars.add_child(avatar)

func _on_lobby_created(_response: int, _lobby_id: int) -> void:
	create_lobby_avatar(await SteamManager.get_avatar_image(Steam.getSteamID()), Steam.getSteamID())

func _on_lobby_joined() -> void:
	await show_active_users_avatars()

func show_active_users_avatars() -> void:
	var users: Array = SteamManager.get_users_in_lobby()
	for u: Dictionary in users:
		create_lobby_avatar(await SteamManager.get_avatar_image(u.steam_id), u.steam_id)



func _on_peer_connected(peer_id: int, steam_id: int) -> void:
	if multiplayer.is_server():
		if Globals.world != null:
			load_world.rpc_id(peer_id, PlayerManager.player_has_save(steam_id))


@rpc("any_peer", "call_remote")
func load_world(has_save: bool) -> void:
	if !has_save:
		#SceneLoader.load_scene_with_callback(SceneLoader.Scene.WORLD_SCENE, func(_world: World) -> void: Globals.player_ui.show_character_creator(), false)
		EventBus.world.world_spawn_requested.emit(func(_world: World) -> void: Globals.player_ui.show_character_creator())
	else:
		#SceneLoader.load_scene_with_callback(SceneLoader.Scene.WORLD_SCENE, func(world: World) -> void: world._request_player_spawn.rpc_id(1))
		EventBus.world.world_spawn_requested.emit(func(world: World) -> void: world._request_player_spawn.rpc_id(1))
		

func _on_host_disconnected() -> void:
	show()
	ui_state = ScreenType.TITLE_MENU
	title_menu.visibile = true
	_update_ui()

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
			
			
			
			
			
	## NEED TO SOMEHOW MAKE IT SO IT aCTUALLY STARSTS A NEW GAME AND NOT LOADING
	#_load_world()
	#new_game_screen.visible = true
## Pressed by a client
#func _on_join_button_pressed() -> void:
	#NetworkManager.enable_multiplayer(true)
	#var status: Error = NetworkManager.join_game()
	#if status != OK:
		#print("Joining game failed with status: ", status)
