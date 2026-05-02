extends TextureButton

func _ready() -> void:
	mouse_entered.connect(grab_focus)
