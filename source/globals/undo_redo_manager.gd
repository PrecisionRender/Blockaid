extends Node


signal saved_state_changed(is_saved: bool)


var undo_redo: UndoRedo = UndoRedo.new()
var save_version: int = 0:
	set(value):
		var old_save_version: int = save_version
		save_version = value
		if not save_version == old_save_version:
			saved_state_changed.emit((undo_redo.get_version() == value))


func _ready() -> void:
	undo_redo.version_changed.connect(_on_version_changed)


func _shortcut_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_pressed() or event.is_echo():
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


func _on_version_changed() -> void:
	saved_state_changed.emit(undo_redo.get_version() == save_version)
