extends CharacterBody2D

# Interaction variables
var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true
var attacking = false
var current_attack = 1  # Tracks which attack animation to play (1 or 2)
var is_hurt = false  # Tracks if the player is currently playing the hurt animation

# Movement variables
@export var speed: float = 100  # Speed of the player in pixels per second
var current_dir = "right"
@onready var anim = $AnimatedSprite2D

func _ready() -> void:
	# Set the default animation to idle when the player is initialized
	anim.play("idle")

func _physics_process(delta: float) -> void:
	# Reset velocity each frame
	velocity = Vector2.ZERO

	enemy_attack()
	attack()

	if health <= 0:
		player_alive = false
		anim.play("death")
		health = 0
		print("Player has died")
		self.queue_free()

	# Get input from the player (only if not attacking or hurt)
	if not attacking and not is_hurt:
		if Input.is_action_pressed("ui_right"):
			current_dir = "right"
			play_anim(1)
			velocity.x += 1
		if Input.is_action_pressed("ui_left"):
			current_dir = "left"
			play_anim(1)
			velocity.x -= 1
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
			play_anim(1)
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1
			play_anim(1)
		if velocity.x == 0 && velocity.y == 0:
			play_anim(0)

	# Normalize the velocity to prevent faster diagonal movement
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	# Move the player and handle collisions
	move_and_slide()

func play_anim(movement):
	var dir = current_dir

	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("walk")
		elif movement == 0:
			if not attacking and not is_hurt:
				anim.play("idle")
	elif dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("walk")
		elif movement == 0:
			if not attacking and not is_hurt:
				anim.play("idle")
	elif dir == "down":
		anim.flip_h = false
		if movement == 1:
			anim.play("walk")
		elif movement == 0:
			if not attacking and not is_hurt:
				anim.play("idle")
	elif dir == "up":
		anim.flip_h = false
		if movement == 1:
			anim.play("walk")
		elif movement == 0:
			if not attacking and not is_hurt:
				anim.play("idle")

func player():
	pass

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown and not is_hurt:
		is_hurt = true
		anim.play("hurt")
		health -= 10
		enemy_attack_cooldown = false
		$attackCooldown.start()
		print("Player has been hit! -10 HP")
		print(health)

		# Wait for the hurt animation to finish
		await anim.animation_finished
		is_hurt = false

func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true

func attack():
	if Input.is_action_just_pressed("attack") and not attacking and not is_hurt:
		attacking = true
		GlobalVariableName.player_current_attack = true

		# Alternate between attack1 and attack2
		if current_attack == 1:
			anim.play("attack1")
			current_attack = 2
		else:
			anim.play("attack2")
			current_attack = 1

		# Flip the sprite based on direction
		if current_dir == "right":
			anim.flip_h = false
		elif current_dir == "left":
			anim.flip_h = true

		# Start the attacking timer
		$attackingTimer.start()

func _on_attacking_timer_timeout() -> void:
	# Reset attack state after the animation finishes
	$attackingTimer.stop()
	GlobalVariableName.player_current_attack = false
	attacking = false
	anim.play("idle")  # Return to idle after attacking
