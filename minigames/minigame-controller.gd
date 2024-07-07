extends Node2D

const savefileLocation = "user://fishgamesave.json"
const highscoreDataFileLocation = "user://highsores.json"

var score = 0
var gameName:String

func _ready():
	if (get_parent() != get_tree().root.get_child(0)): push_error("MinigameController must be added to the minigame scene's root!")
	gameName = get_parent().name
	$EndScreen.visible = false
	$EndScreen/NewHighScore.visible = false
	$Sound/Music.play()
	visible = true
	print("started minigame ", gameName)

func increase_score(amount):
	score += amount
	$Score.text = str(score)
	$Sound/Collect.play()

func end_game():
	$EndScreen/Money.text = str(score)
	$EndScreen.visible = true
	$Sound/Music.stop()
	
	var parsedGameData = getSavedData(savefileLocation)
	var highScoreData = getHighscoreData()
	var current_high_score = int(highScoreData[gameName])
	
	if score > current_high_score:
		var bonus_money = score - current_high_score
		$EndScreen/NewHighScore/Money.text = str(bonus_money)
		$EndScreen/NewHighScore.visible = true
		highScoreData[gameName] = score
		parsedGameData.money += score + bonus_money
		saveData(highscoreDataFileLocation, highScoreData)
	else:
		parsedGameData.money += score
	
	$EndScreen/HighScore.text = "High Score: " + str(highScoreData[gameName])
	saveData(savefileLocation, parsedGameData)
	
func getHighscoreData():
	# make sure the high score data file exists
	if not FileAccess.file_exists(highscoreDataFileLocation):
		var file = FileAccess.open(highscoreDataFileLocation, FileAccess.WRITE)
		file.store_string("{}")
		print("created ",highscoreDataFileLocation)
	
	var parsedScoreData = getSavedData(highscoreDataFileLocation)
	
	# make sure the current game is listed in the file
	if not parsedScoreData.has(gameName): 
		parsedScoreData[gameName] = 0
		print("added ",gameName, " to high scores file")
		
	return parsedScoreData


func saveData(saveFile, data):
	var file = FileAccess.open(saveFile, FileAccess.WRITE)
	var dataText = JSON.stringify(data)
	file.store_string(dataText)	
	print("saved ",saveFile)

	
func getSavedData(saveFile):
	var file = FileAccess.open(saveFile, FileAccess.READ)
	var text = file.get_as_text()
	return JSON.parse_string(text)

func _on_back_to_tank_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
