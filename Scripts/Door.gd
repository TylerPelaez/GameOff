@tool
extends Node3D
class_name Door

@export var opened_by: OpenedBy = OpenedBy.ButtonPress : set = set_opened_by
@export var _button: InteractableItem
@export var _alter: InteractableItem

@onready var mesh_instance_3d = $MeshInstance3D
@onready var animation_player = $AnimationPlayer

enum OpenedBy {
	ButtonPress,
	KeyOnAlter,
}

@export var mat_y_offset: float = 0.0
@export var mat_y_scale: float = 1.0

var mat: StandardMaterial3D

var opened = false

func set_opened_by(val):
	opened_by = val
	notify_property_list_changed()

# Called when the node enters the scene tree for the first time.
func _ready():
	mat = mesh_instance_3d.get_active_material(0)
	
	if opened_by == OpenedBy.ButtonPress:
		if _button == null:
			push_error("Missing button on door opened by button press!")
			return
		
		_button.interacted.connect(open)
	elif opened_by == OpenedBy.KeyOnAlter:
		if _alter == null:
			push_error("Missing Alter on door opened by alter!")
			return
		
		_alter.unlocked.connect(open)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	mat.uv1_offset.y = mat_y_offset
	mat.uv1_scale.y = mat_y_scale

func open():
	if opened:
		return
	animation_player.play("Open")
	opened = true
