class_name HighwayLayout
extends RefCounted

## The ring highway around the city (persecucion-lugares.md, "Dónde quedan"): 4 lanes with a median, guardrails on
## both sides, rounded corners, one ramp per side and 2 tolls. Pure data in the city's space, like CityLayout.
## Every number here is (propuesta).

## From the city's edge to the highway's inner edge (m).
const GAP := 40.0
## Two lanes each way and the median between them.
const LANE := 3.5
const MEDIAN := 1.0
const WIDTH := MEDIAN + LANE * 4
## The corners are arcs of this radius (on the middle line), drawn in this many straight pieces.
const CORNER := 45.0
const ARC_STEPS := 10
## Half the size of the middle line's rectangle, and of the outside edge.
const HALF := CityLayout.SIZE / 2 + Vector2.ONE * (GAP + WIDTH / 2)
const OUTER := HALF + Vector2.ONE * WIDTH / 2
## The ramps go out from the city's edge streets along these: the north and south ones along north-south street 3,
## the east and west ones along west-east street 3 (the station's street).
const RAMP_STREET_X := 3
const RAMP_STREET_Z := 3
const SIDES: Array[String] = ["n", "e", "s", "w"]
## The 2 tolls: the side of the ring and how far along it (x on the north and south sides).
const TOLLS := [{"side": "n", "x": 150.0}, {"side": "s", "x": -150.0}]


## The closed line around the ring, `offset` meters out from its middle (negative goes in), corner by corner:
## north-east, south-east, south-west, north-west, clockwise seen from above.
static func loop(offset := 0.0) -> PackedVector3Array:
	var points := PackedVector3Array()
	var inner := HALF - Vector2.ONE * CORNER
	var radius := CORNER + offset
	var corners := [Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1)]
	for c in corners.size():
		var center: Vector2 = corners[c] * inner
		for k in ARC_STEPS + 1:
			var angle := -PI / 2 + (c + float(k) / ARC_STEPS) * PI / 2
			points.append(Vector3(center.x + cos(angle) * radius, 0, center.y + sin(angle) * radius))
	return points


## The ring's line at `offset` as straight pieces [from, to], leaving out `gaps` (each [point, half width]).
static func pieces(offset := 0.0, gaps: Array = []) -> Array[Array]:
	var points := loop(offset)
	var out: Array[Array] = []
	for i in points.size():
		var cut: Array[Array] = [[points[i], points[(i + 1) % points.size()]]]
		for gap: Array in gaps:
			var next: Array[Array] = []
			for piece in cut:
				next.append_array(_without(piece[0], piece[1], gap[0], gap[1]))
			cut = next
		out.append_array(cut)
	return out


## A piece minus the stretch of it around `point`, if the point is on it.
static func _without(from: Vector3, to: Vector3, point: Vector3, half_width: float) -> Array[Array]:
	var length := from.distance_to(to)
	var along := (to - from) / length
	var t := (point - from).dot(along)
	if t <= 0.0 or t >= length or (from + along * t).distance_to(point) > 0.5:
		return [[from, to]]
	var out: Array[Array] = []
	if t - half_width > 0.0:
		out.append([from, from + along * (t - half_width)])
	if t + half_width < length:
		out.append([from + along * (t + half_width), to])
	return out


## Where ramp `side` meets the ring's line at `offset`.
static func ramp_point(side: String, offset := 0.0) -> Vector3:
	var x := CityLayout.street_x(RAMP_STREET_X)
	var z := CityLayout.street_z(RAMP_STREET_Z)
	match side:
		"n":
			return Vector3(x, 0, -HALF.y - offset)
		"s":
			return Vector3(x, 0, HALF.y + offset)
		"e":
			return Vector3(HALF.x + offset, 0, z)
	return Vector3(-HALF.x - offset, 0, z)


## The ramp's road from the city's edge to the ring's inner edge: its middle and size on the ground (x, z).
static func ramp_rect(side: String) -> Array:
	var city := CityLayout.SIZE / 2
	var from := ramp_point(side, -WIDTH / 2)
	var normal := CityLayout.side_normal(side)
	var length := (HALF.x if side in ["e", "w"] else HALF.y) - WIDTH / 2 - (city.x if side in ["e", "w"] else city.y)
	var middle := from - normal * length / 2
	var size := Vector2(CityLayout.STREET, length) if side in ["n", "s"] else Vector2(length, CityLayout.STREET)
	return [middle, size]


## How far a point (the city's x, z) is from the ring's middle line: 0 on it, WIDTH / 2 at its edges.
static func off_middle(point: Vector3) -> float:
	var q := Vector2(absf(point.x), absf(point.z)) - (HALF - Vector2.ONE * CORNER)
	var outside := Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length() + minf(maxf(q.x, q.y), 0.0)
	return absf(outside - CORNER)


## Whether a point (the city's x, z) is on the highway's road.
static func on_road(point: Vector3) -> bool:
	return off_middle(point) <= WIDTH / 2


## Where toll `index` stands on the middle line, and the way the road runs there (+X on both).
static func toll_point(index: int) -> Vector3:
	var toll: Dictionary = TOLLS[index]
	return Vector3(toll.x, 0, -HALF.y if toll.side == "n" else HALF.y)
