extends NinePatchRect

const TWEEN_SPEED = 0.5

@onready var settingsButton = get_node("../SettingsButton")
var openButton = load("res://art/ui/settings.png")
var closeButton = load("res://art/ui/close-left.png")

var open = false
func _ready():
	pass

func toggleSettings():
	if open: hideSettings()
	else: showSettings()

func showSettings():
	open = true
	settingsButton.texture_normal = closeButton
	settingsButton.tooltip_text = "Close Settings"
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x,30), TWEEN_SPEED).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	get_node("/root/Node2D/Sound/MenuOpen").play()
	
func hideSettings():
	open = false
	settingsButton.texture_normal = openButton
	settingsButton.tooltip_text = "Settings"
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x,274), TWEEN_SPEED).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	get_node("/root/Node2D/Sound/MenuClose").play()
