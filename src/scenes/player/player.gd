class_name Player extends CharacterBody3D

@export var player_data: PlayerData

@export var friction: float = 40.0
@export var acceleration: float = 20.0
@export var walk_speed: float = 2.0
@export var jog_speed: float = 4.0
@export var sprint_speed: float = 5.0
@export var jump_velocity: float = 4.5

@export var default_fov: float = 90.0
@export var jog_fov_multiplier: float = 1.05

@onready var camera_3d: Camera3D = %Camera3D

@onready var current_speed: float = walk_speed
@onready var current_state: State = State.IDLE


enum State
{
	IDLE,
	WALKING,
	JOGGING
}
var current_blend_space: Vector2 = Vector2.ZERO
var input_direction: Vector2
var current_time_scale: float = 1.0

func _enter_tree() -> void:
	set_multiplayer_authority(int(name))

func _ready() -> void:
	if !is_multiplayer_authority():
		set_physics_process(false)
		set_process_input(false)
		set_process_unhandled_input(false)
		set_process_unhandled_key_input(false)
	else:
		camera_3d.make_current()
		Globals.player = self
		EventBus.ui.mouse_mode_changed.connect(_on_mouse_mode_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * 0.001
		camera_3d.rotation.x -= event.relative.y * 0.001


func _physics_process(delta: float) -> void:
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	_handle_state()
	_handle_movement(delta)
	_handle_animation(delta)


func _handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		
	current_speed = jog_speed if current_state == State.JOGGING else walk_speed
	var target_fov: float = default_fov * jog_fov_multiplier if current_state == State.JOGGING else default_fov
	camera_3d.fov = lerp(camera_3d.fov, target_fov, delta * 2.0)
	if input_direction:
		velocity = velocity.move_toward(global_transform.basis * Vector3(input_direction.x, 0.0, input_direction.y) * current_speed, delta * acceleration)
	else:
		velocity = velocity.move_toward(Vector3(0.0, velocity.y, 0.0), delta * friction)
	move_and_slide()
	
	
func _handle_state() -> void:
	match current_state:
		
		State.IDLE:
			
			if input_direction.length():
				if Input.is_action_pressed("jog"):
					current_state = State.JOGGING
				else:
					current_state = State.WALKING
			
		State.WALKING:

			if !input_direction.length():
				current_state = State.IDLE
			elif Input.is_action_pressed("jog"):
				current_state = State.JOGGING
				
		State.JOGGING:
			
			if !input_direction.length():
				current_state = State.IDLE
			elif Input.is_action_just_released("jog"):
				current_state = State.WALKING
			


func _handle_animation(delta: float) -> void:
	var animation_direction: Vector2 = input_direction
	var time_scale: float = 1.0
	if input_direction.y > 0.0:
		time_scale = -1.0
		animation_direction.x = -input_direction.x
		
	current_blend_space = lerp(current_blend_space, animation_direction, delta * 6.0)
	$AnimationTree.set("parameters/WalkBlendSpace/blend_position", current_blend_space)
	$AnimationTree.set("parameters/Transition/transition_request", _state_to_animation())
	$AnimationTree.set("parameters/JogTimeScale/scale", time_scale)
	$AnimationTree.set("parameters/WalkTimeScale/scale", time_scale)
	
	
func _state_to_animation() -> String:
	match current_state:
		State.IDLE:
			return "idle"
		State.WALKING:
			return "walking"
		State.JOGGING:
			return "jogging"
		_:
			return ""


func _on_mouse_mode_changed(value: bool) -> void:
	if is_multiplayer_authority():
		set_process_input(value)
		set_process_unhandled_input(value)
		set_process_unhandled_key_input(value)
