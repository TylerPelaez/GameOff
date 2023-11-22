extends CharacterBody3D
class_name Player3D

@export var max_speed = 400
@export var accel = 1500
@export var friction = 600
@export var jump_strength = 1000
#@export var push_force: float = 200
#@export var drag_object_animation_time_seconds: float = 0.75
#
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree["parameters/playback"]
@onready var flashlight = $FlashlightHolder


#@onready var shape_cast_2d = $ShapeCast2D
#@onready var hold_position = $HoldPosition


var input = Vector3.ZERO
var direction = Vector3.RIGHT
#var in_interactable_area: bool = false
#var current_interactable: InteractableItem
#
#var current_movable: Movable
#var movable_anchor: Node2D
#
#var dragging_object_playing: bool = false
#var dragging_object_origin: Vector2
#var dragging_object_target: Vector2

#enum Mode {
#	Normal,
#	Hidden,
#	MovingObject
#}
#var mode = Mode.Normal
#
func _ready():
	animation_tree.active = true

func _physics_process(delta):
#	if mode == Mode.Normal:
		normal_mode(delta)
#	elif mode == Mode.MovingObject:
#		moving_object_mode(delta)

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

	if input == Vector3.ZERO:
		animation_state.travel("Idle")
	else:
		var animation_values = Vector2(input.x, input.z)
		animation_tree.set("parameters/Idle/blend_position", animation_values)
		animation_tree.set("parameters/Walk/blend_position", animation_values)
		animation_state.travel("Walk")
	move_and_slide()
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength
	
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	velocity.y -= delta * gravity

#	if move_and_slide(): # true if collided
#		for i in get_slide_collision_count():
#			var col = get_slide_collision(i)
#			if col.get_collider() is RigidBody2D:
#				col.get_collider().apply_force(col.get_normal() * -push_force)
#
#func moving_object_mode(delta):
#	if dragging_object_playing:
#		return
#
#	var input = get_input()
#	if input.x != 0 && input.y != 0:
#		input.y = 0
#		input = input.normalized()
#
#	var offset = (current_movable.GRID_SIZE * input)
#	if input != Vector2.ZERO && current_movable.can_move_by_amount(offset, shape_cast_2d):
#		global_position = movable_anchor.global_position - hold_position.position
#		dragging_object_origin = global_position
#		dragging_object_playing = true
#		dragging_object_target = global_position + offset
#		var tween = get_tree().create_tween().bind_node(self)
#		tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
#		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
#		tween.set_parallel(true)
#		tween.tween_property(self, "global_position", dragging_object_target, drag_object_animation_time_seconds)
#		tween.tween_method(current_movable.move_to, current_movable.global_position, current_movable.global_position + offset, drag_object_animation_time_seconds)
#		tween.chain().tween_callback(on_object_drag_complete)
#		tween.play()
#
#func on_object_drag_complete():
#	dragging_object_playing = false
#
#func _unhandled_input(event):
#	if event.is_action_pressed("interact") && mode == Mode.Normal:
#		if in_interactable_area and current_interactable != null:
#			current_interactable.interact()
#	elif event.is_action_pressed("move"):
#		if current_movable != null && mode == Mode.Normal:
#			start_moving(current_movable)
#		elif mode == Mode.MovingObject && !dragging_object_playing:
#			stop_moving()
#
#
#func start_moving(object: Movable):
#	current_movable = object
#	mode = Mode.MovingObject
#	object.start_moving()
#	var anchor = object.get_anchor_for_player(self)
#	movable_anchor = anchor.node
#
#	animation_tree.set("parameters/Idle/blend_position", anchor.player_face_direction)
#	animation_tree.set("parameters/Walk/blend_position", anchor.player_face_direction)
#	animation_state.travel("Idle")
#
#
#	global_position = movable_anchor.global_position - hold_position.position
#
#
#func stop_moving():
#	mode = Mode.Normal
#	current_movable.stop_moving()
#
#func _on_interactable_check_area_entered(area: Area2D):
#	in_interactable_area = true
#	var interactable = area.get_parent()
#	if current_interactable == null:
#		current_interactable = interactable
#
#
#func _on_interactable_check_area_exited(area):
#	var interactable = area.get_parent()
#	if interactable == current_interactable:
#		current_interactable = null
#		in_interactable_area = false
#
#
#func _on_movable_check_area_entered(area):
#	if mode != Mode.MovingObject:
#		current_movable = area
#
#func _on_movable_check_area_exited(area):
#	if mode != Mode.MovingObject:
#		current_movable = null
