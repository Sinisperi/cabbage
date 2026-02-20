class_name EquipmentSlots extends PanelContainer


@onready var equipment_grid: GridContainer = %EquipmentGrid

@export var equipped_items: Dictionary[String, EquipableItemData] = {

	InventoryData.HELMET_SLOT: null,
	InventoryData.CHEST_SLOT: null,
	InventoryData.PANTS_SLOT: null,
	InventoryData.BOOTS_SLOT: null,
	InventoryData.BACKPACK_SLOT: null,
}

@export var equipment_slots: Dictionary[String, EquipmentSlot] = {

	InventoryData.HELMET_SLOT: null,
	InventoryData.CHEST_SLOT: null,
	InventoryData.PANTS_SLOT: null,
	InventoryData.BOOTS_SLOT: null,
	InventoryData.BACKPACK_SLOT: null,
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
	print_rich("[color=yellow]Itrem equippped [/color]", item_data)
	pass

func _on_item_unequipped(item_data: EquipableItemData) -> void:
	## TODO Unapply effects here
	print("item unequipped", item_data)
	pass


func init_equipment() -> void:
	pass
	#for s in equipment_slots:
		#print(s)
		#equipment_slots[s].set_item(equipped_items[s])
	
	#for t in trinket_slots.size():
		#trinket_slots[t].set_item(trinket_items[t])
