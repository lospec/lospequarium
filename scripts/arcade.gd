extends NinePatchRect

@onready var arcadeButton = get_node("../ArcadeButton")
var openButton = load("res://art/ui/arcade.png")
var closeButton = load("res://art/ui/close-left.png")

const OPEN_POSITION = 30
const CLOSED_POSITION = -210
const TWEEN_SPEED = 0.5

var open = false


func toggleArcade():
	if open: hideArcade()
	else: showArcade()

func showArcade():
	open = true
	arcadeButton.texture_normal = closeButton
	arcadeButton.tooltip_text = "Close Arcade"
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x,OPEN_POSITION), TWEEN_SPEED).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	get_node("/root/Node2D/Sound/MenuOpen").play()
	
func hideArcade():
	open = false
	arcadeButton.texture_normal = openButton
	arcadeButton.tooltip_text = "Settings"
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x,CLOSED_POSITION), TWEEN_SPEED).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	get_node("/root/Node2D/Sound/MenuClose").play()

