@tool
class_name ItemDrop extends RigidBody3D

@export var data: ItemData: set = _update_visuals_tool
@export_category("Interaction")

@export var interaction_area_shape: InteractionAreaShape


@onready var interaction_area: InteractionArea = %InteractionArea
@onready var mesh_instance: MeshInstance3D = %MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var interaction_area_collider: CollisionShape3D = %InteractionAreaCollider

enum InteractionAreaShape
{
	SPHERE,
	CAPSULE,
	BOX
}


func _update_visuals_tool(item_data: ItemData) -> void:
	if !is_inside_tree():
		await self.ready
	if item_data:
		mesh_instance.set_deferred("mesh", item_data.mesh)
		collision_shape_3d.set_deferred("shape", item_data.collision_shape)
		#mesh_instance.mesh = item_data.mesh
		#collision_shape_3d.shape = item_data.collision_shape
		generate_interaction_area(item_data.mesh)
	else:
		mesh_instance.mesh = null
		collision_shape_3d.shape = null
		interaction_area_collider.shape = null
	data = item_data
	
func generate_interaction_area(mesh: Mesh) -> void:
	var aabb: AABB = mesh.get_aabb()
	var longest_size: float = aabb.get_longest_axis_size()
	var shortest_size: float = aabb.get_shortest_axis_size()
	var new_collision_shape: Shape3D = null
	match interaction_area_shape:
		InteractionAreaShape.SPHERE:
			new_collision_shape = SphereShape3D.new()
			new_collision_shape.radius = longest_size / 2.0
		InteractionAreaShape.CAPSULE:
			new_collision_shape = CapsuleShape3D.new()
			new_collision_shape.height = longest_size
			new_collision_shape.radius = shortest_size
		_:
			new_collision_shape = BoxShape3D.new()
			new_collision_shape.size = aabb.size
			
	interaction_area_collider.set_deferred("shape", new_collision_shape)
	interaction_area_collider.set_deferred("position", aabb.get_center())

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	interaction_area.interacted_with.connect(_on_being_interacted_with)
	await get_tree().process_frame
	_update_visuals_tool(data)

func _on_being_interacted_with() -> bool:
	EventBus.inventory.item_pick_up_requested.emit(data)
	destroy_itself.rpc()
	return true

@rpc("any_peer", "call_local")
func destroy_itself() -> void:
	if multiplayer.is_server():
		queue_free()


func generate_entity_data() -> Dictionary:
	return {
		"item_data": data.to_dict(),
		"position": {
			"x": global_position.x,
			"y": global_position.y,
			"z": global_position.z,
		},
		"rotation": {
			"x": rotation.x,
			"y": rotation.y,
			"z": rotation.z
		}
		
	}
