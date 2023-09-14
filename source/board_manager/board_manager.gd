class_name BoardManager
extends PanelContainer


signal board_cut_queued


var board_list_context_menu: PopupMenu


@onready var session_title_label: Label = $MarginContainer/VBoxContainer/SessionTitleLabel
@onready var session_title_edit: LineEdit = $MarginContainer/VBoxContainer/SessionTitleEdit
@onready var save_button: MenuButton = $MarginContainer/VBoxContainer/ButtonBar/SaveFile
@onready var board_list: Tree = $MarginContainer/VBoxContainer/BoardList


func _ready() -> void:
	SessionManager.session_name_changed.connect(_on_session_name_changed)
	SessionManager.board_added.connect(_on_board_added)
	SessionManager.board_removed.connect(_on_board_removed)
	SessionManager.board_moved.connect(_on_board_moved)
	SessionManager.save_file_loaded.connect(_on_save_file_loaded)
	session_title_label.text = SessionManager.get_session_name()

	var root = board_list.create_item()
	root.set_editable(0, false)
	root.set_text(0, "Root")

	board_list.set_drag_forwarding(_get_drag_data_fw, _can_drop_data_fw, _drop_data_fw)

	_initialize_context_menus()


func _shortcut_input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	board_list_context_menu.activate_item_by_event(event)


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
	if not tree_item:
		return false

	
	board_list.drop_mode_flags = Tree.DROP_MODE_INBETWEEN | Tree.DROP_MODE_ON_ITEM
	return true


func _drop_data_fw(at_position: Vector2, data: Variant) -> void:
	board_list.drop_mode_flags = 0
	
	var item: TreeItem = board_list.get_item_at_position(at_position)
	if not item:
		return

	SessionManager.move_current_board_to(item.get_index())


func _initialize_context_menus() -> void:
	var control_key: int
	match OS.get_name():
		"macOS":
			control_key = KEY_MASK_META
		_:
			control_key = KEY_MASK_CTRL

	save_button.get_popup().add_item("Save", 0, control_key | KEY_S)
	save_button.get_popup().add_item("Save as...", 1, control_key | KEY_MASK_SHIFT | KEY_S)
	save_button.get_popup().set_item_indent(0, 2)
	save_button.get_popup().set_item_indent(1, 2)

	save_button.get_popup().index_pressed.connect(_on_save_menu_index_pressed)

	board_list_context_menu = PopupMenu.new()
	board_list_context_menu.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE

	board_list_context_menu.min_size.x = 300

	board_list_context_menu.add_item("Cut", 0, control_key | KEY_X)
	board_list_context_menu.add_item("Copy", 1, control_key | KEY_C)
	board_list_context_menu.add_item("Paste", 2, control_key | KEY_V)
	board_list_context_menu.add_separator("", 5)
	board_list_context_menu.add_item("Rename", 3, KEY_F2)
	board_list_context_menu.add_item("Delete", 4, KEY_DELETE)
	board_list_context_menu.set_item_indent(0, 2)
	board_list_context_menu.set_item_indent(1, 2)
	board_list_context_menu.set_item_indent(2, 2)
	board_list_context_menu.set_item_indent(4, 2)
	board_list_context_menu.set_item_indent(5, 2)

	add_child(board_list_context_menu)
	board_list_context_menu.id_pressed.connect(_on_board_menu_id_pressed)


func _add_board_item(title: String, index = -1) -> void:
	index = index if not index == -1 else board_list.get_root().get_child_count()
	var item = board_list.create_item(null, index)
	item.set_editable(0, false)
	item.set_text(0, title)
	item.custom_minimum_height = 25
	board_list.set_selected(item, 0)


func _update_item_name_from_board(board: SessionManager.Board) -> void:
	var board_index: int = SessionManager.boards.find(board)
	board_list.get_root().get_child(board_index).set_text(0, board.board_title)


func _update_session_title() -> void:
	session_title_edit.hide()
	session_title_label.show()
	var new_title: String = session_title_edit.text
	if new_title.is_empty():
		return
	SessionManager.set_session_name(new_title)


func _on_board_added(index: int, old_index: int) -> void:
	_add_board_item(SessionManager.get_current_board().board_title, index)


func _on_board_removed(index: int) -> void:
	board_list.get_root().remove_child(board_list.get_selected())

	var current_board_index: int = SessionManager.get_current_board_index()
	if not current_board_index == -1:
		board_list.set_selected(board_list.get_root().get_child(current_board_index), 0)


func _on_board_moved(to_index: int, old_index: int) -> void:
	board_list.get_root().remove_child(board_list.get_root().get_child(old_index))
	_add_board_item(SessionManager.get_current_board().board_title, to_index)


func _on_session_name_changed(new_title: String) -> void:
	session_title_label.text = new_title


func _on_add_board_button_pressed() -> void:
	SessionManager.add_board()


func _on_save_file_loaded() -> void:
	var tree_root: TreeItem = board_list.get_root()
	for item in tree_root.get_children():
		tree_root.remove_child(item)
	for board in SessionManager.boards:
		_add_board_item(board.board_title)
	
	if tree_root.get_child_count() > 0:
		board_list.set_selected(tree_root.get_child(0), 0)


func _on_tree_item_activated() -> void:
	board_list.edit_selected(true)


func _on_tree_item_edited() -> void:
	board_list.get_edited().set_editable(0, false)

	UndoRedoManager.undo_redo.create_action("Rename board")
	var board: SessionManager.Board = SessionManager.get_current_board()
	var board_item: TreeItem = board_list.get_edited()
	UndoRedoManager.undo_redo.add_do_property(board, "board_title", board_item.get_text(0))
	UndoRedoManager.undo_redo.add_do_method(_update_item_name_from_board.bind(board))
	UndoRedoManager.undo_redo.add_undo_property(board, "board_title", board.board_title)
	UndoRedoManager.undo_redo.add_undo_method(_update_item_name_from_board.bind(board))
	UndoRedoManager.undo_redo.commit_action()


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
	SessionManager.change_current_board(board_list.get_selected().get_index())

	if not mouse_button_index == MOUSE_BUTTON_MASK_RIGHT:
		return

	board_list_context_menu.position = get_screen_position() + get_viewport().get_mouse_position()
	board_list_context_menu.show()


func _on_open_file_pressed() -> void:
	var file_extension: PackedStringArray = PackedStringArray(["*" + Constants.FILE_EXTENSION])
	DisplayServer.file_dialog_show("Open", OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), "", false, 
			DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, file_extension, _open_dialogue_confirmed)


func _on_save_menu_index_pressed(menu_item_index: int) -> void:
	if menu_item_index > 0 or not SessionManager.session_path.is_absolute_path():
		var file_extension: PackedStringArray = PackedStringArray(["*" + Constants.FILE_EXTENSION])
		DisplayServer.file_dialog_show("Save as...", OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), 
				SessionManager.get_session_name(), false, DisplayServer.FILE_DIALOG_MODE_SAVE_FILE, 
				file_extension, _save_dialogue_confirmed)
	else:
		SessionManager.save_to_file(SessionManager.session_path)


func _on_board_menu_id_pressed(menu_item_id: int) -> void:
	match menu_item_id:
		0:
			if not SessionManager.get_current_board_index() == -1:
				board_cut_queued.emit()
				var board_data: Dictionary = SessionManager.get_current_board().get_as_dictionary()
				DisplayServer.clipboard_set(JSON.stringify(board_data, "", false))
				SessionManager.remove_current_board()
		1:
			if not SessionManager.get_current_board_index() == -1:
				var board_data: Dictionary = SessionManager.get_current_board().get_as_dictionary()
				DisplayServer.clipboard_set(JSON.stringify(board_data, "", false))
		2:
			var json: JSON = JSON.new()
			var error: int = json.parse(DisplayServer.clipboard_get())
			if not error == OK:
				return
			var board: SessionManager.Board = SessionManager.Board.new()
			if board.set_from_dictionary(json.data):
				SessionManager.add_board(-1, board)
		3:
			board_list.get_selected().set_editable(0, true)
			board_list.edit_selected()
		4:
			SessionManager.remove_current_board()


func _open_dialogue_confirmed(status: bool, selected_paths: PackedStringArray) -> void:
	if not status:
		return

	var path: String = selected_paths[0]
	if not path.ends_with(Constants.FILE_EXTENSION):
		path += Constants.FILE_EXTENSION
	SessionManager.load_from_file(path)


func _save_dialogue_confirmed(status: bool, selected_paths: PackedStringArray) -> void:
	if not status:
		return

	var path: String = selected_paths[0]
	if not path.ends_with(Constants.FILE_EXTENSION):
		path += Constants.FILE_EXTENSION
	SessionManager.save_to_file(path)
