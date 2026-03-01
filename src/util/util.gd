@tool
class_name Util extends Node


@export var item_to_process: ItemData
@export var interaction_area_shape: InteractionAreaShape
@export_tool_button("Generate Collision","CollisionPolygon3D") var gen_col: Callable = generate_collision
@export_tool_button("Generate Interaction Area","Area3D") var gen_int: Callable = generate_interaction
@export_tool_button("Chunkify", "ActionCut") var ch: Callable = chunkify

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


const CHUNK_SIZE: int = 64
func chunkify() -> void:
	var mesh: Mesh = $MeshInstance3D.mesh
	var mdt: MeshDataTool = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	var chunks: Dictionary = {}
	for surf in range(mesh.get_surface_count()):
		
		for f in range(mdt.get_face_count()):
			var vertex_location: Vector3 = mdt.get_vertex(mdt.get_face_vertex(f, 0))
			
			var key: String = str(floor(vertex_location.x / CHUNK_SIZE)) + "_" + str(floor(vertex_location.z / CHUNK_SIZE))
			if !chunks.has(key):
				var st: SurfaceTool = SurfaceTool.new()
				st.begin(Mesh.PRIMITIVE_TRIANGLES)
				chunks[key] = st
			#var st: SurfaceTool = chunks[key]
			for i in range(3):
				var idx: int = mdt.get_face_vertex(f, i)
				chunks[key].set_normal(mdt.get_vertex_normal(idx))
				chunks[key].set_tangent(mdt.get_vertex_tangent(idx))
				chunks[key].set_color(mdt.get_vertex_color(idx))
				chunks[key].set_uv(mdt.get_vertex_uv(idx))
				chunks[key].add_vertex(mdt.get_vertex(idx))
			
		for key: String in chunks:
			var st: SurfaceTool = chunks[key]
			var new_mesh: ArrayMesh = st.commit()
			var mesh_instance: MeshInstance3D = MeshInstance3D.new()
			mesh_instance.mesh = new_mesh
			mesh_instance.name = "Chunk_" + key
			add_child(mesh_instance)
			mesh_instance.owner = get_tree().edited_scene_root
