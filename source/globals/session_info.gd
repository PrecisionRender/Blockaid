extends Node


signal session_name_changed(new_name: String)
signal current_board_changed(current_board: int, old_board: int)


var session_name: String = "Untitled":
	set(value):
		session_name = value
		session_name_changed.emit(value)
var boards: Array[Board]
var current_board: int = -1:
	set(value):
		var old_board = current_board
		current_board = value
		current_board_changed.emit(value, old_board)


func create_new_board() -> void:
	boards.append(Board.new())
	if current_board == -1:
		current_board = 0


class Board:
	var board_title: String = "New board"
	var initial_board_info: BoardInfo = BoardInfo.new()
	var solution_board_info: BoardInfo = BoardInfo.new()
	var alternate_solution_board_info: BoardInfo = BoardInfo.new()
