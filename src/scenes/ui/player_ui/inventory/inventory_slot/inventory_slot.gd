class_name InventorySlot extends ColorRect


signal item_picked(index: int)
signal item_placed(index: int, item_data: ItemData)

@export var draggable_item_scene: PackedScene = null
@export var slot_type: EquipableItemData.EquipmentType

@onready var item_display: TextureRect = %ItemDisplay

var slot_data: ItemData = null
var slot_index: int = -1

var is_hot_bar_selected: bool = false

var is_equipment_slot: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gui_input.connect(_on_gui_input)
	if !slot_data: return
	item_display.texture = slot_data.texture

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT:
			var draggable_item: DraggableItem = get_tree().get_first_node_in_group("draggable_item")
			if slot_data:
				if !draggable_item:
					_handle_pick_item()
				else:
					_handle_swap_item(draggable_item)
			else:
				if draggable_item:
					_handle_place_item(draggable_item)


func _handle_pick_item() -> void:
	
	if is_equipment_slot:
		EventBus.inventory.equipment.item_unequipped.emit(slot_data)
		
	var new_draggable_item: DraggableItem = draggable_item_scene.instantiate()
	new_draggable_item.data = slot_data
	item_picked.emit(slot_index)
	get_tree().get_first_node_in_group("inventory").add_child(new_draggable_item)
	slot_data = null
	update_item_display()
	if is_hot_bar_selected:
		EventBus.inventory.hot_bar.rh_item_equipped.emit(slot_data)
	
func _handle_place_item(draggable_item: DraggableItem) -> void:
	
	if is_equipment_slot:
		if draggable_item.data is not EquipableItemData:
			return
		if draggable_item.data.equipment_type != slot_type:
			return
		EventBus.inventory.equipment.item_equipped.emit(draggable_item.data)

	slot_data = draggable_item.data
	draggable_item.queue_free()
	item_placed.emit(slot_index, slot_data)
	update_item_display()
	if is_hot_bar_selected:
		EventBus.inventory.hot_bar.rh_item_equipped.emit(slot_data)

func _handle_swap_item(draggable_item: DraggableItem) -> void:
	
	if is_equipment_slot:
		if draggable_item.data is not EquipableItemData:
			return
		if draggable_item.data.equipment_type != slot_type:
			return
		EventBus.inventory.equipment.item_unequipped.emit(slot_data)
		EventBus.inventory.equipment.item_equipped.emit(draggable_item.data)
			
	var temp: ItemData = slot_data.duplicate()
	slot_data = draggable_item.data.duplicate()
	draggable_item.data = temp
	draggable_item.update()
	item_placed.emit(slot_index, slot_data)
	update_item_display()
	if is_hot_bar_selected:
		EventBus.inventory.hot_bar.rh_item_equipped.emit(slot_data)

func set_item(item_data: ItemData) -> void:
	slot_data = item_data
	update_item_display()
	if is_hot_bar_selected:
		EventBus.inventory.hot_bar.rh_item_equipped.emit(slot_data)
		
func update_item_display() -> void:
	if slot_data:
		item_display.texture = slot_data.texture
	else:
		item_display.texture = null
