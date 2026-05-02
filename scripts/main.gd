extends Control

var _next_menu := ""
var _menu_stack: Array[String] = []

func _ready():
	Global.add_subscriber(self)
	_next_menu = "MainMenu"

func _process(_delta):
	if len(_next_menu) == 0:
		return
	if _next_menu == "MainMenu":
		_menu_stack.clear()
	var menu: Control = get_node(_next_menu)
	var stack_idx := _menu_stack.find(_next_menu)
	if stack_idx == -1:
		stack_idx = len(_menu_stack)
	while len(_menu_stack) > stack_idx:
		_menu_stack.pop_back()
	_menu_stack.append(_next_menu)
	for child in get_children():
		if child == menu:
			if menu.has_method("wake"):
				menu.wake()
		elif child.has_method("sleep"):
			child.sleep()
	_next_menu = ""

func _input(event):
	if event.is_action_released("ui_cancel"):
		Global.add_message("back")

func _queue_set_menu(menu_name: String):
	_next_menu = menu_name

func _back():
	if len(_menu_stack) < 2:
		return
	_menu_stack.pop_back()
	_queue_set_menu(_menu_stack[-1])
	pass

func handle_message(verb: String, payload: String):
	match verb:
		"play":
			_queue_set_menu("Story")
		"resume":
			_queue_set_menu("Story")
		"restart":
			Global.add_message("story: restart")
			_queue_set_menu("Story")
		"set_menu":
			_queue_set_menu(payload)
		"back":
			_back()
		"play_music":
			var track = ResourceLoader.load(payload)
			$MusicPlayer.stream = track
			$MusicPlayer.play()
		"play_sfx":
			var track = ResourceLoader.load(payload)
			$SfxPlayer.stream = track
			$SfxPlayer.play()
