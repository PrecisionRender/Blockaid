class_name QueueInputDialogue
extends ConfirmationDialog


signal queue_sumbitted(queue: Constants.MinoQueues, tpyes: String)


const ACCEPTED_CHARS: String = "[ZLOSIJTzlosijt]"
const HOLD_QUEUE_LENGTH: int = 1
const NEXT_QUEUE_LENGTH: int = 6


var queue_length: int = 1:
	set(value):
		queue_length = value
		line_edit.call_deferred("set_max_length", value)
var queue_type: Constants.MinoQueues = Constants.MinoQueues.HOLD:
	set(value):
		queue_type = value
		match value:
			Constants.MinoQueues.HOLD:
				queue_length = HOLD_QUEUE_LENGTH
			Constants.MinoQueues.NEXT:
				queue_length = NEXT_QUEUE_LENGTH


@onready var line_edit: LineEdit = $LineEdit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_ok_button().focus_mode = Control.FOCUS_NONE
	get_cancel_button().focus_mode = Control.FOCUS_NONE
	line_edit.max_length = queue_length
	get_ok_button().disabled = true
	line_edit.grab_focus()


func _on_line_edit_text_changed(new_text: String) -> void:
	# Hacky solution to filter out unwanted charcaters
	var filtered_string: String = ""
	var previous_caret_column: int = $LineEdit.caret_column

	var regex = RegEx.new()
	regex.compile(ACCEPTED_CHARS)
	for accepted_char in regex.search_all(new_text):
		filtered_string += accepted_char.get_string()

	# Force the LineEdit box to use our filtered string
	$LineEdit.set_text(filtered_string)
	# Since changing the text manually resets the caret position, we restore it, 
	# taking into account the difference in characters between the previous text 
	# and the filtered text
	$LineEdit.caret_column = previous_caret_column - (new_text.length() - filtered_string.length())
	
	# Only enable the OK button once the character length matched the queue length
	get_ok_button().disabled = filtered_string.length() != queue_length


func _on_line_edit_text_submitted(_new_text: String) -> void:
	# Hacky solution to confirm the dialogue box when the enter key is pressed
	if !get_ok_button().disabled:
		get_ok_button().pressed.emit()


func _on_confirmed() -> void:
	queue_sumbitted.emit(queue_type, $LineEdit.text.to_lower())
