class_name EquipmentSlot extends InventorySlot

@export var slot_type: EquipableItemData.EquipSlot

@onready var slot_icon: TextureRect = %SlotIcon

func _ready() -> void:
	super._ready()
	_set_slot_icon_based_on_type()
	


func _set_slot_icon_based_on_type() -> void:
	match slot_type:
		EquipableItemData.EquipSlot.ARMOR:
			slot_icon.texture = load("res://assets/icons/inventory/shirt_icon.png") 
		EquipableItemData.EquipSlot.BACKPACK:
			slot_icon.texture = load("res://assets/icons/inventory/backpack_icon.png")
		EquipableItemData.EquipSlot.POUCH:
			slot_icon.texture = load("res://assets/icons/inventory/puch_icon.png")
		EquipableItemData.EquipSlot.TRINKET:
			slot_icon.texture = load("res://assets/icons/inventory/trinket_icon.png") 
			
			 
			
