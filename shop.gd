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

var shopItems = Array(DirAccess.get_files_at("res://fish/")).map(createFishDB)

func createFishDB(f):
	print('processing fish ',f.replace('.remap', ''))
	var path = "res://fish/"+f.replace('.remap', '')
	var scene = load(path)
	var instance = scene.instantiate()
	var newFishData = {
		"cost": instance.cost,
		"properName": instance.properName,
		"texture": instance.find_child("Sprite2D").texture,
		"rarity": instance.rarity,
		"path": path,
	}
	instance.queue_free()
	return newFishData


var currentItem
var rng = RandomNumberGenerator.new()

func revealShop():
	isOpen = true
	shopButton.texture_normal = closeButton
	shopButton.tooltip_text = "Close Shop"
	updateShop()
	var tween = create_tween()
	tween.tween_property(shop, "position", Vector2(400,position.y), shopRevealTime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	get_node("/root/Node2D/Sound/MenuOpen").playing = true
	print("revealed shop")

func updateShop():
	currentItemLabel.text = currentItem.properName
	get_node("CurrentItemTexture").texture = currentItem.texture
	
	buyCurrentItemButton.text = "$" + str(currentItem.cost)
	if (roomInTank() == false): 
		buyCurrentItemButton.disabled = true
		buyCurrentItemButton.tooltip_text = "Tank is full! Upgrade to fit more fish!"
	elif (currentItem.cost > game.money):
		buyCurrentItemButton.disabled = true
		buyCurrentItemButton.tooltip_text = "You can't afford this!"
	else: 
		buyCurrentItemButton.disabled = false
		buyCurrentItemButton.tooltip_text = "Buy " + currentItem.properName + " for $" + str(currentItem.cost)
	
	#Max Fish
	tankLevelLabel.text = "Max Fish: " + str(game.tankSize+1)
	var tankSizeCost = pow(2, game.tankSize+5)
	
	buyTankUpgradeButton.text = "$" + str(tankSizeCost)
	if (tankSizeCost > game.money): 
		buyTankUpgradeButton.tooltip_text = "You can't afford this!"
		buyTankUpgradeButton.disabled = true
	else: 
		buyTankUpgradeButton.tooltip_text = "Upgrade max fish in tank to " + str(game.tankSize+1) + " for $" + str(tankSizeCost)
		buyTankUpgradeButton.disabled = false
	
	print("foom in tank: ",roomInTank())
	print("updated shop")

func hideShop():
	isOpen = false
	shopButton.texture_normal = openButton
	shopButton.tooltip_text = "Open Shop"
	var tween = create_tween()
	tween.tween_property(shop, "position", Vector2(480,position.y), shopRevealTime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	get_node("/root/Node2D/Sound/MenuClose").playing = true
	print("hid shop")

func _ready():
	print("Fish Database:")
	for r in range(16):
		var fishOfThisRarity = shopItems.filter(func(f): return f.rarity==r)
		var count = fishOfThisRarity.size()
		var total = fishOfThisRarity.reduce(func(acc,f): return acc + f.cost,0)
		var avg = 0
		if count > 0: avg = round(float(total) / float(count))
		var list = fishOfThisRarity.reduce(func(acc,f): return acc + f.properName+" ($"+str(f.cost)+")"+ ", ","")
		print("R",r," | ",count,"x | $",avg," = ", list )
	refreshShop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	refreshCounter.text = str(secondsBetweenEachRefresh - ceil((Time.get_ticks_msec() - lastRefresh) / 1000))
	if (Time.get_ticks_msec() - lastRefresh > secondsBetweenEachRefresh*1000):
		refreshShop()
	

func refreshShop():
	print("refresh shop")
	lastRefresh = Time.get_ticks_msec() 
	
	var skipTankSizeCheck = (game.tankSize == 0) # refreshShop gets called right away before the game data has loaded, and it thinks tank size is 0, which means no fish get matched, so we have to trick it into skipping the tank size check otherwise it will get an infinite loop because no fish have a rarity of 0, or if we exit and dont pick a current fish, then when the user clicks the shop button, the game will crash (sorry)
	
	var newItem
	while (!newItem):
		var possibleNewItem = shopItems[rng.randi_range(0,shopItems.size()-1)]
		var diceRoll = rng.randi_range(1, possibleNewItem.rarity)
		print("possiblenewitem", possibleNewItem.rarity <= game.tankSize , possibleNewItem, game.tankSize, "/", game.money)
		if (skipTankSizeCheck && possibleNewItem.rarity == 1):
			newItem = possibleNewItem
		elif (diceRoll == 1 && possibleNewItem.rarity <= game.tankSize):
			newItem = possibleNewItem

	print("picked a new item:",newItem)
	currentItem = newItem

	updateShop()

func _on_shop_button_pressed():
	if isOpen: hideShop()
	else: revealShop()

func _on_upgrade_tank_button_pressed():
	var tankSizeCost = pow(2, game.tankSize+5)
	if (tankSizeCost <= game.money):
		game.tankSize = game.tankSize + 1
		game.money = game.money - tankSizeCost
		get_node("/root/Node2D/Sound/BoughtItem").playing = true
	updateShop()
	

func _on_buy_current_item_button_pressed():
	if (currentItem.cost <= game.money && roomInTank()): 
		game.money = game.money - currentItem.cost
		var fishScene = load(currentItem.path)
		var newFish = fishScene.instantiate()
		newFish.position.x = rng.randi_range(20, 380)
		newFish.position.y = 10
		print("namne",newFish.scene_file_path)
		newFish.type = "Adsfgasdf"
		fishContainer.add_child(newFish)
		newFish.apply_impulse(Vector2(0,100), Vector2(0.5,0.5))
		game.addFish(newFish)
		get_node("/root/Node2D/Sound/BoughtItem").playing = true
	updateShop()

func roomInTank(): 
	print("tanksize: ",game.tankSize," | current fish: ",fishContainer.get_child_count(), " | room in tank: ",str(game.tankSize > fishContainer.get_child_count()))
	return (game.tankSize > fishContainer.get_child_count()) 
	
func _on_buy_current_item_button_gui_input(event):
	checkIfClickedShopButtonIsDisable(event, buyCurrentItemButton)

func _on_upgrade_tank_button_gui_input(event):
	checkIfClickedShopButtonIsDisable(event, buyTankUpgradeButton)

func checkIfClickedShopButtonIsDisable (event, button):
	if (event is InputEventMouseButton && event.pressed && event.button_index==1):
		if (button.disabled):
			get_node("/root/Node2D/Sound/CantBuy").playing = true
