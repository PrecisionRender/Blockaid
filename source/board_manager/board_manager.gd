class_name BoardManager
extends PanelContainer


@onready var session_title_label: Label = $MarginContainer/VBoxContainer/SessionTitleLabel
@onready var session_title_edit: LineEdit = $MarginContainer/VBoxContainer/SessionTitleEdit
@onready var board_tree: Tree = $MarginContainer/VBoxContainer/BoardTree


func _ready() -> void:
	session_title_label.text = SessionInfo.session_name
	var root = board_tree.create_item()
	root.set_editable(0, false)
	root.set_text(0, "Root")


func _update_session_title() -> void:
	session_title_edit.hide()
	session_title_label.show()
	session_title_label.text = session_title_edit.text
	SessionInfo.session_name = session_title_edit.text


func _on_board_tree_item_selected() -> void:
	if SessionInfo.boards.size() - 1 < board_tree.get_selected().get_index():
		return
	SessionInfo.current_board = board_tree.get_selected().get_index()


func _on_tree_item_activated() -> void:
	board_tree.edit_selected(true)


func _on_tree_item_edited() -> void:
	board_tree.get_edited().set_editable(0, false)


func _on_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.double_click == true:
		session_title_label.hide()
		session_title_edit.show()
		session_title_edit.text = session_title_label.text
		session_title_edit.grab_focus()
		session_title_edit.select_all()


func _on_line_edit_text_submitted(_new_text: String) -> void:
	_update_session_title()


func _on_line_edit_focus_exited() -> void:
	_update_session_title()


func _on_new_board_button_pressed() -> void:
	var item = board_tree.create_item(null, board_tree.get_root().get_child_count())
	item.set_editable(0, false)
	item.set_text(0, "New board")
	board_tree.set_selected(item, 0)
	SessionInfo.create_new_board()
