class_name GameBoard
extends AspectRatioContainer

const GRID_CELL: PackedScene = preload("res://source/playfield/grid_cell.tscn")

const PLAYFIELD_WIDTH: int = 10
const PLAYFIELD_HEIGHT: int = 22


var grid_cells: Array[GridCell] = []


@onready var playfield_grid: GridContainer = $HBoxContainer/Playfield/PlayfieldGrid
@onready var hold_queue: MinoQueue = $HBoxContainer/HBoxContainer/VBoxContainer/AspectRatioContainer/HoldQueue
@onready var next_queue: MinoQueue = $HBoxContainer/VBoxContainer/AspectRatioContainer/NextQueue


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_grid()


func save_board(board: BoardState) -> void:
	for x in range(grid_cells.size()):
		board.board[x] = grid_cells[x].type


func load_board(board: BoardState) -> void:
	for x in range(grid_cells.size()):
		grid_cells[x].type = board.board[x]


func update_mino_queue(queue: Constants.MinoQueues, types: Array[Constants.Minos]) -> void:
	match queue:
		Constants.MinoQueues.HOLD:
			hold_queue.update_mino_queue(types)
		Constants.MinoQueues.NEXT:
			next_queue.update_mino_queue(types)
		_:
			pass


func _initialize_grid() -> void:
	for x in range(PLAYFIELD_WIDTH * PLAYFIELD_HEIGHT):
		var grid_cell: GridCell = GRID_CELL.instantiate()
		grid_cell.id = x
		grid_cell.cell_updated.connect(_on_cell_updated)
		# Hide the top 2 rows of the grid
		if x < PLAYFIELD_WIDTH * 2:
			grid_cell.hide_when_empty = true
		
		playfield_grid.add_child(grid_cell)
		grid_cells.append(grid_cell)


func _on_cell_updated(id: int, type: Constants.Minos) -> void:
	pass
