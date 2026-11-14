class_name ButtonPopupRow extends PopupRow

@export var buttonText: String

func getScene() -> PackedScene:
	return preload("res://scenes/popupRows/buttonPopupRow.tscn")
