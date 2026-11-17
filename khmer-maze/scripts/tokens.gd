extends Node
## Autoload "Tokens": loads design tokens from data/tokens.json.
## Usage: Tokens.c("bg.parchment") -> Color, Tokens.get_value("motion.quick") -> 120

const TOKENS_PATH := "res://data/tokens.json"

var data: Dictionary = {}


func _ready() -> void:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(TOKENS_PATH))
	if parsed is Dictionary:
		data = parsed
	else:
		push_error("tokens.json is missing or invalid")


func get_value(path: String, default = null):
	var node = data
	for part in path.split("."):
		if node is Dictionary and node.has(part):
			node = node[part]
		else:
			return default
	return node


func c(path: String) -> Color:
	var v = get_value("color." + path)
	if v is String:
		return Color.html(v)
	push_warning("Unknown color token: " + path)
	return Color.MAGENTA
