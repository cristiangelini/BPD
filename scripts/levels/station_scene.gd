class_name StationScene
extends CrimeScenePlace

## The station crime scene (escena-comisaria.md): the place is the station the city already builds, with the evidence
## room behind the break room (EvidenceRoom). It sits on the station's lot and brings the six suspects into it: the
## five coworkers of StationStaff, each with their traits and their file (StaffFile), and the armero behind his counter;
## el Chancho waits in cell 1. The cops are at the scene once inside the evidence room. What was stolen is drawn with
## the seed. The clues (step 4b): the prints on the empty shelf (EvidenceShelf), the camera's tape (VcrDeck), the
## sign-out book on the lectern (GuestBook), a mug of coffee and a bitten donut on the cage's floor (CrimeClueItem),
## and el Chancho for a donut; at MOPA_WASH seconds don Mopa cleans the evidence room and takes the mug to wash it. The
## getaway comes in step 5. Every number here is (propuesta).

## What can go missing from the evidence room (BRIEF_STATION_A_<loot>, OBJ_STATION_LOOT_<loot>).
const LOOTS: Array[String] = ["necklace", "painting", "pillow"]
## Where the clues go, in the station's space: the empty spot on the shelf, the VCR on its table, the book on the
## lectern, and the mug and the donut on the cage's floor.
const SHELF_SPOT_AT := EvidenceRoom.EMPTY_SHELF_AT + Vector3(0, 0.72, 0)
const VCR_AT := EvidenceRoom.VCR_AT
const BOOK_AT := EvidenceRoom.LECTERN_AT + Vector3(0, 1.12, 0)
const CUP_AT := EvidenceRoom.EMPTY_SHELF_AT + Vector3(0.9, 0.05, 0.65)
const DONUT_AT := EvidenceRoom.EMPTY_SHELF_AT + Vector3(-0.7, 0.05, 0.7)
## Seconds after the tip when don Mopa cleans the evidence room (the mug, if nobody bagged it).
const MOPA_WASH := 240.0

## The city that built the station (its armero is one of the suspects).
var city: City
var case: CrimeSceneCase
var loot := ""
var people: Array[StationStaff] = []
var shelf: EvidenceShelf
var vcr: VcrDeck
var book: GuestBook
var clue_items := {}
var chancho: StationStaff
var _since_tip := 0.0
var mopa_cleaned := false


func _init() -> void:
	variant = "station"


func set_up_case(new_case: CrimeSceneCase) -> void:
	case = new_case
	loot = LOOTS[hash(["station loot", case.case_seed]) % LOOTS.size()]
	people = StationStaff.spawn_all(self, case.cooks)
	for person in people:
		var index := StaffTraits.IDS.find(person.who)
		if index >= 0:
			person.file = StaffFile.new(case, index, person)
	if city and city.armero:
		city.armero.file = StaffFile.new(case, 0, city.armero)
	chancho = people.filter(func(person: StationStaff) -> bool: return person.who == "chancho")[0]
	chancho.witness_case = case
	chancho.knows = case.plan.clues.has("witness")
	shelf = EvidenceShelf.new()
	shelf.name = "EmptyShelf"
	shelf.case = case
	shelf.has_prints = case.plan.clues.has("prints")
	shelf.position = SHELF_SPOT_AT
	add_child(shelf)
	vcr = VcrDeck.new()
	vcr.name = "Vcr"
	vcr.case = case
	vcr.has_tape = case.plan.clues.has("tape")
	vcr.position = VCR_AT
	vcr.rotation.y = -PI / 2
	add_child(vcr)
	book = GuestBook.new()
	book.name = "SignOutBook"
	book.case = case
	book.kind = "book"
	book.prompt = "PROMPT_SIGN_OUT_BOOK"
	book.signed_hint = "HINT_SIGN_OUT_SIGNED"
	book.has_signature = case.plan.clues.has("book")
	book.position = BOOK_AT
	add_child(book)
	for kind: String in ["cup", "bite"]:
		if not case.plan.clues.has(kind):
			continue
		var item := CrimeClueItem.new()
		item.name = "Clue_" + kind
		item.kind = kind
		item.look = "station"
		item.case = case
		item.position = CUP_AT if kind == "cup" else DONUT_AT
		add_child(item)
		clue_items[kind] = item
		case.items[kind] = item


## The suspect's body, by index (StaffTraits.IDS: the armero first).
func suspect(index: int) -> CollisionObject3D:
	if index == 0:
		return city.armero if city else null
	for person in people:
		if StaffTraits.IDS.find(person.who) == index:
			return person
	return null


## Whether a point in the world (ignoring height) is in the evidence room.
func at_scene(world: Vector3) -> bool:
	var local := to_local(world)
	return local.x > EvidenceRoom.FROM_X and local.x < EvidenceRoom.TO_X and local.z < EvidenceRoom.FROM_Z \
		and local.z > EvidenceRoom.TO_Z


## The witness took offense: el Chancho, his cell opened.
func witness_offended() -> bool:
	return chancho != null and chancho.offended


func offend_witness() -> void:
	if chancho:
		chancho.offend()


func _physics_process(delta: float) -> void:
	if not case or not case.tip_given:
		return
	_since_tip += delta
	if chancho and not chancho.offended and city and not city.cell_doors.is_empty() and city.cell_doors[0].is_open:
		chancho.offend()
	if not mopa_cleaned and _since_tip >= MOPA_WASH:
		mopa_cleaned = true
		var cup := clue_items.get("cup") as CrimeClueItem
		if cup and not cup.bagged and not cup.spoiled:
			cup.wash()
			cup.hide()
			for cop in get_tree().get_nodes_in_group("cops"):
				(cop as Cop).show_hint("HINT_MOPA_WASHED")
