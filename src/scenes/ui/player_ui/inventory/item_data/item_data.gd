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
var _uid: int = -1
var uid: int:
	get():
		if _uid < 0:
			_uid = ItemDb.id_from_name(name_normalized)
		return _uid


func _init() -> void:
	schema = (Schema.new({"id": Schema.Type.U16, "quantity": Schema.Type.U32}))


func _ready() -> void:
	print(item_name)


func is_same_type(item_data: ItemData) -> bool:
	return item_data.uid == uid


func to_bytes() -> PackedByteArray:
	schema.create_buffer({"id": ItemDb.id_from_name(name_normalized), "quantity": 123456})
	return schema.data_array


## we get the dict of everything
## every item will figure out its own stuff and overload this function
## by default it's just an id


func from_bytes(bytes: PackedByteArray) -> void:
	schema.from_bytes(bytes)


func to_dict() -> Dictionary:
	return {
		"uid": uid,
	}


func get_schema() -> Dictionary:
	return schema.get_schema()
