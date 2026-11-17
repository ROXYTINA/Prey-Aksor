extends Control
## Khmer render test (Phase 0), responsive for phones and tablets.
## Shows tricky Khmer words as tappable tiles so you can check, on a real device:
##   1. shaping (subscripts, stacked vowels, no broken clusters)
##   2. clipping (nothing cut off at the top or bottom)
##   3. tile segmentation (tiles from words.json join back to the full word)
##   4. tap animation (bounce) runs smoothly
##   5. layout adapts: more columns on wide screens, centered max width, rotation works

const FONT_PATH := "res://fonts/NotoSansKhmer.ttf"
const WORDS_PATH := "res://data/words.json"

var khmer_font: Font
var font_size: int = 48
var tile_labels: Array[Label] = []

var margin: MarginContainer
var grid: GridContainer
var layout_info: Label


func _ready() -> void:
	khmer_font = load(FONT_PATH)
	_build_ui()
	Layout.changed.connect(_update_layout)
	_update_layout()


func _load_words() -> Array:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(WORDS_PATH))
	if parsed is Dictionary:
		return parsed.get("words", [])
	push_error("words.json is missing or invalid")
	return []


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Tokens.c("bg.parchment")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	root.add_child(_ink_label("Khmer Render Test", 28))
	root.add_child(_make_engine_status())
	layout_info = _ink_label("", 14)
	root.add_child(layout_info)
	root.add_child(_make_size_row())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	grid = GridContainer.new()
	grid.columns = 1
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(grid)

	for w in _load_words():
		grid.add_child(_make_tile(w))


## Re-arranges the screen for the current size: centered max width + N columns.
func _update_layout() -> void:
	if margin == null or grid == null:
		return
	var w: float = Layout.viewport_size.x
	var max_w: float = float(Tokens.get_value("layout.maxContentWidth", 1200))
	var min_tile: float = float(Tokens.get_value("layout.tileMinWidth", 360))
	var max_cols: int = int(Tokens.get_value("layout.maxColumns", 3))

	var side: int = int(maxf(16.0, (w - max_w) / 2.0))
	margin.add_theme_constant_override("margin_left", side)
	margin.add_theme_constant_override("margin_right", side)

	var content_w: float = w - 2.0 * side
	grid.columns = Layout.columns_for(content_w, min_tile, max_cols)

	layout_info.text = "View %d x %d  |  %s  |  %s  |  short side %d dp  |  %d column(s)" % [
		int(Layout.viewport_size.x), int(Layout.viewport_size.y),
		"landscape" if Layout.is_landscape() else "portrait",
		"TABLET" if Layout.is_tablet() else "phone",
		int(Layout.shortest_side_dp()),
		grid.columns,
	]


func _ink_label(text: String, size: int = 16, wrap: bool = true) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Tokens.c("ink"))
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	return l


func _make_engine_status() -> Label:
	var ts_name := TextServerManager.get_primary_interface().get_name()
	var ok := ts_name.contains("HarfBuzz")
	var l := _ink_label(("OK: " if ok else "PROBLEM: ") + "text server = " + ts_name)
	l.add_theme_color_override("font_color", Tokens.c("success") if ok else Tokens.c("retry"))
	return l


func _make_size_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_child(_ink_label("Tile size  ", 16, false))
	var slider := HSlider.new()
	slider.min_value = 24
	slider.max_value = 96
	slider.step = 4
	slider.value = font_size
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(0, 48)
	slider.value_changed.connect(_on_size_changed)
	row.add_child(slider)
	return row


func _make_tile(w: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Tokens.c("stone.base")
	style.set_corner_radius_all(int(Tokens.get_value("radius.tile", 12)))
	style.set_border_width_all(3)
	style.border_color = Tokens.c("ink")
	style.set_content_margin_all(12)
	panel.add_theme_stylebox_override("panel", style)
	panel.gui_input.connect(_on_tile_input.bind(panel))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)

	# Big Khmer word
	var text: String = w.get("text", "")
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", khmer_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Tokens.c("ink"))
	label.custom_minimum_size.y = font_size * 1.8  # generous height so marks never clip
	box.add_child(label)
	tile_labels.append(label)

	# Segmentation row: each tile in its own small label
	var tiles: Array = w.get("tiles", [])
	var seg_row := HBoxContainer.new()
	seg_row.alignment = BoxContainer.ALIGNMENT_CENTER
	for i in tiles.size():
		if i > 0:
			seg_row.add_child(_ink_label("  |  ", 16, false))
		var t := Label.new()
		t.text = str(tiles[i])
		t.add_theme_font_override("font", khmer_font)
		t.add_theme_font_size_override("font_size", 28)
		t.add_theme_color_override("font_color", Tokens.c("jungle.deep"))
		seg_row.add_child(t)
	box.add_child(seg_row)

	# Info + segmentation check (Latin text only)
	var seg_ok := "".join(tiles) == text
	var info := _ink_label("%s  -  %s   %s" % [
		w.get("romanization", ""),
		w.get("meaning_en", ""),
		"[segmentation OK]" if seg_ok else "[WARNING: tiles do not join to the word]",
	], 16)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if not seg_ok:
		info.add_theme_color_override("font_color", Tokens.c("retry"))
	box.add_child(info)

	return panel


func _on_size_changed(v: float) -> void:
	font_size = int(v)
	for l in tile_labels:
		l.add_theme_font_size_override("font_size", font_size)
		l.custom_minimum_size.y = font_size * 1.8


func _on_tile_input(event: InputEvent, panel: Control) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_bounce(panel)


func _bounce(panel: Control) -> void:
	var quick: float = float(Tokens.get_value("motion.quick", 120)) / 1000.0
	var base: float = float(Tokens.get_value("motion.base", 240)) / 1000.0
	panel.pivot_offset = panel.size / 2.0
	var tw := create_tween()
	tw.tween_property(panel, "scale", Vector2(1.08, 1.08), quick) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "scale", Vector2.ONE, base) \
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
