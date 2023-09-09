class_name BoardInfo
extends Resource


@export var hold_queue: Constants.Minos = Constants.Minos.Z
@export var next_queue: Array[Constants.Minos] = [
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
