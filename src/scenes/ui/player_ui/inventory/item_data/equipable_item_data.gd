class_name EquipableItemData extends ItemData


enum EquipSlot
{
	HELMET,
	SHIRT,
	PANTS,
	BOOTS,
	BACKPACK,
	POUCH,
	TRINKET
}

@export var equip_slot: EquipSlot
@export var stats: ItemStats
