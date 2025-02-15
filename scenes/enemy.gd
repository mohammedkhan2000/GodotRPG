extends CharacterBody2D

# Enemy variables
@export var speed: float = 50  # Speed of the enemy in pixels per second
var health = 100
var player_inattack_zone = false
var canTakeDmg = true

var target: Node2D = null  # The player to chase
var is_chasing: bool = false  # Whether the enemy is currently chasing the player

# Reference to the detection area
@onready var detection_area: Area2D = $detectionArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Set the default animation to idle when the enemy is initialised
	animated_sprite.play("slimeIdle")

func _physics_process(delta: float) -> void:
	
	takingDamage()
	
	if is_chasing and target:
		# Calculate the direction to the player
		var direction = (target.global_position - global_position).normalized()
		
		# Move towards the player
		velocity = direction * speed
		move_and_slide()
		
		# Play the run animation if not already playing
		if animated_sprite.animation != "slimeRun":
			animated_sprite.play("slimeRun")
		
		# Flip[ the sprite based on movement direction
		if direction.x > 0:
			animated_sprite.flip_h = false # Face right
		elif direction.x < 0:
			animated_sprite.flip_h = true # Face left
	else:
		# Stop moving if not chasing
		velocity = Vector2.ZERO
		
		# Play the idle animation if not already playing
		if animated_sprite.animation != "slimeIdle":
			animated_sprite.play("slimeIdle")

func _on_detection_area_body_entered(body: Node2D) -> void:
	# Check if the detected body is the player
	if body.name == "player":
		target = body
		is_chasing = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	# Stop chasing if the player leaves the detection area
	if body == target:
		target = null
		is_chasing = false
		
func enemy():
	pass

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = true

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false
		
func takingDamage():
	if player_inattack_zone and GlobalVariableName.player_current_attack == true:
		if canTakeDmg == true:
			health -= 20
			$dmgCooldown.start()
			canTakeDmg = false
			print("slime health = ", health)
			if health <= 0:
				self.queue_free()

func _on_dmg_cooldown_timeout() -> void:
	canTakeDmg = true
