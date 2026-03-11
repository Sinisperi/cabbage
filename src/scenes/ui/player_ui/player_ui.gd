class_name PlayerUI extends CanvasLayer

@onready var inventory: Inventory = %Inventory
@onready var hud: Control = %HUD
@onready var debug_screen: DebugScreen = %DebugScreen
@onready var character_creator_screen: Control = %CharacterCreatorScreen

enum {
	NONE = 0,
	HUD = 1,
	INVENTORY = 1 << 1,
	DEBUG_SCREEN = 1 << 2,
	CHARACTER_CREATOR = 1 << 3
}

var ui_state: int = HUD

func _ready() -> void:
	Globals.player_ui = self
	EventBus.ui.character_cretion_finished.connect(_on_character_creation_finished)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		ui_state ^= INVENTORY
		prints(String.num_int64(ui_state, 2), _is_flag_set(INVENTORY))
		_update_ui()
	if event.is_action_pressed("toggle_debug_screen"):
		ui_state ^= DEBUG_SCREEN
		_update_ui()
		
	#if event is InputEventKey:
		#if event.keycode == KEY_F4 && event.is_pressed():
			#PlayerManager.save_player_data(multiplayer.get_unique_id())
		#if event.keycode == KEY_F7 && event.is_pressed():
			#ChunkLoader.defragment_region_files()
			

#func _physics_process(_delta: float) -> void:
	#_show_ui()


func _update_ui() -> void:
	hud.visible = _is_flag_set(HUD)
	debug_screen.visible = _is_flag_set(DEBUG_SCREEN)
	character_creator_screen.visible = _is_flag_set(CHARACTER_CREATOR)
	inventory.visible = !_is_flag_set(CHARACTER_CREATOR)
	hud.visible = !_is_flag_set(CHARACTER_CREATOR)
	inventory.toggle_inventory(_is_flag_set(INVENTORY))


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
