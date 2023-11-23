extends MeshInstance3D
class_name Box

const FALL_DISTANCE_MARGIN = 0.01

static var GRID_SIZE = .5


@export var droppable = true

@onready var shape_cast = $ShapeCast3D
@onready var draggable_shape = $DraggableArea/CollisionShape3D

@onready var collision_shape_3d = $StaticBody3D/CollisionShape3D


@onready var anchor_right = $AnchorRight
@onready var anchor_left = $AnchorLeft
@onready var anchor_forward = $AnchorForward
@onready var anchor_behind = $AnchorBehind

@onready var ray_cast_3d = $RayCast3D


enum State {
	Default,
	Moving,
	Falling,
}


var state = State.Default

func start_moving():
	state = State.Moving

func stop_moving():
	if state != State.Falling:
		state = State.Default

func move_to(position: Vector3):
	if state == State.Moving:
		global_position = position

func on_drag_complete() -> bool:
	return try_fall()

func try_fall() -> bool:
	ray_cast_3d.position = Vector3.ZERO
	ray_cast_3d.target_position = Vector3(0, -20, 0)
	ray_cast_3d.force_raycast_update()
	if ray_cast_3d.is_colliding():
		var collision_position = ray_cast_3d.get_collision_point()
		
		var min_y = 999999
		if collision_shape_3d.shape is ConcavePolygonShape3D:
			var faces: PackedVector3Array = collision_shape_3d.shape.get_faces()

			for face in faces:
				if face.y < min_y:
					min_y = face.y
		
		if (global_position.y + min_y) - collision_position.y > FALL_DISTANCE_MARGIN:
			fall(Vector3(global_position.x, collision_position.y - min_y, global_position.z))
			return true
	else:
		push_error("Box cannot find ground, will now float")
	return false

func fall(target_position: Vector3):
	var tween = get_tree().create_tween().bind_node(self)
	var collision_position = ray_cast_3d.get_collision_point()
	
	state = State.Falling
	tween.tween_property(self, "global_position", target_position, 0.25)
	tween.tween_callback(on_fall_complete)

func on_fall_complete():
	state = State.Default

func can_move_by_amount(amount: Vector3, player_shape_cast: ShapeCast3D, player: Player3D) -> bool:
	shape_cast.clear_exceptions()
	player_shape_cast.clear_exceptions()
	var children = get_children()
	for child in children:
		if child is CollisionObject3D:
			shape_cast.add_exception(child)
			player_shape_cast.add_exception(child)
		children.append_array(child.get_children())
			
	var new_shape = draggable_shape.shape.duplicate()
	if new_shape is BoxShape3D:
		new_shape.size = new_shape.size - Vector3(.02, 0, .02)
	
	shape_cast.shape = new_shape
	shape_cast.target_position = amount
	shape_cast.enabled = true
	shape_cast.force_shapecast_update()
	if shape_cast.is_colliding():
		return false
	
	player_shape_cast.target_position = amount
	player_shape_cast.force_shapecast_update()
	if player_shape_cast.is_colliding():
		return false
	
	var new_pos = player.global_position + amount
	ray_cast_3d.global_position = new_pos
	ray_cast_3d.target_position = Vector3(0, -0.11, 0) # height of the player currently
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

	if ppos.x >= anchor_right.global_position.x:
		return Anchor.new(anchor_right, Vector2.LEFT)
	if ppos.z <= anchor_behind.global_position.z:
		return Anchor.new(anchor_behind, Vector2.DOWN)
	if ppos.x <= anchor_left.global_position.x:
		return Anchor.new(anchor_left, Vector2.RIGHT)
	else:
		return Anchor.new(anchor_forward, Vector2.UP)