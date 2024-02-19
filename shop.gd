extends NinePatchRect

@onready var game = get_node("/root/Node2D")
@onready var shop = get_node("/root/Node2D/UI/Shop")
@onready var shopButton = get_node("../ShopButton")
@onready var buyCurrentItemButton = get_node("BuyCurrentItemButton")
@onready var currentItemLabel = get_node("CurrentItemName")
@onready var buyTankUpgradeButton = get_node("UpgradeTankButton")
@onready var tankLevelLabel = get_node("UpgradeTankLevel")
@onready var refreshCounter = get_node("RefreshCountdown")
@onready var fishContainer = get_node("/root/Node2D/Fish")

var openButton = load("res://art/ui/shop.png")
var closeButton = load("res://art/ui/close.png")

const shopRevealTime = 0.4

const secondsBetweenEachRefresh = 30
var lastRefresh = Time.get_ticks_msec()

@export var isOpen = false

var shopItems = [
	load("res://fish/black-bass.tscn"),
	load("res://fish/carp.tscn"),
	load("res://fish/horse-mackerel.tscn")
];

var currentItem
var rng = RandomNumberGenerator.new()

func revealShop():
	isOpen = true
	shopButton.texture_normal = closeButton
	shopButton.tooltip_text = "Close Shop"
	updateShop()
	var tween = create_tween()
	tween.set_ease(1)
	tween.tween_property(shop, "position", Vector2(400,position.y), shopRevealTime)
	print("revealed shop")

func updateShop():
	# Current Item
	currentItemLabel.text = currentItem.properName
	buyCurrentItemButton.tooltip_text = "Buy " + currentItem.properName + " for $" + str(currentItem.cost)
	
	get_node("CurrentItemTexture").texture = currentItem.texture
	
	buyCurrentItemButton.text = "$" + str(currentItem.cost)
	if (currentItem.cost > game.money || roomInTank() == false): buyCurrentItemButton.disabled = true
	else: buyCurrentItemButton.disabled = false
	
	#Max Fish
	tankLevelLabel.text = "Max Fish: " + str(game.tankSize+1)
	var tankSizeCost = pow(2, game.tankSize+5)
	buyTankUpgradeButton.tooltip_text = "Upgrade max fish in tank to " + str(game.tankSize+1) + " for $" + str(tankSizeCost)
	buyTankUpgradeButton.text = "$" + str(tankSizeCost)
	if (tankSizeCost > game.money): buyTankUpgradeButton.disabled = true
	else: buyTankUpgradeButton.disabled = false

func hideShop():
	isOpen = false
	shopButton.texture_normal = openButton
	shopButton.tooltip_text = "Open Shop"
	var tween = create_tween()
	tween.set_ease(1)
	tween.tween_property(shop, "position", Vector2(480,position.y), shopRevealTime)	
	print("hid shop")

func _ready():
	refreshShop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	refreshCounter.text = str(secondsBetweenEachRefresh - ceil((Time.get_ticks_msec() - lastRefresh) / 1000))
	if (Time.get_ticks_msec() - lastRefresh > secondsBetweenEachRefresh*1000):
		refreshShop()
	

func refreshShop():
	print("refresh shop")
	lastRefresh = Time.get_ticks_msec() 
	
	var newItemIndex = rng.randi_range(0,shopItems.size()-1)
	print("newItemIndex",newItemIndex,shopItems[newItemIndex])
	var newItem = shopItems[newItemIndex]
	var instantiatedItem = newItem.instantiate()
	
	currentItem = {}
	currentItem.scene = newItem
	currentItem.cost = instantiatedItem.cost
	currentItem.properName = instantiatedItem.properName
	currentItem.texture = instantiatedItem.find_child("Sprite2D").texture
	instantiatedItem.queue_free()
	
	print("new item", currentItem)
	updateShop()
	

func _on_shop_button_pressed():
	if isOpen: hideShop()
	else: revealShop()

func _on_upgrade_tank_button_pressed():
	var tankSizeCost = pow(2, game.tankSize)
	if (tankSizeCost <= game.money):
		game.tankSize = game.tankSize + 1
		game.money = game.money - tankSizeCost
	updateShop()
	

func _on_buy_current_item_button_pressed():
	if (currentItem.cost <= game.money && roomInTank()): 
		game.money = game.money - currentItem.cost
		var newFish = currentItem.scene.instantiate()
		newFish.position.x = rng.randi_range(20, 380)
		newFish.position.y = 10
		fishContainer.add_child(newFish)
		newFish.apply_impulse(Vector2(0,100), Vector2(0.5,0.5))
	updateShop()

func roomInTank(): 
	print("tanksize: ",game.tankSize," | current fish: ",fishContainer.get_child_count(), " | room in tank: ",str(game.tankSize > fishContainer.get_child_count()))
	return (game.tankSize > fishContainer.get_child_count()) 
	
