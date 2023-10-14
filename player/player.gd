extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -300.0
@export var health = 30
@export var acceleration = 1200

signal hit

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = get_node("AnimationPlayer")
@onready var hit_player = $HitPlayer
@onready var kill_player = $KillPlayer

var dead = false
var being_hit = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if not dead:
		if !being_hit:
			# Handle Jump.
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = jump_velocity
				
			if Input.is_action_just_pressed("jump") and is_on_wall():
				velocity.y = jump_velocity
				velocity.x = get_wall_normal().x * 300

			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			var direction = Input.get_axis("move_left", "move_right")
			if direction:
				velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, acceleration)
			
		if position.y > 1000:
			queue_free()
				
	play_animation()
	move_and_slide()

func play_animation():
	if dead:
		anim.play("Death")
	elif being_hit:
		anim.play("Fall")
	elif velocity.y != 0:
		if velocity.y > 0:
			anim.play("Fall")
		else:
			anim.play("Jump")
		if velocity.x > 0:
			get_node("AnimatedSprite2D").flip_h = false
		elif velocity.x < 0:
			get_node("AnimatedSprite2D").flip_h = true
	elif velocity.x != 0:
		anim.play("Run")
		if velocity.x > 0:
			get_node("AnimatedSprite2D").flip_h = false
		elif velocity.x < 0:
			get_node("AnimatedSprite2D").flip_h = true
	else:
		anim.play("Idle")

func _on_hitbox_area_body_entered(body):
	if body.name != "Player" && body.name != "TileMap":
		on_being_hit(body)

func on_being_hit(body):
	health -= 10
	emit_signal("hit")
	if health > 0:
		print("hit by" + body.name)
		velocity.y -= 150
		print(velocity)
		var direction = (body.position - position).normalized().x
		velocity.x = direction * -150
		being_hit = true
		hit_player.play()
		get_tree().create_timer(0.33).timeout.connect(_on_being_hit_end)
	else:
		dead = true
		anim.play("Death")

func _on_being_hit_end():
	being_hit = false
	
func on_kill():
	velocity.y -= 250
	kill_player.play()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Death":
		queue_free()
