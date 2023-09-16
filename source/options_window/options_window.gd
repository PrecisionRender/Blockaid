extends Control


@export_category("Startup")
@export var startup_button: OptionButton
@export_category("Skin")
@export var skin_name_label: Label
@export var choose_skn_button: Button
@export_category("Licenses")
@export var third_party_license_text: RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_button_pressed() -> void:
	pass # Replace with function body.
