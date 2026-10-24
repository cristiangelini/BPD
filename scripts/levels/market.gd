class_name MarketLevel
extends Node3D

## The city's covered market (politico-mercado.md, step 1, decision 120): a hall on block (2, 0), the front to +Z, where
## the deputy walks and tastes everything. Two wide doorways in the front: the entrance on the west and the way out on
## the east, with the ribbon for the closing photo across it. Inside, a U-shaped aisle around a cold room in the middle:
## up the west side, across the back and down the east side, with 12 stalls along it, their goods drawn by the seed.
## Each stall has its vendor behind the counter (MarketVendor) and a few shoppers stand at the counters
## (MarketShopper). At the back, between the two back stalls, the chemical toilet. The cops start in the station and
## drive here; --place=market opens it from Play. Step 2: Deputy Lustre waits outside the way in and walks the aisle
## stall by stall (MarketTour). Step 3: the samples he's handed, some with laxative (MarketSamples). Step 4: cramps
## for the cops who bite one (Cramps), the toilet that locks in and cures (ChemicalToilet) and the deputy's run to it
## or home (MarketToiletRun). Step 5: the spiteful vendor with the clues (MarketSpite) and the deputy's image
## (MarketImage). Every number here is (propuesta).

const STALL_MODEL := preload("res://assets/models/market_stall.glb")
## What the 12 stalls sell; the seed spreads them along the aisle.
const KINDS: Array[String] = ["fruit", "cheese", "empanadas", "fish", "pickles", "olives", "bread", "sweets", "juice",
	"meat", "spices", "ice_cream"]
## The hall (CityLayout "market"): 30 x 22 m and 6 m tall, with the two doorways 3 m wide in the front wall.
const HALF_X := 15.0
const HALF_Z := 11.0
const ROOF := 6.0
const FLOOR_TOP := 0.06
const DOORWAY := 3.0
const DOORWAY_HEIGHT := 3.0
const ENTRANCE_X := -10.0
const EXIT_X := 10.0
## The cold room in the middle, the stalls' back on its west and east sides.
const ISLAND := Rect2(-4.2, -5.0, 8.4, 13.0)
const ISLAND_HEIGHT := 2.6
## The stalls in the order the deputy walks by them: where the middle of each counter is and which way its customers'
## side faces (+X, -X or +Z). The vendor stands VENDOR_BACK behind it.
const STALLS: Array[Array] = [
	[Vector3(-13.4, 0, 6.0), Vector3.RIGHT], [Vector3(-5.6, 0, 3.0), Vector3.LEFT],
	[Vector3(-13.4, 0, 0.0), Vector3.RIGHT], [Vector3(-5.6, 0, -3.0), Vector3.LEFT],
	[Vector3(-13.4, 0, -6.0), Vector3.RIGHT], [Vector3(-3.0, 0, -9.4), Vector3.BACK],
	[Vector3(3.0, 0, -9.4), Vector3.BACK], [Vector3(13.4, 0, -6.0), Vector3.LEFT],
	[Vector3(5.6, 0, -3.0), Vector3.RIGHT], [Vector3(13.4, 0, 0.0), Vector3.LEFT],
	[Vector3(5.6, 0, 3.0), Vector3.RIGHT], [Vector3(13.4, 0, 6.0), Vector3.LEFT],
]
const COUNTER := Vector3(3.0, 0.97, 0.8)
const VENDOR_BACK := 0.9
## Where the deputy stops in front of a stall: this far out from the counter.
const CUSTOMER_OUT := 1.3
## The chemical toilet at the back, its door to +Z.
const TOILET_AT := Vector3(0, 0, -10.2)
## The ribbon for the photo across the way out, between two posts.
const RIBBON_Z := 9.0
const RIBBON_FROM := 7.0
const RIBBON_TO := 12.5
## The aisle's four stretches around the cold room, each by its middle line: the west and east sides (x) and the back
## and front (z); and the corner where two of them meet.
const AISLE_X := 9.5
const AISLE_BACK := -7.6
const AISLE_FRONT := 9.6
## How many shoppers stand at the counters, and how far to the side of the counter's middle: the deputy's spot
## stays free.
const SHOPPERS := 10
const SHOPPER_ASIDE := Vector2(0.8, 1.1)
const AWNINGS: Array[Color] = [Color(0.85, 0.25, 0.18), Color(0.2, 0.5, 0.85), Color(0.25, 0.65, 0.3),
	Color(0.95, 0.65, 0.15), Color(0.6, 0.3, 0.7), Color(0.9, 0.4, 0.6)]

const WALL := Color(0.88, 0.8, 0.62)
const TILE := Color(0.78, 0.7, 0.58)
const ISLAND_WALL := Color(0.8, 0.86, 0.88)
const BEAM := Color(0.45, 0.32, 0.22)
const RIBBON := Color(0.9, 0.12, 0.15)
const POST := Color(0.85, 0.7, 0.2)

## The case's seed: which stall sells what (step 1), which samples carry laxative and who put it there (later steps).
var case_seed := 0
## Stall by stall, in walking order: {kind, at (the counter's middle), facing, vendor, stop (where the deputy stands)}.
var stalls: Array[Dictionary] = []
var shoppers: Array[MarketShopper] = []
## The chemical toilet at the back (step 4: it locks in and cures cramps).
var toilet: ChemicalToilet
## Deputy Lustre (step 2), waiting outside the way in, and his walk along the stalls.
var politician: Politician
var tour: MarketTour
## The samples he's handed, some with laxative (step 3).
var samples: MarketSamples
## His run to the toilet, or home (step 4).
var toilet_run: MarketToiletRun
## The spiteful vendor and the clues, and the deputy's image (step 5).
var spite: MarketSpite
var image: MarketImage
var _build: PlaceBuilder

@onready var car: PatrolCar = $PatrolCar
@onready var city: Node3D = $City


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_stalls()
	_build_back()
	_place_shoppers()
	politician = Politician.new()
	politician.name = "Politician"
	add_child(politician)
	politician.position = Vector3(ENTRANCE_X, FLOOR_TOP, HALF_Z + 2.5)
	# Facing the street, waiting for his guard.
	politician.rotation.y = PI
	tour = MarketTour.new()
	tour.name = "Tour"
	tour.setup(self, politician, case_seed)
	add_child(tour)
	samples = MarketSamples.new()
	samples.name = "Samples"
	add_child(samples)
	samples.setup(self, tour, case_seed)
	toilet_run = MarketToiletRun.new()
	toilet_run.name = "ToiletRun"
	add_child(toilet_run)
	toilet_run.setup(self, tour, samples)
	spite = MarketSpite.new()
	spite.name = "Spite"
	add_child(spite)
	spite.setup(self, tour, samples, case_seed)
	image = MarketImage.new()
	image.name = "Image"
	add_child(image)
	image.setup(tour, samples, spite)
	city.transform = CityLayout.anchor("market")
	car.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)


## What each stall sells, in walking order: the 12 kinds shuffled by the seed.
static func kinds_for(seed_value: int) -> Array[String]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["market stalls", seed_value])
	var kinds := KINDS.duplicate()
	for i in range(kinds.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: String = kinds[i]
		kinds[i] = kinds[j]
		kinds[j] = swap
	return kinds


## Whether a world position is inside the hall.
func inside(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return absf(local.x) < HALF_X and absf(local.z) < HALF_Z


## The floor, the walls with the two doorways and their signs, the roof on its beams and the lights.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP + 0.02, TILE)
	_build.slab(-HALF_X - 0.3, HALF_X + 0.3, -HALF_Z - 0.3, HALF_Z + 0.3, ROOF + 0.2, WALL.darkened(0.45))
	var y := ROOF / 2
	_build.box(Vector3(0, y, -HALF_Z), Vector3(HALF_X * 2, ROOF, PlaceBuilder.WALL), WALL)
	for side: float in [-1.0, 1.0]:
		_build.box(Vector3(side * HALF_X, y, 0), Vector3(PlaceBuilder.WALL, ROOF, HALF_Z * 2), WALL)
	# The front: solid between and beside the doorways, with a lintel over each.
	var edges: Array[float] = [-HALF_X, ENTRANCE_X - DOORWAY / 2, ENTRANCE_X + DOORWAY / 2, EXIT_X - DOORWAY / 2,
		EXIT_X + DOORWAY / 2, HALF_X]
	for i in range(0, edges.size(), 2):
		var middle := (edges[i] + edges[i + 1]) / 2
		_build.box(Vector3(middle, y, HALF_Z), Vector3(edges[i + 1] - edges[i], ROOF, PlaceBuilder.WALL), WALL)
	for x: float in [ENTRANCE_X, EXIT_X]:
		var lintel := ROOF - DOORWAY_HEIGHT
		_build.box(Vector3(x, DOORWAY_HEIGHT + lintel / 2, HALF_Z), Vector3(DOORWAY, lintel, PlaceBuilder.WALL), WALL)
	_label("PLACE_MARKET", Vector3(0, DOORWAY_HEIGHT + 1.4, HALF_Z + 0.12), 0.0, 96)
	_label("MARKET_IN", Vector3(ENTRANCE_X, DOORWAY_HEIGHT + 0.4, HALF_Z + 0.12), 0.0, 48)
	_label("MARKET_OUT", Vector3(EXIT_X, DOORWAY_HEIGHT + 0.4, HALF_Z + 0.12), 0.0, 48)
	for x: float in [-10.0, -5.0, 0.0, 5.0, 10.0]:
		_build.mesh_box(Vector3(x, ROOF - 0.25, 0), Vector3(0.3, 0.5, HALF_Z * 2), BEAM)
	for x: float in [-10.0, 0.0, 10.0]:
		for z: float in [-7.0, 0.0, 7.0]:
			var lamp := OmniLight3D.new()
			lamp.position = Vector3(x, ROOF - 1.2, z)
			lamp.light_color = Color(1.0, 0.93, 0.8)
			lamp.light_energy = 1.5
			lamp.omni_range = 10.0
			$Built.add_child(lamp)
	# The cold room in the middle, with crates piled on its front.
	var island := Vector3(ISLAND.get_center().x, ISLAND_HEIGHT / 2 + FLOOR_TOP, ISLAND.get_center().y)
	_build.box(island, Vector3(ISLAND.size.x, ISLAND_HEIGHT, ISLAND.size.y), ISLAND_WALL)
	for i in 4:
		_build.box(Vector3(-2.4 + i * 1.6, FLOOR_TOP + 0.3, ISLAND.end.y + 0.35), Vector3(1.0, 0.6, 0.6), BEAM.lightened(0.3))


## The 12 stalls along the aisle: the model, its awning's color, a solid counter, its goods, its sign and its vendor.
func _build_stalls() -> void:
	var kinds := kinds_for(case_seed)
	for i in STALLS.size():
		var at: Vector3 = STALLS[i][0]
		var facing: Vector3 = STALLS[i][1]
		var turn := atan2(facing.x, facing.z)
		var floor_at := at + Vector3.UP * FLOOR_TOP
		var stall: Node3D = STALL_MODEL.instantiate()
		stall.name = "Stall%d" % i
		stall.position = floor_at
		stall.rotation.y = turn
		$Built.add_child(stall)
		_tint(stall.find_child("awning", true, false), AWNINGS[i % AWNINGS.size()])
		var solid := _build.body(floor_at + Vector3.UP * COUNTER.y / 2)
		solid.rotation.y = turn
		_build.shape(solid, COUNTER)
		var goods: Node3D = load("res://assets/models/market_food_%s.glb" % kinds[i]).instantiate()
		goods.position = floor_at + Vector3.UP * COUNTER.y
		goods.rotation.y = turn
		$Built.add_child(goods)
		_label("MARKET_STALL_%s" % kinds[i].to_upper(), floor_at + Vector3.UP * 2.75 + facing * 0.7, turn, 40)
		var vendor := MarketVendor.new()
		vendor.name = "Vendor%d" % i
		vendor.kind = kinds[i]
		vendor.apron = AWNINGS[(i + 2) % AWNINGS.size()]
		vendor.position = floor_at - facing * VENDOR_BACK
		# NPCs face -Z: turned to look at the customers.
		vendor.rotation.y = turn + PI
		add_child(vendor)
		stalls.append({"kind": kinds[i], "at": at, "facing": facing, "vendor": vendor,
			"stop": at + facing * (COUNTER.z / 2 + CUSTOMER_OUT)})


## The chemical toilet between the two back stalls and the ribbon with its posts across the way out.
func _build_back() -> void:
	toilet = ChemicalToilet.new()
	toilet.name = "Toilet"
	toilet.position = TOILET_AT + Vector3.UP * FLOOR_TOP
	$Built.add_child(toilet)
	for x: float in [RIBBON_FROM, RIBBON_TO]:
		_build.box(Vector3(x, FLOOR_TOP + 0.55, RIBBON_Z), Vector3(0.12, 1.1, 0.12), POST)
	var length := RIBBON_TO - RIBBON_FROM
	_build.mesh_box(Vector3((RIBBON_FROM + RIBBON_TO) / 2, FLOOR_TOP + 1.0, RIBBON_Z), Vector3(length, 0.12, 0.02), RIBBON)
	_build.mesh_box(Vector3((RIBBON_FROM + RIBBON_TO) / 2, FLOOR_TOP + 1.0, RIBBON_Z), Vector3(0.3, 0.3, 0.06), RIBBON)


## A way to walk from `from` to `to` (world space) along the aisle, around the cold room and the stalls: the corners
## to go through, then `to`. Of the two ways around, the shorter.
func aisle_path(from: Vector3, to: Vector3) -> Array[Vector3]:
	var a := _stretch(to_local(from))
	var b := _stretch(to_local(to))
	var ring := ["w", "b", "e", "f"]
	var corners := {"wb": Vector2(-AISLE_X, AISLE_BACK), "be": Vector2(AISLE_X, AISLE_BACK),
		"ef": Vector2(AISLE_X, AISLE_FRONT), "fw": Vector2(-AISLE_X, AISLE_FRONT)}
	var best: Array[Vector3] = [to]
	var best_length := INF
	for way: int in [1, -1]:
		var path: Array[Vector3] = []
		var at := ring.find(a)
		while ring[at] != b:
			var next := posmod(at + way, ring.size())
			var key: String = ring[at] + ring[next] if way == 1 else ring[next] + ring[at]
			var corner: Vector2 = corners[key]
			path.append(to_global(Vector3(corner.x, 0, corner.y)))
			at = next
		path.append(to)
		var length := 0.0
		var last := from
		for point in path:
			length += last.distance_to(point)
			last = point
		if length < best_length:
			best_length = length
			best = path
	return best


## Which stretch of the aisle a point in the hall's space is on: w, e, b (back) or f (front).
func _stretch(local: Vector3) -> String:
	if local.x < ISLAND.position.x - 0.5:
		return "w"
	if local.x > ISLAND.end.x + 0.5:
		return "e"
	return "b" if local.z < ISLAND.position.y else "f"


## Where the deputy stands for the photo: in the middle of the ribbon, on the inside.
func photo_spot() -> Vector3:
	return Vector3((RIBBON_FROM + RIBBON_TO) / 2, 0, RIBBON_Z - 0.8)


## SHOPPERS shoppers, each at the counter of a different stall drawn by the seed, a little to one side.
func _place_shoppers() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["market shoppers", case_seed])
	var order := range(STALLS.size())
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	for i in SHOPPERS:
		var stall := stalls[order[i]]
		var facing: Vector3 = stall.facing
		var side := 1.0 if rng.randf() < 0.5 else -1.0
		var aside := facing.cross(Vector3.UP) * rng.randf_range(SHOPPER_ASIDE.x, SHOPPER_ASIDE.y) * side
		var shopper := MarketShopper.new()
		shopper.name = "Shopper%d" % i
		shopper.look = MarketShopper.LOOKS[rng.randi() % MarketShopper.LOOKS.size()]
		shopper.next_line = rng.randi() % MarketShopper.LINES
		shopper.position = (stall.at as Vector3) + facing * (COUNTER.z / 2 + 0.7) + aside + Vector3.UP * FLOOR_TOP
		# Facing the counter, which is -facing; NPCs face -Z.
		shopper.rotation.y = atan2(facing.x, facing.z)
		add_child(shopper)
		shoppers.append(shopper)


func _label(key: String, at: Vector3, turn: float, size: int) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = size
	label.pixel_size = 0.01
	label.outline_size = 12
	label.position = at
	label.rotation.y = turn
	$Built.add_child(label)


func _tint(part: Node, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part.find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
