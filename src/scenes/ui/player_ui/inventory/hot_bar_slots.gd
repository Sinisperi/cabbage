class_name HotBarSlots extends PanelContainer


@onready var hot_bar_grid: HotBar = %HotBarGrid

signal item_picked(index: int)
signal item_placed(index: int, item_data: ItemData)

func _ready() -> void:
	hot_bar_grid.item_picked.connect(func(index: int) -> void: item_picked.emit(index))
	hot_bar_grid.item_placed.connect(func(index: int, item_data: ItemData) -> void: item_placed.emit(index, item_data))
	pass


func init_grid() -> void:
	hot_bar_grid.init_grid()


func place_items(items: Array[ItemData]) -> void:
	hot_bar_grid.place_items(items)


func get_selected_item() -> ItemData:
	return hot_bar_grid.get_selected_item()
