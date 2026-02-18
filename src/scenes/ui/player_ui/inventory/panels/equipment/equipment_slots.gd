class_name EquipmentSlots extends PanelContainer


@onready var equipment_grid: GridContainer = %EquipmentGrid

enum Slot
{
	HELMET,
	SHIRT,
	PANTS,
	BOOTS,
	BACKPACK,
	POUCH_01,
	POUCH_02,
	TRINKET
}


func init_equipment(equipment: Dictionary) -> void:
	pass
