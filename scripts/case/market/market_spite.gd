class_name MarketSpite
extends Node

## The spiteful vendor (politico-mercado.md, step 5, decision 120): one of the 12, drawn by the seed, put the laxative
## in the samples. Three clues give them away: white powder on their hands (DECOYS innocent vendors have flour or sugar
## too), the jar of "Laxante Exprés" in the bin behind their counter (every stall has a bin with a lid you lift with your
## hands, decision 76) and a laugh when the deputy stops at a stall with a bad sample. Cuffed, the samples not handed
## out yet are all clean (`caught`); walked to the patrol car, `jailed`. Cuffing an innocent vendor or a shopper costs
## image (`wrong_cuff`, MarketImage). Every number here is (propuesta).

signal found_jar
signal caught
signal jailed
signal wrong_cuff(who: Node3D)

const DECOYS := 2
const LAUGHS := 3
## The bin: behind the counter, beside the vendor; its size and how thick its walls are.
const BIN_BACK := 0.9
const BIN_ASIDE := 1.15
const BIN_SIZE := Vector3(0.42, 0.6, 0.42)
const BIN_WALL := 0.04
const BIN_MODEL := preload("res://assets/models/market_bin.glb")
const LID_MODEL := preload("res://assets/models/market_bin_lid.glb")

var market: MarketLevel
var tour: MarketTour
var samples: MarketSamples
var spiteful: MarketVendor
## Their stall (MarketLevel.stalls index).
var index := 0
var jar: LaxativeJar
var jar_found := false
var is_caught := false
var _line := 0


func setup(the_market: MarketLevel, the_tour: MarketTour, the_samples: MarketSamples, case_seed: int) -> void:
	market = the_market
	tour = the_tour
	samples = the_samples
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["market spite", case_seed])
	var order := range(market.stalls.size())
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	index = order[0]
	for i in market.stalls.size():
		var vendor: MarketVendor = market.stalls[i].vendor
		vendor.spiteful = i == index
		if order.find(i) <= DECOYS:
			vendor.powder()
		vendor.cuffed_now.connect(_on_vendor_cuffed)
		var escort := OwnerEscort.attach(vendor, market.car)
		escort.in_car_hint = "HINT_VENDOR_IN_CAR"
		if vendor.spiteful:
			escort.boarded.connect(func() -> void: jailed.emit())
		_bin(i)
	spiteful = market.stalls[index].vendor
	for shopper in market.shoppers:
		shopper.cuffed_now.connect(func(who: MarketShopper) -> void: wrong_cuff.emit(who))
	tour.arrived.connect(_on_arrived)


## The bin behind stall `i`'s counter, beside the vendor, with its lid on; the spiteful one's hides the jar.
func _bin(i: int) -> void:
	var stall: Dictionary = market.stalls[i]
	var facing: Vector3 = stall.facing
	var at := (stall.at as Vector3) - facing * BIN_BACK + facing.cross(Vector3.UP) * BIN_ASIDE
	at.y = MarketLevel.FLOOR_TOP
	var bin: Node3D = BIN_MODEL.instantiate()
	bin.name = "Bin%d" % i
	bin.position = at
	market.add_child(bin)
	var walls := StaticBody3D.new()
	bin.add_child(walls)
	var half := BIN_SIZE / 2
	for part: Array in [[Vector3(0, BIN_WALL / 2, 0), Vector3(BIN_SIZE.x, BIN_WALL, BIN_SIZE.z)],
			[Vector3(-half.x, half.y, 0), Vector3(BIN_WALL, BIN_SIZE.y, BIN_SIZE.z)],
			[Vector3(half.x, half.y, 0), Vector3(BIN_WALL, BIN_SIZE.y, BIN_SIZE.z)],
			[Vector3(0, half.y, -half.z), Vector3(BIN_SIZE.x, BIN_SIZE.y, BIN_WALL)],
			[Vector3(0, half.y, half.z), Vector3(BIN_SIZE.x, BIN_SIZE.y, BIN_WALL)]]:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = part[1]
		shape.shape = box
		shape.position = part[0]
		walls.add_child(shape)
	var lid := Grabbable.new()
	lid.name = "Lid%d" % i
	lid.mass = 0.5
	lid.collision_layer = 4
	lid.collision_mask = 15
	var lid_shape := CollisionShape3D.new()
	var disc := CylinderShape3D.new()
	disc.radius = 0.25
	disc.height = 0.04
	lid_shape.shape = disc
	lid.add_child(lid_shape)
	lid.add_child(LID_MODEL.instantiate())
	market.add_child(lid)
	lid.global_position = market.to_global(at + Vector3.UP * (BIN_SIZE.y + 0.03))
	if i == index:
		jar = LaxativeJar.new()
		jar.name = "LaxativeJar"
		market.add_child(jar)
		jar.global_position = market.to_global(at + Vector3.UP * 0.1)


func _on_arrived(stall: int) -> void:
	if is_caught or not samples.laxed.has(stall):
		return
	spiteful.say("VENDOR_SPITE_LAUGH_%d" % (_line % LAUGHS + 1))
	_line += 1


func _on_vendor_cuffed(vendor: MarketVendor) -> void:
	if not vendor.spiteful:
		wrong_cuff.emit(vendor)
		return
	if is_caught:
		return
	is_caught = true
	samples.clean_rest()
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_SPITE_CAUGHT")
	caught.emit()


func _physics_process(_delta: float) -> void:
	if jar_found or not jar or not jar.is_held():
		return
	jar_found = true
	var mark := Label3D.new()
	mark.name = "Mark"
	mark.text = "!"
	mark.position = Vector3(0, 1.75, 0)
	mark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	mark.pixel_size = 0.006
	mark.font_size = 64
	mark.outline_size = 12
	mark.modulate = Color(1, 0.25, 0.2)
	spiteful.add_child(mark)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_JAR_FOUND")
	found_jar.emit()
