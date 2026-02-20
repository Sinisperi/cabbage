class_name InventoryData extends Resource

const HELMET_SLOT = "HELMET_SLOT"
const CHEST_SLOT = "CHEST_SLOT"
const PANTS_SLOT = "PANTS_SLOT"
const BOOTS_SLOT = "BOOTS_SLOT"
const BACKPACK_SLOT = "BACKPACK_SLOT"

@export var inventory_items: Array[ItemData]

@export var equipment_items: Dictionary[String, EquipableItemData] = {
	HELMET_SLOT: null,
	CHEST_SLOT: null,
	PANTS_SLOT: null,
	BOOTS_SLOT: null,
	BACKPACK_SLOT: null
}

@export var trinket_items: Array[TrinketData] = [null, null, null]
