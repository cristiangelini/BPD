class_name CityTraffic
extends Node3D

## The city's traffic and its people (ciudad-viva.md, step 3): cars driving loops of streets in their right-hand lane
## and neighbors walking round their blocks' sidewalks. Every number here is (propuesta).

## Car loops: rectangles of streets (west, north, east, south street indexes) and whether they run clockwise.
const LOOPS := [[0, 0, 7, 5, true], [0, 0, 7, 5, false], [1, 1, 4, 4, true], [3, 1, 6, 4, false],
	[2, 0, 5, 3, true], [1, 2, 6, 5, false]]
const CARS_PER_LOOP := 6
const WALKER_LOOKS: Array[String] = ["cliente", "clienta", "senora", "vecina", "abuela", "periodista", "repartidor",
	"portero", "portera", "mudancero", "heladero", "abogado", "sospechoso", "abuelo", "chela", "ernesto"]
const WALKERS_PER_BLOCK := 7

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 7
	for loop: Array in LOOPS:
		var points := loop_points(loop[0], loop[1], loop[2], loop[3], loop[4])
		for k in CARS_PER_LOOP:
			var car := CityCar.new()
			car.name = "Car%d" % get_child_count()
			car.path = points
			car.look = _rng.randi_range(0, 3)
			add_child(car)
			car.place_along(float(k) / CARS_PER_LOOP + _rng.randf_range(0.0, 0.08))
	for row in CityLayout.ROWS:
		for col in CityLayout.COLUMNS:
			for k in WALKERS_PER_BLOCK:
				var walker := CityWalker.new()
				walker.name = "Walker%d" % get_child_count()
				walker.look = WALKER_LOOKS[_rng.randi() % WALKER_LOOKS.size()]
				walker.path = ring(Vector2i(col, row), _rng.randf_range(-0.7, 0.7), _rng.randf() < 0.5)
				add_child(walker)
				walker.rng.seed = _rng.randi()
				walker.place_along(_rng.randf())


## At night half the walkers go home (ciudad-viva.md, step 5): every other one hides and stops.
func set_night(night: bool) -> void:
	var k := 0
	for child in get_children():
		if child is CityWalker:
			var home := night and k % 2 == 1
			child.visible = not home
			child.process_mode = Node.PROCESS_MODE_DISABLED if home else Node.PROCESS_MODE_INHERIT
			if home:
				child.remove_from_group("city_walkers")
			elif not child.is_in_group("city_walkers"):
				child.add_to_group("city_walkers")
			k += 1


## The right-hand lane around a rectangle of streets: clockwise (seen from above, north up) runs inside it.
static func loop_points(west: int, north: int, east: int, south: int, clockwise: bool) -> PackedVector3Array:
	var lane := CityLayout.STREET / 4 * (1 if clockwise else -1)
	var x0 := CityLayout.street_x(west) + lane
	var x1 := CityLayout.street_x(east) - lane
	var z0 := CityLayout.street_z(north) + lane
	var z1 := CityLayout.street_z(south) - lane
	var corners := [Vector3(x0, 0, z0), Vector3(x1, 0, z0), Vector3(x1, 0, z1), Vector3(x0, 0, z1)]
	if not clockwise:
		corners.reverse()
	return PackedVector3Array(corners)


## The middle of a block's sidewalk, as a closed loop, `shift` meters toward the street.
static func ring(block: Vector2i, shift := 0.0, clockwise := true) -> PackedVector3Array:
	var c := CityLayout.block_center(block)
	var r := CityLayout.BLOCK / 2 - CityLayout.SIDEWALK / 2 + shift
	var y := CityLife.CURB
	var corners := [c + Vector3(-r, y, -r), c + Vector3(r, y, -r), c + Vector3(r, y, r), c + Vector3(-r, y, r)]
	if not clockwise:
		corners.reverse()
	return PackedVector3Array(corners)
