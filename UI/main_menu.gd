extends CanvasLayer


func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/Rooms/FullLevel.tscn")


func _on_credits_pressed():
	get_tree().change_scene_to_file("res://UI/Credits.tscn")


func _on_quit_pressed():
	get_tree().quit()
