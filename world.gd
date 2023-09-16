extends Node2D

var win = false
var last_cam_position = null

func _on_player_tree_exiting():
	var cam_position = get_node("Player/Camera2D").get_screen_center_position()
	if win:
		var win_cam = get_node("WinCamera")
		# print(last_cam_position)
		win_cam.position = cam_position
		win_cam.enabled = true
		get_node("WinCamera/WinScene").visible = true
	else:
		var death_cam = get_node("DeathCamera")
		death_cam.enabled = true
		death_cam.position = cam_position
		get_node("DeathCamera/DeathScene").visible = true

func _on_enemies_child_exiting_tree(_node):
	var enemies_count = get_node("Enemies").get_child_count()
	# print("remaining enemies:", enemies_count)
	if enemies_count <= 1:
		win = true
		var player = get_node("Player")
		if player:
			player.queue_free()
		
