class_name GridCell
extends TextureRect


signal cell_updated(type: Constants.Minos)


var id: int = -1
var cell_width: float = 30
var hide_when_empty: bool = false
var type: Constants.Minos:
	set(value):
		type = value
		if hide_when_empty:
			if type != Constants.Minos.EMPTY:
				modulate.a = 255
			else:
				modulate.a = 0
		_update_texture_region()


@onready var atlas_texture: AtlasTexture = AtlasTexture.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = atlas_texture
	_update_texture()

	type = Constants.Minos.EMPTY


func _update_texture() -> void:
	var image: ImageTexture = ImageTexture.new()
	atlas_texture.atlas = image
	
	image.set_image(Settings.skin)
	cell_width = Settings.skin.get_height()
	atlas_texture.region.size = Vector2(cell_width, cell_width)

	_update_texture_region()


func _update_texture_region() -> void:
	atlas_texture.region.position.x = type * cell_width


func _on_mouse_entered() -> void:
	if (Input.get_mouse_button_mask() & MOUSE_BUTTON_MASK_LEFT) != 0:
		type = Constants.Minos.Z
	elif (Input.get_mouse_button_mask() & MOUSE_BUTTON_MASK_RIGHT) != 0:
		type = Constants.Minos.EMPTY


func _on_texture_button_pressed() -> void:
	if (Input.get_mouse_button_mask() & MOUSE_BUTTON_MASK_LEFT) != 0:
		type = Constants.Minos.Z
	elif (Input.get_mouse_button_mask() & MOUSE_BUTTON_MASK_RIGHT) != 0:
		type = Constants.Minos.EMPTY
