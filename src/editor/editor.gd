class_name Editor
extends Control


enum EditorState
{
	VIEW,
	EDIT
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$HBoxContainer/EditPanel.brush_changed.connect(_on_brush_changed)


func _on_brush_changed(type: Constants.Minos):
	get_tree().call_group("grid_cells", "change_brush", type)
