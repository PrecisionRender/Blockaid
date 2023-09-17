extends Node


signal session_name_changed(new_name: String)
signal current_board_changed(index: int, old_index: int)
signal board_added(index: int, old_index: int)
signal board_removed(index: int)
signal board_info_changed
signal board_order_edit_queued
signal board_moved(to_index: int, old_index: int)
signal board_save_queued
signal save_file_loaded


var session_path: String = ""
var boards: Array[Board]
var _session_name: String = "Untitled"
var _current_board_index: int = -1


func load_from_last_session() -> void:
	if Settings.startup_behavior == Settings.StartupBehavior.LOAD_LAST_SESSION:
		load_from_file(Settings.last_opened_session)


func get_session_name() -> String:
	return _session_name


func set_session_name(new_name: String) -> void:
	if new_name == _session_name:
		return
	UndoRedoManager.undo_redo.create_action("Rename session")
	UndoRedoManager.undo_redo.add_do_property(self, "_session_name", new_name)
	UndoRedoManager.undo_redo.add_undo_property(self, "_session_name", self._session_name)
	UndoRedoManager.undo_redo.add_do_method(_on_session_name_undo_redo)
	UndoRedoManager.undo_redo.add_undo_method(_on_session_name_undo_redo)
	UndoRedoManager.undo_redo.commit_action()
	session_name_changed.emit(_session_name)


func get_current_board() -> Board:
	if _current_board_index < 0:
		return null
	return boards[_current_board_index]


func set_board_info(board: Board, info_type: Constants.BoardState, info: BoardInfo) -> void:
	if not boards.has(board):
		return

	UndoRedoManager.undo_redo.create_action("Edit board info")
	var board_changed_signal: Signal = self.board_info_changed
	var info_name: String = ""
	var old_info: BoardInfo

	match info_type:
		Constants.BoardState.INITIAL:
			info_name = "initial_board_info"
			old_info = board.initial_board_info
		Constants.BoardState.SOLUTION:
			info_name = "solution_board_info"
			old_info = board.solution_board_info
		Constants.BoardState.ALTERNATE_SOLUTION:
			info_name = "alternate_solution_board_info"
			old_info = board.alternate_solution_board_info
		_:
			pass
	
	UndoRedoManager.undo_redo.add_do_method(change_current_board.bind(board))
	UndoRedoManager.undo_redo.add_do_property(board, info_name, info)
	UndoRedoManager.undo_redo.add_do_method(func() -> void: board_changed_signal.emit())

	UndoRedoManager.undo_redo.add_undo_method(change_current_board.bind(board))
	UndoRedoManager.undo_redo.add_undo_property(board, info_name, old_info)
	UndoRedoManager.undo_redo.add_undo_method(func() -> void: board_changed_signal.emit())

	UndoRedoManager.undo_redo.commit_action()


func get_current_board_index() -> int:
	return _current_board_index


func change_current_board_index(new_index: int) -> void:
	var old_board = _current_board_index
	_current_board_index = new_index
	current_board_changed.emit(new_index, old_board)


func change_current_board(board: Board) -> void:
	if not boards.has(board) or board == get_current_board():
		return
	var old_board = _current_board_index
	_current_board_index = boards.find(board)
	current_board_changed.emit(_current_board_index, old_board)


func add_board(at_index: int = -1, board: Board = Board.new()) -> void:
	UndoRedoManager.undo_redo.create_action("Add board")
	UndoRedoManager.undo_redo.add_do_method(_add_board_undo_redo.bind(at_index, board))
	UndoRedoManager.undo_redo.add_undo_method(_remove_current_board_undo_redo)
	UndoRedoManager.undo_redo.commit_action()


func remove_current_board() -> void:
	if _current_board_index == -1:
		return

	UndoRedoManager.undo_redo.create_action("Remove board")
	var current_board: Board = get_current_board()
	UndoRedoManager.undo_redo.add_do_method(_remove_current_board_undo_redo)
	UndoRedoManager.undo_redo.add_undo_reference(current_board)
	UndoRedoManager.undo_redo.add_undo_method(_add_board_undo_redo.bind(
			_current_board_index, current_board))
	UndoRedoManager.undo_redo.commit_action()


func move_current_board_to(to_index: int) -> void:
	UndoRedoManager.undo_redo.create_action("Move board")
	var current_board: Board = get_current_board()
	UndoRedoManager.undo_redo.add_do_method(_move_board_undo_redo.bind(current_board, to_index))
	UndoRedoManager.undo_redo.add_undo_method(_move_board_undo_redo.bind(current_board, 
			boards.find(current_board)))
	UndoRedoManager.undo_redo.commit_action()


func save_to_file(file_path: String) -> void:
	if not file_path.is_absolute_path():
		return

	board_save_queued.emit()

	var save_data: Dictionary = {
		"session_name": _session_name,
		"boards": []
	}
	
	for x in range(boards.size()):
		var board_dict: Dictionary = {
			"title": boards[x].board_title,
			"notes": boards[x].board_notes,
			"initial_board_info": boards[x].initial_board_info.to_dictionary(),
			"solution_board_info": boards[x].solution_board_info.to_dictionary(),
			"alternate_solution_board_info": boards[x].alternate_solution_board_info.to_dictionary()
		}
		save_data["boards"].append(board_dict)
	
	var save_file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	
	save_file.store_line(JSON.stringify(save_data, "", false))
	session_path = file_path
	UndoRedoManager.save_version = UndoRedoManager.undo_redo.get_version()
	Settings.last_opened_session = file_path


func load_from_file(file_path: String) -> void:
	if file_path.is_empty():
		return

	if not FileAccess.file_exists(file_path):
		push_error("File path %s does not exist." % file_path)
		return

	var save_file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	var json = JSON.new()
	var error: Error = json.parse(save_file.get_as_text())
	if not error == OK:
		push_error("Could not load file at %s" % file_path)
		return

	var save_data: Dictionary = json.data
	set_session_name(save_data["session_name"])
	boards = []
	for x in range(save_data["boards"].size()):
		var board: Board = Board.new()
		if board.set_from_dictionary(save_data["boards"][x]):
			boards.append(board)

	_current_board_index = 0 if boards.size() > 0 else -1
	session_path = file_path
	SessionManager._current_board_index = 0
	UndoRedoManager.undo_redo.clear_history()
	UndoRedoManager.save_version = UndoRedoManager.undo_redo.get_version()
	Settings.last_opened_session = file_path
	save_file_loaded.emit()


func _add_board_undo_redo(at_index: int = -1, board: Board = Board.new()) -> void:
	var old_index: int = _current_board_index

	if at_index == -1 or _current_board_index == -1:
		boards.append(board)
		_current_board_index = boards.size() - 1
	else:
		boards.insert(min(at_index, boards.size()), board)
		_current_board_index = at_index

	board_added.emit(_current_board_index, old_index)


func _remove_current_board_undo_redo() -> void:
	var old_board_index: int = _current_board_index
	boards.remove_at(_current_board_index)
	
	if boards.is_empty():
		_current_board_index = -1
	else:
		_current_board_index = min(_current_board_index, boards.size() - 1)
	board_removed.emit(old_board_index)


func _move_board_undo_redo(board: Board, to_index: int) -> void:
	board_order_edit_queued.emit()
	var board_index: int = boards.find(board)
	var moved_board: Board = boards.pop_at(board_index)
	if to_index >= boards.size():
		boards.append(moved_board)
		to_index = boards.size() - 1
	else:
		boards.insert(to_index, moved_board)
	_current_board_index = to_index
	board_moved.emit(_current_board_index, board_index)


func _on_session_name_undo_redo() -> void:
	session_name_changed.emit(_session_name)

