class_name DoubleClownRig
extends BirthdayRaidRig

## The double clown (allanamiento-cumple.md, "El payaso doble"): there are two Chispitas taking turns, so one can
## entertain while the other cases a house; the second costume, with the plan of a house in its pocket, is hidden.
## Every HONK_EVERY seconds Chispita's horn sounds in the restroom where he isn't: a cop who hears it gets the story's
## own clue on the checklist. Every SWAP_EVERY seconds they swap, and the one coming back has other shoes. Every number
## here is (propuesta).

const HONK_EVERY := 25.0
## The other one honks in the restroom, and no honk while Chispita stands this close to it.
const HONK_AT := Vector3(PartyHall.RESTROOM_X + 1.0, BirthdayRaid.FLOOR_TOP + 1.2, PartyHall.RESTROOM_DOOR_Z)
const HONK_FAR := 4.0
const HEAR := 6.0
const SWAP_EVERY := 60.0
## The other one's shoes, much smaller.
const SMALL_SHOES := Vector3(0.85, 1.0, 0.55)
const BRASS := Color(0.95, 0.75, 0.3)

## Which of the two is entertaining (0 or 1).
var twin := 0
var honk_left := HONK_EVERY
var swap_left := SWAP_EVERY
## How many times the horn honked (online the guests show each one).
var honks := 0
var _shoes: Node3D


func setup(place: BirthdayRaid) -> void:
	super.setup(place)
	_shoes = place.chispita.find_child("shoes", true, false)


func _physics_process(delta: float) -> void:
	if not party or party.singing() or not multiplayer.is_server():
		return
	honk_left -= delta
	if honk_left <= 0.0:
		honk()
	swap_left -= delta
	if swap_left <= 0.0:
		swap()


## The other one's horn in the restroom: "¡Mec, mec!", unless Chispita is right there.
func honk() -> void:
	honk_left = HONK_EVERY
	var at := party.to_global(HONK_AT)
	if party.chispita.global_position.distance_to(at) < HONK_FAR:
		return
	honks += 1
	_show_honk()
	for node in party.get_tree().get_nodes_in_group("cops"):
		if (node as Node3D).global_position.distance_to(at) < HEAR:
			party.raid.add_clue(tr("CLUE_DOUBLE_CLOWN"))
			return


func _show_honk() -> void:
	party.raid.float_label(tr("BIRTHDAY_HONK"), party.to_global(HONK_AT), BRASS)


## They swap: the one coming back from the restroom has other shoes.
func swap() -> void:
	swap_left = SWAP_EVERY
	_set_twin(1 - twin)
	party.chispita.praise(0.0, "CHISPITA_BACK")


func _set_twin(which: int) -> void:
	twin = which
	if _shoes:
		_shoes.scale = SMALL_SHOES if twin == 1 else Vector3.ONE


func net_state() -> Variant:
	return [twin, honks]


func apply_net_state(state: Variant) -> void:
	if state[0] != twin:
		_set_twin(state[0])
	if state[1] > honks:
		honks = state[1]
		_show_honk()
