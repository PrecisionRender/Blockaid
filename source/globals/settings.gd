extends Node


signal settings_loaded
signal startup_behavior_changed(new_behavior: StartupBehavior)
signal skin_changed(skin: Image)


enum StartupBehavior
{
	NEW_SESSION,
	LOAD_LAST_SESSION,
}


var startup_behavior: StartupBehavior = StartupBehavior.NEW_SESSION:
	set(value):
		if value == startup_behavior:
			return
		startup_behavior = value
		startup_behavior_changed.emit(startup_behavior)
		if _is_dirty:
			return
		_save_settings()
var default_skin: Image = preload("res://assets/images/skin.png")
var skin: Image = default_skin:
	set(value):
		if skin == value:
			return
		if value == null:
			skin = default_skin
		else:
			skin = value
		skin_changed.emit(value)
var custom_skin_path: String = "":
	set(value):
		if value == custom_skin_path:
			return
		if value.is_empty():
			custom_skin_path = value
			skin = default_skin
			_save_settings()
			return
		if !FileAccess.file_exists(value):
			return
		var image: Image = Image.load_from_file(value)

		if image == null:
			OS.alert("Invalid file selected.")
		if not image.get_size() == Vector2i(270, 30):
			OS.alert("Image size not supported, must be 270 x 30.")
			return

		custom_skin_path = value
		skin = image
		if _is_dirty:
			return
		_save_settings()
var last_opened_session: String = "":
	set(value):
		if value == last_opened_session:
			return
		last_opened_session = value
		if _is_dirty:
			return
		_save_settings()
var last_working_directory: String = "":
	set(value):
		if value == last_working_directory:
			return
		last_working_directory = value
		if _is_dirty:
			return
		_save_settings()
var last_skin_directory: String = "":
	set(value):
		if value == last_skin_directory:
			return
		last_skin_directory = value
		if _is_dirty:
			return
		_save_settings()

var _is_dirty: bool = false


func _ready() -> void:
	_load_settings()


func is_valid_path(path: String) -> bool:
	if path.is_empty():
		return false
	return DirAccess.dir_exists_absolute(path)


func _save_settings() -> void:
	var config_file: ConfigFile = ConfigFile.new()
	config_file.set_value("Options", "custom_skin_path", custom_skin_path)
	config_file.set_value("Options", "startup_behavior", startup_behavior)
	config_file.set_value("Paths", "last_opened_file", last_opened_session)
	config_file.set_value("Paths", "last_working_directory", last_working_directory)
	config_file.set_value("Paths", "last_skin_directory", last_skin_directory)
	config_file.save("user://options.cfg")


func _load_settings() -> void:
	var config_file: ConfigFile = ConfigFile.new()
	var err: int = config_file.load("user://options.cfg")

	if err != OK:
		return

	_is_dirty = true
	custom_skin_path = config_file.get_value("Options", "custom_skin_path")
	startup_behavior = config_file.get_value("Options", "startup_behavior")
	last_opened_session = config_file.get_value("Paths", "last_opened_file", "")
	last_working_directory = config_file.get_value("Paths", "last_working_directory", "")
	last_skin_directory = config_file.get_value("Paths", "last_skin_directory", "")
	_is_dirty = false
	settings_loaded.emit()
