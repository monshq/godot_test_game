extends Control

func _on_quit_pressed():
	get_tree().quit()

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://world.tscn")

func set_win_reason(text):
	var detail_label = get_node("DetailLabel")
	if detail_label:
		detail_label.text = text
