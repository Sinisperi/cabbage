class_name InventoryData extends Resource


enum EquipmentType {
	NONE,
	HELMET,
	CHEST,
	PANTS,
	BOOTS,
	BACKPACK,
	TRINKET
}

#const HELMET_SLOT = "HELMET_SLOT"
#const CHEST_SLOT = "CHEST_SLOT"
#const PANTS_SLOT = "PANTS_SLOT"
#const BOOTS_SLOT = "BOOTS_SLOT"
#const BACKPACK_SLOT = "BACKPACK_SLOT"

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

## TURN THIS ALL INTO ONE ARRAY

#@export var equipment_items: Dictionary[EquipmentType, EquipableItemData] = {
	#EquipmentType.HELMET: null,
	#EquipmentType.CHEST: null,
	#EquipmentType.PANTS: null,
	#EquipmentType.BOOTS: null,
	#EquipmentType.BACKPACK: null
#}
#
#@export var trinket_items: Array[TrinketData] = [null, null, null]


@export var equipment_items: Array[EquipableItemData] = [null, null, null, null, null, null, null, null, ]

func _init(data: Dictionary = {}) -> void:
	if data.is_empty(): return
	for i in range(data.inventory_items.size()):
		if data.inventory_items[i]:
			inventory_items[i] = ItemDb.get_item(data.inventory_items[i].uid)
	for i in range(data.hot_bar_items.size()):
		if data.hot_bar_items[i]:
			hot_bar_items[i] = ItemDb.get_item(data.hot_bar_items[i].uid)
	for i in range(data.equipment_items.size()):
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


func equipment_items_to_obj() -> Array:
	return _array_to_obj(equipment_items)


func to_obj() -> Dictionary:
	return {
		"inventory_items": inventory_items_to_obj(),
		"hot_bar_items": hot_bar_items_to_obj(),
		"equipment_items": equipment_items_to_obj()
	}
