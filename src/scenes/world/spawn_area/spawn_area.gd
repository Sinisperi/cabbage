class_name SpawnArea extends Area3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	pass

func get_spawn_point() -> Vector2:
	var radius: float = collision_shape.shape.radius
	return Vector2(randf_range(global_position.x - radius, global_position.x + radius), 
	randf_range(global_position.y - radius, global_position.y + radius))
