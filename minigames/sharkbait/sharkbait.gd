extends Node2D

var rng = RandomNumberGenerator.new()

var game_speed_multiplier = 1

var game_start = Time.get_ticks_msec()
var last_spawn = Time.get_ticks_msec()
var ms_until_next_spawn = 2000
var next_coin_drop = Time.get_ticks_msec() + 1000

@onready var enemy = load("res://minigames/sharkbait/enemy.tscn")
@onready var coin = load("res://minigames/sharkbait/coin.tscn")
@onready var controller = $MinigameController

func _process(delta):
	if Time.get_ticks_msec() - last_spawn > ms_until_next_spawn:
		spawn_enemy()

	if Time.get_ticks_msec() > next_coin_drop:
		spawn_coin()
	
	var game_age = (Time.get_ticks_msec()-game_start)
	game_speed_multiplier = 1 + 0.05 * (game_age / 1000)
		
func spawn_enemy():
	var instance = enemy.instantiate()
	instance.swim_speed = 80 + randi_range(0,40)
	instance.position.x = 550
	instance.position.y = rng.randi_range(25,250)
	add_child(instance)
	last_spawn = Time.get_ticks_msec()
	ms_until_next_spawn = max(ms_until_next_spawn * .95, 200)

func spawn_coin():
	var instance = coin.instantiate()
	instance.position.x = rng.randi_range(200,550)
	instance.position.y = -30
	add_child(instance)
	
	var max_coin_drop_length = max(1200, 5000 - ((Time.get_ticks_msec()-game_start)/10))
	print(Time.get_ticks_msec()-game_start, " " , max_coin_drop_length)
	
	next_coin_drop = Time.get_ticks_msec() + randi_range(800,max_coin_drop_length)
