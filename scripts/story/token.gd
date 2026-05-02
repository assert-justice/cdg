class_name Token extends RefCounted

enum TokenType {IDENTIFIER, NUMBER, STRING}

var literal: String
var type: TokenType

func _init(_literal: String, _type: TokenType):
	literal = _literal
	type = _type

func _to_string() -> String:
	match type:
		TokenType.IDENTIFIER:
			return literal
		TokenType.NUMBER:
			return literal
		TokenType.STRING:
			return "\"" + literal + "\""
		_:
			push_error("should be unreachable")
			return ""
