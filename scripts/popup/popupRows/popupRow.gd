class_name PopupRow extends Resource

@export var dark: bool = false 

func getScene() -> PackedScene:
	return preload("res://scenes/popupRows/popupRow.tscn")
