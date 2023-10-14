extends AnimatableBody2D

signal collected

@onready var player = $CollectedPlayer
var done = false

func _on_area_2d_body_entered(_body):
	if !done:
		done = true
		visible = false
		player.play()
		emit_signal("collected")
		await player.finished
		queue_free()
