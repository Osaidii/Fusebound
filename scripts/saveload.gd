extends Node

const save_location := "res://SaveFile.json"

# This function saves the user settings.
func save_settings(dict: Dictionary) -> void:
	var file = FileAccess.open(save_location, FileAccess.WRITE)
	file.store_var(dict.duplicate())
	file.close()

# This function returns the user settings.
func get_settings() -> Dictionary:
	if FileAccess.file_exists(save_location):
		var file = FileAccess.open(save_location, FileAccess.READ)
		var data = file.get_var()
		var save_data = data.duplicate()
		return save_data
	else:
		return {}
