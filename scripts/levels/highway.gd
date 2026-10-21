class_name Highway
extends Node3D

## The ring highway around the city (persecucion-lugares.md, step 1), built from HighwayLayout in the city's space:
## the road with its lane lines, the median, guardrails on both sides with a gap at each ramp, the ramps from the
## city's edge streets, and the 2 tolls with a booth and a TollBarrier on each side. On it the patrol car goes up
## to 110 km/h (PatrolCar.top_speed asks `covers`).

const RAIL := Color(0.78, 0.8, 0.82)
const RAIL_HEIGHT := 0.9
const MEDIAN_HEIGHT := 0.6
const BOOTH := Color(0.95, 0.85, 0.55)
const CANOPY := Color(0.3, 0.45, 0.8)
const LINE := Color(0.95, 0.95, 0.95)

var city: City


func _ready() -> void:
	add_to_group("highway")
	for piece in HighwayLayout.pieces():
		_along(piece, Vector3(HighwayLayout.WIDTH, 0.01, 0), 0.006, City.ROAD, false, HighwayLayout.WIDTH / 2)
	for offset: float in [-HighwayLayout.MEDIAN / 2 - HighwayLayout.LANE, HighwayLayout.MEDIAN / 2 + HighwayLayout.LANE]:
		for piece in HighwayLayout.pieces(offset):
			_along(piece, Vector3(0.15, 0.01, 0), 0.013, LINE, false, 0.0)
	# The east ramp goes on across the ring to the golf club's gate: the median and the outer guardrail open there.
	var golf_gap := CityLayout.STREET / 2 + 0.5
	for piece in HighwayLayout.pieces(0.0, [[HighwayLayout.ramp_point("e"), golf_gap]]):
		_along(piece, Vector3(HighwayLayout.MEDIAN, MEDIAN_HEIGHT, 0), MEDIAN_HEIGHT / 2, City.HEDGE, true, 0.5)
	var inner := -HighwayLayout.WIDTH / 2 - 0.2
	var gaps := HighwayLayout.SIDES.map(func(side: String) -> Array:
		return [HighwayLayout.ramp_point(side, inner), CityLayout.STREET / 2 + 0.5])
	for piece in HighwayLayout.pieces(inner, gaps):
		_along(piece, Vector3(0.3, RAIL_HEIGHT, 0), RAIL_HEIGHT / 2, RAIL, true, 0.0)
	var outer := HighwayLayout.WIDTH / 2 + 0.2
	for piece in HighwayLayout.pieces(outer, [[HighwayLayout.ramp_point("e", outer), golf_gap]]):
		_along(piece, Vector3(0.3, RAIL_HEIGHT, 0), RAIL_HEIGHT / 2, RAIL, true, 0.0)
	for side in HighwayLayout.SIDES:
		var ramp := HighwayLayout.ramp_rect(side)
		city._mesh_box(ramp[0] + Vector3(0, 0.006, 0), Vector3(ramp[1].x, 0.01, ramp[1].y), City.ROAD, self)
	for i in HighwayLayout.TOLLS.size():
		_toll(HighwayLayout.toll_point(i))


## Whether a point in the world is on the highway's road.
func covers(world: Vector3) -> bool:
	return HighwayLayout.on_road(global_transform.affine_inverse() * world)


## A box along a piece of the ring: `size` gives its width and height, its length is the piece's, a little longer to
## close the corners' seams (by `seam` m, half the width that fans out). Solid ones bump.
func _along(piece: Array, size: Vector3, height: float, color: Color, solid: bool, seam: float) -> void:
	var from: Vector3 = piece[0]
	var to: Vector3 = piece[1]
	var length := from.distance_to(to)
	if length < 0.05:
		return
	var turn := Basis(Vector3.UP, atan2(to.x - from.x, to.z - from.z))
	var extra := seam * tan(PI / 4 / HighwayLayout.ARC_STEPS) * 2
	var box_size := Vector3(size.x, size.y, length + extra)
	var middle := (from + to) / 2 + Vector3.UP * height
	var holder := Node3D.new()
	holder.position = middle
	holder.basis = turn
	add_child(holder)
	if solid:
		city._box(Vector3.ZERO, box_size, color, holder)
	else:
		city._mesh_box(Vector3.ZERO, box_size, color, holder)


## A toll on the north or south side: the booth on the median, a canopy over the road on 4 posts and one barrier per
## side, after the booth in the way that side drives (on the right).
func _toll(at: Vector3) -> void:
	var root := Node3D.new()
	root.name = "Toll"
	root.position = at
	add_child(root)
	city._box(Vector3(0, 1.5, 0), Vector3(2.0, 3.0, 4.0), BOOTH, root)
	var reach := HighwayLayout.WIDTH / 2 + 0.8
	for x: float in [-3.0, 3.0]:
		for z: float in [-reach, reach]:
			city._box(Vector3(x, 2.9, z), Vector3(0.4, 5.8, 0.4), CANOPY, root)
	city._mesh_box(Vector3(0, 5.9, 0), Vector3(7.0, 0.4, reach * 2 + 1.0), CANOPY, root)
	var label := Label3D.new()
	label.text = "SIGN_TOLL"
	label.font_size = 96
	label.pixel_size = 0.01
	label.outline_size = 18
	label.double_sided = false
	for s: float in [-1.0, 1.0]:
		var sign := label.duplicate() as Label3D
		sign.position = Vector3(s * 3.55, 5.9, 0)
		sign.rotation.y = s * PI / 2
		root.add_child(sign)
	label.free()
	var middle := HighwayLayout.MEDIAN / 2 + HighwayLayout.LANE
	# South half drives east (+X), north half west: the barrier stands past the booth, across the half, its +X
	# toward that half's guardrail.
	for s: float in [-1.0, 1.0]:
		var barrier := TollBarrier.new()
		barrier.name = "Barrier" + ("North" if s < 0 else "South")
		barrier.position = Vector3(s * 3.0, 0, s * middle)
		barrier.basis = Basis(Vector3.UP, -PI / 2 if s > 0 else PI / 2)
		root.add_child(barrier)
