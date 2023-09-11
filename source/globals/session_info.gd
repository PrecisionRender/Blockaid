extends Node


signal session_name_changed(new_name: String)
signal current_board_changed(current_board: int, old_board: int)
signal board_order_edit_queued


var session_name: String = "Untitled":
	set(value):
		session_name = value
		session_name_changed.emit(value)
var boards: Array[Board]
var _current_board_index: int = -1


func get_current_board_index() -> int:
	return _current_board_index


func set_current_board_index(new_index: int) -> void:
	var old_board = _current_board_index
	_current_board_index = new_index
	current_board_changed.emit(new_index, old_board)


func create_new_board() -> void:
	boards.append(Board.new())
	set_current_board_index(boards.size() - 1)
	if _current_board_index == -1:
		set_current_board_index(0)


func get_current_board() -> Board:
	if _current_board_index < 0:
		return null
	return boards[_current_board_index]


func move_current_board_to(to_idx: int) -> void:
	board_order_edit_queued.emit()
	var moved_board: Board = boards.pop_at(_current_board_index)
	boards.insert(to_idx, moved_board)
	_current_board_index = to_idx


class Board:
	var board_title: String = "New board"
	var board_notes: String = ""
	var initial_board_info: BoardInfo = BoardInfo.new()
	var solution_board_info: BoardInfo = BoardInfo.new()
	var alternate_solution_board_info: BoardInfo = BoardInfo.new()
