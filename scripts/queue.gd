class_name Queue extends RefCounted

var _data: Dictionary[int,Variant] = {}
var _counter := 0
var _head := 0

func count() -> int:
	return _counter - _head

func enqueue(value: Variant):
	_data[_counter] = value
	_counter += 1

func dequeue() -> Variant:
	if count() > 0:
		var value = _data[_head]
		_head += 1
		return value
	push_error("attempted to dequeue from an empty queue")
	return null
