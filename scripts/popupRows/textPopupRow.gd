class_name TextPopupRow extends PopupRow

@export var colour: Color
@export var text: String

func getScene() -> PackedScene:
	return preload("res://scenes/popupRows/textPopupRow.tscn")
