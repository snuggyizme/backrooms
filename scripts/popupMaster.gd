## Controls and creates popups (e.g. item tooltips, block functionalities)
class_name PopupMaster extends Control
signal popupButtonPressed(popup, buttonTag: StringName)

const POPUP_SCENE: PackedScene = preload("res://scenes/popup.tscn")

var items: Dictionary[StringName, Node]

func create(
	def: PopupDefinition,
	pos: Vector2,
	tag: StringName,
	rowTags: Array[StringName]
) -> void:
	var popup: PanelContainer = POPUP_SCENE.instantiate()
	var rowAddPoint: VBoxContainer = popup.get_child(0)
	
	for i: int in range(def.rows.size()):
		var rowDef: PopupRow = def.rows[i]
		var row: PanelContainer = rowDef.getScene().instantiate()
		var rowTag: StringName = rowTags[i]
		
		if rowDef is TextPopupRow:
			items[rowTag] = row.get_node("Label")
		elif rowDef is ButtonPopupRow:
			items[rowTag] = row.get_node("Button")
		
		rowAddPoint.add_child(row)
	
	var fitPos: Vector2 = findFittingPos(pos, popup.size)
	popup.global_position = fitPos
	
	add_child(popup)

func findFittingPos(pos: Vector2, popupSize: Vector2) -> Vector2:
	var viewportRect: Rect2 = get_viewport_rect()
	
	var candidates: Array[Vector2] = [
		pos - popupSize,                # NW
		pos + Vector2(-popupSize.x, 0), # SW
		pos + Vector2(0, -popupSize.y), # NE
		pos,                            # SE
	]
	candidates.reverse()
	
	for candidate: Vector2 in candidates:
		var popupRect := Rect2(candidate, popupSize)
		if viewportRect.encloses(popupRect):
			return candidate
	
	return Vector2(
		clampf(pos.x, viewportRect.position.x, viewportRect.end.x - popupSize.x),
		clampf(pos.y, viewportRect.position.y, viewportRect.end.y - popupSize.y)
	)

func updateLabel(labelTag: StringName, text: String) -> void:
	var label: Label = getItem(labelTag) as Label
	label.text = text

func getItem(tag: StringName) -> Node:
	if not items.has(tag):
		return null
	
	var item: Node = items[tag]
	
	if item == null:
		items.erase(tag)
		return null
	
	if not is_instance_valid(item):
		items.erase(tag)
		return null
	
	return item
