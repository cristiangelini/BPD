class_name GolfLayout
extends RefCounted

## The golf club (persecucion-lugares.md, "Ladrones en carrito de golf"): 224 × 168 m outside the ring on the east
## side, its gate on the ring's east ramp. 6 holes joined by a concrete path, 5 sand bunkers and 2 lakes. Pure data:
## CENTER is in the city's space, everything else in the club's own (its middle, +X east, the gate at -X).
## Every number here is (propuesta).

## Twice the ground (Cristian, 26/10: "que el campo de golf sea más grande", decision 182): every length 1.4 times.
const HALF := Vector2(112, 84)
## The club's west fence stands on the hedge past the highway, so its gate opens onto the ring's east side.
const CENTER := Vector3(HighwayLayout.OUTER.x + 6.0 + HALF.x, 0, -CityLayout.SIZE.y / 2 + CityLayout.STREET / 2
	+ (HighwayLayout.RAMP_STREET_Z - CityLayout.NORTH) * CityLayout.PITCH)
const GATE := Vector3(-HALF.x, 0, 0)
const GATE_WIDTH := 14.0
const PATH_WIDTH := 3.0
const GREEN_RADIUS := 6.0
const HOLES: Array[Vector3] = [Vector3(-77, 0, -53), Vector3(-7, 0, -63), Vector3(70, 0, -56), Vector3(87, 0, 28),
	Vector3(14, 0, 59), Vector3(-63, 0, 49)]
## Bunkers and lakes are ellipses: [middle, radius across x, radius across z].
const BUNKERS := [[Vector3(-53, 0, -39), 8.5, 5.5], [Vector3(31, 0, -70), 10.0, 5.0], [Vector3(101, 0, -14), 7.0, 11.0],
	[Vector3(-17, 0, 31), 11.0, 5.5], [Vector3(-91, 0, 35), 7.0, 8.5]]
const LAKES := [[Vector3(7, 0, -17), 19.5, 12.5], [Vector3(49, 0, 11), 12.5, 10.0]]
## Where the path from the gate meets the loop between the holes.
const JUNCTION := Vector3(-70, 0, 0)
## The cart keeps this far (m) off the lakes, and its route is this many holes long (minutes of driving).
const LAKE_MARGIN := 2.5
const CART_STOPS := 40


## The concrete path as straight pieces [from, to]: from the gate to the loop, then hole to hole all the way round.
static func path() -> Array[Array]:
	var out: Array[Array] = [[GATE, JUNCTION]]
	for i in HOLES.size():
		out.append([HOLES[i], HOLES[(i + 1) % HOLES.size()]])
	return out


## A point of the city's space in the club's own.
static func to_club(city_point: Vector3) -> Vector3:
	return city_point - CENTER


## Whether a point of the club's space is inside its fence.
static func inside(point: Vector3) -> bool:
	return absf(point.x) <= HALF.x and absf(point.z) <= HALF.y


static func in_ellipse(point: Vector3, ellipse: Array) -> bool:
	var middle: Vector3 = ellipse[0]
	var dx := (point.x - middle.x) / float(ellipse[1])
	var dz := (point.z - middle.z) / float(ellipse[2])
	return dx * dx + dz * dz <= 1.0


static func in_bunker(point: Vector3) -> bool:
	return BUNKERS.any(func(bunker: Array) -> bool: return in_ellipse(point, bunker))


static func in_lake(point: Vector3) -> bool:
	return LAKES.any(func(lake: Array) -> bool: return in_ellipse(point, lake))


## The holes the cart can drive straight to from hole `i`: every other one with no lake (and a margin) in the way.
static func links(i: int) -> Array[int]:
	var out: Array[int] = []
	for j in HOLES.size():
		if j != i and _dry(HOLES[i], HOLES[j]):
			out.append(j)
	return out


static func _dry(from: Vector3, to: Vector3) -> bool:
	for k in 31:
		var at := from.lerp(to, k / 30.0)
		for lake: Array in LAKES:
			if in_ellipse(at, [lake[0], float(lake[1]) + LAKE_MARGIN, float(lake[2]) + LAKE_MARGIN]):
				return false
	return true


## The thieves' cart route (persecucion-lugares.md): from a hole drawn with the seed, `stops` holes one after another,
## each one linked to the last and never straight back. In the city's space, so SuspectCar.follow_path takes it.
static func cart_route(seed_value: int, stops := CART_STOPS) -> Array[Vector3]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("golf cart %d" % seed_value)
	var at := rng.randi_range(0, HOLES.size() - 1)
	var before := -1
	var path: Array[Vector3] = [CENTER + HOLES[at]]
	for k in stops:
		var options := links(at)
		if options.size() > 1:
			options.erase(before)
		before = at
		at = options[rng.randi_range(0, options.size() - 1)]
		path.append(CENTER + HOLES[at])
	return path
