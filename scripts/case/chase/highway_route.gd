class_name HighwayRoute
extends RefCounted

## Where the highway suspect drives (persecucion-lugares.md, "En la autopista"): from his corner along the streets to
## the nearest ramp, up it onto the ring, and around the ring clockwise in the right-hand lanes, sometimes moving
## over to the other one halfway down a side. Pure data in the city's space, like ChaseRoute. Every number here is
## (propuesta).

## Laps around the ring: far more than the clock lasts.
const LAPS := 3
## His two lanes going clockwise (the inner half of the ring): the slow one by the guardrail, the fast one by the median.
const SLOW_LANE := -(HighwayLayout.MEDIAN / 2 + HighwayLayout.LANE * 1.5)
const FAST_LANE := -(HighwayLayout.MEDIAN / 2 + HighwayLayout.LANE / 2)
## The share of the sides where he moves over to the other lane.
const LANE_CHANGE := 0.5
## After the ramp he merges this far down the ring.
const MERGE := 25.0


## The ramp nearest to `start` (a corner), going by the streets.
static func nearest_ramp(start: Vector2i) -> String:
	var best := ""
	for side in HighwayLayout.SIDES:
		if best == "" or _blocks(start, ramp_corner(side)) < _blocks(start, ramp_corner(best)):
			best = side
	return best


## The corner of the city's edge where ramp `side` starts.
static func ramp_corner(side: String) -> Vector2i:
	match side:
		"n":
			return Vector2i(HighwayLayout.RAMP_STREET_X, CityLayout.NORTH)
		"s":
			return Vector2i(HighwayLayout.RAMP_STREET_X, CityLayout.SOUTH)
		"e":
			return Vector2i(CityLayout.EAST, HighwayLayout.RAMP_STREET_Z)
	return Vector2i(CityLayout.WEST, HighwayLayout.RAMP_STREET_Z)


## The way clockwise runs on each side of the ring.
static func clockwise(side: String) -> Vector3:
	return {"n": Vector3.RIGHT, "e": Vector3.BACK, "s": Vector3.LEFT, "w": Vector3.FORWARD}[side]


## The streets from `start` to the ramp's corner: first across to the ramp's street, then down it, so he drives
## straight on out onto the ramp.
static func city_corners(start: Vector2i, side: String) -> Array[Vector2i]:
	var goal := ramp_corner(side)
	var corners: Array[Vector2i] = [start]
	var at := start
	var legs := [Vector2i(1, 0), Vector2i(0, 1)] if side in ["n", "s"] else [Vector2i(0, 1), Vector2i(1, 0)]
	for axis: Vector2i in legs:
		while (at * axis) != (goal * axis):
			at += axis * signi((goal - at).x * axis.x + (goal - at).y * axis.y)
			corners.append(at)
	return corners


static func draw(seed_value: int, start: Vector2i) -> Array[Vector3]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("highway %d" % seed_value)
	var side := nearest_ramp(start)
	var route := ChaseRoute.new()
	route.corners = city_corners(start, side)
	if route.corners.size() < 2:
		route.corners.append(start)
	var points: Array[Vector3] = route.waypoints()
	var out := CityLayout.side_normal(side)
	var right := Vector3(-out.z, 0, out.x)
	points.append(HighwayLayout.ramp_point(side, -HighwayLayout.WIDTH / 2) + right * ChaseRoute.LANE)
	var merge := HighwayLayout.ramp_point(side, SLOW_LANE) + clockwise(side) * MERGE
	points.append(merge)
	var lanes := [HighwayLayout.loop(SLOW_LANE), HighwayLayout.loop(FAST_LANE)]
	var count: int = lanes[0].size()
	var k := _ahead(lanes[0], merge)
	var lane := 0
	for step in count * LAPS:
		var i := (k + step) % count
		var next := (i + 1) % count
		points.append(lanes[lane][i])
		# A long piece between two corners is a side: he may move over halfway down it.
		if lanes[0][i].distance_to(lanes[0][next]) > 50.0 and rng.randf() < LANE_CHANGE:
			points.append(lanes[lane][i].lerp(lanes[lane][next], 0.45))
			lane = 1 - lane
			points.append(lanes[lane][i].lerp(lanes[lane][next], 0.55))
	return points


## The first point of a lane's loop past `point`, going clockwise.
static func _ahead(loop: PackedVector3Array, point: Vector3) -> int:
	var best := 0
	for i in loop.size():
		if loop[i].distance_to(point) < loop[best].distance_to(point):
			best = i
	var along := loop[(best + 1) % loop.size()] - loop[best]
	return (best + 1) % loop.size() if (loop[best] - point).dot(along) < 0.0 else best


static func _blocks(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)
