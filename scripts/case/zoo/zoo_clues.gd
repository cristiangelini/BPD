class_name ZooClues
extends Node

## The zoo case's clues where they go (escena-zoo.md, "Las pistas"), put by Zoo when the case comes: prints on the
## penguins' glass (a keeper cleans it at GLASS_CLEANED_AT), a boot print in the mud by the pool (the ostrich running
## over it wipes it), a hair in the cap lost by the floe and a bitten cookie on the ticket booth's counter (the loose
## monkey takes them), Copito's blanket on his floe, the peck (ZooKeeper.show_hands) and Don Pico, the witness
## (ZooParrot). What the elephant soaks (Zoo.washed) is lost. Every number here is (propuesta).

const GLASS_PRINTS_AT := Vector3(-3.5, 1.2, Zoo.GLASS_Z + 0.08)
const GLASS_PRINTS_SIZE := Vector2(1.2, 0.8)
const FOOTPRINT_AT := Vector3(-2.0, 0.02, 5.5)
const CAP_AT := Vector3(4.6, Zoo.GROUND_TOP, 3.0)
const COUNTER_AT := Zoo.BOOTH_AT + Vector3(0, 1.0, 1.05)
const BLANKET_AT := Zoo.ICE_AT + Vector3(0.55, 0.6, 0.4)
## When the keeper on duty cleans the glass (s from the start), and how close the ostrich wipes the boot print.
const GLASS_CLEANED_AT := 240.0
const OSTRICH_STEP := 0.6
const MUD := Color(0.4, 0.28, 0.16)

var zoo: Zoo
var case: CrimeSceneCase
var glass: EmptyFrame
var footprint: FlourPrint
var blanket: ZooBlanket
var clock := 0.0
var glass_cleaned := false


func _ready() -> void:
	var plan := case.plan
	var who := case.culprit()
	glass = EmptyFrame.new(GLASS_PRINTS_SIZE)
	glass.name = "GlassPrints"
	glass.look = "GLASS"
	glass.case = case
	glass.has_prints = plan.clues.has("prints")
	glass.position = GLASS_PRINTS_AT
	zoo.add_child(glass)
	blanket = ZooBlanket.new()
	blanket.name = "Blanket"
	blanket.case = case
	blanket.smells = plan.clues.has("blanket")
	blanket.position = BLANKET_AT
	zoo.add_child(blanket)
	var counter := PlaceBuilder.new(zoo)
	counter.box(COUNTER_AT, Vector3(1.6, 0.06, 0.3), Zoo.WOOD)
	if plan.clues.has("footprint"):
		footprint = FlourPrint.new()
		footprint.name = "MudPrint"
		footprint.case = case
		footprint.shoe = who.shoe
		footprint.dust = MUD
		footprint.position = FOOTPRINT_AT
		zoo.add_child(footprint)
		case.flour_print = footprint
	if plan.clues.has("hair"):
		_clue_item("hair", CAP_AT)
	if plan.clues.has("bite"):
		_clue_item("bite", COUNTER_AT + Vector3(0.3, 0.03, 0))
	zoo.parrot.case = case
	zoo.parrot.knows = plan.clues.has("witness")
	zoo.washed.connect(_washed)


func _clue_item(kind: String, at: Vector3) -> void:
	var item := CrimeClueItem.new()
	item.name = "Clue_" + kind
	item.kind = kind
	item.look = "zoo"
	item.case = case
	item.hair_color = CookTraits.HAIRS[case.culprit().hair]
	item.position = at
	zoo.add_child(item)
	case.items[kind] = item


func _physics_process(delta: float) -> void:
	if case.follower:
		return
	clock += delta
	if not glass_cleaned and clock >= GLASS_CLEANED_AT:
		clean_glass()
	var ostrich := zoo.animals.get("ostrich") as ZooAnimal
	if footprint and not footprint.wiped and ostrich and ostrich.state != "in":
		var off := ostrich.global_position - footprint.global_position
		if Vector2(off.x, off.z).length() <= OSTRICH_STEP:
			footprint.wipe()


## The keeper on duty cleans the penguins' glass: prints not taken yet are gone.
func clean_glass() -> void:
	glass_cleaned = true
	glass.touched = true
	if glass.has_prints and not case.clues_found.has("prints"):
		case.ruin("prints")


## The elephant soaked the spot `at` (world) within `radius`: the prints, the boot print, the loose clues and the
## blanket there are lost.
func _washed(at: Vector3, radius: float) -> void:
	var near := func(node: Node3D) -> bool:
		var off := node.global_position - at
		return Vector2(off.x, off.z).length() <= radius
	if near.call(glass) and glass.has_prints and not case.clues_found.has("prints"):
		glass.touched = true
		case.ruin("prints")
	if footprint and near.call(footprint):
		footprint.wipe()
	if near.call(blanket):
		blanket.soak()
	for kind: String in ["hair", "bite"]:
		var item := case.items.get(kind) as CrimeClueItem
		if item and is_instance_valid(item) and near.call(item):
			item.wash()
