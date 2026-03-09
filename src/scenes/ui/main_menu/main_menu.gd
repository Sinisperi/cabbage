extends Control
@onready var quit_button: Button = %QuitButton
@onready var new_game_button: Button = %StartNewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var online_play_button: Button = %OnlinePlayButton

@onready var new_game_screen: Control = %NewGameScreen
@onready var title_menu: Control = %TitleMenu
@onready var online_play_screen: Control = %OnlinePlayScreen


@onready var toast_popup: PanelContainer = %ToastPopup
@onready var toast_text_label: Label = %ToastTextLabel
@onready var toast_title: Label = %ToastTitle

enum ScreenType {
	TITLE_MENU = 1,
	NEW_GAME_SCREEN = 1 << 1,
	ONLINE_PLAY_SCREEN = 1 << 2,
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
