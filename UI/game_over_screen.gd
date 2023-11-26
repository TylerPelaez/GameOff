extends CanvasLayer



func _on_restart_button_pressed():
	get.tree().reload_current_scene()


func _on_quit_button_pressed():
	get.tree().quit()

