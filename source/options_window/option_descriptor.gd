@tool
class_name OptionDescriptor
extends VBoxContainer


@export var option_title: String = "Option Title":
	set(value):
		option_title = value
		if title_label == null:
			return
		title_label.text = option_title
@export var option_description: String = "Option description.":
	set(value):
		option_description = value
		if description_label == null:
			return
		description_label.text = option_description


@onready var title_label: Label = $Title
@onready var description_label: Label = $Description


func _ready() -> void:
	title_label.text = option_title
	description_label.text = option_description
