extends Node

var ui: UISignals = UISignals.new()
var inventory: InventorySignals = InventorySignals.new()
var world: WorldSignals = WorldSignals.new()

class UISignals:
	## Useful for disabling movement on the player while menus are open
	signal mouse_mode_changed(mode: int)


class InventorySignals:
	var equipment: EquipmentSignals = EquipmentSignals.new()
	var hot_bar: HotBarSignals = HotBarSignals.new()
	
	
	signal expantion_requested(columns_amount: int, type: InventoryGrid.InventoryType)
	signal item_pick_up_requested(item_data: ItemData)
	signal item_drop_requested(item: Node)

	class EquipmentSignals:
		signal item_equipped(item_data: EquipableItemData, index: int)
		signal item_unequipped(item_data: EquipableItemData, index: int)
	
	class HotBarSignals:
		signal rh_item_equipped(item_data: ItemData)

class WorldSignals:
	signal item_spawn_requested(item_data: Variant)
	signal player_spawned_item_despawn_requested(item_id: String)
