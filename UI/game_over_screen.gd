extends CanvasLayer



func _on_restart_button_pressed():
	GameStateService.load_data_from_default_path()


func _on_quit_button_pressed():
	get_tree().quit()

