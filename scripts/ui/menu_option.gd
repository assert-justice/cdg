class_name MenuOption extends Control

@export var setting_name: String

func _ready() -> void:
	visibility_changed.connect(vis_changed)

func load_setting() -> Variant:
	return Global.get_setting(setting_name)

func change_setting(value: Variant):
	Global.set_setting(setting_name, value)

func vis_changed():
	# todo: this is another bad hack
	if visible:
		if setting_name == "fullscreen" and OS.has_feature("web"):
			visible = false
		else:
			load_setting()
