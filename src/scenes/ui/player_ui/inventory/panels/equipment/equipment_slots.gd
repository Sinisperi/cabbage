class_name EquipmentSlots extends PanelContainer


@onready var equipment_grid: GridContainer = %EquipmentGrid

enum Slot
{
	HELMET,
	SHIRT,
	PANTS,
	BOOTS,
	BACKPACK,
}
@export var equipped_items: Dictionary[Slot, EquipableItemData] = {

	Slot.HELMET: null,
	Slot.SHIRT: null,
	Slot.PANTS: null,
	Slot.BOOTS: null,
	Slot.BACKPACK: null,
}

@export var equipment_slots: Dictionary[Slot, EquipmentSlot] = {

	Slot.HELMET: null,
	Slot.SHIRT: null,
	Slot.PANTS: null,
	Slot.BOOTS: null,
	Slot.BACKPACK: null,
}

@export var trinket_slots: Array[EquipmentSlot] = []
@export var trinket_items: Array[TrinketData] = [null, null, null]


func _ready() -> void:
	EventBus.inventory.equipment.item_equipped.connect(_on_item_equipped)
	EventBus.inventory.equipment.item_unequipped.connect(_on_item_unequipped)
	init_equipment()
	pass

func _on_item_equipped(item_data: EquipableItemData) -> void:
	# item_data.stats += player.stats
	## TODO Apply effects here
	print("Itrem equippped ", item_data)
	pass

func _on_item_unequipped(item_data: EquipableItemData) -> void:
	
	pass


func init_equipment() -> void:
	for s in equipment_slots:
		print(s)
		equipment_slots[s].set_item(equipped_items[s])
	
	for t in trinket_slots.size():
		trinket_slots[t].set_item(trinket_items[t])
