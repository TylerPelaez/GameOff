@tool
extends Node

func make_debug_sphere(size) -> MeshInstance3D:
	# Create sphere with low detail of size.
	var sphere = SphereMesh.new()
	sphere.radial_segments = 10
	sphere.rings = 10
	sphere.radius = size
	sphere.height = size * 2
	# Bright red material (unshaded).
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 1, 1, 0.25)
	material.flags_unshaded = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sphere.surface_set_material(0, material)
	
	# Add to meshinstance in the right place.
	var node = MeshInstance3D.new()
	node.mesh = sphere
	return node
