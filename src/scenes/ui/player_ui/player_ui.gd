class_name PlayerUI extends CanvasLayer

@onready var inventory: Inventory = %Inventory
@onready var hud: Control = %HUD
@onready var debug_screen: DebugScreen = %DebugScreen
@onready var character_creator_screen: Control = %CharacterCreatorScreen
@onready var in_game_menu: Control = %InGameMenu

enum {
	NONE = 0,
	HUD = 1,
	INVENTORY = 1 << 1,
	DEBUG_SCREEN = 1 << 2,
	CHARACTER_CREATOR = 1 << 3,
	IN_GAME_MENU = 1 << 4
}

var ui_state: int = HUD

func _ready() -> void:
	Globals.player_ui = self
	EventBus.ui.character_cretion_finished.connect(_on_character_creation_finished)
	in_game_menu.continue_button_pressed.connect(_on_in_game_menu_continue_button_pressed)
	_update_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		if _is_flag_set(IN_GAME_MENU): return
		ui_state ^= INVENTORY
		inventory.toggle_inventory(_is_flag_set(INVENTORY))
		_update_ui()
	if event.is_action_pressed("toggle_debug_screen"):
		if _is_flag_set(IN_GAME_MENU): return
		ui_state ^= DEBUG_SCREEN
		_update_ui()
		
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_F4:
				#PlayerManager.save_player_data(multiplayer.get_unique_id())
				if multiplayer.is_server():
					SaveDataManager.save_game()
			if event.keycode == KEY_ESCAPE:
				ui_state ^= IN_GAME_MENU
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if ui_state & (IN_GAME_MENU | INVENTORY) else Input.MOUSE_MODE_CAPTURED
				EventBus.ui.mouse_mode_changed.emit(Input.mouse_mode)
				_update_ui()
			if event.keycode == KEY_F1:
				inventory.visible = !inventory.visible
				hud.visible = !hud.visible



func _update_ui() -> void:
	hud.visible = _is_flag_set(HUD)
	debug_screen.visible = _is_flag_set(DEBUG_SCREEN)
	character_creator_screen.visible = _is_flag_set(CHARACTER_CREATOR)
	inventory.visible = !_is_flag_set(CHARACTER_CREATOR)
	hud.visible = !_is_flag_set(CHARACTER_CREATOR)
	hud.visible = !_is_flag_set(IN_GAME_MENU)
	in_game_menu.visible = _is_flag_set(IN_GAME_MENU)


func _is_flag_set(flag: int) -> bool:
	return ui_state & flag

func show_character_creator() -> void:
	ui_state = CHARACTER_CREATOR
	_update_ui()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	EventBus.ui.mouse_mode_changed.emit(Input.MOUSE_MODE_VISIBLE)


func _on_character_creation_finished() -> void:
	ui_state = HUD
	_update_ui()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventBus.ui.mouse_mode_changed.emit(Input.MOUSE_MODE_CAPTURED)


func _on_in_game_menu_continue_button_pressed() -> void:
	ui_state ^= IN_GAME_MENU
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if ui_state & (IN_GAME_MENU | INVENTORY) else Input.MOUSE_MODE_CAPTURED
	EventBus.ui.mouse_mode_changed.emit(Input.mouse_mode)
	_update_ui()
