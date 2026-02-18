class_name EquipableItemData extends ItemData


enum EquipSlot
{
	ARMOR,
	BACKPACK,
	POUCH,
	TRINKET
}

@export var equip_slot: EquipSlot
@export var stats: ItemStats
