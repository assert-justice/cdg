extends Node

var _settings: Dictionary = {}
var _message_queue: Queue = Queue.new()
var _subscribers: Array[Node] = []
var _story: StoryNode
var in_game := false

func _ready():
	add_subscriber(self)
	# load settings
	_load_settings()
	var names := ["fullscreen", "volume_main", "volume_music", "volume_sfx"]
	for n in names:
		set_setting(n, get_setting(n))
	# load story
	var f := FileAccess.open("res://assets/story.yara", FileAccess.READ)
	if not f:
		push_error("failed to read script")
		return
	var src := f.get_as_text()
	var p := StoryParser.new()
	_story = p.parse(src)

func _process(_delta):
	_dispatch()

func _dispatch():
	while _message_queue.count() > 0:
		var message := _message_queue.dequeue() as String
		var split := message.find(":")
		var verb := message
		var payload := ""
		if(split != -1):
			verb = message.substr(0, split)
			payload = message.substr(split+1).strip_edges()
		for sub in _subscribers:
			if sub.has_method("handle_message"):
				sub.handle_message(verb, payload) 

func add_message(message: String):
	_message_queue.enqueue(message)

func add_subscriber(node: Node):
	if node.has_method("handle_message"):
		_subscribers.append(node)
	else:
		push_error("attempted to add a subscriber without a handle_message method")

func handle_message(verb: String, _payload: String):
	match verb:
		"quit":
			_save_settings()
			get_tree().quit()

func _read_json(path: String) -> Variant:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var content = file.get_as_text()
	var json = JSON.new()
	var err = json.parse(content)
	if err == OK:
		return json
	push_error("failed to parse json at path '%s'" % path)
	return null

func _load_settings():
	var json = _read_json("user://settings.json")
	if not json:
		json = JSON.new()
		json.parse("{}")
	_settings = json.get_data()
	print(_settings)

func _save_settings():
	var json_str = JSON.stringify(_settings)
	var file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	if file == null:
		push_error("failed to save settings, cannot open file")
	elif not file.store_string(json_str):
		push_error("failed to save settings, cannot write to file")

func get_setting(setting_name: String) -> Variant:
	if setting_name in _settings:
		return Global._settings[setting_name]
	match setting_name:
		"fullscreen":
			return false
		"volume_main":
			return 0.5
		"volume_music":
			return 0.5
		"volume_sfx":
			return 0.5
	return null

func set_setting(setting_name: String, value: Variant):
	match setting_name:
		"fullscreen":
			var mode := DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
			if value:
				mode = DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
			DisplayServer.window_set_mode(mode)
		"volume_main":
			AudioServer.set_bus_volume_linear(0, value)
		"volume_music":
			AudioServer.set_bus_volume_linear(1, value)
		"volume_sfx":
			AudioServer.set_bus_volume_linear(2, value)
	_settings[setting_name] = value
