class_name VentDuct
extends Node3D

## The duct over the ceiling in the vent jailbreak (docs/diseno/fuga-ventilacion.md, step 2), built in the station's
## lot space: a MAIN run above both cells and the guard room, and three STUBS south over the comisario's office. Only
## one stub (drawn by the seed) ends in the office's ceiling grille; the other two are dead ends. A hatch over each
## cell drops back into it. Inside, cops crawl (Cop.crawling). Every number here is (propuesta).

## The duct's floor, on the station's ceiling slab, and its inside height and width (a crouched cop fits, standing no).
const FLOOR_Y := StationRooms.CEILING + 0.25
const HEIGHT := 1.3
const WIDTH := 1.2
const THICK := 0.1
## The main run along x, at z = MAIN_Z, from MAIN_FROM to MAIN_TO.
const MAIN_Z := 2.0
const MAIN_FROM := -3.6
const MAIN_TO := 13.6
## The stubs south, at these x, down to STUB_END along z; the way out is at OFFICE_Z in one of them.
const STUBS: Array[float] = [-2.5, 0.0, 2.5]
const STUB_END := -2.6
const OFFICE_Z := -2.0
const METAL := Color(0.45, 0.47, 0.5)

## Which stub has the office grille.
var exit_stub := 0
## Over each cell, back down (one per cell); and the office's.
var cell_hatches: Array[VentHatch] = []
var office_hatch: VentHatch


## Builds it for this seed, with a hatch over each of `cells_x` (the cells' middles along x).
func build(case_seed: int, cells_x: Array[float]) -> void:
	exit_stub = hash(["vent exit", case_seed]) % STUBS.size()
	var body := StaticBody3D.new()
	body.name = "DuctBody"
	add_child(body)
	var half := WIDTH / 2
	var y_mid := FLOOR_Y + HEIGHT / 2
	# Floor and top of the main run and the stubs.
	_slab(body, Vector3((MAIN_FROM + MAIN_TO) / 2, 0, MAIN_Z), Vector3(MAIN_TO - MAIN_FROM + 2 * THICK, 0, WIDTH + 2 * THICK))
	var stub_len := MAIN_Z - half - STUB_END
	for x in STUBS:
		_slab(body, Vector3(x, 0, STUB_END + stub_len / 2), Vector3(WIDTH + 2 * THICK, 0, stub_len))
	# The main run's walls: the north one whole, the south one open where each stub leaves, and its two ends.
	_box(body, Vector3((MAIN_FROM + MAIN_TO) / 2, y_mid, MAIN_Z + half + THICK / 2), Vector3(MAIN_TO - MAIN_FROM, HEIGHT, THICK))
	var from := MAIN_FROM
	for x in STUBS + [MAIN_TO + half]:
		var to: float = x - half
		if to > from:
			_box(body, Vector3((from + to) / 2, y_mid, MAIN_Z - half - THICK / 2), Vector3(to - from, HEIGHT, THICK))
		from = x + half
	for x: float in [MAIN_FROM - THICK / 2, MAIN_TO + THICK / 2]:
		_box(body, Vector3(x, y_mid, MAIN_Z), Vector3(THICK, HEIGHT, WIDTH + 2 * THICK))
	# Each stub's two sides and its end.
	for x in STUBS:
		for side: float in [-1.0, 1.0]:
			_box(body, Vector3(x + side * (half + THICK / 2), y_mid, STUB_END + stub_len / 2), Vector3(THICK, HEIGHT, stub_len))
		_box(body, Vector3(x, y_mid, STUB_END - THICK / 2), Vector3(WIDTH + 2 * THICK, HEIGHT, THICK))
	# A little light leaks in along it.
	var lights: Array[Vector3] = [Vector3(10.5, 0, MAIN_Z), Vector3(5.0, 0, MAIN_Z)]
	for x in STUBS:
		lights.append(Vector3(x, 0, STUB_END + 1.0))
	for at in lights:
		var light := OmniLight3D.new()
		light.position = Vector3(at.x, FLOOR_Y + HEIGHT - 0.2, at.z)
		light.light_color = Color(0.7, 0.8, 1.0)
		light.light_energy = 0.15
		light.omni_range = 5.0
		add_child(light)
	for i in cells_x.size():
		var hatch := VentHatch.new()
		hatch.name = "CellHatch%d" % i
		hatch.position = Vector3(cells_x[i], FLOOR_Y, MAIN_Z)
		hatch.drop_to = Transform3D(Basis.IDENTITY, Vector3(cells_x[i], 0.1, 2.9))
		add_child(hatch)
		cell_hatches.append(hatch)
	office_hatch = VentHatch.new()
	office_hatch.name = "OfficeHatch"
	office_hatch.into_office = true
	office_hatch.position = Vector3(STUBS[exit_stub], FLOOR_Y, OFFICE_Z)
	office_hatch.drop_to = Transform3D(Basis(Vector3.UP, PI), Vector3(STUBS[exit_stub], 0.1, OFFICE_Z))
	add_child(office_hatch)


func _slab(body: StaticBody3D, at: Vector3, size: Vector3) -> void:
	_box(body, Vector3(at.x, FLOOR_Y - THICK / 2, at.z), Vector3(size.x, THICK, size.z))
	_box(body, Vector3(at.x, FLOOR_Y + HEIGHT + THICK / 2, at.z), Vector3(size.x, THICK, size.z))


func _box(body: StaticBody3D, at: Vector3, size: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = at
	body.add_child(shape)
	var mesh := MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = METAL
	material.metallic = 0.4
	cube.material = material
	mesh.mesh = cube
	mesh.position = at
	body.add_child(mesh)


## Where a duct's start is over the cell at `cell_x`, facing along the main run, in the lot's space.
func start_over(cell_x: float) -> Transform3D:
	return Transform3D(Basis(Vector3.UP, PI / 2), Vector3(cell_x, FLOOR_Y + 0.05, MAIN_Z))


## Whether a point in the world is inside the duct.
func contains(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	if local.y < FLOOR_Y - 0.3 or local.y > FLOOR_Y + HEIGHT:
		return false
	var half := WIDTH / 2
	if absf(local.z - MAIN_Z) <= half and local.x >= MAIN_FROM and local.x <= MAIN_TO:
		return true
	return STUBS.any(func(x: float) -> bool:
		return absf(local.x - x) <= half and local.z >= STUB_END and local.z <= MAIN_Z)
