@tool
extends Button

## The name of the game displayed on the button
@export var pretty_title:String
## The id of the game, aka the name of it's folder and root element, which is used to lookup scores
@export var game_id:String

const highscoreDataFileLocation = "user://highsores.json"

func _ready():
	update_view()
	
	if not Engine.is_editor_hint():
		tooltip_text = "Play "+pretty_title+"!"
		if FileAccess.file_exists(highscoreDataFileLocation):
			var parsedScoreData = getSavedData(highscoreDataFileLocation)
			$HighScore.text = "High Score: "+ str(parsedScoreData[game_id])
		else:
			$HighScore.text = "High Score: 0"


func _process(delta):
	if Engine.is_editor_hint(): update_view()

func getSavedData(saveFile):
	var file = FileAccess.open(saveFile, FileAccess.READ)
	var text = file.get_as_text()
	return JSON.parse_string(text)

func update_view():
	if pretty_title: $Title.text = pretty_title
	else: $Title.text = "!MISSING TITLE"
	
	if game_id and ResourceLoader.exists("res://minigames/"+game_id+"/icon.png"):
		$GameIcon.texture = load("res://minigames/"+game_id+"/icon.png")
	else:
		$GameIcon.texture = load("res://art/ui/arcade-button-missing-game.png")


func _on_pressed():
	get_tree().change_scene_to_file("res://minigames/"+game_id+"/game.tscn")
