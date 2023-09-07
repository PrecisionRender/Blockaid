class_name EditPanel
extends Control


signal brush_changed(type: Constants.Minos)
signal hold_queue_edit_requested
signal next_queue_edit_requested


const DEFAULT_BRUSH: Constants.Minos = Constants.Minos.GARBAGE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button in get_tree().get_nodes_in_group("brush_buttons"):
		button.pressed.connect(_on_brush_button_pressed.bind(button.get_index()))
	
	emit_signal("brush_changed", DEFAULT_BRUSH)


func _on_brush_button_pressed(index: int) -> void:
	brush_changed.emit(index)



func _on_edit_hold_queue_pressed() -> void:
	hold_queue_edit_requested.emit()


func _on_edit_next_queue_pressed() -> void:
	next_queue_edit_requested.emit()
