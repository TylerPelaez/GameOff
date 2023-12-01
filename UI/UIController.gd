extends CanvasLayer
class_name UIController

@export var text_display_time_seconds := 1.0

var interaction_prompt_prefab = preload("res://UI/interaction_prompt.tscn")

var camera: Camera3D

@onready var item_inventory = $ItemInventory
@onready var dialog_container = $DialogContainer
@onready var dialog_text_label = $DialogContainer/NinePatchRect/MarginContainer/RichTextLabel

@onready var effects = $Effects

@onready var interaction_prompts = $InteractionPrompts

var item_container_prefab = preload("res://UI/item_container.tscn")

var dialog_active = false
var current_dialog: Array
var current_dialog_index: int = 0
var cur_params: Array

var prompt_prefab = preload("res://UI/interaction_prompt.tscn")
var prompt_instance
var prompt_origin_object


var current_tween
var tweening = false

func _ready():
	EventManager.show_interaction_prompt.connect(_on_show_interaction_prompt)
	EventManager.hide_interaction_prompt.connect(_on_hide_interaction_prompt)
	EventManager.show_hunt_visuals.connect(_on_show_hunt_visuals)
	EventManager.stop_hunt_visuals.connect(_on_hide_hunt_visuals)
	for item_id in PlayerInventory.items.keys():
		add_item(item_id)

func _process(delta):
	if camera == null:
		camera = get_tree().get_first_node_in_group("camera")
	
	if prompt_instance != null && prompt_origin_object != null && camera != null:
		var pos = camera.unproject_position(prompt_origin_object.global_position + Vector3(0, .1, 0))
		prompt_instance.position = pos
		prompt_instance.position.x -= (prompt_instance.size.x / 4)
		prompt_instance.position.y -= 32


func add_item(item_id: ItemData.ItemId):
	var instance = item_container_prefab.instantiate()
	item_inventory.add_child(instance)
	instance.set_item(item_id)


func remove_item(item_id: ItemData.ItemId):
	for child in item_inventory.get_children():
		if child.item_id == item_id:
			child.queue_free()
			return


func _input(event):
	if dialog_active && event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		advance_dialog()


func play_dialog(id: DialogData.DialogId, params: Array[String]):
	
	var file_path = DialogData.data[id]
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text = file.get_as_text()
		
	var json_data = JSON.parse_string(text)
	if json_data == null:
		printerr("Invalid JSON!")
	
	cur_params = params

	current_dialog = json_data
	current_dialog_index = 0
	
	dialog_container.visible = true
	dialog_active = true
	# TODO: animate text display
	set_dialog_text()


func finish_dialog():
	dialog_container.visible = false
	dialog_active = false
	DialogManager.finish_dialog()

func advance_dialog():
	current_dialog_index += 1
	if current_dialog_index == current_dialog.size():
		finish_dialog()
	else:
		set_dialog_text()

func set_dialog_text():
	if current_tween != null:
		current_tween.kill()
	
	var data = current_dialog[current_dialog_index]
	var text: String = data["text"]
	if text.contains("%s"):
		text = text % [cur_params[current_dialog_index]]
	
	dialog_text_label.text = text
	dialog_text_label.visible_ratio = 0
	
	current_tween = get_tree().create_tween().bind_node(self)
	current_tween.tween_property(dialog_text_label, "visible_ratio", 1, text_display_time_seconds)
	current_tween.tween_callback(func(): tweening = false)
	tweening = true

func _on_show_interaction_prompt(prompt_src):
	if prompt_instance != null:
		prompt_instance.queue_free()
	prompt_instance = prompt_prefab.instantiate()
	interaction_prompts.add_child(prompt_instance)
	prompt_origin_object = prompt_src

func _on_hide_interaction_prompt():
	if prompt_instance != null:
		prompt_instance.queue_free()
	prompt_origin_object = null

func _on_show_hunt_visuals():
	effects.visible = true

func _on_hide_hunt_visuals():
	effects.visible = false
