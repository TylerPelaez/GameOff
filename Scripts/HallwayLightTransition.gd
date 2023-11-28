extends Node3D

var player_in_darkness: bool = false
var player_in_light: bool = false

func _on_darkness_trigger_body_entered(body):
	player_in_darkness = true


func _on_darkness_trigger_body_exited(body):
	if !player_in_light:
		EventManager.darken.emit()
	player_in_darkness = false

func _on_lightness_trigger_body_entered(body):
	player_in_light = true

func _on_lightness_trigger_body_exited(body):
	if !player_in_darkness:
		EventManager.lighten.emit()
	player_in_light = false
