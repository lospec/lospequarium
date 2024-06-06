extends NinePatchRect

@onready var main = get_node("/root/Node2D")
@onready var panel = get_node("/root/Node2D/UI/FishInfo")

@export var panelRevealTime = 0.4
@export var isOpen = false
@export var selectedFish : Node2D

func _process(delta):
	if (selectedFish):
		updateHunger()
	if (main.DEBUG_MODE):
		updateDebugText()

func revealInfo():
	isOpen = true
	updateInfo()
	var tween = create_tween()
	tween.tween_property(panel, "position", Vector2(-18,position.y), panelRevealTime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	get_node("/root/Node2D/Sound/MenuOpen").playing = true
	print("revealed fish info")
	
func hideInfo():
	isOpen = false
	var tween = create_tween()
	tween.tween_property(panel, "position", Vector2(-98,position.y), panelRevealTime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	get_node("/root/Node2D/UI/FishInfo/DebugText").text = ""
	get_node("/root/Node2D/Sound/MenuClose").playing = true
	print("hid fish info")

func updateInfo():
	get_node("/root/Node2D/UI/FishInfo/FishTexture").texture = selectedFish.get_node("Sprite2D").texture
	
	get_node("/root/Node2D/UI/FishInfo/FishSpecies").text = selectedFish.properName
	if (selectedFish.petName && selectedFish.petName.length() > 0):
		get_node("/root/Node2D/UI/FishInfo/FishName").text = selectedFish.petName
	else:
		get_node("/root/Node2D/UI/FishInfo/FishName").text = ""
	
	if (main.DEBUG_MODE): updateDebugText()
	
	updateHunger()
	updateXP()	
	updateAge()
	
func updateHunger():
	var hungerPercent = float(selectedFish.hunger) / float(selectedFish.hungerThreshold)
	get_node("/root/Node2D/UI/FishInfo/HungerBar").value = hungerPercent
	get_node("/root/Node2D/UI/FishInfo/HungerBar").tooltip_text = str(floor(hungerPercent*100)) + "% hungry"

func updateXP():
	var xpNeededForNextLevelUp =calculateXpNeededForLevelUp(selectedFish.level)
	
	print("xp",xpNeededForNextLevelUp,selectedFish.xp,selectedFish.xp / xpNeededForNextLevelUp)
	var percentToNextLevel = float(selectedFish.xp) / float(xpNeededForNextLevelUp)
	get_node("/root/Node2D/UI/FishInfo/XPBar").value = percentToNextLevel
	get_node("/root/Node2D/UI/FishInfo/XPBar").tooltip_text = str(floor((percentToNextLevel)*100)) + "% of the way to level " + str(selectedFish.level+1) 
	get_node("/root/Node2D/UI/FishInfo/XPCurrent").text = str(selectedFish.xp)
	get_node("/root/Node2D/UI/FishInfo/XPNeeded").text = "/ "+ str(xpNeededForNextLevelUp)
	get_node("/root/Node2D/UI/FishInfo/FishLevel").text = "lv. " + str(selectedFish.level)

func calculateXpNeededForLevelUp (level): 
	return 9 + level

func updateAge():
	var secondsAlive = Time.get_unix_time_from_system() - selectedFish.birth
	var age:String 
	
	if (secondsAlive < 60): age = str(floor(secondsAlive)) + " seconds"
	elif (secondsAlive < 60*60): age = str(floor(secondsAlive/60)) + " minutes"
	elif (secondsAlive < 60*60*24): age = str(floor(secondsAlive/60/60)) + " hours"
	elif (secondsAlive < 60*60*24*7): age = str(floor(secondsAlive/60/60/24/25)) + " days"
	elif (secondsAlive < 60*60*24*30): age = str(floor(secondsAlive/60/60/24/7)) + " weeks"
	elif (secondsAlive < 60*60*24*365): age = str(floor(secondsAlive/60/60/24/30)) + " months"
	else: age = str(floor(secondsAlive/60/24/365)) + " years"
	
	get_node("/root/Node2D/UI/FishInfo/Age").text = "age: " + str(age)

func _on_texture_button_pressed():
	hideInfo()

var states = ['idle','swim','food']
func updateDebugText():
	var fish = selectedFish
	if (!fish): return
	var xpNeededForNextLevelUp = calculateXpNeededForLevelUp(fish.level)
	var fishInfo = ""
	fishInfo += "state: " + str(fish.state) + "("+states[fish.state]+")" + "\n"
	fishInfo += "type: " + fish.type + "\n"
	fishInfo += "proper name: " + fish.properName + "\n"
	fishInfo += "hunger: " + str(fish.hunger) + "\n"
	fishInfo += "petName: " + fish.petName + "\n"
	fishInfo += "cost: " + str(fish.cost) + "\n"
	fishInfo += "maxSpeed: " + str(fish.maxSpeed) + "\n"
	fishInfo += "id: " + str(fish.id) + "\n"
	fishInfo += "level: " + str(fish.level) + "\n"
	fishInfo += "xp: " + str(fish.xp) + "\n"
	fishInfo += "xpNeededForNextLevelUp: " + str(xpNeededForNextLevelUp) + "\n"
	fishInfo += "xpBarValue: " + str(float(fish.xp) / float(xpNeededForNextLevelUp)) + "\n"
	fishInfo += "birth: " + str(fish.birth) + "\n"
	fishInfo += "boredomThreshold: " + str(fish.boredomThreshold) + "\n"
	fishInfo += "tired: " + str(fish.tired) + "\n"
	fishInfo += "tiredThreshold: " + str(fish.tiredThreshold) + "\n"
	fishInfo += "hunger: " + str(fish.hunger) + "\n"
	fishInfo += "hungerThreshold: " + str(fish.hungerThreshold) + "\n"
	fishInfo += "direction: " + str(fish.direction) + "\n"
	fishInfo += "lastMoneyDrop: " + str(fish.lastMoneyDrop) + "\n"
	fishInfo += "moneyDropCoolDown: " + str(fish.moneyDropCoolDown) + "\n"
	
	get_node("/root/Node2D/UI/FishInfo/DebugText").text = fishInfo

func _on_rename_area_mouse_entered():
	$RenameButton.visible = true

func _on_rename_area_mouse_exited():
	$RenameButton.visible = false

func _on_rename_button_pressed():
	$FishName.grab_focus()
	$FishName.caret_column = $FishName.text.length()

func _on_fish_name_text_submitted(new_text):
	$FishName.release_focus()


func _on_rename_area_input_event(viewport, event, shape_idx):
	pass
	var physicsSpace = get_world_2d().direct_space_state
	var query_parameters = PhysicsPointQueryParameters2D.new()
	query_parameters.collide_with_areas = true
	query_parameters.position = event.position
	var intersections = physicsSpace.intersect_point(query_parameters)
	for i in intersections:
		if i.collider == self or i.collider == $FishName or i.collider == $RenameButton: 
			$RenameButton.visible = true
			print("showy")
