class_name ReturningGiftsRig
extends BirthdayRaidRig

## The gifts that come back (allanamiento-cumple.md, "Los regalos que vuelven"): Chispita takes the birthday gifts
## back to the toy shop and resells them; the notebook of his resales is hidden. One gift on the table still has the
## shop's alarm tag: carried near the hall's front door it beeps (the story's own clue, on the checklist). While he
## entertains, Chispita slips the gifts into his case one at a time, every TAKE_EVERY seconds. Every number here is
## (propuesta).

const GIFT_MODEL := preload("res://assets/models/gift_box.glb")
const BEEPER_SIZE := Vector3(0.24, 0.18, 0.24)
const BEEPER_KG := 1.5
const BEEPER_ON := Vector3(-0.8, 0, 0.25)
const BEEP_REACH := 1.5
const BEEP_GAP := 2.0
const TAKE_EVERY := 30.0
const RED := Color(1.0, 0.35, 0.3)

## The gift with the alarm tag.
var beeper: Grabbable
var taken := 0
var take_left := TAKE_EVERY
var _beep_left := 0.0


func setup(place: BirthdayRaid) -> void:
	super.setup(place)
	beeper = ClubEvidence.make_item("AlarmGift", GIFT_MODEL, BEEPER_SIZE, BEEPER_KG)
	var look := beeper.get_child(1) as Node3D
	look.scale = Vector3.ONE * 0.8
	look.position.y = -BEEPER_SIZE.y / 2
	place.add_child(beeper)
	beeper.position = BirthdayRaid.GIFT_TABLE_AT + BEEPER_ON \
		+ Vector3.UP * (BirthdayRaid.GIFT_TABLE_SIZE.y + BEEPER_SIZE.y / 2 + 0.01)


## Where the hall's front door is, in the party's space.
static func door_at() -> Vector3:
	return Vector3(PartyHall.ENTRANCE_X, BirthdayRaid.FLOOR_TOP, PartyHall.HALF_Z)


func _physics_process(delta: float) -> void:
	if not party:
		return
	_beep_left = maxf(_beep_left - delta, 0.0)
	var at := party.to_local(beeper.global_position)
	if _beep_left <= 0.0 and Vector2(at.x - door_at().x, at.z - door_at().z).length() < BEEP_REACH:
		_beep_left = BEEP_GAP
		party.raid.float_label(tr("BIRTHDAY_GIFT_BEEP"), beeper.global_position + Vector3.UP * 0.5, RED)
		party.raid.add_clue(tr("CLUE_RETURNING_GIFTS"))
	if party.singing() or taken >= party.gifts.size() or not multiplayer.is_server():
		return
	take_left -= delta
	if take_left <= 0.0:
		take_gift()


## Chispita slips the next gift into his case, the ones on top first.
func take_gift() -> void:
	take_left = TAKE_EVERY
	taken += 1
	party.gifts[party.gifts.size() - taken].visible = false
	# Not a praise: the complaint stays, he just says it.
	party.chispita.praise(0.0, "CHISPITA_GIFT_TAKE")


func net_state() -> Variant:
	return taken


func apply_net_state(state: Variant) -> void:
	while taken < state:
		taken += 1
		party.gifts[party.gifts.size() - taken].visible = false
