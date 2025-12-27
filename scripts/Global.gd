extends Node

const SAVE_PATH = "user://savegame.json"

var save_data = {
	"cleared_levels": []
}

func _ready():
	load_game()

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)
		file.store_string(json_string)
		print("Game Saved: ", save_data)
	else:
		print("Failed to ensure save file at: ", SAVE_PATH)

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found.")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			if typeof(data) == TYPE_DICTIONARY:
				save_data = data
				print("Game Loaded: ", save_data)
			else:
				print("Save data corrupted (not a dictionary).")
		else:
			print("JSON Parse Error: ", json.get_error_message())

func unlock_level(level_id: int):
	# 重複登録を防ぐ
	if not level_id in save_data["cleared_levels"]:
		save_data["cleared_levels"].append(level_id)
		save_game()
		print("Level Unlocked: ", level_id)
	else:
		print("Level already unlocked: ", level_id)

func is_level_cleared(level_id: int) -> bool:
	return level_id in save_data["cleared_levels"]
