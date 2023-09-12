extends Node


signal session_name_changed(new_name: String)
signal current_board_changed(current_board: int, old_board: int)
signal board_order_edit_queued
signal board_save_queued
signal save_file_loaded


var session_path: String = ""
var boards: Array[Board]
var _session_name: String = "Untitled"
var _current_board_index: int = -1


func get_session_name() -> String:
	return _session_name


func set_session_name(new_name: String) -> void:
	if new_name == _session_name:
		return
	UndoRedoManager.undo_redo.create_action("Renmae session")
	UndoRedoManager.undo_redo.add_do_property(self, "_session_name", new_name)
	UndoRedoManager.undo_redo.add_undo_property(self, "_session_name", self._session_name)
	UndoRedoManager.undo_redo.add_do_method(_on_session_name_undo_redo)
	UndoRedoManager.undo_redo.add_undo_method(_on_session_name_undo_redo)
	UndoRedoManager.undo_redo.commit_action()
	_session_name = new_name
	session_name_changed.emit(_session_name)


func get_current_board_index() -> int:
	return _current_board_index


func set_current_board_index(new_index: int) -> void:
	var old_board = _current_board_index
	_current_board_index = new_index
	current_board_changed.emit(new_index, old_board)


func create_new_board(at_index: int = -1) -> void:
	if at_index == -1 or _current_board_index == -1:
		boards.append(Board.new())
		set_current_board_index(boards.size() - 1)
	else:
		boards.insert(at_index, Board.new())
		set_current_board_index(at_index)


func get_current_board() -> Board:
	if _current_board_index < 0:
		return null
	return boards[_current_board_index]


func move_current_board_to(to_idx: int) -> void:
	board_order_edit_queued.emit()
	var moved_board: Board = boards.pop_at(_current_board_index)
	boards.insert(to_idx, moved_board)
	_current_board_index = to_idx


func save_to_file(file_path: String) -> void:
	if !file_path.is_absolute_path():
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
	
	save_file.store_line(JSON.stringify(save_data, "\t", false))
	session_path = file_path


func load_from_file(file_path: String) -> void:
	if !FileAccess.file_exists(file_path):
		printerr("File path %s does not exist." % file_path)
		return

	var save_file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	var json = JSON.new()
	var error: Error = json.parse(save_file.get_as_text())
	if not error == OK:
		printerr("Could not load file at %s" % file_path)
		return

	var save_data: Dictionary = json.data
	set_session_name(save_data["session_name"])
	boards = []
	for x in range(save_data["boards"].size()):
		var board: Board = Board.new()
		board.board_title = save_data["boards"][x]["title"]
		board.board_notes = save_data["boards"][x]["notes"]
		board.initial_board_info.from_dictionary(save_data["boards"][x]["initial_board_info"])
		board.solution_board_info.from_dictionary(save_data["boards"][x]["solution_board_info"])
		board.alternate_solution_board_info.from_dictionary(save_data["boards"][x]["alternate_solution_board_info"])
		boards.append(board)

	set_current_board_index(0 if boards.size() > 0 else -1)
	session_path = file_path
	save_file_loaded.emit()


func _on_session_name_undo_redo() -> void:
	session_name_changed.emit(_session_name)


class Board:
	var board_title: String = "New board"
	var board_notes: String = ""
	var initial_board_info: BoardInfo = BoardInfo.new()
	var solution_board_info: BoardInfo = BoardInfo.new()
	var alternate_solution_board_info: BoardInfo = BoardInfo.new()
