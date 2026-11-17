extends Node
## Autoload "Layout": responsive helpers for phones AND tablets, portrait AND landscape.
## Screens listen to `changed` and re-arrange themselves (never hard-code positions).

signal changed

var viewport_size: Vector2 = Vector2.ZERO


func _ready() -> void:
	get_tree().root.size_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	viewport_size = get_tree().root.get_visible_rect().size
	changed.emit()


func is_landscape() -> bool:
	return viewport_size.x > viewport_size.y


## Shortest physical screen side in Android-style dp (px / (dpi / 160)).
func shortest_side_dp() -> float:
	var s := DisplayServer.screen_get_size()
	var dpi := maxf(float(DisplayServer.screen_get_dpi()), 96.0)
	return float(mini(s.x, s.y)) / (dpi / 160.0)


func is_tablet() -> bool:
	return shortest_side_dp() >= float(Tokens.get_value("layout.tabletMinDp", 600))


## How many columns of `min_width`-wide items fit in `available_width`.
func columns_for(available_width: float, min_width: float, max_cols: int) -> int:
	return clampi(int(available_width / min_width), 1, max_cols)
