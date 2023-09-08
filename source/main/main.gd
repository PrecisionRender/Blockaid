class_name Main
extends Node


enum WindowStates
{
	EDITOR,
	CAPTURE
}


var window_position: Vector2 = Vector2(0, 0)
var window_size: Vector2 = Vector2(1366, 768)
var window_mode: int = Window.MODE_WINDOWED

var current_window_state: WindowStates = WindowStates.EDITOR
var screen_texture: ImageTexture


@onready var editor: Editor = $Editor
@onready var screen_capture_tool: ScreenCaptureTool = $ScreenCaptureTool


func _ready() -> void:
	get_window().set_min_size(Vector2(960, 576))
	editor.screen_capture_requested.connect(_on_screen_capture_requested)
	screen_capture_tool.screen_captured.connect(_on_screen_capture_tool_screen_captured)
	screen_capture_tool.screen_capture_canceled.connect(_on_screen_capture_tool_screen_capture_canceled)


func _process(delta: float) -> void:
	return
	$Control.queue_redraw()


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


func _on_screen_capture_requested() -> void:
	save_window_state()
	editor.hide()
	screen_capture_tool.start_screen_capture(get_window().current_screen)


func _on_screen_capture_tool_screen_captured(result_image: Image) -> void:
	restore_window_state()
	editor.show()
	editor.convert_image_to_board(result_image)

func _on_screen_capture_tool_screen_capture_canceled():
	restore_window_state()
	editor.show()
