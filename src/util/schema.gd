class_name Schema extends RefCounted

var _buffer: StreamPeerBuffer
var _schema: Dictionary

var data_array: PackedByteArray:
	get():
		return _buffer.data_array
# 1cm precision for coordinate quantizing
var coord_precision_factor: float = 100.0
# maximum negative y coordinate. we are turning negative y into positive to prevent from
# wasting one bit in the coord int for the sign
var y_offset: float = 5000.0

enum Type { S8, S16, S32, S64, U8, U16, U32, U64, COORD, STRING }

# TODO think about how to do this with nested inventories

# schema should be like this
#var schema: Dictionary = {
#"id": 3234,
#"position": Type.COORD,
#"something_else": Type.S8,
#"inventory": [Schema]

#}


func _init(schema: Dictionary) -> void:
	_schema = schema
	_buffer = StreamPeerBuffer.new()


func create_buffer(data: Dictionary) -> void:
	_buffer.clear()
	_to_buffer(data, _schema)


func _to_buffer(data: Dictionary, schema: Dictionary) -> void:
	for key: String in schema:
		match schema[key]:
			Type.S8:
				_buffer.put_8(data[key])
			Type.S16:
				_buffer.put_16(data[key])
			Type.S32:
				_buffer.put_32(data[key])
			Type.S64:
				_buffer.put_64(data[key])
			Type.U8:
				_buffer.put_u8(data[key])
			Type.U16:
				_buffer.put_u16(data[key])
			Type.U32:
				_buffer.put_u32(data[key])
			Type.U64:
				_buffer.put_u64(data[key])
			Type.STRING:
				_buffer.put_string(data[key])
			Type.COORD:
				var coord: int = 0
				var x: int = int(data[key].x * coord_precision_factor) & 0xFFFFF  # first 20 bits
				var y: int = int((data[key].y + y_offset) * coord_precision_factor) & 0xFFFFFF  # first 24 bits
				var z: int = int(data[key].z * coord_precision_factor) & 0xFFFFF  # first 20 bits again
				# first 20 bits is x coord, next 24 bits is y, next 20 is z
				coord = x | (y << 20) | (z << 44)
				_buffer.put_64(coord)
			_:
				if schema[key] is Array:
					_buffer.put_8(data[key].size())
					var array_item_schema: Dictionary = schema[key][0]
					for i: Dictionary in data[key]:
						_to_buffer(i, array_item_schema)

				elif schema[key] is Dictionary:
					_to_buffer(data[key], schema[key])


## Static function.
## I will get schema from the first byte of the thing that is the id of the resource in
## world Dictionary
## then from that i will make a resource and get the schema
## then, if schema's key is an array, i will get the first byte of that and repeat the process


func from_bytes(bytes: PackedByteArray) -> Dictionary:
	_buffer.data_array = bytes
	_buffer.seek(0)
	var result: Dictionary = _unpack_buffer(_schema)
	return result


func _unpack_buffer(schema: Dictionary) -> Dictionary:
	var res: Dictionary = {}
	for key: String in schema:
		match schema[key]:
			Type.S8:
				res[key] = _buffer.get_8()
			Type.S16:
				res[key] = _buffer.get_16()
			Type.S32:
				res[key] = _buffer.get_32()
			Type.S64:
				res[key] = _buffer.get_64()
			Type.U8:
				res[key] = _buffer.get_u8()
			Type.U16:
				res[key] = _buffer.get_u16()
			Type.U32:
				res[key] = _buffer.get_u32()
			Type.U64:
				res[key] = _buffer.get_u64()
			Type.STRING:
				res[key] = _buffer.get_string()
			Type.COORD:
				var coord_packed: int = _buffer.get_u64()
				var x: float = float(coord_packed & 0xFFFFF) / coord_precision_factor
				var y: float = (
					float((coord_packed >> 20) & 0xFFFFFF) / coord_precision_factor - y_offset
				)
				var z: float = float((coord_packed >> 44) & 0xFFFFF) / coord_precision_factor
				res[key] = Vector3(x, y, z)
			_:
				if schema[key] is Array:
					var array_size: int = _buffer.get_u8()
					res[key] = []
					(res[key] as Array).resize(array_size)
					var array_item_schema: Dictionary = schema[key][0]
					for i in range(array_size):
						var data: Dictionary = _unpack_buffer(array_item_schema)
						res[key][i] = data

				elif schema[key] is Dictionary:
					res[key] = _unpack_buffer(schema[key])
	return res


func get_schema() -> Dictionary:
	return _schema
