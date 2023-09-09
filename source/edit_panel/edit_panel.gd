class_name EditPanel
extends PanelContainer

signal screen_capture_requested
signal brush_changed(type: Constants.Minos)
signal board_clear_requested
signal mino_queue_edit_requested(queue_type: Constants.MinoQueues)
signal board_state_change_requested(state: int)


const DEFAULT_BRUSH: Constants.Minos = Constants.Minos.GARBAGE


@onready var board_editor: Control = $MarginContainer/VBoxContainer/BoardEditor
@onready var edit_mode_button: CheckButton = $MarginContainer/VBoxContainer/EditModeButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board_editor.visible = edit_mode_button.button_pressed
	get_tree().call_group("grid_cells", "set_editable", edit_mode_button.button_pressed)
	for button in get_tree().get_nodes_in_group("brush_buttons"):
		button.pressed.connect(_on_brush_button_pressed.bind(button.get_index()))
	
	emit_signal("brush_changed", DEFAULT_BRUSH)


func _on_edit_mode_button_toggled(button_pressed: bool) -> void:
	board_editor.visible = button_pressed
	get_tree().call_group("grid_cells", "set_editable", button_pressed)


func _on_brush_button_pressed(index: int) -> void:
	brush_changed.emit(index)


func _on_edit_hold_queue_pressed() -> void:
	mino_queue_edit_requested.emit(Constants.MinoQueues.HOLD)


func _on_edit_next_queue_pressed() -> void:
	mino_queue_edit_requested.emit(Constants.MinoQueues.NEXT)


func _on_screen_capture_button_pressed() -> void:
	screen_capture_requested.emit()


func _on_clear_board_button_pressed() -> void:
	board_clear_requested.emit()


func _on_board_state_dropdown_item_selected(index: int) -> void:
	board_state_change_requested.emit(index)
