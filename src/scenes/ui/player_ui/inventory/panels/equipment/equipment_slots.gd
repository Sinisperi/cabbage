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
@export var equipped_items: Dictionary[Slot, EquipableItemData] = {

	Slot.HELMET: null,
	Slot.SHIRT: null,
	Slot.PANTS: null,
	Slot.BOOTS: null,
	Slot.BACKPACK: null,
	Slot.POUCH_01: null,
	Slot.POUCH_02: null,
	Slot.TRINKET: null,
}

func _ready() -> void:
	pass

func _on_item_equipped(item_data: EquipableItemData) -> void:
	# item_data.stats += player.stats
	pass
