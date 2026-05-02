class_name Command extends RefCounted

var _tokens: Array[Token] = []
var _head := 0

func _to_string() -> String:
	var s := ""
	for t in _tokens:
		s += str(t) + " "
	return s

func len() -> int:
	return len(_tokens)

func remaining() -> int:
	return len(_tokens) - _head

func is_empty() -> bool:
	return _head >= len(_tokens)

func reset():
	_head = 0

func peek() -> Token:
	if is_empty():
		push_error("command out of tokens")
		return null
	return _tokens[_head]

func advance() -> Token:
	if is_empty():
		return null
	var r := _tokens[_head]
	_head += 1
	return r

func ident() -> String:
	var token := peek()
	if not token:
		return ""
	if token.type != Token.TokenType.IDENTIFIER:
		return ""
	return advance().literal

func string() -> String:
	var token := peek()
	if not token:
		return ""
	if token.type != Token.TokenType.STRING:
		return ""
	return advance().literal

func res() -> Resource:
	var token := peek()
	if not token:
		return null
	if token.type != Token.TokenType.STRING:
		return null
	var filename := peek().literal
	if not filename:
		return null
	var r = ResourceLoader.load(filename)
	if r:
		advance()
		return r
	return null

func number() -> float:
	var token := peek()
	if not token:
		return 0
	if token.type != Token.TokenType.NUMBER:
		return 0
	return float(advance().literal)

func boolean() -> bool:
	var token := peek()
	if not token:
		return false
	match token.type:
		Token.TokenType.IDENTIFIER:
			advance()
			if token.literal == "true":
				return true
			return false
		Token.TokenType.NUMBER:
			return number() != 0
		Token.TokenType.STRING:
			return string().length() > 0
		_:
			return false
