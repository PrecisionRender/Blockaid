extends Node


var undo_redo: UndoRedo = UndoRedo.new()


func _shortcut_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_pressed():
		return

	if event.keycode == KEY_Y and event.is_command_or_control_pressed():
		undo_redo.redo()
		return
	if event.keycode == KEY_Z and event.is_command_or_control_pressed() and event.shift_pressed:
		undo_redo.redo()
		return
	if event.keycode == KEY_Z and event.is_command_or_control_pressed():
		undo_redo.undo()
		return
