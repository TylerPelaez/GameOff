@tool
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
		chain.scale.z = distance
		chain.look_at(target, Vector3.UP, true)
	
	if debug_sphere != null:
			debug_sphere.queue_free()
	if Engine.is_editor_hint():
		# The things I do for visual debugging tools :(
		if self in (EditorPlugin as Variant).new().get_editor_interface().get_selection().get_selected_nodes():
			debug_sphere = DrawDebug.make_debug_sphere(get_max_distance())
			add_child(debug_sphere)
			debug_sphere.global_position = global_position

func get_max_distance() -> float:
	return max_tiles * Box.GRID_SIZE + .505

func can_reach(target_pos: Vector3) -> bool:
	return target_pos.distance_to(global_position) <= get_max_distance()
