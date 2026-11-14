extends Node

var popupMaster: PopupMaster

func isValid(node: Node) -> bool:
	if node == null:
		return false
	
	if is_instance_valid(node):
		return true
	
	return false
