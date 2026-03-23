class_name ItemData extends Resource

@export var item_name: String

@export var texture: Texture2D

@export var mesh: Mesh
@export var collision_shape: ConvexPolygonShape3D
@export var interaction_area: Shape3D

var schema: Schema = null

var name_normalized: String:
	get():
		return item_name.to_lower().replace(" ", "_")

var uid: String:
	get():
		var _uid: String = item_name.to_lower().replace(" ", "_")
		#print(ItemDb.id_from_name(_uid))
		return _uid


func _init() -> void:
	schema = (
		Schema
		. new(
			{
				"id": Schema.Type.U16,
			}
		)
	)


func is_same_type(item_data: ItemData) -> bool:
	return item_data.uid == uid


func to_bytes() -> PackedByteArray:
	schema.create_buffer({"id": ItemDb.id_from_name(name_normalized)})
	return schema.data_array


func from_bytes(bytes: PackedByteArray) -> void:
	var data: Dictionary = schema.from_bytes(bytes)
	print("item data ", data)


func to_dict() -> Dictionary:
	return {
		"uid": uid,
	}


func get_schema() -> Dictionary:
	return schema.get_schema()


func register() -> void:
	ItemDb.id_from_name(uid)
