class_name ItemData extends Resource

@export var item_name: String
@export var texture: Texture2D

@export var mesh: Mesh
@export var collision_shape: ConvexPolygonShape3D
@export var interaction_area: Shape3D
var uid: String:
	get():
		var _uid: String = item_name.to_lower().replace(" ", "_")
		print(resource_path)
		print(ItemDb.id_from_name(_uid))
		return _uid


func _init() -> void:
	print(item_name)


func is_same_type(item_data: ItemData) -> bool:
	return item_data.uid == uid


func to_dict() -> Dictionary:
	return {
		"uid": uid,
	}
