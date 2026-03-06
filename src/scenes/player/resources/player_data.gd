class_name PlayerData extends Resource

@export var username: String
@export var inventory: InventoryData = load("res://src/scenes/player/resources/test_inventory.tres").duplicate()


func _init(data: Dictionary = {}) -> void:
	print(data)
	#return
	if data.is_empty(): return
	username = data.username
	inventory = InventoryData.new(data.inventory)


func to_obj() -> Dictionary:
	return {
		"username": username,
		"inventory": inventory.to_obj()
	}

func from_obj(data: Dictionary = {}) -> void:
	if data.is_empty(): return
	username = data.username
	inventory = InventoryData.new(data.inventory)
