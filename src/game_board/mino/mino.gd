class_name Mino
extends TextureRect

var cell_width: float = 30
var hide_when_empty: bool = false
var type: Constants.Minos:
	set(value):
		type = value
		if type != Constants.Minos.EMPTY:
			modulate.a = 255
		elif hide_when_empty:
			modulate.a = 0
		_update_texture_region()


@onready var atlas_texture: AtlasTexture = AtlasTexture.new()


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
