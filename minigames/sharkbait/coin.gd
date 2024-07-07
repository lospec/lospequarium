extends CharacterBody2D

const fall_velocity = Vector2(-40, 50)

@onready var game = get_parent()

func _physics_process(delta):
	velocity = Vector2(fall_velocity.x * game.game_speed_multiplier, fall_velocity.y)
	move_and_slide()
