class_name OptionsWindow
extends Control


@export_category("Startup")
@export var startup_button: OptionButton
@export_category("Skin")
@export var skin_name_label: Label
@export var choose_skin_button: Button
@export_category("Licenses")
@export var third_party_license_text: RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Settings.settings_loaded.connect(_on_settings_loaded)
	Settings.startup_behavior_changed.connect(_on_startup_behavior_changed)
	Settings.skin_changed.connect(_on_skin_changed)

	_update_skin_name_label()
	startup_button.selected = Settings.startup_behavior

	third_party_license_text.push_mono()
	var licenses: Array = []

	licenses.append(Engine.get_license_text())
	licenses.append_array(Engine.get_license_info().values())
	for license in licenses:
		third_party_license_text.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
		third_party_license_text.append_text(license)
		third_party_license_text.pop()
		third_party_license_text.newline()
		third_party_license_text.newline()
		third_party_license_text.newline()


func _update_skin_name_label() -> void:
	var skin_name: String = Settings.custom_skin_path.get_file()
	if skin_name.is_empty():
		skin_name_label.text = "None (default)"
		choose_skin_button.text = "Choose skin"
	else:
		skin_name_label.text = skin_name
		choose_skin_button.text = "Remove skin"


func _on_settings_loaded() -> void:
	startup_button.selected = Settings.startup_behavior
	_update_skin_name_label()


func _on_startup_behavior_changed(new_behavior: Settings.StartupBehavior) -> void:
	if startup_button.selected == new_behavior:
		return
	startup_button.selected = new_behavior


func _on_skin_changed(_skin: Image) -> void:
	_update_skin_name_label()


func _on_close_button_pressed() -> void:
	hide()


func _on_color_rect_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT 
			and event.is_pressed()):
		hide()


@warning_ignore("int_as_enum_without_cast")
func _on_startup_button_item_selected(index: int) -> void:
	Settings.startup_behavior = index


func _on_choose_skin_button_pressed() -> void:
	if not Settings.custom_skin_path.is_empty():
		Settings.custom_skin_path = ""
		return

	var file_extensions: Array[String] = [ "*.png,*.jpg,*.jpeg,*.bmp;All Supported files",
			"*.png;PNG", "*.jpg,*.jpeg;JPEG", "*.bmp;BMP"]
	var current_directory: String = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	if Settings.is_valid_path(Settings.last_skin_directory):
		current_directory = Settings.last_skin_directory
	DisplayServer.file_dialog_show("Select skin", current_directory, "", 
			false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, file_extensions, 
			_on_open_dialogue_confirmed)


func _on_open_dialogue_confirmed(status: bool, selected_paths: PackedStringArray, 
		_selected_filter_index: int) -> void: 
	if not status:
		return
	Settings.custom_skin_path = selected_paths[0]
	Settings.last_skin_directory = selected_paths[0].get_base_dir()
