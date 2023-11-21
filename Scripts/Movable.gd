extends Area2D
class_name Movable

static var GRID_SIZE = 16

@export var droppable = true

@onready var anchor_left = $AnchorLeft
@onready var anchor_right = $AnchorRight
@onready var anchor_up = $AnchorUp
@onready var anchor_down = $AnchorDown

@onready var shape_cast_2d = $ShapeCast2D
@onready var collision_shape_2d = $CollisionShape2D

enum State {
	Default,
	Moving
}


var state = State.Default

func start_moving():
	state = State.Moving

func stop_moving():
	state = State.Default

func move_to(position: Vector2):
	if state == State.Moving:
		get_parent().global_position = position

func can_move_by_amount(amount: Vector2, player_shape_cast: ShapeCast2D) -> bool:
	shape_cast_2d.clear_exceptions()
	player_shape_cast.clear_exceptions()
	var children = get_parent().get_children()
	for child in children:
		if child is CollisionObject2D:
			shape_cast_2d.add_exception(child)
			player_shape_cast.add_exception(child)
		children.append_array(child.get_children())
			
	var new_shape =  collision_shape_2d.shape.duplicate()
	if new_shape is RectangleShape2D:
		new_shape.size = new_shape.size - Vector2(2, 2)
	
	shape_cast_2d.shape = new_shape
	shape_cast_2d.target_position = amount
	shape_cast_2d.enabled = true
	shape_cast_2d.force_shapecast_update()
	if shape_cast_2d.is_colliding():
		return false
	
	player_shape_cast.target_position = amount
	player_shape_cast.force_shapecast_update()
	return !player_shape_cast.is_colliding()

class Anchor:
	var node: Node2D
	var player_face_direction: Vector2
	
	func _init(node, player_face_direction):
		self.node = node
		self.player_face_direction = player_face_direction

func get_anchor_for_player(player: Player) -> Anchor:
	var ppos = player.global_position

	if ppos.x >= anchor_right.global_position.x:
		return Anchor.new(anchor_right, Vector2.LEFT)
	if ppos.y <= anchor_up.global_position.y:
		return Anchor.new(anchor_up, Vector2.DOWN)
	if ppos.x <= anchor_left.global_position.x:
		return Anchor.new(anchor_left, Vector2.RIGHT)
	else:
		return Anchor.new(anchor_down, Vector2.UP)
