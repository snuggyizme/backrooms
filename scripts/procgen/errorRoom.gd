class_name ErrorRoom extends Room

var text: String

@onready var label: Label = $"Label"

func setError(vec: Vector4i) -> void:
	text = (
		"COULD NOT PLACE TILE FOR GIVEN CONNECTIONS:" +
		str(vec.x) + ":" + str(vec.y) + ":" +
		str(vec.z) + ":" + str(vec.w)
	)

func _process(_Δ: float) -> void:
	label.text = text
