class_name HotelClues
extends Node

## The hotel case's clues in the suite (escena-hotel.md, "Las pistas"), put by Hotel when the case comes: the open safe
## with the prints, the bare footprint on the bathroom's wet mat, the hair on the pillow and the bitten bonbon on it.
## And doña Escoba: once a cop walks into the hotel she starts her round down the corridor, and if she gets into the
## suite she changes the pillowcase (the hair goes) and vacuums the bathroom (the footprint goes), unless the card on
## the suite's door says "No molestar". Every number here is (propuesta).

const MAID_SPEED := 0.6
## Seconds she waits before trying again when the card turned her away.
const MAID_RETRY := 20.0
## Her round, in the hotel's space at the upper floor: where she goes, how long she stays and what she does there.
const ROUND: Array[Dictionary] = [
	{"at": Vector3(1.25, 0, 0), "wait": 6.0},
	{"at": Vector3(-0.25, 0, 0), "wait": 6.0},
	{"at": Vector3(-4.5, 0, 0), "wait": 6.0},
	{"at": Vector3(-6.0, 0, 0), "do": "knock"},
	{"at": Vector3(-8.5, 0, 0)},
	{"at": Vector3(-8.3, 0, 3.0), "wait": 4.0, "do": "pillow"},
	{"at": Vector3(-8.5, 0, -6.5)},
	{"at": Vector3(-11.2, 0, -6.5), "wait": 4.0, "do": "bath"},
	{"at": Vector3(-8.5, 0, -6.5)},
	{"at": Vector3(-8.5, 0, 0)},
	{"at": Vector3(-6.0, 0, 0)},
	{"at": Vector3(7.5, 0, 0), "do": "back"},
]
const PILLOW_TOP := 0.73
const HAIR_AT := Vector3(-0.3, PILLOW_TOP, 0.7)
const BONBON_AT := Vector3(0.4, PILLOW_TOP, 0.7)
const FOOTPRINT_AT := Vector3(-11.6, 0, -6.0)
const MAT := Color(0.55, 0.72, 0.85)
const HANGER_AT := Vector3(Hotel.SUITE_X + 0.16, 1.1, Hotel.DOOR_SUITE_Z + 0.8)

var hotel: Hotel
var case: CrimeSceneCase
var safe: EmptyFrame
var hanger: DoorHanger
var footprint: FlourPrint
## Her round: walking once a cop is in, and done once she cleaned the suite.
var maid_walking := false
var suite_cleaned := false
var _step := 0
var _wait := 0.0


func _ready() -> void:
	var plan := case.plan
	safe = EmptyFrame.new(Vector2(0.34, 0.42))
	safe.name = "Safe"
	safe.look = "SAFE"
	safe.case = case
	safe.has_prints = plan.clues.has("prints")
	safe.position = Hotel.SAFE_AT + Vector3(0.06, 0, 0)
	safe.rotation.y = PI / 2
	hotel.add_child(safe)
	hanger = DoorHanger.new()
	hanger.name = "DoorHanger"
	hanger.position = HANGER_AT + Vector3(0, Hotel.UP, 0)
	hotel.add_child(hanger)
	if plan.clues.has("footprint"):
		footprint = FlourPrint.new()
		footprint.name = "WetPrint"
		footprint.case = case
		footprint.shoe = case.culprit().shoe
		footprint.dust = MAT
		footprint.position = FOOTPRINT_AT + Vector3(0, Hotel.UP, 0)
		hotel.add_child(footprint)
		case.flour_print = footprint
	if plan.clues.has("hair"):
		_clue_item("hair", HAIR_AT)
	if plan.clues.has("bite"):
		_clue_item("bite", BONBON_AT)


func _clue_item(kind: String, at: Vector3) -> void:
	var item := CrimeClueItem.new()
	item.name = "Clue_" + kind
	item.kind = kind
	item.look = "hotel"
	item.case = case
	item.hair_color = CookTraits.HAIRS[case.culprit().hair]
	item.position = Hotel.SUITE_BED_AT + at
	hotel.add_child(item)
	case.items[kind] = item


func _physics_process(delta: float) -> void:
	# Online the host's hotel moves the maid.
	if case.follower or suite_cleaned and _step == 0:
		return
	if not maid_walking:
		for cop in get_tree().get_nodes_in_group("cops"):
			if hotel.inside((cop as Node3D).global_position):
				maid_walking = true
		return
	walk_maid(delta)


## One step of doña Escoba's round: walking to the next stop, or waiting at it.
func walk_maid(delta: float) -> void:
	var maid := hotel.maid
	if _wait > 0.0:
		_wait -= delta
		return
	var stop: Dictionary = ROUND[_step]
	var target: Vector3 = stop.at + Vector3(0, Hotel.UP, 0)
	var off := target - maid.position
	var step := MAID_SPEED * delta
	if off.length() > step:
		maid.position += off.normalized() * step
		maid.rotation.y = atan2(off.x, off.z)
		return
	maid.position = target
	_wait = stop.get("wait", 0.0)
	_step += 1
	match stop.get("do", ""):
		"knock":
			if hanger.hung:
				maid.say(tr("HOTEL_MAID_DND"))
				_wait = MAID_RETRY
				_step = ROUND.size() - 1
		"pillow":
			maid.say(tr("HOTEL_MAID_PILLOW"))
			change_pillowcase()
		"bath":
			maid.say(tr("HOTEL_MAID_BATH"))
			if footprint and not footprint.wiped:
				footprint.wipe()
			suite_cleaned = true
		"back":
			_step = 0
			_wait = MAID_RETRY


## A clean pillowcase: the hair on the pillow goes with the dirty one, unless a cop took it already.
func change_pillowcase() -> void:
	var hair: CrimeClueItem = case.items.get("hair")
	if hair and hotel.to_local(hair.global_position).distance_to(Hotel.SUITE_BED_AT + HAIR_AT) <= 0.4:
		hair.wash()
