class_name Menu extends Control

var _has_focus := false

func _ready() -> void:
	for node in _get_nodes_dfs(self):
		_bind(node)

func _bind(node: Control):
	if node is BaseButton:
		_bind_button(node)

func _bind_button(button: BaseButton):
	match button.name:
		"Start":
			button.pressed.connect(func():Global.add_message("play"))
		"Resume":
			button.pressed.connect(func():Global.add_message("resume"))
		"Restart":
			button.pressed.connect(func():Global.add_message("restart"))
		"Back":
			button.pressed.connect(func():Global.add_message("back"))
		"Quit":
			button.pressed.connect(func():Global.add_message("quit"))
		"MainMenu":
			button.pressed.connect(func():Global.add_message("set_menu: MainMenu"))
		"Options":
			button.pressed.connect(func():Global.add_message("set_menu: Options"))
		"Credits":
			button.pressed.connect(func():Global.add_message("set_menu: Credits"))

func _get_nodes_dfs(parent: Control, nodes: Array[Control] = []) -> Array[Control]:
	for child in parent.get_children():
		if child is Control:
			nodes.push_back(child)
			_get_nodes_dfs(child, nodes)
	return nodes

func wake():
	visible = true
	var nodes := _get_nodes_dfs(self)
	for node in nodes:
		if _has_focus:
			break
		elif not node.visible:
			continue
		elif node.focus_mode == FocusMode.FOCUS_CLICK or node.focus_mode == FocusMode.FOCUS_ALL:
			node.grab_focus()
			_has_focus = true
			break

func sleep():
	_has_focus = false
	visible = false
