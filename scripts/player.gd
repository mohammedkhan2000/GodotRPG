extends CharacterBody2D

# Movement variables
@export var speed: float = 100  # Speed of the player in pixels per second
var current_dir = "none"

func _physics_process(delta: float) -> void:
	# Reset velocity each frame
	velocity = Vector2.ZERO

	# Get input from the player
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
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("walk")
		elif movement == 0:
			anim.play("idle")
	elif dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("walk")
		elif movement == 0:
			anim.play("idle")
	elif dir == "down":
		anim.flip_h = false
		if movement == 1:
			anim.play("walk")
		elif movement == 0:
			anim.play("idle")
	elif dir == "up":
		anim.flip_h = false
		if movement == 1:
			anim.play("walk")
		elif movement == 0:
			anim.play("idle")
