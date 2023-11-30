extends CanvasLayer
class_name UIController

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


var prompt_prefab = preload("res://UI/interaction_prompt.tscn")
var prompt_instance
var prompt_origin_object


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
	var text = DialogData.data[id]
	if params.size() > 0 and text.size() == 1:
		text =  [text[0] % params]
	
	current_dialog = text
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
	dialog_text_label.text = current_dialog[current_dialog_index]


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
