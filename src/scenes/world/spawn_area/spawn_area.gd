class_name SpawnArea extends Area3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func get_spawn_point() -> Vector2:
	var radius: float = collision_shape.shape.radius
	
	prints("global pos ", global_position, global_position.z - radius, global_position.z + radius, radius)
	return Vector2(randf_range(global_position.x - radius, global_position.x + radius), 
	randf_range(global_position.z - radius, global_position.z + radius))
