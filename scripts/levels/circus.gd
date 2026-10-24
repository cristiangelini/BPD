class_name Circus
extends CrimeScenePlace

## The Cascabel Brothers' circus (escena-circo.md, step 2, decision 130), on its lot in the city with the front to +Z:
## the big striped tent with its entrance at the front, the ring of sawdust inside with its low curb, the stands
## around the back half, the trapeze over the ring and the cannon by its side. Behind the tent, the clowns' six
## caravans in a row; on one side, the seal's empty pool with its tap, and on the other, the costume trunk. In the
## ring, the six clowns alike (ClownTraits.draw with the case seed) practice in a circle facing out, the ringmaster
## (Ringmaster) waits at the ring's gap and Zulema the tamer (CircusTamer) stands by the pool. It's the circus case's
## CrimeScenePlace (the clues come in a later step). Every number here is (propuesta).

## The lot's floor: width (x) and depth (z), like its size in CityLayout.PLACES.
const SIZE := Vector2(40, 30)
const TENT_AT := Vector3(0, 0, 4)
const TENT_RADIUS := 9.0
const WALL_HEIGHT := 3.0
const ROOF_HEIGHT := 5.0
## The tent's wall in this many pieces around; the entrance is the front's piece and ENTRANCE_SIDE more each side.
const WALL_PIECES := 24
const ENTRANCE_SIDE := 1
const RING_RADIUS := 4.5
const CURB_HEIGHT := 0.4
## The stands: three steps around the back half, from this radius out.
const STANDS_FROM := 6.0
const STAND_STEP := Vector2(0.8, 0.45)
const STANDS_ARC := 2.4
## The trapeze: two poles beside the ring, up to the roof, and the bar hanging between them.
const TRAPEZE_X := 3.5
const TRAPEZE_HEIGHT := 2.3
const CANNON_AT := Vector3(6.6, 0, 7.5)
## The clowns' caravans behind the tent, in a row, their doors to the front.
const CARAVANS: Array[Vector3] = [
	Vector3(-15, 0, -11), Vector3(-9, 0, -11), Vector3(-3, 0, -11), Vector3(3, 0, -11), Vector3(9, 0, -11),
	Vector3(15, 0, -11),
]
const CARAVAN_SIZE := Vector3(4.0, 2.4, 2.2)
const POOL_AT := Vector3(-15, 0, 6)
const POOL_RADIUS := 1.8
const TRUNK_AT := Vector3(15.5, 0, 3)
const TRUNK_SIZE := Vector3(1.3, 0.75, 0.8)
const SAWDUST := Color(0.82, 0.68, 0.45)
const DIRT := Color(0.55, 0.47, 0.36)
const RED := Color(0.86, 0.18, 0.2)
const WHITE := Color(0.96, 0.95, 0.9)
const YELLOW := Color(0.98, 0.8, 0.25)
const WOOD := Color(0.55, 0.38, 0.24)
const METAL := Color(0.35, 0.37, 0.42)
const POOL_TILE := Color(0.55, 0.78, 0.88)
## Where the clowns practice: a circle inside the ring, each facing out.
const CLOWNS_RADIUS := 2.6
const RINGMASTER_AT := TENT_AT + Vector3(1.6, 0, RING_RADIUS + 0.9)
const TAMER_AT := POOL_AT + Vector3(2.6, 0, 0.4)
## The bucket with the sponges for the clowns' makeup, inside the tent by the entrance.
const BUCKET_AT := TENT_AT + Vector3(-3.0, 0, 6.6)
const SPONGES := 2
## Of the clowns, how many gloves at most one has on under the first (the infinite glove trick), by the seed.
const MAX_SPARE_GLOVES := 2
## The pad of numbered signs, one per clown, on a stool by the bucket.
const SIGNS_AT := BUCKET_AT + Vector3(1.2, 0, 0)
const CARAVAN_COLORS: Array[Color] = [
	Color(0.95, 0.55, 0.7), Color(0.45, 0.82, 0.65), Color(0.98, 0.82, 0.3), Color(0.68, 0.58, 0.9),
	Color(0.5, 0.7, 0.95), Color(0.98, 0.6, 0.35),
]

var clowns: Array[CircusClown] = []
var ringmaster: Ringmaster
## "¡El truco!": the clowns swap spots every so often while the case is on (ClownTrick).
var trick: ClownTrick
## Who wears which sign: number -> clown index, and the last clown each number was on.
var signs := {}
var last_wearer := {}
var tamer: CircusTamer
var _builder: PlaceBuilder


func _ready() -> void:
	add_to_group("circus")
	variant = "circus"
	_builder = PlaceBuilder.new(self)
	_builder.mesh_box(Vector3(0, 0.04, 0), Vector3(SIZE.x, 0.02, SIZE.y), DIRT)
	_tent()
	_ring()
	_stands()
	_trapeze()
	_cannon()
	for i in CARAVANS.size():
		_caravan(CARAVANS[i], i)
	_pool()
	_trunk()
	_people()
	_bucket()
	_sign_pad()


## The six clowns in a circle in the ring, the ringmaster at its gap and Zulema by the pool.
func _people() -> void:
	var traits := ClownTraits.draw(case_seed)
	for i in traits.size():
		var turn := (i + 0.5) * TAU / traits.size()
		var clown := CircusClown.new()
		clown.name = "Clown%d" % i
		clown.traits = traits[i]
		clown.index = i
		clown.position = TENT_AT + _around(turn, CLOWNS_RADIUS)
		clown.rotation.y = turn
		clown.circus = self
		add_child(clown)
		clowns.append(clown)
	ringmaster = Ringmaster.new()
	ringmaster.name = "Ringmaster"
	ringmaster.position = RINGMASTER_AT
	add_child(ringmaster)
	tamer = CircusTamer.new()
	tamer.name = "Tamer"
	tamer.position = TAMER_AT
	add_child(tamer)


## The round wall in red and white pieces, open at the front, under a red cone of a roof, with the circus's name
## over the entrance.
func _tent() -> void:
	var piece := TAU * TENT_RADIUS / WALL_PIECES + 0.05
	for i in WALL_PIECES:
		if _is_entrance(i):
			continue
		var turn := i * TAU / WALL_PIECES
		var at := TENT_AT + _around(turn, TENT_RADIUS) + Vector3(0, WALL_HEIGHT / 2, 0)
		_turned_box(at, Vector3(piece, WALL_HEIGHT, 0.15), turn, RED if i % 2 == 0 else WHITE)
	var roof := CylinderMesh.new()
	roof.top_radius = 0.25
	roof.bottom_radius = TENT_RADIUS + 0.4
	roof.height = ROOF_HEIGHT
	_builder.mesh(roof, TENT_AT + Vector3(0, WALL_HEIGHT + ROOF_HEIGHT / 2, 0), RED)
	var band := CylinderMesh.new()
	band.top_radius = TENT_RADIUS + 0.45
	band.bottom_radius = TENT_RADIUS + 0.45
	band.height = 0.4
	# A ring around the roof's edge, not a lid over the tent.
	band.cap_top = false
	band.cap_bottom = false
	_builder.mesh(band, TENT_AT + Vector3(0, WALL_HEIGHT + 0.1, 0), YELLOW)
	var banner := Label3D.new()
	banner.name = "Banner"
	banner.text = "SIGN_CIRCUS"
	banner.font_size = 96
	banner.pixel_size = 0.01
	banner.outline_size = 18
	banner.double_sided = false
	banner.position = TENT_AT + Vector3(0, WALL_HEIGHT + 0.9, TENT_RADIUS + 0.6)
	add_child(banner)
	_builder.light(TENT_AT + Vector3(0, WALL_HEIGHT - 0.3, 0))


## The ring of sawdust in the tent's middle, with a low curb around it and a gap to walk in from the entrance.
func _ring() -> void:
	var floor_mesh := CylinderMesh.new()
	floor_mesh.top_radius = RING_RADIUS
	floor_mesh.bottom_radius = RING_RADIUS
	floor_mesh.height = 0.02
	_builder.mesh(floor_mesh, TENT_AT + Vector3(0, 0.06, 0), SAWDUST)
	var pieces := 20
	var piece := TAU * RING_RADIUS / pieces + 0.05
	for i in pieces:
		if i == 0:
			continue
		var turn := i * TAU / pieces
		var at := TENT_AT + _around(turn, RING_RADIUS) + Vector3(0, CURB_HEIGHT / 2, 0)
		_turned_box(at, Vector3(piece, CURB_HEIGHT, 0.3), turn, RED if i % 2 == 0 else YELLOW)


## Three steps of benches around the back half of the tent, facing the ring.
func _stands() -> void:
	var pieces := 9
	for row in 3:
		var radius := STANDS_FROM + (row + 0.5) * STAND_STEP.x
		var height := (row + 1) * STAND_STEP.y
		var piece := STANDS_ARC * radius / pieces + 0.05
		for i in pieces:
			var turn := PI - STANDS_ARC / 2 + (i + 0.5) * STANDS_ARC / pieces
			var at := TENT_AT + _around(turn, radius) + Vector3(0, height / 2, 0)
			_turned_box(at, Vector3(piece, height, STAND_STEP.x), turn, WOOD.lightened(0.1 * row))


## Two poles beside the ring with the trapeze's bar hanging between them on two ropes.
func _trapeze() -> void:
	var top := WALL_HEIGHT - 0.1
	for x: float in [-TRAPEZE_X, TRAPEZE_X]:
		_builder.box(TENT_AT + Vector3(x, top / 2, 0), Vector3(0.15, top, 0.15), METAL)
	_builder.mesh_box(TENT_AT + Vector3(0, top, 0), Vector3(TRAPEZE_X * 2, 0.08, 0.08), METAL)
	for x: float in [-0.5, 0.5]:
		_builder.mesh_box(TENT_AT + Vector3(x, (TRAPEZE_HEIGHT + top) / 2, 0), Vector3(0.03, top - TRAPEZE_HEIGHT, 0.03),
			WHITE)
	_builder.mesh_box(TENT_AT + Vector3(0, TRAPEZE_HEIGHT, 0), Vector3(1.1, 0.06, 0.06), YELLOW)


## The human cannon on its cart beside the ring, aimed up at the roof.
func _cannon() -> void:
	_builder.box(CANNON_AT + Vector3(0, 0.35, 0), Vector3(1.2, 0.7, 2.0), RED)
	var barrel := CylinderMesh.new()
	barrel.top_radius = 0.35
	barrel.bottom_radius = 0.45
	barrel.height = 2.6
	_builder.mesh(barrel, CANNON_AT + Vector3(0, 1.5, 0.3), METAL, Vector3(-0.7, 0, 0))
	var wheel := CylinderMesh.new()
	wheel.top_radius = 0.45
	wheel.bottom_radius = 0.45
	wheel.height = 0.15
	for x: float in [-0.7, 0.7]:
		_builder.mesh(wheel, CANNON_AT + Vector3(x, 0.45, 0), YELLOW, Vector3(0, 0, PI / 2))


## A clown's caravan: its box on four wheels, a roof, a door and a window to the front, and its number.
func _caravan(at: Vector3, index: int) -> void:
	var color := CARAVAN_COLORS[index % CARAVAN_COLORS.size()]
	var lift := 0.45
	_builder.box(at + Vector3(0, lift + CARAVAN_SIZE.y / 2, 0), CARAVAN_SIZE, color)
	_builder.mesh_box(at + Vector3(0, lift + CARAVAN_SIZE.y + 0.08, 0),
		Vector3(CARAVAN_SIZE.x + 0.2, 0.16, CARAVAN_SIZE.z + 0.2), WHITE)
	var front := CARAVAN_SIZE.z / 2 + 0.03
	_builder.mesh_box(at + Vector3(-0.9, lift + 0.95, front), Vector3(0.8, 1.8, 0.05), color.darkened(0.4))
	_builder.mesh_box(at + Vector3(0.8, lift + 1.5, front), Vector3(1.0, 0.6, 0.05), Color(0.6, 0.8, 0.95))
	var wheel := CylinderMesh.new()
	wheel.top_radius = 0.4
	wheel.bottom_radius = 0.4
	wheel.height = 0.2
	for x: float in [-1.3, 1.3]:
		for z: float in [-1.0, 1.0]:
			_builder.mesh(wheel, at + Vector3(x, 0.4, z * (CARAVAN_SIZE.z / 2)), Color(0.15, 0.15, 0.17),
				Vector3(PI / 2, 0, 0))
	var number := Label3D.new()
	number.name = "Caravan%d" % index
	number.text = str(index + 1)
	number.font_size = 96
	number.pixel_size = 0.006
	number.outline_size = 14
	number.position = at + Vector3(0.8, lift + 2.1, front + 0.02)
	add_child(number)


## Galleta's pool, empty: a low round rim around a tiled floor, with its tap on the rim.
func _pool() -> void:
	var tiles := CylinderMesh.new()
	tiles.top_radius = POOL_RADIUS
	tiles.bottom_radius = POOL_RADIUS
	tiles.height = 0.02
	_builder.mesh(tiles, POOL_AT + Vector3(0, 0.06, 0), POOL_TILE)
	var pieces := 10
	var piece := TAU * POOL_RADIUS / pieces + 0.05
	for i in pieces:
		var turn := i * TAU / pieces
		_turned_box(POOL_AT + _around(turn, POOL_RADIUS) + Vector3(0, 0.3, 0), Vector3(piece, 0.6, 0.2), turn, WHITE)
	_builder.mesh_box(POOL_AT + Vector3(0, 0.75, -POOL_RADIUS), Vector3(0.12, 0.3, 0.12), METAL)


## The costume trunk on the tent's other side, its lid shut.
func _trunk() -> void:
	_builder.box(TRUNK_AT + Vector3(0, TRUNK_SIZE.y / 2, 0), TRUNK_SIZE, WOOD)
	_builder.mesh_box(TRUNK_AT + Vector3(0, TRUNK_SIZE.y + 0.03, 0), TRUNK_SIZE + Vector3(0.06, -TRUNK_SIZE.y + 0.06, 0.06),
		YELLOW)


## A bucket of soapy water with the sponges on its rim.
func _bucket() -> void:
	var bucket := CylinderMesh.new()
	bucket.top_radius = 0.22
	bucket.bottom_radius = 0.18
	bucket.height = 0.35
	_builder.mesh(bucket, BUCKET_AT + Vector3(0, 0.18, 0), METAL)
	var shape := _builder.body(BUCKET_AT + Vector3(0, 0.18, 0))
	_builder.shape(shape, Vector3(0.4, 0.35, 0.4))
	var water := CylinderMesh.new()
	water.top_radius = 0.2
	water.bottom_radius = 0.2
	water.height = 0.02
	_builder.mesh(water, BUCKET_AT + Vector3(0, 0.3, 0), POOL_TILE)
	for i in SPONGES:
		var sponge := ClownSponge.new()
		sponge.name = "Sponge%d" % i
		sponge.position = BUCKET_AT + Vector3(-0.12 + i * 0.24, 0.42, 0)
		add_child(sponge)


## A stool with the six numbered signs stacked on it.
func _sign_pad() -> void:
	_builder.box(SIGNS_AT + Vector3(0, 0.25, 0), Vector3(0.4, 0.5, 0.4), WOOD)
	for i in ClownTraits.COUNT:
		var sign := ClownSign.new()
		sign.name = "Sign%d" % i
		sign.number = i
		sign.position = SIGNS_AT + Vector3(0, 0.52 + i * 0.03, 0)
		sign.rotation.x = -PI / 2
		add_child(sign)


## Sticks sign `number` on a clown's back; the one he had falls at his feet. What he shows already (his own hair,
## his real foot) goes to that file right away.
func stick_sign(number: int, clown: CircusClown) -> void:
	var had := sign_of(clown.index)
	if had == number:
		return
	if had >= 0:
		drop_sign(clown)
	signs[number] = clown.index
	last_wearer[number] = clown.index
	clown.show_sign(number)
	clown.say(tr("CLOWN_SIGNED") % (number + 1))
	if clown.case:
		if not clown.wig_on:
			clown.case.clown_part(clown.index, "hair")
		if not clown.shoe_on:
			clown.case.clown_part(clown.index, "shoe")


## A clown's sign falls off at his feet, a sign to pick up again.
func drop_sign(clown: CircusClown) -> void:
	var number := sign_of(clown.index)
	if number < 0:
		return
	signs.erase(number)
	clown.show_sign(-1)
	var sign := ClownSign.new()
	sign.name = "Sign%d" % number
	sign.number = number
	add_child(sign)
	sign.global_position = clown.to_global(Vector3(0, 0.1, -0.7))


## The number of the sign on a clown's back, or -1.
func sign_of(clown_index: int) -> int:
	for number: int in signs:
		if signs[number] == clown_index:
			return number
	return -1


## The clown wearing a sign now, or the last one who did (-1 if nobody ever did).
func wearer(number: int) -> int:
	return signs.get(number, last_wearer.get(number, -1))


## The clowns and Zulema know the case: one clown (by the seed) won't take off his wig for nothing, and each has his
## spare gloves. The clues come in a later step.
func set_up_case(case: CrimeSceneCase) -> void:
	var stubborn := hash("stubborn clown %d" % case.case_seed) % clowns.size()
	for clown in clowns:
		clown.case = case
		clown.stubborn = clown.index == stubborn
		clown.spare_gloves = hash(["clown gloves", case.case_seed, clown.index]) % (MAX_SPARE_GLOVES + 1)
	tamer.case = case
	tamer.knows = case.plan.clues.has("witness")
	trick = ClownTrick.new()
	trick.name = "Trick"
	trick.circus = self
	trick.case = case
	add_child(trick)


## Whether a wall piece is part of the entrance, at the front (+Z).
func _is_entrance(i: int) -> bool:
	return mini(i, WALL_PIECES - i) <= ENTRANCE_SIDE


## A point at `turn` around a circle of `radius`, 0 at the front (+Z).
func _around(turn: float, radius: float) -> Vector3:
	return Vector3(sin(turn), 0, cos(turn)) * radius


## A solid box turned around Y so its width runs along the circle at `turn`.
func _turned_box(at: Vector3, size: Vector3, turn: float, color: Color) -> void:
	var piece := _builder.body(at)
	piece.rotation.y = turn
	_builder.shape(piece, size)
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	var instance := MeshInstance3D.new()
	instance.mesh = box_mesh
	instance.material_override = _builder.material(color)
	piece.add_child(instance)


func at_scene(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) <= SIZE.x / 2 and absf(local.z) <= SIZE.y / 2


## Whether a point in the world (ignoring height) is inside the tent.
func in_tent(world: Vector3) -> bool:
	var local := to_local(world) - TENT_AT
	return Vector2(local.x, local.z).length() <= TENT_RADIUS


func suspect(index: int) -> CollisionObject3D:
	return clowns[index]


func witness_offended() -> bool:
	return tamer.offended


func offend_witness() -> void:
	tamer.offended = true


func shouted_by(cop: Cop) -> void:
	tamer.shouted_by(cop)
