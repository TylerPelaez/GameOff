extends Node3D

var player
@export var camera_state_blend_speed = 2.0

@onready var upper_ray_cast = $UpperRayCast
@onready var lower_ray_cast = $LowerRayCast
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree["parameters/playback"]

var blend_pos = 0.0


@onready var camera_3d = $Camera3D
@onready var camera_environment_animation_tree = $Camera3D/AnimationTree


var current_tween: Tween

func _ready():
	blend_pos = 0.0
	player = get_tree().get_nodes_in_group(&"player")[0]

	
	EventManager.darken.connect(on_darken)
	EventManager.lighten.connect(on_lighten)
	camera_environment_animation_tree.set("parameters/blend_position", 1.0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	upper_ray_cast.target_position = upper_ray_cast.to_local(player.global_position)
	lower_ray_cast.target_position = lower_ray_cast.to_local(player.global_position)
	upper_ray_cast.force_raycast_update()
	lower_ray_cast.force_raycast_update()
	if upper_ray_cast.is_colliding():
		blend_pos += delta * camera_state_blend_speed
		if blend_pos > 1.0:
			blend_pos = 1.0
	elif !lower_ray_cast.is_colliding():
		blend_pos -= delta * camera_state_blend_speed
		if blend_pos <= 0.0:
			blend_pos = 0.0

	animation_tree.set("parameters/BlendSpace1D/blend_position", blend_pos)


func on_darken():
	if current_tween != null:
		current_tween.stop()
	current_tween = get_tree().create_tween().bind_node(self)
	current_tween.tween_property(camera_environment_animation_tree, "parameters/blend_position", 0, 1.0)


func on_lighten():
	if current_tween != null:
		current_tween.stop()
	
	current_tween = get_tree().create_tween().bind_node(self)
	current_tween.tween_property(camera_environment_animation_tree, "parameters/blend_position", 1.0, 1.0)
