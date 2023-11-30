@tool
extends Area3D

@onready var collision_shape_3d = $CollisionShape3D
@onready var mesh_instance_3d = $MeshInstance3D


var material

# Called when the node enters the scene tree for the first time.
func _ready():
	material = mesh_instance_3d.mesh.surface_get_material(0).duplicate()
	mesh_instance_3d.mesh.surface_set_material(0, material)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		material.uv1_scale.x = scale.x
		material.uv1_scale.y = scale.z


func _on_body_entered(body):
	if body is Player3D:
		body.die()
