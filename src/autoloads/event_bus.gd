extends Node

var ui: UISignals = UISignals.new()
var inventory: InventorySignals = InventorySignals.new()

class UISignals:
	signal mouse_mode_changed(value: bool)

class InventorySignals:
	signal item_equipped(item_data: ItemData)
	signal hot_bar_expantion_requested(columns_amount: int)
	signal inventory_expantion_requested(columns_amount: int)
