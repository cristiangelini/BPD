class_name CityMap
extends CanvasLayer

## The city map on the radio (docs/diseno/ciudad.md, step 3): M opens and closes a top view of the blocks,
## with the station, today's case place, the cops and the patrol car, and the ring highway around it. Drawn from
## CityLayout and HighwayLayout, so new places show up on their own.

const SIZE := 760.0
const MARGIN := 24.0
const STREET := Color(0.3, 0.31, 0.34)
const BLOCK := Color(0.55, 0.53, 0.5)
const BUILDING := Color(0.42, 0.41, 0.4)
const PLACE := Color(0.95, 0.9, 0.8)
const TARGET := Color(1, 0.82, 0.3)
const STATION := Color(0.35, 0.55, 1)
const COP := Color(0.45, 1, 0.5)
const CAR := Color(1, 1, 1)
const SUSPECT := Color(1, 0.45, 0.75)
const GRASS := Color(0.3, 0.45, 0.25)
const TOLL := Color(1, 0.82, 0.3)
## What the map shows: the whole ring highway.
## What the map shows: the ring, and past it on the east the golf club; MIDDLE is its center.
const EXTENT := Vector2(HighwayLayout.OUTER.x + GolfLayout.CENTER.x + GolfLayout.HALF.x, HighwayLayout.OUTER.y * 2)
const MIDDLE := Vector2(GolfLayout.CENTER.x + GolfLayout.HALF.x - HighwayLayout.OUTER.x, 0) / 2
const LAWN := Color(0.4, 0.62, 0.3)
const SAND := Color(0.85, 0.78, 0.55)
const WATER := Color(0.25, 0.45, 0.8)
const BLINK := 0.5

## The city node whose local space CityLayout describes, and the place to mark (empty for none).
var city: Node3D
var target := ""
var car: Node3D
## A chase's suspect, shown only while `shows_suspect` says so (the copilot's map, persecucion.md).
var suspect: Node3D
var shows_suspect: Callable = func() -> bool: return true

var _panel: PanelContainer
var _canvas: Control
var _reminder: Label
var _time := 0.0


func _ready() -> void:
	layer = 4
	_reminder = Label.new()
	_reminder.text = "HUD_MAP_HINT"
	_reminder.anchor_left = 1.0
	_reminder.anchor_right = 1.0
	_reminder.offset_left = -260
	_reminder.offset_right = -20
	_reminder.offset_top = 44
	_reminder.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_reminder.add_theme_font_size_override("font_size", 20)
	_reminder.add_theme_constant_override("outline_size", 6)
	add_child(_reminder)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override("panel", CaseBriefing._panel_style())
	center.add_child(_panel)
	var box := VBoxContainer.new()
	_panel.add_child(box)
	var title := Label.new()
	title.text = "MAP_TITLE"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", TARGET)
	box.add_child(title)
	_canvas = Control.new()
	_canvas.custom_minimum_size = Vector2.ONE * SIZE
	_canvas.draw.connect(_draw_map)
	box.add_child(_canvas)
	set_open(false)


func setup(new_city: Node3D, new_target: String, new_car: Node3D) -> void:
	city = new_city
	target = new_target
	car = new_car


func is_open() -> bool:
	return _panel.visible


func set_open(open: bool) -> void:
	_panel.visible = open
	_reminder.visible = not open


func toggle() -> void:
	set_open(not is_open())


## Where a point on the city's ground (its local x, z) lands on the map square, north up.
static func to_map(local: Vector3) -> Vector2:
	return Vector2(SIZE, SIZE) / 2 + (Vector2(local.x, local.z) - MIDDLE) * map_scale()


static func map_scale() -> float:
	return (SIZE - MARGIN * 2) / maxf(EXTENT.x, EXTENT.y)


## A point in the world on the map, through the city's transform.
func world_to_map(world: Vector3) -> Vector2:
	return to_map(city.global_transform.affine_inverse() * world if city else world)


func _process(delta: float) -> void:
	_time += delta
	if is_open():
		_canvas.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("map"):
		toggle()


func _draw_map() -> void:
	var k := map_scale()
	var half := CityLayout.SIZE / 2
	_canvas.draw_rect(Rect2(to_map(Vector3(MIDDLE.x - EXTENT.x / 2, 0, -EXTENT.y / 2)), EXTENT * k), GRASS)
	_highway(k)
	_golf(k)
	_canvas.draw_rect(Rect2(to_map(Vector3(-half.x, 0, -half.y)), CityLayout.SIZE * k), STREET)
	for block in CityLayout.blocks():
		var center := CityLayout.block_center(block)
		var corner := center - Vector3(CityLayout.BLOCK, 0, CityLayout.BLOCK) / 2
		_canvas.draw_rect(Rect2(to_map(corner), Vector2.ONE * CityLayout.BLOCK * k), BLOCK)
	for lot: Dictionary in CityLayout.fillers():
		_lot(lot, BUILDING)
	for p: Dictionary in CityLayout.PLACES:
		# A park shows as its grass.
		var plain: Color = p.color if p.get("park", false) else PLACE
		var color: Color = STATION if p.id == "station" else (TARGET if p.id == target else plain)
		if p.id == target and fmod(_time, BLINK * 2) > BLINK:
			color = plain
		_lot(p, color)
	for id: String in ["station", target]:
		if id == "":
			continue
		var p := CityLayout.place(id)
		var at := to_map(CityLayout.lot_center(p.block, p.side, p.along, p.size.z))
		var font := ThemeDB.fallback_font
		var text := tr(p.sign) if id == "station" else tr("MAP_CASE")
		var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
		_canvas.draw_string_outline(font, at + Vector2(-width / 2, -14), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, 6,
			Color.BLACK)
		_canvas.draw_string(font, at + Vector2(-width / 2, -14), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18,
			STATION.lightened(0.4) if id == "station" else TARGET)
	if car:
		_canvas.draw_rect(Rect2(world_to_map(car.global_position) - Vector2(5, 5), Vector2(10, 10)), CAR)
	if is_instance_valid(suspect) and shows_suspect.call():
		_canvas.draw_circle(world_to_map(suspect.global_position), 7.0, SUSPECT)
	for cop in _canvas.get_tree().get_nodes_in_group("cops"):
		_arrow(world_to_map((cop as Node3D).global_position), _map_heading(cop as Node3D))


## The ring as a thick line, its ramps and a mark on each toll.
func _highway(k: float) -> void:
	var line := PackedVector2Array()
	for point in HighwayLayout.loop():
		line.append(to_map(point))
	line.append(line[0])
	_canvas.draw_polyline(line, STREET, HighwayLayout.WIDTH * k)
	for side in HighwayLayout.SIDES:
		var ramp := HighwayLayout.ramp_rect(side)
		var size: Vector2 = ramp[1]
		_canvas.draw_rect(Rect2(to_map(ramp[0] - Vector3(size.x, 0, size.y) / 2), size * k), STREET)
	for i in HighwayLayout.TOLLS.size():
		_canvas.draw_rect(Rect2(to_map(HighwayLayout.toll_point(i)) - Vector2(3, 7), Vector2(6, 14)), TOLL)


## The golf club: its lawn, the lakes and the bunkers, and a dot on each hole.
func _golf(k: float) -> void:
	var half := GolfLayout.HALF
	var center := GolfLayout.CENTER
	_canvas.draw_rect(Rect2(to_map(center - Vector3(half.x, 0, half.y)), half * 2 * k), LAWN)
	for ellipse: Array in GolfLayout.LAKES + GolfLayout.BUNKERS:
		var color := WATER if GolfLayout.LAKES.has(ellipse) else SAND
		var middle: Vector3 = ellipse[0]
		_canvas.draw_set_transform(to_map(center + middle), 0.0, Vector2(ellipse[1], ellipse[2]) * k)
		_canvas.draw_circle(Vector2.ZERO, 1.0, color)
	_canvas.draw_set_transform(Vector2.ZERO)
	for hole in GolfLayout.HOLES:
		_canvas.draw_circle(to_map(center + hole), 2.5, Color.WHITE)


func _lot(lot: Dictionary, color: Color) -> void:
	var rect := CityLayout.footprint(lot.block, lot.side, lot.along, lot.size)
	_canvas.draw_rect(Rect2(to_map(Vector3(rect.position.x, 0, rect.position.y)), rect.size * map_scale()), color)


## The direction a node faces on the map: its -Z, through the city's turn.
func _map_heading(node: Node3D) -> Vector2:
	var forward := -node.global_basis.z
	if city:
		forward = city.global_basis.inverse() * forward
	return Vector2(forward.x, forward.z).normalized()


func _arrow(at: Vector2, heading: Vector2) -> void:
	var side := Vector2(-heading.y, heading.x)
	_canvas.draw_colored_polygon(PackedVector2Array([at + heading * 10, at - heading * 6 + side * 6,
		at - heading * 6 - side * 6]), COP)
