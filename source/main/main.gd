class_name Main
extends Node


var window_position: Vector2 = Vector2(0, 0)
var window_size: Vector2 = Vector2(1366, 768)
var window_mode: Window.Mode = Window.MODE_WINDOWED

var screen_texture: ImageTexture


@onready var editor: Editor = $Editor
@onready var screen_capture_tool: ScreenCaptureTool = $ScreenCaptureTool
@onready var options_window: OptionsWindow = $OptionsWindow 


func _ready() -> void:
	get_window().files_dropped.connect(_on_files_dropped)
	SessionManager.session_name_changed.connect(_on_session_name_changed)
	UndoRedoManager.saved_state_changed.connect(_update_window_title)
	editor.screen_capture_requested.connect(_on_screen_capture_requested)
	editor.open_options_requested.connect(_on_open_options_requested)
	screen_capture_tool.screen_captured.connect(_on_screen_captured)
	screen_capture_tool.screen_capture_canceled.connect(_on_screen_capture_canceled)

	get_window().set_min_size(Vector2(960, 576))
	_update_window_title()

	if OS.has_feature("editor"):
		return

	var args: PackedStringArray = OS.get_cmdline_args()
	for arg in args:
		if not arg.is_absolute_path():
			continue
		if not arg.get_extension() == Constants.FILE_EXTENSION.trim_prefix("."):
			OS.alert("Blockaid can't open files with extension .%s" % arg.get_extension())
			continue
		SessionManager.load_from_file(arg)
		break


func save_window_state() -> void:
	var window: Window = get_window()
	window_position = window.position
	window_size = window.size
	window_mode = window.mode


func restore_window_state() -> void:
	var window: Window = get_window()
	window.mode = window_mode
	if window_mode == window.MODE_MAXIMIZED:
		return
	window.position = window_position
	window.size = window_size


func _on_files_dropped(files: PackedStringArray) -> void:
	if files.size() > 1:
		OS.alert("Blockaid doesn't support opening multiple files at once.")
		return

	if not files[0].get_extension() == "bbs":
		OS.alert("Blockaid doesn't support file type .%s" % files[0].get_extension())
		return

	SessionManager.load_from_file(files[0])


func _update_window_title() -> void:
	var is_saved: bool = UndoRedoManager.save_version == UndoRedoManager.undo_redo.get_version()
	var title: String = "Blockaid - %s" % SessionManager.get_session_name()
	if not is_saved:
		title += "*"
	get_window().title = title


func _on_session_name_changed(_new_name: String) -> void:
	_update_window_title()


func _on_screen_capture_requested() -> void:
	save_window_state()
	editor.hide()
	screen_capture_tool.start_screen_capture(get_window().current_screen)


func _on_screen_captured(result_image: Image) -> void:
	restore_window_state()
	editor.show()
	editor.convert_image_to_board(result_image)


func _on_screen_capture_canceled() -> void:
	restore_window_state()
	editor.show()


func _on_open_options_requested() -> void:
	options_window.show()
