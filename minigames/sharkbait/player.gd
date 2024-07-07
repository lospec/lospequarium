extends CharacterBody2D

const MAX_SPEED = 200
const FULL_SPEED_DISTANCE = 100
var target = Vector2.ZERO

@onready var game = get_parent()
@onready var controller = game.get_node("MinigameController")

func _physics_process(delta):
	target = get_global_mouse_position()
	var distance_to_mouse = global_position.distance_to(target)
	
	var new_speed = MAX_SPEED
	
	if distance_to_mouse < 10:
		new_speed = 0
	if distance_to_mouse < FULL_SPEED_DISTANCE:
		new_speed = MAX_SPEED * distance_to_mouse / FULL_SPEED_DISTANCE
		
	var new_direction =  global_position.direction_to(target)
	var new_velocity = new_direction * new_speed
	velocity = lerp(velocity, new_velocity, 0.1)

	move_and_slide()


func _on_area_2d_area_entered(area):
	if (area.is_in_group("coin")):
		controller.increase_score(1)
		area.get_parent().queue_free()
	if (area.is_in_group("enemy")):
		controller.end_game()
		queue_free()
