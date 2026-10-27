class_name WatchCastleRig
extends BirthdayRaidRig

## The bouncy castle of watches (allanamiento-cumple.md, "El inflable de los relojes"): Chispita hides a bag of stolen
## watches inside the castle's floor. Bouncing on it goes "clinc, clinc" (the story's own clue, on the checklist).
## Something sharp landing on it, like the cake knife by the cake, lets the air out: for FLAT_TIME seconds it lies flat
## and bounces nobody, the bag spills out, and then the kids blow it up again. Every number here is (propuesta).

const KNIFE_MODEL := preload("res://assets/models/cake_knife.glb")
const KNIFE_SIZE := Vector3(0.31, 0.02, 0.04)
const KNIFE_KG := 0.3
const FLAT_TIME := 10.0
const FLAT := 0.3
## Seconds between two "clinc" over the castle.
const CLINC_GAP := 1.0
const GOLD := Color(0.95, 0.8, 0.3)

## The bag is still inside the castle's floor.
var inside := true
var knife: Grabbable
var flat_left := 0.0
var _castle_look: Node3D
var _clinc_left := 0.0


func setup(place: BirthdayRaid) -> void:
	super.setup(place)
	_castle_look = place.get_node("Built/BouncyCastle").get_child(0)
	var bag := place.main
	bag.freeze = true
	bag.visible = false
	bag.collision_layer = 0
	knife = ClubEvidence.make_item("CakeKnife", KNIFE_MODEL, KNIFE_SIZE, KNIFE_KG)
	knife.set_meta("sharp", true)
	place.add_child(knife)
	knife.position = BirthdayRaid.CAKE_AT + Vector3(0, KNIFE_SIZE.y / 2 + 0.01, -0.5)
	var over := Area3D.new()
	over.collision_layer = 0
	over.collision_mask = 4
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(BirthdayRaid.CASTLE_HALF * 2, 1.0, BirthdayRaid.CASTLE_HALF * 2)
	shape.shape = box
	over.add_child(shape)
	over.position = BirthdayRaid.CASTLE_AT + Vector3(0, BirthdayRaid.CASTLE_FLOOR + 0.5, 0)
	place.add_child(over)
	over.body_entered.connect(_on_landed)
	place.bounced.connect(_on_bounced)


func _on_landed(body: Node3D) -> void:
	if body.has_meta("sharp") and flat_left <= 0.0 and multiplayer.is_server():
		deflate()


## Pssss: flat for FLAT_TIME seconds, and the bag spills out if it's still inside.
func deflate() -> void:
	_flatten()
	_release()


func _flatten() -> void:
	flat_left = FLAT_TIME
	party.castle_flat = true
	_castle_look.scale.y = FLAT
	party.raid.float_label(tr("BIRTHDAY_CASTLE_PSSS"), party.to_global(BirthdayRaid.CASTLE_AT + Vector3.UP * 1.5), GOLD)


func _release() -> void:
	if not inside:
		return
	inside = false
	var bag := party.main
	bag.visible = true
	bag.collision_layer = 4
	bag.freeze = false


## The kids blow it up again.
func _reinflate() -> void:
	party.castle_flat = false
	_castle_look.scale.y = 1.0
	party.kids[1].say("BIRTHDAY_KID_INFLATE")


func _on_bounced(cop: Cop) -> void:
	if not inside or _clinc_left > 0.0:
		return
	_clinc_left = CLINC_GAP
	party.raid.float_label(tr("BIRTHDAY_CLINC"), cop.global_position + Vector3.UP * 1.3, GOLD)
	party.raid.add_clue(tr("CLUE_WATCH_CASTLE"))


func _physics_process(delta: float) -> void:
	_clinc_left = maxf(_clinc_left - delta, 0.0)
	if flat_left <= 0.0:
		return
	flat_left -= delta
	if flat_left <= 0.0:
		_reinflate()


func net_state() -> Variant:
	return [inside, flat_left]


func apply_net_state(state: Variant) -> void:
	if not state[0]:
		_release()
	if state[1] > 0.0 and not party.castle_flat:
		_flatten()
	elif state[1] <= 0.0 and party.castle_flat:
		_reinflate()
	flat_left = state[1]
