@tool
class_name Util extends Node


@export var item_to_process: ItemData
@export var interaction_area_shape: InteractionAreaShape
@export_tool_button("Generate Collision","CollisionPolygon3D") var gen_col: Callable = generate_collision
@export_tool_button("Generate Interaction Area","Area3D") var gen_int: Callable = generate_interaction

enum InteractionAreaShape
{
	SPHERE,
	CAPSULE,
	BOX
}

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
	

func generate_interaction() -> void:
	var aabb: AABB = item_to_process.mesh.get_aabb()
	var longest_size: float = aabb.get_longest_axis_size()
	var shortest_size: float = aabb.get_shortest_axis_size()
	var new_collision_shape: Shape3D = null
	match interaction_area_shape:
		InteractionAreaShape.SPHERE:
			new_collision_shape = SphereShape3D.new()
			new_collision_shape.radius = longest_size / 2.0 + 0.2
		InteractionAreaShape.CAPSULE:
			new_collision_shape = CapsuleShape3D.new()
			new_collision_shape.height = longest_size
			new_collision_shape.radius = shortest_size
		_:
			new_collision_shape = BoxShape3D.new()
			new_collision_shape.size = aabb.size
	item_to_process.interaction_area = new_collision_shape
	item_to_process.emit_changed()
	ResourceSaver.save(item_to_process)
