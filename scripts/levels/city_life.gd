class_name CityLife
extends Node3D

## The living city (ciudad-viva.md, step 2): raised sidewalks with curbs, crosswalks, lamps, trash bins, benches,
## hydrants, taller buildings downtown with fire escapes and water towers, and dead-end alleys with dumpsters, crates
## and a chain-link fence. Cars and walkers come in the next step, and the street events after them.
## Every number here is (propuesta).

const CURB := 0.15
## The group of the sidewalks' bodies.
const SIDEWALKS := "sidewalks"
const BRICK := Color(0.58, 0.3, 0.24)
const BRICK_DARK := Color(0.42, 0.22, 0.18)
const IRON := Color(0.16, 0.17, 0.19)
const BIN := Color(0.2, 0.42, 0.28)
const DUMPSTER := Color(0.18, 0.4, 0.55)
const BAG := Color(0.1, 0.1, 0.12)
const WOOD := Color(0.6, 0.45, 0.28)
const HYDRANT := Color(0.85, 0.15, 0.12)
const STRIPE := Color(0.92, 0.92, 0.9)
const SIDEWALK_TOP := Color(0.63, 0.61, 0.58)
const CURB_COLOR := Color(0.7, 0.68, 0.64)
const LAMP_GLOW := Color(1.0, 0.92, 0.7)
const FENCE := Color(0.55, 0.58, 0.6)
const TANK := Color(0.5, 0.36, 0.24)
## Blocks with a dead-end alley, and the side it opens to: blocks whose middle no place reaches (tested).
const ALLEYS := [[Vector2i(2, 4), "e"], [Vector2i(6, 3), "w"], [Vector2i(3, 1), "e"], [Vector2i(5, 4), "w"]]
const ALLEY_WIDTH := 4.5
const ALLEY_LENGTH := 24.0

var _materials := {}
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 7
	for block in CityLayout.blocks():
		_sidewalk(block)
	for c in CityLayout.crossings(true):
		_crosswalks(Vector3(CityLayout.street_x(c.x), 0, CityLayout.street_z(c.y)))
	for alley: Array in ALLEYS:
		_alley(alley[0], alley[1])
	for lot: Dictionary in CityLayout.fillers():
		if CityLayout.barrio_kind(lot.block) == "building":
			_fire_escape(lot)
			if _rng.randf() < 0.6:
				lot = _tower(lot)
		if CityLayout.barrio_kind(lot.block) != "house" and _rng.randf() < 0.35:
			_water_tower(lot)
	var yards := CityYards.new()
	yards.name = "Yards"
	add_child(yards)


## The materials that light up at night: the lamp heads, and the windows of the alleys and the taller floors.
func lamp_materials() -> Array[StandardMaterial3D]:
	return [_material(LAMP_GLOW, true)]


func window_materials() -> Array[StandardMaterial3D]:
	return [_material(City.GLASS)]


## An alley's footprint on the ground (x, z), its two walls included, for overlap checks.
static func alley_rect(block: Vector2i, side: String) -> Rect2:
	var normal := CityLayout.side_normal(side)
	var mouth := CityLayout.block_center(block) + normal * (CityLayout.BLOCK / 2 - CityLayout.SIDEWALK)
	var far := mouth - normal * (ALLEY_LENGTH + 1.0)
	var across := Vector3(-normal.z, 0, normal.x) * (ALLEY_WIDTH / 2 + 6.0)
	var rect := Rect2(Vector2(mouth.x, mouth.z), Vector2.ZERO)
	for corner: Vector3 in [mouth + across, mouth - across, far + across, far - across]:
		rect = rect.expand(Vector2(corner.x, corner.z))
	return rect


## The raised sidewalk ring with its curb, and the street furniture along it: lamps, bins, benches and hydrants.
func _sidewalk(block: Vector2i) -> void:
	var c := CityLayout.block_center(block)
	var half := CityLayout.BLOCK / 2
	var w := CityLayout.SIDEWALK
	for side in 4:
		var normal: Vector3 = [Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK, Vector3.LEFT][side]
		var tangent := Vector3(-normal.z, 0, normal.x)
		var along_x := absf(normal.z) > 0.5
		var length := CityLayout.BLOCK if along_x else CityLayout.BLOCK - w * 2
		var slab := Vector3(length, CURB, w) if along_x else Vector3(w, CURB, length)
		# What rolls on the sidewalks steps up these (SuspectCar.climb_curbs).
		_box(c + normal * (half - w / 2) + Vector3.UP * CURB / 2, slab, SIDEWALK_TOP).add_to_group(SIDEWALKS)
		var curb := Vector3(CityLayout.BLOCK, CURB + 0.02, 0.25) if along_x else Vector3(0.25, CURB + 0.02, CityLayout.BLOCK)
		_mesh_box(c + normal * (half - 0.125) + Vector3.UP * (CURB + 0.02) / 2, curb, CURB_COLOR)
		var edge := c + normal * (half - 0.6)
		for k in 3:
			var along := (k - 1) * 20.0 + 4.0
			_lamp(edge + tangent * along, normal)
		for along: float in [-14.0, 13.0]:
			if _rng.randf() < 0.75:
				_trash_bin(edge + tangent * (along + _rng.randf_range(-2, 2)))
		if _rng.randf() < 0.4:
			_bench(c + normal * (half - w + 0.5) + tangent * _rng.randf_range(-8, 8), normal)
		if _rng.randf() < 0.5:
			_hydrant(edge + tangent * _rng.randf_range(-25, 25))


## Zebra stripes across the four streets that meet at a crossing.
func _crosswalks(at: Vector3) -> void:
	var gap := CityLayout.STREET / 2 + 1.2
	for dir: Vector3 in [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]:
		var across := Vector3(-dir.z, 0, dir.x)
		for k in 6:
			var spot := at + dir * gap + across * ((k - 2.5) * 1.8)
			var size := Vector3(0.9, 0.01, 2.0) if absf(dir.z) > 0.5 else Vector3(2.0, 0.01, 0.9)
			_mesh_box(spot + Vector3.UP * 0.02, size, STRIPE)


func _lamp(at: Vector3, normal: Vector3) -> void:
	_mesh_box(at + Vector3.UP * (CURB + 2.5), Vector3(0.14, 5.0, 0.14), City.POLE)
	_mesh_box(at + Vector3.UP * (CURB + 4.95) + normal * 0.6, Vector3(0.1, 0.1, 0.1) + normal.abs() * 1.1, City.POLE)
	_mesh_box(at + Vector3.UP * (CURB + 4.8) + normal * 1.1, Vector3(0.5, 0.2, 0.5), LAMP_GLOW, null, true)


func _trash_bin(at: Vector3) -> void:
	var can := CylinderMesh.new()
	can.top_radius = 0.32
	can.bottom_radius = 0.28
	can.height = 0.95
	_mesh(can, at + Vector3.UP * (CURB + 0.48), BIN)
	var lid := CylinderMesh.new()
	lid.top_radius = 0.2
	lid.bottom_radius = 0.36
	lid.height = 0.12
	_mesh(lid, at + Vector3.UP * (CURB + 1.0), BIN.darkened(0.3))


func _bench(at: Vector3, normal: Vector3) -> void:
	var along_x := absf(normal.z) > 0.5
	var seat := Vector3(1.8, 0.08, 0.5) if along_x else Vector3(0.5, 0.08, 1.8)
	_mesh_box(at + Vector3.UP * (CURB + 0.45), seat, WOOD)
	var back := Vector3(1.8, 0.5, 0.08) if along_x else Vector3(0.08, 0.5, 1.8)
	_mesh_box(at + Vector3.UP * (CURB + 0.75) - normal * 0.25, back, WOOD)
	_mesh_box(at + Vector3.UP * (CURB + 0.22), seat * Vector3(0.9, 5.0, 0.6), IRON)


func _hydrant(at: Vector3) -> void:
	var body := CylinderMesh.new()
	body.top_radius = 0.14
	body.bottom_radius = 0.17
	body.height = 0.6
	_mesh(body, at + Vector3.UP * (CURB + 0.3), HYDRANT)
	var cap := SphereMesh.new()
	cap.radius = 0.15
	cap.height = 0.2
	_mesh(cap, at + Vector3.UP * (CURB + 0.62), HYDRANT)
	_mesh_box(at + Vector3.UP * (CURB + 0.38), Vector3(0.45, 0.09, 0.09), HYDRANT)


## A dead-end alley cut into a block from `side`: two brick walls with fire escapes, a brick wall and a chain-link
## fence at the end, dumpsters, crates, trash bags and puddles in the way.
func _alley(block: Vector2i, side: String) -> void:
	var root := Node3D.new()
	root.position = CityLayout.block_center(block) + CityLayout.side_normal(side) * (CityLayout.BLOCK / 2 - CityLayout.SIDEWALK)
	root.rotation.y = CityLayout.side_turn(side)
	add_child(root)
	# Local space: the alley runs from the sidewalk (z = 0) into the block (-z), walls at x = +-width/2.
	var half := ALLEY_WIDTH / 2
	for x: float in [-1.0, 1.0]:
		var height := 14.0 if x < 0 else 11.0
		_box(Vector3(x * (half + 3), height / 2, -ALLEY_LENGTH / 2), Vector3(6, height, ALLEY_LENGTH), BRICK, root)
		for f in range(1, floori(height / 3.2)):
			for k in 4:
				_mesh_box(Vector3(x * (half + 0.02), f * 3.2 + 0.4, -3.5 - k * 5.5), Vector3(0.06, 1.3, 1.0),
					City.GLASS, root)
		_alley_fire_escape(root, x * half, height)
	_box(Vector3(0, 4, -ALLEY_LENGTH - 0.5), Vector3(ALLEY_WIDTH + 2, 8, 1), BRICK_DARK, root)
	# The chain-link fence: posts, a top rail and a see-through mesh. It climbs (Climbable).
	var fence_z := -ALLEY_LENGTH + 6
	var climb := Climbable.new()
	climb.top = 3.0
	climb.position = Vector3(0, 1.5, fence_z)
	root.add_child(climb)
	var wall := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(ALLEY_WIDTH, 3.0, 0.1)
	wall.shape = box
	climb.add_child(wall)
	for x: float in [-half + 0.1, 0.0, half - 0.1]:
		_mesh_box(Vector3(x, 1.5, fence_z), Vector3(0.08, 3.0, 0.08), FENCE, root)
	_mesh_box(Vector3(0, 3.0, fence_z), Vector3(ALLEY_WIDTH, 0.06, 0.06), FENCE, root)
	var net := BoxMesh.new()
	net.size = Vector3(ALLEY_WIDTH, 2.9, 0.02)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(FENCE, 0.35)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var fence := MeshInstance3D.new()
	fence.mesh = net
	fence.material_override = material
	fence.position = Vector3(0, 1.5, fence_z)
	root.add_child(fence)
	_box(Vector3(half - 1.0, 0.7, -6), Vector3(1.6, 1.4, 2.6), DUMPSTER, root)
	_mesh_box(Vector3(half - 1.0, 1.45, -6), Vector3(1.7, 0.1, 2.7), DUMPSTER.darkened(0.3), root)
	_box(Vector3(-half + 0.9, 0.7, -14), Vector3(1.6, 1.4, 2.6), DUMPSTER.lerp(BIN, 0.6), root)
	for k in 6:
		# Against the walls, so the middle stays a way through (the purse snatcher runs it).
		var against := 1.0 if k % 2 == 0 else -1.0
		var crate := Vector3(against * _rng.randf_range(0.9, half - 0.4), 0.3, -9.0 - _rng.randf() * 10.0)
		_box(crate, Vector3(0.6, 0.6, 0.6), WOOD, root)
	for k in 8:
		var bag := SphereMesh.new()
		bag.radius = 0.35
		bag.height = 0.6
		_mesh(bag, Vector3(_rng.randf_range(-half + 0.4, half - 0.4), 0.28, -2.0 - _rng.randf() * 20.0), BAG, root)
	_mesh_box(Vector3(0.4, 0.012, -11), Vector3(1.6, 0.01, 1.1), Color(0.25, 0.3, 0.38), root)
	_mesh_box(Vector3(0, 0.008, -ALLEY_LENGTH / 2), Vector3(ALLEY_WIDTH, 0.01, ALLEY_LENGTH), City.ROAD.darkened(0.2), root)
	_steam(root, Vector3(-0.6, 0.0, -17))


## Zigzag iron landings and ladders up an alley wall, from the first floor to the roof.
func _alley_fire_escape(root: Node3D, x: float, height: float) -> void:
	var out := signf(-x)
	for f in range(1, floori(height / 3.2)):
		var y := f * 3.2
		var landing := Vector3(x + out * 0.6, y, -6.5)
		_mesh_box(landing, Vector3(1.2, 0.06, 3.0), IRON, root)
		_mesh_box(landing + Vector3(out * 0.6, 0.5, 0), Vector3(0.04, 1.0, 3.0), IRON, root)
		var ladder := Node3D.new()
		ladder.position = landing + Vector3(0, 1.6, 0)
		ladder.rotation.x = 0.9 if f % 2 == 0 else -0.9
		root.add_child(ladder)
		_mesh_box(Vector3.ZERO, Vector3(0.7, 0.05, 3.6), IRON, ladder)


## Iron landings on a tall building's front, the way city buildings have them.
func _fire_escape(lot: Dictionary) -> void:
	var root := Node3D.new()
	root.position = CityLayout.lot_center(lot.block, lot.side, lot.along, lot.size.z)
	root.rotation.y = CityLayout.side_turn(lot.side)
	add_child(root)
	var front: float = lot.size.z / 2 + 0.55
	for f in range(1, floori(lot.size.y / 3.0)):
		var y := f * 3.0 + 0.2
		_mesh_box(Vector3(2.5, y, front), Vector3(3.0, 0.06, 1.1), IRON, root)
		_mesh_box(Vector3(2.5, y + 0.5, front + 0.55), Vector3(3.0, 0.04, 0.04), IRON, root)
		_mesh_box(Vector3(2.5, y + 0.25, front + 0.55), Vector3(3.0, 0.04, 0.04), IRON, root)
		var ladder := Node3D.new()
		ladder.position = Vector3(2.5, y + 1.5, front)
		ladder.rotation.z = 0.7 if f % 2 == 0 else -0.7
		root.add_child(ladder)
		_mesh_box(Vector3.ZERO, Vector3(3.4, 0.05, 0.6), IRON, ladder)


## More floors over a building, set back a little, so the middle of the city has a skyline. Returns the lot as tall
## as it ends up, for what goes on its roof.
func _tower(lot: Dictionary) -> Dictionary:
	var extra := float(_rng.randi_range(2, 6) * 3)
	var root := Node3D.new()
	root.position = CityLayout.lot_center(lot.block, lot.side, lot.along, lot.size.z)
	root.rotation.y = CityLayout.side_turn(lot.side)
	add_child(root)
	var size: Vector3 = lot.size
	var top := Vector3(size.x - 1.0, extra, size.z - 1.0)
	var color: Color = lot.color.darkened(0.08)
	_box(Vector3(0, size.y + extra / 2, -0.5), top, color, root)
	_mesh_box(Vector3(0, size.y + extra + 0.15, -0.5), top + Vector3(0.4, 0.3 - extra, 0.4), color.darkened(0.35), root)
	for f in int(extra / 3.0):
		for c in 3:
			_mesh_box(Vector3((c - 1) * 4.0, size.y + 1.6 + f * 3.0, top.z / 2 - 0.45), Vector3(1.4, 1.6, 0.1),
				City.GLASS, root)
	var taller := lot.duplicate()
	taller.size = size + Vector3(0, extra, 0)
	return taller


## A wooden water tank on legs on a roof.
func _water_tower(lot: Dictionary) -> void:
	var at := CityLayout.lot_center(lot.block, lot.side, lot.along, lot.size.z) + Vector3(_rng.randf_range(-2, 2), lot.size.y, 0)
	for leg: Vector3 in [Vector3(-0.9, 0, -0.9), Vector3(0.9, 0, -0.9), Vector3(-0.9, 0, 0.9), Vector3(0.9, 0, 0.9)]:
		_mesh_box(at + leg + Vector3.UP * 1.0, Vector3(0.12, 2.0, 0.12), IRON)
	var tank := CylinderMesh.new()
	tank.top_radius = 1.3
	tank.bottom_radius = 1.3
	tank.height = 2.4
	_mesh(tank, at + Vector3.UP * 3.2, TANK)
	var hat := CylinderMesh.new()
	hat.top_radius = 0.05
	hat.bottom_radius = 1.45
	hat.height = 0.9
	_mesh(hat, at + Vector3.UP * 4.85, TANK.darkened(0.35))


## Steam coming up from a manhole.
func _steam(root: Node3D, at: Vector3) -> void:
	var cover := CylinderMesh.new()
	cover.top_radius = 0.4
	cover.bottom_radius = 0.4
	cover.height = 0.02
	_mesh(cover, at + Vector3.UP * 0.015, IRON, root)
	var puffs := CPUParticles3D.new()
	puffs.position = at
	puffs.amount = 24
	puffs.lifetime = 3.0
	puffs.direction = Vector3.UP
	puffs.spread = 12.0
	puffs.initial_velocity_min = 0.6
	puffs.initial_velocity_max = 1.0
	puffs.gravity = Vector3(0.1, 0.3, 0)
	puffs.scale_amount_min = 0.6
	puffs.scale_amount_max = 1.6
	var puff := SphereMesh.new()
	puff.radius = 0.4
	puff.height = 0.8
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.95, 0.95, 0.95, 0.25)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	puff.material = material
	puffs.mesh = puff
	root.add_child(puffs)
	puffs.preprocess = 3.0


func _material(color: Color, glow := false) -> StandardMaterial3D:
	var key := [color, glow]
	if not _materials.has(key):
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.9
		if glow:
			material.emission_enabled = true
			material.emission = color
			material.emission_energy_multiplier = 0.8
		_materials[key] = material
	return _materials[key]


func _box(center: Vector3, size: Vector3, color: Color, parent: Node3D = null) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = center
	(parent if parent else self).add_child(body)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	_mesh_box(center, size, color, parent)
	return body


func _mesh_box(center: Vector3, size: Vector3, color: Color, parent: Node3D = null, glow := false) -> void:
	var box := BoxMesh.new()
	box.size = size
	_mesh(box, center, color, parent, glow)


func _mesh(mesh: Mesh, at: Vector3, color: Color, parent: Node3D = null, glow := false) -> void:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = _material(color, glow)
	instance.position = at
	(parent if parent else self).add_child(instance)
