class_name StolenBookRig
extends PrintShopRig

## The stolen book (allanamiento-imprenta.md, "El libro robado"): Don Renglón stole a famous writer's manuscript and
## prints it as his own. The posters on the front wall, outside, say "el nuevo libro de Don Renglón" over the photo of
## a lady with glasses, and a cop this close to them notices, the story's own clue (on the checklist the first time).
## And the piles of his "new book" around the shop fall over each time the rotativa starts (they stand frozen until
## the first time). Every number here is (propuesta).

signal piles_fell

const NOTICE_RANGE := 2.5
const CHECK_EVERY := 0.5
## The two posters on the front wall's outer face, east of the door.
const POSTERS: Array[Vector3] = [Vector3(0.5, 1.6, PrintShop.HALF_Z + PlaceBuilder.WALL / 2 + 0.02),
	Vector3(5.5, 1.6, PrintShop.HALF_Z + PlaceBuilder.WALL / 2 + 0.02)]
const POSTER_SIZE := Vector3(0.9, 1.3, 0.02)
## The piles of the book, BOOKS_PER_PILE high, out of everyone's way; how hard the press's shake pushes each book
## (more the higher it is).
const PILES: Array[Vector3] = [Vector3(6.0, PrintShop.FLOOR_TOP, 3.0), Vector3(-3.0, PrintShop.FLOOR_TOP, 4.5),
	Vector3(9.5, PrintShop.FLOOR_TOP, 1.0), Vector3(-11.0, PrintShop.FLOOR_TOP, -2.0)]
const BOOKS_PER_PILE := 6
const BOOK_SIZE := Vector3(0.22, 0.05, 0.3)
const BOOK_MASS := 0.4
const SHAKE := 0.25
const BOOK_RED := Color(0.75, 0.22, 0.17)

var noticed := false
var posters: Array[MeshInstance3D] = []
## The books, pile by pile (bottom first).
var piles: Array[Array] = []
var falls := 0
var _since := 0.0


func setup(place: PrintShop) -> void:
	super.setup(place)
	for at: Vector3 in POSTERS:
		posters.append(_poster(at))
	for at: Vector3 in PILES:
		var pile: Array[RigidBody3D] = []
		for i in BOOKS_PER_PILE:
			pile.append(_book(at + Vector3(0, BOOK_SIZE.y * (i + 0.5) + 0.002 * i, 0), i))
		piles.append(pile)
	shop.press.started.connect(func(_cop: Cop) -> void: topple())


func _physics_process(delta: float) -> void:
	_since += delta
	# Online the host sees the cops come close: the guests' rig shows the clue when it says (net_state).
	if noticed or _since < CHECK_EVERY or not multiplayer.is_server():
		return
	_since = 0.0
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		for at: Vector3 in POSTERS:
			if cop.global_position.distance_to(shop.to_global(at)) <= NOTICE_RANGE:
				notice()
				return


## A cop looks at the posters: the photo is of somebody else. The first time it's a clue.
func notice() -> void:
	if noticed:
		return
	noticed = true
	shop.raid.add_clue(tr("CLUE_BOOK_POSTER"))
	shop.raid.float_label(tr("PRINT_SHOP_NOT_HIS_FACE"), shop.to_global(POSTERS[0] + Vector3(0, 1.0, 0.3)), BOOK_RED)


## The press starts and the floor shakes: every pile falls over (whatever is still standing of it).
func topple() -> void:
	falls += 1
	for pile: Array in piles:
		for i in pile.size():
			var book: RigidBody3D = pile[i]
			if not is_instance_valid(book):
				continue
			var way := Vector3(1, 0, 0).rotated(Vector3.UP, falls * 1.3 + i * 0.2)
			book.freeze = false
			book.sleeping = false
			book.apply_central_impulse(way * SHAKE * BOOK_MASS * (i + 1))
	piles_fell.emit()


## One poster on the front wall: the title over the photo of a lady with glasses (not him).
func _poster(at: Vector3) -> MeshInstance3D:
	var poster := _mesh(POSTER_SIZE, Color(0.97, 0.95, 0.88))
	poster.position = at
	shop.add_child(poster)
	var photo := _mesh(Vector3(0.5, 0.55, 0.01), Color(0.55, 0.75, 0.9))
	photo.position = Vector3(0, -0.25, 0.015)
	poster.add_child(photo)
	var hair := _mesh(Vector3(0.34, 0.4, 0.01), Color(0.55, 0.55, 0.58))
	hair.position = Vector3(0, -0.22, 0.022)
	poster.add_child(hair)
	var face := _mesh(Vector3(0.22, 0.26, 0.01), Color(0.93, 0.76, 0.62))
	face.position = Vector3(0, -0.26, 0.03)
	poster.add_child(face)
	for x: float in [-0.05, 0.05]:
		var lens := _mesh(Vector3(0.07, 0.05, 0.01), Color(0.1, 0.1, 0.12))
		lens.position = Vector3(x, -0.22, 0.037)
		poster.add_child(lens)
	var title := Label3D.new()
	title.text = "PRINT_SHOP_BOOK_POSTER"
	title.font_size = 26
	title.pixel_size = 0.004
	title.width = 200.0
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.modulate = BOOK_RED
	title.outline_size = 0
	title.position = Vector3(0, 0.36, 0.02)
	poster.add_child(title)
	return poster


## One copy of his "new book", the `level`-th of its pile.
func _book(at: Vector3, level: int) -> RigidBody3D:
	var book := RigidBody3D.new()
	book.name = "StolenBook"
	book.collision_layer = 4
	book.collision_mask = 15
	book.mass = BOOK_MASS
	book.position = at
	book.rotation.y = (level % 3 - 1) * 0.06
	# A pile of thin light books doesn't stand on its own in the physics: they wait frozen until the first shake.
	book.freeze = true
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = BOOK_SIZE
	shape.shape = box
	book.add_child(shape)
	book.add_child(_mesh(BOOK_SIZE, BOOK_RED if level % 2 == 0 else BOOK_RED.darkened(0.2)))
	shop.add_child(book)
	return book


func _mesh(size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	node.material_override = material
	return node
