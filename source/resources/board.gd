class_name Board 
extends Resource


@export var board_title: String = "New board"
@export var board_notes: String = ""
@export var initial_board_info: BoardInfo = BoardInfo.new()
@export var solution_board_info: BoardInfo = BoardInfo.new()
@export var alternate_solution_board_info: BoardInfo = BoardInfo.new()


func get_as_dictionary() -> Dictionary:
	return {
		"title": board_title,
		"notes": board_notes,
		"initial_board_info": initial_board_info.to_dictionary(),
		"solution_board_info": solution_board_info.to_dictionary(),
		"alternate_solution_board_info": alternate_solution_board_info.to_dictionary()
	}


func set_from_dictionary(dict: Dictionary) -> bool:
	if not dict.has_all(["title", "notes", "initial_board_info", "solution_board_info", 
			"alternate_solution_board_info"]):
		return false

	board_title = dict["title"]
	board_notes = dict["notes"]
	initial_board_info.from_dictionary(dict["initial_board_info"])
	solution_board_info.from_dictionary(dict["solution_board_info"])
	alternate_solution_board_info.from_dictionary(dict["alternate_solution_board_info"])

	return true
