extends Node2D

var win = false
var last_cam_position = null

@onready var player = $Player
@onready var hp_label = $UILayer/PanelContainer/MarginContainer/GridContainer/HBoxContainer/HealthValue
@onready var bg_player = $BgMusicPlayer
@onready var victory_player = $VictoryPlayer
@onready var cherries = $Cherries
@onready var cherry_label = $UILayer/PanelContainer/MarginContainer/GridContainer/HBoxContainer2/CherryLabel
@onready var win_scene = $UILayer/WinScene

func _on_player_tree_exiting():
	var cam_position = get_node("Player/Camera2D").get_screen_center_position()
	var after_camera = get_node("AfterCamera")
	after_camera.position = cam_position
	after_camera.enabled = true
	if win:
		get_node("UILayer/WinScene").visible = true
		bg_player.stop()
		victory_player.play()
	else:
		get_node("UILayer/DeathScene").visible = true

func _on_enemies_child_exiting_tree(_node):
	var enemies_count = get_node("Enemies").get_child_count()
	# print("remaining enemies:", enemies_count)
	if enemies_count <= 1:
		win = true
		win_scene.set_win_reason("Genocide ending")
		
		if is_instance_valid(player):
			player.queue_free()

func _on_player_hit():
	hp_label.text = str(player.health)
	if player.health <= 10:
		hp_label.add_theme_color_override("font_color", Color.FIREBRICK)

func _on_cherry_collected():
	var cherries_count = 5 - cherries.get_child_count() + 1
	cherry_label.text = str(cherries_count)
	if cherries_count == 5:
		win = true
		win_scene.set_win_reason("Pacifist ending")
		player.queue_free()
