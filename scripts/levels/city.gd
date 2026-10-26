class_name City
extends Node3D

## The open city (docs/diseno/ciudad.md, step 1): streets, blocks, the station and the closed fronts of the
## 10 raid places, built from CityLayout. The station opens, with its rooms inside (StationRooms); the cops appear
## in its guard room and walk or drive the patrol car around.

const GRASS := Color(0.45, 0.72, 0.3)
const ROAD := Color(0.32, 0.33, 0.36)
const SIDEWALK := Color(0.55, 0.53, 0.5)
const PAVED := Color(0.45, 0.43, 0.42)
const LINE := Color(0.95, 0.85, 0.3)
const GLASS := Color(0.25, 0.35, 0.5)
const DOOR := Color(0.4, 0.26, 0.18)
const PUMP := Color(0.85, 0.2, 0.18)
const SHUTTER := Color(0.55, 0.57, 0.6)
const ROOF := Color(0.86, 0.32, 0.26)
const TRUNK := Color(0.45, 0.3, 0.2)
const LEAVES := Color(0.3, 0.6, 0.25)
const HEDGE := Color(0.25, 0.5, 0.22)
const POLE := Color(0.25, 0.27, 0.3)
const STATION_WALL := Color(0.78, 0.84, 0.9)
const STATION_FLOOR := Color(0.62, 0.66, 0.7)
const BARS := Color(0.25, 0.27, 0.3)
## The interrogation wing inside: grey-green concrete and a dark floor, like in the movies.
const CONCRETE := Color(0.42, 0.46, 0.43)
const WING_FLOOR := Color(0.3, 0.31, 0.32)
const LAMP_LIGHT := Color(1.0, 0.92, 0.75)
const HEDGE_HEIGHT := 2.5

## The place whose case is on today: its own scene builds it, so the city leaves its lot empty.
@export var live_place := ""
## Whether the live place's scene brings the ground of its whole block (the grandpa's yard) or only its own lot.
@export var live_block_ground := true
## The crime scene's case opens a door from the comisario's office to the station's board room
## (escena-del-crimen.md); otherwise the board room stays shut.
@export var board_room_open := false
## Night at the station for the jailbreak (fuga.md): the station's lights turn low and warm.
@export var night := false

## The comisario in his office at the station; the case scene listens to him.
var comisario: Comisario
## The armero behind the armory counter.
var armero: Armero
## The two cells' barred doors, west cell first (StationRooms.CELL_DOORS).
var cell_doors: Array[CellDoor] = []
## Its own map, walking the city with no place in it (a chase).
var map: CityMap
var _materials := {}
var _built: Node3D


func _ready() -> void:
	_built = get_node_or_null("Built")
	if _built == null:
		_built = Node3D.new()
		_built.name = "Built"
		add_child(_built)
	_build()
	# Walking the city on its own (the test scene), it brings its own map; a case scene adds one with its place.
	if live_place == "":
		map = CityMap.new()
		add_child(map)
		map.setup(self, "", get_node_or_null("PatrolCar"))


func _build() -> void:
	var size := CityLayout.SIZE
	var land := Vector2(GolfLayout.CENTER.x + GolfLayout.HALF.x, HighwayLayout.OUTER.y) * 2 + Vector2.ONE * 40
	_box(Vector3(0, -0.1, 0), Vector3(land.x, 0.2, land.y), GRASS)
	_mesh_box(Vector3(0, 0.005, 0), Vector3(size.x, 0.01, size.y), ROAD)
	for k in CityLayout.COLUMNS + 1:
		_mesh_box(Vector3(CityLayout.street_x(k), 0.012, 0), Vector3(0.2, 0.01, size.y - CityLayout.STREET), LINE)
	for k in CityLayout.ROWS + 1:
		_mesh_box(Vector3(0, 0.012, CityLayout.street_z(k)), Vector3(size.x - CityLayout.STREET, 0.01, 0.2), LINE)
	for row in CityLayout.ROWS:
		for col in CityLayout.COLUMNS:
			_block(Vector2i(col, row))
	for p: Dictionary in CityLayout.PLACES:
		if p.id == live_place:
			continue
		var root := _building(p.block, p.side, p.along, p.size, p.color, p.sign, CityLayout.SHOPS.has(p.id),
			p.id == "grandpa", p.id == "station")
		if p.id == "station":
			_station_inside(root, p.size)
			_interrogation_wing(root, p.color)
		if p.id == "gas_station":
			_pumps(root, p.size)
	for lot: Dictionary in CityLayout.fillers():
		_building(lot.block, lot.side, lot.along, lot.size, lot.color, "", false,
			CityLayout.barrio_kind(lot.block) == "house")
	for i in range(1, CityLayout.COLUMNS):
		for j in range(1, CityLayout.ROWS):
			_corner(i, j)
	# A hedge around the city, open at the highway's ramps, and another one past the highway so nobody drives off
	# the edge, open on the east side at the golf club's gate (the club's own hedge closes it).
	_hedge(size / 2 + Vector2.ONE, HighwayLayout.SIDES)
	_hedge(HighwayLayout.OUTER + Vector2.ONE * 6, ["e"])
	var highway := Highway.new()
	highway.name = "Highway"
	highway.city = self
	_built.add_child(highway)
	var golf := GolfClub.new()
	golf.name = "Golf"
	golf.city = self
	_built.add_child(golf)


## A square hedge `reach` from the middle, with a gap at the ramp's street on each of the `open` sides.
func _hedge(reach: Vector2, open: Array) -> void:
	var x := CityLayout.street_x(HighwayLayout.RAMP_STREET_X)
	var z := CityLayout.street_z(HighwayLayout.RAMP_STREET_Z)
	var across := {"n": x, "s": x, "e": z, "w": z}
	for side: String in HighwayLayout.SIDES:
		var north_south := side in ["n", "s"]
		var half := (reach.x if north_south else reach.y) + 1.0
		var line := (-reach.y if side == "n" else reach.y) if north_south else (reach.x if side == "e" else -reach.x)
		var at: float = across[side]
		var gap := CityLayout.STREET / 2 + 1.0 if open.has(side) else 0.0
		for stretch: Vector2 in [Vector2(-half, at - gap), Vector2(at + gap, half)]:
			var length := stretch.y - stretch.x
			var middle := (stretch.x + stretch.y) / 2
			if north_south:
				_box(Vector3(middle, HEDGE_HEIGHT / 2, line), Vector3(length, HEDGE_HEIGHT, 1), HEDGE)
			else:
				_box(Vector3(line, HEDGE_HEIGHT / 2, middle), Vector3(1, HEDGE_HEIGHT, length), HEDGE)


## Sidewalk ring and the ground of the block: grass for houses and the plaza, paved elsewhere. The live place's
## block has none when its scene brings that ground itself.
func _block(block: Vector2i) -> void:
	var center := CityLayout.block_center(block)
	var live := CityLayout.place(live_place)
	if live_block_ground and not live.is_empty() and live.block == block:
		return
	var inner := CityLayout.BLOCK - CityLayout.SIDEWALK * 2
	_mesh_box(center + Vector3(0, 0.015, 0), Vector3(CityLayout.BLOCK, 0.01, CityLayout.BLOCK), SIDEWALK)
	var ground := PAVED
	if block == CityLayout.PLAZA or CityLayout.barrio_kind(block) == "house":
		ground = GRASS
	_mesh_box(center + Vector3(0, 0.03, 0), Vector3(inner, 0.01, inner), ground)
	if block == CityLayout.PLAZA:
		_plaza(center)


func _plaza(center: Vector3) -> void:
	var basin := CylinderMesh.new()
	basin.top_radius = 4.0
	basin.bottom_radius = 4.2
	basin.height = 0.7
	_mesh(basin, center + Vector3(0, 0.35, 0), SIDEWALK)
	var body := _body(center + Vector3(0, 0.35, 0))
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 4.2
	cylinder.height = 0.7
	shape.shape = cylinder
	body.add_child(shape)
	var water := CylinderMesh.new()
	water.top_radius = 3.7
	water.bottom_radius = 3.7
	water.height = 0.05
	_mesh(water, center + Vector3(0, 0.68, 0), Color(0.4, 0.7, 0.95))
	for x: float in [-18.0, -9.0, 9.0, 18.0]:
		for z: float in [-18.0, 18.0]:
			_tree(center + Vector3(x, 0, z))


## A building on its lot, front to the street: body, roof trim, door, windows, and a sign over the door.
## Shops get a lowered shutter and an awning, since nothing opens until its case comes. Houses get a gable roof.
## A hollow building (the station) is only its outside walls, with the doorway open.
func _building(block: Vector2i, side: String, along: float, size: Vector3, color: Color, sign_key: String, shop: bool,
		gable: bool, hollow := false) -> Node3D:
	var root := Node3D.new()
	root.position = CityLayout.lot_center(block, side, along, size.z)
	root.rotation.y = CityLayout.side_turn(side)
	_built.add_child(root)
	if hollow:
		_shell(size, color, root)
	else:
		_box(Vector3(0, size.y / 2, 0), size, color, root)
	if gable:
		var roof := PrismMesh.new()
		roof.size = Vector3(size.x + 0.6, 2.2, size.z + 0.6)
		_mesh(roof, Vector3(0, size.y + 1.1, 0), ROOF, root)
	else:
		_mesh_box(Vector3(0, size.y + 0.15, 0), Vector3(size.x + 0.4, 0.3, size.z + 0.4), color.darkened(0.35), root)
	var front := size.z / 2 + 0.05
	if not hollow:
		_mesh_box(Vector3(0, 1.1, front), Vector3(1.6, 2.2, 0.1), DOOR, root)
	if shop:
		_mesh_box(Vector3(0, 1.4, front + 0.02), Vector3(size.x * 0.7, 2.8, 0.06), SHUTTER, root)
		_mesh_box(Vector3(0, 3.2, front + 0.8), Vector3(size.x * 0.8, 0.12, 1.6), color.darkened(0.3), root)
	var floors := maxi(1, floori(size.y / 3.0))
	var columns := maxi(1, floori(size.x / 4.0))
	for f in floors:
		var y := 1.6 + f * 3.0
		for c in columns:
			var x := (c - (columns - 1) / 2.0) * 4.0
			if f == 0 and (absf(x) < 2.0 or shop):
				continue
			_mesh_box(Vector3(x, y, front), Vector3(1.4, 1.4, 0.06), GLASS, root)
	if sign_key != "":
		var label := Label3D.new()
		label.text = sign_key
		# Long names shrink to fit the front (a letter is about half its font size wide).
		label.font_size = mini(96, floori(size.x * 0.85 / (tr(sign_key).length() * 0.55 * 0.01)))
		label.pixel_size = 0.01
		label.outline_size = 18
		label.position = Vector3(0, minf(size.y - 0.8, 4.2), front + 0.1)
		root.add_child(label)
	return root


## The outside walls of a hollow building, its roof, and the front split around the door (StationRooms).
func _shell(size: Vector3, color: Color, root: Node3D) -> void:
	var half := Vector3(size.x, 0, size.z) / 2
	var wall := StationRooms.WALL
	for piece: Array in StationRooms.back_wall(size.y):
		_box(piece[0] + Vector3(0, 0, wall / 2), piece[1], color, root)
	for s: float in [-1.0, 1.0]:
		_box(Vector3(s * (half.x - wall / 2), size.y / 2, 0), Vector3(wall, size.y, size.z), color, root)
	for piece: Array in StationRooms.front_wall(size.y):
		_box(piece[0] + Vector3(0, 0, -wall / 2), piece[1], color, root)
	_box(Vector3(0, size.y - 0.1, 0), Vector3(size.x, 0.2, size.z), color, root)


## The station's rooms (docs/diseno/comisaria.md): floor, ceiling, inside walls, the barred counter and cells, the
## furniture, a light per room, the comisario behind his desk and the armero behind the counter.
func _station_inside(root: Node3D, size: Vector3) -> void:
	_mesh_box(Vector3(0, 0.04, 0), Vector3(size.x - 0.4, 0.02, size.z - 0.4), STATION_FLOOR, root)
	# The facade's color stays outside: the outside walls get a light lining up to the ceiling.
	var lining := Vector3(size.x / 2 - StationRooms.WALL - 0.01, StationRooms.CEILING / 2, size.z / 2 - StationRooms.WALL - 0.01)
	for piece: Array in StationRooms.back_wall(StationRooms.CEILING):
		_mesh_box(piece[0] + Vector3(0, 0, StationRooms.WALL + 0.01), Vector3(piece[1].x, piece[1].y, 0.01), STATION_WALL, root)
	for s: float in [-1.0, 1.0]:
		_mesh_box(Vector3(s * lining.x, lining.y, 0), Vector3(0.01, StationRooms.CEILING, size.z), STATION_WALL, root)
	for piece: Array in StationRooms.front_wall(StationRooms.CEILING):
		_mesh_box(piece[0] + Vector3(0, 0, -StationRooms.WALL - 0.01), Vector3(piece[1].x, piece[1].y, 0.01), STATION_WALL, root)
	_box(Vector3(0, StationRooms.CEILING + 0.1, 0), Vector3(size.x, 0.2, size.z), STATION_WALL, root)
	for piece: Array in StationRooms.walls(board_room_open) + StationRooms.counter():
		_box(piece[0], piece[1], STATION_WALL, root)
	for piece: Array in StationRooms.bars():
		_box(piece[0], piece[1], BARS, root)
	for piece: Array in StationRooms.closed_doors():
		_box(piece[0], piece[1], DOOR, root)
	for i in StationRooms.CELL_DOORS.size():
		var door := CellDoor.new()
		door.name = "CellDoor%d" % i
		door.position = Vector3(StationRooms.CELL_DOORS[i].x, 0, StationRooms.CELL_FRONT_Z)
		root.add_child(door)
		cell_doors.append(door)
	_furniture(StationRooms.FURNITURE, StationRooms.SOLID, root)
	if not night:
		_disguises(root)
	for at: Vector3 in StationRooms.lights():
		var light := OmniLight3D.new()
		light.position = at
		light.light_color = Color(1.0, 0.78, 0.5) if night else Color(0.95, 0.97, 1.0)
		light.light_energy = 0.25 if night else 0.8
		light.omni_range = 9.0
		root.add_child(light)
	comisario = Comisario.new()
	comisario.name = "Comisario"
	comisario.position = StationRooms.COMISARIO_AT
	root.add_child(comisario)
	armero = Armero.new()
	armero.name = "Armero"
	armero.position = StationRooms.ARMERO_AT
	armero.rotation.y = PI / 2
	root.add_child(armero)


## The interrogation wing behind the station (interrogatorio.md): outside walls in the station's color, concrete
## inside, the one-way mirror (a mirror from the interrogation room, dark glass from the observation room), the
## furniture, a dim light in the hall and the observation room, and only the hanging lamp over the table.
func _interrogation_wing(root: Node3D, color: Color) -> void:
	var wall := StationRooms.WALL
	var ceiling := StationRooms.CEILING
	var depth := InterrogationWing.FROM_Z - InterrogationWing.TO_Z
	var middle := (InterrogationWing.FROM_Z + InterrogationWing.TO_Z) / 2
	var width := InterrogationWing.HALF_X * 2
	for piece: Array in InterrogationWing.shell():
		_box(piece[0], piece[1], color, root)
	_mesh_box(Vector3(0, 0.04, middle), Vector3(width - 0.4, 0.02, depth - 0.2), WING_FLOOR, root)
	_box(Vector3(0, ceiling + 0.1, middle), Vector3(width, 0.2, depth), CONCRETE, root)
	var inner := InterrogationWing.HALF_X - wall - 0.01
	for s: float in [-1.0, 1.0]:
		_mesh_box(Vector3(s * inner, ceiling / 2, middle), Vector3(0.01, ceiling, depth), CONCRETE, root)
	_mesh_box(Vector3(0, ceiling / 2, InterrogationWing.TO_Z + wall + 0.01), Vector3(width, ceiling, 0.01), CONCRETE, root)
	for piece: Array in StationRooms.back_wall(ceiling):
		_mesh_box(piece[0] + Vector3(0, 0, -0.01), Vector3(piece[1].x, piece[1].y, 0.01), CONCRETE, root)
	for piece: Array in InterrogationWing.walls():
		_box(piece[0], piece[1], CONCRETE, root)
	_mirror(root)
	var sign := Label3D.new()
	sign.text = "SIGN_NO_SMOKING"
	sign.font_size = 32
	sign.pixel_size = 0.006
	sign.modulate = Color(0.85, 0.2, 0.15)
	sign.position = InterrogationWing.SIGN_AT
	sign.rotation.y = -PI / 2
	root.add_child(sign)
	_furniture(InterrogationWing.FURNITURE, InterrogationWing.SOLID, root)
	for at: Vector3 in InterrogationWing.lights():
		var light := OmniLight3D.new()
		light.position = at
		light.light_color = Color(0.8, 0.9, 1.0)
		light.light_energy = 0.35
		light.omni_range = 6.0
		root.add_child(light)
	var lamp := SpotLight3D.new()
	lamp.name = "InterrogationLamp"
	lamp.add_to_group("interrogation_lamp")
	lamp.position = InterrogationWing.LAMP_AT + Vector3.UP * 0.05
	lamp.rotation.x = -PI / 2
	lamp.light_color = LAMP_LIGHT
	lamp.light_energy = 6.0
	lamp.spot_range = 4.0
	lamp.spot_angle = 38.0
	lamp.shadow_enabled = true
	root.add_child(lamp)


## The one-way mirror: it stops you like glass, reflects the interrogation room and lets the observers see through.
func _mirror(root: Node3D) -> void:
	var pane: Array = InterrogationWing.mirror()
	var body := _body(pane[0], root)
	# The dangerous suspect counts as watched from behind it (InterrogationCase).
	body.add_to_group("see_through")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = pane[1]
	shape.shape = box
	body.add_child(shape)
	var size := Vector2(pane[1].z, pane[1].y)
	var mirror := StandardMaterial3D.new()
	mirror.albedo_color = Color(0.55, 0.58, 0.6)
	mirror.metallic = 1.0
	mirror.roughness = 0.03
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.05, 0.07, 0.08, 0.3)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for side: float in [1.0, -1.0]:
		var quad := QuadMesh.new()
		quad.size = size
		quad.orientation = PlaneMesh.FACE_X
		quad.flip_faces = side < 0
		var face := MeshInstance3D.new()
		face.name = "Mirror" if side > 0 else "ObservationGlass"
		face.mesh = quad
		face.material_override = mirror if side > 0 else glass
		face.position = pane[0] + Vector3(side * 0.03, 0, 0)
		root.add_child(face)
	var probe := ReflectionProbe.new()
	probe.position = Vector3((InterrogationWing.MIRROR_X + InterrogationWing.HALF_X) / 2, 1.5, (InterrogationWing.HALL_Z + InterrogationWing.TO_Z) / 2)
	probe.size = Vector3(InterrogationWing.HALF_X - InterrogationWing.MIRROR_X, StationRooms.CEILING, InterrogationWing.HALL_Z - InterrogationWing.TO_Z)
	probe.box_projection = true
	probe.interior = true
	root.add_child(probe)


## Furniture models with a box to bump into when it has a footprint in `solids`; one with an action gets an
## InterrogationProp, which a cop can use (E) during an interrogation.
## The disguises on the floor in front of the lockers (infiltracion.md, step 1): one of each piece per cop, and the
## choir's robes and songbooks (infiltracion-coro.md, step 2), and the mime troupe's pieces (infiltracion-mimos.md, step 1)
## and the costume party's (infiltracion-fiesta.md, step 1).
func _disguises(root: Node3D) -> void:
	for i in StationRooms.DISGUISES.size():
		var piece: DisguisePiece = DisguisePiece.scene_of(StationRooms.DISGUISES[i]).instantiate()
		piece.name = "Disguise%d" % i
		piece.position = StationRooms.DISGUISES_AT + Vector3((i % 6) * 0.38, 0.12, floorf(i / 6.0) * 0.35)
		root.add_child(piece)
	for i in StationRooms.CHOIR_DISGUISES.size():
		var kind := StationRooms.CHOIR_DISGUISES[i]
		var item: Grabbable = (load(StationRooms.SONGBOOK_SCENE) if kind == "songbook"
			else DisguisePiece.scene_of(kind)).instantiate()
		item.name = "Choir%d" % i
		item.position = StationRooms.CHOIR_DISGUISES_AT + Vector3(i * StationRooms.CHOIR_GAP, 0.12, 0)
		root.add_child(item)
	for i in StationRooms.MIME_DISGUISES.size():
		var piece: DisguisePiece = DisguisePiece.scene_of(StationRooms.MIME_DISGUISES[i]).instantiate()
		piece.name = "Mime%d" % i
		piece.position = StationRooms.MIME_DISGUISES_AT + Vector3(i * StationRooms.MIME_GAP, 0.12, 0)
		root.add_child(piece)
	for i in StationRooms.PARTY_DISGUISES.size():
		var piece: DisguisePiece = DisguisePiece.scene_of(StationRooms.PARTY_DISGUISES[i]).instantiate()
		piece.name = "Party%d" % i
		piece.position = StationRooms.PARTY_DISGUISES_AT + Vector3(i * StationRooms.PARTY_GAP, 0.12, 0)
		root.add_child(piece)
	for i in StationRooms.GYM_DISGUISES.size():
		var piece: DisguisePiece = DisguisePiece.scene_of(StationRooms.GYM_DISGUISES[i]).instantiate()
		piece.name = "Gym%d" % i
		piece.position = StationRooms.GYM_DISGUISES_AT + Vector3(i * StationRooms.GYM_GAP, 0.12, 0)
		root.add_child(piece)
	for i in StationRooms.THIEF_DISGUISES.size():
		var piece: DisguisePiece = DisguisePiece.scene_of(StationRooms.THIEF_DISGUISES[i]).instantiate()
		piece.name = "Thief%d" % i
		piece.position = StationRooms.THIEF_DISGUISES_AT + Vector3(i * StationRooms.THIEF_GAP, 0.12, 0)
		root.add_child(piece)
	for i in StationRooms.CHEF_DISGUISES.size():
		var piece: DisguisePiece = DisguisePiece.scene_of(StationRooms.CHEF_DISGUISES[i]).instantiate()
		piece.name = "Chef%d" % i
		piece.position = StationRooms.CHEF_DISGUISES_AT + Vector3(i * StationRooms.CHEF_GAP, 0.12, 0)
		root.add_child(piece)


func _furniture(items: Array, solids: Dictionary, root: Node3D) -> void:
	for item: Array in items:
		var model: Node3D = load("res://assets/models/%s.glb" % item[0]).instantiate()
		model.position = item[1]
		model.rotation.y = item[2]
		root.add_child(model)
		if not solids.has(item[0]):
			continue
		var solid: Vector3 = solids[item[0]]
		var body: StaticBody3D = InterrogationProp.new() if item.size() > 3 else StaticBody3D.new()
		if body is InterrogationProp:
			(body as InterrogationProp).action = item[3]
			# Named by its action, so a guest's E reaches the same one on the host (ActionSync).
			body.name = "Prop_" + item[3]
		body.position = item[1] + Vector3(0, solid.y / 2, 0)
		root.add_child(body)
		body.rotation.y = item[2]
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = solid
		shape.shape = box
		body.add_child(shape)


## Traffic light and street name sign on the north-east corner of an inner crossing.
func _corner(i: int, j: int) -> void:
	var at := Vector3(CityLayout.street_x(i), 0, CityLayout.street_z(j))
	var corner := at + Vector3(CityLayout.STREET / 2 + 0.6, 0, -CityLayout.STREET / 2 - 0.6)
	_box(corner + Vector3(0, 1.8, 0), Vector3(0.15, 3.6, 0.15), POLE)
	_mesh_box(corner + Vector3(0, 3.9, 0), Vector3(0.4, 1.0, 0.4), POLE)
	for k in 3:
		_mesh_box(corner + Vector3(0, 4.2 - k * 0.3, 0.21), Vector3(0.2, 0.2, 0.02),
			[Color(0.9, 0.2, 0.2), Color(0.95, 0.8, 0.2), Color(0.3, 0.85, 0.35)][k])
	var names := [CityLayout.STREETS_EW[j - 1], CityLayout.STREETS_NS[i - 1]]
	for k in 2:
		var label := Label3D.new()
		label.text = names[k]
		label.font_size = 48
		label.pixel_size = 0.01
		label.outline_size = 10
		label.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		label.position = corner + Vector3(0, 2.8 - k * 0.4, 0)
		_built.add_child(label)


func _tree(at: Vector3) -> void:
	_box(at + Vector3(0, 1.2, 0), Vector3(0.4, 2.4, 0.4), TRUNK)
	var crown := SphereMesh.new()
	crown.radius = 1.8
	crown.height = 3.2
	_mesh(crown, at + Vector3(0, 3.4, 0), LEAVES)


func _material(color: Color) -> StandardMaterial3D:
	if not _materials.has(color):
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.9
		_materials[color] = material
	return _materials[color]


func _box(center: Vector3, size: Vector3, color: Color, parent: Node3D = null) -> void:
	var body := _body(center, parent)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	_mesh_box(center, size, color, parent)


func _body(at: Vector3, parent: Node3D = null) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = at
	(parent if parent else _built).add_child(body)
	return body


## The gas station's two pumps on the sidewalk by its door, under a red canopy (traslado-presos.md: the bathroom
## stop). Only looks: nothing to bump into.
func _pumps(root: Node3D, size: Vector3) -> void:
	var front := size.z / 2
	for x: float in [-3.5, 3.5]:
		_mesh_box(Vector3(x, 0.8, front + 1.2), Vector3(0.6, 1.6, 0.45), PUMP, root)
		_mesh_box(Vector3(x, 1.25, front + 1.43), Vector3(0.4, 0.3, 0.02), GLASS, root)
		_mesh_box(Vector3(x + 0.33, 0.9, front + 1.2), Vector3(0.06, 0.7, 0.06), POLE, root)
	_mesh_box(Vector3(0, 3.4, front + 1.4), Vector3(size.x - 2.0, 0.25, 2.6), PUMP, root)


func _mesh_box(center: Vector3, size: Vector3, color: Color, parent: Node3D = null) -> void:
	var box := BoxMesh.new()
	box.size = size
	_mesh(box, center, color, parent)


func _mesh(mesh: Mesh, at: Vector3, color: Color, parent: Node3D = null) -> void:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = _material(color)
	instance.position = at
	(parent if parent else _built).add_child(instance)
