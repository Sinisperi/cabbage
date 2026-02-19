class_name EquipableItemData extends ItemData


enum EquipmentType
{
	NONE,
	HELMET,
	SHIRT,
	PANTS,
	BOOTS,
	BACKPACK,
	POUCH,
	TRINKET
}

@export var equip_slot: EquipmentType
@export var stats: ItemStats


func apply_stats() -> void:
	pass
