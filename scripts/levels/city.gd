class_name City
extends Node3D

## The open city (docs/diseno/ciudad.md, step 1): streets, blocks, the station and the closed fronts of the
## 10 raid places, built from CityLayout. Nothing opens yet; the cops walk or drive the patrol car around.

const GRASS := Color(0.45, 0.72, 0.3)
const ROAD := Color(0.32, 0.33, 0.36)
const SIDEWALK := Color(0.55, 0.53, 0.5)
const PAVED := Color(0.45, 0.43, 0.42)
const LINE := Color(0.95, 0.85, 0.3)
const GLASS := Color(0.25, 0.35, 0.5)
const DOOR := Color(0.4, 0.26, 0.18)
const SHUTTER := Color(0.55, 0.57, 0.6)
const ROOF := Color(0.86, 0.32, 0.26)
const TRUNK := Color(0.45, 0.3, 0.2)
const LEAVES := Color(0.3, 0.6, 0.25)
const HEDGE := Color(0.25, 0.5, 0.22)
const POLE := Color(0.25, 0.27, 0.3)
const COMISARIO_MODEL := preload("res://assets/models/npc_comisario.glb")
const HEDGE_HEIGHT := 2.5

## The place whose case is on today: its own scene builds it, so the city leaves its lot empty.
@export var live_place := ""

var _materials := {}
var _built: Node3D


func _ready() -> void:
	_built = get_node_or_null("Built")
	if _built == null:
		_built = Node3D.new()
		_built.name = "Built"
		add_child(_built)
	_build()
	var door := CityLayout.door_of("station")
	var comisario: Node3D = COMISARIO_MODEL.instantiate()
	comisario.position = door + Vector3(3, 0, 1.5)
	_built.add_child(comisario)


func _build() -> void:
	var size := CityLayout.SIZE
	_box(Vector3(0, -0.1, 0), Vector3(size.x + 40, 0.2, size.y + 40), GRASS)
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
		_building(p.block, p.side, p.along, p.size, p.color, p.sign, CityLayout.SHOPS.has(p.id), p.id == "grandpa")
	for lot: Dictionary in CityLayout.fillers():
		_building(lot.block, lot.side, lot.along, lot.size, lot.color, "", false,
			CityLayout.barrio_kind(lot.block) == "house")
	for i in range(1, CityLayout.COLUMNS):
		for j in range(1, CityLayout.ROWS):
			_corner(i, j)
	# A hedge around the city so nobody drives off the edge.
	var reach := size / 2 + Vector2.ONE
	for s: float in [-1.0, 1.0]:
		_box(Vector3(0, HEDGE_HEIGHT / 2, s * reach.y), Vector3(size.x + 2, HEDGE_HEIGHT, 1), HEDGE)
		_box(Vector3(s * reach.x, HEDGE_HEIGHT / 2, 0), Vector3(1, HEDGE_HEIGHT, size.y + 2), HEDGE)


## Sidewalk ring and the ground of the block: grass for houses and the plaza, paved elsewhere. The live place's
## block has none: its scene brings its own ground.
func _block(block: Vector2i) -> void:
	var center := CityLayout.block_center(block)
	var live := CityLayout.place(live_place)
	if not live.is_empty() and live.block == block:
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
func _building(block: Vector2i, side: String, along: float, size: Vector3, color: Color, sign_key: String, shop: bool,
		gable: bool) -> void:
	var root := Node3D.new()
	root.position = CityLayout.lot_center(block, side, along, size.z)
	root.rotation.y = CityLayout.side_turn(side)
	_built.add_child(root)
	_box(Vector3(0, size.y / 2, 0), size, color, root)
	if gable:
		var roof := PrismMesh.new()
		roof.size = Vector3(size.x + 0.6, 2.2, size.z + 0.6)
		_mesh(roof, Vector3(0, size.y + 1.1, 0), ROOF, root)
	else:
		_mesh_box(Vector3(0, size.y + 0.15, 0), Vector3(size.x + 0.4, 0.3, size.z + 0.4), color.darkened(0.35), root)
	var front := size.z / 2 + 0.05
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
