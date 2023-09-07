class_name Editor
extends Control


signal screen_capture_requested


enum EditorState
{
	VIEW,
	EDIT
}


const QUEUE_INPUT_DIALOGUE: PackedScene = preload("res://source/editor/queue_input_dialogue.tscn")


@onready var game_board: GameBoard = $HBoxContainer/BoardContainer/HBoxContainer/GameBoard
@onready var edit_panel: EditPanel = $HBoxContainer/EditPanel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	edit_panel.screen_capture_requested.connect(_on_editor_screen_capture_requested)
	edit_panel.brush_changed.connect(_on_brush_changed)
	edit_panel.mino_queue_edit_requested.connect(_on_mino_queue_edit_requested)


func _on_mino_queue_edit_requested(queue_type: Constants.MinoQueues):
	var input_dialogue = QUEUE_INPUT_DIALOGUE.instantiate()
	add_child(input_dialogue)
	input_dialogue.queue_type = queue_type
	input_dialogue.queue_sumbitted.connect(_on_queue_input_dialogue_queue_sumbitted)


func _on_brush_changed(type: Constants.Minos):
	get_tree().call_group("grid_cells", "change_brush", type)


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


func _on_editor_screen_capture_requested() -> void:
	screen_capture_requested.emit()
