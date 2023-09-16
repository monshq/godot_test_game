extends CharacterBody2D

var SPEED = 50
var direction = 1
var chase = false
var dead = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if not dead:
		velocity.x = SPEED * direction
		
		if velocity.x != 0:
			anim.play("Run")
			if velocity.x > 0:
				get_node("AnimatedSprite2D").flip_h = true
			elif velocity.x < 0:
				get_node("AnimatedSprite2D").flip_h = false
		else:
			anim.play("Idle")
		
		move_and_slide()


func _on_timer_timeout():
	if not chase:
		direction = -direction

func _on_area_2d_body_entered(body):
	if body.name == "Player" and not dead:
		dead = true
		get_node("CollisionShape2D").queue_free()
		anim.play("Death")

func _on_player_detection_area_body_entered(body):
	if body.name == "Player":
		chase = true
		direction = (body.position - position).normalized().x

func _on_player_chase_area_body_exited(body):
	if body.name == "Player":
		chase = false
		direction = -direction

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Death":
		queue_free()
