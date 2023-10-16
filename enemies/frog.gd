extends CharacterBody2D

var SPEED = 50
var direction = 1
var chase_target = null
var dead = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = get_node("AnimatedSprite2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if not dead:
		if chase_target:
			direction = (chase_target.position - position).normalized().x
			velocity.x = direction * SPEED
			
		if velocity.x != 0:
			anim.play("Jump")
			if velocity.x > 0:
				get_node("AnimatedSprite2D").flip_h = true
			elif velocity.x < 0:
				get_node("AnimatedSprite2D").flip_h = false
		else:
			anim.play("Idle")
		
		move_and_slide()

func _on_area_2d_body_entered(body):
	print(name + " hit by " + body.name)
	if body.name == 'Player':
		on_hit(body)

func on_hit(body):
	if not dead:
		body.on_kill()
		dead = true
		get_node("CollisionShape2D").queue_free()
		anim.play("Death")
		await anim.animation_finished
		queue_free()

func _on_player_detection_area_body_entered(body):
	chase_target = body
		

func _on_player_chase_area_body_exited(_body):
	chase_target = null
	velocity.x = 0
