@tool
extends Node2D

@export var state := true
@export var spin_speed := 10

func _process(delta):
	if not Engine.is_editor_hint():
		$Sunshine.rotation_degrees += spin_speed * delta
		$Sunshine.rotation_degrees += spin_speed * delta
	if state and not $Moon.visible:
		return
	if state:
		$Sun.visible = true
		$Sunshine.visible = true
		$Moon.visible = false
		$Moonshine.visible = false
	else:
		$Sun.visible = false
		$Sunshine.visible = false
		$Moon.visible = true
		$Moonshine.visible = true
