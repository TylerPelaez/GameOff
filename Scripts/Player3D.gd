extends CharacterBody3D
class_name Player3D

@export var max_speed = 400
@export var accel = 1500
@export var friction = 600
@export var jump_strength = 1000

@export var drag_object_animation_time_seconds: float = 0.75
@export var max_fallible_tiles: int = 2

@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree["parameters/playback"]
@onready var flashlight = $FlashlightHolder


@onready var shape_cast = $ShapeCast3D
@onready var hold_position = $HoldPosition

@onready var interactable_not_blocked_ray_cast = $InteractableNotBlockedRayCast

@onready var remote_transform_3d = $RemoteTransform3D

var facing_dir

var hold_positions = {
	Vector2.LEFT: Vector3(-.064, 0, 0),
	Vector2.RIGHT: Vector3(.064, 0, 0),
	Vector2.UP: Vector3(0, 0, -0.064),
	Vector2.DOWN: Vector3(0, 0, 0.064),
}

var input = Vector3.ZERO
var direction = Vector3.RIGHT

var objects_in_range = []

var current_interactable
var movable_anchor: Node3D

var dragging_object_playing: bool = false
var dragging_object_origin: Vector3
var dragging_object_target: Vector3

enum Mode {
	Normal,
	Hidden,
	MovingObject
}

var mode = Mode.Normal

var last_on_ground_pos: Vector3

func _ready():
	animation_tree.active = true

func _physics_process(delta):
	if mode == Mode.Normal:
		normal_mode(delta)
	elif mode == Mode.MovingObject:
		moving_object_mode(delta)

func get_input():
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.z = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return input.normalized()

func normal_mode(delta):
	input = get_input()
	
	var ground_velocity = Vector2(velocity.x, velocity.z)
	
	if input == Vector3.ZERO:
		if ground_velocity.length() > (friction * delta):
			ground_velocity -= ground_velocity.normalized() * (friction * delta)
		else:
			ground_velocity = Vector3.ZERO
	else:
		ground_velocity += (Vector2(input.x, input.z) * accel * delta)
		ground_velocity = ground_velocity.limit_length(max_speed)

	velocity.x = ground_velocity.x
	velocity.z = ground_velocity.y

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength

	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	velocity.y -= delta * gravity

	move_and_slide()
	
	if is_on_floor():
		if last_on_ground_pos.y - global_position.y > max_fallible_tiles * Box.GRID_SIZE_Y:
			die()
		else:
			last_on_ground_pos = global_position

	if input == Vector3.ZERO:
		animation_state.travel("Idle")
	else:
		var animation_values = Vector2(input.x, input.z)
		animation_tree.set("parameters/Idle/blend_position", animation_values)
		animation_tree.set("parameters/Walk/blend_position", animation_values)
		animation_state.travel("Walk")
		
		update_objects()

func moving_object_mode(delta):
	if dragging_object_playing:
		return

	var input = get_input()
	if input.x != 0 && input.z != 0:
		input.z = 0
		input = input.normalized()

	var test_input = Vector2(input.x, input.z)
	if test_input != facing_dir && test_input != -facing_dir:
		return

	var offset = (current_interactable.GRID_SIZE * input)
	if input != Vector3.ZERO && current_interactable.can_move_by_amount(offset, shape_cast, self):
		var new_pos = movable_anchor.global_position - hold_position.position
		global_position.x = new_pos.x
		global_position.z = new_pos.z
		current_interactable.on_drag_start()
		dragging_object_origin = global_position
		dragging_object_playing = true
		dragging_object_target = global_position + offset
		var tween = get_tree().create_tween().bind_node(self)
		tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.set_parallel(true)
		tween.tween_property(self, "global_position", dragging_object_target, drag_object_animation_time_seconds)
		var result = current_interactable.get_all_boxes_in_row(offset, self)
		for box in result.values():
			tween.tween_method(box.move_to, box.global_position, box.global_position + offset, drag_object_animation_time_seconds)
		
		tween.chain().tween_callback(on_object_drag_complete)
		tween.play()

func on_object_drag_complete():
	dragging_object_playing = false
	if current_interactable.on_drag_complete():
		stop_moving()

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		if mode == Mode.Hidden:
			unhide()
		elif !is_on_floor():
			return
		elif mode == Mode.Normal &&  current_interactable != null and current_interactable is InteractableItem:
			current_interactable.interact()
			update_objects()
		elif current_interactable != null && mode == Mode.Normal and current_interactable is Box:
			start_moving(current_interactable)
		elif mode == Mode.MovingObject && !dragging_object_playing:
			stop_moving()
	if event.is_action_pressed("ui_cancel"):
		die()

func die():
	get_tree().change_scene_to_file("res://UI/game_over_screen.tscn")
#
func start_moving(object: Box):
	if object.state != Box.State.Default:
		return
	current_interactable = object
	mode = Mode.MovingObject
	object.start_moving()
	var anchor = object.get_anchor_for_player(self)
	movable_anchor = anchor.node
	hold_position.position = hold_positions[anchor.player_face_direction]


	facing_dir = anchor.player_face_direction
	animation_tree.set("parameters/Idle/blend_position", anchor.player_face_direction)
	animation_tree.set("parameters/Walk/blend_position", anchor.player_face_direction)
	animation_state.travel("Idle")

	var new_pos = movable_anchor.global_position - hold_position.position
	global_position.x = new_pos.x
	global_position.z = new_pos.z
	shape_cast.position = Vector3.ZERO
	
	hide_interaction_prompt()

func stop_moving():
	mode = Mode.Normal
	current_interactable.stop_moving()
	update_objects()

func _on_draggable_check_area_entered(area):
	var object = area.get_parent()
	objects_in_range.append(object)
	
	update_objects()

func update_objects():
	if mode == Mode.MovingObject:
		return # don't mess with whatever we're doinge
	
	if objects_in_range.size() == 0:
		current_interactable = null
		hide_interaction_prompt()
		return
	
	var prev_interactable = current_interactable
	
	current_interactable = null
	var max_distance_sq = 99999999
	for object in objects_in_range:
		if object is Box and !object.can_drag():
			continue
		
		if object is InteractableItem and !object.can_interact():
			continue
		
		var target_pos = object.global_position
		if object is InteractableItem:
			interactable_not_blocked_ray_cast.position = Vector3.ZERO
			target_pos = object.get_interaction_area_global_pos()
		
		# Check if theres a wall b/w the player and the object
		interactable_not_blocked_ray_cast.target_position = interactable_not_blocked_ray_cast.to_local(target_pos)
		interactable_not_blocked_ray_cast.force_raycast_update()
		if interactable_not_blocked_ray_cast.is_colliding() && interactable_not_blocked_ray_cast.get_collider().get_parent().get_parent() != object && interactable_not_blocked_ray_cast.get_collider().get_parent() != object:
			continue
		
		# If this is a box, check if the player would be able to even grab the box at a valid point
		if object is Box:
			var anchor = object.get_anchor_for_player(self)
			var candidate_hold_position = hold_positions[anchor.player_face_direction]
			var candidate_position = anchor.node.global_position - candidate_hold_position
			candidate_position.y = global_position.y

			interactable_not_blocked_ray_cast.global_position = candidate_position
			interactable_not_blocked_ray_cast.target_position = Vector3(0, -0.11, 0) # height of the player currently
			interactable_not_blocked_ray_cast.force_raycast_update()
			# this means the player would not have ground beneath them, so we should not allow holding the box here
			if !interactable_not_blocked_ray_cast.is_colliding():
				continue
			
			shape_cast.clear_exceptions()
			var children = object.get_children()
			for child in children:
				if child is CollisionObject3D:
					shape_cast.add_exception(child)
				children.append_array(child.get_children())
			
			var dir_to_anchor = (candidate_position - object.global_position)
			dir_to_anchor.y = 0
			shape_cast.global_position = object.global_position
			shape_cast.target_position = dir_to_anchor.normalized() * (Box.GRID_SIZE / 2)
			shape_cast.force_shapecast_update()
			if shape_cast.is_colliding():
				continue
			
		
		var distance_sq = global_position.distance_squared_to(object.global_position)
		if current_interactable == null || max_distance_sq > distance_sq:
			current_interactable = object
			max_distance_sq = distance_sq
	
	if prev_interactable != null and current_interactable == null:
		hide_interaction_prompt()
	
	if current_interactable != null:
		show_interaction_prompt(current_interactable)

func _on_draggable_check_area_exited(area):
	var object = area.get_parent()
	objects_in_range.erase(object)
	
	update_objects()

func show_interaction_prompt(object):
	EventManager.show_interaction_prompt.emit(object)

func hide_interaction_prompt():
	EventManager.hide_interaction_prompt.emit()

func hide_inside_object(hiding_place: InteractableItem):
	if mode == Mode.Normal:
		visible = false
		mode = Mode.Hidden
		hide_interaction_prompt()

func unhide():
	if mode == Mode.Hidden:
		mode = Mode.Normal
		visible = true
		update_objects()

func is_hidden() -> bool:
	return mode == Mode.Hidden

func assign_camera_rig(camera_rig: Node3D):
	remote_transform_3d.remote_path = remote_transform_3d.get_path_to(camera_rig)

