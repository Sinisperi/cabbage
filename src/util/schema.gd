class_name Schema extends RefCounted

var buffer: PackedByteArray
# 1cm precision for coordinate quantizing
var coord_precision_factor: float = 100.0
# maximum negative y coordinate. we are turning negative y into positive to prevent from
# wasting one bit in the coord int for the sign
var y_offset: int = 5000

enum Type {
	U8,
	U16,
	U32,
	U64,
	COORD
}


func _init(schema: Dictionary) -> void:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	for key: Type in schema:
		match(key):
			Type.U8:
				stream.put_8(schema[key])
			Type.U16:
				stream.put_16(schema[key])
			Type.U32:
				stream.put_32(schema[key])
			Type.U64:
				stream.put_64(schema[key])
			Type.COORD:
				var coord: int = 0
				var x: int = int(schema[key].x * coord_precision_factor) & 0xFFFFF # first 20 bits
				var y: int = int((schema[key].y + y_offset) * coord_precision_factor) & 0xFFFFFF # first 24 bits
				var z: int = int(schema[key].z * coord_precision_factor) & 0xFFFFF # first 20 bits again
				# first 20 bits is x coord, next 24 bits is y, next 20 is z
				coord = x | (y << 20) | (z << 44)
				stream.put_64(coord)
	buffer = stream.data_array
