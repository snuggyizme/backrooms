class_name Hotbar extends Control

const UNSELECTED: StyleBoxTexture = preload("res://resources/hotbarDeselected.tres")
const SELECTED: StyleBoxTexture = preload("res://resources/hotbarSelected.tres")

@export_group("Private")
@export var offsetTransformTrans: Tween.TransitionType
@export var offsetTransformEase: Tween.EaseType
@export var offsetTransformOffset: float
@export var offsetTransformTimeA: float
@export var offsetTransformTimeB: float
@export var offsetTransformDoA: bool = true
@export var offsetTransformDoB: bool = true

@onready var containers: Array[PanelContainer] = [
	$"CC/HotbarContainer1",
	$"CC/HotbarContainer2",
	$"CC/HotbarContainer3",
	$"CC/HotbarContainer4",
	$"CC/HotbarContainer5",
	$"CC/HotbarContainer6",
	$"CC/HotbarContainer7",
	$"CC/HotbarContainer8",
	$"CC/HotbarContainer9",
	$"CC/HotbarContainer10",
]
@onready var hotbarIndex: int = 0:
	set(x):
		hotbarIndex = x
		for i: int in range(containers.size()):
			containers[i].add_theme_stylebox_override(
				"panel", SELECTED if ( i == x ) else UNSELECTED
			)
		
		var container: PanelContainer = containers[x]
		
		var tween := create_tween()
		tween.set_trans(offsetTransformTrans)
		tween.set_ease(offsetTransformEase)
		
		tween.tween_property(
			container,
			"offset_transform_position:y",
			offsetTransformOffset,
			offsetTransformTimeA if ( offsetTransformDoA ) else 0.0
		)
		
		tween.tween_property(
			container,
			"offset_transform_position:y",
			0.0,
			offsetTransformTimeB if ( offsetTransformDoB ) else 0.0
		)

func _unhandled_key_input(event: InputEvent) -> void:
	if ( event.pressed ) and !( event.echo ) and ( event is InputEventKey ):
		var detectedIndex: int = -1
		
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			detectedIndex = event.keycode - KEY_1
		elif event.keycode == KEY_0:
			detectedIndex = 9
		
		if detectedIndex != -1:
			hotbarIndex = detectedIndex
			print("Selected hotbar index ", hotbarIndex)
