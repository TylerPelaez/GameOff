extends MeshInstance3D
class_name Box

const FALL_DISTANCE_MARGIN = 0.1

const GRID_SIZE = .5
const GRID_SIZE_Y = 0.333333333333

const PUSH_CHAIN_LIMIT = 3

@onready var shape_cast = $ShapeCast3D
@onready var draggable_shape = $DraggableArea/CollisionShape3D
@onready var draggable_area = $DraggableArea

@onready var collision_shape_3d = $StaticBody3D/CollisionShape3D


@onready var anchor_right = $AnchorRight
@onready var anchor_left = $AnchorLeft
@onready var anchor_forward = $AnchorForward
@onready var anchor_behind = $AnchorBehind

@onready var ray_cast_3d = $RayCast3D

@export var attached_to_chain: bool = false
@export var attached_chain: Chain
@export var use_attachment_pos: bool = false
@export var attachment_pos: Vector3

var lower_box
var upper_box


enum State {
	Default,
	Moving,
	Falling,
}


var state = State.Default

func _ready():
	ray_cast_3d.position = Vector3.ZERO
	ray_cast_3d.target_position = Vector3(0, -20, 0)
	ray_cast_3d.force_raycast_update()
	
	if ray_cast_3d.is_colliding():
		var obj = ray_cast_3d.get_collider().get_parent()
		if obj is Box:
			obj.upper_box = self
			lower_box = obj

func _physics_process(delta):
	if !attached_to_chain:
		return
	
	ray_cast_3d.target_position = Vector3(0, -(GRID_SIZE_Y / 2.0) - .5, 0)
	ray_cast_3d.force_raycast_update()
	
	if !ray_cast_3d.is_colliding():
		if state == State.Falling:
			return
		use_attachment_pos = true
		var chain_dir = global_position.direction_to(attached_chain.global_position)
		chain_dir.y = 0
		chain_dir = chain_dir.normalized()
		attachment_pos = global_position + (chain_dir * GRID_SIZE / 2.0)
		attachment_pos.y += GRID_SIZE_Y / 2.0
	else:
		use_attachment_pos = false


func start_moving():
	state = State.Moving
	if upper_box != null:
		upper_box.start_moving()

func stop_moving():
	if state != State.Falling:
		state = State.Default
		if upper_box != null:
			upper_box.stop_moving()

func move_to(position: Vector3):
	global_position.x = position.x
	global_position.z = position.z

func on_drag_start():
	if lower_box != null:
		lower_box.upper_box = null
		lower_box = null

func on_drag_complete() -> bool:
	return try_fall_and_update_lower_box()

func try_fall_and_update_lower_box(target_pos = null) -> bool:
	if target_pos == null:
		ray_cast_3d.position = Vector3.ZERO
		ray_cast_3d.target_position = Vector3(0, -6, 0)
		ray_cast_3d.force_raycast_update()
		if ray_cast_3d.is_colliding():
			var collision_position = ray_cast_3d.get_collision_point()
			var obj = ray_cast_3d.get_collider().get_parent()
		
			if obj is Box:
				obj.upper_box = self
				lower_box = obj
			
			if global_position.y - (collision_position.y + GRID_SIZE_Y / 2.0) > FALL_DISTANCE_MARGIN:
				target_pos = (collision_position + Vector3(0, GRID_SIZE_Y / 2.0, 0)) if !attached_to_chain else (global_position - Vector3(0, GRID_SIZE_Y, 0))
			else:
				return false
			

		else:
			push_error("Box cannot find ground, will now float")
			return false
	
	
	if global_position.y - target_pos.y > FALL_DISTANCE_MARGIN:
		fall(Vector3(global_position.x, target_pos.y, global_position.z), attached_to_chain)
		if upper_box != null:
			upper_box.try_fall_and_update_lower_box(target_pos + Vector3(0, GRID_SIZE_Y, 0))
		
		
		return true

	return false
	
	

func fall(target_position: Vector3, suspend: bool):
	var tween = get_tree().create_tween().bind_node(self)
	var collision_position = ray_cast_3d.get_collision_point()
	state = State.Falling
	tween.tween_property(self, "global_position", target_position, 0.25)
	tween.tween_callback(on_fall_complete)
	
	
	if attached_to_chain:
		attachment_pos = global_position
		use_attachment_pos = true
		
		var target_attachment_pos = (global_position + target_position) / 2.0
		var towards_chain_origin = (attached_chain.global_position - target_attachment_pos)
		var offset = Vector3(towards_chain_origin.x, 0, towards_chain_origin.z).normalized() * (GRID_SIZE / 2.0)
		target_attachment_pos += offset
		
		var attachment_pos_tween = get_tree().create_tween().bind_node(self)
		attachment_pos_tween.tween_property(self, "attachment_pos", target_attachment_pos, 0.125)
	
	if upper_box != null:
		upper_box.fall(Vector3(target_position.x, target_position.y + GRID_SIZE_Y, target_position.z), false)

func on_fall_complete():
	state = State.Default

func get_stack_height() -> int:
	if upper_box == null:
		return 1
	else:
		return upper_box.get_stack_height() + 1

func get_all_boxes_in_row(amount: Vector3, player: Player3D, depth: int = PUSH_CHAIN_LIMIT) -> Dictionary:
	if depth == 0:
		return {}
	var dir = amount.normalized()
	var player_dir = player.global_position.direction_to(global_position)
	player_dir.y = 0
	player_dir = player_dir.normalized()
	
	var result = {}
	
	if upper_box != null:
		result.merge(upper_box.get_all_boxes_in_row(amount, player, depth))
	
	
	if (player_dir - dir).length() > .1:
		result[get_instance_id()] = self
		return result
	
	ray_cast_3d.position = Vector3.ZERO
	ray_cast_3d.clear_exceptions()
	var children = get_children()
	for child in children:
		if child is CollisionObject3D:
			ray_cast_3d.add_exception(child)
		children.append_array(child.get_children())
	
	ray_cast_3d.target_position = amount 
	ray_cast_3d.force_raycast_update()

	
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		if collider.get_parent() is Box and !result.has(collider.get_parent().get_instance_id()):
			result.merge(collider.get_parent().get_all_boxes_in_row(amount, player, depth - 1))
	
	result[get_instance_id()] = self
	return result


func can_move_by_amount(amount: Vector3, player_shape_cast: ShapeCast3D, player: Player3D, ignore_player_shape: bool = false, depth: int = PUSH_CHAIN_LIMIT) -> bool:
	if attached_to_chain && !attached_chain.can_reach(global_position + amount):
		return false
	
	var dir = amount.normalized()
	
	# First shoot a ray from origin box in direction in of movement
	# Get the last box in the chain
	# perform this check on that last box instead
	# return true if that box returns true

	ray_cast_3d.position = Vector3.ZERO
	shape_cast.position = Vector3.ZERO
	ray_cast_3d.clear_exceptions()
	shape_cast.clear_exceptions()

	var children = get_children()
	for child in children:
		if child is CollisionObject3D:
			shape_cast.add_exception(child)
			ray_cast_3d.add_exception(child)
		children.append_array(child.get_children())
	
	var player_dir = player.global_position.direction_to(global_position)
	player_dir.y = 0
	player_dir = player_dir.normalized()
	if (player_dir - dir).length() < .1:
		if upper_box != null:
			if !upper_box.can_move_by_amount(amount, player_shape_cast, player, true, depth):
				return false
		
		ray_cast_3d.target_position = amount 
		ray_cast_3d.force_raycast_update()
		if ray_cast_3d.is_colliding():
			var collider = ray_cast_3d.get_collider()
			if depth == 0:
				return false
			if collider.get_parent() is Box:
				var result = collider.get_parent().can_move_by_amount(amount, player_shape_cast, player, true, depth - 1)
				return result
	
	var new_shape = draggable_shape.shape.duplicate()
	if new_shape is BoxShape3D:
		new_shape.size = new_shape.size - Vector3(.02, 0, .02)
	
	shape_cast.shape = new_shape
	shape_cast.target_position = amount
	shape_cast.enabled = true
	shape_cast.force_shapecast_update()
	
	if shape_cast.is_colliding():
		var col = shape_cast.get_collider(0)
		print(shape_cast.get_collider(0))
		return false
	
	if ignore_player_shape:
		return true
	
	player_shape_cast.clear_exceptions()
	for child in children:
		if child is CollisionObject3D:
			player_shape_cast.add_exception(child)
	if upper_box != null:
		var children2 = upper_box.get_children()
		for child in children2:
			if child is CollisionObject3D:
				player_shape_cast.add_exception(child)
			children2.append_array(child.get_children())
			
	player_shape_cast.position = Vector3(0, 0.01, 0)
	player_shape_cast.target_position = amount
	player_shape_cast.force_shapecast_update()
	if player_shape_cast.is_colliding():
		var col = player_shape_cast.get_collider(0)
		print(player_shape_cast.get_collider(0).name)
		return false
	
	var shape = player_shape_cast.shape
	if !(shape is CapsuleShape3D):
		print("Player shape is wrong")
		return false
	
	
	var new_pos = player.global_position + amount
	ray_cast_3d.global_position = new_pos
	ray_cast_3d.target_position = Vector3(0, -(shape.height + 0.01), 0)
	ray_cast_3d.force_raycast_update()
	
	# if the player would have the ground below them, then we can move the box
	return ray_cast_3d.is_colliding() 

class Anchor:
	var node: Node3D
	var player_face_direction: Vector2
	
	func _init(node, player_face_direction):
		self.node = node
		self.player_face_direction = player_face_direction

func get_anchor_for_player(player: Player3D) -> Anchor:
	var ppos = player.global_position
	var closest = anchor_right
	var closest_distance_sq = closest.global_position.distance_squared_to(ppos)
	var anchors = [anchor_behind, anchor_left, anchor_forward]
	for anchor in anchors:
		var dist_sq = anchor.global_position.distance_squared_to(ppos)
		if dist_sq < closest_distance_sq:
			closest_distance_sq = dist_sq
			closest = anchor
	

	if closest == anchor_right:
		return Anchor.new(anchor_right, Vector2.LEFT)
	if closest == anchor_behind:
		return Anchor.new(anchor_behind, Vector2.DOWN)
	if closest == anchor_left:
		return Anchor.new(anchor_left, Vector2.RIGHT)
	else:
		return Anchor.new(anchor_forward, Vector2.UP)


func can_drag() -> bool:
	return true 
