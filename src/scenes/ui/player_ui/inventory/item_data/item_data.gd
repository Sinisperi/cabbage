class_name ItemData extends Resource

@export var item_name: String
@export var texture: Texture2D

var uid: String:
	get():
		return item_name.to_lower().replace(" ", "_")

func is_same_type(item_data: ItemData) -> bool:
	return item_data.uid == uid


func to_dict() -> Dictionary:
	return {
		"uid": uid
	}
