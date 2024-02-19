extends RigidBody2D

@export var value = 10
@onready var game = get_node("/root/Node2D")
@onready var shop = get_node("/root/Node2D/UI/Shop")

func _process(delta):
	if (self.position.y > 270):
		queue_free()
		
func _input(event):
	pass

func _on_area_2d_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && !event.pressed && event.button_index==1):
		game.money = game.money + value
		queue_free()
		get_viewport().set_input_as_handled()
		shop.updateShop()
		print("clicked coin")
		
