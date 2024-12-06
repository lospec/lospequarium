extends RigidBody2D

## Actual name of the type of fish, with proper capitalization.
@export var properName = "REPLACEME"
## How much the fish costs to purchase from the shop (should roughly be tied to rarity).
@export var cost:int = 50
## The speed the fish swims, at it's fastest.
@export var maxSpeed:int = 100
## Higher numbers have a higher chance of being skipped when picking next shop item. It also determines the fish tank size tier the player must have in order to see it. [0=starter; 1=50%; 5=80% chance to skip/spent$1000 and 10 means they spent $16000 on tank upgrades and there's a 90% chance it will be skipped
@export var rarity:int = 1;

var type = "invalid-fish-type" 
var petName = ""
var id:int = -1
var level:int = 1
var xp:int = 0
var birth:float = Time.get_unix_time_from_system()

const hungerSpeed = 60

var speed = maxSpeed

enum {IDLE, SWIM, FOOD}
var state = IDLE

var boredom = 0
var boredomThreshold = 800
var tired = 0
var tiredThreshold = 2000
var hungerThreshold = 5000
var hunger = hungerThreshold / 2
var direction = Vector2.ZERO

var lastMoneyDrop = 0
var moneyDropCoolDown = 1000 * 30

var velocity = Vector2.ZERO
var rng = RandomNumberGenerator.new()

@onready var game = get_node("/root/Node2D")
@onready var sprite = get_node("Sprite2D")
@onready var mouth = get_node("Mouth")
@onready var mouthPoint = get_node("Mouth/MouthPoint")
@onready var mouthCol = mouth.find_child("CollisionShape2D")

@onready var FoodGroup = get_node("../../Food")
@onready var FishInfoPanel = get_node("/root/Node2D/UI/FishInfo")

var coin = load("res://coin.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if (rng.randi_range(0, 2) == 0):
		sprite.scale.x = -1
		mouth.scale.x = -1

var lastFlip = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	{
		IDLE: idle,
		SWIM: swim,
		FOOD: food
	}[state].call()
	
	hunger = hunger + delta * hungerSpeed
	if (hunger > hungerThreshold): hunger = hungerThreshold
	
	if (lastFlip + 500 < Time.get_ticks_msec() && abs(direction.x) > 0.25):
		lastFlip = Time.get_ticks_msec()
		if (direction.x > 0):
			sprite.scale.x = -1
			mouth.scale.x = -1
		else:
			sprite.scale.x = 1
			mouth.scale.x = 1

func is_hungry():
	return hunger > hungerThreshold / 2

func idle(): 
	boredom = boredom + rng.randi_range(0,5)
	if (boredom > boredomThreshold):
		state = SWIM
		boredom = 0
		updateOutline()

func swim():
	if (is_hungry() && FoodGroup.get_children().size() > 0): 
		state = FOOD
		return food()
	
	if (tired == 0): 
		direction = Vector2(rng.randi_range(-1,1), rng.randi_range(-1,1))
		if (is_hungry()): speed = maxSpeed / 5
		else: speed = maxSpeed
	
	apply_impulse(Vector2(direction.x/100*speed,direction.y/500*speed), Vector2(0.5,0.5))
	
	tired = tired + rng.randi_range(0,5)
	if (tired > tiredThreshold):
		state = IDLE
		tired = 0
		if (is_hungry()): tired = tiredThreshold/2
	
	moneyDrop()


func moneyDrop():
	if (hunger < (hungerThreshold * 0.25) && lastMoneyDrop + moneyDropCoolDown < Time.get_ticks_msec() && rng.randi_range(0,100) == 0):
		lastMoneyDrop = Time.get_ticks_msec()
		var instance = coin.instantiate()
		instance.position.x = get_global_position().x
		instance.position.y = get_global_position().y
		get_node("/root/Node2D").add_child(instance)
		print("money drop")

func food():
	var current_foods = FoodGroup.get_children()
	if current_foods.size() == 0 || !is_hungry():
		state = SWIM
		return swim()
	var closest_distance = 9999
	var closest_food = -1

	for f in current_foods:
		var distance = f.get_global_position().distance_to(get_global_position())
		if distance < closest_distance:
			closest_distance = distance
			closest_food = f

	direction = mouthPoint.get_global_position().direction_to(closest_food.get_global_position())	
	apply_impulse(Vector2(direction.x/2,direction.y/3), Vector2(0.5,0.5))


func _on_fish_mouth_body_shape_entered(body_rid, collidedObject, body_shape_index, local_shape_index):
	
	print("mouth collide from ",properName," with ",collidedObject.name,"(", collidedObject.get_parent().name,")"," /state:",state)
	
	if (state == FOOD && collidedObject.is_in_group("food")):
		hunger = hunger - collidedObject.value
		if (hunger < 0): hunger = 0
		xp = xp + 1
		collidedObject.queue_free()
		get_node("/root/Node2D/Sound/Eat").playing = true
		updateOutline()
		
		if (xp >= FishInfoPanel.calculateXpNeededForLevelUp(level)):
			xp = xp - FishInfoPanel.calculateXpNeededForLevelUp(level)
			level = level + 1
			get_node("/root/Node2D/Sound/LevelUp").playing = true

			var levelUpParticle = load("res://particles/level-up-particle.tscn").instantiate()
			levelUpParticle.position.x = 0
			levelUpParticle.position.y = -10
			self.add_child(levelUpParticle)
			levelUpParticle.emitting = true
			levelUpOutline()
			
		print("fish ate food")
		
		if (self == FishInfoPanel.selectedFish):
			FishInfoPanel.updateXP()

func _on_mouse_entered():
	(sprite.material as ShaderMaterial).set("shader_param/enabled", true)
	(sprite.material as ShaderMaterial).set("shader_param/line_color", Vector4(1,1,1,1))
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	print('hover fish')

func _on_mouse_exited():
	(sprite.material as ShaderMaterial).set("shader_param/enabled", false)
	updateOutline()
	
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	print('unhover fish')

func _on_input_event(viewport, event, shape_idx):
	if !(event is InputEventMouseButton) || event.pressed || event.button_index != 1:
		return
	var physicsSpace = get_world_2d().direct_space_state
	var query_parameters = PhysicsPointQueryParameters2D.new()
	query_parameters.collide_with_areas = true
	query_parameters.position = event.position
	var intersections = physicsSpace.intersect_point(query_parameters)
	for i in intersections:
		if i.collider.name in ["CoinClick"]: return
	FishInfoPanel.selectedFish = self
	FishInfoPanel.revealInfo()
	print("clicked fish")

func _on_body_entered(collidedObject):
	if (collidedObject.name == "Fish"):
		get_node("/root/Node2D/Sound/Bloop").playing = true
		print("bloop")

func updateOutline():
	if (hunger>hungerThreshold*0.75):
		(sprite.material as ShaderMaterial).set("shader_param/line_color", Vector4(1, 0.863,0.416,1))
		(sprite.material as ShaderMaterial).set("shader_param/enabled", true)
	else:
		(sprite.material as ShaderMaterial).set("shader_param/enabled", false)

func levelUpOutline():
	var timeout = 0.15
	for i in range(8):
		if i % 2 == 0:
			outlineOn()
		else:
			outlineOff()
		await get_tree().create_timer(timeout).timeout
	await get_tree().create_timer(1.0 - timeout).timeout
	updateOutline()
	
func outlineOn():
	(sprite.material as ShaderMaterial).set("shader_param/line_color", Color(0.553, 0.757, 0.337))
	(sprite.material as ShaderMaterial).set("shader_param/enabled", true)

func outlineOff():
	(sprite.material as ShaderMaterial).set("shader_param/enabled", false)
