class_name BoardManager
extends PanelContainer


signal board_cut_queued
signal open_options_requested


var board_list_context_menu: PopupMenu


@onready var session_title_label: Label = $MarginContainer/VBoxContainer/SessionTitleLabel
@onready var session_title_edit: LineEdit = $MarginContainer/VBoxContainer/SessionTitleEdit
@onready var save_button: MenuButton = $MarginContainer/VBoxContainer/ButtonBar/SaveFile
@onready var board_list: Tree = $MarginContainer/VBoxContainer/BoardList
@onready var version_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VersionLabel



func _ready() -> void:
	SessionManager.session_name_changed.connect(_on_session_name_changed)
	SessionManager.board_added.connect(_on_board_added)
	SessionManager.board_removed.connect(_on_board_removed)
	SessionManager.board_moved.connect(_on_board_moved)
	SessionManager.current_board_changed.connect(_on_current_board_changed)
	SessionManager.save_file_loaded.connect(_on_save_file_loaded)
	UndoRedoManager.saved_state_changed.connect(_update_title_label)
	session_title_label.text = SessionManager.get_session_name()

	# Create an invisible root item in the board list
	var root = board_list.create_item()
	root.set_editable(0, false)
	root.set_text(0, "Root")

	# Forward drag-and-drop information from the board list so it can be handeled here
	board_list.set_drag_forwarding(_get_drag_data_fw, _can_drop_data_fw, _drop_data_fw)

	_initialize_context_menus()
	_update_title_label()

	version_label.text = "v%s" % ProjectSettings.get_setting("application/config/version")

	SessionManager.load_from_last_session()


func _shortcut_input(event: InputEvent) -> void:
	# Only forward shortcut inputs if they are the first press of a button
	if not event.is_pressed() and not event.is_echo():
		return
	board_list_context_menu.activate_item_by_event(event)


func _get_drag_data_fw(_at_position: Vector2) -> Variant:
	# Create a drag-and-drop preview containing the board's name
	var preview: MarginContainer = MarginContainer.new()
	preview.add_theme_constant_override("margin_left", 15)
	var label: Label = Label.new()
	label.text = SessionManager.get_current_board().board_title
	preview.add_child(label)
	board_list.set_drag_preview(preview)

	# Store the board in the drag information
	var drag_data: Dictionary = {}
	drag_data["type"] = "boards";
	drag_data["board"] = board_list.get_selected().get_index()

	return drag_data


func _can_drop_data_fw(at_position: Vector2, _data: Variant) -> bool:
	# Do not allow dropping if the mouse is not inside the board list
	var tree_item: TreeItem = board_list.get_item_at_position(at_position)
	if not tree_item:
		return false

	# Enable the drag and drop highlighter
	board_list.drop_mode_flags = Tree.DROP_MODE_INBETWEEN | Tree.DROP_MODE_ON_ITEM
	return true


func _drop_data_fw(at_position: Vector2, _data: Variant) -> void:
	# Remove the drag and drop highlighter
	board_list.drop_mode_flags = 0

	# Get the tree item at the current mouse position
	var item: TreeItem = board_list.get_item_at_position(at_position)
	if not item:
		return

	SessionManager.move_current_board_to(item.get_index())


func _on_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.double_click == true:
		# Hide the static label and show the text edit box
		session_title_label.hide()
		session_title_edit.show()
		# Set the text edit box's current text to the session's current title
		session_title_edit.text = session_title_label.text.trim_suffix("*")
		# Select the whole text
		session_title_edit.grab_focus()
		session_title_edit.select_all()


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


func _update_title_label() -> void:
	# Check if the current undo version matches the version of the last time we saved
	var is_saved: bool = UndoRedoManager.save_version == UndoRedoManager.undo_redo.get_version()
	session_title_label.text = SessionManager.get_session_name()
	if not is_saved:
		session_title_label.text += "*"


func _add_board_item(title: String, index = -1) -> void:
	# If index is -1, just add an item at the end of the list
	index = index if not index == -1 else board_list.get_root().get_child_count()
	var item = board_list.create_item(null, index)
	# Don't allow editing by default
	item.set_editable(0, false)
	item.set_text(0, title)
	item.custom_minimum_height = 25
	# Select the newly-created board item
	board_list.set_selected(item, 0)


func _update_item_name_from_board(board: Board) -> void:
	# Find the index of the supplied board in the board list
	var board_index: int = SessionManager.boards.find(board)
	# Update the title of the item with the matching index
	board_list.get_root().get_child(board_index).set_text(0, board.board_title)


func _update_session_title() -> void:
	# Hide the text edit box and show the static label
	session_title_edit.hide()
	session_title_label.show()
	# Don't bother updating the etxt if the input was empty
	var new_title: String = session_title_edit.text
	if new_title.is_empty():
		return
	SessionManager.set_session_name(new_title)


func _on_board_added(index: int, _old_index: int) -> void:
	# Add a board item to represent a new board when it's created
	_add_board_item(SessionManager.get_current_board().board_title, index)


func _on_board_removed(_index: int) -> void:
	board_list.get_root().remove_child(board_list.get_selected())

	var current_board_index: int = SessionManager.get_current_board_index()
	if not current_board_index == -1:
		board_list.set_selected(board_list.get_root().get_child(current_board_index), 0)


func _on_board_moved(to_index: int, old_index: int) -> void:
	# When a board is moved, just remove the item representing it
	# and add an item at the new index
	board_list.get_root().remove_child(board_list.get_root().get_child(old_index))
	_add_board_item(SessionManager.get_current_board().board_title, to_index)


func _on_current_board_changed(index: int, _old_index: int) -> void:
	if index == -1 or index == board_list.get_selected().get_index():
		return
	board_list.deselect_all()
	board_list.set_selected(board_list.get_root().get_child(index), 0)


func _on_session_name_changed(_new_title: String) -> void:
	_update_title_label()


func _on_add_board_button_pressed() -> void:
	# Duh
	SessionManager.add_board()


func _on_save_file_loaded() -> void:
	# When a new save file is loaded, remove all current items
	var tree_root: TreeItem = board_list.get_root()
	for item in tree_root.get_children():
		tree_root.remove_child(item)
	# Then add the loaded ones
	for board in SessionManager.boards:
		_add_board_item(board.board_title)
	
	if tree_root.get_child_count() > 0:
		board_list.set_selected(tree_root.get_child(0), 0)


func _on_tree_item_activated() -> void:
	board_list.edit_selected(true)


func _on_tree_item_edited() -> void:
	board_list.get_edited().set_editable(0, false)

	var board: Board = SessionManager.get_current_board()
	var board_item: TreeItem = board_list.get_edited()

	UndoRedoManager.undo_redo.create_action("Rename board")
	# For the do action, set the current board's title to match the board item's text...
	UndoRedoManager.undo_redo.add_do_property(board, "board_title", board_item.get_text(0))
	# ...and update the corresponding board item's title to match
	UndoRedoManager.undo_redo.add_do_method(_update_item_name_from_board.bind(board))
	# For the undo action, set the current board's title to whatever it currently is...
	UndoRedoManager.undo_redo.add_undo_property(board, "board_title", board.board_title)
	# ...and update the corresponding board item's title to match
	UndoRedoManager.undo_redo.add_undo_method(_update_item_name_from_board.bind(board))

	board.board_title = board_item.get_text(0)
	UndoRedoManager.undo_redo.commit_action(false)



func _on_line_edit_text_submitted(_new_text: String) -> void:
	_update_session_title()


func _on_line_edit_focus_exited() -> void:
	_update_session_title()


@warning_ignore("shadowed_variable_base_class")
func _on_board_list_item_mouse_selected(position: Vector2, mouse_button_index: int) -> void:
	if SessionManager.boards.size() - 1 < board_list.get_selected().get_index():
		return

	# Change the current board to the one corersponding to the selected item
	SessionManager.change_current_board_index(board_list.get_selected().get_index())

	if not mouse_button_index == MOUSE_BUTTON_MASK_RIGHT:
		return

	# If we did a right-click, spawn the right-click context menu
	board_list_context_menu.position = get_screen_position() + get_viewport().get_mouse_position()
	board_list_context_menu.show()


func _on_open_file_pressed() -> void:
	# Show the open file dialogue
	var file_extension: PackedStringArray = PackedStringArray(
				["*" + Constants.FILE_EXTENSION + ";Blockaid Board Session"])
	var current_directory: String = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	if Settings.is_valid_path(Settings.last_working_directory):
		current_directory = Settings.last_working_directory
	DisplayServer.file_dialog_show("Open", current_directory, "", false, 
			DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, file_extension, _open_dialogue_confirmed)


func _on_save_menu_index_pressed(menu_item_index: int) -> void:
	# Show the save file dialogue if there isn't a currently opened file
	if menu_item_index > 0 or not SessionManager.session_path.is_absolute_path():
		var file_extension: PackedStringArray = PackedStringArray(
				["*" + Constants.FILE_EXTENSION + ";Blockaid Board Session"])
		var current_directory: String = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
		if Settings.is_valid_path(Settings.last_working_directory):
			current_directory = Settings.last_working_directory
		DisplayServer.file_dialog_show("Save as...", current_directory, 
				SessionManager.get_session_name(), false, DisplayServer.FILE_DIALOG_MODE_SAVE_FILE, 
				file_extension, _save_dialogue_confirmed)
	else:
		# Save to the currently opened file
		SessionManager.save_to_file(SessionManager.session_path)


func _on_board_menu_id_pressed(menu_item_id: int) -> void:
	match menu_item_id:
		# Cut
		0:
			# Don't cut if there's no active board
			if not SessionManager.get_current_board_index() == -1:
				board_cut_queued.emit()
				# Copy the board information to the clipboard
				var board_data: Dictionary = SessionManager.get_current_board().get_as_dictionary()
				DisplayServer.clipboard_set(JSON.stringify(board_data, "", false))
				# Remove it from the board list
				SessionManager.remove_current_board()
		# Copy
		1:
			# Don't copy if there's no active board
			if not SessionManager.get_current_board_index() == -1:
				# Copy the board information to the clipboard
				var board_data: Dictionary = SessionManager.get_current_board().get_as_dictionary()
				DisplayServer.clipboard_set(JSON.stringify(board_data, "", false))
		# Paste
		2:
			# Try to get board information from the clipboard
			var json: JSON = JSON.new()
			var error: int = json.parse(DisplayServer.clipboard_get())
			if not error == OK:
				return
			# If we succeeded, create a new board with that data
			var board: Board = Board.new()
			if board.set_from_dictionary(json.data):
				SessionManager.add_board(-1, board)
		# Rename
		3:
			# Basically just double-clicking an item
			board_list.get_selected().set_editable(0, true)
			board_list.edit_selected()
		# Delete
		4:
			# Who could have guessed?
			SessionManager.remove_current_board()


func _open_dialogue_confirmed(status: bool, selected_paths: PackedStringArray, 
		_selected_filter_index: int) -> void:
	# Do nothing if the file dialogue was cancelled
	if not status:
		return

	var path: String = selected_paths[0]
	# If the file the user is trying to open doesn't have an extension, assume
	# they're trying to open a .bbs file
	if not path.to_lower().ends_with(Constants.FILE_EXTENSION):
		path += Constants.FILE_EXTENSION
	SessionManager.load_from_file(path)


func _save_dialogue_confirmed(status: bool, selected_paths: PackedStringArray, 
		_selected_filter_index: int) -> void:
	# Do nothing if the file dialogue was cancelled
	if not status:
		return

	# Save to the selected file
	SessionManager.save_to_file(selected_paths[0])


func _on_options_button_pressed() -> void:
	open_options_requested.emit()
