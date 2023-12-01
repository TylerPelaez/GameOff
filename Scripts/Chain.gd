extends Node3D
class_name Chain

@export var max_tiles = 5
@export var attached: Node3D : set = set_attached

@onready var chain = $Chain


var material: StandardMaterial3D

var debug_sphere

func set_attached(val):
	if attached != null:
		attached.attached_to_chain = false
		attached.attached_chain = null
	attached = val

func _ready():
	material = chain.mesh.surface_get_material(0).duplicate()
	chain.mesh.surface_set_material(0, material)
	if attached != null and attached is Box:
		attached.attached_to_chain = true
		attached.attached_chain = self
		

func _process(delta):
	if attached != null:
		var target = attached.global_position
		if attached is Box and attached.use_attachment_pos:
			target = attached.attachment_pos
			
		
		var distance = target.distance_to(global_position)
		material.uv1_scale.x = distance
		var max_distance = get_max_distance()
		var bgval = clampf(1.0 - (distance / get_max_distance()), 0.0, 1.0)
		chain.mesh.surface_get_material(0).albedo_color = Color(1.0, bgval, bgval)
		chain.scale.z = distance
		chain.look_at(target, Vector3.UP, true)

func get_max_distance() -> float:
	return max_tiles * Box.GRID_SIZE + .505

func can_reach(target_pos: Vector3) -> bool:
	return target_pos.distance_to(global_position) <= get_max_distance()
