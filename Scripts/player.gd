extends CharacterBody2D
class_name Player

@export var max_speed = 400
@export var accel = 1500
@export var friction = 600

var input = Vector2.ZERO

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
	
