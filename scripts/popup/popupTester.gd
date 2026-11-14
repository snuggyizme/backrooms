class_name PopupTester extends Node2D

const DEFINITION: PopupDefinition = preload("res://resources/popups/test.tres")

var tag: StringName
var subTags: Array[StringName]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		event = event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_RIGHT:
			createPopup()

func createPopup() -> void:
	print("{PopupTester}: Create test popup")
	var pos: Vector2 = get_global_mouse_position()
	
	tag = &"test-%d" % randi()
	subTags = [
		&"test-label-%d" % randi(),
		&"discard-%d" % randi(), # Empty space, dont need it
		&"test-button-%d" % randi(),
	]
	
	var isValid: bool = Refs.isValid(Refs.popupMaster)
	print("{PopupTester}: PopupMaster apparent validity: ", isValid)
	
	if isValid:
		Refs.popupMaster.create(
			DEFINITION, pos, tag, subTags
		)
