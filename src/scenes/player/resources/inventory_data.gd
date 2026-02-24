class_name InventoryData extends Resource

const HELMET_SLOT = "HELMET_SLOT"
const CHEST_SLOT = "CHEST_SLOT"
const PANTS_SLOT = "PANTS_SLOT"
const BOOTS_SLOT = "BOOTS_SLOT"
const BACKPACK_SLOT = "BACKPACK_SLOT"

@export var inventory_items: Array[ItemData] = [
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
]

@export var hot_bar_items: Array[ItemData] = [
	null,
	null,
	null,
	null,
]

@export var equipment_items: Dictionary[String, EquipableItemData] = {
	HELMET_SLOT: null,
	CHEST_SLOT: null,
	PANTS_SLOT: null,
	BOOTS_SLOT: null,
	BACKPACK_SLOT: null
}

@export var trinket_items: Array[TrinketData] = [null, null, null]

func to_obj(array: Array) -> Array:
	var res: Array = []
	for i: ItemData in array:
		if i != null:
			res.append(i.to_dict())
		else:
			res.append(null)
	return res

func inventory_items_to_obj() -> Array:
	return to_obj(inventory_items)

func hot_bar_items_to_obj() -> Array:
	return to_obj(hot_bar_items)

func trinket_items_to_obj() -> Array:
	return to_obj(trinket_items)

func equipment_items_to_obj() -> Dictionary:
	var res: = {}
	for key: String in equipment_items:
		if equipment_items[key]:
			res[key] = equipment_items[key].to_dict()
		else:
			res[key] = null
	return res
