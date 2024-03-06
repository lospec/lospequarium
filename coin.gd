extends RigidBody2D

@export var value = 10
@onready var game = get_node("/root/Node2D")
@onready var shop = get_node("/root/Node2D/UI/Shop")
@onready var sprite = get_node("Sprite2D")

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
		

func _on_coin_click_mouse_entered():
	#TODO: something is wrong with the outline shader on animations
	#(sprite.material as ShaderMaterial).set("shader_param/enabled", true)
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	print('hover coin')


func _on_coin_click_mouse_exited():
	#(sprite.material as ShaderMaterial).set("shader_param/enabled", false)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	print('unhover coin')
