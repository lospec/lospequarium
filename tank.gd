extends Node2D

var food = load("res://food.tscn")
@onready var foodContainer = get_node("../Food")

		
func _input(event):
	if (event is InputEventMouseButton && !event.pressed && event.button_index==1):
		var instance = food.instantiate()
		instance.position.x = event.position.x
		instance.position.y = event.position.y
		foodContainer.add_child(instance)
