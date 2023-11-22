extends MeshInstance3D
class_name Box

static var GRID_SIZE = .5

@export var droppable = true

@onready var shape_cast = $ShapeCast3D
@onready var collision_shape = $DraggableArea/CollisionShape3D

@onready var anchor_right = $AnchorRight
@onready var anchor_left = $AnchorLeft
@onready var anchor_forward = $AnchorForward
@onready var anchor_behind = $AnchorBehind



enum State {
	Default,
	Moving
}


var state = State.Default

func start_moving():
	state = State.Moving

func stop_moving():
	state = State.Default

func move_to(position: Vector3):
	if state == State.Moving:
		global_position = position

func can_move_by_amount(amount: Vector3, player_shape_cast: ShapeCast3D) -> bool:
	shape_cast.clear_exceptions()
	player_shape_cast.clear_exceptions()
	var children = get_children()
	for child in children:
		if child is CollisionObject3D:
			shape_cast.add_exception(child)
			player_shape_cast.add_exception(child)
		children.append_array(child.get_children())
			
	var new_shape = collision_shape.shape.duplicate()
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
	return !player_shape_cast.is_colliding()

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
		return Anchor.new(anchor_left, Vector3.RIGHT)
	else:
		return Anchor.new(anchor_forward, Vector2.UP)
