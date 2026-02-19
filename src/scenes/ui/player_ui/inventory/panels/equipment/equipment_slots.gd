class_name EquipmentSlots extends PanelContainer


@onready var equipment_grid: GridContainer = %EquipmentGrid

enum Slot
{
	HELMET,
	SHIRT,
	PANTS,
	BOOTS,
	BACKPACK,
	TRINKET_01,
	TRINKET_02,
	TRINKET_03
}
@export var equipped_items: Dictionary[Slot, EquipableItemData] = {

	Slot.HELMET: null,
	Slot.SHIRT: null,
	Slot.PANTS: null,
	Slot.BOOTS: null,
	Slot.BACKPACK: null,
	Slot.TRINKET_01: null,
	Slot.TRINKET_02: null,
	Slot.TRINKET_03: null,
}

@export var equipment_slots: Dictionary[Slot, EquipmentSlot] = {

	Slot.HELMET: null,
	Slot.SHIRT: null,
	Slot.PANTS: null,
	Slot.BOOTS: null,
	Slot.BACKPACK: null,
	Slot.TRINKET_01: null,
	Slot.TRINKET_02: null,
	Slot.TRINKET_03: null,
}

func _ready() -> void:
	pass

func _on_item_equipped(item_data: EquipableItemData) -> void:
	# item_data.stats += player.stats
	pass
