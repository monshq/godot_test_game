extends Node2D

var win = false
var last_cam_position = null

@onready var player = null
@onready var hp_label = $UILayer/PanelContainer/MarginContainer/GridContainer/HBoxContainer/HealthValue
@onready var bg_player = $BgMusicPlayer
@onready var victory_player = $VictoryPlayer
@onready var cherries = $Cherries
@onready var cherry_label = $UILayer/PanelContainer/MarginContainer/GridContainer/HBoxContainer2/CherryLabel
@onready var win_scene = $UILayer/WinScene

func _ready():
	var err = peer.create_server(PORT)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		_add_player()
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.connected_to_server.connect(_add_self)

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
	print("cherry collected, remaining=" + str(cherries_count))
	if cherries_count == 5:
		win = true
		win_scene.set_win_reason("Pacifist ending")
		player.queue_free()


var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
const PORT = 8001
const SERVER = "localhost"

func _add_player(id = 1):
	var new_player = player_scene.instantiate()
	new_player.name = str(id)
	print("spawning new player: id=" + str(id))
	$Players.call_deferred("add_child", new_player)
	call_deferred("_update_player_position", new_player)
	
func _add_self():
	var new_player = player_scene.instantiate()
	var id = str(peer.get_unique_id())
	new_player.name = id
	print("spawning new player (self): id=" + id)
	$Players.call_deferred("add_child", new_player)
	call_deferred("_update_player_position", new_player)

func _on_button_pressed():
	peer.create_client(SERVER, PORT)
	#peer.compress
	multiplayer.multiplayer_peer = peer

func _update_player_position(new_player):
	new_player.position = Vector2(0, 400)
