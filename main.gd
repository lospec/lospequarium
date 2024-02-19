extends Node2D

@onready var moneyCounter = get_node("UI/Money")

@export var tankSize = 1

@export var money:int :
	set(new_value):
		money = new_value
		moneyCounter.text = str(money)
	get:
		return money

func _ready():
	money = 50
