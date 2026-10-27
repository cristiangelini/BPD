class_name StationScene
extends CrimeScenePlace

## The station crime scene (escena-comisaria.md): the place is the station the city already builds, with the evidence
## room behind the break room (EvidenceRoom). It sits on the station's lot and brings the six suspects into it: the
## five coworkers of StationStaff, each with their traits and their file (StaffFile), and the armero behind his counter;
## el Chancho waits in cell 1. The cops are at the scene once inside the evidence room. What was stolen is drawn with
## the seed. The clues (step 4b): the prints on the empty shelf (EvidenceShelf), the camera's tape (VcrDeck), the
## sign-out book on the lectern (GuestBook), a mug of coffee and a bitten donut on the cage's floor (CrimeClueItem),
## and el Chancho for a donut; at MOPA_WASH seconds don Mopa cleans the evidence room and takes the mug to wash it.
## Accused, half the culprits take the old patrol car parked by the station (ChaseLevel.OLD_CAR_SPOT), and if internal
## affairs gets there first its agent comes in by the front door (`ia_arrives`). Every number here is (propuesta).

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
	# Online the host's evidence room says when don Mopa cleaned (net_state).
	if case.follower:
		return
	if chancho and not chancho.offended and city and not city.cell_doors.is_empty() and city.cell_doors[0].is_open:
		chancho.offend()
	if not mopa_cleaned and _since_tip >= MOPA_WASH:
		_mopa_cleans()


## Don Mopa cleans the evidence room: the mug, if nobody bagged it, goes to be washed.
func _mopa_cleans() -> void:
	mopa_cleaned = true
	var cup := clue_items.get("cup") as CrimeClueItem
	if cup and not cup.bagged and not cup.spoiled:
		cup.wash()
		cup.hide()
		for cop in get_tree().get_nodes_in_group("cops"):
			(cop as Cop).show_hint("HINT_MOPA_WASHED")


## Online, what the guests' station takes from the host's: who already said where they were, the shelf touched, the
## tape watched or recorded over, the book signed over, don Mopa's cleaning, and internal affairs' warning and arrival.
func net_state() -> Dictionary:
	if not case:
		return {}
	var signed := []
	for i in StaffTraits.IDS.size():
		var body := suspect(i)
		signed.append(body != null and body.get("file") != null and (body.file as StaffFile).signed)
	return {"signed": signed, "shelf": shelf.touched, "tape": [vcr.watched, vcr.overwritten],
		"book": book.signed_over, "mopa": mopa_cleaned, "ia": [case.ia_warned, case.ia_arrived]}


func apply_net_state(state: Dictionary) -> void:
	if not case or not state.has("signed"):
		return
	for i in state.signed.size():
		var body := suspect(i)
		if body and body.get("file") != null:
			(body.file as StaffFile).signed = state.signed[i]
	shelf.touched = state.shelf
	vcr.watched = state.tape[0]
	vcr.overwritten = state.tape[1]
	book.signed_over = state.book
	if state.mopa and not mopa_cleaned:
		_mopa_cleans()
	if state.ia[0] and not case.ia_warned:
		case.ia_warned = true
		case._hint_all("HINT_IA_SOON")
	if state.ia[1] and not case.ia_arrived:
		case.ia_arrived = true
		case._hint_all("HINT_IA_ARRIVED")
		ia_arrives()


## The old patrol car by the station, where the culprit runs off from.
func getaway(_index: int, _city: Node3D) -> Dictionary:
	return {"at": global_transform * ChaseLevel.OLD_CAR_SPOT, "via": []}


## Internal affairs took the case: its agent comes in by the front door, and follows the cops with his folder.
func ia_arrives() -> InternalAffairsAgent:
	var agent := InternalAffairsAgent.new()
	agent.name = "InternalAffairsAgent"
	get_parent().add_child(agent)
	agent.global_position = global_transform * Vector3(0, 0.05, StationRooms.HALF_Z - 1.0)
	return agent
