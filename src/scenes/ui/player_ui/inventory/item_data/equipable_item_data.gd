class_name EquipableItemData extends ItemData


enum EquipmentType
{
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
