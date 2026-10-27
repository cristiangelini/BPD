class_name ChaseRoute
extends RefCounted

## Where the chase suspect drives (persecucion.md, "Cómo es el caso"): from a street corner drawn with the seed, a
## corner at a time along the city's streets (CityLayout), straight on or turning at random, never back the way he came
## and, while there's another way, never down the same block of street twice. Pure data, so tests check it without a
## scene. Every number here is (propuesta).

## Corners the route goes through: enough for a minute at the suspect's speed with room to spare.
const CORNERS := 30
## He keeps to the right-hand lane: this far right of the middle of the street.
const LANE := 1.5
## The delivery scooter rides the sidewalk instead: the middle of it.
const SIDEWALK_LANE := CityLayout.STREET / 2 + CityLayout.SIDEWALK / 2

## No corner: draw() picks its own start.
const NONE := Vector2i(-99, -99)

## Corners (i, j): i is the north-south street (CityLayout.WEST to EAST), j the west-east one (NORTH to SOUTH).
var corners: Array[Vector2i] = []


## `start` is the corner he sets off from (by default, an inner corner drawn with the seed), and `heading` the way he
## was going there, so he doesn't turn straight back.
static func draw(seed_value: int, count := CORNERS, start := NONE, heading := Vector2i.ZERO) -> ChaseRoute:
	var route := ChaseRoute.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("chase %d" % seed_value)
	var at := Vector2i(rng.randi_range(CityLayout.WEST + 1, CityLayout.EAST - 1),
		rng.randi_range(CityLayout.NORTH + 1, CityLayout.SOUTH - 1))
	if on_grid(start):
		at = start
	route.corners.append(at)
	var used := {}
	while route.corners.size() < count:
		var options: Array[Vector2i] = []
		var fresh: Array[Vector2i] = []
		for step: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var next := at + step
			if step == -heading or not on_grid(next):
				continue
			options.append(step)
			if not used.has(_segment(at, next)):
				fresh.append(step)
		var pick_from := fresh if not fresh.is_empty() else options
		heading = pick_from[rng.randi() % pick_from.size()]
		used[_segment(at, at + heading)] = true
		at += heading
		route.corners.append(at)
	return route


static func on_grid(corner: Vector2i) -> bool:
	return CityLayout.on_grid(corner)


## The middle of corner `c`, on the ground, in the city's space.
static func corner_point(c: Vector2i) -> Vector3:
	return Vector3(CityLayout.street_x(c.x), 0, CityLayout.street_z(c.y))


## Where he drives through each corner, in the city's space: in his lane (`lane` m right of the street's middle),
## cutting the corner when he turns.
func waypoints(lane := LANE) -> Array[Vector3]:
	var points: Array[Vector3] = []
	for k in corners.size():
		var into := corners[k] - corners[k - 1] if k > 0 else corners[k + 1] - corners[k]
		var out := corners[k + 1] - corners[k] if k + 1 < corners.size() else into
		var right_in := _right(into)
		var right_out := _right(out)
		var offset := right_in * lane if into == out else (right_in + right_out) * lane
		points.append(corner_point(corners[k]) + offset)
	return points


## The corner nearest to `point` (in the city's space).
static func nearest_corner(point: Vector3) -> Vector2i:
	var best := Vector2i(CityLayout.WEST, CityLayout.NORTH)
	for c in CityLayout.crossings():
		if corner_point(c).distance_to(point) < corner_point(best).distance_to(point):
			best = c
	return best


## The block of street between two corners, the same whichever way it's driven.
static func _segment(a: Vector2i, b: Vector2i) -> Vector4i:
	return Vector4i(mini(a.x, b.x), mini(a.y, b.y), maxi(a.x, b.x), maxi(a.y, b.y))


## Right of a heading on the grid (+x east, +y south, like +Z): north (0, -1) has east on its right.
static func _right(heading: Vector2i) -> Vector3:
	return Vector3(-heading.y, 0, heading.x)
