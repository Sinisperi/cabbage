extends Node

var ui: UISignals = UISignals.new()
var inventory: InventorySignals = InventorySignals.new()


class UISignals:
	signal mouse_mode_changed(value: bool)


class InventorySignals:
	var equipment: EquipmentSignals = EquipmentSignals.new()
	var hot_bar: HotBarSignals = HotBarSignals.new()
	
	
	signal expantion_requested(columns_amount: int, type: InventoryGrid.InventoryType)
	signal item_pick_up_requested(item_data: ItemData)

	class EquipmentSignals:
		signal item_equipped(item_data: EquipableItemData)
		signal item_unequipped(item_data: EquipableItemData)
	
	class HotBarSignals:
		signal rh_item_equipped(item_data: ItemData)
