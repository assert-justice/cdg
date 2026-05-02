class_name OptionSlider extends MenuOption

@export var prefix := ""
@export var suffix := ""
var slider: Slider
var label: RichTextLabel

func _ready() -> void:
	slider = $MarginContainer/VBoxContainer/HSlider
	label = $MarginContainer/VBoxContainer/RichTextLabel
	slider.value_changed.connect(change_setting)
	super._ready()

func load_setting() -> Variant:
	var value = super.load_setting()
	# value is a float between 0 and 1
	if value is not float:
		push_error("slider '" + name + "' expected float, got: " + str(typeof(value)))
		return
	if value < 0 or value > 1:
		push_error("slider value is: " + str(value) + ", out of bounds")
		return
	# put value into correct range
	value = value * (slider.max_value - slider.min_value) + slider.min_value
	slider.value = value
	#slider.set_value_no_signal(value)
	return value

func change_setting(value: Variant):
	if value is not float:
		push_error("should be unreachable")
		return
	var text := prefix + str(int(value)) + suffix
	label.text = text
	# normalize value
	value -= slider.min_value
	value /= slider.max_value - slider.min_value
	super.change_setting(value)
	# todo: this is a hack
	if setting_name == "volume_main" or setting_name == "volume_sfx":
		Global.add_message("play_sfx: res://assets/Audio/Sfx/sipping 3.wav")
