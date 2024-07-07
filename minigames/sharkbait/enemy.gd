extends CharacterBody2D

var swim_speed = 100

@onready var game = get_parent()

func _physics_process(delta):
	velocity = Vector2(-swim_speed,0) * game.game_speed_multiplier
	move_and_slide()
