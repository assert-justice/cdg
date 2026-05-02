class_name Story extends Control

var _ip := 0
var _commands: Array[Command] = []
var _running := false
var _images: Dictionary[String, Sprite2D] = {}
var _speakers: Dictionary[String, String] = {}
var _tween: Tween
var _anim_time := 0.0

func _ready() -> void:
	_speakers = {
		"Lucy": "res://assets/Ui/SpeakerLucy.png",
		"Jean": "res://assets/Ui/SpeakerJean.png",
		"Manager": "res://assets/Ui/SpeakerManager.png"
	}
	_commands = Global._story.commands
	#_running = true
	$Ui/Continue.pressed.connect(_continue)
	Global.add_subscriber(self)
	_restart()

func _process(_delta: float) -> void:
	if not visible:
		return
	if not _running:
		return
	while _running and in_story():
		_cycle()
	_running = false

func in_story() -> bool:
	return _ip < len(_commands)

func _cycle():
	var command := _commands[_ip]
	_ip += 1
	_exe(command)

func _continue():
	if _tween is Tween and _tween.is_running():
		# todo: figure out how to skip to end of tween and clean it up
		pass
		#_tween.pause()
		#_tween.custom_step(1000000)
		#_tween.kill()
	if in_story():
		_running = true
	else:
		print("fin")
		_restart()
		Global.add_message("set_menu: Credits")

func _get_tween() -> Tween:
	if not _tween or _tween.finished:
		_tween = create_tween().set_parallel()
	return _tween

func _exe(command: Command):
	command.reset()
	if command.is_empty():
		push_error("empty command")
		return
	var verb := command.ident()
	if not verb:
		push_error("token '%' is not an identifier" % command.peek().literal)
	match verb:
		"set":
			_setter(command)
		"clear":
			_clear(command)
		"append":
			_append(command)
		"add":
			_add(command)
		"remove":
			pass
		"await":
			_running = false
		"restart":
			Global.add_message("restart")
		_:
			push_error("unexpected method '" + verb + "'")

func _clear(command: Command):
	var prop := command.ident()
	if not prop:
		push_error("expected property name")
		return
	match prop:
		"all":
			_clear_all()
		"text":
			_clear_text()
		"canvas":
			_clear_canvas()
		_:
			push_error("unknown property '%'" % prop)

func _clear_text():
	$Ui/Dialogue.text = ""

func _clear_canvas():
	for node in $Canvas.get_children():
		$Canvas.remove_child(node)
		node.queue_free()
	_images.clear()

func _clear_all():
	_clear_text()
	_clear_canvas()

func _append(command: Command):
	var s := command.string()
	if not s:
		push_error("expected string argument")
	else:
		$Ui/Dialogue.text += s

func _add(command: Command):
	var prop := command.ident()
	if not prop:
		push_error("expected property name")
		return
	match prop:
		"image":
			_add_image(command)
		_:
			push_error("unknown property '" + prop + "'")

func _add_image(command: Command):
	if command.is_empty():
		push_error("expected image name")
		return
	var n := command.advance().literal
	var spr := _set_image_tex(command)
	if not spr:
		return
	_images[n] = spr
	if not command.is_empty():
		_set_image(command, spr)

func _setter(command: Command):
	var prop := command.ident()
	if not prop:
		push_error("expected property name")
		return
	match prop:
		"image":
			if command.is_empty():
				push_error("expected image name")
				return
			var n := command.advance().literal
			if not n in _images:
				push_error("no image of name '" + n + "' exists")
				return
			_set_image(command, _images[n])
		"speaker":
			if command.is_empty():
				push_error("expected speaker name")
				return
			var speaker_name := command.advance().literal
			if speaker_name in _speakers:
				$Ui/Speaker.texture = ResourceLoader.load(_speakers[speaker_name])
				$Ui/Speaker.visible = true
				$Ui/SpeakerFallback.visible = false
			else:
				$Ui/Speaker.visible = false
				$Ui/SpeakerFallback.visible = true
				$Ui/SpeakerFallback.text = speaker_name
		"anim":
			_set_anim(command)
		"music":
			var filename := command.string()
			if not filename:
				push_error("no filename argument supplied")
				return
			Global.add_message("play_music: " + filename)
		"sfx":
			var filename := command.string()
			if not filename:
				push_error("no filename argument supplied")
				return
			Global.add_message("play_sfx: " + filename)
		_:
			push_error("unknown property '" + prop + "'")

func _set_image(command: Command, spr: Sprite2D):
	while not command.is_empty():
		var prop := command.ident()
		if not prop:
			push_error("expected property name")
			return
		match prop:
			"tex":
				_set_image_tex(command, spr)
			"position":
				var px := command.number()
				var py := command.number()
				var pos := Vector2(px, py)
				if _anim_time > 0:
					_get_tween().tween_property(spr, "position", pos, _anim_time)
				else:
					spr.position = pos
			"scale":
				var v := command.number()
				var _scale := Vector2(v, v)
				if _anim_time > 0:
					_get_tween().tween_property(spr, "scale", _scale, _anim_time)
				else:
					spr.scale = _scale
			"flip_h":
				spr.flip_h = command.boolean()
			"flip_v":
				spr.flip_v = command.boolean()
			"angle":
				if _anim_time > 0:
					_get_tween().tween_property(spr, "rotation_degrees", command.number(), _anim_time)
				else:
					spr.rotation_degrees = command.number()
			"alpha":
				if _anim_time > 0:
					#_get_tween().tween_property(spr.modulate, "a", command.number(), _anim_time)
					_get_tween().tween_method(func(a:float): spr.modulate.a = a, spr.modulate.a, command.number(), _anim_time)
				else:
					spr.modulate.a = command.number()
			_:
				push_error("unknown property '" + prop + "'")
				break

func _set_image_tex(command: Command, spr: Sprite2D = null) -> Sprite2D:
	var tex := command.res()
	if not tex:
		push_error("expected extant texture resource")
		return
	elif tex is not Texture:
		push_error("expected extant texture resource")
		return
	if not spr:
		spr = Sprite2D.new()
		spr.texture = tex
		$Canvas.add_child(spr)
		spr.centered = false
	else:
		spr.texture = tex
	return spr

func _set_anim(command: Command):
	var prop := command.ident()
	if not prop:
		push_error("unknown property '" + prop + "'")
		return
	match prop:
		"time":
			_anim_time = command.number()

func _restart():
	_clear_all()
	_anim_time = 0
	_ip = 0
	_running = false
	Global.in_game = false

func wake():
	visible = true
	if not Global.in_game:
		Global.in_game = true
		_running = true
	$Ui/Continue.grab_focus()
	if _tween is Tween and not _tween.finished:
		_tween.play()

func sleep():
	visible = false
	if _tween is Tween:
		if _tween.finished:
			_tween = null
		else:
			_tween.pause()

func handle_message(verb: String, payload: String):
	if verb != "story":
		return
	match payload:
		"restart":
			_restart()
		_:
			push_error("unexpected story message '" + payload + "'")
