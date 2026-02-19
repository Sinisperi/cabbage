class_name EquipmentSlot extends InventorySlot

@onready var slot_icon: TextureRect = %SlotIcon


# TODO Maybe i dont need a separate script for equipment slot and just 
# have a slot type and is_equipment_slot
 
func _ready() -> void:
	super._ready()
	_set_slot_icon_from_type()
	is_equipment_slot = true


func _set_slot_icon_from_type() -> void:
	match slot_type:
		EquipableItemData.EquipmentType.HELMET:
			slot_icon.texture = load("res://assets/icons/inventory/helmet_icon.png")
		EquipableItemData.EquipmentType.SHIRT:
			slot_icon.texture = load("res://assets/icons/inventory/shirt_icon.png")
		EquipableItemData.EquipmentType.PANTS:
			slot_icon.texture = load("res://assets/icons/inventory/pants_icon.png")
		EquipableItemData.EquipmentType.BOOTS:
			slot_icon.texture = load("res://assets/icons/inventory/boots_icon.png")
		EquipableItemData.EquipmentType.BACKPACK:
			slot_icon.texture = load("res://assets/icons/inventory/backpack_icon.png")
		EquipableItemData.EquipmentType.TRINKET:
			slot_icon.texture = load("res://assets/icons/inventory/trinket_icon.png")
