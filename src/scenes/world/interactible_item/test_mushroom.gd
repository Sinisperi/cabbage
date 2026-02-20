extends InteractibleItem


func _ready() -> void:
	pass

func being_interacted_with() -> bool:
	EventBus.inventory.item_pick_up_requested.emit(data)
	queue_free()
	return true
