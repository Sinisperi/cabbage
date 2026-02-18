class_name EquipmentSlot extends InventorySlot

@export var slot_type: EquipableItemData.EquipSlot

@onready var slot_icon: TextureRect = %SlotIcon

func _ready() -> void:
	super._ready()
	_set_slot_icon_from_type() 
			


func _set_slot_icon_from_type() -> void:
	match slot_type:
		EquipableItemData.EquipSlot.HELMET:
			slot_icon.texture = load("res://assets/icons/inventory/helmet_icon.png")
		EquipableItemData.EquipSlot.SHIRT:
			slot_icon.texture = load("res://assets/icons/inventory/shirt_icon.png")
		EquipableItemData.EquipSlot.PANTS:
			slot_icon.texture = load("res://assets/icons/inventory/pants_icon.png")
		EquipableItemData.EquipSlot.BOOTS:
			slot_icon.texture = load("res://assets/icons/inventory/boots_icon.png")
		EquipableItemData.EquipSlot.BACKPACK:
			slot_icon.texture = load("res://assets/icons/inventory/backpack_icon.png")
		EquipableItemData.EquipSlot.POUCH:
			slot_icon.texture = load("res://assets/icons/inventory/puch_icon.png")
		EquipableItemData.EquipSlot.TRINKET:
			slot_icon.texture = load("res://assets/icons/inventory/trinket_icon.png")
