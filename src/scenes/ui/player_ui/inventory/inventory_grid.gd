class_name InventoryGrid extends GridContainer

signal item_picked(index: int)
signal item_placed(index: int, item_data: ItemData)
@export var inventory_slot_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func init_grid() -> void:
	for i: InventorySlot in get_children():
		i.item_picked.connect(func(index: int) -> void: item_picked.emit(index))
		i.item_placed.connect(func(index: int, item_data: ItemData) -> void: item_placed.emit(index, item_data))


func place_items(items: Array[ItemData]) -> void:
	for i in items.size():
		if i > get_child_count():
			break
		var slot = get_child(i)
		slot.set_item(items[i])
		slot.slot_index = i


func expand(amount: int) -> void:
	var items_per_column = get_child_count() / columns
	columns += amount
	for i in items_per_column * amount:
		var inventory_slot = inventory_slot_scene.instantiate()
		inventory_slot.slot_index = get_child_count()
		add_child(inventory_slot)
		i.item_picked.connect(func(index: int) -> void: item_picked.emit(index))
		i.item_placed.connect(func(index: int, item_data: ItemData) -> void: item_placed.emit(index, item_data))
