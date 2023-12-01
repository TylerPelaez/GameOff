extends CanvasLayer




func _on_restart_button_pressed():
	#GameStateService.load_data_from_default_path()
	
	get_tree().change_scene_to_file("res://Scenes/Rooms/Room" + str(SceneTracker.last_scene_loaded + 1) + ".tscn")


func _on_quit_button_pressed():
	get_tree().quit()


func _on_menu_pressed():
		get_tree().change_scene_to_file("res://UI/main_menu.tscn")
