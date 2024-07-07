extends NinePatchRect

@onready var game = get_node("/root/Node2D")

func _ready():
	visible = false

func show_sell():
	var selectedFish = get_node("/root/Node2D/UI/FishInfo").selectedFish
	$FishTexture.texture = selectedFish.get_node("Sprite2D").texture
	$Value.text = "Value: " + str(calculateFishValue(selectedFish))
	visible = true
	get_node("/root/Node2D/UI/Shop").hideShop()

func calculateFishValue(fish):
	if fish.level == 1: return fish.cost
	var base_price = fish.cost
	var level = fish.level
	var increased_value = base_price * pow(1.1, level)
	var rounded_cost = ceil(increased_value)
	return rounded_cost

func hide_sell():
	visible = false

func _on_press_confirm():
	var selectedFish = get_node("/root/Node2D/UI/FishInfo").selectedFish
	get_node("/root/Node2D/UI/FishInfo").hideInfo()
	game.money += calculateFishValue(selectedFish)
	game.remove_fish(selectedFish)
	hide_sell()

func _on_press_keep():
	hide_sell()
