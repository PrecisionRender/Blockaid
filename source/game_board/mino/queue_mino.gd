class_name QueueMino
extends AspectRatioContainer


const MINO: PackedScene = preload("res://source/game_board/mino/mino.tscn")

var type: Constants.Minos = Constants.Minos.Z:
	set(value):
		type = value
		_refresh_cells()
var mino_states: Dictionary = {
	Constants.Minos.Z: QueueMinoState.new(3, [1, 1, 0, 0, 1, 1]),
	Constants.Minos.L: QueueMinoState.new(3, [0, 0, 1, 1, 1, 1]),
	Constants.Minos.O: QueueMinoState.new(2, [1, 1, 1, 1]),
	Constants.Minos.S: QueueMinoState.new(3, [0, 1, 1, 1, 1, 0]),
	Constants.Minos.I: QueueMinoState.new(4, [1, 1, 1, 1]),
	Constants.Minos.J: QueueMinoState.new(3, [1, 0, 0, 1, 1, 1]),
	Constants.Minos.T: QueueMinoState.new(3, [0, 1, 0, 1, 1, 1])
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_refresh_cells()


func _refresh_cells() -> void:
	for child in $AspectRatioContainer/GridContainer.get_children():
		child.queue_free()

	var mino_state: QueueMinoState = mino_states[type]
	var cell_count: int = mino_state.active_cells.size()

	$AspectRatioContainer/GridContainer.columns = mino_state.grid_columns
	$AspectRatioContainer.ratio = float(mino_state.grid_columns) / float(cell_count / mino_state.grid_columns)

	for x in range(cell_count):
		var cell: Mino = MINO.instantiate()
		$AspectRatioContainer/GridContainer.add_child(cell)
		if mino_state.active_cells[x] == 0:
			cell.hide_when_empty = true
			cell.type = Constants.Minos.EMPTY
		else:
			cell.type = type


class QueueMinoState:
	var grid_rows: int = 1
	var grid_columns: int = 4
	var active_cells: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0]
	
	func _init(grid_columns: int, active_cells: Array[int]) -> void:
		self.grid_columns = grid_columns
		self.active_cells = active_cells
