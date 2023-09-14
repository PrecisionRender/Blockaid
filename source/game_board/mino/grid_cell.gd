class_name GridCell
extends Mino


signal cell_updated(id: int, type: Constants.Minos)


var id: int = -1

var brush: Constants.Minos = Constants.Minos.GARBAGE
var is_occupied: bool = false
var is_editable: bool = true


func change_brush(brush_type: Constants.Minos) -> void:
	brush = brush_type


func update_cell_type(new_type: Constants.Minos) -> void:
		modulate = Color.WHITE
		type = new_type
		is_occupied = not new_type == Constants.Minos.EMPTY
		cell_updated.emit(id, type)


func set_editable(value: bool) -> void:
	is_editable = value


func _is_mouse_button_pressed(button_mask: int) -> bool:
	return not (Input.get_mouse_button_mask() & button_mask) == 0


func _handle_cell_clicked() -> void:
	if not is_editable:
		return

	if _is_mouse_button_pressed(MOUSE_BUTTON_MASK_LEFT):
		update_cell_type(brush)
	elif _is_mouse_button_pressed(MOUSE_BUTTON_MASK_RIGHT):
		type = Constants.Minos.EMPTY
		update_cell_type(Constants.Minos.EMPTY)


func _on_texture_button_pressed() -> void:
	_handle_cell_clicked()


func _on_mouse_entered() -> void:
	if not is_editable:
		return
	if not is_occupied and not _is_mouse_button_pressed(MOUSE_BUTTON_MASK_LEFT):
		type = brush
		modulate = modulate.darkened(.5)

	_handle_cell_clicked()


func _on_mouse_exited() -> void:
	if not is_occupied:
		modulate = Color.WHITE
		type = Constants.Minos.EMPTY
