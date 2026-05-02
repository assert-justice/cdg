class_name MainMenu extends Menu

func wake():
	if Global.in_game:
		$HBoxContainer/MarginContainer/VBoxContainer/Start.visible = false
		$HBoxContainer/MarginContainer/VBoxContainer/Resume.visible = true
		$HBoxContainer/MarginContainer/VBoxContainer/Restart.visible = true
	else:
		$HBoxContainer/MarginContainer/VBoxContainer/Start.visible = true
		$HBoxContainer/MarginContainer/VBoxContainer/Resume.visible = false
		$HBoxContainer/MarginContainer/VBoxContainer/Restart.visible = false
	$HBoxContainer/MarginContainer/VBoxContainer/Quit.visible = not OS.has_feature("web")
	super.wake()
