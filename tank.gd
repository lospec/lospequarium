extends Node2D

var food = load("res://food.tscn")
@onready var foodContainer = get_node("../Food")
@onready var game = get_node("/root/Node2D")

func _unhandled_input(event):
	var size = get_viewport().get_visible_rect().size
	if !(event is InputEventMouseButton) || event.pressed || event.button_index != 1:
		return
	var physicsSpace = get_world_2d().direct_space_state
	var query_parameters = PhysicsPointQueryParameters2D.new()
	query_parameters.collide_with_areas = true
	query_parameters.position = event.position
	var intersections = physicsSpace.intersect_point(query_parameters)
	for i in intersections:
		if i.collider.name in ["Fish", "CoinClick"]: return

	var x = event.position.x
	var y = event.position.y

	if (x < 0) || (y < 0) || (x >= size.x) || (y >= size.y):
		return

	var instance = food.instantiate()
	instance.position.x = x
	instance.position.y = y
	foodContainer.add_child(instance)
	game.money = game.money - 1
	if game.money < 1: game.money = 1
	print("fed")

func findCoinClick(c):
	print("namey",c.collider.name)
	return c.collider.name == "CoinClick"
