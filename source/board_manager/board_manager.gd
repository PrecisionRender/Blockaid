class_name BoardManager
extends PanelContainer


@onready var session_title_label: Label = $MarginContainer/VBoxContainer/SessionTitleLabel
@onready var session_title_edit: LineEdit = $MarginContainer/VBoxContainer/SessionTitleEdit
@onready var board_list: Tree = $MarginContainer/VBoxContainer/BoardList


func _ready() -> void:
	session_title_label.text = SessionInfo.session_name

	var root = board_list.create_item()
	root.set_editable(0, false)
	root.set_text(0, "Root")

	board_list.set_drag_forwarding(Callable(self, "_get_drag_data_fw"), 
			Callable(self, "_can_drop_data_fw"), Callable(self, "_drop_data_fw"))


func _get_drag_data_fw(at_position: Vector2) -> Variant:
	board_list.drop_mode_flags = board_list.DROP_MODE_INBETWEEN

	var preview: MarginContainer = MarginContainer.new()
	preview.add_theme_constant_override("margin_left", 15)
	var label: Label = Label.new()
	label.text = SessionInfo.get_current_board().board_title
	preview.add_child(label)
	board_list.set_drag_preview(preview)

	var drag_data: Dictionary = {}
	drag_data["type"] = "boards";
	drag_data["board"] = board_list.get_selected().get_index()

	return drag_data


func _can_drop_data_fw(at_position: Vector2, data: Variant) -> bool:
	var tree_item: TreeItem = board_list.get_item_at_position(at_position)
	if !tree_item:
		return false

	
	board_list.drop_mode_flags = Tree.DROP_MODE_INBETWEEN
	return true


func _drop_data_fw(at_position: Vector2, data: Variant) -> void:
	board_list.drop_mode_flags = 0
	
	var item: TreeItem = board_list.get_item_at_position(at_position)
	if !item:
		return

	var section: int = board_list.get_drop_section_at_position(at_position)
	if section < -1:
		return

	if section < 1:
		board_list.get_selected().move_before(item)
	else:
		board_list.get_selected().move_after(item)

	SessionInfo.move_current_board_to(board_list.get_selected().get_index())


func _update_session_title() -> void:
	session_title_edit.hide()
	session_title_label.show()
	var new_title: String = session_title_edit.text
	if new_title.is_empty():
		return
	session_title_label.text = new_title
	SessionInfo.session_name = new_title


func _on_board_list_item_selected() -> void:
	pass


func _on_tree_item_activated() -> void:
	board_list.edit_selected(true)


func _on_tree_item_edited() -> void:
	board_list.get_edited().set_editable(0, false)
	SessionInfo.get_current_board().board_title = board_list.get_edited().get_text(0)


func _on_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.double_click == true:
		session_title_label.hide()
		session_title_edit.show()
		session_title_edit.text = session_title_label.text
		session_title_edit.grab_focus()
		session_title_edit.select_all()


func _on_line_edit_text_submitted(_new_text: String) -> void:
	_update_session_title()


func _on_line_edit_focus_exited() -> void:
	_update_session_title()


func _on_add_board_button_pressed() -> void:
	var item = board_list.create_item(null, board_list.get_root().get_child_count())
	item.set_editable(0, false)
	item.set_text(0, "New board")
	item.custom_minimum_height = 25
	board_list.set_selected(item, 0)
	SessionInfo.create_new_board()


func _on_board_list_item_mouse_selected(position: Vector2, mouse_button_index: int) -> void:
	if SessionInfo.boards.size() - 1 < board_list.get_selected().get_index():
		return
	SessionInfo.set_current_board_index(board_list.get_selected().get_index())

	if mouse_button_index != MOUSE_BUTTON_MASK_RIGHT:
		return

	var context_menu: PopupMenu = PopupMenu.new()
	context_menu.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
	
	context_menu.position = get_screen_position() + get_viewport().get_mouse_position()
	context_menu.min_size.x = 250

	context_menu.add_item("Cut")
	context_menu.add_item("Copy")
	context_menu.add_item("Paste")
	context_menu.add_separator()
	context_menu.add_item("Delete")

	context_menu.set_item_disabled(0, true)
	context_menu.set_item_disabled(1, true)
	context_menu.set_item_disabled(2, true)
	context_menu.set_item_disabled(4, true)
	context_menu.set_item_tooltip(0, "Not implemented yet")
	context_menu.set_item_tooltip(1, "Not implemented yet")
	context_menu.set_item_tooltip(2, "Not implemented yet")
	context_menu.set_item_tooltip(4, "Not implemented yet")

	var cut_event: InputEventKey = InputEventKey.new()
	cut_event.keycode = KEY_X | KEY_MASK_CMD_OR_CTRL
	var copy_event: InputEventKey = InputEventKey.new()
	copy_event.keycode = KEY_C | KEY_MASK_CMD_OR_CTRL
	var paste_event: InputEventKey = InputEventKey.new()
	paste_event.keycode = KEY_V | KEY_MASK_CMD_OR_CTRL
	var delete_event: InputEventKey = InputEventKey.new()
	delete_event.keycode = KEY_DELETE

	var cut_shortcut = Shortcut.new()
	cut_shortcut.events.append(cut_event)
	var copy_shortcut = Shortcut.new()
	copy_shortcut.events.append(copy_event)
	var paste_shortcut = Shortcut.new()
	paste_shortcut.events.append(paste_event)
	var delete_shortcut = Shortcut.new()

	delete_shortcut.events.append(delete_event)
	context_menu.set_item_shortcut(0, cut_shortcut)
	context_menu.set_item_shortcut(1, copy_shortcut)
	context_menu.set_item_shortcut(2, paste_shortcut)
	context_menu.set_item_shortcut(4, delete_shortcut)

	add_child(context_menu)
	context_menu.show()
