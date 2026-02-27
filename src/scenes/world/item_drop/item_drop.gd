@tool
class_name ItemDrop extends RigidBody3D

@export var data: ItemData: set = _update_visuals_tool
@export_category("Interaction")



@onready var interaction_area: InteractionArea = %InteractionArea
@onready var mesh_instance: MeshInstance3D = %MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var interaction_area_collider: CollisionShape3D = %InteractionAreaCollider




func _update_visuals_tool(item_data: ItemData) -> void:
	data = item_data
	if Engine.is_editor_hint():
		if !is_inside_tree():
			await self.ready
			await update_visuals()
		
	

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	interaction_area.interacted_with.connect(_on_being_interacted_with)
	if multiplayer.is_server():
		await update_visuals()
	sleeping_state_changed.connect(_on_sleeping_state_changed)

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
			"x": position.x,
			"y": position.y,
			"z": position.z,
		},
		"rotation": {
			"x": rotation.x,
			"y": rotation.y,
			"z": rotation.z
		}
		
	}



func update_visuals() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	if data:
		mesh_instance.set_deferred("mesh", data.mesh)
		collision_shape_3d.set_deferred("shape", data.collision_shape)
		interaction_area_collider.set_deferred("shape", data.interaction_area)
		var aabb_center: Vector3 = data.mesh.get_aabb().get_center()
		interaction_area_collider.set_deferred("position",aabb_center)
	else:
		mesh_instance.mesh = null
		collision_shape_3d.shape = null
		interaction_area_collider.shape = null
	await get_tree().process_frame
	process_mode = Node.PROCESS_MODE_INHERIT	


func _on_sleeping_state_changed() -> void:
	if sleeping:
		freeze = true
