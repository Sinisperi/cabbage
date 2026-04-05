@tool
class_name TerrainClipMap extends Node3D
const WORLD_SIZE: float = 32.0 * 64.0
#const map_resolution: int = 4096
var height_map_image: Image
@export var height_map: Texture2D
@onready var lod_0: MeshInstance3D = %LOD_0
@onready var lod_1: MeshInstance3D = %LOD_1
@onready var lod_0_col: CollisionShape3D = %LOD_0_col
var old_col_pos: Vector2 = Vector2(INF, INF)
var collision_map_image: Image
var collision_map_size: Vector2 =  Vector2(127.0, 127.0)
@onready var map_limit: float = WORLD_SIZE / 2.0 - (128.0 / 2.0)
@onready var camera: Camera3D = get_active_camera()
func _ready() -> void:
	height_map_image = Image.new()
	height_map_image = height_map.get_image()
	height_map_image.decompress()
	height_map_image.convert(Image.FORMAT_RF)
	collision_map_image = Image.create_empty(127, 127, false, Image.FORMAT_RF)
	collision_map_image.blit_rect(height_map_image, Rect2(Vector2.ZERO, collision_map_size), Vector2.ZERO)
	collision_map_image.convert(Image.FORMAT_RF)
	(lod_0_col.shape as HeightMapShape3D).update_map_data_from_image(collision_map_image, 0.0, 182.58 / 4.0)
	#HeightMapSampler.init(height_map, WORLD_SIZE)
	await get_tree().process_frame
	var tex: ImageTexture = ImageTexture.create_from_image(collision_map_image)
	$"../CanvasLayer/TextureRect".texture = tex
	
func _physics_process(_delta: float) -> void:
	move_clipmap_ring(lod_0, 4.0, 512.0)
	move_clipmap_ring(lod_1, 4.0, 1024.0)
	update_collision(32.0)

func move_clipmap_ring(ring: MeshInstance3D, spacing: float, size: float) -> void:
	if !camera:
		camera = get_active_camera()
	var limit: float = WORLD_SIZE / 2.0 - (size / 2.0)
	var x: float = clamp(camera.global_position.x, -limit, limit)
	var z: float = clamp(camera.global_position.z, -limit, limit)
	ring.global_position.x = floor(x / spacing) * spacing
	ring.global_position.z = floor(z / spacing) * spacing
	


func get_active_camera() -> Camera3D:
	if Engine.is_editor_hint():
		return EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
	else:
		return get_viewport().get_camera_3d()


func update_collision(spacing: float) -> void:
	if !camera:
		camera = get_active_camera()
	if !collision_map_image: return
	var pos: Vector2 = Vector2.ZERO
	var world_to_pixel: float = 1.0
	var limit: float = WORLD_SIZE / 2.0 - (collision_map_size.x / 2.0)
	pos.x = floor(camera.global_position.x / world_to_pixel) * world_to_pixel
	pos.y = floor(camera.global_position.z / world_to_pixel) * world_to_pixel
	
	pos.x = floor(pos.x / spacing) * spacing
	pos.y = floor(pos.y / spacing) * spacing
	pos.x = clamp(pos.x, -limit, limit)
	pos.y = clamp(pos.y, -limit, limit)
	if pos.x != old_col_pos.x || pos.y != old_col_pos.y:
		print("collision regen")
		var uv_x: float = (pos.x + (WORLD_SIZE / 2.0)) / world_to_pixel
		var uv_y: float = (pos.y + (WORLD_SIZE / 2.0)) / world_to_pixel
		var tx: int = int(uv_x - collision_map_size.x / 2.0)
		var ty: int = int(uv_y - collision_map_size.y / 2.0)
		#collision_map_image.blit_rect(height_map_image, Rect2(Vector2(tx, ty), collision_map_size), Vector2.ZERO)
		var temp_img: Image = height_map_image.get_region(Rect2(Vector2(tx, ty), collision_map_size))
		temp_img.convert(Image.FORMAT_RF)
		#collision_map_image.resize(int(collision_map_size.x / 4.0), int(collision_map_size.x / 4.0), Image.INTERPOLATE_NEAREST)
		temp_img.resize(int(collision_map_size.x / 4.0) + 1, int(collision_map_size.x / 4.0) + 1, Image.INTERPOLATE_LANCZOS)
		lod_0_col.scale = Vector3.ONE * 4.0
		(lod_0_col.shape as HeightMapShape3D).update_map_data_from_image(temp_img, 0.0, 182.58 / 4.0)
		old_col_pos = pos
		#lod_0_col.global_position.x = floor(pos.x / spacing) * spacing
		#lod_0_col.global_position.z = floor(pos.y / spacing) * spacing
		#lod_0_col.global_position.y = 0.01
		lod_0_col.global_position.x = pos.x 
		lod_0_col.global_position.z = pos.y
		var tex: ImageTexture = ImageTexture.create_from_image(temp_img)
		$"../CanvasLayer/TextureRect".texture = tex
