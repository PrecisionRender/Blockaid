extends Node


signal session_name_changed(new_name: String)


var session_name: String = "Untitled":
	set(value):
		session_name = value
		session_name_changed.emit(value)
