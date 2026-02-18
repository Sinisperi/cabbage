class_name PlayerUI extends CanvasLayer

@onready var inventory: Inventory = %Inventory
@onready var hud: Control = %HUD

enum {
	NONE = 0,
	HUD = 1,
	INVENTORY = 1 << 2
}

var ui_state: int = HUD


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		if _is_flag_set(INVENTORY):
			ui_state = ui_state & ~INVENTORY
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			EventBus.mouse_mode_changed.emit(true)
		else:
			ui_state |= INVENTORY
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			EventBus.mouse_mode_changed.emit(false)

func _physics_process(_delta: float) -> void:
	_show_ui()


func _show_ui() -> void:
	inventory.toggle_inventory(_is_flag_set(INVENTORY))
	hud.visible = _is_flag_set(HUD)


func _is_flag_set(flag: int) -> bool:
	return ui_state & flag
