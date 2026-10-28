class_name WeddingHall
extends CrimeScenePlace

## The wedding crime scene (docs/diseno/escena-boda.md, step 1, decision 290): Rosa and Tito's party in the Salón Gala,
## the costume party's hall (PartyHall builds the shell, the dance floor, the coat check, the restroom and the office)
## dressed for a wedding, on the same lot with the front to +Z. The head table against the back wall under the banner,
## eight round tables with their tablecloths, centerpieces and numbers, the three-tier cake on its own round table in
## the back west corner, the DJ's booth facing the dance floor, white garlands along the walls and rice on the floor
## by the entrance. The office stays locked. Step 2: Tito and his five groomsmen in front of the head table (TuxedoGuest,
## with WeddingTraits drawn with the case seed), Rosa by Tito, DJ Bombo behind his booth, grandma Chola at table 3 with
## her ear trumpet and four guests at the other tables. Step 3: what the cops get from the tuxedos goes to their files
## (set_up_case). Step 4: what was stolen (the ring, the gift envelopes' box or the sugar couple) hidden in the cake,
## among the coats in the coat check or in the head table's centerpiece, all drawn with the case seed.
## Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const CAKE_MODEL := preload("res://assets/models/wedding_cake.glb")
const CENTERPIECE_MODEL := preload("res://assets/models/flower_centerpiece.glb")
const DJ_MODEL := preload("res://assets/models/dj_booth.glb")
const BRIDE_MODEL := preload("res://assets/models/npc_novia.glb")
const DJ_PERSON_MODEL := preload("res://assets/models/npc_dj_bombo.glb")
const GRANDMA_MODEL := preload("res://assets/models/npc_abuela_chola.glb")
const TRUMPET_MODEL := preload("res://assets/models/ear_trumpet.glb")
const GUEST_MODELS: Array[PackedScene] = [preload("res://assets/models/npc_invitado.glb"),
	preload("res://assets/models/npc_senora.glb"), preload("res://assets/models/npc_invitado_b.glb"),
	preload("res://assets/models/npc_vecina.glb")]
const HALF_X := PartyHall.HALF_X
const HALF_Z := PartyHall.HALF_Z
const FLOOR_TOP := PartyHall.FLOOR_TOP
const ROOF := PartyHall.ROOF
## The head table, where the photo steps of the party stand: its middle on the floor, and its size.
const HEAD_TABLE_AT := Vector3(-3.0, 0, -8.4)
const HEAD_TABLE_SIZE := Vector3(6.0, 0.8, 0.9)
## The round tables of the guests, numbered from 1 in this order: three on the west side, three on the east side and
## two by the entrance, clear of the dance floor, the coat check, the restroom and the office.
const TABLES: Array[Vector3] = [
	Vector3(-8.5, 0, -2.5), Vector3(-8.5, 0, 0.5), Vector3(-8.5, 0, 3.5),
	Vector3(8.5, 0, -3.5), Vector3(8.5, 0, -0.5), Vector3(8.5, 0, 2.5),
	Vector3(-3.8, 0, 6.6), Vector3(3.8, 0, 6.6),
]
const TABLE_RADIUS := 0.8
const TABLE_HEIGHT := 0.75
## The cake's round table in the back west corner.
const CAKE_TABLE_AT := Vector3(-9.6, 0, -7.6)
const CAKE_TABLE_RADIUS := 0.6
## The DJ's booth east of the head table, facing the dance floor (+Z).
const DJ_AT := Vector3(3.5, 0, -8.6)
## The rice thrown at the newlyweds, on the floor inside the entrance: RICE grains in a RICE_AREA (x, z, width, depth).
const RICE := 90
const RICE_AREA := Rect2(-1.6, 6.8, 3.2, 3.0)
## Where the six tuxedos stand, by index (Tito, 0, in the middle by Rosa): in a row in front of the head table, off the
## dance floor.
const TUXEDOS_AT: Array[Vector3] = [
	Vector3(-2.6, 0, -6.6), Vector3(-6.4, 0, -6.4), Vector3(-5.1, 0, -6.4),
	Vector3(0.3, 0, -6.4), Vector3(1.6, 0, -6.4), Vector3(-3.9, 0, -6.4),
]
const BRIDE_AT := Vector3(-1.3, 0, -6.6)
## DJ Bombo behind his booth.
const DJ_PERSON_AT := Vector3(3.5, 0, -9.4)
## Grandma Chola by table 3, facing it, with her ear trumpet on it.
const GRANDMA_TABLE := 2
const GRANDMA_AT := Vector3(-7.2, 0, 3.5)
## The four guests, each by a table and facing it: where they stand and their turn (radians around Y).
const GUESTS_AT: Array[Vector3] = [Vector3(7.2, 0, -3.5), Vector3(7.2, 0, -0.5), Vector3(-3.8, 0, 5.3),
	Vector3(3.8, 0, 5.3)]
const GUESTS_TURN: Array[float] = [PI / 2, PI / 2, 0.0, 0.0]
## What was stolen, drawn with the seed (escena-boda.md, pregunta 1), and where it can be hidden: in the cake (cutting
## it open is the search), among the coats in the coat check or in the head table's centerpiece.
const LOOTS: Array[String] = ["ring", "envelopes", "sugar_couple"]
const LOOT_SPOTS: Array[String] = ["cake", "coats", "centerpiece"]
const LOOT_MODELS := {
	"ring": preload("res://assets/models/wedding_ring_box.glb"),
	"envelopes": preload("res://assets/models/gift_urn.glb"),
	"sugar_couple": preload("res://assets/models/sugar_couple.glb"),
}
## The coats hanging on the coat check's rail (PartyHall.build_rooms): their middle and size.
const COATS_AT := Vector3(-11.6, 1.15, 8.3)
const COATS_SIZE := Vector3(0.5, 1.0, 3.0)
## The cake's shape once it's cut open: caved in and spread out.
const CUT_CAKE := Vector3(1.15, 0.55, 1.15)
const GUEST_LINES := 6
const BRIDE_LINES := 10
const DJ_LINES := 4
const GRANDMA_LINES := 4

const WHITE_BALLOONS: Array[Color] = [Color(0.98, 0.98, 0.96), Color(0.95, 0.85, 0.9), Color(0.98, 0.98, 0.96),
	Color(0.9, 0.85, 0.65)]
const GARLAND := Color(0.98, 0.97, 0.94)
const TABLECLOTH := Color(0.97, 0.97, 0.94)
const RICE_COLOR := Color(0.98, 0.98, 0.95)

var office_door: FrontDoor
var cake: Node3D
var dj_booth: Node3D
## Each round table's top, in the hall's space, by table number - 1.
var table_tops: Array[Vector3] = []
## Tito and his five groomsmen, by index (WeddingTraits.draw with the case seed).
var tuxedos: Array[TuxedoGuest] = []
var bride: WeddingPerson
var dj: WeddingPerson
var grandma: WeddingPerson
var ear_trumpet: Node3D
var guests: Array[WeddingPerson] = []
var case: CrimeSceneCase
## What was stolen and where it is (drawn with the case seed in set_up_case), and whether the cops found it.
var loot := "ring"
var loot_spot := "cake"
var loot_found := false
## The searchable places, by spot.
var loot_spots := {}
## A cop cut the cake open.
var cake_cut := false
var _build: PlaceBuilder


func _ready() -> void:
	add_to_group("wedding")
	variant = "wedding"
	_build = PlaceBuilder.new(self)
	PartyHall.build_shell(_build, self, WHITE_BALLOONS)
	PartyHall.build_dance_floor(_build)
	PartyHall.build_rooms(_build)
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(PartyHall.OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, PartyHall.OFFICE_Z)
	add_child(office_door)
	_head_table()
	_round_tables()
	_cake()
	_dj()
	_garlands()
	_rice()
	_people()
	_loot_spots()


## Draws what was stolen and where it is, and tells the six tuxedos about the case, so what the cops get from them goes
## to their files.
func set_up_case(new_case: CrimeSceneCase) -> void:
	case = new_case
	loot = LOOTS[hash(["wedding loot", case.case_seed]) % LOOTS.size()]
	loot_spot = LOOT_SPOTS[hash(["wedding loot spot", case.case_seed]) % LOOT_SPOTS.size()]
	for tuxedo in tuxedos:
		tuxedo.case = case


## Searching a spot: the stolen thing turns up in the right one; a sign of nothing in the others. Searching the cake
## cuts it open, whatever is in it.
func search(spot: String, cop: Cop) -> void:
	if spot == "cake" and not cake_cut:
		cake_cut = true
		cake.scale = CUT_CAKE
	if spot != loot_spot or loot_found or not case:
		if cop:
			cop.show_hint("HINT_SEARCH_NOTHING_" + spot)
		return
	reveal_loot()


## What was stolen comes out of its hiding spot, on the floor in front of it, and the case notes it.
func reveal_loot() -> void:
	if loot_found:
		return
	loot_found = true
	var item: Node3D = LOOT_MODELS[loot].instantiate()
	item.name = "Loot"
	add_child(item)
	var spot := loot_spots[loot_spot] as Node3D
	var out: Vector3 = spot.get_meta("out")
	item.position = Vector3(spot.position.x, FLOOR_TOP, spot.position.z) + out
	item.rotation.y = atan2(out.x, out.z)
	if case:
		case.found_loot()


## The tuxedo by index (the order of the case's traits).
func suspect(index: int) -> CollisionObject3D:
	return tuxedos[index] if index >= 0 and index < tuxedos.size() else null


## Whether a point in the world (ignoring height) is in the hall.
func at_scene(world: Vector3) -> bool:
	var local := global_transform.affine_inverse() * world
	return absf(local.x) < HALF_X and absf(local.z) < HALF_Z


## The long head table under the banner, with a white skirt to the floor.
func _head_table() -> void:
	_build.box(HEAD_TABLE_AT + Vector3(0, FLOOR_TOP + HEAD_TABLE_SIZE.y / 2, 0), HEAD_TABLE_SIZE, TABLECLOTH)
	_build.mesh_box(HEAD_TABLE_AT + Vector3(0, FLOOR_TOP + 0.55, HEAD_TABLE_SIZE.z / 2 + 0.01),
		Vector3(HEAD_TABLE_SIZE.x, 0.12, 0.02), Color(0.93, 0.66, 0.75))
	var banner := Label3D.new()
	banner.name = "Banner"
	banner.text = "WEDDING_BANNER"
	banner.font_size = 48
	banner.pixel_size = 0.01
	banner.outline_size = 16
	banner.modulate = Color(0.95, 0.55, 0.7)
	banner.position = Vector3(HEAD_TABLE_AT.x, 2.3, -HALF_Z + 0.15)
	add_child(banner)
	_build.mesh_box(Vector3(HEAD_TABLE_AT.x, 2.3, -HALF_Z + 0.1), Vector3(HEAD_TABLE_SIZE.x + 1.0, 0.45, 0.02), GARLAND)


## The eight round tables, each with its tablecloth, a centerpiece and its number on a card.
func _round_tables() -> void:
	for i in TABLES.size():
		var at := TABLES[i]
		_round_table(at, TABLE_RADIUS)
		var top := at + Vector3(0, FLOOR_TOP + TABLE_HEIGHT, 0)
		table_tops.append(top)
		var flowers: Node3D = CENTERPIECE_MODEL.instantiate()
		flowers.name = "Centerpiece%d" % (i + 1)
		flowers.position = top
		add_child(flowers)
		var number := Label3D.new()
		number.name = "TableNumber%d" % (i + 1)
		number.text = str(i + 1)
		number.font_size = 64
		number.pixel_size = 0.004
		number.outline_size = 10
		number.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		number.modulate = Color(0.2, 0.2, 0.25)
		number.position = top + Vector3(0, 0.55, 0)
		add_child(number)


## A round table: a solid cylinder with its tablecloth to the floor (one body the cops bump into).
func _round_table(at: Vector3, radius: float) -> void:
	var cloth := CylinderMesh.new()
	cloth.top_radius = radius
	cloth.bottom_radius = radius + 0.06
	cloth.height = TABLE_HEIGHT
	_build.mesh(cloth, at + Vector3(0, FLOOR_TOP + TABLE_HEIGHT / 2, 0), TABLECLOTH)
	var body := StaticBody3D.new()
	body.position = at + Vector3(0, FLOOR_TOP + TABLE_HEIGHT / 2, 0)
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = radius
	cylinder.height = TABLE_HEIGHT
	shape.shape = cylinder
	body.add_child(shape)
	add_child(body)


## The three places to search: the cake, the coats on the rail and the head table's centerpiece. `out` is the way into
## the hall from each, as far as the stolen thing falls.
func _loot_spots() -> void:
	var cake_top := CAKE_TABLE_AT + Vector3(0, FLOOR_TOP + TABLE_HEIGHT, 0)
	_loot_spot("cake", cake_top + Vector3(0, 0.45, 0), Vector3(0.7, 0.9, 0.7), Vector3(1, 0, 1).normalized() * 0.9)
	_loot_spot("coats", COATS_AT + Vector3(0, FLOOR_TOP, 0), COATS_SIZE, Vector3.RIGHT * 0.6)
	var head_top := HEAD_TABLE_AT + Vector3(0, FLOOR_TOP + HEAD_TABLE_SIZE.y, 0)
	var flowers: Node3D = CENTERPIECE_MODEL.instantiate()
	flowers.name = "HeadCenterpiece"
	flowers.position = head_top
	add_child(flowers)
	_loot_spot("centerpiece", head_top + Vector3(0, 0.25, 0), Vector3(0.5, 0.5, 0.5), Vector3.BACK * 1.0)


func _loot_spot(spot: String, at: Vector3, size: Vector3, out: Vector3) -> void:
	var body := LootSpot.new(size)
	body.name = "Search_" + spot
	body.spot = spot
	body.place = self
	body.position = at
	body.set_meta("out", out)
	add_child(body)
	loot_spots[spot] = body


## The cake on its own round table in the back west corner.
func _cake() -> void:
	_round_table(CAKE_TABLE_AT, CAKE_TABLE_RADIUS)
	cake = CAKE_MODEL.instantiate()
	cake.name = "Cake"
	cake.position = CAKE_TABLE_AT + Vector3(0, FLOOR_TOP + TABLE_HEIGHT, 0)
	add_child(cake)


## The DJ's booth, with a body to bump into.
func _dj() -> void:
	dj_booth = DJ_MODEL.instantiate()
	dj_booth.name = "DjBooth"
	dj_booth.position = DJ_AT + Vector3(0, FLOOR_TOP, 0)
	add_child(dj_booth)
	_build.box(DJ_AT + Vector3(0, FLOOR_TOP + 0.5, 0), Vector3(1.6, 1.0, 0.6), Color(0.11, 0.11, 0.13))
	var name_label := Label3D.new()
	name_label.text = "DJ"
	name_label.font_size = 96
	name_label.pixel_size = 0.004
	name_label.outline_size = 8
	name_label.position = DJ_AT + Vector3(0, FLOOR_TOP + 0.6, 0.32)
	add_child(name_label)


## White garlands hanging along the side walls, and white balloons at the corners of the dance floor.
func _garlands() -> void:
	for x: float in [-HALF_X + 0.08, HALF_X - 0.08]:
		for k in 5:
			var z := -8.0 + k * 3.2
			_build.mesh_box(Vector3(x, ROOF - 0.35, z), Vector3(0.04, 0.12, 2.6), GARLAND)
			_build.mesh_box(Vector3(x, ROOF - 0.55, z), Vector3(0.04, 0.3, 0.2), Color(0.93, 0.66, 0.75))
	var dance := PartyHall.DANCE
	for corner: Vector2 in [dance.position, dance.position + Vector2(dance.size.x, 0),
			dance.position + Vector2(0, dance.size.y), dance.end]:
		for i in 3:
			var balloon := SphereMesh.new()
			balloon.radius = 0.2
			balloon.height = 0.46
			_build.mesh(balloon, Vector3(corner.x + (i - 1) * 0.3, 1.8 + (i % 2) * 0.35, corner.y),
				WHITE_BALLOONS[i])


## The rice on the floor by the entrance: RICE grains scattered with a fixed seed (the same in every match), in one
## multimesh.
func _rice() -> void:
	var grain := BoxMesh.new()
	grain.size = Vector3(0.05, 0.012, 0.025)
	var material := StandardMaterial3D.new()
	material.albedo_color = RICE_COLOR
	grain.material = material
	var many := MultiMesh.new()
	many.transform_format = MultiMesh.TRANSFORM_3D
	many.mesh = grain
	many.instance_count = RICE
	var rng := RandomNumberGenerator.new()
	rng.seed = 290
	for i in RICE:
		var x := RICE_AREA.position.x + rng.randf() * RICE_AREA.size.x
		var z := RICE_AREA.position.y + rng.randf() * RICE_AREA.size.y
		many.set_instance_transform(i, Transform3D(Basis(Vector3.UP, rng.randf() * TAU),
			Vector3(x, FLOOR_TOP + 0.006, z)))
	var rice := MultiMeshInstance3D.new()
	rice.name = "Rice"
	rice.multimesh = many
	add_child(rice)


## Tito and the five groomsmen, Rosa, DJ Bombo, grandma Chola with her ear trumpet and the guests at their tables.
func _people() -> void:
	var traits := WeddingTraits.draw(case_seed)
	for i in traits.size():
		var tuxedo := TuxedoGuest.new()
		tuxedo.name = "Tuxedo%d" % i
		tuxedo.traits = traits[i]
		tuxedo.index = i
		tuxedo.position = TUXEDOS_AT[i] + Vector3(0, FLOOR_TOP, 0)
		add_child(tuxedo)
		tuxedos.append(tuxedo)
	bride = _person("Bride", BRIDE_MODEL, "PROMPT_WEDDING_BRIDE", "WEDDING_BRIDE_LINE_", BRIDE_LINES, BRIDE_AT)
	dj = _person("Dj", DJ_PERSON_MODEL, "PROMPT_WEDDING_DJ", "WEDDING_DJ_LINE_", DJ_LINES, DJ_PERSON_AT)
	grandma = _person("Grandma", GRANDMA_MODEL, "PROMPT_WEDDING_GRANDMA", "WEDDING_GRANDMA_LINE_", GRANDMA_LINES,
		GRANDMA_AT, -PI / 2)
	ear_trumpet = TRUMPET_MODEL.instantiate()
	ear_trumpet.name = "EarTrumpet"
	ear_trumpet.position = table_tops[GRANDMA_TABLE] + Vector3(0.35, 0, 0.3)
	add_child(ear_trumpet)
	for i in GUESTS_AT.size():
		guests.append(_person("Guest%d" % i, GUEST_MODELS[i], "PROMPT_WEDDING_TALK", "WEDDING_GUEST_LINE_",
			GUEST_LINES, GUESTS_AT[i], GUESTS_TURN[i]))


func _person(id: String, look: PackedScene, prompt: String, line_key: String, lines: int, at: Vector3,
		turn := 0.0) -> WeddingPerson:
	var person := WeddingPerson.new()
	person.name = id
	person.model = look
	person.prompt = prompt
	person.line_key = line_key
	person.lines = lines
	person.position = at + Vector3(0, FLOOR_TOP, 0)
	person.rotation.y = turn
	add_child(person)
	return person
