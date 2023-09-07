class_name MinoQueue
extends PanelContainer


const QUEUE_MINO: PackedScene = preload("res://src/game_board/mino/queue_mino.tscn")


@export var queue_size: int = 1
@export var queue_parent: NodePath


var queue_minos: Array[QueueMino]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in range(queue_size):
		var queue_mino = QUEUE_MINO.instantiate()
		queue_minos.append(queue_mino)
		queue_mino.type = x if queue_size == 1 else x + 1
		$HBoxContainer/MinoContainer.add_child(queue_mino)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
