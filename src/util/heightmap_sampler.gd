class_name HeightMapSampler extends RefCounted

static var shader_file: RDShaderFile = preload("uid://cjfjgxpx0xo26")
static var rendering_device: RenderingDevice
static var shader: RID
static var pipeline: RID
static var height_map: RID
static var sampler: RID
static var height_map_texture: Texture2D
static var height_map_resolution: int
static var uniform_texture: RDUniform
static var world_size: int

static func init(height_map_p: Texture2D, world_size_p: int) -> void:
	var temp_img: Image = height_map_p.get_image()
	temp_img.convert(Image.FORMAT_RF)
	height_map_p = ImageTexture.create_from_image(temp_img)
	height_map_texture = height_map_p
	
	rendering_device = RenderingServer.create_local_rendering_device()
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rendering_device.shader_create_from_spirv(shader_spirv)
	pipeline = rendering_device.compute_pipeline_create(shader)
	
	var fmt := RDTextureFormat.new()
	height_map_resolution = height_map_p.get_width()
	fmt.width = int(height_map_resolution)
	fmt.height = int(height_map_resolution)
	fmt.format = RenderingDevice.DATA_FORMAT_R32_SFLOAT
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	height_map = rendering_device.texture_create(fmt, RDTextureView.new(), [temp_img.get_data()])
	
	
	var sampler_attr: RDSamplerState = RDSamplerState.new()
	sampler_attr.mag_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	sampler_attr.min_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	sampler_attr.mip_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	sampler_attr.repeat_u = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	sampler_attr.repeat_v = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	sampler = rendering_device.sampler_create(sampler_attr)
	
	#height_map = RenderingServer.texture_get_rd_texture(height_map_p.get_rid())
	world_size = world_size_p
	


static func get_height_data(pos: Vector2, area: Vector2i) -> PackedFloat32Array:
	if not rendering_device or not height_map_texture: return PackedFloat32Array()
	#height_map = RenderingServer.texture_get_rd_texture(height_map_texture.get_rid())
	if !height_map.is_valid():
		return PackedFloat32Array()
	var output: PackedFloat32Array = PackedFloat32Array()
	output.resize(area.x * area.y)
	var buffer: RID = rendering_device.storage_buffer_create(output.size() * 4, output.to_byte_array())
	
	var uniform_buffer: RDUniform = RDUniform.new()
	uniform_buffer.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform_buffer.binding = 0
	uniform_buffer.add_id(buffer)
	
	uniform_texture = RDUniform.new()
	uniform_texture.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	uniform_texture.binding = 1
	uniform_texture.add_id(sampler)
	uniform_texture.add_id(height_map)
	
	var uniform_set: RID = rendering_device.uniform_set_create([uniform_buffer, uniform_texture], shader, 0)
	var uniform_buffer_data: PackedByteArray = PackedFloat32Array(
		[
			pos.x,
			pos.y,
			float(world_size),
			float(height_map_resolution),
		]
	).to_byte_array()
	
	var compute_list: int = rendering_device.compute_list_begin()
	rendering_device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rendering_device.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rendering_device.compute_list_set_push_constant(compute_list, uniform_buffer_data, uniform_buffer_data.size())
	var x_groups: int = ceili(float(area.x) / 8)
	var y_groups: int = ceili(float(area.y) / 8)
	rendering_device.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
	rendering_device.compute_list_end()
	rendering_device.submit()
	rendering_device.sync()
	var res_bytes: PackedByteArray = rendering_device.buffer_get_data(buffer)
	var res_height_data: PackedFloat32Array = res_bytes.to_float32_array()
	rendering_device.free_rid(buffer)
	#rendering_device.free_rid(uniform_set)
	return res_height_data


static func delete() -> void:
	if pipeline.is_valid():
		rendering_device.free_rid(pipeline)
	if shader.is_valid():
		rendering_device.free_rid(shader)
	rendering_device = null
