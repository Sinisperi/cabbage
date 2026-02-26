class_name EquipmentSlots extends PanelContainer


@onready var equipment_grid: GridContainer = %EquipmentGrid

#@export var equipped_items: Dictionary[String, EquipableItemData] = {
#
	#InventoryData.HELMET_SLOT: null,
	#InventoryData.CHEST_SLOT: null,
	#InventoryData.PANTS_SLOT: null,
	#InventoryData.BOOTS_SLOT: null,
	#InventoryData.BACKPACK_SLOT: null,
#}

@onready var equipment_slots: Dictionary[String, EquipmentSlot] = {

	InventoryData.HELMET_SLOT: $MarginContainer/EquipmentGrid/HelmetSlot,
	InventoryData.CHEST_SLOT: $MarginContainer/EquipmentGrid/ChestSlot,
	InventoryData.PANTS_SLOT: $MarginContainer/EquipmentGrid/PantsSlot,
	InventoryData.BOOTS_SLOT: $MarginContainer/EquipmentGrid/BootsSlot,
	InventoryData.BACKPACK_SLOT: $MarginContainer/EquipmentGrid/BackpackSlot,
}

@export var trinket_slots: Array[EquipmentSlot] = []


func _ready() -> void:
	EventBus.inventory.equipment.item_equipped.connect(_on_item_equipped)
	EventBus.inventory.equipment.item_unequipped.connect(_on_item_unequipped)


func _on_item_equipped(item_data: EquipableItemData) -> void:
	## TODO Apply effects here
	print_rich("[color=yellow]Itrem equippped [/color]", item_data)


func _on_item_unequipped(item_data: EquipableItemData) -> void:
	## TODO Unapply effects here
	print("item unequipped", item_data)


@rpc("any_peer", "call_local")
func init_equipment_request(peer_id: int) -> void:
	if multiplayer.is_server():
		var equipment_items: Dictionary = PlayerManager.get_player_data(peer_id).inventory.equipment_items_to_obj()
		var trinket_items: Array = PlayerManager.get_player_data(peer_id).inventory.trinket_items_to_obj()
		if peer_id <= 1:
			_init_equipment(equipment_items, trinket_items)
		else:
			print(peer_id, "this is called asdfasdf;lkjasd;flkjasdf;lkj")
			_init_equipment.rpc_id(peer_id, equipment_items, trinket_items)
		
		
@rpc("authority", "call_remote")
func _init_equipment(equipment: Dictionary, trinkets: Array) -> void:
	
	for s in equipment_slots:
		equipment_slots[s].set_item(ItemDb.get_item(equipment[s].uid) if equipment[s] else null)
	
	
	for t in trinket_slots.size():
		trinket_slots[t].set_item(ItemDb.get_item(trinkets[t].uid) if trinkets[t] else null)
