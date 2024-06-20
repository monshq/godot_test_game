extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -300.0
@export var health = 30
@export var acceleration = 3000
@export var wall_jump_knockback_velocity = 450
@export var multiplayer_uid = 1

signal hit

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = get_node("AnimationPlayer")
@onready var hit_player = $HitPlayer
@onready var kill_player = $KillPlayer
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var wall_jump_timer = $WallJumpTimer
@onready var synchronizer = $MultiplayerSynchronizer

var dead = false
var being_hit = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	#print("position is " + str(position))
	#print("name " + name + " is authority " + str(is_multiplayer_authority()))
	if not (dead or being_hit) and is_multiplayer_authority():
		# Handle Jump.
		if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_jump_timer.time_left > 0):
			velocity.y = jump_velocity
			
		if Input.is_action_just_pressed("jump") and (is_on_wall_only() or wall_jump_timer.time_left > 0):
			velocity.y = jump_velocity
			velocity.x = get_wall_normal().x * wall_jump_knockback_velocity
			
		if Input.is_action_just_released("jump"):
			velocity.y = velocity.y * 0.3

		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, acceleration)
		
		if position.y > 1000:
			queue_free()
	
	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	play_animation()
	move_and_slide()
	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		coyote_jump_timer.start()
	if was_on_wall and not is_on_wall():
		wall_jump_timer.start()

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
	on_being_hit(body)

func on_being_hit(body):
	health -= 10
	emit_signal("hit")
	print(name + " hit by " + body.name)
	if health > 0:
		velocity.y -= 150
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

func _enter_tree():
	var uid = name.to_int()
	print("setting multiplayer authority to: " + name)
	set_multiplayer_authority(uid)
	call_deferred("after_spawn")

func after_spawn():
	if multiplayer_uid != 1:
		pass
#		name = str(multiplayer.get_unique_id())
#		print("changed name to " + name)
	if is_multiplayer_authority():
		print("activating camera")
		$Camera2D.make_current()


func _on_multiplayer_synchronizer_synchronized():
	print("synced position to ", position)
