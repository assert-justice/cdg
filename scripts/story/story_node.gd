class_name StoryNode extends RefCounted

var commands: Array[Command] = []
var children: Dictionary[String,StoryNode] = {}
var title: String
var id: String

func _init(_id: String, _title: String):
	id = _id
	title = _title

func _to_string(depth := 0) -> String:
	var s := ""
	for i in range(0, depth + 1):
		s += "#"
	s += " " + title + " {#" + id + "}" + "\n"
	for com in commands:
		s += str(com) + "\n"
	s += "\n"
	for _id in children:
		s += children[_id]._to_string(depth + 1) + "\n"
	return s
