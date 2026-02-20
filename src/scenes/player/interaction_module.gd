class_name InteractionModule extends Area3D


@onready var interaction_ray: RayCast3D = %InteractionRay

var interactible_items_in_area: int:
	set(value):
		interactible_items_in_area = value
		print(value)
	get():
		return interactible_items_in_area


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	interaction_ray.enabled = false
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if interaction_ray.is_colliding():
			var collider: Node = interaction_ray.get_collider()
			if collider is InteractibleItem:
				collider.being_looked_at.emit()


func _on_area_entered(area: Area3D) -> void:
	if area is InteractibleItem:
		interactible_items_in_area += 1
		if interactible_items_in_area == 1:
			interaction_ray.enabled = true
	else:
		print("not interactivel item")


func _on_area_exited(area: Area3D) -> void:
	print("area exited you fuck")
	if area is InteractibleItem:
		interactible_items_in_area -= 1
		if interactible_items_in_area <= 0:
			interaction_ray.enabled = false


func _update_interaction_ray() -> void:
	if interaction_ray.is_colliding():
		var collider: Node = interaction_ray.get_collider()
		if collider is InteractibleItem:
			collider.being_interacted_with()


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_update_interaction_ray()


func disable() -> void:
	set_process(false)
	set_process_input(false)
	set_physics_process(false)
