class_name BoardInfo 
extends Resource


@export var hold_queue: Constants.Minos = Constants.Minos.Z
@export var next_queue: Array = [
	Constants.Minos.L,
	Constants.Minos.O,
	Constants.Minos.S,
	Constants.Minos.I,
	Constants.Minos.J,
	Constants.Minos.T,
]
@export var board: Array[Array]


func _init() -> void:
	for x in range(GameBoard.PLAYFIELD_WIDTH):
		board.append([])
		for y in range(GameBoard.PLAYFIELD_HEIGHT):
			board[x].append(Constants.Minos.EMPTY)


func to_dictionary() -> Dictionary:
	var dict: Dictionary = {
		"hold_queue": hold_queue,
		"next_queue": next_queue,
		"board": []
	}

	for x in range(board.size()):
		dict["board"].append([])
		for y in range(board[x].size()):
			dict["board"][x].append(board[x][y])

	return dict


func from_dictionary(dictionary: Dictionary) -> void:
	if not dictionary.has_all(["hold_queue", "next_queue", "board"]):
		return

	hold_queue = dictionary["hold_queue"]
	next_queue = dictionary["next_queue"]

	board = []
	for x in range(dictionary["board"].size()):
		board.append([])
		for y in range(dictionary["board"][x].size()):
			board[x].append(dictionary["board"][x][y])
