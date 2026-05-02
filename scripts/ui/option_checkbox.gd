class_name OptionCheckBox extends MenuOption

var checkbox: CheckBox

func _ready() -> void:
	checkbox = $CheckBox
	checkbox.toggled.connect(change_setting)
	super._ready()

func load_setting() -> Variant:
	var value = super.load_setting()
	if value is not bool:
		push_error("checkbox expected bool, received: " + str(typeof(value)))
		return
	#checkbox.button_pressed = value
	checkbox.set_pressed_no_signal(value)
	return value
