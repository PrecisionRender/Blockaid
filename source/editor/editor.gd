class_name Editor
extends PanelContainer


signal screen_capture_requested


enum BoardState
{
	INITIAL,
	SOLUTION,
	ALTERNATE_SOLUTION,
}


const QUEUE_INPUT_DIALOGUE: PackedScene = preload("res://source/editor/queue_input_dialogue.tscn")


var current_board_state: BoardState = BoardState.INITIAL
var initial_board_info: BoardInfo = BoardInfo.new()
var solution_board_info: BoardInfo = BoardInfo.new()
var alternate_solution_board_info: BoardInfo = BoardInfo.new()


@onready var board_manager: BoardManager = $HBoxContainer/BoardManager
@onready var game_board: GameBoard = $HBoxContainer/BoardContainer/GameBoard
@onready var edit_panel: EditPanel = $HBoxContainer/EditPanel
@onready var side_margin: Control = $HBoxContainer/SideMargin


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SessionManager.current_board_changed.connect(_on_current_board_changed)
	SessionManager.board_added.connect(_on_board_added)
	SessionManager.board_removed.connect(_on_board_removed)
	SessionManager.board_order_edit_queued.connect(_save_current_board_state)
	SessionManager.board_save_queued.connect(_save_current_board_state)
	SessionManager.save_file_loaded.connect(_on_save_file_loaded)

	edit_panel.screen_capture_requested.connect(_on_editor_screen_capture_requested)
	edit_panel.brush_changed.connect(_on_brush_changed)
	edit_panel.board_clear_requested.connect(_on_board_clear_requested)
	edit_panel.mino_queue_edit_requested.connect(_on_mino_queue_edit_requested)
	edit_panel.board_state_change_requested.connect(_on_board_state_change_requested)
	edit_panel.board_notes_changed.connect(_on_board_notes_changed)

	if (SessionManager.get_current_board_index() == -1):
		side_margin.show()
		$HBoxContainer/BoardContainer.hide()
		$HBoxContainer/EditPanel.hide()
	_update_game_board(current_board_state)


func convert_image_to_board(image: Image) -> void:
	game_board.convert_image_to_board(image)


func _update_game_board(state: BoardState) -> void:
	current_board_state = state

	match current_board_state:
		BoardState.INITIAL:
			game_board.load_board(initial_board_info)
		BoardState.SOLUTION:
			game_board.load_board(solution_board_info)
		BoardState.ALTERNATE_SOLUTION:
			game_board.load_board(alternate_solution_board_info)
		_:
			pass


func _on_board_added(index: int, old_index: int) -> void:
	_save_current_board_state(old_index)
	_load_new_board()


func _on_current_board_changed(index: int, old_index: int) -> void:
	_update_editor_visibility()

	# Empty board list, return
	if (index == -1):
		return

	_save_current_board_state(old_index)
	_load_new_board()


func _on_board_removed(index: int) -> void:
	_update_editor_visibility()
	if SessionManager.get_current_board_index() == -1:
		return
	_load_new_board()


func _on_save_file_loaded() -> void:
	_update_editor_visibility()
	if not SessionManager._current_board_index == -1:
		_load_new_board()


func _update_editor_visibility() -> void:
	var index: int = SessionManager.get_current_board_index()
	side_margin.visible = index == -1
	$HBoxContainer/BoardContainer.visible = not index == -1
	$HBoxContainer/EditPanel.visible = not index == -1


func _save_current_board_state(board_idx: int = -1) -> void:
	if (SessionManager.get_current_board_index() == -1):
		return

	var board_to_save: int = board_idx if board_idx >= 0 else SessionManager.get_current_board_index()

	match current_board_state:
		BoardState.INITIAL:
			game_board.save_board(initial_board_info)
			SessionManager.boards[board_to_save].initial_board_info = initial_board_info
		BoardState.SOLUTION:
			game_board.save_board(solution_board_info)
			SessionManager.boards[board_to_save].solution_board_info = solution_board_info
		BoardState.ALTERNATE_SOLUTION:
			game_board.save_board(alternate_solution_board_info)
			SessionManager.boards[board_to_save].alternate_solution_board_info = alternate_solution_board_info
		_:
			pass


func _load_new_board() -> void:
	var current_board: SessionManager.Board = SessionManager.get_current_board()
	initial_board_info = current_board.initial_board_info
	solution_board_info = current_board.solution_board_info
	alternate_solution_board_info = current_board.alternate_solution_board_info
	_update_game_board(current_board_state)
	edit_panel.update_board_notes(SessionManager.get_current_board().board_notes)


func _on_mino_queue_edit_requested(queue_type: Constants.MinoQueues) -> void:
	var input_dialogue = QUEUE_INPUT_DIALOGUE.instantiate()
	add_child(input_dialogue)
	input_dialogue.queue_type = queue_type
	input_dialogue.queue_sumbitted.connect(_on_queue_input_dialogue_queue_sumbitted)


func _on_editor_screen_capture_requested() -> void:
	screen_capture_requested.emit()


func _on_brush_changed(type: Constants.Minos) -> void:
	get_tree().call_group("grid_cells", "change_brush", type)


func _on_board_clear_requested() -> void:
	game_board.clear_board()


func _on_queue_input_dialogue_queue_sumbitted(queue: Constants.MinoQueues, types: String) -> void:
	var mino_queue: Array[Constants.Minos] = []
	for letter in types:
		match letter:
			"z":
				mino_queue.append(Constants.Minos.Z)
			"l":
				mino_queue.append(Constants.Minos.L)
			"o":
				mino_queue.append(Constants.Minos.O)
			"s":
				mino_queue.append(Constants.Minos.S)
			"i":
				mino_queue.append(Constants.Minos.I)
			"j":
				mino_queue.append(Constants.Minos.J)
			"t":
				mino_queue.append(Constants.Minos.T)
	game_board.update_mino_queue(queue, mino_queue)


func _on_board_state_change_requested(state: int) -> void:
	if state == current_board_state:
		return

	_save_current_board_state()
	_update_game_board(state)


func _on_board_notes_changed(new_text: String) -> void:
	SessionManager.get_current_board().board_notes = new_text
