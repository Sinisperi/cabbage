@tool
extends MultiMeshInstance3D

#@export var tree_container: Node3D
@export var tree_mesh: ArrayMesh
@export_tool_button("Multimesh", "Mesh") var ml: Callable = do_multimesh
@export_tool_button("Rendering Server", "RegionEdit") var sv: Callable = do_server
@export_tool_button("Clear", "ActionCut") var cl: Callable = clear_multimesh
@export var density: int = 3
var instance_ids: Array = []
var total_chunks: int = 16 * 16 * 4
var quantity: int = 30 * total_chunks
var area: float = total_chunks


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	do_multimesh()
	#do_server()


func do_multimesh() -> void:
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = quantity
	multimesh.mesh = tree_mesh
	for i in quantity:
		var pos: Vector3 = Vector3(randf_range(-area, area), 0.0, randf_range(-area, area))

		var b: Basis = Basis()
		var t: Transform3D = Transform3D(b, pos)
		multimesh.set_instance_transform(i, t)
		#print("hello ", pos)


func do_server() -> void:
	for i: RID in instance_ids:
		RenderingServer.free_rid(i)

	var i: int = quantity
	while i:
		render_tree()
		i -= 1


func render_tree(_t: Transform3D = Transform3D()) -> void:
	var instance_id: RID = RenderingServer.instance_create()
	var pos: Vector3 = Vector3(
		randf_range(-(64.0 * 80), 64.0 * 80), 0.0, randf_range(-(64.0 * 80), 64.0 * 80)
	)
	var b: Basis = Basis()
	var t: Transform3D = Transform3D(b, pos)
	RenderingServer.instance_set_base(instance_id, tree_mesh.get_rid())

	RenderingServer.instance_set_scenario(instance_id, get_world_3d().scenario)
	RenderingServer.instance_set_transform(instance_id, t)
	instance_ids.push_back(instance_id)


func _exit_tree() -> void:
	for i: RID in instance_ids:
		RenderingServer.free_rid(i)


func clear_multimesh() -> void:
	multimesh.instance_count = 0
	multimesh = null
	for i: RID in instance_ids:
		RenderingServer.free_rid(i)
	instance_ids = []
