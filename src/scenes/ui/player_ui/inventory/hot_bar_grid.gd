class_name HotBar extends InventoryGrid


@onready var item_selector: TextureRect = %ItemSelector


const SCROLL_THRESHOLD: float = 1.0
const SCROLL_INCREMENT: float = 1.0


var selected_item_index: int = 0
var scroll_accumulator: float = 0.0


func _ready() -> void:
	super._ready()
	await get_tree().process_frame
	_set_slot_selected(0, true, false)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				scroll_accumulator -= SCROLL_INCREMENT
				_change_selected_slot()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				scroll_accumulator += SCROLL_INCREMENT
				_change_selected_slot()


func _change_selected_slot() -> void:
	if abs(scroll_accumulator) >= SCROLL_THRESHOLD:
		var amount = int(scroll_accumulator / SCROLL_THRESHOLD)
		scroll_accumulator -= amount * SCROLL_THRESHOLD
		
		_set_slot_selected(selected_item_index, false)
		selected_item_index = wrapi(selected_item_index + amount, 0, get_child_count())
		_set_slot_selected(selected_item_index, true)


func _set_slot_selected(index: int, is_selected: bool, animate: bool = true) -> void:
	var slot: InventorySlot = get_child(index)
	slot.is_hot_bar_selected = is_selected
	
	
	var target_position = (slot.global_position + (slot.size / 2.0)) - (item_selector.size / 2.0)
	if animate:
		var tween = create_tween().set_ease(Tween.EASE_IN)
		tween.tween_property(item_selector, "global_position", target_position, 0.07).set_trans(Tween.TRANS_CUBIC)
	else:
		item_selector.global_position = target_position
		
		
	if is_selected:
		EventBus.item_equipped.emit(get_child(selected_item_index).slot_data)


func get_selected_item() -> ItemData:
	return get_child(selected_item_index).slot_data
