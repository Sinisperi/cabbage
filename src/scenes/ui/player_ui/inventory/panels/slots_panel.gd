class_name SlotsPanel extends PanelContainer


@export var inventory_grid: InventoryGrid

signal item_picked(index: int)
signal item_placed(index: int, item_data: ItemData)

func _ready() -> void:
	inventory_grid.item_picked.connect(func(index: int) -> void: item_picked.emit(index))
	inventory_grid.item_placed.connect(func(index: int, item_data: ItemData) -> void: item_placed.emit(index, item_data))
	pass


func init_grid() -> void:
	inventory_grid.init_grid()


func place_items(items: Array[ItemData]) -> void:
	inventory_grid.place_items(items)


func get_selected_item() -> ItemData:
	return inventory_grid.get_selected_item()


func add_item(item_data: ItemData, index: int) -> void:
	inventory_grid.place_item(item_data, index)
