extends CharacterBody2D
class_name Player

@export var max_speed = 400
@export var accel = 1500
@export var friction = 600

var input = Vector2.ZERO
var direction = Vector2.RIGHT
var in_interactable_area: bool = false
var current_interactable: InteractableItem

func _physics_process(delta):
	player_movement(delta)
	

func get_input():
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return input.normalized()

func player_movement(delta):
	input = get_input()
	
	if input == Vector2.ZERO:
		if velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * accel * delta)
		velocity = velocity.limit_length(max_speed)
	# if the player presses both keys at the same time
	# the character will be looking to the right
	if Input.is_action_pressed("ui_left"):
		direction = Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		direction = Vector2.RIGHT
	if Input.is_action_pressed("ui_up"):
		direction = Vector2.UP
	if Input.is_action_pressed("ui_down"):
		direction = Vector2.DOWN

	if direction == Vector2.RIGHT:
		rotation_degrees = 0
	elif direction == Vector2.LEFT:
		rotation_degrees = 180
	elif direction == Vector2.UP:
		rotation_degrees = -90
	elif  direction == Vector2.DOWN:
		rotation_degrees = 90
	
	move_and_slide()


func _unhandled_input(event):
	if event.is_action_pressed("interact") and in_interactable_area and current_interactable != null:
		current_interactable.interact()

func _on_interactable_check_area_entered(area: Area2D):
	in_interactable_area = true
	var interactable = area.get_parent()
	if current_interactable == null:
		current_interactable = interactable


func _on_interactable_check_area_exited(area):
	var interactable = area.get_parent()
	if interactable == current_interactable:
		current_interactable = null
		in_interactable_area = false
	
