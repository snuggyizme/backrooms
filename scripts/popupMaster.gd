## Controls and creates popups (e.g. item tooltips, block functionalities)
class_name PopupMaster extends Control

signal popupButtonPressed(popup, buttonTag: StringName)

const POPUP_SCENE: PackedScene = preload("res://scenes/popup.tscn")

var active: Array[Popup]

func create(def: PopupDefinition, pos: Vector2) -> void:
	var popup: PanelContainer = POPUP_SCENE.instantiate()
	var rowAddPoint: VBoxContainer = popup.get_child(0)
	
	for row: PopupRow in def.rows:
