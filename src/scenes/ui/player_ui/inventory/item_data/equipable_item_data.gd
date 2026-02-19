class_name EquipableItemData extends ItemData


enum EquipmentType
{
	NONE,
	HELMET,
	SHIRT,
	PANTS,
	BOOTS,
	BACKPACK,
	TRINKET
}

@export var equipment_type: EquipmentType
@export var stats: ItemStats


func apply_stats() -> void:
	pass
