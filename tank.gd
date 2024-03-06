extends Node2D

var food = load("res://food.tscn")
@onready var foodContainer = get_node("../Food")
@onready var game = get_node("/root/Node2D")
		
func _unhandled_input(event):

	
	if (event is InputEventMouseButton && !event.pressed && event.button_index==1):
		var physicsSpace = get_world_2d().direct_space_state
		var query_parameters = PhysicsPointQueryParameters2D.new()
		query_parameters.collide_with_areas = true
		query_parameters.position = event.position
		var intersections = physicsSpace.intersect_point(query_parameters)
		for i in intersections:
			if (i.collider.name == "Fish"): return
			if (i.collider.name == "CoinClick"): return

		var instance = food.instantiate()
		instance.position.x = event.position.x
		instance.position.y = event.position.y
		foodContainer.add_child(instance)
		game.money = game.money - 1
		if game.money < 1: game.money = 1
		print("fed")

func findCoinClick(c):
	print("namey",c.collider.name)
	if c.collider.name == "CoinClick": return true
	else: return false
