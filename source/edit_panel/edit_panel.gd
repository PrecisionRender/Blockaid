class_name EditPanel
extends Control


signal brush_changed(type: Constants.Minos)
signal mino_queue_edit_requested(queue_type: Constants.MinoQueues)
signal screen_capture_requested


const DEFAULT_BRUSH: Constants.Minos = Constants.Minos.GARBAGE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button in get_tree().get_nodes_in_group("brush_buttons"):
		button.pressed.connect(_on_brush_button_pressed.bind(button.get_index()))
	
	emit_signal("brush_changed", DEFAULT_BRUSH)


func _on_brush_button_pressed(index: int) -> void:
	brush_changed.emit(index)



func _on_edit_hold_queue_pressed() -> void:
	mino_queue_edit_requested.emit(Constants.MinoQueues.HOLD)


func _on_edit_next_queue_pressed() -> void:
	mino_queue_edit_requested.emit(Constants.MinoQueues.NEXT)


func _on_screen_capture_button_pressed() -> void:
	screen_capture_requested.emit()
