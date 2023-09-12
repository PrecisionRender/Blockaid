class_name BoardManager
extends PanelContainer


var board_list_context_menu: PopupMenu


@onready var session_title_label: Label = $MarginContainer/VBoxContainer/SessionTitleLabel
@onready var session_title_edit: LineEdit = $MarginContainer/VBoxContainer/SessionTitleEdit
@onready var save_button: MenuButton = $MarginContainer/VBoxContainer/ButtonBar/SaveFile
@onready var board_list: Tree = $MarginContainer/VBoxContainer/BoardList


func _ready() -> void:
	SessionManager.session_name_changed.connect(_on_session_name_changed)
	SessionManager.save_file_loaded.connect(_on_save_file_loaded)
	session_title_label.text = SessionManager.get_session_name()

	var root = board_list.create_item()
	root.set_editable(0, false)
	root.set_text(0, "Root")

	board_list.set_drag_forwarding(_get_drag_data_fw, _can_drop_data_fw, _drop_data_fw)

	_initialize_context_menus()


func _get_drag_data_fw(at_position: Vector2) -> Variant:
	board_list.drop_mode_flags = board_list.DROP_MODE_INBETWEEN

	var preview: MarginContainer = MarginContainer.new()
	preview.add_theme_constant_override("margin_left", 15)
	var label: Label = Label.new()
	label.text = SessionManager.get_current_board().board_title
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

	
	board_list.drop_mode_flags = Tree.DROP_MODE_INBETWEEN | Tree.DROP_MODE_ON_ITEM
	return true


func _drop_data_fw(at_position: Vector2, data: Variant) -> void:
	board_list.drop_mode_flags = 0
	
	var item: TreeItem = board_list.get_item_at_position(at_position)
	if !item:
		return

	var section: int = board_list.get_drop_section_at_position(at_position)
	if section < -1:
		return

	var is_dragging_up: bool = item.get_index() < board_list.get_selected().get_index()

	if section == -1 or (section == 0 and is_dragging_up):
		board_list.get_selected().move_before(item)
	else:
		board_list.get_selected().move_after(item)

	SessionManager.move_current_board_to(board_list.get_selected().get_index())


func _initialize_context_menus() -> void:
	var control_key: int
	match OS.get_name():
		"macOS":
			control_key = KEY_MASK_META
		_:
			control_key = KEY_MASK_CTRL

	save_button.get_popup().add_item("Save", 0, control_key | KEY_S)
	save_button.get_popup().add_item("Save as...", 1, control_key | KEY_MASK_SHIFT | KEY_S)

	save_button.get_popup().index_pressed.connect(_on_save_button_pressed)

	board_list_context_menu = PopupMenu.new()
	board_list_context_menu.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE

	board_list_context_menu.min_size.x = 300

	board_list_context_menu.add_item("Cut")
	board_list_context_menu.add_item("Copy")
	board_list_context_menu.add_item("Paste")
	board_list_context_menu.add_separator()
	board_list_context_menu.add_item("Rename")
	board_list_context_menu.add_item("Delete")
	board_list_context_menu.set_item_indent(0, 2)
	board_list_context_menu.set_item_indent(1, 2)
	board_list_context_menu.set_item_indent(2, 2)
	board_list_context_menu.set_item_indent(4, 2)
	board_list_context_menu.set_item_indent(5, 2)

	board_list_context_menu.set_item_disabled(0, true)
	board_list_context_menu.set_item_disabled(1, true)
	board_list_context_menu.set_item_disabled(2, true)
	board_list_context_menu.set_item_disabled(4, true)
	board_list_context_menu.set_item_disabled(5, true)
	board_list_context_menu.set_item_tooltip(0, "Not implemented yet")
	board_list_context_menu.set_item_tooltip(1, "Not implemented yet")
	board_list_context_menu.set_item_tooltip(2, "Not implemented yet")
	board_list_context_menu.set_item_tooltip(4, "Not implemented yet")
	board_list_context_menu.set_item_tooltip(5, "Not implemented yet")

	var cut_event: InputEventKey = InputEventKey.new()
	cut_event.keycode = KEY_X | KEY_MASK_CMD_OR_CTRL
	var copy_event: InputEventKey = InputEventKey.new()
	copy_event.keycode = KEY_C | KEY_MASK_CMD_OR_CTRL
	var paste_event: InputEventKey = InputEventKey.new()
	paste_event.keycode = KEY_V | KEY_MASK_CMD_OR_CTRL
	var rename_event: InputEventKey = InputEventKey.new()
	rename_event.keycode = KEY_F2
	var delete_event: InputEventKey = InputEventKey.new()
	delete_event.keycode = KEY_DELETE

	var cut_shortcut = Shortcut.new()
	cut_shortcut.events.append(cut_event)
	var copy_shortcut = Shortcut.new()
	copy_shortcut.events.append(copy_event)
	var paste_shortcut = Shortcut.new()
	paste_shortcut.events.append(paste_event)
	var rename_shortcut = Shortcut.new()
	rename_shortcut.events.append(rename_event)
	var delete_shortcut = Shortcut.new()
	delete_shortcut.events.append(delete_event)

	board_list_context_menu.set_item_shortcut(0, cut_shortcut)
	board_list_context_menu.set_item_shortcut(1, copy_shortcut)
	board_list_context_menu.set_item_shortcut(2, paste_shortcut)
	board_list_context_menu.set_item_shortcut(4, rename_shortcut)
	board_list_context_menu.set_item_shortcut(5, delete_shortcut)

	add_child(board_list_context_menu)

func _create_new_board(title: String = "New board") -> void:
	var item = board_list.create_item(null, board_list.get_root().get_child_count())
	item.set_editable(0, false)
	item.set_text(0, title)
	item.custom_minimum_height = 25
	board_list.set_selected(item, 0)


func _update_session_title() -> void:
	session_title_edit.hide()
	session_title_label.show()
	var new_title: String = session_title_edit.text
	if new_title.is_empty():
		return
	SessionManager.set_session_name(new_title)


func _on_session_name_changed(new_title: String) -> void:
	session_title_label.text = new_title


func _on_add_board_button_pressed() -> void:
	_create_new_board()
	SessionManager.create_new_board()


func _on_save_file_loaded() -> void:
	var tree_root: TreeItem = board_list.get_root()
	for item in tree_root.get_children():
		tree_root.remove_child(item)
	for board in SessionManager.boards:
		_create_new_board(board.board_title)
	
	if tree_root.get_child_count() > 0:
		board_list.set_selected(tree_root.get_child(0), 0)
		SessionManager.set_current_board_index(0)


func _on_tree_item_activated() -> void:
	board_list.edit_selected(true)


func _on_tree_item_edited() -> void:
	board_list.get_edited().set_editable(0, false)
	SessionManager.get_current_board().board_title = board_list.get_edited().get_text(0)


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


func _on_board_list_item_mouse_selected(position: Vector2, mouse_button_index: int) -> void:
	if SessionManager.boards.size() - 1 < board_list.get_selected().get_index():
		return
	SessionManager.set_current_board_index(board_list.get_selected().get_index())

	if mouse_button_index != MOUSE_BUTTON_MASK_RIGHT:
		return

	board_list_context_menu.position = get_screen_position() + get_viewport().get_mouse_position()
	board_list_context_menu.show()


func _on_open_file_pressed() -> void:
	var file_extension: PackedStringArray = PackedStringArray(["*" + Constants.FILE_EXTENSION])
	DisplayServer.file_dialog_show("Open", OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), "", false, 
			DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, file_extension, _open_dialogue_confirmed)


func _on_save_button_pressed(button_menu_item_index: int) -> void:
	if button_menu_item_index > 0 or !SessionManager.session_path.is_absolute_path():
		var file_extension: PackedStringArray = PackedStringArray(["*" + Constants.FILE_EXTENSION])
		DisplayServer.file_dialog_show("Save as...", OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), 
				SessionManager.get_session_name(), false, DisplayServer.FILE_DIALOG_MODE_SAVE_FILE, 
				file_extension, _save_dialogue_confirmed)
	else:
		SessionManager.save_to_file(SessionManager.session_path)


func _open_dialogue_confirmed(status: bool, selected_paths: PackedStringArray) -> void:
	if !status:
		return

	var path: String = selected_paths[0]
	if !path.ends_with(".bbs"):
		path += ".bbs"
	SessionManager.load_from_file(path)


func _save_dialogue_confirmed(status: bool, selected_paths: PackedStringArray) -> void:
	if !status:
		return

	var path: String = selected_paths[0]
	if !path.ends_with(".bbs"):
		path += ".bbs"
	SessionManager.save_to_file(path)
