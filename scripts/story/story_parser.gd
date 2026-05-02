class_name StoryParser extends RefCounted

var _start := 0
var _current := 0
# line number should be shown as 1 higher
var _line_num := 0
var _root: StoryNode
var _tokens: Array[Token]
var _node_stack: Array[StoryNode]
var _src: String
var _command: Command
var _errors: Array[String] = []
var _synched := true
const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
const digits = "0123456789"

func _has_error() -> bool:
	return len(_errors) > 0

func _log_error(message: String):
	if not _synched:
		return
	message = "error " + str(_line_num + 1) + ":" + str(_current) + " '" + message + "'"
	_errors.push_back(message)
	push_error(message)

func _at_eof() -> bool:
	return _current >= _src.length()

func _peek() -> String:
	# an empty string from peek signals eof
	if _at_eof():
		return ""
	return _src[_current]

func _advance() -> String:
	if _at_eof():
		return ""
	var c := _peek()
	_current += 1
	return c

func _whitespace():
	while not _at_eof():
		var _o := ord(_peek())
		match _peek():
			" ":
				_advance()
			"\t":
				_advance()
			"\r":
				_advance()
			_:
				break

func _match(s: String, trim: bool = true) -> bool:
	if trim:
		_whitespace()
	var begin := _current
	for c in s:
		if c != _advance():
			_current = begin
			return false
	return true

func _is_alpha(c: String) -> bool:
	return letters.find(c) != -1

func _is_digit(c: String) -> bool:
	return digits.find(c) != -1

func _add_command():
	_command = Command.new()
	_node_stack[-1].commands.append(_command)

func _add_token():
	if len(_tokens) == 0:
		_log_error("no tokens in stack")
		return
	if not _command:
		_add_command()
	var token = _tokens.pop_back()
	_command._tokens.append(token)

func _push_node(node_id: String, title: String):
	var node := StoryNode.new(node_id, title)
	if node_id in _node_stack[-1].children:
		_log_error("duplicate story node id")
	_node_stack[-1].children[node_id] = node
	_node_stack.append(node)

func _identifier() -> bool:
	var c := _peek()
	if _is_alpha(c):
		pass
	elif c == "_":
		pass
	else:
		return false
	while not _at_eof():
		c = _peek()
		if _is_alpha(c):
			pass
		elif _is_digit(c):
			pass
		elif c == "_":
			pass
		else:
			break
		_advance()
	var literal := _src.substr(_start, _current - _start)
	var token := Token.new(literal, Token.TokenType.IDENTIFIER)
	_tokens.push_back(token)
	return true

func _string() -> bool:
	if not _match("\""):
		return false
	while true:
		if _at_eof():
			_log_error("unexpected end of string")
			return true
		elif _match("\""):
			break
		else:
			_advance()
	var literal := _src.substr(_start + 1, _current - _start - 2)
	var token = Token.new(literal, Token.TokenType.STRING)
	_tokens.push_back(token)
	return true

func _comment() -> bool:
	if not _match(";"):
		return false
	while not _at_eof() and _peek() != "\n":
		_advance()
	return true

func _number() -> bool:
	if not _is_digit(_peek()):
		return false
	while not _at_eof():
		var c := _peek()
		if _is_digit(c):
			pass
		elif c == "_":
			pass
		# note: currently accepts multiple decimal points
		elif c == ".":
			pass
		else:
			break
		_advance()
	var literal := _src.substr(_start, _current - _start)
	var token := Token.new(literal, Token.TokenType.NUMBER)
	_tokens.push_back(token)
	return true

func _parse_line():
	_current = _src.find("\n", _start)
	if _current == -1:
		_current = _src.length()
	#else:
		#_current -= 1
	var literal := _src.substr(_start, _current - _start)
	var token := Token.new("append", Token.TokenType.IDENTIFIER)
	_tokens.push_back(token)
	_add_token()
	token = Token.new(literal, Token.TokenType.STRING)
	_tokens.push_back(token)
	_add_token()

func _parse_command():
	while true:
		_whitespace()
		_start = _current
		if _at_eof():
			break
		elif _peek() == "\n":
			break
		elif _comment():
			pass
		elif _string():
			_add_token()
		elif _identifier():
			_add_token()
		elif _number():
			_add_token()
		else:
			_log_error(str(ord(_peek())))
			break

func _change_node():
	var depth := 1
	while _peek() == "#":
		depth += 1
		_advance()
	_start = _current
	var nl_idx := _src.find("\n", _start)
	if nl_idx == -1:
		nl_idx = _src.length()
	var lc_idx := _src.find("{", _start)
	if lc_idx == -1:
		lc_idx = _src.length()
	var node_id: String
	var title: String
	if lc_idx < nl_idx:
		# handle story nodes with custom ids
		# consume the left curly
		_current = lc_idx
		title = _src.substr(_start, _current - _start)
		# consume open curly
		_advance()
		if not _match("#"):
			_log_error("failed to find id")
			return
		_start = _current
		if _identifier():
			node_id = _tokens.pop_back().literal
		elif _number():
			node_id = _tokens.pop_back().literal
		else:
			_log_error("failed to find id again")
			return
		if not _match("}"):
			_log_error("id not closed")
	else:
		_current = nl_idx
		title = _src.substr(_start, _current - _start)
		node_id = str(title.hash())
	
	_command = null
	# dumb node juggle
	while depth < len(_node_stack):
		_node_stack.pop_back()
	if depth > len(_node_stack):
		while depth > len(_node_stack) + 1:
			var temp_t := _node_stack[-1].title + "_inner"
			_push_node(str(temp_t.hash()), temp_t)
		_push_node(node_id, title)

func parse(src: String) -> StoryNode:
	_src = src
	_root = StoryNode.new("start", "start")
	_tokens = []
	_node_stack = [_root]
	_start = 0
	_current = 0
	_command = null
	var in_block := false
	while not _at_eof() and not _has_error():
		_synched = true
		_whitespace()
		_start = _current
		var c := _peek()
		var _o := ord(c)
		match c:
			"\n":
				_line_num += 1
				_command = null
				_advance()
			"\r":
				_log_error("bite me")
			"#":
				if in_block:
					_log_error("unexpected end of code block, end of node found")
				else:
					_change_node()
					in_block = false
			"`":
				if not _match("```"):
					_log_error("wtf")
				in_block = not in_block
			_:
				if in_block:
					_parse_command()
				else:
					_parse_line()
	if in_block:
		_log_error("unexpected end of code block, eof found")
	return _root
