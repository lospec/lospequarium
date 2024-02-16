extends RigidBody2D

@export var speed = 100

enum {IDLE, SWIM, FOOD}
var state = IDLE

var boredom = 0
var tired = 0
var hunger = 5000
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
	if (boredom > 800):
		state = SWIM
		boredom = 0
	pass

func swim():
	
	if (hunger>5000 && FoodGroup.get_children().size() > 0): 
		state = FOOD
		return food()
	
	if (tired == 0): direction = Vector2(rng.randi_range(-1,1), rng.randi_range(-1,1))
	
	apply_impulse(Vector2(direction.x/2,direction.y/5), Vector2(0.5,0.5))
	
	tired = tired + rng.randi_range(0,5)
	if (tired > 2000):
		state = IDLE
		tired = 0
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


#func _on_body_entered(body):
#	if body.name == "Food":
#		print("entered body")
#		hunger = 0
#		body.queue_free()

var fishSprites = ['black-bass','carp','gargle','horse-mackerel','loach','pond-smelt','rainbow-trout','red-snapper','sockeye-salmon','yellow-tang']

func _input(event):
	if (event.is_action_released("ChangeFish")):
		var randomFishSprite = rng.randi_range(0,fishSprites.size()-1)
		sprite.texture = load("res://art/fish/"+fishSprites[randomFishSprite]+".png")

func _on_fish_mouth_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.name == "Food":
		print("got good")
		#hunger = 0
		body.queue_free()
