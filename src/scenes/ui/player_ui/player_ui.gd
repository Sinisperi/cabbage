class_name PlayerUI extends CanvasLayer

@onready var inventory: Inventory = %Inventory
@onready var hud: Control = %HUD
@onready var debug_screen: DebugScreen = %DebugScreen

enum {
	NONE = 0,
	HUD = 1,
	INVENTORY = 1 << 1,
	DEBUG_SCREEN = 1 << 2
}

var ui_state: int = HUD


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		ui_state ^= INVENTORY
		prints(String.num_int64(ui_state, 2), _is_flag_set(INVENTORY))
	if event.is_action_pressed("toggle_debug_screen"):
		ui_state ^= DEBUG_SCREEN
			

func _physics_process(_delta: float) -> void:
	_show_ui()


func _show_ui() -> void:
	inventory.toggle_inventory(_is_flag_set(INVENTORY))
	hud.visible = _is_flag_set(HUD)
	debug_screen.visible = _is_flag_set(DEBUG_SCREEN)


func _is_flag_set(flag: int) -> bool:
	return ui_state & flag
