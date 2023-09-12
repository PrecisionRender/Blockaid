class_name MinoQueue
extends PanelContainer


const QUEUE_MINO: PackedScene = preload("res://source/game_board/mino/queue_mino.tscn")


@export var queue_size: int = 1
@export var queue_parent: NodePath


var queue_minos: Array[QueueMino]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in range(queue_size):
		var queue_mino = QUEUE_MINO.instantiate()
		queue_minos.append(queue_mino)
		# Initialize the defualt queues to hold one of each mino
		queue_mino.type = x if queue_size == 1 else x + 1
		$HBoxContainer/MinoContainer.add_child(queue_mino)


func update_mino_queue(types: Array) -> void:
	assert(types.size() == queue_size, "Incorrect quantity of mino types supplied!")
	for x in range(queue_size):
		queue_minos[x].type = types[x]
