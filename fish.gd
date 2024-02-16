extends RigidBody2D

var maxSpeed = 100
var speed = maxSpeed

enum {IDLE, SWIM, FOOD}
var state = IDLE

var boredom = 0
var boredomThreshold = 800
var tired = 0
var tiredThreshold = 2000
var hunger = 5000
var hungerThreshold = 5000
var direction = Vector2.ZERO

var velocity = Vector2.ZERO
var rng = RandomNumberGenerator.new()

@onready var sprite = get_node("Sprite2D")
@onready var mouth = get_node("Mouth")
@onready var mouthCol = mouth.find_child("CollisionShape2D")

@onready var FoodGroup = get_node("../../Food")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var lastFlip = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if (state == IDLE):	idle()
	if (state == SWIM):	swim()
	if (state == FOOD):	food()

	hunger = hunger + 1
	
	if (lastFlip + 500 < Time.get_ticks_msec() && abs(direction.x) > 0.25):
		print("flip", direction.x)
		lastFlip = Time.get_ticks_msec()
		if (direction.x > 0):
			sprite.scale.x = -1
			mouth.scale.x = -1
		else:
			sprite.scale.x = 1
			mouth.scale.x = 1
	

func idle(): 
	boredom = boredom + rng.randi_range(0,5)
	if (boredom > boredomThreshold):
		state = SWIM
		boredom = 0
	pass

func swim():
	
	if (hunger>hungerThreshold/2 && FoodGroup.get_children().size() > 0): 
		state = FOOD
		return food()
	
	if (tired == 0): 
		direction = Vector2(rng.randi_range(-1,1), rng.randi_range(-1,1))
		if (hunger > hungerThreshold/2): speed = maxSpeed / 5
		else: speed = maxSpeed
	
	apply_impulse(Vector2(direction.x/100*speed,direction.y/500*speed), Vector2(0.5,0.5))
	
	tired = tired + rng.randi_range(0,5)
	if (tired > tiredThreshold):
		state = IDLE
		tired = 0
		if (hunger > hungerThreshold/2): tired = tiredThreshold/2
	pass
	
func food():
	var current_foods = FoodGroup.get_children()
	if current_foods.size() == 0: 
		state = SWIM
		return swim()
	var closest_distance = 9999
	var closest_food = -1

	for f in current_foods:
		var distance = f.get_global_position().distance_to(get_global_position())
		if distance < closest_distance:
			closest_distance = distance
			closest_food = f

	direction = mouthCol.get_global_position().direction_to(closest_food.get_global_position())	
	apply_impulse(Vector2(direction.x/2,direction.y/3), Vector2(0.5,0.5))

var fishSprites = ['black-bass','carp','gargle','horse-mackerel','loach','pond-smelt','rainbow-trout','red-snapper','sockeye-salmon','yellow-tang']

func _input(event):
	if (event.is_action_released("ChangeFish")):
		var randomFishSprite = rng.randi_range(0,fishSprites.size()-1)
		sprite.texture = load("res://art/fish/"+fishSprites[randomFishSprite]+".png")

func _on_fish_mouth_body_shape_entered(body_rid, collidedObject, body_shape_index, local_shape_index):
	if collidedObject.name == "Food":
		print("got good")
		hunger = hunger - collidedObject.value
		if (hunger < 0): hunger = 0
		print("healed fish hunger",collidedObject.value, "now", hunger)
		collidedObject.queue_free()
