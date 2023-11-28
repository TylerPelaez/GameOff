extends OmniLight3D

@onready var animation_tree = $AnimationTree

var current_tween: Tween

func _ready():
	animation_tree.active = true
	EventManager.darken.connect(on_darken)
	EventManager.lighten.connect(on_lighten)

func on_darken():
	if current_tween != null:
		current_tween.stop()
	current_tween = get_tree().create_tween().bind_node(self)
	current_tween.tween_property(animation_tree, "parameters/blend_position", 0, 1.0)

func on_lighten():
	if current_tween != null:
		current_tween.stop()
	
	current_tween = get_tree().create_tween().bind_node(self)
	
	current_tween.tween_property(animation_tree, "parameters/blend_position", 1.0, 1.0)
