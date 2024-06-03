extends NinePatchRect

const TWEEN_SPEED = 0.5
const SETTINGS_DATA_PATH = "user://settings.json"

@onready var settingsButton = get_node("../SettingsButton")
var openButton = load("res://art/ui/settings.png")
var closeButton = load("res://art/ui/close-left.png")

var open = false
func _ready():
	var settings = get_settings()
	$MusicSlider.value = settings.volume.music
	$EffectsSlider.value = settings.volume.effects
	$MasterSlider.value = settings.volume.master
	update_audio_bus_volumes()

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

func update_audio_bus_volumes():
	var settings = get_settings()
	AudioServer.set_bus_volume_db(0, linear_to_db(settings.volume.master/100.0))
	AudioServer.set_bus_volume_db(1, linear_to_db(settings.volume.music/100.0))
	AudioServer.set_bus_volume_db(2, linear_to_db(settings.volume.effects/100.0))

func _on_music_slider_value_changed(value):
	$MusicPercent.text = str(value) + "%"
	save_settings()
	update_audio_bus_volumes()

func _on_effects_slider_value_changed(value):
	$EffectsPercent.text = str(value) + "%"
	save_settings()
	update_audio_bus_volumes()

func _on_master_slider_value_changed(value):
	$MasterPercent.text = str(value) + "%"
	save_settings()
	update_audio_bus_volumes()
	
func save_settings():
	var file = FileAccess.open(SETTINGS_DATA_PATH, FileAccess.WRITE)
	var data = {
		"_v" = 1,
		"volume" = {
		music = $MusicSlider.value,
		effects = $EffectsSlider.value,
		master = $MasterSlider.value,
		}
	}
	file.store_string(JSON.stringify(data))
	print("saved settings ")
	
func get_settings():
	if FileAccess.file_exists(SETTINGS_DATA_PATH):
		var gameData = FileAccess.open(SETTINGS_DATA_PATH, FileAccess.READ)
		var parsed = JSON.parse_string(gameData.get_as_text())
		print("loaded settings ", SETTINGS_DATA_PATH)
		return parsed
	else:
		var file = FileAccess.open(SETTINGS_DATA_PATH, FileAccess.WRITE)
		var data = {
			"_v" = 1,
			"volume" = {
				music = 100,
				effects = 100,
				master = 100,
			}
		}
		file.store_string(JSON.stringify(data))
		print("initialized settings ",SETTINGS_DATA_PATH)
		return data
