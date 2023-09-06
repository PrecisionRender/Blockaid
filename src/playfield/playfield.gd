class_name Playfield
extends AspectRatioContainer


const GRID_CELL: PackedScene = preload("res://src/playfield/grid_cell.tscn")

const PLAYFIELD_WIDTH: int = 10
const PLAYFIELD_HEIGHT: int = 22


var grid_cells: Array[GridCell] = []

@onready var grid: GridContainer = $GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_grid()


func _initialize_grid() -> void:
	for x in range(PLAYFIELD_WIDTH * PLAYFIELD_HEIGHT):
		var grid_cell: GridCell = GRID_CELL.instantiate()
		grid_cell.id = x
		if x < PLAYFIELD_WIDTH * 2:
			grid_cell.hide_when_empty = true
		grid.add_child(grid_cell)
		grid_cells.append(grid_cell)
