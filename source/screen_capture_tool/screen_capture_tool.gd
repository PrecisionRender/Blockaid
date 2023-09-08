class_name ScreenCaptureTool
extends Control


signal screen_captured(result_image: Image)
signal screen_capture_canceled


const SCREEN_TEXTURE_BRIGHTNESS: float = 0.5


var is_capturing: bool = false
var capture_rect: Rect2i = Rect2i()


@onready var screen_texture: TextureRect = $ScreenTexture
@onready var selection_hint: Control = $SelectionHint


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


func _input(event) -> void:
	if event.is_action("ui_cancel"):
		hide()
		get_window().borderless = false
		screen_capture_canceled.emit()


func start_screen_capture(screen_index: int) -> void:
	show()
	is_capturing = false
	capture_rect = Rect2i()

	var window: Window = get_window()
	window.borderless = true
	window.mode = Window.MODE_MINIMIZED
	var image = DisplayServer.screen_get_image(screen_index)
	window.mode = Window.MODE_MAXIMIZED
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	screen_texture.texture = image_texture
	
	screen_texture.modulate = Color.WHITE
	var tween: Tween = get_tree().create_tween()
	var new_color = screen_texture.modulate.darkened(SCREEN_TEXTURE_BRIGHTNESS)
	tween.tween_property(screen_texture, "modulate", new_color, 0.25)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.play()

	selection_hint.grab_focus()


func _capture_screen() -> void:
	hide()
	get_window().borderless = false
	screen_captured.emit(screen_texture.texture.get_image().get_region(capture_rect.abs()))


func _on_selection_hint_draw() -> void:
	selection_hint.draw_texture_rect_region(screen_texture.texture, capture_rect.abs(), capture_rect.abs())
	selection_hint.draw_rect(capture_rect.abs(), Color.WHITE, false, 1)


func _on_selection_hint_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_capturing = true
			capture_rect.position = Vector2i(get_viewport().get_mouse_position())
		elif event.is_released() and is_capturing:
			_capture_screen()
	elif event is InputEventMouseMotion and is_capturing:
		capture_rect.size = Vector2i(get_viewport().get_mouse_position()) - capture_rect.position
		selection_hint.queue_redraw()
