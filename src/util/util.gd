@tool
class_name Util extends Node


@export var item_to_process: ItemData
@export_tool_button("Generate Collision","CollisionPolygon3D") var gen_col: Callable = generate_collision

func generate_collision() -> void:
	if !item_to_process:
		push_warning("No item to process have been provided")
		return
	
	if !item_to_process.mesh:
		push_warning("Item to process is missing a mesh data")
		return
	
	item_to_process.collision_shape = item_to_process.mesh.create_convex_shape()
	item_to_process.emit_changed()
	ResourceSaver.save(item_to_process)
	
