class_name GameBoard
extends AspectRatioContainer


signal board_edited


const GRID_CELL: PackedScene = preload("res://source/game_board/mino/grid_cell.tscn")

const PLAYFIELD_WIDTH: int = 10
const PLAYFIELD_HEIGHT: int = 22


var grid_cells: Array[Array] = []
var _is_editable: bool = false


@onready var playfield_grid: GridContainer = $HBoxContainer/Playfield/PlayfieldGrid
@onready var hold_queue: MinoQueue = $HBoxContainer/HBoxContainer/VBoxContainer/AspectRatioContainer/HoldQueue
@onready var next_queue: MinoQueue = $HBoxContainer/VBoxContainer/AspectRatioContainer/NextQueue


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_grid()


func _on_playfield_grid_gui_input(event: InputEvent) -> void:
	if not _is_editable:
		return
	if (event is InputEventMouseButton and event.is_released() and
			(event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT)):
				board_edited.emit()


func set_editable(is_editable: bool) -> void:
	_is_editable = is_editable


func clear_board() -> void:
	for x in range(grid_cells.size()):
		for cell in grid_cells[x]:
			cell.update_cell_type(Constants.Minos.EMPTY)


func save_board(board: BoardInfo) -> void:
	board.hold_queue = hold_queue.queue_minos[0].type
	for x in range(next_queue.queue_minos.size()):
		board.next_queue[x] = next_queue.queue_minos[x].type
	
	board.board = []
	for x in range(grid_cells.size()):
		board.board.append([])
		for y in grid_cells[x].size():
			board.board[x].append(grid_cells[x][y].type)


func load_board(board: BoardInfo) -> void:
	hold_queue.update_mino_queue([board.hold_queue])
	next_queue.update_mino_queue(board.next_queue)
	
	if grid_cells.is_empty():
		_initialize_grid()
	for x in range(board.board.size()):
		for y in range(board.board[x].size()):
			grid_cells[x][y].update_cell_type(board.board[x][y])


func convert_image_to_board(image: Image) -> void:
	var aspect_ratio: float = float(image.get_height()) / float(image.get_width())
	aspect_ratio *= 10
	aspect_ratio = round(aspect_ratio)
	aspect_ratio /= 10
	var height: float = min(PLAYFIELD_WIDTH * aspect_ratio, PLAYFIELD_HEIGHT)
	image.resize(PLAYFIELD_WIDTH, height, Image.INTERPOLATE_LANCZOS)

	clear_board()

	for y in range(height):
		for x in range(PLAYFIELD_WIDTH):
			var current_cell: GridCell = grid_cells[x][(PLAYFIELD_HEIGHT - 1) - y]
			var current_pixel: Color = image.get_pixel(x, (height - 1) - y)

			# Dark pixel, most likely empty
			if current_pixel.v < 0.25:
				current_cell.update_cell_type(Constants.Minos.EMPTY)
			# Gray pixel, most likely garbage
			elif current_pixel.s < 0.3:
				current_cell.update_cell_type(Constants.Minos.GARBAGE)
			else:
				var hue: float = current_pixel.h
				# Red
				if hue < 0.03 or hue > 0.9192:
					current_cell.update_cell_type(Constants.Minos.Z)
				#Orange
				elif hue < 0.1114:
					current_cell.update_cell_type(Constants.Minos.L)
				# Yellow
				elif hue < 0.1810:
					current_cell.update_cell_type(Constants.Minos.O)
				# Green
				elif hue < 0.4122:
					current_cell.update_cell_type(Constants.Minos.S)
				# Light blue
				elif hue < 0.5766:
					current_cell.update_cell_type(Constants.Minos.I)
				# Dark blue
				elif hue < 0.7715:
					current_cell.update_cell_type(Constants.Minos.J)
				# Purple
				elif hue < 0.9192:
					current_cell.update_cell_type(Constants.Minos.T)
				# Most likely garbage
				else:
					current_cell.update_cell_type(Constants.Minos.GARBAGE)


func update_mino_queue(queue: Constants.MinoQueues, types: Array[Constants.Minos]) -> void:
	match queue:
		Constants.MinoQueues.HOLD:
			hold_queue.update_mino_queue(types)
			board_edited.emit()
		Constants.MinoQueues.NEXT:
			next_queue.update_mino_queue(types)
			board_edited.emit()
		_:
			pass


func _initialize_grid() -> void:
	grid_cells = []
	for y in range(PLAYFIELD_HEIGHT):
		for x in range(PLAYFIELD_WIDTH):
			var grid_cell: GridCell = GRID_CELL.instantiate()
			grid_cell.id = x * 10 + y
			grid_cell.cell_updated.connect(_on_cell_updated)
			# Hide the top 2 rows of the grid
			if y < PLAYFIELD_HEIGHT - 20:
				grid_cell.hide_when_empty = true
			
			playfield_grid.add_child(grid_cell)
			if grid_cells.size() < x + 1:
				grid_cells.append([])
			grid_cells[x].append(grid_cell)


func _on_cell_updated(id: int, type: Constants.Minos) -> void:
	pass
