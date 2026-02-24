class_name InventoryGrid extends GridContainer

signal item_picked(index: int)
signal item_placed(index: int, item_data: ItemData)
enum InventoryType
{
	MAIN,
	HOT_BAR
}
@export var inventory_type: InventoryType
@export var inventory_slot_scene: PackedScene

func _ready() -> void:
	EventBus.inventory.expantion_requested.connect(_expand)


func init_grid() -> void:
	for i: InventorySlot in get_children():
		i.item_picked.connect(func(index: int) -> void: item_picked.emit(index))
		i.item_placed.connect(func(index: int, item_data: ItemData) -> void: item_placed.emit(index, item_data))


func place_items(items: Array) -> void:
	for i in items.size():
		if i > get_child_count():
			break
		var slot: InventorySlot = get_child(i)
		slot.set_item(items[i])
		slot.slot_index = i

func _expand(amount: int, type: InventoryType) -> void:
	if inventory_type != type: return
	
	@warning_ignore("integer_division")
	var items_per_column: int = get_child_count() / columns
	columns += amount
	for i: int in items_per_column * amount:
		var inventory_slot: InventorySlot = inventory_slot_scene.instantiate()
		inventory_slot.slot_index = get_child_count()
		add_child(inventory_slot)
		inventory_slot.item_picked.connect(func(index: int) -> void: item_picked.emit(index))
		inventory_slot.item_placed.connect(func(index: int, item_data: ItemData) -> void: item_placed.emit(index, item_data))


func place_item(item_data: ItemData, index: int) -> void:
	get_child(index).set_item(item_data)
	
