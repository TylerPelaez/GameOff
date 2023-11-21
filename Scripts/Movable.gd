extends Area2D
class_name Movable

static var GRID_SIZE = 32

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

func _physics_process(delta):
	if state == State.Moving:
		get_parent().global_position = global_position

func start_moving():
	state = State.Moving

func stop_moving():
	state = State.Default

func can_move_by_amount(amount: Vector2, player_shape_cast: ShapeCast2D) -> bool:
	shape_cast_2d.clear_exceptions()
	player_shape_cast.clear_exceptions()
	var children = get_parent().get_children()
	for child in children:
		if child is CollisionObject2D:
			shape_cast_2d.add_exception(child)
			player_shape_cast.add_exception(child)
		children.append_array(child.get_children())
			

	shape_cast_2d.shape = collision_shape_2d.shape
	shape_cast_2d.target_position = amount
	shape_cast_2d.enabled = true
	shape_cast_2d.force_shapecast_update()
	if shape_cast_2d.is_colliding():
		return false
	
	player_shape_cast.target_position = amount
	player_shape_cast.force_shapecast_update()
	return !player_shape_cast.is_colliding()

func get_anchor_for_player(player: Player) -> Node2D:
	var ppos = player.global_position

	if ppos.x >= anchor_right.global_position.x:
		return anchor_right
	if ppos.y <= anchor_up.global_position.y:
		return anchor_up
	if ppos.x <= anchor_left.global_position.x:
		return anchor_left
	else:
		return anchor_down
