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

func _init(data: Dictionary = {}) -> void:
	if data.is_empty(): return
	for i in range(data.inventory_items.size()):
		if data.inventory_items[i]:
			inventory_items[i] = ItemDb.get_item(data.inventory_items[i].uid)
	for i in range(data.hot_bar_items.size()):
		if data.hot_bar_items[i]:
			hot_bar_items[i] = ItemDb.get_item(data.hot_bar_items[i].uid)
	for i in data.equipment_items:
		if data.equipment_items[i]:
			equipment_items[i] = ItemDb.get_item(data.equipment_items[i].uid)

func _array_to_obj(array: Array) -> Array:
	var res: Array = []
	for i: ItemData in array:
		if i != null:
			res.append(i.to_dict())
		else:
			res.append(null)
	return res

func inventory_items_to_obj() -> Array:
	return _array_to_obj(inventory_items)

func hot_bar_items_to_obj() -> Array:
	return _array_to_obj(hot_bar_items)

func trinket_items_to_obj() -> Array:
	return _array_to_obj(trinket_items)

func equipment_items_to_obj() -> Dictionary:
	var res: = {}
	for key: String in equipment_items:
		if equipment_items[key]:
			res[key] = equipment_items[key].to_dict()
		else:
			res[key] = null
	return res

func to_obj() -> Dictionary:
	return {
		"inventory_items": inventory_items_to_obj(),
		"hot_bar_items": hot_bar_items_to_obj(),
		"trinket_items": trinket_items_to_obj(),
		"equipment_items": equipment_items_to_obj()
	}
