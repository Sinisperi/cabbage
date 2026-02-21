class_name PlayerData extends Resource

@export var username: String

@export var inventory_columns_expansion: int = 0
@export var hot_bar_slots_expansion: int = 0

@export var inventory: InventoryData = load("res://src/scenes/player/resources/test_inventory.tres").duplicate()
